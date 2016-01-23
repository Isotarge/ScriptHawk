-- Script to fill the minimap in Impossible Mission (SMS)
-- Written by Isotarge, 2015

local map_base = 0x1B5A;
local num_maps = 10 * 10;

local function fillMinimap()
	local value;
	for i = 0, num_maps do
		value = mainmemory.readbyte(map_base + i);
		mainmemory.writebyte(map_base + i, bit.bor(value, 0x80));
	end
end

event.onframestart(fillMinimap, "Fill Minimap");