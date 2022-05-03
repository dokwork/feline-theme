---This is an example of statusline configuration

local active_left = {
    { component = 'vi_mode_bar' },
    { component = 'working_directory' },
    { component = 'relative_file_name' }
}

local active_middle = {}

local active_right = {
    { component = 'git_branch' }
}

local inactive_left = {
    { component = 'file_name' },
}

local active = { active_left, active_middle, active_right }
local inactive = { inactive_left }

local M = {
    generate = function()
        return require('feline-components.utils').build_statusline(active, inactive)
    end,
}

return M
