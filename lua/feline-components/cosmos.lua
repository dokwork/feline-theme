---This is an example of statusline configuration

local active_left = {
    { component = 'vi_mode_bar' },
}

local active_middle = {}

local active_right = {}

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
