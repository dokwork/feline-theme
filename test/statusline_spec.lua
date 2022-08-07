local Statusline = require('compline.statusline')

describe('Building componentns', function()
    it('should resolve components by their names', function()
        -- given:
        local components = {
            some_component = { provider = 'example', hl = 'ComponentHighlight' },
        }
        local statusline = Statusline.new('test', {
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
                    { name = 'some_component', provider = 'example', hl = 'ComponentHighlight' },
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

    it('should build components and sections in correct order', function()
        -- given:
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    b = { 'b', 'c' },
                    a = { 'a' },
                },
                right = {
                    z = { 'z' },
                    w = { 'w' },
                },
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { name = 'a', provider = 'a' },
                    { name = 'b', provider = 'b' },
                    { name = 'c', provider = 'c' },
                },
                {},
                {
                    { name = 'w', provider = 'w' },
                    { name = 'z', provider = 'z' },
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

describe('Resolving highlights', function()
    it('should use default hl if nothing specified in the theme', function()
        -- given:
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'some_component' },
                },
            },
            theme = {},
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        name = 'some_component',
                        provider = 'some_component',
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

    it('should add hl to components from the theme', function()
        -- given:
        local components = {}
        local theme = {
            active = {
                left = {
                    a = { hl = 'CustomHighlight' },
                    b = { hl = { bg = 'white' } },
                },
            },
        }
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'some_component_1' },
                    b = { 'some_component_2' },
                },
            },
            components = components,
            theme = theme,
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        name = 'some_component_1',
                        provider = 'some_component_1',
                        hl = 'CustomHighlight',
                    },
                    {
                        name = 'some_component_2',
                        provider = 'some_component_2',
                        hl = { bg = 'white' },
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

describe('Resolving separators', function()
    it("should add always visible zone's separators for the first and last components", function()
        -- given:
        local theme = {
            active = {
                left = {
                    separators = { left = '<', right = { str = '>', hl = { fg = 'red' } } },
                },
            },
        }
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'first' },
                    b = { 'other', 'last' },
                },
            },
            theme = theme,
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        name = 'first',
                        provider = 'first',

                        left_sep = { str = '<', always_visible = true },
                    },
                    {
                        name = 'other',
                        provider = 'other',
                    },
                    {
                        name = 'last',
                        provider = 'last',

                        right_sep = { str = '>', hl = { fg = 'red' }, always_visible = true },
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

    it("should add section's separators to the first and last components", function()
        -- given:
        local theme = {
            active = {
                left = {
                    a = {
                        separators = { left = '<', right = '>' },
                    },
                },
            },
        }
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'first', 'test', 'last' },
                },
            },
            theme = theme,
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        name = 'first',
                        provider = 'first',
                        left_sep = '<',
                    },
                    {
                        name = 'test',
                        provider = 'test',
                    },
                    {
                        name = 'last',
                        provider = 'last',
                        right_sep = '>',
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

    it("zone's separators must override sections separators", function()
        -- given:
        local theme = {
            active = {
                left = {
                    separators = { right = '>' },
                    a = { separators = { left = '[' } },
                    b = { separators = { right = ']' } },
                },
            },
        }
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'test 1' },
                    b = { 'test 2' },
                },
            },
            theme = theme,
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        name = 'test 1',
                        provider = 'test 1',
                        left_sep = '[',
                    },
                    {
                        name = 'test 2',
                        provider = 'test 2',
                        right_sep = { str = '>', always_visible = true },
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

    it('should use separators from the components', function()
        -- given:
        local components = {
            test = {
                provider = 'test',
                left_sep = '<',
                right_sep = { str = '>' },
            },
        }
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'test' },
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
                    {
                        name = 'test',
                        provider = 'test',
                        left_sep = '<',
                        right_sep = { str = '>' },
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

    it("components's separators must override section's separators", function()
        -- given:
        local theme = {
            active = {
                left = {
                    a = { separators = { left = '[', right = ']' } },
                },
            },
        }
        local components = {
            test = {
                provider = 'test',
                left_sep = '<',
                right_sep = '>',
            },
        }
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'test' },
                },
            },
            theme = theme,
            components = components,
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        name = 'test',
                        provider = 'test',
                        left_sep = '<',
                        right_sep = '>',
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

    it("components's separators must override zone's separators", function()
        -- given:
        local theme = {
            active = {
                separators = { left = '[', right = ']' },
            },
        }
        local components = {
            test = {
                provider = 'test',
                left_sep = '<',
                right_sep = '>',
            },
        }
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'test' },
                },
            },
            theme = theme,
            components = components,
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        name = 'test',
                        provider = 'test',
                        left_sep = '<',
                        right_sep = '>',
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
