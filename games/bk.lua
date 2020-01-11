if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	squish_memory_table = true,
	Memory = { -- Version order: Europe, Japan, US 1.1, US 1.0
		fb_pointer = {0x282E00, 0x281E20, 0x281E20, 0x282FE0}, -- Pointer
		game_time_scale_multiplier = {0x384E60, 0x384FC0, 0x3836A0, 0x384480}, -- Float
		game_speed_coefficient = {0x3723A0, 0x372B20, 0x371020, 0x371E20}, -- Float
		frame_timer = {0x280700, 0x27F718, 0x27F718, 0x2808D8}, -- s32_be
		floor_object_pointer = {0x37CBD0, 0x37CD00, 0x37B400, 0x37C200}, -- Pointer
		carried_object_pointer = {0x37CC68, 0x37CD98, 0x37B498, 0x37C298}, -- Pointer
		slope_timer = {0x37CCB4, 0x37CDE4, 0x37B4E4, 0x37C2E4}, -- Float
		beak_bomb_available_timer = {0x37DCF0, 0x37DE20, 0x37C520, 0x37D320}, -- Float
		player_grounded = {0x37C930, 0x37CA60, 0x37B160, 0x37BF60}, -- u32_be
		wall_collisions = {0x37CC4D, 0x37CD7D, 0x37B47D, 0x37C27D}, -- u8
		moves_bitfield = {0x37CD70, 0x37CEA0, 0x37B5A0, 0x37C3A0}, -- 4 Byte, Bitfield
		x_velocity = {0x37CE88, 0x37CFB8, 0x37B6B8, 0x37C4B8}, -- Float, divide by framerate (to match dXZ,dY scale)
		y_velocity = {0x37CE8C, 0x37CFBC, 0x37B6BC, 0x37C4BC}, -- Float, divide by framerate (to match dXZ,dY scale)
		z_velocity = {0x37CE90, 0x37CFC0, 0x37B6C0, 0x37C4C0}, -- Float, divide by framerate (to match dXZ,dY scale)
		x_position = {0x37CF70, 0x37D0A0, 0x37B7A0, 0x37C5A0}, -- Float
		y_position = {0x37CF74, 0x37D0A4, 0x37B7A4, 0x37C5A4}, -- Float
		z_position = {0x37CF78, 0x37D0A8, 0x37B7A8, 0x37C5A8}, -- Float
		x_rotation = {0x37CF10, 0x37D040, 0x37B740, 0x37C540}, -- Float
		y_rotation = {0x37D060, 0x37D190, 0x37B890, 0x37C690}, -- Float
		facing_angle = {0x37D060, 0x37D190, 0x37B890, 0x37C690}, -- Float
		moving_angle = {0x37D064, 0x37D194, 0x37B894, 0x37C694}, -- Float
		z_rotation = {0x37D050, 0x37D180, 0x37B880, 0x37C680}, -- Float
		jiggy_spawn_angle = {0x37E784, 0x37E8C4, 0x37CFB4, 0x37DDB4}, -- Float
		jiggy_spawn_velocity = {0x37E788, 0x37E8C8, 0x37CFB8, 0x37DDB8}, -- Float
		gravity = {0x37CEB8, 0x37CFE8, 0x37B6E8, 0x37C4E8}, -- Float, divide by framerate
		camera_x_position = {0x37E328, 0x37E458, 0x37CB58, 0x37D958}, -- Float
		camera_y_position = {0x37E32C, 0x37E45C, 0x37CB5C, 0x37D95C}, -- Float
		camera_z_position = {0x37E330, 0x37E460, 0x37CB60, 0x37D960}, -- Float
		camera_x_rotation = {0x37E338, 0x37E468, 0x37CB68, 0x37D968}, -- Float
		camera_y_rotation = {0x37E33C, 0x37E46C, 0x37CB6C, 0x37D96C}, -- Float
		first_person_flag = {0x37CBB7, 0x37CCE7, 0x37B3E7, 0x37C1E7},
		first_person_cam_x_pos = {0x37E630, 0x37E760, 0x37CE60, 0x37DC60}, -- Float
		first_person_cam_y_pos = {0x37E634, 0x37E764, 0x37CE64, 0x37DC64}, -- Float
		first_person_cam_z_pos = {0x37E638, 0x37E768, 0x37CE68, 0x37DC68}, -- Float
		first_person_cam_x_rot = {0x37E63C, 0x37E76C, 0x37CE6C, 0x37DC6C}, -- Float
		first_person_cam_y_rot = {0x37E640, 0x37E770, 0x37CE70, 0x37DC70}, -- Float
		previous_movement_state = {0x37DB30, 0x37DC60, 0x37C360, 0x37D160},
		current_movement_state = {0x37DB34, 0x37DC64, 0x37C364, 0x37D164},
		map = {0x37F2C5, 0x37F405, 0x37DAF5, 0x37E8F5},
		ff_question_pointer = {0x383AC0, 0x383C20, 0x382300, 0x3830E0},
		ff_pattern = {0x383BA2, 0x383D02, 0x3823E2, 0x3831C2},
		collectable_base = {0x386910, 0x386A70, 0x385150, 0x385F30},
		object_array_pointer = {0x36EAE0, 0x36F260, 0x36D760, 0x36E560},
		struct_array_pointer = {0x382970, 0x382AB0, 0x3811A0, 0x381FA0},
		board_base = {0x394140, 0x394350, 0x3929C0, 0x393760},
		pause_menu_strings_base = {0x36C99C, 0x36CAF0, 0x36B6E0, 0x36C4E0},
		return_to_lair_enabled = {0x383A60, 0x383BC0, 0x3822A0, 0x383080},
		game_progress_bitfield = {0x383B88, 0x383D18, 0x3823F8, 0x3831A8},
		jiggy_bitfield = {0x383CA0, 0x383E00, 0x3824E0, 0x3832C0},
		jiggy_grabbed_behavior_struct_pointer = {0x37DE84, 0x37DFB4, 0x37C6B4, 0x37D4B4},
		honeycomb_bitfield = {0x383CC0, 0x383E20, 0x382500, 0x3832E0},
		mumbo_token_bitfield = {0x383CD0, 0x383E30, 0x382510, 0x3832F0},
		clip_vel = {-2900, -3500, -3500, -3500}, -- Minimum velocity required to clip on the Y axis -- TODO: This seems to be different for different geometry
	},
	defaultFloor = -9000,
	speedy_speeds = { .1, 1, 5, 10, 20, 35, 50, 75, 100 },
	speedy_index = 6,
	rot_speed = 0.5,
	max_rot_units = 360,
	form_height = 11,
	maps = {
		"SM - Spiral Mountain",
		"MM - Mumbo's Mountain",
		"!Unknown 0x03",
		"!Unknown 0x04",
		"TTC - Blubber's Ship",
		"TTC - Nipper's Shell",
		"TTC - Treasure Trove Cove",
		"!Unknown 0x08",
		"!Unknown 0x09",
		"TTC - Sandcastle",
		"CC - Clanker's Cavern",
		"MM - Ticker's Tower",
		"BGS - Bubblegloop Swamp",
		"Mumbo's Skull (MM)",
		"!Unknown 0x0F",
		"BGS - Mr. Vile",
		"BGS - Tiptup",
		"GV - Gobi's Valley",
		"GV - Matching Game",
		"GV - Maze",
		"GV - Water",
		"GV - Rubee's Chamber",
		"!Unknown 0x17",
		"!Unknown 0x18",
		"!Unknown 0x19",
		"GV - Sphinx",
		"MMM - Mad Monster Mansion",
		"MMM - Church",
		"MMM - Cellar",
		"Start - Nintendo",
		"Start - Rareware",
		"End Scene 2: Not 100",
		"CC - Witch Switch Room",
		"CC - Inside Clanker",
		"CC - Gold Feather Room",
		"MMM - Tumblar's Shed",
		"MMM - Well",
		"MMM - Dining Room (Napper)",
		"FP - Freezeezy Peak",
		"MMM - Room 1",
		"MMM - Room 2",
		"MMM - Room 3: Fireplace",
		"MMM - Church (Secret Room)",
		"MMM - Room 4: Bathroom",
		"MMM - Room 5: Bedroom",
		"MMM - Room 6: Floorboards",
		"MMM - Barrel",
		"Mumbo's Skull (MMM)",
		"RBB - Rusty Bucket Bay",
		"!Unknown 0x32",
		"!Unknown 0x33",
		"RBB - Engine Room",
		"RBB - Warehouse 1",
		"RBB - Warehouse 2",
		"RBB - Container 1",
		"RBB - Container 3",
		"RBB - Crew Cabin",
		"RBB - Boss Boom Box",
		"RBB - Store Room",
		"RBB - Kitchen",
		"RBB - Navigation Room",
		"RBB - Container 2",
		"RBB - Captain's Cabin",
		"CCW - Start",
		"FP - Boggy's Igloo",
		"!Unknown 0x42",
		"CCW - Spring",
		"CCW - Summer",
		"CCW - Autumn",
		"CCW - Winter",
		"Mumbo's Skull (BGS)",
		"Mumbo's Skull (FP)",
		"!Unknown 0x49",
		"Mumbo's Skull (CCW Spring)",
		"Mumbo's Skull (CCW Summer)",
		"Mumbo's Skull (CCW Autumn)",
		"Mumbo's Skull (CCW Winter)",
		"!Unknown 0x4E",
		"!Unknown 0x4F",
		"!Unknown 0x50",
		"!Unknown 0x51",
		"!Unknown 0x52",
		"FP - Inside Xmas Tree",
		"!Unknown 0x54",
		"!Unknown 0x55",
		"!Unknown 0x56",
		"!Unknown 0x57",
		"!Unknown 0x58",
		"!Unknown 0x59",
		"CCW - Zubba's Hive (Summer)",
		"CCW - Zubba's Hive (Spring)",
		"CCW - Zubba's Hive (Autumn)",
		"!Unknown 0x5D",
		"CCW - Nabnut's House (Spring)",
		"CCW - Nabnut's House (Summer)",
		"CCW - Nabnut's House (Autumn)",
		"CCW - Nabnut's House (Winter)",
		"CCW - Nabnut's Room 1 (Winter)",
		"CCW - Nabnut's Room 2 (Autumn)",
		"CCW - Nabnut's Room 2 (Winter)",
		"CCW - Top (Spring)",
		"CCW - Top (Summer)",
		"CCW - Top (Autumn)",
		"CCW - Top (Winter)",
		"Lair - MM Lobby",
		"Lair - TTC/CC Puzzle",
		"Lair - CCW Puzzle & 180 Note Door",
		"Lair - Red Cauldron Room",
		"Lair - TTC Lobby",
		"Lair - GV Lobby",
		"Lair - FP Lobby",
		"Lair - CC Lobby",
		"Lair - Statue",
		"Lair - BGS Lobby",
		"!Unknown 0x73",
		"Lair - GV Puzzle",
		"Lair - MMM Lobby",
		"Lair - 640 Note Door Room",
		"Lair - RBB Lobby",
		"Lair - RBB Puzzle",
		"Lair - CCW Lobby",
		"Lair - Floor 2, Area 5a: Crypt inside",
		"Intro - Lair 1 - Scene 1",
		"Intro - Banjo's House 1 - Scenes 3,7",
		"Intro - Spiral 'A' - Scenes 2,4",
		"Intro - Spiral 'B' - Scenes 5,6",
		"FP - Wozza's Cave",
		"Lair - Floor 3, Area 4a",
		"Intro - Lair 2",
		"Intro - Lair 3 - Machine 1",
		"Intro - Lair 4 - Game Over",
		"Intro - Lair 5",
		"Intro - Spiral 'C'",
		"Intro - Spiral 'D'",
		"Intro - Spiral 'E'",
		"Intro - Spiral 'F'",
		"Intro - Banjo's House 2",
		"Intro - Banjo's House 3",
		"RBB - Anchor room",
		"SM - Banjo's House",
		"MMM - Inside Loggo",
		"Lair - Furnace Fun",
		"TTC - Sharkfood Island",
		"Lair - Battlements",
		"File Select Screen",
		"GV - Secret Chamber",
		"Lair - Dingpot",
		"Intro - Spiral 'G'",
		"End Scene 3: All 100",
		"End Scene",
		"End Scene 4",
		"Intro - Grunty Threat 1",
		"Intro - Grunty Threat 2"
	},
};

local script_modes = { --TODO: Object analysis tools state needs to be up here for reasons, can probably be somewhere else with a clever reshuffle
	"Disabled",
	"List",
	"Examine",
	"List Struct",
	"Examine Struct",
};

local script_mode_index = 1;
local script_mode = script_modes[script_mode_index];

hide_non_animated = false;
hide_unknown_structs = true;

--------------------
-- Region/Version --
--------------------

local framebuffer = { -- Larger on PAL
	width = 292,
	height = 200,
};

local collectable_offsets = {
	skull_hourglass_timer = 4,
	propellor_timer = 12,
	christmasTree_Timer = 20,
	hourglass_Timer = 24,
	notes = 48,
	eggs = 52,
	jiggies_current_level = 56,
	red_feathers = 60,
	gold_feathers = 64,
	jinjos = 72, -- Byte, bitfield ...YPOGB
	empty_honeycombs = 76,
	health = 80,
	health_containers = 84,
	lives = 88,
	air = 92,
	blubbers_gold = 96,
	chimpys_orange = 100,
	players_vile_score = 104,
	viles_vile_score = 108,
	mumbo_tokens_on_hand = 112,
	grumblies = 116,
	yumblies = 120,
	green_presents = 124,
	blue_presents = 128,
	red_presents = 132,
	caterpillars = 136,
	acorns = 140,
	twinklies = 144,
	mumbo_tokens = 148,
	jiggies = 152,
	joker_cards = 156,
};

local max_notes = 100;
local max_eggs = 200; -- RAM:803461AC li $v0, 0x64 -- US 1.0
local max_red_feathers = 50; -- RAM:803461CC li $v0, 0x32 -- US 1.0
local max_gold_feathers = 10; -- RAM:803461E8 li $v0, 0xA -- US 1.0
local max_lives = 9;
local max_air = 6 * 600; -- 6 * 500 on PAL
local max_mumbo_tokens = 99;
local max_jiggies = 100;
local max_joker_cards = 99;

local flag_array = {};
local flag_names = {};

local eep_checksum = {
	{ address = 0x74, value = 0 }, -- Save Slot 1
	{ address = 0xEC, value = 0 }, -- Save Slot 2
	{ address = 0x164, value = 0 }, -- Save Slot 3
	{ address = 0x1DC, value = 0 }, -- Save Slot 4
	{ address = 0x1FC, value = 0 }, -- Global flags
};

function Game.detectVersion(romName, romHash)
	if Game.version == 1 then -- Europe
		flag_array = require("games.bk_flags");
		framebuffer.width = 292;
		framebuffer.height = 216;
		max_air = 6 * 500;
	elseif Game.version == 2 then -- Japan
		flag_array = require("games.bk_flags");
	elseif Game.version == 3 then -- USA 1.1
		flag_array = require("games.bk_flags");
	elseif Game.version == 4 then -- USA 1.0
		flag_array = require("games.bk_flags");
	else
		return false;
	end

	Game.objectList = require "games.bk_objects_USA";
	Game.actorArray = {};
	for k, v in pairs(Game.objectList) do
		Game.actorArray[v.id] = v.name;
	end

	-- Read EEPROM checksums
	for i = 1, #eep_checksum do
		eep_checksum[i].value = memory.read_u32_be(eep_checksum[i].address, "EEPROM");
	end

	if #flag_array > 0 then
		for i = 1, #flag_array do
			flag_names[i] = flag_array[i].name;
		end
	else
		print("Warning: No flags found");
		flag_names = {"None"};
	end

	return true;
end

-- The amount that many timers decrement per frame
function Game.getSpeed()
	return mainmemory.readfloat(Game.Memory.game_time_scale_multiplier, true) * mainmemory.readfloat(Game.Memory.game_speed_coefficient, true);
end

function Game.isGrounded()
	return mainmemory.read_u32_be(Game.Memory.player_grounded) > 0;
end

function Game.getWallCollisions()
	return mainmemory.readbyte(Game.Memory.wall_collisions);
end

local function neverSlip()
	mainmemory.writefloat(Game.Memory.slope_timer, 0.0, true);
end

function Game.getSlopeTimer()
	return mainmemory.readfloat(Game.Memory.slope_timer, true);
end

function Game.isBeakBombAvailable()
	-- Check whether the move is unlocked
	if not Game.isMoveUnlocked(Game.moves.BeakBomb) then
		return false;
	end
	-- Check whether we're flying
	if not (mainmemory.read_u32_be(Game.Memory.current_movement_state) == 36) then -- Flying
		return false;
	end
	-- Check that we've got a feather available
	if mainmemory.read_s32_be(Game.Memory.collectable_base + collectable_offsets.red_feathers) < 1 then
		return false;
	end
	-- Check that the beak bomb timer is <= zero
	local bombTimer = mainmemory.readfloat(Game.Memory.beak_bomb_available_timer, true);
	if bombTimer <= 0 then
		return true;
	end
	-- The bomb timer is decremented before it's checked next frame, so we should calculate ahead and see when it's going to happen
	local speed = Game.getSpeed();
	if speed > 0 and bombTimer > 0 then
		local framesRemaining = bombTimer / speed - 2;
		if framesRemaining <= 0 then
			return true;
		end
		return math.floor(framesRemaining + 0.5).." frames";
	end
	return false;
