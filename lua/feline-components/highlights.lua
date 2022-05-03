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
local c = require('feline-components.conditions')

local M = {}

---@type fun(hls: table<string, Highlight>): function
---Creates a function which returns highlight according to the current
---vi mode.
---
---@param hls table<string, Highlight> # custom highlights for vi modes.
---The keys of this table are names of the vi mode according to
---`require('feline.providers.vi_mode').get_mode_highlight_name`.
M.vi_mode = function(hls)
    return function()
        local name = vi_mode.get_mode_highlight_name()
        return hls[name]
            or {
                name = name,
                fg = hls[name] or vi_mode.get_mode_color(),
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
---@return function # which returns actual highlight according to the current git status.
M.git_status = function(hls)
    local hls = vim.tbl_extend('keep', hls, {
        inactive = { name = 'FCGitInactive', fg = 'white' },
        changed = { name = 'FCGitChanged', fg = 'yellow' },
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

return M
