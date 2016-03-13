local insert = table.insert

local data = require "lips.data"
local util = require "lips.util"
local Muncher = require "lips.Muncher"
local Token = require "lips.Token"

local Preproc = util.Class(Muncher)
function Preproc:init(options)
    self.options = options or {}
end

function Preproc:process(tokens)
    self.tokens = tokens

    local defines = {}
    local plus_labels = {} -- constructed forwards
    local minus_labels = {} -- constructed backwards

    -- first pass: resolve defines, collect relative labels
    local new_tokens = {}
    self.i = 0
    while self.i < #self.tokens do
        local t = self:advance()
        if t.tt == nil then
            error('Internal Error: missing token')
        elseif t.tt == 'DEF' then
            local t2 = self:advance()
            if t2.tt ~= 'NUM' then
                self:error('expected number for define')
            end
            defines[t.tok] = t2.tok
        elseif t.tt == 'DEFSYM' then
            local tt = 'NUM'
            local tok = defines[t.tok]
            if tok == nil then
                self:error('undefined define') -- uhhh nice wording
            end
            insert(new_tokens, self:token(tt, tok))
        elseif t.tt == 'RELLABEL' then
            if t.tok == '+' then
                insert(plus_labels, #new_tokens + 1)
            elseif t.tok == '-' then
                insert(minus_labels, 1, #new_tokens + 1)
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
            t.tok = tostring(i)
        elseif t.tt == 'RELLABELSYM' then
            t.tt = 'LABELSYM'

            local rel = t.tok
            local seen = 0
            -- TODO: don't iterate over *every* label, just the ones nearby
            if rel > 0 then
                for _, label_i in ipairs(plus_labels) do
                    if label_i > i then
                        seen = seen + 1
                        if seen == rel then
                            t.tok = tostring(label_i)
                            break
                        end
                    end
                end
            else
                for _, label_i in ipairs(minus_labels) do
                    if label_i < i then
                        seen = seen - 1
                        if seen == rel then
                            t.tok = tostring(label_i)
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
