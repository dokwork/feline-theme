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

---@type fun():LspClient
---
---@return LspClient the first attached to the current buffer lsp client.
M.lsp_client = function()
    local clients = vim.lsp.buf_get_clients(0)
    if M.is_empty(clients) then
        return nil
    end
    local _, client = next(clients)
    return client
end

---@type fun(icons: table<string, DevIcon>, client?: LspClient): DevIcon
---Takes a type of the file from the {client} and tries to take a corresponding icon
---from the {icons} or 'nvim-web-devicons'. {client} can be omitted. If so, result of
---the `lsp_client()` is used.
---
---DevIcon example:
---```lua
---{
---   icon = "",
---   color = "#51a0cf",
---   cterm_color = "74",
---   name = "Lua",
---}
---```
---
---@see require('nvim-web-devicons').get_icons
---
---@param icons table<string, DevIcon> # a table with icons for the lsp clients.
---If no one lsp client is attached, then nil will be returned.
---If an icon for the client is not found, then it's taken from the 'nvim-web-devicons'
---module (if such module exists) or nil will be returned.
---
---@param client? LspClient the client to the LSP server. If absent, the first attached client to
---the current buffer is used.
---
---@return DevIcon # icon of the LspClient or `nil` when the `client` is absent or icon not found.
M.lsp_client_icon = function(icons, client)
    local c = client or M.lsp_client()
    if c == nil then
        return nil
    end

    -- try to get icons from the 'nvim-web-devicons' module
    local ok, dev_icons = pcall(require, 'nvim-web-devicons')
    dev_icons = ok and dev_icons.get_icons()

    -- merge both sources with icons
    local all_icons = M.merge(icons, dev_icons)

    -- get an appropriated icon
    local icon
    for _, ft in ipairs(c.config.filetypes) do
        if all_icons[ft] then
            icon = all_icons[ft]
            break
        end
    end
    return icon
end

M.is_lsp_client_ready = function(client)
    -- TODO: add support of the metals
    return true
end

---@type fun(t: table): table
---Replace all string values with 'nil' by the `nil` to remove the pair from the table.
M.remove_nil = function(t)
    for k, v in pairs(t) do
        if v == 'nil' then
            t[k] = nil
        elseif type(v) == 'table' then
            t[k] = M.remove_nil(v)
        end
    end
    return (not M.is_empty(t)) and t or nil
end

---@type fun(module_name: string): table
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

---@fun(line: Line, lib: Library, theme: Theme): FelineSection[]
---Transforms every component from the {line} to its Feline representation.
---@see `build_component`
M.build_line = function(line, lib, theme)
    if line == 'nil' or not line then
        return nil
    end
    local result = {}
    local i = 0
    for _, side in pairs({ 'left', 'middle', 'right' }) do
        local sections = line[side]
        sections = sections ~= 'nil' and sections or {}
        i = i + 1
        result[i] = {}
        local j = 0
        for char, section in M.sorted_by_keys(sections) do
            if section ~= 'nil' then
                for _, component in ipairs(section) do
                    j = j + 1
                    local hl = theme and vim.tbl_get(theme, 'sections', side, char)
                    result[i][j] = M.build_component(component, lib, hl)
                end
            end
        end
    end
    return result
end

return M
