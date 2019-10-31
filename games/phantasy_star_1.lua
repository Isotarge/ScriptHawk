if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	characters = {
		"Alis",
		"Myau",
		"Odin",
		"Noah",
	},
	Memory = { -- 1 version for now, not sure if addresses are different in others
		mode = 0x202,
		RNG = 0x20C, -- 2 bytes, code at 5B1 ROM
		options_menu_open = 0x268, -- Hide dungeon minimap if non zero
		interaction_type = 0x29E,
		textbox_open = 0x2D3, -- Not sure if this is exactly right, but we'll hide dungeon minimap if it's non zero
		dungeon_layout = 0xB00,
		-- 0 = up
		-- 1 = right
		-- 2 = down
		-- 3 = left
		dungeon_direction = 0x30A,
		dungeon_position = 0x30C,
		dungeon_index = 0x30D,
		stats = {
			Alis = 0x0400, -- see Game.stats
			Myau = 0x0410, -- see Game.stats
			Odin = 0x0420, -- see Game.stats
			Noah = 0x0430, -- see Game.stats
		},
		inventory = 0x4C0,
		current_money = 0x4E0, -- u16_le
		max_items = 24,
		inventory_current_num = 0x4E2,
		party_current_num = 0x4F0, -- starts from 0
		level_table = { -- ROM, Bank 3
			Alis = 0xF8AF,
			Myau = 0xF99F,
			Odin = 0xFA8F,
			Noah = 0xFB7F,
		},
		dungeon_object_base = 0xEF5C, -- ROM, Bank 3
	},
	modes = {
		[0x00] = "Init Intro",
		[0x01] = "Init Intro",
		[0x02] = "Load Intro",
		[0x03] = "Intro",
		[0x04] = "Loading Ship", -- Between Planets, A5C ROM
		[0x05] = "On Ship", -- Between Planets, 86F ROM
		[0x06] = "LABEL_B07", -- Unknown
		[0x07] = "LABEL_B07", -- Unknown
		[0x08] = "Load Map",
		[0x09] = "Map",
		[0x0A] = "Load Dungeon",
		[0x0B] = "Dungeon",
		[0x0C] = "Load Interaction",
		[0x0D] = "Interaction",
		[0x0E] = "Loading Road", -- Between Towns, ED7 ROM
		[0x0F] = "On Road", -- Between Towns, E8B ROM
		[0x10] = "Load Name Input",
		[0x11] = "Name Input",
		[0x12] = "LABEL_467C", -- Unknown
		[0x13] = "LABEL_467C", -- Unknown
	},
	items = {
		[0x00] = "Nothing",
		[0x01] = "Wood Cane",
		[0x02] = "Short Sword",
		[0x03] = "Iron Sword",
		[0x04] = "Wand",
		[0x05] = "Iron Fang",
		[0x06] = "Iron Axe",
		[0x07] = "Titanium Sword",
		[0x08] = "Ceramic Sword",
		[0x09] = "Needle Gun",
		[0x0A] = "Silver Fang",
		[0x0B] = "Heat Gun",
		[0x0C] = "Light Saber",
		[0x0D] = "Laser Gun",
		[0x0E] = "Laconia Sword",
		[0x0F] = "Laconia Axe",
		[0x10] = "Leather Armor",
		[0x11] = "White Mantle",
		[0x12] = "Light Suit",
		[0x13] = "Iron Armor",
		[0x14] = "Thick Fur",
		[0x15] = "Zirconia Armor",
		[0x16] = "Diamond Armor",
		[0x17] = "Laconia Armor",
		[0x18] = "Frade Mantle",
		[0x19] = "Leather Shield",
		[0x1A] = "Bronze Shield",
		[0x1B] = "Iron Shield",
		[0x1C] = "Ceramic Shield",
		[0x1D] = "Gloves",
		[0x1E] = "Laser Shield",
		[0x1F] = "Mirror Shield",
		[0x20] = "Laconia Shield",
		[0x21] = "Landrover",
		[0x22] = "Hovercraft",
		[0x23] = "Ice Digger",
		[0x24] = "Cola",
		[0x25] = "Burger",
		[0x26] = "Flute",
		[0x27] = "Flash",
		[0x28] = "Escaper",
		[0x29] = "Transfer",
		[0x2A] = "Magic Hat",
		[0x2B] = "Alsulin",
		[0x2C] = "Polymaterial",
		[0x2D] = "Dungeon Key",
		[0x2E] = "Sphere",
		[0x2F] = "Eclipse Torch",
		[0x30] = "Aero Prism",
		[0x31] = "Nuts",
		[0x32] = "Hapsby",
		[0x33] = "Road Pass",
		[0x34] = "Passport",
		[0x35] = "Compass",
		[0x36] = "Cake",
		[0x37] = "Letter",
		[0x38] = "Laconia Pot",
		[0x39] = "Magic Lamp",
		[0x3A] = "Amber Eye",
		[0x3B] = "Gas Shield",
		[0x3C] = "Crystal",
		[0x3D] = "Master System",
		[0x3E] = "Miracle Key",
		[0x3F] = "Zillion",
		[0x40] = "Secrets",
	},
	enemies = {
		[0x00] = "Nothing",
		[0x01] = "Sworm",
		[0x02] = "GrSlime",
		[0x03] = "WingEye",
		[0x04] = "ManEater",
		[0x05] = "Scorpion",
		[0x06] = "GScorpi",
		[0x07] = "BlSlime",
		[0x08] = "NFarmer",
		[0x09] = "OwlBear",
		[0x0A] = "DeadTree",
		[0x0B] = "Scorpius",
		[0x0C] = "EFarmer",
		[0x0D] = "GiantFly",
		[0x0E] = "Crawler",
		[0x0F] = "Barbrian",
		[0x10] = "GoldLens",
		[0x11] = "RdSlime",
		[0x12] = "WereBat",
		[0x13] = "BigClub",
		[0x14] = "Fishman",
		[0x15] = "EvilDead",
		[0x16] = "Tarantul",
		[0x17] = "Manticor",
		[0x18] = "Skeleton",
		[0x19] = "AntLion",
		[0x1A] = "Marman",
		[0x1B] = "Dezorian",
		[0x1C] = "Leech",
		[0x1D] = "Vampire",
		[0x1E] = "Elephant",
		[0x1F] = "Ghoul",
		[0x20] = "Shelfish",
		[0x21] = "Executer",
		[0x22] = "Wight",
		[0x23] = "SkullEn",
		[0x24] = "Ammonite",
		[0x25] = "Sphinx",
		[0x26] = "Serpent",
		[0x27] = "Sandworm",
		[0x28] = "Lich",
		[0x29] = "Octopus",
		[0x2A] = "Stalker",
		[0x2B] = "EvilHead",
		[0x2C] = "Zombie",
		[0x2D] = "Batalion",
		[0x2E] = "RobotCop",
		[0x2F] = "Sorcerer",
		[0x30] = "Nessie",
		[0x31] = "Tarzimal",
		[0x32] = "Golem",
		[0x33] = "AndroCop",
		[0x34] = "Tentacle",
		[0x35] = "Giant",
		[0x36] = "Wyvern",
		[0x37] = "Reaper",
		[0x38] = "Magician",
		[0x39] = "Horseman",
		[0x3A] = "Frostman",
		[0x3B] = "Amundsen",
		[0x3C] = "RdDragn",
		[0x3D] = "GrDragn",
		[0x3E] = "Shadow",
		[0x3F] = "Mammoth",
		[0x40] = "Centaur",
		[0x41] = "Marauder",
		[0x42] = "Titan",
		[0x43] = "Medusa",
		[0x44] = "WtDragn",
		[0x45] = "BlDragn",
		[0x46] = "GdDragn",
		[0x47] = "DrMad",
		[0x48] = "Lassic",
		[0x49] = "DarkFalz",
		[0x4A] = "Saccubus",
	},
	stats = {
		status = 0x00, -- byte
		current_hp = 0x01, -- byte
		current_mp = 0x02, -- byte
		exp = 0x03, -- word
		level = 0x05, -- byte
		max_hp = 0x06, -- byte
		max_mp = 0x07, -- byte
		attack = 0x08, -- byte
		defense = 0x09, -- byte
		weapon = 0x0A, -- byte
		armor = 0x0B, -- byte
		shield = 0x0C, -- byte
		battle_magic_num = 0x0E, -- byte
		map_magic_num = 0x0F, -- byte
	},
};

