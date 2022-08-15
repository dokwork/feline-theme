local feline = require('feline-theme.schema.feline')

local M = {}

M.palette = { oneof = { 'function', { table = { key = 'string', value = feline.color } } } }

M.colors = {
    table = {
        -- the palette can have a key with a name of the colorscheme for which this palette
        -- should be used
        { key = 'string', value = M.palette },
        -- will be used in case of `dark` background, if palette with the same name as the
        -- current colorscheme was not found
        { key = 'light', value = M.palette },
        -- will be used in case of `light` background, if palette with the same name as the
        -- current colorscheme was not found
        { key = 'dark', value = M.palette },
        -- palette with colors which will be used when no other option will be appropriate
        { key = 'default', value = M.palette, required = true },
    },
}

return M
