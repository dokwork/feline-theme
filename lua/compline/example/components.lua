local M = {}

M.mode = {
    provider = require('feline.providers.vi_mode').get_vim_mode,
}

M.file_name = {
    provider = function()
        return vim.fn.expand('%:t')
    end,
}

M.file_type = {
    provider = 'file_type',
}

M.position = {
    provider = {
        name = 'position',
        opts = { format = 'Ln {line}, Col {col}' },
    },
}

return M
