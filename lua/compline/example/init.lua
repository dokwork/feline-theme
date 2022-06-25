local example = require('compline.statusline'):new('example', {
    active = {
        left = {
            a = { 'mode' },
            b = { 'file_name' },
        },
        right = {
            c = { 'file_type' },
            d = { 'position' },
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
    components = require('compline.example.components')
})

return example
