local Game = {};

-------------------------
-- DK64 specific state --
-------------------------

local version; -- 1 USA, 2 PAL, 3 JP, 4 Kiosk
Game.Memory = {
	["map"] = {0x7444E4, 0x73EC34, 0x743DA4, 0x72CDE4}, -- Note: Exit = Map + 4
	["file"] = {0x7467C8, 0x740F18, 0x746088, nil},
	["character"] = {0x74E77C, 0x748EDC, 0x74E05C, 0x6F9EB8},
	["tb_void_byte"] = {0x7FBB63, 0x7FBA83, 0x7FBFD3, 0x7B5B13},
	["player_pointer"] = {0x7FBB4C, 0x7FBA6C, 0x7FBFBC, 0x7B5AFC},
	["camera_pointer"] = {0x7FB968, 0x7FB888, 0x7FBDD8, 0x7B5918},
	["pointer_list"] = {0x7FBFF0, 0x7FBF10, 0x7FC460, 0x7B5E58}, -- TODO: Kiosk is in a weird spot, is this correct?
	["linked_list_pointer"] = {0x7F0990, 0x7F08B0, 0x7F0E00, 0x7A12C0},
	["global_base"] = {0x7FCC41, 0x7FCB81, 0x7FD0D1, 0x7B6754},
	["kong_base"] = {0x7FC950, 0x7FC890, 0x7FCDE0, nil}, -- TODO: Kiosk?
	["menu_flags"] = {0x7ED558, 0x7ED478, 0x7ED9C8, nil},
	["framebuffer_pointer"] = {0x7F07F4, 0x73EBC0, 0x743D30, 0x72CDA0},
	["flag_block_pointer"] = {0x7654F4, 0x760014, 0x7656E4, nil},
	["security_byte"] = {0x7552E0, 0x74FB60, 0x7553A0, nil}, -- TODO: Kiosk?
	["security_message"] = {0x75E5DC, 0x7590F0, 0x75E790, nil},
	["bone_displacement_pointer"] = {0x76FDF8, 0x76A918, 0x76FFE8, nil}, -- TODO: Kiosk
	["frames_lag"] = {0x76AF10, 0x765A30, 0x76B100, 0x72D140}, -- TODO: Kiosk only works for minecart?
	["frames_real"] = {0x7F0560, 0x7F0480, 0x7F09D0, nil}, -- TODO: Make sure freezing these crashes the main thread -- TODO: Kiosk
	["boss_pointer"] = {0x7FDC90, 0x7FDBD0, 0x7FE120, nil}, -- TODO: Find Mad Jack state based on Model 1 pointer list and actor type knowledge. MJ is actor 204
	["slope_object_pointer"] = {0x7F94B8, nil, nil , nil}, -- TODO - PAL, JP & Kiosk, also note this is part of the player object so might be simpler to do getPlayerObject() + offset if it doesn't break anything
	["obj_model2_array_pointer"] = {0x7F6000, 0x7F5F20, 0x7F6470, nil},
	["obj_model2_array_count"] = {0x7F6004, 0x7F5F24, 0x7F6474, nil},
	["obj_model2_collision_linked_list_pointer"] = {0x754244, 0x74E9A4, 0x753B34, 0x6FF054},
};

local flag_array = {};
local flag_names = {};
local prev_map = 0;
local map_value = 0;

---------------------------
-- Arcade specific state --
---------------------------

local arcade_map = 2;
local jumpman_position;
local jumpman_velocity;

---------------------------
-- Jetpac specific state --
---------------------------

local jetpac_map = 9;
local jetman_position;
local jetman_velocity;

--------------
-- Mad Jack --
--------------

local mad_jack_map = 154;

-- Relative to MJ state object
local MJ_time_until_next_action;
local MJ_actions_remaining;
local MJ_action_type;
local MJ_current_pos;
local MJ_next_pos;
local MJ_white_switch_pos;
local MJ_blue_switch_pos;

-----------------
-- Other state --
-----------------

local eep_checksum_offsets = {
	0x1A8,
	0x354,
	0x500,
	0x6AC,
	0x6EC
};

local eep_checksum_values = {
	0x00000000,
	0x00000000,
	0x00000000,
	0x00000000,
	0x00000000
};

----------------------------------
-- Refill Consumables           --
-- Based on research by Exchord --
----------------------------------

-- Maximum values
local max_melons = 3;
local max_health = max_melons * 4;

local max_coins          = 50;
local max_crystals       = 20;
local max_film           = 10;
local max_oranges        = 20;
local max_musical_energy = 10;
local max_standard_ammo  = 50;
local max_homing_ammo    = 50;

local max_blueprints = 40 * 2;
local max_fairies = 20;
local max_crowns = 10;
local max_medals = 40;
local max_cb = 3511;
local max_gb = 201;
local max_warps = (5 * 2 * 8) + 4 + 2 + 2 + 6;

-- Relative to global_base
local standard_ammo = 0;
local homing_ammo   = 2;
local oranges       = 4;
local crystals      = 5;
local film          = 8;
local health        = 10;
local melons        = 11;

-- Kong index
local DK     = 0;
local Diddy  = 1;
local Lanky  = 2;
local Tiny   = 3;
local Chunky = 4;
local Krusha = 5;

-- Pointers relative to Kong base
local moves      = 0;
local sim_slam   = 1;
local weapon     = 2;
local instrument = 4;
local coins      = 7;
local lives      = 9; -- This is used as instrument ammo in single player

----------------------------------
-- Object Model 1 Documentation --
----------------------------------

local max_objects = 0xFF;

-- Relative to objects found in the pointer list (Model 1)
local previous_object = -0x10; -- u32_be
local object_size = -0x0C; -- u32_be

local model_pointer = 0x00; -- u32_be
	-- Relative to model_pointer
	local num_bones = 0x20;

local rendering_parameters_pointer = 0x04; -- u32_be
	-- Relative to rendering parameters
	local scale_x = 0x34;
	local scale_y = scale_x + 4;
	local scale_z = scale_y + 4;

local current_bone_array_pointer = 0x08; -- u32_be

local actor_type = 0x58; -- TODO: Document values for this, different on Kiosk

-- 0001 0000 = collides with terrain
-- 0000 0100 = visible
-- 0000 0001 = in water
local visibility = 0x63; -- Bitfield TODO: Fully document

local specular_highlight = 0x6D;

local shadow_width = 0x6E;
local shadow_height = 0x6F;

local x_pos = 0x7C;
local y_pos = x_pos + 4;
local z_pos = y_pos + 4;

local floor = 0xA4;
local distance_from_floor = 0xB4;

local velocity = 0xB8;
--local acceleration = 0xBC; -- Seems wrong

local y_velocity = 0xC0;
local y_acceleration = 0xC4;

local gravity_strength = 0xC8;

local light_thing = 0xCC; -- Values 0x00->0x14

local x_rot = 0xE4;
local y_rot = x_rot + 2;
local z_rot = y_rot + 2;

local locked_to_pad = 0x110;
local lock_method_1_pointer = 0x13C;
local hand_state = 0x147; -- Bitfield

-- State byte
-- 0x02 First person camera
-- 0x04 Fairy camera
-- 0x0C standing normally
-- 0x0e Skid
-- 0x18 Moonrise?
-- 0x20 Splat
-- 0x24 Sparkles
-- 0x2C Crouch?
-- 0x39 Shrinking
-- 0x31 ESS
-- 0x36 Backwalk into loading zone?
-- 0x39 Shrink
-- 0x3E Camera zooms out
-- 0x4E Surface swimming
-- 0x4F Underwater
local object_state_byte = 0x154;

local camera_focus_pointer = 0x178;

local animation_type = 0x181;
local kick_animation_value = 0x29;

local velocity_uncrouch_aerial = 0x1A4;

local misc_acceleration_float = 0x1AC;
local horizontal_acceleration = 0x1B0; -- Set to a negative number to go fast
local misc_acceleration_float_2 = 0x1B4;
local misc_acceleration_float_3 = 0x1B8;

local velocity_ground = 0x1C0;

local grabbed_vine_pointer = 0x2B0;

-- TODO: Properly document these, also these only apply to the player and maybe kongs in the tag barrel
local scale = {
	0x344, 0x348, 0x34C, 0x350, 0x354
}

local effect_byte = 0x372; -- Bitfield, TODO: Document bits

local function getPlayerObject() -- TODO: Cache this
	return mainmemory.read_u24_be(Game.Memory.player_pointer[version] + 1);
end

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if stringContains(romName, "USA") and not stringContains(romName, "Kiosk") then
		version = 1;
		flag_array = require("games.dk64_flags_USA");

		--Mad Jack
		MJ_time_until_next_action = 0x2D;
		MJ_actions_remaining      = 0x58;
		MJ_action_type            = 0x59;
		MJ_current_pos            = 0x60;
		MJ_next_pos               = 0x61;
		MJ_white_switch_pos       = 0x64;
		MJ_blue_switch_pos        = 0x65;

		--Subgames
		jumpman_position = {0x04BD70, 0x04BD74};
		jumpman_velocity = {0x04BD78, 0x04BD7C};
		jetman_position  = {0x02F050, 0x02F054};
		jetman_velocity =  {0x02F058, 0x02F05C};
	elseif stringContains(romName, "Europe") then
		version = 2;
		flag_array = require("games.dk64_flags_PAL");

		--Mad Jack
		MJ_time_until_next_action = 0x25;
		MJ_actions_remaining      = 0x60;
		MJ_action_type            = 0x61;
		MJ_current_pos            = 0x68;
		MJ_next_pos               = 0x69;
		MJ_white_switch_pos       = 0x6C;
		MJ_blue_switch_pos        = 0x6D;

		--Subgames
		jumpman_position = {0x03ECD0, 0x03ECD4};
		jumpman_velocity = {0x03ECD8, 0x03ECDC};
		jetman_position  = {0x022100, 0x022104};
		jetman_velocity  = {0x022108, 0x02210C};
	elseif stringContains(romName, "Japan") then
		version = 3;
		flag_array = require("games.dk64_flags_JP");

		--Mad Jack
		MJ_time_until_next_action = 0x25;
		MJ_actions_remaining      = 0x60;
		MJ_action_type            = 0x61;
		MJ_current_pos            = 0x68;
		MJ_next_pos               = 0x69;
		MJ_white_switch_pos       = 0x6C;
		MJ_blue_switch_pos        = 0x6D;

		--Subgames
		jumpman_position = {0x03EB00, 0x03EB04};
		jumpman_velocity = {0x03EB00, 0x03EB04};
		jetman_position  = {0x022060, 0x022064};
		jetman_velocity  = {0x022068, 0x02206C};
	elseif stringContains(romName, "Kiosk") then
		version = 4;
		-- TODO: Flags?

		x_rot = 0xD8;
		y_rot = x_rot + 2;
		z_rot = y_rot + 2;

		velocity = 0xB0;
		y_velocity = 0xB8;
		y_acceleration = 0xBC;

		-- Kiosk version maps
		--0 Crash
		--1 Crash
		--2 Crash
		--3 Dogadon (2?) fight (Crash??!?!?!)
		--4 Crash
		--5 Crash
		--6 Minecart
		--7 Crash
		--8 Armydillo fight
		--9-39 Crash
		--40 N+R logo
		--41-75 Crash
		--76 DK Rap
		--77 Crash
		--78 Crash
		--79 Crash
		--80 Title screen
		--81 "Thanks for playing" or Test Map
		--82 Crash?
		--83 Dogadon Fight
		--84-214 Crash
		--215 Partially loads (kong position changes), then crashes
		--216-228 Crash
		--229 Partially loads (kong position changes), then crashes
		--230-240 Crash
		--241 Partially loads (kong position changes), then crashes
		--242-255 Crash
	else
		return false;
	end

	-- Read EEPROM checksums
	if memory.usememorydomain("EEPROM") then
		for i = 1, #eep_checksum_offsets do
			eep_checksum_values[i] = memory.read_u32_be(eep_checksum_offsets[i]);
		end
	end
	memory.usememorydomain("RDRAM");

	-- Fill the flag names
	if #flag_array > 0 then
		for i = 1, #flag_array do
			flag_names[i] = flag_array[i]["name"];
		end
	else
		print("Warning: No flags found");
		flag_names = {"None"};
	end

	return true;
