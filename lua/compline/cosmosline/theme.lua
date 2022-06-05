local h = require('compline.highlights')

return {

    active = {
        separators = { left = ' ', right = ' ' },
        left = {
            a = h.vi_mode,
            b = { fg = 'fg', bg = 'bg' },
        },
        middle = {
            a = { fg = 'bg', bg = 'NONE' },
        },
        right = {
            separators = { right = { '|', hl = { fg = 'blue'  } } },
            a = { fg = 'fg', bg = 'bg' },
            b = { fg = 'fg', bg = 'bg' },
            c = { fg = 'fg', bg = 'bg' },
            d = { fg = 'fg', bg = 'bg' },
            e = { fg = 'fg', bg = 'bg' },
            f = h.vi_mode,
        },
    },

    inactive = {
        left = { a = { fg = 'fg', bg = 'bg' } },
    },

    vi_mode = {
        NORMAL = 'blue',
        OP = 'magenta',
        INSERT = 'green',
        VISUAL = 'magenta',
        LINES = 'magenta',
        BLOCK = 'magenta',
        REPLACE = 'violet',
        ['V-REPLACE'] = 'pink',
        ENTER = 'cyan',
        MORE = 'cyan',
        SELECT = 'yellow',
        COMMAND = 'orange',
        SHELL = 'yellow',
        TERM = 'orange',
        NONE = 'yellow',
    },

    dark = {
        fg = '#abb2bf',
        bg = '#282c34',
        yellow = '#e8a561',
        cyan = '#56b6c2',
        grey = '#5c6370',
        green = '#79a15c',
        orange = '#e5c07b',
        purple = '#5931a3',
        magenta = '#c678dd',
        blue = '#61afef',
        red = '#e06c75',
        black = '#000000',
        white = '#abb2bf',
        oceanblue = '#45707a',
        violet = '#d3869b',
        skyblue = '#7daea3',
    },

    light = {
        fg = '#565c69',
        bg = '#dbdbdb',
        yellow = '#e8a561',
        cyan = '#56b6c2',
        grey = '#abb2bf',
        green = '#79a15c',
        orange = '#ab7f2e',
        purple = '#5931a3',
        magenta = '#c678dd',
        blue = '#3974a8',
        red = '#e06c75',
        black = '#000000',
        white = '#abb2bf',
        oceanblue = '#45707a',
        violet = '#d3869b',
        skyblue = '#7daea3',
    },
}
