local p = require('feline.providers.vi_mode')

local vi_mode_fg = function()
    return {
        name = p.get_mode_highlight_name(),
        fg = p.get_mode_color(),
        bg = 'bg',
        style = 'bold',
    }
end

local vi_mode_bg = function()
    return {
        name = p.get_mode_highlight_name(),
        fg = 'fg',
        bg = p.get_mode_color(),
        style = 'bold',
    }
end

local theme = {
    active = {
        left = {
            separators = { right = { '', hl = vi_mode_fg } },
            sections = {
                a = { hl = vi_mode_bg, rs = ' ' },
                b = { hl = vi_mode_fg, rs = ' ' }
            },
        },
        right = {
            separators = { left = { '', hl = vi_mode_fg } },
            sections = {
                c = { hl = vi_mode_fg, ls = ' ' },
                d = { hl = vi_mode_bg, ls = ' ' },
            },
        },
    },

    dark = {
        bg = '#282c34'
    }
}

return theme