end

Game.maps = {
	"Test Map",
	"Funky's Store",
	"DK Arcade",
	"K. Rool Barrel: Lanky's Maze",
	"Jungle Japes: Mountain",
	"Cranky's Lab",
	"Jungle Japes: Minecart",
	"Jungle Japes",
	"Jungle Japes: Army Dillo",
	"Jetpac",
	"Kremling Kosh! (very easy)",
	"Stealthy Snoop! (normal, no logo)",
	"Jungle Japes: Shell",
	"Jungle Japes: Lanky's Cave",
	"Angry Aztec: Beetle Race",
	"Snide's H.Q.",
	"Angry Aztec: Tiny's Temple",
	"Hideout Helm",
	"Teetering Turtle Trouble! (very easy)",
	"Angry Aztec: Five Door Temple (DK)",
	"Angry Aztec: Llama Temple",
	"Angry Aztec: Five Door Temple (Diddy)",
	"Angry Aztec: Five Door Temple (Tiny)",
	"Angry Aztec: Five Door Temple (Lanky)",
	"Angry Aztec: Five Door Temple (Chunky)",
	"Candy's Music Shop",
	"Frantic Factory",
	"Frantic Factory: Car Race",
	"Hideout Helm (Level Intros, Game Over)",
	"Frantic Factory: Power Hut",
	"Gloomy Galleon",
	"Gloomy Galleon: K. Rool's Ship",
	"Batty Barrel Bandit! (easy)",
	"Jungle Japes: Chunky's Cave",
	"DK Isles Overworld",
	"K. Rool Barrel: DK's Target Game",
	"Frantic Factory: Conveyor Belt",
	"Jungle Japes: Barrel Blast",
	"Angry Aztec",
	"Gloomy Galleon: Seal Race",
	"Nintendo Logo",
	"Angry Aztec: Barrel Blast",
	"Troff 'n' Scoff",
	"Gloomy Galleon: Shipwreck (Diddy, Lanky, Chunky)",
	"Gloomy Galleon: Treasure Chest",
	"Gloomy Galleon: Mermaid",
	"Gloomy Galleon: Shipwreck (DK, Tiny)",
	"Gloomy Galleon: Shipwreck (Lanky, Tiny)",
	"Fungi Forest",
	"Gloomy Galleon: Lighthouse",
	"K. Rool Barrel: Tiny's Mushroom Game",
	"Gloomy Galleon: Mechanical Fish",
	"Fungi Forest: Tree Stump",
	"Beaver Brawl!",
	"Gloomy Galleon: Barrel Blast",
	"Fungi Forest: Minecart",
	"Fungi Forest: Diddy's Barn",
	"Fungi Forest: Diddy's Attic",
	"Fungi Forest: Lanky's Attic",
	"Fungi Forest: DK's Barn",
	"Fungi Forest: Spider",
	"Fungi Forest: Front Part of Mill",
	"Fungi Forest: Rear Part of Mill",
	"Fungi Forest: Mushroom Puzzle",
	"Fungi Forest: Giant Mushroom",
	"Stealthy Snoop! (normal)",
	"Mad Maze Maul! (hard)",
	"Stash Snatch! (normal)",
	"Mad Maze Maul! (easy)",
	"Mad Maze Maul! (normal)",
	"Fungi Forest: Mushroom Leap",
	"Fungi Forest: Shooting Game",
	"Crystal Caves",
	"Kritter Karnage!",
	"Stash Snatch! (easy)",
	"Stash Snatch! (hard)",
	"DK Rap",
	"Minecart Mayhem! (easy)",
	"Busy Barrel Barrage! (easy)",
	"Busy Barrel Barrage! (normal)",
	"Main Menu",
	"Title Screen (Not For Resale Version)",
	"Crystal Caves: Beetle Race",
	"Fungi Forest: Dogadon",
	"Crystal Caves: Igloo (Tiny)",
	"Crystal Caves: Igloo (Lanky)",
	"Crystal Caves: Igloo (DK)",
	"Creepy Castle",
	"Creepy Castle: Ballroom",
	"Crystal Caves: DK's Hut",
	"Crystal Caves: Shack (Chunky)",
	"Crystal Caves: Shack (DK)",
	"Crystal Caves: Shack (Diddy, middle part)",
	"Crystal Caves: Shack (Tiny)",
	"Crystal Caves: Lanky's Hut",
	"Crystal Caves: Igloo (Chunky)",
	"Splish-Splash Salvage! (normal)",
	"K. Lumsy",
	"Crystal Caves: Ice Castle",
	"Speedy Swing Sortie! (easy)",
	"Crystal Caves: Igloo (Diddy)",
	"Krazy Kong Klamour! (easy)",
	"Big Bug Bash! (very easy)",
	"Searchlight Seek! (very easy)",
	"Beaver Bother! (easy)",
	"Creepy Castle: Tower",
	"Creepy Castle: Minecart",
	"Kong Battle: Battle Arena",
	"Creepy Castle: Basement (Lanky, Tiny)",
	"Kong Battle: Arena 1",
	"Frantic Factory: Barrel Blast",
	"Gloomy Galleon: Pufftoss",
	"Creepy Castle: Basement (DK, Diddy, Chunky)",
	"Creepy Castle: Museum",
	"Creepy Castle: Library",
	"Kremling Kosh! (easy)",
	"Kremling Kosh! (normal)",
	"Kremling Kosh! (hard)",
	"Teetering Turtle Trouble! (easy)",
	"Teetering Turtle Trouble! (normal)",
	"Teetering Turtle Trouble! (hard)",
	"Batty Barrel Bandit! (easy)",
	"Batty Barrel Bandit! (normal)",
	"Batty Barrel Bandit! (hard)",
	"Mad Maze Maul! (insane)",
	"Stash Snatch! (insane)",
	"Stealthy Snoop! (very easy)",
	"Stealthy Snoop! (easy)",
	"Stealthy Snoop! (hard)",
	"Minecart Mayhem! (normal)",
	"Minecart Mayhem! (hard)",
	"Busy Barrel Barrage! (hard)",
	"Splish-Splash Salvage! (hard)",
	"Splish-Splash Salvage! (easy)",
	"Speedy Swing Sortie! (normal)",
	"Speedy Swing Sortie! (hard)",
	"Beaver Bother! (normal)",
	"Beaver Bother! (hard)",
	"Searchlight Seek! (easy)",
	"Searchlight Seek! (normal)",
	"Searchlight Seek! (hard)",
	"Krazy Kong Klamour! (normal)",
	"Krazy Kong Klamour! (hard)",
	"Krazy Kong Klamour! (insane)",
	"Peril Path Panic! (very easy)",
	"Peril Path Panic! (easy)",
	"Peril Path Panic! (normal)",
	"Peril Path Panic! (hard)",
	"Big Bug Bash! (easy)",
	"Big Bug Bash! (normal)",
	"Big Bug Bash! (hard)",
	"Creepy Castle: Tunnel",
	"Hideout Helm (Intro Story)",
	"DK Isles (DK Theatre)",
	"Frantic Factory: Mad Jack",
	"Arena Ambush!",
	"More Kritter Karnage!",
	"Forest Fracas!",
	"Bish Bash Brawl!",
	"Kamikaze Kremlings!",
	"Plinth Panic!",
	"Pinnacle Palaver!",
	"Shockwave Showdown!",
	"Creepy Castle: Dungeon",
	"Creepy Castle: Tree",
	"K. Rool Barrel: Diddy's Kremling Game",
	"Creepy Castle: Hut",
	"Creepy Castle: Trash Can",
	"Creepy Castle: Greenhouse",
	"Jungle Japes Lobby",
	"Hideout Helm Lobby",
	"DK's House",
	"Rock (Intro Story)",
	"Angry Aztec Lobby",
	"Gloomy Galleon Lobby",
	"Frantic Factory Lobby",
	"Training Grounds",
	"Water Barrel",
	"Fungi Forest Lobby",
	"Gloomy Galleon: Submarine",
	"Orange Barrel",
	"Barrel Barrel",
	"Vine Barrel",
	"Creepy Castle: Crypt",
	"Enguarde Arena",
	"Creepy Castle: Car Race",
	"Crystal Caves: Barrel Blast",
	"Creepy Castle: Barrel Blast",
	"Fungi Forest: Barrel Blast",
	"Fairy Island",
	"Kong Battle: Arena 2",
	"Rambi Arena",
	"Kong Battle: Arena 3",
	"Creepy Castle Lobby",
	"Crystal Caves Lobby",
	"DK Isles: Snide's Room",
	"Crystal Caves: Army Dillo",
	"Angry Aztec: Dogadon",
	"Training Grounds (End Sequence)",
	"Creepy Castle: King Kutout",
	"Crystal Caves: Shack (Diddy, upper part)",
	"K. Rool Barrel: Diddy's Rocketbarrel Game",
	"K. Rool Barrel: Lanky's Shooting Game",
	"K. Rool Fight: DK Phase",
	"K. Rool Fight: Diddy Phase",
	"K. Rool Fight: Lanky Phase",
	"K. Rool Fight: Tiny Phase",
	"K. Rool Fight: Chunky Phase",
	"Bloopers Ending",
	"K. Rool Barrel: Chunky's Hidden Kremling Game",
	"K. Rool Barrel: Tiny's Pony Tail Twirl Game",
	"K. Rool Barrel: Chunky's Shooting Game",
	"K. Rool Barrel: DK's Rambi Game",
	"K. Lumsy Ending",
	"K. Rool's Shoe",
	"K. Rool's Arena"
};

local function isPointer(value)
	return value >= 0x80000000 and value < 0x80800000;
end

local function isRDRAM(value)
	return value > 0x000000 and value < 0x800000;
end

----------------
-- Flag stuff --
----------------

local flag_block_size = 0x13B; -- TODO: Different size on PAL/JP? -- TODO: Find exact size

local flag_action_queue = {};
flag_block = {};

function adjustBlockSize(value)
	flag_block = {};
	flag_block_size = value;
	checkFlags();
end

function isFound(byte, bit)
	for i = 1, #flag_array do
		if byte == flag_array[i]["byte"] and bit == flag_array[i]["bit"] then
			return true;
		end
	end
	return false;
