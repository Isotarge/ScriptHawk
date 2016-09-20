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

local cursorX = 0xB410;
local cursorY = 0xB412;

local sectorData = {
	["breed_ticker"] = 0xBA, -- 12.4 fixed point (u16_be / 16)
	["population"] = 0xBC, -- u16_be
	["research_pop"] = 0xC4, -- u16_be
	["research_ticker"] = 0xCC, -- u16_be
	["research_pop_2"] = 0xCE, -- u16_be
	["army"] = { -- TODO: Is this just scarlet?
		["rocks"] = 0x2C8, -- u8
		["catapaults"] = 0x2C9, -- u8
		["pikes"] = 0x2CA, -- u8
		["longbows"] = 0x2CB, -- u8
		["unarmed"] = 0x2D2, -- u8
		["total"] = 0x2F4, -- u16_be
	},
	["population_real"] = 0x406, -- u16_be
};

local OSDPosition = {2, 70};
local OSDRowHeight = 16;

function getSectorData(sector)
	local data = {};
	data.breed_ticker = mainmemory.read_u16_be(sector + sectorData.breed_ticker) / 16;
	data.population = mainmemory.read_u16_be(sector + sectorData.population);
	data.population_real = mainmemory.read_u16_be(sector + sectorData.population_real);
	return data;
end

function draw_OSD()
	local row = 0;
	for i = 1, numSectors do
		local sector = sectorBase + (i - 1) * sectorSize;
		local data = getSectorData(sector);
		if data.breed_ticker ~= 0 then -- TODO: Better detection for sector in use
			gui.text(OSDPosition[1], OSDPosition[2] + row * OSDRowHeight, toHexString(sector).." pop: "..data.population_real.." breed: "..data.breed_ticker);
			row = row + 1;
		end
	end
end

event.onframestart(draw_OSD);