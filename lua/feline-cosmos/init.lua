local u = require('feline-cosmos.utils')

local M = {}

M.setup = function(config)
    config.components = u.build_statusline(
        config.components.active,
        config.components.inactive,
        config.custom_components
    )
    require('feline').setup(config)
end

return M
