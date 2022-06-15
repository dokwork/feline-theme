local s = require('compline.schema')

describe('validation the schema', function()
    it('should be passed for every type', function()
        assert(s.validate(s.const, s.type()), 'Wrong schema for the const')
        assert(s.validate(s.list(), s.type()), 'Wrong schema for the list')
        assert(s.validate(s.oneof(), s.type()), 'Wrong schema for the oneof')
        assert(s.validate(s.table(), s.type()), 'Wrong schema for the table')
        assert(s.validate(s.type(), s.type()), 'Wrong schema for the type')
    end)

    it('should be passed for "any" type', function()
        -- given:
        local schema = 'any'

        -- then:
        assert(s.validate(nil, schema))
        assert(s.validate({ a = 'a' }, schema))
        assert(s.validate({ 1, 2, 3 }, schema))
        assert(s.validate(true, schema))
        assert(s.validate(123, schema))
        assert(s.validate('str', schema))
    end)

    describe('of the constants', function()
        it('should be passed for both syntax of constants', function()
            -- when:
            assert(s.validate('123', s.const))
            assert(s.validate({ const = '123' }, s.const))
        end)

        it('should validate particular value', function()
            -- given:
            local schema = { const = '123' }

            -- then:
            assert(s.validate('123', schema))
            assert(not s.validate('12', schema))
            assert(not s.validate(123, schema))
        end)
    end)

    describe('of the list', function()
        it('should be passed for list with elements with valid type', function()
            -- given:
            local schema = { list = 'number' }

            -- when:
            local ok, err = s.validate({ 1, 2, 3 }, schema)

            -- then:
            assert(ok, tostring(err))
        end)

        it('should be failed for list with element with wrong type', function()
            -- given:
            local schema = { list = 'number' }

            -- when:
            local ok, err = s.validate({ 1, 2, '3' }, schema)

            -- then:
            assert(not ok)
            assert.are.same({ 1, 2, '3' }, err.object)
            assert.are.same(schema, err.schema)
        end)
    end)

    describe('of the table', function()
        it('should be passed for a valid table', function()
            -- given:
            local schema = { table = { key = 'string', value = 'string' } }

            -- when:
            local ok, err = s.validate({ a = 'b' }, schema)

            -- then:
            assert(ok, tostring(err))
        end)

        it('should validate type of keys', function()
            -- given:
            local schema = { table = { key = 'string', value = 'number' } }

            -- then:
            assert(not s.validate({ 1, 2 }, schema))
        end)

        it('should validate type of values', function()
            -- given:
            local schema = { table = { key = 'string', value = 'number' } }

            -- when:
            local ok, err = s.validate({ a = 'str' }, schema)

            -- then:
            assert(not ok)
            assert.are.same({ a = 'str' }, err.object)
            assert.are.same({ table = { { key = 'string', value = 'number' } } }, err.schema)
        end)

        it('should support oneof as a type of keys', function()
            -- given:
            local schema = { table = { key = { oneof = { 'a', 'b' } }, value = 'string' } }

            -- then:
            assert(s.validate({ a = 'a' }, schema))
            assert(s.validate({ b = 'b' }, schema))
            assert(not s.validate({ c = 'c' }, schema))
        end)

        it('should check other key options if oneof failed', function()
            -- given:
            local schema = {
                table = {
                    { key = { oneof = { 'a', 'b' } }, value = 'string' },
                    { key = 'string', value = 'boolean' },
                },
            }

            -- when:
            local ok, err = s.validate({ c = true }, schema)

            -- then:
            assert(ok, tostring(err))
        end)

        it('should not be passed when required oneof was not satisfied', function()
            -- given:
            local schema = {
                table = {
                    { key = { oneof = { 'a', 'b' } }, value = 'string', required = true },
                    { key = 'string', value = 'boolean' },
                },
            }

            -- when:
            local ok, err = s.validate({ c = true }, schema)

            -- then:
            assert(not ok)

            assert.are.same({ c = '?' }, err.object)
            assert.are.same({
                table = { { key = { oneof = { 'a', 'b' } } } },
            }, err.schema)
        end)

        it('should support oneof as a type of values', function()
            -- given:
            local schema = { table = { key = 'string', value = { oneof = { 'a', 'b' } } } }

            -- then:
            assert(s.validate({ a = 'a' }, schema))
            assert(s.validate({ a = 'b' }, schema))
            assert(not s.validate({ a = 'c' }, schema))
        end)

        it('should support const as a type of keys', function()
            -- given:
            local schema = {
                table = {
                    { key = 'a', value = 'number' },
                    { key = 'b', value = 'boolean' },
                },
            }

            -- when:
            local ok, err = s.validate({ a = 1, b = true }, schema)

            -- then:
            assert(ok, tostring(err))
            assert(not s.validate({ a = 'str', b = true }, schema))
            assert(not s.validate({ a = 1, b = 1 }, schema))
        end)

        it('should be passed for missed optional keys', function()
            -- given:
            local schema = {
                table = {
                    { key = 'a', value = 'number' },
                    { key = 'b', value = 'boolean', required = true },
                },
            }

            -- then:
            assert(s.validate({ b = true }, schema))
        end)

        it('should be failed for missed required keys', function()
            -- given:
            local schema = {
                table = {
                    { key = 'a', value = 'number' },
                    { key = 'b', value = 'boolean', required = true },
                },
            }

            -- then:
            assert(not s.validate({ a = 1 }, schema))
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
            local ok, err = s.validate({ a = 1, str = true }, schema)

            -- then:
            assert(ok, tostring(err))
        end)

        it('should support table as a value', function()
            -- given:
            local schema = {
                table = {
                    {
                        key = 'a',
                        value = {
                            table = { key = 'b', value = 'number' },
                        },
                    },
                },
            }

            -- when:
            local ok, err = s.validate({ a = { b = 1 } }, schema)

            -- then:
            assert(ok, tostring(err))
        end)

        it('should correctly compose error for nested tables', function()
            -- given:
            local schema = {
                table = {
                    {
                        key = 'a',
                        value = {
                            table = { key = 'b', value = 'number' },
                        },
                    },
                },
            }

            -- when:
            local ok, err = s.validate({ a = { c = 1 } }, schema)

            -- then:
            assert(not ok)
            assert.are.same({ a = { c = '?' } }, err.object)
            assert.are.same(
                { table = { { key = 'a', value = { table = { { key = 'b' } } } } } },
                err.schema
            )
        end)
    end)
end)

describe('statusline schema validation', function()
    it('should be passed', function()
        -- when:
        local ok, err = s.validate(s.statusline, s.type)

        -- then:
        assert(ok, tostring(err))
    end)
end)
