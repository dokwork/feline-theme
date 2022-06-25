local vi_mode_fg = function()
    return {
        fg = require('feline.providers.vi_mode').get_mode_color(),
        bg = 'bg',
    }
end

local vi_mode_bg = function()
    return {
        fg = 'fg',
        bg = require('feline.providers.vi_mode').get_mode_color(),
    }
end

local theme = {
    active = {
        left = {
            zone_separators = { right = { '', hl = vi_mode_fg } },
            sections_separators = { right = ' ' },
            sections = {
                a = { hl = vi_mode_bg },
                b = { hl = vi_mode_fg },
            },
        },
        right = {
            zone_separators = { left = { '', hl = vi_mode_fg } },
            sections_separators = { left = ' ' },
            sections = {
                c = { hl = vi_mode_fg },
                d = { hl = vi_mode_bg },
            },
        },
    },

    colors = {
        bg = '#282c34',
    },
}

return theme
