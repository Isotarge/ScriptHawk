local floor = math.floor

local path = string.gsub(..., "[^.]+$", "")
local Base = require(path.."Base")
local util = require(path.."util")

local bitrange = util.bitrange

local Token = Base:extend()
function Token:init(...)
    local args = {...}
    if #args == 1 then
        local t = args[1]
        if type(t) == 'table' then
            for k, v in pairs(t) do
                self[k] = v
            end
        end
    elseif #args == 3 then
        self.fn = args[1]
        self.line = args[2]
        local t = args[3]
        if type(t) == 'table' then
            self.tt = t[1]
            self.tok = t[2]
        elseif type(t) == 'string' then
            self.tt = 'REG'
            self.tok = t
        elseif type(t) == 'number' then
            self.tt = 'NUM'
            self.tok = t
        else
            error('Internal Error: unknown type to construct', 3)
        end
    elseif #args == 4 then
        self.fn = args[1]
        self.line = args[2]
        self.tt = args[3]
        self.tok = args[4]
    else
        error('Internal Error: init takes 1, 3 or 4 arguments', 3)
    end
    self:validate(1)
    return self
end

function Token:validate(n)
    n = (n or 0) + 3 -- depth for error message
    if not self.fn then
        error('Internal Error: tokens require a filename', n)
    end
    if not self.line then
        error('Internal Error: tokens require a line number', n)
    end
    if not self.tt then
        error('Internal Error: token is missing a type', n)
    end
    if not self.tok then
        error('Internal Error: token is missing a value', n)
    end
end

function Token:set(key, value)
    if value == nil then
        value = true
    end
    self[key] = value
    return self
end

function Token:compute(n)
    local n = n or self.tok
    assert(n or self.tt == 'NUM', 'Internal Error: cannot compute a non-number token')

    if self.offset then
        n = n + self.offset
    end

    if self.index then
        n = n % 0x80000000
        n = floor(n/4)
    end
    if self.negate then
        n = -n
    end

    if self.portion == 'upper' then
        n = bitrange(n, 16, 31)
    elseif self.portion == 'lower' then
        n = bitrange(n, 0, 15)
    elseif self.portion == 'upperoff' then
        local upper = bitrange(n, 16, 31)
        local lower = bitrange(n, 0, 15)
        if lower >= 0x8000 then
            -- accommodate for offsets being signed
            upper = (upper + 1) % 0x10000
        end
        n = upper
    end

    if self.signed then
        if n >= 0x10000 or n < -0x8000 then
            return n, 'value out of range'
        end
        n = n % 0x10000
    end

    return n
end

return Token
