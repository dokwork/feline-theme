local M = {}

M.mode = {
    provider = require('feline.providers.vi_mode').get_vim_mode,
}

M.short_working_directory = {
    provider = function()
        return vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.getcwd(), ':p'))
    end,
}

M.file_name = {
    provider = function()
        return vim.fn.expand('%:t')
    end,
}

M.time = {
    provider = function()
        return vim.fn.strftime('%H:%M')
    end,
}

M.file_format = {
    provider = {
        name = 'file_type',
        opts = {
            filetype_icon = true,
            case = 'lowercase',
        },
    },
}

return M
