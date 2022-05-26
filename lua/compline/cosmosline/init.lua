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

local active_middle = {}

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

local Cosmosline = require('compline.statusline'):new('cosmosline', {
    active_components = { active_left, active_middle, active_right },
    inactive_components = { inactive_left },
    themes = {
        light = require('compline.cosmosline.themes.light'),
        dark = require('compline.cosmosline.themes.dark'),
    },
    vi_mode_colors = require('compline.cosmosline.themes.vi_mode_colors'),
    lib = {
        components = require('compline.components'),
        providers = require('compline.providers'),
        highlights = require('compline.highlights'),
        icons = require('compline.icons'),
    },
})

return Cosmosline
