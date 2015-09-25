local Game = {};

-------------------------
-- DK64 specific state --
-------------------------

local kong_object_pointer;
local training_barrel;
local pointer_list;
local global_base;
local kongbase;
local tb_void_byte;
local menu_flags;
local map;

---------------------------
-- Arcade specific state --
---------------------------

local arcade_map = 2;
local jumpman_x_position;
local jumpman_y_position;

---------------------------
-- Jetpac specific state --
---------------------------

local jetpac_map = 9;
local jetman_x_position;
local jetman_y_position;

--------------
-- Mad Jack --
--------------

local mad_jack_map = 154;
local MJ_state_pointer;

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
}

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

------------------
-- Unlock menus --
------------------

function Game.unlock_menus()
	for byte=0,7 do
		mainmemory.write_u8(menu_flags + byte, 0xff);
	end
end

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

-- Pointers relative to Kong base
local moves      = 0;
local sim_slam   = 1;
local weapon     = 2;
local instrument = 4;
local coins      = 7;
local lives      = 9; -- This is used as instrument ammo in single player

local function unlock_moves()
	local kong;
	for kong=DK,Chunky do
		local base = kongbase + kong * 0x5e;
		mainmemory.write_u8(base + moves,      3);
		mainmemory.write_u8(base + sim_slam,   3);
		mainmemory.write_u8(base + weapon,     7);
		mainmemory.write_u8(base + instrument, 15);
	end

	-- Training barrels
	mainmemory.write_u8(training_barrel, 0xff);
end

------------------------------------
-- Moonjump BizHawk Lua port      --
-- Based on work by SubDrag, 2006 --
------------------------------------
-- http://www.therwp.com/forums/showthread.php?t=7238

-- Relative to kong_object_pointer
local model_pointer = 0x00;

local hand_state = 0x47; -- Bitfield
local visibility = 0x63; -- 127 = visible

local specular_highlight = 0x6D;

local shadow_width = 0x6E;
local shadow_height = 0x6F;

local x_pos = 0x7c;
local y_pos = 0x80;
local z_pos = 0x84;

local floor = 0xa4;

local kick_freeze = 0xc4;
local kick_freeze_value = 0xc020;

local light_thing = 0xcc; -- Values 0x00->0x14

local slope_byte = 0xDE;

local x_rot = 0xe4;
local y_rot = 0xe6;
local z_rot = 0xe8;

local locked_to_pad = 0x110;

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

local kick_animation = 0x181;
local kick_animation_value = 0x29;

local scale = {
	0x344, 0x348, 0x34C, 0x350, 0x354
}

-- Bitfield?
local effect_byte = 0x372;

local kong_object;

local prev_map = 0;
local map_value = 0;

---------------
-- Key stuff --
---------------

local key_flag_pointer;
local key_collected_bitmasks = {
	2, 2, 2, 0,
	4, 4, 5, 4
};
local key_offsets = {
	0x03, 0x09, 0x11, 0x15,
	0x1d, 0x24, 0x27, 0x2f
};

local options_key_dropdown;
local options_get_key_button;
local options_lose_key_button;

local function keyGet()
	local key = forms.getproperty(options_key_dropdown, "SelectedIndex") + 1;
	local key_flags = mainmemory.read_u24_be(key_flag_pointer + 1);
	if key_flags > 0x700000 and key > 0 and key < 9 then
		local current_value = mainmemory.readbyte(key_flags + key_offsets[key]);
		mainmemory.write_u8(key_flags + key_offsets[key], set_bit(current_value, key_collected_bitmasks[key]));
	else
		console.log("Key get failed to execute.");
	end
end

local function keyLose()
	local key = forms.getproperty(options_key_dropdown, "SelectedIndex") + 1;
	local key_flags = mainmemory.read_u24_be(key_flag_pointer + 1);
	if key_flags > 0x700000 and key > 0 and key < 9 then
		local current_value = mainmemory.readbyte(key_flags + key_offsets[key]);
		mainmemory.write_u8(key_flags + key_offsets[key], clear_bit(current_value, key_collected_bitmasks[key]));
	else
		console.log("Key lose failed to execute.");
	end
