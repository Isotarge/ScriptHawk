local insert = table.insert

local data = require "lips.data"
local util = require "lips.util"

local instructions = data.instructions

local overrides = {}
-- note: "self" is an instance of Parser

function overrides.LI(self, name)
    local lui = instructions['LUI']
    local ori = instructions['ORI']
    local addiu = instructions['ADDIU']
    local args = {}
    args.rt = self:register()
    self:optional_comma()
    local im = self:const()

    -- for us, this is just semantics. for a "real" assembler,
    -- LA could add appropriate RELO LUI/ADDIU directives.
    if im.tt == 'LABELSYM' then
        self:error('use LA for labels')
    end

    if im.portion then
        args.rs = 'R0'
        args.immediate = im
        self:format_out(addiu, args)
        return
    end

    im.tok = im.tok % 0x100000000
    if im.tok >= 0x10000 and im.tok <= 0xFFFF8000 then
        args.rs = args.rt
        args.immediate = self:token(im):set('portion', 'upper')
        self:format_out(lui, args)
        if im.tok % 0x10000 ~= 0 then
            args.immediate = self:token(im):set('portion', 'lower')
            self:format_out(ori, args)
        end
    elseif im.tok >= 0x8000 and im.tok < 0x10000 then
        args.rs = 'R0'
        args.immediate = self:token(im):set('portion', 'lower')
        self:format_out(ori, args)
    else
        args.rs = 'R0'
        args.immediate = self:token(im):set('portion', 'lower')
        self:format_out(addiu, args)
    end
end

function overrides.LA(self, name)
    local lui = instructions['LUI']
    local addiu = instructions['ADDIU']
    local args = {}
    args.rt = self:register()
    self:optional_comma()
    local im = self:const()

    args.rs = args.rt
    args.immediate = self:token(im):set('portion', 'upperoff')
    self:format_out(lui, args)
    args.immediate = self:token(im):set('portion', 'lower')
    self:format_out(addiu, args)
end

