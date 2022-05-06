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

---@type fun(icons: table?<string, DevIcon>, client: LspClient?): DevIcon
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
---@param client LspClient the client to the LSP server. If absent, the first attached client to
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

---@class Library # library of the reusable components.
---@field components table<string, Component>
---@field highlights table<string, Highlight>
---@field icons      table<string, Icon>

---@type fun(component: Component, lib: Library): table
---Takes a component from the {lib} according to the name of the {component}.
---Then merges both components with rules:
---1. All values with equal keys will be taken from the passed {component};
---2. If the merged component has a property `hl` with a type of function,
---   that function will be invoked with argument `component.hls or {}`
---   and the result will be assigned back to the property `hl`.
---3. If the merged component has a property `icon` with a type of function,
---   that function will be invoked with follow arguments: this `component`,
---   `component.opts` and `component.hls`.
---
---@param component Component # should have a property `component` with a name of
---the component from the library. All other properties will be copied to the
---found component. Exceptions are properties `hl` and `icon`.
---TODO explain exceptions
---
---@param lib Library # library with reusable components.
---
---@return table # resolved component in term of the feline.
M.build_component = function(component, lib)
    local lib = lib or { components = {} }
    local c = assert(
        lib.components[component.component],
        'Component ' .. component.component .. ' was not found.'
    )
    c = vim.tbl_extend('force', c, component)
    -- resolve highlight function with custom highlights
    if c.hl and type(c.hl) == 'function' then
        c.hl = c.hl(c.hls or {})
    end
    if c.icon and type(c.icon) == 'function' then
        c.icon = c.icon(c, c.opts or {}, c.hls or {})
    end
    return c
end

M.build_statusline = function(active, inactive, lib)
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
