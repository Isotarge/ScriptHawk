function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	prefix = prefix or "0x";
	desiredLength = desiredLength or string.len(value);
	while string.len(value) < desiredLength do
		value = "0"..value;
	end
	return prefix..value;
end

local selectedSectorPointer = 0xB5B4;
local sectorBase = 0xB6C4;
local sectorSize = 0x44A;
local numSectors = 16;

local sectorData = {
	["breed_ticker"] = 0xBA, -- 12.4 fixed point (u16_be / 16)
	["population"] = 0xBC, -- u16_be
};

local OSDPosition = {2, 70};
local OSDRowHeight = 16;

function getSectorData(sector)
	local data = {};
	data.breed_ticker = mainmemory.read_u16_be(sector + sectorData.breed_ticker) / 16;
	data.population = mainmemory.read_u16_be(sector + sectorData.population);
	return data;
end

function draw_OSD()
	local row = 0;
	for i = 1, numSectors do
		local sector = sectorBase + (i - 1) * sectorSize;
		local data = getSectorData(sector);
		if data.breed_ticker ~= 0 then -- TODO: Better detection for sector in use
			gui.text(OSDPosition[1], OSDPosition[2] + row * OSDRowHeight, toHexString(sector).." pop: "..data.population.." breed: "..data.breed_ticker);
			row = row + 1;
		end
	end
end

event.onframestart(draw_OSD);