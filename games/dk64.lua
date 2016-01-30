local Game = {};

-------------------------
-- DK64 specific state --
-------------------------

local form_controls = {};

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

local function isPointer(value)
	return value > 0x80000000 and value < 0x807FFFFF;
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

-- Relative to shared model object (model_pointer)
local num_bones = 0x20;

-- Relative to objects found in the pointer list (Model 1)
local previous_object = -0x10;
local object_size = -0x0C;

local model_pointer = 0x00;
local rendering_parameters_pointer = 0x04;
local current_bone_array_pointer = 0x08;

local actor_type = 0x58; -- TODO: Document values for this
local visibility = 0x63; -- Bitfield, also contains whether the actor collides with terrain and whether they are in water

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

local slope_byte = 0xDE;

local x_rot = 0xE4;
local y_rot = x_rot + 2;
local z_rot = y_rot + 2;

local locked_to_pad = 0x110;
local locked_to_rainbow_coin_pointer = 0x13C;
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

local kick_animation = 0x181;
local kick_animation_value = 0x29;

local velocity_uncrouch_aerial = 0x1A4;

local misc_acceleration_float = 0x1AC;
local horizontal_acceleration = 0x1B0; -- Set to a negative number to go fast
local misc_acceleration_float_2 = 0x1B4;
local misc_acceleration_float_3 = 0x1B8;

local velocity_ground = 0x1C0;

local grabbed_vine_pointer = 0x2B0;

-- TODO: Properly document these
local scale = {
	0x344, 0x348, 0x34C, 0x350, 0x354
}

local effect_byte = 0x372; -- Bitfield, TODO: Document bits

local function getKongObject() -- TODO: Cache this
	return mainmemory.read_u24_be(kong_object_pointer);
end

local prev_map = 0;
local map_value = 0;

-- Relative to rendering parameters
local scale_x = 0x34;
local scale_y = scale_x + 4;
local scale_z = scale_y + 4;

----------------
-- Flag stuff --
----------------

