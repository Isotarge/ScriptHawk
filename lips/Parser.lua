local insert = table.insert

local path = string.gsub(..., "[^.]+$", "")
local Base = require(path.."Base")
local Token = require(path.."Token")
local Lexer = require(path.."Lexer")
local Collector = require(path.."Collector")
local Preproc = require(path.."Preproc")
local Dumper = require(path.."Dumper")

local Parser = Base:extend()
function Parser:init(writer, fn, options)
    self.writer = writer
    self.fn = fn or '(string)'
    self.main_fn = self.fn
    self.options = options or {}
end

function Parser:tokenize(asm)
    local lexer = Lexer(asm, self.main_fn, self.options)
    local tokens = {}

    local loop = true
    while loop do
        lexer:lex(function(tt, tok, fn, line)
            assert(tt, 'Internal Error: missing token')
            local t = Token(fn, line, tt, tok)
            insert(tokens, t)
            -- don't break if this is an included file's EOF
            if tt == 'EOF' and fn == self.main_fn then
                loop = false
            end
        end)
    end

    -- the lexer guarantees an EOL and EOF for a blank file
    assert(#tokens > 0, 'Internal Error: no tokens after preprocessing')

    local collector = Collector(self.options)
    self.statements = collector:collect(tokens, self.main_fn)
end

function Parser:debug_dump()
    local boring = {
        tt = true,
        tok = true,
        fn = true,
        line = true,
    }
    for i, s in ipairs(self.statements) do
        local values = ''
        for j, t in ipairs(s) do
            local tok = t.tok
            if type(tok) == 'number' then
                tok = ("$%X"):format(tok)
            end
            values = values..'\t'..t.tt..'('..tostring(tok)..')'
            for k, v in pairs(t) do
                if not boring[k] then
                    values = values..'['..k..'='..tostring(v)..']'
                end
            end
        end
        values = values:sub(2)
        print(s.line, s.type, values)
    end
end

function Parser:parse(asm)
    self:tokenize(asm)

    if self.options.debug_token then self:debug_dump() end

    local preproc = Preproc(self.options)
    self.statements = preproc:process(self.statements)

    if self.options.debug_pre then self:debug_dump() end

    self.statements = preproc:expand(self.statements)

    if self.options.debug_post then self:debug_dump() end

    local dumper = Dumper(self.writer, self.options)
    self.statements = dumper:load(self.statements)

    if self.options.debug_asm then self:debug_dump() end

    if self.options.labels then
        dumper:export_labels(self.options.labels)
    end
    return dumper:dump()
end

return Parser
