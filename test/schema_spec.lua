local s = require('lua-schema')
local c = require('feline-theme.schema.colors')
local t = require('feline-theme.schema.theme')
local st = require('feline-theme.schema.statusline')
local feline = require('feline-theme.schema.feline')

describe('feline schema validation', function()
    it('should be passed for every object', function()
        -- when:
        for name, schema in pairs(feline) do
            local ok, err = s.validate(schema, s.type)

            -- then:
            assert(
                ok,
                string.format(
                    'Error on validation schema of the %s.\nReason:\n%s\nSchema:\n%s',
                    name,
                    err,
                    vim.inspect(schema)
                )
            )
        end
    end)

    it('should be passed for highlight', function()
        assert(s.validate('red', feline.highlight))
        assert(s.validate({ fg = 'red', bg = 'green' }, feline.highlight))
        -- example with a function
        assert(s.validate(it, feline.highlight))
    end)
end)

describe('colors schema validation', function()
    it('should be passed for every object', function()
        -- when:
        for name, schema in pairs(c) do
            local ok, err = s.validate(schema, s.type)

            -- then:
            assert(
                ok,
                string.format(
                    'Error on validation schema of the %s.\nReason:\n%s\nSchema:\n%s',
                    name,
                    err,
                    vim.inspect(schema)
                )
            )
        end
    end)
end)

describe('theme schema validation', function()
    it('should be passed for every object', function()
        -- when:
        for name, schema in pairs(t) do
            local ok, err = s.validate(schema, s.type)

            -- then:
            assert(
                ok,
                string.format(
                    'Error on validation schema of the %s.\nReason:\n%s\nSchema:\n%s',
                    name,
                    err,
                    vim.inspect(schema)
                )
            )
        end
    end)
end)

describe('statusline schema validation', function()
    it('should be passed for every object', function()
        -- when:
        for name, schema in pairs(st) do
            local ok, err = s.validate(schema, s.type)

            -- then:
            assert(
                ok,
                string.format(
                    'Error on validation schema of the %s.\nReason:\n%s\nSchema:\n%s',
                    name,
                    err,
                    vim.inspect(schema)
                )
            )
        end
    end)

    it('should be passed for the zone', function()
        -- given:
        local zone = {
            a = { 'str' },
        }

        -- when
        local ok, err = s.validate(zone, st.zone)

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
        local ok, err = s.validate(line, st.line)

        -- then:
        assert(ok, tostring(err))
    end)
end)
