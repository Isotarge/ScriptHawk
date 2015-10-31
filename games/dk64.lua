local Game = {};

-------------------------
-- DK64 specific state --
-------------------------

local version;
local kong_object_pointer;
local camera_pointer;
local pointer_list;
local global_base;
local kongbase;
local tb_void_byte;
local menu_flags;
local map;
local security_byte;
local security_message;
local geometry_spike_pointer;
local frames_real;
local frames_lag;

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
		mainmemory.writebyte(menu_flags + byte, 0xFF);
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

local max_blueprints = 40 * 2;
local max_fairies = 20;
local max_crowns = 10;
local max_medals = 40;
local max_cb = 3511;
local max_gb = 201;
local max_warps = (5 * 2 * 7) + 4 + 2 + 2 + 6;
	
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

local x_pos = 0x7C;
local y_pos = 0x80;
local z_pos = 0x84;

local floor = 0xa4;

local kick_freeze = 0xC4;
local kick_freeze_value = 0xC020;

local light_thing = 0xCC; -- Values 0x00->0x14

local slope_byte = 0xDE;

local x_rot = 0xE4;
local y_rot = 0xE6;
local z_rot = 0xE8;

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

----------------
-- Flag stuff --
----------------

local options_flag_dropdown;
local options_set_flag_button;
local options_Clear_flag_button;

local flag_pointer;

local flag_block_size = 0x120;

local flag_action_queue = {};
local flag_names = {};
flag_block = {};

function adjustBlockSize(value)
	flag_block = {};
	flag_block_size = value;
	checkFlags();
end

