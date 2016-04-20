local Game = {};

--------------------
-- Region/Version --
--------------------

local framebuffer_width = 292; -- Bigger on PAL
local framebuffer_height = 200; -- Bigger on PAL

local clip_vel = -3500; -- Minimum velocity required to clip on the Y axis -- TODO: This seems to be different for different geometry

-- Relative to notes
-- TODO: Add jinjos
local eggs = 4;
local red_feathers = 12;
local gold_feathers = 16;
local health = 32;
local health_containers = 36;
local lives = 40;
local air = 44;
local mumbo_tokens_on_hand = 64;
local mumbo_tokens = 100;
local jiggies = 104;

local max_notes = 100;
local max_eggs = 200; -- TODO: How do you get this information out of the game?
	-- The max eggs value appears in register v0 when executing the beql at 0x80346200
local max_red_feathers = 50; -- TODO: How do you get this information out of the game?
local max_gold_feathers = 10; -- TODO: How do you get this information out of the game?
local max_lives = 9;
local max_air = 6 * 600;
local max_mumbo_tokens = 99;
local max_jiggies = 100;

local eep_checksum_offsets = {
	0x74,
	0xEC,
	0x164,
	0x1DC,
	0x1FC
};

local eep_checksum_values = {
	0x00000000,
	0x00000000,
	0x00000000,
	0x00000000,
	0x00000000
}

Game.maps = {
	"SM - Spiral Mountain",
	"MM - Mumbo's Mountain",
	"Unknown 0x03",
	"Unknown 0x04",
	"TTC - Blubber's Ship",
	"TTC - Nipper's Shell",
	"TTC - Treasure Trove Cove",
	"Unknown 0x08",
	"Unknown 0x09",
	"TTC - Sandcastle",
	"CC - Clanker's Cavern",
	"MM - Ticker's Tower",
	"BGS - Bubblegloop Swamp",
	"Mumbo's Skull (MM)",
	"Unknown 0x0F",
	"BGS - Mr. Vile",
	"BGS - Tiptup",
	"GV - Gobi's Valley",
	"GV - Matching Game",
	"GV - Maze",
	"GV - Water",
	"GV - Rubee's Chamber",
	"Unknown 0x17",
	"Unknown 0x18",
	"Unknown 0x19",
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
	"MMM - Church",
	"MMM - Room 4: Bathroom",
	"MMM - Room 5: Bedroom",
	"MMM - Room 6: Floorboards",
	"MMM - Barrel",
	"Mumbo's Skull (MMM)",
	"RBB - Rusty Bucket Bay",
	"Unknown 0x32",
	"Unknown 0x33",
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
	"Unknown 0x42",
	"CCW - Spring",
	"CCW - Summer",
	"CCW - Autumn",
	"CCW - Winter",
	"Mumbo's Skull (BGS)",
	"Mumbo's Skull (FP)",
	"Unknown 0x49",
	"Mumbo's Skull (CCW Spring)",
	"Mumbo's Skull (CCW Summer)",
	"Mumbo's Skull (CCW Autumn)",
	"Mumbo's Skull (CCW Winter)",
	"Unknown 0x4E",
	"Unknown 0x4F",
	"Unknown 0x50",
	"Unknown 0x51",
	"Unknown 0x52",
	"FP - Inside Xmas Tree",
	"Unknown 0x54",
	"Unknown 0x55",
	"Unknown 0x56",
	"Unknown 0x57",
	"Unknown 0x58",
	"Unknown 0x59",
	"CCW - Zubba's Hive (Summer)",
	"CCW - Zubba's Hive (Spring)",
	"CCW - Zubba's Hive (Autumn)",
	"Unknown 0x5D",
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
	"Unknown 0x73",
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
};

