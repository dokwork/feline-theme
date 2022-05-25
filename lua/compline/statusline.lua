local u = require('compline.utils')
local feline = require('feline')

local Statusline = {
    active_components = {},
    inactive_components = {},
    themes = {},
    vi_mode_colors = {},
    lib = {},
}

function Statusline:new( customization)
    local x = customization or {}
    setmetatable(x, self)
    self.__index = self
    return x
end

---Takes a theme from the `self.themes` with the same key as a name
---of the current colorscheme. If no theme is found, this method will
---tries to take 'light' or 'dark' theme according to the current
---`vim.o.background` value.
function Statusline:select_theme()
    local feline_themes = require('feline.themes')
    local theme = self.themes and self.themes[vim.g.colors_name]
    theme = theme or (self.themes and self.themes[vim.o.background])
    if theme and feline_themes[theme] then
        feline.use_theme(theme)
    end
end

---@return FelineSetup # table which were used to setup feline.
function Statusline:setup()
    local config = {}
    config.components = u.build_statusline(
        self.active_components,
        self.inactive_components,
        self.lib
    )
    config.custom_providers = self.lib.providers

    local feline_themes = require('feline.themes')
    for k, v in self.themes do
        feline_themes[k] = v
    end

    feline.setup(config)

    self:select_theme()

    -- change the theme on every changes colorscheme or background
    local group = vim.api.nvim_create_augroup('compline_select_theme', { clear = true })
    vim.api.nvim_create_autocmd(
        'ColorScheme',
        { pattern = '*', group = group, callback = function() self:select_theme() end }
    )

    return config
end

return Statusline
