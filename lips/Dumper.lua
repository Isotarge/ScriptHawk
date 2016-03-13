local floor = math.floor
local format = string.format
local insert = table.insert

local data = require "lips.data"
local util = require "lips.util"

local bitrange = util.bitrange

local Dumper = util.Class()
function Dumper:init(writer, fn, options)
    self.writer = writer
    self.fn = fn or '(string)'
    self.options = options or {}
    self.labels = {}
    self.commands = {}
    self.pos = options.offset or 0
    self.lastcommand = nil
end

function Dumper:error(msg)
    error(format('%s:%d: Error: %s', self.fn, self.line, msg), 2)
end

function Dumper:advance(by)
    self.pos = self.pos + by
end

function Dumper:push_instruction(t)
    t.kind = 'instruction'
    insert(self.commands, t)
    self:advance(4)
end

function Dumper:add_instruction_j(fn, line, o, T)
    self:push_instruction{fn=fn, line=line, o, T}
end

function Dumper:add_instruction_i(fn, line, o, s, t, i)
    self:push_instruction{fn=fn, line=line, o, s, t, i}
end

function Dumper:add_instruction_r(fn, line, o, s, t, d, f, c)
    self:push_instruction{fn=fn, line=line, o, s, t, d, f, c}
end

function Dumper:add_label(name)
    self.labels[name] = self.pos
end

function Dumper:add_bytes(line, ...)
    local use_last = self.lastcommand and self.lastcommand.kind == 'bytes'
    local t
    if use_last then
        t = self.lastcommand
    else
        t = {}
        t.kind = 'bytes'
        t.size = 0
        t.fn = self.fn
        t.line = self.line
    end
    t.line = line
    for _, b in ipairs{...} do
        t.size = t.size + 1
        t[t.size] = b
    end
    if not use_last then
        insert(self.commands, t)
    end
    self:advance(t.size)
end

function Dumper:add_directive(fn, line, name, a, b)
    self.fn = fn
    self.line = line
    local t = {}
    t.fn = self.fn
    t.line = self.line
    if name == 'BYTE' then
        self:add_bytes(line, a % 0x100)
    elseif name == 'HALFWORD' then
        local b0 = bitrange(a, 0, 7)
        local b1 = bitrange(a, 8, 15)
        self:add_bytes(line, b1, b0)
    elseif name == 'WORD' then
        if type(a) == 'string' then
            local t = {line=line, kind='label', name=a}
            insert(self.commands, t)
            self:advance(4)
        else
            local b0 = bitrange(a, 0, 7)
            local b1 = bitrange(a, 8, 15)
            local b2 = bitrange(a, 16, 23)
            local b3 = bitrange(a, 24, 31)
            self:add_bytes(line, b3, b2, b1, b0)
        end
    elseif name == 'ORG' then
        t.kind = 'goto'
        t.addr = a
        insert(self.commands, t)
        self.pos = a % 0x80000000
        self:advance(0)
    elseif name == 'ALIGN' then
        t.kind = 'ahead'
        local align
        if a == 0 then
            align = 4
        elseif a < 0 then
            self:error('negative alignment')
        else
            align = 2^a
        end
        local temp = self.pos + align - 1
        t.skip = temp - (temp % align) - self.pos
        t.fill = t.fill or 0
        insert(self.commands, t)
        self:advance(t.skip)
    elseif name == 'SKIP' then
        t.kind = 'ahead'
        t.skip = a
        t.fill = b
        insert(self.commands, t)
        self:advance(t.skip)
    else
        self:error('unimplemented directive')
    end
end

function Dumper:desym(t)
    if type(t.tok) == 'number' then
        return t.tok
    elseif t.tt == 'REG' then
        assert(data.all_registers[t.tok], 'Internal Error: unknown register')
        return data.registers[t.tok] or data.fpu_registers[t.tok] or data.sys_registers[t.tok]
    elseif t.tt == 'LABELSYM' then
        local label = self.labels[t.tok]
        if label == nil then
            self:error('undefined label')
        end
        return label
    elseif t.tt == 'LABELREL' then
        local label = self.labels[t.tok]
        if label == nil then
            self:error('undefined label')
        end
        label = label % 0x80000000
        local pos = self.pos % 0x80000000
        local rel = floor(label/4) - 1 - floor(pos/4)
        if rel > 0x8000 or rel <= -0x8000 then
            self:error('branch too far')
        end
        return rel % 0x10000
    end
    error('Internal Error: failed to desym')