end

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if bizstring.contains(romName, "USA") and not bizstring.contains(romName, "Kiosk") then
		map                 = 0x7444E7;
		file                = 0x7467c8;
		key_flag_pointer    = 0x7654F4;
		training_barrel     = 0x7ed230;
		menu_flags          = 0x7ed558;
		kong_object_pointer = 0x7fbb4d;
		tb_void_byte        = 0x7fbb63;
		pointer_list        = 0x7fbff0;
		kongbase            = 0x7fc950;
		global_base         = 0x7fcc41;

		--Mad Jack
		MJ_state_pointer   = 0x7fdc91;
		MJ_time_until_next_action = 0x2d;
		MJ_actions_remaining      = 0x58;
		MJ_action_type            = 0x59;
		MJ_current_pos            = 0x60;
		MJ_next_pos               = 0x61;
		MJ_white_switch_pos       = 0x64;
		MJ_blue_switch_pos        = 0x65;

		--Subgames
		jumpman_x_position = 0x04BD70;
		jumpman_y_position = 0x04BD74;
		jetman_x_position = 0x02F050;
		jetman_y_position = 0x02F054;
	elseif bizstring.contains(romName, "Europe") then
		map                 = 0x73EC37;
		file                = 0x740F18;
		key_flag_pointer    = 0x760014;
		training_barrel     = 0x7ed150;
		menu_flags          = 0x7ed478;
		kong_object_pointer = 0x7fba6d;
		tb_void_byte        = 0x7FBA83;
		pointer_list        = 0x7fbf10;
		kongbase            = 0x7fc890;
		global_base         = 0x7fcb81;

		--Mad Jack
		MJ_state_pointer   = 0x7FDBD1;
		MJ_time_until_next_action = 0x25;
		MJ_actions_remaining      = 0x60;
		MJ_action_type            = 0x61;
		MJ_current_pos            = 0x68;
		MJ_next_pos               = 0x69;
		MJ_white_switch_pos       = 0x6C;
		MJ_blue_switch_pos        = 0x6D;

		--Subgames
		jumpman_x_position = 0x03ECD0;
		jumpman_y_position = 0x03ECD4;
		jetman_x_position = 0x022100;
		jetman_y_position = 0x022104;
	elseif bizstring.contains(romName, "Japan") then
		map                 = 0x743DA7;
		file                = 0x746088;
		key_flag_pointer    = 0x7656E4;
		training_barrel     = 0x7ed84c;
		menu_flags          = 0x7ed9c8;
		kong_object_pointer = 0x7fbfbd;
		tb_void_byte        = 0x7FBFD3;
		pointer_list        = 0x7fc460;
		kongbase            = 0x7fcde0;
		global_base         = 0x7fd0d1;

		--Mad Jack
		MJ_state_pointer   = 0x7fe121;
		MJ_time_until_next_action = 0x25;
		MJ_actions_remaining      = 0x60;
		MJ_action_type            = 0x61;
		MJ_current_pos            = 0x68;
		MJ_next_pos               = 0x69;
		MJ_white_switch_pos       = 0x6C;
		MJ_blue_switch_pos        = 0x6D;

		--Subgames
		jumpman_x_position = 0x03EB00;
		jumpman_y_position = 0x03EB04;
		jetman_x_position = 0x022060;
		jetman_y_position = 0x022064;
	elseif bizstring.contains(romName, "Kiosk") then
		file                = 0x7467c8; -- TODO?
		map                 = 0x72CDE7;
		training_barrel     = 0x7ed150; -- TODO?
		menu_flags          = 0x7ed558; -- TODO?
		kong_object_pointer = 0x7b5afd;
		tb_void_byte        = 0x7fbb63; -- TODO?
		pointer_list        = 0x7b5e58;
		kongbase            = 0x7fc950; -- TODO
		global_base         = 0x7fcc41; -- TODO

		-- TODO: Keys?

		x_rot = 0xD8;
		y_rot = 0xDA;
		z_rot = 0xDC;

		-- Kiosk version maps
		--0 Crash
		--1 Crash
		--2 Crash
		--3 Dogadon (2?) fight (Crash??!?!?!)
		--4 Crash
		--5 Crash
		--6 Minecart
		--7 Crash
		--8 Armydillo fight -> crash?
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
		--83 Partially loads, then crashes
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
		local i;
		for i=1,#eep_checksum_offsets do
			eep_checksum_values[i] = memory.read_u32_be(eep_checksum_offsets[i]);
		end
	end
	memory.usememorydomain("RDRAM");

	return true;
end

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

--------------
-- Position --
--------------

function Game.getXPosition()
	if map_value == arcade_map then
		return mainmemory.readfloat(jumpman_x_position, true);
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(jetman_x_position, true);
	end
	return mainmemory.readfloat(kong_object + x_pos, true);
