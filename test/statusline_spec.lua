local schema = require('compline.schema')
local feline_schema = require('compline.schema.feline')
local Statusline = require('compline.statusline')

describe('statusline schema validation', function()
    it('should be passed', function()
        -- when:
        local ok, err = schema.validate(feline_schema.statusline, schema.type)

        -- then:
        assert(ok, tostring(err))
    end)

    it('should be passed for the zone', function()
        -- given:
        local zone = {
            a = { 'str' },
        }

        -- when
        local ok, err = schema.validate(zone, feline_schema.zone)

        -- then:
        assert(ok, tostring(err))
    end)

    it('should be passed for the line', function()
        -- given:
        local line = {
            left = {
                a = { 'str' },
            },
        }

        -- when
        local ok, err = schema.validate(line, feline_schema.line)

        -- then:
        assert(ok, tostring(err))
    end)
end)

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
                    a = { fg = 'black', bg = 'white' },
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
                    { provider = 'example', hl = { fg = 'black', bg = 'white' } },
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

    it("should use hl from a component when it's specified", function()
        -- given:
        local components = {
            some_component = { provider = 'example', hl = { fg = 'red' } },
        }
        local theme = {
            active = {
                left = {
                    a = { fg = 'black', bg = 'white' },
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

    it('should create components for zones separators', function()
        -- given:
        local theme = {
            active = {
                separators = { left = '>', right = '<' },
            },
        }
        local statusline = Statusline:new('test', {
            active = {},
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
                    { provider = '>' },
                },
                {},
                {
                    { provider = '<' },
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

    it('should add hl for zones separators', function()
        -- given:
        local theme = {
            active = {
                separators = { left = '>', right = { provider = '<', hl = 'red' } },
            },
        }
        local statusline = Statusline:new('test', {
            active = {},
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
                    { provider = '>' },
                },
                {},
                {
                    { provider = '<', hl = 'red' },
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

    it('should add components as sections separators', function()
        -- given:
        local theme = {
            active = {
                left = {
                    separators = { left = '<', right = { provider = '>', hl = 'green' } },
                },
            },
        }
        local statusline = Statusline:new('test', {
            themes = {
                default = theme,
            },
            active = {
                left = {
                    a = { 'component' },
                },
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = '<' },
                    { provider = 'component' },
                    { provider = '>', hl = 'green' },
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
