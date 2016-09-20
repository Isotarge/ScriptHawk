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
	["army_bases"] = {
		["scarlet"] = 0x2C8,
		["caesar"] = 0x2D3,
		["oberon"] = 0x2DE,
		["madcap"] = 0x2E9,
	},
	["army"] = { -- Size 0x0B
		["rocks"] = 0x00, -- u8
		["catapaults"] = 0x01, -- u8
		["pikes"] = 0x02, -- u8
		["longbows"] = 0x03, -- u8
		-- TODO: Everything inbetween
		["unarmed"] = 0x0A, -- u8
	},
	["army_totals"] = {
		["scarlet"] = 0x2F4, -- u16_be
		["caesar"] = 0x2F6, -- u16_be
		["oberon"] = 0x2F8, -- u16_be
		["madcap"] = 0x2FA, -- u16_be
	},
	["population_real"] = 0x406, -- u16_be
};

local OSDPosition = {2, 70};
local OSDRowHeight = 16;

function getArmyData(army)
	local data = {};
	data.rocks = mainmemory.read_u8(army + sectorData.army.rocks);
	data.catapaults = mainmemory.read_u8(army + sectorData.army.catapaults);
	data.pikes = mainmemory.read_u8(army + sectorData.army.pikes);
	data.longbows = mainmemory.read_u8(army + sectorData.army.longbows);
	data.unarmed = mainmemory.read_u8(army + sectorData.army.unarmed);
	return data;
end

function getSectorData(sector)
	local data = {};
	data.breed_ticker = mainmemory.read_u16_be(sector + sectorData.breed_ticker) / 16;
	data.population = mainmemory.read_u16_be(sector + sectorData.population);
	data.population_real = mainmemory.read_u16_be(sector + sectorData.population_real);

	data.army_totals = {};
	data.army_totals.scarlet = mainmemory.read_u16_be(sector + sectorData.army_totals.scarlet);
	data.army_totals.caesar = mainmemory.read_u16_be(sector + sectorData.army_totals.caesar);
	data.army_totals.oberon = mainmemory.read_u16_be(sector + sectorData.army_totals.oberon);
	data.army_totals.madcap = mainmemory.read_u16_be(sector + sectorData.army_totals.madcap);

	data.army = {};
	data.army.scarlet = getArmyData(sector + sectorData.army_bases.scarlet);
	data.army.caesar = getArmyData(sector + sectorData.army_bases.caesar);
	data.army.oberon = getArmyData(sector + sectorData.army_bases.oberon);
	data.army.madcap = getArmyData(sector + sectorData.army_bases.madcap);

	return data;
end

function draw_OSD()
	local row = 0;
	for i = 1, numSectors do
		local sector = sectorBase + (i - 1) * sectorSize;
		local data = getSectorData(sector);
		if data.breed_ticker ~= 0 then -- TODO: Better detection for sector in use
			gui.text(OSDPosition[1], OSDPosition[2] + row * OSDRowHeight, toHexString(sector).." pop: "..data.population_real.." armies: "..data.army_totals.scarlet..","..data.army_totals.caesar..","..data.army_totals.oberon..","..data.army_totals.madcap);
			row = row + 1;
		end
	end
end

event.onframestart(draw_OSD);