# Components line 

![light_example](light_example.png)
![dark_example](dark_example.png)

This plugin is an extension for the [feline.nvim](https://github.com/feline-nvim/feline.nvim), which
combines advantages of the templating similar to the
[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) with powerful syntax for description
components of the statusline from the `feline.nvim`.

## Configuration example

Let's see how to create a simple statusline:

```lua

-- Prepare needed components --

local components = {
  mode = {
      provider = require('feline.providers.vi_mode').get_vim_mode,
  }

  file_name = {
      provider = function()
          return vim.fn.expand('%:t')
      end,
  }
}

-- Describe how the statusline should look like --

local vi_mode_fg = function()
    return {
        fg = require('feline.providers.vi_mode').get_mode_color(),
        bg = 'bg',
    }
end

local vi_mode_bg = function()
    return {
        fg = 'fg',
        bg = require('feline.providers.vi_mode').get_mode_color(),
    }
end

local theme = {
    active = {
        left = {
            separators = { right = { '', hl = vi_mode_fg } },
            sections = {
                a = { hl = vi_mode_bg, rs = ' ' },
                b = { hl = vi_mode_fg, rs = ' ' }
            },
        },
        right = {
            separators = { left = { '', hl = vi_mode_fg } },
            sections = {
                c = { hl = vi_mode_fg, ls = ' ' },
                d = { hl = vi_mode_bg, ls = ' ' },
            },
        },
    },

    dark = {
        bg = '#282c34'
    }
}

-- Create your oun statusline --

local statusline = require('compline.statusline'):new('example', {
    active = {
        left = {
            a = { 'mode' },
            c = { 'file_name' },
        },
        right = {
            e = { 'file_type' },
            g = { 'position' },
        },
    },
    inactive = {
        left = {
            a = { 'file_name' },
        },
    },
    themes = {
        default = theme,
    },
    components = components
})
```

More details about configuration you can find here: [Guide.md](Guide.md).

## How to install

With [packer.nvim](https://github.com/wbthomason/packer.nvim/):

```lua
use({
    'dokwork/compline.nvim',
    requires = {
        'kyazdani42/nvim-web-devicons',
        'famiu/feline.nvim',
        'tpope/vim-fugitive', -- used for git components
    },
    -- optionally, you can setup preconfigured statusline:
    config = function()
        require('compline.cosmosline'):setup()
    end,
})
```

## Motivation

I'm glad to use the [feline.nvim](https://github.com/feline-nvim/feline.nvim) plugin. This is a very
powerful and useful plugin for configuring the neovim statusline. But for my taste, the final
configuration usually looks a little bit cumbersome and messy. I prefer to separate an
implementation of the components and their composition. 

This project is more the proof of concept, instead of the final solution, and currently **is under
develop**.
