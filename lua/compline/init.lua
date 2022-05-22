local u = require('compline.utils')

local M = {}

M.setup = function(config)
    config.components = u.build_statusline(config.components.active, config.components.inactive, {
        components = u.merge(config.custom_components, require('compline.components')),
        highlights = u.merge(config.custom_higlights, require('compline.highlights')),
        icons = u.merge(config.custom_icons, require('compline.icons')),
    })
    config.custom_providers = u.merge(config.custom_providers, require('compline.providers'))
    require('feline').setup(config)

    return config
end

return M