function Game.getItemName(index)
	if Game.items[index] ~= nil then
		return Game.items[index];
	end
	return "Unknown Item "..toHexString(index);
end

function Game.getItemIndex(itemName)
	for k, v in pairs(Game.items) do
		if v == itemName then
			return k;
		end
	end
	return 0;
end

function Game.getStats(address)
	local stats = {
		status = mainmemory.readbyte(address + Game.stats.status),
		current_hp = mainmemory.readbyte(address + Game.stats.current_hp),
		current_mp = mainmemory.readbyte(address + Game.stats.current_mp),
		exp = mainmemory.read_u16_le(address + Game.stats.exp),
		level = mainmemory.readbyte(address + Game.stats.level),
		max_hp = mainmemory.readbyte(address + Game.stats.max_hp),
		max_mp = mainmemory.readbyte(address + Game.stats.max_mp),
		attack = mainmemory.readbyte(address + Game.stats.attack),
		defense = mainmemory.readbyte(address + Game.stats.defense),
		weapon = mainmemory.readbyte(address + Game.stats.weapon),
		armor = mainmemory.readbyte(address + Game.stats.armor),
		shield = mainmemory.readbyte(address + Game.stats.shield),
		battle_magic_num = mainmemory.readbyte(address + Game.stats.battle_magic_num),
		map_magic_num = mainmemory.readbyte(address + Game.stats.map_magic_num),
	};

	-- Get names of equipped items
	stats.weapon_name = Game.getItemName(stats.weapon);
	stats.armor_name = Game.getItemName(stats.armor);
	stats.shield_name = Game.getItemName(stats.shield);

	return stats;
