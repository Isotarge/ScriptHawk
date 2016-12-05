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

--[[
from idaapi import *
funcs = Functions()
for f in funcs:
    name = Name(f)
    apifunc = idaapi.get_func(f)
    size = apifunc.endEA - apifunc.startEA
    print "{['start'] = 0x%08x, ['end'] = 0x%08x, ['size'] = 0x%02x, ['name'] = '%s'}," % (apifunc.startEA, apifunc.endEA, size, name)
]]--

local functions = {};
local romHash = gameinfo.getromhash();
if romHash == "1FE1632098865F639E22C11B9A81EE8F29C75D7A" then -- BK US 1.0
	functions = require("BKFunctions");
elseif romHash == "AF1A89E12B638B8D82CC4C085C8E01D4CBA03FB3" then -- BT US
	functions = require("BTFunctions");
elseif romHash == "CF806FF2603640A748FCA5026DED28802F1F4A50" then -- DK64 US
	functions = require("DK64Functions");
end

RDRAMBase = 0x80000000;
RDRAMSize = 0x800000; -- Halved with no expansion pak, can be read from 0x80000318

-- Checks whether a value falls within N64 RDRAM
function isRDRAM(value)
	return type(value) == "number" and value >= 0 and value < RDRAMSize;
end

-- Checks whether a value is a pointer in to N64 RDRAM on the system bus
function isPointer(value)
	return type(value) == "number" and value >= RDRAMBase and value < RDRAMBase + RDRAMSize;
end

-- Dereferences a N64 RDRAM pointer
-- Returns the RDRAM address pointed to if it's a valid pointer
-- Returns nil if invalid
function dereferencePointer(address)
	if type(address) == "number" and address >= 0 and address < (RDRAMSize - 4) then
		address = mainmemory.read_u32_be(address);
		if isPointer(address) then
			return address - RDRAMBase;
		end
	end
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

function hex2float(c)
	if c == 0 then return 0.0 end
	local c = toHexString(c, 8, "");
	local b1,b2,b3,b4 = string.byte(c, 1, 4);
	local sign = b1 > 0x7F;
	local expo = (b1 % 0x80) * 0x2 + math.floor(b2 / 0x80);
	local mant = ((b2 % 0x80) * 0x100 + b3) * 0x100 + b4;

	if sign then
		sign = -1;
	else
		sign = 1;
	end

	local n;

	if mant == 0 and expo == 0 then
		n = sign * 0.0;
	elseif expo == 0xFF then
		if mant == 0 then
			n = sign * math.huge; -- Infinity
		else
			n = 0.0 / 0.0; -- NaN
		end
	else
		n = sign * math.ldexp(1.0 + mant / 0x800000, expo - 0x7F);
	end

	return n;
end