-- Version order: PAL, JP, US 1.1, US 1.0
Game.Memory = {
	["fb_pointer"] = {0x282E00, 0x281E20, 0x281E20, 0x282FE0},
	["frame_timer"] = {0x280700, 0x27F718, 0x27F718, 0x2808D8},
	["slope_timer"] = {0x37CCB4, 0x37CDE4, 0x37B4E4, 0x37C2E4},
	["player_grounded"] = {0x37C930, 0x37CA60, 0x37B160, 0x37BF60},
	["moves_bitfield"] = {0x37CD70, 0x37CEA0, 0x37B5A0, 0x37C3A0},
	["x_velocity"] = {0x37CE88, 0x37CFB8, 0x37B6B8, 0x37C4B8},
	["y_velocity"] = {0x37CE8C, 0x37CFBC, 0x37B6BC, 0x37C4BC},
	["z_velocity"] = {0x37CE90, 0x37CFC0, 0x37B6C0, 0x37C4C0},
	["x_position"] = {0x37CF70, 0x37D0A0, 0x37B7A0, 0x37C5A0},
	["y_position"] = {0x37CF74, 0x37D0A4, 0x37B7A4, 0x37C5A4},
	["z_position"] = {0x37CF78, 0x37D0A8, 0x37B7A8, 0x37C5A8},
	["x_rotation"] = {0x37CF10, 0x37D040, 0x37B740, 0x37C540},
	["y_rotation"] = {0x37D060, 0x37D190, 0x37B890, 0x37C690},
	["facing_angle"] = {0x37D060, 0x37D190, 0x37B890, 0x37C690},
	["moving_angle"] = {0x37D064, 0x37D194, 0x37B894, 0x37C694},
	["z_rotation"] = {0x37D050, 0x37D180, 0x37B880, 0x37C680},
	["camera_rotation"] = {0x37E578, 0x37E6A8, 0x37CDA8, 0x37D96C},
	["previous_movement_state"] = {0x37DB30, 0x37DC60, 0x37C360, 0x37D160},
	["current_movement_state"] = {0x37DB34, 0x37DC64, 0x37C364, 0x37D164},
	["map"] = {0x37F2C5, 0x37F405, 0x37DAF5, 0x37E8F5},
	["ff_question_pointer"] = {0x383AC0, 0x383C20, 0x382300, 0x3830E0},
	["notes"] = {0x386940, 0x386AA0, 0x385180, 0x385F60},
	["object_array_pointer"] = {0x36EAE0, 0x36F260, 0x36D760, 0x36E560},
};

function Game.detectVersion(romName)
	if stringContains(romName, "Europe") then
		version = 1;
		framebuffer_width = 292;
		framebuffer_height = 216;
		clip_vel = -2900;
		Game.allowFurnaceFunPatch = false; -- TODO: FF Patch for this version
		Game.supportsASMHacks = false; -- TODO: Research ASM hook for this version
	elseif stringContains(romName, "Japan") then
		version = 2;
		Game.allowFurnaceFunPatch = false; -- TODO: FF Patch for this version
		Game.supportsASMHacks = false; -- TODO: Research ASM hook for this version
	elseif stringContains(romName, "USA") and stringContains(romName, "Rev A") then
		version = 3;
		Game.allowFurnaceFunPatch = false; -- TODO: FF Patch for this version
		Game.supportsASMHacks = false; -- TODO: Research ASM hook for this version
	elseif stringContains(romName, "USA") then
		version = 4;
		Game.allowFurnaceFunPatch = true;
		Game.supportsASMHacks = true;
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

local function neverSlip()
	mainmemory.writefloat(Game.Memory.slope_timer[version], 0.0, true);
end

function Game.getSlopeTimer()
	return mainmemory.readfloat(Game.Memory.slope_timer[version], true);
end

function Game.colorSlopeTimer()
	if forms.ischecked(ScriptHawkUI.form_controls.toggle_neverslip) then
		return 0xFF00FFFF; -- Light blue
	end
	local slopeTimer = Game.getSlopeTimer();
		if slopeTimer >= 0.75 then
		return getColor(slopeTimer);
	end
end

-----------------
-- Moves stuff --
-----------------