end

function Game.getYPosition()
	if map_value == arcade_map then
		return mainmemory.readfloat(jumpman_y_position, true);
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(jetman_y_position, true);
	end
	return mainmemory.readfloat(kong_object + y_pos, true);
end

function Game.getZPosition()
	if not isInSubGame() then
		return mainmemory.readfloat(kong_object + z_pos, true);
	end
	return 0;
end

function Game.setXPosition(value)
	if map_value == arcade_map then
		--mainmemory.writefloat(jumpman_x_position, value, true);
	elseif map_value == jetpac_map then
		--mainmemory.writefloat(jetman_x_position, value, true);
	else
		mainmemory.writefloat(kong_object + x_pos, value, true);
		mainmemory.writebyte(kong_object + locked_to_pad, 0x00);
	end
end

function Game.setYPosition(value)
	if map_value == arcade_map then
		--mainmemory.writefloat(jumpman_y_position, value, true);
	elseif map_value == jetpac_map then
		--mainmemory.writefloat(jetman_y_position, value, true);
	else
		mainmemory.writefloat(kong_object + y_pos, value, true);
		mainmemory.writebyte(kong_object + locked_to_pad, 0x00);
	end
end

function Game.setZPosition(value)
	if not isInSubGame() then
		mainmemory.writefloat(kong_object + z_pos, value, true);
		mainmemory.writebyte(kong_object + locked_to_pad, 0x00);
	end
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	if not isInSubGame() then
		return mainmemory.read_u16_be(kong_object + x_rot);
	end
	return 0;
end

function Game.getYRotation()
	if not isInSubGame() then
		return mainmemory.read_u16_be(kong_object + y_rot);
	end
	return 0;
end

function Game.getZRotation()
	if not isInSubGame() then
		return mainmemory.read_u16_be(kong_object + z_rot);
	end
	return 0;
end

function Game.setXRotation(value)
	if not isInSubGame() then
		mainmemory.write_u16_be(kong_object + x_rot, value);
	end
end

function Game.setYRotation(value)
	if not isInSubGame() then
		mainmemory.write_u16_be(kong_object + y_rot, value);
	end
end

function Game.setZRotation(value)
	if not isInSubGame() then
		mainmemory.write_u16_be(kong_object + z_rot, value);
	end
end

--------------------
-- Misc functions --
--------------------

local function invisify()
	kong_object = mainmemory.read_u24_be(kong_object_pointer);
	mainmemory.writebyte(kong_object + visibility, 0x00);
end

local function visify()
	kong_object = mainmemory.read_u24_be(kong_object_pointer);
	mainmemory.writebyte(kong_object + visibility, 0x7f);
end

local options_toggle_invisify_button;
local current_invisify = "Invisify";
local function toggle_invisify()
	if current_invisify == "Invisify" then
		invisify();
		current_invisify = "Visify";
	else
		visify();
		current_invisify = "Invisify";
	end

	forms.settext(options_toggle_invisify_button, current_invisify);
end

local function clear_tb_void()
	local tb_void_byte_val = mainmemory.readbyte(tb_void_byte);
	mainmemory.writebyte(tb_void_byte, bit.bor(tb_void_byte_val, 0x30));
end

local function force_pause()
	mainmemory.writebyte(tb_void_byte, 0x31);
end

local function force_zipper()
	mainmemory.writebyte(tb_void_byte - 1, 0x01);
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
	local map_value = mainmemory.readbyte(map);
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
		gui.text(16, 16, "ISG Timer: "..timer_string, null, null, 'topright');
	else
		gui.text(16, 16, "Waiting for ISG", null, null, 'topright');
	end
end

-----------------------------------
-- DK64 - Mad Jack Minimap
-- Written by Isotarge, 2014-2015
-----------------------------------
local script_root = "Lua/ScriptHawk";

-- Colors
local MJ_blue         = 0x7f00a2e8;
local MJ_blue_switch  = 0xff00a2e8;
local MJ_white        = 0x7fffffff;
local MJ_white_switch = 0xffffffff;

-- Minimap ui
local MJ_minimap_x_offset  = 19;
local MJ_minimap_y_offset  = 19;
local MJ_minimap_width     = 16;
local MJ_minimap_height    = 16;

local MJ_minimap_text_x = MJ_minimap_x_offset + 4.5 * MJ_minimap_width;
local MJ_minimap_text_y = MJ_minimap_y_offset;

