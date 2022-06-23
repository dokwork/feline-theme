local s = require('compline.schema')
local ss = require('compline.schema.statusline')
local st = require('compline.schema.theme')
local sf = require('compline.schema.feline')

describe('feline schema validation', function()
    it('should be passed for highlight', function()
        assert(s.validate('red', sf.highlight))
        assert(s.validate({ fg = 'red', bg = 'green' }, sf.highlight))
        -- example with a function
        assert(s.validate(it, sf.highlight))
    end)
end)

describe('theme schema validation', function()

    it('should be passed for colors', function()
        -- when:
        local ok, err = s.validate(st.colors, s.type)

        -- then:
        assert(ok, tostring(err))
    end)

    it('should be passed for vi_mode', function()
        -- when:
        local ok, err = s.validate(st.vi_mode, s.type)

        -- then:
        assert(ok, tostring(err))
    end)

    it('should be passed for separator', function()
        -- when:
        local ok, err = s.validate(st.separator, s.type)

        -- then:
        assert(ok, tostring(err))
    end)

    it('should be passed for sections', function()
        -- when:
        local ok, err = s.validate(st.sections, s.type)

        -- then:
        assert(ok, tostring(err))
    end)

    it('should be passed for zone', function()
        -- when:
        local ok, err = s.validate(st.zone, s.type)

        -- then:
        assert(ok, tostring(err))
    end)

    it('should be passed for line', function()
        -- when:
        local ok, err = s.validate(st.line, s.type)

        -- then:
        assert(ok, tostring(err))
    end)

    it('should be passed for whole theme', function()
        -- when:
        local ok, err = s.validate(st.theme, s.type)

        -- then:
        assert(ok, tostring(err))
    end)
end)

describe('statusline schema validation', function()
    it('should be passed for the zone', function()
        -- given:
        local zone = {
            a = { 'str' },
        }

        -- when
        local ok, err = s.validate(zone, ss.zone)

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
        local ok, err = s.validate(line, ss.line)

        -- then:
        assert(ok, tostring(err))
    end)

    it('should be passed for whole statusline', function()
        -- when:
        local ok, err = s.validate(ss.statusline, s.type)

        -- then:
        assert(ok, tostring(err))
    end)

end)
