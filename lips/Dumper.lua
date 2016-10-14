local floor = math.floor
local format = string.format
local insert = table.insert
local remove = table.remove

local path = string.gsub(..., "[^.]+$", "")
local data = require(path.."data")
local util = require(path.."util")
local Token = require(path.."Token")
local Statement = require(path.."Statement")
local Reader = require(path.."Reader")

local bitrange = util.bitrange

local Dumper = Reader:extend()
function Dumper:init(writer, options)
    self.writer = writer
    self.options = options or {}
    self.labels = setmetatable({}, {__index=options.labels})
    self.commands = {}
    self.lastcommand = nil
    self.pos = 0
    self.base = 0
end

function Dumper:export_labels(t)
    for k, v in pairs(self.labels) do
        -- only return valid labels; those that don't begin with a number
        -- (relative labels are invalid)
        if not tostring(k):sub(1, 1):find('%d') then
            t[k] = v
        end
    end
    return t
end

function Dumper:label_delta(from, to)
    from = from % 0x80000000
    to = to % 0x80000000
    local rel = floor(to/4) - 1 - floor(from/4)
    if rel > 0x8000 or rel <= -0x8000 then
        self:error('branch too far', rel)
    end
    return rel % 0x10000
end

function Dumper:desym(t)
    -- note: don't run t:compute() here; let valvar handle that
    if t.tt == 'REL' and not t.fixed then
        return self:label_delta(self:pc(), t.tok)
    elseif type(t.tok) == 'number' then
        return t.tok
    elseif t.tt == 'REG' then
        assert(data.all_registers[t.tok], 'Internal Error: unknown register')
        return data.registers[t.tok] or data.fpu_registers[t.tok] or data.sys_registers[t.tok]
    elseif t.tt == 'LABELSYM' or t.tt == 'LABELREL' then
        local label = self.labels[t.tok]
        if label == nil then
            self:error('undefined label', t.tok)
        end
        if t.tt == 'LABELSYM' then
            return label
        end

        return self:label_delta(self:pc(), label)
    end
    error('Internal Error: failed to desym')
end

function Dumper:validate(n, bits)
    local max = 2^bits
    if n == nil then
        error('Internal Error: number to validate is nil', 2)
    end
    if n > max or n < 0 then
        self:error('value out of range', ("%X"):format(n))
    end
    return n
end

function Dumper:valvar(t, bits)
    local val = t
    local err
    if type(val) ~= 'number' then
        t.tok = self:desym(t)
        t.tt = 'NUM'
        val, err = t:compute()
        if err then
            self:error(err, val)
        end
    end
    return self:validate(val, bits)
end

function Dumper:write(t)
    for _, b in ipairs(t) do
        self.writer(self.pos, b)
        self.pos = self.pos + 1
    end
end

function Dumper:assemble_j(first, out)
    local w = 0
    w = w + self:valvar(first,   6) * 0x04000000
    w = w + self:valvar(out[1], 26) * 0x00000001
    local t = Token(self.fn, self.line, 'WORDS', {w})
    local s = Statement(self.fn, self.line, '!DATA', t)
    return s
end
function Dumper:assemble_i(first, out)
    local w = 0
    w = w + self:valvar(first,   6) * 0x04000000
    w = w + self:valvar(out[1],  5) * 0x00200000
    w = w + self:valvar(out[2],  5) * 0x00010000
    w = w + self:valvar(out[3], 16) * 0x00000001
    local t = Token(self.fn, self.line, 'WORDS', {w})
    local s = Statement(self.fn, self.line, '!DATA', t)
    return s
end
function Dumper:assemble_r(first, out)
    local w = 0
    w = w + self:valvar(first,   6) * 0x04000000
    w = w + self:valvar(out[1],  5) * 0x00200000
    w = w + self:valvar(out[2],  5) * 0x00010000
    w = w + self:valvar(out[3],  5) * 0x00000800
    w = w + self:valvar(out[4],  5) * 0x00000040
    w = w + self:valvar(out[5],  6) * 0x00000001
    local t = Token(self.fn, self.line, 'WORDS', {w})
    local s = Statement(self.fn, self.line, '!DATA', t)
    return s
end

