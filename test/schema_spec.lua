local s = require('compline.schema')

describe('validation the schema', function()
    it('should be passed for every type', function()
        assert(s.call_validate(s.list(), s.type()), 'Wrong schema for the list')
        assert(s.call_validate(s.oneof(), s.type()), 'Wrong schema for the oneof')
        assert(s.call_validate(s.const(), s.type()), 'Wrong schema for the const')
        assert(s.call_validate(s.table(), s.type()), 'Wrong schema for the table')
        assert(s.call_validate(s.type(), s.type()), 'Wrong schema for the type')
    end)

    it('should be passed for "any" type', function()
        -- given:
        local schema = 'any'

        -- then:
        assert(s.call_validate(nil, schema))
        assert(s.call_validate({ a = 'a' }, schema))
        assert(s.call_validate({ 1, 2, 3 }, schema))
        assert(s.call_validate(true, schema))
        assert(s.call_validate(123, schema))
        assert(s.call_validate('str', schema))
    end)

    describe('of the constants', function()
        it('should be passed for both syntax of constants', function()
            -- when:
            s.validate('123', s.const())
            s.validate({ const = '123' }, s.const())
        end)

        it('should validate particular value', function()
            -- given:
            local schema = { const = '123' }

            -- then:
            assert(s.call_validate('123', schema))
            assert(not s.call_validate('12', schema))
            assert(not s.call_validate(123, schema))
        end)
    end)

    describe('of the list', function()
        it('should be passed for list with elements with valid type', function()
            -- given:
            local schema = { list = 'number' }

            -- when:
            s.validate({ 1, 2, 3 }, schema)
        end)

        it('should be failed for list with element with wrong type', function()
            -- given:
            local schema = { list = 'number' }

            -- when:
            assert(not s.call_validate({ 1, 2, '3' }, schema))
        end)
    end)

    describe('of the table', function()
        it('should be passed for a valid table', function()
            -- given:
            local schema = { table = { key = 'string', value = 'string' } }

            -- when:
            local result = s.validate({ a = 'b' }, schema)

            -- then:
            assert.are.True(result)
        end)

        it('should validate type of keys', function()
            -- given:
            local schema = { table = { key = 'string', value = 'number' } }
            local table = { 1, 2 }

            -- when:
            local ok, reason = s.call_validate(table, schema)

            -- then:
            assert(not ok)
            assert(#reason > 0)
        end)

        it('should validate type of values', function()
            -- given:
            local schema = { table = { key = 'string', value = 'number' } }
            local table = { a = 'str' }

            -- when:
            local ok, reason = s.call_validate(table, schema)

            -- then:
            assert(not ok)
            assert(#reason > 0)
        end)

        it('should support oneof as a type of keys', function()
            -- given:
            local schema = { table = { key = { oneof = { 'a', 'b' } }, value = 'string' } }

            -- them:
            assert(s.call_validate({ a = 'a' }, schema))
            assert(s.call_validate({ b = 'b' }, schema))
            assert(not s.call_validate({ c = 'c' }, schema))
        end)

        it('should support oneof as a type of values', function()
            -- given:
            local schema = { table = { key = 'string', value = { oneof = { 'a', 'b' } } } }

            -- them:
            assert(s.call_validate({ a = 'a' }, schema))
            assert(s.call_validate({ a = 'b' }, schema))
            assert(not s.call_validate({ a = 'c' }, schema))
        end)

        it('should support const as a type of keys', function()
            -- given:
            local schema = {
                table = { { key = 'a', value = 'number' }, { key = 'b', value = 'boolean' } },
            }

            -- then:
            assert(s.call_validate({ a = 1, b = true }, schema))
            assert(not s.call_validate({ a = 'str', b = true }, schema))
            assert(not s.call_validate({ a = 1, b = 1 }, schema))
        end)

        it('should be passed for missed keys', function()
            -- given:
            local schema = {
                table = {
                    { key = 'a', value = 'number' },
                    { key = 'b', value = 'boolean' },
                },
            }

            -- then:
            assert(s.call_validate({ a = 1 }, schema))
            assert(s.call_validate({ b = true }, schema))
        end)

        it('should be failed for missed required keys', function()
            -- given:
            local schema = {
                table = {
                    { key = 'a', value = 'number', required = true },
                    { key = 'b', value = 'boolean', required = true },
                },
            }

            -- then:
            assert(not s.call_validate({ a = 1 }, schema))
            assert(not s.call_validate({ b = true }, schema))
        end)

        it('should support mix of const and other types', function()
            -- given:
            local schema = {
                table = {
                    { key = 'a', value = 'number' },
                    { key = 'string', value = 'boolean' },
                },
            }

            -- when:
            s.validate({ a = 1, str = true }, schema)
        end)
    end)
end)
