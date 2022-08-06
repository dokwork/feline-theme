local u = require('compline.utils')

-- Prepare highlight groups for sections:
-- We begin from the default background for Statusline
-- and will make it lighter for every next section:
local bg = u.get_hl_bg('Statusline') or '#5f5f5f'
local colors = {}
colors.d = u.ligthening_color(bg)
colors.c = u.ligthening_color(colors.d)
colors.b = u.ligthening_color(colors.c)
colors.a = u.ligthening_color(colors.b)

for _, line in pairs({ 'active', 'inactive' }) do
    for _, section in pairs({ 'a', 'b', 'c', 'd' }) do
        local hl_name = string.format(
            'Cl%sLeft%s',
            line:gsub('^%l', string.upper),
            section:gsub('^%l', string.upper)
        )
        vim.api.nvim_set_hl(0, hl_name, { bg = colors[section] })
    end
    for section, color in pairs({ z = 'a', y = 'b', x = 'c', w = 'd' }) do
        local hl_name = string.format(
            'Cl%sRight%s',
            line:gsub('^%l', string.upper),
            section:gsub('^%l', string.upper)
        )
        vim.api.nvim_set_hl(0, hl_name, { bg = colors[color] })
    end
end

local vi_mode_bg = function()
    return {
        fg = 'fg',
        bg = require('feline.providers.vi_mode').get_mode_color(),
    }
end

return {
    active = {
        left = {
            separators = { right = ' ' },
            a = {
                hl = vi_mode_bg,
                separators = { right = '' },
            },
            b = { separators = { right = '' } },
            c = { separators = { right = '' } },
            d = { separators = { right = '' } },
        },
        right = {
            separators = { left = ' ' },
            w = { separators = { left = '' } },
            x = { separators = { left = '' } },
            y = { separators = { left = '' } },
            z = {
                hl = vi_mode_bg,
                separators = { left = '' },
            },
        },
    },
}