end

function Game.colorBeakBombAvailable()
	local bombAvailable = Game.isBeakBombAvailable();
	if type(bombAvailable) == "string" then
		return colors.yellow;
	elseif bombAvailable then
		return colors.green;
	end
end

function Game.colorSlopeTimer()
	if ScriptHawk.UI.ischecked("toggle_neverslip") then
		return colors.blue;
	end
	local slopeTimer = Game.getSlopeTimer();
	if slopeTimer >= 0.75 then
		return getColor(slopeTimer);
	end
end

--------------------------
-- Beta Menu Recreation --
--------------------------

local PauseMenuData_offsets = {
	appearenceTime = 0x00,
	string = 0x08,
	YPos = 0x0C,
	portrait = 0x0E,
	Size = 0x10,
};

local function beta_menu_recreate()
	local pause_menu_base = Game.Memory.pause_menu_strings_base;
	for i = 0, 3 do
		mainmemory.writefloat(pause_menu_base + PauseMenuData_offsets.Size * i + PauseMenuData_offsets.appearenceTime, i * 0.1, true);
		mainmemory.write_u16_be(pause_menu_base + PauseMenuData_offsets.Size * i + PauseMenuData_offsets.YPos, i * 30 + 45);
		mainmemory.writebyte(pause_menu_base + PauseMenuData_offsets.Size * i + PauseMenuData_offsets.portrait, i + 4);
	end
	mainmemory.writebyte(Game.Memory.return_to_lair_enabled , 0);
end

-----------------
-- Moves stuff --
-----------------

local move_levels = {
	["5. All Minus Swim"]  = 0x000F7FFF,
	["4. None"]            = 0x00000000,
	["3. SM 100%"]         = 0x00009DB9,
	["2. FFM Setup"]       = 0x000BFDBF,
	["1. All"]             = 0x000FFFFF,
	["0. Demo"]            = 0xFFFFFFFF
};

local function unlock_moves()
	local level = forms.gettext(ScriptHawk.UI.form_controls.moves_dropdown);
	mainmemory.write_u32_be(Game.Memory.moves_bitfield, move_levels[level]);
end

Game.moves = {
	BeakBarge = 0,
	BeakBomb = 1,
	BeakBuster = 2,
	CameraControls = 3,
	BearPunch = 4,
	ClimbTrees = 5,
	Eggs = 6,
	FeatheryFlap = 7,
	FlapFlip = 8,
	Flying = 9,
	HoldAToJumpHigher = 10,
	RatATatRap = 11,
	Roll = 12,
	ShockSpringJump = 13,
	WadingBoots = 14,
	Dive = 15,
	TalonTrot = 16,
	TurboTalonTrainers = 17,
	Wonderwing = 18,
	FirstNoteDoorMolehill = 19,
};

function Game.isMoveUnlocked(index)
	local bitfieldValue = mainmemory.read_u32_be(Game.Memory.moves_bitfield);
	return bit.check(bitfieldValue, index);
end

--------------------
-- Object Model 1 --
--------------------

-- Slot data
local slot_base = 0x08;
local slot_size = 0x180;
local max_slots = 0x100;

-- BEHAVIOR STRUCTURE
local behavior_struct = {
	[0x00] = {Name="Renderer Pointer", Type="Pointer", Fields={
		[0x04] = {Name="x_pos", Type="s16_be"},
		[0x06] = {Name="y_pos", Type="s16_be"},
		[0x08] = {Name="z_pos", Type="s16_be"},
		--[0x0A] = {Name="scale", Type="u16_be"},
		},
	},
	[0x2C] = {Name="Object Array Index (doubled)", Type="u16_be"},
	[0x2E] = {Name="Collide Able Bitfield", Type="u16_be"},
};

-- MOVEMENT STRUCTURE
local movement_struct = {
	[0x00] = {Type="Pointer", Name="Animation Object Pointer", Fields={
			[0x10] = {Type="u32_be", Name="Animation Type"},
			[0x14] = {Type="Float", Name="Animation Timer Copy"},
		},
	},
	[0x04] = {Type="Float", Name="Animation Timer"},

	[0x0C] = {Type="Float", Name="Movement Duration"},
	[0x10] = {Type="Float", Name="Animation Duration"},
	[0x14] = {Type="Float", Name="Bone Transition Duration"},

	[0x1C] = {Type="u32_be", Name="Movement State"},
	[0x20] = {Type="Byte", Name="Movement SubState"},
};

-- OBJECT1 STRUCTURE
local slot_variables = {
	[0x00] = {Type="Pointer", Name="Behavior Struct Pointer", Fields={
			behavior_struct,
		},
	},
	[0x04] = {Type="Float", Name={"X", "X Pos", "X Position"}},
	[0x08] = {Type="Float", Name={"Y", "Y Pos", "Y Position"}},
	[0x0C] = {Type="Float", Name={"Z", "Z Pos", "Z Position"}},
	[0x10] = {Type="u8", Name="State"},
	[0x14] = {Type="Pointer", Name="Movement Object Pointer", Fields={
			movement_struct,
		},
	},
	[0x28] = {Type="Float", Name="Chase Velocity"},

	[0x38] = {Type="u16_be", Name="Movement Timer"},

	[0x3B] = {Type="Byte", Name="Movement State"},

	[0x48] = {Type="Float", Name="Race path progression"},
	[0x4C] = {Type="Float", Name="Speed (rubberband)"},
	[0x50] = {Type="Float", Name={"Facing Angle", "Facing", "Rot Y", "Rot. Y", "Y Rotation"}},

	[0x60] = {Type="Float", Name="Rotation Speed"}, -- Atleast for honeycomb pieces
	[0x64] = {Type="Float", Name={"Moving Angle", "Moving", "Rot Y", "Rot. Y", "Y Rotation"}},
	[0x68] = {Type="Float", Name={"Rot X", "Rot. X", "X Rotation"}},

	--[[
	[0x7C] = {
		["Climbable Pole"] = {Type="Float", Name="Top X", "Top X Pos", "Top X Position"},
		["Mumbo Token"] = {Type="u32_be", Name="Mumbo Token Index"},
		["Empty Honeycomb Piece"] = {Type="u32_be", Name="Empty Honeycomb Index"},
	}, -- Pole Top XPos
	[0x80] = {
		["Climbable Pole"] = {Type="Float", Name="Top Y", "Top Y Pos", "Top Y Position"},
		["Jiggy"] = {Type="u32_be", Name="Mumbo Token Index"},
	},
	[0x84] = {
		["Climbable Pole"] = {Type="Float", Name="Top Z", "Top Z Pos", "Top Z Position"},
	},
	--]]

	[0xBC] = {Type="u32_be", Name="Spawn Index"},

	[0xEB] = {Type="Byte", Name="Flag 2"}, -- TODO: Better name for this, lifted from Runehero's C source
	[0xEC] = {Type="Float", Name="AnimationTimer_Copy"},
	[0xF0] = {Type="Float", Name="AnimationDuration_Copy"},

	[0xFC] = {Type="Float", Name="MovementTimer_Copy"},

	[0x110] = {Type="Float", Name={"Rot Z", "Rot. Z", "Z Rotation"}},
	[0x114] = {Type="Float", Name="Sound timer?"}, -- Also used by Conga to decide when to throw orange -- Copy of timer from animation substruct

	[0x125] = {Type="Byte", Name="Transparancy"},

	[0x127] = {Type="Byte", Name="Eye State"},
	[0x128] = {Type="Float", Name="Scale"},
	[0x12C] = {Type="Pointer", Name="Identifier", Fields={
			[0x02] = {Type="u16_be", Name="Object Index"},
			[0x04] = {Type="u16_be", Name="Model Index"},

			[0x0C] = {Type="Pointer", Name="Object Behavior Function"},
		},
	},
	[0x14C] = {Type="Pointer", Name="Bone Array 1 Pointer"},
	[0x150] = {Type="Pointer", Name="Bone Array 2 Pointer"},
};
local slot_variables_inv = {};

-- TODO: Surely this isn't needed?
local function fillBlankVariableSlots()
	local data_size = 0x04;
	for i = 0, slot_size - data_size, data_size do
		if type(slot_variables[i]) == "nil" then
			slot_variables[i] = {Type="Z4_Unknown"};
		end
	end
end
fillBlankVariableSlots();

local function getSlotBase(index)
	return slot_base + index * slot_size;
end

local function getObjectName(address)
	local animationType = "Unknown";
	if isRDRAM(address) then
		local objectIDPointer = dereferencePointer(address + 0x12C);
		if isRDRAM(objectIDPointer) then
			local objectType = mainmemory.read_u16_be(objectIDPointer + 0x02);
			animationType = Game.actorArray[objectType] or toHexString(objectType);
		end
	end
	return animationType;
end

local function getObjectModel1Pointers()
	local pointers = {};
	local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
	if isRDRAM(objectArray) then
		local num_slots = mainmemory.read_u32_be(objectArray);
		for i = 0, num_slots - 1 do
			table.insert(pointers, objectArray + getSlotBase(i)); -- TODO: Check for bone arrays before adding to table, we don't want to move stuff we can't see
		end
		--table.sort(pointers); -- I don't think we need to sort them since getSlotBase isn't reading anything
	end
	return pointers;
end

function setObjectModel1Position(pointer, x, y, z)
	if isRDRAM(pointer) then
		mainmemory.writefloat(pointer + 0x04, x, true);
		mainmemory.writefloat(pointer + 0x08, y, true);
		mainmemory.writefloat(pointer + 0x0C, z, true);
	end
end

----------------
-- Animations --
----------------

local animation_object_unknown_pointer = 0x00; -- TODO: Stop using local constants for this stuff, they're in the slot_variables array now
local animation_object_animation_type = 0x10;
local animation_object_animation_timer = 0x14;

