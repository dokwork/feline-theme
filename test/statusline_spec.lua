local Statusline = require('compline.statusline')

describe('Creating a new statusline', function()
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
            'Expected:\n%s\nActual:\n%s',
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
            'Expected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)
end)

describe('Resolving theme', function()
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
                    { provider = 'example', { fg = 'black', bg = 'white' } },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            'Expected:\n%s\nActual:\n%s',
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
            'Expected:\n%s\nActual:\n%s',
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
            'Expected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it('should add hl for zones separators', function()
        -- given:
        local theme = {
            active = {
                left = {
                    separators = { left = '>', right = { '<', hl = 'red' } },
                },
            },
        }
        local statusline = Statusline:new('test', {
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
                    { provider = '>', hl = 'red' },
                },
                {},
                {
                    { provider = '<', hl = 'green' },
                },
            },
        }
        local msg = string.format(
            'Expected:\n%s\nActual:\n%s',
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
                    separators = { left = { '<' }, right = { '>', hl = 'green' } },
                },
            },
        }
        local statusline = Statusline:new('test', {
            themes = {
                default = theme,
            },
            active = {
                a = { 'component' },
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
            'Expected:\n%s\nActual:\n%s',
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
            },
        },
    })

    it('should override the component', function()
        -- given:
        local new_statusline = existed_statusline:new('new', {
            active = {
                left = {
                    a = { [2] = 'new' },
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
                },
                {},
                {},
            },
        }
        assert.are.same(expected, result, vim.inspect(result))
    end)

    it('should remove the component', function()
        -- given:
        local new_statusline = existed_statusline:new('new', {
            active = {
                left = {
                    a = { [1] = 'nil' },
                },
            },
        })

        -- when:
        local result = new_statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = 'component 2' },
                },
                {},
                {},
            },
        }
        assert.are.same(expected, result, vim.inspect(result))
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
        assert.are.same(expected, result, vim.inspect(result))
    end)
end)