local move_levels = {
	["0. None"]                 = 0x00000000,
	["1. Spiral Mountain 100%"] = 0x00009DB9,
	["2. FFM Setup"]            = 0x000BFDBF,
	["3. All"]                  = 0x000FFFFF,
	["3. Demo"]                 = 0xFFFFFFFF
};

local function unlock_moves()
	local level = forms.gettext(ScriptHawkUI.form_controls.moves_dropdown);
	mainmemory.write_u32_be(Game.Memory.moves_bitfield[version], move_levels[level]);
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

	[113] = "Falling", -- Talon Trot
	[114] = "Recovering", -- Getting up after taking damage, eg. fall famage
	[115] = "Locked", -- Cutscene
	[116] = "Locked", -- Jiggy pad, Mumbo transformation, Bottles
	[117] = "Locked", -- Bottles

	[121] = "Locked", -- Holding Jiggy, Talon Trot
	[122] = "Creeping", -- In damaging water etc
	[123] = "Damaged", -- Talon Trot
	[124] = "Locked", -- Sled in FP sliding down scarf
	[127] = "Damaged", -- Swimming

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
	[157] = "Locked", -- Bee?
	[159] = "Knockback", -- Termite, not damaged
	[160] = "Knockback", -- Pumpkin, not damaged
	[161] = "Knockback", -- Croc, not damaged
	[162] = "Knockback", -- Walrus, not damaged
	[163] = "Knockback", -- Bee, not damaged
	[165] = "Locked", -- Wonderwing
};

function Game.getCurrentMovementState()
	local currentMovementState = mainmemory.read_u32_be(Game.Memory.current_movement_state[version]);
	if type(movementStates[currentMovementState]) ~= "nil" then
		return movementStates[currentMovementState];
	end
	return "Unknown ("..currentMovementState..")";
end

function Game.colorCurrentMovementState()
	local currentMovementState = mainmemory.read_u32_be(Game.Memory.current_movement_state[version]);
	local stringMovementState = Game.getCurrentMovementState();
	if stringMovementState == "Slipping" or stringMovementState == "Skidding" or stringMovementState == "Recovering" or stringMovementState == "Knockback" then
		return 0xFFFFFF00; -- Yellow
	end
	if stringMovementState == "Damaged" or stringMovementState == "Death" then
		return 0xFFFF0000; -- Red
	end
end

---------------
-- Autopound --
---------------

local holdingAPostJump = false;
allowPound = false;
allowTTrotJump = true;
function autoPound()
	if forms.ischecked(ScriptHawkUI.form_controls.autopound_checkbox) then
		local currentMovementState = mainmemory.read_u32_be(Game.Memory.current_movement_state[version]);
		local YVelocity = Game.getYVelocity();

		-- First frame pound out of peck
		if allowPound and currentMovementState == 17 and YVelocity == -272 and not Game.isPhysicsFrame() then -- TODO: YVelocity == -272 doesn't work for all versions
			joypad.set({["Z"] = true}, 1);
		end

		-- Frame perfect mid air talon trot slide jump
		if allowTTrotJump and (currentMovementState == 21 and mainmemory.readbyte(Game.Memory.player_grounded[version]) == 0 or holdingAPostJump) then
			holdingAPostJump = true;
			if holdingAPostJump then
				holdingAPostJump = holdingAPostJump and (currentMovementState == 21 or YVelocity > 0); -- TODO: Better method for detecting end of a jump, velocity > 0 is janky
			end
			joypad.set({["A"] = true}, 1);
		end
	end
end
event.onframestart(autoPound, "ScriptHawk - Auto Pound");

--------------------------
-- Sandcastle positions --
--------------------------