local flag_array = {	
	---------------------------
	-- Needs further testing --
	---------------------------

	{["byte"] = 0x30, ["bit"] = 7, ["name"] = "? All training barrels comeplete cutscene ?"}, -- TODO: Test this

	{["byte"] = 0x61, ["bit"] = 1, ["name"] = "?? Training barrels spawned?"}, -- TODO: Test this

	{["byte"] = 0x38, ["bit"] = 5, ["name"] = "Japes: Entered Japes (1)"}, -- TODO: Test this

	{["byte"] = 0x31, ["bit"] = 3, ["name"] = "? Japes W3 Right CB Bunch", ["type"] = "Bunch"}, -- TODO: Test this
	{["byte"] = 0x64, ["bit"] = 7, ["name"] = "? Japes W3 Right CB Bunch", ["type"] = "Bunch"}, -- TODO: Test this
	{["byte"] = 0x2E, ["bit"] = 3, ["name"] = "? Orange Barrel Completed?"}, -- TODO: Test this

	{["byte"] = 0x2C, ["bit"] = 7, ["name"] = "? T&S FTT (entered in Japes)"}, -- TODO: Test this

	{["byte"] = 0x20, ["bit"] = 0, ["name"] = "Fungi: Day/Night First Time CS"}, -- TODO: Test this

	{["byte"] = 0x31, ["bit"] = 4, ["name"] = "Fungi: DK Coin by BBlast or First Coin?", ["type"] = "Coin"}, -- TODO: Test this

	{["byte"] = 0x39, ["bit"] = 4, ["name"] = "? Enter Helm/W1"},

	{["byte"] = 0x18, ["bit"] = 2, ["name"] = "? Galleon first time cutscene"},
	{["byte"] = 0x39, ["bit"] = 0, ["name"] = "?? Galleon first time cutscene"},

	-----------
	-- Known --
	-----------

	{["byte"] = 0x00, ["bit"] = 0, ["name"] = "Japes: DK Switch by enterance"}, -- TODO: Test this
	{["byte"] = 0x00, ["bit"] = 1, ["name"] = "Japes: Lanky: Mad Maze Maul GB", ["type"] = "GB"},
	{["byte"] = 0x00, ["bit"] = 2, ["name"] = "Japes: Tiny: Splish-Splash Salvage GB", ["type"] = "GB"},
	{["byte"] = 0x00, ["bit"] = 3, ["name"] = "Japes: DK: Babboon blast GB", ["type"] = "GB"},
	{["byte"] = 0x00, ["bit"] = 4, ["name"] = "Japes: DK: GB in front of Diddy's cage", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x00, ["bit"] = 5, ["name"] = "Japes: DK: GB in Diddy's cage", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x00, ["bit"] = 6, ["name"] = "Kong Unlocked: Diddy"},
	{["byte"] = 0x00, ["bit"] = 7, ["name"] = "Japes: Feather gate open"},

	{["byte"] = 0x01, ["bit"] = 0, ["name"] = "Japes: Tiny: Stump GB", ["type"] = "GB"},
	{["byte"] = 0x01, ["bit"] = 1, ["name"] = "Japes: Tiny: Shellhive GB", ["type"] = "GB"},
	{["byte"] = 0x01, ["bit"] = 2, ["name"] = "Japes: Lanky: Painting room GB", ["type"] = "GB"},
	{["byte"] = 0x01, ["bit"] = 3, ["name"] = "Japes: Lanky: Speedy Swing Sortie GB", ["type"] = "GB"},
	{["byte"] = 0x01, ["bit"] = 4, ["name"] = "Japes: Chunky: Underground GB", ["type"] = "GB"},
	{["byte"] = 0x01, ["bit"] = 5, ["name"] = "Japes: Hut Smashed (Diddy)"},
	{["byte"] = 0x01, ["bit"] = 6, ["name"] = "Japes: Hut Smashed (Lanky)"},
	{["byte"] = 0x01, ["bit"] = 7, ["name"] = "Japes: Hut Smashed (DK)"},
	{["byte"] = 0x02, ["bit"] = 0, ["name"] = "Japes: Hut Smashed (Tiny)"},
	{["byte"] = 0x02, ["bit"] = 2, ["name"] = "Japes: Diddy Caged GB", ["type"] = "GB"},
	{["byte"] = 0x02, ["bit"] = 3, ["name"] = "Japes: Lanky Caged GB", ["type"] = "GB"},
	{["byte"] = 0x02, ["bit"] = 4, ["name"] = "Japes: DK Caged GB", ["type"] = "GB"},
	{["byte"] = 0x02, ["bit"] = 5, ["name"] = "Japes: Tiny Caged GB", ["type"] = "GB"},
	{["byte"] = 0x02, ["bit"] = 6, ["name"] = "Japes: Chunky Caged GB", ["type"] = "GB"},
	{["byte"] = 0x02, ["bit"] = 7, ["name"] = "Japes: Diddy mountain top GB (W5)", ["type"] = "GB"},

	{["byte"] = 0x03, ["bit"] = 0, ["name"] = "Japes: Diddy: Minecart GB", ["type"] = "GB"},
	{["byte"] = 0x03, ["bit"] = 1, ["name"] = "Japes: Chunky: Boulder GB", ["type"] = "GB"},
	{["byte"] = 0x03, ["bit"] = 2, ["name"] = "Key 1", ["type"] = "Key"},
	{["byte"] = 0x03, ["bit"] = 3, ["name"] = "Japes: Cutscene at the start played"},
	{["byte"] = 0x03, ["bit"] = 4, ["name"] = "Japes: Chunky: Bonus barrel GB (Shellhive)", ["type"] = "GB"},
	{["byte"] = 0x03, ["bit"] = 6, ["name"] = "Japes: Painting room opened"},
	{["byte"] = 0x03, ["bit"] = 7, ["name"] = "Japes: Diddy: Cave GB", ["type"] = "GB"},

	{["byte"] = 0x04, ["bit"] = 0, ["name"] = "Japes: W1 (Portal)", ["type"] = "Warp"},
	{["byte"] = 0x04, ["bit"] = 1, ["name"] = "Japes: W1 (Far)", ["type"] = "Warp"},
	{["byte"] = 0x04, ["bit"] = 2, ["name"] = "Japes: W2 (High)", ["type"] = "Warp"},
	{["byte"] = 0x04, ["bit"] = 3, ["name"] = "Japes: W2 (Low)", ["type"] = "Warp"},
	{["byte"] = 0x04, ["bit"] = 4, ["name"] = "Japes: W3 (Right)", ["type"] = "Warp"},
	{["byte"] = 0x04, ["bit"] = 5, ["name"] = "Japes: W3 (Left)", ["type"] = "Warp"},
	{["byte"] = 0x04, ["bit"] = 6, ["name"] = "Japes: W5 (Shellhive area)", ["type"] = "Warp"},
	{["byte"] = 0x04, ["bit"] = 7, ["name"] = "Japes: W5 (Top)", ["type"] = "Warp"},
	{["byte"] = 0x05, ["bit"] = 0, ["name"] = "Japes: W4 (Close)", ["type"] = "Warp"},
	{["byte"] = 0x05, ["bit"] = 1, ["name"] = "Japes: W4 (Cranky)", ["type"] = "Warp"},

	{["byte"] = 0x05, ["bit"] = 2, ["name"] = "Japes: Cutscene by far W1 played"}, -- TODO: Test this
	{["byte"] = 0x05, ["bit"] = 3, ["name"] = "Japes: Rambi Door Smashed"}, -- TODO: Test this
	{["byte"] = 0x05, ["bit"] = 6, ["name"] = "Japes: T&S Despawned"}, -- TODO: Test this

	{["byte"] = 0x06, ["bit"] = 0, ["name"] = "Aztec: DK Blueprint room open"},

	{["byte"] = 0x08, ["bit"] = 2, ["name"] = "Kong Unlocked: Tiny"},
	{["byte"] = 0x08, ["bit"] = 4, ["name"] = "Aztec: Lanky: Vulture GB", ["type"] = "GB"},
	{["byte"] = 0x08, ["bit"] = 5, ["name"] = "Aztec: Tiny Temple ice melted"},
	{["byte"] = 0x08, ["bit"] = 6, ["name"] = "Kong Unlocked: Lanky"},
	{["byte"] = 0x09, ["bit"] = 2, ["name"] = "Key 2", ["type"] = "Key"},

	{["byte"] = 0x0B, ["bit"] = 0, ["name"] = "Aztec: W1 (Llama temple, high)", ["type"] = "Warp"},
	{["byte"] = 0x0B, ["bit"] = 1, ["name"] = "Aztec: W1 (Llama temple, low)", ["type"] = "Warp"},
	{["byte"] = 0x0B, ["bit"] = 2, ["name"] = "Aztec: W2 (Llama temple, far)", ["type"] = "Warp"},
	{["byte"] = 0x0B, ["bit"] = 3, ["name"] = "Aztec: W2 (Llama temple, low)", ["type"] = "Warp"},

	{["byte"] = 0x0B, ["bit"] = 4, ["name"] = "Aztec: Llama Cutscene"}, -- TODO: Bananas in this hallway were skipped with block size 0x80
	{["byte"] = 0x0B, ["bit"] = 5, ["name"] = "Aztec: Lanky's help me cutscene"},
	{["byte"] = 0x0B, ["bit"] = 7, ["name"] = "Aztec: FT Cutscene"},

	{["byte"] = 0x0D, ["bit"] = 5, ["name"] = "Factory: Hatch opened"},
	{["byte"] = 0x0D, ["bit"] = 6, ["name"] = "? Factory: Storage room switch pressed"},
	{["byte"] = 0x0D, ["bit"] = 7, ["name"] = "Factory: Power shed activated"},
	{["byte"] = 0x0E, ["bit"] = 0, ["name"] = "Factory: Power shed GB", ["type"] = "GB"},
	
	{["byte"] = 0x0E, ["bit"] = 5, ["name"] = "Kong Unlocked: Chunky"},
	{["byte"] = 0x0E, ["bit"] = 6, ["name"] = "Factory: Lanky GB: Free Chunky", ["type"] = "GB"},
	{["byte"] = 0x0F, ["bit"] = 4, ["name"] = "Factory: Tiny GB: Bad hit detection wheel", ["type"] = "GB"},
	{["byte"] = 0x10, ["bit"] = 0, ["name"] = "Factory: DK GB: Crusher room", ["type"] = "GB"},
	{["byte"] = 0x11, ["bit"] = 2, ["name"] = "Key 3", ["type"] = "Key"},
	{["byte"] = 0x11, ["bit"] = 4, ["name"] = "Factory: Chunky's help me cutscene"},

	{["byte"] = 0x11, ["bit"] = 5, ["name"] = "Factory: W1 (Foyer)", ["type"] = "Warp"},
	{["byte"] = 0x11, ["bit"] = 6, ["name"] = "Factory: W1 (Storage Room)", ["type"] = "Warp"},
	{["byte"] = 0x11, ["bit"] = 7, ["name"] = "Factory: W2 (Foyer)", ["type"] = "Warp"},
	{["byte"] = 0x12, ["bit"] = 0, ["name"] = "Factory: W2 (R&D)", ["type"] = "Warp"},
	{["byte"] = 0x12, ["bit"] = 1, ["name"] = "Factory: W3 (Foyer)", ["type"] = "Warp"},
	{["byte"] = 0x12, ["bit"] = 2, ["name"] = "Factory: W3 (Snide's)", ["type"] = "Warp"},
	{["byte"] = 0x12, ["bit"] = 3, ["name"] = "Factory: W4 (Top)", ["type"] = "Warp"},
	{["byte"] = 0x12, ["bit"] = 4, ["name"] = "Factory: W4 (Bottom)", ["type"] = "Warp"},
	{["byte"] = 0x12, ["bit"] = 5, ["name"] = "Factory: W5 (Funky's)", ["type"] = "Warp"},
	{["byte"] = 0x12, ["bit"] = 6, ["name"] = "Factory: W5 (Arcade room)", ["type"] = "Warp"},

	{["byte"] = 0x13, ["bit"] = 0, ["name"] = "Factory: T&S Cleared"},
	{["byte"] = 0x13, ["bit"] = 1, ["name"] = "Galleon: Cannon game room open"},

	{["byte"] = 0x15, ["bit"] = 0, ["name"] = "Key 4", ["type"] = "Key"},

	{["byte"] = 0x19, ["bit"] = 6, ["name"] = "Fungi: Nighttime"},
	{["byte"] = 0x19, ["bit"] = 7, ["name"] = "Fungi: Green Tunnel (Feather Side)"},
	{["byte"] = 0x1A, ["bit"] = 2, ["name"] = "Fungi: Brown Tunnel Open"},
	{["byte"] = 0x1B, ["bit"] = 0, ["name"] = "Fungi: Diddy Barn GB", ["type"] = "GB"},
	{["byte"] = 0x1C, ["bit"] = 5, ["name"] = "Fungi: Mushroom Cannons"},
	{["byte"] = 0x1C, ["bit"] = 6, ["name"] = "Fungi: Mushroom Coconut Switch"},
	{["byte"] = 0x1C, ["bit"] = 7, ["name"] = "Fungi: Mushroom Grape Switch"},
	{["byte"] = 0x1D, ["bit"] = 0, ["name"] = "Fungi: Mushroom Feather Switch"},
	{["byte"] = 0x1D, ["bit"] = 1, ["name"] = "Fungi: Mushroom Peanut Switch"},
	{["byte"] = 0x1D, ["bit"] = 2, ["name"] = "Fungi: Mushroom Pineapple Switch"},
	{["byte"] = 0x1D, ["bit"] = 4, ["name"] = "Key 5", ["type"] = "Key"},

	{["byte"] = 0x1D, ["bit"] = 5, ["name"] = "Fungi: W1 (Mill)", ["type"] = "Warp"},
	{["byte"] = 0x1D, ["bit"] = 6, ["name"] = "Fungi: W1 (Tree)", ["type"] = "Warp"},
	{["byte"] = 0x1E, ["bit"] = 1, ["name"] = "Fungi: W3 (Tree)", ["type"] = "Warp"},
	{["byte"] = 0x1E, ["bit"] = 2, ["name"] = "Fungi: W3 (Mushroom)", ["type"] = "Warp"},
	{["byte"] = 0x1E, ["bit"] = 3, ["name"] = "Fungi: W4 (Tree)", ["type"] = "Warp"},
	{["byte"] = 0x1E, ["bit"] = 5, ["name"] = "Fungi: W5 (Low)", ["type"] = "Warp"},

	{["byte"] = 0x20, ["bit"] = 1, ["name"] = "Fungi: First time cutscene"},

	{["byte"] = 0x22, ["bit"] = 4, ["name"] = "Caves: DK Rotating room GB", ["type"] = "GB"},
	{["byte"] = 0x22, ["bit"] = 7, ["name"] = "Caves: Tiny Igloo GB", ["type"] = "GB"},

	{["byte"] = 0x23, ["bit"] = 4, ["name"] = "Caves: W1 (Enterance)", ["type"] = "Warp"},
	{["byte"] = 0x23, ["bit"] = 5, ["name"] = "Caves: W2 (Enterance)", ["type"] = "Warp"},
	{["byte"] = 0x23, ["bit"] = 6, ["name"] = "Caves: W2 (Far)", ["type"] = "Warp"},
	{["byte"] = 0x23, ["bit"] = 7, ["name"] = "Caves: W4 (Far)", ["type"] = "Warp"},
	{["byte"] = 0x24, ["bit"] = 2, ["name"] = "Caves: W5 (Lanky BP))", ["type"] = "Warp"},

	{["byte"] = 0x24, ["bit"] = 4, ["name"] = "Key 6", ["type"] = "Key"},
	{["byte"] = 0x24, ["bit"] = 5, ["name"] = "Caves: Diddy Cabin GB (Upper)", ["type"] = "GB"},
	
	{["byte"] = 0x25, ["bit"] = 3, ["name"] = "Caves: Giant Kosha cutscene"},
	
	{["byte"] = 0x27, ["bit"] = 5, ["name"] = "Key 7", ["type"] = "Key"},

	{["byte"] = 0x28, ["bit"] = 3, ["name"] = "Castle: Lanky: Greenhouse GB", ["type"] = "GB"},

	{["byte"] = 0x28, ["bit"] = 7, ["name"] = "Castle: W1 (Hub)", ["type"] = "Warp"},
	{["byte"] = 0x29, ["bit"] = 0, ["name"] = "Castle: W1 (Far)", ["type"] = "Warp"},
	{["byte"] = 0x29, ["bit"] = 1, ["name"] = "Castle: W2 (Hub)", ["type"] = "Warp"},
	-- TODO: W2
	{["byte"] = 0x29, ["bit"] = 3, ["name"] = "Castle: W3 (Hub)", ["type"] = "Warp"},
	-- TODO: W3
	{["byte"] = 0x29, ["bit"] = 5, ["name"] = "Castle: W4 (Hub)", ["type"] = "Warp"},
	-- TODO: W4
	{["byte"] = 0x29, ["bit"] = 7, ["name"] = "Castle: W5 (Hub)", ["type"] = "Warp"},
	-- TODO: W5
	{["byte"] = 0x2A, ["bit"] = 1, ["name"] = "Castle: W1 (Crypt, close)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 2, ["name"] = "Castle: W1 (Crypt, far)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 3, ["name"] = "Castle: W2 (Crypt, close)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 4, ["name"] = "Castle: W2 (Crypt, far)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 5, ["name"] = "Castle: W3 (Crypt, close)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 6, ["name"] = "Castle: W3 (Crypt, far)", ["type"] = "Warp"},

	{["byte"] = 0x2B, ["bit"] = 5, ["name"] = "Castle: First time cutscene"},
	
	{["byte"] = 0x2C, ["bit"] = 3, ["name"] = "Warp pad FTT"},
	{["byte"] = 0x2C, ["bit"] = 6, ["name"] = "Crown pad FTT"},
	{["byte"] = 0x2D, ["bit"] = 0, ["name"] = "Mini Monkey FTT?"},
	{["byte"] = 0x2D, ["bit"] = 1, ["name"] = "Hunky Chunky FTT"}, -- TODO: Test this
	{["byte"] = 0x2D, ["bit"] = 3, ["name"] = "Strong Kong FTT"}, -- TODO: Test this
	{["byte"] = 0x2D, ["bit"] = 7, ["name"] = "Diddy Caves Lobby GB, more like FTT of some sort"}, -- TODO: Test this
	{["byte"] = 0x2D, ["bit"] = 4, ["name"] = "Rainbow Coin FTT"}, -- TODO: Test this
	{["byte"] = 0x2D, ["bit"] = 5, ["name"] = "Rambi FTT"}, -- TODO: Test this
	{["byte"] = 0x2E, ["bit"] = 0, ["name"] = "Lanky FT GB", ["type"] = "GB"},
	{["byte"] = 0x2E, ["bit"] = 1, ["name"] = "Tiny FT GB", ["type"] = "GB"},
	{["byte"] = 0x2E, ["bit"] = 2, ["name"] = "Chunky FT GB", ["type"] = "GB"},
	{["byte"] = 0x2E, ["bit"] = 4, ["name"] = "Snide's FTT"},
	{["byte"] = 0x2F, ["bit"] = 0, ["name"] = "Wrinkly FTT"}, -- TODO: Test this
	{["byte"] = 0x2F, ["bit"] = 1, ["name"] = "? Fairy FTT"}, -- TODO: Test this

	{["byte"] = 0x2F, ["bit"] = 1, ["name"] = "Camera/Shockwave"},
	{["byte"] = 0x2F, ["bit"] = 2, ["name"] = "Training Grounds: Treehouse Squawk Cutscene"},
	{["byte"] = 0x2F, ["bit"] = 4, ["name"] = "Key 8", ["type"] = "Key"},
	{["byte"] = 0x2F, ["bit"] = 5, ["name"] = "Isles: Japes boulder GB", ["type"] = "GB"},
	{["byte"] = 0x2F, ["bit"] = 6, ["name"] = "B.Locker FTT"},
	{["byte"] = 0x2F, ["bit"] = 7, ["name"] = "Training Grounds: Barrels spwaned"}, -- TODO: Test this

	{["byte"] = 0x30, ["bit"] = 1, ["name"] = "Kong Unlocked: DK"},
	{["byte"] = 0x30, ["bit"] = 2, ["name"] = "Training Grounds: Dive Barrel Completed"},
	{["byte"] = 0x30, ["bit"] = 3, ["name"] = "Training Grounds: Vine Barrel Completed"},
	{["byte"] = 0x30, ["bit"] = 4, ["name"] = "Training Grounds: Orange Barrel Completed"}, -- TODO: Test this
	{["byte"] = 0x30, ["bit"] = 5, ["name"] = "Training Grounds: Barrel Barrel Completed"}, -- TODO: Test this

	{["byte"] = 0x30, ["bit"] = 6, ["name"] = "Isles: Escape FTT"}, -- TODO: Test this

	{["byte"] = 0x31, ["bit"] = 5, ["name"] = "Factory Lobby: Lever pulled"}, -- TODO: Test this
	{["byte"] = 0x31, ["bit"] = 6, ["name"] = "? Japes Lobby: Lanky GB", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x31, ["bit"] = 7, ["name"] = "Aztec Lobby: Side room open"}, -- TODO: Test this

	{["byte"] = 0x32, ["bit"] = 0, ["name"] = "Aztec Lobby: Chunky Wrinkly flipped"}, -- TODO: Test this
	{["byte"] = 0x32, ["bit"] = 1, ["name"] = "Galleon Lobby: Chunky Switch"}, -- TODO: Test this

	{["byte"] = 0x32, ["bit"] = 3, ["name"] = "? Galleon Lobby: Tiny GB?", ["type"] = "GB"}, -- TODO: Which one actually set it
	{["byte"] = 0x32, ["bit"] = 4, ["name"] = "Factory Lobby: DK GB", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x32, ["bit"] = 6, ["name"] = "Helm Lobby: Kremling Kosh GB", ["type"] = "GB"},
	{["byte"] = 0x32, ["bit"] = 7, ["name"] = "Helm Lobby: Bridge Spawned"},

	{["byte"] = 0x33, ["bit"] = 0, ["name"] = "Caves Lobby: Ice wall BP room"}, -- TODO: Test this
	{["byte"] = 0x33, ["bit"] = 1, ["name"] = "Caves Lobby: Ice wall GB room"}, -- TODO: Test this
	{["byte"] = 0x33, ["bit"] = 2, ["name"] = "Caves Lobby: Diddy GB", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x33, ["bit"] = 3, ["name"] = "Caves Lobby: DK GB", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x33, ["bit"] = 5, ["name"] = "Caves Lobby: Boulder on pad"}, -- TODO: Test this

	{["byte"] = 0x33, ["bit"] = 7, ["name"] = "Castle Lobby: Searchlight seek GB", ["type"] = "GB"},

	{["byte"] = 0x34, ["bit"] = 1, ["name"] = "Helm Lobby: W1 (Enterance)", ["type"] = "Warp"},
	{["byte"] = 0x34, ["bit"] = 2, ["name"] = "Helm Lobby: W1 (Far)", ["type"] = "Warp"},
	{["byte"] = 0x34, ["bit"] = 3, ["name"] = "Isles: DK Caged GB", ["type"] = "GB"},
	{["byte"] = 0x34, ["bit"] = 4, ["name"] = "Isles: Tiny Caged GB", ["type"] = "GB"},
	{["byte"] = 0x34, ["bit"] = 5, ["name"] = "Isles: Lanky Caged GB", ["type"] = "GB"},
	{["byte"] = 0x34, ["bit"] = 6, ["name"] = "Isles: Chunky Caged GB", ["type"] = "GB"},
	{["byte"] = 0x34, ["bit"] = 7, ["name"] = "Isles: Diddy Caged GB", ["type"] = "GB"},

	{["byte"] = 0x35, ["bit"] = 0, ["name"] = "Isles: Chunky instrument pad GB", ["type"] = "GB"},
	{["byte"] = 0x35, ["bit"] = 1, ["name"] = "Isles: Tiny: High instrument pad GB", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x35, ["bit"] = 2, ["name"] = "Isles: Lanky instrument pad played"},
	{["byte"] = 0x35, ["bit"] = 3, ["name"] = "Isles: Tiny: High instrument pad played"}, -- TODO: Test this
	{["byte"] = 0x35, ["bit"] = 4, ["name"] = "Isles: Diddy: Summit Bonus Barrel"},
	{["byte"] = 0x35, ["bit"] = 5, ["name"] = "Isles: Lanky Sprint GB", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x35, ["bit"] = 6, ["name"] = "Isles: Chunky: Pound the X"},
	{["byte"] = 0x35, ["bit"] = 7, ["name"] = "Isles: Chunky: Pound the X GB", ["type"] = "GB"},

	{["byte"] = 0x36, ["bit"] = 0, ["name"] = "K. Rool Defeated", ["type"] = "Warp"},
	{["byte"] = 0x36, ["bit"] = 1, ["name"] = "Isles: W1 (Ring)", ["type"] = "Warp"},
	{["byte"] = 0x36, ["bit"] = 2, ["name"] = "Isles: W1 (Far)", ["type"] = "Warp"},
	{["byte"] = 0x36, ["bit"] = 3, ["name"] = "Isles: W2 (Ring)", ["type"] = "Warp"},
	{["byte"] = 0x36, ["bit"] = 4, ["name"] = "Isles: W2 (High)", ["type"] = "Warp"},
	{["byte"] = 0x36, ["bit"] = 5, ["name"] = "Isles: W3 (Ring)", ["type"] = "Warp"},
	{["byte"] = 0x36, ["bit"] = 6, ["name"] = "Isles: W3 (Far)", ["type"] = "Warp"},
	{["byte"] = 0x36, ["bit"] = 7, ["name"] = "Isles: W4 (Ring)", ["type"] = "Warp"},
	{["byte"] = 0x37, ["bit"] = 0, ["name"] = "Isles: W4 (High)", ["type"] = "Warp"},
	{["byte"] = 0x37, ["bit"] = 1, ["name"] = "Isles: W5 (Far)", ["type"] = "Warp"},
	{["byte"] = 0x37, ["bit"] = 2, ["name"] = "Isles: W5 (Ring)", ["type"] = "Warp"},

	{["byte"] = 0x37, ["bit"] = 3, ["name"] = "Isles: Japes boulder smashed"},
	{["byte"] = 0x37, ["bit"] = 4, ["name"] = "Key 1 Turned", ["type"] = "Key"},
	{["byte"] = 0x37, ["bit"] = 5, ["name"] = "Key 2 Turned", ["type"] = "Key"},
	{["byte"] = 0x37, ["bit"] = 6, ["name"] = "Key 3 Turned", ["type"] = "Key"},
	{["byte"] = 0x37, ["bit"] = 7, ["name"] = "Key 4 Turned", ["type"] = "Key"},
	{["byte"] = 0x38, ["bit"] = 0, ["name"] = "Key 5 Turned", ["type"] = "Key"},
	{["byte"] = 0x38, ["bit"] = 1, ["name"] = "Key 6 Turned", ["type"] = "Key"},
	{["byte"] = 0x38, ["bit"] = 2, ["name"] = "Key 7 Turned", ["type"] = "Key"},
	{["byte"] = 0x38, ["bit"] = 3, ["name"] = "Key 8 Turned", ["type"] = "Key"},

	{["byte"] = 0x39, ["bit"] = 5, ["name"] = "Japes Lobby: B. Locker Cleared"},
	{["byte"] = 0x39, ["bit"] = 6, ["name"] = "Aztec Lobby: B. Locker Cleared"},
	{["byte"] = 0x39, ["bit"] = 7, ["name"] = "Factory Lobby: B. Locker Cleared"},
	{["byte"] = 0x3A, ["bit"] = 0, ["name"] = "Galleon Lobby: B. Locker Cleared"},

	{["byte"] = 0x3A, ["bit"] = 5, ["name"] = "Japes: Blueprint - DK", ["type"] = "Blueprint"},
	{["byte"] = 0x3A, ["bit"] = 6, ["name"] = "Japes: Blueprint - Diddy", ["type"] = "Blueprint"},
	{["byte"] = 0x3A, ["bit"] = 7, ["name"] = "Japes: Blueprint - Lanky", ["type"] = "Blueprint"},
	{["byte"] = 0x3B, ["bit"] = 0, ["name"] = "Japes: Blueprint - Tiny", ["type"] = "Blueprint"},
	{["byte"] = 0x3B, ["bit"] = 1, ["name"] = "Japes: Blueprint - Chunky", ["type"] = "Blueprint"},

	{["byte"] = 0x3B, ["bit"] = 2, ["name"] = "Aztec: Blueprint - DK", ["type"] = "Blueprint"},
	{["byte"] = 0x3B, ["bit"] = 3, ["name"] = "Aztec: Blueprint - Diddy", ["type"] = "Blueprint"},
	{["byte"] = 0x3B, ["bit"] = 4, ["name"] = "Aztec: Blueprint - Lanky", ["type"] = "Blueprint"},
	{["byte"] = 0x3B, ["bit"] = 5, ["name"] = "Aztec: Blueprint - Tiny", ["type"] = "Blueprint"},
	{["byte"] = 0x3B, ["bit"] = 6, ["name"] = "Aztec: Blueprint - Chunky", ["type"] = "Blueprint"},

	{["byte"] = 0x3B, ["bit"] = 7, ["name"] = "Factory: Blueprint - DK", ["type"] = "Blueprint"},
	{["byte"] = 0x3C, ["bit"] = 0, ["name"] = "Factory: Blueprint - Diddy", ["type"] = "Blueprint"},
	{["byte"] = 0x3C, ["bit"] = 1, ["name"] = "Factory: Blueprint - Lanky", ["type"] = "Blueprint"},
	{["byte"] = 0x3C, ["bit"] = 2, ["name"] = "Factory: Blueprint - Tiny", ["type"] = "Blueprint"},
	{["byte"] = 0x3C, ["bit"] = 3, ["name"] = "Factory: Blueprint - Chunky", ["type"] = "Blueprint"},

	{["byte"] = 0x3C, ["bit"] = 4, ["name"] = "Galleon: Blueprint - DK", ["type"] = "Blueprint"},
	{["byte"] = 0x3C, ["bit"] = 5, ["name"] = "Galleon: Blueprint - Diddy", ["type"] = "Blueprint"},
	{["byte"] = 0x3C, ["bit"] = 6, ["name"] = "Galleon: Blueprint - Lanky", ["type"] = "Blueprint"},
	{["byte"] = 0x3C, ["bit"] = 7, ["name"] = "Galleon: Blueprint - Tiny", ["type"] = "Blueprint"},
	{["byte"] = 0x3D, ["bit"] = 0, ["name"] = "Galleon: Blueprint - Chunky", ["type"] = "Blueprint"},

	{["byte"] = 0x3D, ["bit"] = 1, ["name"] = "Fungi: Blueprint - DK", ["type"] = "Blueprint"},
	{["byte"] = 0x3D, ["bit"] = 2, ["name"] = "Fungi: Blueprint - Diddy", ["type"] = "Blueprint"},
	{["byte"] = 0x3D, ["bit"] = 3, ["name"] = "Fungi: Blueprint - Lanky", ["type"] = "Blueprint"},
	{["byte"] = 0x3D, ["bit"] = 4, ["name"] = "Fungi: Blueprint - Tiny", ["type"] = "Blueprint"},
	{["byte"] = 0x3D, ["bit"] = 5, ["name"] = "Fungi: Blueprint - Chunky", ["type"] = "Blueprint"},

	{["byte"] = 0x3D, ["bit"] = 6, ["name"] = "Caves: Blueprint - DK", ["type"] = "Blueprint"},
	{["byte"] = 0x3D, ["bit"] = 7, ["name"] = "Caves: Blueprint - Diddy", ["type"] = "Blueprint"},
	{["byte"] = 0x3E, ["bit"] = 0, ["name"] = "Caves: Blueprint - Lanky", ["type"] = "Blueprint"},
	{["byte"] = 0x3E, ["bit"] = 1, ["name"] = "Caves: Blueprint - Tiny", ["type"] = "Blueprint"},
	{["byte"] = 0x3E, ["bit"] = 2, ["name"] = "Caves: Blueprint - Chunky", ["type"] = "Blueprint"},

	{["byte"] = 0x3E, ["bit"] = 3, ["name"] = "Castle: Blueprint - DK", ["type"] = "Blueprint"},
	{["byte"] = 0x3E, ["bit"] = 4, ["name"] = "Castle: Blueprint - Diddy", ["type"] = "Blueprint"},
	{["byte"] = 0x3E, ["bit"] = 5, ["name"] = "Castle: Blueprint - Lanky", ["type"] = "Blueprint"},
	{["byte"] = 0x3E, ["bit"] = 6, ["name"] = "Castle: Blueprint - Tiny", ["type"] = "Blueprint"},
	{["byte"] = 0x3E, ["bit"] = 7, ["name"] = "Castle: Blueprint - Chunky", ["type"] = "Blueprint"},

	{["byte"] = 0x3F, ["bit"] = 0, ["name"] = "Isles: Blueprint - DK", ["type"] = "Blueprint"},
	{["byte"] = 0x3F, ["bit"] = 1, ["name"] = "Isles: Blueprint - Diddy", ["type"] = "Blueprint"},
	{["byte"] = 0x3F, ["bit"] = 2, ["name"] = "Isles: Blueprint - Lanky", ["type"] = "Blueprint"},
	{["byte"] = 0x3F, ["bit"] = 3, ["name"] = "Isles: Blueprint - Tiny", ["type"] = "Blueprint"},
	{["byte"] = 0x3F, ["bit"] = 4, ["name"] = "Isles: Blueprint - Chunky", ["type"] = "Blueprint"},

	{["byte"] = 0x3F, ["bit"] = 5, ["name"] = "Snide's: DK BP Turned (Japes)", ["type"] = "Blueprint"},
	{["byte"] = 0x3F, ["bit"] = 6, ["name"] = "Snide's: Diddy BP Turned (Japes)", ["type"] = "Blueprint"},
	{["byte"] = 0x3F, ["bit"] = 7, ["name"] = "Snide's: Lanky BP Turned (Japes)", ["type"] = "Blueprint"},
	{["byte"] = 0x40, ["bit"] = 0, ["name"] = "Snide's: Tiny BP Turned (Japes)", ["type"] = "Blueprint"},
	{["byte"] = 0x40, ["bit"] = 1, ["name"] = "Snide's: Chunky BP Turned (Japes)", ["type"] = "Blueprint"},

	{["byte"] = 0x40, ["bit"] = 2, ["name"] = "Snide's: DK BP Turned (Aztec)", ["type"] = "Blueprint"},
	{["byte"] = 0x40, ["bit"] = 3, ["name"] = "Snide's: Diddy BP Turned (Aztec)", ["type"] = "Blueprint"},
	{["byte"] = 0x40, ["bit"] = 4, ["name"] = "Snide's: Lanky BP Turned (Aztec)", ["type"] = "Blueprint"},
	{["byte"] = 0x40, ["bit"] = 5, ["name"] = "Snide's: Tiny BP Turned (Aztec)", ["type"] = "Blueprint"},
	{["byte"] = 0x40, ["bit"] = 6, ["name"] = "Snide's: Chunky BP Turned (Aztec)", ["type"] = "Blueprint"},

	{["byte"] = 0x40, ["bit"] = 7, ["name"] = "Snide's: DK BP Turned (Factory)", ["type"] = "Blueprint"},
	{["byte"] = 0x41, ["bit"] = 0, ["name"] = "Snide's: Diddy BP Turned (Factory)", ["type"] = "Blueprint"},
	{["byte"] = 0x41, ["bit"] = 1, ["name"] = "Snide's: Lanky BP Turned (Factory)", ["type"] = "Blueprint"},
	{["byte"] = 0x41, ["bit"] = 2, ["name"] = "Snide's: Tiny BP Turned (Factory)", ["type"] = "Blueprint"},
	{["byte"] = 0x41, ["bit"] = 3, ["name"] = "Snide's: Chunky BP Turned (Factory)", ["type"] = "Blueprint"},

	{["byte"] = 0x41, ["bit"] = 4, ["name"] = "Snide's: DK BP Turned (Galleon)", ["type"] = "Blueprint"},
	{["byte"] = 0x41, ["bit"] = 5, ["name"] = "Snide's: Diddy BP Turned (Galleon)", ["type"] = "Blueprint"},
	{["byte"] = 0x41, ["bit"] = 6, ["name"] = "Snide's: Lanky BP Turned (Galleon)", ["type"] = "Blueprint"},
	{["byte"] = 0x41, ["bit"] = 7, ["name"] = "Snide's: Tiny BP Turned (Galleon)", ["type"] = "Blueprint"},
	{["byte"] = 0x42, ["bit"] = 0, ["name"] = "Snide's: Chunky BP Turned (Galleon)", ["type"] = "Blueprint"},

	{["byte"] = 0x42, ["bit"] = 1, ["name"] = "Snide's: DK BP Turned (Fungi)", ["type"] = "Blueprint"},
	-- TODO: Diddy
	-- TODO: Lanky
	-- TODO: Tiny
	-- TODO: Chunky
	
	{["byte"] = 0x42, ["bit"] = 6, ["name"] = "Snide's: DK BP Turned (Caves)", ["type"] = "Blueprint"},
	{["byte"] = 0x42, ["bit"] = 7, ["name"] = "Snide's: Diddy BP Turned (Caves)", ["type"] = "Blueprint"},
	{["byte"] = 0x43, ["bit"] = 0, ["name"] = "Snide's: Lanky BP Turned (Caves)", ["type"] = "Blueprint"},
	{["byte"] = 0x43, ["bit"] = 1, ["name"] = "Snide's: Tiny BP Turned (Caves)", ["type"] = "Blueprint"},
	{["byte"] = 0x43, ["bit"] = 2, ["name"] = "Snide's: Chunky BP Turned (Caves)", ["type"] = "Blueprint"},
	
	{["byte"] = 0x44, ["bit"] = 0, ["name"] = "Snide's: DK BP Turned (Isles)", ["type"] = "Blueprint"},
	{["byte"] = 0x44, ["bit"] = 1, ["name"] = "Snide's: Diddy BP Turned (Isles)", ["type"] = "Blueprint"},
	{["byte"] = 0x44, ["bit"] = 2, ["name"] = "Snide's: Lanky BP Turned (Isles)", ["type"] = "Blueprint"},
	{["byte"] = 0x44, ["bit"] = 3, ["name"] = "Snide's: Tiny BP Turned (Isles)", ["type"] = "Blueprint"},
	{["byte"] = 0x44, ["bit"] = 4, ["name"] = "Snide's: Chunky BP Turned (Isles)", ["type"] = "Blueprint"},

	{["byte"] = 0x44, ["bit"] = 5, ["name"] = "? Japes: DK CB: Balloon by Underground or Banana Medal", ["type"] = "Balloon"}, -- TODO: Test this
	{["byte"] = 0x44, ["bit"] = 7, ["name"] = "Japes: Lanky Banana Medal"},
	{["byte"] = 0x45, ["bit"] = 1, ["name"] = "Japes: Chunky Banana Medal"},

	{["byte"] = 0x4E, ["bit"] = 3, ["name"] = "?? Japes: DK CB: Balloon by Underground or Banana Medal", ["type"] = "Balloon"}, -- TODO: Test this

	{["byte"] = 0x49, ["bit"] = 5, ["name"] = "Japes: Fairy (Water room)", ["type"] = "Fairy"},
	{["byte"] = 0x49, ["bit"] = 6, ["name"] = "Japes: Fairy (Painting room)", ["type"] = "Fairy"},
	{["byte"] = 0x49, ["bit"] = 7, ["name"] = "Factory: Fairy (Funky's)", ["type"] = "Fairy"},
	{["byte"] = 0x4A, ["bit"] = 0, ["name"] = "Galleon: Fairy (Chunky's chest room)", ["type"] = "Fairy"},
	{["byte"] = 0x4A, ["bit"] = 1, ["name"] = "Isles: Fairy (Factory Lobby)", ["type"] = "Fairy"},
	{["byte"] = 0x4A, ["bit"] = 2, ["name"] = "Isles: Fairy (Fungi Lobby)", ["type"] = "Fairy"},
	{["byte"] = 0x4A, ["bit"] = 3, ["name"] = "Fungi: Fairy (Diddy's Barn)", ["type"] = "Fairy"},
	{["byte"] = 0x4A, ["bit"] = 4, ["name"] = "Fungi: Fairy (DK's Barn)", ["type"] = "Fairy"},
	{["byte"] = 0x4A, ["bit"] = 5, ["name"] = "Caves: Fairy (Tiny Igloo)", ["type"] = "Fairy"},
	{["byte"] = 0x4A, ["bit"] = 6, ["name"] = "Helm: Fairy (1)", ["type"] = "Fairy"},
	{["byte"] = 0x4A, ["bit"] = 7, ["name"] = "Helm: Fairy (2)", ["type"] = "Fairy"},
	{["byte"] = 0x4B, ["bit"] = 0, ["name"] = "Aztec: Fairy (Llama Temple)", ["type"] = "Fairy"},
	{["byte"] = 0x4B, ["bit"] = 1, ["name"] = "Aztec: Fairy (5DT, Tiny)", ["type"] = "Fairy"},
	{["byte"] = 0x4B, ["bit"] = 2, ["name"] = "Factory: Fairy (Number Game Tunnel)", ["type"] = "Fairy"},
	{["byte"] = 0x4B, ["bit"] = 3, ["name"] = "Galleon: Fairy (Tiny's 5DS)", ["type"] = "Fairy"},
	{["byte"] = 0x4B, ["bit"] = 4, ["name"] = "Castle: Fairy (Museum)", ["type"] = "Fairy"},
	{["byte"] = 0x4B, ["bit"] = 5, ["name"] = "Castle: Fairy (Tree)", ["type"] = "Fairy"},
	{["byte"] = 0x4B, ["bit"] = 6, ["name"] = "Isles: Fairy (Tree)", ["type"] = "Fairy"},
	{["byte"] = 0x4B, ["bit"] = 7, ["name"] = "Isles: Fairy (High)", ["type"] = "Fairy"},
	{["byte"] = 0x4C, ["bit"] = 0, ["name"] = "Caves: Fairy (Diddy Cabin)", ["type"] = "Fairy"},

	{["byte"] = 0x4C, ["bit"] = 1, ["name"] = "Japes: Crown", ["type"] = "Crown"},
	{["byte"] = 0x4C, ["bit"] = 2, ["name"] = "Aztec: Crown", ["type"] = "Crown"},
	{["byte"] = 0x4C, ["bit"] = 3, ["name"] = "Factory: Crown", ["type"] = "Crown"},
	{["byte"] = 0x4C, ["bit"] = 4, ["name"] = "Galleon: Crown", ["type"] = "Crown"},
	{["byte"] = 0x4C, ["bit"] = 5, ["name"] = "Fungi: Crown", ["type"] = "Crown"},
	{["byte"] = 0x4C, ["bit"] = 6, ["name"] = "Isles: Crown (Fungi Lobby)", ["type"] = "Crown"},
	{["byte"] = 0x4C, ["bit"] = 7, ["name"] = "Isles: Crown (Snide's)", ["type"] = "Crown"},
	{["byte"] = 0x4D, ["bit"] = 0, ["name"] = "Caves: Crown", ["type"] = "Crown"},
	{["byte"] = 0x4D, ["bit"] = 1, ["name"] = "Castle: Crown", ["type"] = "Crown"},
	{["byte"] = 0x4D, ["bit"] = 2, ["name"] = "Helm: Crown", ["type"] = "Crown"},

	{["byte"] = 0x4D, ["bit"] = 3, ["name"] = "Test Room: Balloon", ["type"] = "Balloon"},

	{["byte"] = 0x4D, ["bit"] = 5, ["name"] = "Japes: Rainbow Coin (Slope by painting room)"},
	{["byte"] = 0x4D, ["bit"] = 6, ["name"] = "Japes: Diddy CB: Balloon in cave", ["type"] = "Balloon"},
	{["byte"] = 0x4D, ["bit"] = 7, ["name"] = "Japes: DK CB: Balloon by Snide", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 0, ["name"] = "Japes: Chunky CB: Balloon in cave (1)", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 1, ["name"] = "Japes: Lanky CB: Balloon by hut", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 2, ["name"] = "Japes: Diddy CB: Balloon by W5", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 4, ["name"] = "Japes: DK CB: Balloon by Cranky", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 5, ["name"] = "Japes: Tiny CB: Balloon by hut", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 6, ["name"] = "Japes: Tiny CB: Balloon in Fairy room", ["type"] = "Balloon"},

	{["byte"] = 0x4E, ["bit"] = 7, ["name"] = "Japes: Chunky CB: Balloon in cave (2)", ["type"] = "Balloon"},
	{["byte"] = 0x4F, ["bit"] = 0, ["name"] = "Japes: Chunky CB: Balloon in cave (3)", ["type"] = "Balloon"},

	{["byte"] = 0x4F, ["bit"] = 1, ["name"] = "Japes: Lanky CB: Balloon by his BP", ["type"] = "Balloon"},
	{["byte"] = 0x4F, ["bit"] = 2, ["name"] = "Japes: Tiny CB: Balloon in shellhive", ["type"] = "Balloon"},
	{["byte"] = 0x4F, ["bit"] = 3, ["name"] = "Japes: Lanky CB: Balloon in painting room)", ["type"] = "Balloon"},

	{["byte"] = 0x54, ["bit"] = 4, ["name"] = "Isles: Rainbow Coin (Fungi Lobby Enterance)?", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x54, ["bit"] = 5, ["name"] = "Isles: Rainbow Coin (Slope leading to Aztec Lobby)", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x54, ["bit"] = 6, ["name"] = "Isles: Rainbow Coin (Aztec Lobby Roof)", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x56, ["bit"] = 2, ["name"] = "Fungi: Rainbow Coin", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x57, ["bit"] = 0, ["name"] = "Fungi: Balloon - DK Mill", ["type"] = "Balloon"},
	{["byte"] = 0x57, ["bit"] = 2, ["name"] = "Fungi: Balloon - Lanky Lower Mushroom", ["type"] = "Balloon"},
	{["byte"] = 0x59, ["bit"] = 1, ["name"] = "Castle: Rainbow Coin (Snide's)", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x59, ["bit"] = 6, ["name"] = "Isles: Rainbow Coin (K. Lumsy)", ["type"] = "Rainbow Coin"},

	{["byte"] = 0x5C, ["bit"] = 3, ["name"] = "Castle Lobby: Rainbow Coin", ["type"] = "Rainbow Coin"},

	{["byte"] = 0x60, ["bit"] = 2, ["name"] = "Helm: BoM off"},
	{["byte"] = 0x60, ["bit"] = 4, ["name"] = "Helm: Crown door open"},
	{["byte"] = 0x60, ["bit"] = 5, ["name"] = "Helm: W1 (Enterance)"},
	{["byte"] = 0x60, ["bit"] = 6, ["name"] = "Helm: W1 (Far)"},

	{["byte"] = 0x61, ["bit"] = 3, ["name"] = "Japes: FTT"},
	{["byte"] = 0x62, ["bit"] = 0, ["name"] = "Castle: FTT"},
	{["byte"] = 0x62, ["bit"] = 1, ["name"] = "T&S FTT"},
	{["byte"] = 0x62, ["bit"] = 2, ["name"] = "Helm: FTT"},
	{["byte"] = 0x62, ["bit"] = 3, ["name"] = "Aztec: FTT"},

	{["byte"] = 0x64, ["bit"] = 0, ["name"] = "Japes: Chunky Coin: By portal (1)", ["type"] = "Coin"},
	{["byte"] = 0x64, ["bit"] = 1, ["name"] = "Japes: Chunky Coin: In water (1)", ["type"] = "Coin"},
	{["byte"] = 0x64, ["bit"] = 2, ["name"] = "Japes: Tiny CB: Tunnel to main area (1)", ["type"] = "CB"},
	{["byte"] = 0x64, ["bit"] = 3, ["name"] = "Japes: Tiny CB: Tunnel to main area (2)", ["type"] = "CB"},
	{["byte"] = 0x64, ["bit"] = 4, ["name"] = "Japes: Tiny CB: Tunnel to main area (3)", ["type"] = "CB"},
	{["byte"] = 0x64, ["bit"] = 5, ["name"] = "Japes: Chunky CB: Shellhive tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0x64, ["bit"] = 6, ["name"] = "Japes: Tiny CB: Tunnel to main area (4)", ["type"] = "CB"},
	{["byte"] = 0x65, ["bit"] = 0, ["name"] = "Japes: DK CB: By enterance (1)", ["type"] = "CB"},
	{["byte"] = 0x65, ["bit"] = 2, ["name"] = "Japes: DK CB: Bunch on left W3", ["type"] = "Bunch"}, -- TODO: Test this
	{["byte"] = 0x65, ["bit"] = 4, ["name"] = "Japes: DK CB: By enterance (2)", ["type"] = "CB"},
	{["byte"] = 0x65, ["bit"] = 6, ["name"] = "Japes: Chunky CB: Bunch on Funky's (Right)", ["type"] = "Bunch"},
	{["byte"] = 0x65, ["bit"] = 7, ["name"] = "Japes: Lanky CB: Bunch on tree by Cranky's", ["type"] = "Bunch"},
	{["byte"] = 0x66, ["bit"] = 3, ["name"] = "Japes: Diddy CB: 101st banana", ["type"] = "CB"},
	{["byte"] = 0x66, ["bit"] = 5, ["name"] = "Japes: DK CB: By enterance (3)", ["type"] = "CB"},
	{["byte"] = 0x66, ["bit"] = 6, ["name"] = "Japes: DK CB: By enterance (4)", ["type"] = "CB"},
	{["byte"] = 0x66, ["bit"] = 7, ["name"] = "Japes: DK CB: By enterance (5)", ["type"] = "CB"},
	{["byte"] = 0x68, ["bit"] = 0, ["name"] = "Japes: Chunky Coin: By portal (2)", ["type"] = "Coin"},
	{["byte"] = 0x68, ["bit"] = 1, ["name"] = "Japes: Lanky CB: Bonus Barrel Room (1)", ["type"] = "CB"},
	{["byte"] = 0x68, ["bit"] = 2, ["name"] = "Japes: Chunky Coin: In water (2)", ["type"] = "Coin"},
	{["byte"] = 0x68, ["bit"] = 3, ["name"] = "Japes: Chunky Coin: In water (3)", ["type"] = "Coin"},
	{["byte"] = 0x68, ["bit"] = 4, ["name"] = "Japes: Diddy CB: Bunch under hut", ["type"] = "Bunch"},
	{["byte"] = 0x68, ["bit"] = 5, ["name"] = "Japes: Lanky CB: Bonus Barrel Room (2)", ["type"] = "CB"},
	{["byte"] = 0x68, ["bit"] = 7, ["name"] = "Japes: Lanky Coin: Cave near enterance (1)", ["type"] = "Coin"},
	{["byte"] = 0x69, ["bit"] = 6, ["name"] = "Japes: Lanky CB: Bunch under hut", ["type"] = "Bunch"},
	{["byte"] = 0x69, ["bit"] = 7, ["name"] = "Japes: DK CB: Bunch under hut", ["type"] = "Bunch"},
	{["byte"] = 0x6A, ["bit"] = 1, ["name"] = "Japes: Lanky CB: Bunch under bonus barrel", ["type"] = "Bunch"},
	{["byte"] = 0x6A, ["bit"] = 5, ["name"] = "Japes: Diddy CB: In right tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0x6B, ["bit"] = 0, ["name"] = "Japes: DK Coin by babboon blast pad (1)", ["type"] = "Coin"},
	{["byte"] = 0x6B, ["bit"] = 4, ["name"] = "Japes: DK Coin by enterance", ["type"] = "Coin"},
	{["byte"] = 0x6B, ["bit"] = 5, ["name"] = "Japes: Chunky CB: Shellhive tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0x6C, ["bit"] = 0, ["name"] = "Japes: Chunky CB: Shellhive tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0x6C, ["bit"] = 6, ["name"] = "Japes: DK CB: Bunch by Funky's (tree)", ["type"] = "Bunch"}, -- TODO: Test this
	{["byte"] = 0x6D, ["bit"] = 0, ["name"] = "Japes: Chunky CB: Bunch in Shellhive area (1)", ["type"] = "Bunch"},
	{["byte"] = 0x6D, ["bit"] = 1, ["name"] = "Japes: Tiny Coin: Fairy cave (1)", ["type"] = "Coin"},
	{["byte"] = 0x6D, ["bit"] = 3, ["name"] = "Japes: Diddy CB: In right tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0x6D, ["bit"] = 4, ["name"] = "Japes: Diddy CB: In right tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0x6D, ["bit"] = 6, ["name"] = "Japes: DK Coin by babboon blast pad (2)", ["type"] = "Coin"},
	{["byte"] = 0x6D, ["bit"] = 7, ["name"] = "Japes: DK Coin by enterance", ["type"] = "Coin"},
	{["byte"] = 0x6E, ["bit"] = 0, ["name"] = "Japes: Tiny CB: Bunch under hut", ["type"] = "Bunch"},
	{["byte"] = 0x6E, ["bit"] = 3, ["name"] = "Japes: DK Coin by his BP (1)", ["type"] = "Coin"},
	{["byte"] = 0x6E, ["bit"] = 4, ["name"] = "Japes: Tiny Coin by her BP (1)", ["type"] = "Coin"},
	{["byte"] = 0x6E, ["bit"] = 5, ["name"] = "Japes: Diddy CB: Bunch on tree (Middle Left)", ["type"] = "Bunch"},
	{["byte"] = 0x6E, ["bit"] = 6, ["name"] = "Japes: Diddy CB: Bunch on tree (Left)", ["type"] = "Bunch"},
	{["byte"] = 0x6F, ["bit"] = 0, ["name"] = "Japes: Lanky Coin: Cave near enterance (2)", ["type"] = "Coin"},
	{["byte"] = 0x6F, ["bit"] = 1, ["name"] = "Japes: Lanky Coin: Cave near enterance (3)", ["type"] = "Coin"},
	{["byte"] = 0x6F, ["bit"] = 2, ["name"] = "Japes: Diddy Coin by his BP", ["type"] = "Coin"},
	{["byte"] = 0x6F, ["bit"] = 3, ["name"] = "Japes: Chunky CB: Shellhive tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0x6F, ["bit"] = 5, ["name"] = "Japes: Diddy CB: By enterance (1)", ["type"] = "CB"},
	{["byte"] = 0x6F, ["bit"] = 6, ["name"] = "Japes: Tiny Coin by her BP (2)", ["type"] = "Coin"},
	{["byte"] = 0x6F, ["bit"] = 7, ["name"] = "Japes: DK Coin by enterance", ["type"] = "Coin"},

	{["byte"] = 0x70, ["bit"] = 3, ["name"] = "Japes: Tiny CB: Bunch in log (1)", ["type"] = "Bunch"},
	{["byte"] = 0x70, ["bit"] = 4, ["name"] = "Japes: Tiny CB: Bunch in log (2)", ["type"] = "Bunch"},
	{["byte"] = 0x70, ["bit"] = 5, ["name"] = "Japes: Tiny CB: Bunch in log (3)", ["type"] = "Bunch"},
	{["byte"] = 0x70, ["bit"] = 7, ["name"] = "Japes: Tiny CB: Bunch infront of Shellhive", ["type"] = "Bunch"},
	{["byte"] = 0x71, ["bit"] = 3, ["name"] = "Japes: Chunky CB: Shellhive tunnel (5)", ["type"] = "CB"},
	{["byte"] = 0x71, ["bit"] = 4, ["name"] = "Japes: Chunky CB: Shellhive tunnel (6)", ["type"] = "CB"},
	{["byte"] = 0x71, ["bit"] = 5, ["name"] = "Japes: Chunky CB: Shellhive tunnel (7)", ["type"] = "CB"},
	{["byte"] = 0x71, ["bit"] = 6, ["name"] = "Japes: Chunky CB: Shellhive tunnel (8)", ["type"] = "CB"},
	{["byte"] = 0x71, ["bit"] = 7, ["name"] = "Japes: Chunky CB: Shellhive tunnel (9)", ["type"] = "CB"},
	{["byte"] = 0x72, ["bit"] = 0, ["name"] = "Japes: Diddy CB: Bunch in water (Left)", ["type"] = "Bunch"},
	{["byte"] = 0x72, ["bit"] = 2, ["name"] = "Japes: Diddy CB: Bunch in water (Right)", ["type"] = "Bunch"},
	{["byte"] = 0x72, ["bit"] = 3, ["name"] = "Japes: Diddy CB: Bunch on tree (Right)", ["type"] = "Bunch"},
	{["byte"] = 0x72, ["bit"] = 4, ["name"] = "Japes: Diddy Coin by his BP", ["type"] = "Coin"},
	{["byte"] = 0x72, ["bit"] = 5, ["name"] = "Japes: Diddy CB: Bunch on tree (Middle Right)", ["type"] = "Bunch"},
	{["byte"] = 0x73, ["bit"] = 0, ["name"] = "Japes: Tiny CB: Tunnel to main area (5)", ["type"] = "CB"},
	{["byte"] = 0x73, ["bit"] = 1, ["name"] = "Japes: DK Coin by babboon blast pad (3)", ["type"] = "Coin"},
	{["byte"] = 0x73, ["bit"] = 2, ["name"] = "Japes: Chunky Coin: By portal (3)", ["type"] = "Coin"},
	{["byte"] = 0x73, ["bit"] = 3, ["name"] = "Japes: Tiny CB: Fairy cave (1)", ["type"] = "CB"},
	{["byte"] = 0x73, ["bit"] = 4, ["name"] = "Japes: Tiny CB: Fairy cave (2)", ["type"] = "CB"},
	{["byte"] = 0x73, ["bit"] = 5, ["name"] = "Japes: Lanky Coin: In water (Left) (1)", ["type"] = "Coin"},
	{["byte"] = 0x73, ["bit"] = 6, ["name"] = "Japes: Lanky Coin: In water (Left) (2)", ["type"] = "Coin"},
	{["byte"] = 0x73, ["bit"] = 7, ["name"] = "Japes: Tiny CB: Fairy cave (3)", ["type"] = "CB"},
	{["byte"] = 0x74, ["bit"] = 0, ["name"] = "Japes: Lanky CB: Bonus Barrel Room (3)", ["type"] = "CB"},
	{["byte"] = 0x74, ["bit"] = 1, ["name"] = "Japes: Lanky CB: Fairy cave (1)", ["type"] = "CB"},
	{["byte"] = 0x74, ["bit"] = 2, ["name"] = "Japes: Lanky CB: Fairy cave (2)", ["type"] = "CB"},
	{["byte"] = 0x74, ["bit"] = 3, ["name"] = "Japes: Lanky CB: Fairy cave (3)", ["type"] = "CB"},
	{["byte"] = 0x74, ["bit"] = 5, ["name"] = "Japes: Chunky CB: Bunch on Funky's (Left)", ["type"] = "Bunch"},
	{["byte"] = 0x74, ["bit"] = 6, ["name"] = "Japes: Diddy CB: By enterance (2)", ["type"] = "CB"},
	{["byte"] = 0x74, ["bit"] = 7, ["name"] = "Japes: Lanky Coin: Bonus Barrel Room (1)"}, -- TODO: Flags missing in this room with block size 0x80
	{["byte"] = 0x75, ["bit"] = 0, ["name"] = "Japes: Lanky CB: Painting room slope (1)", ["type"] = "CB"},
	{["byte"] = 0x75, ["bit"] = 1, ["name"] = "Japes: Lanky CB: Painting room slope (2)", ["type"] = "CB"},
	{["byte"] = 0x75, ["bit"] = 2, ["name"] = "Japes: Lanky CB: In water (1)", ["type"] = "CB"},
	{["byte"] = 0x75, ["bit"] = 3, ["name"] = "Japes: Lanky CB: In water (2)", ["type"] = "CB"},
	{["byte"] = 0x75, ["bit"] = 4, ["name"] = "Japes: Lanky CB: In water (3)", ["type"] = "CB"},
	{["byte"] = 0x75, ["bit"] = 5, ["name"] = "Japes: Lanky CB: In water (4)", ["type"] = "CB"},
	{["byte"] = 0x75, ["bit"] = 6, ["name"] = "Japes: Lanky CB: In water (5)", ["type"] = "CB"},
	{["byte"] = 0x75, ["bit"] = 7, ["name"] = "Japes: Lanky CB: Fairy cave (4)", ["type"] = "CB"},
	{["byte"] = 0x76, ["bit"] = 2, ["name"] = "Japes: Lanky CB: Bonus Barrel Room (4)", ["type"] = "CB"},
	{["byte"] = 0x76, ["bit"] = 3, ["name"] = "Japes: Lanky CB: Bonus Barrel Room (5)", ["type"] = "CB"},
	{["byte"] = 0x76, ["bit"] = 4, ["name"] = "Japes: Lanky CB: Bonus Barrel Room (6)", ["type"] = "CB"},
	{["byte"] = 0x76, ["bit"] = 5, ["name"] = "Japes: Lanky CB: Fairy cave (5)", ["type"] = "CB"},
	{["byte"] = 0x76, ["bit"] = 6, ["name"] = "Japes: Lanky CB: Bonus Barrel Room (7)", ["type"] = "CB"},
	{["byte"] = 0x76, ["bit"] = 7, ["name"] = "Japes: Lanky CB: Painting room slope (3)", ["type"] = "CB"},

	{["byte"] = 0x77, ["bit"] = 0, ["name"] = "Japes: Tiny CB: Bunch on tree by Cranky's", ["type"] = "Bunch"},
	{["byte"] = 0x77, ["bit"] = 1, ["name"] = "Japes: Tiny CB: Bunch under bonus barrel", ["type"] = "Bunch"},
	{["byte"] = 0x77, ["bit"] = 2, ["name"] = "Japes: Diddy Coin: In water (Left) (1)", ["type"] = "Coin"},
	{["byte"] = 0x77, ["bit"] = 3, ["name"] = "Japes: Chunky CB: Shellhive tunnel (10)", ["type"] = "CB"},
	{["byte"] = 0x77, ["bit"] = 4, ["name"] = "Japes: Diddy Coin: In water (Left) (2)", ["type"] = "Coin"},
	{["byte"] = 0x77, ["bit"] = 5, ["name"] = "Japes: Diddy Coin: In water (Left) (3)", ["type"] = "Coin"},	
	{["byte"] = 0x77, ["bit"] = 6, ["name"] = "Japes: Chunky Coin behind stump (1)", ["type"] = "Coin"},
	{["byte"] = 0x77, ["bit"] = 7, ["name"] = "Japes: Chunky Coin behind stump (2)", ["type"] = "Coin"},

	{["byte"] = 0x78, ["bit"] = 0, ["name"] = "Japes: Chunky CB: By underground (1)", ["type"] = "CB"},
	{["byte"] = 0x78, ["bit"] = 1, ["name"] = "Japes: Chunky CB: Bunch on top of Cranky's", ["type"] = "Bunch"},
	{["byte"] = 0x78, ["bit"] = 2, ["name"] = "Japes: Lanky Coin: By Snide's (1)", ["type"] = "Coin"},
	{["byte"] = 0x78, ["bit"] = 3, ["name"] = "Japes: Lanky CB: Bunch by Snide's", ["type"] = "Bunch"},
	{["byte"] = 0x78, ["bit"] = 4, ["name"] = "Japes: Lanky Coin: By Snide's (2)", ["type"] = "Coin"},
	{["byte"] = 0x78, ["bit"] = 5, ["name"] = "Japes: Lanky Coin: By Snide's (3)", ["type"] = "Coin"},
	{["byte"] = 0x78, ["bit"] = 6, ["name"] = "Japes: DK Coin by his BP (2)", ["type"] = "Coin"},
	{["byte"] = 0x78, ["bit"] = 7, ["name"] = "Japes: Tiny Coin by her BP (3)", ["type"] = "Coin"},

	{["byte"] = 0x79, ["bit"] = 0, ["name"] = "Japes: Tiny CB: Fairy cave (4)", ["type"] = "CB"},
	{["byte"] = 0x79, ["bit"] = 1, ["name"] = "Japes: Tiny CB: Fairy cave (5)", ["type"] = "CB"},
	{["byte"] = 0x79, ["bit"] = 2, ["name"] = "Japes: Tiny CB: Fairy cave (6)", ["type"] = "CB"},
	{["byte"] = 0x79, ["bit"] = 4, ["name"] = "Japes: Chunky CB: By underground (2)", ["type"] = "CB"},
	{["byte"] = 0x79, ["bit"] = 5, ["name"] = "Japes: Chunky CB: By underground (3)", ["type"] = "CB"},
	{["byte"] = 0x79, ["bit"] = 6, ["name"] = "Japes: Chunky CB: By underground (4)", ["type"] = "CB"},
	{["byte"] = 0x79, ["bit"] = 7, ["name"] = "Japes: Chunky CB: By underground (5)", ["type"] = "CB"},

	{["byte"] = 0x7A, ["bit"] = 2, ["name"] = "Japes: Tiny Coin: Fairy cave (2)", ["type"] = "Coin"},
	{["byte"] = 0x7A, ["bit"] = 3, ["name"] = "Japes: Tiny Coin: Fairy cave (3)", ["type"] = "Coin"},
	{["byte"] = 0x7A, ["bit"] = 4, ["name"] = "Japes: Tiny Coin: Fairy cave (4)", ["type"] = "Coin"},
	{["byte"] = 0x7A, ["bit"] = 5, ["name"] = "Japes: Chunky CB: Bunch in Shellhive area (2)", ["type"] = "Bunch"},
	{["byte"] = 0x7A, ["bit"] = 6, ["name"] = "Japes: Chunky CB: Bunch in Shellhive area (3)", ["type"] = "Bunch"},
	{["byte"] = 0x7A, ["bit"] = 7, ["name"] = "Japes: Tiny CB: Fairy cave (7)", ["type"] = "CB"},

	{["byte"] = 0x7B, ["bit"] = 0, ["name"] = "Japes: Lanky Coin: Bonus Barrel Room (2)"}, -- TODO: Flags missing in this room with block size 0x80
	{["byte"] = 0x7B, ["bit"] = 1, ["name"] = "Japes: Chunky CB: Bunch in Shellhive area (4)", ["type"] = "Bunch"},
	{["byte"] = 0x7B, ["bit"] = 2, ["name"] = "Japes: Chunky Coin behind stump (3)", ["type"] = "Coin"},
	{["byte"] = 0x7B, ["bit"] = 3, ["name"] = "Japes: Diddy Coin by his BP", ["type"] = "Coin"},
	{["byte"] = 0x7B, ["bit"] = 4, ["name"] = "Japes: Lanky Coin: By Snide's (4)", ["type"] = "Coin"},
	{["byte"] = 0x7B, ["bit"] = 5, ["name"] = "Japes: Lanky Coin: By Snide's (5)", ["type"] = "Coin"},

	{["byte"] = 0x7C, ["bit"] = 0, ["name"] = "Japes: Tiny Coin: Underground (1)", ["type"] = "Coin"},
	{["byte"] = 0x7C, ["bit"] = 3, ["name"] = "Japes: Tiny Coin: Underground (2)", ["type"] = "Coin"},
	{["byte"] = 0x7C, ["bit"] = 6, ["name"] = "Japes: DK CB: Bunch in Babboon blast (1)", ["type"] = "Bunch"},  -- TODO: Flags missing in this room with block size 0x80
	{["byte"] = 0x7C, ["bit"] = 7, ["name"] = "Japes: DK Coin: Babboon blast (1)", ["type"] = "Coin"},  -- TODO: Flags missing in this room with block size 0x80
	{["byte"] = 0x7D, ["bit"] = 0, ["name"] = "Japes: Lanky CB: Bunch in painting room (Left)", ["type"] = "Bunch"},
	{["byte"] = 0x7D, ["bit"] = 1, ["name"] = "Japes: Tiny Coin: Underground (3)", ["type"] = "Coin"},

	{["byte"] = 0x7E, ["bit"] = 0, ["name"] = "Japes: Tiny CB: Inside shellhive (1)", ["type"] = "CB"},
	{["byte"] = 0x7E, ["bit"] = 1, ["name"] = "Japes: Tiny CB: Inside shellhive (2)", ["type"] = "CB"},
	{["byte"] = 0x7E, ["bit"] = 2, ["name"] = "Japes: Tiny CB: Inside shellhive (3)", ["type"] = "CB"},
	{["byte"] = 0x7E, ["bit"] = 3, ["name"] = "Japes: Lanky CB: Bunch in painting room (Right)", ["type"] = "Bunch"},
	{["byte"] = 0x7E, ["bit"] = 4, ["name"] = "Japes: Lanky CB: Bunch in painting room (1)", ["type"] = "Bunch"},
	{["byte"] = 0x7E, ["bit"] = 5, ["name"] = "Japes: Lanky Coin: In painting room (Left)", ["type"] = "Coin"},
	{["byte"] = 0x7E, ["bit"] = 6, ["name"] = "Japes: Lanky Coin: In painting room (Right)", ["type"] = "Coin"},
	{["byte"] = 0x7E, ["bit"] = 7, ["name"] = "Japes: Lanky CB: Bunch in painting room (2)", ["type"] = "Bunch"},

	{["byte"] = 0x7F, ["bit"] = 0, ["name"] = "Japes: DK Coin by his BP (3)", ["type"] = "Coin"},
	{["byte"] = 0x7F, ["bit"] = 1, ["name"] = "Japes: Tiny Coin: Inside shellhive (1)", ["type"] = "Coin"},
	{["byte"] = 0x7F, ["bit"] = 2, ["name"] = "Japes: Tiny Coin: Inside shellhive (2)", ["type"] = "Coin"},
	{["byte"] = 0x7F, ["bit"] = 3, ["name"] = "Japes: Tiny CB: Inside shellhive (4)", ["type"] = "CB"},
	{["byte"] = 0x7F, ["bit"] = 4, ["name"] = "Japes: Tiny CB: Inside shellhive (5)", ["type"] = "CB"},
	{["byte"] = 0x7F, ["bit"] = 5, ["name"] = "Japes: Tiny CB: Inside shellhive (6)", ["type"] = "CB"},
	{["byte"] = 0x7F, ["bit"] = 6, ["name"] = "Japes: Tiny CB: Inside shellhive (7)", ["type"] = "CB"},
	{["byte"] = 0x7F, ["bit"] = 7, ["name"] = "Japes: Tiny CB: Inside shellhive (8)", ["type"] = "CB"},

	{["byte"] = 0x81, ["bit"] = 3, ["name"] = "Aztec: Lanky CB: Bunch on Tiny temple switch", ["type"] = "Bunch"},

	{["byte"] = 0x82, ["bit"] = 6, ["name"] = "Aztec: Diddy Coin: Instrument pad (Tiny temple)", ["type"] = "Coin"},

	{["byte"] = 0xBD, ["bit"] = 0, ["name"] = "Factory: DK CB: Bunch in power shed (GB)", ["type"] = "Bunch"},
	{["byte"] = 0xBD, ["bit"] = 1, ["name"] = "Factory: DK CB: Bunch in power shed (Left)", ["type"] = "Bunch"},
	{["byte"] = 0xBD, ["bit"] = 2, ["name"] = "Factory: DK CB: Bunch in power shed (Right)", ["type"] = "Bunch"},
	{["byte"] = 0xBD, ["bit"] = 4, ["name"] = "Factory: DK CB: Bunch in crusher room (1)", ["type"] = "Bunch"},
	{["byte"] = 0xBD, ["bit"] = 5, ["name"] = "Factory: DK CB: Bunch in crusher room (2)", ["type"] = "Bunch"},
	{["byte"] = 0xBD, ["bit"] = 6, ["name"] = "Factory: DK CB: Bunch in crusher room (3)", ["type"] = "Bunch"},

	{["byte"] = 0xD0, ["bit"] = 0, ["name"] = "Galleon: Chunky coin around BP (1)", ["type"] = "Coin"},
	{["byte"] = 0xD1, ["bit"] = 4, ["name"] = "Galleon: Chunky coin around BP (2)", ["type"] = "Coin"},
	{["byte"] = 0xD1, ["bit"] = 5, ["name"] = "Galleon: Chunky coin around BP (3)", ["type"] = "Coin"},
	{["byte"] = 0xD1, ["bit"] = 6, ["name"] = "Galleon: Chunky coin around BP (4)", ["type"] = "Coin"},
	{["byte"] = 0xD1, ["bit"] = 7, ["name"] = "Galleon: Chunky coin around BP (5)", ["type"] = "Coin"},

	{["byte"] = 0xDC, ["bit"] = 0, ["name"] = "Fungi: DK CB: Blue tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xDC, ["bit"] = 1, ["name"] = "Fungi: DK CB: Blue tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xDC, ["bit"] = 2, ["name"] = "Fungi: DK CB: Blue tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xDC, ["bit"] = 3, ["name"] = "Fungi: DK CB: Blue tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xDC, ["bit"] = 4, ["name"] = "Fungi: DK CB: Blue tunnel (5)", ["type"] = "CB"},

	{["byte"] = 0xDD, ["bit"] = 3, ["name"] = "Fungi: DK CB: Pink tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xDD, ["bit"] = 4, ["name"] = "Fungi: DK CB: Pink tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xDD, ["bit"] = 5, ["name"] = "Fungi: DK CB: Pink tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xDD, ["bit"] = 6, ["name"] = "Fungi: DK CB: Pink tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xDD, ["bit"] = 7, ["name"] = "Fungi: DK CB: Pink tunnel (5)", ["type"] = "CB"},

	{["byte"] = 0xEA, ["bit"] = 0, ["name"] = "Fungi: Lanky CB: Gold tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 1, ["name"] = "Fungi: Lanky CB: Gold tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 2, ["name"] = "Fungi: Lanky CB: Gold tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 3, ["name"] = "Fungi: Lanky CB: Gold tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 4, ["name"] = "Fungi: Lanky CB: Gold tunnel (5)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 5, ["name"] = "Fungi: Lanky CB: Gold tunnel (6)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 6, ["name"] = "Fungi: Lanky CB: Gold tunnel (7)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 7, ["name"] = "Fungi: Lanky CB: Gold tunnel (8)", ["type"] = "CB"},
	{["byte"] = 0xEB, ["bit"] = 6, ["name"] = "Fungi: Lanky CB: Gold tunnel (9)", ["type"] = "CB"},
	{["byte"] = 0xEB, ["bit"] = 7, ["name"] = "Fungi: Lanky CB: Gold tunnel (10)", ["type"] = "CB"},

	{["byte"] = 0x106, ["bit"] = 1, ["name"] = "Caves: Diddy CB: Bunch on W4 (far)", ["type"] = "Bunch"},

	{["byte"] = 0x11A, ["bit"] = 0, ["name"] = "Castle: DK bridge CB (1)", ["type"] = "CB"},
	{["byte"] = 0x11B, ["bit"] = 5, ["name"] = "Castle: DK bridge CB (2)", ["type"] = "CB"},
	{["byte"] = 0x11B, ["bit"] = 4, ["name"] = "Castle: DK bridge CB (3)", ["type"] = "CB"},
	{["byte"] = 0x11B, ["bit"] = 6, ["name"] = "Castle: DK bridge CB (4)", ["type"] = "CB"},
	{["byte"] = 0x11B, ["bit"] = 7, ["name"] = "Castle: DK bridge CB (5)", ["type"] = "CB"},
}

local function fill_flag_names()
	local i;
	for i=1,#flag_array do
		flag_names[i] = flag_array[i]["name"];
	end
end
fill_flag_names();

function isFound(byte, bit)
	local i;
	for i=1,#flag_array do
		if byte == flag_array[i]["byte"] and bit == flag_array[i]["bit"] then
			return true;
		end
	end
	return false;
end

function checkFlags()
	local flags = mainmemory.read_u24_be(flag_pointer + 1);
	local i, bit, temp_value;
	local flag_found = false;
	local known_flags_found = 0;
	if flags > 0x700000 and flags < 0x7fffff - flag_block_size then
		if #flag_block > 0 then
			for i=0,#flag_block do
				temp_value = mainmemory.readbyte(flags + i);
				if flag_block[i] ~= temp_value then
					for bit=0,7 do
						if get_bit(temp_value, bit) and not get_bit(flag_block[i], bit) then
							-- Output debug info if the flag isn't known
							if not isFound(i, bit) then
								flag_found = true;
								console.log("{[\"byte\"] = 0x"..bizstring.hex(i)..", [\"bit\"] = "..bit..", [\"name\"] = \"Name\", [\"type\"] = \"Type\"},");
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
				console.log(known_flags_found.." Known flags skipped.")
			end
			if not flag_found then
				console.log("No unknown flags were changed.")
			end
		else
			-- Populate flag block
			for i=0,flag_block_size do
				flag_block[i] = mainmemory.readbyte(flags + i);
			end
			console.log("Populated flag array.")
		end
	else
		console.log("Failed to find flag block on this frame, adding to queue. Will be checked next time block is found.");
		table.insert(flag_action_queue, {["action_type"]="check"});
	end
end

local function process_flag_queue()
	if #flag_action_queue > 0 then
		local flags = mainmemory.read_u24_be(flag_pointer + 1);
		if flags > 0x700000 and flags < 0x7fffff - flag_block_size then
			local i, queue_item, current_value;
			for i=1,#flag_action_queue do
				queue_item = flag_action_queue[i];
				if type(queue_item) == "table" then
					if queue_item["action_type"] == "set" then
						current_value = mainmemory.readbyte(flags + queue_item["byte"]);
						mainmemory.writebyte(flags + queue_item["byte"], set_bit(current_value, queue_item["bit"]));
						console.log("Set \""..queue_item["name"].."\" at 0x"..bizstring.hex(queue_item["byte"]).." bit "..queue_item["bit"]);
					elseif queue_item["action_type"] == "clear" then
						current_value = mainmemory.readbyte(flags + queue_item["byte"]);
						mainmemory.writebyte(flags + queue_item["byte"], clear_bit(current_value, queue_item["bit"]));
						console.log("Cleared \""..queue_item["name"].."\" at 0x"..bizstring.hex(queue_item["byte"]).." bit "..queue_item["bit"]);
					elseif queue_item["action_type"] == "check" then
						checkFlags();
					end
				end
			end
			-- Clear queue if we found the block that frame
			flag_action_queue = {};
		end
	end
end

local function getFlagByName(flagName)
	local i;
	for i=1,#flag_array do
		if flagName == flag_array[i]["name"] then
			return flag_array[i];
		end
	end
end

function setFlagByName(name)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		table.insert(flag_action_queue, {["action_type"]="set", ["byte"]=flag["byte"], ["bit"]=flag["bit"], ["name"]=name, ["type"]=flag["type"]});
		process_flag_queue();
	end
end

function clearFlagByName(name)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		table.insert(flag_action_queue, {["action_type"]="clear", ["byte"]=flag["byte"], ["bit"]=flag["bit"], ["name"]=name, ["type"]=flag["type"]});
		process_flag_queue();
	end
end	

local function flagSetButtonHandler()
	setFlagByName(forms.getproperty(options_flag_dropdown, "SelectedItem"));
end

local function flagClearButtonHandler()
	clearFlagByName(forms.getproperty(options_flag_dropdown, "SelectedItem"));
end

local function formatOutputString(caption, value, max)
	console.log(caption..value.."/"..max.." or "..round(value/max * 100,2).."%");
end

function flagStats()
	local fairies_known = 0;
	local blueprints_known = 0;
	local warps_known = 0;
	local cb_known = 0;
	local gb_known = 0;
	local crowns_known = 0;
	local coins_known = 0;
	
	local i, flag, name;
	for i=1,#flag_array do
		flag = flag_array[i];
		name = flag["name"];
		_type = flag["type"];
		if _type == "Fairy" then
			fairies_known = fairies_known + 1;
		end
		if _type == "Blueprint" then
			blueprints_known = blueprints_known + 1;
			if bizstring.contains(_type, "Turned") then
				gb_known = gb_known + 1;
			end
		end
		if _type == "Warp" then
			warps_known = warps_known + 1;
		end
		if _type == "GB" then
			gb_known = gb_known + 1;
		end
		if _type == "CB" then
			cb_known = cb_known + 1;
		end
		if _type == "Bunch" then
			cb_known = cb_known + 5;
		end
		if _type == "Balloon" then
			cb_known = cb_known + 10;
		end
		if _type == "Crown" then
			crowns_known = crowns_known + 1;
		end
		if _type == "Coin" then
			coins_known = coins_known + 1;
		end
		if _type == "Rainbow Coin" then
			coins_known = coins_known + 25;
		end
	end

	local knownFlags = #flag_array;
	local totalFlags = flag_block_size * 8;

	console.log("Block size: 0x"..bizstring.hex(flag_block_size));
	formatOutputString("Flags known: ", knownFlags, totalFlags);
	console.log();
	formatOutputString("Crowns: ", crowns_known, max_crowns);
	formatOutputString("Fairies: ", fairies_known, max_fairies);
	console.log();
	formatOutputString("Blueprints: ", blueprints_known, max_blueprints);
	formatOutputString("Warps: ", warps_known, max_warps);
	formatOutputString("CB: ", cb_known, max_cb);
	formatOutputString("GB: ", gb_known, max_gb);
	console.log("Coins: "..coins_known);
	console.log();
end
flagStats();

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if bizstring.contains(romName, "USA") and not bizstring.contains(romName, "Kiosk") then
		version = "USA";
		map                    = 0x7444E7;
		file                   = 0x7467c8;
		flag_pointer           = 0x7654F4;
		menu_flags             = 0x7ed558;
		kong_object_pointer    = 0x7fbb4d;
		camera_pointer         = 0x7fb968;
		tb_void_byte           = 0x7fbb63;
		pointer_list           = 0x7fbff0;
		kongbase               = 0x7fc950;
		global_base            = 0x7fcc41;
		security_byte          = 0x7552E0;
		security_message       = 0x75E5DC;
		frames_lag             = 0x76AF10;
		frames_real            = 0x7F0560;
		geometry_spike_pointer = 0x76FDF8;

		--Mad Jack
		MJ_state_pointer      = 0x7fdc91;
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
		jetman_x_position  = 0x02F050;
		jetman_y_position  = 0x02F054;
	elseif bizstring.contains(romName, "Europe") then
		version = "PAL";
		map                    = 0x73EC37;
		file                   = 0x740F18;
		flag_pointer           = 0x760014;
		menu_flags             = 0x7ed478;
		kong_object_pointer    = 0x7fba6d;
		camera_pointer         = 0x7fb888;
		tb_void_byte           = 0x7FBA83;
		pointer_list           = 0x7fbf10;
		kongbase               = 0x7fc890;
		global_base            = 0x7fcb81;
		security_byte          = 0x74FB60;
		security_message       = 0x7590F0;
		frames_lag             = 0x765A30;
		frames_real            = 0x7F0480;
		geometry_spike_pointer = 0x76A918;

		--Mad Jack
		MJ_state_pointer      = 0x7FDBD1;
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
		jetman_x_position  = 0x022100;
		jetman_y_position  = 0x022104;
	elseif bizstring.contains(romName, "Japan") then
		version = "JP";
		map                    = 0x743DA7;
		file                   = 0x746088;
		flag_pointer           = 0x7656E4;
		menu_flags             = 0x7ed9c8;
		kong_object_pointer    = 0x7fbfbd;
		camera_pointer         = 0x7fbdd8;
		tb_void_byte           = 0x7FBFD3;
		pointer_list           = 0x7fc460;
		kongbase               = 0x7fcde0;
		global_base            = 0x7fd0d1;
		security_byte          = 0x7553A0;
		security_message       = 0x75E790;
		frames_lag             = 0x76B100;
		frames_real            = 0x7F09D0;
		geometry_spike_pointer = 0x76FFE8;

		--Mad Jack
		MJ_state_pointer      = 0x7fe121;
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
		jetman_x_position  = 0x022060;
		jetman_y_position  = 0x022064;
	elseif bizstring.contains(romName, "Kiosk") then
		version = "Kiosk";
		file                = 0x7467c8; -- TODO?
		map                 = 0x72CDE7;
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
local slope_object_pointer = 0x7f94b9; -- TODO - Find on PAL & JP

-- Relative to slope object
local slope_timer = 0xc3;

local function neverSlip()
	-- Patch the slope timer
	local slope_object = mainmemory.read_u24_be(slope_object_pointer);
	mainmemory.writebyte(slope_object + slope_timer, 0);

	-- Patch the Kong object
	local kong_object = mainmemory.read_u24_be(kong_object_pointer);
	local slope_value = mainmemory.read_u8(kong_object + slope_byte);
	--mainmemory.writebyte(kong_object + slope_byte, math.max(3, slope_value));
	mainmemory.writebyte(kong_object + slope_byte + 1, 0xFE);
end

----------------------
-- Geometry Spiking --
----------------------

local spiking_fix = false;
local freeze_value = 0;

local function fix_geometry_spiking()
	spiking_fix = true;
	--freeze_value = mainmemory.read_u32_be(geometry_spike_pointer);
end

local function break_geometry_spiking()
	spiking_fix = false;
end

event.onloadstate(break_geometry_spiking, "Break spiking");

local function apply_spiking_fix()
	mainmemory.write_u32_be(geometry_spike_pointer, freeze_value);
end

-----------------------
-- Lag configuration --
-----------------------

local options_toggle_lag_fix;
local options_decrease_lag_factor_button;
local options_increase_lag_factor_button;
local options_lag_factor_value_label;

local lag_factor = 1;

local function increase_lag_factor()
	lag_factor = lag_factor + 1;
end

local function decrease_lag_factor()
	lag_factor = lag_factor - 1;
end

local function fix_lag()
	local frames_real_value = mainmemory.read_u32_be(frames_real);
	mainmemory.write_u32_be(frames_lag, frames_real_value - lag_factor);
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

function everythingiskong()
	local object_found = true;
	local object_no = 0;
	local kong_model_pointer = mainmemory.read_u24_be(kong_object + 1);
	local object_model_pointer;
	local pointer;
	local camera_object = mainmemory.read_u24_be(camera_pointer + 1); 

	while object_found do
		pointer = mainmemory.read_u24_be(pointer_list + (object_no * 4) + 1);
		object_found = (pointer ~= 0xffffff) and (pointer ~= 0x000000) and (pointer ~= camera_object) and (object_no <= max_objects);

		if object_found then
			object_model_pointer = mainmemory.read_u24_be(pointer + model_pointer + 1);
			if object_model_pointer ~= 0x000000 then
				mainmemory.writebyte(pointer + model_pointer, 0x80);
				mainmemory.write_u24_be(pointer + model_pointer + 1, kong_model_pointer);
				console.log("wrote: "..bizstring.hex(pointer));
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
	local i, j, char;
	local charFound = false;
	for i=1,length do
		char = bizstring.substring(value, i - 1, 1);
		charFound = false;
		for j=1,#jp_charset do
			if jp_charset[j] == char then
				tempString = tempString..string.char(j - 1);
				charFound = true;
				break;
			end
		end
		if charFound == false then
			console.log("JP String parse warning: Didn't find character for '"..char..'\'');
		end
	end
	return tempString;
end

local brb_message_max_length = 79;
brb_message = "BRB";
is_brb = false;

function brb(value)
	local message = value or "BRB";
	if version == "JP" then
		message = toJPString(message);
	else
		message = string.upper(message);
	end
	if version ~= "Kiosk" then
		brb_message = message;
		is_brb = true;
	else
		console.log("Not supported in this version.");
	end
end

function back()
	is_brb = false;
end

local function do_brb()
	if is_brb then
		mainmemory.writebyte(security_byte, 0x01);
		local i;
		local message_length = math.min(string.len(brb_message), brb_message_max_length);
		for i=1,message_length do
			mainmemory.writebyte(security_message + i - 1, string.byte(brb_message, i));
		end
		mainmemory.writebyte(security_message + message_length, 0x00);
	end
end

------------
-- Events --
------------

local function unlock_moves()
	local kong;
	for kong=DK,Chunky do
		local base = kongbase + kong * 0x5E;
		mainmemory.writebyte(base + moves,      3);
		mainmemory.writebyte(base + sim_slam,   3);
		mainmemory.writebyte(base + weapon,     7);
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
	options_flag_dropdown =     forms.dropdown(form_handle, flag_names, col(0) + dropdown_offset, row(7) + dropdown_offset, col(9) + 7, button_height);
	options_set_flag_button =   forms.button(form_handle, "Set", flagSetButtonHandler,    col(10),     row(7), 59, button_height);
	options_Clear_flag_button = forms.button(form_handle, "Clear", flagClearButtonHandler, col(13) - 5, row(7), 59, button_height);

	-- Moon stuff
	options_moon_mode_label =  forms.label(form_handle,  "Moon:",                    col(10),     row(2) + label_offset, 48, button_height);
	options_moon_mode_button = forms.button(form_handle, moon_mode, toggle_moonmode, col(13) - 20, row(2),                59, button_height);

	-- Mad Jack stuff
	options_toggle_madjack = forms.checkbox(form_handle, "MJ Minimap", col(5) + dropdown_offset, row(6) + dropdown_offset);

	-- ISG Timer
	options_toggle_isg_timer = forms.checkbox(form_handle, "ISG Timer", col(5) + dropdown_offset, row(5) + dropdown_offset);

	-- Buttons
	options_toggle_invisify_button = forms.button(form_handle, "Invisify",      toggle_invisify, col(7), row(1), 64,         button_height);
	options_clear_tb_void_button =   forms.button(form_handle, "Clear TB void", clear_tb_void,   col(10), row(1), col(4) + 8, button_height);
	options_unlock_moves_button =    forms.button(form_handle, "Unlock Moves",  unlock_moves,    col(10), row(4), col(4) + 8, button_height);

	--options_kong_button        =  forms.button(form_handle, "Kong",   everythingiskong,  col(10), row(3), col(4) + 8, button_height);
	--options_force_pause_button =  forms.button(form_handle, "Force Pause",   force_pause,  col(10), row(4), col(4) + 8, button_height);
	options_force_zipper_button =  forms.button(form_handle, "Force Zipper",  force_zipper,         col(5), row(4), col(4) + 8, button_height);
	options_fix_geometry_spiking = forms.button(form_handle, "Fix Spiking",   fix_geometry_spiking, col(10), row(0), col(4) + 8, button_height);
	--options_random_effect_button = forms.button(form_handle, "Random effect", random_effect,        col(10), row(6), col(4) + 8, button_height);

	-- Lag fix
	options_decrease_lag_factor_button = forms.button(form_handle,  "-",       decrease_lag_factor, col(13) - 7,                  row(6),                   button_height, button_height);
	options_increase_lag_factor_button = forms.button(form_handle,  "+",       increase_lag_factor, col(13) + button_height - 7,  row(6),                   button_height, button_height);
	options_lag_factor_value_label =     forms.label(form_handle,   "0",                            col(13) + button_height + 21, row(6) + label_offset,    54,            14);
	options_toggle_lag_fix =             forms.checkbox(form_handle, "Lag fix",                     col(10) + dropdown_offset,    row(6) + dropdown_offset);
	
	-- Checkboxes
	options_toggle_homing_ammo = forms.checkbox(form_handle, "Homing Ammo", col(0) + dropdown_offset, row(6) + dropdown_offset);
	options_toggle_neverslip =   forms.checkbox(form_handle, "Never Slip",  col(10) + dropdown_offset, row(5) + dropdown_offset);
end

function Game.applyInfinites()
	mainmemory.writebyte(global_base + standard_ammo, max_standard_ammo);
	if forms.ischecked(options_toggle_homing_ammo) then
		mainmemory.writebyte(global_base + homing_ammo, max_homing_ammo);
	else
		mainmemory.writebyte(global_base + homing_ammo, 0);
	end
	mainmemory.writebyte(global_base + oranges,  max_oranges);
	mainmemory.write_u16_be(global_base + crystals, max_crystals * 150);
	mainmemory.writebyte(global_base + film,     max_film);
	mainmemory.writebyte(global_base + health,   max_health);
	mainmemory.writebyte(global_base + melons,   max_melons);
	local kong;
	for kong=DK,Chunky do
		local base = kongbase + kong * 0x5e;
		mainmemory.writebyte(base + coins, max_coins);
		mainmemory.writebyte(base + lives, max_musical_energy);
	end
end

function Game.eachFrame()
	kong_object = mainmemory.read_u24_be(kong_object_pointer);
	map_value = mainmemory.readbyte(map);

	Game.unlock_menus();

	-- Lag fix
	forms.settext(options_lag_factor_value_label, lag_factor);
	if forms.ischecked(options_toggle_lag_fix) then
		fix_lag();
	end

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

	do_brb();
	process_flag_queue();

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
