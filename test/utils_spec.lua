local test = require('compline.test')
local u = require('compline.utils')

describe('is_empty', function()
    it('should return true for nil', function()
        assert.are.True(u.is_empty(nil))
    end)
    it('should return true for empty table', function()
        assert.are.True(u.is_empty({}))
    end)
    it('should return true for empty string', function()
        assert.are.True(u.is_empty(''))
    end)
end)

describe('iterate with sorted keys', function()
    it("should iterate over table's keys in order", function()
        -- given:
        local t = { a = 3, c = 1, b = 2 }
        local result = {}

        -- when:
        for k, v in u.sorted_by_keys(t) do
            result[k] = v
        end

        -- then:
        assert.are.same({ a = 3, b = 2, c = 1 }, result)
    end)
end)

describe('lsp_client', function()
    it('should return the first attached to the current buffer client', function()
        -- given:
        local clients = { { name = 'first' }, { name = 'second' } }
        local mock = function()
            return clients
        end
        test.use_mocked_table(vim.lsp, 'buf_get_clients', mock, function()
            -- when:
            local result = u.lsp_client()

            -- then:
            assert.are.same({ name = 'first' }, result)
        end)
    end)
end)

describe('lsp_client_icon', function()
    it('should find the icon for the client by the filetype', function()
        -- given:
        local client = { config = { filetypes = { 'other_type', 'test' } } }
        local icon = { name = 'test', icon = '!' }

        -- when:
        local result = u.lsp_client_icon({ test = icon }, client)

        -- then:
        assert.are.same(icon, result)
    end)

    it('should find the icon for the first attached client', function()
        -- given:
        local client = { config = { filetypes = { 'other_type', 'test' } } }
        local icon = { name = 'test', icon = '!' }
        local mock = function()
            return { client }
        end
        test.use_mocked_table(vim.lsp, 'buf_get_clients', mock, function()
            -- when:
            local result = u.lsp_client_icon({ test = icon })

            -- then:
            assert.are.same(icon, result)
        end)
    end)

    it('should take an icon from the "nvim-web-devicons"', function()
        -- given:
        local client = { config = { filetypes = { 'other_type', 'test' } } }
        local icon = { name = 'test', icon = '!' }
        local mock = function()
            return { test = icon }
        end
        test.use_mocked_module('nvim-web-devicons', 'get_icons', mock, function()
            -- when:
            local result = u.lsp_client_icon({}, client)

            -- then:
            assert.are.same(icon, result)
        end)
    end)
end)

describe('build_component', function()
    it('should take a component with the specified name from the library', function()
        -- given:
        local lib = {
            components = { test = { provider = 'example' } },
        }

        -- when:
        local result = u.build_component({ component = 'test' }, lib)

        -- then:
        assert.are.same({ component = 'test', provider = 'example' }, result)
    end)

    it(
        'should replace a property of the component from the lib by the value from the provided component',
        function()
            -- given:
            local lib = {
                components = { test = { provider = 'example' } },
            }

            -- when:
            local result = u.build_component({ component = 'test', provider = 'custom' }, lib)

            -- then:
            assert.are.same({ component = 'test', provider = 'custom' }, result)
        end
    )

    it('should put the `opts` to the `provider`', function()
        -- given:
        local lib = {
            components = { test = { provider = 'example' } },
        }

        -- when:
        local result = u.build_component({ component = 'test', opts = 'args' }, lib)

        -- then:
        assert.are.same({
            component = 'test',
            opts = 'args',
            provider = { name = 'example', opts = 'args' },
        }, result)
    end)

    it('should take an icon with the specified name from the lib', function()
        -- given:
        local lib = {
            components = { test = { provider = 'example' } },
            icons = { test_icon = { str = '!' } },
        }
        local component = {
            component = 'test',
            icon = 'test_icon',
        }

        -- when:
        local result = u.build_component(component, lib)

        -- then:
        assert.are.same(lib.icons.test_icon, result.icon)
    end)

    it(
        'should use a string as an icon, when the icon with such name is absent in the lib',
        function()
            -- given:
            local component = {
                icon = '!',
            }

            -- when:
            local result = u.build_component(component)

            -- then:
            assert.are.same({ icon = '!' }, result)
        end
    )

    it('should remove property with string value "nil"', function()
        -- given:
        local lib = {
            components = {
                test = { provider = 'example', icon = '!' },
            },
        }
        local component = {
            component = 'test',
            icon = 'nil',
        }

        -- when:
        local result = u.build_component(component, lib)

        -- then:
        assert.are.same({ component = 'test', provider = 'example' }, result)
    end)

    it('should remove nested property with string value "nil"', function()
        -- given:
        local lib = {
            components = {
                test = { icon = { str = '!', hl = 'green' } },
            },
        }
        local component = {
            component = 'test',
            icon = { hl = 'nil' },
        }

        -- when:
        local result = u.build_component(component, lib)

        -- then:
        assert.are.same({ component = 'test', icon = { str = '!' } }, result)
    end)

    it('should return nil in case of empty component', function()
        -- given:
        local component = {
            provider = 'nil',
        }

        -- when:
        local result = u.build_component(component)

        -- then:
        assert.are.equal(nil, result)
    end)

    it('should invoke `hl` function on initializing a component', function()
        -- given:
        local lib = {
            components = {
                test = {
                    hl = function(hls)
                        -- just returrn an argument to check it later
                        return hls
                    end,
                },
            },
        }
        local component = {
            component = 'test',
            hls = { fg = 'green' },
        }

        -- when:
        local result = u.build_component(component, lib)

        -- then:
        assert.are.same({ fg = 'green' }, result.hl())
    end)

    it("should use `hl` from the arguments when component doesn't have it", function()
        -- given:
        local lib = {}
        local hl = { fg = 'white', bg = 'black' }
        local component = { provider = 'test' }

        -- when:
        local result = u.build_component(component, lib, hl)

        -- then:
        assert.are.same({ provider = 'test', hl = hl }, result)
    end)

    it('should create component when only icon is specified', function()
        -- given:
        local component = {
            icon = 'expectation',
        }

        -- when:
        local result = u.build_component(component)

        -- then:
        assert.are.same({ icon = 'expectation' }, result)
    end)

    it('should invoke `icon` function on initializing a component', function()
        -- given:
        local lib = {
            components = {
                test = {
                    icon = function(opts, hls)
                        -- just return arguments to check them later
                        return { opts = opts, hls = hls }
                    end,
                },
            },
        }
        local opts = { prop = 'value' }
        local hls = { fg = 'green' }
        local component = {
            component = 'test',
            icon_opts = opts,
            icon_hls = hls,
        }

        -- when:
        local result = u.build_component(component, lib).icon()

        -- then:
        assert.are.same(opts, result.opts)
        assert.are.same(hls, result.hls)
    end)
end)
