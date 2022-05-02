local p = require('feline-components.providers')
local c = require('feline-components.conditions')
local h = require('feline-components.highlights')

local M = {}

M.vi_mode_bar = {
    provider = '▊',
    hl = h.vi_mode,
}

M.file_name = {
    provider = p.relative_file_name,
    short_provider = p.file_name,
    icon = p.file_status_icon,
    enabled = c.is_buffer_not_empty,
}

M.file_type = {
    provider = p.file_type,
}

M.git_branch = {
    provider = p.fugitive_branch,
    hl = h.git_status,
    hls = {  inactive = 'inactive' },
    truncate_hide = true,
}

return M
