if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local object_index = 1;
local object_pointers = {};
local script_modes = {
	"Disabled",
	"List",
	"Examine",
};
local script_mode_index = 1;
local script_mode = script_modes[script_mode_index];

local Game = {
	squish_memory_table = true,
	Memory = { -- Version order: Europe, USA
		exit = {0x0BE800, 0x0BE3E0}, -- byte
		current_map = {0x0BEE12, 0x0BE9F2}, -- u16_be
		destination_map = {0x0BEE16, 0x0BE9F6}, -- u16_be
		previous_map = {0x0BEE1A, 0x0BE9FA}, --u16_be
		x_position = {0x0CC704, 0x0CC2E4}, -- Float
		y_position = {0x0CC708, 0x0CC2E8}, -- Float
		z_position = {0x0CC70C, 0x0CC2EC}, -- Float
		y_velocity = {0x0CC710, 0x0CC2F0}, -- Float
		velocity = {0x0CC72C, 0x0CC30C}, -- Float
		moving_angle = {0x0CC766, 0x0CC346}, -- u16_be
		facing_angle = {0x0CC76A, 0x0CC34A}, -- u16_be
		health = {0x0CC8BA,0x0CC49A}, -- u8
		first_object = {0x0CC6F0, 0x0CC2D0},
		--multiplayer_character = {nil, 0x0D213F}, --u8
		--wealth = {nil, 0x0D2148}, -- u32_be

	},
	maps = {
		"Windy: Cow Field",
		"Barn Boys: Inside Barn",
		"Uga Buga: Outside Rock Solid",
		"!Unknown 0x03", -- Bulldog, B&W?
		"It's War: Beach",
		"Beta: Black Room",
		"Windy: Day",
		"Bat's Tower: River",
		"Beta: Unused Texture (0x8)",
		"!Unknown 0x9", -- B&W, similar to Map 3
		"Bat's Tower: Boiler Room",
		"Bat's Tower: Cog Room",
		"Barn Boys: Outside the Barn",
		"!Crash 0xD",
		"It's War: Tank Field",
		"Beta: Raptor Arena",
		"Barn Boys: Haybot Fight (Tower)",
		"!Unknown 0x11",
		"Bat's Tower: Safe",
		"It's War: Pier",
		"Uga Buga: Arena",
		"!Unknown 0x15", -- B&W, similar ot Map 3
		"Beta: Tank Room", -- Tank Room
		"Bat's Tower: Safe (Underwater)",
		"The Panther King's Lair",
		"Uga Buga: Lava Waterfall",
		"Multiplayer: Heist",
		"It's War: Laser Tunnels",
		"It's War: Pond",
		"The Cock and Plucker", -- Also Berri's House
		"It's War: Laser Tunnels II",
		"!Unknown 0x1F",
		"Beta: Unused Texture (0x20)",
		"Nintendo 64 Logo",
		"Gregg's Underworld",
		"It's War: The Experiment",
		"Multiplayer: Tank",
		"Nintendo Logo", -- Boot up
		"It's War: Gun Tunnels",
		"Windy: Beehive",
		"It's War: Escape Tunnels",
		"Hungover: Field",
		"!Unknown 0x2A",
		"Multiplayer: Beach",
		"Windy: The Beetle Tower",
		"Multiplayer: War",
		"Hungover: Key Chamber",
		"It's War: Operating Room",
		"Multiplayer: Colors",
		"Uga Buga: Rock Solid",
		"Uga Buga: Race",
		"Multiplayer: Race",
		"Multiplayer: Bunker",
		"Sloprano: The Great Mighty Poo",
		"Heist: Feral Reserve (Lobby)",
		"Sloprano: Water Caverns",
		"Uga Buga: Boardroom",
		"Heist: Outside Feral Reserve",
		"Hiest: Feral Reserve (Safe)",
		"Windy: Night",
		"Spooky: Haunted Castle",
		"Spooky: Haunted Castle Exterior",
		"!Unknown 0x3E",
		"Multiplayer: Raptor",
		"Heist: Feral Reserve (Final Boss)",
		"Spooky: Flooded Mineshafts",
		"Uga Buga: Tribe Room (Fossil)",
		"Uga Buga: Tribe Room",
		"Uga Buga: Tribe Room (Lava)",
	},
	takeMeThereStyle = "Checkbox",
};