local sandcastle_square_size = 90;
local sandcastlePositions = {
	["A"] = {2, -8},
	["B"] = {0, 6},
	["C"] = {4, -6},
	["D"] = {-4, -2},
	["E"] = {0, -6},
	["F"] = {4, 2},
	["G"] = {-2, -8},
	["H"] = {-4, 6},
	["I"] = {6, 0},
	["J"] = {-6, -8},
	["K"] = {4, 6},
	["L"] = {6, -8},
	["M"] = {-6, -4},
	["N"] = {-2, -4},
	["O"] = {0, -2},
	["P"] = {6, -4},
	-- There's no Q in the sandcastle
	["R"] = {2, -4},
	["S"] = {4, -2},
	["T"] = {0, 2},
	["U"] = {-2, 0},
	["V"] = {-4, -6},
	["W"] = {2, 4},
	["X"] = {-4, 2},
	["Y"] = {2, 0},
	["Z"] = {-6, 0},
};

function gotoSandcastleLetter(letter)
	if type(letter) ~= "string" then
		print("Letter not a string.");
	end

	-- Convert the letter to uppercase
	letter = string.upper(letter);

	if type(sandcastlePositions[letter]) ~= "table" then
		print("Letter not found.");
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

local function applyFurnaceFunPatch() -- TODO: Can we just read the FF bytes from EEPROM?
	if Game.allowFurnaceFunPatch and forms.ischecked(ScriptHawkUI.form_controls.allow_ff_patch) then
		mainmemory.write_u16_be(0x320064, 0x080A);
		mainmemory.write_u16_be(0x320066, 0x1840);

		mainmemory.write_u16_be(0x286100, 0xAC86);
		mainmemory.write_u16_be(0x286102, 0x2DC8);
		mainmemory.write_u16_be(0x286104, 0x0C0C);
		mainmemory.write_u16_be(0x286106, 0x8072);

		mainmemory.write_u16_be(0x28610C, 0x080C);
		mainmemory.write_u16_be(0x28610E, 0x801B);
	end
end

-- Relative to question object
local ff_current_answer = 0x13;
local ff_correct_answer = 0x1D;

local ff_question_text_pointer = 0x34;
local ff_answer1_text_pointer = 0x64;
local ff_answer2_text_pointer = 0x54;
local ff_answer3_text_pointer = 0x44;

function getSelectedFFAnswer()
	local ff_question_object = dereferencePointer(Game.Memory.ff_question_pointer[version]);
	if isRDRAM(ff_question_object) then
		return mainmemory.readbyte(ff_question_object + ff_current_answer);
	end
	return 0;
end

-- TODO: Doesn't always work
function getCorrectFFAnswer()
	local ff_question_object = dereferencePointer(Game.Memory.ff_question_pointer[version]);
	if isRDRAM(ff_question_object) then
		return mainmemory.readbyte(ff_question_object + ff_correct_answer);
	end
	return 0;
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
local first_slot_base = 0x08;
local slot_size = 0x180;
local slot_base = first_slot_base + 2 * slot_size;

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
			if mainmemory.readfloat(objectArray + first_slot_base + (i * slot_size) + 0x08, true) == -100 then
				if slotsFound == index then
					return objectArray + first_slot_base + (i * slot_size);
				end
				slotsFound = slotsFound + 1;
			end
		end
	end
end

local function fireSlot(objectArray, index, slotType)
	current_slot_base = getVileSlotBase(objectArray, index);
	if isRDRAM(current_slot_base) then
		mainmemory.writebyte(current_slot_base + slot_state, 0x0C);
		mainmemory.writebyte(current_slot_base + slot_type, slotType);
		mainmemory.writefloat(current_slot_base + popped_amount, 1.0, true);
		mainmemory.writefloat(current_slot_base + slot_timer, 0.1, true);
	end
end

local vileMap = {
	{ 22, 24, 16 },
	{ 21, 23, 14, 15 },
	{ 20, 19, 17, 13, 12 },
	{ 9,  18, 11, 4 },
	{ 10, 7,  8,  2,  1  },
	{ 6,  5,  3,  0 }
};

