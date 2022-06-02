local u = require('compline.utils')
local feline = u.lazy_load('feline')

local Statusline = {
    -- user should be able to not specify components in some case at all
    active = nil,
    inactive = nil,
    lib = {},
}

---@fun(name: string, customization: Statusline): Statusline
function Statusline:new(name, customization)
    assert(type(name) == 'string', 'Statusline must have a name.')

    local x = vim.tbl_deep_extend('force', self, customization or {})
    setmetatable(x, self)
    self.__index = self
    x.name = name
    return x
end

function Statusline:select_theme()
    local feline_themes = require('feline.themes')
    local background = vim.o.background or 'dark'
    local theme = string.format("%s_%s_%s", self.name, vim.g.colors_name, background)
    local default = string.format("%s_%s_%s", self.name, 'default', background)

    theme = feline_themes[theme] or feline_themes[default]
    if theme then
        feline.use_theme(theme)
        return
    end
end

function Statusline:build_components()
    self.theme = self.themes and (self.themes[vim.g.colors_name] or self.themes.default)

    return {
        active = u.build_line(self.active, self.lib, self.theme),
        inactive = u.build_line(self.inactive, self.lib, self.theme),
    }
end

---@return FelineSetup # table which were used to setup feline.
function Statusline:setup()
    local config = {}
    config.components = self:build_components()
    config.custom_providers = self.lib.providers
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
