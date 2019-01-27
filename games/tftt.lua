if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		pop_available = 0x156E,
		pop_allocated = 0xB602,
		island = 0x1588, -- s16_be
		epoch = 0x1590, -- s16_be
		opponents = 0xA760, -- byte, bitfield
		password_cursor_index = 0x1574,
		password_string = 0xABD8,
		character = 0xB364,
		cursorX = 0xB410,
		cursorY = 0xB412,
		cursor_is_moving = 0xFBC6,
		ticker_held = 0xB394,
		ticker_speed = 0xB396,
		tick_timer = 0xA730,
		RNG = 0xB50E,
		selectedSectorPointer = 0xB5B4,
		suspended_men = {
			scarlet = 0xB604, -- u16_be, it appears to be divided by 10 until it crosses over 0x8000
			caesar = 0xB606, -- u16_be, it appears to be divided by 10 until it crosses over 0x8000
			oberon = 0xB608, -- u16_be, it appears to be divided by 10 until it crosses over 0x8000
			madcap = 0xB60A, -- u16_be, it appears to be divided by 10 until it crosses over 0x8000
		},
	},
	maps = {
		"1-1 Aloha",
		"1-2 Bazooka",
		"1-3 Cilla",
		"2-1 Dracula",
		"2-2 Etcetra",
		"2-3 Formica",
		"3-1 Gazza",
		"3-2 Hernia",
		"3-3 Ibiza",
		"4-1 Junta",
		"4-2 Karma",
		"4-3 Lada",
		"5-1 Mascara",
		"5-2 Nausea",
		"5-3 Ocarina",
		"6-1 Pyjama",
		"6-2 Quota",
		"6-3 Rumbaba",
		"7-1 Sinatra",
		"7-2 Tapioca",
		"7-3 Utopia",
		"8-1 Vespa",
		"8-2 Wonka",
		"8-3 Xtra",
		"9-1 Yoga",
		"9-2 Zappa",
		"9-3 Ohm",
		"10-1 Megalomania",
	},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.setMap(value)
	mainmemory.write_s16_be(Game.Memory.island, value - 1);
	mainmemory.write_s16_be(Game.Memory.epoch, math.floor((value - 1) / 3));
end

function Game.getXPosition()
	return mainmemory.read_u16_be(Game.Memory.cursorX);
end

function Game.getYPosition()
	return mainmemory.read_u16_be(Game.Memory.cursorY);
end

function Game.setXPosition(value)
	mainmemory.write_u16_be(Game.Memory.cursorX, value);
end

function Game.setYPosition(value)
	mainmemory.write_u16_be(Game.Memory.cursorY, value);
end

function Game.isCursorMoving()
	return mainmemory.read_u16_be(Game.Memory.cursor_is_moving) ~= 0x0000;
end

function Game.colorCursorIsMoving()
	if Game.isCursorMoving() then
		return colors.red;
	end
	return colors.green;
end

local displayModes = {
	"General",
	"Element",
	"Off",
};
local currentDisplayMode = 1;

local function toggleDisplayMode()
	currentDisplayMode = currentDisplayMode + 1;
	if currentDisplayMode > #displayModes then
		currentDisplayMode = 1;
	end
end

local displayEmptySectors = true;
local function toggleDisplayEmptySectors()
	displayEmptySectors = not displayEmptySectors;
end

local sectorBase = 0xB6C4;
local sectorSize = 0x44A;
local numSectors = 16;

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