end

function checkFlags()
	local flags = mainmemory.read_u24_be(Game.Memory.flag_block_pointer[version] + 1);
	local temp_value;
	local flag_found = false;
	local known_flags_found = 0;
	if flags > 0x700000 and flags < 0x7FFFFF - flag_block_size then
		if #flag_block > 0 then
			for i = 0, #flag_block do
				temp_value = mainmemory.readbyte(flags + i);
				if flag_block[i] ~= temp_value then
					for bit = 0, 7 do
						if get_bit(temp_value, bit) and not get_bit(flag_block[i], bit) then
							-- Output debug info if the flag isn't known
							if not isFound(i, bit) then
								flag_found = true;
								dprint("{[\"byte\"] = "..toHexString(i)..", [\"bit\"] = "..bit..", [\"name\"] = \"Name\", [\"type\"] = \"Type\"},");
							else
								known_flags_found = known_flags_found + 1;
							end
						end
					end

					-- Update entry in array
					flag_block[i] = temp_value;
				end
			end
			if known_flags_found > 0 then
				dprint(known_flags_found.." Known flags skipped.")
			end
			if not flag_found then
				dprint("No unknown flags were changed.")
			end
		else
			-- Populate flag block
			for i = 0, flag_block_size do
				flag_block[i] = mainmemory.readbyte(flags + i);
			end
			dprint("Populated flag array.")
		end
	else
		dprint("Failed to find flag block on this frame, adding to queue. Will be checked next time block is found.");
		table.insert(flag_action_queue, {["action_type"]="check"});
	end
	print_deferred();
end

local function process_flag_queue()
	if #flag_action_queue > 0 then
		local flags = mainmemory.read_u24_be(Game.Memory.flag_block_pointer[version] + 1);
		if flags > 0x700000 and flags < 0x7FFFFF - flag_block_size then
			local queue_item, current_value;
			for i = 1, #flag_action_queue do
				queue_item = flag_action_queue[i];
				if type(queue_item) == "table" then
					if queue_item["action_type"] == "set" then
						current_value = mainmemory.readbyte(flags + queue_item["byte"]);
						mainmemory.writebyte(flags + queue_item["byte"], set_bit(current_value, queue_item["bit"]));
						if not queue_item["suppressPrint"] then
							if type(queue_item["name"]) == "string" then
								dprint("Set \""..queue_item["name"].."\" at "..toHexString(queue_item["byte"]).." bit "..queue_item["bit"]);
							else
								dprint("Set flag at "..toHexString(queue_item["byte"]).." bit "..queue_item["bit"]);
							end
						end
					elseif queue_item["action_type"] == "clear" then
						current_value = mainmemory.readbyte(flags + queue_item["byte"]);
						mainmemory.writebyte(flags + queue_item["byte"], clear_bit(current_value, queue_item["bit"]));
						if not queue_item["suppressPrint"] then
							if type(queue_item["name"]) == "string" then
								dprint("Cleared \""..queue_item["name"].."\" at "..toHexString(queue_item["byte"]).." bit "..queue_item["bit"]);
							else
								dprint("Cleared flag at "..toHexString(queue_item["byte"]).." bit "..queue_item["bit"]);
							end
						end
					elseif queue_item["action_type"] == "check" then
						checkFlags();
					end
				end
			end
			-- Speed up output by printing everything in one call to print
			print_deferred();
			-- Clear queue if we found the block that frame
			flag_action_queue = {};
		end
	end
end

local function getFlagByName(flagName)
	for i = 1, #flag_array do
		if flagName == flag_array[i]["name"] then
			return flag_array[i];
		end
	end
end

------------------------
-- Set flag functions --
------------------------

function setFlag(byte, bit, suppressPrint)
	suppressPrint = suppressPrint or false;
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit <= 7 then
		table.insert(flag_action_queue, {["action_type"]="set", ["byte"]=byte, ["bit"]=bit, ["suppressPrint"]=suppressPrint});
		process_flag_queue();
	end
end

function setFlagByName(name)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		flag["action_type"] = "set";
		table.insert(flag_action_queue, flag);
		process_flag_queue();
	end
end

function setFlagByType(_type)
	local num_set = 0;
	if type(_type) == "string" then
		local flag;
		for i = 1, #flag_array do
			if flag_array[i]["type"] == _type then
				flag = flag_array[i];
				flag["action_type"] = "set";
				flag["suppressPrint"] = true;
				table.insert(flag_action_queue, flag);
				num_set = num_set + 1;
			end
		end
	end
	if num_set > 0 then
		process_flag_queue();
		print("Set "..num_set.." flags of type '".._type.."'");
	else
		print("No flags found for specified type.");
	end
end
setFlagsByType = setFlagByType;

function setAllFlags()
	for byte = 0, flag_block_size do
		for bit = 0, 7 do
			setFlag(byte, bit, true);
		end
	end
end

function clearAllFlags()
	for byte = 0, flag_block_size do
		for bit = 0, 7 do
			clearFlag(byte, bit, true);
		end
	end
end

--------------------------
-- Clear flag functions --
--------------------------

function clearFlag(byte, bit, suppressPrint)
	suppressPrint = suppressPrint or false;
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit <= 7 then
		table.insert(flag_action_queue, {["action_type"]="clear", ["byte"]=byte, ["bit"]=bit, ["suppressPrint"]=suppressPrint});
		process_flag_queue();
	end
end

function clearFlagByName(name)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		flag["action_type"] = "clear";
		table.insert(flag_action_queue, flag);
		process_flag_queue();
	end
end

function clearFlagByType(_type)
	local num_cleared = 0;
	if type(_type) == "string" then
		local flag;
		for i = 1, #flag_array do
			if flag_array[i]["type"] == _type then
				flag = flag_array[i];
				flag["action_type"] = "clear";
				flag["suppressPrint"] = true;
				table.insert(flag_action_queue, flag);
				num_cleared = num_cleared + 1;
			end
		end
	end
	if num_cleared > 0 then
		process_flag_queue();
		print("Cleared "..num_cleared.." flags of type '".._type.."'");
	else
		print("No flags found for specified type.");
	end
end
clearFlagsByType = clearFlagByType;

--------------------------
-- Other flag functions --
--------------------------