end

function Game.giveItem(item)
	-- Convert name to index
	if type(item) == "string" then
		item = Game.getItemIndex(item);
	end
	-- Make sure it's a valid item
	if Game.items[item] ~= nil and item ~= 0 then
		for i = 0, Game.Memory.max_items - 1 do
			-- Find free slot
			if mainmemory.readbyte(Game.Memory.inventory + i) == 0 then
				-- Add the item to the inventory
				mainmemory.writebyte(Game.Memory.inventory + i, item);
				mainmemory.writebyte(Game.Memory.inventory_current_num, mainmemory.readbyte(Game.Memory.inventory_current_num) + 1);
				return;
			end
		end
		print("Inventory is full.");
		return;
	end
	print("Invalid item specified.");
end

local function giveItemFromDropdown()
	Game.giveItem(forms.getproperty(ScriptHawk.UI.form_controls.item_dropdown, "SelectedItem"));
end

function Game.setLevel(name, level)
	if Game.Memory.level_table[name] == nil or Game.Memory.stats[name] == nil then
		print("Invalid character name");
		return;
	end
	if type(level) ~= "number" then
		print("Level is not number");
		return;
	end
	-- Clamp level between 0 and 30
	level = math.min(math.max(math.floor(level), 1), 30) - 1;

	-- Read correct level stats from ROM
	local tableStart = Game.Memory.level_table[name] + level * 8;

	local maxHP = memory.readbyte(tableStart + 0x00, "ROM");
	local attack = memory.readbyte(tableStart + 0x01, "ROM");
	local defense = memory.readbyte(tableStart + 0x02, "ROM");
	local maxMP = memory.readbyte(tableStart + 0x03, "ROM");
	local exp = memory.read_u16_le(tableStart + 0x04, "ROM");
	local battleMagicNum = memory.readbyte(tableStart + 0x06, "ROM");
	local mapMagicNum = memory.readbyte(tableStart + 0x07, "ROM");

	-- Write correct level stats to RAM
	local statBase = Game.Memory.stats[name];
	mainmemory.writebyte(statBase + Game.stats.level, level + 1);

	mainmemory.writebyte(statBase + Game.stats.max_hp, maxHP);
	mainmemory.writebyte(statBase + Game.stats.attack, attack);
	mainmemory.writebyte(statBase + Game.stats.defense, defense);
	mainmemory.writebyte(statBase + Game.stats.max_mp, maxMP);
	mainmemory.write_u16_le(statBase + Game.stats.exp, exp);
	mainmemory.writebyte(statBase + Game.stats.battle_magic_num, battleMagicNum);
	mainmemory.writebyte(statBase + Game.stats.map_magic_num, mapMagicNum);

	-- Update current HP values because why not
	mainmemory.writebyte(statBase + Game.stats.status, 1); -- Make sure the character is unlocked
	mainmemory.writebyte(statBase + Game.stats.current_hp, maxHP);
	mainmemory.writebyte(statBase + Game.stats.current_mp, maxMP);
