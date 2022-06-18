local M = {}

-- const = <any not reserved string> | { const = <any not reserved string> }
-- type = 'string' | 'number' | 'boolean' | 'function' | 'any' | 'nil' | const
--      | { list = type }
--      | { oneof = [ type ] }
--      | { table = { keys = type, values = type } | [ { key = const, value = type} ] }

M.const = { oneof = { 'string', { table = { key = 'const', value = 'string' } } } }

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

M.key_type = { oneof = { 'string', M.const } }

-- stylua: ignore start
M.table = function()
    return {
        table = {
            { key = 'table', value = {
                oneof = {
                    { table = { { key = 'key', value = M.key_type }, { key = 'value', value = M.type } } },
                    { list = { table = { { key = 'key', value = M.key_type },  { key = 'value', value = M.type } } } },
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
    table.insert(oneof, M.const)
    table.insert(oneof, M.list())
    table.insert(oneof, M.table())
    table.insert(oneof, M.oneof())

    return {
        oneof = oneof,
    }
end

M.name_of_type = function(typ)
    if type(typ) == 'string' then
        return typ
    end
    if type(typ) == 'table' then
        local typ = next(typ)
        return typ
    end
    error('Unsupported type ' .. vim.inspect(typ))
end

local PathToError = {}

function PathToError:new(object, schema)
    local p = {}
    -- pointer to the current validated position in the object
    p.current_object = self.current_object
    p.current_object_key = self.current_object_key
    -- pointer to the current validated position in the schema
    p.current_schema = self.current_schema
    p.current_schema_key = self.current_schema_key
    setmetatable(p, {
        __index = self,
        __tostring = function(t)
            return string.format(
                '%s\nValidated value: %s\n\nValidated schema: %s',
                t.error_message or '',
                vim.inspect(t.object),
                vim.inspect(t.schema)
            )
        end,
    })
    if not (object or schema) then
        return p
    end

    -- adding a new elements to the path --

    if not p.current_schema then
        p.object = object
        p.schema = schema
        p.current_object = object
        p.current_schema = schema
    elseif p.current_schema.list then
        p.current_object[p.current_object_key] = object
        p.current_object = object
        p.current_object_key = nil
    elseif p.current_schema.table then
        local kv = p.current_schema.table[p.current_schema_key]
        if not kv or kv.value then
            -- key and value are already set, we should prepare a new key-value schema now
            kv = {}
            p.current_schema.table[p.current_schema_key] = kv
        end
        if not kv.key then
            -- we should set a key
            kv.key = schema
            p.current_object[object] = '?'
            p.current_schema = schema
            p.current_object = object
            p.current_schema_key = nil
            p.current_object_key = nil
        else
            -- a key is already set, we should set a value now
            kv.value = schema
            p.current_object[p.current_object_key] = object
            p.current_schema = schema
            p.current_object = object
            p.current_schema_key = nil
            p.current_object_key = nil
        end
    else
        p.current_object = object
        p.current_schema = schema
        p.current_object_key = nil
        p.current_schema_key = nil
    end

    return p
end

function PathToError:wrong_type(expected_type, obj)
    self.error_message = string.format(
        'Wrong type. Expected <%s>, but actual was <%s>.',
        M.name_of_type(expected_type),
        type(obj)
    )
    return self
end

function PathToError:wrong_value(expected, actual)
    self.error_message = string.format(
        'Wrong value "%s". Expected "%s".',
        tostring(actual),
        tostring(expected)
    )
    return self
end

function PathToError:wrong_oneof(value, options)
    self.error_message = string.format(
        'Wrong oneof value: %s. Expected values %s.',
        vim.inspect(value),
        vim.inspect(options)
    )
    return self
end

function PathToError:wrong_kv_types_schema(kv_types)
    self.error_message = string.format(
        "Wrong schema. It should have description for 'key' and 'value', but it doesn't: `%s`",
        vim.inspect(kv_types)
    )
    return self
end

function PathToError:wrong_schema_of(typ, type_schema)
    self.error_message = string.format(
        'Wrong schema of the %s. Expected table, but was %s.',
        typ,
        type(type_schema)
    )
    return self
end

function PathToError:required_key_not_found(kv_types, orig_table)
    self.error_message = string.format(
        'Required key `%s` was not found, or had a type of the value distinguished from `%s`\nOriginal table was:\n%s',
        vim.inspect(kv_types.key),
        vim.inspect(kv_types.value),
        vim.inspect(orig_table)
    )
    return self
end

local function validate_const(value, schema, path)
    local path = path:new(value, schema)
    if value ~= schema then
        return false, path:wrong_value(schema, value)
    end
    return path
end

local function validate_list(list, el_type, path)
    local path = path:new({}, { list = el_type })
    if type(list) ~= 'table' then
        return false, path:wrong_type('table', list)
    end

    for i, el in ipairs(list) do
        path.current_object_key = i
        local _, err = M.validate(el, el_type, path)
        if err then
            return false, err
        end
    end
    return true
end

local function validate_oneof(value, options, path)
    local path = path:new(value, { oneof = options })
    if type(options) ~= 'table' then
        return nil, path:wrong_schema_of('oneof', options)
    end
    for _, opt in ipairs(options) do
        -- we do not pass any path here to avoid adding not applicable opt
        if M.validate(value, opt) then
            return true
        end
    end
    return false, path:wrong_oneof(value, options)
end

local function validate_table(orig_tbl, kvs_schema, path)
    local path = path:new({}, { table = {} })
    if type(kvs_schema) ~= 'table' then
        return false, path:wrong_schema_of('table', kvs_schema)
    end

    if type(orig_tbl) ~= 'table' then
        return false, path:wrong_type('table', orig_tbl)
    end

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

    local function validate_key_value(unvalidated_tbl, kv_types, is_strict)
        if not (kv_types.key and kv_types.value) then
            return false, path:wrong_kv_types_schema(kv_types)
        end

        local at_least_one_passed = false

        for k, v in pairs(unvalidated_tbl) do
            path.current_object_key = k
            local _, err = M.validate(k, kv_types.key, path)
            if not err then
                _, err = M.validate(v, kv_types.value, path)
                -- if key is valid, but value is not,
                -- then validation must be failed regadles of is_strict
                if err then
                    return false, err
                end

                at_least_one_passed = true

                -- remove validated key
                unvalidated_tbl[k] = nil

                -- constant can be checked only once
                if M.is_const(kv_types.key) then
                    return true
                end
            end
        end

        if is_strict and not at_least_one_passed then
            return false, path:required_key_not_found(kv_types, unvalidated_tbl)
        end

        return true
    end

    local function validate_keys(unvalidated_tbl, kv_schemas, is_strict)
        for i, kv_schema in ipairs(kv_schemas) do
            path.current_schema_key = i
            local _, err = validate_key_value(unvalidated_tbl, kv_schema, is_strict)
            if err then
                return false, err
            end
        end
        return true
    end

    -- this instance will be changed on validation
    local unvalidated_tbl = vim.tbl_extend('error', {}, orig_tbl)
    if kvs_schema.key and kvs_schema.value then
        path.current_schema_key = 1
        return validate_key_value(unvalidated_tbl, kvs_schema, true)
    else
        local required, optional = split_list(kvs_schema)
        local _, err = validate_keys(unvalidated_tbl, required, true)
        if err then
            return false, err
        end
        return validate_keys(unvalidated_tbl, optional, false)
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
    local path = path or PathToError:new()

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
        return validate_table(object, type_schema, path)
    end
    if type_name == 'oneof' then
        return validate_oneof(object, type_schema, path)
    end
    if type_name == 'list' then
        return validate_list(object, type_schema, path)
    end
    if type_name == 'const' then
        return validate_const(object, type_value, path)
    end
    if type_name == 'any' then
        path:new(object, schema)
        return true
    end
    -- flat constants or primitives
    path = path:new(object, schema)
    local ok = type(object) == type_name or object == type_name
    if not ok then
        return false, path:wrong_type(type_name, object)
    end
    return true
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
