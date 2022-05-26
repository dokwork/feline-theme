local u = require('compline.utils')
local feline = require('feline')

local Statusline = {
    -- user should be able to not specify components in some case at all
    active_components = nil,
    inactive_components = nil,
    themes = {},
    vi_mode_colors = {},
    lib = {},
}

---@fun(name: string, customization: Statusline): Statusline
function Statusline:new(name, customization)
    assert(type(name) == 'string', 'Statusline must have an uniq name.')

    local x = customization or {}
    setmetatable(x, self)
    self.__index = self
    x.name = name
    return x
end

---Takes a theme from the `self.themes` with the same key as a name
---of the current colorscheme. If no theme is found, this method will
---tries to take 'light' or 'dark' theme according to the current
---`vim.o.background` value.
function Statusline:select_theme()
    local s = self.name .. '_'
    local feline_themes = require('feline.themes')
    if vim.g.colors_name and feline_themes[s .. vim.g.colors_name] then
        return feline.use_theme(s .. vim.g.colors_name)
    end
    if vim.o.background and feline_themes[s .. vim.o.background] then
        return feline.use_theme(s .. vim.o.background)
    end
end

function Statusline:build_components()
    return {
        active = u.build_statusline(self.active_components, self.lib),
        inactive = u.build_statusline(self.inactive_components, self.lib),
    }
end

---@return FelineSetup # table which were used to setup feline.
function Statusline:setup()
    local config = {}
    config.components = self:build_components()
    config.custom_providers = self.lib.providers
    config.vi_mode_colors = self.vi_mode_colors

    feline.setup(config)

    local feline_themes = require('feline.themes')
    for k, v in pairs(self.themes) do
        feline_themes[self.name .. '_' .. k] = v
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
