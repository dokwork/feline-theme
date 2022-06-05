local M = {}

-- const = <any not reserved string> | { const = <any not reserved string> }
-- type = 'string' | 'number' | 'boolean' | 'function' | 'any' | 'nil' | const
--      | { list = type }
--      | { oneof = [ type ] }
--      | { table = { keys = type, values = type } | [ { key = const, value = type} ] }

M.list = function()
    return {
        table = { key = 'list', value = M.type },
    }
end

M.oneof = function()
    return {
        table = { key = 'oneof', value = { table = { keys = 'number', values = M.type } } },
    }
end

M.const = function()
    return { oneof = { 'string', { table = { key = 'const', value = 'string' } } } }
end

-- stylua: ignore start
M.table = function()
    return {
        table = {
            { key = 'table', value = {
                oneof = {
                    { table = { { key = 'key', value = M.type }, { key = 'value', value = M.type } } },
                    { list = { table = { { key = 'key', value = M.type },  { key = 'value', value = M.type } } } },
                } }
            }
        }
    }
end
-- stylua: ignore end

M.primirives = function()
    return {
        'boolean',
        'string',
        'number',
        'function',
        'nil',
        'any',
    }
end

M.type = function()
    local oneof = M.primirives()
    table.insert(oneof, M.list())
    table.insert(oneof, M.table())
    table.insert(oneof, M.const())
    table.insert(oneof, M.oneof())

    return {
        oneof = oneof,
    }
end

local function wrong_type(expected, obj, path)
    return string.format(
        'Path: `%s` <- !!! Wrong type. Expected <%s>, but actual was <%s>.',
        path,
        vim.inspect(expected),
        type(obj)
    )
end

local function wrong_value(expected, actual, path)
    return string.format(
        'Path: `%s` <- !!! Wrong value "%s". Expected "%s".',
        path,
        tostring(actual),
        tostring(expected)
    )
end

local function wrong_oneof(value, options, path)
    return string.format(
        'Path: `%s` <- !!! Wrong oneof value: %s. Expected values %s.',
        path,
        vim.inspect(value),
        vim.inspect(options)
    )
end

local function wrong_kv_types(kv_types, path)
    return string.format(
        'Path: `%s` <- !!! Wrong description of the key or value in %s.',
        path,
        vim.inspect(kv_types)
    )
end

local function wrong_schema(typ, type_schema, path)
    return string.format(
        "Path: `%s` <- !!! Wrong type of the %s's schema. Expected table, but was %s",
        path,
        typ,
        type(type_schema)
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
    error('Unsupported type ' .. vim.inspect(typ))
end

local function validate_list(list, el_type, path)
    assert(type(list) == 'table', wrong_type('table', list, path))
    for i, el in ipairs(list) do
        M.validate(el, el_type, string.format('%s[%d] = ', path, i))
    end
    return true
end

local function validate_oneof(value, options, path)
    for _, opt in ipairs(options) do
        local path = path .. '?' .. type_name(opt)
        if M.call_validate(value, opt, path) then
            return true
        end
    end
    error(wrong_oneof(value, options, path))
end

local function validate_table(table, kv_schema, path)
    assert(type(table) == 'table', wrong_type('table', table, path))
    local path = path or ''

    local function validate_keys_type(tbl, kv_types)
        assert(kv_types.key and kv_types.value, wrong_kv_types(kv_types, path))

        for k, v in pairs(tbl) do
            local path = path .. '<'
            M.validate(k, kv_types.key, path)

            path = path .. type_name(kv_types.key) .. ':'
            M.validate(v, kv_types.value, path)
            path = path .. '>'
        end
    end

    if kv_schema.key or kv_schema.value then
        validate_keys_type(table, kv_schema)
    else
        local t = vim.tbl_extend('keep', {}, table)
        for _, kv in ipairs(kv_schema) do
            if M.is_const(kv.key) then
                -- all keys in tables are optional.
                -- absent expected keys should be skiped
                if t[kv.key] then
                    M.validate(t[kv.key], kv.value, path .. '.' .. kv.key)
                    -- already validated field should not be validated again
                    t[kv.key] = nil
                end
            else
                validate_keys_type(t, kv)
            end
        end
    end
    return true
end

M.is_const = function(object)
    if type(object) == 'string' and not vim.tbl_contains(M.primirives(), object) then
        return true
    end
    if type(object) == 'table' then
        return object[1] == 'const'
    end
end

M.validate = function(object, schema, path)
    local path = path or ''
    local typ, type_schema
    if type(schema) == 'function' then
        return M.validate(object, schema(), path)
    elseif type(schema) == 'table' then
        typ, type_schema = next(schema)
    elseif M.is_const(schema) then
        typ = 'const'
        type_schema = schema
    else
        typ = schema
    end
    if typ == 'table' then
        assert(type(type_schema) == 'table', wrong_schema('table', type_schema, path))
        return validate_table(object, type_schema, path .. 'table')
    end
    if typ == 'oneof' then
        assert(type(type_schema) == 'table', wrong_schema('oneof', type_schema, path))
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
        wrong_type(typ, object, path .. vim.inspect(object))
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

M.separator = { oneof = {
    'string',
    M.component,
} }

M.section = {
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
            key = 'string',
            value = { list = 'string' },
        },
    },
}

return M
