local insert = table.insert

local path = string.gsub(..., "[^.]+$", "")
local data = require(path.."data")
local overrides = require(path.."overrides")
local Statement = require(path.."Statement")
local Reader = require(path.."Reader")

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

local Preproc = Reader:extend()
function Preproc:init(options)
    self.options = options or {}
end

function Preproc:lookup(t)
    if t.tt == 'VARSYM' then
        local name = t.tok
        t.tt = 'NUM'
        t.tok = self.variables[name]
        if t.tok == nil then
            self:error('undefined variable', name)
        end
    elseif self.do_labels and t.tt == 'RELLABELSYM' or t.tt == 'RELLABEL' then
        if t.tt == 'RELLABEL' then
            t.tt = 'LABEL'
            -- exploits the fact that user labels can't begin with a number
            local name = t.tok:sub(2)
            t.tok = tostring(self.i)..name
        elseif t.tt == 'RELLABELSYM' then
            local i = self.i
            t.tt = 'LABELSYM'

            local rel = signs(t.tok)
            assert(rel ~= 0, 'Internal Error: relative label without signs')

            local name = t.tok:sub(abs(rel) + 1)
            local seen = 0

            -- TODO: don't iterate over *every* label, just the ones nearby.
            -- we could do this by popping labels as we pass over them.
            -- (would need to iterate once forwards and once backwards
            --  for plus and minus labels respectively)
            if rel > 0 then
                for _, rl in ipairs(self.plus_labels) do
                    if rl.name == name and rl.index > i then
                        seen = seen + 1
                        if seen == rel then
                            t.tok = tostring(rl.index)..name
                            break
                        end
                    end
                end
            else
                for _, rl in ipairs(self.minus_labels) do
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
                self:error('could not find appropriate relative label', t.tok)
            end
        end
    else
        return false
    end
    return true
end

function Preproc:check(s, i, tt)
    s = s or self.s
    i = i or self.i
    local t = s[i]
    if t == nil then
        local err = ("expected another argument for %s at position %i"):format(self.s.type, self.i)
        self:error(err)
    end

    self.fn = t.fn
    self.line = t.line

    if t.tt ~= tt then
        self:lookup(t)
    end

    if t.tt ~= tt then
        local err = ("argument %i of %s expected type %s"):format(i, s.type, tt)
        self:error(err, t.tt)
    end
    return t.tok
end

function Preproc:process(statements)
    self.statements = statements

    self.variables = {}
    self.plus_labels = {} -- constructed forwards
    self.minus_labels = {} -- constructed backwards
    self.do_labels = false

    -- first pass: resolve variables and collect relative labels
    local new_statements = {}
    for i=1, #self.statements do
        local s = self.statements[i]
        self.fn = s.fn
        self.line = s.line
        if s.type:sub(1, 1) == '!' then
            -- directive, label, etc.
            if s.type == '!VAR' then
                local a = self:check(s, 1, 'VAR')
                local b = self:check(s, 2, 'NUM')
                self.variables[a] = b
            elseif s.type == '!LABEL' then
                if s[1].tt == 'RELLABEL' then
                    local label = s[1].tok
                    local rl = {
                        index = #new_statements + 1,
                        name = label:sub(2)
                    }
                    local c = label:sub(1, 1)
                    if c == '+' then
                        insert(self.plus_labels, rl)
                    elseif c == '-' then
                        insert(self.minus_labels, 1, rl) -- remember, it's backwards
                    else
                        error('Internal Error: unexpected token for relative label')
                    end
                end
                insert(new_statements, s)
            else
                for j, t in ipairs(s) do
                    self:lookup(t)
                end
                insert(new_statements, s)
            end
        else
            -- regular instruction
            for j, t in ipairs(s) do
                self:lookup(t)
            end
            insert(new_statements, s)
        end
    end

    -- second pass: resolve relative labels
    self.do_labels = true
    for i=1, #new_statements do
        self.i = i -- make visible to :lookup
        local s = new_statements[i]
        self.fn = s.fn
        self.line = s.line
        for j, t in ipairs(s) do
            self:lookup(t)
        end
    end

    return new_statements
end

function Preproc:statement(...)
    self.fn = self.s.fn
    self.line = self.s.line
    local s = Statement(self.fn, self.line, ...)
    return s
end

function Preproc:push(s)
    s:validate()
    insert(self.statements, s)
end

function Preproc:push_new(...)
    self:push(self:statement(...))
end

function Preproc:pop(kind)
    local ret
    if kind == nil then
        ret = self.s[self.i]
    elseif kind == 'CPU' then
        ret = self:register(data.registers)
    elseif kind == 'DEREF' then
        ret = self:deref()
    elseif kind == 'CONST' then
        ret = self:const()
    elseif kind == 'END' then
        if self.s[self.i] ~= nil then
            self:error('expected EOL; too many arguments')
        end
        return -- don't increment self.i past end of arguments
    else
        error('Internal Error: unknown kind, got '..tostring(kind))
    end
    self.i = self.i + 1
    return ret
end

function Preproc:expand(statements)
    -- third pass: expand pseudo-instructions and register arguments
    self.statements = {}
    for i=1, #statements do
        local s = statements[i]
        self.s = s
        self.fn = s.fn
        self.line = s.line
        if s.type:sub(1, 1) == '!' then
            self:push(s)
        else
            local name = s.type
            local h = data.instructions[name]
            if h == nil then
                error('Internal Error: unknown instruction')
            end

            if data.one_register_variants[name] then
                self.i = 1
                local a = self:register(data.all_registers)
                local b = s[2]
                if b == nil or b.tt ~= 'REG' then
                    insert(s, 2, self:token(a))
                end
            elseif data.two_register_variants[name] then
                self.i = 1
                local a = self:register(data.all_registers)
                local b = self:register(data.all_registers)
                local c = s[3]
                if c == nil or c.tt ~= 'REG' then
                    insert(s, 2, self:token(a))
                end
            end

            if overrides[name] then
                self.i = 1
                overrides[name](self, name)
                self:pop('END')
            else
                self:push(s)
            end
        end
    end

    return self.statements
end

return Preproc
