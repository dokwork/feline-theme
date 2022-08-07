local h = require('compline.highlights')

return {
    active = {
        left = {
            separators = { right = { str = ' ', hl = { fg = 'bg', bg = 'NONE' } } },
            a = { hl = h.vi_mode },
            b = { hl = { fg = 'fg', bg = 'bg' } },
        },
        middle = {
            a = { fg = 'bg', bg = 'NONE' },
        },
        right = {
            separators = { left = { str = ' ', hl = { fg = 'bg', bg = 'NONE' } } },
            u = {
                hl = { fg = 'fg', bg = 'bg' },
                separators = { right = { str = ' | ', hl = { fg = 'blue' } } },
            },
            v = {
                hl = { fg = 'fg', bg = 'bg' },
                separators = { right = { str = ' | ', hl = { fg = 'blue' } } },
            },
            w = {
                hl = { fg = 'fg', bg = 'bg' },
                separators = { right = { str = ' | ', hl = { fg = 'blue' } } },
            },
            x = {
                hl = { fg = 'fg', bg = 'bg' },
                separators = { right = { str = ' | ', hl = { fg = 'blue' } } },
            },
            y = {
                hl = { fg = 'fg', bg = 'bg' },
                separators = { right = { str = ' | ', hl = { fg = 'blue' } } },
            },
            z = { hl = h.vi_mode },
        },
    },

    inactive = {
        left = { a = { fg = 'fg', bg = 'bg' } },
    },
}
