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

local cursorColors = { -- Pattern repeats % 4
	[0] = 0xFF66AAEE, -- Blue
	[1] = 0xFFEE0000, -- Red
	[2] = 0xFFEECC22, -- Yellow
	[3] = 0xFF00AA00, -- Green
};

local characterColors = {
	[0] = 0xFFEE0000, -- Red
	[1] = 0xFF00AA00, -- Green
	[2] = 0xFFEECC22, -- Yellow
	[3] = 0xFF66AAEE, -- Blue
};

local epochs = {
	[0] = "9500BC",
	[1] = "3000BC",
	[2] = "100BC",
	[3] = "900AD",
	[4] = "1400AD",
	[5] = "1850AD",
	[6] = "1915AD",
	[7] = "1945AD",
	[8] = "1980AD",
	[9] = "2001AD",
};

local maxTowerHealth = { -- TODO: Calculate this
	[0] = 200,
	[1] = 300,
	[2] = 400,
	[3] = 500,
	[4] = 600,
	[5] = 700,
	[6] = 800,
	[7] = 900,
	[8] = 1000,
	[9] = 1000, -- TODO: I think this is correct but I'm not 100%
};

local sectorData = {
	["breed_ticker"] = 0xBA, -- 12.4 fixed point (u16_be / 16)
	["breed_population"] = 0xBC, -- u16_be
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
		["giant_catapaults"] = 0x04, -- u8
		["cannons"] = 0x05, -- u8
		--["?"] = 0x06, -- u8 -- TODO
		["planes"] = 0x07, -- u8
		["jets"] = 0x08, -- u8
		--["?"] = 0x09, -- u8 -- TODO
		["unarmed"] = 0x0A, -- u8
	},
	["army_totals"] = {
		["scarlet"] = 0x2F4, -- u16_be
		["caesar"] = 0x2F6, -- u16_be
		["oberon"] = 0x2F8, -- u16_be
		["madcap"] = 0x2FA, -- u16_be
	},
	["defenses"] = 0x3B8, -- Array, 10 bytes, TTTTMMLFFF
	["tower_health"] = 0x3D6, -- u16_be
	["mine_health"] = 0x3D8, -- u16_be
	["lab_health"] = 0x3DA, -- u16_be
	["factory_health"] = 0x3DC, -- u16_be
	["owner"] = 0x3FE, -- u16_be
	["population"] = 0x406, -- u16_be
	["epoch"] = 0x418, -- u16_be
};

local OSDPosition = {2, 70};
local OSDRowHeight = 16;
local OSDCharacterWidth = 10;

function getArmyData(army)
	return {
		["rocks"] = mainmemory.read_u8(army + sectorData.army.rocks),
		["catapaults"] = mainmemory.read_u8(army + sectorData.army.catapaults),
		["pikes"] = mainmemory.read_u8(army + sectorData.army.pikes),
		["longbows"] = mainmemory.read_u8(army + sectorData.army.longbows),
		["giant_catapaults"] = mainmemory.read_u8(army + sectorData.army.giant_catapaults),
		["cannons"] = mainmemory.read_u8(army + sectorData.army.cannons),
		-- TODO
		["planes"] = mainmemory.read_u8(army + sectorData.army.planes),
		["jets"] = mainmemory.read_u8(army + sectorData.army.jets),
		-- TODO
		["unarmed"] = mainmemory.read_u8(army + sectorData.army.unarmed),
	};
end

function getSectorData(sector)
	local data = {};
	data.breed_ticker = mainmemory.read_u16_be(sector + sectorData.breed_ticker) / 16;
	data.breed_population = mainmemory.read_u16_be(sector + sectorData.breed_population);
	data.population = mainmemory.read_u16_be(sector + sectorData.population);
	data.epoch = mainmemory.read_u16_be(sector + sectorData.epoch);
	data.owner = mainmemory.read_u16_be(sector + sectorData.owner);

	data.tower_health = mainmemory.read_u16_be(sector + sectorData.tower_health);
	data.max_tower_health = maxTowerHealth[data.epoch];
	data.mine_health = mainmemory.read_u16_be(sector + sectorData.mine_health);
	data.lab_health = mainmemory.read_u16_be(sector + sectorData.lab_health);
	data.factory_health = mainmemory.read_u16_be(sector + sectorData.factory_health);

	data.army = {
		["scarlet"] = getArmyData(sector + sectorData.army_bases.scarlet),
		["caesar"] = getArmyData(sector + sectorData.army_bases.caesar),
		["oberon"] = getArmyData(sector + sectorData.army_bases.oberon),
		["madcap"] = getArmyData(sector + sectorData.army_bases.madcap),
	};

	data.army.scarlet.total = mainmemory.read_u16_be(sector + sectorData.army_totals.scarlet);
	data.army.caesar.total = mainmemory.read_u16_be(sector + sectorData.army_totals.caesar);
	data.army.oberon.total = mainmemory.read_u16_be(sector + sectorData.army_totals.oberon);
	data.army.madcap.total = mainmemory.read_u16_be(sector + sectorData.army_totals.madcap);

	return data;
end

function draw_OSD()
	local row = 0;
	for i = 1, numSectors do
		local sector = sectorBase + (i - 1) * sectorSize;
		local data = getSectorData(sector);
		if data.tower_health > 0 and data.owner < 4 then
			gui.text(OSDPosition[1], OSDPosition[2] + row * OSDRowHeight, toHexString(sector)..":", characterColors[data.owner]);
			gui.text(OSDPosition[1] + 8 * OSDCharacterWidth, OSDPosition[2] + row * OSDRowHeight, epochs[data.epoch].." "..data.tower_health.."/"..data.max_tower_health.."HP pop: "..data.population.." armies: "..data.army.scarlet.total..","..data.army.caesar.total..","..data.army.oberon.total..","..data.army.madcap.total);
			row = row + 1;
		end
	end
end

event.onframestart(draw_OSD);