local animation_types = {
	[0x01] = "Banjo Ducking",
	[0x02] = "Banjo Walking (Slow)",
	[0x03] = "Banjo Walking",

	[0x05] = "Banjo Punching",

	[0x07] = "Kazooie Leaving Talon Trot",
	[0x08] = "Banjo Jumping",
	[0x09] = "Banjo Dying",
	[0x0A] = "Banjo Climbing",

	[0x0C] = "Banjo Running",

	[0x0E] = "Banjo Skidding",
	[0x0F] = "Banjo Damaged", -- "Banjo Hit"
	[0x10] = "Bigbutt Charging",
	[0x11] = "Banjo Running (Wonderwing)",

	[0x15] = "Kazooie Walking (Talon Trot)",
	[0x16] = "Kazooie Entering Talon Trot",
	[0x17] = "Kazooie Flutter", -- "Kazooie Hover"
	[0x18] = "Kazooie Feathery Flap",
	[0x19] = "Kazooie Rat-A-Tat Rap (Loop)",
	[0x1A] = "Kazooie Rat-A-Tat Rap (Start)",
	[0x1B] = "Banjo Jumping (Wonderwing)",
	[0x1C] = "Kazooie Beak Barge",
	[0x1D] = "Kazooie Beak Buster",

	[0x21] = "Bigbutt Skidding",
	[0x22] = "Banjo Entering Wonderwing",
	[0x23] = "Banjo (Wonderwing)",
	[0x24] = "Yum-Yum Hopping",

	[0x26] = "Kazooie (Talon Trot)",
	[0x27] = "Kazooie Jumping (Talon Trot)",
	[0x28] = "Banjo Termite Hurt",
	[0x29] = "Banjo Termite Dying",
	[0x2A] = "Kazooie Shooting Egg",
	[0x2B] = "Kazooie Pooping Egg",
	[0x2C] = "Snippet Walking",
	[0x2D] = "Jinjo",
	[0x2E] = "Banjo Jiggy Jig",
	[0x2F] = "Jinjo Help",
	[0x30] = "Gripped Jiggy Jig", -- TODO: Better name
	[0x31] = "Jinjo Hopping",
	[0x32] = "Bigbutt Attacking",
	[0x33] = "Bigbutt Eating",
	[0x34] = "Bigbutt Kill", -- TODO: What is this exactly?
	[0x35] = "Bigbutt Alerted",
	[0x36] = "Bigbutt Walking",

	[0x38] = "Banjo Flying",
	[0x39] = "Banjo Swimming (Surface)",

	[0x3C] = "Banjo Diving",
	[0x3D] = "Banjo Shock Spring", -- TODO: Names
	[0x3E] = "Banjo Fly Crash",
	[0x3F] = "Kazooie Swimming (Underwater)",
	[0x40] = "Kazooie Wading Boots (Start)",
	[0x41] = "Kazooie Wading Boots",
	[0x42] = "Kazooie Wading Boots Walking",
	[0x43] = "Kazooie Starting Beakbomb",
	[0x44] = "Kazooie Turbo Trainers",
	[0x45] = "Kazooie Taking Flight",

	[0x47] = "Kazooie Beak Bomb",
	[0x48] = "Kazooie Shock Spring Start",
	[0x49] = "Kazooie Shock Sprint Jump",

	[0x4B] = "Banjo Backflip",
	[0x4C] = "Banjo Backflip Transition",
	[0x4D] = "Banjo Hurt",
	[0x4E] = "MM Hut Smashing",
	[0x4F] = "Banjo Water Splash",

	[0x51] = "Conga",
	[0x52] = "Conga Hurt",
	[0x53] = "Conga Defeated",
	[0x54] = "Conga Throwing",
	[0x55] = "Conga Beating Chest",
	[0x56] = "Conga Raising Arms",
	[0x57] = "Banjo Swimming", -- TODO: Details, under/surface
	[0x58] = "Banjo Swimming",
	[0x59] = "Banjo Sliding (Back)",
	[0x5A] = "Banjo Sliding (Front)",
	[0x5B] = "Chimpy Hopping",
	[0x5C] = "Chimpy",
	[0x5D] = "Chimpy Walking",
	[0x5E] = "Ticker",
	[0x5F] = "Ticker Walking",
	[0x60] = "Banjo Termite Jumping",
	[0x61] = "Banjo Backflip Ending",
	[0x62] = "Grublin",
	[0x63] = "Grublin Sneaking",
	[0x64] = "Grublin Jumping", -- TODO: Alerted?
	[0x65] = "Beehive Dying",
	[0x66] = "Kazooie Damaged (Talon Trot)",
	[0x67] = "Wading Boots",
	[0x68] = "Banjo Falling",
	[0x69] = "Banjo Riding Tumblar",
	[0x6A] = "Mumbo Sleeping",
	[0x6B] = "Mumbo Waking",
	[0x6C] = "Mumbo",
	[0x6D] = "Mumbo Transforming",
	[0x6E] = "Mumbo Unknown (0x6E)", -- TODO: What is this exactly?
	[0x6F] = "Banjo",
	[0x70] = "Banjo (Underwater)",
	[0x71] = "Banjo Swimming (Slow)",
	[0x72] = "Banjo (Holding Item)",
	[0x73] = "Banjo Walking (Holding Item)",

	[0x77] = "Banjo Lose Minigame",
	[0x78] = "Snacker Swimming",
	[0x79] = "Mumbo Concert Playing Instrument",
	[0x7A] = "Banjo Concert Angry",
	[0x7B] = "Banjo Concert Play",
	[0x7C] = "Banjo Concert End",
	[0x7D] = "Tooty Concert Start",
	[0x7E] = "Banjo Concert Start",
	[0x7F] = "Concert Cutscene",
	[0x80] = "Concert Timer",
	[0x81] = "Concert Unknown (0x81)", -- TODO: What is this exactly?
	[0x82] = "Mumbo Concert Dance",
	[0x83] = "Tooty Concert Dance",
	[0x84] = "Tooty Hopping",

	[0x8C] = "Rareware Logo Falling",

	[0x8F] = "Nintendo Logo Walking",
	[0x90] = "Nintendo Logo Shrugging",
	[0x91] = "Frog Hopping (Concert)",
	[0x92] = "Shrapnel Chasing",
	[0x93] = "Tooty Running (Concert)",
	[0x94] = "Grublin Dying",
	[0x95] = "Kazooie Taunting Banjo",
	[0x96] = "Snippet Recovering",
	[0x97] = "Snippet Dying",

	[0x9A] = "Ripper", -- TODO: Appearing?
	[0x9B] = "Ripper Chasing",

	[0x9D] = "Nibbly Chasing", -- Bat
	[0x9E] = "Tee-Hee",
	[0x9F] = "Tee-Hee Alerted",
	[0xA0] = "Pumpkin Banjo, Walking, Bouncing",
	[0xA1] = "Pumpkin Banjo Jumping",
	[0xA2] = "Conga Throwing", -- Retaliation
	[0xA3] = "Napper Sleeping",
	[0xA4] = "Napper Looking Around",
	[0xA5] = "Napper Waking",
	[0xA6] = "Napper Alerted",
	[0xA7] = "Motzhand",
	[0xA8] = "Motzhand Playing",
	[0xA9] = "Pot", -- MMM
	[0xAA] = "Yum-Yum",
	[0xAB] = "Yum-Yum Eating",
	[0xAC] = "Tee-Hee Chasing",
	[0xAD] = "Nibbly Taking Flight", -- Bat
	[0xAE] = "Nibbly", -- Bat

	[0xB0] = "Banjo Falling",
	[0xB1] = "Banjo Climbing",
	[0xB2] = "Banjo Climbing (Freeze)",
	[0xB3] = "Chump",
	[0xB4] = "Chump Chomping",
	[0xB5] = "Blubber Walking",
	[0xB6] = "Blubber Crying",
	[0xB7] = "Blubber Danceing",
	[0xB8] = "Blubber Running",
	[0xB9] = "Banjo Drowning",

	[0xBC] = "Lockup",
	[0xBD] = "Nipper Vulnerable",
	[0xBE] = "Nipper Hurt",
	[0xBF] = "Nipper Attacking",
	[0xC0] = "Nipper",
	[0xC1] = "Littlebounce", -- TODO: What is this?
	[0xC2] = "Wobblybounce", -- TODO: What is this?
	[0xC3] = "Clanker",
	[0xC4] = "Clanker Mouth Open",
	[0xC5] = "Grabba Appearing",
	[0xC6] = "Grabba Hiding",
	[0xC7] = "Grabba",
	[0xC8] = "Grabba Defeated",
	[0xC9] = "Carpet", -- GV
	[0xCA] = "Gloop Swimming",
	[0xCB] = "Gloop Blowing Bubble",
	[0xCC] = "Banjo Beak Bomb (Ending)",
	[0xCD] = "Green Grate near RBB... (4B1)", -- TODO: Better name
	[0xCE] = "Rubee",
	[0xCF] = "Histup Raised",
	[0xD0] = "Histup Rising",
	[0xD1] = "Rubee's Pot",
	[0xD2] = "Banjo Getting Up",
	[0xD3] = "Banjo Hurt (Beak Bomb)",
	[0xD4] = "Switch Down", -- Witch Switch (MM), Shock Spring Pad Switch (GV Lobby)
	[0xD5] = "Switch Up",
	[0xD6] = "Turbo Trainers",

	[0xD9] = "Gobi",
	[0xDA] = "Gobi Pulling Back",
	[0xDB] = "Flibbit Hopping",
	[0xDC] = "Gobi's Rope Pulling",
	[0xDD] = "Gobi's Rope",
	[0xDF] = "Rubee Petting Toots",
	[0xE0] = "Crocodile Banjo Walking",
	[0xE1] = "Crocodile Banjo",
	[0xE2] = "Histup Peeking", -- Snake
	[0xE3] = "Rubee",
	[0xE4] = "Rubee Playing",
	[0xE5] = "Grabba Shadow Spawning",
	[0xE6] = "Grabba Shadow",
	[0xE7] = "Grabba Shadow Hiding",
	[0xE8] = "Grabba Shadow Defeated",
	[0xE9] = "Slappa Appearing", -- Purple Hand
	[0xEA] = "Slappa Moving",
	[0xEB] = "Slappa Slapping",

	[0xEC] = "Slappa Getting up",
	[0xED] = "Ancient Ones Leave (And appear?)",
	[0xEE] = "Slappa Dying", -- Plays 0.001 seconds before he falls apart
	[0xEF] = "Slappa Hurt",
	[0xF0] = "Mini-Jinxy Eating",
	[0xF1] = "Carpet", -- GV

	[0xF4] = "Gobi Relaxing",

	[0xF6] = "Banjo Punishing Kazooie",
	[0xF7] = "Gobi Happy",
	[0xF8] = "Gobi Running",
	[0xF9] = "Buzzbomb Flying", -- cutscene dragonfly
	[0xFA] = "Flibbit", -- Frog
	[0xFB] = "Flibbit Turning",
	[0xFC] = "Gobi Giving water",
	[0xFD] = "Gobi Getting up",
	[0xFE] = "Trunker Short",
	[0xFF] = "Trunker Growing",
	-- [0x100] = "blagh.noidea", -- (Gobi's Water? 80387CBC) -- TODO: What is this
	[0x101] = "Tanktup's Head",
	[0x102] = "Tanktup's Head Pounded",
	[0x103] = "Tanktup's BL Leg Hit",
	[0x104] = "Tanktup's FL Leg Hit",
	[0x105] = "Tanktup's FR Leg Hit",
	[0x106] = "Tanktup's BR Leg Hit",
	[0x107] = "Tanktup Spawning Jiggy",
	[0x108] = "Sir Slush",
	[0x109] = "Sir Slush Attacking",

	[0x10C] = "Banjo Ducking & Turning",
	[0x10D] = "Banjo Hit (Flying)",
	[0x10E] = "Buzzbomb Prepare charge",
	[0x10F] = "Buzzbomb Charging",
	[0x110] = "Buzzbomb Falling From Sky", -- Concert
	[0x111] = "Buzzbomb Dying",
	[0x112] = "Flibbit Dying (Start)", -- Frog
	[0x113] = "Flibbit Dying (Finish)",

	[0x116] = "Banjo Look Duck", -- TODO: What are these?
	[0x117] = "Jellyfish (Unknown) 0x117", -- TODO: What are these? Whipcrack?

	[0x11B] = "Banjo Throwing Item", -- TODO: Confirm
	[0x11C] = "Crocodile Banjo Jumping",
	[0x11D] = "Crocodile Banjo Hurt",
	[0x11E] = "Crocodile Banjo Dying",
	[0x11F] = "Walrus Banjo",
	[0x120] = "Walrus Banjo Hopping",
	[0x121] = "Walrus Banjo Jumping",
	[0x122] = "Crocodile Banjo Biting",
	[0x123] = "Crocodile Banjo Grossed Out",
	[0x124] = "Mr. Vile Eating",
	[0x125] = "Red Yumblie Spawning",
	[0x126] = "Red Yumblie Leaving",
	[0x127] = "Red Yumblie",
	[0x128] = "Yellow Grumblie Spawning",
	[0x129] = "Yellow Grumblie Leaving",
	[0x12A] = "Yellow Grumblie",
	[0x12B] = "Tiptup looking around, shrugging",
	[0x12C] = "Tiptup Tapping",
	[0x12D] = "Choir",
	[0x12E] = "Choir Singing",
	[0x12F] = "Choir Hurt",
	[0x130] = "Jinjo Circling (Start)",
	[0x131] = "Jinjo Circling (End)",
	[0x132] = "Floatsam Bouncing",
	[0x133] = "Nipper Dying",

	[0x137] = "Grimlet Attacking", -- Pipe
	[0x138] = "Text Shadow Animation",
	[0x139] = "Bottles Disappearing",
	[0x13A] = "Bottles Appearing",
	[0x13B] = "Bottles Scratching",
	[0x13C] = "Bottles' Molehill", -- Bottles going in
	[0x13D] = "Bottles' Molehill", -- Bottles coming out
	[0x13E] = "Snorkel Swimming",
	[0x13F] = "Snorkel Stuck",

	[0x141] = "Anchor On Snorkel",
	[0x142] = "Anchor Rising",
	[0x143] = "Button", -- Snowman, Xmas tree
	[0x144] = "Jinxy Sniffing",
	[0x145] = "Jinxy Sneezing",
	[0x146] = "Boss Boombox Appearing",
	[0x147] = "Boombox Hopping",
	[0x148] = "Boombox Exploding",
	[0x149] = "Banjo Landing (Damaging)",
	[0x14A] = "Banjo Listening",
	[0x14B] = "Croctus", -- BGS, feed egg
	[0x14C] = "Boggy",
	[0x14D] = "Boggy Hit",
	[0x14E] = "Boggy Laying Down",
	[0x14F] = "Boggy Running",
	[0x150] = "Boggy On Sled",
	[0x151] = "Race Flag Hit",
	[0x152] = "Race Flag",
	[0x153] = "Gold Chest Spawning",
	[0x154] = "Snacker Eating ", -- Shark
	[0x155] = "Snippet Get Up",
	[0x156] = "Mutie Snippet Walking",
	[0x157] = "Mutie Snippet Flip upside down",
	[0x158] = "Mutie Snippet Stuck upside down",
	[0x159] = "Mutie Snippet Get up",
	[0x15A] = "Grille Chompa Attack",
	[0x15B] = "Grille Chompa Dying",
	[0x15C] = "Whiplash",
	[0x15D] = "Whiplash Attack",

	[0x15F] = "Concert Banjo Before Start (Keeps him off screen)",
	[0x160] = "Concert Bug Crawling",

	[0x162] = "Toots",
	[0x163] = "Cutscene Buzzbomb Smack",
	-- [0x164] = "rotatetowardground+nosegrowning and shrinking. (Toots/Happy?)", -- TODO: What is this?
	[0x165] = "Beehive",
	[0x166] = "Gold Chest Bouncing",
	[0x167] = "Banjo/MoveVeryLittle (used in small cutscenes)",
	-- [0x168] = "twisted, nose really tiny. (BeforeRareLogoAppears)", -- TODO: What is this?
	-- [0x169] = "BetaVent/Open (Shooting out smoke)", -- TODO: What is this?

	[0x16B] = "Snare-Bear Snapping",
	[0x16C] = "Snare-Bear",
	[0x16D] = "Twinkly Present Opening",
	[0x16E] = "Mumbo Reclining", -- CCW Summer
	[0x16F] = "Zubba Flying Moving",
	[0x170] = "Zubba Flying",
	[0x171] = "Zubba Falling",
	[0x172] = "Zubba Landing",
	[0x173] = "Flower Sprouting (Spring)",
	[0x174] = "Flower Sprouting (Summer)",
	[0x175] = "Flower Sprouting (Autumn)",
	[0x176] = "Gobi Yawning",
	[0x177] = "Gobi Sleeping",
	[0x178] = "Twinkly Spawning",
	[0x179] = "Boggy Signaling (Speed up slowpoke!)",
	[0x17A] = "Boggy Lookingback (On sled)",
	-- [0x17B] = "Boggy Something.." -- TODO: What is this?
	[0x17C] = "Twinkly Twinkling",
	[0x17D] = "Spawn of Boggy Happy", -- Groggy, Moggy, Soggy
	[0x17E] = "Spawn of Boggy Sad", -- Groggy, Moggy, Soggy
	[0x17F] = "Mumbo Sweeping",
	[0x180] = "Mumbo Rotating", -- With broom!
	[0x181] = "Flower (Spring)",
	[0x182] = "Flower (Summer)",
	[0x183] = "Flower (Fall)",
	[0x184] = "Big Clucker Attacking (Short)",
	[0x185] = "Big Clucker Attacking (Long)",
	[0x186] = "Big Clucker Dying",
	-- [0x187] = "rotateodd and go in ground.", -- TODO: What is this?
	[0x188] = "Pumpkin Banjo Dying",
	[0x189] = "Floatsam Dying",
	[0x18A] = "Present", -- FP

	-- [0x18D] = "rotate to standing mode, and back.", -- TODO: What is this?
	-- [0x18E] = "rock sideways gently", -- TODO: What is this?
	[0x18F] = "Spring Eyrie Yawn -> Sleep", -- Names
	[0x190] = "Spring Eyrie Baby Sleeping",
	[0x191] = "Summer Eyrie Waiting For Food",
	[0x192] = "Summer Eyrie Finished Eating > Grow",
	[0x193] = "Summer Eyrie Yawn Fall to Ground",
	[0x194] = "Summer Eyrie Sleeping",
	[0x195] = "Fall Eyrie Waiting For Food",
	[0x196] = "Fall Eyrie Finished Eating > Grow",
	[0x197] = "Fall Eyrie Yawn Fall to Ground",
	[0x198] = "Fall Eyrie Sleeping",
	[0x199] = "Winter Eyrie Tweet-Tweet",
	[0x19A] = "Winter Eyire Tweet > Flying",
	[0x19B] = "Banjo Transforming",
	[0x19C] = "Walrus Banjo Hurt",
	[0x19D] = "Walrus Banjo Dying",
	[0x19E] = "Walrus Banjo On Sled",
	[0x19F] = "Walrus Banjo Before Lose Race",
	[0x1A0] = "Unknown Dying (0x1A0)",
	[0x1A1] = "Sled", -- FP
	[0x1A2] = "Nabnut Sleeping",
	[0x1A3] = "Nabnut",
	[0x1A4] = "Nabnut Eating",

	[0x1A6] = "Gnawty",
	[0x1A7] = "Gnawty Happy",
	[0x1A8] = "Gnawty Walking",
	[0x1A9] = "Banjo Walrus Lost Race",
	[0x1AA] = "Boggy Won Race",
	[0x1AB] = "Boggy Lost Race",
	[0x1AC] = "Wozza Holding Jiggy",
	[0x1AD] = "Wozza Handing Jiggy",
	[0x1AE] = "Wozza Hopping Away",
	[0x1AF] = "Twinkly Muncher Dying",
	[0x1B0] = "Twinkly Muncher Appearing",
	[0x1B1] = "Twinkly Muncher",
	[0x1B2] = "Twinkly Muncher Munching",
	[0x1B3] = "Wozza Before Stop", -- TODO: Better name
	[0x1B4] = "Wozza Bodyblocking",
	[0x1B5] = "Wozza Giving Jiggy",
	[0x1B6] = "Wozza Throwing...Freezehalfway", -- TODO: Better name
	[0x1B7] = "Green Mist", -- Intro
	[0x1B8] = "Door Opening", -- Intro
	[0x1B9] = "Grunty", -- Intro

	[0x1BB] = "Grunty Picking Nose", -- Intro

	[0x1BD] = "Grunty Angry at Dingpot ", -- Intro
	[0x1BE] = "Grunty Throwing Booger ", -- Intro
	[0x1BF] = "Grunty Shocked > Confused ", -- Intro
	[0x1C0] = "Grunty Walking", -- Intro

	[0x1C2] = "Door Closing", -- Intro

	[0x1C4] = "Grunty's Broomstick Flying", -- Intro
	[0x1C5] = "Grunty Flying", -- Intro

	[0x1C7] = "Banjo Sleeping", -- Intro
	[0x1C8] = "Banjo Waking Up", -- Intro
	[0x1C9] = "Bedsheets Banjo Sleeping", -- Intro
	[0x1CA] = "Bedsheets Banjo Awake", -- Intro
	[0x1CB] = "Kazooie Appearing", -- Intro

	[0x1CD] = "Kazooie Inside Backpack", -- Intro
	[0x1CE] = "Curtain", -- Banjo's house
	[0x1CF] = "Kazooie Uneasy",
	[0x1D0] = "Tooty Hopping",

	[0x1D3] = "Kazooie Waking Banjo",
	[0x1D4] = "Kazooie Falling",
	[0x1D5] = "Tooty Chattering Teeth",
	[0x1D6] = "Grublin Walking",
	[0x1D7] = "Grublin Alerted",
	[0x1D8] = "Grublin Chasing",
	[0x1D9] = "Grublin Dying",
	[0x1DA] = "Snippet",
	[0x1DB] = "Mutie Snippet",
	[0x1DC] = "Bee Banjo Flying",
	[0x1DD] = "Bee Banjo Walking",
	[0x1DE] = "Bee Banjo",
	[0x1DF] = "Bee Banjo Unknown 0x1DF", -- TODO: "tiyhop"
	[0x1E0] = "Bee Banjo Hurt",
	[0x1E1] = "Bee Banjo Dying",
	[0x1E2] = "Bee Banjo Jumping",
	[0x1E3] = "GV Brick Wall Smashing",
	[0x1E4] = "Limbo", -- Skeleton
	[0x1E5] = "Limbo Alerted",
	[0x1E6] = "Limbo Chasing",
	[0x1E7] = "Limbo Breaking",
	[0x1E8] = "Limbo Rising",
	[0x1E9] = "Mum-Mum",
	[0x1EA] = "Mum-Mum Curling",
	[0x1EB] = "Mum-Mum Uncurling",

	[0x1ED] = "Ripper Damaged",
	[0x1EE] = "Ripper Dying",
	-- [0x1EF] = "noseforward>back", -- TODO: Switch?
	[0x1F0] = "Web (Floor)",
	[0x1F1] = "Web Dying (Floor)",
	[0x1F2] = "Web (Wall)",
	[0x1F3] = "Web Dying (Wall)",
	[0x1F4] = "Shrapnel",
	[0x1F5] = "Jiggy Transition",
	-- [0x1F6] = "looks like some diver hitting a ground of play-doh.", -- TODO: What is this?
	[0x1F7] = "Kazooie Feathers Poof (End intro)", -- TODO: Better names
	[0x1F8] = "Bottles PointAtGrunty",
	[0x1F9] = "Tooty Confused",
	[0x1FA] = "Sexy Grunty Walking",
	[0x1FB] = "Sexy Grunty Checking herself out",
	[0x1FC] = "Ugly Tooty Walking",
	[0x1FD] = "Ugly Tooty Punching",
	[0x1FE] = "Machine Door Opening",
	[0x1FF] = "Machine Door Closing",
	[0x200] = "Static Machine Door Up",
	[0x201] = "Klungo Limping",
	[0x202] = "Klungo Pushing Button",

	[0x204] = "Grunty Falling",
	[0x205] = "Dingpot wap", -- TODO: wat
	[0x206] = "Dingpot",
	[0x207] = "Grunty Crammed in Machine",
	[0x208] = "Roysten",
	[0x209] = "Cuckoo Clock",
	[0x20A] = "Cuckoo Clock Chiming",
	[0x20B] = "Grunty Falling", -- Ending
	-- [0x20C] = "stretch,shrink, arms spread out.", -- TODO: What is this?
	[0x20D] = "Klungo Lever down",
	[0x20E] = "Machine Lever down", -- Game Over
	[0x20F] = "Klungo Laughing",
	[0x210] = "Machine", -- Ugly Tooty trying to get out
	-- [0x211] = "nosemoveleftright", -- TODO: What is this?
	[0x212] = "Cauldron Activating",
	[0x213] = "Cauldron Sleeping",
	[0x214] = "Cauldron Activated",
	[0x215] = "Cauldron Teleporting",
	[0x216] = "Cauldron Rejected",
	[0x217] = "Transform Pad",
	-- [0x218] = "spin randomly, nose stretch (Two poles...)", --TODO: Door?
	-- [0x219] = "twistedup.", -- TODO: What is this?
	[0x21A] = "Eyrie Eating", -- Summer
	[0x21B] = "Eyrie Eating", -- Autumn

	[0x21D] = "Eyrie Flying",
	[0x21E] = "Eyrie Pooping Jiggy",

	[0x220] = "Sir. Slush",
	[0x221] = "Wozza", -- In Cave
	[0x222] = "Boggy Sleeping",
	[0x223] = "Topper", -- Carrot gets it
	[0x224] = "Topper Dying",
	[0x225] = "Colliwobble",
	[0x226] = "Bawl",
	[0x227] = "Bawl Dying",
	-- [0x228] = "Banjo On led", -- TODO: wat
	[0x229] = "Whipcrack Attacking",
	[0x22A] = "Whipcrack",
	[0x22B] = "Nabnut Fat",
	[0x22C] = "Nabnut Crying",
	[0x22D] = "Nabnut Happy",
	[0x22E] = "Nabnut",
	[0x22F] = "Nabnut Running",
	[0x230] = "Mrs. Nanbut Sleeping",
	[0x231] = "Nabnut's Bedsheets",
	-- [0x232] = "freezeani", -- TODO: What is this?
	[0x233] = "Chinker", -- Ice Cube
	[0x234] = "Snare-Bear (Winter)",
	[0x235] = "Sarcophagus (GV Lobby)",
	[0x236] = "Pumpkin Banjo Hurt",
	[0x237] = "Twinkly Present",
	[0x238] = "Loggo Hop",
	[0x239] = "Leaky Hop",
	[0x23A] = "Gobi Fly", -- TODO: Is this Scabby
	[0x23B] = "Gobi Fly Prepare Attack",
	[0x23C] = "Gobi Fly Charge",
	[0x23D] = "Gobi Fly Dying",
	[0x23E] = "Portrait Chompa (Picture Monster)",
	[0x23F] = "Portrait",
	[0x240] = "Loggo Flush", -- Toilet
	-- [0x241] = "noidea..", (moveup from ground, hide in ground)
	[0x242] = "Gobi Relaxing",
	[0x243] = "Grublin-Hood",
	[0x244] = "Grublin-Hood Alerted",
	[0x245] = "Grublin-Hood Chasing",
	[0x246] = "Grublin-Hood Dying",
	-- [0x247] = "Nosebounce", -- TODO: What is this?
	-- [0x248] = "Boingboingbacktensely", -- TODO: What is this?
	-- [0x249] = "Huge.. Turnaround stop wobble wobble", -- TODO: What is this?
	[0x24A] = "Banjo Cook Cooking",
	[0x24B] = "Banjo Cook Activated",
	[0x24C] = "Banjo Cook Flip",
	[0x24D] = "Banjo On Bed Sleeping",
	[0x24E] = "Banjo On Bed Activated",
	[0x24F] = "Banjo On Bed Spring",
	[0x250] = "Banjo Playing Gameboy",
	[0x251] = "Banjo Playing Gameboy Activated",
	[0x252] = "Banjo Playing Gameboy Spring",
	[0x253] = "Big Butt Hit ", -- Bull
	[0x254] = "Big Butt Fall",
	[0x255] = "Big Butt Get Up",
	-- [0x256] = "move up from ground, go back down.",
	[0x257] = "Grunty Green Spell", -- Flying
	[0x258] = "Grunty Hurt",
	[0x259] = "Grunty Hurt",
	[0x25A] = "Grunty Fireball Spell", -- Flying
	[0x25B] = "Nabnut Acorn Bouncing",
	[0x25C] = "Grunty Phase 1 Swooping",
	-- [0x25D] = "Grunty SmackOnCastle Fixselfup Hopup", -- TODO: What is this?
	[0x25E] = "Grunty Phase 1 Vulnerable",
	[0x25F] = "Grunty",
	[0x260] = "Grunty Fireball Spell", -- Landed
	[0x261] = "Grunty Green Spell", -- Landed
	[0x262] = "Jinjo Statue Rising", -- TODO: Also diving?
	[0x263] = "Grunty Fall off Broom",
	[0x264] = "Jinjo Statue Activating",
	[0x265] = "Jinjo Statue",
	-- [0x266] = "Grunty/Falling down tower", -- TODO: What is this?
	-- [0x267] = "Grunty?", -- TODO: What is this?
	[0x268] = "Big Blue Egg",
	[0x269] = "Big Red Feather",
	[0x26A] = "Big Gold Feather",
	[0x26B] = "Brentilda",
	[0x26C] = "Brentilda Hands on Hips",
	[0x26D] = "Gruntling",
	[0x26E] = "Gruntling Alerted", -- RARR
	[0x26F] = "Gruntling Chasing",
	[0x270] = "Gruntling Dying",
	[0x271] = "DoG", -- TODO: Verify
	[0x272] = "Cheato",
	[0x273] = "Snacker Hurt",
	[0x274] = "Snacker Dying",
	[0x275] = "Jinjonator Activating", -- TODO: Verify
	[0x276] = "Jinjonator Charging",
	-- [0x277] = "Jinjonator ReadyToAttackPose (I think)" -- TODO: Verify
	[0x278] = "Jinjonator Recoil",
	-- [0x279] = "Grunty JawDrop > Shiver", -- TODO: Verify
	[0x27A] = "Grunty Hurt by Jinjonator",
	[0x27B] = "Jinjonator? (spin spin spin, stop far way, shake)", -- TODO: What is this?
	[0x27C] = "Jinjonator Charging",
	[0x27D] = "Jinjonator Final Hit",
	[0x27E] = "Jinjonator Taking Flight",
	[0x27F] = "Jinjonator Circling",
	[0x280] = "Jinjonator Attacking",
	[0x281] = "Wishy-Washy-Banjo 'Doooohh....'",
	[0x282] = "Banjo Unlocking Note Door",
	[0x283] = "Grunty Chattering Teeth",
	[0x284] = "PRESS START Appearing",
	[0x285] = "PRESS START",
	[0x286] = "NO CONTROLLER Appearing",
	[0x287] = "NO CONTROLLER",
	[0x288] = "Flibbit Hurt",
	[0x289] = "Gnawty Swimming",
	[0x28A] = "Grunty's Washing Machine", -- Furnace Fun
	[0x28B] = "Grunty",
	[0x28C] = "Grunty Doll",
	[0x28D] = "Grunty Walking",
	[0x28E] = "Tooty Looking Around",
	[0x28F] = "Dingpot",
	[0x290] = "Dingpot Shooting",
	[0x291] = "Mumbo Flipping Food",
	[0x292] = "Food Flipping",
	[0x293] = "Banjo Drinking",
	[0x294] = "Mumbo Screaming",
	[0x295] = "Banjo's Chair Breaking", -- Also music trigger for N64 Cutscene
	[0x296] = "Bottles Eating corn",
	[0x297] = "Mumbo Skidding", -- Giving flower to Sexy Grunty

	[0x299] = "Bottles Falling off chair",
	[0x29A] = "Banjo Drunk", -- Ending
	[0x29B] = "Kazooie Hits Banjo",
	[0x29C] = "Yellow Jinjo Waving & Whistling", -- Ending
	[0x29D] = "Melon Babe Walking",
	[0x29E] = "Blubber On Jetski",
	[0x29F] = "Blubber Cheering on JetSki",
	-- [0x2A0] = "Drapes Boom Up", -- TODO: What is this?
	[0x2A1] = "Banjo's Hand Dropping Jiggy",
	[0x2A2] = "Banjo's Hand",
	[0x2A3] = "Banjo's Hand Turning Jiggy (Right)",
	[0x2A4] = "Banjo's Hand Turning Jiggy (Left)",
	[0x2A5] = "Banjo's Hand Grabbing Jiggy",
	[0x2A6] = "Banjo's Hand Thumbs Up",
	[0x2A7] = "Banjo's Hand Placing Jiggy",
	[0x2A8] = "Banjo's Hand Thumbs Down",
	[0x2A9] = "Nibbly Falling", -- Bat
	[0x2AA] = "Nibbly Dying", -- Bat
	[0x2AB] = "Tee-Hee Dying",
	[0x2AC] = "Grunty Upset", -- After Banjo completes Furnace Fun
	[0x2AD] = "Grunty Looking",
	[0x2AE] = "Tree Shaking (Mumbo)", -- TODO: Better names from here on
	[0x2AF] = "Mumbo Sliding down tree",
	[0x2B0] = "Mumbo on tree (waving pictures)",
	[0x2B1] = "Mumbo falling from tree",
	[0x2B2] = "Bottles Eating watermelon",
	[0x2B3] = "Mumbo Hit by Coconuts",
	[0x2B4] = "Mumbo shake head sitting down",
	[0x2B5] = "Mumbo Jumping > Running", -- After MelonBabe
	[0x2B6] = "Klungo Pushing rock",
	[0x2B7] = "Klungo Tired",
	[0x2B8] = "Tooty Drinking", -- Coconut
	[0x2B9] = "Grunty's Rock",
	[0x2BA] = "Kazooie Talking", -- To Bottles
	[0x2BB] = "Mumbo Running", -- After MelonBabe
	[0x2BC] = "Mumbo Talking", -- About pictures, on ground
	[0x2C0] = "Piranha Dying", -- TODO: Where is this used?

	[0x2C5] = "Grunty Preparing charge",
	[0x2C6] = "Mumbo's Hand",
	[0x2C7] = "Mumbo's Hand Appearing",
	[0x2C8] = "Mumbo's Hand Leaving",
};

function setAnimationType(index, animationType)
	local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
	if isRDRAM(objectArray) then
		local objectSlotBase = objectArray + getSlotBase(index);
		local animationObjectPointer = dereferencePointer(objectSlotBase + 0x14);
		if isRDRAM(animationObjectPointer) then
			mainmemory.write_u32_be(animationObjectPointer + animation_object_animation_type, animationType);
		end
	end
end

--------------------
-- Movement state --
--------------------

local movementStates = {
	[0] = "Null",
	[1] = "Idle",
	[2] = "Walking", -- Slow
	[3] = "Walking",
	[4] = "Walking", -- Fast
	[5] = "Jumping",
	[6] = "Bear punch",
	[7] = "Crouching",
	[8] = "Jumping", -- Talon Trot
	[9] = "Shooting Egg",
	[10] = "Pooping Egg",

	[12] = "Skidding",

	[14] = "Damaged",
	[15] = "Beak Buster",
	[16] = "Feathery Flap",
	[17] = "Rat-a-tat rap",
	[18] = "Backflip", -- Flap Flip
	[19] = "Beak Barge",
	[20] = "Entering Talon Trot",
	[21] = "Idle", -- Talon Trot
	[22] = "Walking", -- Talon Trot
	[23] = "Leaving Talon Trot",
	[24] = "Knockback", -- Flying

	[26] = "Entering Wonderwing",
	[27] = "Idle", -- Wonderwing
	[28] = "Walking", -- Wonderwing
	[29] = "Jumping", -- Wonderwing
	[30] = "Leaving Wonderwing",
	[31] = "Creeping",
	[32] = "Landing", -- After Jump
	[33] = "Charging Shock Spring Jump",
	[34] = "Shock Spring Jump",
	[35] = "Taking Flight",
	[36] = "Flying",
	[37] = "Entering Wading Boots",
	[38] = "Idle", -- Wading Boots
	[39] = "Walking", -- Wading Boots
	[40] = "Jumping", -- Wading Boots
	[41] = "Leaving Wading Boots",
	[42] = "Beak Bomb",
	[43] = "Idle", -- Underwater
	[44] = "Swimming (B)",
	[45] = "Idle", -- Treading water
	[46] = "Paddling",
	[47] = "Falling", -- After pecking
	[48] = "Diving",
	[49] = "Rolling",
	[50] = "Slipping",

	[52] = "Jig", -- Note door
	[53] = "Idle", -- Termite
	[54] = "Walking", -- Termite
	[55] = "Jumping", -- Termite
	[56] = "Falling", -- Termite
	[57] = "Swimming (A)",
	[58] = "Idle", -- Carrying object (eg. Orange)
	[59] = "Walking", -- Carrying object (eg. Orange)

	[61] = "Falling", -- Tumbling, will take damage
	[62] = "Damaged", -- Termite

	[64] = "Locked", -- Pumpkin: Pipe
	[65] = "Death",
	[66] = "Dingpot",
	[67] = "Death", -- Termite
	[68] = "Jig", -- Jiggy
	[69] = "Slipping", -- Talon Trot

	[72] = "Idle", -- Pumpkin
	[73] = "Walking", -- Pumpkin
	[74] = "Jumping", -- Pumpkin
	[75] = "Falling", -- Pumpkin
	[76] = "Landing", -- In water
	[77] = "Damaged", -- Pumpkin
	[78] = "Death", -- Pumpkin
	[79] = "Idle", -- Holding tree, pole, etc.
	[80] = "Climbing", -- Tree, pole, etc.
	[81] = "Leaving Climb",
	[82] = "Tumblar", -- Standing on Tumblar
	[83] = "Tumblar", -- Standing on Tumblar
	[84] = "Death", -- Drowning
	[85] = "Slipping", -- Wading Boots
	[86] = "Knockback", -- Successful enemy damage
	[87] = "Beak Bomb", -- Ending
	[88] = "Damaged", -- Beak Bomb
	[89] = "Damaged", -- Beak Bomb
	[90] = "Loading Zone",
	[91] = "Throwing", -- Throwing object (eg. Orange)

	[94] = "Idle", -- Croc
	[95] = "Walking", -- Croc
	[96] = "Jumping", -- Croc
	[97] = "Falling", -- Croc
	[99] = "Damaged", -- Croc
	[100] = "Death", -- Croc

	[103] = "Idle", -- Walrus
	[104] = "Walking", -- Walrus
	[105] = "Jumping", -- Walrus
	[106] = "Falling", -- Walrus
	[107] = "Locked", -- Bee, Mumbo Transform Cutscene
	[108] = "Knockback", -- Walrus
	[109] = "Death", -- Walrus
	[110] = "Biting", -- Croc
	[111] = "EatingWrongThing", -- Croc
	[112] = "EatingCorrectThing", -- Croc
	[113] = "Falling", -- Talon Trot
	[114] = "Recovering", -- Getting up after taking damage, eg. fall famage
	[115] = "Locked", -- Cutscene
	[116] = "Locked", -- Jiggy pad, Mumbo transformation, Bottles
	[117] = "Locked", -- Bottles
	[118] = "Locked", -- Flying
	[119] = "Locked", -- Water Surface
	[120] = "Locked", -- Underwater
	[121] = "Locked", -- Holding Jiggy, Talon Trot
	[122] = "Creeping", -- In damaging water etc
	[123] = "Damaged", -- Talon Trot
	[124] = "Locked", -- Sled in FP sliding down scarf
	[125] = "Idle", -- Walrus Sled
	[126] = "Jumping", -- Walrus Sled
	[127] = "Damaged", -- Swimming
	[128] = "Locked", -- Walrus Sled losing race
	[129] = "Locked", -- Walrus Sled
	[130] = "Locked", -- Walrus Sled In Air when losing race

	[133] = "Idle", -- Bee
	[134] = "Walking", -- Bee
	[135] = "Jumping", -- Bee
	[136] = "Falling", -- Bee
	[137] = "Damaged", -- Bee
	[138] = "Death", -- Bee

	[140] = "Flying", -- Bee
	[141] = "Locked", -- Mumbo transformation, Mr. Vile
	[142] = "Locked", -- Jiggy podium, Bottles' text outside Mumbo's
	[143] = "Locked", -- Pumpkin
	[145] = "Damaged", -- Flying
	[147] = "Locked", -- Pumpkin?
	[148] = "Locked", -- Mumbo transformation
	[149] = "Locked", -- Walrus?
	[150] = "Locked", -- Paddling
	[151] = "Locked", -- Swimming
	[152] = "Locked", -- Loading zone, Mumbo transformation
	[153] = "Locked", -- Flying
	[154] = "Locked", -- Talon Trot
	[155] = "Locked", -- Wading Boots
	--[156] = "Locked??", -- In WalrusSled Set
	[157] = "Locked", -- Bee?
	[158] = "Locked", -- Climbing
	[159] = "Knockback", -- Termite, not damaged
	[160] = "Knockback", -- Pumpkin, not damaged
	[161] = "Knockback", -- Croc, not damaged
	[162] = "Knockback", -- Walrus, not damaged
	[163] = "Knockback", -- Bee, not damaged
	--[164] = "???", -- Wonderwing
	[165] = "Locked", -- Wonderwing
};

function Game.getCurrentMovementState()
	local currentMovementState = mainmemory.read_u32_be(Game.Memory.current_movement_state);
	return movementStates[currentMovementState] or "Unknown ("..currentMovementState..")";
end

function Game.colorCurrentMovementState()
	local stringMovementState = Game.getCurrentMovementState();
	if stringMovementState == "Slipping" or stringMovementState == "Skidding" or stringMovementState == "Recovering" or stringMovementState == "Knockback" then
		return colors.yellow;
	end
	if stringMovementState == "Damaged" or stringMovementState == "Death" then
		return colors.red;
	end
end

---------------------------
-- Object analysis tools --
---------------------------

local object_index = 1;
local object_top_index = 1;
--TODO: Set object_max_slots based on screen size
object_max_slots = 50;

--------------------
-- Output Helpers --
--------------------

local function isBinary(var_type)
	return var_type == "Binary" or var_type == "Bitfield" or var_type == "Byte" or var_type == "Flag" or var_type == "Boolean";
end

local function isHex(var_type)
	return var_type == "Hex" or var_type == "Pointer" or var_type == "Z4_Unknown";
end

local function formatForOutput(var_type, value)
	if isBinary(var_type) then
		local binstring = toBinaryString(value);
		if binstring ~= "" then
			return binstring;
		end
		return "0";
	elseif isHex(var_type) then
		return toHexString(value);
	end
	return ""..value;
end

local function getVariableName(address)
	local variable = slot_variables[address];
	local nameType = type(variable.Name);

	if nameType == "string" then
		return variable.Name;
	elseif nameType == "table" then
		return variable.Name[1];
	end

	return variable.Type.." "..toHexString(address);
end

--------------------
-- "Struct" stuff --
--------------------

local structPointers = {};

local struct_array_types = {
	[0] = { -- Game takes low 12-bits and adds 0x572 for comparisons
		[0x00E] = "Red Feather", -- + 0x572 = 0x580
		[0x15F] = "Gold Feather", -- + 0x572 = 0x6D1
		[0x164] = "Note", -- + 0x572 = 0x6D6
		[0x165] = "Egg", -- + 0x572 = 0x6D7
	},
	[2] = {
		[0x0C] = "Shock spring pad", -- = 0x2DD
		[0x17] = "Flight pad", -- = 0x2E8
	},
	[3] = {
		-- Enemy collisions
	},
};

local struct_array_variables = {
	[0x00] = {Name = "item_index", Type = "u16_be"}, -- Game takes low 12-bits and adds 0x572 for comparisons
	[0x02] = {Name = "scale", Type = "u16_be"},
	[0x04] = {Name = "x_pos", Type = "s16_be"},
	[0x06] = {Name = "y_pos", Type = "s16_be"},
	[0x08] = {Name = "z_pos", Type = "s16_be"},
	[0x0B] = {Name = "struct_type", Type = "byte"} -- Check the last 2 bits of the (Struct[0x08] & 0x03), if both bits are 0, it a collectable object
};

local function getStructType(pointer)
	if isRDRAM(pointer) then
		return bit.band(mainmemory.readbyte(pointer + 0x0B), 0x03);
	end
	return 0;
end

local function getStructCollectable(pointer)
	if isRDRAM(pointer) then
		return bit.band(mainmemory.readbyte(pointer + 0x0B), 0x10)/16;
	end
end

local function getStructRotationDirection(pointer)
	if isRDRAM(pointer) then
		if bit.band(mainmemory.readbyte(pointer + 0x0B), 0x80) ~= 0 then
			return "Clockwise";
		else
			return "Counter Clockwise";
		end
	end
end

local function getItemType(pointer)
	if isRDRAM(pointer) then
		return bit.rshift(mainmemory.read_u16_be(pointer), 4);
	end
	return 0;
end

local function getStructName(pointer)
	local structType = getStructType(pointer);
	local itemType = getItemType(pointer);
    if structType == 0 then
		if type(struct_array_types[structType][itemType]) == "string" then
			return struct_array_types[structType][itemType];
		--else
		--	return "Unknown Collectable ("..toHexString(itemType)..")";
		end
	elseif structType == 2 then
		if type(struct_array_types[structType][itemType]) == "string" then
			return struct_array_types[structType][itemType];
		end
	end
	return "Unknown ("..structType.."->"..toHexString(itemType)..")";
end

local function isKnownStruct(pointer)
	local structType = getStructType(pointer);
	local itemType = getItemType(pointer);
	if structType == 0 then
		if type(struct_array_types[0][itemType]) == "string" then
			return true;
		end
	elseif structType == 2 then
		if type(struct_array_types[2][itemType]) == "string" then
			return true;
		end
	end
	return false;
end

local function getStructData(pointer)
	local structData = {};

	if isRDRAM(pointer) then
		table.insert(structData, {"Slot Base", toHexString(pointer)});
		table.insert(structData, {"Name", getStructName(pointer)});
		table.insert(structData, {"Collectable", getStructCollectable(pointer)});
		table.insert(structData, {"Struct Type", getStructType(pointer)});
		table.insert(structData, {"Item Type", getItemType(pointer)});
		table.insert(structData, {"Separator", 1});

		table.insert(structData, {"X", mainmemory.read_s16_be(pointer + 0x04)});
		table.insert(structData, {"Y", mainmemory.read_s16_be(pointer + 0x06)});
		table.insert(structData, {"Z", mainmemory.read_s16_be(pointer + 0x08)});
		table.insert(structData, {"Scale", mainmemory.read_u16_be(pointer + 0x02)});
		table.insert(structData, {"Rot Dir", getStructRotationDirection(pointer)});
	end

	return structData;
end

local function setStructPosition(pointer, x, y, z)
	if isRDRAM(pointer) then
		mainmemory.write_s16_be(pointer + 0x04, x);
		mainmemory.write_s16_be(pointer + 0x06, y);
		mainmemory.write_s16_be(pointer + 0x08, z);
	end
end

local function getNStructsFromBlock(pointer, nObjects)
	local pointers = {};
	if isRDRAM(pointer) then
        for i = 0, nObjects - 1 do
            if not hide_unknown_structs or isKnownStruct(pointer + i * 0x0C) then
                table.insert(pointers, pointer + i * 0x0C);
            end
        end
        return pointers;
	end
	return pointers;
end


local function getStructPointers()
	local block = dereferencePointer(Game.Memory.struct_array_pointer);
	local pointers = {};
	if isRDRAM(block) then
        local voxel_count = mainmemory.read_u32_be(Game.Memory.struct_array_pointer + 0x28);
        local blockend = block + voxel_count * 0x0C;
        for address = block, blockend, 0x0C do --step through voxels
            local voxel_header = mainmemory.read_u32_be(address);
            --local ptr1_cnt = bit.band(voxel_header, 0x0001F800)/0x400;
            local ptr2_cnt = bit.band(voxel_header, 0x000007E0)/32;
            --[[
            if(ptr1_cnt ~= 0) then
            --    local pointer1 = dereferencePointer(address + 4);
            --    if isRDRAM(pointer1) then
            --        local blockPointers = getStructsFromBlock(pointer1);
            --        for i = 1, #blockPointers do
            --            table.insert(pointers, blockPointers[i]);
            --        end
            --    end
            --end
            --]]
            if(ptr2_cnt ~= 0) then
                local pointer2 = dereferencePointer(address + 8);
                if isRDRAM(pointer2) then
                    local blockPointers = getNStructsFromBlock(pointer2, ptr2_cnt);
                    for i = 1, #blockPointers do
                        table.insert(pointers, blockPointers[i]);
                    end
                end
            end
		end
	end
	return pointers;
end

local function getNumSlots()
	if script_mode == "Examine" or script_mode == "List" then -- Model 1
		local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
		if isRDRAM(objectArray) then
			return math.min(max_slots, mainmemory.read_u32_be(objectArray));
		end
	else -- Model 2
		return #structPointers;
	end
	return 0;
end

--------------------
-- Object Overlay --
--------------------
local viewport_YAngleRange = 60;
local viewport_XAngleRange = 45;
local object_selectable_size = 10 * client.bufferwidth() / 640;
local reference_distance = 2000;

local mouseClickedLastFrame = false;
local startDragPosition = {0,0};
local draggedObjects = {};
local dragging = false;

local screen = {
	width = client.bufferwidth(),
	height = client.bufferheight(),
};

function drawObjectPositions()
	local draggableObjects = {};
	local objectModel;
	if string.contains(script_mode, "Struct") then
		objectModel = 2;
		draggableObjects = getStructPointers();
	else
		objectModel = 1;
		draggableObjects = getObjectModel1Pointers();
	end

	local startDrag = false;
	local dragTransform = {0, 0};
	local mouse = input.getmouse();

	if mouse.Left then -- if mouse clicked object is being dragged
		if not mouseClickedLastFrame then
			if dragging ~= true then
				startDrag = true;
				dragging = true;
				startDragPosition = {mouse.X, mouse.Y, mouse.Wheel or 0};
			else
				draggedObjects[1] = nil;
				draggedObjects = {};
				dragging = false;
			end
		end
		mouseClickedLastFrame = true;
	else
		mouseClickedLastFrame = false;
	end

	if dragging then
		dragTransform = {mouse.X - startDragPosition[1], mouse.Y - startDragPosition[2], (mouse.Wheel or 0) - startDragPosition[3]};
	end

	local cameraData = {};
	if mainmemory.readbyte(Game.Memory.first_person_flag) ~= 0 then
		cameraData = { -- In first person
			xPos = mainmemory.readfloat(Game.Memory.first_person_cam_x_pos, true),
			yPos = mainmemory.readfloat(Game.Memory.first_person_cam_y_pos, true),
			zPos = mainmemory.readfloat(Game.Memory.first_person_cam_z_pos, true),
			xRot = mainmemory.readfloat(Game.Memory.first_person_cam_x_rot, true) * math.pi / 180,
			yRot = mainmemory.readfloat(Game.Memory.first_person_cam_y_rot, true) * math.pi / 180,
		};
	else
		cameraData = { -- In third person
			xPos = mainmemory.readfloat(Game.Memory.camera_x_position, true),
			yPos = mainmemory.readfloat(Game.Memory.camera_y_position, true),
			zPos = mainmemory.readfloat(Game.Memory.camera_z_position, true),
			xRot = mainmemory.readfloat(Game.Memory.camera_x_rotation, true) * math.pi / 180,
			yRot = mainmemory.readfloat(Game.Memory.camera_y_rotation, true) * math.pi / 180,
		};
	end
	for i = 1, #draggableObjects do
		local slotBase = draggableObjects[i];

		-- Translate origin to camera position
		local xDifference, yDifference, zDifference;
		if objectModel == 1 then
			xDifference = mainmemory.readfloat(slotBase + 0x04, true) - cameraData.xPos;
			yDifference = mainmemory.readfloat(slotBase + 0x08, true) - cameraData.yPos;
			zDifference = mainmemory.readfloat(slotBase + 0x0C, true) - cameraData.zPos;
		else
			xDifference = mainmemory.read_s16_be(slotBase + 0x04) - cameraData.xPos;
			yDifference = mainmemory.read_s16_be(slotBase + 0x06) - cameraData.yPos;
			zDifference = mainmemory.read_s16_be(slotBase + 0x08) - cameraData.zPos;
		end

		-- Transform object point to point in coordinate system based on camera normal
		-- Rotation transform 1
		local tempData = {
			xPos = math.cos(cameraData.yRot)*xDifference - math.sin(cameraData.yRot) * zDifference,
			yPos = yDifference,
			zPos = math.sin(cameraData.yRot)*xDifference + math.cos(cameraData.yRot) * zDifference,
		};

		-- Rotation transform 2
		local objectData = {
			xPos = tempData.xPos,
			yPos = math.sin(cameraData.xRot) * tempData.zPos + math.cos(cameraData.xRot) * tempData.yPos,
			zPos = -math.cos(cameraData.xRot) * tempData.zPos + math.sin(cameraData.xRot) * tempData.yPos,
		};

		if objectData.zPos > 30 then
			local XAngle_local = math.atan(objectData.yPos / objectData.zPos); -- Horizontal Angle
			local YAngle_local = math.atan(objectData.xPos / objectData.zPos); -- Horizontal Angle
			-- Don't need to compentate for tan since angle between

			YAngle_local = ((YAngle_local + math.pi) % (2 * math.pi)) - math.pi; -- Get angle between -180 and +180
			XAngle_local = ((XAngle_local + math.pi) % (2 * math.pi)) - math.pi;

			if YAngle_local <= (viewport_YAngleRange / 2) and YAngle_local > (-viewport_XAngleRange / 2) then
				if XAngle_local <= (viewport_XAngleRange / 2) and XAngle_local > (-viewport_YAngleRange / 2) then

					-- At this point object is selectable/draggable
					local drawXPos = (screen.width / 2) * math.sin(YAngle_local) / math.sin(viewport_YAngleRange * math.pi / 360) + screen.width / 2;
					local drawYPos = -(screen.height / 2) * math.sin(XAngle_local) / math.sin(viewport_XAngleRange * math.pi / 360) + screen.height / 2;

					-- Calc scaling factor -- current calc might be incorrect
					local scaling_factor = reference_distance / objectData.zPos;
					-- Object selection
					if draggedObjects[1] ~= nil then
						if i == draggedObjects[1][1] then
							if dragging then
								drawXPos = draggedObjects[1][2] + dragTransform[1];
								drawYPos = draggedObjects[1][3] + dragTransform[2];
								objectData.zPos = draggedObjects[1][4] + dragTransform[3];

								-- Transform screen-to-game coords
								YAngle_local = math.asin(math.sin(viewport_YAngleRange * math.pi / 360) * (2 * drawXPos / screen.width - 1));
								XAngle_local = math.asin(math.sin(viewport_XAngleRange * math.pi / 360) * (1 - 2 * drawYPos / screen.height));

								objectData.yPos = objectData.zPos * math.tan(XAngle_local); -- Horizontal Angle
								objectData.xPos = objectData.zPos * math.tan(YAngle_local);

								tempData.xPos = objectData.xPos;
								tempData.yPos = math.cos(cameraData.xRot)*objectData.yPos + math.sin(cameraData.xRot)*objectData.zPos;
								tempData.zPos = math.sin(cameraData.xRot)*objectData.yPos - math.cos(cameraData.xRot)*objectData.zPos;

								xDifference = math.cos(cameraData.yRot)*tempData.xPos + math.sin(cameraData.yRot)*tempData.zPos;
								yDifference = tempData.yPos;
								zDifference = -math.sin(cameraData.yRot)*tempData.xPos + math.cos(cameraData.yRot)*tempData.zPos;

								-- Save new object position to RDRAM
								if objectModel == 1 then
									setObjectModel1Position(slotBase, cameraData.xPos + xDifference, cameraData.yPos + yDifference, cameraData.zPos + zDifference);
								else
									setStructPosition(slotBase, cameraData.xPos + xDifference, cameraData.yPos + yDifference, cameraData.zPos + zDifference);
								end

							end
						end
					end
					if mouse.Left then
						if (mouse.X >= drawXPos - scaling_factor * object_selectable_size / 2 and mouse.X <= drawXPos + scaling_factor * object_selectable_size / 2) 
						and (mouse.Y >= drawYPos - scaling_factor * object_selectable_size / 2 and mouse.Y <= drawYPos + scaling_factor * object_selectable_size / 2) then
							object_index = i;
						end
					end
					-- Draw to screen
					local color = colors.white;
					if object_index == i then
						color = colors.yellow;
						if startDrag then
							draggedObjects = {};
							table.insert(draggedObjects, {i, drawXPos, drawYPos, objectData.zPos});
						end
						if dragging then
							color = 0xFF42D4FF;
						end
					end
					gui.drawLine(drawXPos - scaling_factor * object_selectable_size / 2, drawYPos, drawXPos + scaling_factor * object_selectable_size / 2, drawYPos, color);
					gui.drawLine(drawXPos, drawYPos - scaling_factor * object_selectable_size / 2, drawXPos, drawYPos + scaling_factor * object_selectable_size / 2, color);
					gui.drawText(drawXPos, drawYPos, string.format("%d", i), color, nil, 9 + 3 * scaling_factor);
				end
			end
		end
	end
end

function zipToSelectedObject()
	if script_mode == "Examine" or script_mode == "List" then -- Model 1
		local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
		if isRDRAM(objectArray) then
			local slotBase = objectArray + getSlotBase(object_index - 1);

			local x = mainmemory.readfloat(slotBase + slot_variables_inv.X, true);
			local y = mainmemory.readfloat(slotBase + slot_variables_inv.Y, true);
			local z = mainmemory.readfloat(slotBase + slot_variables_inv.Z, true);

			Game.setPosition(x, y, z);
		end
	else
		local rendererPointer = structPointers[object_index];
		if isRDRAM(rendererPointer) then
			local x = mainmemory.read_s16_be(rendererPointer + 0x04); -- TODO: Get these constants from somewhere
			local y = mainmemory.read_s16_be(rendererPointer + 0x06);
			local z = mainmemory.read_s16_be(rendererPointer + 0x08);

			Game.setPosition(x, y, z);
		end
	end
end

function setSelectedObjectModel(model_index)
	if script_mode == "Examine" or script_mode == "List" then -- Model 1
		local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
		if isRDRAM(objectArray) then
			local slotBase = objectArray + getSlotBase(object_index - 1);
			local behavior_pointer = dereferencePointer(slotBase);
			if isRDRAM(behavior_pointer) then
				local objectModel = mainmemory.read_u16_be(behavior_pointer + 0x3E);
				objectModel = bit.band(objectModel, 0x0003);
				objectModel = bit.bor(objectModel, bit.lshift(model_index, 2));
				mainmemory.write_u16_be(behavior_pointer + 0x3E, objectModel);
			end
		end
	end
end

function turnOffSelectedObjectCollision()
	if script_mode == "Examine" or script_mode == "List" then -- Model 1
		local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
		if isRDRAM(objectArray) then
			local slotBase = objectArray + getSlotBase(object_index - 1);
			local behavior_pointer = dereferencePointer(slotBase);
			if isRDRAM(behavior_pointer) then
				mainmemory.write_u16_be(behavior_pointer + 0x2E, 0);
			end
		end
	end
end

function turnOnSelectedObjectCollision()
	if script_mode == "Examine" or script_mode == "List" then -- Model 1
		local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
		if isRDRAM(objectArray) then
			local slotBase = objectArray + getSlotBase(object_index - 1);
			local behavior_pointer = dereferencePointer(slotBase);
			if isRDRAM(behavior_pointer) then
				mainmemory.write_u16_be(behavior_pointer + 0x2E, 1);
			end
		end
	end
end

function despawnSelectedObject()
	if script_mode == "Examine" or script_mode == "List" then -- Model 1
		local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
		if isRDRAM(objectArray) then
			local slotBase = objectArray + getSlotBase(object_index - 1);
			local bitfieldValue = mainmemory.readbyte(slotBase + 0x47);
			mainmemory.writebyte(slotBase + 0x47, bit.set(bitfieldValue, 3));
		end
	end
end

function grabSelectedObject()
	if script_mode == "Examine" or script_mode == "List" then -- Model 1
		local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
		if isRDRAM(objectArray) then
			local slotBase = objectArray + getSlotBase(object_index - 1);
			local unknownStructAddress = dereferencePointer(slotBase);
			if isRDRAM(unknownStructAddress) then
				local tempBitField = mainmemory.readbyte(slotBase + 0x139);
				tempBitField = bit.bor(tempBitField, 0x40);
				mainmemory.writebyte(slotBase + 0x139, tempBitField);
				mainmemory.write_u32_be(Game.Memory.carried_object_pointer, RDRAMBase + unknownStructAddress);
				mainmemory.writebyte(Game.Memory.carried_object_pointer + 4, 1); -- Force update position
				mainmemory.write_u32_be(Game.Memory.current_movement_state, 58); -- Force movement state
				forms.setproperty(ScriptHawk.UI.form_controls.spawner_carry_checkbox, "Checked", true);
			end
		end
	end
end

---------------
-- OSD Stuff --
---------------

local function toggleObjectAnalysisToolsMode()
	script_mode_index = script_mode_index + 1;
	if script_mode_index > #script_modes then
		script_mode_index = 1;
	end
	script_mode = script_modes[script_mode_index];
end

function getExamineData(slotBase) -- TODO: Improve this based on SM64 module implementation
	local current_slot_variables = {};
	for relative_address, variable_data in pairs(slot_variables) do
		if type(variable_data) == "table" then
			local variableName = getVariableName(relative_address);
			if variable_data.Type == "Byte" then
				table.insert(current_slot_variables, {variableName, formatForOutput(variable_data.Type, mainmemory.readbyte(slotBase + relative_address))});
			elseif variable_data.Type == "u16_be" then
				table.insert(current_slot_variables, {variableName, formatForOutput(variable_data.Type, mainmemory.read_u16_be(slotBase + relative_address))});
			elseif variable_data.Type == "u8" then
				table.insert(current_slot_variables, {variableName, formatForOutput(variable_data.Type, mainmemory.read_u8(slotBase + relative_address))});
			elseif variable_data.Type == "Z4_Unknown" then
				-- Don't print yo
			elseif variable_data.Type == "Pointer" or variable_data.Type == "u32_be" then
				table.insert(current_slot_variables, {variableName, formatForOutput(variable_data.Type, mainmemory.read_u32_be(slotBase + relative_address))});
			elseif variable_data.Type == "Float" then
				table.insert(current_slot_variables, {variableName, formatForOutput(variable_data.Type, mainmemory.readfloat(slotBase + relative_address, true))});
			end
		end
	end
	return current_slot_variables;
end

function Game.drawUI()
	if script_mode == "Disabled" then
		return;
	end

	local row = 0;

	local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
	if string.contains(script_mode, "Struct") then
		structPointers = getStructPointers();
	end
	local numSlots = getNumSlots();

	gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, "Mode: "..script_mode, nil, 'bottomright');
	row = row + 1;
	gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, "Index: "..(object_index).."/"..(numSlots), nil, 'bottomright');
	row = row + 1;

	--drawObjectPositions();

	if script_mode == "Examine" and isRDRAM(objectArray) then
		local examine_data = getExamineData(objectArray + getSlotBase(object_index - 1));
		for i = #examine_data, 1, -1 do
			if examine_data[i][1] ~= "Separator" then
				gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, examine_data[i][2].." - "..examine_data[i][1], nil, 'bottomright');
				row = row + 1;
			else
				row = row + examine_data[i][2];
			end
		end
	end

	if script_mode == "Examine Struct" then
		local structData = getStructData(structPointers[object_index]);
		for i = #structData, 1, -1 do
			if structData[i][1] ~= "Separator" then
				gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, structData[i][2].." - "..structData[i][1], nil, 'bottomright');
				row = row + 1;
			else
				row = row + structData[i][2];
			end
		end
	end

	if script_mode == "List" and isRDRAM(objectArray) then
		for i = math.min(numSlots, object_top_index + object_max_slots), object_top_index, -1 do
			local currentSlotBase = objectArray + getSlotBase(i - 1);
			local currentBehaviorStructPointer = dereferencePointer(currentSlotBase);
			local animationType = getObjectName(currentSlotBase);

			local color = nil;
			if object_index == i then
				color = colors.yellow;
			end

			if animationType == "Unknown" then
				local boneArray1 = dereferencePointer(currentSlotBase + slot_variables_inv["Bone Array 1 Pointer"]);
				local boneArray2 = dereferencePointer(currentSlotBase + slot_variables_inv["Bone Array 2 Pointer"]);
				if not hide_non_animated or (isRDRAM(boneArray1) or isRDRAM(boneArray2)) then
					gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, i..": "..toHexString(currentSlotBase or 0).." "..toHexString(currentBehaviorStructPointer or 0), color, 'bottomright');
					row = row + 1;
				end
			else
				gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, animationType.." "..i..": "..toHexString(currentSlotBase or 0).." "..toHexString(currentBehaviorStructPointer or 0), color, 'bottomright');
				row = row + 1;
			end
		end
	end

	if script_mode == "List Struct" then
		for i = math.min(#structPointers, object_top_index + object_max_slots), object_top_index, -1 do
			local structName = getStructName(structPointers[i]).." - ";
			if object_index == i then
				local x = mainmemory.read_s16_be(structPointers[i] + 0x04); -- TODO: Get these constants from somewhere
				local y = mainmemory.read_s16_be(structPointers[i] + 0x06);
				local z = mainmemory.read_s16_be(structPointers[i] + 0x08);
				gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, structName..x..", "..y..", "..z.." "..i..": "..toHexString(structPointers[i]), colors.yellow, 'bottomright');
				row = row + 1;
			else
				gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, structName..i..": "..toHexString(structPointers[i]), nil, 'bottomright');
				row = row + 1;
			end
		end
	end
