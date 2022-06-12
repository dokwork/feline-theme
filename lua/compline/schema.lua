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

local Path = {}

function Path:new()
    local x = {
        -- validated object's path
        object = self.object or {},
        -- validated schema's path
        schema = self.schema or {},
    }
    -- pointer to the current validated position in the object
    x.object_head = self.object_head or x.object
    -- pointer to the current validated position in the schema
    x.schema_head = self.schema_head or x.schema
    setmetatable(x, {
        __index = self,
        __tostring = function(t)
            -- remove wrappers to make an output more clear
            local _, object = next(t.object)
            local _, schema = next(t.schema)
            return string.format(
                '%s\nValidated value: %s\n\nValidated schema: %s',
                t.error_message or '',
                vim.inspect(object),
                vim.inspect(schema)
            )
        end,
    })
    return x
end

function Path:add_const(value, schema)
    if not self.object_head_key then
        self.object_head = value
    else
        self.object_head[self.object_head_key] = value
    end
    self.schema_head = schema
end

function Path:new_oneof()
    table.insert(self.object_head, {})
    local options = {}
    table.insert(self.schema_head, { oneof = options })
    self.schema_head = options
end

function Path:add_oneof(value, options)
    table.insert(self.object_head, value)
    table.insert(self.schema_head, options)
end

function Path:new_list(schema)
    if type(schema) ~= 'table' then
        table.insert(self.schema_head, { list = schema })
        return false, self:wrong_schema_of('list', schema)
    end

    local elements = {}
    table.insert(self.schema_head, { list = elements })
    self.schema_head = elements
end

function Path:add_to_list(el, el_type)
    table.insert(self.object_head, el)
    table.insert(self.schema_head, el_type)
end

---@param schema table|table[] or list of key-value schemas, or key-value schema of all table
function Path:new_table(schema)
    if type(schema) ~= 'table' then
        table.insert(self.schema_head, { table = schema })
        return false, self:wrong_schema_of('table', schema)
    end

    table.insert(self.object_head, {})
    local root = {}
    table.insert(self.schema_head, { table = root })
    self.schema_head = root
end

---@param schema table `{ key = type, value = type }`
function Path:new_schema_kv(schema)
    if not (schema.key and schema.value) then
        table.insert(self.schema_head, schema)
        return false, self:wrong_kv_types_schema(schema)
    end

    local kv = {}
    table.insert(self.schema_head, kv)
    self.schema_head = kv
end

function Path:add_key(key_object, key_schema)
    self.object_head_key = key_object
    self.object_head[key_object] = '?'
    self.schema_head.key = key_schema
end

function Path:add_value(value_object, value_schema)
    self.object_head[self.object_head_key] = value_object
    self.object_head_key = nil
    self.schema_head.value = value_schema
end

function Path:wrong_type(expected_type, obj)
    self.error_message = string.format(
        'Wrong type. Expected <%s>, but actual was <%s>.',
        M.name_of_type(expected_type),
        type(obj)
    )
    return self
end

function Path:wrong_value(expected, actual)
    self.error_message = string.format(
        'Wrong value "%s". Expected "%s".',
        tostring(actual),
        tostring(expected)
    )
    return self
end

function Path:wrong_oneof(value, options)
    self.error_message = string.format(
        'Wrong oneof value: %s. Expected values %s.',
        vim.inspect(value),
        vim.inspect(options)
    )
    return self
end

function Path:wrong_kv_types_schema(kv_types)
    self.error_message = string.format(
        "Wrong schema. It should have description for 'key' and 'value', but it doesn't: %s",
        vim.inspect(kv_types)
    )
    return self
end

function Path:wrong_schema_of(typ, type_schema)
    self.error_message = string.format(
        'Wrong schema of the %s. Expected table, but was %s.',
        typ,
        type(type_schema)
    )
    return self
end

function Path:required_key_not_found(kv_types)
    self.error_message = string.format(
        'Required key %s was not found, or had type of the value distinguished from %s',
        kv_types.key,
        kv_types.value
    )
    return self
end

local function validate_list(list, el_type, path)
    local path = path:new()

    local _, err = path:new_list(el_type)
    if err then
        return false, err
    end

    for _, el in ipairs(list) do
        path:add_to_list(el, el_type)
        M.validate(el, el_type, path)
    end
end

local function validate_oneof(value, options, path)
    local path = path:new()
    for _, opt in ipairs(options) do
        if M.validate(value, opt, path) then
            path:add_oneof(value, options)
            return true
        end
    end
    return false, path:wrong_oneof(value, options)
end

local function validate_table(orig_tbl, kvs_schema, path)
    local path = path:new()

    local _, err = path:new_table(kvs_schema)
    if err then
        return false, err
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

    local function validate_single_option(unvalidated_tbl, kv_types, is_strict)
        local _, err = path:new_schema_kv(kv_types)
        if err then
            return false, err
        end

        local at_least_one_passed = false

        for k, v in pairs(unvalidated_tbl) do
            path:add_key(k, kv_types.key)
            _, err = M.validate(k, kv_types.key, path)
            if err then
                return false, err
            end

            path:add_value(v, kv_types.value)
            _, err = M.validate(v, kv_types.value, path)
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

        if is_strict and not at_least_one_passed then
            return false, path:required_key_not_found(kv_types)
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

    local unvalidated_tbl = vim.tbl_extend('error', {}, orig_tbl) -- this instance will be changed on validation
    if kvs_schema.key and kvs_schema.value then
        return validate_single_option(unvalidated_tbl, kvs_schema, true)
    else
        local required, optional = split_list(kvs_schema)
        local _, err = validate_required_keys(unvalidated_tbl, required)
        if err then
            return false, err
        end
        return validate_optional_keys(unvalidated_tbl, optional)
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
    local path = path and path:new() or Path:new()

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
        path:new_oneof()
        if type(type_schema) ~= 'table' then
            return false, path:wrong_schema('oneof', type_schema)
        end
        return validate_oneof(object, type_schema, path)
    end
    if type_name == 'list' then
        return validate_list(object, type_schema, path)
    end
    if type_name == 'const' then
        path:add_const(object, schema)
        if object ~= type_value then
            return false, path:wrong_value(type_value, object)
        end
        return true
    end
    if type_name == 'any' then
        return true
    end
    path:add_const(object, schema)
    local ok = type(object) == type_name or object == type_name
    local error_path = not ok and path:wrong_type(type_name, object)
    return ok, error_path
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

local theme_separators = {
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
        theme_separators,
        {
            key = 'string',
            value = { list = M.highlight },
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
            key = ' components',
            value = { table = { key = 'string', value = M.component } },
            required = true,
        },
    },
}

return M
