---All functions in this module must take a parameter `hls`
---and return a highlight according to the |feline-Component-highlight|
---
---For example:
---```lua
---M.example = function(hls)
---     return { fg = 'red' }
---end
---```
---NOTE: Only colors from the default palette should be used.

---@alias Color string # a name of the color or RGB hex color description

---@alias Highlight string|table|function # a description of the highlight according to the |feline-Component-highlight|.

local vi_mode = require('feline.providers.vi_mode')
local c = require('compline.conditions')
local u = require('compline.utils')

local M = {}

---@type fun(hls: table<string, Highlight>): function
---Creates a function which returns highlight according to the current
---vi mode.
---
---@param hls table<string, Highlight> # custom highlights for vi modes.
---The keys of this table are names of the vi mode according to
---`require('feline.providers.vi_mode').get_vim_mode`.
M.vi_mode = function(hls)
    local hls = hls or {}
    return function()
        return hls[vi_mode.get_vim_mode()]
            or {
                name = vi_mode.get_mode_highlight_name(),
                fg = vi_mode.get_mode_color(),
            }
    end
end

---@type fun(hls: table<string, Highlight>): function
---Creates a function which returns highlight according to the current
---git status.
---
---@param hls table<string, Highlight> # custom highlights with possible properties:
--- * `inactive: Highlight` a highlight which sould be used when git is not active;
--- * `changed: Highlight`  a highlight which sould be used when at least one file is changed;
--- * `commited: Highlight` a highlight which sould be used when no one change exist.
---
---@return function # funciton which returns actual highlight according to the current git status.
M.git_status = function(hls)
    local hls = u.merge(hls, {
        inactive = { name = 'FCGitInactive', fg = 'grey' },
        changed = { name = 'FCGitChanged', fg = 'orange' },
        commited = { name = 'FCGitCommited', fg = 'green' },
    })
    return function()
        if not c.is_git_workspace() then
            return hls.inactive
        end
        if c.is_git_changed() then
            return hls.changed
        else
            return hls.commited
        end
    end
end

---@type fun(hls: table<string, Highlight>): function
---Creates a function which returns highlight according to the current state
---of the spellchecking.
---
---@param hls table<string, Highlight> # custom highlights with possible properties:
--- * `active: Highlight` a highlight which sould be used when spellcheck is turned on;
--- * `inactive: Highlight` a highlight which sould be used when spellcheck is turned off;
---
---@return function # function which returns actual highlight for spellchecking depending on its state.
M.spellcheck = function(hls)
    local hls = u.merge(hls, {
        active = { name = 'FCSpellcheckActive', fg = 'fg' },
        inactive = { name = 'FCSpellcheckInactive', fg = 'grey' },
    })
    return function()
        if vim.wo.spell then
            return hls.active
        else
            return hls.inactive
        end
    end
end

---@type fun(): function
---Creates a function which returns highlight according to the first attached lsp client.
---The color will be taken from the 'nvim-web-devicons' or 'fg' will be used. If no one
---client is attached, then 'inactive' will be used as foreground color.
---
---@param hls table<string, Highlight> # custom highlights with possible properties:
--- * `default: Highlight` a highlight which will be used if a color for the attached lsp
---    client is not found;
--- * `inactive: Highlight` a highlight which will be used if no one lsp client is attached;
---
---@return function # highlight for the first attached lsp client.
M.lsp_client = function(hls)
    local hls = u.merge(hls, { default = 'fg', inactive = 'grey' })
    return function()
        local client = u.lsp_client()
        local icon = u.lsp_client_icon({}, client)
        if u.is_lsp_client_ready(client) then
            return {
                name = 'FCLspClientIcon' .. (client and client.name or 'Off'),
                fg = (icon and icon.color) or (icon and hls.default) or hls.inactive,
            }
        end
    end
end

M.treesitter_parser = function(hls)
    local hls = u.merge(hls, {
        active = { name = 'FCTreesitterActive', fg = 'green' },
        inactive = { name = 'FCTreesitterInactive', fg = 'grey' },
    })
    return function()
        -- TODO move to conditions
        local ok, _ = pcall(vim.treesitter.get_parser, 0)
        if ok then
            return hls.active
        else
            return hls.inactive
        end
    end
end

---@type fun(hls: table<string, Highlight>): function
---Creates a function which returns highlight according to the current
---file state.
---
---@param hls table<string, Highlight> # custom highlights with possible properties:
--- * `default: Highlight` a highlight which sould be used when the file is not changed;
--- * `changed: Highlight`  a highlight which sould be used when the file is changed;
--- * `read_only: Highlight` a highlight which sould be used when the file is in read only mode.
---
---@return function # funciton which returns actual highlight according to the current file state.
M.file_status = function(hls)
    local hls = u.merge(hls, {
        default = { name = 'FCFileDefault', fg = 'fg' },
        changed = { name = 'FCFileChanged', fg = 'orange' },
        read_only = { name = 'FCFileReadOnly', fg = 'red' },
    })
    return function()
        if vim.bo.readonly then
            return hls.read_only
        end
        if vim.bo.modified then
            return hls.changed
        else
            return hls.default
        end
    end
end

return M
