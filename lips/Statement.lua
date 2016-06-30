local path = string.gsub(..., "[^.]+$", "")
local util = require(path.."util")
local Base = require(path.."Base")
local Token = require(path.."Token")

local Statement = Base:extend()
function Statement:init(...)
    local args = {...}
    if #args == 1 then
        local t = args[1]
        if util.parent(t) ~= Statement then
            error('Internal Error: 1-arg Statement:init expected a Statement', 3)
        end
        if type(t) == 'table' then
            for k, v in pairs(t) do
                self[k] = v
            end
        end
    elseif #args >= 3 then
        self.fn = args[1]
        self.line = args[2]
        self.type = args[3]
        for i, v in ipairs(args) do
            if i > 3 then
                self[i - 3] = v
            end
        end
    else
        error('Internal Error: Statement:init takes 1 or 3+ arguments', 3)
    end
    self:validate(1)
    return self
end

function Statement:validate(n)
    n = (n or 0) + 3 -- depth for error message
    if not self.fn then
        error('Internal Error: statements require a filename', n)
    end
    if not self.line then
        error('Internal Error: statements require a line number', n)
    end
    if not self.type then
        error('Internal Error: statement is missing a type', n)
    end
    for i, v in ipairs(self) do
        if util.parent(v) ~= Token then
            self[i] = Token(self.fn, self.line, v)
        end
    end
end

return Statement
