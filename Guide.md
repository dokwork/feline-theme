# Guide to feline-theme

The best way to understand how something works is using it to create some example.
Here we're going to create a simple statusline  theme with dynamic colors, which depends on
the background:

```viml
:echo &background
> light
```
![light_example](light_example.png)

```viml
:echo &background
> dark
```
![dark_example](dark_example.png)

_Note, that changing background will not affect the statusline. Only changing the colorscheme will
have an effect._

## Configuration of the statusline

### Describe statusline

`Feline-theme` provides a way to describe components for _active_ and _inactive_ statusline.
In both cases the statusline has three zones: _left_, _middle_ and _right_. Every zone can have
unlimited sections. Sections can have arbitrary names. But, it would be better to follow next
convention: left and middle zones should have sections with chars from a to z as their names,
and right zone should have sections with names from z to a. Names can intersect in different zones,
it's ok.

In this example we'll turn our minds only to the _active_ line. The _inactive_ line has completely
the same rules, as _active_.

```lua
local statusline = {
    active = {
        left = {
            -- in the first section 'a' we will have a name of the current vi mode:
            a = { 'vi_mode' },
            -- then a shorten full path to the working directory will be in the section 'b':
            b = { 'short_working_directory' },
            -- and the name of the current file will be in the last section 'c':
            c = { 'file_name' },
        },
        middle = {
            -- we'll put a current time to the middle:
            a = { 'time' },
        },
        right = {
            -- far right component will show the current cursor position:
            z = { 'position' },
            -- info abount encoding and format of the file will go before the section 
            -- with cursor position:
            y = { 'file_encoding', 'file_format' },
        },
    },
}
```

### Describe components