local function flagSetButtonHandler()
	setFlagByName(forms.getproperty(ScriptHawkUI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagClearButtonHandler()
	clearFlagByName(forms.getproperty(ScriptHawkUI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function formatOutputString(caption, value, max)
	return caption..value.."/"..max.." or "..round(value / max * 100, 2).."%";
end

function flagStats(verbose)
	local fairies_known = 0;
	local blueprints_known = 0;
	local warps_known = 0;
	local cb_known = 0;
	local gb_known = 0;
	local crowns_known = 0;
	local coins_known = 0;
	local untypedFlags = 0;

	-- Setting this to true warns the user of flags without types
	verbose = verbose or false;

	local flag, name, flagType;
	for i = 1, #flag_array do
		flag = flag_array[i];
		name = flag["name"];
		flagType = flag["type"];
		if flagType == nil then
			untypedFlags = untypedFlags + 1;
			if verbose then
				dprint("Warning: Flag without type detected at "..toHexString(flag["byte"]).." bit "..flag["bit"].." with name: \""..flag["name"].."\"");
			end
		end
		if flagType == "Fairy" then
			fairies_known = fairies_known + 1;
		end
		if flagType == "Blueprint" then
			blueprints_known = blueprints_known + 1;
			if stringContains(name, "Turned") then
				gb_known = gb_known + 1;
			end
		end
		if flagType == "Warp" then
			warps_known = warps_known + 1;
		end
		if flagType == "GB" then
			gb_known = gb_known + 1;
		end
		if flagType == "CB" then
			cb_known = cb_known + 1;
		end
		if flagType == "Bunch" then
			cb_known = cb_known + 5;
		end
		if flagType == "Balloon" then
			cb_known = cb_known + 10;
		end
		if flagType == "Crown" then
			crowns_known = crowns_known + 1;
		end
		if flagType == "Coin" then
			coins_known = coins_known + 1;
		end
		if flagType == "Rainbow Coin" then
			coins_known = coins_known + 25;
		end
	end

	local knownFlags = #flag_array;
	local totalFlags = flag_block_size * 8;

	dprint("Block size: "..toHexString(flag_block_size));
	dprint(formatOutputString("Flags known: ", knownFlags, totalFlags));
	dprint(formatOutputString("Flags without types: ", untypedFlags, knownFlags));
	dprint("");
	dprint(formatOutputString("Crowns: ", crowns_known, max_crowns));
	dprint(formatOutputString("Fairies: ", fairies_known, max_fairies));
	dprint(formatOutputString("Blueprints: ", blueprints_known, max_blueprints));
	dprint("");
	dprint(formatOutputString("Warps: ", warps_known, max_warps));
	dprint(formatOutputString("CB: ", cb_known, max_cb));
	dprint(formatOutputString("GB: ", gb_known, max_gb));
	dprint("Coins: "..coins_known); -- Just a note: Fungi Rabbit Race coins aren't flagged
	dprint("");
	print_deferred();
end

------------------
-- TBS Nonsense --
------------------

--force_tbs = false;
function forceTBS()
	if force_tbs then
		local pointer = mainmemory.read_u32_be(getPlayerObject() + lock_method_1_pointer);
		if pointer > 0x80000000 and pointer < 0x807FFFFF then
			print("Forcing TBS");
			mainmemory.write_u32_be(getPlayerObject() + lock_method_1_pointer, 0x00000000);
		end
	end
end
event.onframestart(forceTBS, "ScriptHawk - Force TBS");

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 15, 20, 35, 50, 100 };
Game.speedy_index = 8;

Game.rot_speed = 10;
Game.max_rot_units = 4096;

function Game.isPhysicsFrame()
	return not emu.islagged();
end

function isInSubGame()
	return map_value == arcade_map or map_value == jetpac_map;
end

function Game.getFloor() -- TODO: Got errors with this when exiting tiny temple
	return mainmemory.readfloat(getPlayerObject() + floor, true);
end

function Game.getDistanceFromFloor()
	return mainmemory.readfloat(getPlayerObject() + distance_from_floor, true);
end

--------------
-- Position --
--------------

function Game.getXPosition()
	if map_value == arcade_map then
		return mainmemory.readfloat(jumpman_position[1], true);
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(jetman_position[1], true);
	end
	return mainmemory.readfloat(getPlayerObject() + x_pos, true);
end

function Game.getYPosition()
	if map_value == arcade_map then
		return mainmemory.readfloat(jumpman_position[2], true);
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(jetman_position[2], true);
	end
	return mainmemory.readfloat(getPlayerObject() + y_pos, true);
end

function Game.getZPosition()
	if not isInSubGame() then
		return mainmemory.readfloat(getPlayerObject() + z_pos, true);
	end
	return 0;
end

function Game.setXPosition(value)
	if map_value == arcade_map then
		--mainmemory.writefloat(jumpman_position[1], value, true);
	elseif map_value == jetpac_map then
		--mainmemory.writefloat(jetman_position[1], value, true);
	else
		mainmemory.writefloat(getPlayerObject() + x_pos, value, true);
		mainmemory.writebyte(getPlayerObject() + locked_to_pad, 0x00);
		mainmemory.write_u32_be(getPlayerObject() + lock_method_1_pointer, 0x00);
	end
end

function Game.setYPosition(value)
	if map_value == arcade_map then
		--mainmemory.writefloat(jumpman_position[2], value, true);
	elseif map_value == jetpac_map then
		--mainmemory.writefloat(jetman_position[2], value, true);
	else
		mainmemory.writefloat(getPlayerObject() + y_pos, value, true);
		mainmemory.writebyte(getPlayerObject() + locked_to_pad, 0x00);
	end
end

function Game.setZPosition(value)
	if not isInSubGame() then
		mainmemory.writefloat(getPlayerObject() + z_pos, value, true);
		mainmemory.writebyte(getPlayerObject() + locked_to_pad, 0x00);
		mainmemory.write_u32_be(getPlayerObject() + lock_method_1_pointer, 0x00);
	end
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	if not isInSubGame() then
		return mainmemory.read_u16_be(getPlayerObject() + x_rot);
	end
	return 0;
end

function Game.getYRotation()
	if not isInSubGame() then
		return mainmemory.read_u16_be(getPlayerObject() + y_rot);
	end
	return 0;
end

function Game.colorYRotation()
	local currentRotation = Game.getYRotation()
	if currentRotation > 4095 then -- Detect STVW angles
		return 0xFF007FFF;
	end
end

function Game.getZRotation()
	if not isInSubGame() then
		return mainmemory.read_u16_be(getPlayerObject() + z_rot);
	end
	return 0;
end

function Game.setXRotation(value)
	if not isInSubGame() then
		mainmemory.write_u16_be(getPlayerObject() + x_rot, value);
	end
end

function Game.setYRotation(value)
	if not isInSubGame() then
		mainmemory.write_u16_be(getPlayerObject() + y_rot, value);
	end
end

function Game.setZRotation(value)
	if not isInSubGame() then
		mainmemory.write_u16_be(getPlayerObject() + z_rot, value);
	end
end

-----------------------------
-- Velocity & Acceleration --
-----------------------------

function Game.getVelocity()
	local playerObject = getPlayerObject();
	if map_value == arcade_map then
		return mainmemory.readfloat(jumpman_velocity[1], true);
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(jetman_velocity[1], true);
	elseif isRDRAM(playerObject) then
		return mainmemory.readfloat(playerObject + velocity, true);
	end
	return 0;
end

function Game.setVelocity(value)
	local playerObject = getPlayerObject();
	if map_value == arcade_map then
		mainmemory.writefloat(jumpman_velocity[1], value, true);
	elseif map_value == jetpac_map then
		mainmemory.writefloat(jetman_velocity[1], value, true);
	elseif isRDRAM(playerObject) then
		mainmemory.writefloat(playerObject + velocity, value, true);
	end
end

--function Game.getAcceleration()
--	if not isInSubGame() then
--		local playerObject = getPlayerObject();
--		if isRDRAM(playerObject) then
--			return mainmemory.readfloat(playerObject + acceleration, true);
--		end
--	end
--	return 0;
--end

function Game.getYVelocity()
	local playerObject = getPlayerObject();
	if map_value == arcade_map then
		return mainmemory.readfloat(jumpman_velocity[2], true);
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(jetman_velocity[2], true);
	elseif isRDRAM(playerObject) then
		return mainmemory.readfloat(playerObject + y_velocity, true);
	end
	return 0;
end

function Game.setYVelocity(value)
	local playerObject = getPlayerObject();
	if map_value == arcade_map then
		mainmemory.writefloat(jumpman_velocity[2], value, true);
	elseif map_value == jetpac_map then
		mainmemory.writefloat(jetman_velocity[2], value, true);
	elseif isRDRAM(playerObject) then
		mainmemory.writefloat(playerObject + y_velocity, value, true);
	end
end

function Game.getYAcceleration()
	if not isInSubGame() then
		local playerObject = getPlayerObject();
		if isRDRAM(playerObject) then
			return mainmemory.readfloat(playerObject + y_acceleration, true);
		end
	end
	return 0;
end

--------------------
-- Misc functions --
--------------------

local function invisify()
	local playerObject = getPlayerObject();
	if isRDRAM(playerObject) then
		local visibilityBitfieldValue = mainmemory.readbyte(playerObject + visibility);
		mainmemory.writebyte(playerObject + visibility, clear_bit(visibilityBitfieldValue, 2));
	end
end

local function visify()
	local playerObject = getPlayerObject();
	if isRDRAM(playerObject) then
		local visibilityBitfieldValue = mainmemory.readbyte(playerObject + visibility);
		mainmemory.writebyte(playerObject + visibility, set_bit(visibilityBitfieldValue, 2));
	end
end

local current_invisify = "Invisify";
local function toggle_invisify()
	if current_invisify == "Invisify" then
		invisify();
	else
		visify();
	end
end

local function updateCurrentInvisify()
	local playerObject = getPlayerObject();
	if isRDRAM(playerObject) then
		local isVisible = check_bit(mainmemory.readbyte(playerObject + visibility), 2);
		if isVisible then
			current_invisify = "Invisify";
		else
			current_invisify = "Visify";
		end
		forms.settext(ScriptHawkUI.form_controls["Toggle Invisify Button"], current_invisify);
	end
end

local function clear_tb_void()
	local tb_void_byte_val = mainmemory.readbyte(Game.Memory.tb_void_byte[version]);
	tb_void_byte_val = set_bit(tb_void_byte_val, 4); -- Show Object Model 2 Objects
	tb_void_byte_val = set_bit(tb_void_byte_val, 5); -- Turn on the lights
	mainmemory.writebyte(Game.Memory.tb_void_byte[version], tb_void_byte_val);
end

function force_pause()
	local voidByteValue = mainmemory.readbyte(Game.Memory.tb_void_byte[version]);
	mainmemory.writebyte(Game.Memory.tb_void_byte[version], set_bit(voidByteValue, 0));
end

function force_zipper()
	local voidByteValue = mainmemory.readbyte(Game.Memory.tb_void_byte[version] - 1);
	mainmemory.writebyte(Game.Memory.tb_void_byte[version] - 1, set_bit(voidByteValue, 0));
end

-----------------------------------
-- DK64 - ISG Timer
-- Written by Isotarge, 2015
-- Based on research by Exchord
-----------------------------------

local timer_value = 0;
local timer_start_frame = 0;
local timer_started = false;

local function timer()
	if map_value == 153 and prev_map ~= 153 then
		timer_value = 0;
		timer_start_frame = emu.framecount();
		timer_started = true;
	end
	prev_map = map_value;

	if timer_started then
		timer_value = emu.framecount() - timer_start_frame;
	end

	if timer_value / 60 > 270 or timer_value < 0 then
		timer_value = 0;
		timer_start_frame = 0;
		timer_started = false;
	end

	if timer_started then
		local s = timer_value / 60;
		local timer_string = string.format("%.2d:%05.2f", s / 60 % 60, s % 60);
		gui.text(16, 16, "ISG Timer: "..timer_string, nil, nil, 'topright');
	else
		gui.text(16, 16, "Waiting for ISG", nil, nil, 'topright');
	end
end

-----------------------------------
-- DK64 - Mad Jack Minimap
-- Written by Isotarge, 2014-2015
-----------------------------------
image_directory_root = ".\\Images\\"; -- TODO: Move this to ScriptHawk.lua, it'll probably be useful in other places eventually

-- Colors (ARGB)
local MJ_blue         = 0x7F00A2E8;
local MJ_blue_switch  = 0xFF00A2E8;
local MJ_white        = 0x7FFFFFFF;
local MJ_white_switch = 0xFFFFFFFF;

-- Minimap ui
local MJ_minimap_x_offset  = 19;
local MJ_minimap_y_offset  = 19;
local MJ_minimap_width     = 16;
local MJ_minimap_height    = 16;

local MJ_minimap_text_x = MJ_minimap_x_offset + 4.5 * MJ_minimap_width;
local MJ_minimap_text_y = MJ_minimap_y_offset;

local MJ_minimap_phase_number_y      = MJ_minimap_text_y;
local MJ_minimap_actions_remaining_y = MJ_minimap_phase_number_y + MJ_minimap_height;
local MJ_time_until_next_action_y    = MJ_minimap_actions_remaining_y + MJ_minimap_height;

local MJ_kong_row_y                  = MJ_time_until_next_action_y + MJ_minimap_height;
local MJ_kong_col_y                  = MJ_kong_row_y + MJ_minimap_height;

local function position_to_rowcol(pos)
	pos = math.floor((pos - 330) / 120); -- Calculate row index
	return math.min(7, math.max(0, pos)); -- Clamp between 0 and 7
end

local function get_kong_position()
	local x = Game.getXPosition();
	local z = Game.getZPosition();

	local colseg = position_to_rowcol(z);
	local rowseg = position_to_rowcol(x);

	local col = math.floor(colseg / 2);
	local row = math.floor(rowseg / 2);

	return {
		["x"] = x, ["z"] = z,
		["col"] = col, ["row"] = row,
		["col_seg"] = colseg, ["row_seg"] = rowseg
	};
end

local function MJ_get_col_mask(position)
	return bit.band(position, 0x03);
end

local function MJ_get_row_mask(position)
	return bit.rshift(bit.band(position, 0x0C), 2);
end

local function MJ_get_switch_active_mask(position)
	return bit.rshift(bit.band(position, 0x10), 4) > 0;
end

local function MJ_get_color(col, row)
	local color = 'blue';
	if row % 2 == col % 2 then
		color = 'white';
	end
	return color;
end

local function MJ_get_action_type(phase_byte)
	if phase_byte == 0x28 or phase_byte == 0x2D or phase_byte == 0x32 then
		return "Fireball";
	elseif phase_byte == 0x01 or phase_byte == 0x05 then
		return "Laser";
	end
	return "Jump";
end

local function MJ_get_phase(phase_byte)
	if phase_byte == 0x08 or phase_byte == 0x32 then
		return 1;
	elseif phase_byte == 0x0A or phase_byte == 0x2D then
		return 2;
	elseif phase_byte == 0x0B or phase_byte == 0x28 then
		return 3;
	elseif phase_byte == 0x0C or phase_byte == 0x05 then
		return 4;
	elseif phase_byte == 0x0E or phase_byte == 0x01 then
		return 5;
	end
	return 0;
end

local function MJ_get_arrow_image(current, new)
	if new.row > current.row then
		if new.col > current.col then
			return image_directory_root.."up_right.png";
		elseif new.col == current.col then
			return image_directory_root.."up.png";
		elseif new.col < current.col then
			return image_directory_root.."up_left.png";
		end
	elseif new.row == current.row then
		if new.col > current.col then
			return image_directory_root.."right.png";
		elseif new.col < current.col then
			return image_directory_root.."left.png";
		end
	elseif new.row < current.row then
		if new.col > current.col then
			return image_directory_root.."down_right.png";
		elseif new.col == current.col then
			return image_directory_root.."down.png";
		elseif new.col < current.col then
			return image_directory_root.."down_left.png";
		end
	end
	return image_directory_root.."question-mark.png";
end

local function MJ_parse_position(position)
	return {
		["active"] = MJ_get_switch_active_mask(position),
		["col"] = MJ_get_col_mask(position),
		["row"] = MJ_get_row_mask(position),
	};
end

local function draw_mj_minimap()
	-- Only draw minimap if the player is in the Mad Jack fight
	if version ~= 4 and map_value == mad_jack_map then
		local MJ_state = mainmemory.read_u24_be(Game.Memory.boss_pointer[version] + 1);

		local cur_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_current_pos));
		local next_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_next_pos));

		local white_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_white_switch_pos));
		local blue_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_blue_switch_pos));

		local switches_active = white_pos.active or blue_pos.active;

		local x, y, color;

		gui.clearGraphics();

		local kong_position = get_kong_position();

		for row = 0, 3 do
			for	col = 0, 3 do
				x = MJ_minimap_x_offset + col * MJ_minimap_width;
				y = MJ_minimap_y_offset + (3 - row) * MJ_minimap_height;

				color = MJ_blue;
				if MJ_get_color(col, row) == 'white' then
					color = MJ_white;
				end

				if switches_active then
					if white_pos.row == row and white_pos.col == col and MJ_get_color(cur_pos.col, cur_pos.row) == 'white' then
						color = MJ_white_switch;
					elseif blue_pos.row == row and blue_pos.col == col and MJ_get_color(cur_pos.col, cur_pos.row) == 'blue' then
						color = MJ_blue_switch;
					end
				end

				gui.drawRectangle(x, y, MJ_minimap_width, MJ_minimap_height, 0, color);

				if switches_active then
					if (white_pos.row == row and white_pos.col == col) or (blue_pos.row == row and blue_pos.col == col) then
						gui.drawImage(image_directory_root.."switch.png", x, y, MJ_minimap_width, MJ_minimap_height);
						--gui.drawText(x, y, "S");
					end
				end

				if cur_pos.row == row and cur_pos.col == col then
					gui.drawImage(image_directory_root.."jack_icon.png", x, y, MJ_minimap_width, MJ_minimap_height);
					--gui.drawText(x, y, "J")
				elseif next_pos.row == row and next_pos.col == col then
					gui.drawImage(MJ_get_arrow_image(cur_pos, next_pos), x, y, MJ_minimap_width, MJ_minimap_height);
					--gui.drawText(x, y, "N");
				end

				if kong_position.row == row and kong_position.col == col then
					gui.drawImage(image_directory_root.."TinyFaceEdited.png", x, y, MJ_minimap_width, MJ_minimap_height);
					--gui.drawText(x, y, "K");
				end
			end
		end

		-- Text info
		local phase_byte = mainmemory.readbyte(MJ_state + MJ_action_type);
		local actions_remaining = mainmemory.readbyte(MJ_state + MJ_actions_remaining);
		local time_until_next_action = mainmemory.readbyte(MJ_state + MJ_time_until_next_action);

		local phase = MJ_get_phase(phase_byte);
		local action_type = MJ_get_action_type(phase_byte);

		gui.drawText(MJ_minimap_text_x, MJ_minimap_actions_remaining_y, actions_remaining.." "..action_type.."s remaining");

		if action_type ~= "Jump" then
			gui.drawText(MJ_minimap_text_x, MJ_minimap_phase_number_y , "Phase "..phase.." (switch)");
			gui.drawText(MJ_minimap_text_x, MJ_time_until_next_action_y, time_until_next_action.." ticks until next "..action_type);
		else
			gui.drawText(MJ_minimap_text_x, MJ_minimap_phase_number_y , "Phase "..phase);
		end
	end
