local example = require('compline.statusline'):new('example', {
    active = {
        left = {
            a = { 'mode' },
            b = { 'git_branch' },
            c = { 'file_name' },
        },
        right = {
            d = { 'file_encoding', 'file_format' },
            e = { 'position' },
        },
    },
    inactive = {
        left = {
            a = { 'file_name' },
        },
    },
    themes = {
        default = require('compline.example.theme'),
    },
    components = require('compline.example.components'),
})

return example
