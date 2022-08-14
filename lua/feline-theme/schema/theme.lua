local feline = require('feline-theme.schema.feline')

local M = {}

M.separator = feline.separator

M.separators = {
    table = {
        { key = 'left', value = M.separator },
        { key = 'right', value = M.separator },
    },
}

M.section = {
    table = {
        { key = 'hl', value = feline.highlight },
        { key = 'separators', value = M.separators },
    },
}

M.zone = {
    table = {
        { key = 'separators', value = M.separators },
        { key = 'string', value = M.section },
    },
}

M.line = {
    table = {
        { key = 'left', value = M.zone },
        { key = 'middle', value = M.zone },
        { key = 'right', value = M.zone },
    },
}

M.vi_mode = {
    table = {
        key = {
            oneof = {
                'NORMAL',
                'OP',
                'INSERT',
                'VISUAL',
                'LINES',
                'BLOCK',
                'REPLACE',
                'V-REPLACE',
                'ENTER',
                'MORE',
                'SELECT',
                'COMMAND',
                'SHELL',
                'TERM',
                'NONE',
            },
        },
        value = feline.color,
    },
}

M.theme = {
    table = {
        { key = { oneof = { 'active', 'inactive' } }, value = M.line },
        { key = 'vi_mode', value = M.vi_mode },
    },
}

return M
