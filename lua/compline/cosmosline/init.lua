return {
    active = {
        left = {
            a = { '▊', 'file_status_icon', 'working_directory' },
            b = { 'relative_file_name' },
        },
        right = {
            u = { 'diagnostic_warnings', 'diagnostic_errors' },
            v = { 'git_icon', 'git_branch' },
            w = { 'lsp_client_icon', 'treesitter_parser_icon' },
            x = { 'spellcheck_icon' },
            y = { 'position' },
            z = { 'scroll_bar' },
        },
    },
    inactive = {
        left = {
            a = { 'relative_file_name' },
        },
    },
    theme = require('compline.cosmosline.theme'),
    colors = require('compline.cosmosline.colors'),
    components = vim.tbl_extend('error', require('compline.components'), require('compline.icons')),
}
