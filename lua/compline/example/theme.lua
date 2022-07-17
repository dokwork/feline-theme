local vi_mode_fg = function()
    return {
        fg = require('feline.providers.vi_mode').get_mode_color(),
        bg = 'bg',
    }
end

local vi_mode_bg = function()
    return {
        bg = require('feline.providers.vi_mode').get_mode_color(),
    }
end

local git_state_bg = function()
    return {
        bg = 'yellow',
    }
end

local theme = {
    active = {
        left = {
            separators = { right = ' ' },
            sections = {
                separators = { right = { '', hl = vi_mode_fg } },
                a = { hl = vi_mode_bg },
                b = { hl = git_state_bg },
            },
        },
        right = {
            separators = { left = ' ' },
            sections = {
                separators = { left = { '' } },
                d = {},
                e = { hl = vi_mode_bg, separators = { left = { '', hl = vi_mode_fg } } },
            },
        },
    },

    colors = {
        bg = '#282c34',
    },
}

return theme