end

function Game.setAllLevels(level)
	for k, character in ipairs(Game.characters) do
		Game.setLevel(character, level);
	end
end

local function setLevelFromDropdown()
	Game.setLevel(forms.getproperty(ScriptHawk.UI.form_controls.character_dropdown, "SelectedItem"), tonumber(forms.getproperty(ScriptHawk.UI.form_controls.level_dropdown, "SelectedItem")));
end

function Game.unlockAllCharacters()
	mainmemory.writebyte(Game.Memory.party_current_num, 3);
	for k, character in ipairs(Game.characters) do
		mainmemory.writebyte(Game.Memory.stats[character] + Game.stats.status, 1);
	end
end

function dumpStats()
	for k, character in ipairs(Game.characters) do
		local stats = Game.getStats(Game.Memory.stats[character]);
		dprint(character..": ");
		for k, v in pairs(stats) do
			dprint(k..": "..v);
		end
	end
	print_deferred();
end

local tiles = {
	[0x00] = "Floor", -- "Empty"
	[0x01] = "Wall",
	[0x02] = "Floor Up",
	[0x03] = "Floor Down",
	[0x04] = "Door (Closed)",
	[0x84] = "Door (Open)",
	[0x05] = "Key Door",
	[0x06] = "Magically Locked Door",
	[0x07] = "Fake Wall",
	[0x08] = "Treasure/Trap",
	[0x0A] = "Exit Up",
	[0x0B] = "Exit Down",
	[0x0C] = "Exit Door",
	[0x0D] = "Exit Door (Locked)",
	[0x0E] = "Exit Door (Magical)",
};

function getTileName(tileValue)
	if tiles[tileValue] ~= nil then
		return tiles[tileValue];
	end
	return "Unknown "..toHexString(tileValue);
end

-- TODO: Adjust for yellow/blue dungeons
local floorColor = 0x55FF55;
local wallColor = 0x00AA55;
local itemColor = 0x5500AA;
local playerColor = 0xFFFF00;

local minimapAlpha = 0xFF000000;
local minimapScale = 5;

