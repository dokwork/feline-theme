local M = {}

---@alias LspClient table #an object which returns from the `vim.lsp.client()`.

---@alias DevIcon table #an object which returns from the 'nvim-web-devicons' module.

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

---@type fun(t:any):boolean
---Checks do the argument have a type 'table'.
---
---@return boolean true when the argument has a type 'table'.
M.is_table = function(t)
    return type(t) == 'table'
end

---@type fun(client:LspClient):boolean
--- Checks is the argumen a client to the 'metals' language server.
---
---@see :h vim.lsp.client()
---
---@return boolean true when the client is a client to the 'metals'
---language server.
M.is_metals = function(client)
    return client and client.name == 'metals'
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

---@type fun(icons: table?<string, DevIcon | string>, client: LspClient?): DevIcon
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
---@param icons table?<string, DevIcon | string> # a table with icons for the lsp clients.
---All string values will be converted to the table `{ icon = VALUE, name = KEY }`,
---where VALUE is an original string value, KEY is a corresponded key from the {icons}.
---If an icon for the client is not found, then it's taken from the 'nvim-web-devicons'
---module (if such module exists).
---
---@param client LspClient the client to the LSP server. If absent, the first attached client to
---the current buffer is used.
---
---@return DevIcon # icon of the LspClient or `nil` when the `client` is absent
---or not found.
M.lsp_client_icon = function(icons, client)
    local c = client or M.lsp_client()
    if c == nil then
        return nil
    end

    -- replace all string values by a short version of the DevIcon
    local all_icons = icons or {}
    for k, v in pairs(all_icons) do
        if type(v) == 'string' then
            all_icons[k] = { icon = v, name = k }
        end
    end

    -- try to get icons from the 'nvim-web-devicons' module
    local ok, dev_icons = pcall(require, 'nvim-web-devicons')
    dev_icons = ok and dev_icons.get_icons() or {}

    -- merge both sources with icons
    all_icons = vim.tbl_deep_extend('keep', all_icons, dev_icons)

    -- get an appropriated icon
    local icon = all_icons.default or ''
    for _, ft in ipairs(c.config.filetypes) do
        if all_icons[ft] ~= nil then
            icon = all_icons[ft]
            break
        end
    end
    return icon
end

---@type fun(component: table, lib: table): table
---Takes a table with property `component` which should have a name of the
---component from the {lib}. If a component is not found in the {lib},
---a component is taken from the 'feline-components.components'.
---Then such component will be merged with passed {component} with following
---rules:
---1. All values with equal keys will be taken from the passed component;
---2. If the merged component has a property `hl` with a type of function,
---   that function will be invoked with argument `component.colors or {}`
---   and the result will be assigned back to the property `hl`.
---
---@param component table # should have a property `component` with a name of
---the component from the library. All other properties will be copied to the
---found component. Exception is the property `hl`. When it has a type 'function',
---then value of the `hl` will be overriden by the result of original function.
---
---@param lib table? # library with predefined components.
---
---@return table # resolved component in term of the feline.
M.build_component = function(component, lib)
    local lib = lib or require('feline-components.components')
    local c = assert(
        lib[component.component],
        'Component ' .. component.component .. ' was not found.'
    )
    c = vim.tbl_extend('force', c, component)
    -- resolve highlight function with custom colors
    if c.hl and type(c.hl) == 'function' then
        c.hl = c.hl(c.colors or {})
    end
    return c
end

M.build_statusline = function(active, inactive, lib)
    local lib = lib or require('feline-components.components')
    local transform = function(statusline)
        for i, section in ipairs(statusline) do
            for k, c in pairs(section) do
                if c.component then
                    statusline[i][k] = M.build_component(c, lib)
                end
            end
        end
        return statusline
    end

    return {
        active = transform(active),
        inactive = transform(inactive),
    }
end

return M
