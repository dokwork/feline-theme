local u = require('feline-theme.utils')

-- Prepare colors for sections:
-- We begin from the default background for Statusline
-- and will make it lighter/darker (depends on vim.go.background)
-- for every next section
local gradient_colors = function()
    local function change(color)
        if vim.go.background == 'light' then
            return u.darkening_color(color, 0.4, 0.3, 0.1)
        else
            return u.ligthening_color(color, 0.2, 0.2, 0.3)
        end
    end
    local colors = {}
    colors.fg = vim.go.background == 'light' and 'White' or 'Black'
    colors.bg = u.get_hl_bg('Statusline')
        or (vim.go.background == 'light' and '#c8c8cd' or '#505050')
    colors.d = change(colors.bg)
    colors.c = change(colors.d)
    colors.b = change(colors.c)
    colors.a = change(colors.b)

    colors.z = colors.a
    colors.y = colors.b
    colors.x = colors.c
    colors.w = colors.d

    return colors
end

return {
    default = gradient_colors,
}
