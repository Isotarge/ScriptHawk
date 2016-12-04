-- Script to fill the minimap in Impossible Mission (SMS)
-- Written by Isotarge, The8bitbeast 2015-2016

string.lpad = function(str, len, char)
	if char == nil then char = ' ' end
	return string.rep(char, len - #str) .. str
end

function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	value = string.lpad(value, desiredLength or string.len(value), '0');
	return (prefix or "0x")..value;
end

local map_base = 0x1B5A;
local num_maps = 10 * 10;

local gametime = {
	hours = 0x00CA,
	minutes = 0x00CB,
	seconds = 0x00CC,
	centiseconds = 0x00CD,
};

local function fillMinimap()
	if mainmemory.readbyte(gametime.minutes) == 0 and mainmemory.readbyte(gametime.seconds) == 0 then
		return;
	end

	local value;
	for i = 0, num_maps do
		value = mainmemory.readbyte(map_base + i);
		mainmemory.writebyte(map_base + i, bit.bor(value, 0x80));
	end
end

object_types = {
	-- TODO
};

maps = {
	[0x7F] = "Empty",
};

object_arrays = { -- Use indexes from maps array
	
}; 

function dumpMaps()
	local value;
	for i = 0, num_maps do
		value = bit.bxor(mainmemory.readbyte(map_base + i), 0x80);
		if type(maps[value]) == "string" then
			print(i.." ("..toHexString(map_base + i).."): "..maps[value]);
		else
			print(i.." ("..toHexString(map_base + i).."): "..toHexString(value));
		end
	end
end

event.onframestart(fillMinimap, "ScriptHawk - Fill minimap");