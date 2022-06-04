local u = require('compline.utils')
local h = require('compline.highlights')

local Cosmosline = require('compline.statusline'):new('cosmosline', {
    active = {
        separators = { left = ' ', right = ' ' },
        left = {
            a = { '▊', 'file_status_icon', 'working_directory' },
            b = { 'relative_file_name' },
        },
        right = {
            separators = { right = { provider = ' | ', hl = h.vi_mode } },
            a = { 'diagnostic_warnings', 'diagnostic_errors' },
            b = { 'git_branch' },
            c = { 'lsp_client_icon', 'treesitter_parser_icon' },
            d = { 'spellcheck' },
            e = { 'position' },
            f = { 'scroll_bar' },
        },
    },
    inactive = {
        left = {
            a = { 'relative_file_name' },
        },
    },
    themes = {
        default = require('compline.cosmosline.theme'),
    },
    components = vim.tbl_extend('error', require('compline.components'), require('compline.icons')),
})

return Cosmosline
