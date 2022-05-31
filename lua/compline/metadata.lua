------------------------------------------------------------------
-- This script contains EmmyLua Annotations for all used types. --
------------------------------------------------------------------

---@alias LspClient table #an object which returns from the `vim.lsp.client()`.

---@alias DevIcon table #an object which returns from the 'nvim-web-devicons' module.

---@alias RGB string # RGB hex color description

---@alias Color string # a name of the color or RGB hex color description

---@alias Highlight string|table|function # similar to the highlight from the Feline, but a function
---can take a table as an argument.

---@alias Provider string|table|function

---@class Icon
---@field str string
---@field hl Highlight
---@field always_visible boolean

---@class FelineComponent # see complete description here: |feline-components|
---@field name string
---@field provider Provider
---@field hl string|table|function # a description of the highlight according to the |feline-Component-highlight|
---@field icon Icon
---@field enabled boolean

---@class FelineSetup # see |feline-setup-function|
---@field components table
---@field conditional_components table
---@field custom_providers table
---@field theme string|table
---@field separators table
---@field force_inactive table

---@class Component : FelineComponent
---@field component string # a name of the existing component which will be used as a prototype.
---@field hls table<string, Highlight> # custom highlights for the component.

---@alias Section Component[]

---@class Line
---@field left   table<string, Section>
---@field middle table<string, Section>
---@field right  table<string, Section>

---@class Theme
---@field colors  table<string, RGB> # key - name of a color; value - RGB hex color description
---@field vi_mode table<string, RGB> # key - name of the vi mode; value - RGB hex color description

---@class Library # library of reusable components.
---@field components table<string, Component>
---@field providers  table<string, Provider>
---@field highlights table<string, Highlight>
---@field icons      table<string, Icon>
---@field themes     table<string, Theme>

---@class Statusline
---@field name      string
---@field active    Section[] list of sections with components for an active window.
---@field inactive  Section[] list of sections with components for an inactive window.
---@field theme?    Theme     optional name of particular theme which should be used with this
---                           statusline. If absent, a theme with the same name as the current
---                           colorscheme will be taken (if exists)
---@field lib       Library