end

------------------------------------
-- Never Slip                     --
-- Written by Isotarge, 2014-2015 --
------------------------------------

-- Relative to slope object
local slope_timer = 0xC3;

local function neverSlip()
	if version == 1 then -- TODO: PAL, JP, Kiosk
		-- Patch the slope timer
		local slopeObject = mainmemory.read_u32_be(Game.Memory.slope_object_pointer[version]);
		if isPointer(slopeObject) then
			slopeObject = slopeObject - 0x80000000;
			mainmemory.writebyte(slopeObject + slope_timer, 0);
		end
	end
end

-----------------------
-- Bone Displacement --
-----------------------

local bone_displacement_fix = false;

local function fixBoneDisplacement()
	bone_displacement_fix = true;
end

local function breakBoneDisplacement()
	bone_displacement_fix = false;
end

event.onloadstate(breakBoneDisplacement, "ScriptHawk - Break bone displacement");

local function applyBoneDisplacementFix()
	if version ~= 4 then -- TODO: Kiosk
		-- Old fix basically crashes sound thread, seems to work well but... no sound.
		mainmemory.write_u32_be(Game.Memory.bone_displacement_pointer[version], 0);
	end
end

-----------------------
-- Lag configuration --
-----------------------

local min_lag_factor = -30;
local max_lag_factor = 20;
local lag_factor = 1;

local function increase_lag_factor()
	lag_factor = math.min(max_lag_factor, lag_factor + 1);
end

local function decrease_lag_factor()
	lag_factor = math.max(min_lag_factor, lag_factor - 1);
end

local function fix_lag()
	if version ~= 4 then -- TODO: Kiosk
		local frames_real_value = mainmemory.read_u32_be(Game.Memory.frames_real[version]);
		mainmemory.write_u32_be(Game.Memory.frames_lag[version], frames_real_value - lag_factor);
	end
end

----------------
-- Moon stuff --
----------------

local moon_mode = "None";
local function toggle_moonmode()
	if moon_mode == 'None' then
		moon_mode = 'Kick';
	elseif moon_mode == 'Kick' then
		moon_mode = 'All';
	elseif moon_mode == 'All' then
		moon_mode = 'None';
	end
	Game.eachFrame();
end

-----------------------
-- Effect byte stuff --
-----------------------

function everythingIsKong()
	local kongSharedModel = mainmemory.read_u32_be(getPlayerObject() + model_pointer);

	if not isPointer(kongSharedModel) then
		print("This ain't gonna work...");
		return;
	end

	local kongNumBones = mainmemory.readbyte(kongSharedModel - 0x80000000 + num_bones);

	local cameraObject = mainmemory.read_u24_be(Game.Memory.camera_pointer[version] + 1);
	local actorListIndex = 0;

	for actorListIndex = 0, max_objects do
		local pointer = mainmemory.read_u24_be(Game.Memory.pointer_list[version] + (actorListIndex * 4) + 1);
		local objectFound = isRDRAM(pointer);

		if objectFound and (pointer ~= cameraObject) then
			local modelPointer = mainmemory.read_u24_be(pointer + model_pointer + 1);
			local hasModel = isRDRAM(modelPointer);

			local actorType = mainmemory.read_u32_be(pointer + actor_type);
			-- TODO: Merge this table from Grab Objects.lua
			--if type(actor_types[actorType]) ~= nil then
			--	actorType = actor_types[actorType];
			--end

			if hasModel then
				local numBones = mainmemory.readbyte(modelPointer + num_bones);
				if numBones <= kongNumBones then
					mainmemory.write_u32_be(pointer + model_pointer, kongSharedModel);
					print("Wrote: "..toHexString(pointer).." Bones: "..numBones.." Type: "..actorType);
				end
			end
		end
	end
end

function Game.setScale(value)
	for i = 1, #scale do
		mainmemory.writefloat(getPlayerObject() + scale[i], value, true);
	end
end

function Game.randomEffect()
	-- Randomly manipulate the effect byte
	local randomEffect = math.random(0, 0xFFFF);
	mainmemory.write_u16_be(getPlayerObject() + effect_byte, randomEffect);

	-- Randomly resize the kong
	local scaleValue = 0.01 + math.random() * 0.49;
	Game.setScale(scaleValue);

	print("Activated effect: "..bizstring.binary(randomEffect).." with scale "..scaleValue);
end

----------------
-- Paper Mode --
----------------

paper_thickness = 0.015;

function paperMode()
	local actorListIndex = 0;
	local cameraObject = mainmemory.read_u24_be(Game.Memory.camera_pointer[version] + 1);

	for actorListIndex = 0, max_objects do
		local pointer = mainmemory.read_u24_be(Game.Memory.pointer_list[version] + (actorListIndex * 4) + 1);
		local objectFound = isRDRAM(pointer);

		if objectFound and pointer ~= cameraObject then
			local objectRenderingParameters = mainmemory.read_u24_be(pointer + rendering_parameters_pointer + 1);
			if isRDRAM(objectRenderingParameters) then
				mainmemory.writefloat(objectRenderingParameters + scale_z, paper_thickness, true);
			end
		end
	end
end

---------------
-- BRB Stuff --
---------------

local jp_charset = {
--   0    1    2    3    4    5    6    7    8    9
	"\0", "\0", "$", "(", ")", "\0", "%", "「", "」", "`", -- 0
	"\0", "<", ">", "&", "~", " ", "0", "1", "2", "3", -- 1
	"4", "5", "6", "7", "8", "9", "A", "B", "C", "D", -- 2
	"E", "F", "G", "H", "I", "J", "K", "\0", "M", "N", -- 3
	"O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", -- 4
	"Y", "Z", "!", "\"", "#", "'", "*", "+", ",", "-", -- 5
	".", "/", ":", "=", "?", "@", "。", "゛", " ", "ァ", -- 6
	"ィ", "ゥ", "ェ", "ォ", "ッ", "ャ", "ュ", "ョ", "ヲ", "ン", -- 7
	"ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ", -- 8
	"サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト", -- 9
	"ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", -- 10
	"マ", "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", -- 11
	"ル", "レ", "ロ", "ワ", "ガ", "ギ", "グ", "ゲ", "ゴ", "ザ", -- 12
	"ジ", "ズ", "ゼ", "ゾ", "ダ", "ヂ", "ヅ", "デ", "ド", "バ", -- 13
	"ビ", "ブ", "ベ", "ボ", "パ", "ピ", "プ", "ペ", "ポ", "a", -- 14
	"b", "c", "d", "e", "f", "g", "h", "i", "j", "k", -- 15
	"l", "m", "n", "o", "p", "q", "r", "s", "t", "u", -- 16
	"v", "w", "x", "y", "z", "ぁ", "ぃ", "ぅ", "ぇ", "ぉ", -- 17
	"っ", "ゃ", "ゅ", "ょ", "を", "ん", "あ", "い", "う", "え", -- 18
	"お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", -- 19
	"そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", -- 20
	"の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", -- 21
	"も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", -- 22
	"が", "ぎ", "ぐ", "げ", "ご", "ざ", "じ", "ず", "ぜ", "ぞ", -- 23
	"だ", "ぢ", "づ", "で", "ど", "ば", "び", "ぶ", "べ", "ぼ", -- 24
	"ぱ", "ぴ", "ぷ", "ぺ", "ぽ", "ヴ" -- 25
};

local function toJPString(value)
	local length = string.len(value);
	local tempString = "";
	local char;
	local charFound = false;
	for i = 1, length do
		char = bizstring.substring(value, i - 1, 1); -- TODO: call string.sub() instead, how do params work?
		charFound = false;
		for j = 1, #jp_charset do
			if jp_charset[j] == char then
				tempString = tempString..string.char(j - 1);
				charFound = true;
				break;
			end
		end
		if charFound == false then
			dprint("JP String parse warning: Didn't find character for '"..char..'\'');
		end
	end
	print_deferred();
	return tempString;