function Game.setMap(value)
	mainmemory.write_u16_be(Game.Memory.destination_map, value - 1);
end

function Game.getMap()
	local map_value = mainmemory.read_u16_be(Game.Memory.current_map);
	if Game.maps[map_value + 1] ~= nil then
		return Game.maps[map_value + 1];
	end
	return "Unknown (0x"..bizstring.hex(map_value)..")"
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100, 200 };
Game.speedy_index = 8;

function Game.isPhysicsFrame()
	return not emu.islagged(); -- TODO: Research lag in this game
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.x_position, true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_position, true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_position, true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(Game.Memory.x_position, value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.y_position, value, true);
	Game.setYVelocity(0);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_position, value, true);
end

function Game.getVelocity()
	return mainmemory.readfloat(Game.Memory.velocity, true);
end

function Game.setVelocity(value)
	return mainmemory.writefloat(Game.Memory.velocity, value, true);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity, true);
end

function Game.setYVelocity(value)
	return mainmemory.writefloat(Game.Memory.y_velocity, value, true);
end

--------------
-- Rotation --
--------------

Game.rot_speed = 16;
Game.max_rot_units = 0xFFFF;

function Game.getYRotation()
	return (mainmemory.read_u16_be(Game.Memory.moving_angle) + Game.max_rot_units / 4) % Game.max_rot_units; -- TODO: Fix this for all modules with a dpad angle offset
end

function Game.setYRotation(value)
	mainmemory.write_u16_be(Game.Memory.moving_angle, (value - Game.max_rot_units / 4) % Game.max_rot_units);
end

----------------------------
-- Multiplayer Characters --
----------------------------
local multiplayer_characters = {
	[0] = "Conker",
	[1] = "Weasel (Red & White)",
	[2] = "Weasel (Black)",
	[3] = "Tedi",
	[4] = "Rodent",
	[5] = "Conker",
	[6] = "Conker",
	[7] = "Conker",
	[8] = "Tank",
	[9] = "Fangy",
	[10] = "Tank (First Person)",
	[11] = "Uga Buga (Bald & No Glasses)",
	[12] = "Uga Buga (Bald & Glasses)",
	[13] = "Uga Buga (Afro)",
	[14] = "Uga Buga (Mohawk)",
	[15] = "Uga Buga (Spiky Hair)",
	[16] = "Conker (Heist)",
	[17] = "Villager (Male - No Hat)",
	[18] = "Villager (Male - No Hat)",
	[19] = "Villager (Male - No Hat)",
	[20] = "Villager (Male - No Hat)",
	[21] = "Villager (Male - Fedora)",
	[22] = "Villager (Male - Fedora)",
	[23] = "Villager (Male - Fedora)",
	[24] = "Villager (Male - Fedora)",
	[25] = "Villager (Male - Flat Hat)",
	[26] = "Villager (Male - Flat Hat)",
	[27] = "Villager (Male - Flat Hat)",
	[28] = "Villager (Male - Flat Hat)",
	[29] = "Villager (Female - Young)",
	[30] = "Villager (Female - Young)",
	[31] = "Villager (Female - Old)",
	[32] = "Villager (Female - Old)",
	[33] = "Zombie (Male)",
	[34] = "Zombie (Female)",
	[35] = "Bat",
	[36] = "Bat Conker",
	[37] = "Seargent",
	[38] = "Tedi Henchman",
	[39] = "Gregg",
	[40] = "Gregg (No Coat)",
};

-------------
-- Objects --
-------------

object_slot_size = 0x32C;
max_page_size = 40;

