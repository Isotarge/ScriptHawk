local util = require "lips.util"

local Token = util.Class()
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
    if not self.fn then
        error('Internal Error: tokens require a filename', 3)
    end
    if not self.line then
        error('Internal Error: tokens require a line number', 3)
    end
    if not self.tt then
        error('Internal Error: token is missing a type', 3)
    end
    if not self.tok then
        error('Internal Error: token is missing a value', 3)
    end
    return self
end

function Token:set(key, value)
    if value == nil then
        value = true
    end
    self[key] = value
    return self
end

return Token