end

local brb_message_max_length = 79;
brb_message = "BRB";
is_brb = false;

function brb(value)
	local message = value or "BRB";
	if version == 3 then -- JP
		message = toJPString(message);
	else
		message = string.upper(message);
	end
	if version ~= 4 then -- TODO: Not Kiosk
		brb_message = message;
		is_brb = true;
	else
		print("Not supported in this version.");
	end
end

function back()
	is_brb = false;
end

local function do_brb()
	if is_brb then
		mainmemory.writebyte(Game.Memory.security_byte[version], 0x01);
		local messageLength = math.min(string.len(brb_message), brb_message_max_length);
		for i = 1, messageLength do
			mainmemory.writebyte(Game.Memory.security_message[version] + i - 1, string.byte(brb_message, i));
		end
		mainmemory.writebyte(Game.Memory.security_message[version] + messageLength, 0x00);
	end
end

-------------------
-- For papa cfox --
-------------------

local list_previous_pointer = 0x00; -- pointer
local list_size = 0x04; -- u32_be

max_length = 0x40;

function setText(pointer, message)
	local messageLength = math.min(string.len(message), max_length);
	for i = 1, messageLength do
		mainmemory.writebyte(pointer + i - 1, string.byte(message, i));
	end
	mainmemory.writebyte(pointer + messageLength, 0x00);
end

function setDKTV(message)
	local linkedListRoot = mainmemory.read_u24_be(Game.Memory.linked_list_pointer[version] + 1);
	local linkedListSize = mainmemory.read_u32_be(Game.Memory.linked_list_pointer[version] + 4);
	local totalSize = 0;
	local currentPointer = linkedListRoot;
	while totalSize < linkedListSize do
		local currentObjectSize = mainmemory.read_u32_be(currentPointer + 4);
		currentPointer = currentPointer + 0x10;
		if currentObjectSize == 0x40 then
			if mainmemory.read_u32_be(currentPointer) == 0x444B2054 then
				setText(currentPointer, message);
			end
		end
		currentPointer = currentPointer + currentObjectSize;
		totalSize = currentPointer - linkedListRoot;
	end
end

--------------------------
-- Free Trade Agreement --
--------------------------

local obj_model2_slot_size = 0x90;
local obj_model2_collectable_state = 0x8C; -- byte long bitfield

BalloonStates = {
	[DK] = 114,
	[Diddy] = 91,
	[Lanky] = 113,
	[Tiny] = 112,
	[Chunky] = 111,
};

KasplatStates = {
	[DK] = 241,
	[Diddy] = 242,
	[Lanky] = 243,
	[Tiny] = 244,
	[Chunky] = 245,
}

function isBalloon(actorType)
	return array_contains(BalloonStates, actorType)
end

function isKasplat(actorType)
	return actorType >= 241 and actorType <= 245;
end

function isKong(actorType)
	return actorType >= 2 and actorType <= 6;
end

function freeTradeObjectModel1(currentKong)
	for object_no = 0, max_objects do
		local pointer = mainmemory.read_u24_be(Game.Memory.pointer_list[version] + (object_no * 4) + 1);
		if isRDRAM(pointer) then
			local actorType = mainmemory.read_u32_be(pointer + actor_type);
			if isKasplat(actorType) then
				-- Fix which blueprint the Kasplat drops
				mainmemory.write_u32_be(pointer + actor_type, KasplatStates[currentKong]);
			end
			if isBalloon(actorType) then
				-- Fix balloon color
				mainmemory.write_u32_be(pointer + actor_type, BalloonStates[currentKong]);
			end
		end
	end
end

local collisionTypes = {
	[0x000A] = "CB Single (A)",
	[0x000D] = "CB Single (D)",
	[0x0011] = "Homing Ammo Crate",
	[0x0016] = "CB Single (16)",
	[0x001C] = "Coin (1C)",
	[0x001D] = "Coin (1D)",
	[0x001E] = "CB Single (1E)",
	[0x001F] = "CB Single (1F)",
	[0x0023] = "Coin (23)",
	[0x0024] = "Coin (24)",
	[0x0027] = "Coin (27)",
	[0x002B] = "CB Bunch (2B)",
	[0x0056] = "Orange",
	[0x0074] = "GB (Tiny)",
	[0x008E] = "Crystal Coconut",
	[0x008F] = "Ammo Crate",
	[0x0098] = "Film",
	[0x0205] = "CB Bunch (205)",
	[0x0206] = "CB Bunch (206)",
	[0x0207] = "CB Bunch (207)",
	[0x0208] = "CB Bunch (208)",
};

function fixSingleCollision(objectBase)
	local currentCollisionValue = mainmemory.read_u16_be(objectBase + 4);
	if isKong(currentCollisionValue) then
		mainmemory.write_u16_be(objectBase + 4, 0); -- Set the collision to accept the any Kong
		-- TODO: Is setting 0 here safe?
		-- It'll be faster, yeah but safe idk
	end
end

function freeTradeCollisionListBackboneMethod(currentKong)
	local object = mainmemory.read_u24_be(Game.Memory.linked_list_pointer[version] + 1);
	while isRDRAM(object) do
		size = mainmemory.read_u32_be(object + 4);
		if size == 0x20 then
			fixSingleCollision(object + 0x10);
		end
		object = object + 0x10 + size;
	end
end

function dumpCollisionTypes()
	local object = mainmemory.read_u24_be(Game.Memory.linked_list_pointer[version] + 1);
	while isRDRAM(object) do
		size = mainmemory.read_u32_be(object + 4);
		if size == 0x20 then
			local collisionType = mainmemory.read_u16_be(object + 0x10 + 0x02);
			if collisionTypes[collisionType] ~= nil then
				collisionType = collisionTypes[collisionType];
			else
				collisionType = toHexString(collisionType, 4);
			end
			dprint(toHexString(object + 0x10)..": "..collisionType);
		end
		object = object + 0x10 + size;
	end
	print_deferred();
end

function replaceCollisionType(target, desired)
	local object = mainmemory.read_u24_be(Game.Memory.linked_list_pointer[version] + 1);
	while isRDRAM(object) do
		size = mainmemory.read_u32_be(object + 4);
		if size == 0x20 then
			local collisionType = mainmemory.read_u16_be(object + 0x10 + 0x02);
			if collisionType == target then
				mainmemory.write_u16_be(object + 0x10 + 0x02, desired);
			end
		end
		object = object + 0x10 + size;
	end
end

local previousCollisionLinkedListPointer = 0;
function freeTradeCollisionList(currentKong)
	if version ~= 4 then
		-- This call resolves the pointer to the object that contains a pointer to the linked list of collision data
		local currentCollisionLinkedListPointer = mainmemory.read_u32_be(Game.Memory.obj_model2_collision_linked_list_pointer[version]);
		if currentCollisionLinkedListPointer ~= previousCollisionLinkedListPointer and isPointer(currentCollisionLinkedListPointer) then
			freeTradeCollisionListBackboneMethod(currentKong);
		end
		previousCollisionLinkedListPointer = currentCollisionLinkedListPointer;
	end
end

GBStates = {
	[DK] = 0x28,
	[Diddy] = 0x22,
	[Lanky] = 0x30,
	[Tiny] = 0x24,
	[Chunky] = 0x21,
};

function isGB(collectableState)
	return array_contains(GBStates, collectableState);
end

-- TODO: Sort this object model 2 constants mess out
local obj_model2_behavior_type_pointer = 0x24;

function getScriptName(objectModel2Base)
	local behaviorTypePointer = mainmemory.read_u32_be(objectModel2Base + obj_model2_behavior_type_pointer);
	if isPointer(behaviorTypePointer) then
		return readNullTerminatedString(behaviorTypePointer - 0x80000000 + 0x0C);
	end
	return "";
end

BulletChecks = {
	[DK] = 0x0030,
	[Diddy] = 0x0024,
	[Lanky] = 0x002A,
	[Tiny] = 0x002B,
	[Chunky] = 0x0026,
};

function isBulletCheck(value)
	return array_contains(BulletChecks, value);
end

SimSlamChecks = {
	[DK] = 0x0002,
	[Diddy] = 0x0003,
	[Lanky] = 0x0004,
	[Tiny] = 0x0005,
	[Chunky] = 0x0006,
};

function isSimSlamCheck(value)
	return array_contains(SimSlamChecks, value);
end

function ohWrongnana()
	if version ~= 4 then -- Anything but Kiosk
		local objModel2Array = mainmemory.read_u24_be(Game.Memory.obj_model2_array_pointer[version] + 1);
		local numSlots = mainmemory.read_u32_be(Game.Memory.obj_model2_array_count[version]);
		local currentKong = mainmemory.readbyte(Game.Memory.character[version]);
		local scriptName, slotBase, currentValue, activationScript, earlyCheckValue, lateCheckValue;
		-- Fill and sort pointer list
		for i = 0, numSlots - 1 do
			slotBase = objModel2Array + i * obj_model2_slot_size;
			currentValue = mainmemory.readbyte(slotBase + obj_model2_collectable_state);
			if isGB(currentValue) then
				mainmemory.writebyte(slotBase + obj_model2_collectable_state, GBStates[currentKong]);
			end
			scriptName = getScriptName(slotBase);
			if scriptName == "gunswitches" or scriptName == "buttons" then
				-- Get activation script
				activationScript = mainmemory.read_u32_be(slotBase + 0x7C);
				if isPointer(activationScript) then
					activationScript = activationScript - 0x80000000;
					-- Get part 2
					activationScript = mainmemory.read_u32_be(activationScript + 0xA0);
					while isPointer(activationScript) do
						activationScript = activationScript - 0x80000000;
						earlyCheckValue = mainmemory.read_u16_be(activationScript + 0x0C);
						lateCheckValue = mainmemory.read_u16_be(activationScript + 0x24);
						-- Check for the bullet magic and patch if needed
						if isBulletCheck(earlyCheckValue) then
							mainmemory.write_u16_be(activationScript + 0x0C, BulletChecks[currentKong]);
						end
						-- Check for the simslam magic and patch if needed
						if isSimSlamCheck(earlyCheckValue) then
							mainmemory.write_u16_be(activationScript + 0x0C, SimSlamChecks[currentKong]);
						end
						if isSimSlamCheck(lateCheckValue) then
							mainmemory.write_u16_be(activationScript + 0x24, SimSlamChecks[currentKong]);
						end
						-- Get next script chunk
						activationScript = mainmemory.read_u32_be(activationScript + 0x4C);
					end
				end
			end
		end

		freeTradeObjectModel1(currentKong);
		freeTradeCollisionList(currentKong);
	end
end

----------------
-- ASM Loader --
----------------

-- Output gameshark code
function outputGamesharkCode(bytes, base, skipZeroes)
	skipZeroes = skipZeroes or false;
	skippedZeroes = 0;
	if type(bytes) == "table" and #bytes > 0 and #bytes % 2 == 0 then
		for i = 1, #bytes, 2 do
			if not (skipZeroes and bytes[i] == 0x00 and bytes[i + 1] == 0x00) then
				dprint("81"..toHexString(base + i - 1, 6, "").." "..toHexString(bytes[i], 2, "")..toHexString(bytes[i + 1], 2, ""));
			else
				skippedZeroes = skippedZeroes + 1;
			end
		end
	end
	return skippedZeroes;
