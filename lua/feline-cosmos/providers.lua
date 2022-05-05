local c = require('feline-cosmos.conditions')
local u = require('feline-cosmos.utils')

local M = {}

---@alias FelineComponent table

---@type fun(): string
---
---@return string # the name with extension of the file from the current buffer.
M.file_name = function()
    return vim.fn.expand('%:t')
end

---@type fun(_: any, opts: table): string
---
---@param opts table with properties:
---* `readonly_icon: string`  icon which should be used when a file is readonly. Default is ''
---* `modified_icon: string`  icon which should be used when a file is modified. Default is '✎'
---
---@return string # icon of the current state of the file: readonly, modified, none. In last case
---an empty string will be returned.
M.file_status_icon = function(_, opts)
    if vim.bo.readonly then
        return opts and opts.readonly_icon or ''
    end
    if vim.bo.modified then
        return opts and opts.modified_icon or '✎'
    end

    return ''
end

---@type fun(): string
---Resolves the name of the current file relative to the current working directory.
---If file is not in the one of subdirectories of the working directory, then its
---path will be returned with:
--- * prefix "/.../" in case when the file is not in the one of home subdirectories;
--- * prefix "~/" in case when the file is in one of home subdirectories.
---
---@return string # the name of the file relative to the current working directory.
M.relative_file_name = function()
    local full_name = vim.fn.expand('%:p')
    local name = vim.fn.expand('%:.')
    if name == full_name then
        name = vim.fn.expand('%:~')
    end
    if name == full_name then
        name = '/.../' .. vim.fn.expand('%:t')
    end
    return name
end

---@type fun(_: any, opts: table): string
---Cuts the current working path and gets the `opts.length` directories from the end
---with prefix ".../". For example: inside the path `/3/2/1` this provider will return
---the string ".../2/1" for depth 2. If `opts.length` is more then directories in the path,
---then path will be returned as is.
---
---@param opts table with properties:
---* `depth: number`   it will be used as a count of the last directories in the working path. Default is 2.
---
---@return string # last `opts.depth` ac count of directories of the current working path.
M.working_path_tail = function(_, opts)
    local opts = opts or {}
    local full_path = vim.fn.getcwd()
    local count = opts.depth or 2
    local sep = '/' -- FIXME: use system separator
    local dirs = vim.split(full_path, sep, { plain = true, trimempty = true })
    local result = '...' .. sep
    if count > #dirs then
        return full_path
    end
    if count <= 0 then
        return result
    end
    local tail = vim.list_slice(dirs, #dirs - count + 1, #dirs)
    for _, dir in ipairs(tail) do
        result = result .. dir .. sep
    end
    return result
end

---@type fun(_: any, opts: table): string
---Returns an icon for the first lsp client attached to the current buffer.
---Icon will be taken from the `opts.icons` or from the module 'nvim-web-devicons'.
---If no one client will be found, the `opts.client_off` or 'ﮤ' will be returned.
---
---@param opts table with properties:
---* `icons: table?`        an optional table with icons for possible lsp clients.
---                         Keys are names of the lsp clients in lowercase; Values are icons;
---* `client_off: string?`  an optional string with icon which means that no one client is
---                         attached to the current buffer. Default is 'ﮤ';
---@return string lsp_client_icon a string which contains an icon for the lsp client.
M.lsp_client_icon = function(_, opts)
    local opts = opts or {}
    local icon = u.lsp_client_icon(opts.icons)
    if icon == nil then
        return opts.client_off or 'ﮤ'
    else
        return icon.icon
    end
end

---@type fun(component): string
---Returns a list of languages used for spellchecking. If spellchecking is off and component
---doesn't have an icon, then string '暈' will be returned. But, if component has an icon,
---an empty string will be returned.
---Example: '暈en' for english spellcheck, or just '暈' when spellchecking is off.
---Such behaviour can be used to create a component which will show inactive icon when
---spellchecking is off, instead of disappear from the statusline at all.
---
---@return string # an optional icon '暈' and list of languages used to spell check.
M.spellcheck = function(component)
    if vim.wo.spell then
        local langs = vim.bo.spelllang
        return not component.icon and '暈' .. langs or langs
    else
        return not component.icon and '暈' or ''
    end
end

---@type fun(): string, string
---Returns the curent git branch and icon '  '.
---It uses `vim.fn.FugitiveHead` to take a current git branch.
---
---@return string branch a name of the current branch or empty string;
---@return string icon  '  ';
M.fugitive_branch = function()
    if c.is_git_workspace() then
        return vim.fn.FugitiveHead(), '  '
    else
        return '', '  '
    end
end

return M

-- TODO:
-- git_icon provider (?) / spellcheck icon provider (?) / **and** try to use `always_visible` propertie in the components : (I don't like mix a component and its icon in the provider)
-- length => depth for working directory
-- move out file status icon (to put it on the rigth side and customize a color(?))