local function getResearchString(data)
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
	ticker = {
		pop = 0x00, -- u16_be
		ticker = 0x08, -- 12.4 fixed point (u16_be / 16)
		pop_scaled = 0x0A, -- u16_be
	},
	tickers = {
		tower_construction = {
			scarlet = 0x10,
			caesar = 0x28,
			oberon = 0x40,
			madcap = 0x58,
		},
		mine_construction = 0x70,
		lab_construction = 0x88,
		factory_construction = 0xA0,
		breed = 0xB2,
		research = 0xC4,
		factory = 0xD8,
		element1 = 0x134,
		element2 = 0x144,
		element3 = 0x154,
		element4 = 0x164,
	},
	element1_index = 0x140, -- s16_be
	element2_index = 0x150, -- s16_be
	element3_index = 0x160, -- s16_be
	element4_index = 0x170, -- s16_be
	element_total_array = 0x174, -- 0x13 entries
	research_type = 0xBE, -- s16_be
	research_index = 0xC0, -- u16_be
	factory_quantity = 0xD6, -- u16_be, 0x00 = infinite
	recipe_base_shield = 0x1AC, -- Array of recipes, 10 elements, 0x0A each
	recipe_base_defense = 0x200, -- Array of recipes, 10 elements, 0x0A each
	recipe_base_weapon = 0x264, -- Array of recipes, 10 elements, 0x0A each
	army_bases = {
		scarlet = 0x2C8,
		caesar = 0x2D3,
		oberon = 0x2DE,
		madcap = 0x2E9,
	},
	army = { -- Size 0x0B
		rocks = 0x00, -- u8
		catapaults = 0x01, -- u8
		pikes = 0x02, -- u8
		longbows = 0x03, -- u8
		giant_catapaults = 0x04, -- u8
		cannons = 0x05, -- u8
		--["?"] = 0x06, -- u8 -- TODO
		planes = 0x07, -- u8
		jets = 0x08, -- u8
		UFOs = 0x09, -- u8
		unarmed = 0x0A, -- u8
	},
	army_totals = {
		scarlet = 0x2F4, -- u16_be
		caesar = 0x2F6, -- u16_be
		oberon = 0x2F8, -- u16_be
		madcap = 0x2FA, -- u16_be
	},
	defenses = 0x3B8, -- Array, 10 bytes, TTTTMMLFFF
	tower_health = 0x3D6, -- u16_be
	mine_health = 0x3D8, -- u16_be
	lab_health = 0x3DA, -- u16_be
	factory_health = 0x3DC, -- u16_be
	owner = 0x3FE, -- u16_be
	population = 0x406, -- u16_be
	epoch = 0x418, -- u16_be
	status = 0x448, -- u16_be (0x0000 unusable, 0x8000 normal, 0x9000 2001AD?, 0xB000 shut down, 0x4000 nuked)
};

local OSDPosition = {2, 2};
local OSDRowHeight = 16;
local OSDCharacterWidth = 10;

local emptyArmy = {
	rocks = 0,
	catapaults = 0,
	pikes = 0,
	longbows = 0,
	giant_catapaults = 0,
	cannons = 0,
	-- TODO
	planes = 0,
	jets = 0,
	UFOs = 0,
	unarmed = 0,
	total = 0,
};

local function getArmyData(sector, army, total)
	total = mainmemory.read_u16_be(sector + total);
	if total > 0 then
		army = sector + army;
		return {
			rocks = mainmemory.read_u8(army + sectorData.army.rocks),
			catapaults = mainmemory.read_u8(army + sectorData.army.catapaults),
			pikes = mainmemory.read_u8(army + sectorData.army.pikes),
			longbows = mainmemory.read_u8(army + sectorData.army.longbows),
			giant_catapaults = mainmemory.read_u8(army + sectorData.army.giant_catapaults),
			cannons = mainmemory.read_u8(army + sectorData.army.cannons),
			-- TODO
			planes = mainmemory.read_u8(army + sectorData.army.planes),
			jets = mainmemory.read_u8(army + sectorData.army.jets),
			UFOs = mainmemory.read_u8(army + sectorData.army.UFOs),
			unarmed = mainmemory.read_u8(army + sectorData.army.unarmed),
			total = total,
		};
	else
		return emptyArmy;
	end
end

function clearArmyData(sector, army, total)
	totalValue = mainmemory.read_u16_be(sector + total);
	if totalValue > 0 then
		army = sector + army;
		mainmemory.write_u8(army + sectorData.army.rocks, 0);
		mainmemory.write_u8(army + sectorData.army.catapaults, 0);
		mainmemory.write_u8(army + sectorData.army.pikes, 0);
		mainmemory.write_u8(army + sectorData.army.longbows, 0);
		mainmemory.write_u8(army + sectorData.army.giant_catapaults, 0);
		mainmemory.write_u8(army + sectorData.army.cannons, 0);
		-- TODO
		mainmemory.write_u8(army + sectorData.army.planes, 0);
		mainmemory.write_u8(army + sectorData.army.jets, 0);
		mainmemory.write_u8(army + sectorData.army.UFOs, 0);
		mainmemory.write_u8(army + sectorData.army.unarmed, 0);
		mainmemory.write_u16_be(sector + total, 0);
	end
end

