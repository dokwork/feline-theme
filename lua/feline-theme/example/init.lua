return {
    active = {
        left = {
            a = { 'mode' },
            b = { 'short_working_directory' },
            c = { 'file_name' },
        },
        middle = {
            a = { 'time' },
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
    theme = require('feline-theme.example.theme'),
    components = require('feline-theme.example.components'),
    colors = require('feline-theme.example.colors'),
}