end

local hookBase = 0x7494; -- TODO: Other versions
local codeBase = 0x7FF500;
local maxCodeSize = 0xAFF;

local hook = {
	0x3C, 0x08, 0x80, 0x7F, 0x35, 0x08, 0xF5, 0x00,
	0x01, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00
};
local code = {};

function codeWriter(...)
	table.insert(code, tonumber(arg[2], 16));
end

function loadASMPatch()
	local code_filename = forms.openfile(nil, nil, "R4300i Assembly Code|*.asm|All Files (*.*)|*.*");
	if code_filename == "" then
		print("No code loaded, aborting mission...");
		return;
	end

	-- Open the file and assemble the code
	code = {};
	local result = Lips(code_filename, codeWriter);

	if #code == 0 then
		print(result);
		print("The code did not compile correctly, check for errors in your source.");
		return;
	end

	-- Patch the code
	for i = 1, #code do
		mainmemory.writebyte(codeBase + (i - 1), code[i]);
	end

	-- Patch the hook
	for i = 1, #hook do
		mainmemory.writebyte(hookBase + (i - 1), hook[i]);
	end

	outputGamesharkCode(hook, hookBase, false);
	outputGamesharkCode(code, codeBase, false);

	dprint("Patched code ("..(#code * 4).." bytes)");
	dprint("Patched hook ("..#hook.." bytes)");
	dprint("Done!");
	print_deferred();
end

----------------------
-- Framebuffer Jank --
----------------------

local framebuffer_size = 320 * 240; -- Oddly enough it's the same size on PAL

-- Pixel format: 16bit RGBA 5551
-- RRRR RGGG GGBB BBBA
local framebuffer_color_bit_constants = {
	["Red"] = 0x0800,
	["Green"] = 0x0040,
	["Blue"] = 0x0002,
};

function fillFB()
	local image_filename = forms.openfile(nil, nil, "All Files (*.*)|*.*");
	if image_filename == "" then
		print("No image selected. Exiting.");
		return;
	end
	input_file = assert(io.open(image_filename, "rb"));

	local frameBufferLocation = mainmemory.read_u24_be(Game.Memory.framebuffer_pointer[version] + 1);
	if isRDRAM(frameBufferLocation) then
		for i = 0, framebuffer_size - 1 do
			local r = math.floor(string.byte(input_file:read(1)) / 8) * framebuffer_color_bit_constants["Red"];
			local g = math.floor(string.byte(input_file:read(1)) / 8) * framebuffer_color_bit_constants["Green"];
			local b = math.floor(string.byte(input_file:read(1)) / 8) * framebuffer_color_bit_constants["Blue"];
			local a = 1;

			mainmemory.write_u16_be(frameBufferLocation + (i * 2), r + g + b + a);
			mainmemory.write_u16_be(frameBufferLocation + framebuffer_size + (i * 2), r + g + b + a);
		end
	end

	input_file:close();
end

------------
-- Events --
------------

local function unlock_moves()
	for kong = DK, Chunky do
		local base = Game.Memory.kong_base[version] + kong * 0x5E;
		mainmemory.writebyte(base + moves, 3);
		mainmemory.writebyte(base + sim_slam, 3);
		mainmemory.writebyte(base + weapon, 7);
		mainmemory.writebyte(base + instrument, 15);
	end

	-- Training barrels
	setFlagByName("Camera/Shockwave");
	setFlagByName("Training Grounds: Dive Barrel Completed");
	setFlagByName("Training Grounds: Orange Barrel Completed");
	setFlagByName("Training Grounds: Barrel Barrel Completed");
	setFlagByName("Training Grounds: Vine Barrel Completed");

	-- Kongs
	setFlagByName("Kong Unlocked: DK");
	setFlagByName("Kong Unlocked: Diddy");
	setFlagByName("Kong Unlocked: Lanky");
	setFlagByName("Kong Unlocked: Tiny");
	setFlagByName("Kong Unlocked: Chunky");
end

function Game.getMap()
	return mainmemory.read_u32_be(Game.Memory.map[version]);
end

function Game.setMap(value)
	if value >= 1 and value <= #Game.maps then
		mainmemory.write_u32_be(Game.Memory.map[version], value - 1);
	end
end

function Game.initUI()
	-- Flag stuff
	ScriptHawkUI.form_controls["Flag Dropdown"] = forms.dropdown(ScriptHawkUI.options_form, flag_names, ScriptHawkUI.col(0) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(7) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.col(9) + 7, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Set Flag Button"] = forms.button(ScriptHawkUI.options_form, "Set", flagSetButtonHandler, ScriptHawkUI.col(10), ScriptHawkUI.row(7), 59, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Clear Flag Button"] = forms.button(ScriptHawkUI.options_form, "Clear", flagClearButtonHandler, ScriptHawkUI.col(13) - 5, ScriptHawkUI.row(7), 59, ScriptHawkUI.button_height);

	-- Moon stuff
	ScriptHawkUI.form_controls["Moon Mode Label"] = forms.label(ScriptHawkUI.options_form, "Moon:", ScriptHawkUI.col(10), ScriptHawkUI.row(2) + ScriptHawkUI.label_offset, 48, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Moon Mode Button"] = forms.button(ScriptHawkUI.options_form, moon_mode, toggle_moonmode, ScriptHawkUI.col(13) - 20, ScriptHawkUI.row(2), 59, ScriptHawkUI.button_height);

	-- Buttons
	ScriptHawkUI.form_controls["Toggle Invisify Button"] = forms.button(ScriptHawkUI.options_form, "Invisify", toggle_invisify, ScriptHawkUI.col(7), ScriptHawkUI.row(1), 64, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Clear TB Void Button"] = forms.button(ScriptHawkUI.options_form, "Clear TB void", clear_tb_void, ScriptHawkUI.col(10), ScriptHawkUI.row(1), ScriptHawkUI.col(4) + 8, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Unlock Moves Button"] = forms.button(ScriptHawkUI.options_form, "Unlock Moves", unlock_moves, ScriptHawkUI.col(10), ScriptHawkUI.row(4), ScriptHawkUI.col(4) + 8, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Random Color"] = forms.button(ScriptHawkUI.options_form, "Random Color", Game.setKongColor, ScriptHawkUI.col(5), ScriptHawkUI.row(5), ScriptHawkUI.col(4) + 8, ScriptHawkUI.button_height);

	--ScriptHawkUI.form_controls["Everything is Kong Button"] = forms.button(ScriptHawkUI.options_form, "Kong", everythingIsKong, ScriptHawkUI.col(10), ScriptHawkUI.row(3), ScriptHawkUI.col(4) + 8, ScriptHawkUI.button_height);
	--ScriptHawkUI.form_controls["Force Pause Button"] = forms.button(ScriptHawkUI.options_form, "Force Pause", force_pause, ScriptHawkUI.col(10), ScriptHawkUI.row(4), ScriptHawkUI.col(4) + 8, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Force Zipper Button"] = forms.button(ScriptHawkUI.options_form, "Force Zipper", force_zipper, ScriptHawkUI.col(5), ScriptHawkUI.row(4), ScriptHawkUI.col(4) + 8, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Fix Bone Displacement Button"] = forms.button(ScriptHawkUI.options_form, "Fix Spiking", fixBoneDisplacement, ScriptHawkUI.col(10), ScriptHawkUI.row(0), ScriptHawkUI.col(4) + 8, ScriptHawkUI.button_height);
	--ScriptHawkUI.form_controls["Random Effect Button"] = forms.button(ScriptHawkUI.options_form, "Random effect", random_effect, ScriptHawkUI.col(10), ScriptHawkUI.row(6), ScriptHawkUI.col(4) + 8, ScriptHawkUI.button_height);

	-- Lag fix
	ScriptHawkUI.form_controls["Decrease Lag Factor Button"] = forms.button(ScriptHawkUI.options_form, "-", decrease_lag_factor, ScriptHawkUI.col(13) - 7, ScriptHawkUI.row(6), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Increase Lag Factor Button"] = forms.button(ScriptHawkUI.options_form, "+", increase_lag_factor, ScriptHawkUI.col(13) + ScriptHawkUI.button_height - 7, ScriptHawkUI.row(6),ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Lag Factor Value Label"] = forms.label(ScriptHawkUI.options_form, "0", ScriptHawkUI.col(13) + ScriptHawkUI.button_height + 21, ScriptHawkUI.row(6) + ScriptHawkUI.label_offset, 54, 14);
	ScriptHawkUI.form_controls["Toggle Lag Fix Checkbox"] = forms.checkbox(ScriptHawkUI.options_form, "Lag fix", ScriptHawkUI.col(10) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(6) + ScriptHawkUI.dropdown_offset);

	-- Checkboxes
	ScriptHawkUI.form_controls["Toggle Homing Ammo Checkbox"] = forms.checkbox(ScriptHawkUI.options_form, "Homing Ammo", ScriptHawkUI.col(0) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(6) + ScriptHawkUI.dropdown_offset);
	--ScriptHawkUI.form_controls["Toggle Neverslip Checkbox"] = forms.checkbox(ScriptHawkUI.options_form, "Never Slip", ScriptHawkUI.col(10) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(5) + ScriptHawkUI.dropdown_offset);
	ScriptHawkUI.form_controls["Toggle Paper Mode Checkbox"] = forms.checkbox(ScriptHawkUI.options_form, "Paper Mode", ScriptHawkUI.col(10) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(5) + ScriptHawkUI.dropdown_offset);
	--ScriptHawkUI.form_controls["Toggle MJ Minimap"] = forms.checkbox(ScriptHawkUI.options_form, "MJ Minimap", ScriptHawkUI.col(5) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(6) + ScriptHawkUI.dropdown_offset);
	--ScriptHawkUI.form_controls["Toggle ISG Timer"] = forms.checkbox(ScriptHawkUI.options_form, "ISG Timer", ScriptHawkUI.col(5) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(5) + ScriptHawkUI.dropdown_offset);
	ScriptHawkUI.form_controls["Toggle OhWrongnana"] = forms.checkbox(ScriptHawkUI.options_form, "OhWrongnana", ScriptHawkUI.col(5) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(6) + ScriptHawkUI.dropdown_offset);
	
	-- Output flag statistics
	flagStats();
end

----------------------
-- High Score Stuff --
----------------------

local arcadeScores = { -- TODO: How long can these names be
	{"AAA", 0}, -- TODO: Get some good scores with proof
};

local enguardeScores = {
	{"JON", 430}, -- https://www.youtube.com/watch?v=VrFWWcGlKOE
	{"ING", 420}, -- https://www.youtube.com/watch?v=UEPeqomGHN4
};

local jetpacScores = { -- TODO: How long can these names be
	{"AAA", 0}, -- TODO: Get some good scores with proof
};

local rambiBase = 0x744548; -- TODO: Port to all versions
local scoreBase = 0;
local nameBase = 2;
local scoreInstanceSize = 6;

local rambiScores = {
	{"BIS", 220}, -- http://www.twitch.tv/bismuth9/v/42515576
};

function Game.getScore(index)
	readNullTerminatedString();
end

function Game.setScore(index, name, score)
	if version ~= 4 then -- TODO: Are the scores in Kiosk or nah
		mainmemory.write_u16_be(rambiBase + index * scoreInstanceSize + scoreBase, score);
		for i = 0, 3 do
			mainmemory.writebyte(rambiBase + index * scoreInstanceSize + nameBase, string.byte(name, i))
		end
	end
end

function Game.setHighScores()
	-- TODO
end

function Game.unlock_menus()
	if version ~= 4 then -- Anything but the Kiosk version
		mainmemory.write_u32_be(Game.Memory.menu_flags[version], 0xFFFFFFFF);
		mainmemory.write_u32_be(Game.Memory.menu_flags[version] + 4, 0xFFFFFFFF);
	end
end

function Game.applyInfinites()
	local global_base = Game.Memory.global_base[version]; -- TODO: Use HUD pointer and object to get these memory locations

	mainmemory.writebyte(global_base + standard_ammo, max_standard_ammo);
	if forms.ischecked(ScriptHawkUI.form_controls["Toggle Homing Ammo Checkbox"]) then
		mainmemory.writebyte(global_base + homing_ammo, max_homing_ammo);
	else
		mainmemory.writebyte(global_base + homing_ammo, 0);
	end

	mainmemory.writebyte(global_base + oranges, max_oranges);
	mainmemory.write_u16_be(global_base + crystals, max_crystals * 150);
	mainmemory.writebyte(global_base + film, max_film);
	mainmemory.writebyte(global_base + health, mainmemory.readbyte(global_base + melons) * 4);
	--mainmemory.writebyte(global_base + melons, max_melons);

	if version ~= 4 then -- TODO: Kiosk
		for kong = DK, Chunky do
			local base = Game.Memory.kong_base[version] + kong * 0x5e;
			mainmemory.writebyte(base + coins, max_coins);
			mainmemory.writebyte(base + lives, max_musical_energy);
		end
	end
end

-------------------
-- Color setters --
-------------------

local actor_texture_renderer_pointer = 0x158;
local texture_renderer_texture_index = 0x0C; -- u16_be
local texture_renderer_next_renderer = 0x24; -- u32_be

function getNextTextureRenderer(texturePointer)
	return mainmemory.read_u24_be(texturePointer + texture_renderer_next_renderer + 1);
end

function Game.getTextureRenderers()
	local playerObject = getPlayerObject();
	local texturePointer = mainmemory.read_u24_be(playerObject + actor_texture_renderer_pointer + 1);

	while isRDRAM(texturePointer) do
		print(toHexString(texturePointer));
		texturePointer = getNextTextureRenderer(texturePointer);
	end
end

local DKBodyColors = {
	{"Normal", 0},
	{"Light Blue", 1},
	{"Light Green", 2},
	{"Purple", 3},
	{"Bright Orange", 16},
	{"Yellow", 19},
};

local DKTieColors = {
	{"Red (Normal)", 0},
	{"Purple", 1},
	{"Blue", 2},
	{"Yellow", 3},
};

function Game.setDKColors()
	local playerObject = getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = mainmemory.read_u24_be(playerObject + actor_texture_renderer_pointer + 1);

		if isRDRAM(texturePointer) then
			texturePointer = getNextTextureRenderer(texturePointer); -- Skip eyes

			-- 1 Body
			mainmemory.write_u16_be(texturePointer + texture_renderer_texture_index, DKBodyColors[math.random(1, #DKBodyColors)][2]);
			texturePointer = getNextTextureRenderer(texturePointer);

			-- 2 Tie Outer
			mainmemory.write_u16_be(texturePointer + texture_renderer_texture_index, DKTieColors[math.random(1, #DKTieColors)][2]);

			-- TODO: Tie inner
		end
	end
end

local DiddyHatColors = {
	{"Red (Normal)", 0},
	{"Dark Blue", 1},
	{"Yellow", 2},
	{"Blue", 3},
	{"Purple", 19},
	{"Dark Red", 24},
	{"Green", 26},
}

function Game.setDiddyColors()
	local playerObject = getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = mainmemory.read_u24_be(playerObject + actor_texture_renderer_pointer + 1);

		if isRDRAM(texturePointer) then
			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Left eye
			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Right eye

			-- 3 Hat
			mainmemory.write_u16_be(texturePointer + texture_renderer_texture_index, DiddyHatColors[math.random(1, #DiddyHatColors)][2]);
		end
	end
end

local LankyTopColors = {
	{"Blue (Normal)", 0},
	{"Green", 1},
	{"Purple", 2},
	{"Red", 3},
	{"Yellow", 27},
}

function Game.setLankyColors()
	local playerObject = getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = mainmemory.read_u24_be(playerObject + actor_texture_renderer_pointer + 1);

		if isRDRAM(texturePointer) then
			texturePointer = getNextTextureRenderer(texturePointer); -- Skip eyes

			-- 1 Top
			mainmemory.write_u16_be(texturePointer + texture_renderer_texture_index, LankyTopColors[math.random(1, #LankyTopColors)][2]);

			-- TODO: Bottom
		end
	end
end

local TinyBodyColors = {
	{"Blue (Normal)", 0},
	{"Green", 1},
	{"Purple", 2},
	{"Orange", 3},
};

function Game.setTinyColors()
	local playerObject = getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = mainmemory.read_u24_be(playerObject + actor_texture_renderer_pointer + 1);

		if isRDRAM(texturePointer) then
			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Left eye
			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Right eye

			-- 3 Body
			mainmemory.write_u16_be(texturePointer + texture_renderer_texture_index, TinyBodyColors[math.random(1, #TinyBodyColors)][2]);
		end
	end
end

local ChunkyBackColors = {
	{"Green + Yellow (Normal)", 0},
	{"Red + Yellow", 1},
	{"Blue + Light Blue", 2},
	{"Purple + Pink", 3},
	{"Blue", 16},
	{"Red", 17},
	{"Purple", 18},
	{"Green", 19},
};

local ChunkyFrontColors = {
	{"Blue (Normal)", 0},
	{"Red", 1},
	{"Purple", 2},
	{"Green", 3},
}

function Game.setChunkyColors()
	local playerObject = getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = mainmemory.read_u24_be(playerObject + actor_texture_renderer_pointer + 1);

		if isRDRAM(texturePointer) then
			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Eyes

			-- 1 Back
			mainmemory.write_u16_be(texturePointer + texture_renderer_texture_index, ChunkyBackColors[math.random(1, #ChunkyBackColors)][2]);
			texturePointer = getNextTextureRenderer(texturePointer);

			-- 2 Front
			mainmemory.write_u16_be(texturePointer + texture_renderer_texture_index, ChunkyFrontColors[math.random(1, #ChunkyFrontColors)][2]);
		end
	end
end

local KrushaColors = {
	{"Blue (Normal)", 0},
	{"Green", 1},
	{"Purple", 2},
	{"Yellow", 3},
}

function Game.setKrushaColors()
	local playerObject = getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = mainmemory.read_u24_be(playerObject + actor_texture_renderer_pointer + 1);

		if isRDRAM(texturePointer) then
			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Eyes

			-- 2 Body
			mainmemory.write_u16_be(texturePointer + texture_renderer_texture_index, TinyBodyColors[math.random(1, #TinyBodyColors)][2]);
		end
	end
end

local setColorFunctions = {
	[DK] = Game.setDKColors,
	[Diddy] = Game.setDiddyColors,
	[Lanky] = Game.setLankyColors,
	[Tiny] = Game.setTinyColors,
	[Chunky] = Game.setChunkyColors,
	[Krusha] = Game.setKrushaColors
};

function Game.setKongColor()
	local currentKong = mainmemory.readbyte(Game.Memory.character[version]);
	if type(setColorFunctions[currentKong]) == "function" then
		setColorFunctions[currentKong]();
	end
end

function Game.eachFrame()
	map_value = Game.getMap();
	updateCurrentInvisify();

	-- TODO: Allow user to toggle this
	Game.unlock_menus();

	-- Force STVW
	--local player = getPlayerObject();
	--local yRot = Game.getYRotation();
	--if yRot < Game.max_rot_units then
	--		Game.setYRotation(yRot + Game.max_rot_units);
	--end

	-- Lag fix
	forms.settext(ScriptHawkUI.form_controls["Lag Factor Value Label"], lag_factor);
	if forms.ischecked(ScriptHawkUI.form_controls["Toggle Lag Fix Checkbox"]) then
		fix_lag();
	end

	--if forms.ischecked(ScriptHawkUI.form_controls["Toggle Neverslip Checkbox"]) then
	--	neverSlip();
	--end

	if forms.ischecked(ScriptHawkUI.form_controls["Toggle Paper Mode Checkbox"]) then
		paperMode();
	end

	-- OhWrongnana
	if type(ScriptHawkUI.form_controls["Toggle OhWrongnana"]) ~= "nil" and forms.ischecked(ScriptHawkUI.form_controls["Toggle OhWrongnana"]) then
		ohWrongnana();
	end

	-- Mad Jack
	draw_mj_minimap();

	-- ISG Timer
	if type(ScriptHawkUI.form_controls["Toggle ISG Timer"]) ~= "nil" and forms.ischecked(ScriptHawkUI.form_controls["Toggle ISG Timer"]) then
		timer();
	else
		timer_started = false;
	end

	if bone_displacement_fix then
		applyBoneDisplacementFix();
	end

	do_brb();
	process_flag_queue();

	-- Moonkick
	if moon_mode == 'All' or (moon_mode == 'Kick' and mainmemory.readbyte(getPlayerObject() + animation_type) == kick_animation_value) then
		mainmemory.writefloat(getPlayerObject() + y_acceleration, -2.5, true);
	end

	-- Check EEPROM checksums
	if memory.usememorydomain("EEPROM") then
		local checksum_value;
		for i = 1, #eep_checksum_offsets do
			checksum_value = memory.read_u32_be(eep_checksum_offsets[i]);
			if eep_checksum_values[i] ~= checksum_value then
				if i == 5 then
					dprint("Global flags "..i.." Checksum: "..toHexString(eep_checksum_values[i], 8).." -> "..toHexString(checksum_value, 8));
				else
					dprint("Slot "..i.." Checksum: "..toHexString(eep_checksum_values[i], 8).." -> "..toHexString(checksum_value, 8));
				end
				eep_checksum_values[i] = checksum_value;
			end
		end
		print_deferred();
	end
	memory.usememorydomain("RDRAM");

	forms.settext(ScriptHawkUI.form_controls["Toggle Invisify Button"], current_invisify);
	forms.settext(ScriptHawkUI.form_controls["Moon Mode Button"], moon_mode);
end

Game.OSDPosition = {32, 70}
Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"Floor", Game.getFloor},
	{"Separator", 1},
	{"dY"},
	{"dXZ"},
	{"Velocity", Game.getVelocity},
	--{"Accel", Game.getAcceleration}, -- TODO
	{"Y Velocity", Game.getYVelocity},
	{"Y Accel", Game.getYAcceleration},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
	{"Rot. X", Game.getXRotation},
	{"Facing", Game.getYRotation, Game.colorYRotation},
	--{"Moving", Game.getMovingRotation}, -- TODO
	{"Rot. Z", Game.getZRotation},
};

return Game;