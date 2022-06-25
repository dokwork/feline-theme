local u = require('compline.utils')
local feline = u.lazy_load('feline')

local resolve_component = function(components, component_name)
    return components[component_name] or { provider = component_name }
end

local add_highlight = function(component, theme_hl)
    component.hl = component.hl or theme_hl
end

local add_separator = function(component, sections_seps, separator, side)
    local sep = separator or sections_seps[side]
    if type(sep) == 'table' then
        component[side .. '_sep'] = {
            str = sep[1],
            hl = sep.hl,
        }
    elseif type(sep) == 'string' then
        component[side .. '_sep'] = {
            str = sep,
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

---@param line table
---@param line_name string
---@param zone_name string
---@param theme table
---@param components table
local build_zone = function(line, line_name, zone_name, theme, components)
    local result = {}
    local theme_sections = vim.tbl_get(theme, line_name, zone_name, 'sections') or {}
    local sections_separators = vim.tbl_get(theme, line_name, zone_name, 'sections_separators')
        or {}
    local zone_separators = vim.tbl_get(theme, line_name, zone_name, 'zone_separators') or {}
    local sections = line[zone_name]
    sections = sections ~= 'nil' and sections or {}

    local j = 0
    -- add a left separator to the zone
    if zone_separators.left then
        j = j + 1
        result[j] = separator_as_component(zone_separators.left)
    end
    -- now, resolve components in the every section a, b, c, etc...
    for section_name, section in u.sorted_by_keys(sections) do
        -- 'nil' is an option to remove existed section when extends existed Statusline
        if section ~= 'nil' then
            local theme_section = theme_sections[section_name] or {}
            -- resolve components
            for n, component_name in ipairs(section) do
                j = j + 1
                local component = resolve_component(components, component_name)
                add_highlight(component, theme_section.hl)
                if n == 1 then
                    -- add left section's separator
                    add_separator(component, sections_separators, theme_section.ls, 'left')
                end
                if n == #section then
                    -- add right section's separator
                    add_separator(component, sections_separators, theme_section.rs, 'right')
                end
                result[j] = component
            end
        end
    end
    -- add a right separator to the zone
    if zone_separators.right then
        j = j + 1
        result[j] = separator_as_component(zone_separators.right)
    end
    return result
end

local build_line = function(statusline, line_name)
    local result = {}
    local theme = statusline.theme or {}
    local components = statusline.components or {}
    local line = statusline[line_name]
    local i = 0
    for _, zone_name in pairs({ 'left', 'middle', 'right' }) do
        i = i + 1
        result[i] = build_zone(line, line_name, zone_name, theme, components)
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

---@fun(name: string, customization: Statusline): Statusline
function Statusline:new(name, customization)
    assert(type(name) == 'string', 'Statusline must have a name.')

    local x = vim.tbl_deep_extend('force', self, customization or {})
    x.name = name
    return x
end

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

return Statusline
