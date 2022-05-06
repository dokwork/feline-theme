local p = require('feline-cosmos.providers')
local i = require('feline-cosmos.icons')
local c = require('feline-cosmos.conditions')
local h = require('feline-cosmos.highlights')

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

---The name of the current git branch. This component uses 'tpope/vim-fugitive'
---plugin to take info about git workspace.
---
---@type Component
M.git_branch = {
    provider = p.fugitive_branch,
    icon = i.git_icon,
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
    provider = p.working_path,
    hl = h.vi_mode,
}

---@type Component
M.diagnostic_errors = {
    provider = 'diagnostic_errors',
    hl = 'DiagnosticError',
}

---@type Component
M.diagnostic_warnings = {
    provider = 'diagnostic_warnings',
    hl = 'DiagnosticWarn',
}

---@type Component
M.diagnostic_info = {
    provider = 'diagnostic_info',
    hl = 'DiagnosticInfo',
}

---@type Component
M.diagnostic_hint = {
    provider = 'diagnostic_hint',
    hl = 'DiagnosticHint',
}

---Returns a list of languages used for spellchecking. If spellchecking is off and component
---doesn't have an icon, then only string '暈' will be returned. But, if component has an icon,
---then it behave as usually: shows a list of langs with icon when spellchecking is on, and it's
---hide when spellchecking is off.
---Example: '暈en' for english spellcheck, or just '暈' when spellchecking is off.
---
---@type Component
M.spellcheck = {
    provider = p.spellcheck_langs,
    hl = h.spellcheck,
    icon = i.spellcheck_icon
}

return M
