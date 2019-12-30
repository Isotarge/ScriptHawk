--------------------
-- Deferred print --
-- HT Notwa       --
--------------------

local __dprinted = {};

function dprint(...) -- defer print
	-- helps with lag from printing directly to Bizhawk's console
	table.insert(__dprinted, {...});
end

function dprintf(fmt, ...)
	table.insert(__dprinted, fmt:format(...));
end

function print_deferred()
	local buff = '';
	for i, t in ipairs(__dprinted) do
		if type(t) == 'string' then
			buff = buff..t..'\n';
		elseif type(t) == 'table' then
			local s = '';
			for j, v in ipairs(t) do
				s = s..tostring(v);
				if j ~= #t then s = s..'\t' end
			end
			buff = buff..s..'\n';
		end
	end
	if #buff > 0 then
		print(buff:sub(1, #buff - 1));
	end
	__dprinted = {};
end

function string.starts(String, Start)
	return string.sub(String, 1, string.len(Start)) == Start;
end

function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	prefix = prefix or "0x";
	desiredLength = desiredLength or string.len(value);
	while string.len(value) < desiredLength do
		value = "0"..value;
	end
	return prefix..value;
end

local SMSRegisters = {
	"A",
	"AF",
	"B",
	"BC",
	"C",
	"D",
	"DE",
	"E",
	--"F",
	--"Flag 3rd",
	--"Flag 5th",
	--"Flag C",
	--"Flag H",
	--"Flag N",
	--"Flag P/V",
	--"Flag S",
	--"Flag Z",
	"H",
	"HL",
	"I",
	"IX",
	"IY",
	"L",
	--"PC",
	"R",
	"Shadow AF",
	"Shadow BC",
	"Shadow DE",
	"Shadow HL",
	--"SP",
};

local function callback()
	local registers = emu.getregisters();

	local PC = registers.PC;

	dprint("PC: "..toHexString(PC, 4, ""));
	dprint();
	print_deferred();

	for i = 1, #SMSRegisters do
		local friendlyName = SMSRegisters[i];
		if friendlyName == "HL" then
			--dprint("X Velocity: "..toHexString(mainmemory.read_u16_le(0x1404)));
			--dprint("Y Velocity: "..toHexString(mainmemory.read_u16_le(0x1407)));
			--dprint("FFFC: "..toHexString(memory.readbyte(0xFFFC, "System Bus")));
			--dprint("FFFD: "..toHexString(memory.readbyte(0xFFFD, "System Bus")));
			--dprint("FFFE: "..toHexString(memory.readbyte(0xFFFE, "System Bus")));
			--dprint("FFFF: "..toHexString(memory.readbyte(0xFFFF, "System Bus")));
			if registers[SMSRegisters[i]] >= 0xC000 and registers[SMSRegisters[i]] < 0xE000 then
				--dprint(toHexString(registers[SMSRegisters[i]])..": "..toHexString(memory.read_u16_le(registers[SMSRegisters[i]], "System Bus")));
			end
		end
		registers[SMSRegisters[i]] = toHexString(registers[SMSRegisters[i]]);
		dprint(friendlyName..": "..registers[SMSRegisters[i]]);
	end

	dprint();
	print_deferred();
end

event.onmemoryread(callback, 0xD2D5); -- Sonic 1 GG solidity level index read

--event.onmemorywrite(callback, 0xFFFF); -- Bank switch
--event.onmemoryexecute(callback, 0x4A05); -- Sonic 1 sms solidity data read
--event.onmemorywrite(callback, 0xD404); -- Sonic 1 sms x velocity write
--event.onmemorywrite(callback, 0xD407); -- Sonic 1 sms y velocity write
--event.onmemoryexecute(callback, 0x4BDC);
--event.onmemoryexecute(callback, 0x5781); -- sonic 1 sms spring activated
--event.onmemoryexecute(callback, 0x37DF); -- Sonic 1 sms ram location for terrain type returned in hl
--event.onmemorywrite(callback, 0xD408);

--[[event.onmemorywrite(callback, 0xC839); -- Bridge 1 glitchy bridge tile write
event.onmemorywrite(callback, 0xC83A); -- Bridge 1 glitchy bridge tile write
event.onmemorywrite(callback, 0xC939); -- Bridge 1 glitchy bridge tile write
event.onmemorywrite(callback, 0xC93A); -- Bridge 1 glitchy bridge tile write
event.onmemorywrite(callback, 0xCA39); -- Bridge 1 glitchy bridge tile write
event.onmemorywrite(callback, 0xCA3A); -- Bridge 1 glitchy bridge tile write
--]]