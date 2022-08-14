local u = require('feline-theme.utils')

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
