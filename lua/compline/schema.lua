local M = {}

-- const = <any not reserved string> | { const = <any not reserved string> }
-- type = 'string' | 'number' | 'boolean' | 'function' | 'table' | 'any' | 'nil' | const
--      | { list = type }
--      | { oneof = [ type ] }
--      | { table = { keys = type, values = type } | [ { key = const, value = type} ] }

M.list = function()
    return {
        table = { { key = 'list', value = M.type } },
    }
end

M.oneof = function()
    return {
        table = { { key = 'oneof', value = { table = { keys = 'number', values = M.type } } } },
    }
end

M.const = function()
    return { oneof = { 'string', { table = { { key = 'const', value = 'string' } } } } }
end

-- stylua: ignore start
M.table = function()
    return {
        table = {
            { key = 'table', value = {
                oneof = {
                    { table = { { key = 'keys', value = M.type }, { key = 'values', value = M.type } } },
                    { list = { table = { { key = 'key', value = M.const },  { key = 'value', value = M.type } } } },
                } }
            }
        }
    }
end
-- stylua: ignore end

M.type = function()
    return {
        oneof = {
            'boolean',
            'string',
            'number',
            'function',
            'nil',
            'any',
            M.list(),
            M.table(),
            M.const(),
            M.oneof(),
        },
    }
end

local function wrong_type(expected, obj, path)
    return string.format(
        'Path: %s <- !!! Wrong type. Expected <%s>, but actual was <%s>.',
        path,
        expected,
        type(obj)
    )
end

local function wrong_value(expected, actual, path)
    return string.format(
        'Path: %s <- !!! Wrong value %s. Expected %s.',
        path,
        tostring(actual),
        tostring(expected)
    )
end

local function wrong_oneof(value, options, path)
    return string.format(
        'Path: %s <- !!! Wrong oneof value %s. Expected values %s.',
        path,
        tostring(value),
        vim.inspect(options)
    )
end

local function type_name(typ)
    if type(typ) == 'string' then
        return typ
    end
    if type(typ) == 'table' then
        local typ = next(typ)
        return typ
    end
    error('Wrong type of the key: ' .. type(typ))
end

local function validate_list(list, el_type, path)
    for i, el in ipairs(list) do
        M.validate(el, el_type, string.format('%s[%d] = ', path, i))
    end
    return true
end

local function validate_oneof(value, options, path)
    for _, opt in ipairs(options) do
        if M.call_validate(value, opt, path) then
            return true
        end
    end
    error(wrong_oneof(value, options, path))
end

local function validate_table(table, kv_schema, path)
    assert(type(table) == 'table', wrong_type('table', table, path))
    local path = path or ''
    if kv_schema.keys and kv_schema.values then
        for k, v in pairs(table) do
            path = path .. '<'
            M.validate(k, kv_schema.keys, path)

            path = path .. type_name(kv_schema.keys) .. ':'
            M.validate(v, kv_schema.values, path)
            path = path .. '>'
        end
    else
        for _, kv in ipairs(kv_schema) do
            if table[kv.key] then
                M.validate(table[kv.key], kv.value, path .. '.' .. kv.key)
            end
        end
    end
    return true
end

M.validate = function(object, schema, path)
    local path = path or ''
    local typ, type_schema
    if type(schema) == 'table' then
        typ, type_schema = next(schema)
    else
        typ = schema
    end
    if typ == 'table' then
        assert(
            type(type_schema) == 'table',
            'Wrong type of the table schema: ' .. type(type_schema)
        )
        return validate_table(object, type_schema, path .. 'table')
    end
    if typ == 'oneof' then
        assert(
            type(type_schema) == 'table',
            'Wrong type of the oneof schema: ' .. type(type_schema)
        )
        return validate_oneof(object, type_schema, path .. 'oneof')
    end
    if typ == 'list' then
        return validate_list(object, type_schema, path .. 'list')
    end
    if typ == 'const' then
        assert(object == type_schema, wrong_value(type_schema, object, path .. tostring(object)))
        return true
    end
    if typ == 'any' then
        return true
    end
    return assert(
        type(object) == typ or object == typ,
        wrong_type(typ, object, path .. tostring(object))
    )
end

M.call_validate = function(object, schema, path)
    return pcall(M.validate, object, schema, path)
end

M.color = 'string'

M.highlight = {
    oneof = {
        'string',
        'function',
        { table = { { key = 'fg', value = M.color }, { key = 'bg', value = M.color } } },
    },
}

M.component = {
    table = {
        { key = 'provider', value = { oneof = { 'function', 'string' } } },
        { key = 'hl', value = M.highlight },
    },
}

M.separator = { {
    'string',
    { table = { { key = 'hl', value = M.highlight } } },
} }

M.zone = {
    table = {
        {
            key = 'separators',
            value = {
                table = {
                    { key = 'left', value = M.component },
                    { key = 'right', value = M.component },
                },
            },
        },
    },
}

return M
