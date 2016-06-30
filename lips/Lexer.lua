local byte = string.byte
local char = string.char
local find = string.find
local format = string.format
local insert = table.insert

local path = string.gsub(..., "[^.]+$", "")
local data = require(path.."data")
local util = require(path.."util")
local Base = require(path.."Base")

local simple_escapes = {
    ['0']   = 0x00,
    ['\\']  = 0x5C,
    ['"']   = 0x22,
    ['a']   = 0x07,
    ['b']   = 0x08,
    ['f']   = 0x0C,
    ['n']   = 0x0A,
    ['r']   = 0x0D,
    ['t']   = 0x09,
    ['v']   = 0x0B,
}

local Lexer = Base:extend()
function Lexer:init(asm, fn, options)
    self.asm = asm
    self.fn = fn or '(string)'
    self.options = options or {}
    self.pos = 1
    self.line = 1
    self.EOF = -1
    self.was_EOL = false
    self:nextc()
end

function Lexer:error(msg)
    error(format('%s:%d: Error: %s', self.fn, self.line, msg), 2)
end

function Lexer:nextc()
    -- iterate to the next character while translating newlines.
    -- outputs:
    --self.chr      the character as a string
    --self.chr2     the character after it as a string
    --self.chrchr   both characters as a string
    --              chr values can be empty
    --self.ord      numeric value of the character
    --self.ord2     numeric value of the character after it
    --              ord values can be self.EOF
    --self.was_EOL  if the character was an EOL
    --              this EOL state is preserved past the EOF
    --              so it can be used to determine if the file lacks a final EOL

    if self.pos > #self.asm then
        self.ord = self.EOF
        self.ord2 = self.EOF
        self.chr = ''
        self.chr2 = ''
        self.chrchr = ''
        return
    end

    if self.chr == '\n' then
        self.line = self.line + 1
    end

    self.ord = byte(self.asm, self.pos)
    self.pos = self.pos + 1

    -- handle newlines; translate CRLF to LF
    if self.ord == 13 then
        if self.pos <= #self.asm and byte(self.asm, self.pos) == 10 then
            self.pos = self.pos + 1
        end
        self.ord = 10
    end
    self.was_EOL = self.ord == 10

    self.chr = char(self.ord)
    if self.pos <= #self.asm then
        self.ord2 = byte(self.asm, self.pos)
        self.chr2 = char(self.ord2)
        self.chrchr = char(self.ord, self.ord2)
    else
        self.ord2 = self.EOF
        self.chr2 = ''
        self.chrchr = self.chr
    end
end

function Lexer:skip_to_EOL()
    while self.chr ~= '\n' and self.ord ~= self.EOF do
        self:nextc()
    end
end

function Lexer:read_chars(pattern)
    local buff = ''
    while find(self.chr, pattern) do
        buff = buff..self.chr
        self:nextc()
    end
    return buff
end

function Lexer:read_spaces()
    return self:read_chars('[ \t]')
end

function Lexer:read_decimal()
    local buff = self:read_chars('%d')
    local num = tonumber(buff)
    if not num then self:error('invalid decimal number') end
    return num
end

function Lexer:read_hex()
    local buff = self:read_chars('%x')
    local num = tonumber(buff, 16)
    if not num then self:error('invalid hex number') end
    return num
end

function Lexer:read_octal()
    local buff = self:read_chars('[0-7]')
    local num = tonumber(buff, 8)
    if not num then self:error('invalid octal number') end
    return num
end

function Lexer:read_binary()
    local buff = self:read_chars('[01]')
    local num = tonumber(buff, 2)
    if not num then self:error('invalid binary number') end
    return num
end

function Lexer:read_number()
    if self.chr == '%' then
        self:nextc()
        return self:read_binary()
    elseif self.chr == '$' then
        self:nextc()
        return self:read_hex()
    elseif self.chr:find('%d') then
        if self.chr2 == 'x' then
            self:nextc()
            self:nextc()
            return self:read_hex()
        elseif self.chr2 == 'o' then
            self:nextc()
            self:nextc()
            return self:read_octal()
        elseif self.chr2 == 'b' then
            self:nextc()
            self:nextc()
            return self:read_binary()
        elseif self.chr == '0' and self.chr2:find('%d') then
            self:nextc()
            return self:read_octal()
        else
            return self:read_decimal()
        end
    elseif self.chr == '#' then
        self:nextc()
        return self:read_decimal()
    end
