local c = require('compline.conditions')
local u = require('compline.utils')
local vi_mode = u.lazy_load('feline.providers.vi_mode')

local M = {}

---@type fun(hls: table<string, Highlight>): Highlight
---Returns highlight according to the current vi mode.
M.vi_mode = function(cmp)
    local hls = cmp and cmp.hls or {}
    return hls[vi_mode.get_vim_mode()] or {
        fg = vi_mode.get_mode_color(),
    }
end

---@type fun(hls: table<string, Highlight>): Highlight
---Returns a highlight according to the current git status.
---
---@param hls table<string, Highlight> # custom highlights with possible properties:
--- * `inactive: Highlight` a highlight which sould be used when git is not active;
--- * `changed: Highlight`  a highlight which sould be used when at least one file is changed;
--- * `commited: Highlight` a highlight which sould be used when no one change exist.
---
---@return Highlight # actual highlight according to the current git status.
M.git_status = function(cmp)
    local hls = u.merge(cmp and cmp.hls, {
        inactive = { fg = 'grey' },
        changed = { fg = 'orange' },
        commited = { fg = 'green' },
    })
    -- TODO move git utils to the separate script
    if not c.is_git_workspace() then
        return hls.inactive
    end
    if c.is_git_changed() then
        return hls.changed
    else
        return hls.commited
    end
end

---@type fun(hls: table<string, Highlight>): Highlight
---Returns highlight according to the current state of the spellchecking.
---
---@param hls table<string, Highlight> # custom highlights with possible properties:
--- * `active: Highlight` a highlight which sould be used when spellcheck is turned on;
--- * `inactive: Highlight` a highlight which sould be used when spellcheck is turned off;
---
---@return function # actual highlight for spellchecking depending on its state.
M.spellcheck = function(cmp)
    local hls = u.merge(cmp and cmp.hls, {
        active = { fg = 'fg' },
        inactive = { fg = 'grey' },
    })
    if vim.wo.spell then
        return hls.active
    else
        return hls.inactive
    end
end

---@type fun(hls: table<string, Highlight>): Highlight
---Returns a highlight according to the first attached lsp client.
---The color will be taken from the 'nvim-web-devicons' or 'hls.fg' will be used. If no one
---client is attached, then 'hls.client_off' will be used as foreground color.
---
---@param hls table<string, Highlight> # custom highlights with possible properties:
--- * `unknown` a highlight which will be used if a color for the attached lsp
---             client is not found;
--- * `client_off` a highlight which will be used if no one lsp client is attached;
---
---@return Highlight # highlight for the first attached lsp client.
M.lsp_client = function(cmp)
    local hls = u.merge(cmp and cmp.hls, {
        unknown = 'fg',
        client_off = 'grey',
    })
    local client = u.lsp_client()
    local icon = u.lsp_client_icon({}, client)
    return {
        fg = (u.is_lsp_client_ready(client) and (icon and icon.color) or (icon and hls.unknown))
            or hls.client_off,
    }
end

M.treesitter_parser = function(cmp)
    local hls = u.merge(cmp and cmp.hls, {
        active = { fg = 'green' },
        inactive = { fg = 'grey' },
    })
    -- TODO move to conditions
    local ok, _ = pcall(vim.treesitter.get_parser, 0)
    if ok then
        return hls.active
    else
        return hls.inactive
    end
end

---@type fun(hls: table<string, Highlight>): Highlight
---
---@param hls table<string, Highlight> # custom highlights with possible properties:
--- * `default: Highlight` a highlight which sould be used when the file is not changed;
--- * `changed: Highlight`  a highlight which sould be used when the file is changed;
--- * `read_only: Highlight` a highlight which sould be used when the file is in read only mode.
---
---@return Highlight # actual highlight according to the current file state.
M.file_status = function(hls)
    local hls = u.merge(hls, {
        default = { name = 'FCFileDefault', fg = 'fg' },
        changed = { name = 'FCFileChanged', fg = 'orange' },
        read_only = { name = 'FCFileReadOnly', fg = 'red' },
    })
    if vim.bo.readonly then
        return hls.read_only
    end
    if vim.bo.modified then
        return hls.changed
    else
        return hls.default
    end
end

return M