local heart = {
	{2, 2}, {2, 3},
	{3, 2}, {3, 3}, {3, 4},
	{4, 2}, {4, 3},
	{5, 3}
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
	{ {3, 5}, {5, 5} }
}

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
			local objectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
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
	local objectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
	if isRDRAM(objectArray) then
		local colour = math.random(0, 1);
		for i = 1, #heart do
			fireSlot(objectArray, getSlotIndex(heart[i][1], heart[i][2]), colour);
		end
	end
end

local function fireAllSlots()
	local objectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
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
	if mainmemory.readbyte(Game.Memory.map[version]) == 0x02 then -- Make sure we're in Mumbo's Mountain
		local levelObjectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
		if isRDRAM(levelObjectArray) then
			local numObjects = mainmemory.read_u32_be(levelObjectArray);
			for i = 0, numObjects do
				local slotBase = levelObjectArray + first_slot_base + (i * slot_size);
				local x = mainmemory.readfloat(slotBase + 0x04, true);
				local y = mainmemory.readfloat(slotBase + 0x08, true);
				local z = mainmemory.readfloat(slotBase + 0x0C, true);
				if x == -4100 and y == 236 and z == 4650 then -- TODO: Base this off of animation type, rather than position
					return slotBase;
				end
			end
		end
	end
end

function throwOrange()
	local congaBase = findConga();
	if isRDRAM(congaBase) then
		mainmemory.writefloat(congaBase + 0x114, 0.5, true); -- Write 0.5 to main behavior timer, these fields are documented in Beta/Level Object Analyser.lua
	end
end

ScriptHawk.bindKeyFrame("C", throwOrange, false);

--------------
-- Encircle --
--------------

local dynamic_radius_factor = 15;
y_stagger_amount = 10;

-- Relative to level_object_array
local max_slots = 0x100;
local radius = 1000;

-- Relative to slot
local slot_x_pos = 0x04;
local slot_y_pos = 0x08;
local slot_z_pos = 0x0C;

local function get_num_slots()
	local levelObjectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
	if isRDRAM(levelObjectArray) then
		return math.min(max_slots, mainmemory.read_u32_be(levelObjectArray));
	end
	return 0;
end

local function get_slot_base(index)
	local levelObjectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
	if isRDRAM(levelObjectArray) then
		return levelObjectArray + first_slot_base + index * slot_size;
	end
	return 0;
end

local function encircle_banjo()
	local current_banjo_x = Game.getXPosition();
	local current_banjo_y = Game.getYPosition();
	local current_banjo_z = Game.getZPosition();
	local currentPointers = {};

	num_slots = get_num_slots();

	radius = 1000;
	if forms.ischecked(ScriptHawkUI.form_controls.dynamic_radius_checkbox) then
		radius = num_slots * dynamic_radius_factor;
	end

	-- Fill and sort pointer list
	for i = 0, num_slots - 1 do
		-- TODO: Check for bone arrays before adding to table, we don't want to move stuff we can't see
		table.insert(currentPointers, get_slot_base(i));
	end
	table.sort(currentPointers);

	-- Iterate and set position
	local x, z;
	for i = 1, #currentPointers do
		x = current_banjo_x + math.cos(math.pi * 2 * i / #currentPointers) * radius;
		z = current_banjo_z + math.sin(math.pi * 2 * i / #currentPointers) * radius;

		mainmemory.writefloat(currentPointers[i] + slot_x_pos, x, true);
		mainmemory.writefloat(currentPointers[i] + slot_y_pos, current_banjo_y + i * y_stagger_amount, true);
		mainmemory.writefloat(currentPointers[i] + slot_z_pos, z, true);
	end
end

----------------------
-- Framebuffer Jank --
----------------------

-- TODO: Not working?
function fillFB()
	local frameBufferLocation = dereferencePointer(Game.Memory.fb_pointer[version]);
	if isRDRAM(frameBufferLocation) then
		replaceTextureRGBA5551(nil, frameBufferLocation, framebuffer_width, framebuffer_height)
	end
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .1, 1, 5, 10, 20, 35, 50, 75, 100 };
Game.speedy_index = 6;

Game.rot_speed = 5;
Game.max_rot_units = 360;

function Game.isPhysicsFrame()
	local frameTimerValue = mainmemory.read_s32_be(Game.Memory.frame_timer[version]);
	return frameTimerValue <= 0 and not emu.islagged();
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.x_position[version], true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_position[version], true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_position[version], true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(Game.Memory.x_position[version], value, true);
	mainmemory.writefloat(Game.Memory.x_position[version] + 0x10, value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.y_position[version], value, true);
	mainmemory.writefloat(Game.Memory.y_position[version] + 0x10, value, true);

	-- Nullify gravity when setting Y position
	Game.setYVelocity(0);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_position[version], value, true);
	mainmemory.writefloat(Game.Memory.z_position[version] + 0x10, value, true);
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	return mainmemory.readfloat(Game.Memory.x_rotation[version], true);
end