local object_struct = {
	interaction_state = 0x0, -- u32
	interaction_states = {
		[0x00] = "Not spawned",
		[0x01] = "Player", -- Only 1 can exist. Not 0 or 2+
		[0x02] = "Other",
		[0x1F] = "Rideable", -- Raptor
	},
	id = 0x4, -- u8
	id_names = {
		[0x00] = "Conker",
		[0x01] = "Conker",
		[0x02] = "Conker",
		[0x03] = "Conker",
		[0x04] = "Conker",
		[0x05] = "Wasp", -- Barn Boys
		[0x07] = "Mrs. Bee",
		[0x08] = "Bullfish",
		[0x0A] = "Catfish",
		[0x0C] = "Franky",
		[0x0D] = "Hay Bale",
		[0x0F] = "Red Cog",
		[0x10] = "Rock (Male)", -- Rock Solid
		[0x11] = "Tall Weasel (Guard)", -- Bridge
		[0x12] = "Machine Gun", -- War
		[0x14] = "Short Weasel (Guard", -- Bridge
		[0x13] = "Bee Hive",
		[0x15] = "Wooden Crate",
		[0x16] = "Uga Buga Member",
		[0x17] = "Large Wheel",
		[0x18] = "Metal Box",
		[0x1E] = "Large Metal Box",
		[0x20] = "Cheese",
		[0x21] = "Bull",
		[0x22] = "Mouse",
		[0x24] = "Whirlpool",
		[0x25] = "Dung Ball",
		[0x26] = "Mouse Carcass",
		[0x28] = "Tank",
		[0x29] = "Spiked Enemy",
		[0x2B] = "The Furnace",
		[0x2C] = "Ron the Paint Can",
		[0x2D] = "Reg the Paintbrush",
		[0x30] = "Stone Tablet",
		[0x31] = "Stone Tablet Reader",
		[0x33] = "Fireball",
		[0x36] = "Baby Dino", -- Uga Buga Sacrifice
		[0x37] = "Franky (Hung)",
		[0x38] = "Rock Bouncer", -- Rock Solid
		[0x3A] = "Fire Imp",
		[0x3B] = "Weasel",
		[0x3C] = "Money",
		[0x3F] = "Uvula Pendulum",
		[0x41] = "Anvil",
		[0x43] = "Air", -- Final Boss
		[0x44] = "Dung Beetle",
		[0x45] = "Haybot (Hay)",
		[0x46] = "Blue Cog",
		[0x48] = "Hoverboard", -- Uga Buga Mugged Race
		[0x49] = "Boat", -- War
		[0x4A] = "Submarine",
		[0x4B] = "Haybot (Robot)",
		[0x4C] = "Green Cog",
		[0x4E] = "Gun Cannon", -- War
		[0x4F] = "U47 ICB Missile",
		[0x50] = "Bat",
		[0x52] = "Carl the Cog",
		[0x53] = "Fangy",
		[0x54] = "Buga the Knut",
		[0x58] = "Soldier",
		-- [0x59] = "Something to do with Buga?",
		[0x5A] = "Tedi",
		[0x5B] = "Rodent",
		[0x5E] = "Heinrich",
		[0x60] = "Metal Box", -- War
		[0x61] = "Large Metal Box", -- War
		[0x66] = "'Ammo' Crates", -- War
		[0x69] = "Jugga",
		[0x6B] = "Eel",
		[0x6C] = "Sunflower",
		[0x6D] = "Mr. Bee",
		[0x70] = "Gregg", -- Spooky
		[0x72] = "Berri",
		[0x73] = "Gun Cannon", -- War
		[0x75] = "Tedi",
		[0x76] = "Panther King",
		[0x77] = "Tank",
		[0x79] = "Cow",
		[0x7B] = "The Experiment",
		[0x7C] = "Little Girl",
		[0x7D] = "Franky (Broken)",
		[0x7F] = "Barrel",
		[0x80] = "Rodent",
		[0x82] = "Conker (Mech Suit)",
		[0x86] = "Weasel Boss",
		[0x87] = "Sergeant",
		[0x88] = "Uga Buga Member",
		[0x89] = "Bomb",
		[0x8B] = "Scaredy Birdy",
		[0x8C] = "Key",
		[0x8D] = "Tedi (Nurse)",
		[0x8E] = "Gargoyle",
		[0x8F] = "Diplodocus", -- Uga Buga Mugged Race
		[0x90] = "Uga Buga Member",
		[0x91] = "Rock (Female)", -- Rock Solid
		[0x92] = "The Great Mighty Poo",
		[0x93] = "Sweetcorn", -- Great Mighty Poo
		[0x94] = "Cable", -- Haybot fight
		[0x95] = "Hand", -- Great Mighty Poo
		[0x96] = "Conker (Heist)",
		[0x97] = "Berri (Heist)",
		[0x98] = "Weasel (War)",
		[0x9A] = "Conker (Bat)",
		[0x9B] = "Bat",
		[0x9C] = "Villager (Male)",
		[0x9D] = "Villager (Female)",
		[0x9F] = "Zombie (Male)",
		[0xA0] = "Zombie (Female)",
		[0xA2] = "Count Batula (Bat)",
		[0xA3] = "Rope", -- Spooky, Count Batula
		[0xA4] = "Count Batula (Vampire)",
		[0xAC] = "Brass Ball",
		[0xAD] = "Bee", -- Windy
		[0xAE] = "Bee", -- Windy
		[0xAF] = "Bee", -- Windy
		[0xB0] = "Sergeant", -- Multiplayer?
		[0xB1] = "Tedi Henchman",
		[0xB2] = "Gregg", -- Multiplayer?
		[0xB3] = "Mouse (Stiches)", -- Intro
		[0xB4] = "Gregg (No Coat)",
		[0xFF] = "Projectile", -- Eg Knife, Toilet Roll
	},
	x_position = 0x14, -- Float
	y_position = 0x18, -- Float
	z_position = 0x1C, -- Float
	y_velocity = 0x20, -- Float
	xz_velocity = 0x3C, -- Float
	moving_angle = 0x76, -- u16_be
	facing_angle = 0x7A, -- u16_be
	health = 0x1CA, -- u8
};

