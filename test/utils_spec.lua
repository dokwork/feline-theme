local u = require('compline.utils')

---@type fun(table: table, prop: string | number, mock: any, test: function): any
-- Replaces a value in the {table} with a key {prop} by the {mock], and run the {test}.
-- Then restores an original value of the {table}, when the {test} is completed
-- (despite of errors), and returns thr result of the {test}.
local use_mocked_table = function(table, prop, mock, test)
    local orig = table[prop]
    table[prop] = mock
    local ok, result = pcall(test)
    table[prop] = orig
    if ok then
        return result
    else
        error(result)
    end
end

---@type fun(module: string, prop: string | number, mock: any, test: function): any
-- Replace a value in the {module} with a key {prop} by the {mock}, and run the {test}.
-- Then unload {module}, when test is completed (despite errors in the {test}).
local use_mocked_module = function(module, prop, mock, test)
    package.loaded[table] = nil
    local m = require(module)
    m[prop] = mock
    local ok, result = pcall(test)
    package.loaded[table] = nil
    if ok then
        return result
    else
        error(result)
    end
end

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

describe('colors utilities', function()
    describe('create a color', function()
        it('should create string with color', function()
            -- given:
            local r, g, b = 0, 0, 0

            -- then:
            assert.are.equal('#000000', u.create_color(r, g, b))
        end)
    end)

    describe('parse RGB color', function()
        it('should return numbers for every part of the color', function()
            -- given:
            local color = '#11AA4B'

            -- when:
            local r, g, b = u.parse_rgb_color(color)

            -- then:
            assert.are.equal(17, r)
            assert.are.equal(170, g)
            assert.are.equal(75, b)
        end)
    end)

    describe('changing a brightness of a color', function()
        it('should make a color lighter', function()
            -- given:
            local color = '#9e6f11'

            -- when:
            local light_color = u.ligthening_color(color)

            -- then:
            assert.are.equal('#a77d28', light_color)
        end)

        it('should make a color darker', function()
            -- given:
            local color = '#9e6f11'

            -- when:
            local light_color = u.darkening_color(color)

            -- then:
            assert.are.equal('#8e630f', light_color)
        end)
    end)
end)

describe('lsp_client', function()
    it('should return the first attached to the current buffer client', function()
        -- given:
        local clients = { { name = 'first' }, { name = 'second' } }
        local mock = function()
            return clients
        end
        use_mocked_table(vim.lsp, 'buf_get_clients', mock, function()
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
        use_mocked_table(vim.lsp, 'buf_get_clients', mock, function()
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
        use_mocked_module('nvim-web-devicons', 'get_icons', mock, function()
            -- when:
            local result = u.lsp_client_icon({}, client)

            -- then:
            assert.are.same(icon, result)
        end)
    end)
end)
