local M = {}

---@type fun(x: any): boolean
---Checks is an argument {x} is empty.
---
---@return boolean #true when the argument is empty.
---The argument is empty when:
---* it is the nil;
---* it has a type 'table' and doesn't have any pair;
---* it has a type 'string' and doesn't have any char;
---otherwise result is false.
M.is_empty = function(x)
    if x == nil then
        return true
    end
    if type(x) == 'table' and next(x) == nil then
        return true
    end
    if type(x) == 'string' and string.len(x) < 1 then
        return true
    end
    return false
end

---@type fun(t1: table, t2: table): table
---The same as `vim.extend('keep', t1 or {}, t2 or {})`
M.merge = function(t1, t2)
    return vim.tbl_extend('keep', t1 or {}, t2 or {})
end

M.sorted_by_keys = function(t, f)
    local index = {}
    for k in pairs(t) do
        table.insert(index, k)
    end
    table.sort(index, f)
    local i = 0
    return function()
        i = i + 1
        local k = index[i]
        return k, t[k]
    end
end

---Lazy import of a module. It doesn't load a module til a first using.
---@return table # a proxy which delegates any invocation of the `__index` to the module with {module_name}.
M.lazy_load = function(module_name)
    local module = {}
    setmetatable(module, module)
    module.__index = function(_, k)
        return require(module_name)[k]
    end
    return module
end

M.get_hl_attr = function(hl, what)
    local result = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hl)), what)
    if result == '' then
        return nil
    else
        return result
    end
end

M.get_hl_fg = function(hl)
    return M.get_hl_attr(hl, 'fg#')
end

M.get_hl_bg = function(hl)
    return M.get_hl_attr(hl, 'bg#')
end

---@type fun(color: string): number, number, number
--- Parses a color in the format '#RRGGBB', where
--- RR is a number for red part in the hex format,
--- GG is a number for green part in the hex format,
--- BB is a number for blue part in the hex format.
--- For example: '#000000' for 'black' color, or '#AAAAAA' for white color.
--- In case of wrong format of the color the error will be thrown.
M.parse_rgb_color = function(color)
    if type(color) ~= 'string' then
        error(string.format('Illegal color type %s. It must be string.', type(color)))
    end
    local _, _, r, g, b = string.find(color, '#(%x%x)(%x%x)(%x%x)')
    r = tonumber(r, 16)
    g = tonumber(g, 16)
    b = tonumber(b, 16)
    if r and g and b then
        return r, g, b
    else
        error(
            string.format(
                'Illegal color: %s. A color must follow format: #(%x%x)(%x%x)(%x%x)',
                color
            )
        )
    end
end

M.create_color = function(r, g, b)
    return string.format('#%02x%02x%02x', r, g, b)
end

M.darkening_color = function(color, rf, gf, bf)
    local rf  = rf or 0.1
    local gf  = gf or 0.1
    local bf  = bf or 0.1
    local r, g, b = M.parse_rgb_color(color)
    r = r * (1 - rf)
    g = g * (1 - gf)
    b = b * (1 - bf)
    return M.create_color(r, g, b)
end

M.ligthening_color = function(color, rf, gf, bf)
    local rf  = rf or 0.1
    local gf  = gf or 0.1
    local bf  = bf or 0.1
    local r, g, b = M.parse_rgb_color(color)
    r = r + (255 - r) * rf
    g = g + (255 - g) * gf
    b = b + (255 - b) * bf
    return M.create_color(r, g, b)
end

return M
