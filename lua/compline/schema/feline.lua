local M = {}

-- #RRBBGG
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

M.provider = {
    oneof = {
        'string',
        'function',
        {
            table = {
                { key = 'name', value = 'string' },
                { key = 'opts', value = { table = { key = 'string', value = 'any' } } },
            },
        },
    },
}

M.separator = {
    oneof = {
        'string',
        'function',
        {
            table = {
                { key = 'str', value = 'string' },
                { key = 'hl', value = M.highlight },
                { key = 'always_visible', value = 'boolean' },
            },
        },
    },
}

M.component = {
    table = {
        { key = 'provider', value = M.provider },
        { key = 'hl', value = M.highlight },
        { key = { oneof = { 'left_sep', 'right_sep' } }, value = M.separator  },
    },
}

return M