local MJ_minimap_phase_number_y      = MJ_minimap_text_y;
local MJ_minimap_actions_remaining_y = MJ_minimap_phase_number_y      + MJ_minimap_height;
local MJ_time_until_next_action_y    = MJ_minimap_actions_remaining_y + MJ_minimap_height;

local MJ_kong_row_y                  = MJ_time_until_next_action_y + MJ_minimap_height;
local MJ_kong_col_y                  = MJ_kong_row_y + MJ_minimap_height;

local function round(x)
	return x + 0.5 - (x + 0.5) % 1;
end

local function position_to_rowcol(pos)
	if pos < 450 then
		return 0;
	elseif pos < 570 then
		return 1;
	elseif pos < 690 then
		return 2;
	elseif pos < 810 then
		return 3;
	elseif pos < 930 then
		return 4;
	elseif pos < 1050 then
		return 5;
	elseif pos < 1170 then
		return 6;
	end
	return 7;
end

local function get_kong_position()
	local kong_model = mainmemory.read_u24_be(kong_object_pointer);

	local x = mainmemory.readfloat(kong_model + x_pos, true);
	local z = mainmemory.readfloat(kong_model + z_pos, true);

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
	if phase_byte == 0x08 or phase_byte == 0x0a or phase_byte == 0x0b or phase_byte == 0x0c or phase_byte == 0x0e then
		return "Jump";
	elseif phase_byte == 0x01 or phase_byte == 0x05 then
		return "Laser";
	elseif phase_byte == 0x28 or phase_byte == 0x2d or phase_byte == 0x32 then
		return "Fireball";
	end
	return "Jump";
end

local function MJ_get_phase(phase_byte)
	if phase_byte == 0x08 or phase_byte == 0x32 then
		return 1;
	elseif phase_byte == 0x0a or phase_byte == 0x2d then
		return 2;
	elseif phase_byte == 0x0b or phase_byte == 0x28 then
		return 3;
	elseif phase_byte == 0x0c or phase_byte == 0x05 then
		return 4;
	elseif phase_byte == 0x0e or phase_byte == 0x01 then
		return 5;
	end
	return 0;
end

local function MJ_get_arrow_image(current, new)
	if new.row > current.row then
		if new.col > current.col then
			return script_root.."/Images/up_right.png";
		elseif new.col == current.col then
			return script_root.."/Images/up.png";
		elseif new.col < current.col then
			return script_root.."/Images/up_left.png";
		end
	elseif new.row == current.row then
		if new.col > current.col then
			return script_root.."/Images/right.png";
		elseif new.col < current.col then
			return script_root.."/Images/left.png";
		end
	elseif new.row < current.row then
		if new.col > current.col then
			return script_root.."/Images/down_right.png";
		elseif new.col == current.col then
			return script_root.."/Images/down.png";
		elseif new.col < current.col then
			return script_root.."/Images/down_left.png";
		end
	end
	return script_root.."/Images/question-mark.png";
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
	if mainmemory.readbyte(map) == mad_jack_map then
		local MJ_state  = mainmemory.read_u24_be(MJ_state_pointer);

		local cur_pos   = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_current_pos));
		local next_pos  = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_next_pos));

		local white_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_white_switch_pos));
		local blue_pos  = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_blue_switch_pos));

		local switches_active = white_pos.active or blue_pos.active;

		local row, col, x, y, color;

		gui.clearGraphics();

		local kong_position = get_kong_position();

		for row=0,3 do
			for	col=0,3 do
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
						gui.drawImage(script_root.."/Images/switch.png", x, y, MJ_minimap_width, MJ_minimap_height);
					end
				end

				if cur_pos.row == row and cur_pos.col == col then
					gui.drawImage(script_root.."/Images/jack_icon.png", x, y, MJ_minimap_width, MJ_minimap_height);
				elseif next_pos.row == row and next_pos.col == col then
					gui.drawImage(MJ_get_arrow_image(cur_pos, next_pos), x, y, MJ_minimap_width, MJ_minimap_height);
				end

				if kong_position.row == row and kong_position.col == col then
					gui.drawImage(script_root.."/Images/TinyFaceEdited.png", x, y, MJ_minimap_width, MJ_minimap_height);
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
			gui.drawText(MJ_minimap_text_x, MJ_minimap_phase_number_y  , "Phase "..phase.." (switch)");
			gui.drawText(MJ_minimap_text_x, MJ_time_until_next_action_y, time_until_next_action.." ticks until next "..action_type);
		else
			gui.drawText(MJ_minimap_text_x, MJ_minimap_phase_number_y  , "Phase "..phase);
		end
	end