local function getTickerData(ticker)
	return {
		pop = mainmemory.read_u16_be(ticker + sectorData.ticker.pop),
		ticker = mainmemory.read_u16_be(ticker + sectorData.ticker.ticker) / 16,
		pop_scaled = mainmemory.read_u16_be(ticker + sectorData.ticker.pop_scaled),
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

local function getRecipeData(sector, recipeArrayBase, recipeType)
	local recipeData = {};
	for i = 0, 9 do
		local recipe = {};
		local recipeBase = sector + recipeArrayBase + i * 10;
		for elementIndex = 0, 4 do
			local elementData = {
				element = mainmemory.readbyte(recipeBase + elementIndex * 2),
				quantity = mainmemory.readbyte(recipeBase + elementIndex * 2 + 1) / 2,
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

local function getElementData(sector, indexOffset)
	local elementIndex = mainmemory.read_s16_be(sector + indexOffset);
	local elementData = {
		index = elementIndex,
		name = "None",
		quantity = 0,
		remaining = 0,
		total = 0,
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

function isUsable(sector)
	local status = mainmemory.read_u16_be(sector + sectorData.status);
	return status == 0x8000 or status == 0x9000 or status == 0xB000;
end

local function getSectorData(sector)
	local data = {};

	data.status = mainmemory.read_u16_be(sector + sectorData.status);

	if not displayEmptySectors and not isUsable(sector) then -- Speedup: Don't get data for unusable or nuked sectors
		return data;
	end

	data.tickers = {
		tower_construction = {
			scarlet = getTickerData(sector + sectorData.tickers.tower_construction.scarlet),
			caesar = getTickerData(sector + sectorData.tickers.tower_construction.caesar),
			oberon = getTickerData(sector + sectorData.tickers.tower_construction.oberon),
			madcap = getTickerData(sector + sectorData.tickers.tower_construction.madcap),
		},
		mine_construction = getTickerData(sector + sectorData.tickers.mine_construction),
		lab_construction = getTickerData(sector + sectorData.tickers.lab_construction),
		factory_construction = getTickerData(sector + sectorData.tickers.factory_construction),
		breed = getTickerData(sector + sectorData.tickers.breed),
		research = getTickerData(sector + sectorData.tickers.research),
		factory = getTickerData(sector + sectorData.tickers.factory),
		element1 = getTickerData(sector + sectorData.tickers.element1),
		element2 = getTickerData(sector + sectorData.tickers.element2),
		element3 = getTickerData(sector + sectorData.tickers.element3),
		element4 = getTickerData(sector + sectorData.tickers.element4),
	};

	data.population = mainmemory.read_u16_be(sector + sectorData.population);
	data.epoch = mainmemory.read_u16_be(sector + sectorData.epoch);
	data.owner = mainmemory.read_u16_be(sector + sectorData.owner);

	data.research_type = mainmemory.read_u16_be(sector + sectorData.research_type);
	data.research_index = mainmemory.read_u16_be(sector + sectorData.research_index);

	data.recipes = {
		shield = getRecipeData(sector, sectorData.recipe_base_shield, 0),
		defense = getRecipeData(sector, sectorData.recipe_base_defense, 1),
		weapon = getRecipeData(sector, sectorData.recipe_base_weapon, 2),
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
		scarlet = getArmyData(sector, sectorData.army_bases.scarlet, sectorData.army_totals.scarlet),
		caesar = getArmyData(sector, sectorData.army_bases.caesar, sectorData.army_totals.caesar),
		oberon = getArmyData(sector, sectorData.army_bases.oberon, sectorData.army_totals.oberon),
		madcap = getArmyData(sector, sectorData.army_bases.madcap, sectorData.army_totals.madcap),
	};

	return data;
end

function printSectorData(sector)
	rPrint(getSectorData(sector), 10000);
end

local function getArmyString(data)
	local armyString = "armies: ";
	armyString = armyString..data.army.scarlet.total..",";
	armyString = armyString..data.army.caesar.total..",";
	armyString = armyString..data.army.oberon.total..",";
	armyString = armyString..data.army.madcap.total;
	return armyString;
end

ScriptHawk.bindKeyRealtime("C", toggleDisplayMode, true);
ScriptHawk.bindKeyRealtime("V", toggleDisplayEmptySectors, true);

function Game.drawUI()
	local row = 0;

	if displayModes[currentDisplayMode] == "Off" then
		return;
	end

	gui.text(OSDPosition[1], OSDPosition[2] + row * OSDRowHeight, "Mode: "..displayModes[currentDisplayMode], nil, "bottomright");
	row = row + 1;

	for i = numSectors, 1, -1 do
		local sector = sectorBase + (i - 1) * sectorSize;
		local data = getSectorData(sector);
		if isUsable(sector) then
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
		if isUsable(sector) then
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

function Game.buildAll()
	local you = mainmemory.read_u16_be(Game.Memory.character);
	for i = 1, numSectors do
		local sector = sectorBase + (i - 1) * sectorSize;
		local owner = mainmemory.read_u16_be(sector + sectorData.owner);
		if owner == 4 then
			mainmemory.write_u16_be(sector + sectorData.owner, you);
		end
	end
end

function Game.applyInfinites()
	local you = mainmemory.read_u16_be(Game.Memory.character);
	for i = 1, numSectors do
		local sector = sectorBase + (i - 1) * sectorSize;
		local owner = mainmemory.read_u16_be(sector + sectorData.owner);
		if owner == you then
			mainmemory.write_u16_be(sector + sectorData.population, 419);
		end
	end
end

function Game.setPassword(password)
	writeNullTerminatedString(Game.Memory.password_string, password);
	mainmemory.write_u16_be(Game.Memory.password_cursor_index, 0x0B);
end

function Game.getTickerSpeed()
	if mainmemory.readbyte(Game.Memory.ticker_speed) == 0x01 then
		if mainmemory.readbyte(Game.Memory.ticker_speed + 1) == 0x01 then
			return 2;
		end
		return 1;
	end
	return 0;
end

function Game.getTickerHeld()
	return mainmemory.read_u16_be(Game.Memory.ticker_held);
end

function Game.getRNG()
	return mainmemory.read_u16_be(Game.Memory.RNG);
end

function Game.getPopAllocated()
	return mainmemory.read_u16_be(Game.Memory.pop_allocated);
end

function Game.getPopAvailable()
	return mainmemory.read_u16_be(Game.Memory.pop_available);
end

function Game.getPopAllocatedOSD()
	local allocated = Game.getPopAllocated();
	local available = allocated + Game.getPopAvailable();
	return allocated.."/"..available;
end

function Game.getOpponents()
	return toBinaryString(mainmemory.readbyte(Game.Memory.opponents), 4);
end

function Game.getTickTimer()
	return mainmemory.read_u16_be(Game.Memory.tick_timer);
end

function readSuspendedMen(address)
	local value = mainmemory.read_u16_be(address);
	if value < 0x8000 then
		return math.floor(value / 10);
	end
	return value;
end

function Game.getSuspendedMen()
	local scarlet = readSuspendedMen(Game.Memory.suspended_men.scarlet);
	local caesar = readSuspendedMen(Game.Memory.suspended_men.caesar);
	local oberon = readSuspendedMen(Game.Memory.suspended_men.oberon);
	local madcap = readSuspendedMen(Game.Memory.suspended_men.madcap);
	return scarlet..","..caesar..","..oberon..","..madcap;
end

function Game.eachFrame()
	if ScriptHawk.UI.ischecked("mouse_control") then
		-- Make game cursor follow real cursor
		local mousePos = input.getmouse();
		if mousePos.X >= 0 and mousePos.X <= ScriptHawk.bufferWidth and mousePos.Y >= 0 and mousePos.Y <= ScriptHawk.bufferHeight then
			Game.setXPosition(mousePos.X * 2);
			Game.setYPosition((mousePos.Y * 2) - 40); -- Minus 40 pixels to compensate for Overscan

			if mousePos.Left then
				joypad.set({B = true}, 1);
			end
			if mousePos.Right then
				joypad.set({C = true}, 1);
			end
		end
	end

	if ScriptHawk.UI.ischecked("sandbox_mode") then
		local you = mainmemory.read_u16_be(Game.Memory.character);
		for i = numSectors, 1, -1 do
			local sector = sectorBase + (i - 1) * sectorSize;
			if isUsable(sector) then
				local owner = mainmemory.read_u16_be(sector + sectorData.owner);
				if owner ~= you then
					mainmemory.write_u16_be(sector + sectorData.population, 0);
				end
				if you ~= 0 then
					clearArmyData(sector, sectorData.army_bases.scarlet, sectorData.army_totals.scarlet);
				end
				if you ~= 1 then
					clearArmyData(sector, sectorData.army_bases.caesar, sectorData.army_totals.caesar);
				end
				if you ~= 2 then
					clearArmyData(sector, sectorData.army_bases.oberon, sectorData.army_totals.oberon);
				end
				if you ~= 3 then
					clearArmyData(sector, sectorData.army_bases.madcap, sectorData.army_totals.madcap);
				end
			end
		end
	end
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.button(10, 4, {4, 10}, nil, nil, "Build All", Game.buildAll);
		ScriptHawk.UI.checkbox(0, 6, "mouse_control", "Mouse Control");
		ScriptHawk.UI.checkbox(0, 7, "sandbox_mode", "Sandbox Mode");
	end
end

Game.OSD = {
	{"X", nil, Game.colorCursorIsMoving, category="position"},
	{"Y", nil, Game.colorCursorIsMoving, category="position"},
	{"dX", nil, category="positionStats"},
	{"dY", nil, category="positionStats"},
	{"Ticker Speed", Game.getTickerSpeed, category="ticker"},
	{"Ticker Held", Game.getTickerHeld, category="ticker"},
	{"Tick Timer", Game.getTickTimer, category="ticker"},
	{"RNG", hexifyOSD(Game.getRNG, 4, ""), category="rng"},
	{"Opponents", Game.getOpponents, category="opponents"},
	{"Pop Available", Game.getPopAvailable, category="popAvailable"},
	{"Pop Allocated", Game.getPopAllocatedOSD, category="popAllocated"},
	{"Suspended Men", Game.getSuspendedMen, category="suspendedMen"},
};

return Game;