local h = require('feline-cosmos.highlights')
local u = require('feline-cosmos.utils')

local M = {}
-- TODO: add option for padding

---@class Icon
---@field str string
---@field hl Highlight
---@field always_visible boolean

---@type fun(_: any, opts: table, hls: Highlight): function
---
---@param opts table with properties:
---* `readonly_icon: string`  icon which should be used when a file is readonly. Default is '  ';
---* `modified_icon: string`  icon which should be used when a file is modified. Default is '  ';
---
---@return function # which returns an icon of the current state of the file: readonly, modified,
---none. In last case an empty string will be returned.
M.file_status_icon = function(_, opts, hls)
    local opts = u.merge(opts, {
        readonly_icon = '  ',
        modified_icon = '  ',
    })
    local hl = h.file_status(hls)
    return function()
        return {
            str = (vim.bo.readonly and opts.readonly_icon)
                or (vim.bo.modified and opts.modified_icon)
                or '',
            hl = hl,
            always_visible = true,
        }
    end
end

---@type fun(_: any, opts: table, hls: table): Icon
---Returns an icon for the first lsp client attached to the current buffer.
---Icon will be taken from the `opts.icons` or from the module 'nvim-web-devicons'.
---If no one client will be found, the `opts.client_off` or 'ﮤ' will be returned.
---
---@param opts table with properties:
--- * `icons: table`       an optional table with icons for possible lsp clients.
---                        Keys are names of the lsp clients in lowercase; Values are icons;
---                        If no one icon is found, the `hls.unknown` will be used.
--- * `unknown: string`    an optional string with icon for unknown lsp client. Default is '?';
--- * `client_off: string` an optional string with icon which means that no one client is
---                        attached to the current buffer. Default is 'ﮤ';
---@return string # a string which contains an icon for the lsp client.
M.lsp_client_icon = function(_, opts, hls)
    local opts = u.merge(opts, { unknown = '?', client_off = 'ﮤ', icons = {} })
    return function()
        local client = u.lsp_client()
        local icon
        if client then
            icon = u.lsp_client_icon(opts.icons, client)
        else
            icon = { icon = opts.client_off }
        end
        return {
            str = icon and icon.icon or opts.unknown,
            hl = h.lsp_client(hls),
            always_visible = true,
        }
    end
end

---@type fun(_: any, opts: table, hls: table): Icon
---Returns an icon symbolizing state of the spellchecking.
---When spellchecking is on, the icon will have `hls.active` color.
---When spellchecking is off, the icon will have `hls.inactive` color.
M.spellcheck_icon = function(_, opts, hls)
    local opts = u.merge(opts, { icon = '暈' })
    return {
        str = opts.icon,
        hl = h.spellcheck(hls),
        always_visible = true,
    }
end

M.git_icon = function(_, opts, hls)
    local opts = u.merge(opts, { icon = ' ' })
    return {
        str = opts.icon,
        hl = h.git_status(hls),
        always_visible = true,
    }
end

M.treesitter_parser_icon = function(_, opts, hls)
    local opts = u.merge(opts, { icon = '  ' })
    return {
        str = opts.icon,
        hl = h.treesitter_parser(hls),
        always_visible = true,
    }
end

return M
