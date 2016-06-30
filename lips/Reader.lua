local path = string.gsub(..., "[^.]+$", "")
local Base = require(path.."Base")
local Token = require(path.."Token")

local Reader = Base:extend()
-- no base init method

-- Reader expects self.s to be set to a statement, and self.i to a token index

function Reader:error(msg, got)
    if got ~= nil then
        msg = msg..', got '..tostring(got)
    end
    error(('%s:%d: Error: %s'):format(self.fn, self.line, msg), 2)
end

function Reader:token(t, ...)
    local new
    if type(t) == 'table' then
        new = Token(t, ...)
    else
        new = Token(self.fn, self.line, t, ...)
    end
    return new
end

function Reader:expect(tts)
    local t = self.s[self.i]
    if t == nil then
        local err = ("expected another argument for %s at position %i"):format(self.s.type, self.i)
        self:error(err)
    end

    self.fn = t.fn
    self.line = t.line

    for _, tt in pairs(tts) do
        if t.tt == tt then
            return t.ok
        end
    end

    local err
    if #tts == 1 then
        err = ("argument %i of %s expected type %s"):format(self.i, self.s.type, tts[1])
    else
        err = ("unexpected type for argument %i of %s"):format(self.i, self.s.type)
    end
    self:error(err, t.tt)
end

function Reader:register(registers)
    self:expect{'REG'}
    local t = self.s[self.i]
    local numeric = registers[t.tok]
    if not numeric then
        self:error('wrong type of register', t.tok)
    end
    local new = Token(t)
    return new
end

function Reader:const(relative, no_label)
    self:expect{'NUM', 'LABELSYM', 'LABELREL'}
    local t = self.s[self.i]
    -- overrides will want to LUI a label; let portioned labels pass
    if no_label and not t.portion then
        self:expect{'NUM', 'LABELREL'}
    end
    local new = Token(t)
    if relative then -- you probably shouldn't use this in Preproc
        if t.tt == 'LABELSYM' then
            new.tt = 'LABELREL'
        elseif t.tt == 'NUM' then
            new.tt = 'REL'
        end
    end
    return new
end

function Reader:deref()
    self:expect{'DEREF'}
    local t = self.s[self.i]
    local new = Token(t)
    --new.tt = 'REG'
    return new
end

function Reader:peek(tt)
    local t = self.s[self.i]
    local seen = t and t.tt or nil
    if tt ~= nil then
        return seen == tt
    end
    return t
end

return Reader