function getObjectCount()
	return #object_pointers
end

local max_search_limit = 28

function populateObjectPointers()
	object_pointers = {};
	local first_object_location = Game.Memory.first_object
	local null_object_found = false;
	for i = 1, max_search_limit do
		if not null_object_found then
			local header = first_object_location + ((i - 1) * object_slot_size);
			local object_interaction_state = mainmemory.read_u32_be(header);
			local object_data = mainmemory.read_u32_be(header + object_struct.id)
			if object_data == 0 and object_interaction_state == 0 then
				null_object_found = true;
			end
			if object_interaction_state ~= 0 and not null_object_found then
				table.insert(object_pointers, header);
			end
		end
	end
end

function getObjectName(id)
	object_name = object_struct.id_names[id];
	if object_name == nil then
		object_name = toHexString(id)
	end
	return object_name;
end

function getSlotBase(index)
	local first_object_location = Game.Memory.first_object
	return first_object_location + (index * object_slot_size);
end

function getInteractionStateName(state)
	interaction_name = object_struct.interaction_states[state];
	if interaction_name == nil then
		interaction_name = toHexString(state)
	end
	return interaction_name;
end

local function getExamineData(header)
	local examine_data = {};
	local interactionState = mainmemory.read_u32_be(header + object_struct.interaction_state);
	if interactionState == 0 then
		return examine_data;
	end

	local xPos = mainmemory.readfloat(header + object_struct.x_position, true);
	local yPos = mainmemory.readfloat(header + object_struct.y_position, true);
	local zPos = mainmemory.readfloat(header + object_struct.z_position, true);
	local hasPosition = xPos ~= 0 or yPos ~= 0 or zPos ~= 0;

	table.insert(examine_data, { "Object Type", getObjectName(mainmemory.readbyte(header + object_struct.id)); });
	table.insert(examine_data, { "Separator", 1 });
	table.insert(examine_data, { "X", round(xPos, precision) });
	table.insert(examine_data, { "Y", round(yPos, precision) });
	table.insert(examine_data, { "Z", round(zPos, precision) });
	table.insert(examine_data, { "Health", mainmemory.readbyte(header + object_struct.health) });
	table.insert(examine_data, { "Interaction State", getInteractionStateName(mainmemory.read_u32_be(header + object_struct.interaction_state)) });
	table.insert(examine_data, { "Separator", 1 });
	table.insert(examine_data, { "Moving Angle", (mainmemory.read_u16_be(header + object_struct.moving_angle) + Game.max_rot_units / 4) % Game.max_rot_units });
	table.insert(examine_data, { "Facing Angle", (mainmemory.read_u16_be(header + object_struct.facing_angle) + Game.max_rot_units / 4) % Game.max_rot_units });
	table.insert(examine_data, { "Separator", 1 });
	table.insert(examine_data, { "Velocity", round(mainmemory.readfloat(header + object_struct.xz_velocity, true),precision) });
	table.insert(examine_data, { "Y Velocity", round(mainmemory.readfloat(header + object_struct.y_velocity, true),precision) });
	return examine_data;
