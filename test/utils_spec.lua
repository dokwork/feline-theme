local test = require('feline-components.test')
local u = require('feline-components.utils')

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

    it('should transform string to icon', function()
        -- given:
        local client = { config = { filetypes = { 'other_type', 'test' } } }

        -- when:
        local result = u.lsp_client_icon({ test = '!' }, client)

        -- then:
        assert.are.same({ name = 'test', icon = '!' }, result)
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
