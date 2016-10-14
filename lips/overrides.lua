local insert = table.insert
local unpack = rawget(_G, 'unpack') or table.unpack

local path = string.gsub(..., "[^.]+$", "")
local data = require(path.."data")

local function name_pop(name, character)
    if name:sub(#name) == character then
        return name:sub(1, #name - 1), character
    else
        return name, ''
    end
end

local function li(self, buffer, dest, im)
    if im.tt == 'LABELSYM' then
        local im = self:token(im):set('portion', 'upperoff')
        insert(buffer, {'LUI', dest, im})
        im = self:token(im):set('portion', 'lower')
        insert(buffer, {'ADDIU', dest, dest, im})
        return
    end

    if im.portion then
        -- FIXME: use appropriate instruction based on portion?
        insert(buffer, {'ADDIU', dest, 'R0', im})
        return
    end

    im.tok = im.tok % 0x100000000
    if im.tok >= 0x10000 and im.tok <= 0xFFFF8000 then
        local temp = self:token(im):set('portion', 'upper')
        insert(buffer, {'LUI', dest, temp})
        if im.tok % 0x10000 ~= 0 then
            local temp = self:token(im):set('portion', 'lower')
            insert(buffer, {'ORI', dest, dest, temp})
        end
    elseif im.tok >= 0x8000 and im.tok < 0x10000 then
        local temp = self:token(im):set('portion', 'lower')
        insert(buffer, {'ORI', dest, 'R0', temp})
    else
        local temp = self:token(im):set('portion', 'lower')
        insert(buffer, {'ADDIU', dest, 'R0', temp})
    end

    return buffer
end

local overrides = {}
-- note: "self" is an instance of Preproc

local function tob_override(self, name)
    -- handle all the addressing modes for lw/sw-like instructions
    local dest = self:pop('CPU')
    local offset, base
    if self:peek('DEREF') then
        offset = 0
        base = self:pop('DEREF')
    elseif self:peek('REG') then
        local o = self:pop('CPU')
        local b = self:pop('DEREF'):set('tt', 'REG')
        self:push_new('ADDU', 'AT', o, b)
        offset = 0
        base = self:token('DEREF', 'AT')
    else -- NUM or LABELSYM
        local o = self:pop('CONST')
        if self:peek('NUM') then
            local temp, err = self:pop('CONST'):compute()
            if err then
                self:error(err, temp)
            end
            o:set('offset', temp)
        end
        offset = self:token(o)
        if not o.portion then
            offset:set('portion', 'lower')
        end
        -- attempt to use the fewest possible instructions for this offset
        if not o.portion and (o.tt == 'LABELSYM' or o.tok >= 0x80000000) then
            local temp = self:token(o):set('portion', 'upperoff')
            self:push_new('LUI', 'AT', temp)
            if self.s[self.i] ~= nil then
                local reg = self:pop('DEREF'):set('tt', 'REG')
                if reg.tok ~= 'R0' then
                    self:push_new('ADDU', 'AT', 'AT', reg)
                end
            end
            base = self:token('DEREF', 'AT')
        else
            base = self:pop('DEREF')
        end
    end
    self:push_new(name, dest, offset, base)
end

for k, v in pairs(data.instructions) do
    if v[2] == 'tob' then
        overrides[k] = tob_override
    end
end

function overrides:LI(name)
    local dest = self:pop('CPU')
    local im = self:pop('CONST')

    -- for us, this is just semantics. for a "real" assembler,
    -- LA could add appropriate RELO LUI/ADDIU directives.
    if im.tt == 'LABELSYM' then
        self:error('use LA for labels')
    end

    local buffer = li(self, {}, dest, im)
    for i, v in ipairs(buffer) do
        self:push_new(unpack(v))
    end
end

function overrides:LA(name)
    local dest = self:pop('CPU')
    local im = self:pop('CONST')

    im = self:token(im):set('portion', 'upperoff')
    self:push_new('LUI', dest, im)
    im = self:token(im):set('portion', 'lower')
    self:push_new('ADDIU', dest, dest, im)
end

function overrides:PUSH(name)
    local w = name == 'PUSH' and 'SW' or 'LW'
    local stack = {}
    for _, t in ipairs(self.s) do
        if t.tt == 'NUM' then
            if t.tok < 0 then
                self:error("can't push a negative number of spaces", t.tok)
            end
            for i=1, t.tok do
                insert(stack, '')
            end
            self:pop()
        else
            insert(stack, self:pop('CPU'))
        end
    end
    if #stack == 0 then
        self:error(name..' requires at least one argument')
    end
    if name == 'PUSH' then
        local im = self:token(#stack*4):set('negate')
        self:push_new('ADDIU', 'SP', 'SP', im)
    end
    for i, r in ipairs(stack) do
        if r ~= '' then
            local offset = (i - 1)*4
            self:push_new(w, r, offset, self:token('DEREF', 'SP'))
        end
    end
    if name == 'JPOP' or name == 'RET' then
        self:push_new('JR', 'RA')
    end
    if name == 'POP' or name == 'JPOP' or name == 'RET' then
        local im = #stack * 4
        self:push_new('ADDIU', 'SP', 'SP', im)
    end
end
overrides.POP = overrides.PUSH
overrides.JPOP = overrides.PUSH
overrides.RET = overrides.PUSH

function overrides:CALL(name)
    local func = nil
    local stack = {}
    for i, t in ipairs(self.s) do
        if i == 1 then
            func = self:pop()
        elseif t.tt == 'REG' then
            insert(stack, self:pop('CPU'))
        else
            insert(stack, self:pop())
        end
    end
    if func == nil then
        self:error(name..' requires at least one argument')
    end

    local buffer = {}
    -- keep track of An registers used so that
    -- we don't use an overwritten value by mistake.
    -- in theory, we could set up something to swap
    -- An registers around with the minimum use of AT,
    -- but that's more complexity than we need for an edge case.
    local used = {false, false, false, false}
    local need = {false, false, false, false}

    local deref_sp = self:token('DEREF', 'SP')
    for i, t in ipairs(stack) do
        if t.tt == 'REG' then
            if     i == 1 and t.tok == 'A0' then -- A0 is already A0, noop.
            elseif i == 2 and t.tok == 'A1' then -- etc.
            elseif i == 3 and t.tok == 'A2' then
            elseif i == 4 and t.tok == 'A3' then
            elseif i <= 4 then
                if t.tok:sub(1, 1) == 'A' then
                    local n = tonumber(t.tok:sub(2, 2))
                    if used[n + 1] then
                        self:error("cannot use overwritten register A"..tostring(n), t.tok)
                    end
                end
                local dest = 'A'..tostring(i - 1)
                insert(buffer, {'MOV', dest, t})
                used[i] = true
            else
                local offset = (i - 1) * 4
                insert(buffer, {'SW', t, offset, deref_sp})
            end
        else
            if i <= 4 then
                local dest = 'A'..tostring(i - 1)
                li(self, buffer, dest, t)
                used[i] = true
            else
                local dest = 'AT'
                li(self, buffer, dest, t)
                local offset = (i - 1) * 4
                insert(buffer, {'SW', dest, offset, deref_sp})
            end
        end
    end

    -- if there was just one argument (the function/label),
    -- then push a NOP to fill the delay slot.
    -- (if the user wants to be efficient, they should be using JAL directly)
    if #buffer == 0 then
        insert(buffer, {'NOP'})
    end

    -- insert jal as the second to last instruction
    -- to place the last instruction in the jal's delay slot.
    insert(buffer, #buffer, {'JAL', func})

    -- finally, write everything out
    for i, v in ipairs(buffer) do
        self:push_new(unpack(v))
    end
end

function overrides:NAND(name)
    local dest = self:pop('CPU')
    local src = self:pop('CPU')
    local target = self:pop('CPU')
    self:push_new('AND', dest, src, target)
    self:push_new('NOR', dest, dest, 'R0') -- NOT
end

function overrides:NANDI(name)
    local dest = self:pop('CPU')
    local src = self:pop('CPU')
    local im = self:pop('CONST')
    self:push_new('ANDI', dest, src, im)
    self:push_new('NOR', dest, dest, 'R0') -- NOT
end

function overrides:NORI(name)
    local dest = self:pop('CPU')
    local src = self:pop('CPU')
    local im = self:pop('CONST')
    self:push_new('ORI', dest, src, im)
    self:push_new('NOR', dest, dest, 'R0') -- NOT
end

-- TODO: ROLV/RORV-like versions of this
--       maybe give the same auto-register treatment to SLL/SRL/SRA too
function overrides:ROL(name)
    local first = name == 'ROL' and 'SLL' or 'SRL'
    local second = name == 'ROL' and 'SRL' or 'SLL'
    local dest = self:pop('CPU')
    local src = self:pop('CPU')
    local im = self:pop('CONST')
    if dest == 'AT' or src == 'AT' then
        self:error('registers cannot be AT in this pseudo-instruction')
    end

    self:push_new(first, dest, src, im)
    local temp, err = im:compute()
    if err then
        self:error(err, temp)
    end
    self:push_new(second, 'AT', src, 32 - temp)
    self:push_new('OR', dest, dest, 'AT')
end
overrides.ROR = overrides.ROL

function overrides:ABS(name)
    local dest = self:pop('CPU')
    local src = self:pop('CPU')
    self:push_new('SRA', 'AT', src, 31)
    self:push_new('XOR', dest, src, 'AT')
    self:push_new('SUBU', dest, dest, 'AT')
end

function overrides:CL(name)
    self:expect{'REG'} -- assert there's at least one argument
    for i=1, #self.s do
        local reg = self:pop('CPU')
        self:push_new('CL', reg)
    end
end

function overrides:JR(name)
    local src = self:peek() and self:pop('CPU') or 'RA'
    self:push_new('JR', src)
end

local branch_basics = {
    BEQ = 'BEQ',
    BGE = 'BEQ',
    BGT = 'BNE',
    BLE = 'BEQ',
    BLT = 'BNE',
    BNE = 'BNE',
}

function overrides:BLT(name)
    local likely, unsigned
    name, likely = name_pop(name, 'L')
    name, unsigned = name_pop(name, 'U')
    local branch = branch_basics[name]
    local a = self:pop('CPU')
    local b = self:pop('CPU')
    local offset = self:pop('CONST')
    self:push_new('SLT'..unsigned, 'AT', a, b)
    self:push_new(branch..likely, 'AT', 'R0', offset)
end

function overrides:BLE(name)
    local likely, unsigned
    name, likely = name_pop(name, 'L')
    name, unsigned = name_pop(name, 'U')
    local branch = branch_basics[name]
    local a = self:pop('CPU')
    local b = self:pop('CPU')
    local offset = self:pop('CONST')
    self:push_new('SLT'..unsigned, 'AT', b, a)
    self:push_new(branch..likely, 'AT', 'R0', offset)
end

function overrides:BLTI(name)
    local likely, unsigned
    name, likely = name_pop(name, 'L')
    name, unsigned = name_pop(name, 'U')
    local branch = branch_basics[name:sub(1, #name - 1)]
    local reg = self:pop('CPU')
    local im = self:pop('CONST')
    local offset = self:pop('CONST')
    self:push_new('SLTI'..unsigned, 'AT', reg, im)
    self:push_new(branch..likely, 'AT', 'R0', offset)
end

function overrides:BLEI(name)
    local likely, unsigned
    name, likely = name_pop(name, 'L')
    name, unsigned = name_pop(name, 'U')
    local branch = branch_basics[name:sub(1, #name - 1)]
    local loadi = unsigned == 'U' and 'ORI' or 'ADDIU'
    local reg = self:pop('CPU')
    local im = self:pop('CONST')
    local offset = self:pop('CONST')
    self:push_new(loadi, 'AT', 'R0', im)
    self:push_new('SLT'..unsigned, 'AT', 'AT', reg)
    self:push_new(branch..likely, 'AT', 'R0', offset)
end

function overrides:BEQI(name)
    local likely, unsigned
    name, likely = name_pop(name, 'L')
    name, unsigned = name_pop(name, 'U')
    local branch = name:sub(1, #name - 1)
    local loadi = unsigned == 'U' and 'ORI' or 'ADDIU'
    local reg = self:pop('CPU')
    local im = self:pop('CONST')
    local offset = self:pop('CONST')
    self:push_new(loadi, 'AT', 'R0', im)
    self:push_new(branch..likely, reg, 'AT', offset)
end

local BLT = overrides.BLT
local BLE = overrides.BLE
local BLTI = overrides.BLTI
local BLEI = overrides.BLEI
local BEQI = overrides.BEQI
for k, v in pairs{
    BGE = BLT,   BGEI = BLTI,
    BGT = BLE,   BGTI = BLEI,

    BGEL = BLT,  BGEIL = BLTI,
    BGTL = BLE,  BGTIL = BLEI,
    BLEL = BLE,  BLEIL = BLEI,
    BLTL = BLT,  BLTIL = BLTI,

    BGEU = BLT,  BGEIU = BLTI,
    BGTU = BLE,  BGTIU = BLEI,
    BLEU = BLE,  BLEIU = BLEI,
    BLTU = BLT,  BLTIU = BLTI,

    BGEUL = BLT, BGEIUL = BLTI,
    BGTUL = BLE, BGTIUL = BLEI,
    BLEUL = BLE, BLEIUL = BLEI,
    BLTUL = BLT, BLTIUL = BLTI,

    BEQI    = BEQI, BEQIU   = BEQI,
    BEQIL   = BEQI, BEQIUL  = BEQI,
    BNEI    = BEQI, BNEIU   = BEQI,
    BNEIL   = BEQI, BNEIUL  = BEQI,
} do
    overrides[k] = v
end

return overrides
