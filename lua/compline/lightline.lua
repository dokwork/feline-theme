local lightline = require('compline.statusline'):new('lightline', {
    active = {
        left = {
            a = { 'mode', 'paste' },
            b = { 'readonly', 'filename', 'modified' },
        },
        right = {
            x = { 'lineinfo' },
            y = { 'percent' },
            z = { 'fileformat', 'fileencoding', 'filetype' },
        },
    },
    inactive = {
        left = {
            a = { 'filename' },
        },
        right = {
            x = { 'lineinfo' },
            y = { 'percent' },
        },
    },
})

return lightline
