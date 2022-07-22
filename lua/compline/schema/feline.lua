local M = {}

M.color = 'string'

M.highlight = {
    oneof = {
        'string',
        'function',
        {
            table = {
                { key = 'fg', value = M.color },
                { key = 'bg', value = M.color },
            },
        },
    },
}

local provider = {
    table = {
        { key = 'name', value = 'string' },
        { key = 'opts', value = { table = { key = 'string', value = 'any' } } },
    },
}

M.component = {
    table = {
        { key = 'provider', value = { oneof = { 'function', 'string', provider } } },
        { key = 'hl', value = M.highlight },
    },
}

return M