end

function Lexer:lex_hex(yield)
    local hexmatch = '[0-9A-Fa-f]'
    local entered = false
    while true do
        if self.chr == '\n' then
            yield('EOL', '\n')
            self:nextc()
        elseif self.ord == self.EOF then
            self:error('unexpected EOF; incomplete hex directive')
        elseif self.chr == ';' then
            self:skip_to_EOL()
        elseif self.chrchr == '//' then
            self:skip_to_EOL()
        elseif self.chrchr == '/*' then
            self:nextc()
            self:nextc()
            self:lex_block_comment(yield)
        elseif self.chr:find('%s') then
            self:nextc()
        elseif self.chr == '{' then
            if entered then
                self:error('unexpected opening brace')
            end
            self:nextc()
            entered = true
            yield('OPEN', '{')
        elseif self.chr == '}' then
            if not entered then
                self:error('expected opening brace')
            end
            self:nextc()
            yield('CLOSE', '}')
            break
        elseif self.chr == ',' then
            self:error('commas are not allowed in HEX directives')
        elseif self.chr:find(hexmatch) and self.chr2:find(hexmatch) then
            local num = tonumber(self.chrchr, 16)
            self:nextc()
            self:nextc()
            if self.chr:find(hexmatch) then
                self:error('too many hex digits to be a single byte')
            end
            yield('NUM', num)
        elseif self.chr:find(hexmatch) then
            self:error('expected two hex digits to make a byte')
        else
            if entered then
                self:error('expected bytes given in hex or closing brace')
            else
                self:error('expected opening brace')
            end
        end
    end
end

function Lexer:lex_block_comment(yield)
    while true do
        if self.chr == '\n' then
            yield('EOL', '\n')
            self:nextc()
        elseif self.ord == self.EOF then
            self:error('unexpected EOF; incomplete block comment')
        elseif self.chrchr == '*/' then
            self:nextc()
            self:nextc()
            break
        else
            self:nextc()
        end
    end
end

function Lexer:lex_string(yield)
    if self.chr ~= '"' then
        self:error('expected opening double quote')
    end
    self:nextc()

    local bytes = {}
    while true do
        if self.chr == '\n' then
            self:error('unimplemented: newlines in strings')
            yield('EOL', '\n')
            self:nextc()
        elseif self.ord == self.EOF then
            self:nextc()
            self:error('unexpected EOF; incomplete string')
        elseif self.chr == '"' then
            self:nextc()
            break
        elseif self.chr == '\\' then
            self:nextc()
            local simple = simple_escapes[self.chr]
            if simple then
                insert(bytes, simple)
            else
                self:error('unknown escape sequence')
            end
            self:nextc()
        else
            insert(bytes, byte(self.chr))
            self:nextc()
        end
    end

    yield('STRING', bytes)
end

function Lexer:lex_string_naive(yield) -- no escape sequences
    if self.chr ~= '"' then
        self:error('expected opening double quote')
    end
    self:nextc()
    local buff = self:read_chars('[^"\n]')
    if self.chr ~= '"' then
        self:error('expected closing double quote')
    end
    self:nextc()
    yield('STRING', buff)
end

function Lexer:lex_include(_yield)
    self:read_spaces()
    local fn
    self:lex_string_naive(function(tt, tok)
        fn = tok
    end)
    _yield('STRING', fn, self.fn, self.line)

    if self.options.path then
        fn = self.options.path..fn
    end

    local new_options = setmetatable({}, {__index=self.options})
    new_options.path = fn:match(".*/")
    local sublexer = Lexer(util.readfile(fn), fn, new_options)
    sublexer:lex(_yield)
end

function Lexer:lex_include_binary(_yield)
    self:read_spaces()
    local fn
    self:lex_string_naive(function(tt, tok)
        fn = tok
    end)
    _yield('STRING', fn, self.fn, self.line)

    -- TODO: allow optional offset and size arguments
    if self.options.path then
        fn = self.options.path..fn
    end
    local data = util.readfile(fn, true)

    -- FIXME: this allocates a table for each byte.
    --        this could easily cause performance issues on big files.
    _yield('DIR', 'BYTE', fn, 0)
    for b in string.gfind(data, '.') do
        _yield('NUM', string.byte(b), fn, 0)
    end