function Game.getYRotation()
	return mainmemory.readfloat(Game.Memory.moving_angle[version], true);
end

function Game.getFacingAngle()
	return mainmemory.readfloat(Game.Memory.facing_angle[version], true);
end

function Game.getZRotation()
	return mainmemory.readfloat(Game.Memory.z_rotation[version], true);
end

function Game.setXRotation(value)
	mainmemory.writefloat(Game.Memory.x_rotation[version], value, true);

	-- Also set the target
	mainmemory.writefloat(Game.Memory.x_rotation[version] + 4, value, true);
end

function Game.setYRotation(value)
	mainmemory.writefloat(Game.Memory.moving_angle[version], value, true);
	mainmemory.writefloat(Game.Memory.facing_angle[version], value, true);
end

function Game.setZRotation(value)
	mainmemory.writefloat(Game.Memory.z_rotation[version], value, true);

	-- Also set the target
	mainmemory.writefloat(Game.Memory.z_rotation[version] + 4, value, true);
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	return mainmemory.readfloat(Game.Memory.x_velocity[version], true);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity[version], true);
end

function Game.colorYVelocity()
	if Game.getYVelocity() <= clip_vel then
		return 0xFF00FF00; -- Green
	end
end

function Game.getZVelocity()
	return mainmemory.readfloat(Game.Memory.z_velocity[version], true);
end

function Game.setXVelocity(value)
	return mainmemory.writefloat(Game.Memory.x_velocity[version], value, true);
end

function Game.setYVelocity(value)
	return mainmemory.writefloat(Game.Memory.y_velocity[version], value, true);
end

function Game.setZVelocity(value)
	return mainmemory.writefloat(Game.Memory.z_velocity[version], value, true);
end

function Game.getVelocity() -- Calculated VXZ
	local vX = Game.getXVelocity();
	local vZ = Game.getZVelocity();
	return math.sqrt(vX*vX + vZ*vZ);
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
	-- if not forms.ischecked(ScriptHawkUI.form_controls.freeze_clip_velocity) or inputs["P1 L"] or inputs["P1 A"] then
	if not forms.ischecked(ScriptHawkUI.form_controls.freeze_clip_velocity) or inputs["P1 L"] then -- TODO: Less hacky method of detecting moonjump lol
		return;
	end

	if mainmemory.readbyte(Game.Memory.player_grounded[version]) == 0 and Game.getYVelocity() > -4000 then
		Game.setYVelocity(-4000); -- This velocity is pretty much guaranteed to clip on any version if it's possible at all
	end
end

-------------------
-- Actor Spawner --
-------------------

local spawnerEnabled = false;
local spawnActorFlag;
local spawnActorID;
local actorPosition;

function enableActorSpawner()
	if version == 4 then -- TODO: Other versions
		spawnerEnabled = false;
		loadASMPatch("./docs/BK ASM Hacking/Actor Spawner.asm", true);
		-- Find magic flag
		for i = Game.ASMCodeBase, Game.ASMCodeBase + Game.ASMMaxCodeSize, 4 do
			if mainmemory.read_u32_be(i) == 0xABCDEF12 then
				print("Actor spawner enabled successfully!");
				spawnActorFlag = i + 4;
				spawnActorID = i + 6;
				actorPosition = i + 8;
				spawnerEnabled = true;
				break;
			end
		end
	end
