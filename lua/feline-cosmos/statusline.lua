local i = require('feline-cosmos.icons')
local h = require('feline-cosmos.highlights')

local M = {}

local sep = { str = ' | ', hl = { fg = 'blue' } }
sep.always_visible = vim.deepcopy(sep)
sep.always_visible.always_visible = true

local active_left = {
    { component = 'vi_mode_bar' },
    { icon = i.file_status_icon() },
    { component = 'working_directory' },
    { component = 'relative_file_name' },
    { provider = ' ', hl = { fg = 'bg', bg = 'NONE' } },
}

local active_middle = {
    {
        name = 'metal_status',
        provider = function()
            return (vim.g['metals_status'] or '')
        end,
        hl = { fg = 'inactive', bg = 'NONE' },
    },
}

local active_right = {
    { provider = ' ', hl = { fg = 'bg', bg = 'NONE' } },
    { component = 'diagnostic_warnings' },
    { component = 'diagnostic_errors', right_sep = sep },
    { component = 'git_branch', right_sep = sep },
    { icon = i.lsp_client_icon() }, -- TODO: resolve icons in same way as components
    { icon = i.treesitter_parser_icon(), right_sep = sep.always_visible },
    { component = 'spellcheck', hls = { active = { fg = 'blue' } } },
    { provider = 'position', right_sep = sep, left_sep = sep },
    { provider = 'scroll_bar', hl = h.vi_mode()  },
}

local inactive_left = {
    { component = 'relative_file_name' },
}

local active = { active_left, active_middle, active_right }
local inactive = { inactive_left }

M.generate = function()
    return require('feline-cosmos.utils').build_statusline(
        active,
        inactive,
        require('feline-cosmos.components')
    )
end

M.setup = function(theme)
    local theme = theme or require('feline-cosmos.themes.dark')
    local components = M.generate()
    require('feline').setup({
        components = components,
        theme = theme,
        vi_mode_colors = theme.vi_mode_colors,
    })
end

return M
