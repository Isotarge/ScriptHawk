function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	prefix = prefix or "0x";
	desiredLength = desiredLength or string.len(value);
	while string.len(value) < desiredLength do
		value = "0"..value;
	end
	return prefix..value;
end

--[[ rPrint(struct, [limit], [indent])   Recursively print arbitrary data. 
Set limit (default 100) to stanch infinite loops.
Indents tables as [KEY] VALUE, nested tables as [KEY] [KEY]...[KEY] VALUE
Set indent ("") to prefix each line:    Mytable [KEY] [KEY]...[KEY] VALUE
--]]
function rPrint(s, l, i) -- recursive Print (structure, limit, indent)
	l = (l) or 100; i = i or "";	-- default item limit, indent string
	if (l<1) then print "ERROR: Item limit reached."; return l-1 end;
	local ts = type(s);
	if (ts ~= "table") then print (i,ts,s); return l-1 end
	print (i,ts);           -- print "table"
	for k,v in pairs(s) do  -- print "[KEY] VALUE"
		l = rPrint(v, l, i.."\t["..tostring(k).."]");
		if (l < 0) then break end
	end
	return l
end	

local displayModes = {
	"General",
	"Element",
	"Off",
};
currentDisplayMode = 1;

function toggleDisplayMode()
	currentDisplayMode = currentDisplayMode + 1;
	if currentDisplayMode > #displayModes then
		currentDisplayMode = 1;
	end
end

displayEmptySectors = true;
function toggleDisplayEmptySectors()
	displayEmptySectors = not displayEmptySectors;
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
	[2] = "100BC", -- TODO: Sort out padding w/table renderer library
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

local researchTypes = {
	[0] = { -- Shield
		[0] = "1 Shield",
		[1] = "2 Shield",
		[2] = "3 Shield",
		[3] = "4 Shield",
		[4] = "5 Shield",
		[5] = "6 Shield",
		[6] = "7 Shield",
		[7] = "8 Shield",
		[8] = "9 Shield",
		[9] = "10 Shield",
	},
	[1] = { -- Defense
		[0] = "Stick",
		[1] = "Spear",
		[2] = "Bow", -- Bow and Arrow
		[3] = "Oil", -- Cauldron of Oil
		[4] = "Crossbow",
		[5] = "Musket",
		[6] = "Machine Gun",
		[7] = "Bazooka",
		[8] = "Nuke Defence",
		[9] = "Laser",
	},
	[2] = { -- Weapon
		[0] = "Rock",
		[1] = "Catapault",
		[2] = "Pike",
		[3] = "Longbow",
		[4] = "Giant Catapault",
		[5] = "Cannon",
		[6] = "Plane",
		[7] = "Jet",
		[8] = "Nuke",
		[9] = "UFO", -- Spaceship
	},
};

function getResearchString(data)
	local researchString = "lab: ";
	if researchTypes[data.research_type] ~= nil then
		if researchTypes[data.research_type][data.research_index] ~= nil then
			return researchString..researchTypes[data.research_type][data.research_index];
		end
	end
	if data.research_type >= 0 then
		return researchString.."None";
	end
	return researchString.."Unknown ".."("..data.research_type..","..data.research_index..")";
end

local sectorData = {
	["ticker"] = {
		["pop"] = 0x00, -- u16_be
		["ticker"] = 0x08, -- 12.4 fixed point (u16_be / 16)
		["pop_scaled"] = 0x0A, -- u16_be
	},
	["tickers"] = {
		["tower_construction"] = {
			["scarlet"] = 0x10,
			["caesar"] = 0x28,
			["oberon"] = 0x40,
			["madcap"] = 0x58,
		},
		["mine_construction"] = 0x70,
		["lab_construction"] = 0x88,
		["factory_construction"] = 0xA0,
		["breed"] = 0xB2,
		["research"] = 0xC4,
		["factory"] = 0xD8,
		["element1"] = 0x134,
		["element2"] = 0x144,
		["element3"] = 0x154,
		["element4"] = 0x164,
	},
	["element1_index"] = 0x140, -- s16_be
	["element2_index"] = 0x150, -- s16_be
	["element3_index"] = 0x160, -- s16_be
	["element4_index"] = 0x170, -- s16_be
	["element_total_array"] = 0x174, -- 0x13 entries
	["research_type"] = 0xBE, -- s16_be
	["research_index"] = 0xC0, -- u16_be
	["factory_quantity"] = 0xD6, -- u16_be, 0x00 = infinite
	["recipe_base_shield"] = 0x1AC, -- Array of recipes, 10 elements, 0x0A each
	["recipe_base_defense"] = 0x200, -- Array of recipes, 10 elements, 0x0A each
	["recipe_base_weapon"] = 0x264, -- Array of recipes, 10 elements, 0x0A each
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
		["UFOs"] = 0x09, -- u8
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
	["status"] = 0x448, -- u16_be (0x0000 unusable, 0x8000 normal, 0x4000 nuked)
};

