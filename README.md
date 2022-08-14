# Feline-theme

![light_example](light_example.png)
![dark_example](dark_example.png)

This plugin is an extension for the [feline.nvim](https://github.com/feline-nvim/feline.nvim), which
combines advantages of the templating similar to the
[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) with powerful syntax for components
description of the statusline from the `feline.nvim`.

## Configuration example

Let's see how to create a simple statusline:

```lua

-- Prepare needed components --
local components = {
    vi_mode = {
        provider = 'vi_mode',
        icon = ''
    }

  file_name = {
      provider = function()
          return vim.fn.expand('%:t')
      end,
  }
}

-- Describe how the statusline should look like --
local theme = {
    active = {
        left = {
            separators = { right = '', hl = { fg = 'blue' } },
            a = { hl = { bg = 'blue' } },
        },
        right = {
            separators = { left = { '', hl = { fg = 'green' } } },
            z = { hl = { bg = 'green' } },
        },
    },
}

-- Create your oun statusline --
require('feline-theme').setup_statusline({
    active = {
        left = {
            a = { 'file_name' },
        },
        right = {
            z = { 'vi_mode' },
        },
    },
    theme = theme,
    components = components
})
```

More details about configuration you can find in the [Guide.md](Guide.md).

## How to install

_This project **is under development**. API can be changed in non compatible way, so, it may be good
idea to use a tagged version in your own configuration._

With [packer.nvim](https://github.com/wbthomason/packer.nvim/):

```lua
use({
    'dokwork/feline-theme',
    requires = {
        'kyazdani42/nvim-web-devicons',
        'famiu/feline.nvim',
    },
    config = function()
        -- setup your statusline on start:
        require('feline-theme').setup_statusline(require('feline-theme.example'))
    end,
})
```

## Motivation

I'm glad to use the [feline.nvim](https://github.com/feline-nvim/feline.nvim) plugin. This is a very
powerful and useful plugin for configuring the neovim statusline. But, to my taste, the final
configuration usually looks a little bit cumbersome and messy. I prefer to separate an
implementation of the components and their composition. 
