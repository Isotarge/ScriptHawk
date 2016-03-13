local insert = table.insert

local data = require "lips.data"
local util = require "lips.util"
local overrides = require "lips.overrides"
local Token = require "lips.Token"
local Lexer = require "lips.Lexer"
local Dumper = require "lips.Dumper"
local Muncher = require "lips.Muncher"
local Preproc = require "lips.Preproc"

local Parser = util.Class(Muncher)
function Parser:init(writer, fn, options)
    self.fn = fn or '(string)'
    self.main_fn = self.fn
    self.options = options or {}
    self.dumper = Dumper(writer, fn, options)
end

function Parser:directive()
    local name = self.tok
    self:advance()
    local function add(...)
        self.dumper:add_directive(self.fn, self.line, ...)
    end
    if name == 'ORG' then
        add(name, self:number().tok)
    elseif name == 'ALIGN' or name == 'SKIP' then
        if self:is_EOL() and name == 'ALIGN' then
            add(name, 0)
        else
            local size = self:number()
            if self:is_EOL() then
                add(name, size)
            else
                self:optional_comma()
                add(name, size, self:number().tok)
            end
            self:expect_EOL()
        end
    elseif name == 'BYTE' or name == 'HALFWORD' then
        add(name, self:number().tok)
        while not self:is_EOL() do
            self:advance()
            self:optional_comma()
            add(name, self:number().tok)
        end
        self:expect_EOL()
    elseif name == 'WORD' then -- allow labels in word directives
        add(name, self:const().tok)
        while not self:is_EOL() do
            self:advance()
            self:optional_comma()
            add(name, self:const().tok)
        end
        self:expect_EOL()
    elseif name == 'INC' then
        -- noop, handled by lexer
    elseif name == 'ASCII' or name == 'ASCIIZ' then
        local bytes = self:string()
        for i, number in ipairs(bytes.tok) do
            add('BYTE', number)
        end
        if name == 'ASCIIZ' then
            add('BYTE', 0)
        end
        self:expect_EOL()
    elseif name == 'INCBIN' then
        self:error('unimplemented')
    elseif name == 'FLOAT' then
        self:error('unimplemented')
    else
        self:error('unknown directive')
    end
end

function Parser:format_in(informat)
    local args = {}
    for i=1,#informat do
        local c = informat:sub(i, i)
        local c2 = informat:sub(i + 1, i + 1)
        if c == 'd' and not args.rd then
            args.rd = self:register()
        elseif c == 's' and not args.rs then
            args.rs = self:register()
        elseif c == 't' and not args.rt then
            args.rt = self:register()
        elseif c == 'D' and not args.fd then
            args.fd = self:register(data.fpu_registers)
        elseif c == 'S' and not args.fs then
            args.fs = self:register(data.fpu_registers)
        elseif c == 'T' and not args.ft then
            args.ft = self:register(data.fpu_registers)
        elseif c == 'X' and not args.rd then
            args.rd = self:register(data.sys_registers)
        elseif c == 'Y' and not args.rs then
            args.rs = self:register(data.sys_registers)
        elseif c == 'Z' and not args.rt then
            args.rt = self:register(data.sys_registers)
        elseif c == 'o' and not args.offset then
            args.offset = Token(self:const()):set('signed')
        elseif c == 'r' and not args.offset then
            args.offset = Token(self:const('relative')):set('signed')
        elseif c == 'i' and not args.immediate then
            args.immediate = self:const(nil, 'no label')
        elseif c == 'I' and not args.index then
            args.index = Token(self:const()):set('index')
        elseif c == 'k' and not args.immediate then
            args.immediate = Token(self:const(nil, 'no label')):set('negate')
        elseif c == 'K' and not args.immediate then
            args.immediate = Token(self:const(nil, 'no label')):set('signed')
        elseif c == 'b' and not args.base then
            args.base = self:deref()
        else
            error('Internal Error: invalid input formatting string')
        end
        if c2:find('[dstDSTorIikKXYZ]') then
            self:optional_comma()
        end
    end
    return args
end

