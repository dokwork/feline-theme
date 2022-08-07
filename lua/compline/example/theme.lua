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
