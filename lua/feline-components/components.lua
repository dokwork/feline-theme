local p = require('feline-components.providers')
local c = require('feline-components.conditions')
local h = require('feline-components.highlights')

---@class FelineComponent # see complete description here: |feline-components|
---@field name string
---@field provider string|table|function
---@field opts any
---@field hl Highlight
---@field icon string|table|function
---@field enabled boolean

---@class Component : FelineComponent
---@field component string # a name of the existing component which will be used as a prototype.
---@field hls table<string, Highlight> # custom highlights for the component.

local M = {}

---This is a compact indicator of the current vi mode.
---
---Custom properties:
--- * `hls` should have custom highlights for vi modes.
---The keys of this table are names of the vi mode according to
---`'feline.providers.vi_mode'.get_mode_highlight_name`.
---
---@type Component
M.vi_mode_bar = {
    provider = '▊',
    hl = h.vi_mode,
}

---The name of the current file relative to the current working directory.
---If file is not in the one of subdirectories of the working directory, then its
---path will be returned with:
--- * prefix "/.../" in case when the file is not in the one of home subdirectories;
--- * prefix "~/" in case when the file is in one of home subdirectories.
---
---@type Component
M.relative_file_name = {
    provider = p.relative_file_name,
    short_provider = p.file_name,
    icon = p.file_status_icon,
    enabled = c.is_buffer_not_empty,
}

---The type of the current file. This component uses default provider 'file_type',
---but with different default opts:
---```lua
---{
---    filetype_icon = true,
---    colored_icon = false,
---    case = 'lowercase',
---}
---```
---
---@type Component
M.file_type = {
    provider = 'file_type',
    opts = {
        filetype_icon = true,
        colored_icon = false,
        case = 'lowercase',
    },
}

---@type Component
M.file_name = {
    provider = 'file_name'
}

---The name of the current git branch. This component uses 'tpope/vim-fugitive'
---plugin to take info about git workspace.
---
---@type Component
M.git_branch = {
    provider = p.fugitive_branch,
    hl = h.git_status,
}

---The last N directories of the current working directory path. Count of directories
---can be customized.
---
---Custom properties:
--- * `hls` should have custom highlights for vi modes.
---The keys of this table are names of the vi mode according to
---`'feline.providers.vi_mode'.get_mode_highlight_name`.
---
--- * `opts` can have a property 'length' with count of directories in the path.
---
---@type Component
M.working_directory = {
    provider = p.working_path_tail,
    hl = h.vi_mode,
}

M.diagnostic_errors = {
    provider = 'diagnostic_errors',
    hl = 'DiagnosticError'
}

M.diagnostic_warnings = {
    provider = 'diagnostic_warnings',
    hl = 'DiagnosticWarn'
}

M.diagnostic_info = {
    provider = 'diagnostic_info',
    hl = 'DiagnosticInfo'
}

M.diagnostic_hint = {
    provider = 'diagnostic_hint',
    hl = 'DiagnosticHint'
}

return M
