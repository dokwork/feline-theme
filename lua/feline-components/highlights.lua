local vi_mode = require('feline.providers.vi_mode')
local c = require('feline-components.conditions')

local M = {}

M.vi_mode = function(hls)
    local name = vi_mode.get_mode_highlight_name()
    return function()
        return {
            name = name,
            fg = hls[name] or vi_mode.get_mode_color(),
        }
    end
end

M.git_status = function(hls)
    local hls = hls
        or {
            inactive = { name = 'FCGitInactive', fg = 'bg' },
            changed = { name = 'FCGitChanged', fg = 'orange' },
            commited = { name = 'FCGitCommited', fg = 'green' },
        }
    return function()
        if c.is_git_workspace() then
            return hls.inactive
        end
        if c.is_git_changed() then
            return hls.changed
        else
            return hls.commited
        end
    end
end

return M
