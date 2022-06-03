local u = require('compline.utils')
local feline = u.lazy_load('feline')

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

function Statusline:select_theme()
    local feline_themes = require('feline.themes')
    local background = vim.o.background or 'dark'
    local theme = string.format('%s_%s_%s', self.name, vim.g.colors_name, background)
    local default = string.format('%s_%s_%s', self.name, 'default', background)

    theme = feline_themes[theme] or feline_themes[default]
    if theme then
        feline.use_theme(theme)
        return
    end
end

local get_sep = function(theme, state_name, zone, side)
    local sep = side and vim.tbl_get(theme, state_name, zone, 'separators', side)
        or vim.tbl_get(theme, state_name, 'separators', zone)

    if not sep then
        return nil
    elseif type(sep) == 'string' then
        return { provider = sep }
    elseif type(sep) == 'table' then
        return { provider = sep[1], hl = sep.hl }
    else
        return error(
            string.format(
                'Illegal type [%s] of the separator for the %s %s zone.',
                type(sep),
                state_name,
                zone
            )
        )
    end
end

local build_line = function(self, state_name)
    local result = {}
    local theme = self.theme or {}
    local components = self.components or {}
    local line = self[state_name]
    local i = 0
    for _, zone in pairs({ 'left', 'middle', 'right' }) do
        local sections = line[zone]
        local zone_sep = get_sep(theme, state_name, zone)
        sections = sections ~= 'nil' and sections or {}
        i = i + 1
        result[i] = {}
        local j = 0
        -- add separator to the right zone
        if zone == 'right' and zone_sep then
            j = j + 1
            result[i][j] = zone_sep
        end
        -- now, resolve components in the every section a, b, c, etc...
        for char, section in u.sorted_by_keys(sections) do
            -- 'nil' is an option to remove existed section when extends existed Statusline
            if section ~= 'nil' then
                -- getting optional separators
                local section_left_sep = get_sep(theme, state_name, zone, 'left')
                local section_right_sep = get_sep(theme, state_name, zone, 'right')

                -- add a new component as the left section's separator
                if section_left_sep then
                    j = j + 1
                    result[i][j] = section_left_sep
                end

                -- resolve components
                for _, component_name in ipairs(section) do
                    j = j + 1
                    local component = components[component_name] or { provider = component_name }
                    component.hl = component.hl or vim.tbl_get(theme, state_name, zone, char)
                    result[i][j] = component
                end

                -- add a new component as the right section's separator
                if section_right_sep then
                    j = j + 1
                    result[i][j] = section_right_sep
                end
            end
        end
        -- add separator to the left zone
        if zone == 'left' and zone_sep then
            result[i][j + 1] = zone_sep
        end
    end
    return result
end

function Statusline:build_components()
    self.theme = self.themes and (self.themes[vim.g.colors_name] or self.themes.default)

    local result = {}
    for _, state_name in ipairs({ 'active', 'inactive' }) do
        local line = self[state_name]
        if line and line ~= 'nil' then
            result[state_name] = build_line(self, state_name)
        end
    end
    return result
end

---@return FelineSetup # table which were used to setup feline.
function Statusline:setup()
    local config = {}
    config.components = self:build_components()
    config.vi_mode_colors = self.theme.vi_mode

    feline.setup(config)

    local feline_themes = require('feline.themes')
    for theme_name, theme in pairs(self.themes) do
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
