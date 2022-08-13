local feline = require('compline.schema.feline')

local M = {}

M.component = 'string'

M.section = { list = M.component }

M.zone = {
    table = {
        -- usually chars are used as name of the section
        key = 'string',
        value = M.section,
    },
}

M.line = {
    table = {
        { key = 'left', value = M.zone },
        { key = 'middle', value = M.zone },
        { key = 'right', value = M.zone },
    },
}

M.statusline = {
    table = {
        { key = 'active', value = M.line },
        { key = 'inactive', value = M.line },
        { key = 'theme', value = require('compline.schema.theme').theme },
        { key = 'colors', value = require('compline.schema.colors').colors },
        {
            key = 'components',
            value = { table = { key = 'string', value = feline.component } },
        },
    },
}

return M