function Dumper:format_in(informat)
    -- see data.lua for a guide on what all these mean
    local args = {}
    --if #informat ~= #s then error('mismatch') end
    self.i = 0
    for i=1, #informat do
        self.i = i
        local c = informat:sub(i, i)
        if     c == 'd' then args.rd = self:register(data.registers)
        elseif c == 's' then args.rs = self:register(data.registers)
        elseif c == 't' then args.rt = self:register(data.registers)
        elseif c == 'D' then args.fd = self:register(data.fpu_registers)
        elseif c == 'S' then args.fs = self:register(data.fpu_registers)
        elseif c == 'T' then args.ft = self:register(data.fpu_registers)
        elseif c == 'X' then args.rd = self:register(data.sys_registers)
        elseif c == 'Y' then args.rs = self:register(data.sys_registers)
        elseif c == 'Z' then args.rt = self:register(data.sys_registers)
        elseif c == 'o' then args.offset = self:const():set('signed')
        elseif c == 'r' then args.offset = self:const('relative'):set('signed')
        elseif c == 'i' then args.immediate = self:const(nil, 'no label')
        elseif c == 'I' then args.index = self:const():set('index')
        elseif c == 'k' then args.immediate = self:const(nil, 'no label'):set('signed'):set('negate')
        elseif c == 'K' then args.immediate = self:const(nil, 'no label'):set('signed')
        elseif c == 'b' then args.base = self:deref():set('tt', 'REG')
        else error('Internal Error: invalid input formatting string')
        end
    end
    return args
end