end

------------------------------------
-- Never Slip                     --
-- Written by Isotarge, 2014-2015 --
------------------------------------

-- Pointers
-- TODO - Find this in other versions
local slope_object_pointer = 0x7f94b9;

-- Relative to slope object
local slope_timer = 0xc3;

local function neverSlip()
	-- Patch the slope timer
	local slope_object = mainmemory.read_u24_be(slope_object_pointer);
	mainmemory.write_u8(slope_object + slope_timer, 0);

	-- Patch the Kong object
	local kong_object = mainmemory.read_u24_be(kong_object_pointer);
	local slope_value = mainmemory.read_u8(kong_object + slope_byte);
	--mainmemory.write_u8(kong_object + slope_byte, math.max(3, slope_value));
	mainmemory.write_u8(kong_object + slope_byte + 1, 0xFE);
end

----------------------
-- Geometry Spiking --
----------------------

local spiking_fix = false;
local freeze_value = 0;
local geometry_spike_pointer = 0x76FDF8;

local function fix_geometry_spiking()
	spiking_fix = true;
	freeze_value = mainmemory.read_u32_be(geometry_spike_pointer);
end

local function break_geometry_spiking()
	spiking_fix = false;
end

event.onloadstate(break_geometry_spiking, "Break spiking =(");

local function apply_spiking_fix()
	mainmemory.write_u32_be(geometry_spike_pointer, freeze_value);
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

local max_objects = 0xff;

local function everythingiskong()
	local object_found = true;
	local object_no = 0;
	local kong_model_pointer = mainmemory.read_u24_be(kong_object + 1);
	local object_model_pointer;
	local pointer;

	while object_found do
		pointer = mainmemory.read_u24_be(pointer_list + (object_no * 4) + 1);
		object_found = (pointer ~= 0xffffff) and (pointer ~= 0x000000) and (object_no <= max_objects);

		if object_found then
			object_model_pointer = mainmemory.read_u24_be(pointer + model_pointer + 1);
			if object_model_pointer ~= 0x000000 then
				mainmemory.write_u24_be(pointer + model_pointer + 1, kong_model_pointer);
			end
			object_no = object_no + 1;
		end
	end
end

local function applyScale(desired_scale)
	local i;
	for i=1,#scale do
		mainmemory.writefloat(kong_object + scale[i], desired_scale, true);
	end
end

local function random_effect()
	-- Randomly manipulate the effect byte
	local randomEffect = math.random(0, 0xffff);
	mainmemory.write_u16_be(kong_object + effect_byte, randomEffect);

	-- Randomly resize the kong
	applyScale(0.01 + math.random() * 0.49);

	console.log("Activated effect: "..bizstring.binary(randomEffect));
end

------------
-- Events --
------------

function Game.setMap(value)
	if value >= 1 and value <= #Game.maps then
		mainmemory.writebyte(map, value - 1);
	end
end

local options_moon_mode_label;
local options_moon_mode_button;

local options_clear_tb_void_button;
local options_kong_button;
local options_force_pause_button;
local options_force_zipper_button;
local options_random_effect_button;
local options_unlock_moves_button;

local options_toggle_homing_ammo;
local options_toggle_neverslip;

local options_toggle_madjack;
local options_toggle_isg_timer;