local OSDPosition = {2, 2};
local OSDRowHeight = 16;
local OSDCharacterWidth = 10;

local emptyArmy = {
	["rocks"] = 0,
	["catapaults"] = 0,
	["pikes"] = 0,
	["longbows"] = 0,
	["giant_catapaults"] = 0,
	["cannons"] = 0,
	-- TODO
	["planes"] = 0,
	["jets"] = 0,
	["UFOs"] = 0,
	["unarmed"] = 0,
	["total"] = 0,
};

function getArmyData(sector, army, total)
	total = mainmemory.read_u16_be(sector + total);
	if total > 0 then
		army = sector + army;
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
			["UFOs"] = mainmemory.read_u8(army + sectorData.army.UFOs),
			["unarmed"] = mainmemory.read_u8(army + sectorData.army.unarmed),
			["total"] = total,
		};
	else
		return emptyArmy;
	end
end

function getTickerData(ticker)
	return {
		["pop"] = mainmemory.read_u16_be(ticker + sectorData.ticker.pop),
		["ticker"] = mainmemory.read_u16_be(ticker + sectorData.ticker.ticker) / 16,
		["pop_scaled"] = mainmemory.read_u16_be(ticker + sectorData.ticker.pop_scaled),
	};
end

local elementNames = {
	[0] = "Wood",
	[1] = "Stone",
	[2] = "Bone",
	[3] = "Tin",
	[4] = "Moon", -- Moonlite      -- TIER 2 START
	[5] = "Planet", -- Planetarium
	[6] = "Star", -- Bethlium
	[7] = "Sun", -- Solarium
	[8] = "Bottle", -- Aruldite    -- TIER 3 START
	[9] = "Herb", -- Herbirite
	[10] = "C", -- Yeridium
	[11] = "Valium",
	[12] = "Bug", -- Parasite
	[13] = "Fish", -- Aquarium
	[14] = "Hat", -- Paladium
	[15] = "Onion",
	[16] = "ZZZ", -- Tedium
	[17] = "Face", -- Moron
	[18] = "Green", -- Marmite
	[19] = "Alien",
};

function getRecipeData(sector, recipeArrayBase, recipeType)
	local recipeData = {};
	for i = 0, 9 do
		local recipe = {};
		local recipeBase = sector + recipeArrayBase + i * 10;
		for elementIndex = 0, 4 do
			local elementData = {
				["element"] = mainmemory.readbyte(recipeBase + elementIndex * 2),
				["quantity"] = mainmemory.readbyte(recipeBase + elementIndex * 2 + 1) / 2,
			};
			if elementData.element == 0 and elementData.quantity == 0 then
				--Speed up this function by breaking out of fake recipes since we don't return them anyway
				break;
			end
			if elementData.element ~= 0xFF and elementData.quantity > 0 then
				elementData.element = elementNames[elementData.element];
				recipe[elementIndex] = elementData;
			end
		end
		if #recipe > 0 then
			recipeData[researchTypes[recipeType][i]] = recipe;
		end
	end
	return recipeData;
end

