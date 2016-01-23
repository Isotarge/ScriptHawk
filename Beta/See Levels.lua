local map_base = 0x1b5a;
local num_maps = 10 * 10;

local function see_maps()
	local value;
	for i = 0, num_maps do
		value = mainmemory.readbyte(map_base + i);
		mainmemory.writebyte(map_base + i, bit.bor(value, 0x80));
	end
end

event.onframestart(see_maps, "See maps");