Now, let's prepare components for our statusline. Every component mentioned in the statusline
will be looked in the table with components. If a key with the name of the component is found, the
value will be used as a component description, which should follow the feline's rules of components 
describing: [USAGE.md#component
values](https://github.com/feline-nvim/feline.nvim/blob/master/USAGE.md#component-values).
Otherwise, a new component with eponymous provider will be created. Regardless of how component was
created, the `name` property will be added to it. 

```lua
statusline.components = {
    vi_mode = {
        provider = 'vi_mode',
        -- turn icon off and use full name of the mode
        icon = ''
    }

    short_working_directory = {
        provider = function()
            return vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.getcwd(), ':p'))
        end,
    }

    file_name = {
        provider = function()
            return vim.fn.expand('%:t')
        end,
    }

    time = {
        provider = function()
            return vim.fn.strftime('%H:%M')
        end,
    }

    file_format = {
        provider = {
            name = 'file_type',
            opts = {
                filetype_icon = true,
                case = 'lowercase',
            },
        },
    }
}
```


### Describe colors

Our statusline is ready, but looks ugly. To fix it we need to describe which colors should be used
in the every section and maybe add separators between sections and zones. But, before we begin
describing a theme, we need prepare palette of colors. A palette is a table with colors, where the
keys are names of the colors, and values are `#RRGGBB` colors. `feline-theme` can have a few
palettes, which will be chosen depending on the `background` option and current `statusline`. So, you
can specify colors for `dark` and/or `light` background, and/or create palette for particular
colorscheme with appropriate key. But the simplest way is create `default` palette, which will be
used when nor palette with the name of the current colorscheme, nor `light`/`dark` palettes will be
found.

Ok, let's create a default palette with `fg` and `bg` colors, plus colors for sections `a`, `b`,
`c`, `d`, and `z`, `y`, `x`, `w`. Colors in our palette will be generated automatically, changing
brightness of the `bg` color for every next section:

```lua
local u = require('feline-theme.utils')

-- We begin from the default background for Statusline
-- and will make it lighter/darker (depends on vim.go.background)
-- for every next section
local gradient_colors = function()
    local function change(color)
        if vim.go.background == 'light' then
            return u.darkening_color(color, 0.4, 0.3, 0.1)
        else
            return u.ligthening_color(color, 0.2, 0.2, 0.3)
        end
    end
    local colors = {}
    colors.fg = vim.go.background == 'light' and 'White' or 'Black'
    colors.bg = u.get_hl_bg('Statusline') or (vim.go.background == 'light' and '#c8c8cd' or '#505050')
    colors.d = change(colors.bg)
    colors.c = change(colors.d)
    colors.b = change(colors.c)
    colors.a = change(colors.b)

    colors.z = colors.a
    colors.y = colors.b
    colors.x = colors.c
    colors.w = colors.d

    return colors
end

statusline.colors = { default = gradient_colors }
```

Colors must be recalculated, when user will change the colorscheme. This is why palette can be
represented as a function, which returns table with colors.


### Describe theme

When we have prepared palettes, we're ready to create a theme for our statusline. The theme has
pretty similar structure as a statusline, but instead of list of components, sections should have
description of their highlights. The highlights follow the same rules as feline: [USAGE.md#component
highlight](https://github.com/feline-nvim/feline.nvim/blob/master/USAGE.md#component-highlight).

Additionally to highlights, we can specify separators for zones and sections in the theme. All
separators will be added to the extreme components by the follow rules:
1. zones' separators will override sections' separators;
1. zones' separators will be created with property `always_visible = true`;
1. separators, which were described directly in the components will override any separators from the
   theme.

Rules for describe a separator the same as in the feline: [USAGE.md#component
separators](https://github.com/feline-nvim/feline.nvim/blob/master/USAGE.md#component-separators).

We will use two utility functions, to use colors, specific for the current vi mode:
```lua
local vi_mode_bg = function()
    return {
        bg = require('feline.providers.vi_mode').get_mode_color(),
    }
end

-- NOTE: this function return another function!
-- This is done to be able to specify a different bacground color:
local vi_mode_fg = function(bg)
    return function()
        return {
            fg = require('feline.providers.vi_mode').get_mode_color(),
            bg = bg,
        }
    end
end
```

Our left and right zones should have   and   as separators respectively. It'll separate them from
the middle zone. The sections inside zones will have symbols  and  as separators:

```lua
statusline.theme = {
    active = {
        left = {
            separators = { right = ' ' },
            a = {
                hl = vi_mode_bg,
                separators = { right = { str = '', hl = vi_mode_fg('b') } },
            },
            b = {
                hl = { bg = 'b' },
                separators = { right = { str = '', hl = { fg = 'b', bg = 'c' } } },
            },
            c = {
                hl = { bg = 'c' },
                separators = { right = { str = '', hl = { fg = 'c', bg = 'd' } } },
            },
            d = {
                hl = { bg = 'd' },
                separators = { right = { str = '', hl = { fg = 'd', bg = 'bg' } } },
            },
        },
        right = {
            separators = { left = ' ' },
            w = {
                hl = { bg = 'w' },
                separators = { left = { str = '', hl = { bg = 'bg' } } },
            },
            x = {
                hl = { bg = 'x' },
                separators = { left = { str = '', hl = { bg = 'w' } } },
            },
            y = {
                hl = { bg = 'y' },
                separators = { left = { str = '', hl = { bg = 'x' } } },
            },
            z = {
                hl = vi_mode_bg,
                separators = { left = { str = '', hl = vi_mode_fg('y') } },
            },
        },
    },

    vi_mode = {
        NORMAL = 'green',
        OP = 'magenta',
        INSERT = 'blue',
        VISUAL = 'magenta',
        LINES = 'magenta',
        BLOCK = 'magenta',
        REPLACE = 'violet',
        ['V-REPLACE'] = 'pink',
        ENTER = 'cyan',
        MORE = 'cyan',
        SELECT = 'yellow',
        COMMAND = 'orange',
        SHELL = 'yellow',
        TERM = 'orange',
        NONE = 'yellow',
    },
}
```

_Note, that the vi mode colors are part of the theme, not the colors!_

### Setup statusline

Finally, the last step is setup of our statusline:

```lua
require('feline-theme').setup_statusline(statusline)
```

## Statusline's commands

In successful case, the `FelineTheme` global lua variable become available. It provides ability
to work with the current statusline as with `FelineTheme.statusline` variable.

### Showing the components

The final schema is not simple, and your can easily make a mistake on describing your statusline.
For debug purpose, the statusline in `feline-theme` has few methods, which can help you to find
mistakes. The first one is `build_components`, which compose together the description of the
statusline, components, colors and theme, and returns a table with feline's components. You can
print them to looking for mistakes:

```lua
:lua vim.pretty_print(FelineTheme.statusline:build_components())
```

Or you can use the second short way:

```lua
:lua FelineTheme.statusline:show_components()
```

### Showing and refresh colors

`feline-theme` creates an `autocmd` to change colors on changing the colorscheme. To do it manually,
you can run:

```lua
:lua FelineTheme.statusline:refresh_colors()
```

To see the colors, which should be used according to the current vim settings, you can print the
result of the `actual_colors`:

```lua
:lua vim.pretty_print(FelineTheme.statusline:actual_colors())
```

Or shortly:

```lua
:lua FelineTheme.statusline:show_actual_colors()
```

### Show the full configuration

Obviously, you can print the full current configuration just using the `FelineTheme.statusline`:

```lua
:lua vim.pretty_print(FelineTheme.statusline)
```

But, you can do it easily:

```lua
:lua FelineTheme.statusline:show_all()
```

That's all for today! See you!  
