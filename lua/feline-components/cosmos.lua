---This is an example of statusline configuration

local sep = { str = ' | ', hl = { fg = 'blue' } }

local active_left = {
    { component = 'vi_mode_bar' },
    { component = 'working_directory' },
    { component = 'relative_file_name' },
    { provider = ' ', hl = { fg = 'bg', bg = 'NONE' } },
}

local active_middle = {
    {
        name = 'metal_status',
        provider = function()
            return (vim.g['metals_status'] or '')
        end,
        hl = { bg = 'NONE' }
    },
}

local active_right = {
    { provider = ' ', hl = { fg = 'bg', bg = 'NONE' } },
    { component = 'diagnostic_warnings' },
    { component = 'diagnostic_errors', right_sep = sep },
    { component = 'git_branch', right_sep = sep },
    { component = 'spellcheck', right_sep = sep },
    { component = 'lsp_client_icon' },
    { component = 'treesitter_parser', right_sep = sep },
    { provider = 'position', right_sep = sep },
    { component = 'scroll_bar' },
}

local inactive_left = {
    { component = 'relative_file_name' },
}

local active = { active_left, active_middle, active_right }
local inactive = { inactive_left }

local M = {
    generate = function()
        return require('feline-components.utils').build_statusline(active, inactive)
    end,
}

return M