function Parser:format_out_raw(outformat, first, args, const, formatconst)
    local lookup = {
        [1]=self.dumper.add_instruction_j,
        [3]=self.dumper.add_instruction_i,
        [5]=self.dumper.add_instruction_r,
    }
    local out = {}
    for i=1,#outformat do
        local c = outformat:sub(i, i)
        if c == 'd' then
            out[#out+1] = self:token(args.rd)
        elseif c == 's' then
            out[#out+1] = self:token(args.rs)
        elseif c == 't' then
            out[#out+1] = self:token(args.rt)
        elseif c == 'D' then
            out[#out+1] = self:token(args.fd)
        elseif c == 'S' then
            out[#out+1] = self:token(args.fs)
        elseif c == 'T' then
            out[#out+1] = self:token(args.ft)
        elseif c == 'o' then
            out[#out+1] = self:token(args.offset)
        elseif c == 'i' then
            out[#out+1] = self:token(args.immediate)
        elseif c == 'I' then
            out[#out+1] = self:token(args.index)
        elseif c == 'b' then
            out[#out+1] = self:token(args.base)
        elseif c == '0' then
            out[#out+1] = self:token(0)
        elseif c == 'C' then
            out[#out+1] = self:token(const)
        elseif c == 'F' then
            out[#out+1] = self:token(formatconst)
        end
    end
    local f = lookup[#outformat]
    if f == nil then
        error('Internal Error: invalid output formatting string')
    end
    f(self.dumper, self.fn, self.line, first, out[1], out[2], out[3], out[4], out[5])
end

function Parser:format_out(t, args)
    self:format_out_raw(t[3], t[1], args, t[4], t[5])
end

function Parser:instruction()
    local name = self.tok
    local h = data.instructions[name]
    self:advance()

    if h == nil then
        error('Internal Error: undefined instruction')
    elseif overrides[name] then
        overrides[name](self, name)
    elseif h[2] == 'tob' then -- TODO: or h[2] == 'Tob' then
        local lui = data.instructions['LUI']
        local addu = data.instructions['ADDU']
        local args = {}
        args.rt = self:register()
        self:optional_comma()
        if self.tt == 'OPEN' then
            args.offset = 0
            args.base = self:deref()
        else -- NUM or LABELSYM
            local lui_args = {}
            local addu_args = {}
            local o = self:const()
            args.offset = self:token(o)
            if not o.portion then
                args.offset:set('portion', 'lower')
            end
            if not o.portion and (o.tt == 'LABELSYM' or o.tok >= 0x80000000) then
                lui_args.immediate = Token(o):set('portion', 'upperoff')
                lui_args.rt = 'AT'
                self:format_out(lui, lui_args)
                if not self:is_EOL() then
                    addu_args.rd = 'AT'
                    addu_args.rs = 'AT'
                    addu_args.rt = self:deref()
                    self:format_out(addu, addu_args)
                end
                args.base = 'AT'
            else
                args.base = self:deref()
            end
        end
        self:format_out(h, args)
    elseif h[2] ~= nil then
        local args = self:format_in(h[2])
        self:format_out(h, args)
    else
        self:error('unimplemented instruction')
    end
    self:expect_EOL()
end

function Parser:tokenize(asm)
    self.i = 0

    local routine = coroutine.create(function()
        local lexer = Lexer(asm, self.main_fn, self.options)
        lexer:lex(coroutine.yield)
    end)

    local tokens = {}
    while true do
        local ok, a, b, c, d = coroutine.resume(routine)
        if not ok then
            a = a or 'Internal Error: lexer coroutine has stopped'
            error(a)
        end
        assert(a, 'Internal Error: missing token')

        local t = Token(c, d, a, b)
        insert(tokens, t)

        if t.tt == 'EOF' and t.fn == self.main_fn then
            break
        end
    end

    local preproc = Preproc(self.options)
    self.tokens = preproc:process(tokens)

    assert(#self.tokens > 0, 'Internal Error: no tokens after preprocessing')
end

function Parser:parse(asm)
    self:tokenize(asm)
    self:advance()
    while true do
        if self.tt == 'EOF' then
            if self.fn == self.main_fn then
                break
            end
            self:advance()
        elseif self.tt == 'EOL' then
            -- empty line
            self:advance()
        elseif self.tt == 'DIR' then
            self:directive()
        elseif self.tt == 'LABEL' then
            self.dumper:add_label(self.tok)
            self:advance()
        elseif self.tt == 'INSTR' then
            self:instruction()
        else
            self:error('unexpected token (unknown instruction?)')
        end
    end
    return self.dumper:dump()
end

return Parser
