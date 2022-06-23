local f = require('compline.schema.feline')
local t = require('compline.schema.theme')

local M = {}

M.section = { list = 'string' }

M.zone = {
    table = {
        key = 'string',
        value = M.section,
    },
}

M.line = {
    table = {
        key = { oneof = { 'left', 'middle', 'right' } },
        value = M.zone,
    },
}

M.statusline = {
    table = {
        {
            key = { oneof = { 'active', 'inactive' } },
            value = M.line,
        },
        {
            key = 'themes',
            value = {
                table = {
                    { key = 'default', value = t.theme, required = true },
                    { key = 'string', value = t.theme },
                },
            },
            required = true,
        },
        {
            key = 'components',
            value = { table = { key = 'string', value = f.component } },
            required = true,
        },
    },
}

return M