function Game.initUI(form_handle, col, row, button_height, label_offset, dropdown_offset)
	-- Key stuff
	options_key_dropdown = forms.dropdown(form_handle, { "Key 1", "Key 2", "Key 3", "Key 4", "Key 5", "Key 6", "Key 7", "Key 8" }, col(10) + dropdown_offset, row(0) + dropdown_offset);
	options_get_key_button = forms.button(form_handle, "Get", keyGet, col(10), row(1), 59, button_height);
	options_lose_key_button = forms.button(form_handle, "Lose", keyLose, col(13) - 5, row(1), 59, button_height);

	-- Moon stuff
	options_moon_mode_label =  forms.label(form_handle,  "Moon:",                    col(10),     row(2) + label_offset, 48, button_height);
	options_moon_mode_button = forms.button(form_handle, moon_mode, toggle_moonmode, col(13) - 5, row(2),                59, button_height);

	-- Mad Jack stuff
	options_toggle_madjack = forms.checkbox(form_handle, "MJ Minimap", col(5) + dropdown_offset, row(7) + dropdown_offset);

	-- ISG Timer
	options_toggle_isg_timer = forms.checkbox(form_handle, "ISG Timer", col(10) + dropdown_offset, row(7) + dropdown_offset);

	-- Buttons
	options_toggle_invisify_button = forms.button(form_handle, "Invisify",      toggle_invisify, col(5), row(4), col(4) + 8, button_height);
	options_clear_tb_void_button =   forms.button(form_handle, "Clear TB void", clear_tb_void,   col(5), row(5), col(4) + 8, button_height);
	options_unlock_moves_button =    forms.button(form_handle, "Unlock Moves",  unlock_moves,    col(5), row(6), col(4) + 8, button_height);

	--options_kong_button        =  forms.button(form_handle, "Kong",   everythingiskong,  col(10), row(3), col(4) + 8, button_height);
	options_force_pause_button =  forms.button(form_handle, "Force Pause",   force_pause,  col(10), row(4), col(4) + 8, button_height);
	--options_force_zipper_button = forms.button(form_handle, "Force Zipper",  force_zipper, col(10), row(5), col(4) + 8, button_height);
	options_fix_geometry_spiking = forms.button(form_handle, "Fix Spiking", fix_geometry_spiking, col(10), row(5), col(4) + 8, button_height);
	options_random_effect_button = forms.button(form_handle, "Random effect", random_effect, col(10), row(6), col(4) + 8, button_height);

	-- Checkboxes
	options_toggle_homing_ammo = forms.checkbox(form_handle, "Homing Ammo", col(0) + dropdown_offset, row(6) + dropdown_offset);
	options_toggle_neverslip =   forms.checkbox(form_handle, "Never Slip",  col(0) + dropdown_offset, row(7) + dropdown_offset);
end

function Game.applyInfinites()
	mainmemory.write_u8(global_base + standard_ammo, max_standard_ammo);
	if forms.ischecked(options_toggle_homing_ammo) then
		mainmemory.write_u8(global_base + homing_ammo, max_homing_ammo);
	else
		mainmemory.write_u8(global_base + homing_ammo, 0);
	end
	mainmemory.write_u8(global_base + oranges,  max_oranges);
	mainmemory.write_u16_be(global_base + crystals, max_crystals * 150);
	mainmemory.write_u8(global_base + film,     max_film);
	mainmemory.write_u8(global_base + health,   max_health);
	mainmemory.write_u8(global_base + melons,   max_melons);
	local kong;
	for kong=DK,Chunky do
		local base = kongbase + kong * 0x5e;
		mainmemory.write_u8(base + coins, max_coins);
		mainmemory.write_u8(base + lives, max_musical_energy);
	end
end

function Game.eachFrame()
	kong_object = mainmemory.read_u24_be(kong_object_pointer);
	map_value = mainmemory.readbyte(map);

	Game.unlock_menus();

	if forms.ischecked(options_toggle_neverslip) then
		neverSlip();
	end

	-- Mad Jack
	if forms.ischecked(options_toggle_madjack) then
		draw_mj_minimap();
	end

	-- ISG Timer
	if forms.ischecked(options_toggle_isg_timer) then
		timer();
	else
		timer_started = false;
	end

	-- Spiking fix
	if spiking_fix then
		apply_spiking_fix();
	end

	-- Moonkick
	if moon_mode == 'All' or (moon_mode == 'Kick' and mainmemory.readbyte(kong_object + kick_animation) == kick_animation_value) then
		mainmemory.write_u16_be(kong_object + kick_freeze, kick_freeze_value);
	end

	-- Check EEPROM checksums
	if memory.usememorydomain("EEPROM") then
		local i, checksum_value;
		for i=1,#eep_checksum_offsets do
			checksum_value = memory.read_u32_be(eep_checksum_offsets[i]);
			if eep_checksum_values[i] ~= checksum_value then
				if i == 5 then
					console.log("Global flags "..i.." Checksum: "..bizstring.hex(eep_checksum_values[i]).." -> "..bizstring.hex(checksum_value));
				else
					console.log("Slot "..i.." Checksum: "..bizstring.hex(eep_checksum_values[i]).." -> "..bizstring.hex(checksum_value));
				end
				eep_checksum_values[i] = checksum_value;
			end
		end
	end
	memory.usememorydomain("RDRAM");

	forms.settext(options_toggle_invisify_button, current_invisify);
	forms.settext(options_moon_mode_button, moon_mode);
end

return Game;