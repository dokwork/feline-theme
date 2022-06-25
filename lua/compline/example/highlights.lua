local M = {}

M.vi_mode = function()
    return {
        name = require('feline.providers.vi_mode').get_mode_highlight_name(),
        fg = require('feline.providers.vi_mode').get_mode_color(),
        bg = 'bg',
        style = 'bold',
    }
end

return M
