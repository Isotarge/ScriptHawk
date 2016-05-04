local insert = table.insert

local path = string.gsub(..., "[^.]+$", "")
local data = require(path.."data")
local Muncher = require(path.."Muncher")
local Token = require(path.."Token")

local abs = math.abs

local function signs(s)
    local start, end_ = s:find('[+-]+')
    if start ~= 1 then
        return 0
    end
    if s:sub(1, 1) == '+' then
        return end_
    elseif s:sub(1, 1) == '-' then
        return -end_
    end
end

local function RelativeLabel(index, name)
    return {
        index = index,
        name = name,
    }
end

local Preproc = Muncher:extend()
function Preproc:init(options)
    self.options = options or {}
end

function Preproc:process(tokens)
    self.tokens = tokens

    local variables = {}
    local plus_labels = {} -- constructed forwards
    local minus_labels = {} -- constructed backwards

    -- first pass: resolve unary ops, variables, and collect relative labels
    local new_tokens = {}
    self.i = 0
    while self.i < #self.tokens do
        local t = self:advance()
        local sign = 1
        if t.tt == 'UNARY' then
            sign = t.tok
            local peek = self.tokens[self.i + 1]
            if peek.tt == 'UNARY' then
                self:error('unary operators cannot be chained')
            elseif peek.tt == 'EOL' or peek.tt == 'SEP' then
                t.tt = 'RELLABELSYM'
                t.tok = sign == 1 and '+' or sign == -1 and '-'
            elseif peek.tt == 'DEFSYM' then
                t = self:advance()
            else
                self:error('expected a symbolic constant after unary operator')
            end
        end
        if t.tt == nil then
            error('Internal Error: missing token')
        elseif t.tt == 'DEF' then
            local t2 = self:advance()
            if t2.tt ~= 'NUM' then
                self:error('expected number for variable')
            end
            variables[t.tok] = t2.tok
        elseif t.tt == 'DEFSYM' then
            local tt = 'NUM'
            local tok = variables[t.tok]
            if tok == nil then
                self:error('undefined variable')
            end
            insert(new_tokens, self:token(tt, tok * sign))
        elseif t.tt == 'RELLABEL' then
            local label = t.tok or ''
            local rl = RelativeLabel(#new_tokens + 1, label:sub(2))
            if label:sub(1, 1) == '+' then
                insert(plus_labels, rl)
            elseif label:sub(1, 1) == '-' then
                insert(minus_labels, 1, rl)
            else
                error('Internal Error: unexpected token for relative label')
            end
            insert(new_tokens, t)
        else
            insert(new_tokens, t)
        end
    end

    -- second pass: resolve relative labels
    for i, t in ipairs(new_tokens) do
        self.fn = t.fn
        self.line = t.line
        if t.tt == 'RELLABEL' then
            t.tt = 'LABEL'
            -- exploits the fact that user labels can't begin with a number
            local name = t.tok:sub(2)
            t.tok = tostring(i)..name
        elseif t.tt == 'RELLABELSYM' then
            t.tt = 'LABELSYM'

            local rel = signs(t.tok)
            if rel == 0 then
                error('Internal Error: relative label without signs')
            end
            local name = t.tok:sub(abs(rel) + 1)
            local seen = 0

            -- TODO: don't iterate over *every* label, just the ones nearby
            if rel > 0 then
                for _, rl in ipairs(plus_labels) do
                    if rl.name == name and rl.index > i then
                        seen = seen + 1
                        if seen == rel then
                            t.tok = tostring(rl.index)..name
                            break
                        end
                    end
                end
            else
                for _, rl in ipairs(minus_labels) do
                    if rl.name == name and rl.index < i then
                        seen = seen - 1
                        if seen == rel then
                            t.tok = tostring(rl.index)..name
                            break
                        end
                    end
                end
            end

            if seen ~= rel then
                self:error('could not find appropriate relative label')
            end
        end
    end

    self.tokens = new_tokens
    new_tokens = {}

    -- third pass: resolve specials
    self.i = 0
    while self.i < #self.tokens do
        local t = self:advance()
        if t.tt == 'SPECIAL' then
            local name, args = self:special()
            -- TODO: split to its own file, not unlike overrides.lua
            if name == 'hi' then
                if #args ~= 1 then
                    self:error('%hi expected exactly one argument')
                end
                local tnew = self:token(args[1]):set('portion', 'upperoff')
                insert(new_tokens, tnew)
            elseif name == 'up' then
                if #args ~= 1 then
                    self:error('%up expected exactly one argument')
                end
                local tnew = self:token(args[1]):set('portion', 'upper')
                insert(new_tokens, tnew)
            elseif name == 'lo' then
                if #args ~= 1 then
                    self:error('%lo expected exactly one argument')
                end
                local tnew = self:token(args[1]):set('portion', 'lower')
                insert(new_tokens, tnew)
            else
                self:error('unknown special')
            end
        else
            insert(new_tokens, t)
        end
    end

    self.tokens = new_tokens

    return self.tokens
end

return Preproc
