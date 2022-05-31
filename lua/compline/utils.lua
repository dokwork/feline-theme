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

---@type fun(component: Component, lib: Library, hl: Highlight): FelineComponent
---Takes a component from the {lib} according to the name of the {component}.
---Then merges both components with follow rules:
---1. All values with equal keys will be taken from the passed {component};
---2. If the merged component has a property with string value "nil", that property
---   will be removed. This is recursive rule, that means this rule will be
---   applied to all nested tables in the component.
---3. If the merged component has a property `opts`, and property `provider`
---   has a type 'table', `opts` will be injected to the provider. Also, if
---   the provider has a type 'string', it will be transformed to the table
---   { name = <that string> } and `opts` will be injected.
---4. If the merged component has a property `hl` with a type of function,
---   that function will be wrapped by a new one function without arguments in
---   purpose of compatibility with Feline. Original function will be invoked
---   inside the new proxy function with argument `component.hls`
---   and the result will be assigned back to the property `hl`.
---5. If the merged component has a property `icon` with a type of function,
---   that function will be wrapped by a new one. Original function will be invoked
---   with follow arguments:
---   `component.icon_opts` and `component.icon_hls` inside the proxy function.
---Also, it tries to take an icon and highlight from the {lib}, when they have a
---type 'string'. If an icon or hl is not found in the {lib}, it will be used
---according to the Feline rules.
---
---@param component Component # should have a property `component` with a name of
---the component from the library. All other properties will be copied to the
---found component. Exceptions are properties `hl` and `icon`.
---
---@param lib Library # library with reusable components.
---
---@param hl Highlight # default highlight for the section where this component from.
---
---@return FelineComponent # resolved component in term of the feline.
M.build_component = function(component, lib, hl)
    local lib = M.merge(lib, { components = {}, icons = {}, highlights = {} })
    local c = component.component
            and assert(
                lib.components[component.component],
                'Component "' .. component.component .. '" was not found.'
            )
        or component
    c = vim.tbl_deep_extend('force', c or {}, component or {})

    -- inject opts
    if c.opts and type(c.provider) == 'string' then
        c.provider = { name = c.provider }
    end
    if c.opts and type(c.provider) == 'table' then
        c.provider.opts = c.opts
    end

    -- resolve highlight
    if c.hl == nil then
        -- use hl from a theme
        c.hl = hl
    end
    if type(c.hl) == 'string' then
        c.hl = lib.highlights[c.hl] or c.hl
    end
    if c.hl and type(c.hl) == 'function' then
        local hlf = c.hl
        -- to make a component compatible with Feline
        c.hl = function()
            ---@diagnostic disable-next-line: redundant-parameter
            return hlf(c.hls)
        end
    end

    -- resolve icon
    if type(c.icon) == 'string' then
        c.icon = lib.icons[c.icon] or c.icon
    end
    if c.icon and type(c.icon) == 'function' then
        local iconf = c.icon
        -- to make a component compatible with Feline
        c.icon = function()
            ---@diagnostic disable-next-line: redundant-parameter
            return iconf(c.icon_opts, c.icon_hls)
        end
    end

    -- apply removing properties marked as 'nil'
    return M.remove_nil(c)
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
        table.sort(sections)
        local j = 0
        for char, section in pairs(sections) do
            if section ~= 'nil' then
                j = j + 1
                for _, component in ipairs(section) do
                    local hl = theme and vim.tbl_get(theme, 'sections', side, char)
                    result[i][j] = M.build_component(component, lib, hl)
                end
            end
        end
    end
    return result
end

return M