function Dumper:format_out_raw(outformat, first, args, const, formatconst)
    -- see data.lua for a guide on what all these mean
    local lookup = {
        [1]=self.assemble_j,
        [3]=self.assemble_i,
        [5]=self.assemble_r,
    }
    local out = {}
    for i=1, #outformat do
        local c = outformat:sub(i, i)
        if     c == 'd' then insert(out, args.rd)
        elseif c == 's' then insert(out, args.rs)
        elseif c == 't' then insert(out, args.rt)
        elseif c == 'D' then insert(out, args.fd)
        elseif c == 'S' then insert(out, args.fs)
        elseif c == 'T' then insert(out, args.ft)
        elseif c == 'o' then insert(out, args.offset)
        elseif c == 'i' then insert(out, args.immediate)
        elseif c == 'I' then insert(out, args.index)
        elseif c == 'b' then insert(out, args.base)
        elseif c == '0' then insert(out, 0)
        elseif c == 'C' then insert(out, const)
        elseif c == 'F' then insert(out, formatconst)
        end
    end
    local f = lookup[#outformat]
    assert(f, 'Internal Error: invalid output formatting string')
    return f(self, first, out)
end

function Dumper:format_out(t, args)
    return self:format_out_raw(t[3], t[1], args, t[4], t[5])
end

function Dumper:assemble(s)
    local name = s.type
    local h = data.instructions[name]
    self.s = s
    if h[2] ~= nil then
        local args = self:format_in(h[2])
        if self.i ~= #s then
            self:error('expected EOL; too many arguments')
        end
        return self:format_out(h, args)
    else
        self:error('unimplemented instruction', name)
    end
end

function Dumper:fill(length, content)
    self:validate(content, 8)
    local bytes = {}
    for i=1, length do
        insert(bytes, content)
    end
    local t = Token(self.fn, self.line, 'BYTES', bytes)
    local s = Statement(self.fn, self.line, '!DATA', t)
    return s
end

function Dumper:pc()
    --[[ work around a potential overflow issue. consider the assembly:
    .base 0x80000000 ; possibly by default and not explicitly written
    .org 0x80001000
    mylabel:
    la      a0, mylabel ; BUG: this would load 0x1000 instead of 0x80001000
    --]]
    if self.pos >= 0x80000000 and self.base >= 0x80000000 then
        return self.pos - 0x80000000 + self.base
    end
    return self.pos + self.base
end

function Dumper:load(statements)
    local valstack = {} -- for .push/.pop directives
    local new_statements = {}
    self.pos = 0
    self.base = 0
    for i=1, #statements do
        local s = statements[i]
        self.fn = s.fn
        self.line = s.line
        if s.type:sub(1, 1) == '!' then
            if s.type == '!LABEL' then
                self.labels[s[1].tok] = self:pc()
            elseif s.type == '!DATA' then
                s.length = util.measure_data(s) -- cache for next pass
                self.pos = self.pos + s.length
                insert(new_statements, s)
            elseif s.type == '!ORG' then
                self.pos = s[1].tok
                insert(new_statements, s)
            elseif s.type == '!BASE' then
                self.base = s[1].tok
                insert(new_statements, s)
            elseif s.type == '!PUSH' or s.type == '!POP' then
                local thistype = s.type:sub(2):lower()
                for i, t in ipairs(s) do
                    local name = t.tok
                    if type(name) ~= 'string' then
                        self:error('expected state to '..thistype, name)
                    end

                    name = name:lower()
                    local pushing = s.type == '!PUSH'
                    if name == 'org' then
                        if pushing then
                            insert(valstack, self.pos)
                        else
                            self.pos = remove(valstack)
                        end
                    elseif name == 'base' then
                        if pushing then
                            insert(valstack, self.base)
                        else
                            self.base = remove(valstack)
                        end
                    elseif name == 'pc' then
                        if pushing then
                            insert(valstack, self.pos)
                            insert(valstack, self.base)
                        else
                            self.base = remove(valstack)
                            self.pos = remove(valstack)
                        end
                    else
                        self:error('unknown state to '..thistype, name)
                    end

                    if self.pos == nil or self.base == nil then
                        self:error('ran out of values to pop')
                    end

                    if not pushing then
                        local s = Statement(self.fn, self.line, '!ORG', self.pos)
                        insert(new_statements, s)
                        local s = Statement(self.fn, self.line, '!BASE', self.base)
                        insert(new_statements, s)
                    end
                end
            elseif s.type == '!ALIGN' or s.type == '!SKIP' then
                local length, content
                if s.type == '!ALIGN' then
                    local align = s[1] and s[1].tok or 2
                    content = s[2] and s[2].tok or 0
                    if align < 0 then
                        self:error('negative alignment', align)
                    else
                        align = 2^align
                    end
                    local temp = self:pc() + align - 1
                    length = temp - (temp % align) - self:pc()
                else
                    length = s[1] and s[1].tok or 0
                    content = s[2] and s[2].tok or nil
                end

                self.pos = self.pos + length
                if content == nil then
                    local new = Statement(self.fn, self.line, '!ORG', self.pos)
                    insert(new_statements, new)
                elseif length > 0 then
                    insert(new_statements, self:fill(length, content))
                elseif length < 0 then
                    local new = Statement(self.fn, self.line, '!ORG', self.pos)
                    insert(new_statements, new)
                    insert(new_statements, self:fill(length, content))
                    local new = Statement(self.fn, self.line, '!ORG', self.pos)
                    insert(new_statements, new)
                else
                    -- length is 0, noop
                end
            else
                error('Internal Error: unknown statement, got '..s.type)
            end
        else
            self.pos = self.pos + 4
            insert(new_statements, s)
        end
    end

    statements = new_statements

    new_statements = {}
    self.pos = 0
    self.base = 0
    for i=1, #statements do
        local s = statements[i]
        self.fn = s.fn
        self.line = s.line
        if s.type:sub(1, 1) ~= '!' then
            local new = self:assemble(s)
            self.pos = self.pos + 4
            insert(new_statements, new)
        elseif s.type == '!DATA' then
            for i, t in ipairs(s) do
                if t.tt == 'LABELSYM' then
                    local label = self.labels[t.tok]
                    if label == nil then
                        self:error('undefined label', t.tok)
                    end
                    t.tt = 'WORDS'
                    t.tok = {label}
                elseif t.tt == 'NUM' then
                    t.tt = t.size..'S'
                    t.tok = {t.tok}
                    t.size = nil
                end
            end
            self.pos = self.pos + (s.length or util.measure_data(s))
            insert(new_statements, s)
        elseif s.type == '!ORG' then
            self.pos = s[1].tok
            insert(new_statements, s)
        elseif s.type == '!BASE' then
            self.base = s[1].tok
        elseif s.type == '!LABEL' then
            -- noop
        else
            error('Internal Error: unknown statement, got '..s.type)
        end
    end

    self.statements = new_statements
    return self.statements
end

function Dumper:dump()
    self.pos = 0
    self.base = nil
    for i, s in ipairs(self.statements) do
        if s.type == '!DATA' then
            for j, t in ipairs(s) do
                if t.tt == 'WORDS' then
                    for _, w in ipairs(t.tok) do
                        local b0 = bitrange(w, 0, 7)
                        local b1 = bitrange(w, 8, 15)
                        local b2 = bitrange(w, 16, 23)
                        local b3 = bitrange(w, 24, 31)
                        self:write{b3, b2, b1, b0}
                    end
                elseif t.tt == 'HALFWORDS' then
                    for _, h in ipairs(t.tok) do
                        local b0 = bitrange(h, 0, 7)
                        local b1 = bitrange(h, 8, 15)
                        self:write{b1, b0}
                    end
                elseif t.tt == 'BYTES' then
                    for _, b in ipairs(t.tok) do
                        local b0 = bitrange(b, 0, 7)
                        self:write{b0}
                    end
                else
                    error('Internal Error: unknown !DATA token')
                end
            end
        elseif s.type == '!ORG' then
            self.pos = s[1].tok
        else
            error('Internal Error: cannot dump unassembled statement')
        end
    end
end

return Dumper
