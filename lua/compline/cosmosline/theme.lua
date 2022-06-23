local h = require('compline.highlights')

return {
 -- TODO right zone should be rendered from the right to the left
    active = {
        left = {
            separators = { right = { ' ', hl = { fg = 'bg', bg = 'NONE' } } },
            sections = {
                a = { hl = h.vi_mode },
                b = { hl = { fg = 'fg', bg = 'bg' } },
            },
        },
        middle = {
            sections = {
                a = { fg = 'bg', bg = 'NONE' },
            },
        },
        right = {
            separators = { left = { ' ', hl = { fg = 'bg', bg = 'NONE' } } },
            sections = {
                a = { hl = { fg = 'fg', bg = 'bg' }, rs = { ' | ', hl = { fg = 'blue' } } },
                b = { hl = { fg = 'fg', bg = 'bg' }, rs = { ' | ', hl = { fg = 'blue' } } },
                c = { hl = { fg = 'fg', bg = 'bg' }, rs = { ' | ', hl = { fg = 'blue' } } },
                d = { hl = { fg = 'fg', bg = 'bg' }, rs = { ' | ', hl = { fg = 'blue' } } },
                e = { hl = { fg = 'fg', bg = 'bg' }, rs = { ' | ', hl = { fg = 'blue' } } },
                f = { hl = h.vi_mode },
            },
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
