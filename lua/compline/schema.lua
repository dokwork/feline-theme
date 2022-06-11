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

local function validate_table(tbl, kv_schema, path)
    assert(type(tbl) == 'table', wrong_type('table', tbl, path))
    local path = path or ''

    local function split_list(list)
        local required = {}
        local optional = {}
        for _, v in ipairs(list) do
            if type(v) == 'table' and v.required then
                table.insert(required, v)
            else
                table.insert(optional, v)
            end
        end
        return required, optional
    end

    local function validate_single_option(unvalidated_tbl, kv_types, is_strict)
        assert(kv_types.key and kv_types.value, wrong_kv_types(kv_types, path))

        for k, v in pairs(unvalidated_tbl) do
            local path = path .. '<'
            local ok, result = M.call_validate(k, kv_types.key, path)

            if ok then
                path = path .. type_name(kv_types.key) .. ':'
                M.validate(v, kv_types.value, path)
                path = path .. '>'
                -- remove validated key
                unvalidated_tbl[k] = nil
                -- constant can bbe checked only once
                if M.is_const(kv_types.key) then
                    return true
                end
            elseif is_strict then
                error(result)
            end
        end

        return true
    end

    local function validate_required_keys(unvalidated_tbl, kv_schemas)
        for _, kv_schema in ipairs(kv_schemas) do
            validate_single_option(unvalidated_tbl, kv_schema, true)
        end
        return true
    end

    local function validate_optional_keys(unvalidated_tbl, kv_schemas)
        for _, kv_schema in ipairs(kv_schemas) do
            validate_single_option(unvalidated_tbl, kv_schema)
        end
        return true
    end

    local unvalidated_tbl = vim.tbl_extend('error', {}, tbl) -- this instance will be changed on validation
    if kv_schema.key and kv_schema.value then
        return validate_single_option(unvalidated_tbl, kv_schema, true)
    else
        local required, optional = split_list(kv_schema)
        return validate_required_keys(unvalidated_tbl, required)
            and validate_optional_keys(unvalidated_tbl, optional)
    end
end

M.is_const = function(object)
    if type(object) == 'string' and not vim.tbl_contains(M.primirives(), object) then
        return true
    end
    if type(object) == 'table' then
        return object[1] == 'const'
    end
end

---@type fun(object: any, schema: table)
--- Checks that {object} sutisfied to the {schema} or raises error.
--- You can use safe version `call_validate` to avoid error and use returned status
--- instead.
M.validate = function(object, schema, path)
    local path = path or ''
    local type_name, type_schema, type_value
    if type(schema) == 'function' then
        return M.validate(object, schema(), path)
    elseif type(schema) == 'table' then
        type_name, type_schema = next(schema)
        type_value = type_name == 'const' and type_schema or nil
    elseif M.is_const(schema) then
        type_name = 'const'
        type_value = schema
    else
        type_name = schema
    end
    if type_name == 'table' then
        assert(type(type_schema) == 'table', wrong_schema('table', type_schema, path))
        return validate_table(object, type_schema, path .. 'table')
    end
    if type_name == 'oneof' then
        assert(type(type_schema) == 'table', wrong_schema('oneof', type_schema, path))
        return validate_oneof(object, type_schema, path .. 'oneof')
    end
    if type_name == 'list' then
        return validate_list(object, type_schema, path .. 'list')
    end
    if type_name == 'const' then
        assert(object == type_value, wrong_value(type_value, object, path .. tostring(object)))
        return true
    end
    if type_name == 'any' then
        return true
    end
    return assert(
        type(object) == type_name or object == type_name,
        wrong_type(type_name, object, path .. vim.inspect(object))
    )
end

---@type fun(object: any, schema: table)
--- Wraps invocation of the `validate` to the `pcall`.
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

M.theme_separator = { oneof = {
    'string',
    M.component,
} }

M.theme_separators = {
    key = 'separators',
    value = {
        table = {
            { key = 'left', value = M.separator },
            { key = 'right', value = M.separator },
        },
    },
}

M.theme_zone = {
    table = {
        M.theme_separators,
        {
            key = 'string',
            value = { list = M.highlight },
        },
    },
}

M.theme_line = {
    table = {
        M.theme_separators,
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
        key = { onneof = { 'left', 'middle', 'right' } },
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
                table = { { key = 'default', M.theme }, { key = 'string', value = M.theme } },
            },
        },
        {
            key = ' components',
            value = { table = { key = 'string', value = M.component } },
        },
    },
}

return M