local function renderDungeonMinimap()
	local dungeonPosition = Game.getDungeonPosition();
	local dungeonDirection = Game.getDungeonDirection();
	local screenWidth = client.bufferwidth();
	local xOffset = screenWidth - 16 * minimapScale;
	local yOffset = 0;
	local mouse = input.getmouse();
	local mouseIsOnScreen = (mouse.X >= 0 and mouse.X < ScriptHawk.bufferWidth) and (mouse.Y >= 0 and mouse.Y < ScriptHawk.bufferHeight);
	local mouseOverTextToRender = false;
	local mouseOverIndex = nil;
	for y = 0, 15 do
		for x = 0, 15 do
			local tileIndex = (y * 16) + x;
			local tileAddress = Game.Memory.dungeon_layout + tileIndex;
			local tileValue = mainmemory.readbyte(tileAddress);
			local drawColor = 0x000000;
			if tileValue == 0x00 then -- Floor
				drawColor = floorColor;
			elseif tileValue == 0x01 then -- Wall
				drawColor = wallColor;
			elseif tileValue == 0x08 then
				drawColor = itemColor;
			end
			local drawX = xOffset + x * minimapScale;
			local drawY = yOffset + y * minimapScale;
			local xBottom = drawX + minimapScale - 1;
			local yBottom = drawY + minimapScale - 1;
			gui.drawRectangle(drawX, drawY, minimapScale, minimapScale, minimapAlpha + drawColor, minimapAlpha + drawColor);
			if tileIndex == dungeonPosition then
				local xCenter = drawX + minimapScale / 2;
				local yCenter = drawY + minimapScale / 2;
				if dungeonDirection == 0 then
					-- Up
					gui.drawLine(xCenter, drawY, drawX, yBottom, minimapAlpha + playerColor);
					gui.drawLine(xCenter, drawY, xBottom, yBottom, minimapAlpha + playerColor);
				elseif dungeonDirection == 1 then
					-- Right
					gui.drawLine(xBottom, yCenter, drawX, drawY, minimapAlpha + playerColor);
					gui.drawLine(xBottom, yCenter, drawX, yBottom, minimapAlpha + playerColor);
				elseif dungeonDirection == 2 then
					-- Down
					gui.drawLine(xCenter, yBottom, drawX, drawY, minimapAlpha + playerColor);
					gui.drawLine(xCenter, yBottom, xBottom, drawY, minimapAlpha + playerColor);
				elseif dungeonDirection == 3 then
					-- Left
					gui.drawLine(drawX, yCenter, xBottom, drawY, minimapAlpha + playerColor);
					gui.drawLine(drawX, yCenter, xBottom, yBottom, minimapAlpha + playerColor);
				else
					-- ?
				end
			end
			if mouseIsOnScreen and mouse.X >= drawX and mouse.X <= xBottom and mouse.Y >= drawY and mouse.Y <= yBottom then
				mouseOverIndex = tileIndex;
				if tileValue == 0x08 then
					mouseOverTextToRender = {drawX, drawY, {toHexString(tileValue)..": "..x..","..y}, colors.white, nil, false};
					local extraDetails = Game.getDungeonObjectMouseOverText(Game.getDungeonIndex(), x, y);
					for k, v in ipairs(extraDetails) do
						table.insert(mouseOverTextToRender[3], v);
					end
				else
					mouseOverTextToRender = {drawX, drawY, {toHexString(tileValue)..": "..x..","..y, getTileName(tileValue)}, colors.white, nil, false};
				end
			end
		end
	end
	if type(mouseOverTextToRender) == "table" then
		if mouse.Left then
			mainmemory.writebyte(Game.Memory.dungeon_position, mouseOverIndex);
		end
		ScriptHawk.drawText(mouseOverTextToRender[1], mouseOverTextToRender[2], mouseOverTextToRender[3], mouseOverTextToRender[4], mouseOverTextToRender[5], mouseOverTextToRender[6]);
	end
end

function Game.getMode()
	return mainmemory.readbyte(Game.Memory.mode);
end

function Game.getModeOSD()
	local mode = Game.getMode();
	if Game.modes[mode] ~= nil then
		return Game.modes[mode];
	end
	return "Unknown "..toHexString(mode);
end

function Game.eachFrame()
	Game.OSD = Game.standardOSD;
	if Game.getModeOSD() == "Dungeon" then
		Game.OSD = Game.dungeonOSD;
		if mainmemory.readbyte(Game.Memory.options_menu_open) == 0 and mainmemory.readbyte(Game.Memory.textbox_open) == 0 then
			renderDungeonMinimap();
		end
	end
end

function Game.getDungeonIndex()
	return mainmemory.readbyte(Game.Memory.dungeon_index);
end

function Game.getDungeonPosition()
	return mainmemory.readbyte(Game.Memory.dungeon_position);
end

function Game.getDungeonDirection()
	return mainmemory.readbyte(Game.Memory.dungeon_direction);
end

function Game.getMoney()
	return mainmemory.read_u16_le(Game.Memory.current_money);
end

function Game.applyInfinites()
	-- Set money
	mainmemory.write_u16_le(Game.Memory.current_money, 0xFFFF);

	-- Set HP & MP
	for k, character in ipairs(Game.characters) do
		mainmemory.writebyte(Game.Memory.stats[character] + Game.stats.current_hp, mainmemory.readbyte(Game.Memory.stats[character] + Game.stats.max_hp));
		mainmemory.writebyte(Game.Memory.stats[character] + Game.stats.current_mp, mainmemory.readbyte(Game.Memory.stats[character] + Game.stats.max_mp));
	end
end

-------------------
-- Dungeon Items --
-------------------

-- Lookup: dungeonObjects[dungeonID][x][y]
local dungeonObjects = {};
local dungeonObjectTypes = {
	[0] = "Item",
	[1] = "Meseta",
	[2] = "Battle",
	[3] = "Dialogue",
};

