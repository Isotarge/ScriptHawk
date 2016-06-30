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

local path = string.gsub(..., "%.init$", "").."."
local util = require(path.."util")
local Parser = require(path.."Parser")

lips.writers = require(path.."writers")

function lips.assemble(fn_or_asm, writer, options)
    -- assemble MIPS R4300i assembly code.
    -- if fn_or_asm contains a newline; treat as assembly, otherwise load file.
    -- returns error message on error, or nil on success.
    fn_or_asm = tostring(fn_or_asm)
    local default_writer = not writer
    writer = writer or lips.writers.make_word()
    options = options or {}

    local function main()
        if options.offset then
            if options.origin or options.base then
                error('offset and origin/base options are mutually exclusive')
            end
            io.stderr:write('Warning: options.offset is deprecated.\n')
            options.origin = options.offset
            options.base = 0
        else
            options.origin = options.origin or 0
            options.base = options.base or 0x80000000
        end

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