local flag_pointer;
local flag_block_size = 0x13B;

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

	{["byte"] = 0x18, ["bit"] = 2, ["name"] = "? Galleon first time cutscene"},
	{["byte"] = 0x20, ["bit"] = 0, ["name"] = "? Fungi: Day/Night First Time CS"}, -- TODO: Test this
	{["byte"] = 0x2C, ["bit"] = 7, ["name"] = "? T&S FTT (entered in Japes)", ["type"] = "FTT"}, -- TODO: Test this
	{["byte"] = 0x2E, ["bit"] = 3, ["name"] = "? Orange Barrel Completed"}, -- TODO: Test this
	{["byte"] = 0x30, ["bit"] = 7, ["name"] = "? All training barrels comeplete cutscene ?"}, -- TODO: Test this
	{["byte"] = 0x31, ["bit"] = 3, ["name"] = "? Japes W3 Right CB Bunch", ["type"] = "Bunch"}, -- TODO: Test this
	{["byte"] = 0x31, ["bit"] = 4, ["name"] = "? Fungi: DK Coin by BBlast or First Coin?", ["type"] = "Coin"}, -- TODO: Test this
	{["byte"] = 0x38, ["bit"] = 5, ["name"] = "? Japes: Entered Japes (1)"}, -- TODO: Test this
	{["byte"] = 0x61, ["bit"] = 1, ["name"] = "? Training barrels spawned"}, -- TODO: Test this
	{["byte"] = 0x64, ["bit"] = 7, ["name"] = "? Japes W3 Right CB Bunch", ["type"] = "Bunch"}, -- TODO: Test this

	-----------
	-- Known --
	-----------

	{["byte"] = 0x00, ["bit"] = 0, ["name"] = "Japes: DK Switch by entrance"}, -- TODO: Test this
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
	{["byte"] = 0x05, ["bit"] = 6, ["name"] = "Japes: T&S Cleared"},
	{["byte"] = 0x05, ["bit"] = 7, ["name"] = "Open Chunky vase room"},

	{["byte"] = 0x06, ["bit"] = 0, ["name"] = "Aztec: DK Blueprint room open"},
	{["byte"] = 0x06, ["bit"] = 1, ["name"] = "Aztec: Chunky GB: Vase GB", ["type"] = "GB"},
	{["byte"] = 0x06, ["bit"] = 2, ["name"] = "Llama freed CS"},
	{["byte"] = 0x06, ["bit"] = 3, ["name"] = "Aztec: DK GB: Llama cage GB", ["type"] = "GB"},
	{["byte"] = 0x06, ["bit"] = 4, ["name"] = "Aztec: Chunky GB: HunkyChunky caged GB", ["type"] = "GB"},
	{["byte"] = 0x06, ["bit"] = 5, ["name"] = "Diddytower rises CS"},
	{["byte"] = 0x06, ["bit"] = 6, ["name"] = "Aztec: Diddy GB: Diddytower", ["type"] = "GB"},
	{["byte"] = 0x06, ["bit"] = 7, ["name"] = "5DT switches spawn CS"},

	{["byte"] = 0x07, ["bit"] = 0, ["name"] = "Aztec: Diddy GB: 5DT", ["type"] = "GB"},
	{["byte"] = 0x07, ["bit"] = 1, ["name"] = "Aztec: DK GB: 5DT", ["type"] = "GB"},
	{["byte"] = 0x07, ["bit"] = 2, ["name"] = "Aztec: Tiny GB: 5DT", ["type"] = "GB"},
	{["byte"] = 0x07, ["bit"] = 3, ["name"] = "Aztec: Chunky GB: 5DT", ["type"] = "GB"},
	{["byte"] = 0x07, ["bit"] = 4, ["name"] = "Aztec: Lanky GB: 5DT", ["type"] = "GB"},
	{["byte"] = 0x07, ["bit"] = 6, ["name"] = "Aztec: DK GB: W5", ["type"] = "GB"},
	{["byte"] = 0x07, ["bit"] = 7, ["name"] = "Aztec: Diddy GB: Vulture Race", ["type"] = "GB"},

	{["byte"] = 0x08, ["bit"] = 0, ["name"] = "Aztec: Chunky GB: Rotating room", ["type"] = "GB"},
	{["byte"] = 0x08, ["bit"] = 1, ["name"] = "Aztec: Tiny GB: Tiny temple", ["type"] = "GB"},
	{["byte"] = 0x08, ["bit"] = 2, ["name"] = "Kong Unlocked: Tiny"},
	{["byte"] = 0x08, ["bit"] = 3, ["name"] = "Aztec: Diddy GB: Tiny Temple", ["type"] = "GB"},
	{["byte"] = 0x08, ["bit"] = 4, ["name"] = "Aztec: Lanky: Vulture GB", ["type"] = "GB"},
	{["byte"] = 0x08, ["bit"] = 5, ["name"] = "Aztec: Tiny Temple ice melted"},
	{["byte"] = 0x08, ["bit"] = 6, ["name"] = "Kong Unlocked: Lanky"},
	{["byte"] = 0x08, ["bit"] = 7, ["name"] = "Aztec: Tiny GB: Llama temple", ["type"] = "GB"},

	{["byte"] = 0x09, ["bit"] = 0, ["name"] = "Aztec: Lanky GB: Matching game", ["type"] = "GB"},
	{["byte"] = 0x09, ["bit"] = 1, ["name"] = "Aztec: Lanky GB: Llama temple", ["type"] = "GB"},
	{["byte"] = 0x09, ["bit"] = 2, ["name"] = "Key 2", ["type"] = "Key"},
	{["byte"] = 0x09, ["bit"] = 3, ["name"] = "Aztec: Tiny GB: Beelerace", ["type"] = "GB"},
	{["byte"] = 0x09, ["bit"] = 4, ["name"] = "Aztec: Wakeup Llama CS"},
	{["byte"] = 0x09, ["bit"] = 6, ["name"] = "Aztec: Open tunnel CS"},
	{["byte"] = 0x09, ["bit"] = 7, ["name"] = "Aztec: W1 (Entrance)", ["type"] = "Warp"},

	{["byte"] = 0x0A, ["bit"] = 0, ["name"] = "Aztec: W1 (Candy)", ["type"] = "Warp"},
	{["byte"] = 0x0A, ["bit"] = 1, ["name"] = "Aztec: W2 (Tiny temple)", ["type"] = "Warp"},
	{["byte"] = 0x0A, ["bit"] = 2, ["name"] = "Aztec: W2 (Totem)", ["type"] = "Warp"},
	{["byte"] = 0x0A, ["bit"] = 3, ["name"] = "Aztec: W3 (Cranky)", ["type"] = "Warp"},
	{["byte"] = 0x0A, ["bit"] = 4, ["name"] = "Aztec: W3 (Totem)", ["type"] = "Warp"},
	{["byte"] = 0x0A, ["bit"] = 5, ["name"] = "Aztec: W4 (Totem)", ["type"] = "Warp"},
	{["byte"] = 0x0A, ["bit"] = 6, ["name"] = "Aztec: W4 (Funky)", ["type"] = "Warp"},
	{["byte"] = 0x0A, ["bit"] = 7, ["name"] = "Aztec: W5 (Totem)", ["type"] = "Warp"},

	{["byte"] = 0x0B, ["bit"] = 0, ["name"] = "Aztec: W1 (Llama temple, high)", ["type"] = "Warp"},
	{["byte"] = 0x0B, ["bit"] = 1, ["name"] = "Aztec: W1 (Llama temple, low)", ["type"] = "Warp"},
	{["byte"] = 0x0B, ["bit"] = 2, ["name"] = "Aztec: W2 (Llama temple, far)", ["type"] = "Warp"},
	{["byte"] = 0x0B, ["bit"] = 3, ["name"] = "Aztec: W2 (Llama temple, low)", ["type"] = "Warp"},
	{["byte"] = 0x0B, ["bit"] = 4, ["name"] = "Aztec: Llama Cutscene"},
	{["byte"] = 0x0B, ["bit"] = 5, ["name"] = "Aztec: Lanky's help me cutscene"},
	{["byte"] = 0x0B, ["bit"] = 6, ["name"] = "Aztec: W2 (Tiny temple)", ["type"] = "Warp"},
	{["byte"] = 0x0B, ["bit"] = 7, ["name"] = "Aztec: FT Cutscene"},

	{["byte"] = 0x0C, ["bit"] = 0, ["name"] = "FT Open door of Tiny temple CS (Tiny)"},
	{["byte"] = 0x0C, ["bit"] = 1, ["name"] = "FT Open door of Tiny temple CS (Lanky)"},
	{["byte"] = 0x0C, ["bit"] = 2, ["name"] = "FT Open door of Tiny temple CS (Diddy)"},
	{["byte"] = 0x0C, ["bit"] = 3, ["name"] = "FT Open door of Tiny temple CS (Chunky)"},
	{["byte"] = 0x0C, ["bit"] = 4, ["name"] = "FT Open door of 5DT (DK)"},
	{["byte"] = 0x0C, ["bit"] = 5, ["name"] = "FT Open door of 5DT (Diddy)"},
	{["byte"] = 0x0C, ["bit"] = 6, ["name"] = "FT Open door of 5DT (Tiny)"},
	{["byte"] = 0x0C, ["bit"] = 7, ["name"] = "FT Open door of 5DT (Lanky)"},

	{["byte"] = 0x0D, ["bit"] = 0, ["name"] = "FT Open door of 5DT (Chunky)"},
	{["byte"] = 0x0D, ["bit"] = 1, ["name"] = "FT Open door of Llama temple (DK)"},
	{["byte"] = 0x0D, ["bit"] = 2, ["name"] = "FT Open door of Llama temple (Lanky)"},
	{["byte"] = 0x0D, ["bit"] = 3, ["name"] = "FT Open door of Llama temple (Tiny)"},
	{["byte"] = 0x0D, ["bit"] = 4, ["name"] = "Aztec: T&S Cleared"},
	{["byte"] = 0x0D, ["bit"] = 5, ["name"] = "Factory: Hatch opened"},
	{["byte"] = 0x0D, ["bit"] = 6, ["name"] = "Factory: Storage Room Neutral Switch"},
	{["byte"] = 0x0D, ["bit"] = 7, ["name"] = "Factory: Power shed activated"},

	{["byte"] = 0x0E, ["bit"] = 0, ["name"] = "Factory: Power shed GB", ["type"] = "GB"},
	{["byte"] = 0x0E, ["bit"] = 1, ["name"] = "Factory: Diddy GB: Production room", ["type"] = "GB"},
	{["byte"] = 0x0E, ["bit"] = 4, ["name"] = "Factory: Tiny GB: Production room", ["type"] = "GB"},
	{["byte"] = 0x0E, ["bit"] = 2, ["name"] = "Factory: Chunky GB: Production room", ["type"] = "GB"},
	{["byte"] = 0x0E, ["bit"] = 3, ["name"] = "Factory: Lanky GB: Production room", ["type"] = "GB"},
	{["byte"] = 0x0E, ["bit"] = 5, ["name"] = "Kong Unlocked: Chunky"},
	{["byte"] = 0x0E, ["bit"] = 6, ["name"] = "Factory: Lanky GB: Free Chunky", ["type"] = "GB"},
	{["byte"] = 0x0E, ["bit"] = 7, ["name"] = "Factory: Dark Room Gate"},

	{["byte"] = 0x0F, ["bit"] = 0, ["name"] = "Factory: Dark Room Box"},
	{["byte"] = 0x0F, ["bit"] = 1, ["name"] = "Factory: Chunky GB: Dark Room", ["type"] = "GB"},
	{["byte"] = 0x0F, ["bit"] = 2, ["name"] = "Factory: DK GB: Numbers Game", ["type"] = "GB"},
	{["byte"] = 0x0F, ["bit"] = 3, ["name"] = "Factory: Tiny GB: Arcade Room", ["type"] = "GB"},
	{["byte"] = 0x0F, ["bit"] = 4, ["name"] = "Factory: Tiny GB: Bad hit detection wheel", ["type"] = "GB"},
	{["byte"] = 0x0F, ["bit"] = 5, ["name"] = "Factory: Lanky GB: R&D", ["type"] = "GB"},
	{["byte"] = 0x0F, ["bit"] = 6, ["name"] = "Factory: Diddy GB: R&D", ["type"] = "GB"},
	{["byte"] = 0x0F, ["bit"] = 7, ["name"] = "Factory: Chunky GB: R&D", ["type"] = "GB"},

	{["byte"] = 0x10, ["bit"] = 0, ["name"] = "Factory: DK GB: Crusher room", ["type"] = "GB"},
	{["byte"] = 0x10, ["bit"] = 1, ["name"] = "Factory: Arcade Lever"},
	{["byte"] = 0x10, ["bit"] = 2, ["name"] = "Factory: Arcade LV2"},
	{["byte"] = 0x10, ["bit"] = 3, ["name"] = "Factory: Arcade LV3"},
	{["byte"] = 0x10, ["bit"] = 4, ["name"] = "Nintendo Coin"},
	{["byte"] = 0x10, ["bit"] = 5, ["name"] = "Factory: Chunky R&D Gate open"},
	{["byte"] = 0x10, ["bit"] = 7, ["name"] = "Factory: Diddy GB: Block Tower", ["type"] = "GB"},

	{["byte"] = 0x11, ["bit"] = 0, ["name"] = "Factory: Chunky GB: Stash Snatch", ["type"] = "GB"},
	{["byte"] = 0x11, ["bit"] = 1, ["name"] = "Factory: Lanky GB: Batty Barrel Bandit", ["type"] = "GB"},
	{["byte"] = 0x11, ["bit"] = 2, ["name"] = "Key 3", ["type"] = "Key"},
	{["byte"] = 0x11, ["bit"] = 3, ["name"] = "Factory: Tiny GB: Car Race", ["type"] = "GB"},
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
	{["byte"] = 0x12, ["bit"] = 7, ["name"] = "Factory: R&D Lever"},

	{["byte"] = 0x13, ["bit"] = 0, ["name"] = "Factory: T&S Cleared"},
	{["byte"] = 0x13, ["bit"] = 1, ["name"] = "Galleon: Cannon game room open"},
	{["byte"] = 0x13, ["bit"] = 7, ["name"] = "Galleon: Enguarde door open"},

	{["byte"] = 0x14, ["bit"] = 2, ["name"] = "Galleon: Gold tower gate open"},

	{["byte"] = 0x15, ["bit"] = 0, ["name"] = "Key 4", ["type"] = "Key"},
	{["byte"] = 0x15, ["bit"] = 1, ["name"] = "Galleon: W5: 5DS", ["type"] = "Warp"},
	{["byte"] = 0x15, ["bit"] = 3, ["name"] = "Galleon: W2: 2DS", ["type"] = "Warp"},
	{["byte"] = 0x15, ["bit"] = 4, ["name"] = "Galleon: W2: Cranky", ["type"] = "Warp"},
	{["byte"] = 0x15, ["bit"] = 5, ["name"] = "Galleon: W3: Snide", ["type"] = "Warp"},
	{["byte"] = 0x15, ["bit"] = 6, ["name"] = "Galleon: W3: Cranky", ["type"] = "Warp"},

	{["byte"] = 0x16, ["bit"] = 2, ["name"] = "Galleon: W1: Cranky", ["type"] = "Warp"},

	{["byte"] = 0x17, ["bit"] = 0, ["name"] = "Galleon: Tiny GB: 2DS", ["type"] = "GB"},
	{["byte"] = 0x17, ["bit"] = 7, ["name"] = "Galleon: Tiny GB: Pearls", ["type"] = "GB"},

	{["byte"] = 0x18, ["bit"] = 3, ["name"] = "Galleon: Water level raised CS"},
	{["byte"] = 0x18, ["bit"] = 4, ["name"] = "Galleon: Water level lowered CS"},

	{["byte"] = 0x19, ["bit"] = 1, ["name"] = "Galleon: Tiny GB: 5DS", ["type"] = "GB"},
	{["byte"] = 0x19, ["bit"] = 2, ["name"] = "Galleon: Tiny GB: Submarine", ["type"] = "GB"},
	{["byte"] = 0x19, ["bit"] = 3, ["name"] = "Galleon: T&S Cleared"},
	{["byte"] = 0x19, ["bit"] = 5, ["name"] = "Fungi: Tiny GB: Anthill", ["type"] = "GB"},
	{["byte"] = 0x19, ["bit"] = 6, ["name"] = "Fungi: Nighttime"},
	{["byte"] = 0x19, ["bit"] = 7, ["name"] = "Fungi: Green Tunnel (Feather Side)"},

	{["byte"] = 0x1A, ["bit"] = 0, ["name"] = "Fungi: Pineapple gate open"},
	{["byte"] = 0x1A, ["bit"] = 1, ["name"] = "Fungi: Tiny GB: Beanstalk", ["type"] = "GB"},
	{["byte"] = 0x1A, ["bit"] = 2, ["name"] = "Fungi: Brown Tunnel Open"},
	{["byte"] = 0x1A, ["bit"] = 3, ["name"] = "Fungi: Diddy GB: Top of mushroom", ["type"] = "GB"},
	{["byte"] = 0x1A, ["bit"] = 4, ["name"] = "Fungi: Diddy's cage raised"},
	{["byte"] = 0x1A, ["bit"] = 5, ["name"] = "Fungi: Diddy's cage destroyed"},
	{["byte"] = 0x1A, ["bit"] = 6, ["name"] = "Fungi: Diddy GB: Cage GB", ["type"] = "GB"},
	{["byte"] = 0x1A, ["bit"] = 7, ["name"] = "Fungi: Chunky GB: Minecart", ["type"] = "GB"},

	{["byte"] = 0x1B, ["bit"] = 0, ["name"] = "Fungi: Diddy Barn GB", ["type"] = "GB"},
	{["byte"] = 0x1B, ["bit"] = 1, ["name"] = "Fungi: Lanky GB: Attic", ["type"] = "GB"},
	{["byte"] = 0x1B, ["bit"] = 2, ["name"] = "Fungi: Mill crate broken (1)"},
	{["byte"] = 0x1B, ["bit"] = 4, ["name"] = "Fungi: Conveyor belt on"},
	{["byte"] = 0x1B, ["bit"] = 5, ["name"] = "Fungi: Chunky GB: Mill", ["type"] = "GB"},
	{["byte"] = 0x1B, ["bit"] = 6, ["name"] = "Fungi: Mill crate broken (2)"},
	{["byte"] = 0x1B, ["bit"] = 7, ["name"] = "Fungi: Mill crate broken (3)"},

	{["byte"] = 0x1C, ["bit"] = 0, ["name"] = "Fungi: Lanky GB: Colored mushroom puzzle", ["type"] = "GB"},
	{["byte"] = 0x1C, ["bit"] = 1, ["name"] = "Fungi: Chunky GB: Facegame", ["type"] = "GB"},
	{["byte"] = 0x1C, ["bit"] = 2, ["name"] = "Fungi: Lanky GB: Bouncy mushroom", ["type"] = "GB"},
	{["byte"] = 0x1C, ["bit"] = 3, ["name"] = "Fungi: Tiny GB: Speedy swing sortie", ["type"] = "GB"},
	{["byte"] = 0x1C, ["bit"] = 4, ["name"] = "Fungi: DK GB: Cannon", ["type"] = "GB"},
	{["byte"] = 0x1C, ["bit"] = 5, ["name"] = "Fungi: Mushroom Cannons"},
	{["byte"] = 0x1C, ["bit"] = 6, ["name"] = "Fungi: Mushroom Coconut Switch"},
	{["byte"] = 0x1C, ["bit"] = 7, ["name"] = "Fungi: Mushroom Grape Switch"},

	{["byte"] = 0x1D, ["bit"] = 0, ["name"] = "Fungi: Mushroom Feather Switch"},
	{["byte"] = 0x1D, ["bit"] = 1, ["name"] = "Fungi: Mushroom Peanut Switch"},
	{["byte"] = 0x1D, ["bit"] = 2, ["name"] = "Fungi: Mushroom Pineapple Switch"},
	{["byte"] = 0x1D, ["bit"] = 3, ["name"] = "Fungi: DK GB: Minecart", ["type"] = "GB"},
	{["byte"] = 0x1D, ["bit"] = 4, ["name"] = "Key 5", ["type"] = "Key"},
	{["byte"] = 0x1D, ["bit"] = 5, ["name"] = "Fungi: W1 (Mill)", ["type"] = "Warp"},
	{["byte"] = 0x1D, ["bit"] = 6, ["name"] = "Fungi: W1 (Tree)", ["type"] = "Warp"},
	{["byte"] = 0x1D, ["bit"] = 7, ["name"] = "Fungi: Main W2", ["type"] = "Warp"},

	{["byte"] = 0x1E, ["bit"] = 0, ["name"] = "Fungi: Funky W2", ["type"] = "Warp"},
	{["byte"] = 0x1E, ["bit"] = 1, ["name"] = "Fungi: W3 (Tree)", ["type"] = "Warp"},
	{["byte"] = 0x1E, ["bit"] = 2, ["name"] = "Fungi: W3 (Mushroom)", ["type"] = "Warp"},
	{["byte"] = 0x1E, ["bit"] = 3, ["name"] = "Fungi: W4 (Tree)", ["type"] = "Warp"},
	{["byte"] = 0x1E, ["bit"] = 4, ["name"] = "Fungi: rabbitrace W4", ["type"] = "Warp"},
	{["byte"] = 0x1E, ["bit"] = 5, ["name"] = "Fungi: W5 (Low)", ["type"] = "Warp"},
	{["byte"] = 0x1E, ["bit"] = 6, ["name"] = "Fungi: High W5", ["type"] = "Warp"},
	{["byte"] = 0x1E, ["bit"] = 7, ["name"] = "Fungi: Tiny GB: Spider miniboss", ["type"] = "GB"},

	{["byte"] = 0x1F, ["bit"] = 0, ["name"] = "Fungi: Rabbit race round 1 completed"},
	{["byte"] = 0x1F, ["bit"] = 1, ["name"] = "Fungi: Lanky GB: Rabbit race", ["type"] = "GB"},
	{["byte"] = 0x1F, ["bit"] = 2, ["name"] = "Fungi: Diddy GB: Owl race", ["type"] = "GB"},
	{["byte"] = 0x1F, ["bit"] = 3, ["name"] = "Fungi: Beanstalk spawned"},
	{["byte"] = 0x1F, ["bit"] = 4, ["name"] = "Fungi: Apple placed"},
	{["byte"] = 0x1F, ["bit"] = 5, ["name"] = "Fungi: Chunky GB: Apple", ["type"] = "GB"},
	{["byte"] = 0x1F, ["bit"] = 6, ["name"] = "Fungi: DK GB: Bblast", ["type"] = "GB"},
	{["byte"] = 0x1F, ["bit"] = 7, ["name"] = "Fungi: Clock CS"},

	{["byte"] = 0x20, ["bit"] = 1, ["name"] = "Fungi: First time cutscene"},
	{["byte"] = 0x20, ["bit"] = 2, ["name"] = "Fungi: T&S Cleared"},
	{["byte"] = 0x20, ["bit"] = 3, ["name"] = "Caves: Lanky GB: Beetle Race", ["type"] = "GB"},
	{["byte"] = 0x20, ["bit"] = 4, ["name"] = "Caves: Tiny GB: 5DC", ["type"] = "GB"},
	{["byte"] = 0x20, ["bit"] = 5, ["name"] = "Caves: DK GB: 5DC", ["type"] = "GB"},
	{["byte"] = 0x20, ["bit"] = 6, ["name"] = "Caves: Diddy GB: Lower 5DC", ["type"] = "GB"},
	{["byte"] = 0x20, ["bit"] = 7, ["name"] = "Caves: Chunky GB: 5DC", ["type"] = "GB"},

	{["byte"] = 0x21, ["bit"] = 0, ["name"] = "Caves: Lanky GB: Lanky Cabin", ["type"] = "GB"},
	{["byte"] = 0x21, ["bit"] = 1, ["name"] = "Caves: T&S Igloo Icewall cleared"},
	{["byte"] = 0x21, ["bit"] = 2, ["name"] = "Caves: Entrance Icewall cleared"},
	{["byte"] = 0x21, ["bit"] = 3, ["name"] = "Caves: Snide Icewall cleared"},
	{["byte"] = 0x21, ["bit"] = 4, ["name"] = "Caves: Chunky GB: Entrance Icewall", ["type"] = "GB"},
	{["byte"] = 0x21, ["bit"] = 6, ["name"] = "Caves: Chunky GB: Chunky Igloo", ["type"] = "GB"},
	{["byte"] = 0x21, ["bit"] = 7, ["name"] = "Caves: Lanky GB: Ice Tomato", ["type"] = "GB"},

	{["byte"] = 0x22, ["bit"] = 2, ["name"] = "Caves: Diddy GB: 5DI", ["type"] = "GB"},
	{["byte"] = 0x22, ["bit"] = 3, ["name"] = "Caves: DK GB: 5DI", ["type"] = "GB"},
	{["byte"] = 0x22, ["bit"] = 4, ["name"] = "Caves: DK Rotating room GB", ["type"] = "GB"},
	{["byte"] = 0x22, ["bit"] = 5, ["name"] = "Caves: FT Enter Rotating room CS",},
	{["byte"] = 0x22, ["bit"] = 6, ["name"] = "Caves: Chunky CB: 5DI", ["type"] = "GB"},
	{["byte"] = 0x22, ["bit"] = 7, ["name"] = "Caves: Tiny Igloo GB", ["type"] = "GB"},

	{["byte"] = 0x23, ["bit"] = 0, ["name"] = "Caves: Lanky 5DI bballon pad spawn"},
	{["byte"] = 0x23, ["bit"] = 1, ["name"] = "Caves: Lanky GB: 5DI", ["type"] = "GB"},
	{["byte"] = 0x23, ["bit"] = 4, ["name"] = "Caves: W1 (Entrance)", ["type"] = "Warp"},
	{["byte"] = 0x23, ["bit"] = 5, ["name"] = "Caves: W2 (Entrance)", ["type"] = "Warp"},
	{["byte"] = 0x23, ["bit"] = 6, ["name"] = "Caves: W2 (Far)", ["type"] = "Warp"},
	{["byte"] = 0x23, ["bit"] = 7, ["name"] = "Caves: W4 (Far)", ["type"] = "Warp"},

	{["byte"] = 0x24, ["bit"] = 1, ["name"] = "Caves: W5 5DC", ["type"] = "Warp"},
	{["byte"] = 0x24, ["bit"] = 2, ["name"] = "Caves: W5 (Lanky BP))", ["type"] = "Warp"},
	{["byte"] = 0x24, ["bit"] = 4, ["name"] = "Key 6", ["type"] = "Key"},
	{["byte"] = 0x24, ["bit"] = 5, ["name"] = "Caves: Diddy Cabin GB (Upper)", ["type"] = "GB"},
	{["byte"] = 0x24, ["bit"] = 6, ["name"] = "Caves: Diddy GB: mad maze maul", ["type"] = "GB"},
	{["byte"] = 0x24, ["bit"] = 7, ["name"] = "Caves: Tiny GB: W3", ["type"] = "GB"},

	{["byte"] = 0x25, ["bit"] = 0, ["name"] = "Caves: 5DI pads spawned"},
	{["byte"] = 0x25, ["bit"] = 1, ["name"] = "Caves: Tiny GB: Mini monkey Igloo", ["type"] = "GB"},
	{["byte"] = 0x25, ["bit"] = 2, ["name"] = "Caves: DK GB: Bblast", ["type"] = "GB"},
	{["byte"] = 0x25, ["bit"] = 3, ["name"] = "Caves: Giant Kosha cutscene"},
	{["byte"] = 0x25, ["bit"] = 4, ["name"] = "Giant Kosha dead"},
	{["byte"] = 0x25, ["bit"] = 5, ["name"] = "Isles: Tiny GB: Rareware GB", ["type"] = "GB"},
	{["byte"] = 0x25, ["bit"] = 6, ["name"] = "Caves: T&S Cleared"},

	{["byte"] = 0x26, ["bit"] = 0, ["name"] = "Castle: Ballroom Rocketbarrel Spawn"},
	{["byte"] = 0x26, ["bit"] = 1, ["name"] = "Castle: Diddy GB: Ballroom", ["type"] = "GB"},
	{["byte"] = 0x26, ["bit"] = 2, ["name"] = "Castle: Lanky GB: Lanky tower", ["type"] = "GB"},
	{["byte"] = 0x26, ["bit"] = 3, ["name"] = "Castle: Lanky tower BBpad spawn"},
	{["byte"] = 0x26, ["bit"] = 4, ["name"] = "Castle: Lanky GB: Orangstand GB", ["type"] = "GB"},
	{["byte"] = 0x26, ["bit"] = 5, ["name"] = "Castle: Tiny GB: Goohands", ["type"] = "GB"},
	{["byte"] = 0x26, ["bit"] = 6, ["name"] = "Castle: Diddy GB: Crypt", ["type"] = "GB"},
	{["byte"] = 0x26, ["bit"] = 7, ["name"] = "Castle: Chunky GB: Crypt", ["type"] = "GB"},

	{["byte"] = 0x27, ["bit"] = 0, ["name"] = "Castle: DK minecart open"},
	{["byte"] = 0x27, ["bit"] = 1, ["name"] = "Castle: DK GB: Library", ["type"] = "GB"},
	{["byte"] = 0x27, ["bit"] = 2, ["name"] = "Castle: Chunky GB: Museum", ["type"] = "GB"},
	{["byte"] = 0x27, ["bit"] = 3, ["name"] = "Castle: Tiny GB: Dungeon", ["type"] = "GB"},
	{["byte"] = 0x27, ["bit"] = 4, ["name"] = "Castle: Lanky GB: Dungeon", ["type"] = "GB"},
	{["byte"] = 0x27, ["bit"] = 5, ["name"] = "Key 7", ["type"] = "Key"},
	{["byte"] = 0x27, ["bit"] = 7, ["name"] = "Castle: Chunky GB: Tree", ["type"] = "GB"},

	{["byte"] = 0x28, ["bit"] = 0, ["name"] = "Castle: DK GB: Tree", ["type"] = "GB"},
	{["byte"] = 0x28, ["bit"] = 1, ["name"] = "Castle: Shed crate broken"},
	{["byte"] = 0x28, ["bit"] = 2, ["name"] = "Castle: Chunky GB: Shed", ["type"] = "GB"},
	{["byte"] = 0x28, ["bit"] = 3, ["name"] = "Castle: Lanky: Greenhouse GB", ["type"] = "GB"},
	{["byte"] = 0x28, ["bit"] = 5, ["name"] = "Castle: Tiny GB: Car race", ["type"] = "GB"},
	{["byte"] = 0x28, ["bit"] = 6, ["name"] = "Castle: DK GB: Face Puzzle", ["type"] = "GB"},
	{["byte"] = 0x28, ["bit"] = 7, ["name"] = "Castle: W1 (Hub)", ["type"] = "Warp"},

	{["byte"] = 0x29, ["bit"] = 0, ["name"] = "Castle: W1 (Far)", ["type"] = "Warp"},
	{["byte"] = 0x29, ["bit"] = 1, ["name"] = "Castle: W2 (Hub)", ["type"] = "Warp"},
	{["byte"] = 0x29, ["bit"] = 2, ["name"] = "Castle: W2 (High)", ["type"] = "Warp"},
	{["byte"] = 0x29, ["bit"] = 3, ["name"] = "Castle: W3 (Hub)", ["type"] = "Warp"},
	{["byte"] = 0x29, ["bit"] = 4, ["name"] = "Castle: W3 (High)", ["type"] = "Warp"},
	{["byte"] = 0x29, ["bit"] = 5, ["name"] = "Castle: W4 (Hub)", ["type"] = "Warp"},
	{["byte"] = 0x29, ["bit"] = 6, ["name"] = "Castle: W4 (High)", ["type"] = "Warp"},
	{["byte"] = 0x29, ["bit"] = 7, ["name"] = "Castle: W5 (Hub)", ["type"] = "Warp"},

	{["byte"] = 0x2A, ["bit"] = 0, ["name"] = "Castle: W5 (High)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 1, ["name"] = "Castle: W1 (Crypt, close)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 2, ["name"] = "Castle: W1 (Crypt, far)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 3, ["name"] = "Castle: W2 (Crypt, close)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 4, ["name"] = "Castle: W2 (Crypt, far)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 5, ["name"] = "Castle: W3 (Crypt, close)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 6, ["name"] = "Castle: W3 (Crypt, far)", ["type"] = "Warp"},
	{["byte"] = 0x2A, ["bit"] = 7, ["name"] = "Castle: Dungeon gate cleared (1)"},

	{["byte"] = 0x2B, ["bit"] = 0, ["name"] = "Castle: Dungeon gate cleared (2)"},
	{["byte"] = 0x2B, ["bit"] = 1, ["name"] = "Castle: Dungeon gate cleared (3)"},
	{["byte"] = 0x2B, ["bit"] = 2, ["name"] = "Castle: Dungeon gate cleared (4)"},
	{["byte"] = 0x2B, ["bit"] = 3, ["name"] = "Castle: Dungeon gate cleared (5)"},
	{["byte"] = 0x2B, ["bit"] = 4, ["name"] = "Castle: Dungeon gate cleared (6)"},
	{["byte"] = 0x2B, ["bit"] = 5, ["name"] = "Castle: First time cutscene"},
	{["byte"] = 0x2B, ["bit"] = 6, ["name"] = "Castle: Diddy GB: BigBugBash", ["type"] = "GB"},
	{["byte"] = 0x2B, ["bit"] = 7, ["name"] = "Castle: Tiny GB: Trashcan", ["type"] = "GB"},

	{["byte"] = 0x2C, ["bit"] = 0, ["name"] = "Castle: T&S Cleared"},
	{["byte"] = 0x2C, ["bit"] = 1, ["name"] = "Castle: Diddy GB: Chain room", ["type"] = "GB"},
	{["byte"] = 0x2C, ["bit"] = 3, ["name"] = "Warp pad FTT", ["type"] = "FTT"},
	{["byte"] = 0x2C, ["bit"] = 6, ["name"] = "Crown pad FTT", ["type"] = "FTT"},

	{["byte"] = 0x2D, ["bit"] = 0, ["name"] = "Mini Monkey FTT?", ["type"] = "FTT"},
	{["byte"] = 0x2D, ["bit"] = 1, ["name"] = "Hunky Chunky FTT", ["type"] = "FTT"}, -- TODO: Test this
	{["byte"] = 0x2D, ["bit"] = 3, ["name"] = "Strong Kong FTT", ["type"] = "FTT"}, -- TODO: Test this
	{["byte"] = 0x2D, ["bit"] = 7, ["name"] = "? Caves Lobby: Diddy GB, more like FTT of some sort", ["type"] = "FTT"}, -- TODO: Test this
	{["byte"] = 0x2D, ["bit"] = 4, ["name"] = "Rainbow Coin FTT", ["type"] = "FTT"}, -- TODO: Test this
	{["byte"] = 0x2D, ["bit"] = 5, ["name"] = "Rambi FTT", ["type"] = "FTT"}, -- TODO: Test this
	{["byte"] = 0x2D, ["bit"] = 6, ["name"] = "Enguarde FTT", ["type"] = "Type"},

	{["byte"] = 0x2E, ["bit"] = 0, ["name"] = "Lanky FT GB", ["type"] = "FTT"},
	{["byte"] = 0x2E, ["bit"] = 1, ["name"] = "Tiny FT GB", ["type"] = "FTT"},
	{["byte"] = 0x2E, ["bit"] = 2, ["name"] = "Chunky FT GB", ["type"] = "FTT"},
	{["byte"] = 0x2E, ["bit"] = 4, ["name"] = "Snide's FTT", ["type"] = "FTT"},
	{["byte"] = 0x2E, ["bit"] = 5, ["name"] = "Buy Instruments"},
	{["byte"] = 0x2E, ["bit"] = 6, ["name"] = "Buy Guns"},

	{["byte"] = 0x2F, ["bit"] = 0, ["name"] = "Wrinkly FTT", ["type"] = "FTT"}, -- TODO: Test this
	{["byte"] = 0x2F, ["bit"] = 1, ["name"] = "? Fairy FTT", ["type"] = "FTT"}, -- TODO: Test this
	{["byte"] = 0x2F, ["bit"] = 1, ["name"] = "Camera/Shockwave"},
	{["byte"] = 0x2F, ["bit"] = 2, ["name"] = "Training Grounds: Treehouse Squawk Cutscene"},
	{["byte"] = 0x2F, ["bit"] = 4, ["name"] = "Key 8", ["type"] = "Key"},
	{["byte"] = 0x2F, ["bit"] = 5, ["name"] = "Isles: Japes boulder GB", ["type"] = "GB"},
	{["byte"] = 0x2F, ["bit"] = 6, ["name"] = "B.Locker FTT", ["type"] = "FTT"},
	{["byte"] = 0x2F, ["bit"] = 7, ["name"] = "Training Grounds: Barrels spwaned"}, -- TODO: Test this

	{["byte"] = 0x30, ["bit"] = 1, ["name"] = "Kong Unlocked: DK"},
	{["byte"] = 0x30, ["bit"] = 2, ["name"] = "Training Grounds: Dive Barrel Completed"},
	{["byte"] = 0x30, ["bit"] = 3, ["name"] = "Training Grounds: Vine Barrel Completed"},
	{["byte"] = 0x30, ["bit"] = 4, ["name"] = "Training Grounds: Orange Barrel Completed"}, -- TODO: Test this
	{["byte"] = 0x30, ["bit"] = 5, ["name"] = "Training Grounds: Barrel Barrel Completed"}, -- TODO: Test this
	{["byte"] = 0x30, ["bit"] = 6, ["name"] = "Isles: Escape FTT", ["type"] = "FTT"}, -- TODO: Test this

	{["byte"] = 0x31, ["bit"] = 0, ["name"] = "? T&S FTT ?", ["type"] = "FTT"},
	{["byte"] = 0x31, ["bit"] = 1, ["name"] = "Isles: Rareware GB room open"},
	{["byte"] = 0x31, ["bit"] = 5, ["name"] = "Factory Lobby: Lever pulled"}, -- TODO: Test this
	{["byte"] = 0x31, ["bit"] = 6, ["name"] = "? Japes Lobby: Lanky GB", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x31, ["bit"] = 7, ["name"] = "Aztec Lobby: Side room open"}, -- TODO: Test this

	{["byte"] = 0x32, ["bit"] = 0, ["name"] = "Aztec Lobby: Chunky Wrinkly flipped"}, -- TODO: Test this
	{["byte"] = 0x32, ["bit"] = 1, ["name"] = "Galleon Lobby: Chunky Switch"}, -- TODO: Test this
	{["byte"] = 0x32, ["bit"] = 2, ["name"] = "Isles: Tiny GB: Aztec lobby", ["type"] = "GB"},
	{["byte"] = 0x32, ["bit"] = 3, ["name"] = "? Galleon Lobby: Tiny GB?", ["type"] = "GB"}, -- TODO: Which one actually set it
	{["byte"] = 0x32, ["bit"] = 4, ["name"] = "Factory Lobby: DK GB", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x32, ["bit"] = 5, ["name"] = "Isles: Fungi lobby GGpad open"},
	{["byte"] = 0x32, ["bit"] = 6, ["name"] = "Helm Lobby: Kremling Kosh GB", ["type"] = "GB"},
	{["byte"] = 0x32, ["bit"] = 7, ["name"] = "Helm Lobby: Bridge Spawned"},

	{["byte"] = 0x33, ["bit"] = 0, ["name"] = "Caves Lobby: Ice wall BP room"}, -- TODO: Test this
	{["byte"] = 0x33, ["bit"] = 1, ["name"] = "Caves Lobby: Ice wall GB room"}, -- TODO: Test this
	{["byte"] = 0x33, ["bit"] = 2, ["name"] = "Caves Lobby: Diddy GB", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x33, ["bit"] = 3, ["name"] = "Caves Lobby: DK GB", ["type"] = "GB"}, -- TODO: Test this
	{["byte"] = 0x33, ["bit"] = 5, ["name"] = "Caves Lobby: Boulder on pad"}, -- TODO: Test this
	{["byte"] = 0x33, ["bit"] = 7, ["name"] = "Castle Lobby: Searchlight seek GB", ["type"] = "GB"},

	{["byte"] = 0x34, ["bit"] = 1, ["name"] = "Helm Lobby: W1 (Entrance)", ["type"] = "Warp"},
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
	{["byte"] = 0x35, ["bit"] = 4, ["name"] = "Isles: Diddy: Summit Bonus Barrel GB", ["type"] = "GB"},
	{["byte"] = 0x35, ["bit"] = 5, ["name"] = "Isles: Lanky: Sprint GB", ["type"] = "GB"}, -- TODO: Test this
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
	{["byte"] = 0x38, ["bit"] = 5, ["name"] = "? Story: Japes Intro"},
	{["byte"] = 0x38, ["bit"] = 6, ["name"] = "Story: Aztec Intro"},
	{["byte"] = 0x38, ["bit"] = 7, ["name"] = "Story: Factory Intro"},

	{["byte"] = 0x39, ["bit"] = 0, ["name"] = "Story: Galleon Intro"},
	{["byte"] = 0x39, ["bit"] = 1, ["name"] = "Story: Fungi Intro"},
	{["byte"] = 0x39, ["bit"] = 2, ["name"] = "Story: Caves Intro"},
	{["byte"] = 0x39, ["bit"] = 3, ["name"] = "Story: Castle Intro"},
	{["byte"] = 0x39, ["bit"] = 4, ["name"] = "Story: Helm Intro"},
	{["byte"] = 0x39, ["bit"] = 5, ["name"] = "Japes Lobby: B. Locker Cleared"},
	{["byte"] = 0x39, ["bit"] = 6, ["name"] = "Aztec Lobby: B. Locker Cleared"},
	{["byte"] = 0x39, ["bit"] = 7, ["name"] = "Factory Lobby: B. Locker Cleared"},

	{["byte"] = 0x3A, ["bit"] = 0, ["name"] = "Galleon Lobby: B. Locker Cleared"},
	{["byte"] = 0x3A, ["bit"] = 1, ["name"] = "Fungi B. Locker cleared"},
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
	{["byte"] = 0x42, ["bit"] = 2, ["name"] = "Snide's: Diddy BP Turned (Fungi)", ["type"] = "Blueprint"},
	{["byte"] = 0x42, ["bit"] = 3, ["name"] = "Snide's: Lanky BP Turned (Fungi)", ["type"] = "Blueprint"},
	{["byte"] = 0x42, ["bit"] = 4, ["name"] = "Snide's: Tiny BP Turned (Fungi)", ["type"] = "Blueprint"},
	{["byte"] = 0x42, ["bit"] = 5, ["name"] = "Snide's: Chunky BP Turned (Fungi)", ["type"] = "Blueprint"},
	{["byte"] = 0x42, ["bit"] = 6, ["name"] = "Snide's: DK BP Turned (Caves)", ["type"] = "Blueprint"},
	{["byte"] = 0x42, ["bit"] = 7, ["name"] = "Snide's: Diddy BP Turned (Caves)", ["type"] = "Blueprint"},

	{["byte"] = 0x43, ["bit"] = 0, ["name"] = "Snide's: Lanky BP Turned (Caves)", ["type"] = "Blueprint"},
	{["byte"] = 0x43, ["bit"] = 1, ["name"] = "Snide's: Tiny BP Turned (Caves)", ["type"] = "Blueprint"},
	{["byte"] = 0x43, ["bit"] = 2, ["name"] = "Snide's: Chunky BP Turned (Caves)", ["type"] = "Blueprint"},
	{["byte"] = 0x43, ["bit"] = 3, ["name"] = "Snide's: DK BP Turned (Castle)", ["type"] = "Blueprint"},
	{["byte"] = 0x43, ["bit"] = 4, ["name"] = "Snide's: Diddy BP Turned (Castle)", ["type"] = "Blueprint"},
	{["byte"] = 0x43, ["bit"] = 5, ["name"] = "Snide's: Lanky BP Turned (Castle)", ["type"] = "Blueprint"},
	{["byte"] = 0x43, ["bit"] = 6, ["name"] = "Snide's: Tiny BP Turned (Castle)", ["type"] = "Blueprint"},
	{["byte"] = 0x43, ["bit"] = 7, ["name"] = "Snide's: Chunky BP Turned (Castle)", ["type"] = "Blueprint"},

	{["byte"] = 0x44, ["bit"] = 0, ["name"] = "Snide's: DK BP Turned (Isles)", ["type"] = "Blueprint"},
	{["byte"] = 0x44, ["bit"] = 1, ["name"] = "Snide's: Diddy BP Turned (Isles)", ["type"] = "Blueprint"},
	{["byte"] = 0x44, ["bit"] = 2, ["name"] = "Snide's: Lanky BP Turned (Isles)", ["type"] = "Blueprint"},
	{["byte"] = 0x44, ["bit"] = 3, ["name"] = "Snide's: Tiny BP Turned (Isles)", ["type"] = "Blueprint"},
	{["byte"] = 0x44, ["bit"] = 4, ["name"] = "Snide's: Chunky BP Turned (Isles)", ["type"] = "Blueprint"},
	{["byte"] = 0x44, ["bit"] = 5, ["name"] = "Japes: DK Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x44, ["bit"] = 6, ["name"] = "Japes: Diddy Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x44, ["bit"] = 7, ["name"] = "Japes: Lanky Banana Medal", ["type"] = "Medal"},

	{["byte"] = 0x45, ["bit"] = 0, ["name"] = "Japes: Tiny Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x45, ["bit"] = 1, ["name"] = "Japes: Chunky Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x45, ["bit"] = 2, ["name"] = "Aztec: DK Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x45, ["bit"] = 3, ["name"] = "Aztec: Diddy Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x45, ["bit"] = 4, ["name"] = "Aztec: Lanky Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x45, ["bit"] = 5, ["name"] = "Aztec: Tiny Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x45, ["bit"] = 6, ["name"] = "Aztec: Chunky Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x45, ["bit"] = 7, ["name"] = "Factory: DK Banana Medal", ["type"] = "Medal"},

	{["byte"] = 0x46, ["bit"] = 0, ["name"] = "Factory: Diddy Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x46, ["bit"] = 1, ["name"] = "Factory: Lanky Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x46, ["bit"] = 2, ["name"] = "Factory: Tiny Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x46, ["bit"] = 3, ["name"] = "Factory: Chunky Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x46, ["bit"] = 7, ["name"] = "Galleon: Tiny Banana medal", ["type"] = "Medal"},

	{["byte"] = 0x47, ["bit"] = 1, ["name"] = "Fungi: DK Banana Medal ", ["type"] = "Medal"},
	{["byte"] = 0x47, ["bit"] = 2, ["name"] = "Fungi: Diddy Banana Medal: ", ["type"] = "Medal"},
	{["byte"] = 0x47, ["bit"] = 3, ["name"] = "Fungi: Lanky Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x47, ["bit"] = 4, ["name"] = "Fungi: Tiny Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x47, ["bit"] = 5, ["name"] = "Fungi: Chunky Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x47, ["bit"] = 6, ["name"] = "Caves: DK Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x47, ["bit"] = 7, ["name"] = "Caves: Diddy Banana Medal", ["type"] = "Medal"},

	{["byte"] = 0x48, ["bit"] = 0, ["name"] = "Caves: Lanky Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x48, ["bit"] = 1, ["name"] = "Caves: Tiny Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x48, ["bit"] = 2, ["name"] = "Caves: Chunky Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x48, ["bit"] = 3, ["name"] = "Castle: DK Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x48, ["bit"] = 4, ["name"] = "Castle: Diddy Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x48, ["bit"] = 5, ["name"] = "Castle: Lanky Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x48, ["bit"] = 6, ["name"] = "Castle: Tiny Banana Medal", ["type"] = "Medal"},
	{["byte"] = 0x48, ["bit"] = 7, ["name"] = "Castle: Chunky Banana Medal", ["type"] = "Medal"},

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
	{["byte"] = 0x4D, ["bit"] = 5, ["name"] = "Japes: Rainbow Coin (Slope by painting room)", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x4D, ["bit"] = 6, ["name"] = "Japes: Diddy CB: Balloon in cave", ["type"] = "Balloon"},
	{["byte"] = 0x4D, ["bit"] = 7, ["name"] = "Japes: DK CB: Balloon by Snide", ["type"] = "Balloon"},

	{["byte"] = 0x4E, ["bit"] = 0, ["name"] = "Japes: Chunky CB: Balloon in cave (1)", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 1, ["name"] = "Japes: Lanky CB: Balloon by hut", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 2, ["name"] = "Japes: Diddy CB: Balloon by W5", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 3, ["name"] = "Japes: DK CB: Balloon by Underground", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 4, ["name"] = "Japes: DK CB: Balloon by Cranky", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 5, ["name"] = "Japes: Tiny CB: Balloon by hut", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 6, ["name"] = "Japes: Tiny CB: Balloon in Fairy room", ["type"] = "Balloon"},
	{["byte"] = 0x4E, ["bit"] = 7, ["name"] = "Japes: Chunky CB: Balloon in cave (2)", ["type"] = "Balloon"},

	{["byte"] = 0x4F, ["bit"] = 0, ["name"] = "Japes: Chunky CB: Balloon in cave (3)", ["type"] = "Balloon"},
	{["byte"] = 0x4F, ["bit"] = 1, ["name"] = "Japes: Lanky CB: Balloon by his BP", ["type"] = "Balloon"},
	{["byte"] = 0x4F, ["bit"] = 2, ["name"] = "Japes: Tiny CB: Balloon in shellhive", ["type"] = "Balloon"},
	{["byte"] = 0x4F, ["bit"] = 3, ["name"] = "Japes: Lanky CB: Balloon in painting room)", ["type"] = "Balloon"},
	{["byte"] = 0x4F, ["bit"] = 4, ["name"] = "Aztec: Tiny CB: Balloon in free Tiny Room (1)", ["type"] = "Balloon"},
	{["byte"] = 0x4F, ["bit"] = 5, ["name"] = "Aztec: Tiny CB: Balloon in free Tiny Room (2)", ["type"] = "Balloon"},
	{["byte"] = 0x4F, ["bit"] = 6, ["name"] = "Aztec: Chunky CB: Battle Crown", ["type"] = "Balloon"},
	{["byte"] = 0x4F, ["bit"] = 7, ["name"] = "Aztec: Tiny CB: Llama temple", ["type"] = "Balloon"},

	{["byte"] = 0x50, ["bit"] = 0, ["name"] = "Aztec: Lanky CB: Lanky Cage (1)", ["type"] = "Balloon"},
	{["byte"] = 0x50, ["bit"] = 1, ["name"] = "Aztec: Lanky CB: Lanky Cage (2)", ["type"] = "Balloon"},
	{["byte"] = 0x50, ["bit"] = 2, ["name"] = "Aztec: Diddy CB: 5DT", ["type"] = "Balloon"},
	{["byte"] = 0x50, ["bit"] = 3, ["name"] = "Aztec: Lanky CB: 5DT", ["type"] = "Balloon"},
	{["byte"] = 0x50, ["bit"] = 4, ["name"] = "Aztec: Chunky CB: 5DT (1)", ["type"] = "Balloon"},
	{["byte"] = 0x50, ["bit"] = 5, ["name"] = "Aztec: Chunky CB: 5DT (2)", ["type"] = "Balloon"},
	{["byte"] = 0x50, ["bit"] = 6, ["name"] = "Aztec: 5DT Rainbow Coin", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x50, ["bit"] = 7, ["name"] = "Factory: Chunky CB: Hatch", ["type"] = "Balloon"},

	{["byte"] = 0x51, ["bit"] = 0, ["name"] = "Factory: Chunky CB: Balloon above Snide", ["type"] = "Balloon"},
	{["byte"] = 0x51, ["bit"] = 1, ["name"] = "Factory: Lanky CB: Balloon by F Key", ["type"] = "Balloon"},
	{["byte"] = 0x51, ["bit"] = 2, ["name"] = "Factory: Tiny CB: Balloon by Snide", ["type"] = "Balloon"},
	{["byte"] = 0x51, ["bit"] = 3, ["name"] = "Factory: Diddy CB: R&D room (1)", ["type"] = "Balloon"},
	{["byte"] = 0x51, ["bit"] = 4, ["name"] = "Factory: Diddy CB: R&D room (2)", ["type"] = "Balloon"},
	{["byte"] = 0x51, ["bit"] = 6, ["name"] = "Factory: DK CB: Balloon in Cranky and Candy Area", ["type"] = "Balloon"},
	{["byte"] = 0x51, ["bit"] = 7, ["name"] = "Factory: DK CB: Balloon by Numbers Game", ["type"] = "Balloon"},

	{["byte"] = 0x52, ["bit"] = 0, ["name"] = "Factory: Diddy CB: R&D room (3)", ["type"] = "Balloon"},
	{["byte"] = 0x52, ["bit"] = 1, ["name"] = "Factory: Tiny CB: Production room", ["type"] = "Balloon"},
	{["byte"] = 0x52, ["bit"] = 2, ["name"] = "Factory: Tiny CB: Balloon by Funky", ["type"] = "Balloon"},
	{["byte"] = 0x52, ["bit"] = 3, ["name"] = "Factory: Lanky CB: Production room", ["type"] = "Balloon"},
	{["byte"] = 0x52, ["bit"] = 4, ["name"] = "Factory: Chunky CB: Toy monster", ["type"] = "Balloon"},
	{["byte"] = 0x52, ["bit"] = 5, ["name"] = "Factory: Rainbow Coin", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x52, ["bit"] = 7, ["name"] = "Galleon: Tiny CB: Diddy kasplat balloon", ["type"] = "Balloon"},

	{["byte"] = 0x54, ["bit"] = 2, ["name"] = "Galleon: Tiny CB: Snides Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x54, ["bit"] = 3, ["name"] = "Galleon: Tiny CB: Gold tower balloon", ["type"] = "Balloon"},
	{["byte"] = 0x54, ["bit"] = 4, ["name"] = "Isles: Rainbow Coin (Fungi Lobby Entrance)?", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x54, ["bit"] = 5, ["name"] = "Isles: Rainbow Coin (Caves Early)", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x54, ["bit"] = 6, ["name"] = "Isles: Rainbow Coin (Aztec Lobby Roof)", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x54, ["bit"] = 7, ["name"] = "Factory: Lanky CB: Crusher room", ["type"] = "Balloon"},

	{["byte"] = 0x55, ["bit"] = 0, ["name"] = "Aztec: DK CB: Cranky (1)", ["type"] = "Balloon"},
	{["byte"] = 0x55, ["bit"] = 1, ["name"] = "Aztec: Diddy CB: Tiny temple Entrance", ["type"] = "Balloon"},
	{["byte"] = 0x55, ["bit"] = 2, ["name"] = "Aztec: DK CB: Behind Llama temple", ["type"] = "Balloon"},
	{["byte"] = 0x55, ["bit"] = 3, ["name"] = "Aztec: DK CB: Cranky (2)", ["type"] = "Balloon"},
	{["byte"] = 0x55, ["bit"] = 4, ["name"] = "Aztec: Diddy CB: W5 tunnel", ["type"] = "Balloon"},
	{["byte"] = 0x55, ["bit"] = 5, ["name"] = "Aztec: Rainbow Coin", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x55, ["bit"] = 6, ["name"] = "Fungi: Diddy CB: Snides balloon", ["type"] = "Balloon"},

	{["byte"] = 0x56, ["bit"] = 0, ["name"] = "Fungi: Tiny CB: Kasplat Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x56, ["bit"] = 1, ["name"] = "Fungi: DK CB: Balloon behind barn", ["type"] = "Balloon"},
	{["byte"] = 0x56, ["bit"] = 2, ["name"] = "Fungi: Rainbow Coin", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x56, ["bit"] = 3, ["name"] = "Fungi: Chunky CB: Kasplat Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x56, ["bit"] = 4, ["name"] = "Fungi: Tiny CB: Behind DK barn", ["type"] = "Balloon"},
	{["byte"] = 0x56, ["bit"] = 6, ["name"] = "Galleon: Rainbow Coin (Lighthouse)", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x56, ["bit"] = 7, ["name"] = "Fungi: Diddy CB: Attic balloon", ["type"] = "Balloon"},

	{["byte"] = 0x57, ["bit"] = 0, ["name"] = "Fungi: DK CB: Balloon in Mill", ["type"] = "Balloon"},
	{["byte"] = 0x57, ["bit"] = 1, ["name"] = "Fungi: Lanky CB: Balloon in upper Mushroom", ["type"] = "Balloon"},
	{["byte"] = 0x57, ["bit"] = 2, ["name"] = "Fungi: Lanky CB: Balloon in Lower Mushroom", ["type"] = "Balloon"},
	{["byte"] = 0x57, ["bit"] = 3, ["name"] = "Fungi: Chunky CB: Face game Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x57, ["bit"] = 4, ["name"] = "Caves: Diddy CB: W4 Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x57, ["bit"] = 5, ["name"] = "Caves: Chunky CB: Snide Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x57, ["bit"] = 6, ["name"] = "Caves: Tiny CB: Near Candy", ["type"] = "Balloon"},
	{["byte"] = 0x57, ["bit"] = 7, ["name"] = "Caves: Rainbow Coin", ["type"] = "Rainbow Coin"},

	{["byte"] = 0x58, ["bit"] = 0, ["name"] = "Caves: Lanky CB: Outside Cabin", ["type"] = "Balloon"},
	{["byte"] = 0x58, ["bit"] = 1, ["name"] = "Caves: DK CB: Entrance Icewall", ["type"] = "Balloon"},
	{["byte"] = 0x58, ["bit"] = 2, ["name"] = "Caves: Diddy CB: 5DC Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x58, ["bit"] = 3, ["name"] = "Caves: Chunky CB: W3 Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x58, ["bit"] = 4, ["name"] = "Caves: Tiny CB: W2 Kasplat", ["type"] = "Balloon"},
	{["byte"] = 0x58, ["bit"] = 6, ["name"] = "Caves: Tiny CB: 5DI", ["type"] = "Balloon"},
	{["byte"] = 0x58, ["bit"] = 7, ["name"] = "Caves: Lanky CB: 5DI Balloon", ["type"] = "Balloon"},

	{["byte"] = 0x59, ["bit"] = 0, ["name"] = "Caves: DK CB: 5DI", ["type"] = "Balloon"},
	{["byte"] = 0x59, ["bit"] = 1, ["name"] = "Castle: Rainbow Coin (Snide's)", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x59, ["bit"] = 2, ["name"] = "Castle: Diddy CB: W1 Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x59, ["bit"] = 3, ["name"] = "Castle: Diddy CB: Ballroom Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x59, ["bit"] = 4, ["name"] = "Caves: Tiny CB: 5DC", ["type"] = "Balloon"},
	{["byte"] = 0x59, ["bit"] = 5, ["name"] = "Caves: Chunky CB: 5DI", ["type"] = "Balloon"},
	{["byte"] = 0x59, ["bit"] = 6, ["name"] = "Isles: Rainbow Coin (K. Lumsy)", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x59, ["bit"] = 7, ["name"] = "Caves: Lanky CB: Ice Tomato Balloon", ["type"] = "Balloon"},

	{["byte"] = 0x5A, ["bit"] = 0, ["name"] = "Caves: Diddy CB: 5DI Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x5A, ["bit"] = 1, ["name"] = "Castle: Lanky CB: Lanky tower Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x5A, ["bit"] = 2, ["name"] = "Castle: Lanky CB: Crypt Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x5A, ["bit"] = 3, ["name"] = "Caves: Diddy CB: Coffin Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x5A, ["bit"] = 4, ["name"] = "Castle: DK CB: Crypt Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x5A, ["bit"] = 5, ["name"] = "Castle: Tiny CB: Museum display Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x5A, ["bit"] = 6, ["name"] = "Castle: Chunky CB: Museum balloon", ["type"] = "Balloon"},
	{["byte"] = 0x5A, ["bit"] = 7, ["name"] = "Castle: Diddy CB: Chain room", ["type"] = "Balloon"},

	{["byte"] = 0x5B, ["bit"] = 0, ["name"] = "Castle: Lanky CB: Dungeon Balloon (1)", ["type"] = "Balloon"},
	{["byte"] = 0x5B, ["bit"] = 1, ["name"] = "Castle: Chunky CB: Dungeon Balloon (1)", ["type"] = "Balloon"},
	{["byte"] = 0x5B, ["bit"] = 2, ["name"] = "Castle: Lanky CB: Dungeon Balloon (2)", ["type"] = "Balloon"},
	{["byte"] = 0x5B, ["bit"] = 4, ["name"] = "Castle: DK CB: Tree Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x5B, ["bit"] = 3, ["name"] = "Castle: Chunky CB: Dungeon Balloon (2)", ["type"] = "Balloon"},
	{["byte"] = 0x5B, ["bit"] = 5, ["name"] = "Castle: Chunky CB: Tree Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x5B, ["bit"] = 6, ["name"] = "Castle: Chunky Balloon: Shed", ["type"] = "Balloon"},
	{["byte"] = 0x5B, ["bit"] = 7, ["name"] = "Training Grounds: Tunnel Rainbow Coin", ["type"] = "Rainbow Coin"},

	{["byte"] = 0x5C, ["bit"] = 0, ["name"] = "Training Grounds: Waterfall Rainbow Coin", ["type"] = "Rainbow Coin"},
	{["byte"] = 0x5C, ["bit"] = 1, ["name"] = "Castle: Diddy CB: Crypt Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x5C, ["bit"] = 2, ["name"] = "Castle: Tiny CB: Funky Balloon", ["type"] = "Balloon"},
	{["byte"] = 0x5C, ["bit"] = 3, ["name"] = "Castle Lobby: Rainbow Coin", ["type"] = "Rainbow Coin"},

	{["byte"] = 0x60, ["bit"] = 2, ["name"] = "Helm: BoM off"},
	{["byte"] = 0x60, ["bit"] = 4, ["name"] = "Helm: Crown door open"},
	{["byte"] = 0x60, ["bit"] = 5, ["name"] = "Helm: W1 (Entrance)", ["type"] = "Warp"},
	{["byte"] = 0x60, ["bit"] = 6, ["name"] = "Helm: W1 (Far)", ["type"] = "Warp"},
	{["byte"] = 0x60, ["bit"] = 7, ["name"] = "FT Funky CS"},

	{["byte"] = 0x61, ["bit"] = 2, ["name"] = "FT Candy CS"},
	{["byte"] = 0x61, ["bit"] = 3, ["name"] = "Japes: FTT", ["type"] = "FTT"},
	{["byte"] = 0x61, ["bit"] = 4, ["name"] = "Factory: FTT", ["type"] = "FTT"},
	{["byte"] = 0x61, ["bit"] = 5, ["name"] = "Galleon: FTT", ["type"] = "FTT"},
	{["byte"] = 0x61, ["bit"] = 6, ["name"] = "Fungi: FTT", ["type"] = "FTT"},
	{["byte"] = 0x61, ["bit"] = 7, ["name"] = "Caves: FTT", ["type"] = "FTT"},

	{["byte"] = 0x62, ["bit"] = 0, ["name"] = "Castle: FTT", ["type"] = "FTT"},
	{["byte"] = 0x62, ["bit"] = 1, ["name"] = "T&S FTT", ["type"] = "FTT"},
	{["byte"] = 0x62, ["bit"] = 2, ["name"] = "Helm: FTT", ["type"] = "FTT"},
	{["byte"] = 0x62, ["bit"] = 3, ["name"] = "Aztec: FTT", ["type"] = "FTT"},

	{["byte"] = 0x64, ["bit"] = 0, ["name"] = "Japes: Chunky Coin: By portal (1)", ["type"] = "Coin"},
	{["byte"] = 0x64, ["bit"] = 1, ["name"] = "Japes: Chunky Coin: In water (1)", ["type"] = "Coin"},
	{["byte"] = 0x64, ["bit"] = 2, ["name"] = "Japes: Tiny CB: Tunnel to main area (1)", ["type"] = "CB"},
	{["byte"] = 0x64, ["bit"] = 3, ["name"] = "Japes: Tiny CB: Tunnel to main area (2)", ["type"] = "CB"},
	{["byte"] = 0x64, ["bit"] = 4, ["name"] = "Japes: Tiny CB: Tunnel to main area (3)", ["type"] = "CB"},
	{["byte"] = 0x64, ["bit"] = 5, ["name"] = "Japes: Chunky CB: Shellhive tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0x64, ["bit"] = 6, ["name"] = "Japes: Tiny CB: Tunnel to main area (4)", ["type"] = "CB"},

	{["byte"] = 0x65, ["bit"] = 0, ["name"] = "Japes: DK CB: By entrance (1)", ["type"] = "CB"},
	{["byte"] = 0x65, ["bit"] = 2, ["name"] = "Japes: DK CB: Bunch on left W3", ["type"] = "Bunch"}, -- TODO: Test this
	{["byte"] = 0x65, ["bit"] = 4, ["name"] = "Japes: DK CB: By entrance (2)", ["type"] = "CB"},
	{["byte"] = 0x65, ["bit"] = 6, ["name"] = "Japes: Chunky CB: Bunch on Funky's (Right)", ["type"] = "Bunch"},
	{["byte"] = 0x65, ["bit"] = 7, ["name"] = "Japes: Lanky CB: Bunch on tree by Cranky's", ["type"] = "Bunch"},

	{["byte"] = 0x66, ["bit"] = 3, ["name"] = "Japes: Diddy CB: 101st banana", ["type"] = "CB"},
	{["byte"] = 0x66, ["bit"] = 5, ["name"] = "Japes: DK CB: By entrance (3)", ["type"] = "CB"},
	{["byte"] = 0x66, ["bit"] = 6, ["name"] = "Japes: DK CB: By entrance (4)", ["type"] = "CB"},
	{["byte"] = 0x66, ["bit"] = 7, ["name"] = "Japes: DK CB: By entrance (5)", ["type"] = "CB"},

	{["byte"] = 0x68, ["bit"] = 0, ["name"] = "Japes: Chunky Coin: By portal (2)", ["type"] = "Coin"},
	{["byte"] = 0x68, ["bit"] = 1, ["name"] = "Japes: Lanky CB: Bonus Barrel Room (1)", ["type"] = "CB"},
	{["byte"] = 0x68, ["bit"] = 2, ["name"] = "Japes: Chunky Coin: In water (2)", ["type"] = "Coin"},
	{["byte"] = 0x68, ["bit"] = 3, ["name"] = "Japes: Chunky Coin: In water (3)", ["type"] = "Coin"},
	{["byte"] = 0x68, ["bit"] = 4, ["name"] = "Japes: Diddy CB: Bunch under hut", ["type"] = "Bunch"},
	{["byte"] = 0x68, ["bit"] = 5, ["name"] = "Japes: Lanky CB: Bonus Barrel Room (2)", ["type"] = "CB"},
	{["byte"] = 0x68, ["bit"] = 7, ["name"] = "Japes: Lanky Coin: Cave near entrance (1)", ["type"] = "Coin"},

	{["byte"] = 0x69, ["bit"] = 6, ["name"] = "Japes: Lanky CB: Bunch under hut", ["type"] = "Bunch"},
	{["byte"] = 0x69, ["bit"] = 7, ["name"] = "Japes: DK CB: Bunch under hut", ["type"] = "Bunch"},

	{["byte"] = 0x6A, ["bit"] = 1, ["name"] = "Japes: Lanky CB: Bunch under bonus barrel", ["type"] = "Bunch"},
	{["byte"] = 0x6A, ["bit"] = 5, ["name"] = "Japes: Diddy CB: In right tunnel (1)", ["type"] = "CB"},

	{["byte"] = 0x6B, ["bit"] = 0, ["name"] = "Japes: DK Coin: Babboon Blast Pad (1)", ["type"] = "Coin"},
	{["byte"] = 0x6B, ["bit"] = 4, ["name"] = "Japes: DK Coin: Entrance (1)", ["type"] = "Coin"},
	{["byte"] = 0x6B, ["bit"] = 5, ["name"] = "Japes: Chunky CB: Shellhive tunnel (2)", ["type"] = "CB"},

	{["byte"] = 0x6C, ["bit"] = 0, ["name"] = "Japes: Chunky CB: Shellhive tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0x6C, ["bit"] = 6, ["name"] = "Japes: DK CB: Bunch by Funky's (tree)", ["type"] = "Bunch"}, -- TODO: Test this

	{["byte"] = 0x6D, ["bit"] = 0, ["name"] = "Japes: Chunky CB: Bunch in Shellhive area (1)", ["type"] = "Bunch"},
	{["byte"] = 0x6D, ["bit"] = 1, ["name"] = "Japes: Tiny Coin: Fairy cave (1)", ["type"] = "Coin"},
	{["byte"] = 0x6D, ["bit"] = 3, ["name"] = "Japes: Diddy CB: In right tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0x6D, ["bit"] = 4, ["name"] = "Japes: Diddy CB: In right tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0x6D, ["bit"] = 6, ["name"] = "Japes: DK Coin: Babboon Blast Pad (2)", ["type"] = "Coin"},
	{["byte"] = 0x6D, ["bit"] = 7, ["name"] = "Japes: DK Coin: Entrance (2)", ["type"] = "Coin"},

	{["byte"] = 0x6E, ["bit"] = 0, ["name"] = "Japes: Tiny CB: Bunch under hut", ["type"] = "Bunch"},
	{["byte"] = 0x6E, ["bit"] = 3, ["name"] = "Japes: DK Coin: BP (1)", ["type"] = "Coin"},
	{["byte"] = 0x6E, ["bit"] = 4, ["name"] = "Japes: Tiny Coin: BP (1)", ["type"] = "Coin"},
	{["byte"] = 0x6E, ["bit"] = 5, ["name"] = "Japes: Diddy CB: Bunch on tree (Middle Left)", ["type"] = "Bunch"},
	{["byte"] = 0x6E, ["bit"] = 6, ["name"] = "Japes: Diddy CB: Bunch on tree (Left)", ["type"] = "Bunch"},

	{["byte"] = 0x6F, ["bit"] = 0, ["name"] = "Japes: Lanky Coin: Cave near entrance (2)", ["type"] = "Coin"},
	{["byte"] = 0x6F, ["bit"] = 1, ["name"] = "Japes: Lanky Coin: Cave near entrance (3)", ["type"] = "Coin"},
	{["byte"] = 0x6F, ["bit"] = 2, ["name"] = "Japes: Diddy Coin: BP (1)", ["type"] = "Coin"},
	{["byte"] = 0x6F, ["bit"] = 3, ["name"] = "Japes: Chunky CB: Shellhive tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0x6F, ["bit"] = 5, ["name"] = "Japes: Diddy CB: By entrance (1)", ["type"] = "CB"},
	{["byte"] = 0x6F, ["bit"] = 6, ["name"] = "Japes: Tiny Coin: BP (2)", ["type"] = "Coin"},
	{["byte"] = 0x6F, ["bit"] = 7, ["name"] = "Japes: DK Coin: Entrance (3)", ["type"] = "Coin"},

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
	{["byte"] = 0x72, ["bit"] = 4, ["name"] = "Japes: Diddy Coin: BP (2)", ["type"] = "Coin"},
	{["byte"] = 0x72, ["bit"] = 5, ["name"] = "Japes: Diddy CB: Bunch on tree (Middle Right)", ["type"] = "Bunch"},

	{["byte"] = 0x73, ["bit"] = 0, ["name"] = "Japes: Tiny CB: Tunnel to main area (5)", ["type"] = "CB"},
	{["byte"] = 0x73, ["bit"] = 1, ["name"] = "Japes: DK Coin: Babboon Blast Pad (3)", ["type"] = "Coin"},
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
	{["byte"] = 0x74, ["bit"] = 6, ["name"] = "Japes: Diddy CB: By entrance (2)", ["type"] = "CB"},
	{["byte"] = 0x74, ["bit"] = 7, ["name"] = "Japes: Lanky Coin: Bonus Barrel Room (1)", ["type"] = "Coin"}, -- TODO: Flags missing in this room with block size 0x80

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
	{["byte"] = 0x77, ["bit"] = 6, ["name"] = "Japes: Chunky Coin: Sump (1)", ["type"] = "Coin"},
	{["byte"] = 0x77, ["bit"] = 7, ["name"] = "Japes: Chunky Coin: Stump (2)", ["type"] = "Coin"},

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

	{["byte"] = 0x7B, ["bit"] = 0, ["name"] = "Japes: Lanky Coin: Bonus Barrel Room (2)", ["type"] = "Coin"}, -- TODO: Flags missing in this room with block size 0x80
	{["byte"] = 0x7B, ["bit"] = 1, ["name"] = "Japes: Chunky CB: Bunch in Shellhive area (4)", ["type"] = "Bunch"},
	{["byte"] = 0x7B, ["bit"] = 2, ["name"] = "Japes: Chunky Coin: Stump (3)", ["type"] = "Coin"},
	{["byte"] = 0x7B, ["bit"] = 3, ["name"] = "Japes: Diddy Coin: BP (3)", ["type"] = "Coin"},
	{["byte"] = 0x7B, ["bit"] = 4, ["name"] = "Japes: Lanky Coin: By Snide's (4)", ["type"] = "Coin"},
	{["byte"] = 0x7B, ["bit"] = 5, ["name"] = "Japes: Lanky Coin: By Snide's (5)", ["type"] = "Coin"},

	{["byte"] = 0x7C, ["bit"] = 0, ["name"] = "Japes: Tiny Coin: Underground (1)", ["type"] = "Coin"},
	{["byte"] = 0x7C, ["bit"] = 3, ["name"] = "Japes: Tiny Coin: Underground (2)", ["type"] = "Coin"},
	{["byte"] = 0x7C, ["bit"] = 6, ["name"] = "Japes: DK CB: Bunch in Babboon blast (1)", ["type"] = "Bunch"}, -- TODO: Flags missing in this room with block size 0x80
	{["byte"] = 0x7C, ["bit"] = 7, ["name"] = "Japes: DK Coin: Babboon blast (1)", ["type"] = "Coin"}, -- TODO: Flags missing in this room with block size 0x80
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

	{["byte"] = 0x7F, ["bit"] = 0, ["name"] = "Japes: DK Coin: BP (3)", ["type"] = "Coin"},
	{["byte"] = 0x7F, ["bit"] = 1, ["name"] = "Japes: Tiny Coin: Inside shellhive (1)", ["type"] = "Coin"},
	{["byte"] = 0x7F, ["bit"] = 2, ["name"] = "Japes: Tiny Coin: Inside shellhive (2)", ["type"] = "Coin"},
	{["byte"] = 0x7F, ["bit"] = 3, ["name"] = "Japes: Tiny CB: Inside shellhive (4)", ["type"] = "CB"},
	{["byte"] = 0x7F, ["bit"] = 4, ["name"] = "Japes: Tiny CB: Inside shellhive (5)", ["type"] = "CB"},
	{["byte"] = 0x7F, ["bit"] = 5, ["name"] = "Japes: Tiny CB: Inside shellhive (6)", ["type"] = "CB"},
	{["byte"] = 0x7F, ["bit"] = 6, ["name"] = "Japes: Tiny CB: Inside shellhive (7)", ["type"] = "CB"},
	{["byte"] = 0x7F, ["bit"] = 7, ["name"] = "Japes: Tiny CB: Inside shellhive (8)", ["type"] = "CB"},

	{["byte"] = 0x80, ["bit"] = 0, ["name"] = "Aztec: Diddy CB: Tiny temple (1)", ["type"] = "CB"},
	{["byte"] = 0x80, ["bit"] = 1, ["name"] = "Aztec: Diddy CB: Bunch on tongue (1)", ["type"] = "Bunch"},
	{["byte"] = 0x80, ["bit"] = 2, ["name"] = "Aztec: Diddy CB: Bunch on tongue (2)", ["type"] = "Bunch"},
	{["byte"] = 0x80, ["bit"] = 3, ["name"] = "Aztec: Diddy CB: Bunch on tongue (3)", ["type"] = "Bunch"},
	{["byte"] = 0x80, ["bit"] = 4, ["name"] = "Aztec: Diddy CB: Tiny temple tongue (1)", ["type"] = "CB"},
	{["byte"] = 0x80, ["bit"] = 5, ["name"] = "Aztec: Diddy CB: Tiny temple tongue (2)", ["type"] = "CB"},
	{["byte"] = 0x80, ["bit"] = 6, ["name"] = "Aztec: Tiny Coin: Near Crown (1)", ["type"] = "Coin"},
	{["byte"] = 0x80, ["bit"] = 7, ["name"] = "Aztec: Tiny temple Tiny CB (2)", ["type"] = "CB"},

	{["byte"] = 0x81, ["bit"] = 0, ["name"] = "Aztec: Diddy CB: Tiny temple tongue (3)", ["type"] = "CB"},
	{["byte"] = 0x81, ["bit"] = 1, ["name"] = "Aztec: Tiny Coin: Near Crown (2)", ["type"] = "Coin"},
	{["byte"] = 0x81, ["bit"] = 2, ["name"] = "Aztec: Chunky Coin: Tiny temple (1)", ["type"] = "Coin"},
	{["byte"] = 0x81, ["bit"] = 3, ["name"] = "Aztec: Lanky CB: Bunch on Tiny temple switch", ["type"] = "Bunch"},
	{["byte"] = 0x81, ["bit"] = 6, ["name"] = "Aztec: Diddy CB: Tiny temple (2)", ["type"] = "CB"},
	{["byte"] = 0x81, ["bit"] = 7, ["name"] = "Aztec: Diddy CB: Tiny temple (3)", ["type"] = "CB"},

	{["byte"] = 0x82, ["bit"] = 7, ["name"] = "Aztec: Tiny Coin: Near Crown (3)", ["type"] = "Coin"},
	{["byte"] = 0x82, ["bit"] = 6, ["name"] = "Aztec: Diddy Coin: Instrument pad (Tiny temple)", ["type"] = "Coin"},

	{["byte"] = 0x83, ["bit"] = 2, ["name"] = "Aztec: Diddy CB: Tiny temple (4)", ["type"] = "CB"},
	{["byte"] = 0x83, ["bit"] = 3, ["name"] = "Aztec: Diddy CB: Tiny temple (5)", ["type"] = "CB"},
	{["byte"] = 0x83, ["bit"] = 4, ["name"] = "Aztec: Diddy CB: Tiny temple (6)", ["type"] = "CB"},
	{["byte"] = 0x83, ["bit"] = 5, ["name"] = "Aztec: Diddy CB: Tiny temple (7)", ["type"] = "CB"},

	{["byte"] = 0x84, ["bit"] = 0, ["name"] = "Aztec: DK Coin: 5DT (1)", ["type"] = "Coin"},
	{["byte"] = 0x84, ["bit"] = 1, ["name"] = "Aztec: DK CB: Llama temple Bongo pad (1)", ["type"] = "CB"},
	{["byte"] = 0x84, ["bit"] = 2, ["name"] = "Aztec: DK Coin: Llama temple Bongo pad (1)", ["type"] = "Coin"},
	{["byte"] = 0x84, ["bit"] = 3, ["name"] = "Aztec: DK CB: Llama temple Bongo pad (2)", ["type"] = "CB"},
	{["byte"] = 0x84, ["bit"] = 4, ["name"] = "Aztec: DK Coin: Llama temple Bongo pad (2)", ["type"] = "Coin"},
	{["byte"] = 0x84, ["bit"] = 5, ["name"] = "Aztec: DK CB: Llama temple stairs (1)", ["type"] = "CB"},
	{["byte"] = 0x84, ["bit"] = 6, ["name"] = "Aztec: DK CB: Llama temple stairs (2)", ["type"] = "CB"},
	{["byte"] = 0x84, ["bit"] = 7, ["name"] = "Aztec: DK CB: Llama temple stairs (3)", ["type"] = "CB"},

	{["byte"] = 0x85, ["bit"] = 0, ["name"] = "Aztec: Chunky Coin: Tiny temple (2)", ["type"] = "Coin"},
	{["byte"] = 0x85, ["bit"] = 1, ["name"] = "Aztec: Tiny Coin: Near Crown (4)", ["type"] = "Coin"},
	{["byte"] = 0x85, ["bit"] = 2, ["name"] = "Aztec: Diddy Coin: Tiny cage (1)", ["type"] = "Coin"},
	{["byte"] = 0x85, ["bit"] = 3, ["name"] = "Aztec: Diddy Coin: Tiny cage (2)", ["type"] = "Coin"},
	{["byte"] = 0x85, ["bit"] = 4, ["name"] = "Aztec: Diddy Coin: Tiny cage (3)", ["type"] = "Coin"},
	{["byte"] = 0x85, ["bit"] = 5, ["name"] = "Aztec: Diddy Coin: Tiny cage (4)", ["type"] = "Coin"},
	{["byte"] = 0x85, ["bit"] = 6, ["name"] = "Aztec: Diddy Coin: Tiny cage (5)", ["type"] = "Coin"},
	{["byte"] = 0x85, ["bit"] = 7, ["name"] = "Aztec: DK Coin: 5DT (2)", ["type"] = "Coin"},

	{["byte"] = 0x86, ["bit"] = 0, ["name"] = "Aztec: Chunky CB: Bunch in Tiny temple (1)", ["type"] = "Bunch"},
	{["byte"] = 0x86, ["bit"] = 1, ["name"] = "Aztec: Chunky CB: Bunch in Tiny temple (2)", ["type"] = "Bunch"},
	{["byte"] = 0x86, ["bit"] = 2, ["name"] = "Aztec: Chunky CB: Bunch in Tiny temple (3)", ["type"] = "Bunch"},
	{["byte"] = 0x86, ["bit"] = 3, ["name"] = "Aztec: Chunky CB: Bunch in Tiny temple (4)", ["type"] = "Bunch"},
	{["byte"] = 0x86, ["bit"] = 4, ["name"] = "Aztec: Chunky CB: Bunch in Tiny temple (5)", ["type"] = "Bunch"},
	{["byte"] = 0x86, ["bit"] = 5, ["name"] = "Aztec: Chunky CB: Tiny temple (1)", ["type"] = "CB"},
	{["byte"] = 0x86, ["bit"] = 7, ["name"] = "Aztec: Chunky Coin: Tiny temple (3)", ["type"] = "Coin"},

	{["byte"] = 0x87, ["bit"] = 0, ["name"] = "Aztec: Tiny temple Tiny CB (1)", ["type"] = "CB"},
	{["byte"] = 0x87, ["bit"] = 1, ["name"] = "Aztec: Tiny temple Tiny CB (5)", ["type"] = "CB"},
	{["byte"] = 0x87, ["bit"] = 2, ["name"] = "Aztec: Tiny temple Tiny CB (3)", ["type"] = "CB"},
	{["byte"] = 0x87, ["bit"] = 3, ["name"] = "Aztec: Tiny temple Tiny CB (4)", ["type"] = "CB"},
	{["byte"] = 0x87, ["bit"] = 5, ["name"] = "Aztec: Chunky CB: Tiny temple (2)", ["type"] = "CB"},
	{["byte"] = 0x87, ["bit"] = 6, ["name"] = "Aztec: Chunky CB: Tiny temple (3)", ["type"] = "CB"},
	{["byte"] = 0x87, ["bit"] = 7, ["name"] = "Aztec: Chunky CB: Tiny temple (4)", ["type"] = "CB"},

	{["byte"] = 0x89, ["bit"] = 0, ["name"] = "Aztec: Tiny CB: Llama temple (1)", ["type"] = "CB"},
	{["byte"] = 0x89, ["bit"] = 1, ["name"] = "Aztec: Tiny CB: Llama temple (4)", ["type"] = "CB"},
	{["byte"] = 0x89, ["bit"] = 2, ["name"] = "Aztec: Tiny CB: Bunch in Llama temple (1)", ["type"] = "Bunch"},
	{["byte"] = 0x89, ["bit"] = 3, ["name"] = "Aztec: Tiny CB: Bunch in Llama temple (2)", ["type"] = "Bunch"},
	{["byte"] = 0x89, ["bit"] = 5, ["name"] = "Aztec: Tiny Coin: Llama temple (1)", ["type"] = "Coin"},
	{["byte"] = 0x89, ["bit"] = 6, ["name"] = "Aztec: Tiny Coin: Llama temple (2)", ["type"] = "Coin"},
	{["byte"] = 0x89, ["bit"] = 7, ["name"] = "Aztec: Tiny Coin: Llama temple (3)", ["type"] = "Coin"},

	{["byte"] = 0x8A, ["bit"] = 0, ["name"] = "Aztec: DK CB: Llama temple stairs (4)", ["type"] = "CB"},
	{["byte"] = 0x8A, ["bit"] = 1, ["name"] = "Aztec DK Coin: Llama temple Bongo pad (3)", ["type"] = "Coin"},
	{["byte"] = 0x8A, ["bit"] = 2, ["name"] = "Aztec DK Coin: Llama temple Bongo pad (4)", ["type"] = "Coin"},
	{["byte"] = 0x8A, ["bit"] = 3, ["name"] = "Aztec DK Coin: Llama temple Bongo pad (5)", ["type"] = "Coin"},
	{["byte"] = 0x8A, ["bit"] = 4, ["name"] = "Aztec: DK CB: Llama temple Bongo pad (3)", ["type"] = "CB"},
	{["byte"] = 0x8A, ["bit"] = 5, ["name"] = "Aztec: Tiny CB: Llama temple (5)", ["type"] = "CB"},
	{["byte"] = 0x8A, ["bit"] = 6, ["name"] = "Aztec: Tiny CB: Llama temple (2)", ["type"] = "CB"},
	{["byte"] = 0x8A, ["bit"] = 7, ["name"] = "Aztec: Tiny CB: Llama temple (3)", ["type"] = "CB"},

	{["byte"] = 0x8B, ["bit"] = 0, ["name"] = "Aztec: DK CB: Llama temple stairs (5)", ["type"] = "CB"},
	{["byte"] = 0x8B, ["bit"] = 1, ["name"] = "Aztec: DK CB: Llama temple stairs (6)", ["type"] = "CB"},
	{["byte"] = 0x8B, ["bit"] = 2, ["name"] = "Aztec: DK CB: Llama temple stairs (7)", ["type"] = "CB"},
	{["byte"] = 0x8B, ["bit"] = 3, ["name"] = "Aztec: DK CB: Llama temple stairs (8)", ["type"] = "CB"},
	{["byte"] = 0x8B, ["bit"] = 4, ["name"] = "Aztec: DK CB: Llama temple stairs (9)", ["type"] = "CB"},
	{["byte"] = 0x8B, ["bit"] = 5, ["name"] = "Aztec: DK CB: Llama temple stairs (10)", ["type"] = "CB"},
	{["byte"] = 0x8B, ["bit"] = 6, ["name"] = "Aztec: DK CB: Llama temple stairs (11)", ["type"] = "CB"},
	{["byte"] = 0x8B, ["bit"] = 7, ["name"] = "Aztec: DK CB: Llama temple stairs (12)", ["type"] = "CB"},

	{["byte"] = 0x8C, ["bit"] = 0, ["name"] = "Aztec: Diddy CB: Diddytower stairs (1)", ["type"] = "CB"},
	{["byte"] = 0x8C, ["bit"] = 1, ["name"] = "Aztec: Chunky CB: Entrance tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0x8C, ["bit"] = 2, ["name"] = "Aztec: Diddy CB: Diddytower stairs (2)", ["type"] = "CB"},
	{["byte"] = 0x8C, ["bit"] = 3, ["name"] = "Aztec: Tiny CB: Hallway (5)", ["type"] = "CB"},
	{["byte"] = 0x8C, ["bit"] = 4, ["name"] = "Aztec: Tiny CB: Hallway (6)", ["type"] = "CB"},
	{["byte"] = 0x8C, ["bit"] = 5, ["name"] = "Aztec: Tiny CB: Hallway (7)", ["type"] = "CB"},
	{["byte"] = 0x8C, ["bit"] = 6, ["name"] = "Aztec: Chunky CB: Entrance tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0x8C, ["bit"] = 7, ["name"] = "Aztec: Diddy CB: Hallway (1)", ["type"] = "CB"},

	{["byte"] = 0x8D, ["bit"] = 0, ["name"] = "Aztec: Tiny CB: Hallway (2)", ["type"] = "CB"},
	{["byte"] = 0x8D, ["bit"] = 1, ["name"] = "Aztec: Diddy CB: Bunch W2", ["type"] = "Bunch"},
	{["byte"] = 0x8D, ["bit"] = 2, ["name"] = "Aztec: Diddy CB: Hallway (2)", ["type"] = "CB"},
	{["byte"] = 0x8D, ["bit"] = 3, ["name"] = "Aztec: Diddy CB: Hallway (3)", ["type"] = "CB"},
	{["byte"] = 0x8D, ["bit"] = 4, ["name"] = "Aztec: Diddy CB: Hallway (4)", ["type"] = "CB"},
	{["byte"] = 0x8D, ["bit"] = 5, ["name"] = "Aztec: DK CB: BBlast stairs (1)", ["type"] = "CB"},
	{["byte"] = 0x8D, ["bit"] = 6, ["name"] = "Aztec: DK CB: BBlast stairs (2)", ["type"] = "CB"},
	{["byte"] = 0x8D, ["bit"] = 7, ["name"] = "Aztec: DK CB: BBlast stairs (3)", ["type"] = "CB"},

	{["byte"] = 0x8E, ["bit"] = 0, ["name"] = "Aztec: Chunky Coin: 5DT (3)", ["type"] = "Coin"},
	{["byte"] = 0x8E, ["bit"] = 1, ["name"] = "Aztec: Chunky Coin: 5DT (4)", ["type"] = "Coin"},
	{["byte"] = 0x8E, ["bit"] = 4, ["name"] = "Aztec: Lanky Coin: W4 Funky (1)", ["type"] = "Coin"},
	{["byte"] = 0x8E, ["bit"] = 5, ["name"] = "Aztec: DK CB: Bunch in Oasis (1)", ["type"] = "Bunch"},
	{["byte"] = 0x8E, ["bit"] = 6, ["name"] = "Aztec: Diddy Coin: W2 (1)", ["type"] = "Coin"},
	{["byte"] = 0x8E, ["bit"] = 7, ["name"] = "Aztec: Diddy CB: Diddytower stairs (3)", ["type"] = "CB"},

	{["byte"] = 0x8F, ["bit"] = 1, ["name"] = "Aztec: Diddy Coin: 5DT (1)", ["type"] = "Coin"},
	{["byte"] = 0x8F, ["bit"] = 2, ["name"] = "Aztec: Diddy Coin: 5DT (2)", ["type"] = "Coin"},
	{["byte"] = 0x8F, ["bit"] = 3, ["name"] = "Aztec: Tiny Coin: Tiny 5DT (1)", ["type"] = "Coin"},
	{["byte"] = 0x8F, ["bit"] = 4, ["name"] = "Aztec: Tiny Coin: Tiny 5DT (2)", ["type"] = "Coin"},
	{["byte"] = 0x8F, ["bit"] = 5, ["name"] = "Aztec: Tiny Coin: Tiny 5DT (3)", ["type"] = "Coin"},
	{["byte"] = 0x8F, ["bit"] = 6, ["name"] = "Aztec: Chunky Coin: 5DT (1)", ["type"] = "Coin"},
	{["byte"] = 0x8F, ["bit"] = 7, ["name"] = "Aztec: Chunky Coin: 5DT (2)", ["type"] = "Coin"},

	{["byte"] = 0x90, ["bit"] = 0, ["name"] = "Aztec: DK Coin: Llama cage (1)", ["type"] = "Coin"},
	{["byte"] = 0x90, ["bit"] = 1, ["name"] = "Aztec: Diddy Coin: W2 (2)", ["type"] = "Coin"},
	{["byte"] = 0x90, ["bit"] = 2, ["name"] = "Aztec: Diddy Coin: W2 (3)", ["type"] = "Coin"},
	{["byte"] = 0x90, ["bit"] = 3, ["name"] = "Aztec: Diddy Coin: W2 (4)", ["type"] = "Coin"},
	{["byte"] = 0x90, ["bit"] = 7, ["name"] = "Aztec: DK CB: Bunch to W5 (1)", ["type"] = "Bunch"},

	{["byte"] = 0x91, ["bit"] = 0, ["name"] = "Aztec: Chunky CB: Entrance tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0x91, ["bit"] = 1, ["name"] = "Aztec: Tiny CB: Hallway (8)", ["type"] = "CB"},
	{["byte"] = 0x91, ["bit"] = 2, ["name"] = "Aztec: DK Coin: Snide TB (1)", ["type"] = "Coin"},
	{["byte"] = 0x91, ["bit"] = 3, ["name"] = "Aztec: Lanky Coin: W4 Funky (2)", ["type"] = "Coin"},
	{["byte"] = 0x91, ["bit"] = 4, ["name"] = "Aztec: Lanky Coin: W4 Funky (3)", ["type"] = "Coin"},
	{["byte"] = 0x91, ["bit"] = 5, ["name"] = "Aztec: Tiny CB: Hallway (9)", ["type"] = "CB"},
	{["byte"] = 0x91, ["bit"] = 6, ["name"] = "Aztec: DK Coin: Snide TB (2)", ["type"] = "Coin"},
	{["byte"] = 0x91, ["bit"] = 7, ["name"] = "Aztec: DK Coin: Llama cage (2)", ["type"] = "Coin"},

	{["byte"] = 0x92, ["bit"] = 0, ["name"] = "Aztec: DK CB: Bunch in Oasis (2)", ["type"] = "Bunch"},
	{["byte"] = 0x92, ["bit"] = 1, ["name"] = "Aztec: DK CB: Bunch to W5 (2)", ["type"] = "Bunch"},
	{["byte"] = 0x92, ["bit"] = 2, ["name"] = "Aztec: DK CB: Bunch to W5 (3)", ["type"] = "Bunch"},
	{["byte"] = 0x92, ["bit"] = 3, ["name"] = "Aztec: DK CB: Bunch to W5 (4)", ["type"] = "Bunch"},
	{["byte"] = 0x92, ["bit"] = 4, ["name"] = "Aztec: Diddy Coin: W2 (5)", ["type"] = "Coin"},
	{["byte"] = 0x92, ["bit"] = 5, ["name"] = "Aztec: Diddy CB: Hallway (5)", ["type"] = "CB"},
	{["byte"] = 0x92, ["bit"] = 6, ["name"] = "Aztec: Diddy CB: Rocketbarrel stairs (1)", ["type"] = "CB"},
	{["byte"] = 0x92, ["bit"] = 7, ["name"] = "Aztec: DK Coin: Snide TB (3)", ["type"] = "Coin"},

	{["byte"] = 0x93, ["bit"] = 0, ["name"] = "Aztec: Chunky CB: Entrance tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0x93, ["bit"] = 1, ["name"] = "Aztec: Tiny CB: Bunch near gongs", ["type"] = "Bunch"},
	{["byte"] = 0x93, ["bit"] = 2, ["name"] = "Aztec: Diddy CB: Rocketbarrel stairs (2)", ["type"] = "CB"},
	{["byte"] = 0x93, ["bit"] = 3, ["name"] = "Aztec: Lanky CB: Entrance tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0x93, ["bit"] = 4, ["name"] = "Aztec: Lanky CB: Entrance tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0x93, ["bit"] = 5, ["name"] = "Aztec: Lanky CB: Entrance tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0x93, ["bit"] = 6, ["name"] = "Aztec: Lanky CB: Entrance tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0x93, ["bit"] = 7, ["name"] = "Aztec: Lanky CB: Entrance tunnel (5)", ["type"] = "CB"},

	{["byte"] = 0x94, ["bit"] = 0, ["name"] = "Aztec: Diddy CB: Bunch in Totem ring", ["type"] = "Bunch"},
	{["byte"] = 0x94, ["bit"] = 1, ["name"] = "Aztec: Diddy CB: Bunch at Diddytower (1)", ["type"] = "Bunch"},
	{["byte"] = 0x94, ["bit"] = 2, ["name"] = "Aztec: Diddy CB: Bunch at Diddytower (2)", ["type"] = "Bunch"},
	{["byte"] = 0x94, ["bit"] = 3, ["name"] = "Aztec: Diddy CB: Bunch at Diddytower (3)", ["type"] = "Bunch"},
	{["byte"] = 0x94, ["bit"] = 4, ["name"] = "Aztec: Diddy Coin: Hallway (1)", ["type"] = "Coin"},
	{["byte"] = 0x94, ["bit"] = 5, ["name"] = "Aztec: Diddy Coin: Hallway (2)", ["type"] = "Coin"},
	{["byte"] = 0x94, ["bit"] = 6, ["name"] = "Aztec: Diddy Coin: Hallway (3)", ["type"] = "Coin"},

	{["byte"] = 0x95, ["bit"] = 0, ["name"] = "Aztec: Tiny CB: Hallway (3)", ["type"] = "CB"},
	{["byte"] = 0x95, ["bit"] = 1, ["name"] = "Aztec: Tiny CB: Hallway (4)", ["type"] = "CB"},
	{["byte"] = 0x95, ["bit"] = 2, ["name"] = "Aztec: Diddy CB: Rocketbarrel stairs (3)", ["type"] = "CB"},
	{["byte"] = 0x95, ["bit"] = 3, ["name"] = "Aztec: Diddy CB: 5DT stairs (1)", ["type"] = "CB"},
	{["byte"] = 0x95, ["bit"] = 4, ["name"] = "Aztec: Diddy CB: 5DT stairs (2)", ["type"] = "CB"},
	{["byte"] = 0x95, ["bit"] = 5, ["name"] = "Aztec: Diddy CB: 5DT stairs (3)", ["type"] = "CB"},
	{["byte"] = 0x95, ["bit"] = 6, ["name"] = "Aztec: Diddy CB: 5DT stairs (4)", ["type"] = "CB"},
	{["byte"] = 0x95, ["bit"] = 7, ["name"] = "Aztec: Diddy CB: Bunch Llama temple roof", ["type"] = "Bunch"},

	{["byte"] = 0x96, ["bit"] = 0, ["name"] = "Aztec: DK CB: Bunch near BP", ["type"] = "Bunch"},
	{["byte"] = 0x96, ["bit"] = 1, ["name"] = "Aztec: DK CB: Bunch near BP", ["type"] = "Bunch"},
	{["byte"] = 0x96, ["bit"] = 2, ["name"] = "Aztec: DK CB: Bunch in Oasis (3)", ["type"] = "Bunch"},
	{["byte"] = 0x96, ["bit"] = 3, ["name"] = "Aztec: DK Coin: Tunnel to Totem (1)", ["type"] = "Coin"},
	{["byte"] = 0x96, ["bit"] = 4, ["name"] = "Aztec: DK Coin: Tunnel to Totem (2)", ["type"] = "Coin"},
	{["byte"] = 0x96, ["bit"] = 5, ["name"] = "Aztec: DK Coin: Tunnel to Totem (3)", ["type"] = "Coin"},
	{["byte"] = 0x96, ["bit"] = 6, ["name"] = "Aztec: Chunky CB: Entrance tunnel (5)", ["type"] = "CB"},
	{["byte"] = 0x96, ["bit"] = 7, ["name"] = "Aztec: Tiny CB: Hallway (5)", ["type"] = "CB"},

	{["byte"] = 0x97, ["bit"] = 0, ["name"] = "Aztec: Chunky Coin: W5 (1)", ["type"] = "Coin"},
	{["byte"] = 0x97, ["bit"] = 1, ["name"] = "Aztec: Chunky Coin: W5 (2)", ["type"] = "Coin"},
	{["byte"] = 0x97, ["bit"] = 2, ["name"] = "Aztec: Chunky Coin: W5 (3)", ["type"] = "Coin"},
	{["byte"] = 0x97, ["bit"] = 3, ["name"] = "Aztec: Chunky Coin: W5 (4)", ["type"] = "Coin"},
	{["byte"] = 0x97, ["bit"] = 4, ["name"] = "Aztec: DK CB: BBlast stairs (4)", ["type"] = "CB"},
	{["byte"] = 0x97, ["bit"] = 5, ["name"] = "Aztec: DK CB: Snide stairs (1)", ["type"] = "CB"},
	{["byte"] = 0x97, ["bit"] = 6, ["name"] = "Aztec: DK CB: Snide stairs (2)", ["type"] = "CB"},
	{["byte"] = 0x97, ["bit"] = 7, ["name"] = "Aztec: DK CB: Snide stairs (3)", ["type"] = "CB"},

	{["byte"] = 0x98, ["bit"] = 0, ["name"] = "Aztec: Lanky CB: Bunch by Diddytower", ["type"] = "Bunch"},
	{["byte"] = 0x98, ["bit"] = 1, ["name"] = "Aztec: Lanky CB: Bunch by Cranky", ["type"] = "Bunch"},
	{["byte"] = 0x98, ["bit"] = 2, ["name"] = "Aztec: Lanky Coin: Behind 5DT (1)", ["type"] = "Coin"},
	{["byte"] = 0x98, ["bit"] = 3, ["name"] = "Aztec: Lanky Coin: Behind 5DT (2)", ["type"] = "Coin"},
	{["byte"] = 0x98, ["bit"] = 4, ["name"] = "Aztec: Tiny Coin: Oasis (1)", ["type"] = "Coin"},
	{["byte"] = 0x98, ["bit"] = 5, ["name"] = "Aztec: Chunky CB: Totem (1)", ["type"] = "CB"},
	{["byte"] = 0x98, ["bit"] = 6, ["name"] = "Aztec: Chunky CB: Totem (2)", ["type"] = "CB"},
	{["byte"] = 0x98, ["bit"] = 7, ["name"] = "Aztec: Chunky CB: Totem (3)", ["type"] = "CB"},

	{["byte"] = 0x99, ["bit"] = 0, ["name"] = "Aztec: Lanky CB: Cranky's (1)", ["type"] = "CB"},
	{["byte"] = 0x99, ["bit"] = 1, ["name"] = "Aztec: Lanky Coin: W4 Funky (4)", ["type"] = "Coin"},
	{["byte"] = 0x99, ["bit"] = 2, ["name"] = "Aztec: Tiny Coin: Hunky Chunky barrel (1)", ["type"] = "Coin"},
	{["byte"] = 0x99, ["bit"] = 3, ["name"] = "Aztec: Tiny Coin: Hunky Chunky barrel (2)", ["type"] = "Coin"},
	{["byte"] = 0x99, ["bit"] = 4, ["name"] = "Aztec: Lanky CB: Bunch by Totem ", ["type"] = "Bunch"},
	{["byte"] = 0x99, ["bit"] = 5, ["name"] = "Aztec: Lanky CB: Bunch by 5DT", ["type"] = "Bunch"},
	{["byte"] = 0x99, ["bit"] = 6, ["name"] = "Aztec: Lanky CB: Bunch by Llama temple (1)", ["type"] = "Bunch"},
	{["byte"] = 0x99, ["bit"] = 7, ["name"] = "Aztec: Lanky CB: Bunch by Llama temple (2)", ["type"] = "Bunch"},

	{["byte"] = 0x9A, ["bit"] = 0, ["name"] = "Aztec: Tiny CB: Bunch near 5DT (1)", ["type"] = "Bunch"},
	{["byte"] = 0x9A, ["bit"] = 1, ["name"] = "Aztec: Tiny CB: Bunch near 5DT (2)", ["type"] = "Bunch"},
	{["byte"] = 0x9A, ["bit"] = 2, ["name"] = "Aztec: Tiny CB: Bunch near 5DT (2)", ["type"] = "Bunch"},
	{["byte"] = 0x9A, ["bit"] = 3, ["name"] = "Aztec: Chunky Coin: Vulture cage (1)", ["type"] = "Coin"},
	{["byte"] = 0x9A, ["bit"] = 4, ["name"] = "Aztec: Lanky CB: Cranky's (2)", ["type"] = "CB"},
	{["byte"] = 0x9A, ["bit"] = 5, ["name"] = "Aztec: Lanky CB: Cranky's (3)", ["type"] = "CB"},
	{["byte"] = 0x9A, ["bit"] = 6, ["name"] = "Aztec: Lanky CB: Cranky's (4)", ["type"] = "CB"},
	{["byte"] = 0x9A, ["bit"] = 7, ["name"] = "Aztec: Lanky CB: Cranky's (5)", ["type"] = "CB"},

	{["byte"] = 0x9B, ["bit"] = 0, ["name"] = "Aztec: Tiny CB: Path to 5DT (1)", ["type"] = "CB"},
	{["byte"] = 0x9B, ["bit"] = 1, ["name"] = "Aztec: Tiny CB: Path to 5DT (2)", ["type"] = "CB"},
	{["byte"] = 0x9B, ["bit"] = 2, ["name"] = "Aztec: Tiny CB: Path to 5DT (3)", ["type"] = "CB"},
	{["byte"] = 0x9B, ["bit"] = 3, ["name"] = "Aztec: Tiny CB: Path to 5DT (4)", ["type"] = "CB"},
	{["byte"] = 0x9B, ["bit"] = 4, ["name"] = "Aztec: Tiny CB: Path to 5DT (5)", ["type"] = "CB"},
	{["byte"] = 0x9B, ["bit"] = 5, ["name"] = "Aztec: Tiny CB: Bunch W5", ["type"] = "Bunch"},
	{["byte"] = 0x9B, ["bit"] = 6, ["name"] = "Aztec: Tiny CB: Bunch near 5DT (3)", ["type"] = "Bunch"},
	{["byte"] = 0x9B, ["bit"] = 7, ["name"] = "Aztec: Tiny CB: Bunch near 5DT (4)", ["type"] = "Bunch"},

	{["byte"] = 0x9C, ["bit"] = 0, ["name"] = "Aztec: Tiny Coin: Oasis (2)", ["type"] = "Coin"},
	{["byte"] = 0x9C, ["bit"] = 4, ["name"] = "Aztec: Tiny Coin: Hunky Chunky barrel (3)", ["type"] = "Coin"},
	{["byte"] = 0x9C, ["bit"] = 5, ["name"] = "Aztec: Tiny Coin: W5 (1)", ["type"] = "Coin"},
	{["byte"] = 0x9C, ["bit"] = 6, ["name"] = "Aztec: Tiny Coin: W5 (2)", ["type"] = "Coin"},
	{["byte"] = 0x9C, ["bit"] = 7, ["name"] = "Aztec: Tiny Coin: W5 (3)", ["type"] = "Coin"},

	{["byte"] = 0x9D, ["bit"] = 0, ["name"] = "Aztec: Chunky CB: Snide stairs (1)", ["type"] = "CB"},
	{["byte"] = 0x9D, ["bit"] = 1, ["name"] = "Aztec: Chunky CB: Snide stairs (2)", ["type"] = "CB"},
	{["byte"] = 0x9D, ["bit"] = 2, ["name"] = "Aztec: Chunky CB: Snide stairs (3)", ["type"] = "CB"},
	{["byte"] = 0x9D, ["bit"] = 3, ["name"] = "Aztec: Chunky Coin: Vulture cage (2)", ["type"] = "Coin"},
	{["byte"] = 0x9D, ["bit"] = 4, ["name"] = "Aztec: Tiny Coin: Oasis (3)", ["type"] = "Coin"},
	{["byte"] = 0x9D, ["bit"] = 5, ["name"] = "Aztec: Tiny Coin: Oasis (4)", ["type"] = "Coin"},
	{["byte"] = 0x9D, ["bit"] = 6, ["name"] = "Aztec: Lanky Coin: Behind 5DT (3)", ["type"] = "Coin"},
	{["byte"] = 0x9D, ["bit"] = 7, ["name"] = "Aztec: Lanky Coin: W4 Funky (5)", ["type"] = "Coin"},

	{["byte"] = 0x9E, ["bit"] = 0, ["name"] = "Aztec: Chunky CB: Bunch vase room (1)", ["type"] = "Bunch"},
	{["byte"] = 0x9E, ["bit"] = 1, ["name"] = "Aztec: Chunky CB: Bunch vase room (2)", ["type"] = "Bunch"},
	{["byte"] = 0x9E, ["bit"] = 2, ["name"] = "Aztec: Chunky CB: Bunch vase room (3)", ["type"] = "Bunch"},
	{["byte"] = 0x9E, ["bit"] = 3, ["name"] = "Aztec: Chunky Coin: Vulture cage (3)", ["type"] = "Coin"},
	{["byte"] = 0x9E, ["bit"] = 4, ["name"] = "Aztec: Chunky Coin: Vulture cage (4)", ["type"] = "Coin"},
	{["byte"] = 0x9E, ["bit"] = 5, ["name"] = "Aztec: Chunky CB: Snide stairs (4)", ["type"] = "CB"},
	{["byte"] = 0x9E, ["bit"] = 6, ["name"] = "Aztec: Chunky CB: Snide stairs (5)", ["type"] = "CB"},
	{["byte"] = 0x9E, ["bit"] = 7, ["name"] = "Aztec: Chunky CB: Snide stairs (6)", ["type"] = "CB"},

	{["byte"] = 0x9F, ["bit"] = 0, ["name"] = "Aztec: Chunky CB: Totem (4)", ["type"] = "CB"},
	{["byte"] = 0x9F, ["bit"] = 1, ["name"] = "Aztec: Chunky CB: Totem (5)", ["type"] = "CB"},
	{["byte"] = 0x9F, ["bit"] = 2, ["name"] = "Aztec: Chunky CB: Totem (6)", ["type"] = "CB"},
	{["byte"] = 0x9F, ["bit"] = 3, ["name"] = "Aztec: Chunky CB: Totem (7)", ["type"] = "CB"},
	{["byte"] = 0x9F, ["bit"] = 4, ["name"] = "Aztec: Chunky CB: Totem (8)", ["type"] = "CB"},
	{["byte"] = 0x9F, ["bit"] = 5, ["name"] = "Aztec: Chunky CB: Totem (9)", ["type"] = "CB"},
	{["byte"] = 0x9F, ["bit"] = 6, ["name"] = "Aztec: Chunky CB: Totem (10)", ["type"] = "CB"},
	{["byte"] = 0x9F, ["bit"] = 7, ["name"] = "Aztec: Chunky CB: Bunch vase room (4)", ["type"] = "Bunch"},

	{["byte"] = 0xA0, ["bit"] = 0, ["name"] = "Factory: DK CB: Tunnel to Production room (1)", ["type"] = "CB"},
	{["byte"] = 0xA0, ["bit"] = 1, ["name"] = "Factory: DK CB: Tunnel to Production room (2)", ["type"] = "CB"},
	{["byte"] = 0xA0, ["bit"] = 2, ["name"] = "Factory: DK CB: Tunnel to Production room (3)", ["type"] = "CB"},
	{["byte"] = 0xA0, ["bit"] = 3, ["name"] = "Factory: DK CB: Hatch tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xA0, ["bit"] = 4, ["name"] = "Factory: DK CB: Hatch tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xA0, ["bit"] = 5, ["name"] = "Factory: DK CB: Storage room tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xA0, ["bit"] = 6, ["name"] = "Factory: DK CB: Numbers Tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xA0, ["bit"] = 7, ["name"] = "Factory: DK CB: Numbers Tunnel (2)", ["type"] = "CB"},

	{["byte"] = 0xA1, ["bit"] = 0, ["name"] = "Factory: DK Coin: R&D Lever (1)", ["type"] = "Coin"},
	{["byte"] = 0xA1, ["bit"] = 1, ["name"] = "Factory: DK Coin: R&D Lever (2)", ["type"] = "Coin"},
	{["byte"] = 0xA1, ["bit"] = 2, ["name"] = "Factory: Chunky CB: Production room (1)", ["type"] = "Bunch"},
	{["byte"] = 0xA1, ["bit"] = 3, ["name"] = "Factory: Chunky CB: Dark Room Bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xA1, ["bit"] = 4, ["name"] = "Factory: Chunky CB: Dark Room Bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xA1, ["bit"] = 5, ["name"] = "Factory: DK CB: Storage room tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xA1, ["bit"] = 6, ["name"] = "Factory: DK CB: Tunnel to Production room (4)", ["type"] = "CB"},
	{["byte"] = 0xA1, ["bit"] = 7, ["name"] = "Factory: DK CB: Tunnel to Production room (5)", ["type"] = "CB"},

	{["byte"] = 0xA2, ["bit"] = 0, ["name"] = "Aztec: DK Coin: Near BP (1)", ["type"] = "Coin"},
	{["byte"] = 0xA2, ["bit"] = 1, ["name"] = "Factory: DK CB: Tunnel to Production room (6)", ["type"] = "CB"},
	{["byte"] = 0xA2, ["bit"] = 2, ["name"] = "Factory: Diddy Coin: Storage room (1)", ["type"] = "Coin"},
	{["byte"] = 0xA2, ["bit"] = 3, ["name"] = "Factory: Chunky Coin: Snide's (1)", ["type"] = "Coin"},
	{["byte"] = 0xA2, ["bit"] = 4, ["name"] = "Factory: Chunky CB: Production room (2)", ["type"] = "CB"},
	{["byte"] = 0xA2, ["bit"] = 5, ["name"] = "Factory: DK Coin: Testing Room Stairs (1)", ["type"] = "Coin"},
	{["byte"] = 0xA2, ["bit"] = 6, ["name"] = "Factory: DK Coin: Testing Room Stairs (2)", ["type"] = "Coin"},
	{["byte"] = 0xA2, ["bit"] = 7, ["name"] = "Factory: DK Coin: R&D Lever (3)", ["type"] = "Coin"},

	{["byte"] = 0xA3, ["bit"] = 0, ["name"] = "Aztec: Tiny Coin: W5 (4)", ["type"] = "Coin"},
	{["byte"] = 0xA3, ["bit"] = 1, ["name"] = "Aztec: Tiny Coin: W5 (5)", ["type"] = "Coin"},
	{["byte"] = 0xA3, ["bit"] = 2, ["name"] = "Aztec: Chunky Coin: Outside Tiny temple (1)", ["type"] = "Coin"},
	{["byte"] = 0xA3, ["bit"] = 3, ["name"] = "Aztec: Chunky Coin: Outside Tiny temple (2)", ["type"] = "Coin"},
	{["byte"] = 0xA3, ["bit"] = 4, ["name"] = "Aztec: Chunky Coin: Outside Tiny temple (3)", ["type"] = "Coin"},
	{["byte"] = 0xA3, ["bit"] = 5, ["name"] = "Aztec: Chunky Coin: Outside Tiny temple (4)", ["type"] = "Coin"},
	{["byte"] = 0xA3, ["bit"] = 6, ["name"] = "Aztec: DK Coin: Near BP (2)", ["type"] = "Coin"},
	{["byte"] = 0xA3, ["bit"] = 7, ["name"] = "Aztec: DK Coin: Near BP (3)", ["type"] = "Coin"},

	{["byte"] = 0xA4, ["bit"] = 0, ["name"] = "Factory: DK Coin: Shaft window (1)", ["type"] = "Coin"},
	{["byte"] = 0xA4, ["bit"] = 1, ["name"] = "Factory: DK Coin: Shaft window (2)", ["type"] = "Coin"},
	{["byte"] = 0xA4, ["bit"] = 2, ["name"] = "Factory: Diddy CB: Low W4 (1)", ["type"] = "CB"},
	{["byte"] = 0xA4, ["bit"] = 3, ["name"] = "Factory: Diddy CB: Low W4 (2)", ["type"] = "CB"},
	{["byte"] = 0xA4, ["bit"] = 4, ["name"] = "Factory: Diddy CB: Low W4 (3)", ["type"] = "CB"},
	{["byte"] = 0xA4, ["bit"] = 5, ["name"] = "Factory: Diddy CB: Low W4 (4)", ["type"] = "CB"},
	{["byte"] = 0xA4, ["bit"] = 6, ["name"] = "Factory: Diddy CB: Low W4 (5)", ["type"] = "CB"},

	{["byte"] = 0xA5, ["bit"] = 0, ["name"] = "Factory: DK CB: Numbers Tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xA5, ["bit"] = 1, ["name"] = "Factory: DK CB: Storage room tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xA5, ["bit"] = 2, ["name"] = "Factory: Chunky Coin: W1 (Storage Room) (1)", ["type"] = "Coin"},
	{["byte"] = 0xA5, ["bit"] = 3, ["name"] = "Factory: DK CB: Hatch tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xA5, ["bit"] = 4, ["name"] = "Factory: DK CB: Hatch tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xA5, ["bit"] = 5, ["name"] = "Factory: Chunky Coin: W1 (Storage Room) (2)", ["type"] = "Coin"},
	{["byte"] = 0xA5, ["bit"] = 6, ["name"] = "Factory: Diddy CB: Low W4 (6)", ["type"] = "CB"},
	{["byte"] = 0xA5, ["bit"] = 7, ["name"] = "Factory: DK Coin: Shaft window (3)", ["type"] = "Coin"},

	{["byte"] = 0xA6, ["bit"] = 0, ["name"] = "Factory: DK CB: Numbers Tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xA6, ["bit"] = 1, ["name"] = "Factory: Diddy CB: Arcade Tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xA6, ["bit"] = 2, ["name"] = "Factory: Diddy CB: Arcade Tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xA6, ["bit"] = 3, ["name"] = "Factory: Diddy CB: Arcade Tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xA6, ["bit"] = 4, ["name"] = "Factory: Chunky Coin: W1 (Storage Room) (3)", ["type"] = "Coin"},
	{["byte"] = 0xA6, ["bit"] = 5, ["name"] = "Factory: Chunky Coin: W1 (Storage Room) (4)", ["type"] = "Coin"},
	{["byte"] = 0xA6, ["bit"] = 6, ["name"] = "Factory: DK CB: Hatch tunnel (5)", ["type"] = "CB"},
	{["byte"] = 0xA6, ["bit"] = 7, ["name"] = "Factory: DK Coin: Testing Room Stairs (3)", ["type"] = "Coin"},

	{["byte"] = 0xA7, ["bit"] = 0, ["name"] = "Factory: Diddy CB: Low W4 (7)", ["type"] = "CB"},
	{["byte"] = 0xA7, ["bit"] = 1, ["name"] = "Factory: Diddy CB: Low W4 (8)", ["type"] = "CB"},
	{["byte"] = 0xA7, ["bit"] = 2, ["name"] = "Factory: Diddy CB: Low W4 (9)", ["type"] = "CB"},
	{["byte"] = 0xA7, ["bit"] = 3, ["name"] = "Factory: Diddy CB: Low W4 (10)", ["type"] = "CB"},
	{["byte"] = 0xA7, ["bit"] = 4, ["name"] = "Factory: Diddy CB: Low W4 (11)", ["type"] = "CB"},
	{["byte"] = 0xA7, ["bit"] = 5, ["name"] = "Factory: Diddy CB: Arcade Tunnel (5)", ["type"] = "CB"},
	{["byte"] = 0xA7, ["bit"] = 7, ["name"] = "Factory: DK CB: Numbers Tunnel (5)", ["type"] = "CB"},

	{["byte"] = 0xA8, ["bit"] = 0, ["name"] = "Factory: Tiny Coin: BP (1)", ["type"] = "Coin"},
	{["byte"] = 0xA8, ["bit"] = 1, ["name"] = "Factory: Tiny Coin: BP (2)", ["type"] = "Coin"},
	{["byte"] = 0xA8, ["bit"] = 2, ["name"] = "Factory: Diddy Coin: Drop to Powershed (1)", ["type"] = "Coin"},
	{["byte"] = 0xA8, ["bit"] = 3, ["name"] = "Factory: Diddy Coin: Drop to Powershed (2)", ["type"] = "Coin"},
	{["byte"] = 0xA8, ["bit"] = 4, ["name"] = "Factory: Lanky CB: R&D (1)", ["type"] = "CB"},
	{["byte"] = 0xA8, ["bit"] = 5, ["name"] = "Factory: Tiny CB: Foyer Tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xA8, ["bit"] = 6, ["name"] = "Factory: Tiny CB: Foyer Tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xA8, ["bit"] = 7, ["name"] = "Factory: Tiny CB: Foyer Tunnel (3)", ["type"] = "CB"},

	{["byte"] = 0xA9, ["bit"] = 0, ["name"] = "Factory: Diddy Coin: Drop to Powershed(3)", ["type"] = "Coin"},
	{["byte"] = 0xA9, ["bit"] = 1, ["name"] = "Factory: Chunky Coin: Hatch(1)", ["type"] = "Coin"},
	{["byte"] = 0xA9, ["bit"] = 2, ["name"] = "Factory: Tiny Coin: BP (3)", ["type"] = "Coin"},
	{["byte"] = 0xA9, ["bit"] = 3, ["name"] = "Factory: Tiny Coin: BP (4)", ["type"] = "Coin"},
	{["byte"] = 0xA9, ["bit"] = 4, ["name"] = "Factory: Lanky CB: R&D (2)", ["type"] = "CB"},
	{["byte"] = 0xA9, ["bit"] = 5, ["name"] = "Factory: Tiny Coin: Zinger Pole (1)", ["type"] = "Coin"},
	{["byte"] = 0xA9, ["bit"] = 6, ["name"] = "Factory: Lanky CB: R&D (3)", ["type"] = "CB"},
	{["byte"] = 0xA9, ["bit"] = 7, ["name"] = "Factory: Tiny Coin: Zinger Pole (2)", ["type"] = "Coin"},

	{["byte"] = 0xAA, ["bit"] = 0, ["name"] = "Factory: Diddy CB: Blocker Tower Bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xAA, ["bit"] = 1, ["name"] = "Factory: Diddy CB: W5 Bunch (Arcade)", ["type"] = "Bunch"},
	{["byte"] = 0xAA, ["bit"] = 2, ["name"] = "Factory: Diddy CB: W5 Bunch (Funky)", ["type"] = "Bunch"},
	{["byte"] = 0xAA, ["bit"] = 3, ["name"] = "Factory: Diddy CB: Prodution room (1)", ["type"] = "Bunch"},
	{["byte"] = 0xAA, ["bit"] = 4, ["name"] = "Factory: Diddy CB: Prodution room (2)", ["type"] = "Bunch"},
	{["byte"] = 0xAA, ["bit"] = 5, ["name"] = "Factory: Diddy CB: Prodution room (3)", ["type"] = "Bunch"},
	{["byte"] = 0xAA, ["bit"] = 6, ["name"] = "Factory: Diddy Coin: Drop to Powershed (4)", ["type"] = "Coin"},
	{["byte"] = 0xAA, ["bit"] = 7, ["name"] = "Factory: Diddy Coin: Drop to Powershed (5)", ["type"] = "Coin"},

	{["byte"] = 0xAB, ["bit"] = 0, ["name"] = "Factory: Diddy CB: Funky Tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xAB, ["bit"] = 1, ["name"] = "Factory: Diddy CB: Funky Tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xAB, ["bit"] = 2, ["name"] = "Factory: Diddy CB: Funky Tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xAB, ["bit"] = 3, ["name"] = "Factory: Diddy CB: Low W4 (12)", ["type"] = "CB"},
	{["byte"] = 0xAB, ["bit"] = 4, ["name"] = "Factory: Diddy CB: Blocker Tower Bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xAB, ["bit"] = 5, ["name"] = "Factory: Diddy CB: Blocker Tower Bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0xAB, ["bit"] = 6, ["name"] = "Factory: Diddy CB: Blocker Tower Bunch (4)", ["type"] = "Bunch"},
	{["byte"] = 0xAB, ["bit"] = 7, ["name"] = "Factory: Diddy CB: Blocker Tower Bunch (5)", ["type"] = "Bunch"},

	{["byte"] = 0xAC, ["bit"] = 0, ["name"] = "Factory: Tiny CB: Bad Hit Detection Wheel (1)", ["type"] = "Bunch"},
	{["byte"] = 0xAC, ["bit"] = 1, ["name"] = "Factory: Tiny CB: Window Bunch (Left)", ["type"] = "Bunch"},
	{["byte"] = 0xAC, ["bit"] = 2, ["name"] = "Factory: Tiny CB: Window Bunch (Right)", ["type"] = "Bunch"},
	{["byte"] = 0xAC, ["bit"] = 3, ["name"] = "Factory: Tiny Coin: Zinger Pole (3)", ["type"] = "Coin"},
	{["byte"] = 0xAC, ["bit"] = 4, ["name"] = "Factory: Tiny Coin: Zinger Pole (4)", ["type"] = "Coin"},
	{["byte"] = 0xAC, ["bit"] = 5, ["name"] = "Factory: Lanky CB: R&D (4)", ["type"] = "CB"},
	{["byte"] = 0xAC, ["bit"] = 6, ["name"] = "Factory: Lanky CB: R&D (5)", ["type"] = "CB"},
	{["byte"] = 0xAC, ["bit"] = 7, ["name"] = "Factory: Tiny Coin: Zinger Pole (5)", ["type"] = "Coin"},

	{["byte"] = 0xAD, ["bit"] = 0, ["name"] = "Factory: Tiny CB: R&D Tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xAD, ["bit"] = 1, ["name"] = "Factory: Tiny CB: Bad Hit Detection Wheel (2)", ["type"] = "Bunch"},
	{["byte"] = 0xAD, ["bit"] = 2, ["name"] = "Factory: Tiny CB: Bunch Production room (1)", ["type"] = "Bunch"},
	{["byte"] = 0xAD, ["bit"] = 3, ["name"] = "Factory: Tiny CB: Bunch Production room (2)", ["type"] = "Bunch"},
	{["byte"] = 0xAD, ["bit"] = 4, ["name"] = "Factory: Tiny CB: Bunch Production room (3)", ["type"] = "Bunch"},
	{["byte"] = 0xAD, ["bit"] = 5, ["name"] = "Factory: Tiny CB: Bunch Production room (4)", ["type"] = "Bunch"},
	{["byte"] = 0xAD, ["bit"] = 6, ["name"] = "Factory: Tiny CB: Bunch Production room (5)", ["type"] = "Bunch"},
	{["byte"] = 0xAD, ["bit"] = 7, ["name"] = "Factory: Tiny CB: Arcade Bunch", ["type"] = "Bunch"},

	{["byte"] = 0xAE, ["bit"] = 0, ["name"] = "Factory: Tiny CB: R&D Tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xAE, ["bit"] = 1, ["name"] = "Factory: Tiny CB: R&D Tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xAE, ["bit"] = 2, ["name"] = "Factory: Tiny CB: R&D Tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xAE, ["bit"] = 3, ["name"] = "Factory: Tiny CB: R&D Tunnel (5)", ["type"] = "CB"},
	{["byte"] = 0xAE, ["bit"] = 4, ["name"] = "Factory: Tiny CB: R&D Tunnel (6)", ["type"] = "CB"},
	{["byte"] = 0xAE, ["bit"] = 5, ["name"] = "Factory: Tiny CB: R&D Tunnel (7)", ["type"] = "CB"},
	{["byte"] = 0xAE, ["bit"] = 6, ["name"] = "Factory: Tiny CB: R&D Tunnel (8)", ["type"] = "CB"},
	{["byte"] = 0xAE, ["bit"] = 7, ["name"] = "Factory: Tiny CB: R&D Tunnel (9)", ["type"] = "CB"},

	{["byte"] = 0xAF, ["bit"] = 0, ["name"] = "Factory: Tiny CB: Testing Room Tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xAF, ["bit"] = 1, ["name"] = "Factory: Tiny CB: Testing Room Tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xAF, ["bit"] = 2, ["name"] = "Factory: Tiny CB: Testing Room Tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xAF, ["bit"] = 3, ["name"] = "Factory: Tiny CB: Testing Room Tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xAF, ["bit"] = 4, ["name"] = "Factory: Tiny CB: Testing Room Tunnel (5)", ["type"] = "CB"},
	{["byte"] = 0xAF, ["bit"] = 5, ["name"] = "Factory: Tiny CB: Testing Room Tunnel (6)", ["type"] = "CB"},
	{["byte"] = 0xAF, ["bit"] = 6, ["name"] = "Factory: Tiny CB: Testing Room Tunnel (7)", ["type"] = "CB"},
	{["byte"] = 0xAF, ["bit"] = 7, ["name"] = "Factory: Tiny CB: R&D Tunnel (10)", ["type"] = "CB"},

	{["byte"] = 0xB0, ["bit"] = 0, ["name"] = "Factory: Lanky Coin: R&D Pole (1)", ["type"] = "Coin"},
	{["byte"] = 0xB0, ["bit"] = 1, ["name"] = "Factory: Lanky CB: Cranky and Candy Area (1)", ["type"] = "CB"},
	{["byte"] = 0xB0, ["bit"] = 2, ["name"] = "Factory: Lanky CB: Cranky and Candy Area (2)", ["type"] = "CB"},
	{["byte"] = 0xB0, ["bit"] = 3, ["name"] = "Factory: Lanky CB: Cranky and Candy Area (3)", ["type"] = "CB"},
	{["byte"] = 0xB0, ["bit"] = 4, ["name"] = "Factory: Lanky CB: Cranky and Candy Area (4)", ["type"] = "CB"},
	{["byte"] = 0xB0, ["bit"] = 5, ["name"] = "Factory: Lanky CB: Cranky and Candy Area (5)", ["type"] = "CB"},
	{["byte"] = 0xB0, ["bit"] = 6, ["name"] = "Factory: Lanky CB: Storage Room Pipe (1)", ["type"] = "CB"},
	{["byte"] = 0xB0, ["bit"] = 7, ["name"] = "Factory: Lanky CB: Storage Room Pipe (2)", ["type"] = "CB"},

	{["byte"] = 0xB1, ["bit"] = 0, ["name"] = "Factory: Tiny Coin: BP (5)", ["type"] = "Coin"},
	{["byte"] = 0xB1, ["bit"] = 1, ["name"] = "Factory: Diddy Coin: R&D Pole (1)", ["type"] = "Coin"},
	{["byte"] = 0xB1, ["bit"] = 2, ["name"] = "Factory: Diddy Coin: R&D Pole (2)", ["type"] = "Coin"},
	{["byte"] = 0xB1, ["bit"] = 3, ["name"] = "Factory: Diddy Coin: R&D Pole (3)", ["type"] = "Coin"},
	{["byte"] = 0xB1, ["bit"] = 4, ["name"] = "Factory: Lanky Coin: R&D Pole (2)", ["type"] = "Coin"},
	{["byte"] = 0xB1, ["bit"] = 5, ["name"] = "Factory: Lanky Coin: R&D Pole (3)", ["type"] = "Coin"},
	{["byte"] = 0xB1, ["bit"] = 6, ["name"] = "Factory: Lanky Coin: R&D Pole (4)", ["type"] = "Coin"},
	{["byte"] = 0xB1, ["bit"] = 7, ["name"] = "Factory: Lanky Coin: R&D Pole (5)", ["type"] = "Coin"},

	{["byte"] = 0xB2, ["bit"] = 0, ["name"] = "Factory: Tiny Coin: High W4 (1)", ["type"] = "Coin"},
	{["byte"] = 0xB2, ["bit"] = 1, ["name"] = "Factory: Tiny Coin: High W4 (2)", ["type"] = "Coin"},
	{["byte"] = 0xB2, ["bit"] = 2, ["name"] = "Factory: Lanky CB: R&D (6)", ["type"] = "CB"},
	{["byte"] = 0xB2, ["bit"] = 3, ["name"] = "Factory: Lanky CB: R&D (7)", ["type"] = "CB"},
	{["byte"] = 0xB2, ["bit"] = 4, ["name"] = "Factory: Lanky CB: R&D (8)", ["type"] = "CB"},
	{["byte"] = 0xB2, ["bit"] = 5, ["name"] = "Factory: Lanky CB: R&D (9)", ["type"] = "CB"},
	{["byte"] = 0xB2, ["bit"] = 6, ["name"] = "Factory: Lanky CB: R&D (10)", ["type"] = "CB"},
	{["byte"] = 0xB2, ["bit"] = 7, ["name"] = "Factory: Diddy Coin: R&D Pole (4)", ["type"] = "Coin"},

	{["byte"] = 0xB3, ["bit"] = 0, ["name"] = "Factory: Diddy Coin: Pole Above Snide's (1)", ["type"] = "Coin"},
	{["byte"] = 0xB3, ["bit"] = 1, ["name"] = "Factory: Diddy Coin: Pole Above Snide's (2)", ["type"] = "Coin"},
	{["byte"] = 0xB3, ["bit"] = 2, ["name"] = "Factory: Diddy Coin: Pole Above Snide's (3)", ["type"] = "Coin"},
	{["byte"] = 0xB3, ["bit"] = 3, ["name"] = "Factory: Diddy Coin: Pole Above Snide's (4)", ["type"] = "Coin"},
	{["byte"] = 0xB3, ["bit"] = 4, ["name"] = "Factory: Diddy Coin: Pole Above Snide's (5)", ["type"] = "Coin"},
	{["byte"] = 0xB3, ["bit"] = 5, ["name"] = "Factory: Tiny Coin: High W4 (3)", ["type"] = "Coin"},
	{["byte"] = 0xB3, ["bit"] = 6, ["name"] = "Factory: Tiny Coin: High W4 (4)", ["type"] = "Coin"},
	{["byte"] = 0xB3, ["bit"] = 7, ["name"] = "Factory: Tiny Coin: High W4 (5)", ["type"] = "Coin"},

	{["byte"] = 0xB4, ["bit"] = 0, ["name"] = "Factory: Chunky CB: Hatch pole (1)", ["type"] = "Coin"},
	{["byte"] = 0xB4, ["bit"] = 1, ["name"] = "Factory: Chunky CB: Hatch pole (2)", ["type"] = "Coin"},
	{["byte"] = 0xB4, ["bit"] = 2, ["name"] = "Factory: Chunky CB: Hatch pole (3)", ["type"] = "Coin"},
	{["byte"] = 0xB4, ["bit"] = 3, ["name"] = "Factory: Chunky CB: Hatch pole (4)", ["type"] = "Coin"},
	{["byte"] = 0xB4, ["bit"] = 4, ["name"] = "Factory: Chunky CB: Hatch pole (5)", ["type"] = "Coin"},
	{["byte"] = 0xB4, ["bit"] = 5, ["name"] = "Factory: Chunky CB: Hatch pole (6)", ["type"] = "Coin"},
	{["byte"] = 0xB4, ["bit"] = 6, ["name"] = "Factory: Chunky CB: Toy monster (1)", ["type"] = "CB"},
	{["byte"] = 0xB4, ["bit"] = 7, ["name"] = "Factory: Chunky CB: Toy monster (2)", ["type"] = "CB"},

	{["byte"] = 0xB5, ["bit"] = 0, ["name"] = "Factory: Lanky Coin: Testing Room Boxes (1)", ["type"] = "Coin"},
	{["byte"] = 0xB5, ["bit"] = 1, ["name"] = "Factory: Lanky Coin: Testing Room Boxes (2)", ["type"] = "Coin"},
	{["byte"] = 0xB5, ["bit"] = 2, ["name"] = "Factory: Lanky Coin: Testing Room Boxes (3)", ["type"] = "Coin"},
	{["byte"] = 0xB5, ["bit"] = 3, ["name"] = "Factory: Lanky Coin: Testing Room Boxes (4)", ["type"] = "Coin"},
	{["byte"] = 0xB5, ["bit"] = 4, ["name"] = "Factory: Chunky CB: Hatch pole (7)", ["type"] = "Coin"},
	{["byte"] = 0xB5, ["bit"] = 5, ["name"] = "Factory: Chunky CB: Hatch pole (8)", ["type"] = "Coin"},
	{["byte"] = 0xB5, ["bit"] = 6, ["name"] = "Factory: Chunky CB: Hatch pole (9)", ["type"] = "Coin"},
	{["byte"] = 0xB5, ["bit"] = 7, ["name"] = "Factory: Chunky CB: Hatch pole (10)", ["type"] = "Coin"},

	{["byte"] = 0xB6, ["bit"] = 0, ["name"] = "Factory: Lanky CB: Production room (1)", ["type"] = "Bunch"},
	{["byte"] = 0xB6, ["bit"] = 1, ["name"] = "Factory: Lanky CB: Production room (2)", ["type"] = "Bunch"},
	{["byte"] = 0xB6, ["bit"] = 2, ["name"] = "Factory: Lanky CB: Production room (3)", ["type"] = "Bunch"},
	{["byte"] = 0xB6, ["bit"] = 3, ["name"] = "Factory: Lanky CB: W2 Bunch", ["type"] = "Bunch"},
	{["byte"] = 0xB6, ["bit"] = 4, ["name"] = "Factory: Lanky CB: R&D Bunch", ["type"] = "Bunch"},
	{["byte"] = 0xB6, ["bit"] = 5, ["name"] = "Factory: Lanky Coin: Production room (1)", ["type"] = "Coin"},
	{["byte"] = 0xB6, ["bit"] = 6, ["name"] = "Factory: Lanky Coin: Production room (2)", ["type"] = "Coin"},
	{["byte"] = 0xB6, ["bit"] = 7, ["name"] = "Factory: Lanky Coin: Production room (3)", ["type"] = "Coin"},

	{["byte"] = 0xB7, ["bit"] = 0, ["name"] = "Factory: Lanky CB: Storage Room Pipe (3)", ["type"] = "CB"},
	{["byte"] = 0xB7, ["bit"] = 1, ["name"] = "Factory: Lanky CB: Storage Room Pipe (4)", ["type"] = "CB"},
	{["byte"] = 0xB7, ["bit"] = 2, ["name"] = "Factory: Lanky CB: Storage Room Pipe (5)", ["type"] = "CB"},
	{["byte"] = 0xB7, ["bit"] = 3, ["name"] = "Factory: Lanky CB: Production room (4)", ["type"] = "Bunch"},
	{["byte"] = 0xB7, ["bit"] = 4, ["name"] = "Factory: Lanky CB: Production room (5)", ["type"] = "Bunch"},
	{["byte"] = 0xB7, ["bit"] = 5, ["name"] = "Factory: Lanky CB: Production room (6)", ["type"] = "Bunch"},
	{["byte"] = 0xB7, ["bit"] = 6, ["name"] = "Factory: Lanky CB: Production room (7)", ["type"] = "Bunch"},
	{["byte"] = 0xB7, ["bit"] = 7, ["name"] = "Factory: Lanky CB: Production room (8)", ["type"] = "Bunch"},

	{["byte"] = 0xB8, ["bit"] = 0, ["name"] = "Factory: Chunky Coin: R&D (1)", ["type"] = "Coin"},
	{["byte"] = 0xB8, ["bit"] = 1, ["name"] = "Factory: Chunky Coin: R&D (2)", ["type"] = "Coin"},
	{["byte"] = 0xB8, ["bit"] = 2, ["name"] = "Factory: Chunky CB: Production room (3)", ["type"] = "Bunch"},
	{["byte"] = 0xB8, ["bit"] = 3, ["name"] = "Factory: Chunky CB: Production room (4)", ["type"] = "Bunch"},
	{["byte"] = 0xB8, ["bit"] = 4, ["name"] = "Factory: Chunky Coin: W1 (Storage Room) (5)", ["type"] = "Coin"},
	{["byte"] = 0xB8, ["bit"] = 5, ["name"] = "Factory: DK Coin: Numbers game (1)", ["type"] = "Coin"},
	{["byte"] = 0xB8, ["bit"] = 6, ["name"] = "Factory: DK Coin: Numbers game (2)", ["type"] = "Coin"},
	{["byte"] = 0xB8, ["bit"] = 7, ["name"] = "Factory: DK Coin: Numbers game (3)", ["type"] = "Coin"},

	{["byte"] = 0xB9, ["bit"] = 0, ["name"] = "Factory: Chunky Coin: Snide's (2)", ["type"] = "Coin"},
	{["byte"] = 0xB9, ["bit"] = 1, ["name"] = "Factory: Chunky CB: W3 by Snide's Bunch", ["type"] = "Bunch"},
	{["byte"] = 0xB9, ["bit"] = 2, ["name"] = "Factory: Chunky Coin: Production room(1)", ["type"] = "Coin"},
	{["byte"] = 0xB9, ["bit"] = 3, ["name"] = "Factory: Chunky Coin: Production room(2)", ["type"] = "Coin"},
	{["byte"] = 0xB9, ["bit"] = 4, ["name"] = "Factory: Chunky Coin: Production room(3)", ["type"] = "Coin"},
	{["byte"] = 0xB9, ["bit"] = 5, ["name"] = "Factory: Chunky Coin: Production room(4)", ["type"] = "Coin"},
	{["byte"] = 0xB9, ["bit"] = 6, ["name"] = "Factory: Chunky Coin: R&D(3)", ["type"] = "Coin"},
	{["byte"] = 0xB9, ["bit"] = 7, ["name"] = "Factory: Chunky Coin: R&D(4)", ["type"] = "Coin"},

	{["byte"] = 0xBA, ["bit"] = 0, ["name"] = "Factory: Chunk Coin: Testing Room Alcove (1)", ["type"] = "Coin"},
	{["byte"] = 0xBA, ["bit"] = 1, ["name"] = "Factory: Chunk Coin: Testing Room Alcove (2)", ["type"] = "Coin"},
	{["byte"] = 0xBA, ["bit"] = 2, ["name"] = "Factory: Chunk Coin: Testing Room Alcove (3)", ["type"] = "Coin"},
	{["byte"] = 0xBA, ["bit"] = 3, ["name"] = "Factory: Chunk Coin: Testing Room Alcove (4)", ["type"] = "Coin"},
	{["byte"] = 0xBA, ["bit"] = 4, ["name"] = "Factory: Chunky CB: W1 Foyer", ["type"] = "Bunch"},
	{["byte"] = 0xBA, ["bit"] = 5, ["name"] = "Factory: Chunky CB: Storage Room W1", ["type"] = "Bunch"},
	{["byte"] = 0xBA, ["bit"] = 6, ["name"] = "Factory: Chunky CB: Dark Room (3)", ["type"] = "Bunch"},
	{["byte"] = 0xBA, ["bit"] = 7, ["name"] = "Factory: Chunky Coin: Snide's (3)", ["type"] = "Coin"},

	{["byte"] = 0xBB, ["bit"] = 0, ["name"] = "Factory: Chunky CB: Toy monster (3)", ["type"] = "CB"},
	{["byte"] = 0xBB, ["bit"] = 1, ["name"] = "Factory: Chunky CB: Toy monster (4)", ["type"] = "CB"},
	{["byte"] = 0xBB, ["bit"] = 2, ["name"] = "Factory: Chunky CB: Toy monster (5)", ["type"] = "CB"},
	{["byte"] = 0xBB, ["bit"] = 3, ["name"] = "Factory: Chunky CB: Toy monster (6)", ["type"] = "CB"},
	{["byte"] = 0xBB, ["bit"] = 4, ["name"] = "Factory: Chunky CB: Toy monster (7)", ["type"] = "CB"},
	{["byte"] = 0xBB, ["bit"] = 5, ["name"] = "Factory: Chunky CB: Toy monster (8)", ["type"] = "CB"},
	{["byte"] = 0xBB, ["bit"] = 6, ["name"] = "Factory: Chunky CB: Toy monster (9)", ["type"] = "CB"},
	{["byte"] = 0xBB, ["bit"] = 7, ["name"] = "Factory: Chunky CB: Toy monster (10)", ["type"] = "CB"},

	{["byte"] = 0xBC, ["bit"] = 0, ["name"] = "Factory: Lanky Coin: Crusher room (1)", ["type"] = "Coin"},
	{["byte"] = 0xBC, ["bit"] = 1, ["name"] = "Factory: Lanky Coin: Crusher room (2)", ["type"] = "Coin"},
	{["byte"] = 0xBC, ["bit"] = 2, ["name"] = "Factory: DK CB: Bunch in Baboon Blast (1)", ["type"] = "Bunch"},
	{["byte"] = 0xBC, ["bit"] = 3, ["name"] = "Factory: DK CB: Bunch in Baboon Blast (2)", ["type"] = "Bunch"},
	{["byte"] = 0xBC, ["bit"] = 4, ["name"] = "Factory: DK CB: Bunch in Baboon Blast (3)", ["type"] = "Bunch"},
	{["byte"] = 0xBC, ["bit"] = 5, ["name"] = "Factory: DK CB: Bunch in Baboon Blast (4)", ["type"] = "Bunch"},

	{["byte"] = 0xBD, ["bit"] = 0, ["name"] = "Factory: DK CB: Bunch in power shed (GB)", ["type"] = "Bunch"},
	{["byte"] = 0xBD, ["bit"] = 1, ["name"] = "Factory: DK CB: Bunch in power shed (Left)", ["type"] = "Bunch"},
	{["byte"] = 0xBD, ["bit"] = 2, ["name"] = "Factory: DK CB: Bunch in power shed (Right)", ["type"] = "Bunch"},
	{["byte"] = 0xBD, ["bit"] = 3, ["name"] = "Factory: DK Coin: Powershed", ["type"] = "Coin"},
	{["byte"] = 0xBD, ["bit"] = 4, ["name"] = "Factory: DK CB: Bunch in crusher room (1)", ["type"] = "Bunch"},
	{["byte"] = 0xBD, ["bit"] = 5, ["name"] = "Factory: DK CB: Bunch in crusher room (2)", ["type"] = "Bunch"},
	{["byte"] = 0xBD, ["bit"] = 6, ["name"] = "Factory: DK CB: Bunch in crusher room (3)", ["type"] = "Bunch"},
	{["byte"] = 0xBD, ["bit"] = 7, ["name"] = "Factory: Lanky Coin: Crusher room(3)", ["type"] = "Coin"},

	{["byte"] = 0xBE, ["bit"] = 0, ["name"] = "Factory: Tiny Coin: Production Room (1)", ["type"] = "Coin"},
	{["byte"] = 0xBE, ["bit"] = 1, ["name"] = "Factory: Diddy Coin: Storage room (2)", ["type"] = "Coin"},
	{["byte"] = 0xBE, ["bit"] = 2, ["name"] = "Factory: Diddy Coin: Storage room (3)", ["type"] = "Coin"},
	{["byte"] = 0xBE, ["bit"] = 3, ["name"] = "Factory: Chunky Coin: Hatch (2)", ["type"] = "Coin"},
	{["byte"] = 0xBE, ["bit"] = 4, ["name"] = "Factory: Chunky Coin: Hatch (3)", ["type"] = "Coin"},
	{["byte"] = 0xBE, ["bit"] = 5, ["name"] = "Factory: Chunky Coin: Hatch (4)", ["type"] = "Coin"},
	{["byte"] = 0xBE, ["bit"] = 6, ["name"] = "Factory: Chunky Coin: Hatch (5)", ["type"] = "Coin"},
	{["byte"] = 0xBE, ["bit"] = 7, ["name"] = "Factory: Diddy Coin: R&D Pole (5)", ["type"] = "Coin"},

	{["byte"] = 0xBF, ["bit"] = 0, ["name"] = "Factory: Chunky Coin: Stash Snatch Area (1)", ["type"] = "Coin"},
	{["byte"] = 0xBF, ["bit"] = 1, ["name"] = "Factory: Chunky Coin: Stash Snatch Area (2)", ["type"] = "Coin"},
	{["byte"] = 0xBF, ["bit"] = 2, ["name"] = "Factory: Chunky Coin: Stash Snatch Area (3)", ["type"] = "Coin"},
	{["byte"] = 0xBF, ["bit"] = 3, ["name"] = "Factory: Lanky Coin: Storage Room Box (1)", ["type"] = "Coin"},
	{["byte"] = 0xBF, ["bit"] = 4, ["name"] = "Factory: Lanky Coin: Storage Room Box (2)", ["type"] = "Coin"},
	{["byte"] = 0xBF, ["bit"] = 5, ["name"] = "Factory: Lanky Coin: Storage Room Box (3)", ["type"] = "Coin"},
	{["byte"] = 0xBF, ["bit"] = 6, ["name"] = "Factory: Tiny Coin: Production Room (2)", ["type"] = "Coin"},
	{["byte"] = 0xBF, ["bit"] = 7, ["name"] = "Factory: Tiny Coin: Production Room (3)", ["type"] = "Coin"},

	{["byte"] = 0xC2, ["bit"] = 7, ["name"] = "Galleon: Tiny Coin: Outside mermaid(1)", ["type"] = "Coin"},

	{["byte"] = 0xC3, ["bit"] = 0, ["name"] = "Galleon: Tiny Coin: Outside mermaid(2)", ["type"] = "Coin"},
	{["byte"] = 0xC3, ["bit"] = 1, ["name"] = "Galleon: Tiny Coin: Outside mermaid(3)", ["type"] = "Coin"},
	{["byte"] = 0xC3, ["bit"] = 3, ["name"] = "Galleon: Tiny Coin: Outside mermaid(4)", ["type"] = "Coin"},

	{["byte"] = 0xC4, ["bit"] = 5, ["name"] = "Galleon: Tiny Coin: Outside mermaid(5)", ["type"] = "Coin"},

	{["byte"] = 0xCC, ["bit"] = 0, ["name"] = "Galleon: Tiny CB: Hallway(1)", ["type"] = "CB"},
	{["byte"] = 0xCC, ["bit"] = 1, ["name"] = "Galleon: Tiny CB: Hallway(2)", ["type"] = "CB"},
	{["byte"] = 0xCC, ["bit"] = 2, ["name"] = "Galleon: Tiny CB: Hallway(3)", ["type"] = "CB"},
	{["byte"] = 0xCC, ["bit"] = 3, ["name"] = "Galleon: Tiny CB: Hallway(4)", ["type"] = "CB"},
	{["byte"] = 0xCC, ["bit"] = 4, ["name"] = "Galleon: Tiny CB: Hallway(5)", ["type"] = "CB"},
	{["byte"] = 0xCC, ["bit"] = 5, ["name"] = "Galleon: Tiny CB: W3 bunch(1)", ["type"] = "Bunch"},
	{["byte"] = 0xCC, ["bit"] = 6, ["name"] = "Galleon: Tiny CB: W3 bunch(2)", ["type"] = "Bunch"},
	{["byte"] = 0xCC, ["bit"] = 7, ["name"] = "Galleon: Tiny CB: Gold tower bunch", ["type"] = "Bunch"},

	{["byte"] = 0xCD, ["bit"] = 1, ["name"] = "Galleon: Tiny CB: Near kasplat(1)", ["type"] = "CB"},
	{["byte"] = 0xCD, ["bit"] = 2, ["name"] = "Galleon: Tiny CB: Near kasplat(2)", ["type"] = "CB"},
	{["byte"] = 0xCD, ["bit"] = 3, ["name"] = "Galleon: Tiny CB: Near kasplat(3)", ["type"] = "CB"},
	{["byte"] = 0xCD, ["bit"] = 4, ["name"] = "Galleon: Tiny CB: Hallway(6)", ["type"] = "CB"},
	{["byte"] = 0xCD, ["bit"] = 5, ["name"] = "Galleon: Tiny CB: Hallway(7)", ["type"] = "CB"},
	{["byte"] = 0xCD, ["bit"] = 6, ["name"] = "Galleon: Tiny CB: Hallway(8)", ["type"] = "CB"},
	{["byte"] = 0xCD, ["bit"] = 7, ["name"] = "Galleon: Tiny CB: Hallway(9)", ["type"] = "CB"},

	{["byte"] = 0xD0, ["bit"] = 0, ["name"] = "Galleon: Chunky Coin: BP (1)", ["type"] = "Coin"},

	{["byte"] = 0xD1, ["bit"] = 4, ["name"] = "Galleon: Chunky Coin: BP (2)", ["type"] = "Coin"},
	{["byte"] = 0xD1, ["bit"] = 5, ["name"] = "Galleon: Chunky Coin: BP (3)", ["type"] = "Coin"},
	{["byte"] = 0xD1, ["bit"] = 6, ["name"] = "Galleon: Chunky Coin: BP (4)", ["type"] = "Coin"},
	{["byte"] = 0xD1, ["bit"] = 7, ["name"] = "Galleon: Chunky Coin: BP (5)", ["type"] = "Coin"},

	{["byte"] = 0xD3, ["bit"] = 0, ["name"] = "Galleon: Tiny CB: Cannon bunch(1)", ["type"] = "Bunch"},
	{["byte"] = 0xD3, ["bit"] = 1, ["name"] = "Galleon: Tiny CB: Cannon bunch(2)", ["type"] = "Bunch"},
	{["byte"] = 0xD3, ["bit"] = 2, ["name"] = "Galleon: Tiny CB: Cannon bunch(3)", ["type"] = "Bunch"},
	{["byte"] = 0xD3, ["bit"] = 3, ["name"] = "Galleon: Tiny Coin: Cannon room(1)", ["type"] = "Coin"},
	{["byte"] = 0xD3, ["bit"] = 4, ["name"] = "Galleon: Tiny Coin: Cannon room(2)", ["type"] = "Coin"},
	{["byte"] = 0xD3, ["bit"] = 5, ["name"] = "Galleon: Tiny Coin: Cannon room(3)", ["type"] = "Coin"},

	{["byte"] = 0xD4, ["bit"] = 5, ["name"] = "Galleon: Tiny Coin: Pearls(1)", ["type"] = "Coin"},
	{["byte"] = 0xD4, ["bit"] = 6, ["name"] = "Galleon: Tiny Coin: Pearls(2)", ["type"] = "Coin"},
	{["byte"] = 0xD4, ["bit"] = 7, ["name"] = "Galleon: Tiny Coin: Pearls(3)", ["type"] = "Coin"},

	{["byte"] = 0xD8, ["bit"] = 2, ["name"] = "Galleon: Tiny CB: 5DS(1)", ["type"] = "CB"},
	{["byte"] = 0xD8, ["bit"] = 3, ["name"] = "Galleon: Tiny CB: 5DS(2)", ["type"] = "CB"},
	{["byte"] = 0xD8, ["bit"] = 4, ["name"] = "Galleon: Tiny CB: 5DS(3)", ["type"] = "CB"},
	{["byte"] = 0xD8, ["bit"] = 5, ["name"] = "Galleon: Tiny CB: 5DS(4)", ["type"] = "CB"},
	{["byte"] = 0xD8, ["bit"] = 6, ["name"] = "Galleon: Tiny CB: 2DS bunch(1)", ["type"] = "Bunch"},

	{["byte"] = 0xD9, ["bit"] = 0, ["name"] = "Galleon: Tiny CB: 5DS bunch(1)", ["type"] = "Bunch"},

	{["byte"] = 0xDA, ["bit"] = 0, ["name"] = "Galleon: Tiny CB: 5DS(5)", ["type"] = "CB"},
	{["byte"] = 0xDA, ["bit"] = 1, ["name"] = "Galleon: Tiny CB: 5DS(6)", ["type"] = "CB"},
	{["byte"] = 0xDA, ["bit"] = 2, ["name"] = "Galleon: Tiny CB: 5DS(7)", ["type"] = "CB"},

	{["byte"] = 0xDB, ["bit"] = 0, ["name"] = "Galleon: Tiny Coin: Pearls(4)", ["type"] = "Coin"},
	{["byte"] = 0xDB, ["bit"] = 1, ["name"] = "Galleon: Tiny Coin: Inside mermaid(1)", ["type"] = "Coin"},
	{["byte"] = 0xDB, ["bit"] = 2, ["name"] = "Galleon: Tiny Coin: Inside mermaid(2)", ["type"] = "Coin"},
	{["byte"] = 0xDB, ["bit"] = 3, ["name"] = "Galleon: Tiny Coin: Inside mermaid(3)", ["type"] = "Coin"},
	{["byte"] = 0xDB, ["bit"] = 4, ["name"] = "Galleon: Tiny CB: 5DS bunch(2)", ["type"] = "Bunch"},
	{["byte"] = 0xDB, ["bit"] = 5, ["name"] = "Galleon: Tiny Coin: 5DS(1)", ["type"] = "Coin"},
	{["byte"] = 0xDB, ["bit"] = 6, ["name"] = "Galleon: Tiny Coin: 5DS(2)", ["type"] = "Coin"},
	{["byte"] = 0xDB, ["bit"] = 7, ["name"] = "Galleon: Tiny CB: 5DS(8)", ["type"] = "CB"},

	{["byte"] = 0xDC, ["bit"] = 0, ["name"] = "Fungi: DK CB: Blue tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xDC, ["bit"] = 1, ["name"] = "Fungi: DK CB: Blue tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xDC, ["bit"] = 2, ["name"] = "Fungi: DK CB: Blue tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xDC, ["bit"] = 3, ["name"] = "Fungi: DK CB: Blue tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xDC, ["bit"] = 4, ["name"] = "Fungi: DK CB: Blue tunnel (5)", ["type"] = "CB"},
	{["byte"] = 0xDC, ["bit"] = 5, ["name"] = "Fungi: DK CB: Outside DK barn (1)", ["type"] = "CB"},
	{["byte"] = 0xDC, ["bit"] = 6, ["name"] = "Fungi: DK CB: Outside DK barn (2)", ["type"] = "CB"},
	{["byte"] = 0xDC, ["bit"] = 7, ["name"] = "Fungi: DK CB: Outside DK barn (3)", ["type"] = "CB"},

	{["byte"] = 0xDD, ["bit"] = 3, ["name"] = "Fungi: DK CB: Pink tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xDD, ["bit"] = 4, ["name"] = "Fungi: DK CB: Pink tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xDD, ["bit"] = 5, ["name"] = "Fungi: DK CB: Pink tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xDD, ["bit"] = 6, ["name"] = "Fungi: DK CB: Pink tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xDD, ["bit"] = 7, ["name"] = "Fungi: DK CB: Pink tunnel (5)", ["type"] = "CB"},

	{["byte"] = 0xDF, ["bit"] = 4, ["name"] = "Galleon: Tiny CB: 2DS bunch(2)", ["type"] = "Bunch"},

	{["byte"] = 0xE0, ["bit"] = 0, ["name"] = "Fungi: DK Coin: bblast (1)", ["type"] = "Coin"},
	{["byte"] = 0xE0, ["bit"] = 1, ["name"] = "Fungi: DK Coin: bblast (2)", ["type"] = "Coin"},
	{["byte"] = 0xE0, ["bit"] = 2, ["name"] = "Fungi: DK Coin: behind clock (1)", ["type"] = "Coin"},
	{["byte"] = 0xE0, ["bit"] = 3, ["name"] = "Fungi: DK Coin: behind clock (2)", ["type"] = "Coin"},
	{["byte"] = 0xE0, ["bit"] = 4, ["name"] = "Fungi: DK Coin: behind clock (3)", ["type"] = "Coin"},
	{["byte"] = 0xE0, ["bit"] = 5, ["name"] = "Fungi: Diddy CB: Top of mushroom (1)", ["type"] = "CB"},
	{["byte"] = 0xE0, ["bit"] = 6, ["name"] = "Fungi: Diddy CB: Top of mushroom (2)", ["type"] = "CB"},
	{["byte"] = 0xE0, ["bit"] = 7, ["name"] = "Fungi: Diddy CB: Top of mushroom (3)", ["type"] = "CB"},

	{["byte"] = 0xE1, ["bit"] = 0, ["name"] = "Fungi: DK CB: Outside giant mushroom(1)", ["type"] = "CB"},
	{["byte"] = 0xE1, ["bit"] = 1, ["name"] = "Fungi: DK CB: Thorn bunch", ["type"] = "Bunch"},
	{["byte"] = 0xE1, ["bit"] = 2, ["name"] = "Fungi: DK CB: High W5 bunch", ["type"] = "Bunch"},
	{["byte"] = 0xE1, ["bit"] = 3, ["name"] = "Fungi: DK CB: Low W5 bunch", ["type"] = "Bunch"},
	{["byte"] = 0xE1, ["bit"] = 4, ["name"] = "Fungi: DK Coin: Near Kasplat (1)", ["type"] = "Coin"},
	{["byte"] = 0xE1, ["bit"] = 5, ["name"] = "Fungi: DK Coin: Near Kasplat (2)", ["type"] = "Coin"},
	{["byte"] = 0xE1, ["bit"] = 6, ["name"] = "Fungi: DK Coin: Near Kasplat (3)", ["type"] = "Coin"},
	{["byte"] = 0xE1, ["bit"] = 7, ["name"] = "Fungi: DK Coin: bblast (3)", ["type"] = "Coin"},

	{["byte"] = 0xE2, ["bit"] = 0, ["name"] = "Fungi: DK CB: Outside giant mushroom (2)", ["type"] = "CB"},
	{["byte"] = 0xE2, ["bit"] = 1, ["name"] = "Fungi: DK CB: Outside giant mushroom (3)", ["type"] = "CB"},
	{["byte"] = 0xE2, ["bit"] = 2, ["name"] = "Fungi: DK CB: Outside giant mushroom (4)", ["type"] = "CB"},
	{["byte"] = 0xE2, ["bit"] = 3, ["name"] = "Fungi: DK CB: Outside giant mushroom (5)", ["type"] = "CB"},
	{["byte"] = 0xE2, ["bit"] = 4, ["name"] = "Fungi: DK CB: Outside giant mushroom (6)", ["type"] = "CB"},
	{["byte"] = 0xE2, ["bit"] = 5, ["name"] = "Fungi: DK CB: Outside giant mushroom (7)", ["type"] = "CB"},
	{["byte"] = 0xE2, ["bit"] = 6, ["name"] = "Fungi: DK CB: Outside giant mushroom (8)", ["type"] = "CB"},
	{["byte"] = 0xE2, ["bit"] = 7, ["name"] = "Fungi: DK CB: Outside giant mushroom (9)", ["type"] = "CB"},

	{["byte"] = 0xE3, ["bit"] = 0, ["name"] = "Fungi: DK CB: Outside DK barn (4)", ["type"] = "CB"},
	{["byte"] = 0xE3, ["bit"] = 1, ["name"] = "Fungi: DK CB: Outside DK barn (5)", ["type"] = "CB"},
	{["byte"] = 0xE3, ["bit"] = 2, ["name"] = "Fungi: DK CB: Outside giant mushroom (10)", ["type"] = "CB"},
	{["byte"] = 0xE3, ["bit"] = 3, ["name"] = "Fungi: DK CB: Outside giant mushroom (11)", ["type"] = "CB"},
	{["byte"] = 0xE3, ["bit"] = 4, ["name"] = "Fungi: DK CB: Outside giant mushroom (12)", ["type"] = "CB"},
	{["byte"] = 0xE3, ["bit"] = 5, ["name"] = "Fungi: DK CB: Outside giant mushroom (13)", ["type"] = "CB"},
	{["byte"] = 0xE3, ["bit"] = 6, ["name"] = "Fungi: DK CB: Outside giant mushroom (14)", ["type"] = "CB"},
	{["byte"] = 0xE3, ["bit"] = 7, ["name"] = "Fungi: DK CB: Outside giant mushroom (15)", ["type"] = "CB"},

	{["byte"] = 0xE4, ["bit"] = 0, ["name"] = "Fungi: Diddy CB: Outside barn bunch", ["type"] = "Bunch"},
	{["byte"] = 0xE4, ["bit"] = 1, ["name"] = "Fungi: Diddy CB: W4 bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xE4, ["bit"] = 2, ["name"] = "Fungi: Diddy CB: W4 bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xE4, ["bit"] = 3, ["name"] = "Fungi: Diddy CB: Treetop bunch", ["type"] = "Bunch"},
	{["byte"] = 0xE4, ["bit"] = 4, ["name"] = "Fungi: Diddy Coin: Outside mill (1)", ["type"] = "Coin"},
	{["byte"] = 0xE4, ["bit"] = 5, ["name"] = "Fungi: Diddy Coin: Outside mill (2)", ["type"] = "Coin"},
	{["byte"] = 0xE4, ["bit"] = 6, ["name"] = "Fungi: Diddy Coin: Outside mill (3)", ["type"] = "Coin"},
	{["byte"] = 0xE4, ["bit"] = 7, ["name"] = "Fungi: Diddy Coin: Battle crown (1)", ["type"] = "Coin"},

	{["byte"] = 0xE5, ["bit"] = 0, ["name"] = "Fungi: Diddy CB: Rabbit race (1)", ["type"] = "CB"},
	{["byte"] = 0xE5, ["bit"] = 1, ["name"] = "Fungi: Lanky CB: Mill roof (1)", ["type"] = "CB"},
	{["byte"] = 0xE5, ["bit"] = 2, ["name"] = "Fungi: Lanky CB: Rope (1)", ["type"] = "CB"},
	{["byte"] = 0xE5, ["bit"] = 3, ["name"] = "Fungi: Lanky CB: Rope (2)", ["type"] = "CB"},
	{["byte"] = 0xE5, ["bit"] = 4, ["name"] = "Fungi: Diddy CB: Entrance rocketbarrel bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xE5, ["bit"] = 5, ["name"] = "Fungi: Diddy CB: Entrance rocketbarrel bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xE5, ["bit"] = 6, ["name"] = "Fungi: Diddy CB: Giant mushroom rocketbarrel bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xE5, ["bit"] = 7, ["name"] = "Fungi: Diddy CB: Giant mushroom rocketbarrel bunch (2)", ["type"] = "Bunch"},

	{["byte"] = 0xE6, ["bit"] = 0, ["name"] = "Fungi: Diddy CB: Rabbit race (1)", ["type"] = "CB"},
	{["byte"] = 0xE6, ["bit"] = 1, ["name"] = "Fungi: Diddy CB: Rabbit race (2)", ["type"] = "CB"},
	{["byte"] = 0xE6, ["bit"] = 2, ["name"] = "Fungi: Diddy CB: Rabbit race (3)", ["type"] = "CB"},
	{["byte"] = 0xE6, ["bit"] = 3, ["name"] = "Fungi: Diddy CB: Rabbit race (4)", ["type"] = "CB"},
	{["byte"] = 0xE6, ["bit"] = 4, ["name"] = "Fungi: Diddy CB: Rabbit race (5)", ["type"] = "CB"},
	{["byte"] = 0xE6, ["bit"] = 5, ["name"] = "Fungi: Diddy CB: Rabbit race (6)", ["type"] = "CB"},
	{["byte"] = 0xE6, ["bit"] = 6, ["name"] = "Fungi: Diddy CB: Rabbit race (7)", ["type"] = "CB"},
	{["byte"] = 0xE6, ["bit"] = 7, ["name"] = "Fungi: Diddy CB: Rabbit race (8)", ["type"] = "CB"},

	{["byte"] = 0xE7, ["bit"] = 0, ["name"] = "Fungi: Diddy CB: Top of mushroom (4)", ["type"] = "CB"},
	{["byte"] = 0xE7, ["bit"] = 1, ["name"] = "Fungi: Diddy CB: Top of mushroom (5)", ["type"] = "CB"},
	{["byte"] = 0xE7, ["bit"] = 2, ["name"] = "Fungi: Diddy CB: Top of mushroom (6)", ["type"] = "CB"},
	{["byte"] = 0xE7, ["bit"] = 3, ["name"] = "Fungi: Diddy CB: Top of mushroom (7)", ["type"] = "CB"},
	{["byte"] = 0xE7, ["bit"] = 4, ["name"] = "Fungi: Diddy CB: Top of mushroom (8)", ["type"] = "CB"},
	{["byte"] = 0xE7, ["bit"] = 5, ["name"] = "Fungi: Diddy CB: Top of mushroom (9)", ["type"] = "CB"},
	{["byte"] = 0xE7, ["bit"] = 6, ["name"] = "Fungi: Diddy CB: Top of mushroom (10)", ["type"] = "CB"},
	{["byte"] = 0xE7, ["bit"] = 7, ["name"] = "Fungi: Diddy CB: Rabbit race (9)", ["type"] = "CB"},

	{["byte"] = 0xE8, ["bit"] = 0, ["name"] = "Fungi: Lanky CB: Around giant mushroom (1)", ["type"] = "CB"},
	{["byte"] = 0xE8, ["bit"] = 1, ["name"] = "Fungi: Lanky CB: Around giant mushroom (2)", ["type"] = "CB"},
	{["byte"] = 0xE8, ["bit"] = 2, ["name"] = "Fungi: Lanky CB: Rabbit race (1)", ["type"] = "CB"},
	{["byte"] = 0xE8, ["bit"] = 3, ["name"] = "Fungi: Lanky CB: Rabbit race (2)", ["type"] = "CB"},
	{["byte"] = 0xE8, ["bit"] = 4, ["name"] = "Fungi: Lanky CB: Rabbit race (3)", ["type"] = "CB"},
	{["byte"] = 0xE8, ["bit"] = 5, ["name"] = "Fungi: Lanky CB: Mill roof (2)", ["type"] = "CB"},
	{["byte"] = 0xE8, ["bit"] = 6, ["name"] = "Fungi: Lanky CB: Mill roof (3)", ["type"] = "CB"},
	{["byte"] = 0xE8, ["bit"] = 7, ["name"] = "Fungi: Lanky CB: Mill roof (4)", ["type"] = "CB"},

	{["byte"] = 0xE9, ["bit"] = 0, ["name"] = "Fungi: Lanky CB: Around giant mushroom (3)", ["type"] = "CB"},
	{["byte"] = 0xE9, ["bit"] = 1, ["name"] = "Fungi: Lanky CB: Around giant mushroom (4)", ["type"] = "CB"},
	{["byte"] = 0xE9, ["bit"] = 2, ["name"] = "Fungi: Lanky CB: Around giant mushroom (5)", ["type"] = "CB"},
	{["byte"] = 0xE9, ["bit"] = 3, ["name"] = "Fungi: Lanky CB: Around giant mushroom (6)", ["type"] = "CB"},
	{["byte"] = 0xE9, ["bit"] = 4, ["name"] = "Fungi: Lanky CB: Around giant mushroom (7)", ["type"] = "CB"},
	{["byte"] = 0xE9, ["bit"] = 5, ["name"] = "Fungi: Lanky CB: Around giant mushroom (8)", ["type"] = "CB"},
	{["byte"] = 0xE9, ["bit"] = 6, ["name"] = "Fungi: Lanky CB: Around giant mushroom (9)", ["type"] = "CB"},
	{["byte"] = 0xE9, ["bit"] = 7, ["name"] = "Fungi: Lanky CB: Around giant mushroom (10)", ["type"] = "CB"},

	{["byte"] = 0xEA, ["bit"] = 0, ["name"] = "Fungi: Lanky CB: Gold tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 1, ["name"] = "Fungi: Lanky CB: Gold tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 2, ["name"] = "Fungi: Lanky CB: Gold tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 3, ["name"] = "Fungi: Lanky CB: Gold tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 4, ["name"] = "Fungi: Lanky CB: Gold tunnel (5)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 5, ["name"] = "Fungi: Lanky CB: Gold tunnel (6)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 6, ["name"] = "Fungi: Lanky CB: Gold tunnel (7)", ["type"] = "CB"},
	{["byte"] = 0xEA, ["bit"] = 7, ["name"] = "Fungi: Lanky CB: Gold tunnel (8)", ["type"] = "CB"},

	{["byte"] = 0xEB, ["bit"] = 0, ["name"] = "Fungi: Diddy Coin: Battle crown (2)", ["type"] = "Coin"},
	{["byte"] = 0xEB, ["bit"] = 1, ["name"] = "Fungi: Diddy Coin: Battle crown (3)", ["type"] = "Coin"},
	{["byte"] = 0xEB, ["bit"] = 2, ["name"] = "Fungi: Tiny Coin: Near kasplat (1)", ["type"] = "Coin"},
	{["byte"] = 0xEB, ["bit"] = 3, ["name"] = "Fungi: Tiny Coin: Near kasplat (2)", ["type"] = "Coin"},
	{["byte"] = 0xEB, ["bit"] = 4, ["name"] = "Fungi: Tiny Coin: Near kasplat (3)", ["type"] = "Coin"},
	{["byte"] = 0xEB, ["bit"] = 5, ["name"] = "Fungi: Tiny Coin: Near kasplat (4)", ["type"] = "Coin"},
	{["byte"] = 0xEB, ["bit"] = 6, ["name"] = "Fungi: Lanky CB: Gold tunnel (9)", ["type"] = "CB"},
	{["byte"] = 0xEB, ["bit"] = 7, ["name"] = "Fungi: Lanky CB: Gold tunnel (10)", ["type"] = "CB"},

	{["byte"] = 0xEC, ["bit"] = 0, ["name"] = "Fungi: Tiny CB: Green tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0xEC, ["bit"] = 1, ["name"] = "Fungi: Tiny CB: Green tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0xEC, ["bit"] = 2, ["name"] = "Fungi: Tiny CB: River (1)", ["type"] = "CB"},
	{["byte"] = 0xEC, ["bit"] = 3, ["name"] = "Fungi: Tiny CB: River (2)", ["type"] = "CB"},
	{["byte"] = 0xEC, ["bit"] = 4, ["name"] = "Fungi: Tiny CB: River (3)", ["type"] = "CB"},
	{["byte"] = 0xEC, ["bit"] = 5, ["name"] = "Fungi: Tiny CB: River (4)", ["type"] = "CB"},
	{["byte"] = 0xEC, ["bit"] = 6, ["name"] = "Fungi: Tiny CB: River (5)", ["type"] = "CB"},
	{["byte"] = 0xEC, ["bit"] = 7, ["name"] = "Fungi: Tiny CB: River (6)", ["type"] = "CB"},

	{["byte"] = 0xED, ["bit"] = 0, ["name"] = "Fungi: Lanky Coin: Near kasplat (1)", ["type"] = "Coin"},
	{["byte"] = 0xED, ["bit"] = 1, ["name"] = "Fungi: Lanky Coin: Near kasplat (2)", ["type"] = "Coin"},
	{["byte"] = 0xED, ["bit"] = 2, ["name"] = "Fungi: Lanky Coin: Above chunky minecart (1)", ["type"] = "Coin"},
	{["byte"] = 0xED, ["bit"] = 3, ["name"] = "Fungi: Lanky Coin: Above chunky minecart (2)", ["type"] = "Coin"},
	{["byte"] = 0xED, ["bit"] = 4, ["name"] = "Fungi: Lanky Coin: Above chunky minecart (3)", ["type"] = "Coin"},
	{["byte"] = 0xED, ["bit"] = 5, ["name"] = "Fungi: Tiny CB: Green tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0xED, ["bit"] = 6, ["name"] = "Fungi: Tiny CB: Green tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0xED, ["bit"] = 7, ["name"] = "Fungi: Tiny CB: Green tunnel (5)", ["type"] = "CB"},

	{["byte"] = 0xEE, ["bit"] = 0, ["name"] = "Fungi: Lanky CB: Rabbit race bunch", ["type"] = "Bunch"},
	{["byte"] = 0xEE, ["bit"] = 4, ["name"] = "Fungi: Lanky Coin: Outside giant mushroom (1)", ["type"] = "Coin"},
	{["byte"] = 0xEE, ["bit"] = 5, ["name"] = "Fungi: Lanky Coin: Outside giant mushroom (2)", ["type"] = "Coin"},
	{["byte"] = 0xEE, ["bit"] = 6, ["name"] = "Fungi: Lanky Coin: Outside giant mushroom (3)", ["type"] = "Coin"},
	{["byte"] = 0xEE, ["bit"] = 7, ["name"] = "Fungi: Lanky Coin: Near kasplat (3)", ["type"] = "Coin"},

	{["byte"] = 0xEF, ["bit"] = 0, ["name"] = "Fungi: Lanky CB: Rope (3)", ["type"] = "CB"},
	{["byte"] = 0xEF, ["bit"] = 1, ["name"] = "Fungi: Diddy CB: Outside Barn (1)", ["type"] = "CB"},
	{["byte"] = 0xEF, ["bit"] = 2, ["name"] = "Fungi: Diddy CB: Outside Barn (2)", ["type"] = "CB"},
	{["byte"] = 0xEF, ["bit"] = 3, ["name"] = "Fungi: Diddy CB: Outside Barn (3)", ["type"] = "CB"},
	{["byte"] = 0xEF, ["bit"] = 4, ["name"] = "Fungi: Lanky CB: Bballoon bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xEF, ["bit"] = 5, ["name"] = "Fungi: Lanky CB: Bballoon bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xEF, ["bit"] = 6, ["name"] = "Fungi: Lanky CB: W1 bunch", ["type"] = "Bunch"},
	{["byte"] = 0xEF, ["bit"] = 7, ["name"] = "Fungi: Lanky CB: Top of giant mushroom bunch", ["type"] = "Bunch"},

	{["byte"] = 0xF0, ["bit"] = 0, ["name"] = "Fungi: Tiny Coin: Purple tunnel (1)", ["type"] = "Coin"},
	{["byte"] = 0xF0, ["bit"] = 1, ["name"] = "Fungi: Tiny Coin: Purple tunnel (2)", ["type"] = "Coin"},
	{["byte"] = 0xF0, ["bit"] = 2, ["name"] = "Fungi: Tiny Coin: Purple tunnel (3)", ["type"] = "Coin"},
	{["byte"] = 0xF0, ["bit"] = 3, ["name"] = "Fungi: Diddy Coin: tree (1)", ["type"] = "Coin"},
	{["byte"] = 0xF0, ["bit"] = 4, ["name"] = "Fungi: Diddy Coin: tree (2)", ["type"] = "Coin"},
	{["byte"] = 0xF0, ["bit"] = 5, ["name"] = "Fungi: Tiny Coin: beanstalk (1)", ["type"] = "Coin"},
	{["byte"] = 0xF0, ["bit"] = 6, ["name"] = "Fungi: Tiny Coin: beanstalk (2)", ["type"] = "Coin"},
	{["byte"] = 0xF0, ["bit"] = 7, ["name"] = "Fungi: Tiny Coin: beanstalk (3)", ["type"] = "Coin"},

	{["byte"] = 0xF1, ["bit"] = 0, ["name"] = "Fungi: Tiny CB: Outside anthill (1)", ["type"] = "CB"},
	{["byte"] = 0xF1, ["bit"] = 1, ["name"] = "Fungi: Tiny CB: Outside anthill (2)", ["type"] = "CB"},
	{["byte"] = 0xF1, ["bit"] = 2, ["name"] = "Fungi: Tiny CB: Outside anthill (3)", ["type"] = "CB"},
	{["byte"] = 0xF1, ["bit"] = 3, ["name"] = "Fungi: Tiny CB: Beanstalk bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xF1, ["bit"] = 4, ["name"] = "Fungi: Tiny CB: W3 bunch", ["type"] = "Bunch"},
	{["byte"] = 0xF1, ["bit"] = 5, ["name"] = "Fungi: Tiny CB:Anthill bunch", ["type"] = "Bunch"},
	{["byte"] = 0xF1, ["bit"] = 6, ["name"] = "Fungi: Tiny CB: Beanstalk bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xF1, ["bit"] = 7, ["name"] = "Fungi: Tiny CB: Beanstalk bunch (3)", ["type"] = "Bunch"},

	{["byte"] = 0xF2, ["bit"] = 0, ["name"] = "Fungi: Tiny CB: River (7)", ["type"] = "CB"},
	{["byte"] = 0xF2, ["bit"] = 1, ["name"] = "Fungi: Tiny CB: River (8)", ["type"] = "CB"},
	{["byte"] = 0xF2, ["bit"] = 2, ["name"] = "Fungi: Tiny CB: River (9)", ["type"] = "CB"},
	{["byte"] = 0xF2, ["bit"] = 3, ["name"] = "Fungi: Tiny CB: Outside anthill (4)", ["type"] = "CB"},
	{["byte"] = 0xF2, ["bit"] = 4, ["name"] = "Fungi: Tiny CB: Outside anthill (5)", ["type"] = "CB"},
	{["byte"] = 0xF2, ["bit"] = 5, ["name"] = "Fungi: Tiny CB: Outside anthill (6)", ["type"] = "CB"},
	{["byte"] = 0xF2, ["bit"] = 6, ["name"] = "Fungi: Tiny CB: Outside anthill (7)", ["type"] = "CB"},
	{["byte"] = 0xF2, ["bit"] = 7, ["name"] = "Fungi: Tiny CB: Outside anthill (8)", ["type"] = "CB"},

	{["byte"] = 0xF3, ["bit"] = 0, ["name"] = "Fungi: Tiny CB: River (10)", ["type"] = "CB"},
	{["byte"] = 0xF3, ["bit"] = 1, ["name"] = "Fungi: Tiny CB: River (11)", ["type"] = "CB"},
	{["byte"] = 0xF3, ["bit"] = 2, ["name"] = "Fungi: Tiny CB: River (12)", ["type"] = "CB"},
	{["byte"] = 0xF3, ["bit"] = 3, ["name"] = "Fungi: Tiny CB: River (13)", ["type"] = "CB"},
	{["byte"] = 0xF3, ["bit"] = 4, ["name"] = "Fungi: Tiny CB: River (14)", ["type"] = "CB"},
	{["byte"] = 0xF3, ["bit"] = 5, ["name"] = "Fungi: Tiny CB: River (15)", ["type"] = "CB"},
	{["byte"] = 0xF3, ["bit"] = 6, ["name"] = "Fungi: Tiny CB: River (16)", ["type"] = "CB"},
	{["byte"] = 0xF3, ["bit"] = 7, ["name"] = "Fungi: Tiny CB: River (17)", ["type"] = "CB"},

	{["byte"] = 0xF4, ["bit"] = 0, ["name"] = "Fungi: Chunky Coin: Well (1)", ["type"] = "Coin"},
	{["byte"] = 0xF4, ["bit"] = 1, ["name"] = "Fungi: Diddy Coin: tree (3)", ["type"] = "Coin"},
	{["byte"] = 0xF4, ["bit"] = 2, ["name"] = "Fungi: Tiny Coin: Near kasplat (5)", ["type"] = "Coin"},
	{["byte"] = 0xF4, ["bit"] = 3, ["name"] = "Fungi: Diddy Coin: tree (4)", ["type"] = "Coin"},
	{["byte"] = 0xF4, ["bit"] = 4, ["name"] = "Fungi: Diddy CB: Barn Bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xF4, ["bit"] = 5, ["name"] = "Fungi: Diddy CB: Barn Bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xF4, ["bit"] = 6, ["name"] = "Fungi: Diddy Coin: Attic (1)", ["type"] = "Coin"},
	{["byte"] = 0xF4, ["bit"] = 7, ["name"] = "Fungi: Diddy Coin: Attic (2)", ["type"] = "Coin"},

	{["byte"] = 0xF5, ["bit"] = 0, ["name"] = "Fungi: Chunky Coin: Apple (1)", ["type"] = "Coin"},
	{["byte"] = 0xF5, ["bit"] = 1, ["name"] = "Fungi: Chunky Coin: Apple (2)", ["type"] = "Coin"},
	{["byte"] = 0xF5, ["bit"] = 2, ["name"] = "Fungi: Chunky Coin: Apple (3)", ["type"] = "Coin"},
	{["byte"] = 0xF5, ["bit"] = 3, ["name"] = "Fungi: Chunky Coin: Facegame (1)", ["type"] = "Coin"},
	{["byte"] = 0xF5, ["bit"] = 4, ["name"] = "Fungi: Chunky Coin: Facegame (2)", ["type"] = "Coin"},
	{["byte"] = 0xF5, ["bit"] = 5, ["name"] = "Fungi: Chunky Coin: Facegame (3)", ["type"] = "Coin"},
	{["byte"] = 0xF5, ["bit"] = 6, ["name"] = "Fungi: Chunky Coin: Well (2)", ["type"] = "Coin"},
	{["byte"] = 0xF5, ["bit"] = 7, ["name"] = "Fungi: Chunky Coin: Well (3)", ["type"] = "Coin"},

	{["byte"] = 0xF6, ["bit"] = 0, ["name"] = "Fungi: Chunky CB: Apple (1)", ["type"] = "CB"},
	{["byte"] = 0xF6, ["bit"] = 1, ["name"] = "Fungi: Chunky CB: Apple (2)", ["type"] = "CB"},
	{["byte"] = 0xF6, ["bit"] = 2, ["name"] = "Fungi: Chunky CB: W2 bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xF6, ["bit"] = 3, ["name"] = "Fungi: Chunky CB: W2 bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xF6, ["bit"] = 4, ["name"] = "Fungi: Chunky CB: Well bunch", ["type"] = "Bunch"},
	{["byte"] = 0xF6, ["bit"] = 5, ["name"] = "Fungi: Chunky Coin: Outside Mill (1)", ["type"] = "Coin"},
	{["byte"] = 0xF6, ["bit"] = 6, ["name"] = "Fungi: Chunky Coin: Outside Mill (2)", ["type"] = "Coin"},
	{["byte"] = 0xF6, ["bit"] = 7, ["name"] = "Fungi: Chunky Coin: Outside Mill (3)", ["type"] = "Coin"},

	{["byte"] = 0xF7, ["bit"] = 0, ["name"] = "Fungi: Chunky CB: Apple (3)", ["type"] = "CB"},
	{["byte"] = 0xF7, ["bit"] = 1, ["name"] = "Fungi: Chunky CB: Apple (4)", ["type"] = "CB"},
	{["byte"] = 0xF7, ["bit"] = 2, ["name"] = "Fungi: Chunky CB: Apple (5)", ["type"] = "CB"},
	{["byte"] = 0xF7, ["bit"] = 3, ["name"] = "Fungi: Chunky CB: Apple (6)", ["type"] = "CB"},
	{["byte"] = 0xF7, ["bit"] = 4, ["name"] = "Fungi: Chunky CB: Apple (7)", ["type"] = "CB"},
	{["byte"] = 0xF7, ["bit"] = 5, ["name"] = "Fungi: Chunky CB: Apple (8)", ["type"] = "CB"},
	{["byte"] = 0xF7, ["bit"] = 6, ["name"] = "Fungi: Chunky CB: Apple (9)", ["type"] = "CB"},
	{["byte"] = 0xF7, ["bit"] = 7, ["name"] = "Fungi: Lanky CB: W3 Bunch", ["type"] = "Bunch"},

	{["byte"] = 0xF8, ["bit"] = 0, ["name"] = "Fungi: DK CB: Cannon bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xF8, ["bit"] = 1, ["name"] = "Fungi: DK CB: Cannon bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xF8, ["bit"] = 2, ["name"] = "Fungi: DK CB: Cannon bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0xF8, ["bit"] = 3, ["name"] = "Fungi: Diddy CB: near BP (1)", ["type"] = "CB"},
	{["byte"] = 0xF8, ["bit"] = 4, ["name"] = "Fungi: Diddy CB: near BP (2)", ["type"] = "CB"},
	{["byte"] = 0xF8, ["bit"] = 5, ["name"] = "Fungi: Diddy CB: near BP (3)", ["type"] = "CB"},
	{["byte"] = 0xF8, ["bit"] = 6, ["name"] = "Fungi: Diddy CB: near BP (4)", ["type"] = "CB"},
	{["byte"] = 0xF8, ["bit"] = 7, ["name"] = "Fungi: Diddy CB: near BP (5)", ["type"] = "CB"},

	{["byte"] = 0xF9, ["bit"] = 0, ["name"] = "Fungi: Tiny CB: Mill bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xF9, ["bit"] = 1, ["name"] = "Fungi: Tiny CB: Mill bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xF9, ["bit"] = 2, ["name"] = "Fungi: Tiny CB: Mill bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0xF9, ["bit"] = 3, ["name"] = "Fungi: Chunky CB: Mill bunch", ["type"] = "Bunch"},
	{["byte"] = 0xF9, ["bit"] = 4, ["name"] = "Fungi: Chunky Coin: Mill (1)", ["type"] = "Coin"},
	{["byte"] = 0xF9, ["bit"] = 5, ["name"] = "Fungi: Chunky Coin: Mill (2)", ["type"] = "Coin"},
	{["byte"] = 0xF9, ["bit"] = 6, ["name"] = "Fungi: Chunky Coin: Mill (3)", ["type"] = "Coin"},
	{["byte"] = 0xF9, ["bit"] = 7, ["name"] = "Fungi: Lanky CB: Colored mushroom puzzle bunch", ["type"] = "Bunch"},

	{["byte"] = 0xFA, ["bit"] = 0, ["name"] = "Fungi: Tiny CB: Spiderboss bunch", ["type"] = "Bunch"},
	{["byte"] = 0xFA, ["bit"] = 1, ["name"] = "Fungi: DK CB: mill bunch", ["type"] = "Bunch"},
	{["byte"] = 0xFA, ["bit"] = 2, ["name"] = "Fungi: Lanky Coin: Mill (1)", ["type"] = "Coin"},
	{["byte"] = 0xFA, ["bit"] = 3, ["name"] = "Fungi: Lanky Coin: Mill (2)", ["type"] = "Coin"},
	{["byte"] = 0xFA, ["bit"] = 4, ["name"] = "Fungi: Lanky Coin: Mill (3)", ["type"] = "Coin"},
	{["byte"] = 0xFA, ["bit"] = 5, ["name"] = "Fungi: Tiny Coin: Mill (1)", ["type"] = "Coin"},
	{["byte"] = 0xFA, ["bit"] = 6, ["name"] = "Fungi: Tiny Coin: Mill (2)", ["type"] = "Coin"},
	{["byte"] = 0xFA, ["bit"] = 7, ["name"] = "Fungi: Tiny Coin: Mill (3)", ["type"] = "Coin"},

	{["byte"] = 0xFB, ["bit"] = 3, ["name"] = "Fungi: Lanky CB: Attic bunch", ["type"] = "Bunch"},
	{["byte"] = 0xFB, ["bit"] = 4, ["name"] = "Fungi: DK CB: DK Barn bunch", ["type"] = "Bunch"},
	{["byte"] = 0xFB, ["bit"] = 5, ["name"] = "Fungi: DK Coin: DK Barn (1)", ["type"] = "Coin"},
	{["byte"] = 0xFB, ["bit"] = 6, ["name"] = "Fungi: DK Coin: DK Barn (2)", ["type"] = "Coin"},
	{["byte"] = 0xFB, ["bit"] = 7, ["name"] = "Fungi: DK Coin: DK Barn (3)", ["type"] = "Coin"},

	{["byte"] = 0xFC, ["bit"] = 0, ["name"] = "Fungi: Chunky CB: Giant mushroom bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xFC, ["bit"] = 1, ["name"] = "Fungi: Chunky CB: Giant mushroom bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xFC, ["bit"] = 2, ["name"] = "Fungi: Chunky CB: Giant mushroom bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0xFC, ["bit"] = 3, ["name"] = "Fungi: Chunky CB: Giant mushroom bunch (4)", ["type"] = "Bunch"},
	{["byte"] = 0xFC, ["bit"] = 4, ["name"] = "Fungi: Chunky CB: Giant mushroom bunch (5)", ["type"] = "Bunch"},
	{["byte"] = 0xFC, ["bit"] = 5, ["name"] = "Fungi: Lanky CB: Bouncy room bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0xFC, ["bit"] = 6, ["name"] = "Fungi: Lanky CB: Bouncy room bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0xFC, ["bit"] = 7, ["name"] = "Fungi: Chunky CB: Facegame bunch", ["type"] = "Bunch"},

	{["byte"] = 0xFD, ["bit"] = 0, ["name"] = "Fungi: Chunky CB: Inside mushroom (7)", ["type"] = "CB"},
	{["byte"] = 0xFD, ["bit"] = 1, ["name"] = "Fungi: Chunky CB: Inside mushroom (8)", ["type"] = "CB"},
	{["byte"] = 0xFD, ["bit"] = 2, ["name"] = "Fungi: Chunky CB: Inside mushroom (9)", ["type"] = "CB"},
	{["byte"] = 0xFD, ["bit"] = 3, ["name"] = "Fungi: Chunky CB: Inside mushroom (10)", ["type"] = "CB"},
	{["byte"] = 0xFD, ["bit"] = 4, ["name"] = "Fungi: Chunky CB: Inside mushroom (11)", ["type"] = "CB"},
	{["byte"] = 0xFD, ["bit"] = 5, ["name"] = "Fungi: Chunky CB: Inside mushroom (12)", ["type"] = "CB"},
	{["byte"] = 0xFD, ["bit"] = 6, ["name"] = "Fungi: Chunky CB: Inside mushroom (13)", ["type"] = "CB"},
	{["byte"] = 0xFD, ["bit"] = 7, ["name"] = "Fungi: Chunky CB: Inside mushroom (14)", ["type"] = "CB"},

	{["byte"] = 0xFE, ["bit"] = 0, ["name"] = "Fungi: Chunky CB: Inside mushroom (1)", ["type"] = "CB"},
	{["byte"] = 0xFE, ["bit"] = 1, ["name"] = "Fungi: Chunky CB: Inside mushroom (15)", ["type"] = "CB"},
	{["byte"] = 0xFE, ["bit"] = 2, ["name"] = "Fungi: Chunky CB: Inside mushroom (16)", ["type"] = "CB"},

	{["byte"] = 0xFF, ["bit"] = 0, ["name"] = "Fungi: Diddy CB: Near BP (6)", ["type"] = "CB"},
	{["byte"] = 0xFF, ["bit"] = 1, ["name"] = "Fungi: Diddy CB: Near BP (7)", ["type"] = "CB"},
	{["byte"] = 0xFF, ["bit"] = 2, ["name"] = "Fungi: Tiny CB: Bunch inside mushroom", ["type"] = "Bunch"},
	{["byte"] = 0xFF, ["bit"] = 3, ["name"] = "Fungi: Chunky CB: Inside mushroom (2)", ["type"] = "CB"},
	{["byte"] = 0xFF, ["bit"] = 4, ["name"] = "Fungi: Chunky CB: Inside mushroom (3)", ["type"] = "CB"},
	{["byte"] = 0xFF, ["bit"] = 5, ["name"] = "Fungi: Chunky CB: Inside mushroom (4)", ["type"] = "CB"},
	{["byte"] = 0xFF, ["bit"] = 6, ["name"] = "Fungi: Chunky CB: Inside mushroom (5)", ["type"] = "CB"},
	{["byte"] = 0xFF, ["bit"] = 7, ["name"] = "Fungi: Chunky CB: Inside mushroom (6)", ["type"] = "CB"},

	{["byte"] = 0x100, ["bit"] = 0, ["name"] = "Caves: DK Coin: T&S Igloo (1)", ["type"] = "Coin"},
	{["byte"] = 0x100, ["bit"] = 1, ["name"] = "Caves: DK Coin: T&S Igloo (2)", ["type"] = "Coin"},
	{["byte"] = 0x100, ["bit"] = 2, ["name"] = "Caves: DK Coin: T&S Igloo (3)", ["type"] = "Coin"},
	{["byte"] = 0x100, ["bit"] = 3, ["name"] = "Caves: Diddy CB: Around 5DI (1)", ["type"] = "Bunch"},
	{["byte"] = 0x100, ["bit"] = 4, ["name"] = "Caves: Lanky CB: Cranky Bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x100, ["bit"] = 5, ["name"] = "Caves: Lanky CB: Lanky Castle", ["type"] = "Bunch"},
	{["byte"] = 0x100, ["bit"] = 6, ["name"] = "Caves: Lanky CB: Lanky Cabin Instrument pad", ["type"] = "Bunch"},
	{["byte"] = 0x100, ["bit"] = 7, ["name"] = "Caves: Tiny Coin: Giant Kosha (1)", ["type"] = "Coin"},

	{["byte"] = 0x101, ["bit"] = 0, ["name"] = "Caves: DK CB: near BBlast (1)", ["type"] = "CB"},
	{["byte"] = 0x101, ["bit"] = 1, ["name"] = "Caves: DK CB: near BBlast (2)", ["type"] = "CB"},
	{["byte"] = 0x101, ["bit"] = 2, ["name"] = "Caves: DK CB: W1 Entrance", ["type"] = "Bunch"},
	{["byte"] = 0x101, ["bit"] = 3, ["name"] = "Caves: DK CB: W1 5DI", ["type"] = "Bunch"},
	{["byte"] = 0x101, ["bit"] = 4, ["name"] = "Caves: DK CB: 5DC Bongo pad", ["type"] = "Bunch"},
	{["byte"] = 0x101, ["bit"] = 5, ["name"] = "Caves: DK Coin: Entrance Icewall (1)", ["type"] = "Coin"},
	{["byte"] = 0x101, ["bit"] = 6, ["name"] = "Caves: DK Coin: Entrance Icewall (2)", ["type"] = "Coin"},
	{["byte"] = 0x101, ["bit"] = 7, ["name"] = "Caves: DK Coin: Entrance Icewall (3)", ["type"] = "Coin"},

	{["byte"] = 0x102, ["bit"] = 0, ["name"] = "Caves: DK CB: Around 5DI (1)", ["type"] = "CB"},
	{["byte"] = 0x102, ["bit"] = 1, ["name"] = "Caves: DK CB: Around 5DI (2)", ["type"] = "CB"},
	{["byte"] = 0x102, ["bit"] = 2, ["name"] = "Caves: DK CB: Around 5DI (3)", ["type"] = "CB"},
	{["byte"] = 0x102, ["bit"] = 3, ["name"] = "Caves: DK CB: Around 5DI (4)", ["type"] = "CB"},
	{["byte"] = 0x102, ["bit"] = 4, ["name"] = "Caves: DK CB: Around 5DI (5)", ["type"] = "CB"},
	{["byte"] = 0x102, ["bit"] = 5, ["name"] = "Caves: DK CB: near BBlast (3)", ["type"] = "CB"},
	{["byte"] = 0x102, ["bit"] = 6, ["name"] = "Caves: DK CB: near BBlast (4)", ["type"] = "CB"},
	{["byte"] = 0x102, ["bit"] = 7, ["name"] = "Caves: DK CB: near BBlast (5)", ["type"] = "CB"},

	{["byte"] = 0x103, ["bit"] = 0, ["name"] = "DK CB: Fungi: Bblast (1)", ["type"] = "Bunch"},
	{["byte"] = 0x103, ["bit"] = 1, ["name"] = "DK CB: Fungi: Bblast (2)", ["type"] = "Bunch"},
	{["byte"] = 0x103, ["bit"] = 2, ["name"] = "Caves: Diddy CB: Around 5DI (2)", ["type"] = "Bunch"},
	{["byte"] = 0x103, ["bit"] = 3, ["name"] = "? Caves: Chunky coin W3???", ["type"] = "Coin"}, -- TODO: Needs testing
	{["byte"] = 0x103, ["bit"] = 4, ["name"] = "Caves: Diddy CB: Funky Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x103, ["bit"] = 5, ["name"] = "Caves: Chunky CB: W2 bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x103, ["bit"] = 6, ["name"] = "Caves: Chunky CB: W2 bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0x103, ["bit"] = 7, ["name"] = "Caves: Chunky CB: T&S Igloo (1)", ["type"] = "CB"},

	{["byte"] = 0x104, ["bit"] = 0, ["name"] = "Caves: Chunky CB: Entrance Icewall (1)", ["type"] = "CB"},
	{["byte"] = 0x104, ["bit"] = 1, ["name"] = "Caves: Chunky CB: Wooden plank (1)", ["type"] = "CB"},
	{["byte"] = 0x104, ["bit"] = 2, ["name"] = "Caves: Chunky CB: Wooden plank (2)", ["type"] = "CB"},
	{["byte"] = 0x104, ["bit"] = 3, ["name"] = "Caves: Chunky CB: Wooden plank (3)", ["type"] = "CB"},
	{["byte"] = 0x104, ["bit"] = 4, ["name"] = "Caves: Chunky CB: Snide (1)", ["type"] = "CB"},
	{["byte"] = 0x104, ["bit"] = 5, ["name"] = "Caves: Chunky CB: Snide (2)", ["type"] = "CB"},
	{["byte"] = 0x104, ["bit"] = 6, ["name"] = "Caves: Chunky CB: Snide (3)", ["type"] = "CB"},
	{["byte"] = 0x104, ["bit"] = 7, ["name"] = "Caves: Chunky CB: Chunky Igloo (1)", ["type"] = "CB"},

	{["byte"] = 0x105, ["bit"] = 0, ["name"] = "Caves: Diddy Coin: Lanky Castle (1)", ["type"] = "Coin"},
	{["byte"] = 0x105, ["bit"] = 1, ["name"] = "Caves: Diddy Coin: Lanky Castle (2)", ["type"] = "Coin"},
	{["byte"] = 0x105, ["bit"] = 2, ["name"] = "Caves: Diddy Coin: Lanky Castle (3)", ["type"] = "Coin"},
	{["byte"] = 0x105, ["bit"] = 3, ["name"] = "Caves: Diddy Coin: Lanky Castle (4)", ["type"] = "Coin"},
	{["byte"] = 0x105, ["bit"] = 4, ["name"] = "Caves: Lanky CB: Entrance (1)", ["type"] = "CB"},
	{["byte"] = 0x105, ["bit"] = 5, ["name"] = "Caves: Diddy CB: W4 Kasplat (1)", ["type"] = "CB"},
	{["byte"] = 0x105, ["bit"] = 6, ["name"] = "Caves: Chunky CB: Entrance Icewall (2)", ["type"] = "CB"},
	{["byte"] = 0x105, ["bit"] = 7, ["name"] = "Caves: Chunky CB: Entrance Icewall (3)", ["type"] = "CB"},

	{["byte"] = 0x106, ["bit"] = 0, ["name"] = "Caves: Tiny Coin: Giant Kosha (2)", ["type"] = "Coin"},
	{["byte"] = 0x106, ["bit"] = 1, ["name"] = "Caves: Diddy CB: Bunch on W4 (far)", ["type"] = "Bunch"},
	{["byte"] = 0x106, ["bit"] = 2, ["name"] = "Caves: Diddy CB: W4 Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x106, ["bit"] = 3, ["name"] = "Caves: Diddy CB: Tiny Igloo Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x106, ["bit"] = 4, ["name"] = "Caves: Diddy CB: Chunky Igloo Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x106, ["bit"] = 5, ["name"] = "Caves: Chunky Coin: Snide's (1)", ["type"] = "Coin"},
	{["byte"] = 0x106, ["bit"] = 6, ["name"] = "Caves: Chunky Coin: Snide's (2)", ["type"] = "Coin"},
	{["byte"] = 0x106, ["bit"] = 7, ["name"] = "Caves: Chunky Coin: Snide's (3)", ["type"] = "Coin"},

	{["byte"] = 0x107, ["bit"] = 0, ["name"] = "Caves: Lanky CB: Entrance (2)", ["type"] = "CB"},
	{["byte"] = 0x107, ["bit"] = 1, ["name"] = "Caves: Lanky CB: Entrance (3)", ["type"] = "CB"},
	{["byte"] = 0x107, ["bit"] = 2, ["name"] = "Caves: Lanky CB: Entrance (4)", ["type"] = "CB"},
	{["byte"] = 0x107, ["bit"] = 3, ["name"] = "Caves: Lanky CB: Entrance (5)", ["type"] = "CB"},
	{["byte"] = 0x107, ["bit"] = 4, ["name"] = "Caves: Diddy CB: Funky (1)", ["type"] = "CB"},
	{["byte"] = 0x107, ["bit"] = 5, ["name"] = "Caves: Diddy CB: Funky (2)", ["type"] = "CB"},
	{["byte"] = 0x107, ["bit"] = 6, ["name"] = "Caves: Diddy CB: Funky (3)", ["type"] = "CB"},
	{["byte"] = 0x107, ["bit"] = 7, ["name"] = "Caves: Diddy CB: Funky (4)", ["type"] = "CB"},

	{["byte"] = 0x108, ["bit"] = 0, ["name"] = "Caves: Chunky Coin: Cranky Slope (1)", ["type"] = "Coin"},
	{["byte"] = 0x108, ["bit"] = 1, ["name"] = "Caves: Diddy CB: W4 Kasplat (2)", ["type"] = "CB"},
	{["byte"] = 0x108, ["bit"] = 2, ["name"] = "Caves: Diddy CB: W4 Kasplat (3)", ["type"] = "CB"},
	{["byte"] = 0x108, ["bit"] = 3, ["name"] = "Caves: Diddy CB: W4 Kasplat (4)", ["type"] = "CB"},
	{["byte"] = 0x108, ["bit"] = 4, ["name"] = "Caves: Diddy CB: Funky (1)", ["type"] = "CB"},
	{["byte"] = 0x108, ["bit"] = 5, ["name"] = "Caves: Diddy CB: W4 Kasplat (5)", ["type"] = "CB"},
	{["byte"] = 0x108, ["bit"] = 6, ["name"] = "Caves: Lanky CB: River to 5DC (1)", ["type"] = "CB"},
	{["byte"] = 0x108, ["bit"] = 7, ["name"] = "Caves: Lanky CB: River to 5DC (2)", ["type"] = "CB"},

	{["byte"] = 0x109, ["bit"] = 3, ["name"] = "Caves: Chunky Coin: Chunky Igloo (1)", ["type"] = "Coin"},
	{["byte"] = 0x109, ["bit"] = 4, ["name"] = "Caves: Chunky Coin: Chunky Igloo (2)", ["type"] = "Coin"},
	{["byte"] = 0x109, ["bit"] = 5, ["name"] = "Caves: Chunky Coin: Chunky Igloo (3)", ["type"] = "Coin"},
	{["byte"] = 0x109, ["bit"] = 6, ["name"] = "Caves: Chunky Coin: Cranky Slope (4)", ["type"] = "Coin"},
	{["byte"] = 0x109, ["bit"] = 7, ["name"] = "Caves: Chunky Coin: Cranky Slope (5)", ["type"] = "Coin"},

	{["byte"] = 0x10A, ["bit"] = 0, ["name"] = "Caves: Chunky CB: T&S Igloo (2)", ["type"] = "CB"},
	{["byte"] = 0x10A, ["bit"] = 1, ["name"] = "Caves: DK CB: T&S Igloo (1)", ["type"] = "CB"},
	{["byte"] = 0x10A, ["bit"] = 2, ["name"] = "Caves: DK CB: T&S Igloo (2)", ["type"] = "CB"},
	{["byte"] = 0x10A, ["bit"] = 3, ["name"] = "Caves: DK CB: T&S Igloo (3)", ["type"] = "CB"},
	{["byte"] = 0x10A, ["bit"] = 4, ["name"] = "Caves: Chunky CB: Entrance Icewall", ["type"] = "Bunch"},
	{["byte"] = 0x10A, ["bit"] = 5, ["name"] = "Caves: Chunky CB: Bunch on rock switch", ["type"] = "Bunch"},
	{["byte"] = 0x10A, ["bit"] = 6, ["name"] = "Caves: Chunky CB: Bunch under big rock", ["type"] = "Bunch"},

	{["byte"] = 0x10B, ["bit"] = 0, ["name"] = "Caves: Chunky CB: Chunky Igloo (2)", ["type"] = "CB"},
	{["byte"] = 0x10B, ["bit"] = 1, ["name"] = "Caves: Chunky CB: Chunky Igloo (3)", ["type"] = "CB"},
	{["byte"] = 0x10B, ["bit"] = 2, ["name"] = "Caves: Chunky CB: Chunky Igloo (4)", ["type"] = "CB"},
	{["byte"] = 0x10B, ["bit"] = 3, ["name"] = "Caves: Chunky CB: Chunky Igloo (5)", ["type"] = "CB"},
	{["byte"] = 0x10B, ["bit"] = 4, ["name"] = "Caves: Chunky CB: T&S Igloo (3)", ["type"] = "CB"},
	{["byte"] = 0x10B, ["bit"] = 5, ["name"] = "Caves: Chunky CB: T&S Igloo (4)", ["type"] = "CB"},
	{["byte"] = 0x10B, ["bit"] = 6, ["name"] = "Caves: Chunky CB: T&S Igloo (5)", ["type"] = "CB"},
	{["byte"] = 0x10B, ["bit"] = 7, ["name"] = "Caves: Chunky CB: T&S Igloo (6)", ["type"] = "CB"},

	{["byte"] = 0x10C, ["bit"] = 0, ["name"] = "Caves: Tiny CB: River to 5DI (1)", ["type"] = "CB"},
	{["byte"] = 0x10C, ["bit"] = 1, ["name"] = "Caves: Tiny CB: River to 5DI (2)", ["type"] = "CB"},
	{["byte"] = 0x10C, ["bit"] = 2, ["name"] = "Caves: Tiny CB: River to 5DI (3)", ["type"] = "CB"},
	{["byte"] = 0x10C, ["bit"] = 3, ["name"] = "Caves: Tiny CB: River to 5DI (4)", ["type"] = "CB"},
	{["byte"] = 0x10C, ["bit"] = 4, ["name"] = "Caves: Tiny CB: River to 5DI (5)", ["type"] = "CB"},
	{["byte"] = 0x10C, ["bit"] = 5, ["name"] = "Caves: Tiny CB: River to 5DI (6)", ["type"] = "CB"},
	{["byte"] = 0x10C, ["bit"] = 6, ["name"] = "Caves: Tiny CB: River to 5DI (7)", ["type"] = "CB"},
	{["byte"] = 0x10C, ["bit"] = 7, ["name"] = "Caves: Tiny CB: River to 5DI (8)", ["type"] = "CB"},

	{["byte"] = 0x10D, ["bit"] = 0, ["name"] = "Caves: Lanky Coin: 5DI underwater (1)", ["type"] = "Coin"},
	{["byte"] = 0x10D, ["bit"] = 1, ["name"] = "Caves: Lanky Coin: near Lanky Cabin (1)", ["type"] = "Coin"},
	{["byte"] = 0x10D, ["bit"] = 2, ["name"] = "Caves: Lanky Coin: near Lanky Cabin (2)", ["type"] = "Coin"},
	{["byte"] = 0x10D, ["bit"] = 3, ["name"] = "Caves: Lanky Coin: near Lanky Cabin (3)", ["type"] = "Coin"},
	{["byte"] = 0x10D, ["bit"] = 4, ["name"] = "Caves: Lanky Coin: Funky underwater (1)", ["type"] = "Coin"},
	{["byte"] = 0x10D, ["bit"] = 5, ["name"] = "Caves: Lanky Coin: Funky underwater (2)", ["type"] = "Coin"},
	{["byte"] = 0x10D, ["bit"] = 6, ["name"] = "Caves: Lanky Coin: Funky underwater (3)", ["type"] = "Coin"},
	{["byte"] = 0x10D, ["bit"] = 7, ["name"] = "Caves: Tiny CB: River to 5DI (9)", ["type"] = "CB"},

	{["byte"] = 0x10E, ["bit"] = 0, ["name"] = "Caves: Lanky CB: Cranky Bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0x10E, ["bit"] = 1, ["name"] = "Caves: Lanky CB: Cranky Bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0x10E, ["bit"] = 2, ["name"] = "Caves: Lanky CB: W5 Bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x10E, ["bit"] = 3, ["name"] = "Caves: Lanky CB: W5 Bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0x10E, ["bit"] = 4, ["name"] = "Caves: Lanky CB: W5 Bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0x10E, ["bit"] = 5, ["name"] = "Caves: Lanky CB: W5 Bunch (4)", ["type"] = "Bunch"},
	{["byte"] = 0x10E, ["bit"] = 6, ["name"] = "Caves: Lanky Coin: 5DI underwater (2)", ["type"] = "Coin"},
	{["byte"] = 0x10E, ["bit"] = 7, ["name"] = "Caves: Lanky Coin: 5DI underwater (3)", ["type"] = "Coin"},

	{["byte"] = 0x10F, ["bit"] = 0, ["name"] = "Caves: Lanky CB: River to 5DC (3)", ["type"] = "CB"},
	{["byte"] = 0x10F, ["bit"] = 1, ["name"] = "Caves: Lanky CB: River to 5DC (4)", ["type"] = "CB"},
	{["byte"] = 0x10F, ["bit"] = 2, ["name"] = "Caves: Lanky CB: River to 5DC (5)", ["type"] = "CB"},
	{["byte"] = 0x10F, ["bit"] = 3, ["name"] = "Caves: Lanky CB: River to 5DC (6)", ["type"] = "CB"},
	{["byte"] = 0x10F, ["bit"] = 4, ["name"] = "Caves: Lanky CB: River to 5DC (7)", ["type"] = "CB"},
	{["byte"] = 0x10F, ["bit"] = 5, ["name"] = "Caves: Lanky CB: River to 5DC (8)", ["type"] = "CB"},
	{["byte"] = 0x10F, ["bit"] = 6, ["name"] = "Caves: Lanky CB: River to 5DC (9)", ["type"] = "CB"},
	{["byte"] = 0x10F, ["bit"] = 7, ["name"] = "Caves: Lanky CB: River to 5DC (10)", ["type"] = "CB"},

	{["byte"] = 0x110, ["bit"] = 0, ["name"] = "Caves: Lanky CB: 5DI (1)", ["type"] = "CB"},
	{["byte"] = 0x110, ["bit"] = 1, ["name"] = "Caves: Lanky CB: 5DI (2)", ["type"] = "CB"},
	{["byte"] = 0x110, ["bit"] = 2, ["name"] = "Caves: Lanky CB: 5DI (3)", ["type"] = "CB"},
	{["byte"] = 0x110, ["bit"] = 3, ["name"] = "Caves: DK CB: 5DI (1)", ["type"] = "CB"},
	{["byte"] = 0x110, ["bit"] = 4, ["name"] = "Caves: DK CB: 5DI (2)", ["type"] = "CB"},
	{["byte"] = 0x110, ["bit"] = 5, ["name"] = "Caves: DK CB: 5DI (3)", ["type"] = "CB"},
	{["byte"] = 0x110, ["bit"] = 6, ["name"] = "Caves: DK CB: 5DI (4)", ["type"] = "CB"},
	{["byte"] = 0x110, ["bit"] = 7, ["name"] = "Caves: DK CB: 5DI (5)", ["type"] = "CB"},

	{["byte"] = 0x111, ["bit"] = 0, ["name"] = "Caves: Tiny Coin: Funky (1)", ["type"] = "Coin"},
	{["byte"] = 0x111, ["bit"] = 1, ["name"] = "Caves: Tiny CB: Giant Kosha (1)", ["type"] = "Bunch"},
	{["byte"] = 0x111, ["bit"] = 2, ["name"] = "Caves: Tiny CB: Giant Kosha (2)", ["type"] = "Bunch"},
	{["byte"] = 0x111, ["bit"] = 3, ["name"] = "Caves: Tiny CB: Giant Kosha (3)", ["type"] = "Bunch"},
	{["byte"] = 0x111, ["bit"] = 4, ["name"] = "Caves: Tiny CB: Giant Kosha (4)", ["type"] = "Bunch"},
	{["byte"] = 0x111, ["bit"] = 5, ["name"] = "Caves: Tiny CB: 5DI", ["type"] = "Bunch"},
	{["byte"] = 0x111, ["bit"] = 6, ["name"] = "Caves: Lanky CB: 5DI (4)", ["type"] = "CB"},
	{["byte"] = 0x111, ["bit"] = 7, ["name"] = "Caves: Lanky CB: 5DI (5)", ["type"] = "CB"},

	{["byte"] = 0x112, ["bit"] = 0, ["name"] = "Caves: Tiny Coin: Giant Kosha (3)", ["type"] = "Coin"},
	{["byte"] = 0x112, ["bit"] = 1, ["name"] = "Caves: Tiny Coin:Air coin by W1 (1)", ["type"] = "Coin"},
	{["byte"] = 0x112, ["bit"] = 2, ["name"] = "Caves: Tiny Coin:Air coin by W1 (2)", ["type"] = "Coin"},
	{["byte"] = 0x112, ["bit"] = 3, ["name"] = "Caves: Tiny Coin: 5DI W3 (1)", ["type"] = "Coin"},
	{["byte"] = 0x112, ["bit"] = 4, ["name"] = "Caves: Tiny Coin: 5DI W3 (2)", ["type"] = "Coin"},
	{["byte"] = 0x112, ["bit"] = 5, ["name"] = "Caves: Tiny Coin: 5DI W3 (3)", ["type"] = "Coin"},
	{["byte"] = 0x112, ["bit"] = 6, ["name"] = "Caves: Tiny Coin: Funky (2)", ["type"] = "Coin"},
	{["byte"] = 0x112, ["bit"] = 7, ["name"] = "Caves: Tiny Coin: Funky (3)", ["type"] = "Coin"},

	{["byte"] = 0x113, ["bit"] = 0, ["name"] = "Caves: Tiny CB: River to 5DI (10)", ["type"] = "CB"},
	{["byte"] = 0x113, ["bit"] = 1, ["name"] = "Caves: Tiny CB: Monkeyport Igloo", ["type"] = "Bunch"},
	{["byte"] = 0x113, ["bit"] = 2, ["name"] = "Caves: Chunky Coin: W3 (2)", ["type"] = "Coin"},
	{["byte"] = 0x113, ["bit"] = 3, ["name"] = "Caves: Tiny CB: W3", ["type"] = "Bunch"},
	{["byte"] = 0x113, ["bit"] = 4, ["name"] = "Caves: Lanky CB: Bunch under rock", ["type"] = "Bunch"},
	{["byte"] = 0x113, ["bit"] = 5, ["name"] = "Caves: Chunky Coin: W3 (3)", ["type"] = "Coin"},
	{["byte"] = 0x113, ["bit"] = 6, ["name"] = "Caves: Chunky Coin: W3 (4)", ["type"] = "Coin"},
	{["byte"] = 0x113, ["bit"] = 7, ["name"] = "Caves: Chunky Coin: W3 (5)", ["type"] = "Coin"},

	{["byte"] = 0x114, ["bit"] = 0, ["name"] = "Caves: Lanky Coin: Ice Tomato (1)", ["type"] = "Coin"},
	{["byte"] = 0x114, ["bit"] = 1, ["name"] = "Caves: Lanky Coin: Ice Tomato (2)", ["type"] = "Coin"},
	{["byte"] = 0x114, ["bit"] = 2, ["name"] = "Caves: DK CB: BBlast (1)", ["type"] = "Bunch"},
	{["byte"] = 0x114, ["bit"] = 3, ["name"] = "Caves: DK Coin: BBlast (1)", ["type"] = "Coin"},
	{["byte"] = 0x114, ["bit"] = 4, ["name"] = "Caves: DK CB: BBlast (2)", ["type"] = "Bunch"},
	{["byte"] = 0x114, ["bit"] = 5, ["name"] = "Caves: DK CB: BBlast (3)", ["type"] = "Bunch"},
	{["byte"] = 0x114, ["bit"] = 6, ["name"] = "Caves: DK CB: BBlast (4)", ["type"] = "Bunch"},
	{["byte"] = 0x114, ["bit"] = 7, ["name"] = "Caves: DK Coin: BBlast (2)", ["type"] = "Coin"},

	{["byte"] = 0x115, ["bit"] = 0, ["name"] = "Caves: Diddy CB: Lower 5DC", ["type"] = "Bunch"},
	{["byte"] = 0x115, ["bit"] = 1, ["name"] = "Caves: Diddy Coin: Lower 5DC (1)", ["type"] = "Coin"},
	{["byte"] = 0x115, ["bit"] = 2, ["name"] = "Caves: Diddy Coin: Lower 5DC (2)", ["type"] = "Coin"},
	{["byte"] = 0x115, ["bit"] = 3, ["name"] = "Caves: Diddy Coin: Lower 5DC (3)", ["type"] = "Coin"},
	{["byte"] = 0x115, ["bit"] = 4, ["name"] = "Caves: Diddy Coin: Lower 5DC (4)", ["type"] = "Coin"},
	{["byte"] = 0x115, ["bit"] = 5, ["name"] = "Caves: Tiny CB: 5DC (1)", ["type"] = "Bunch"},
	{["byte"] = 0x115, ["bit"] = 6, ["name"] = "Caves: Tiny CB: 5DC (2)", ["type"] = "Bunch"},

	{["byte"] = 0x116, ["bit"] = 0, ["name"] = "Caves: DK CB: DK Cabin (1)", ["type"] = "Bunch"},
	{["byte"] = 0x116, ["bit"] = 1, ["name"] = "Caves: DK Coin: DK Cabin (1)", ["type"] = "Coin"},
	{["byte"] = 0x116, ["bit"] = 2, ["name"] = "Caves: DK Coin: DK Cabin (2)", ["type"] = "Coin"},
	{["byte"] = 0x116, ["bit"] = 3, ["name"] = "Caves: Diddy CB: Lower 5DC (1)", ["type"] = "CB"},
	{["byte"] = 0x116, ["bit"] = 4, ["name"] = "Caves: Diddy CB: Lower 5DC (2)", ["type"] = "CB"},
	{["byte"] = 0x116, ["bit"] = 5, ["name"] = "Caves: Diddy CB: Lower 5DC (3)", ["type"] = "CB"},
	{["byte"] = 0x116, ["bit"] = 6, ["name"] = "Caves: Diddy CB: Lower 5DC (4)", ["type"] = "CB"},
	{["byte"] = 0x116, ["bit"] = 7, ["name"] = "Caves: Diddy CB: Lower 5DC (5)", ["type"] = "CB"},

	{["byte"] = 0x117, ["bit"] = 0, ["name"] = "Caves: DK CB: 5DI (6)", ["type"] = "CB"},
	{["byte"] = 0x117, ["bit"] = 1, ["name"] = "Caves: DK CB: 5DI (7)", ["type"] = "CB"},
	{["byte"] = 0x117, ["bit"] = 2, ["name"] = "Caves: DK CB: 5DI Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x117, ["bit"] = 3, ["name"] = "Caves: DK CB: Rotating room", ["type"] = "Bunch"},
	{["byte"] = 0x117, ["bit"] = 4, ["name"] = "Caves Chunky CB: 5DC bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x117, ["bit"] = 5, ["name"] = "Caves Chunky CB: 5DC bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0x117, ["bit"] = 6, ["name"] = "Caves Chunky CB: 5DC bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0x117, ["bit"] = 7, ["name"] = "Caves Chunky CB: 5DC bunch (4)", ["type"] = "Bunch"},

	{["byte"] = 0x118, ["bit"] = 0, ["name"] = "Castle: DK CB: Lower Path from Tunnel (1)", ["type"] = "CB"},
	{["byte"] = 0x118, ["bit"] = 1, ["name"] = "Castle: DK CB: Lower Path from Tunnel (2)", ["type"] = "CB"},
	{["byte"] = 0x118, ["bit"] = 2, ["name"] = "Castle: DK CB: Lower Path from Tunnel (3)", ["type"] = "CB"},
	{["byte"] = 0x118, ["bit"] = 3, ["name"] = "Castle: DK CB: Lower Path from Tunnel (4)", ["type"] = "CB"},
	{["byte"] = 0x118, ["bit"] = 4, ["name"] = "Castle: DK CB: Lower Path from Tunnel (5)", ["type"] = "CB"},
	{["byte"] = 0x118, ["bit"] = 5, ["name"] = "Castle: DK CB: Lower Path from Tunnel (6)", ["type"] = "CB"},
	{["byte"] = 0x118, ["bit"] = 6, ["name"] = "Castle: DK CB: Lower Ladder", ["type"] = "CB"},
	{["byte"] = 0x118, ["bit"] = 7, ["name"] = "Castle: DK CB: Lower Path from Tunnel (7)", ["type"] = "CB"},

	{["byte"] = 0x119, ["bit"] = 0, ["name"] = "Castle: DK CB: Road to W1 (1)", ["type"] = "CB"},
	{["byte"] = 0x119, ["bit"] = 1, ["name"] = "Castle: DK CB: Road to W1 (2)", ["type"] = "CB"},
	{["byte"] = 0x119, ["bit"] = 2, ["name"] = "Castle: DK CB: Road to W1 (3)", ["type"] = "CB"},
	{["byte"] = 0x119, ["bit"] = 3, ["name"] = "Castle: DK CB: Road to W1 (4)", ["type"] = "CB"},
	{["byte"] = 0x119, ["bit"] = 4, ["name"] = "Castle: DK CB: Road to W1 (5)", ["type"] = "CB"},
	{["byte"] = 0x119, ["bit"] = 5, ["name"] = "Castle: DK CB: Road to W1 (6)", ["type"] = "CB"},
	{["byte"] = 0x119, ["bit"] = 6, ["name"] = "Castle: DK CB: Road to W1 (7)", ["type"] = "CB"},
	{["byte"] = 0x119, ["bit"] = 7, ["name"] = "Castle: DK CB: Road to W1 (8)", ["type"] = "CB"},

	{["byte"] = 0x11A, ["bit"] = 0, ["name"] = "Castle: DK CB: Bridge (1)", ["type"] = "CB"},
	{["byte"] = 0x11A, ["bit"] = 1, ["name"] = "Castle: DK CB: Road to W1 (9)", ["type"] = "CB"},
	{["byte"] = 0x11A, ["bit"] = 2, ["name"] = "Castle: DK CB: Road to W1 (10)", ["type"] = "CB"},
	{["byte"] = 0x11A, ["bit"] = 3, ["name"] = "Castle: DK CB: Road to W1 (11)", ["type"] = "CB"},
	{["byte"] = 0x11A, ["bit"] = 4, ["name"] = "Castle: DK CB: Road to W1 (12)", ["type"] = "CB"},
	{["byte"] = 0x11A, ["bit"] = 5, ["name"] = "Castle: DK CB: Road to W1 (13)", ["type"] = "CB"},
	{["byte"] = 0x11A, ["bit"] = 6, ["name"] = "Castle: DK CB: Road to W1 (14)", ["type"] = "CB"},
	{["byte"] = 0x11A, ["bit"] = 7, ["name"] = "Castle: DK CB: Road to W1 (15)", ["type"] = "CB"},

	{["byte"] = 0x11B, ["bit"] = 0, ["name"] = "Caves: Tiny CB: W3 Mini monkey", ["type"] = "Bunch"},
	{["byte"] = 0x11B, ["bit"] = 1, ["name"] = "Caves: Diddy CB: 5DC Bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x11B, ["bit"] = 2, ["name"] = "Caves: Diddy CB: 5DC Bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0x11B, ["bit"] = 3, ["name"] = "Caves: Diddy CB: 5DC Bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0x11B, ["bit"] = 4, ["name"] = "Castle: DK CB: Bridge (2)", ["type"] = "CB"},
	{["byte"] = 0x11B, ["bit"] = 5, ["name"] = "Castle: DK CB: Bridge (3)", ["type"] = "CB"},
	{["byte"] = 0x11B, ["bit"] = 6, ["name"] = "Castle: DK CB: Bridge (4)", ["type"] = "CB"},
	{["byte"] = 0x11B, ["bit"] = 7, ["name"] = "Castle: DK CB: Bridge (5)", ["type"] = "CB"},

	{["byte"] = 0x11C, ["bit"] = 0, ["name"] = "Castle: Tiny CB: Path (1)", ["type"] = "CB"},
	{["byte"] = 0x11C, ["bit"] = 1, ["name"] = "Castle: Tiny CB: Path (2)", ["type"] = "CB"},
	{["byte"] = 0x11C, ["bit"] = 2, ["name"] = "Castle: Tiny CB: Path (3)", ["type"] = "CB"},
	{["byte"] = 0x11C, ["bit"] = 3, ["name"] = "Castle: Tiny CB: Path (4)", ["type"] = "CB"},
	{["byte"] = 0x11C, ["bit"] = 4, ["name"] = "Castle: Tiny CB: Path (5)", ["type"] = "CB"},
	{["byte"] = 0x11C, ["bit"] = 5, ["name"] = "Castle: Tiny CB: Path (6)", ["type"] = "CB"},
	{["byte"] = 0x11C, ["bit"] = 6, ["name"] = "Castle: Tiny CB: Path (7)", ["type"] = "CB"},
	{["byte"] = 0x11C, ["bit"] = 7, ["name"] = "Castle: Tiny CB: Path (8)", ["type"] = "CB"},

	{["byte"] = 0x11D, ["bit"] = 0, ["name"] = "Castle: DK CB: Upper Path to W2 (1)", ["type"] = "CB"},
	{["byte"] = 0x11D, ["bit"] = 1, ["name"] = "Castle: DK CB: Upper Path to W2 (2)", ["type"] = "CB"},
	{["byte"] = 0x11D, ["bit"] = 2, ["name"] = "Castle: DK CB: Upper Path to W2 (3)", ["type"] = "CB"},
	{["byte"] = 0x11D, ["bit"] = 3, ["name"] = "Castle: DK CB: Upper Path to W2 (4)", ["type"] = "CB"},
	{["byte"] = 0x11D, ["bit"] = 4, ["name"] = "Castle: DK CB: Lower Path from Tunnel (8)", ["type"] = "CB"},
	{["byte"] = 0x11D, ["bit"] = 5, ["name"] = "Castle: DK CB: Upper Path to W2 (5)", ["type"] = "CB"},
	{["byte"] = 0x11D, ["bit"] = 6, ["name"] = "Castle: Tiny CB: Path (9)", ["type"] = "CB"},
	{["byte"] = 0x11D, ["bit"] = 7, ["name"] = "Castle: Tiny CB: Path (10)", ["type"] = "CB"},

	{["byte"] = 0x11E, ["bit"] = 0, ["name"] = "Castle: DK CB: Upper Path to W2 (6)", ["type"] = "CB"},
	{["byte"] = 0x11E, ["bit"] = 1, ["name"] = "Castle: DK CB: Upper Path to W2 (7)", ["type"] = "CB"},
	{["byte"] = 0x11E, ["bit"] = 2, ["name"] = "Castle: DK CB: Upper Path to W2 (8)", ["type"] = "CB"},
	{["byte"] = 0x11E, ["bit"] = 3, ["name"] = "Castle: DK CB: Upper Path to W2 (9)", ["type"] = "CB"},
	{["byte"] = 0x11E, ["bit"] = 4, ["name"] = "Castle: DK CB: Upper Path to W2 (10)", ["type"] = "CB"},
	{["byte"] = 0x11E, ["bit"] = 5, ["name"] = "Castle: DK CB: Upper Path to W2 (11)", ["type"] = "CB"},
	{["byte"] = 0x11E, ["bit"] = 6, ["name"] = "Castle: DK CB: Upper Path to W2 (12)", ["type"] = "CB"},
	{["byte"] = 0x11E, ["bit"] = 7, ["name"] = "Castle: DK CB: Upper Path to W2 (13)", ["type"] = "CB"},

	{["byte"] = 0x11F, ["bit"] = 0, ["name"] = "Castle: DK CB: Upper Path to W2 (14)", ["type"] = "CB"},
	{["byte"] = 0x11F, ["bit"] = 1, ["name"] = "Castle: DK CB: Upper Path to W2 (15)", ["type"] = "CB"},
	{["byte"] = 0x11F, ["bit"] = 2, ["name"] = "Castle: DK CB: Upper Path to W2 (16)", ["type"] = "CB"},
	{["byte"] = 0x11F, ["bit"] = 3, ["name"] = "Castle: DK CB: Upper Path to W2 (17)", ["type"] = "CB"},
	{["byte"] = 0x11F, ["bit"] = 4, ["name"] = "Castle: DK CB: Upper Path to W2 (18)", ["type"] = "CB"},
	{["byte"] = 0x11F, ["bit"] = 5, ["name"] = "Castle: DK CB: Upper Path to W2 (19)", ["type"] = "CB"},
	{["byte"] = 0x11F, ["bit"] = 6, ["name"] = "Castle: DK CB: Upper Path to W2 (20)", ["type"] = "CB"},
	{["byte"] = 0x11F, ["bit"] = 7, ["name"] = "Castle: DK CB: Upper Path to W2 (21)", ["type"] = "CB"},

	{["byte"] = 0x120, ["bit"] = 0, ["name"] = "Castle: Tiny CB: path to W5 (1)", ["type"] = "CB"},
	{["byte"] = 0x120, ["bit"] = 1, ["name"] = "Castle: Tiny CB: path to W5 (2)", ["type"] = "CB"},
	{["byte"] = 0x120, ["bit"] = 2, ["name"] = "Castle: Tiny CB: path to W5 (3)", ["type"] = "CB"},
	{["byte"] = 0x120, ["bit"] = 3, ["name"] = "Castle: Tiny CB: path to W5 (4)", ["type"] = "CB"},
	{["byte"] = 0x120, ["bit"] = 4, ["name"] = "Castle: Tiny CB: path to W5 (5)", ["type"] = "CB"},
	{["byte"] = 0x120, ["bit"] = 5, ["name"] = "Castle: Tiny CB: path to W5 (6)", ["type"] = "CB"},
	{["byte"] = 0x120, ["bit"] = 6, ["name"] = "Castle: Tiny CB: path to W5 (7)", ["type"] = "CB"},
	{["byte"] = 0x120, ["bit"] = 7, ["name"] = "Castle: Tiny CB: path to W5 (8)", ["type"] = "CB"},

	{["byte"] = 0x121, ["bit"] = 0, ["name"] = "Castle: Tiny CB: path to W5 (9)", ["type"] = "CB"},
	{["byte"] = 0x121, ["bit"] = 1, ["name"] = "Castle: Tiny CB: path to W5 (10)", ["type"] = "CB"},
	{["byte"] = 0x121, ["bit"] = 2, ["name"] = "Castle: Tiny CB: path to W5 (11)", ["type"] = "CB"},
	{["byte"] = 0x121, ["bit"] = 3, ["name"] = "Castle: Tiny CB: path to W5 (12)", ["type"] = "CB"},
	{["byte"] = 0x121, ["bit"] = 4, ["name"] = "Castle: Tiny CB: path to W5 (13)", ["type"] = "CB"},
	{["byte"] = 0x121, ["bit"] = 5, ["name"] = "Castle: Tiny CB: path to W5 (14)", ["type"] = "CB"},
	{["byte"] = 0x121, ["bit"] = 6, ["name"] = "Castle: Tiny CB: path to W5 (15)", ["type"] = "CB"},
	{["byte"] = 0x121, ["bit"] = 7, ["name"] = "Castle: Tiny CB: path to W5 (16)", ["type"] = "CB"},

	{["byte"] = 0x122, ["bit"] = 0, ["name"] = "Castle: Tiny CB: path to W5 (17)", ["type"] = "CB"},
	{["byte"] = 0x122, ["bit"] = 1, ["name"] = "Castle: Tiny CB: path to W5 (18)", ["type"] = "CB"},
	{["byte"] = 0x122, ["bit"] = 2, ["name"] = "Castle: Tiny CB: path to W5 (19)", ["type"] = "CB"},
	{["byte"] = 0x122, ["bit"] = 3, ["name"] = "Castle: Tiny CB: path to W5 (20)", ["type"] = "CB"},
	{["byte"] = 0x122, ["bit"] = 4, ["name"] = "Castle: Tiny CB: path to W5 (21)", ["type"] = "CB"},
	{["byte"] = 0x122, ["bit"] = 5, ["name"] = "Castle: Tiny CB: path to W5 (22)", ["type"] = "CB"},
	{["byte"] = 0x122, ["bit"] = 6, ["name"] = "Castle: Tiny CB: path to W5 (23)", ["type"] = "CB"},
	{["byte"] = 0x122, ["bit"] = 7, ["name"] = "Castle: Tiny CB: path to W5 (24)", ["type"] = "CB"},

	{["byte"] = 0x123, ["bit"] = 0, ["name"] = "Castle: Tiny CB: Path (11)", ["type"] = "CB"},
	{["byte"] = 0x123, ["bit"] = 1, ["name"] = "Castle: Tiny CB: Path (12)", ["type"] = "CB"},
	{["byte"] = 0x123, ["bit"] = 2, ["name"] = "Castle: Tiny CB: path to Trashcan (1)", ["type"] = "CB"},
	{["byte"] = 0x123, ["bit"] = 3, ["name"] = "Castle: Tiny CB: path to Trashcan (2)", ["type"] = "CB"},
	{["byte"] = 0x123, ["bit"] = 4, ["name"] = "Castle: Tiny CB: path to Trashcan (3)", ["type"] = "CB"},
	{["byte"] = 0x123, ["bit"] = 5, ["name"] = "Castle: Tiny CB: path to Trashcan (4)", ["type"] = "CB"},
	{["byte"] = 0x123, ["bit"] = 6, ["name"] = "Castle: Tiny CB: path to Trashcan (5)", ["type"] = "CB"},
	{["byte"] = 0x123, ["bit"] = 7, ["name"] = "Castle: Tiny CB: path to Trashcan (6)", ["type"] = "CB"},

	{["byte"] = 0x124, ["bit"] = 0, ["name"] = "Castle: Diddy CB: BigBugBash Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x124, ["bit"] = 1, ["name"] = "Castle: Diddy Coin: Drawbridge (1)", ["type"] = "Coin"},
	{["byte"] = 0x124, ["bit"] = 2, ["name"] = "Castle: Diddy Coin: Drawbridge (2)", ["type"] = "Coin"},
	{["byte"] = 0x124, ["bit"] = 3, ["name"] = "Castle: Diddy Coin: Drawbridge (3)", ["type"] = "Coin"},
	{["byte"] = 0x124, ["bit"] = 4, ["name"] = "Castle: Diddy CB: Cranky Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x124, ["bit"] = 5, ["name"] = "Castle: Diddy Coin: near Drawbridge (1)", ["type"] = "Coin"},
	{["byte"] = 0x124, ["bit"] = 6, ["name"] = "Castle: Diddy Coin: near Drawbridge (2)", ["type"] = "Coin"},
	{["byte"] = 0x124, ["bit"] = 7, ["name"] = "Castle: Tiny CB: Ballroom Bunch", ["type"] = "Bunch"},

	{["byte"] = 0x125, ["bit"] = 0, ["name"] = "Castle: Chunky Coin: Ledge (1)", ["type"] = "Coin"},
	{["byte"] = 0x125, ["bit"] = 1, ["name"] = "Castle: Chunky Coin: Ledge (2)", ["type"] = "Coin"},
	{["byte"] = 0x125, ["bit"] = 2, ["name"] = "Castle: Chunky Coin: gravestone (1)", ["type"] = "Coin"},
	{["byte"] = 0x125, ["bit"] = 3, ["name"] = "Castle: Chunky Coin: gravestone (2)", ["type"] = "Coin"},
	{["byte"] = 0x125, ["bit"] = 4, ["name"] = "Castle: Chunky Coin: gravestone (3)", ["type"] = "Coin"},
	{["byte"] = 0x125, ["bit"] = 5, ["name"] = "Castle: Lanky Coin: Tree (1)", ["type"] = "Coin"},
	{["byte"] = 0x125, ["bit"] = 6, ["name"] = "Castle: Lanky Coin: Tree (2)", ["type"] = "Coin"},
	{["byte"] = 0x125, ["bit"] = 7, ["name"] = "Castle: Diddy Coin: Drawbridge (4)", ["type"] = "Coin"},

	{["byte"] = 0x126, ["bit"] = 0, ["name"] = "Castle: DK Coin: W2 (1)", ["type"] = "Coin"},
	{["byte"] = 0x126, ["bit"] = 1, ["name"] = "Castle: DK Coin: W2 (2)", ["type"] = "Coin"},
	{["byte"] = 0x126, ["bit"] = 4, ["name"] = "Castle: Tiny Coin: Gravestone (1)", ["type"] = "Coin"},
	{["byte"] = 0x126, ["bit"] = 5, ["name"] = "Castle: Tiny Coin: Gravestone (2)", ["type"] = "Coin"},
	{["byte"] = 0x126, ["bit"] = 6, ["name"] = "Castle: Tiny Coin: Gravestone (3)", ["type"] = "Coin"},
	{["byte"] = 0x126, ["bit"] = 7, ["name"] = "Castle: Chunky Coin: Ledge (3)", ["type"] = "Coin"},

	{["byte"] = 0x127, ["bit"] = 3, ["name"] = "Castle: Tiny CB: W5 Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x127, ["bit"] = 4, ["name"] = "Castle: DK Coin: Tiny BP (1)", ["type"] = "Coin"},
	{["byte"] = 0x127, ["bit"] = 5, ["name"] = "Castle: DK Coin: Tiny BP (2)", ["type"] = "Coin"},
	{["byte"] = 0x127, ["bit"] = 6, ["name"] = "Castle: DK Coin: Tiny BP (3)", ["type"] = "Coin"},
	{["byte"] = 0x127, ["bit"] = 7, ["name"] = "Castle: DK Coin: W2 (3)", ["type"] = "Coin"},

	{["byte"] = 0x128, ["bit"] = 0, ["name"] = "Castle: Tiny CB: Museum display bunch", ["type"] = "Bunch"},
	{["byte"] = 0x128, ["bit"] = 1, ["name"] = "Castle: Chunky CB: Museum bunch", ["type"] = "Bunch"},
	{["byte"] = 0x128, ["bit"] = 2, ["name"] = "Castle: Chunky Coin: Museum (1)", ["type"] = "Coin"},
	{["byte"] = 0x128, ["bit"] = 3, ["name"] = "Castle: Chunky Coin: Museum (2)", ["type"] = "Coin"},
	{["byte"] = 0x128, ["bit"] = 4, ["name"] = "Castle: Chunky Coin: Museum (3)", ["type"] = "Coin"},
	{["byte"] = 0x128, ["bit"] = 5, ["name"] = "Castle: DK CB: Library Bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x128, ["bit"] = 6, ["name"] = "Castle: DK CB: Library Bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0x128, ["bit"] = 7, ["name"] = "Castle: DK CB: Library Bunch (3)", ["type"] = "Bunch"},

	{["byte"] = 0x129, ["bit"] = 0, ["name"] = "Castle: Chunky Coin: Coffin (1)", ["type"] = "Coin"},
	{["byte"] = 0x129, ["bit"] = 1, ["name"] = "Castle: Chunky Coin: Coffin (2)", ["type"] = "Coin"},
	{["byte"] = 0x129, ["bit"] = 2, ["name"] = "Castle: Diddy CB: Crypt Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x129, ["bit"] = 3, ["name"] = "Castle: Diddy Coin: Coffin (1)", ["type"] = "Coin"},
	{["byte"] = 0x129, ["bit"] = 4, ["name"] = "Castle: Diddy Coin: Coffin (2)", ["type"] = "Coin"},
	{["byte"] = 0x129, ["bit"] = 5, ["name"] = "Castle: Diddy Coin: Coffin (3)", ["type"] = "Coin"},
	{["byte"] = 0x129, ["bit"] = 6, ["name"] = "Castle: Tiny CB: car race Bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x129, ["bit"] = 7, ["name"] = "Castle: Tiny CB: car race Bunch (2)", ["type"] = "Bunch"},

	{["byte"] = 0x12A, ["bit"] = 0, ["name"] = "Castle: Tiny Coin: Goohands (1)", ["type"] = "Coin"},
	{["byte"] = 0x12A, ["bit"] = 1, ["name"] = "Castle: Lanky Coin: Orangstand GB (1)", ["type"] = "Coin"},
	{["byte"] = 0x12A, ["bit"] = 2, ["name"] = "Castle: Lanky Coin: Orangstand GB (2)", ["type"] = "Coin"},
	{["byte"] = 0x12A, ["bit"] = 3, ["name"] = "Castle: Lanky Coin: Orangstand GB (3)", ["type"] = "Coin"},
	{["byte"] = 0x12A, ["bit"] = 4, ["name"] = "Castle: DK CB: Crypt Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x12A, ["bit"] = 5, ["name"] = "Castle: Chunky CB: Coffin bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x12A, ["bit"] = 6, ["name"] = "Castle: Chunky CB: Coffin bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0x12A, ["bit"] = 7, ["name"] = "Castle: Chunky Coin: Coffin (3)", ["type"] = "Coin"},

	{["byte"] = 0x12B, ["bit"] = 0, ["name"] = "Castle: Tiny Coin: Ballroom (1)", ["type"] = "Coin"},
	{["byte"] = 0x12B, ["bit"] = 1, ["name"] = "Castle: Tiny Coin: Ballroom (2)", ["type"] = "Coin"},
	{["byte"] = 0x12B, ["bit"] = 2, ["name"] = "Castle: Tiny Coin: Ballroom (3)", ["type"] = "Coin"},
	{["byte"] = 0x12B, ["bit"] = 3, ["name"] = "Castle: Diddy CB: Ballrom Bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x12B, ["bit"] = 4, ["name"] = "Castle: Diddy CB: Ballrom Bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0x12B, ["bit"] = 5, ["name"] = "Castle: Diddy CB: Ballrom Bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0x12B, ["bit"] = 6, ["name"] = "Castle: Tiny CB: Crypt Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x12B, ["bit"] = 7, ["name"] = "Castle: Tiny Coin: Goohands (2)", ["type"] = "Coin"},

	{["byte"] = 0x12C, ["bit"] = 0, ["name"] = "Castle: Chunky CB: Dungeon hallway (1)", ["type"] = "CB"},
	{["byte"] = 0x12C, ["bit"] = 1, ["name"] = "Castle: Chunky CB: Dungeon hallway (2)", ["type"] = "CB"},
	{["byte"] = 0x12C, ["bit"] = 2, ["name"] = "Castle: Chunky CB: Dungeon hallway (3)", ["type"] = "CB"},
	{["byte"] = 0x12C, ["bit"] = 3, ["name"] = "Castle: Chunky CB: Dungeon hallway (4)", ["type"] = "CB"},
	{["byte"] = 0x12C, ["bit"] = 4, ["name"] = "Castle: Chunky CB: Dungeon hallway (5)", ["type"] = "CB"},
	{["byte"] = 0x12C, ["bit"] = 5, ["name"] = "Castle: Chunky CB: Dungeon hallway (6)", ["type"] = "CB"},
	{["byte"] = 0x12C, ["bit"] = 6, ["name"] = "Castle: Chunky CB: Dungeon hallway (7)", ["type"] = "CB"},
	{["byte"] = 0x12C, ["bit"] = 7, ["name"] = "Castle: Chunky CB: Dungeon hallway (8)", ["type"] = "CB"},

	{["byte"] = 0x12D, ["bit"] = 0, ["name"] = "Castle: Chunky CB: Dungeon hallway (9)", ["type"] = "CB"},
	{["byte"] = 0x12D, ["bit"] = 1, ["name"] = "Castle: Chunky CB: Dungeon hallway (10)", ["type"] = "CB"},
	{["byte"] = 0x12D, ["bit"] = 2, ["name"] = "Castle: Chunky CB: Dungeon hallway (11)", ["type"] = "CB"},
	{["byte"] = 0x12D, ["bit"] = 3, ["name"] = "Castle: Chunky CB: Dungeon hallway (12)", ["type"] = "CB"},
	{["byte"] = 0x12D, ["bit"] = 4, ["name"] = "Castle: Chunky CB: Dungeon hallway (13)", ["type"] = "CB"},
	{["byte"] = 0x12D, ["bit"] = 5, ["name"] = "Castle: Chunky CB: Dungeon hallway (14)", ["type"] = "CB"},
	{["byte"] = 0x12D, ["bit"] = 6, ["name"] = "Castle: Chunky CB: Dungeon hallway (15)", ["type"] = "CB"},
	{["byte"] = 0x12D, ["bit"] = 7, ["name"] = "Castle: Chunky CB: Dungeon hallway (16)", ["type"] = "CB"},

	{["byte"] = 0x12E, ["bit"] = 0, ["name"] = "Castle: Chunky CB: Dungeon hallway (17)", ["type"] = "CB"},
	{["byte"] = 0x12E, ["bit"] = 1, ["name"] = "Castle: Chunky CB: Dungeon hallway (18)", ["type"] = "CB"},
	{["byte"] = 0x12E, ["bit"] = 2, ["name"] = "Castle: Chunky CB: Dungeon hallway (19)", ["type"] = "CB"},
	{["byte"] = 0x12E, ["bit"] = 3, ["name"] = "Castle: Chunky CB: Dungeon hallway (20)", ["type"] = "CB"},
	{["byte"] = 0x12E, ["bit"] = 4, ["name"] = "Castle: Chunky CB: Dungeon hallway (21)", ["type"] = "CB"},
	{["byte"] = 0x12E, ["bit"] = 5, ["name"] = "Castle: Chunky CB: Dungeon hallway (22)", ["type"] = "CB"},
	{["byte"] = 0x12E, ["bit"] = 6, ["name"] = "Castle: Chunky CB: Dungeon hallway (23)", ["type"] = "CB"},
	{["byte"] = 0x12E, ["bit"] = 7, ["name"] = "Castle: Chunky CB: Dungeon hallway (24)", ["type"] = "CB"},

	{["byte"] = 0x12F, ["bit"] = 0, ["name"] = "Castle: Tiny Coin: Dungeon (1)", ["type"] = "Coin"},
	{["byte"] = 0x12F, ["bit"] = 1, ["name"] = "Castle: Tiny Coin: Dungeon (2)", ["type"] = "Coin"},
	{["byte"] = 0x12F, ["bit"] = 2, ["name"] = "Castle: Tiny Coin: Dungeon (3)", ["type"] = "Coin"},
	{["byte"] = 0x12F, ["bit"] = 3, ["name"] = "Castle: Chunky CB: Dungeon hallway (25)", ["type"] = "CB"},
	{["byte"] = 0x12F, ["bit"] = 4, ["name"] = "Castle: Chunky CB: Dungeon hallway (26)", ["type"] = "CB"},
	{["byte"] = 0x12F, ["bit"] = 5, ["name"] = "Castle: Chunky CB: Dungeon hallway (27)", ["type"] = "CB"},
	{["byte"] = 0x12F, ["bit"] = 6, ["name"] = "Castle: Chunky CB: Dungeon hallway (28)", ["type"] = "CB"},
	{["byte"] = 0x12F, ["bit"] = 7, ["name"] = "Castle: Chunky CB: Dungeon hallway (29)", ["type"] = "CB"},

	{["byte"] = 0x130, ["bit"] = 0, ["name"] = "Castle: Chunky Coin: Tree (1)", ["type"] = "Coin"},
	{["byte"] = 0x130, ["bit"] = 1, ["name"] = "Castle: DK CB: Tree Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x130, ["bit"] = 2, ["name"] = "Castle: Chunky CB: Tree Bunch", ["type"] = "Bunch"},
	{["byte"] = 0x130, ["bit"] = 3, ["name"] = "Castle: Chunky Coin: Shed (1)", ["type"] = "Coin"},
	{["byte"] = 0x130, ["bit"] = 4, ["name"] = "Castle: Chunky Coin: Shed (2)", ["type"] = "Coin"},
	{["byte"] = 0x130, ["bit"] = 5, ["name"] = "Castle: Chunky Coin: Shed (3)", ["type"] = "Coin"},
	{["byte"] = 0x130, ["bit"] = 6, ["name"] = "Castle: Chunky Coin: Shed (4)", ["type"] = "Coin"},
	{["byte"] = 0x130, ["bit"] = 7, ["name"] = "Castle: Tiny CB: Trashcan Bunch", ["type"] = "Bunch"},

	{["byte"] = 0x131, ["bit"] = 0, ["name"] = "Castle: Lanky Coin: Dungeon (1)", ["type"] = "Coin"},
	{["byte"] = 0x131, ["bit"] = 1, ["name"] = "Castle: Lanky Coin: Dungeon (2)", ["type"] = "Coin"},
	{["byte"] = 0x131, ["bit"] = 2, ["name"] = "Castle: Diddy CB: Dungeon Bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x131, ["bit"] = 3, ["name"] = "Castle: Diddy CB: Dungeon Bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0x131, ["bit"] = 4, ["name"] = "Castle: Diddy CB: Dungeon Bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0x131, ["bit"] = 5, ["name"] = "Castle: Diddy CB: Dungeon Bunch (4)", ["type"] = "Bunch"},
	{["byte"] = 0x131, ["bit"] = 6, ["name"] = "Castle: Chunky Coin: Tree (2)", ["type"] = "Coin"},
	{["byte"] = 0x131, ["bit"] = 7, ["name"] = "Castle: Chunky Coin: Tree (3)", ["type"] = "Coin"},

	{["byte"] = 0x132, ["bit"] = 0, ["name"] = "Castle: DK Coin: Dungeon (1)", ["type"] = "Coin"},
	{["byte"] = 0x132, ["bit"] = 1, ["name"] = "Castle: DK Coin: Dungeon (2)", ["type"] = "Coin"},
	{["byte"] = 0x132, ["bit"] = 2, ["name"] = "Castle: DK Coin: Dungeon (3)", ["type"] = "Coin"},
	{["byte"] = 0x132, ["bit"] = 3, ["name"] = "Castle: DK Coin: Dungeon (4)", ["type"] = "Coin"},
	{["byte"] = 0x132, ["bit"] = 4, ["name"] = "Castle: Chunky Coin: Dungeon (1)", ["type"] = "Coin"},
	{["byte"] = 0x132, ["bit"] = 5, ["name"] = "Castle: Chunky Coin: Dungeon (2)", ["type"] = "Coin"},
	{["byte"] = 0x132, ["bit"] = 6, ["name"] = "Castle: Chunky Coin: Dungeon (3)", ["type"] = "Coin"},
	{["byte"] = 0x132, ["bit"] = 7, ["name"] = "Castle: Lanky Coin: Dungeon (3)", ["type"] = "Coin"},

	{["byte"] = 0x133, ["bit"] = 0, ["name"] = "Castle: Chunky CB: Dungeon hallway (30)", ["type"] = "CB"},
	{["byte"] = 0x133, ["bit"] = 1, ["name"] = "Castle: Chunky Coin: Candy (1)", ["type"] = "Coin"},
	{["byte"] = 0x133, ["bit"] = 2, ["name"] = "Castle: Chunky Coin: Candy (2)", ["type"] = "Coin"},
	{["byte"] = 0x133, ["bit"] = 3, ["name"] = "Castle: Chunky Coin: Candy (3)", ["type"] = "Coin"},
	{["byte"] = 0x133, ["bit"] = 4, ["name"] = "Castle: Diddy Coin: Dungeon Entrance (1)", ["type"] = "Coin"},
	{["byte"] = 0x133, ["bit"] = 5, ["name"] = "Castle: Diddy Coin: Dungeon Entrance (2)", ["type"] = "Coin"},
	{["byte"] = 0x133, ["bit"] = 6, ["name"] = "Castle: Diddy Coin: Dungeon Entrance (3)", ["type"] = "Coin"},
	{["byte"] = 0x133, ["bit"] = 7, ["name"] = "Castle: DK CB: Dungeon Bunch", ["type"] = "Bunch"},

	{["byte"] = 0x134, ["bit"] = 0, ["name"] = "Castle: Lanky Coin: Crypt (1)", ["type"] = "Coin"},
	{["byte"] = 0x134, ["bit"] = 1, ["name"] = "Castle: Diddy Coin: Crypt (1)", ["type"] = "Coin"},
	{["byte"] = 0x134, ["bit"] = 2, ["name"] = "Castle: Diddy Coin: Crypt (2)", ["type"] = "Coin"},
	{["byte"] = 0x134, ["bit"] = 3, ["name"] = "Castle: Diddy Coin: Crypt (3)", ["type"] = "Coin"},

	{["byte"] = 0x135, ["bit"] = 0, ["name"] = "Castle: Lanky CB: Crypt (1)", ["type"] = "CB"},
	{["byte"] = 0x135, ["bit"] = 1, ["name"] = "Castle: Lanky CB: Crypt bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x135, ["bit"] = 2, ["name"] = "Castle: Lanky CB: Crypt (1)", ["type"] = "CB"},
	{["byte"] = 0x135, ["bit"] = 3, ["name"] = "Castle: Lanky CB: Crypt bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0x135, ["bit"] = 4, ["name"] = "Castle: Lanky CB: Crypt bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0x135, ["bit"] = 5, ["name"] = "Castle: Lanky Coin: Crypt (2)", ["type"] = "Coin"},
	{["byte"] = 0x135, ["bit"] = 6, ["name"] = "Castle: Lanky Coin: Crypt (3)", ["type"] = "Coin"},
	{["byte"] = 0x135, ["bit"] = 7, ["name"] = "Castle: Lanky Coin: Crypt (4)", ["type"] = "Coin"},

	{["byte"] = 0x136, ["bit"] = 0, ["name"] = "Castle: Lanky Coin: Greenhouse (1)", ["type"] = "Coin"},
	{["byte"] = 0x136, ["bit"] = 1, ["name"] = "Castle: Lanky Coin: Greenhouse (2)", ["type"] = "Coin"},
	{["byte"] = 0x136, ["bit"] = 2, ["name"] = "Castle: Lanky Coin: Greenhouse (3)", ["type"] = "Coin"},
	{["byte"] = 0x136, ["bit"] = 3, ["name"] = "Castle: Lanky CB: Crypt (1)", ["type"] = "CB"},
	{["byte"] = 0x136, ["bit"] = 4, ["name"] = "Castle: Lanky CB: Crypt (2)", ["type"] = "CB"},
	{["byte"] = 0x136, ["bit"] = 5, ["name"] = "Castle: Lanky CB: Crypt (3)", ["type"] = "CB"},
	{["byte"] = 0x136, ["bit"] = 6, ["name"] = "Castle: Lanky CB: Crypt (4)", ["type"] = "CB"},
	{["byte"] = 0x136, ["bit"] = 7, ["name"] = "Castle: Lanky CB: Crypt Bunch (4)", ["type"] = "Bunch"},

	{["byte"] = 0x137, ["bit"] = 0, ["name"] = "Castle: Tiny Coin: Trashcan (1)", ["type"] = "Coin"},
	{["byte"] = 0x137, ["bit"] = 1, ["name"] = "Castle: Tiny Coin: Trashcan (2)", ["type"] = "Coin"},
	{["byte"] = 0x137, ["bit"] = 2, ["name"] = "Castle: Lanky CB: Greenhouse Bunch (1)", ["type"] = "Bunch"},
	{["byte"] = 0x137, ["bit"] = 3, ["name"] = "Castle: Lanky CB: Greenhouse Bunch (2)", ["type"] = "Bunch"},
	{["byte"] = 0x137, ["bit"] = 4, ["name"] = "Castle: Lanky CB: Greenhouse Bunch (3)", ["type"] = "Bunch"},
	{["byte"] = 0x137, ["bit"] = 5, ["name"] = "Castle: Lanky CB: Greenhouse Bunch (4)", ["type"] = "Bunch"},
	{["byte"] = 0x137, ["bit"] = 6, ["name"] = "Castle: Lanky CB: Greenhouse Bunch (5)", ["type"] = "Bunch"},
	{["byte"] = 0x137, ["bit"] = 7, ["name"] = "Castle: Lanky CB: Greenhouse Bunch (6)", ["type"] = "Bunch"},
	
	{["byte"] = 0x13B, ["bit"] = 3, ["name"] = "Training Grounds: Left Tunnel Coin", ["type"] = "Coin"},
	{["byte"] = 0x13B, ["bit"] = 2, ["name"] = "Training Grounds: Center Tunnel Coin", ["type"] = "Coin"},
	{["byte"] = 0x13B, ["bit"] = 1, ["name"] = "Training Grounds: Right Tunnel Coin", ["type"] = "Coin"},

}

local function fill_flag_names()
	for i = 1, #flag_array do
		flag_names[i] = flag_array[i]["name"];
	end
end
fill_flag_names();

function isFound(byte, bit)
	for i = 1, #flag_array do
		if byte == flag_array[i]["byte"] and bit == flag_array[i]["bit"] then
			return true;
		end
	end
	return false;
end

function checkFlags()
	local flags = mainmemory.read_u24_be(flag_pointer + 1);
	local temp_value;
	local flag_found = false;
	local known_flags_found = 0;
	if flags > 0x700000 and flags < 0x7fffff - flag_block_size then
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
		local flags = mainmemory.read_u24_be(flag_pointer + 1);
		if flags > 0x700000 and flags < 0x7fffff - flag_block_size then
			local queue_item, current_value;
			for i = 1, #flag_action_queue do
				queue_item = flag_action_queue[i];
				if type(queue_item) == "table" then
					if queue_item["action_type"] == "set" then
						current_value = mainmemory.readbyte(flags + queue_item["byte"]);
						mainmemory.writebyte(flags + queue_item["byte"], set_bit(current_value, queue_item["bit"]));
						if type(queue_item["name"]) == "string" then
							dprint("Set \""..queue_item["name"].."\" at "..toHexString(queue_item["byte"]).." bit "..queue_item["bit"]);
						else
							dprint("Set flag at "..toHexString(queue_item["byte"]).." bit "..queue_item["bit"]);
						end
					elseif queue_item["action_type"] == "clear" then
						current_value = mainmemory.readbyte(flags + queue_item["byte"]);
						mainmemory.writebyte(flags + queue_item["byte"], clear_bit(current_value, queue_item["bit"]));
						if type(queue_item["name"]) == "string" then
							dprint("Cleared \""..queue_item["name"].."\" at "..toHexString(queue_item["byte"]).." bit "..queue_item["bit"]);
						else
							dprint("Cleared flag at "..toHexString(queue_item["byte"]).." bit "..queue_item["bit"]);
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

function setFlag(byte, bit)
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit <= 7 then
		table.insert(flag_action_queue, {["action_type"]="set", ["byte"]=byte, ["bit"]=bit});
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

function setFlagsByType(_type)
	setFlagByType(_type);
end

function setAllFlags()
	for byte = 0, flag_block_size do
		for bit = 0, 7 do
			setFlag(byte, bit);
		end
	end
end

function clearAllFlags()
	for byte = 0, flag_block_size do
		for bit = 0, 7 do
			clearFlag(byte, bit);
		end
	end
end

--------------------------
-- Clear flag functions --
--------------------------

function clearFlag(byte, bit)
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit <= 7 then
		table.insert(flag_action_queue, {["action_type"]="clear", ["byte"]=byte, ["bit"]=bit});
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

function clearFlagsByType(_type)
	clearFlagByType(_type);
end

--------------------------
-- Other flag functions --
--------------------------

local function flagSetButtonHandler()
	setFlagByName(forms.getproperty(form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagClearButtonHandler()
	clearFlagByName(forms.getproperty(form_controls["Flag Dropdown"], "SelectedItem"));
end

local function formatOutputString(caption, value, max)
	return caption..value.."/"..max.." or "..round(value/max * 100,2).."%";
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
		local pointer = mainmemory.read_u32_be(getKongObject() + locked_to_rainbow_coin_pointer);
		if pointer > 0x80000000 and pointer < 0x807FFFFF then
			print("Forcing TBS");
			mainmemory.write_u32_be(getKongObject() + locked_to_rainbow_coin_pointer, 0x00000000);
		end
	end
end
event.onframestart(forceTBS, "ScriptHawk - Force TBS");

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if stringContains(romName, "USA") and not stringContains(romName, "Kiosk") then
		version = "USA";
		map                    = 0x7444E7;
		file                   = 0x7467C8;
		flag_pointer           = 0x7654F4;
		menu_flags             = 0x7ED558;
		kong_object_pointer    = 0x7FBB4D;
		camera_pointer         = 0x7FB968;
		tb_void_byte           = 0x7FBB63;
		pointer_list           = 0x7FBFF0;
		kongbase               = 0x7FC950;
		global_base            = 0x7FCC41;
		security_byte          = 0x7552E0;
		security_message       = 0x75E5DC;
		frames_lag             = 0x76AF10;
		frames_real            = 0x7F0560;
		geometry_spike_pointer = 0x76FDF8;

		--Mad Jack
		MJ_state_pointer      = 0x7FDC91;
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
		jumpman_position = {0x03ECD0, 0x03ECD4};
		jumpman_velocity = {0x03ECD8, 0x03ECDC};
		jetman_position  = {0x022100, 0x022104};
		jetman_velocity  = {0x022108, 0x02210C};
	elseif stringContains(romName, "Japan") then
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
		jumpman_position = {0x03EB00, 0x03EB04};
		jumpman_velocity = {0x03EB00, 0x03EB04};
		jetman_position  = {0x022060, 0x022064};
		jetman_velocity  = {0x022068, 0x02206C};
	elseif stringContains(romName, "Kiosk") then
		version = "Kiosk";
		file                = 0x7467C8; -- TODO?
		map                 = 0x72CDE7;
		menu_flags          = 0x7ED558; -- TODO?
		kong_object_pointer = 0x7B5AFD;
		tb_void_byte        = 0x7FBB63; -- TODO?
		pointer_list        = 0x7B5E58;
		kongbase            = 0x7FC950; -- TODO
		global_base         = 0x7FCC41; -- TODO

		-- TODO: Flags?

		x_rot = 0xD8;
		y_rot = x_rot + 2;
		z_rot = y_rot + 2;

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
		for i = 1, #eep_checksum_offsets do
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

function Game.getFloor() -- TODO: Got errors with this when exiting tiny temple
	return mainmemory.readfloat(getKongObject() + floor, true);
end

function Game.getDistanceFromFloor()
	return mainmemory.readfloat(getKongObject() + distance_from_floor, true);
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
	return mainmemory.readfloat(getKongObject() + x_pos, true);
end

function Game.getYPosition()
	if map_value == arcade_map then
		return mainmemory.readfloat(jumpman_position[2], true);
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(jetman_position[2], true);
	end
	return mainmemory.readfloat(getKongObject() + y_pos, true);
end

function Game.getZPosition()
	if not isInSubGame() then
		return mainmemory.readfloat(getKongObject() + z_pos, true);
	end
	return 0;
end

function Game.setXPosition(value)
	if map_value == arcade_map then
		--mainmemory.writefloat(jumpman_position[1], value, true);
	elseif map_value == jetpac_map then
		--mainmemory.writefloat(jetman_position[1], value, true);
	else
		mainmemory.writefloat(getKongObject() + x_pos, value, true);
		mainmemory.writebyte(getKongObject() + locked_to_pad, 0x00);
		mainmemory.write_u32_be(getKongObject() + locked_to_rainbow_coin_pointer, 0x00);
	end
end

function Game.setYPosition(value)
	if map_value == arcade_map then
		--mainmemory.writefloat(jumpman_position[2], value, true);
	elseif map_value == jetpac_map then
		--mainmemory.writefloat(jetman_position[2], value, true);
	else
		mainmemory.writefloat(getKongObject() + y_pos, value, true);
		mainmemory.writebyte(getKongObject() + locked_to_pad, 0x00);
	end
end

function Game.setZPosition(value)
	if not isInSubGame() then
		mainmemory.writefloat(getKongObject() + z_pos, value, true);
		mainmemory.writebyte(getKongObject() + locked_to_pad, 0x00);
		mainmemory.write_u32_be(getKongObject() + locked_to_rainbow_coin_pointer, 0x00);
	end
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	if not isInSubGame() then
		return mainmemory.read_u16_be(getKongObject() + x_rot);
	end
	return 0;
end

function Game.getYRotation()
	if not isInSubGame() then
		return mainmemory.read_u16_be(getKongObject() + y_rot);
	end
	return 0;
end

function Game.getZRotation()
	if not isInSubGame() then
		return mainmemory.read_u16_be(getKongObject() + z_rot);
	end
	return 0;
end

function Game.setXRotation(value)
	if not isInSubGame() then
		mainmemory.write_u16_be(getKongObject() + x_rot, value);
	end
end

function Game.setYRotation(value)
	if not isInSubGame() then
		mainmemory.write_u16_be(getKongObject() + y_rot, value);
	end
end

function Game.setZRotation(value)
	if not isInSubGame() then
		mainmemory.write_u16_be(getKongObject() + z_rot, value);
	end
end

-----------------------------
-- Velocity & Acceleration --
-----------------------------

function Game.getVelocity()
	if map_value == arcade_map then
		return mainmemory.readfloat(jumpman_velocity[1], true);
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(jetman_velocity[1], true);
	end
	return mainmemory.readfloat(getKongObject() + velocity, true);
end

function Game.setVelocity(value)
	if map_value == arcade_map then
		mainmemory.writefloat(jumpman_velocity[1], value, true);
	elseif map_value == jetpac_map then
		mainmemory.writefloat(jetman_velocity[1], value, true);
	else
		mainmemory.writefloat(getKongObject() + velocity, value, true);
	end
end

--function Game.getAcceleration()
--	if not isInSubGame() then
--		return mainmemory.readfloat(getKongObject() + acceleration, true);
--	end
--	return 0;
--end

function Game.getYVelocity()
	if map_value == arcade_map then
		return mainmemory.readfloat(jumpman_velocity[2], true);
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(jetman_velocity[2], true);
	end
	return mainmemory.readfloat(getKongObject() + y_velocity, true);
end

function Game.setYVelocity(value)
	if map_value == arcade_map then
		mainmemory.writefloat(jumpman_velocity[2], value, true);
	elseif map_value == jetpac_map then
		mainmemory.writefloat(jetman_velocity[2], value, true);
	else
		mainmemory.writefloat(getKongObject() + y_velocity, value, true);
	end
end

function Game.getYAcceleration()
	if not isInSubGame() then
		return mainmemory.readfloat(getKongObject() + y_acceleration, true);
	end
	return 0;
end

--------------------
-- Misc functions --
--------------------

local function invisify()
	mainmemory.writebyte(getKongObject() + visibility, 0x00);
end

local function visify()
	mainmemory.writebyte(getKongObject() + visibility, 0x7F);
end

local current_invisify = "Invisify";
local function toggle_invisify()
	if current_invisify == "Invisify" then
		invisify();
		current_invisify = "Visify";
	else
		visify();
		current_invisify = "Invisify";
	end

	forms.settext(form_controls["Toggle Invisify Button"], current_invisify);
end

local function clear_tb_void()
	local tb_void_byte_val = mainmemory.readbyte(tb_void_byte);
	mainmemory.writebyte(tb_void_byte, bit.bor(tb_void_byte_val, 0x30));
end

function force_pause()
	mainmemory.writebyte(tb_void_byte, 0x31);
end

function force_zipper()
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
		gui.text(16, 16, "ISG Timer: "..timer_string, nil, nil, 'topright');
	else
		gui.text(16, 16, "Waiting for ISG", nil, nil, 'topright');
	end
end

-----------------------------------
-- DK64 - Mad Jack Minimap
-- Written by Isotarge, 2014-2015
-----------------------------------
local script_root = "Lua/ScriptHawk";

-- Colors (ARGB)
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
local MJ_minimap_actions_remaining_y = MJ_minimap_phase_number_y + MJ_minimap_height;
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
		local MJ_state = mainmemory.read_u24_be(MJ_state_pointer);

		local cur_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_current_pos));
		local next_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_next_pos));

		local white_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_white_switch_pos));
		local blue_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + MJ_blue_switch_pos));

		local switches_active = white_pos.active or blue_pos.active;

		local row, col, x, y, color;

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

-- Pointers
local slope_object_pointer = 0x7f94b9; -- TODO - Find on PAL & JP

-- Relative to slope object
local slope_timer = 0xc3;

local function neverSlip()
	-- Patch the slope timer
	local slope_object = mainmemory.read_u24_be(slope_object_pointer);
	mainmemory.writebyte(slope_object + slope_timer, 0);

	-- Patch the Kong object
	local slope_value = mainmemory.read_u8(getKongObject() + slope_byte);
	--mainmemory.writebyte(getKongObject() + slope_byte, math.max(3, slope_value));
	mainmemory.writebyte(getKongObject() + slope_byte + 1, 0xFE);
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

event.onloadstate(break_geometry_spiking, "ScriptHawk - Break spiking");

local stored_y_addresses = {
	0x7480DC,
	0x7F948C,
	0x7F94F8,
	0x7F94E8
};

local function apply_spiking_fix()
	-- Old fix basically crashes sound thread, seems to work well but... no sound.
	mainmemory.write_u32_be(geometry_spike_pointer, freeze_value);
	--return;

	--local xPos = Game.getXPosition();
	--local yPos = Game.getYPosition();
	--local zPos = Game.getZPosition();
	
	-- TODO: Set every stored position to these values
	--for i = 1, #stored_y_addresses do
	--	mainmemory.writefloat(stored_y_addresses[i], yPos, true);
	--end
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

function everythingIsKong()
	local kongSharedModel = mainmemory.read_u32_be(getKongObject() + model_pointer);

	if not isPointer(kongSharedModel) then
		print("This ain't gonna work...");
		return;
	end

	local kongNumBones = mainmemory.readbyte(kongSharedModel - 0x80000000 + num_bones);

	local cameraObject = mainmemory.read_u24_be(camera_pointer + 1);
	local actorListIndex = 0;

	for actorListIndex = 0, max_objects do
		local pointer = mainmemory.read_u24_be(pointer_list + (actorListIndex * 4) + 1);
		local objectFound = pointer > 0x000000 and pointer < 0x7FFFFF;

		if objectFound and (pointer ~= cameraObject) then
			local modelPointer = mainmemory.read_u24_be(pointer + model_pointer + 1);
			local hasModel = modelPointer > 0x000000 and modelPointer < 0x7FFFFF;

			local actorType = mainmemory.read_u32_be(pointer + actor_type);
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
		mainmemory.writefloat(getKongObject() + scale[i], value, true);
	end
end

function Game.randomEffect()
	-- Randomly manipulate the effect byte
	local randomEffect = math.random(0, 0xffff);
	mainmemory.write_u16_be(getKongObject() + effect_byte, randomEffect);

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
	local cameraObject = mainmemory.read_u24_be(camera_pointer + 1);

	for actorListIndex = 0, max_objects do
		local pointer = mainmemory.read_u24_be(pointer_list + (actorListIndex * 4) + 1);
		local objectFound = pointer < 0x7fffff and pointer > 0x000000;

		if objectFound and pointer ~= cameraObject then
			local objectRenderingParameters = mainmemory.read_u24_be(pointer + rendering_parameters_pointer + 1);
			if objectRenderingParameters > 0x000000 and objectRenderingParameters < 0x7fffff then
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
	if version == "JP" then
		message = toJPString(message);
	else
		message = string.upper(message);
	end
	if version ~= "Kiosk" then
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
		mainmemory.writebyte(security_byte, 0x01);
		local messageLength = math.min(string.len(brb_message), brb_message_max_length);
		for i = 1, messageLength do
			mainmemory.writebyte(security_message + i - 1, string.byte(brb_message, i));
		end
		mainmemory.writebyte(security_message + messageLength, 0x00);
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

local hookBase = 0x7494;
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

------------
-- Events --
------------

local function unlock_moves()
	for kong = DK, Chunky do
		local base = kongbase + kong * 0x5E;
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

function Game.setMap(value)
	if value >= 1 and value <= #Game.maps then
		mainmemory.writebyte(map, value - 1);
	end
end

function Game.initUI(form_handle, col, row, button_height, label_offset, dropdown_offset)
	-- Flag stuff
	form_controls["Flag Dropdown"] = forms.dropdown(form_handle, flag_names, col(0) + dropdown_offset, row(7) + dropdown_offset, col(9) + 7, button_height);
	form_controls["Set Flag Button"] = forms.button(form_handle, "Set", flagSetButtonHandler, col(10), row(7), 59, button_height);
	form_controls["Clear Flag Button"] = forms.button(form_handle, "Clear", flagClearButtonHandler, col(13) - 5, row(7), 59, button_height);

	-- Moon stuff
	form_controls["Moon Mode Label"] = forms.label(form_handle, "Moon:", col(10), row(2) + label_offset, 48, button_height);
	form_controls["Moon Mode Button"] = forms.button(form_handle, moon_mode, toggle_moonmode, col(13) - 20, row(2), 59, button_height);

	form_controls["Toggle MJ Minimap"] = forms.checkbox(form_handle, "MJ Minimap", col(5) + dropdown_offset, row(6) + dropdown_offset);
	form_controls["Toggle ISG Timer"] = forms.checkbox(form_handle, "ISG Timer", col(5) + dropdown_offset, row(5) + dropdown_offset);

	-- Buttons
	form_controls["Toggle Invisify Button"] = forms.button(form_handle, "Invisify", toggle_invisify, col(7), row(1), 64, button_height);
	form_controls["Clear TB Void Button"] = forms.button(form_handle, "Clear TB void", clear_tb_void, col(10), row(1), col(4) + 8, button_height);
	form_controls["Unlock Moves Button"] = forms.button(form_handle, "Unlock Moves", unlock_moves, col(10), row(4), col(4) + 8, button_height);

	--form_controls["Everything is Kong Button"] = forms.button(form_handle, "Kong", everythingIsKong, col(10), row(3), col(4) + 8, button_height);
	--form_controls["Force Pause Button"] = forms.button(form_handle, "Force Pause", force_pause, col(10), row(4), col(4) + 8, button_height);
	form_controls["Force Zipper Button"] = forms.button(form_handle, "Force Zipper", force_zipper, col(5), row(4), col(4) + 8, button_height);
	form_controls["Fix Geometry Spiking Button"] = forms.button(form_handle, "Fix Spiking", fix_geometry_spiking, col(10), row(0), col(4) + 8, button_height);
	--form_controls["Random Effect Button"] = forms.button(form_handle, "Random effect", random_effect, col(10), row(6), col(4) + 8, button_height);

	-- Lag fix
	form_controls["Decrease Lag Factor Button"] = forms.button(form_handle, "-", decrease_lag_factor, col(13) - 7, row(6), button_height, button_height);
	form_controls["Increase Lag Factor Button"] = forms.button(form_handle, "+", increase_lag_factor, col(13) + button_height - 7, row(6),button_height, button_height);
	form_controls["Lag Factor Value Label"] = forms.label(form_handle, "0", col(13) + button_height + 21, row(6) + label_offset, 54, 14);
	form_controls["Toggle Lag Fix Checkbox"] = forms.checkbox(form_handle, "Lag fix", col(10) + dropdown_offset, row(6) + dropdown_offset);

	-- Checkboxes
	form_controls["Toggle Homing Ammo Checkbox"] = forms.checkbox(form_handle, "Homing Ammo", col(0) + dropdown_offset, row(6) + dropdown_offset);
	--form_controls["Toggle Neverslip Checkbox"] = forms.checkbox(form_handle, "Never Slip", col(10) + dropdown_offset, row(5) + dropdown_offset);
	form_controls["Toggle Paper Mode Checkbox"] = forms.checkbox(form_handle, "Paper Mode", col(10) + dropdown_offset, row(5) + dropdown_offset);

	-- Output flag statistics
	flagStats();
end

function Game.unlock_menus()
	mainmemory.write_u32_be(menu_flags + 0, 0xFFFFFFFF);
	mainmemory.write_u32_be(menu_flags + 4, 0xFFFFFFFF);
end

function Game.applyInfinites()
	mainmemory.writebyte(global_base + standard_ammo, max_standard_ammo);
	if forms.ischecked(form_controls["Toggle Homing Ammo Checkbox"]) then
		mainmemory.writebyte(global_base + homing_ammo, max_homing_ammo);
	else
		mainmemory.writebyte(global_base + homing_ammo, 0);
	end
	mainmemory.writebyte(global_base + oranges, max_oranges);
	mainmemory.write_u16_be(global_base + crystals, max_crystals * 150);
	mainmemory.writebyte(global_base + film, max_film);
	mainmemory.writebyte(global_base + health, max_health);
	mainmemory.writebyte(global_base + melons, max_melons);

	for kong = DK, Chunky do
		local base = kongbase + kong * 0x5e;
		mainmemory.writebyte(base + coins, max_coins);
		mainmemory.writebyte(base + lives, max_musical_energy);
	end
end

function Game.eachFrame()
	map_value = mainmemory.readbyte(map);

	Game.unlock_menus();

	-- Lag fix
	forms.settext(form_controls["Lag Factor Value Label"], lag_factor);
	if forms.ischecked(form_controls["Toggle Lag Fix Checkbox"]) then
		fix_lag();
	end

	--if forms.ischecked(form_controls["Toggle Neverslip Checkbox"]) then
	--	neverSlip();
	--end

	if forms.ischecked(form_controls["Toggle Paper Mode Checkbox"]) then
		paperMode();
	end

	-- Mad Jack
	if forms.ischecked(form_controls["Toggle MJ Minimap"]) then
		draw_mj_minimap();
	end

	-- ISG Timer
	if forms.ischecked(form_controls["Toggle ISG Timer"]) then
		timer();
	else
		timer_started = false;
	end

	if spiking_fix then
		apply_spiking_fix();
	end

	do_brb();
	process_flag_queue();

	-- Moonkick
	if moon_mode == 'All' or (moon_mode == 'Kick' and mainmemory.readbyte(getKongObject() + kick_animation) == kick_animation_value) then
		mainmemory.writefloat(getKongObject() + y_acceleration, -2.5, true);
	end

	-- Check EEPROM checksums
	if memory.usememorydomain("EEPROM") then
		local checksum_value;
		for i = 1, #eep_checksum_offsets do
			checksum_value = memory.read_u32_be(eep_checksum_offsets[i]);
			if eep_checksum_values[i] ~= checksum_value then
				if i == 5 then
					dprint("Global flags "..i.." Checksum: "..toHexString(eep_checksum_values[i]).." -> "..toHexString(checksum_value));
				else
					dprint("Slot "..i.." Checksum: "..toHexString(eep_checksum_values[i]).." -> "..toHexString(checksum_value));
				end
				eep_checksum_values[i] = checksum_value;
			end
		end
		print_deferred();
	end
	memory.usememorydomain("RDRAM");

	forms.settext(form_controls["Toggle Invisify Button"], current_invisify);
	forms.settext(form_controls["Moon Mode Button"], moon_mode);
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
	{"Facing", Game.getYRotation},
	--{"Moving", Game.getMovingRotation}, -- TODO
	{"Rot. Z", Game.getZRotation},
};

return Game;