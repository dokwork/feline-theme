local u = require('feline-cosmos.utils')

local M = {}

-- TODO:
-- 0. build_statusline should take a table
-- 1. resolve icons
-- 2. resolve highlights

M.setup = function(config)
    config.components = u.build_statusline(config.components.active, config.components.inactive, {
        components = u.merge(config.custom_components, require('feline-cosmos.components')),
        highlights = u.merge(config.custom_higlights, require('feline-cosmos.highlights')),
        icons = u.merge(config.custom_icons, require('feline-cosmos.icons')),
    })
    require('feline').setup(config)
end

return M