end

function updateActorSpawnPosition()
	if spawnerEnabled then
		mainmemory.writefloat(actorPosition, Game.getXPosition(), true);
		mainmemory.writefloat(actorPosition + 4, Game.getYPosition(), true);
		mainmemory.writefloat(actorPosition + 8, Game.getZPosition(), true);
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

function spawnActor(id)
	if not spawnerEnabled then
		enableActorSpawner();
	end
	if spawnerEnabled then
		if type(id) == 'nil' then
			id = getActorID(forms.gettext(ScriptHawkUI.form_controls.actor_dropdown));
		end
		updateActorSpawnPosition();
		mainmemory.write_u16_be(spawnActorFlag, 1);
		mainmemory.write_u16_be(spawnActorID, id);
	else
		print("Error enabling the Actor Spawner :(");
	end
end

function disableActorSpawner()
	spawnerEnabled = false;
end
event.onloadstate(disableActorSpawner, "ScriptHawk - Disable Actor Spawner");

------------
-- Events --
------------

Game.takeMeThereType = "Button";
function Game.setMap(value)
	if value >= 1 and value <= #Game.maps then
		mainmemory.writebyte(Game.Memory.map[version], value);

		-- Force the game to load the map instantly
		mainmemory.writebyte(Game.Memory.map[version] - 1, 0x01);
	end
end

function Game.applyInfinites()
	-- We don't apply infinite notes since it messes up note routing
	--mainmemory.write_s32_be(Game.Memory.notes[version], max_notes);
	mainmemory.write_s32_be(Game.Memory.notes[version] + eggs, max_eggs);
	mainmemory.write_s32_be(Game.Memory.notes[version] + red_feathers, max_red_feathers);
	mainmemory.write_s32_be(Game.Memory.notes[version] + gold_feathers, max_gold_feathers);
	mainmemory.write_s32_be(Game.Memory.notes[version] + health, mainmemory.read_s32_be(Game.Memory.notes[version] + health_containers));
	mainmemory.write_s32_be(Game.Memory.notes[version] + lives, max_lives);
	mainmemory.write_s32_be(Game.Memory.notes[version] + air, max_air);
	mainmemory.write_s32_be(Game.Memory.notes[version] + mumbo_tokens, max_mumbo_tokens);
	mainmemory.write_s32_be(Game.Memory.notes[version] + mumbo_tokens_on_hand, max_mumbo_tokens);
	mainmemory.write_s32_be(Game.Memory.notes[version] + jiggies, max_jiggies);
end

