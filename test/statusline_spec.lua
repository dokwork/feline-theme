local Statusline = require('compline.statusline')

describe('Building componentns', function()
    it('should build components and sections in correct order', function()
        -- given:
        local statusline = Statusline:new('test', {
            active = {
                left = {
                    b = { 'b', 'c' },
                    a = { 'a' },
                },
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = 'a' },
                    { provider = 'b' },
                    { provider = 'c' },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it('should resolve components by their names', function()
        -- given:
        local components = {
            some_component = { provider = 'example' },
        }
        local statusline = Statusline:new('test', {
            active = {
                left = {
                    a = { 'some_component' },
                },
            },
            components = components,
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = 'example' },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it('should add hl to components from the theme', function()
        -- given:
        local components = {
            some_component = { provider = 'example' },
        }
        local theme = {
            active = {
                left = {
                    sections = {
                        a = { hl = { fg = 'black', bg = 'whignoree' } },
                    },
                },
            },
        }
        local statusline = Statusline:new('test', {
            active = {
                left = {
                    a = { 'some_component' },
                },
            },
            components = components,
            themes = {
                default = theme,
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = 'example', hl = { fg = 'black', bg = 'whignoree' } },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it("should use hl from a component when ignore's specified", function()
        -- given:
        local components = {
            some_component = { provider = 'example', hl = { fg = 'red' } },
        }
        local theme = {
            active = {
                left = {
                    sections = {
                        a = { hl = { fg = 'black', bg = 'whignoree' } },
                    },
                },
            },
        }
        local statusline = Statusline:new('test', {
            active = {
                left = {
                    a = { 'some_component' },
                },
            },
            components = components,
            themes = {
                default = theme,
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = 'example', hl = { fg = 'red' } },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it("should create components for zone's separators", function()
        -- given:
        local theme = {
            active = {
                left = {
                    separators = { left = '<', right = { '>', hl = 'red' } },
                },
            },
        }
        local statusline = Statusline:new('test', {
            active = { left = { a = { 'test' } } },
            themes = {
                default = theme,
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = '<' },
                    { provider = 'test' },
                    { provider = '>', hl = 'red' },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it("zone's separators must override sections separators", function()
        -- given:
        local theme = {
            active = {
                left = {
                    separators = { right = ' ' },
                    sections = {
                        separators = { left = '<', right = { '>' } },
                    },
                },
            },
        }
        local statusline = Statusline:new('test', {
            active = { left = { a = { 'test' } } },
            themes = {
                default = theme,
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = 'test', left_sep = { str = '<' } },
                    { provider = ' ' },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it("should add section's separators to the outside components", function()
        -- given:
        local theme = {
            active = {
                left = {
                    sections = {
                        a = { separators = { left = { '<' }, right = { '>', hl = 'green' } } },
                    },
                },
            },
        }
        local statusline = Statusline:new('test', {
            themes = {
                default = theme,
            },
            active = {
                left = {
                    a = { 'test' },
                },
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        provider = 'test',
                        left_sep = { str = '<' },
                        right_sep = { str = '>', hl = 'green' },
                    },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it("section's separators must override component's separators", function()
        -- given:
        local theme = {
            active = {
                left = {
                    sections = {
                        separators = { right = ' ' },
                        a = { separators = { left = { '<' }, right = { '>' } } },
                    },
                },
            },
        }
        local statusline = Statusline:new('test', {
            themes = {
                default = theme,
            },
            active = {
                left = {
                    a = { 'test' },
                },
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        provider = 'test',
                        left_sep = { str = '<' },
                        right_sep = { str = ' ' },
                    },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)
end)

describe('Extending an existing statusline', function()
    local existed_statusline = Statusline:new('existed', {
        active = {
            left = {
                a = { 'component 1', 'component 2' },
                b = { 'component 3' },
            },
        },
    })

    it('should override the section', function()
        -- given:
        local new_statusline = existed_statusline:new('new', {
            active = {
                left = {
                    a = { 'component 1', 'new' },
                },
            },
        })

        -- when:
        local result = new_statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = 'component 1' },
                    { provider = 'new' },
                    { provider = 'component 3' },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it('should remove the section', function()
        -- given:
        local new_statusline = existed_statusline:new('new', {
            active = {
                left = {
                    a = 'nil',
                    b = 'nil',
                },
            },
        })

        -- when:
        local result = new_statusline:build_components()

        -- then:
        local expected = {
            active = {
                {},
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it('should remove active components and add inactive', function()
        -- given:
        local new_statusline = existed_statusline:new('new', {
            active = 'nil',
            inactive = {
                right = {
                    a = { 'new' },
                },
            },
        })

        -- when:
        local result = new_statusline:build_components()

        -- then:
        local expected = {
            inactive = {
                {},
                {},
                {
                    { provider = 'new' },
                },
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)
end)