function getElementData(sector, indexOffset)
	local elementIndex = mainmemory.read_s16_be(sector + indexOffset);
	local elementData = {
		["index"] = elementIndex,
		["name"] = "None",
		["quantity"] = 0,
		["remaining"] = 0,
		["total"] = 0,
	};

	if elementData.index >= 0 then
		elementData.name = elementNames[elementIndex];
		elementData.quantity = mainmemory.read_u16_be(sector + sectorData.element_total_array + elementIndex * 2) / 2;
		elementData.remaining = mainmemory.read_u16_be(sector + indexOffset + 2) / 2;
		elementData.total = elementData.quantity + elementData.remaining;
		if elementData.index < 4 then
			elementData.total = elementData.quantity;
		end
	end

	return elementData;
end

function getSectorData(sector)
	local data = {};

	data.tickers = {
		["tower_construction"] = {
			["scarlet"] = getTickerData(sector + sectorData.tickers.tower_construction.scarlet),
			["caesar"] = getTickerData(sector + sectorData.tickers.tower_construction.caesar),
			["oberon"] = getTickerData(sector + sectorData.tickers.tower_construction.oberon),
			["madcap"] = getTickerData(sector + sectorData.tickers.tower_construction.madcap),
		},
		["mine_construction"] = getTickerData(sector + sectorData.tickers.mine_construction),
		["lab_construction"] = getTickerData(sector + sectorData.tickers.lab_construction),
		["factory_construction"] = getTickerData(sector + sectorData.tickers.factory_construction),
		["breed"] = getTickerData(sector + sectorData.tickers.breed),
		["research"] = getTickerData(sector + sectorData.tickers.research),
		["factory"] = getTickerData(sector + sectorData.tickers.factory),
		["element1"] = getTickerData(sector + sectorData.tickers.element1),
		["element2"] = getTickerData(sector + sectorData.tickers.element2),
		["element3"] = getTickerData(sector + sectorData.tickers.element3),
		["element4"] = getTickerData(sector + sectorData.tickers.element4),
	};

	data.population = mainmemory.read_u16_be(sector + sectorData.population);
	data.epoch = mainmemory.read_u16_be(sector + sectorData.epoch);
	data.owner = mainmemory.read_u16_be(sector + sectorData.owner);

	data.research_type = mainmemory.read_u16_be(sector + sectorData.research_type);
	data.research_index = mainmemory.read_u16_be(sector + sectorData.research_index);

	data.recipes = {
		["shield"] = getRecipeData(sector, sectorData.recipe_base_shield, 0),
		["defense"] = getRecipeData(sector, sectorData.recipe_base_defense, 1),
		["weapon"] = getRecipeData(sector, sectorData.recipe_base_weapon, 2),
	};

	data.factory_quantity = mainmemory.read_u16_be(sector + sectorData.factory_quantity);

	data.tower_health = mainmemory.read_u16_be(sector + sectorData.tower_health);
	data.max_tower_health = maxTowerHealth[data.epoch];
	data.mine_health = mainmemory.read_u16_be(sector + sectorData.mine_health);
	data.lab_health = mainmemory.read_u16_be(sector + sectorData.lab_health);
	data.factory_health = mainmemory.read_u16_be(sector + sectorData.factory_health);

	data.element1 = getElementData(sector, sectorData.element1_index);
	data.element2 = getElementData(sector, sectorData.element2_index);
	data.element3 = getElementData(sector, sectorData.element3_index);
	data.element4 = getElementData(sector, sectorData.element4_index);

	data.army = {
		["scarlet"] = getArmyData(sector, sectorData.army_bases.scarlet, sectorData.army_totals.scarlet),
		["caesar"] = getArmyData(sector, sectorData.army_bases.caesar, sectorData.army_totals.caesar),
		["oberon"] = getArmyData(sector, sectorData.army_bases.oberon, sectorData.army_totals.oberon),
		["madcap"] = getArmyData(sector, sectorData.army_bases.madcap, sectorData.army_totals.madcap),
	};

	data.status = mainmemory.read_u16_be(sector + sectorData.status);

	return data;
end

function printSectorData(sector)
	rPrint(getSectorData(sector), 10000);
end

function getArmyString(data)
	local armyString = "armies: ";
	armyString = armyString..data.army.scarlet.total..",";
	armyString = armyString..data.army.caesar.total..",";
	armyString = armyString..data.army.oberon.total..",";
	armyString = armyString..data.army.madcap.total;
	return armyString;
end