function Game.initUI()
	ScriptHawkUI.form_controls.toggle_neverslip = forms.checkbox(ScriptHawkUI.options_form, "Never Slip", ScriptHawkUI.col(0) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(6) + ScriptHawkUI.dropdown_offset);
	if Game.allowFurnaceFunPatch then
		ScriptHawkUI.form_controls.allow_ff_patch = forms.checkbox(ScriptHawkUI.options_form, "Allow FF patch", ScriptHawkUI.col(0) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(7) + ScriptHawkUI.dropdown_offset);
	end

	ScriptHawkUI.form_controls.encircle_checkbox = forms.checkbox(ScriptHawkUI.options_form, "Encircle (Beta)", ScriptHawkUI.col(5) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(4) + ScriptHawkUI.dropdown_offset);
	ScriptHawkUI.form_controls.dynamic_radius_checkbox = forms.checkbox(ScriptHawkUI.options_form, "Dynamic Radius", ScriptHawkUI.col(5) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(5) + ScriptHawkUI.dropdown_offset);
	ScriptHawkUI.form_controls.freeze_clip_velocity = forms.checkbox(ScriptHawkUI.options_form, "Freeze Clip Vel.", ScriptHawkUI.col(5) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(6) + ScriptHawkUI.dropdown_offset);
	ScriptHawkUI.form_controls.autopound_checkbox = forms.checkbox(ScriptHawkUI.options_form, "Auto Pound", ScriptHawkUI.col(10) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(6) + ScriptHawkUI.dropdown_offset);

	-- Actor spawner
	ScriptHawkUI.form_controls.actor_dropdown = forms.dropdown(ScriptHawkUI.options_form, actorNames, ScriptHawkUI.col(10) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(0) + ScriptHawkUI.dropdown_offset);
	ScriptHawkUI.form_controls.spawn_actor_button = forms.button(ScriptHawkUI.options_form, "Spawn", spawnActor, ScriptHawkUI.col(10), ScriptHawkUI.row(1), ScriptHawkUI.col(2), ScriptHawkUI.button_height);

	-- Vile
	ScriptHawkUI.form_controls.wave_button =     forms.button(ScriptHawkUI.options_form, "Wave", initWave,         ScriptHawkUI.col(10), ScriptHawkUI.row(4), ScriptHawkUI.col(2), ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls.heart_button =    forms.button(ScriptHawkUI.options_form, "Heart", doHeart,         ScriptHawkUI.col(12) + 8, ScriptHawkUI.row(4), ScriptHawkUI.col(2), ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls.fire_all_button = forms.button(ScriptHawkUI.options_form, "Fire all", fireAllSlots, ScriptHawkUI.col(10), ScriptHawkUI.row(5), ScriptHawkUI.col(4) + 8, ScriptHawkUI.button_height);

	-- Moves
	ScriptHawkUI.form_controls.moves_dropdown = forms.dropdown(ScriptHawkUI.options_form, { "0. None", "1. Spiral Mountain 100%", "2. FFM Setup", "3. All", "3. Demo" }, ScriptHawkUI.col(10) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(7) + ScriptHawkUI.dropdown_offset);
	ScriptHawkUI.form_controls.moves_button = forms.button(ScriptHawkUI.options_form, "Unlock Moves", unlock_moves, ScriptHawkUI.col(5), ScriptHawkUI.row(7), ScriptHawkUI.col(4) + 8, ScriptHawkUI.button_height);
end

function Game.eachFrame()
	applyFurnaceFunPatch();
	updateWave();
	freezeClipVelocity();

	if forms.ischecked(ScriptHawkUI.form_controls.toggle_neverslip) then
		neverSlip();
	end

	if forms.ischecked(ScriptHawkUI.form_controls.encircle_checkbox) then
		encircle_banjo();
	end

	-- Check EEPROM checksums
	if memory.usememorydomain("EEPROM") then
		local checksum_value;
		for i = 1, #eep_checksum_offsets do
			checksum_value = memory.read_u32_be(eep_checksum_offsets[i]);
			if eep_checksum_values[i] ~= checksum_value then
				print("Slot "..i.." Checksum: "..toHexString(eep_checksum_values[i], 8).." -> "..toHexString(checksum_value, 8));
				eep_checksum_values[i] = checksum_value;
			end
		end
	end
	memory.usememorydomain("RDRAM");
end

Game.OSDPosition = {2, 70}
Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"dY"},
	{"dXZ"},
	{"Velocity", Game.getVelocity};
	{"Y Velocity", Game.getYVelocity, Game.colorYVelocity},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
	{"Facing", Game.getFacingAngle},
	{"Moving", Game.getYRotation},
	{"Rot. X", Game.getXRotation},
	{"Rot. Z", Game.getZRotation},
	{"Separator", 1},
	{"Movement", Game.getCurrentMovementState, Game.colorCurrentMovementState},
	{"Slope Timer", Game.getSlopeTimer, Game.colorSlopeTimer},
	--{"FF Answer", getCorrectFFAnswer},
};

---------------
-- ASM Stuff --
---------------

Game.ASMHookBase = 0x24EE88;
Game.ASMHook = {
	0x08, 0x10, 0x00, 0x00,
};

Game.ASMCodeBase = 0x400000;
Game.ASMMaxCodeSize = 0x400000;

return Game;