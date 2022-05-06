local test = require('feline-cosmos.test')
local u = require('feline-cosmos.utils')

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
        assert.are.equal(icon, result)
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
            assert.are.equal(icon, result)
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
            assert.are.equal(icon, result)
        end)
    end)
end)

describe('build_component', function()
    it('should take a component with apropriate name from the library', function()
        -- given:
        local lib = {
            components = { test = { name = 'example' } },
        }

        -- when:
        local result = u.build_component({ component = 'test' }, lib)

        -- then:
        assert.are.same({ component = 'test', name = 'example' }, result)
    end)

    it('should invoke `hl` function on initializing the component', function()
        -- given:
        local component = {
            hl = function(hls)
                return function()
                    return hls
                end
            end,
        }
        local lib = {
            components = { test = component },
        }
        local hl = { fg = 'green' }

        -- when:
        local result = u.build_component({
            component = 'test',
            hls = hl,
        }, lib)

        -- then:
        assert.are.same(hl, result.hl())
    end)

    it('should invoke `icon` function on initializing the component', function()
        -- given:
        local component = {
            icon = function(component, opts, hls)
                return function()
                    return { component = component, opts = opts, hls = hls }
                end
            end,
        }
        local lib = {
            components = { test = component }
        }
        local opts = { prop = 'value' }
        local hls = { fg = 'green' }

        -- when:
        local result = u.build_component({
            component = 'test',
            opts = opts,
            hls = hls,
        }, lib).icon()

        -- then:
        assert.are.same(opts, result.opts)
        assert.are.same(hls, result.hls)
    end)
end)
