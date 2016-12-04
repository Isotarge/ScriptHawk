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
local num_maps = 9 * 6;

local gametime = {
	hours = 0x00CA,
	minutes = 0x00CB,
	seconds = 0x00CC,
	centiseconds = 0x00CD,
};

maps = {
	[0x0F] = "Ending",
	[0x1E] = "Puzzle", -- Light green
	[0x1F] = "Puzzle", -- Dark Grey
	[0x20] = "Glitchy Puzzle", -- Light Grey
	[0x21] = "Glitchy Puzzle", -- Yellow
	[0x22] = "Glitchy Puzzle", -- Green
	[0x23] = "Glitchy Puzzle", -- Cyan
	[0x7F] = "Empty",
};

object = {
	obj_type = 0x00,
	obj_types = {
		--[0x00] = "??",
		[0x01] = "Blue Computer",
		[0x02] = "Printer",
		[0x03] = "Oven",
		[0x04] = "Desk",
		[0x05] = "Bed",
		[0x06] = "Drawers",
		[0x07] = "Fireplace ",
		[0x08] = "Sideways blue monitor",
		[0x09] = "Pink Chair",
		[0x0A] = "Flashing brown and blue rectangle",
		[0x0B] = "Brown and blue box",
		[0x0C] = "Bookshelf",
		[0x0D] = "Roll on deodorant",
		[0x0E] = "Lamp",
		[0x0F] = "Lounge",
		[0x10] = "Sink",
		[0x11] = "Small Pink thing",
		[0x12] = "Bathtub",
		[0x13] = "Toilet",
		[0x14] = "Candy",
		[0x15] = "End of Game Object",
		[0x16] = "Microwave",
		[0x17] = "Desk 2",
		[0x18] = "Fridge",
		[0x19] = "*Crash",
		--
		[0x1D] = "A2600 mode crash",
	},
	x_position = 0x01,
	y_position = 0x02,
	contents = 0x03,
	content_types = {
		[0x00] = "Nothing",
		[0x40] = "Lift Init",
		[0x80] = "Snooze",
		[0xC0] = "Puzzle Piece",
	},
};

object_arrays = { -- Use indexes from maps array
	[0x01] = {start=0x11EC, finish=0x11F9, objects=3, exits="dr"},
	[0x02] = {start=0x1201, finish=0x1216, objects=5, exits="dr"},
	[0x03] = {start=0x121A, finish=0x1223, objects=2, exits="dl,ur"},
	[0x04] = {start=0x1227, finish=0x123E, objects=6, exits="dl,ur"},
	[0x05] = {start=0x1244, finish=0x1267, objects=9, exits="ul"},
	[0x06] = {start=0x126D, finish=0x1280, objects=5, exits="dl,ur"},
	[0x07] = {start=0x1286, finish=0x1299, objects=5, exits="dr"},
}; 

function dumpMaps()
	local value;
	for i = 0, num_maps - 1 do
		value = bit.bxor(mainmemory.readbyte(map_base + i * 2), 0x80);
		if type(maps[value]) == "string" then
			print((i + 1).." ("..toHexString(map_base + i * 2).."): "..maps[value]);
		else
			print((i + 1).." ("..toHexString(map_base + i * 2).."): "..toHexString(value));
		end
	end
end
dumpLevels = dumpMaps;

local function fillMinimap()
	if mainmemory.readbyte(gametime.minutes) == 0 and mainmemory.readbyte(gametime.seconds) == 0 then
		return;
	end

	local value;
	for i = 0, num_maps - 1 do
		value = mainmemory.readbyte(map_base + i * 2);
		mainmemory.writebyte(map_base + i * 2, bit.bor(value, 0x80));
		value = mainmemory.readbyte(map_base + i * 2 + 1);
		mainmemory.writebyte(map_base + i * 2 + 1, bit.bor(value, 0x80));
	end
end
event.onframestart(fillMinimap, "ScriptHawk - Fill minimap");