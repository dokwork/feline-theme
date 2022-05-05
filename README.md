# feline-cosmos

This plugin is an extension of the [feline.nvim](https://github.com/feline-nvim/feline.nvim). 
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
    hl = 'file_status' -- highlight depends on the current state of the file (readonly, modified or not)
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
    -- on inactive window we want always show file info in the grey color
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

I'm glad to use the [feline.nvim](https://github.com/feline-nvim/feline.nvim) plugin. 
This is a very powerful and useful plugin for configuring the vim statusline.
But for my taste, the final configuration usually looks a little bit cumbersome
and messy. I prefer to separate an implementation of components and their
composition. Also, I think that not only providers deserve being reusable, but icons and
highlights too. Of course, resolving providers, icons, highlights, or whole components has
a penalty. But first, the penalty is not so big, and second, I'm ready to sacrifice the 
performance for the sake of clarity.

Nevertheless, this plugin is more a proof of concept of such idea, than the final solution.
