local vi_mode_bg = function()
    return {
        bg = require('feline.providers.vi_mode').get_mode_color(),
    }
end

local vi_mode_fg = function(bg)
    return function()
        return {
            fg = require('feline.providers.vi_mode').get_mode_color(),
            bg = bg,
        }
    end
end

return {
    active = {
        left = {
            separators = { right = ' ' },
            a = {
                hl = vi_mode_bg,
                separators = { right = { str = '', hl = vi_mode_fg('b') } },
            },
            b = {
                hl = { bg = 'b' },
                separators = { right = { str = '', hl = { fg = 'b', bg = 'c' } } },
            },
            c = {
                hl = { bg = 'c' },
                separators = { right = { str = '', hl = { fg = 'c', bg = 'd' } } },
            },
            d = {
                hl = { bg = 'd' },
                separators = { right = { str = '', hl = { fg = 'd', bg = 'bg' } } },
            },
        },
        right = {
            separators = { left = ' ' },
            w = {
                hl = { bg = 'w' },
                separators = { left = { str = '', hl = { bg = 'bg' } } },
            },
            x = {
                hl = { bg = 'x' },
                separators = { left = { str = '', hl = { bg = 'w' } } },
            },
            y = {
                hl = { bg = 'y' },
                separators = { left = { str = '', hl = { bg = 'x' } } },
            },
            z = {
                hl = vi_mode_bg,
                separators = { left = { str = '', hl = vi_mode_fg('y') } },
            },
        },
    },

    vi_mode = {
        NORMAL = 'green',
        OP = 'magenta',
        INSERT = 'blue',
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
}
