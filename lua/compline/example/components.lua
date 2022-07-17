local M = {}

M.mode = {
    provider = require('feline.providers.vi_mode').get_vim_mode,
}

M.file_name = {
    provider = function()
        return vim.fn.expand('%:t')
    end,
}

M.file_format = {
    provider = {
        name = 'file_type',
        opts = {
            filetype_icon = true,
            case = 'lowercase'
        }
    }
}

return M