end

function Dumper:toval(t)
    assert(type(t) == 'table', 'Internal Error: invalid value')

    local val = self:desym(t)

    if t.index then
        val = val % 0x80000000
        val = floor(val/4)
    end
    if t.negate then
        val = -val
    end
    if t.negate or t.signed then
        if val >= 0x10000 or val < -0x8000 then
            self:error('value out of range')
        end
        val = val % 0x10000
    end

    if t.portion == 'upper' then
        val = bitrange(val, 16, 31)
    elseif t.portion == 'lower' then
        val = bitrange(val, 0, 15)
    elseif t.portion == 'upperoff' then
        local upper = bitrange(val, 16, 31)
        local lower = bitrange(val, 0, 15)
        if lower >= 0x8000 then
            -- accommodate for offsets being signed
            upper = (upper + 1) % 0x10000
        end
        val = upper
    end

    return val
end

function Dumper:validate(n, bits)
    local max = 2^bits
    if n == nil then
        self:error('value is nil') -- internal error?
    end
    if n > max or n < 0 then
        self:error('value out of range')
    end
end

function Dumper:valvar(t, bits)
    local val = self:toval(t)
    self:validate(val, bits)
    return val
end

function Dumper:write(t)
    for _, b in ipairs(t) do
        local s = ('%02X'):format(b)
        self.writer(self.pos, s)
        self.pos = self.pos + 1
    end
end

function Dumper:dump_instruction(t)
    local uw = 0
    local lw = 0

    local o = t[1]
    uw = uw + o*0x400

    if #t == 2 then
        local val = self:valvar(t[2], 26)
        uw = uw + bitrange(val, 16, 25)
        lw = lw + bitrange(val, 0, 15)
    elseif #t == 4 then
        uw = uw + self:valvar(t[2], 5)*0x20
        uw = uw + self:valvar(t[3], 5)
        lw = lw + self:valvar(t[4], 16)
    elseif #t == 6 then
        uw = uw + self:valvar(t[2], 5)*0x20
        uw = uw + self:valvar(t[3], 5)
        lw = lw + self:valvar(t[4], 5)*0x800
        lw = lw + self:valvar(t[5], 5)*0x40
        lw = lw + self:valvar(t[6], 6)
    else
        error('Internal Error: unknown n-size')
    end

    return uw, lw
end

function Dumper:dump()
    self.pos = self.options.offset or 0
    for i, t in ipairs(self.commands) do
        assert(t.fn, 'Internal Error: no file name available')
        assert(t.line, 'Internal Error: no line number available')
        self.fn = t.fn
        self.line = t.line
        if t.kind == 'instruction' then
            local uw, lw = self:dump_instruction(t)
            local b0 = bitrange(lw, 0, 7)
            local b1 = bitrange(lw, 8, 15)
            local b2 = bitrange(uw, 0, 7)
            local b3 = bitrange(uw, 8, 15)
            self:write{b3, b2, b1, b0}
        elseif t.kind == 'bytes' then
            self:write(t)
        elseif t.kind == 'goto' then
            self.pos = t.addr
        elseif t.kind == 'ahead' then
            if t.fill then
                for i=1, t.skip do
                    self:write{t.fill}
                end
            else
                self.pos = self.pos + t.skip
            end
        elseif t.kind == 'label' then
            local val = self:desym{'LABELSYM', t.name}
            val = (val % 0x80000000) + 0x80000000
            local b0 = bitrange(val, 0, 7)
            local b1 = bitrange(val, 8, 15)
            local b2 = bitrange(val, 16, 23)
            local b3 = bitrange(val, 24, 31)
            self:write{b3, b2, b1, b0}
        else
            error('Internal Error: unknown command')
        end
    end
end

return Dumper