end

local function zipTo(index)
	local objectCount = getObjectCount();
	if objectCount > 0 then
		local header = getSlotBase(index);
		local xPos = mainmemory.readfloat(header + object_struct.x_position, true);
		local yPos = mainmemory.readfloat(header + object_struct.y_position, true);
		local zPos = mainmemory.readfloat(header + object_struct.z_position, true);
		Game.setPosition(xPos, yPos, zPos);
	end
end

local function zipToSelectedObject()
	zipTo(object_index - 1);
end

local function incrementObjectIndex()
	object_index = object_index + 1;
	if object_index > getObjectCount() then
		object_index = 1;
	end
end

local function decrementObjectIndex()
	object_index = object_index - 1;
	if object_index <= 0 then
		object_index = getObjectCount();
	end
end

local function toggleObjectAnalysisToolsMode()
	script_mode_index = script_mode_index + 1;
	if script_mode_index > #script_modes then
		script_mode_index = 1;
	end
	script_mode = script_modes[script_mode_index];
end

function Game.drawUI()
	if script_mode == "Disabled" then
		return;
	end

	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	gui.text(gui_x, gui_y + height * row, "Mode: "..script_mode, nil, 'bottomright');
	row = row + 1;

	populateObjectPointers();
	local objectCount = getObjectCount();

	gui.text(gui_x, gui_y + height * row, "Index: "..object_index.."/"..#object_pointers, nil, 'bottomright');
	row = row + 1;
	gui.text(gui_x, gui_y + height * row, "Page: "..(page_pos).."/"..(page_total), nil, 'bottomright');
	row = row + 1;
	row = row + 1;

	-- Clamp index to number of objects
	if #object_pointers > 0 and object_index > #object_pointers then
		object_index = #object_pointers;
	end

	if #object_pointers > 0 and object_index <= #object_pointers then
		if string.contains(script_mode, "Examine") then
			local examine_data = {};
			examine_data = getExamineData(object_pointers[object_index]);

			pagifyThis(examine_data, 40);

			for i = page_finish, page_start + 1, -1 do
				if examine_data[i][1] ~= "Separator" then
					if type(examine_data[i][2]) == "number" then
						examine_data[i][2] = round(examine_data[i][2], precision);
					end
					gui.text(gui_x, gui_y + height * row, examine_data[i][1]..": "..examine_data[i][2], nil, 'bottomright');
					row = row + 1;
				else
					row = row + examine_data[i][2];
				end
			end
		end

		if string.contains(script_mode, "List") then
			row = row + 1;
			pagifyThis(object_pointers, 40);
			for i = page_finish, page_start + 1, -1 do
				local color = nil;
				if object_index == i then
					color = colors.yellow;
				end

				object_header = object_pointers[i];
				gui.text(gui_x, gui_y + height * row, i..": "..toHexString(object_header or 0, 6).." ("..getObjectName(mainmemory.readbyte(object_header + object_struct.id))..")", color, 'bottomright');
				row = row + 1;
			end
		end
	end
end

-- Keybinds
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm
ScriptHawk.bindKeyRealtime("Z", zipToSelectedObject, true);
ScriptHawk.bindKeyRealtime("C", toggleObjectAnalysisToolsMode, true);
ScriptHawk.bindKeyRealtime("N", decrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("M", incrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("H", decrementPage, true);
ScriptHawk.bindKeyRealtime("J", incrementPage, true);
ScriptHawk.bindMouse("mousewheelup", decrementObjectIndex);
ScriptHawk.bindMouse("mousewheeldown", incrementObjectIndex);

------------
-- Events --
------------

Game.OSD = {
	{"Map", Game.getMap},
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Velocity", Game.getVelocity, category="speed"};
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"},
	--{"Rot. X", Game.getXRotation, category="angleMore"},
	{"Moving", Game.getYRotation, category="angle"},
	--{"Rot. Z", Game.getZRotation, category="angleMore"},
};

return Game;