function overrides.PUSH(self, name)
    local addi = instructions['ADDI']
    local w = instructions[name == 'PUSH' and 'SW' or 'LW']
    local jr = instructions['JR']
    local stack = {}
    while not self:is_EOL() do
        if self.tt == 'NUM' then
            if self.tok < 0 then
                self:error("can't push a negative number of spaces")
            end
            for i=1,self.tok do
                insert(stack, '')
            end
            self:advance()
        else
            insert(stack, self:register())
        end
        if not self:is_EOL() then
            self:optional_comma()
        end
    end
    if #stack == 0 then
        self:error(name..' requires at least one argument')
    end
    local args = {}
    if name == 'PUSH' then
        args.rt = 'SP'
        args.rs = 'SP'
        args.immediate = self:token(#stack*4):set('negate')
        self:format_out(addi, args)
    end
    args.base = 'SP'
    for i, r in ipairs(stack) do
        args.rt = r
        if r ~= '' then
            args.offset = (i - 1)*4
            self:format_out(w, args)
        end
    end
    if name == 'JPOP' then
        args.rs = 'RA'
        self:format_out(jr, args)
    end
    if name == 'POP' or name == 'JPOP' then
        args.rt = 'SP'
        args.rs = 'SP'
        args.immediate = #stack*4
        self:format_out(addi, args)
    end
end
overrides.POP = overrides.PUSH
overrides.JPOP = overrides.PUSH

function overrides.NAND(self, name)
    local and_ = instructions['AND']
    local nor = instructions['NOR']
    local args = {}
    args.rd = self:register()
    self:optional_comma()
    args.rs = self:register()
    self:optional_comma()
    args.rt = self:register()
    self:format_out(and_, args)
    args.rs = args.rd
    args.rt = 'R0'
    self:format_out(nor, args)
end

function overrides.NANDI(self, name)
    local andi = instructions['ANDI']
    local nor = instructions['NOR']
    local args = {}
    args.rt = self:register()
    self:optional_comma()
    args.rs = self:register()
    self:optional_comma()
    args.immediate = self:const()
    self:format_out(andi[3], andi[1], args, andi[4], andi[5])
    args.rd = args.rt
    args.rs = args.rt
    args.rt = 'R0'
    self:format_out(nor[3], nor[1], args, nor[4], nor[5])
end

function overrides.NORI(self, name)
    local ori = instructions['ORI']
    local nor = instructions['NOR']
    local args = {}
    args.rt = self:register()
    self:optional_comma()
    args.rs = self:register()
    self:optional_comma()
    args.immediate = self:const()
    self:format_out(ori, args)
    args.rd = args.rt
    args.rs = args.rt
    args.rt = 'R0'
    self:format_out(nor, args)
end

function overrides.ROL(self, name)
    local sll = instructions['SLL']
    local srl = instructions['SRL']
    local or_ = instructions['OR']
    local args = {}
    local left = self:register()
    self:optional_comma()
    args.rt = self:register()
    self:optional_comma()
    args.immediate = self:const()
    args.rd = left
    if args.rd == 'AT' or args.rt == 'AT' then
        self:error('registers cannot be AT in this pseudo-instruction')
    end
    if args.rd == args.rt and args.rd ~= 'R0' then
        self:error('registers cannot be the same')
    end
    self:format_out(sll, args)
    args.rd = 'AT'
    args.immediate = 32 - args.immediate[2]
    self:format_out(srl, args)
    args.rd = left
    args.rs = left
    args.rt = 'AT'
    self:format_out(or_, args)
end

function overrides.ROR(self, name)
    local sll = instructions['SLL']
    local srl = instructions['SRL']
    local or_ = instructions['OR']
    local args = {}
    local right = self:register()
    self:optional_comma()
    args.rt = self:register()
    self:optional_comma()
    args.immediate = self:const()
    args.rd = right
    if args.rt == 'AT' or args.rd == 'AT' then
        self:error('registers cannot be AT in a pseudo-instruction that uses AT')
    end
    if args.rd == args.rt and args.rd ~= 'R0' then
        self:error('registers cannot be the same')
    end
    self:format_out(srl, args)
    args.rd = 'AT'
    args.immediate = 32 - args.immediate[2]
    self:format_out(sll, args)
    args.rd = right
    args.rs = right
    args.rt = 'AT'
    self:format_out(or_, args)
end

function overrides.JR(self, name)
    local jr = instructions['JR']
    local args = {}
    if self:is_EOL() then
        args.rs = 'RA'
    else
        args.rs = self:register()
    end
    self:format_out(jr, args)
end

local branch_basics = {
    BEQI = "BEQ",
    BGEI = "BEQ",
    BGTI = "BEQ",
    BLEI = "BNE",
    BLTI = "BNE",
    BNEI = "BNE",
}

function overrides.BEQI(self, name)
    local addiu = instructions['ADDIU']
    local branch = instructions[branch_basics[name]]
    local args = {}
    local reg = self:register()
    self:optional_comma()
    args.immediate = self:const()
    self:optional_comma()
    args.offset = self:token(self:const('relative')):set('signed')

    if reg == 'AT' then
        self:error('register cannot be AT in this pseudo-instruction')
    end

    args.rt = 'AT'
    args.rs = 'R0'
    self:format_out(addiu, args)

    args.rs = reg
    self:format_out(branch, args)
end
overrides.BNEI = overrides.BEQI

function overrides.BLTI(self, name)
    local slti = instructions['SLTI']
    local branch = instructions[branch_basics[name]]
    local args = {}
    args.rs = self:register()
    self:optional_comma()
    args.immediate = self:const()
    self:optional_comma()
    args.offset = self:token(self:const('relative')):set('signed')

    if args.rs == 'AT' then
        self:error('register cannot be AT in this pseudo-instruction')
    end

    args.rt = 'AT'
    self:format_out(slti, args)

    args.rs = 'AT'
    args.rt = 'R0'
    self:format_out(branch, args)
end
overrides.BGEI = overrides.BLTI

function overrides.BLEI(self, name)
    -- TODO: this can probably be optimized
    local addiu = instructions['ADDIU']
    local slt = instructions['SLT']
    local branch = instructions[branch_basics[name]]
    local beq = instructions['BEQ']
    local args = {}
    local reg = self:register()
    self:optional_comma()
    args.immediate = self:const()
    self:optional_comma()
    local offset = self:token(self:const('relative')):set('signed')

    if reg == 'AT' then
        self:error('register cannot be AT in this pseudo-instruction')
    end

    args.rt = 'AT'
    args.rs = 'R0'
    self:format_out(addiu, args)

    if name == 'BLEI' then
        args.offset = offset
    else
        args.offset = 2 -- branch to delay slot of the next branch
    end
    args.rs = reg
    self:format_out(beq, args)

    args.rd = 'AT'
    self:format_out(slt, args)

    args.rs = 'AT'
    args.rt = 'R0'
    args.offset = offset
    self:format_out(branch, args)
end
overrides.BGTI = overrides.BLEI

return overrides
