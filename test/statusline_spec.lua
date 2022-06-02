local Statusline = require('compline.statusline')

describe('Creating a new statusline', function()
    it('should build sort sections and zones', function()
        -- given:
        local statusline = Statusline:new('test', {
            active = {
                left = {
                    b = {
                        { provider = 'b' },
                        { provider = 'c' },
                    },
                    a = {
                        { provider = 'a' },
                    },
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
end)

describe('Extending an existing statusline', function()
    local existed_statusline = Statusline:new('existed', {
        active = {
            -- single section --
            left = {
                a = {
                    -- with single component --
                    { provider = 'test' },
                },
            },
        },
    })

    it('should override the component', function()
        -- given:
        local new_statusline = existed_statusline:new('new', {
            active = {
                left = {
                    a = {
                        { provider = 'new' },
                    },
                },
            },
        })

        -- when:
        local result = new_statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
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
                    a = {
                        { provider = 'nil' },
                    },
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
        assert.are.same(expected, result, vim.inspect(result))
    end)

    it('should remove active components and add inactive', function()
        -- given:
        local new_statusline = existed_statusline:new('new', {
            active = 'nil',
            inactive = {
                right = {
                    a = {
                        { provider = 'new' },
                    },
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
