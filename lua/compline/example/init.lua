return {
    active = {
        left = {
            a = { 'mode' },
            b = { 'short_working_directory' },
            c = { 'file_name' },
        },
        middle = {
            a = { 'time' }
        },
        right = {
            y = { 'file_encoding', 'file_format' },
            z = { 'position' },
        },
    },
    inactive = {
        left = {
            a = { 'file_name' },
        },
    },
    theme = require('compline.example.theme'),
    components = require('compline.example.components'),
    colors = require('compline.example.colors')
}
