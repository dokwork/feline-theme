local f = require('compline.schema.feline')

local M = {}

M.separator = {
    oneof = {
        'string',
        {
            table = {
                { key = 1, value = 'string', required = true },
                { key = 'hl', value = f.highlight },
            },
        },
    },
}

M.sections = {
    table = {
        key = 'string',
        value = {
            table = {
                { key = 'hl', value = f.highlight, required = true },
                { key = { oneof = { 'sr', 'sl' } }, value = M.separator },
            },
        },
    },
}

M.zone = {
    table = {
        {
            key = 'separators',
            value = {
                table = {
                    { key = 'left', value = M.separator },
                    { key = 'right', value = M.separator },
                },
            },
        },
        {
            key = 'sections',
            value = M.sections,
            required = true
        },
    },
}

M.line = {
    table = {
        { key = { oneof = { 'left, middle', 'right' } }, value = M.zone },
    },
}

M.colors = {
    table = { key = 'string', value = 'string' },
}

M.vi_mode = {
    table = {
        key = { oneof = { 'NORMAL', 'OP', 'INSERT', 'VISUAL', 'LINES', 'BLOCK', 'REPLACE' } },
        value = 'string',
    },
}

M.theme = {
    table = {
        { key = { oneof = { 'active', 'inactive' } }, value = M.line },
        { key = 'dark', value = M.colors, required = true },
        { key = 'light', value = M.colors, required = true },
        { key = 'vi_mode', value = M.vi_mode, reqired = true },
    },
}

return M