local N64Registers = {
	"PC",
	"r0_lo", "r0_hi", -- zero
	"at_lo", --"at_hi",
	"v0_lo", --"v0_hi",
	"v1_lo", --"v1_hi",
	"a0_lo", --"a0_hi",
	"a1_lo", --"a1_hi",
	"a2_lo", --"a2_hi",
	"a3_lo", --"a3_hi",
	"t0_lo", --"t0_hi",
	"t1_lo", --"t1_hi",
	"t2_lo", --"t2_hi",
	"t3_lo", --"t3_hi",
	"t4_lo", --"t4_hi",
	"t5_lo", --"t5_hi",
	"t6_lo", --"t6_hi",
	"t7_lo", --"t7_hi",
	"s0_lo", --"s0_hi",
	"s1_lo", --"s1_hi",
	"s2_lo", --"s2_hi",
	"s3_lo", --"s3_hi",
	"s4_lo", --"s4_hi",
	"s5_lo", --"s5_hi",
	"s6_lo", --"s6_hi",
	"s7_lo", --"s7_hi",
	"t8_lo", --"t8_hi",
	"t9_lo", --"t9_hi",
	"k0_lo", --"k0_hi",
	"k1_lo", --"k1_hi",
	"gp_lo", --"gp_hi",
	"sp_lo", --"sp_hi",
	"s8_lo", --"s8_hi",
	"ra_lo", --"ra_hi",
	"LL",
	"LO_lo", "LO_hi",
	"HI_lo", "HI_hi",
	"FCR0",
	"FCR31",
	"CP0 REG0", -- Index
	"CP0 REG1", -- Random
	"CP0 REG2", -- EntryLo0
	"CP0 REG3", -- EntryLo1
	"CP0 REG4", -- Context
	"CP0 REG5", -- PageMask
	"CP0 REG6", -- Wired
	"CP0 REG7", -- *RESERVED*
	"CP0 REG8", -- BadVAddr
	"CP0 REG9", -- Count
	"CP0 REG10", -- EntryHi
	"CP0 REG11", -- Compare
	"CP0 REG12", -- Status
	"CP0 REG13", -- Cause
	"CP0 REG14", -- EPC
	"CP0 REG15", -- PRevID
	"CP0 REG16", -- Config
	"CP0 REG17", -- LLAddr
	"CP0 REG18", -- WatchLo
	"CP0 REG19", -- WatchHi
	"CP0 REG20", -- XContext
	"CP0 REG21", -- *RESERVED*
	"CP0 REG22", -- *RESERVED*
	"CP0 REG23", -- *RESERVED*
	"CP0 REG24", -- *RESERVED*
	"CP0 REG25", -- *RESERVED*
	"CP0 REG26", -- PErr
	"CP0 REG27", -- CacheErr
	"CP0 REG28", -- TagLo
	"CP0 REG29", -- TagHi
	"CP0 REG30", -- ErrorEPC
	"CP0 REG31", -- *RESERVED*
	"CP1 FGR REG0_lo", --"CP1 FGR REG0_hi", -- TODO: Floating point coprocessor registers
	"CP1 FGR REG1_lo", --"CP1 FGR REG1_hi",
	"CP1 FGR REG2_lo", --"CP1 FGR REG2_hi",
	"CP1 FGR REG3_lo", --"CP1 FGR REG3_hi",
	"CP1 FGR REG4_lo", --"CP1 FGR REG4_hi",
	"CP1 FGR REG5_lo", --"CP1 FGR REG5_hi",
	"CP1 FGR REG6_lo", --"CP1 FGR REG6_hi",
	"CP1 FGR REG7_lo", --"CP1 FGR REG7_hi",
	"CP1 FGR REG8_lo", --"CP1 FGR REG8_hi",
	"CP1 FGR REG9_lo", --"CP1 FGR REG9_hi",
	"CP1 FGR REG10_lo", --"CP1 FGR REG10_hi",
	"CP1 FGR REG11_lo", --"CP1 FGR REG11_hi",
	"CP1 FGR REG12_lo", --"CP1 FGR REG12_hi",
	"CP1 FGR REG13_lo", --"CP1 FGR REG13_hi",
	"CP1 FGR REG14_lo", --"CP1 FGR REG14_hi",
	"CP1 FGR REG15_lo", --"CP1 FGR REG15_hi",
	"CP1 FGR REG16_lo", --"CP1 FGR REG16_hi",
	"CP1 FGR REG17_lo", --"CP1 FGR REG17_hi",
	"CP1 FGR REG18_lo", --"CP1 FGR REG18_hi",
	"CP1 FGR REG19_lo", --"CP1 FGR REG19_hi",
	"CP1 FGR REG20_lo", --"CP1 FGR REG20_hi",
	"CP1 FGR REG21_lo", --"CP1 FGR REG21_hi",
	"CP1 FGR REG22_lo", --"CP1 FGR REG22_hi",
	"CP1 FGR REG23_lo", --"CP1 FGR REG23_hi",
	"CP1 FGR REG24_lo", --"CP1 FGR REG24_hi",
	"CP1 FGR REG25_lo", --"CP1 FGR REG25_hi",
	"CP1 FGR REG26_lo", --"CP1 FGR REG26_hi",
	"CP1 FGR REG27_lo", --"CP1 FGR REG27_hi",
	-- TODO: Aren't there more of these?
};

