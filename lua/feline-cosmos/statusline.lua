local i = require('feline-cosmos.icons')
local h = require('feline-cosmos.highlights')

local M = {}

local sep = { str = ' | ', hl = { fg = 'blue' } }
sep.permanent = vim.deepcopy(sep)
sep.permanent.always_visible = true

local active_left = {
    { component = 'vi_mode_bar' },
    { icon = i.file_status_icon() },
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
        hl = { fg = 'inactive', bg = 'NONE' },
    },
}

local active_right = {
    { provider = ' ', hl = { fg = 'bg', bg = 'NONE' } },
    { component = 'diagnostic_warnings' },
    { component = 'diagnostic_errors', right_sep = sep },
    { component = 'git_branch', right_sep = sep },
    { icon = i.lsp_client_icon() }, -- TODO: resolve icons in same way as components
    { icon = i.treesitter_parser_icon(), right_sep = sep.permanent },
    { component = 'spellcheck', hls = { active = { fg = 'blue' } } },
    { provider = 'position', right_sep = sep, left_sep = sep },
    { provider = 'scroll_bar', hl = h.vi_mode() },
}

local inactive_left = {
    { component = 'relative_file_name' },
}

M.setup = function(theme)
    local theme = theme or require('feline-cosmos.themes.dark')
    require('feline-cosmos').setup({
        components = {
            active = { active_left, active_middle, active_right },
            inactive = { inactive_left },
        },
        theme = theme,
        vi_mode_colors = theme.vi_mode_colors,
        custom_components = require('feline-cosmos.components'),
    })
end

return M