end

function Lexer:lex(_yield)
    local function yield(tt, tok)
        return _yield(tt, tok, self.fn, self.line)
    end
    while true do
        if self.chr == '\n' then
            yield('EOL', '\n')
            self:nextc()
        elseif self.ord == self.EOF then
            if not self.was_EOL then
                yield('EOL', '\n')
            end
            yield('EOF', self.EOF)
            break
        elseif self.chr == ';' then
            self:skip_to_EOL()
        elseif self.chrchr == '//' then
            self:skip_to_EOL()
        elseif self.chrchr == '/*' then
            self:nextc()
            self:nextc()
            self:lex_block_comment(yield)
        elseif self.chr:find('%s') then
            self:nextc()
        elseif self.chr == ',' then
            self:nextc()
            yield('SEP', ',')
        elseif self.chr == '[' then
            self:nextc()
            local buff = self:read_chars('[%w_]')
            if self.chr ~= ']' then
                self:error('invalid variable name')
            end
            self:nextc()
            if self.chr ~= ':' then
                self:error('expected a colon after closing bracket')
            end
            self:nextc()
            yield('VAR', buff)
        elseif self.chr == ']' then
            self:error('unmatched closing bracket')
        elseif self.chr == '(' then
            self:nextc()
            yield('OPEN', '(')
        elseif self.chr == ')' then
            self:nextc()
            yield('CLOSE', ')')
        elseif self.chr == '.' then
            self:nextc()
            local buff = self:read_chars('[%w]')
            local up = buff:upper()
            if data.directive_aliases[up] then
                up = data.directive_aliases[up]
            end
            if not data.all_directives[up] then
                self:error('unknown directive')
            end
            if up == 'INC' or up == 'INCASM' or up == 'INCLUDE' then
                yield('DIR', 'INC')
                self:lex_include(_yield)
            elseif up == 'INCBIN' then
                yield('DIR', 'INCBIN')
                self:lex_include_binary(_yield)
            else
                yield('DIR', up)
            end
        elseif self.chr == '"' then
            self:lex_string(yield)
        elseif self.chr == '@' then
            self:nextc()
            local buff = self:read_chars('[%w_]')
            yield('VARSYM', buff)
        elseif self.chr == '%' then
            self:nextc()
            if self.chr:find('[%a_]') then
                local call = self:read_chars('[%w_]')
                if call ~= '' then
                    yield('SPECIAL', call)
                end
            elseif self.chr:find('[01]') then
                yield('NUM', self:read_binary())
            else
                self:error('unknown % syntax')
            end
        elseif self.chr:find('[%a_]') then
            local buff = self:read_chars('[%w_.]')
            local up = buff:upper()
            if self.chr == ':' then
                if buff:find('%.') then
                    self:error('labels cannot contain dots')
                end
                self:nextc()
                yield('LABEL', buff)
            elseif up == 'HEX' then
                yield('DIR', 'HEX')
                self:lex_hex(yield)
            elseif data.all_registers[up] then
                yield('REG', up)
            elseif data.all_instructions[up] then
                yield('INSTR', up:gsub('%.', '_'))
            else
                if buff:find('%.') then
                    self:error('labels cannot contain dots')
                end
                yield('LABELSYM', buff)
            end
        elseif self.chr == '+' or self.chr == '-' then
            local sign_chr = self.chr
            local sign = sign_chr == '+' and 1 or -1
            local signs = self:read_chars('%'..self.chr)
            local name = ''
            if self.chr:find('[%a_]') then
                name = self:read_chars('[%w_]')
            end
            if #signs == 1 and self.chr == ':' then
                self:nextc()
                yield('RELLABEL', signs..name)
            else
                self:read_spaces()
                local n = self:read_number()
                if n then
                    yield('NUM', sign*n)
                elseif #signs == 1 and name == '' then
                    -- this could be a RELLABELSYM
                    -- we'll have to let the preproc figure it out
                    yield('UNARY', sign)
                else
                    yield('RELLABELSYM', signs..name)
                end
            end
        else
            local n = self:read_number()
            if n then
                yield('NUM', n)
            else
                self:error('unknown character or control character')
            end
        end
    end
end

return Lexer
