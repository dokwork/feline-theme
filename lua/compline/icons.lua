local h = require('compline.highlights')
local u = require('compline.utils')

local M = {}

M.file_status_icon = {
    provider = function(c)
        return (vim.bo.readonly and c.readonly_icon) or (vim.bo.modified and c.modified_icon) or ''
    end,
    hl = h.file_status,
    readonly_icon = '  ',
    modified_icon = '  ',
}

-- Returns an icon for the first lsp client attached to the current buffer.
-- Icon will be taken from the `icons` field of this component or from the module
-- 'nvim-web-devicons' if it's installed. If no one client will be found,
-- the `icons.client_off` or 'ﮤ' will be used.
--
-- `icons` an optional table with icons for possible lsp clients. Keys are names of
--         the lsp clients in lowercase; Values are icons; Also, it can have two special keys:
--    * `unknown`    an optional string with icon for unknown lsp client. Default is '?';
--    * `client_off` an optional string with icon which means that no one client is
--                   attached to the current buffer. Default is 'ﮤ';
M.lsp_client_icon = {
    provider = function(cmp)
        local client = u.lsp_client()
        if not client then
            return cmp.icons.client_off
        end
        local dev_icon = u.lsp_client_icon(cmp.icons, client)
        return dev_icon and dev_icon.icon or cmp.icons.unknown
    end,
    hl = h.lsp_client,
    icons = {
        unknown = '?',
        client_off = 'ﮤ',
    },
    hls = {
        unknown = 'fg',
        client_off = 'grey',
    },
}

---Returns an icon symbolizing state of the spellchecking.
---When spellchecking is on, the icon will have `hls.active` color.
---When spellchecking is off, the icon will have `hls.inactive` color.
M.spellcheck_icon = {
    provider = function(cmp)
        return cmp and cmp.icon_symbol
    end,
    hl = h.spellcheck,
    icon_symbol = '暈',
    hls = {
        active = 'fg',
        inactive = 'grey',
    },
}

M.git_icon = {
    provider = function(cmp)
        return cmp and cmp.icon_symbol
    end,
    hl = h.git_status,
    icon_symbol = ' ',
    hls = {
        inactive = { fg = 'grey' },
        changed = { fg = 'orange' },
        commited = { fg = 'green' },
    },
}

M.treesitter_parser_icon = {
    provider = function(cmp)
        return cmp and cmp.icon_symbol
    end,
    hl = h.treesitter_parser,
    icon_symbol = '  ',
    hls = {
        active = { fg = 'green' },
        inactive = { fg = 'grey' },
    },
}

return M