local friendlyNames = {
	["r0_lo"] = "zero", ["r0_hi"] = "zero_hi",
	["at_lo"] = "at", ["at_hi"] = "at_hi",
	["v0_lo"] = "v0", ["v0_hi"] = "v0_hi",
	["v1_lo"] = "v1", ["v1_hi"] = "v1_hi",
	["a0_lo"] = "a0", ["a0_hi"] = "a0_hi",
	["a1_lo"] = "a1", ["a1_hi"] = "a1_hi",
	["a2_lo"] = "a2", ["a2_hi"] = "a2_hi",
	["a3_lo"] = "a3", ["a3_hi"] = "a3_hi",
	["t0_lo"] = "t0", ["t0_hi"] = "t0_hi",
	["t1_lo"] = "t1", ["t1_hi"] = "t1_hi",
	["t2_lo"] = "t2", ["t2_hi"] = "t2_hi",
	["t3_lo"] = "t3", ["t3_hi"] = "t3_hi",
	["t4_lo"] = "t4", ["t4_hi"] = "t4_hi",
	["t5_lo"] = "t5", ["t5_hi"] = "t5_hi",
	["t6_lo"] = "t6", ["t6_hi"] = "t6_hi",
	["t7_lo"] = "t7", ["t7_hi"] = "t7_hi",
	["s0_lo"] = "s0", ["s0_hi"] = "s0_hi",
	["s1_lo"] = "s1", ["s1_hi"] = "s1_hi",
	["s2_lo"] = "s2", ["s2_hi"] = "s2_hi",
	["s3_lo"] = "s3", ["s3_hi"] = "s3_hi",
	["s4_lo"] = "s4", ["s4_hi"] = "s4_hi",
	["s5_lo"] = "s5", ["s5_hi"] = "s5_hi",
	["s6_lo"] = "s6", ["s6_hi"] = "s6_hi",
	["s7_lo"] = "s7", ["s7_hi"] = "s7_hi",
	["t8_lo"] = "t8", ["t8_hi"] = "t8_hi",
	["t9_lo"] = "t9", ["t9_hi"] = "t9_hi",
	["k0_lo"] = "k0", ["k0_hi"] = "k0_hi",
	["k1_lo"] = "k1", ["k1_hi"] = "k1_hi",
	["gp_lo"] = "gp", ["gp_hi"] = "gp_hi",
	["sp_lo"] = "sp", ["sp_hi"] = "sp_hi",
	["s8_lo"] = "s8", ["s8_hi"] = "s8_hi",
	["ra_lo"] = "ra", ["ra_hi"] = "ra_hi",
};

function isFunction(address)
	if not isPointer(address) then
		return false;
	end
	for i = 1, #functions do
		local currentFunction = functions[i];
		if address >= currentFunction['start'] and address < currentFunction['end'] then
			return currentFunction;
		end
	end
	return false;
end

function callStack(stackPointer, stackEnd)
	local maxIterations = 1000;
	for i = stackPointer, stackEnd, 4 do
		local currentValue = mainmemory.read_u32_be(i - RDRAMBase);
		local currentFunction = isFunction(currentValue);
		if currentFunction ~= false then
			dprint(currentFunction.name.." + "..toHexString(currentValue - currentFunction.start));
		elseif isPointer(currentValue) then
			dprint(toHexString(currentValue, 8, ""));
		end
	end
end

function callback()
	local registers = emu.getregisters();

	local stackPointer = registers["sp_lo"];
	local PC = registers["PC"];

	-- DK64 Stack
	local stackEnd = 0x80016630; -- TODO: Confirm or compute this somehow
	if stackPointer > 0x80016630 then
		stackEnd = 0x80767C00; -- TODO: Confirm or compute this somehow
	end

	-- BT Stack
	--local stackEnd = 0x800459B0; -- TODO: Confirm or compute this somehow

	local PCFunction = isFunction(PC);
	if PCFunction ~= false then
		dprint(PCFunction.name.." + "..toHexString(PC - PCFunction.start));
	elseif isPointer(PC) then
		dprint(toHexString(PC, 8, ""));
	end
	callStack(stackPointer, stackEnd);
	dprint();
	print_deferred();

	for i = 1, #N64Registers do
		local friendlyName = N64Registers[i];
		if type(friendlyNames[friendlyName]) == "string" then
			friendlyName = friendlyNames[friendlyName];
		end
		if string.starts(N64Registers[i], "CP1") then
			registers[N64Registers[i]] = hex2float(registers[N64Registers[i]]);
		else
			registers[N64Registers[i]] = toHexString(registers[N64Registers[i]]);
		end
		dprint(friendlyName..": "..registers[N64Registers[i]]);
	end
	dprint();
	print_deferred();
end

-- Example callback: DK64 map load state
--event.onmemorywrite(callback, 0x8076A0B1);