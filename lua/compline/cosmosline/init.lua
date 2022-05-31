local sep = { str = ' | ', hl = { fg = 'blue' } }
sep.permanent = vim.deepcopy(sep)
sep.permanent.always_visible = true

local Cosmosline = require('compline.statusline'):new('cosmosline', {
    active = {
        left = {
            a = {
                { provider = '▊', hl = 'vi_mode' },
                { icon = 'file_status_icon' },
                { component = 'working_directory', opts = { depth = 2 } },
            },
            b = {
                { component = 'relative_file_name' },
                { provider = ' ', hl = { fg = 'bg', bg = 'NONE' } },
            },
        },
        right = {
            a = {
                { provider = ' ', hl = { fg = 'bg', bg = 'NONE' } },
                { component = 'diagnostic_warnings' },
                { component = 'diagnostic_errors', right_sep = sep },
                { component = 'git_branch', right_sep = sep },
                { icon = 'lsp_client_icon' },
                { icon = 'treesitter_parser_icon', right_sep = sep.permanent },
                { component = 'spellcheck' },
                { provider = 'position', right_sep = sep, left_sep = sep },
            },
            b = {
                { provider = 'scroll_bar', hl = 'vi_mode' },
            },
        },
    },
    inactive = {
        left = {
            a = {
                { component = 'relative_file_name' },
            },
        },
    },
    themes = {
        default = require('compline.cosmosline.theme'),
    },
    lib = {
        components = require('compline.components'),
        providers = require('compline.providers'),
        highlights = require('compline.highlights'),
        icons = require('compline.icons'),
    },
})

return Cosmosline
