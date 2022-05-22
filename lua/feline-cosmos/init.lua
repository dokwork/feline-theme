local u = require('feline-cosmos.utils')

local M = {}

M.setup = function(config)
    config.components = u.build_statusline(config.components.active, config.components.inactive, {
        components = u.merge(config.custom_components, require('feline-cosmos.components')),
        highlights = u.merge(config.custom_higlights, require('feline-cosmos.highlights')),
        icons = u.merge(config.custom_icons, require('feline-cosmos.icons')),
    })
    config.custom_providers = u.merge(config.custom_providers, require('feline-cosmos.providers'))
    require('feline').setup(config)

    return config
end

return M
