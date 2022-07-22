local vi_mode_bg = function()
    return {
        bg = require('feline.providers.vi_mode').get_mode_color(),
    }
end

local theme = {
    active = {
        left = {
            separators = { right = ' ' },
            sections = {
                separators = { right = '' },
                a = { hl = vi_mode_bg },
                b = {},
            },
        },
        right = {
            separators = { left = ' ' },
            sections = {
                separators = { left = '' },
                a = {},
                b = { hl = vi_mode_bg },
            },
        },
    },

    colors = {
        bg = '#282c34',
    },
}

return theme
