local M = {}

local sep = { str = ' | ', hl = { fg = 'main' } }
sep.permanent = vim.deepcopy(sep)
sep.permanent.always_visible = true

local active_left = {
    { provider = '▊', hl = 'vi_mode' },
    { icon = 'file_status_icon' },
    { component = 'working_directory', opts = { depth = 2 } },
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
    { icon = 'lsp_client_icon' },
    { icon = 'treesitter_parser_icon', right_sep = sep.permanent },
    { component = 'spellcheck', hls = { active = { fg = 'blue' } } },
    { provider = 'position', right_sep = sep, left_sep = sep },
    { provider = 'scroll_bar', hl = 'vi_mode' },
}

local inactive_left = {
    { component = 'relative_file_name' },
}

M.setup = function(theme)
    local theme = theme or require('feline-cosmos.statusline.themes.dark')
    require('feline-cosmos').setup({
        theme = theme,
        vi_mode_colors = theme.vi_mode_colors,
        components = {
            active = { active_left, active_middle, active_right },
            inactive = { inactive_left },
        },
    })
end

return M