local function parseDungeonObjects()
	local index = 0;
	while 7 do
		local base = Game.Memory.dungeon_object_base + index * 7;
		local dungeonID = memory.readbyte(base + 0, "ROM");

		if dungeonID == 0xFF then
			break;
		end

		local coords = memory.readbyte(base + 1, "ROM");
		local xPos = bit.band(coords, 0x0F);
		local yPos = bit.rshift(bit.band(coords, 0xF0), 4);

		local entry = {
			flagAddress = memory.read_u16_le(base + 2, "ROM"),
			itemType = memory.readbyte(base + 4, "ROM"),
			specialByte1 = memory.readbyte(base + 5, "ROM"),
			specialByte2 = memory.readbyte(base + 6, "ROM"),
		};

		if not dungeonObjects[dungeonID] then
			dungeonObjects[dungeonID] = {};
		end
		if not dungeonObjects[dungeonID][xPos] then
			dungeonObjects[dungeonID][xPos] = {};
		end

		dungeonObjects[dungeonID][xPos][yPos] = entry;
		index = index + 1;
	end
end

function Game.getDungeonObjectMouseOverText(index, x, y)
	if dungeonObjects[index] and dungeonObjects[index][x] and dungeonObjects[index][x][y] then
		local entry = dungeonObjects[index][x][y];
		local flagValue = memory.readbyte(entry.flagAddress, "System Bus");
		local output = {
			"Flag: "..toHexString(entry.flagAddress).." ("..flagValue..")",
			"Type: "..dungeonObjectTypes[entry.itemType],
		};
		if entry.itemType == 0 then -- Item
			if entry.specialByte2 > 0 then
				table.insert(output, Game.items[entry.specialByte1].." TRAP!");
			else
				table.insert(output, Game.items[entry.specialByte1]);
			end
		elseif entry.itemType == 1 then -- Meseta
			table.insert(output, (entry.specialByte2 * 256 + entry.specialByte1).." Meseta");
		elseif entry.itemType == 2 then -- Battle
			table.insert(output, "Enemy: "..Game.enemies[entry.specialByte1]); -- TODO: Nil check
			table.insert(output, "Drops: "..Game.items[entry.specialByte2]); -- TODO: Nil check
		elseif entry.itemType == 3 then -- Dialogue
			table.insert(output, "ID "..toHexString(entry.specialByte1));
		end
		return output;
	else
		return {"Unknown"};
	end
end

function Game.initUI()
	parseDungeonObjects(); -- TODO: Move this somewhere more appropriate
	if not TASSafe then
		-- Dropdown and button to give items
		ScriptHawk.UI.form_controls.item_dropdown = forms.dropdown(ScriptHawk.UI.options_form, Game.items, ScriptHawk.UI.col(5) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 8, ScriptHawk.UI.button_height);
		ScriptHawk.UI.button(10, 6, {4, 8}, nil, nil, "Give Item", giveItemFromDropdown);

		-- Dropdowns and button to set character levels
		ScriptHawk.UI.form_controls.character_dropdown = forms.dropdown(ScriptHawk.UI.options_form, Game.characters, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 8, ScriptHawk.UI.button_height);
		local levels = {};
		for i = 1, 30 do
			if i > 9 then
				table.insert(levels, tostring(i));
			else
				table.insert(levels, "0"..tostring(i));
			end
		end
		ScriptHawk.UI.form_controls.level_dropdown = forms.dropdown(ScriptHawk.UI.options_form, levels, ScriptHawk.UI.col(5) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 8, ScriptHawk.UI.button_height);
		ScriptHawk.UI.button(10, 7, {4, 8}, nil, nil, "Set Level", setLevelFromDropdown);

		ScriptHawk.UI.button(10, 5, {4, 8}, nil, nil, "Unlock Characters", Game.unlockAllCharacters);
	end
end

Game.standardOSD = {
	{"Mode", Game.getModeOSD},
	{"Money", Game.getMoney},
};

Game.dungeonOSD = {
	{"Mode", Game.getModeOSD},
	{"Money", Game.getMoney},
	{"Dungeon Index", Game.getDungeonIndex},
	{"Dungeon Pos", hexifyOSD(Game.getDungeonPosition)},
	{"Dungeon Direction", Game.getDungeonDirection},
};

Game.OSD = Game.standardOSD;

return Game;