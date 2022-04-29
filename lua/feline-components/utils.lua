local M = {}

---@alias LspClient table an object which returns from the `vim.lsp.client()`.

---@alias DevIcon table an object which returns from the 'nvim-web-devicons' module.

---@type fun(x: any): boolean
-- Checks is an argument {x} is empty.
--
---@return boolean true when the argument is empty.
-- The argument is empty when:
-- * it is the nil;
-- * it has a type 'table' and doesn't have any pair;
-- * it has a type 'string' and doesn't have any char;
-- otherwise result is false.
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
-- Checks do the argument have a type 'table'.
--
---@return boolean true when the argument has a type 'table'.
M.is_table = function(t)
    return type(t) == 'table'
end

---@type fun(client:LspClient):boolean
--- Checks is the argumen a client to the 'metals' language server.
--
---@see :h vim.lsp.client()
--
---@return boolean true when the client is a client to the 'metals'
-- language server.
M.is_metals = function(client)
    return client and client.name == 'metals'
end

---@type fun():LspClient
--
---@return LspClient the first attached to the current buffer lsp client.
M.lsp_client = function()
    local clients = vim.lsp.buf_get_clients(0)
    if M.is_empty(clients) then
        return nil
    end
    local _, client = next(clients)
    return client
end

---@type fun(icons: table<string, DevIcon | string>?, client: LspClient?): DevIcon
-- Takes a type of the file from the {client} and tries to take a corresponding icon
-- from the {icons} or 'nvim-web-devicons'. {client} can be omitted. If so, result of
-- the `lsp_client()` will be used.
--
-- DevIcon example: {
--    icon = "",
--    color = "#51a0cf",
--    cterm_color = "74",
--    name = "Lua",
--  }
--
---@see require('nvim-web-devicons').get_icons
--
---@param icons table<string, DevIcon | string>? table with icons for the lsp clients.
--- All string values will be converted to the table `{ icon = VALUE, name = KEY }`,
--- where VALUE is an original string value, KEY is a corresponded key from the {icons}.
--- If an icon for the client will not be found, then it will be looked in the 'nvim-web-devicons'
--- module (if such module exists).
--
---@param client LspClient the client to the LSP server. If absent, the first attached client to
--- the current buffer will be used.
--
---@return DevIcon lsp_client_icon icon of the LspClient or `nil` when the `client` is absent
--- or not found.
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

return M
