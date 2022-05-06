local feline = require('feline')

local M = {}

local sep = { str = ' | ', hl = { fg = 'blue' } }
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
        hl = { fg = 'grey', bg = 'NONE' },
    },
}

local active_right = {
    { provider = ' ', hl = { fg = 'bg', bg = 'NONE' } },
    { component = 'diagnostic_warnings' },
    { component = 'diagnostic_errors', right_sep = sep },
    { component = 'git_branch', right_sep = sep },
    { icon = 'lsp_client_icon' },
    { icon = 'treesitter_parser_icon', right_sep = sep.permanent },
    { component = 'spellcheck' },
    { provider = 'position', right_sep = sep, left_sep = sep },
    { provider = 'scroll_bar', hl = 'vi_mode' },
}

local inactive_left = {
    { component = 'relative_file_name' },
}

M.select_theme = function()
    if vim.o.background == 'light' then
        feline.use_theme('cosmos-light')
    else
        feline.use_theme('cosmos-dark')
    end
end

M.setup = function(theme)
    local dark = theme or require('feline-cosmos.statusline.themes.dark')
    local light = theme or require('feline-cosmos.statusline.themes.light')

    require('feline-cosmos').setup({
        theme = dark,
        vi_mode_colors = require('feline-cosmos.statusline.themes.vi_mode_colors'),
        components = {
            active = { active_left, active_middle, active_right },
            inactive = { inactive_left },
        },
    })

    feline.add_theme('cosmos-dark', dark)
    feline.add_theme('cosmos-light', light)

    M.select_theme()

    vim.cmd([[augroup cosmos_themes
        autocmd!
        autocmd ColorScheme * lua require('feline-cosmos.statusline').select_theme()
    augroup END]])
end

return M