end

local function incrementObjectIndex() -- TODO: These functions need to take hide_non_animated into account
	if dragging == false then
		local numSlots = getNumSlots();
		object_index = object_index + 1;
		if object_index > numSlots then
			object_index = 1;
		end
		if object_index > object_top_index + object_max_slots then
			object_top_index = object_index - object_max_slots;
		elseif object_index < object_top_index then
			object_top_index = object_index;
		end
	end
end

local function decrementObjectIndex()
	if dragging == false then
		object_index = object_index - 1;
		if object_index <= 0 then
			local numSlots = getNumSlots();
			object_index = numSlots;
		end
		if object_index > object_top_index + object_max_slots then
			object_top_index = object_index - object_max_slots;
		elseif object_index < object_top_index then
			object_top_index = object_index;
		end
	end
end

-- Keybinds
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm
ScriptHawk.bindKeyRealtime("Z", zipToSelectedObject, true);
ScriptHawk.bindKeyRealtime("X", despawnSelectedObject, true);
ScriptHawk.bindKeyRealtime("C", toggleObjectAnalysisToolsMode, true);
ScriptHawk.bindKeyRealtime("V", grabSelectedObject, true);
ScriptHawk.bindKeyRealtime("N", decrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("M", incrementObjectIndex, true);
ScriptHawk.bindMouse("mousewheelup", decrementObjectIndex);
ScriptHawk.bindMouse("mousewheeldown", incrementObjectIndex);

---------------
-- Autopound --
---------------

local holdingAPostJump = false;
allowPound = false;
allowTTrotJump = true;
local function autoPound()
	local currentMovementState = mainmemory.read_u32_be(Game.Memory.current_movement_state);
	local YVelocity = Game.getYVelocity();

	-- First frame pound out of peck
	if allowPound and currentMovementState == 17 and YVelocity == -272 and not Game.isPhysicsFrame() then -- TODO: YVelocity == -272 doesn't work for all versions
		joypad.set({Z=true}, 1);
	end

	-- Frame perfect mid air talon trot slide jump
	if allowTTrotJump and (currentMovementState == 21 and not Game.isGrounded() or holdingAPostJump) then
		holdingAPostJump = true;
		if holdingAPostJump then
			holdingAPostJump = holdingAPostJump and (currentMovementState == 21 or YVelocity > 0); -- TODO: Better method for detecting end of a jump, velocity > 0 is janky
		end
		joypad.set({A=true}, 1);
	end
end

--------------------------
-- Sandcastle positions --
--------------------------

local sandcastle_square_size = 90;
local sandcastlePositions = {
	A = {2, -8},
	B = {0, 6},
	C = {4, -6},
	D = {-4, -2},
	E = {0, -6},
	F = {4, 2},
	G = {-2, -8},
	H = {-4, 6},
	I = {6, 0},
	J = {-6, -8},
	K = {4, 6},
	L = {6, -8},
	M = {-6, -4},
	N = {-2, -4},
	O = {0, -2},
	P = {6, -4},
	-- There's no Q in the sandcastle
	R = {2, -4},
	S = {4, -2},
	T = {0, 2},
	U = {-2, 0},
	V = {-4, -6},
	W = {2, 4},
	X = {-4, 2},
	Y = {2, 0},
	Z = {-6, 0},
};

function gotoSandcastleLetter(letter)
	if type(letter) ~= "string" then
		print("Letter not a string.");
		return;
	end

	-- Convert the letter to uppercase
	letter = string.upper(letter);

	if type(sandcastlePositions[letter]) ~= "table" then
		print("Letter not found.");
		return;
	end

	Game.setXPosition(sandcastlePositions[letter][1] * sandcastle_square_size);
	Game.setZPosition(sandcastlePositions[letter][2] * sandcastle_square_size);
end

-------------------------------
-- Sandcastle string decoder --
-------------------------------

local sandcastleStringConversionTable = {
	[0x00] = " ",
	[0x30] = "C",
	[0x31] = "M",
	[0x32] = "S",
	[0x33] = "Z",
	[0x34] = "I",
	[0x35] = "G",
	[0x36] = "O",
	[0x37] = "W",
	[0x38] = "K",
	[0x39] = "R",
	[0x61] = "V",
	[0x62] = "L",
	[0x63] = "F",
	[0x64] = "T",
	[0x65] = "Y",
	[0x67] = "U",
	[0x68] = "X",
	[0x69] = "N",
	[0x6A] = "E",
	[0x6B] = "B",
	[0x6C] = "D",
	[0x6D] = "H",
	[0x6E] = "A",
	[0x70] = "J",
	[0x72] = "P",
};

function decodeSandcastleString(base, length, nullTerminate)
	nullTerminate = nullTerminate or false;
	local builtString = "";
	for i = base, base + length do
		local byte = mainmemory.readbyte(i);

		if byte == 0 and nullTerminate then
			break;
		end

		if type(sandcastleStringConversionTable[byte]) ~= "nil" then
			builtString = builtString..sandcastleStringConversionTable[byte];
		else
			builtString = builtString.."?".."("..toHexString(byte).." = "..string.char(byte)..")";
		end
	end
	print(builtString);
end

-----------------------
-- Furnace fun stuff --
-----------------------

function patternToEEPROM(index)
	if index < 0 or index > 255 then
		return 0x0008;
	end

	local indexScaled = math.floor(index / 2) + 0x80;
	local mostSignificantDigit = math.floor(indexScaled / 16);
	local leastSignificantDigit = indexScaled % 16;

	local value = leastSignificantDigit * 0x1000 + mostSignificantDigit;
	if index % 2 == 1 then
		value = value + 0x800;
	end
	return value;
end

-- Note, fiddling with these flags might not actually update the pattern, aaa
function Game.getFFPattern()
	local FFPattern = 0;
	if checkFlag("Prog", 0xD3) then
		FFPattern = FFPattern + 1;
	end
	if checkFlag("Prog", 0xD4) then
		FFPattern = FFPattern + 2;
	end
	if checkFlag("Prog", 0xD5) then
		FFPattern = FFPattern + 4;
	end
	if checkFlag("Prog", 0xD6) then
		FFPattern = FFPattern + 8;
	end
	if checkFlag("Prog", 0xD7) then
		FFPattern = FFPattern + 16;
	end
	if checkFlag("Prog", 0xD8) then
		FFPattern = FFPattern + 32;
	end
	if checkFlag("Prog", 0xD9) then
		FFPattern = FFPattern + 64;
	end
	if checkFlag("Prog", 0xDA) then
		FFPattern = FFPattern + 128;
	end
	return FFPattern;
end

-- Relative to question object
local ff_current_answer = 0x13;
local ff_correct_answer = 0x1D;

local ff_question_text_pointer = 0x34;
local ff_answer1_text_pointer = 0x64;
local ff_answer2_text_pointer = 0x54;
local ff_answer3_text_pointer = 0x44;

function getSelectedFFAnswer()
	local ff_question_object = dereferencePointer(Game.Memory.ff_question_pointer);
	if isRDRAM(ff_question_object) then
		return mainmemory.readbyte(ff_question_object + ff_current_answer);
	end
	return 0;
end

-- TODO: Doesn't always work
function getCorrectFFAnswer()
	local ff_question_object = dereferencePointer(Game.Memory.ff_question_pointer);
	if isRDRAM(ff_question_object) then
		return mainmemory.readbyte(ff_question_object + ff_correct_answer);
	end
	return 0;
end

-- FF Board State
local squareSize = 0x20;
local numSquares = 95;

-- 0x08 Byte - Question Type
local question_types = {
	[0x00] = "None",
	[0x01] = "BK",
	[0x02] = "Screen",
	[0x03] = "Sound",
	[0x04] = "Minigame",
	[0x05] = "Grunty",
	[0x06] = "Death",
	[0x07] = "Joker", -- Gives 1 card
	[0x08] = "Joker", -- Gives 2 cards
	[0x09] = "Joker", -- Gives 3 cards
	[0x0A] = "Joker?", -- Gives 0 cards?
	[0x0B] = "Joker", -- Gives 5 cards
	[0x0C] = "Joker", -- Gives 6 cards
	-- TODO: Finish this table
};

-- 0x08 Byte - Square Type
-- 0x09 Byte - Square State - 0x00 Not completed, 0x01 Completed, 0x02 Active
-- 0x10 Float - Brightness?

function randomizeFFBoardBrightness()
	for i = 0, numSquares do
		mainmemory.writefloat(Game.Memory.board_base + i * squareSize + 0x10, math.random(), true);
	end
end

function dumpFFBoard()
	for i = 0, numSquares do
		local brightness = round(mainmemory.readfloat(Game.Memory.board_base + i * squareSize + 0x10, true), 3);
		local questionType = question_types[mainmemory.readbyte(Game.Memory.board_base + i * squareSize + 0x08)];
		dprint(toHexString(Game.Memory.board_base + i * squareSize)..": "..i..": brightness "..brightness.." "..questionType);
	end
	print_deferred();
end

----------------------
-- Vile state stuff --
----------------------

local game_type = 0x90; -- TODO: Verify these
local previous_game_type = 0x91;
local player_score = 0x92;
local vile_score = 0x93;
local minigame_timer = 0x94;

local number_of_slots = 24;

-- Relative to slot base + (slot number * slot size)

-- 00000 0x00 Disabled
-- 00100 0x04 Idle
-- 01000 0x08 Rising
-- 01100 0x0C Alive
-- 10000 0x10 Falling (not eaten)
-- 10100 0x14 Eaten
local slot_state = 0x10;

-- Float 0-1
local popped_amount = 0x7C;

-- 0x00 = yum, > 0x00 = grum
local slot_type = 0x80;

-- Float 0-15?
local slot_timer = 0x84;

-- Returns the RDRAM location of the yumbly/grumbly slot at the index referenced by "Docs/Vile Map.jpg"
local function getVileSlotBase(objectArray, index)
	if isRDRAM(objectArray) then
		local numSlots = mainmemory.read_u32_be(objectArray);
		local slotsFound = 0;
		for i = 0, numSlots do
			if mainmemory.readfloat(objectArray + slot_base + (i * slot_size) + 0x08, true) == -100 then -- Detect yumbly/grumbly
				if slotsFound == index then
					return objectArray + slot_base + (i * slot_size);
				end
				slotsFound = slotsFound + 1;
			end
		end
	end
end

local function fireSlot(objectArray, index, slotType)
	local currentSlotBase = getVileSlotBase(objectArray, index);
	if isRDRAM(currentSlotBase) then
		mainmemory.writebyte(currentSlotBase + slot_state, 0x0C);
		mainmemory.writebyte(currentSlotBase + slot_type, slotType);
		mainmemory.writefloat(currentSlotBase + popped_amount, 1.0, true);
		mainmemory.writefloat(currentSlotBase + slot_timer, 0.1, true);
	end
end

local vileMap = {
	{ 22, 24, 16 },
	{ 21, 23, 14, 15 },
	{ 20, 19, 17, 13, 12 },
	{ 9,  18, 11, 4 },
	{ 10, 7,  8,  2,  1  },
	{ 6,  5,  3,  0 },
};

local heart = {
	{2, 2}, {2, 3},
	{3, 2}, {3, 3}, {3, 4},
	{4, 2}, {4, 3},
	{5, 3},
};

local waveFrames = {
	{ {3, 1}, {5, 1} },
	{ {2, 1}, {4, 1}, {6, 1} },
	{ {1, 1}, {3, 2}, {5, 2} },
	{ {2, 2}, {4, 2}, {6, 2} },
	{ {1, 2}, {3, 3}, {5, 3} },
	{ {2, 3}, {4, 3}, {6, 3} },
	{ {1, 3}, {3, 4}, {5, 4} },
	{ {2, 4}, {4, 4}, {6, 4} },
	{ {3, 5}, {5, 5} },
};

function getSlotIndex(row, col)
	row = math.max(row, 1);
	if row <= #vileMap then
		col = math.max(col, 1);
		col = math.min(col, #vileMap[row]);
		return vileMap[row][col];
	end
	return 0;
end

local waving = false;
local wave_counter = 0;
local wave_delay = 10;
local wave_frame = 1;
local wave_colour = 0;

local function initWave()
	waving = true;
	wave_frame = 1;
	wave_counter = 0;
	wave_colour = math.random(0, 1);
end

local function updateWave()
	if waving then
		wave_counter = wave_counter + 1;
		if wave_counter == wave_delay then
			local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
			if isRDRAM(objectArray) then
				for i = 1, #waveFrames[wave_frame] do
					fireSlot(objectArray, getSlotIndex(waveFrames[wave_frame][i][1], waveFrames[wave_frame][i][2]), wave_colour);
				end
				wave_counter = 0;
				wave_frame = wave_frame + 1;
			end
		end
		if wave_frame > #waveFrames then
			waving = false;
		end
	end
end

local function doHeart()
	local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
	if isRDRAM(objectArray) then
		local colour = math.random(0, 1);
		for i = 1, #heart do
			fireSlot(objectArray, getSlotIndex(heart[i][1], heart[i][2]), colour);
		end
	end
end

local function fireAllSlots()
	local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
	if isRDRAM(objectArray) then
		local colour = math.random(0, 1);
		for i = 0, number_of_slots do
			fireSlot(objectArray, i, colour);
		end
	end
end

-------------------------------
-- Conga.lua                 --
-- Written by Isotarge, 2015 --
-------------------------------

function findConga()
	if mainmemory.readbyte(Game.Memory.map) == 0x02 then -- Make sure we're in Mumbo's Mountain
		local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
		if isRDRAM(objectArray) then
			local numObjects = mainmemory.read_u32_be(objectArray);
			for i = 0, numObjects do
				local currentSlotBase = objectArray + getSlotBase(i);
				local objectIDPointer = dereferencePointer(currentSlotBase + 0x12C);
				if isRDRAM(objectIDPointer) and mainmemory.read_u16_be(objectIDPointer + 0x02) == 0x0008 then
					return currentSlotBase;
				end
			end
		end
	end
end

function throwOrange()
	local congaBase = findConga();
	if isRDRAM(congaBase) then
		mainmemory.writefloat(congaBase + 0x114, 0.5, true); -- Write 0.5 to main behavior timer
	end
end

--ScriptHawk.bindKeyFrame("C", throwOrange, false); -- TODO: This keybind conflicts with the object analysis tools

--------------
-- Encircle --
--------------

local dynamic_radius_factor = 15;
y_stagger_amount = 10;
radius = 1000;

local function encircle_banjo()
	local current_banjo_x = Game.getXPosition();
	local current_banjo_y = Game.getYPosition();
	local current_banjo_z = Game.getZPosition();
	local x, y, z;

	--radius = 1000;
	if ScriptHawk.UI.ischecked("dynamic_radius_checkbox") then
		radius = getNumSlots() * dynamic_radius_factor;
	end

	if string.contains(script_mode, "Struct") then
		structPointers = getStructPointers(); -- This prevents crashes
		for i = 1, #structPointers do
			x = current_banjo_x + math.cos(math.pi * 2 * i / #structPointers) * radius;
			y = current_banjo_y + i * y_stagger_amount;
			z = current_banjo_z + math.sin(math.pi * 2 * i / #structPointers) * radius;
			setStructPosition(structPointers[i], x, y, z);
		end
	else
		local currentPointers = getObjectModel1Pointers();
		for i = 1, #currentPointers do
			x = current_banjo_x + math.cos(math.pi * 2 * i / #currentPointers) * radius;
			y = current_banjo_y + i * y_stagger_amount;
			z = current_banjo_z + math.sin(math.pi * 2 * i / #currentPointers) * radius;
			setObjectModel1Position(currentPointers[i], x, y, z);
		end
	end
end

----------------------
-- Framebuffer Jank --
----------------------

-- TODO: Not working?
function fillFB()
	local frameBufferLocation = dereferencePointer(Game.Memory.fb_pointer);
	if isRDRAM(frameBufferLocation) then
		replaceTextureRGBA5551(nil, frameBufferLocation, framebuffer.width, framebuffer.height);
	end
end

-------------------
-- Physics/Scale --
-------------------

function Game.getFrameRate()
	local numerator = 60;
	if Game.version == 1 then -- PAL
		numerator = 50;
	end
	local denominator = math.max(1, mainmemory.read_s32_be(Game.Memory.frame_timer + 4));
	return numerator / denominator;
end

function Game.isPhysicsFrame()
	local frameTimerValue = mainmemory.read_s32_be(Game.Memory.frame_timer);
	return frameTimerValue <= 0 and not emu.islagged();
end

--------------
-- Position --
--------------

function Game.getFloor()
	local floorObject = dereferencePointer(Game.Memory.floor_object_pointer);
	if isRDRAM(floorObject) then
		return mainmemory.readfloat(floorObject + 0x40, true);
	end
	return 0;
end

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
	mainmemory.writefloat(Game.Memory.x_position + 0x10, value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.y_position, value, true);
	mainmemory.writefloat(Game.Memory.y_position + 0x10, value, true);

	-- Nullify gravity when setting Y position
	Game.setYVelocity(0);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_position, value, true);
	mainmemory.writefloat(Game.Memory.z_position + 0x10, value, true);
end

-- In one frame
-- TODO: Allow n frames ahead
function Game.getPredictedYPosition()
	local frameRate = Game.getFrameRate();
	local gravity = mainmemory.readfloat(Game.Memory.gravity, true) / frameRate;
	if mainmemory.read_u32_be(Game.Memory.current_movement_state) == 36 then -- Flying
		gravity = 0;
	end
	return Game.getYPosition() + ((Game.getYVelocity() + gravity) / frameRate);
end

Game.predictedZipFrame = nil;
Game.yPosRelativeToFloor = 0;
Game.landingFrame = 0;
function Game.getPredictedYPositionRelativeToFloor()
	return Game.yPosRelativeToFloor;
end

function Game.getPredictedLandingFrame()
	return "in "..Game.landingFrame.." frames";
end

function Game.predictZip()
	local frameRate = Game.getFrameRate();
	local gravity = mainmemory.readfloat(Game.Memory.gravity, true) / frameRate;
	local floor = Game.getFloor();
	local yPos = Game.getYPosition();
	local yVel = Game.getYVelocity();
	local yPosRelativeToFloor;
	local inAir = mainmemory.read_u32_be(Game.Memory.current_movement_state) == 36;

	Game.zipPredicted = false;
	if gravity < 0 then
		for i = 0, 600 do -- Search max 600 frames ahead
			yPosRelativeToFloor = yPos - floor;
			if yPosRelativeToFloor < 0 then
				Game.yPosRelativeToFloor = yPosRelativeToFloor;
				Game.landingFrame = i;
				if yPosRelativeToFloor <= -56 and yPosRelativeToFloor > -66 then
					Game.zipPredicted = true;
				end
				break;
			end
			if not inAir then
				yVel = yVel + gravity;
			end
			yPos = yPos + (yVel / frameRate);
		end
		if Game.zipPredicted then
			return true;
		end
	end
	return false;
end

function Game.colorZipPrediction()
	if Game.zipPredicted then
		return colors.green;
	end
end

function Game.forceZip()
	local inputs = joypad.getimmediate();
	if inputs["P1 L"] or inputs["P1 A"] then
		return;
	end
	if Game.getFloor() > Game.defaultFloor then
		Game.setYVelocity(-53 * Game.getFrameRate());
	end
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	return mainmemory.readfloat(Game.Memory.x_rotation, true);
end

function Game.getYRotation()
	return mainmemory.readfloat(Game.Memory.moving_angle, true);
end

function Game.getFacingAngle()
	return mainmemory.readfloat(Game.Memory.facing_angle, true);
end

function Game.getZRotation()
	return mainmemory.readfloat(Game.Memory.z_rotation, true);
end

function Game.setXRotation(value)
	mainmemory.writefloat(Game.Memory.x_rotation, value, true);

	-- Also set the target
	mainmemory.writefloat(Game.Memory.x_rotation + 4, value, true);
end

function Game.setYRotation(value)
	mainmemory.writefloat(Game.Memory.moving_angle, value, true);
	mainmemory.writefloat(Game.Memory.facing_angle, value, true);
end

function Game.setZRotation(value)
	mainmemory.writefloat(Game.Memory.z_rotation, value, true);

	-- Also set the target
	mainmemory.writefloat(Game.Memory.z_rotation + 4, value, true);
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	return mainmemory.readfloat(Game.Memory.x_velocity, true);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity, true);
end

function Game.colorYVelocity()
	if Game.getYVelocity() <= Game.Memory.clip_vel then
		return colors.green;
	end
end

function Game.getZVelocity()
	return mainmemory.readfloat(Game.Memory.z_velocity, true);
end

function Game.setXVelocity(value)
	return mainmemory.writefloat(Game.Memory.x_velocity, value, true);
end

function Game.setYVelocity(value)
	return mainmemory.writefloat(Game.Memory.y_velocity, value, true);
end

function Game.setZVelocity(value)
	return mainmemory.writefloat(Game.Memory.z_velocity, value, true);
end

function Game.getVelocity() -- Calculated VXZ
	local vX = Game.getXVelocity();
	local vZ = Game.getZVelocity();
	return math.sqrt(vX*vX + vZ*vZ);
end

function Game.clearAverageVelocity()
	Game.totalVelocity = 0;
	Game.previousFrame = 0;
	Game.currentFrame = 0;
	Game.framesPassed = 0;
end
Game.clearAverageVelocity();
ScriptHawk.bindKeyRealtime("Slash", Game.clearAverageVelocity, true);

function Game.updateAverageVelocity()
	Game.previousFrame = Game.currentFrame;
	Game.currentFrame = emu.framecount();
	if Game.currentFrame == Game.previousFrame + 1 then
		Game.framesPassed = Game.framesPassed + 1;
		Game.totalVelocity = Game.totalVelocity + Game.getVelocity();
	end
end

function Game.getAverageVelocity()
	if Game.totalVelocity == 0 or Game.framesPassed == 0 then
		return 0;
	end
	return Game.totalVelocity / Game.framesPassed;
end

-------------------------------------
-- Freeze Clip Velocity            --
-- Written by Isotarge, 2015-2016  --
-------------------------------------

-- This function can be used to check for RTA or TAS viability of a clip using the standard talon trot setup.

-- Since RTA and TAS viable talon trot clips work by exceeding clip velocity (differs on PAL/NTSC)
-- while hooked (off the ground) on an edge that it's possible to ascend without jumping, it's possible
-- that simply freezing Y velocity at -4000 using the RAM watch will yield false positives for talon trot style clips
-- by allowing the player to have -4000 velocity while on the ground, which is not possible RTA or TAS.

-- Thus this method only freezes Y velocity at -4000 while the player is in the air.

-- Unfortunately this comes at a cost of false negatives, for example, the Clanker's Cavern lobby clip
-- might not be possible with this method since it (seemingly) requires a small height boost during the talon trot setup
-- which this method prevents due to the steep increase of velocity over one frame.

-- Ideally, when searching for talon trot style clips, you'd initially lock your Y velocity at -4000 using standard tools
-- to avoid false negatives, then verify that it's psosible RTA or TAS using this function to minimize false positives.

function freezeClipVelocity()
	local inputs = joypad.getimmediate();
	-- if not ScriptHawk.UI.ischecked("freeze_clip_velocity") or inputs["P1 L"] or inputs["P1 A"] then
	if not ScriptHawk.UI.ischecked("freeze_clip_velocity") or inputs["P1 L"] then -- TODO: Less hacky method of detecting moonjump lol
		return;
	end

	if not Game.isGrounded() and Game.getYVelocity() > -4000 then
		Game.setYVelocity(-4000); -- This velocity is pretty much guaranteed to clip on any version if it's possible at all
	end
end

-------------------
-- Actor Spawner --
-------------------

spawner = {
	enabled = false,
	actorFlag = 0, -- Memory address of the flag that is checked to decide whether to spawn an actor
	carryFlag = 0, -- Memory address of the flag that is checked to decide whether to carry the spawned actor
	actorID = 0, -- Memory address of the ID of the actor that will be spawned
	actorPosition = 0, -- Memory address of the array of coordinates to spawn the actor at
	staticPosition = false, -- Boolean to toggle updating spawner position to player position each frame
};

function spawner.enable()
	spawner.enabled = false;
	if Game.version == 1 then
		loadASMPatch("./docs/BK ASM Hacking/Actor Spawner (PAL).asm", true);
	elseif Game.version == 2 then
		loadASMPatch("./docs/BK ASM Hacking/Actor Spawner (Japan).asm", true);
	elseif Game.version == 3 then
		loadASMPatch("./docs/BK ASM Hacking/Actor Spawner (USA 1.1).asm", true);
	elseif Game.version == 4 then
		loadASMPatch("./docs/BK ASM Hacking/Actor Spawner (USA 1.0).asm", true);
	end
	-- Find magic flag
	for i = 0x400000, RDRAMSize, 4 do
		if mainmemory.read_u32_be(i) == 0xABCDEF12 then
			print("Actor Spawner enabled successfully!");
			spawner.actorFlag = i + 4;
			spawner.carryFlag = i + 5;
			spawner.actorID = i + 6;
			spawner.actorPosition = i + 8;
			spawner.staticPosition = false;
			spawner.enabled = true;
			break;
		end
	end
end

function spawner.setPosition(x, y, z)
	if spawner.enabled then
		spawner.staticPosition = true;
		mainmemory.writefloat(spawner.actorPosition, x, true);
		mainmemory.writefloat(spawner.actorPosition + 4, y, true);
		mainmemory.writefloat(spawner.actorPosition + 8, z, true);
	end
end

function spawner.updatePosition()
	if spawner.enabled and not spawner.staticPosition then
		mainmemory.writefloat(spawner.actorPosition, Game.getXPosition(), true);
		mainmemory.writefloat(spawner.actorPosition + 4, Game.getYPosition(), true);
		mainmemory.writefloat(spawner.actorPosition + 8, Game.getZPosition(), true);
	end
end

local actorTypes = require "games.bk_objects_USA";
local actorNames = {};
for k, v in pairs(actorTypes) do
	table.insert(actorNames, v.name);
end

function getActorID(name)
	for k, v in pairs(actorTypes) do
		if v.name == name then
			return v.id;
		end
	end
	return 0;
end

function spawner.spawn(id)
	if not spawner.enabled then
		spawner.enable();
	end
	if spawner.enabled then
		if type(id) == 'nil' then
			id = getActorID(forms.gettext(ScriptHawk.UI.form_controls.actor_dropdown));
		end
		spawner.updatePosition();
		mainmemory.writebyte(spawner.actorFlag, 1);
		if ScriptHawk.UI.ischecked("spawner_carry_checkbox") then
			mainmemory.writebyte(spawner.carryFlag, 1);
		else
			mainmemory.writebyte(spawner.carryFlag, 0);
		end
		mainmemory.write_u16_be(spawner.actorID, id);
	else
		print("Error enabling the Actor Spawner :(");
	end
end

function spawner.disable()
	spawner.enabled = false;
end

------------
-- Events --
------------

Game.takeMeThereType = "Button";
function Game.setMap(value)
	if value >= 1 and value <= #Game.maps then
		mainmemory.writebyte(Game.Memory.map, value);

		-- Force the game to load the map instantly
		mainmemory.writebyte(Game.Memory.map - 1, 0x01);
	end
end

function Game.applyInfinites()
	-- We don't apply infinite notes since it messes up note routing
	local collectable_base = Game.Memory.collectable_base;
	--mainmemory.write_s32_be(collectable_base + collectable_offsets.notes, max_notes);
	mainmemory.write_s32_be(collectable_base + collectable_offsets.eggs, max_eggs);
	mainmemory.write_s32_be(collectable_base + collectable_offsets.red_feathers, max_red_feathers);
	mainmemory.write_s32_be(collectable_base + collectable_offsets.gold_feathers, max_gold_feathers);
	mainmemory.write_s32_be(collectable_base + collectable_offsets.health, mainmemory.read_s32_be(collectable_base + collectable_offsets.health_containers));
	mainmemory.write_s32_be(collectable_base + collectable_offsets.lives, max_lives);
	mainmemory.write_s32_be(collectable_base + collectable_offsets.air, max_air);
	mainmemory.write_s32_be(collectable_base + collectable_offsets.mumbo_tokens, max_mumbo_tokens);
	mainmemory.write_s32_be(collectable_base + collectable_offsets.mumbo_tokens_on_hand, max_mumbo_tokens);
	mainmemory.write_s32_be(collectable_base + collectable_offsets.jiggies, max_jiggies);
	mainmemory.write_s32_be(collectable_base + collectable_offsets.joker_cards, max_joker_cards);
end

----------------
-- Flag Stuff --
----------------

function flagIndexToByteBit(flagType, index)
	local flagByte = math.floor(index / 8);
	local flagBit = index % 8;
	if flagType == "Prog" then
		-- These bits are flipped for progress flags, but only for the second byte in the array, I have no idea why
		if flagByte == 1 then
			if flagBit == 0 then
				flagBit = 1;
			elseif flagBit == 1 then
				flagBit = 0;
			end
		end
	else
		-- Again, I have no idea why
		if flagBit == 0 then
			flagByte = math.floor(index / 8) - 1;
		end
	end
	return flagByte, flagBit;
end

function flagByteBitToIndex(flagType, flagByte, flagBit)
	if flagType == "Prog" then
		-- These bits are flipped for progress flags, but only for the second byte in the array, I have no idea why
		if flagByte == 1 then
			if flagBit == 0 then
				flagBit = 1;
			elseif flagBit == 1 then
				flagBit = 0;
			end
		end
	else
		-- Again, I have no idea why
		if flagBit == 0 then
			flagByte = flagByte + 1;
		end
	end
	return flagByte * 8 + flagBit;
end

local function getFlagByName(flagName)
	for i = 1, #flag_array do
		if flagName == flag_array[i].name then
			return flag_array[i];
		end
	end
end

function getFlagName(flagType, flagIndex)
	for i = 1, #flag_array do
		if flagType == flag_array[i].type and flagIndex == flag_array[i].index then
			return flag_array[i].name;
		end
	end
	return "Unknown "..tostring(flagType).." > "..toHexString(flagIndex);
end

function flagTypeToBitfieldPointer(flagType, index)
	if flagType == "H" and index < 0x19 then
		return Game.Memory.honeycomb_bitfield;
	elseif flagType == "MT" and index < 0x7E then
		return Game.Memory.mumbo_token_bitfield;
	elseif flagType == "Jig" and index < 0x65 then
		return Game.Memory.jiggy_bitfield;
	elseif flagType == "Prog" and index < 0x100 then
		return Game.Memory.game_progress_bitfield;
	end
end

------------------------
-- Set Flag Functions --
------------------------

function setFlag(flagType, index, suppressPrint)
	local bitfield_pointer = flagTypeToBitfieldPointer(flagType, index);
	if isRDRAM(bitfield_pointer) then
		local flagByte, flagBit = flagIndexToByteBit(flagType, index);
		local containingByte = bitfield_pointer + flagByte;
		local currentValue = mainmemory.readbyte(containingByte);
		mainmemory.writebyte(containingByte, bit.set(currentValue, flagBit));
		if ScriptHawk.UI.ischecked("realtime_flags") and not suppressPrint then
			checkFlags();
		end
	end
end

function setFlagByName(flagName)
	local flag = getFlagByName(flagName);
	if type(flag) == "table" then
		setFlag(flag.type, flag.index);
	end
end

function setFlagsByType(flagType)
	for i = 1, #flag_array do
		local flag = flag_array[i];
		if flag.type == flagType then
			setFlag(flagType, flag.index, true);
		end
	end
	if ScriptHawk.UI.ischecked("realtime_flags") then
		checkFlags();
	end
end

function setFlagsByLevel(levelIndex)
	for i = 1, #flag_array do
		local flag = flag_array[i];
		if flag.level == levelIndex then
			setFlag(flag.type, flag.index, true);
		end
	end
	if ScriptHawk.UI.ischecked("realtime_flags") then
		checkFlags();
	end
end

function setAllFlags()
	for i = 1, #flag_array do
		setFlag(flag_array[i].type, flag_array[i].index, true);
	end
	if ScriptHawk.UI.ischecked("realtime_flags") then
		checkFlags();
	end
end

--------------------------
-- Clear Flag Functions --
--------------------------

function clearFlag(flagType, index, suppressPrint)
	local bitfield_pointer = flagTypeToBitfieldPointer(flagType, index);
	if isRDRAM(bitfield_pointer) then
		local flagByte, flagBit = flagIndexToByteBit(flagType, index);
		local containingByte = bitfield_pointer + flagByte;
		local currentValue = mainmemory.readbyte(containingByte);
		mainmemory.writebyte(containingByte, bit.clear(currentValue, flagBit));
		if ScriptHawk.UI.ischecked("realtime_flags") and not suppressPrint then
			checkFlags();
		end
	end
end

function clearFlagByName(flagName)
	local flag = getFlagByName(flagName);
	if type(flag) == "table" then
		clearFlag(flag.type, flag.index);
	end
end

function clearFlagsByType(flagType)
	for i = 1, #flag_array do
		local flag = flag_array[i];
		if flag.type == flagType then
			clearFlag(flagType, flag.index, true);
		end
	end
	if ScriptHawk.UI.ischecked("realtime_flags") then
		checkFlags();
	end
end

function clearFlagsByLevel(levelIndex)
	for i = 1, #flag_array do
		local flag = flag_array[i];
		if flag.level == levelIndex then
			clearFlag(flag.type, flag.index, true);
		end
	end
	if ScriptHawk.UI.ischecked("realtime_flags") then
		checkFlags();
	end
end

function clearAllFlags()
	for i = 1, #flag_array do
		clearFlag(flag_array[i].type, flag_array[i].index, true);
	end
	if ScriptHawk.UI.ischecked("realtime_flags") then
		checkFlags();
	end
end

--------------------------
-- Check flag functions --
--------------------------

function checkFlag(flagType, index)
	local bitfield_pointer = flagTypeToBitfieldPointer(flagType, index);
	if isRDRAM(bitfield_pointer) then
		local flagByte, flagBit = flagIndexToByteBit(flagType, index);
		local containingByte = bitfield_pointer + flagByte;
		local currentValue = mainmemory.readbyte(containingByte);
		return bit.check(currentValue, flagBit);
	end
	return false;
end

function checkFlagByName(flagName)
	local flag = getFlagByName(flagName);
	if type(flag) == "table" then
		if checkFlag(flag.type, flag.index) then
			print('The flag "'..flag.name..'" is SET');
		else
			print('The flag "'..flag.name..'" is NOT set');
		end
	end
end

function checkFlagsByType(flagType)
	for i = 1, #flag_array do
		local flag = flag_array[i];
		if flag.type == flagType then
			local flagByte, flagBit = flagIndexToByteBit(flag.type, flag.index);
			if checkFlag(flag.type, flag.index) then
				dprint('Index: '..toHexString(flag.index)..': '..toHexString(flagByte)..'>'..flagBit..' SET: "'..flag.name..'"');
			else
				dprint('Index: '..toHexString(flag.index)..': '..toHexString(flagByte)..'>'..flagBit..' NOT SET: "'..flag.name..'"');
			end
		end
	end
	print_deferred();
end

local flagBlockCache = nil;

local function checkFlagsTypeInternal(currentFlags, currentFrame, flagType, maxIndex, maxByte)
	local flagChangedThisFrame = false;
	for i = 0, maxByte do
		if flagBlockCache[flagType][i] ~= currentFlags[flagType][i] then
			for j = 0, 7 do
				local flagIndex = flagByteBitToIndex(flagType, i, j);
				if flagIndex > 0 and flagIndex < maxIndex then
					local wasSet = bit.check(flagBlockCache[flagType][i], j);
					local isSet = bit.check(currentFlags[flagType][i], j);
					if wasSet and not isSet then
						dprint('Flag CLEARED on frame '..currentFrame..' "'..getFlagName(flagType, flagIndex)..'"');
						flagChangedThisFrame = true;
					elseif not wasSet and isSet then
						dprint('Flag SET on frame '..currentFrame..' "'..getFlagName(flagType, flagIndex)..'"');
						flagChangedThisFrame = true;
					end
				end
			end
		end
	end
	return flagChangedThisFrame;
end

function checkFlags()
	local currentFrame = emu.framecount();
	local currentFlags = {
		H = mainmemory.readbyterange(Game.Memory.honeycomb_bitfield, 3), -- 0x18 / 8 = 3 bytes
		MT = mainmemory.readbyterange(Game.Memory.mumbo_token_bitfield, 16), -- 0x7D / 8 ~= 16 bytes (15 bytes 5 bits)
		Jig = mainmemory.readbyterange(Game.Memory.jiggy_bitfield, 13), -- 0x64 / 8 ~= 13 bytes (12 bytes 4 bits)
		Prog = mainmemory.readbyterange(Game.Memory.game_progress_bitfield, 32), -- 0xFF / 8 ~= 32 bytes (31 bytes 7 bits)
	};
	if flagBlockCache ~= nil then
		local flagChangedThisFrame = false;
		flagChangedThisFrame = flagChangedThisFrame or checkFlagsTypeInternal(currentFlags, currentFrame, "H", 0x19, 2);
		flagChangedThisFrame = flagChangedThisFrame or checkFlagsTypeInternal(currentFlags, currentFrame, "MT", 0x7E, 15);
		flagChangedThisFrame = flagChangedThisFrame or checkFlagsTypeInternal(currentFlags, currentFrame, "Jig", 0x65, 12);
		flagChangedThisFrame = flagChangedThisFrame or checkFlagsTypeInternal(currentFlags, currentFrame, "Prog", 0x100, 31);
		if flagChangedThisFrame then
			print_deferred();
		end
	else
		print("Populated flag block cache");
	end
	flagBlockCache = currentFlags;
end

--------------------------
-- Other flag functions --
--------------------------

local function flagSetButtonHandler()
	setFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagClearButtonHandler()
	clearFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagCheckButtonHandler()
	checkFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.button(10, 8, {46}, nil, "Set Flag Button", "Set", flagSetButtonHandler);
		ScriptHawk.UI.button(12, 8, {46}, nil, "Check Flag Button", "Check", flagCheckButtonHandler);
		ScriptHawk.UI.button(14, 8, {46}, nil, "Clear Flag Button", "Clear", flagClearButtonHandler);

		ScriptHawk.UI.checkbox(0, 6, "toggle_neverslip", "Never Slip");
		ScriptHawk.UI.checkbox(5, 4, "encircle_checkbox", "Encircle (Beta)");
		ScriptHawk.UI.checkbox(5, 5, "dynamic_radius_checkbox", "Dynamic Radius");
		ScriptHawk.UI.checkbox(5, 6, "freeze_clip_velocity", "Freeze Clip Vel.");

		ScriptHawk.UI.checkbox(10, 2, "beta_pause_menu_checkbox", "Beta Pause");

		-- Actor spawner
		ScriptHawk.UI.form_controls.actor_dropdown = forms.dropdown(ScriptHawk.UI.options_form, actorNames, ScriptHawk.UI.col(10) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(0) + ScriptHawk.UI.dropdown_offset);
		ScriptHawk.UI.button(10, 1, 2, nil, nil, "Spawn", spawner.spawn);
		ScriptHawk.UI.checkbox({12, 10}, 1, "spawner_carry_checkbox", "Carry?");

		-- Vile
		--ScriptHawk.UI.button(10, 4, 2, nil, nil, "Wave", initWave);
		--ScriptHawk.UI.button({12, 8}, 4, 2, nil, nil, "Heart", doHeart);
		--ScriptHawk.UI.button(10, 5, {4, 8}, nil, nil, "Fire all", fireAllSlots);

		-- Moves
		ScriptHawk.UI.form_controls.moves_dropdown = forms.dropdown(ScriptHawk.UI.options_form, { "5. All Minus Swim", "4. None", "3. SM 100%", "2. FFM Setup", "1. All", "0. Demo" }, ScriptHawk.UI.col(10) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(5) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 8, ScriptHawk.UI.button_height);
		ScriptHawk.UI.button(10, 6, {4, 8}, nil, nil, "Unlock Moves", unlock_moves);
	else
		-- Use a bigger check flags button if the others are hidden by TASSafe
		ScriptHawk.UI.button(10, 8, {4, 10}, nil, "Check Flag Button", "Check Flag", flagCheckButtonHandler);
	end

	ScriptHawk.UI.form_controls["Flag Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, flag_names, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(8) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);

	ScriptHawk.UI.checkbox(10, 4, "autopound_checkbox", "Auto Pound");
	ScriptHawk.UI.checkbox(10, 7, "realtime_flags", "Realtime Flags", true);

	-- Create Inverse Object_Slot_Variables
	for k, v in pairs(slot_variables) do
		if v.Name then
			if type(v.Name) == 'table' then
				for l, w in pairs(v.Name) do
					slot_variables_inv[v.Name[l]] = k;
				end
			else
				slot_variables_inv[v.Name] = k;
			end
		end
	end
end

function Game.onLoadState()
	-- Clear flag block cache
	flagBlockCache = nil;
	if ScriptHawk.UI.ischecked("realtime_flags") then
		checkFlags();
	end

	-- Disable actor spawner
	-- It's possible that the savestate that was loaded does not have the needed ASM patch installed
	spawner.disable();
end

function Game.eachFrame()
	Game.updateAverageVelocity();
	updateWave();
	freezeClipVelocity();

	if ScriptHawk.UI.ischecked("toggle_neverslip") then
		neverSlip();
	end

	if ScriptHawk.UI.ischecked("encircle_checkbox") then
		encircle_banjo();
	end

	if ScriptHawk.UI.ischecked("beta_pause_menu_checkbox") then
		beta_menu_recreate();
	end

	if ScriptHawk.UI.ischecked("autopound_checkbox") then
		autoPound();
	end

	if ScriptHawk.UI.ischecked("realtime_flags") then
		checkFlags();
	end

	-- Check EEPROM checksums
	local checksum_value;
	for i = 1, #eep_checksum do
		checksum_value = memory.read_u32_be(eep_checksum[i].address, "EEPROM");
		if eep_checksum[i].value ~= checksum_value then
			print("Slot "..i.." Checksum: "..toHexString(eep_checksum[i].value, 8).." -> "..toHexString(checksum_value, 8));
			eep_checksum[i].value = checksum_value;
		end
	end

	if ScriptHawk.UI.ischecked("spawner_carry_checkbox") then
		mainmemory.writebyte(Game.Memory.carried_object_pointer + 4, 1);
	end
end

function Game.getJiggyGrabbedPointer()
	local pointer = dereferencePointer(Game.Memory.jiggy_grabbed_behavior_struct_pointer);
	if isRDRAM(pointer) then
		return toHexString(pointer);
	end
end

function Game.getJiggyGrabbedIndex()
	local pointer = dereferencePointer(Game.Memory.jiggy_grabbed_behavior_struct_pointer);
	if isRDRAM(pointer) then
		local index = bit.rshift(mainmemory.read_u16_be(pointer + 0x2C), 5) + 1;
		local objectArray = dereferencePointer(Game.Memory.object_array_pointer);
		if isRDRAM(objectArray) then
			return index.." ("..getObjectName(objectArray + getSlotBase(index - 1))..")";
		else
			return index;
		end
	end
end

function Game.getJiggySpawnAngle()
	return mainmemory.readfloat(Game.Memory.jiggy_spawn_angle, true);
end

function Game.setJiggySpawnAngle(value)
	mainmemory.writefloat(Game.Memory.jiggy_spawn_angle, value, true);
end

Game.OSD = {
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"Floor", Game.getFloor, category="position"},
	{"Zip", Game.predictZip, Game.colorZipPrediction, category="positionStats"},
	{"Landing Y", Game.getPredictedYPositionRelativeToFloor, category="positionStats"},
	{"Landing", Game.getPredictedLandingFrame, category="positionStats"},
	{"Separator"},
	{"Y Velocity", Game.getYVelocity, Game.colorYVelocity, category="speed"},
	{"Velocity", Game.getVelocity, category="speed"};
	{"Avg Velocity", Game.getAverageVelocity, category="speed"};
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"},
	{"Movement", Game.getCurrentMovementState, Game.colorCurrentMovementState, category="movement"},
	{"Slope Timer", Game.getSlopeTimer, Game.colorSlopeTimer, category="floorProperties"},
	{"Grounded", Game.isGrounded, category="floorProperties"},
	{"Wall Collisions", Game.getWallCollisions, category="wallProperties"},
	{"Beak Bomb Available", Game.isBeakBombAvailable, Game.colorBeakBombAvailable, category="movement"},
	{"Separator"},
	{"Facing", Game.getFacingAngle, category="angle"},
	{"Moving", Game.getYRotation, category="angle"},
	{"Moving Angle", category="angle"},
	{"Rot. X", Game.getXRotation, category="angle"},
	{"Rot. Z", Game.getZRotation, category="angle"},
	{"Separator"},
	{"FF Answer", getCorrectFFAnswer, category="ffunAnswer"},
	{"FF Pattern", Game.getFFPattern, category="ffunPattern"},
	{"Separator"},
	{"Jiggy Spawn Angle", Game.getJiggySpawnAngle, category="angle"},
	{"Jiggy Grabbed", Game.getJiggyGrabbedPointer, category="objectDespawn"},
	{"Index Grabbed", Game.getJiggyGrabbedIndex, category="objectDespawn"},
};

return Game;