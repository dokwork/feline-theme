local u = require('compline.utils')
local feline = u.lazy_load('feline')

local resolve_component = function(components, component_name)
    return components[component_name] or { provider = component_name }
end

local add_highlight = function(component, theme_hl)
    component.hl = component.hl or theme_hl
end

local add_separator_to_component = function(component, separator, side)
    if type(separator) == 'table' then
        component[side .. '_sep'] = {
            str = separator[1],
            hl = separator.hl,
        }
    elseif type(separator) == 'string' then
        component[side .. '_sep'] = {
            str = separator,
        }
    end
end

local separator_as_component = function(sep)
    if type(sep) == 'string' then
        return { provider = sep }
    elseif type(sep) == 'table' then
        return { provider = sep[1], hl = sep.hl }
    else
        error('Unexpected separator: ' .. vim.inspect(sep))
    end
end

---@param section table list of the components names.
---@param section_theme table description of this section in the theme.
---@param section_separators table sections separators.
---@param components table components library.
---@param result table container for built components.
local build_section = function(section, section_theme, section_separators, components, result)
    if vim.tbl_isempty(section) then
        return
    end
    local components_separators = section_theme.separators or {}
    if section_separators.left then
        table.insert(result, separator_as_component(section_separators.left))
    end
    for n, component_name in ipairs(section) do
        local component = resolve_component(components, component_name)
        add_highlight(component, section_theme.hl)
        -- we should not add component separator to the leftmost component
        -- if a left sections separator exists
        if not section_separators.left or n > 1 then
            add_separator_to_component(component, components_separators.left, 'left')
        end
        -- we should not add component separator to the rightmost component
        -- if a right sections separator exists
        if not section_separators.right or n < #section then
            add_separator_to_component(component, components_separators.right, 'right')
        end
        table.insert(result, component)
    end
    if section_separators.right then
        table.insert(result, separator_as_component(section_separators.right))
    end
end

local build_zone = function(zone, zone_theme, components)
    local result = {}
    local zone_separators = zone_theme.separators or {}
    local sections_separators = zone_theme.sections and zone_theme.sections.separators or {}
    for section_name, section in u.sorted_by_keys(zone) do
        local section_theme = zone_theme.sections and zone_theme.sections[section_name] or {}
        build_section(section, section_theme, sections_separators, components, result)
    end

    -- add left zone separator
    if zone_separators.left then
        local sep = separator_as_component(zone_separators.left)
        if sections_separators.left then
            -- we should override added previously section separator
            result[1] = sep
        else
            result = { sep, unpack(result) }
        end
    end

    -- add right zone separator
    if zone_separators.right then
        local sep = separator_as_component(zone_separators.right)
        if sections_separators.right then
            -- we should override added previously section separator
            result[#result] = sep
        else
            table.insert(result, sep)
        end
    end

    return result
end

---@param line_name string active or inactive.
local build_line = function(statusline, line_name)
    local result = {}
    local theme = statusline.theme and statusline.theme[line_name] or {}
    local components = statusline.components or {}
    local line = statusline[line_name]
    local i = 0
    for _, zone_name in pairs({ 'left', 'middle', 'right' }) do
        i = i + 1
        if line[zone_name] then
            result[i] = build_zone(line[zone_name], theme[zone_name] or {}, components)
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
    themes = {},
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
    self.theme = self.themes and (self.themes[vim.g.colors_name] or self.themes.default)

    local result = {}
    for _, line_name in ipairs({ 'active', 'inactive' }) do
        local line = self[line_name]
        if line and line ~= 'nil' then
            result[line_name] = build_line(self, line_name)
        end
    end
    return result
end

function Statusline:select_theme()
    local feline_themes = require('feline.themes')
    local background = vim.o.background or 'colors'
    local theme = string.format('%s_%s_%s', self.name, vim.g.colors_name, background)
    local default = string.format('%s_%s_%s', self.name, 'default', background)

    theme = feline_themes[theme] or feline_themes[default]
    if theme then
        feline.use_theme(theme)
        return
    end
end

---@return FelineSetup # table which were used to setup feline.
function Statusline:setup()
    local config = {}
    config.components = self:build_components()
    config.vi_mode_colors = self.theme.vi_mode

    feline.setup(config)

    local feline_themes = require('feline.themes')
    for theme_name, theme in pairs(self.themes) do
        feline_themes[self.name .. '_' .. theme_name .. '_colors'] = theme.colors
        feline_themes[self.name .. '_' .. theme_name .. '_dark'] = theme.dark
        feline_themes[self.name .. '_' .. theme_name .. '_light'] = theme.light
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

        local x = vim.tbl_extend('keep', statusline, Statusline)
        x.name = name
        return x
    end,
}
