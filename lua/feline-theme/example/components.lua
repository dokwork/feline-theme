local M = {}

M.vi_mode = {
    provider = 'vi_mode',
    -- turn icon off and use full name of the mode
    icon = '',
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
