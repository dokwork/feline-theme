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

M.component = {
    table = {
        { key = 'provider', value = { oneof = { 'function', 'string' } } },
        { key = 'hl', value = M.highlight },
    },
}

M.theme_separator = { oneof = {
    'string',
    M.component,
} }

local theme_separators = {
    key = 'separators',
    value = {
        table = {
            { key = 'left', value = M.theme_separator },
            { key = 'right', value = M.theme_separator },
        },
    },
}

M.theme_zone = {
    table = {
        theme_separators,
        {
            key = 'string',
            value = M.highlight,
            required = true,
        },
    },
}

M.theme_line = {
    table = {
        theme_separators,
        { key = { oneof = { 'left, middle', 'right' } }, value = M.theme_zone },
    },
}

M.theme_colors = {
    table = { key = 'string', value = M.color },
}

M.theme_vi_mode = {
    table = {
        key = { oneof = { 'NORMAL', 'OP', 'INSERT', 'VISUAL', 'LINES', 'BLOCK', 'REPLACE' } },
        value = 'string',
    },
}

M.theme = {
    table = {
        { key = { oneof = { 'active', 'inactive' } }, value = M.theme_line },
        { key = 'dark', value = M.theme_colors, required = true },
        { key = 'light', value = M.theme_colors, required = true },
        { key = 'vi_mode', value = M.theme_vi_mode, reqired = true },
    },
}

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
                    { key = 'default', value = M.theme, required = true },
                    { key = 'string', value = M.theme },
                },
            },
            required = true,
        },
        {
            key = 'components',
            value = { table = { key = 'string', value = M.component } },
            required = true,
        },
    },
}

return M
