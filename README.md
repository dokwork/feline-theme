# feline-cosmos 
### ! Work in progress !

![dark_example](dark_example.png)

This plugin is an extension for the [feline.nvim](https://github.com/feline-nvim/feline.nvim). 
It follows the idea of reusing providers and makes it possible to reuse other main properties 
of components, such as highlighting or icons. More over, with `feline-cosmos` you can reuse 
the whole component.

For example, assume you have a script, where all your components are described:

```lua
-- my_components.lua

return {
  progress = {
    provider = 'scroll_bar', -- default provider from the feline
    hl = 'vi_mode' -- highlight according to the current vi mode
  },

  file = {
    provider = 'file_info', -- default provider from the feline
    hl = 'file_status' -- highlight depends on the current state of the file (readonly, modified or nothing)
  }
}
```

Now, you can describe your status line just referring to appropriate components in the same way 
as the original `feline` plugin:

```lua
-- my_statusline.lua

return {
  active = {
    { component = 'progress' },
    { component = 'file' }
  },
  inactive = {
    -- in an inactive window we want always to show a file_info in grey
    { component = 'file', hl = { fg = 'grey' } }
  }
}
```

And finally, set up your status line:

```lua
require('feline-cosmos').setup {
  components = require('my_statusline'),
  custom_components = require('my_components')
}
```

## Motivation

I'm glad to use the [feline.nvim](https://github.com/feline-nvim/feline.nvim) plugin. This is a very
powerful and useful plugin for configuring the neovim statusline. But for my taste, the final
configuration usually looks a little bit cumbersome and messy. I prefer to separate an
implementation of components and their composition. Also, I think that not only providers deserve
being reusable, but icons and highlights too. Of course, resolving providers, icons, highlights, or
whole components has a performance penalty. But first, the penalty is not so big, and second, I'm
ready to sacrifice performance for the sake of clarity.
