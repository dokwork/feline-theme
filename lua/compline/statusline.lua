local u = require('compline.utils')
local feline = u.lazy_load('feline')

---@param statusline table a full description of the statusline
---@param line_name string active or inactive.
---@param zone_name string left or middle or right.
---@param section_name string the name of the section: a or b or c and etc.
---@param result table container for built components.
local build_section = function(statusline, line_name, zone_name, section_name, result)
    local zone = vim.tbl_get(statusline, line_name, zone_name)
    local section = zone and zone[section_name]
    -- empty section. Skip build
    if vim.tbl_isempty(section) then
        return
    end

    local zone_theme = vim.tbl_get(statusline, 'theme', line_name, zone_name) or {}
    local section_theme = zone_theme[section_name] or {}
    local section_separators = section_theme.separators or {}

    local add_highlight = function(component)
        if section_theme.hl then
            component.hl = section_theme.hl
        else
            component.hl = string.format(
                'Cl%s%s%s',
                line_name:gsub('^%l', string.upper),
                zone_name:gsub('^%l', string.upper),
                section_name:gsub('^%l', string.upper)
            )
            if not pcall(vim.api.nvim_get_hl_by_name, component.hl, false) then
                vim.api.nvim_set_hl(0, component.hl, { link = 'Statusline' })
            end
        end
    end

    local first_component = #result + 1
    -- here we're building components stubs, which will be partially overrided later
    for _, component_name in ipairs(section) do
        local component = { name = component_name }
        add_highlight(component)
        table.insert(result, component)
    end
    local last_component = #result
    -- render section separators
    if #result >= first_component then
        result[first_component]['left_sep'] = section_separators.left
        result[last_component]['right_sep'] = section_separators.right
    end
end

---@param statusline table a full description of the statusline
---@param line_name string active or inactive.
---@param zone_name string left or middle or right.
---@return table[] # resolved components inside zone.
local build_zone = function(statusline, line_name, zone_name)
    local result = {}
    local zone = vim.tbl_get(statusline, line_name, zone_name)
    local zone_theme = vim.tbl_get(statusline, 'theme', line_name, zone_name) or {}
    local zone_separators = zone_theme.separators or {}

    -- adds `always_visible` property to the separator
    local function always_visible(sep)
        if type(sep) == 'table' then
            sep.always_visible = true
            return sep
        else
            return { str = sep, always_visible = true }
        end
    end

    -- build component stubs for every section
    for section_name in u.sorted_by_keys(zone) do
        build_section(statusline, line_name, zone_name, section_name, result)
    end

    -- add left zone separator
    if #result > 0 and zone_separators.left then
        result[1].left_sep = always_visible(zone_separators.left)
    end

    -- add right zone separator
    if #result > 0 and zone_separators.right then
        result[#result].right_sep = always_visible(zone_separators.right)
    end

    -- finally resolve components
    local components = statusline.components or {}
    for i, stub in ipairs(result) do
        local component = components[stub.name]
        if component then
            result[i] = vim.tbl_extend('force', stub, component)
        else
            stub.provider = stub.name
        end
    end

    return result
end

---@param statusline table a full description of the statusline.
---@param line_name string active or inactive.
---@return table[] # description of the statusline in term of feline.
local build_line = function(statusline, line_name)
    local result = {}
    for i, zone_name in ipairs({ 'left', 'middle', 'right' }) do
        if statusline[line_name][zone_name] then
            result[i] = build_zone(statusline, line_name, zone_name)
        else
            result[i] = {}
        end
    end
    return result
end

local Statusline = {
    -- user should be able to not specify components in some case at all
    active = nil,
    inactive = nil,
    components = {},
    theme = {},
    colors = { default = {} }
}

function Statusline:validate()
    local statusline_schema = require('compline.schema.statusline').statusline
    local ok, schema = pcall(require, 'compline.schema')
    if not ok then
        error('To validate statusline schema, "compline.schema" module should be installed.')
    end
    local ok, err = schema.validate(self, statusline_schema)

    assert(ok, tostring(err))
end

function Statusline:build_components()
    local result = {}
    for _, line_name in ipairs({ 'active', 'inactive' }) do
        if self[line_name] then
            result[line_name] = build_line(self, line_name)
        end
    end
    return result
end

function Statusline:show_components()
    vim.pretty_print(self:build_components())
end

function Statusline:select_theme()
    local feline_themes = require('feline.themes')
    local colorscheme = string.format('%s_%s', self.name, vim.g.colors_name)
    local background = string.format('%s_%s', self.name, vim.o.background)
    local default = string.format('%s_%s', self.name, 'default')

    colorscheme = feline_themes[colorscheme] or feline_themes[background] or feline_themes[default]
    if colorscheme then
        feline.use_theme(colorscheme)
        return
    end
end

---@return FelineSetup # table which were used to setup feline.
function Statusline:setup()
    local config = {}
    config.components = self:build_components()
    config.vi_mode_colors = self.colors.default.vi_mode

    feline.setup(config)

    local feline_themes = require('feline.themes')
    for colors_name, colors in pairs(self.colors) do
        feline_themes[self.name .. '_' .. colors_name] = colors
    end

    self:select_theme()

    -- change the theme on every changes colorscheme or background
    local group = vim.api.nvim_create_augroup('compline_select_theme', { clear = true })
    vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        group = group,
        callback = function()
            self:select_theme()
        end,
    })

    return config
end

return {
    new = function(name, statusline)
        assert(type(name) == 'string', 'Statusline must have a name.')

        statusline.name = name
        setmetatable(statusline, {
            __index = Statusline,
        })
        return statusline
    end,
}