local CPressed = false;
local VPressed = false;
function draw_OSD()
	local row = 0;

	local input_table = input.get();
	if input_table["C"] and not CPressed then
		CPressed = true;
		toggleDisplayMode();
	elseif not input_table["C"] then
		CPressed = false;
	end

	if input_table["V"] and not VPressed then
		VPressed = true;
		toggleDisplayEmptySectors();
	elseif not input_table["V"] then
		VPressed = false;
	end

	if displayModes[currentDisplayMode] == "Off" then
		return;
	end

	gui.text(OSDPosition[1], OSDPosition[2] + row * OSDRowHeight, "Mode: "..displayModes[currentDisplayMode], nil, "bottomright");
	row = row + 1;

	for i = numSectors, 1, -1 do
		local sector = sectorBase + (i - 1) * sectorSize;
		local data = getSectorData(sector);
		--if data.tower_health > 0 and data.owner < 4 then
		if data.status ~= 0x0000 then
			if displayEmptySectors or data.owner < 4 then
				gui.text(OSDPosition[1], OSDPosition[2] + row * OSDRowHeight, toHexString(sector), characterColors[data.owner], "bottomright");
				local rowString = "";

				if displayModes[currentDisplayMode] == "General" then
					rowString = rowString..getArmyString(data).." ";
					rowString = rowString.."pop: "..data.population.." ";
					rowString = rowString..getResearchString(data).." ";
					rowString = rowString..data.tower_health.."/"..data.max_tower_health.."HP ";
					--rowString = rowString.."owner: "..data.owner.." ";
					--rowString = rowString.."status: "..toHexString(data.status, 4, "").." ";
					rowString = rowString..epochs[data.epoch].." ";
				end

				if displayModes[currentDisplayMode] == "Element" then
					rowString = rowString..data.element1.name..": "..data.element1.total.." ";
					rowString = rowString..data.element2.name..": "..data.element2.total.." ";
					rowString = rowString..data.element3.name..": "..data.element3.total.." ";
					rowString = rowString..data.element4.name..": "..data.element4.total.." ";

					--rowString = rowString..data.element1.name..": r: "..data.element1.remaining.." q: "..data.element1.quantity.." ";
					--rowString = rowString..data.element2.name..": r: "..data.element2.remaining.." q: "..data.element2.quantity.." ";
					--rowString = rowString..data.element3.name..": r: "..data.element3.remaining.." q: "..data.element3.quantity.." ";
					--rowString = rowString..data.element4.name..": r: "..data.element4.remaining.." q: "..data.element4.quantity.." ";
				end

				rowString = rowString..(i - 1);

				gui.text(OSDPosition[1] + 7 * OSDCharacterWidth, OSDPosition[2] + row * OSDRowHeight, rowString, nil, "bottomright");
				row = row + 1;
			end
		end
	end
end

function dump()
	for i = 1, numSectors do
		local sector = sectorBase + (i - 1) * sectorSize;
		local data = getSectorData(sector);
		if data.status ~= 0x0000 then
			local rowString = toHexString(sector).." ";
			rowString = rowString..(i - 1).." ";

			rowString = rowString..data.element1.name..": "..data.element1.total.." ";
			rowString = rowString..data.element2.name..": "..data.element2.total.." ";
			rowString = rowString..data.element3.name..": "..data.element3.total.." ";
			rowString = rowString..data.element4.name..": "..data.element4.total.." ";

			print(rowString);
		end
	end
end

function buildAll()
	local character = mainmemory.read_u16_be(0xB364)
	for i = 1, numSectors do
		local sector = sectorBase + (i - 1) * sectorSize;
		local data = getSectorData(sector);
		if data.owner == 4 then
			mainmemory.write_u16_be(sector + sectorData.owner, character);
		end
	end
end

function infiniteMen()
	local character = mainmemory.read_u16_be(0xB364);
	for i = 1, numSectors do
		local sector = sectorBase + (i - 1) * sectorSize;
		local data = getSectorData(sector);
		if data.owner == character then
			mainmemory.write_u16_be(sector + sectorData.population, 419);
		end
	end
end
--event.onframestart(infiniteMen);

event.onframestart(draw_OSD);