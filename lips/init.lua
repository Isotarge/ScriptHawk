local lips = {
    _DESCRIPTION = 'Assembles MIPS assembly files for the R4300i CPU.',
    _URL = 'https://github.com/notwa/lips/',
    _LICENSE = [[
        Copyright (C) 2015,2016 Connor Olding

        This program is licensed under the terms of the MIT License, and
        is distributed without any warranty.  You should have received a
        copy of the license along with this program; see the file LICENSE.
    ]],
}

local util = require "lips.util"
local Parser = require "lips.Parser"

function lips.word_writer()
    local buff = {}
    local max = -1
    return function(pos, b)
        if pos then
            buff[pos] = b
            if pos > max then
                max = pos
            end
        elseif max >= 0 then
            for i=0, max, 4 do
                local a = buff[i+0] or '00'
                local b = buff[i+1] or '00'
                local c = buff[i+2] or '00'
                local d = buff[i+3] or '00'
                print(a..b..c..d)
            end
        end
    end
end

function lips.assemble(fn_or_asm, writer, options)
    -- assemble MIPS R4300i assembly code.
    -- if fn_or_asm contains a newline; treat as assembly, otherwise load file.
    -- returns error message on error, or nil on success.
    fn_or_asm = tostring(fn_or_asm)
    local default_writer = not writer
    writer = writer or lips.word_writer()
    options = options or {}

    local function main()
        local fn = nil
        local asm
        if fn_or_asm:find('[\r\n]') then
            asm = fn_or_asm
        else
            fn = fn_or_asm
            asm = util.readfile(fn)
            options.path = fn:match(".*/")
        end

        local parser = Parser(writer, fn, options)
        parser:parse(asm)

        if default_writer then
            writer()
        end
    end

    if options.unsafe then
        return main()
    else
        local ok, err = pcall(main)
        return err
    end
end

return setmetatable(lips, {
    __call = function(self, ...)
        return self.assemble(...)
    end,
})
