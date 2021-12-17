if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

Game = {
	squish_memory_table = true,
	Memory = { -- Version order: USA, Japan
		gameprogress_bf = {nil, 0x08E575}, -- Pointer
		--
		hit_points = {nil, 0x0AEE04}, -- s32
		powerup_bf = {nil, 0x0AEE0B}, -- 1B Bitfield
		bomb_count = {nil, 0x0AEE0C}, -- s32
		fire_power = {nil, 0x0AEE10}, -- s32
		player_pointer = {0x0BEE18, 0x0AEE18}, -- Pointer
		model_table_pointer = {0x0AED78, nil}, -- Pointer
		sickness_bf = {nil, 0x0AEE5A}, -- s16
		--
		enemy_killcount = {nil, 0x0BC520}, -- s32
		--
		game_state = {0x2AC5D0, 0x2AB800}, -- Bitfield ?
		nxt_mapID = {0x2AC5D4, 0x2AB804}, -- s32
		nxt_exitID = {0x2AC5D8, 0x2AB808}, -- s32
		cur_mapID = {0x2AC5DC, 0x2AB80C}, -- s32
		cur_exitID = {0x2AC5E0, 0x2AB810}, -- s32
		diamonds = {0x2AC62C, 0x2AB85E}, -- s16
		igt_timer = {0x2AC640, 0x2AB870}, -- s16, counts frames
		dizziness_timer = {nil, 0x2ABB02}, -- s16
		dizziness_counter = {nil, 0x2ABB32}, -- s16
	},
	PowerUpBF = { -- the rest seem to be unused ?
		ultra_bombs = 0, -- 0x01
		remote_bombs = 1, -- 0x02
	},
	GameProgress_Flags = {
		"Unknown flag",
		"Unknown flag",
		"Has Beaten Sirius-2",
		"Unknown flag",
		"Card #001 GG1-1 Back Area",
		"Card #002 GG1-2 Start Area",
		"Card #003 GG1-3 WarpRoom",
		"Card #004 GG1-4 Baddie Card",
		"Card #005 GG1-5 Time Card",
		"Card #006 GG2 Sirius-1 #1",
		"Card #007 GG2 Sirius-1 #2",
		"Card #008 GG2 Sirius-1 #3",
		"Card #009 GG2 Sirius-1 #4",
		"Card #010 GG2 Sirius-1 #5",
		"Card #011 GG3-1 Back Area",
		"Card #012 GG3-2 Tower Area Top",
		"Card #013 GG3-3 Tower Area Mid",
		"Card #014 GG3-4 Baddie Card",
		"Card #015 GG3-5 Time Card",
		"Card #016 GG4 Draco #1",
		"Card #017 GG4 Draco #2",
		"Card #018 GG4 Draco #3",
		"Card #019 GG4 Draco #4",
		"Card #020 GG4 Draco #5",
		"Card #021 BR1-1 Canon Area Canon",
		"Card #022 BR1-2 Canon Area Window",
		"Card #023 BR1-3 High Area",
		"Card #024 BR1-4 Baddie Card",
		"Card #025 BR1-5 Time Card",
		"Card #026 BR2 Artemis #1",
		"Card #027 BR2 Artemis #2",
		"Card #028 BR2 Artemis #3",
		"Card #029 BR2 Artemis #4",
		"Card #030 BR2 Artemis #5",
		"Card #031 BR3-1 High Area",
		"Card #032 BR3-2 Start Area Box",
		"Card #033 BR3-3 In the Riverbed",
		"Card #034 BR3-4 Baddie Card",
		"Card #035 BR3-5 Time Card",
		"Card #036 BR4 Leviathan #1",
		"Card #037 BR4 Leviathan #2",
		"Card #038 BR4 Leviathan #3",
		"Card #039 BR4 Leviathan #4",
		"Card #040 BR4 Leviathan #5",
		"Card #041 RM1-1 Start Area",
		"Card #042 RM1-2 Final Area",
		"Card #043 RM1-3 DarkRoom under Start",
		"Card #044 RM1-4 Baddie Card",
		"Card #045 RM1-5 Time Card",
		"Card #046 RM2 Orion #1",
		"Card #047 RM2 Orion #2",
		"Card #048 RM2 Orion #3",
		"Card #049 RM2 Orion #4",
		"Card #050 RM2 Orion #5",
		"Card #051 RM3-1 Boulder Switches",
		"Card #052 RM3-2 Final Area",
		"Card #053 RM3-3 Construction Site",
		"Card #054 RM3-4 Baddie Card",
		"Card #055 RM3-5 Time Card",
		"Card #056 RM4 Hades #1",
		"Card #057 RM4 Hades #2",
		"Card #058 RM4 Hades #3",
		"Card #059 RM4 Hades #4",
		"Card #060 RM4 Hades #5",
		"Card #061 WG1-1 West Side High",
		"Card #062 WG1-2 West Side Cave",
		"Card #063 WG1-3 Final Area",
		"Card #064 WG1-4 Baddie Card",
		"Card #065 WG1-5 Time Card",
		"Card #066 WG2 Regulus #1",
		"Card #067 WG2 Regulus #2",
		"Card #068 WG2 Regulus #3",
		"Card #069 WG2 Regulus #4",
		"Card #070 WG2 Regulus #5",
		"Card #071 WG3-1 Right Path",
		"Card #072 WG3-2 Left Path",
		"Card #073 WG3-3 Slide Area",
		"Card #074 WG3-4 Baddie Card",
		"Card #075 WG3-5 Time Card",
		"Card #076 WG4 Mantis #1",
		"Card #077 WG4 Mantis #2",
		"Card #078 WG4 Mantis #3",
		"Card #079 WG4 Mantis #4",
		"Card #080 WG4 Mantis #5",
		"Card #081 BF1-1 Tunnel #1 RSide",
		"Card #082 BF1-2 Tunnel #2 RSide",
		"Card #083 BF1-3 Tunnel #2 LSide",
		"Card #084 BF1-4 Baddie Card",
		"Card #085 BF1-5 Time Card",
		"Card #086 BF2 Harvester #1",
		"Card #087 BF2 Harvester #2",
		"Card #088 BF2 Harvester #3",
		"Card #089 BF2 Harvester #4",
		"Card #090 BF2 Harvester #5",
		"Card #091 BF3-1 Floor-2 Left",
		"Card #092 BF3-2 Floor-3 Right",
		"Card #093 BF3-3 Floor-6 Left",
		"Card #094 BF3-4 Baddie Card",
		"Card #095 BF3-5 Time Card",
		"Card #096 BF4 Altair #1",
		"Card #097 BF4 Altair #2",
		"Card #098 BF4 Altair #3",
		"Card #099 BF4 Altair #4",
		"Card #100 BF4 Altair #5",
		"Card #101 RP1-1 Start Area Left",
		"Card #102 RP1-2 Start Area Right",
		"Card #103 RP1-3 Side Area",
		"Card #104 RP1-4 Baddie Card",
		"Card #105 RP1-5 Time Card",
		"Card #106 RP2 Spellmaker #1",
		"Card #107 RP2 Spellmaker #2",
		"Card #108 RP2 Spellmaker #3",
		"Card #109 RP2 Spellmaker #4",
		"Card #110 RP2 Spellmaker #5",
		"Card #111 RP3-1 Start Area LPillar",
		"Card #112 RP3-2 Start Area RPillar",
		"Card #113 RP3-3 Side Area",
		"Card #114 RP3-4 Baddie Card",
		"Card #115 RP3-5 Time Card",
		"Card #116 RP4 Sirius-2 #1",
		"Card #117 RP4 SSirius-2 #2",
		"Card #118 RP4 SSirius-2 #3",
		"Card #119 RP4 SSirius-2 #4",
		"Card #120 RP4 SSirius-2 #5",
	},
	CostumePieceBF = {
		"CPi Test",
	},
	SicknessBF = {
		no_bombs = 0x08,
		transmittable = 0x10,
		non_stop = 0x20,
		--
		flaming = 0x80,
		blinking = 0x100,
    },
	GameStateBF = { -- these are all slightly weird..
		loading_map = 0x01,
		death = 0x02,
		battle_mode = 0x04,
		miniboss_fight = 0x08,
		enter_level = 0x10,
		boss_fight = 0x20,
		cutscene = 0x40,
		world_select = 0x80,
	},
	PlayerStruct = {
		object_pointer = 0x40, -- Pointer
		x_position = 0x58, -- Float
		y_position = 0x5C, -- Float
		z_position = 0x60, -- Float
	},
	ObjectStruct = {
		x_position = 0x10, -- Float
		y_position = 0x14, -- Float
		z_position = 0x18, -- Float
		x_rotation = 0x1C, -- Float
		y_rotation = 0x20, -- Float
		x_scale = 0x24, -- Float
		y_scale = 0x28, -- Float
		z_scale = 0x2C, -- Float
	},
	maps = {
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"TestMap 1", --= 0x14,
		"TestMap 2", --= 0x15,
		"Intro CS Village", --= 0x16,
		"TestMap 3", --= 0x17,
		"!unknown",
		"Intro CS VS. Altair", --= 0x19,
		"Intro CS Blue Resort", --= 0x1A,
		"Main Menu CS", --= 0x1B,
		"Credits CS RP Dropdown", --= 0x1C,
		"Credits CS Dancing", --= 0x1D,
		"!unknown",
		"Select Savefile Menu", --= 0x1F,
		"HUDSON Screen", --= 0x20,
		"World Select", --= 0x21,
		"Battlemode Results", --= 0x22,
		"Battlemode Menu", --= 0x23,
		"Erase Records Screen", --= 0x24,
		"Costume Menu", --= 0x25,
		"Options Menu", --= 0x26,
		"!unknown",
		"GG1 Starting Area", --= 0x28,
		"GG1 Back Area", --= 0x29,
		"GG1 WarpRoom with many Boxes", --= 0x2A,
		"GG1 WarpRoom with Pillars", --= 0x2B,
		"GG1 WarpRoom with Bridge", --= 0x2C,
		"GG3 Starting Area", --= 0x2D,
		"GG3 Back Area", --= 0x2E,
		"GG3 WarpRoom", --= 0x2F,
		"GG3 Big Tower Area", --= 0x30,
		"VS. Sirius 1", --= 0x31,
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"BR1 Starting Area", --= 0x38,
		"BR1 Canon/Garden Area", --= 0x39,
		"BR1 Across the River", --= 0x3A,
		"BR1 High Area", --= 0x3B,
		"BR3 Starting Area", --= 0x3C,
		"BR3 Back Area", --= 0x3D,
		"VS. Artemis", --= 0x3E,
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"RM1 Starting Area", --= 0x48,
		"RM1 Branch-A Area-1", --= 0x49,
		"RM1 Branch-A Area-2", --= 0x4A,
		"RM1 Final Area", --= 0x4B,
		"RM1 Branch-B Area-1", --= 0x4C,
		"RM1 DarkRoom near Start", --= 0x4D,
		"RM1 DarkRoom under Start", --= 0x4E,
		"RM1 DarkRoom on Branch-A", --= 0x4F,
		"RM3 Starting Area", --= 0x50,
		"RM3 Inbetween Area", --= 0x51,
		"RM3 Boulder Slope Area", --= 0x52,
		"RM3 Construction Site", --= 0x53,
		"RM3 Final Area", --= 0x54,
		"RM3 DarkRoom", --= 0x55,
		"VS. Orion", --= 0x56,
		"!unknown",
		"WG1 Starting Area", --= 0x58,
		"WG1 West Side", --= 0x59,
		"WG1 Final Area", --= 0x5A,
		"WG1 East Side", --= 0x5B,
		"WG3 Lift Cutscene Dusk", --= 0x5C,
		"!unknown", -- might actually be a Map
		"WG3 Starting Area", --= 0x5E,
		"WG3 Right Path", --= 0x5F,
		"WG3 Left Path", --= 0x60,
		"WG3 Big Slide Area", --= 0x61,
		"VS. Regulus", --= 0x62,
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"BF1 Starting Area", --= 0x68,
		"BF1 1st Tunnel", --= 0x69,
		"BF1 2nd Highway Area", --= 0x6A,
		"BF1 2nd Tunnel", --= 0x6B,
		"BF1 3rd Highway Area", --= 0x6C,
		"BF1 Final Area", --= 0x6D,
		"BF3 Starting Area", --= 0x6E,
		"BF3 Floor-2", --= 0x6F,
		"BF3 Floor-3", --= 0x70,
		"BF3 Floor-4", --= 0x71,
		"BF3 Floor-5", --= 0x72,
		"BF3 Floor-6", --= 0x73,
		"VS. Altair", --= 0x74,
		"!unknown",
		"!unknown",
		"!unknown",
		"RP1 Starting Area", --= 0x78,
		"RP1 Side Area", --= 0x79,
		"!unknown",
		"RP3 Starting Area", --= 0x7B,
		"RP3 Outside Area", --= 0x7C
		"!unknown",
		"VS. Sirius 2", --= 0x7E,
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"!unknown",
		"VS. Draco", --= 0x88,
		"VS. Leviathan", --= 0x89,
		"VS. Hades", --= 0x8A,
		"VS. Mantis", --= 0x8B,
		"VS. Harvester", --= 0x8C,
		"VS. Spellmaker", --= 0x8D,
		"!unknown",
		"!unknown",
		"BattleMap 01: Rock Garden", --= 0x90,
		"BattleMap 02: Up and Down", --= 0x91,
		"BattleMap 03: Pyramid", --= 0x92,
		"BattleMap 04: Greedy Trap", --= 0x93,
		"BattleMap 05: Top Rules", --= 0x94,
		"BattleMap 06: Field of Grass", --= 0x95,
		"BattleMap 07: In the Gutter", --= 0x96,
		"BattleMap 08: Sea Sick", --= 0x97,
		"BattleMap 09: Blizzard Battle", --= 0x98,
		"BattleMap 10: Lost at Sea", --= 0x99,
	},
	exit_IDs = {
		["World Select"] = 0x11,
		--
		["GG1 Back Area"] = 0x13,
		["GG1 WarpRoom with many Boxes"] = 0x14,
		["GG1 WarpRoom with Pillars"] = 0x12,
		["GG1 WarpRoom with Bridge"] = 0x12,
		--
		["GG3 Back Area"] = 0x12,
		["GG3 WarpRoom"] = 0x12,
		["GG3 Big Tower Area"] = 0x12,
		--
		["BR1 Canon/Garden Area"] = 0x11,
		["BR1 Across the River"] = 0x12,
		["BR1 High Area"] = 0x12,
		["BR3 Starting Area"] = 0x12,
		["BR3 Back Area"] = 0x11,
		--
		["RM1 Branch-A Area-1"] = 0x13,
		["RM1 Branch-A Area-2"] = 0x13,
		["RM1 Final Area"] = 0x13,
		["RM1 Branch-B Area-1"] = 0x12,
		["RM1 DarkRoom near Start"] = 0x12,
		["RM1 DarkRoom under Start"] = 0x12,
		["RM1 DarkRoom on Branch-A"] = 0x12,
		--
		["RM3 Inbetween Area"] = 0x16,
		["RM3 Boulder Slope Area"] = 0x13,
		["RM3 Construction Site"] = 0x13,
		["RM3 Final Area"] = 0x12,
		["RM3 DarkRoom"] = 0x12,
		--
		["WG1 West Side"] = 0x11,
		["WG1 Final Area"] = 0x14,
		["WG1 East Side"] = 0x11,
		--
		["WG3 Lift Cutscene Dusk"] = 0x11,
		["WG3 Right Path"] = 0x11,
		["WG3 Left Path"] = 0x11,
		["WG3 Big Slide Area"] = 0x12,
		--
		["BF1 1st Tunnel"] = 0x11,
		["BF1 2nd Highway Area"] = 0x11,
		["BF1 2nd Tunnel"] = 0x11,
		["BF1 3rd Highway Area"] = 0x11,
		["BF1 Final Area"] = 0x11,
		--
		["BF3 Floor-2"] = 0x11,
		["BF3 Floor-3"] = 0x11,
		["BF3 Floor-4"] = 0x11,
		["BF3 Floor-5"] = 0x11,
		["BF3 Floor-6"] = 0x11,
		--
		["RP1 Side Area"] = 0x12,
		--
		["RP3 Outside Area"] = 0x12
	},
	max_bomb_count = 8,
	max_fire_power = 8,
	speedy_invert_XZ = false,
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 }, -- D-Pad speeds
	speedy_index = 7, -- Default speed index into speedy_speeds table
	rot_speed = 45; -- D-Pad rotation-speed (Rotation mode)
	max_rot_units = 360; -- Maximum value of rotation units
	form_height = 11;

	-- these are for calculations; the game does not appear to remember these itself
	old_x_position = 0,
	old_y_position = 0,
	old_z_position = 0,
	dx = 0,
	dy = 0,
	dz = 0,
};

-- set up a comparison bitfield for goldcards
local old_GameProgressBF = {};
for i = 1, #Game.GameProgress_Flags do
	old_GameProgressBF[i] = 0;
end

local flagGroups = {
	"Green Garden Cards",
	"Blue Resort Cards",
	"Red Mountain Cards",
	"White Glacier Cards",
	"Black Fortress Cards",
	"Rainbow Palace Cards",
	"All GoldCards",
};

---------------
-- Bit-Magic --
----------------

-- set a specifc Bit in an arbitrarily big Bitfield
local function setBit(pointer, bit_ID)
	while bit_ID >= 8 do
		pointer = pointer + 1;
		bit_ID = bit_ID - 8;
	end
	local bit_ID = bit.lshift(0x1, bit_ID);
	local membyte = mainmemory.readbyte(pointer);
	membyte = bit.bor(membyte, bit_ID);
	mainmemory.writebyte(pointer, membyte);
end
-- unset a specifc Bit in an arbitrarily big Bitfield
local function unsetBit(pointer, bit_ID)
	while bit_ID >= 8 do
		pointer = pointer + 1;
		bit_ID = bit_ID - 8;
	end
	local bit_ID = bit.lshift(0x1, bit_ID);
	bit_ID = bit.bxor(bit_ID, 0xFF) -- invert the "Card #1bit"-Byte
	local membyte = mainmemory.readbyte(pointer);
	membyte = bit.band(membyte, bit_ID);
	mainmemory.writebyte(pointer, membyte);
end
-- get a specifc Bit in an arbitrarily big Bitfield
local function getBit(pointer, bit_ID)
	while bit_ID >= 8 do
		pointer = pointer + 1;
		bit_ID = bit_ID - 8;
	end
	local bit_ID = bit.lshift(0x1, bit_ID);
	local membyte = mainmemory.readbyte(pointer);
	membyte = bit.band(membyte, bit_ID);
	if membyte > 0 then
		return 1;
	end
	return 0;
end

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	-- version identification is done in ScriptHawk.lua already
	if Game.version == 1 then -- USA
		print("Bomberman 64 (USA) detected.");
	elseif Game.version == 2 then -- Japan
		print("Baku Bomberman (Japan) detected.");
	else
		print("Unsupported version detected.");
		return false; -- unsupported version
	end
	-- version detection successful
	return true; 
end

-------------------
-- Physics/Scale --
-------------------

-- Optional: If lag in your game is more complicated than a simple emu.islagged() call you should add the logic to detect it here
function Game.isPhysicsFrame()
	-- Implementing this logic will result in smooth dY/dXZ calculation (no more flickering between 0 and the correct value)
	return not emu.islagged();
end

--------------
-- Position --
--------------

-- get the PlayerObjectPointer (to declutter other funcs that need this)
function Game.getPlayerObjectPointer()
	local playerPointer = dereferencePointer(Game.Memory.player_pointer);
	if isRDRAM(playerPointer) then
		local objectPointer = dereferencePointer(playerPointer + Game.PlayerStruct.object_pointer);
		if isRDRAM(objectPointer) then
			return objectPointer;
		end
	end
	return 0;
end

-- get Player X Position
function Game.getXPosition()
	local PlayerObjectPointer = Game.getPlayerObjectPointer();
	if isRDRAM(PlayerObjectPointer) then
		return mainmemory.readfloat(PlayerObjectPointer + Game.ObjectStruct.x_position, true);
	end
	return 0.0;
end
-- get Player Y Position
function Game.getYPosition()
	local PlayerObjectPointer = Game.getPlayerObjectPointer();
	if isRDRAM(PlayerObjectPointer) then
		return mainmemory.readfloat(PlayerObjectPointer + Game.ObjectStruct.y_position, true);
	end
	return 0.0;
end
-- get Player Z Position
function Game.getZPosition()
	local PlayerObjectPointer = Game.getPlayerObjectPointer();
	if isRDRAM(PlayerObjectPointer) then
		return mainmemory.readfloat(PlayerObjectPointer + Game.ObjectStruct.z_position, true);
	end
	return 0.0;
end

-- get Player dX
function Game.getdX()
	return Game.dx;
end
-- get Player dY
function Game.getdY()
	return Game.dy;
end
-- get Player dZ
function Game.getdZ()
	return Game.dz;
end
-- get Player dXZ
function Game.getdXZ()
	return math.sqrt(Game.dx*Game.dx + Game.dz*Game.dz);
end

-- set Player X Position
function Game.setXPosition(value)
	local PlayerObjectPointer = Game.getPlayerObjectPointer()
	if isRDRAM(PlayerObjectPointer) then
		mainmemory.writefloat(PlayerObjectPointer + Game.ObjectStruct.x_position, value, true)
	end
end
-- set Player Y Position
function Game.setYPosition(value)
	local PlayerObjectPointer = Game.getPlayerObjectPointer()
	if isRDRAM(PlayerObjectPointer) then
		mainmemory.writefloat(PlayerObjectPointer + Game.ObjectStruct.y_position, value, true)
	end
end
-- set Player Z Position
function Game.setZPosition(value)
	local PlayerObjectPointer = Game.getPlayerObjectPointer()
	if isRDRAM(PlayerObjectPointer) then
		mainmemory.writefloat(PlayerObjectPointer + Game.ObjectStruct.z_position, value, true)
	end
end

-- returns yellow if coordinate is on-Edge
function Game.colorCoordinate(coordinate)
	if math.floor(coordinate) - coordinate == 0 then
		if math.fmod(coordinate - 50.0, 100.0) == 0 then
			return colors.yellow;
		end
	end
	return colors.white;
end
function Game.colorXCoord()
	return Game.colorCoordinate(Game.getXPosition());
end
function Game.colorYCoord()
	return Game.colorCoordinate(Game.getYPosition());
end
function Game.colorZCoord()
	return Game.colorCoordinate(Game.getZPosition());
end

--------------
-- Rotation --
--------------

-- get Player X Rotation
function Game.getXRotation()
	local PlayerObjectPointer = Game.getPlayerObjectPointer();
	if isRDRAM(PlayerObjectPointer) then
		return mainmemory.readfloat(PlayerObjectPointer + Game.ObjectStruct.x_rotation, true);
	end
	return 0.0;
end
-- get Player Y Rotation
function Game.getYRotation()
	local PlayerObjectPointer = Game.getPlayerObjectPointer();
	if isRDRAM(PlayerObjectPointer) then
		return mainmemory.readfloat(PlayerObjectPointer + Game.ObjectStruct.y_rotation, true);
	end
	return 0.0;
end

-- set Player X Rotation
function Game.setXRotation(value)
	local PlayerObjectPointer = Game.getPlayerObjectPointer()
	if isRDRAM(PlayerObjectPointer) then
		mainmemory.writefloat(PlayerObjectPointer + Game.ObjectStruct.x_rotation, value, true)
	end
end
-- set Player Y Rotation
function Game.setYRotation(value)
	local PlayerObjectPointer = Game.getPlayerObjectPointer()
	if isRDRAM(PlayerObjectPointer) then
		mainmemory.writefloat(PlayerObjectPointer + Game.ObjectStruct.x_yotation, value, true)
	end
end

------------
-- Events --
------------

-- Thanks to Coockie for the infos on this !
Game.takeMeThereType = "Button";
function Game.setMap(index)
	-- Set the Game's mapID to the ID selected in the dropdown
	mainmemory.write_s32_be(Game.Memory.cur_mapID, index);
	mainmemory.write_s32_be(Game.Memory.nxt_mapID, index);
	-- set the exit ID properly to make every map load
	if Game.exit_IDs[Game.maps[index]] ~= nil then
		local exit = Game.exit_IDs[Game.maps[index]];
		mainmemory.write_s32_be(Game.Memory.cur_exitID, exit);
		mainmemory.write_s32_be(Game.Memory.nxt_exitID, exit);
	else
		mainmemory.write_s32_be(Game.Memory.cur_exitID, 0x10);
		mainmemory.write_s32_be(Game.Memory.nxt_exitID, 0x10);
	end
	-- Force the Game to load the chosen Map
	mainmemory.write_s32_be(Game.Memory.game_state, 0x01);
end
-- get the MapName and ID
function Game.getMap()
	local mapID = mainmemory.readbyte(Game.Memory.nxt_mapID + 0x03);
	local mapName = Game.maps[mapID] or "UNDEFINED";
	return mapName .. " (" .. toHexString(mapID) .. ")";
end
-- get the MapID
function Game.getMapID()
	local mapID = mainmemory.readbyte(Game.Memory.nxt_mapID + 0x03);
	return toHexString(mapID);
end
-- return red color if MapID is undocumented
function Game.colorMapID()
	local mapID = mainmemory.readbyte(Game.Memory.nxt_mapID + 0x03);
	if Game.maps[mapID] == "!unknown" then
		return colors.red;
	end
	return colors.white;
end



function Game.getBombCount()
	return mainmemory.read_s32_be(Game.Memory.bomb_count);
end
function Game.getFirePower()
	return mainmemory.read_s32_be(Game.Memory.fire_power);
end
function Game.getHP()
	return mainmemory.read_s32_be(Game.Memory.hit_points);
end
function Game.getKillCount()
	return mainmemory.read_s32_be(Game.Memory.enemy_killcount);
end

function Game.setBombCount(value)
	mainmemory.write_s32_be(Game.Memory.bomb_count, value);
end
function Game.setFirePower(value)
	mainmemory.write_s32_be(Game.Memory.fire_power, value);
end
function Game.setHP(value)
	mainmemory.write_s32_be(Game.Memory.hit_points, value);
end
function Game.setKillCount(value)
	return mainmemory.write_s32_be(Game.Memory.enemy_killcount, value);
end
function Game.setUltraBombs(boolean)
	if boolean == true then
		setBit(Game.Memory.powerup_bf, Game.PowerUpBF.ultra_bombs);
	else
		unsetBit(Game.Memory.powerup_bf, Game.PowerUpBF.ultra_bombs);
	end
end
function Game.setRemoteBombs(boolean)
	if boolean == true then
		setBit(Game.Memory.powerup_bf, Game.PowerUpBF.remote_bombs);
	else
		unsetBit(Game.Memory.powerup_bf, Game.PowerUpBF.remote_bombs);
	end
end

-- Infinites and Max Everything
function Game.applyInfinites()
	Game.setHP(2);
	Game.setUltraBombs(true);
	Game.setRemoteBombs(true);
	Game.setBombCount(Game.max_bomb_count);
	Game.setFirePower(Game.max_fire_power);
end
function Game.initZombieBomberman()
	Game.setHP(0);
end

-- Remove Dizziness
function Game.endDizziness()
	mainmemory.write_s32_be(Game.Memory.dizziness_timer, 0);
	mainmemory.write_s32_be(Game.Memory.dizziness_counter, 0);
end

-- update comparison BF and print update-msg
local function updateGameProgressBF()
	for i = 1, #Game.GameProgress_Flags do
		local flag_bit = getBit(Game.Memory.gameprogress_bf, i-1);
		if old_GameProgressBF[i] ~= flag_bit then
			local statement = "set";
			if flag_bit == 0 then
				statement = "cleared";
			end
			print("Flag \"" .. Game.GameProgress_Flags[i] .. "\" " .. statement);
			old_GameProgressBF[i] = flag_bit;
		end
	end
end
-- Because the Dropdowns sort the names alphabetically, I can't just use the SelectedIndex
local function getTableID(table, name)
	for i = 1, #table do
		if name == table[i] then
			return i;
		end
	end
	print("Couldn't retrieve Table ID");
end

local function flagSetButtonHandler()
	local flag_name = forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem");
	local flag_ID = getTableID(Game.GameProgress_Flags, flag_name);
	setBit(Game.Memory.gameprogress_bf, tonumber(flag_ID - 1)); -- lua starts at 1, bits start at 0
end
local function flagClearButtonHandler()
	local flag_name = forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem");
	local flag_ID = getTableID(Game.GameProgress_Flags, flag_name);
	unsetBit(Game.Memory.gameprogress_bf, tonumber(flag_ID - 1)); -- lua starts at 1, bits start at 0
end
local function flagCheckButtonHandler()
	local flag_name = forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem");
	local flag_ID = getTableID(Game.GameProgress_Flags, flag_name);
	local flag_state = getBit(Game.Memory.gameprogress_bf, tonumber(flag_ID - 1)); -- lua starts at 1, bits start at 0
	local statement = "is NOT set";
	if flag_state == 1 then
		statement = "is set";
	end
	print("Flag \"" .. flag_name .. "\" " .. statement);
end

local function groupSetButtonHandler()
	local group_name = forms.getproperty(ScriptHawk.UI.form_controls["Group Dropdown"], "SelectedItem");
	print("Setting Group \"" .. group_name .. "\"...");
	for i = 1, #Game.GameProgress_Flags do
		if group_name == "Green Garden Cards" then
			if string.find(Game.GameProgress_Flags[i], "GG") then
				setBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "Blue Resort Cards" then
			if string.find(Game.GameProgress_Flags[i], "BR") then
				setBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "Red Mountain Cards" then
			if string.find(Game.GameProgress_Flags[i], "RM") then
				setBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "White Glacier Cards" then
			if string.find(Game.GameProgress_Flags[i], "WG") then
				setBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "Black Fortress Cards" then
			if string.find(Game.GameProgress_Flags[i], "BF") then
				setBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "Rainbow Palace Cards" then
			if string.find(Game.GameProgress_Flags[i], "RP") then
				setBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "All GoldCards" then
			if string.find(Game.GameProgress_Flags[i], "Card") then
				setBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		else
			print("Group Name could not be parsed");
		end
	end
end
local function groupClearButtonHandler()
	local group_name = forms.getproperty(ScriptHawk.UI.form_controls["Group Dropdown"], "SelectedItem");
	print("Clearing Group \"" .. group_name .. "\"...");
	for i = 1, #Game.GameProgress_Flags do
		if group_name == "Green Garden Cards" then
			if string.find(Game.GameProgress_Flags[i], "GG") then
				unsetBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "Blue Resort Cards" then
			if string.find(Game.GameProgress_Flags[i], "BR") then
				unsetBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "Red Mountain Cards" then
			if string.find(Game.GameProgress_Flags[i], "RM") then
				unsetBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "White Glacier Cards" then
			if string.find(Game.GameProgress_Flags[i], "WG") then
				unsetBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "Black Fortress Cards" then
			if string.find(Game.GameProgress_Flags[i], "BF") then
				unsetBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "Rainbow Palace Cards" then
			if string.find(Game.GameProgress_Flags[i], "RP") then
				unsetBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		elseif group_name == "All GoldCards" then
			if string.find(Game.GameProgress_Flags[i], "Card") then
				unsetBit(Game.Memory.gameprogress_bf, i-1); -- lua starts at 1, bits start at 0
			end
		else
			print("Group Name could not be parsed");
		end
	end
end

function Game.initUI()
	ScriptHawk.UI:checkbox(0, 6, "no_dizziness", "No Dizziness");

	ScriptHawk.UI:button(5, 4, {110}, nil, "Zombie Mode Button", "Zombie Mode", Game.initZombieBomberman);

	ScriptHawk.UI.form_controls["Group Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, flagGroups, ScriptHawk.UI:col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI:row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI:col(9) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI:button(10, 7, {46}, nil, "Set Group Button", "Set", groupSetButtonHandler);
	ScriptHawk.UI:button(12, 7, {46}, nil, "Clear Group Button", "Clear", groupClearButtonHandler);

	ScriptHawk.UI.form_controls["Flag Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, Game.GameProgress_Flags, ScriptHawk.UI:col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI:row(8) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI:col(9) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI:button(10, 8, {46}, nil, "Set Flag Button", "Set", flagSetButtonHandler);
	ScriptHawk.UI:button(12, 8, {46}, nil, "Clear Flag Button", "Clear", flagClearButtonHandler);
	ScriptHawk.UI:button(14, 8, {46}, nil, "Check Flag Button", "Check", flagCheckButtonHandler);
end

function Game.drawUI()
	local row = 0;
end

-- in case we have to do something on Savestate Load...
function Game.onLoadState()
	print("Savestate loaded!");
end

-- this function will be executed once per frame
function Game.eachFrame()
	if ScriptHawk.UI:ischecked("no_dizziness") then
		Game.endDizziness();
	end
	-- recalculate dxyz
	Game.dx = Game.getXPosition() - Game.old_x_position;
	Game.old_x_position = Game.getXPosition();
	Game.dy = Game.getYPosition() - Game.old_y_position;
	Game.old_y_position = Game.getYPosition();
	Game.dz = Game.getZPosition() - Game.old_z_position;
	Game.old_z_position = Game.getZPosition();
	-- update comparison bitfields
	updateGameProgressBF();
end

-- this function will be executed as fast as possible
function Game.realTime()
	-- nothing yet
end

Game.OSDPosition = {2, 76};
Game.OSD = {
	{"X", Game.getXPosition, Game.colorXCoord, category="position"},
	{"Y", Game.getYPosition, category="position"},
	{"Z", Game.getZPosition, Game.colorZCoord, category="position"},
	{"Separator"},
	{"dX", Game.getdX},
	{"dY", Game.getdY},
	{"dZ", Game.getdZ},
	{"dXZ", Game.getdXZ},
	{"Separator"},
	{"Rot. X", Game.getXRotation},
	{"Facing", Game.getYRotation},
	{"Separator"},
	{"Bombs", Game.getBombCount},
	{"FireP", Game.getFirePower},
	{"HP   ", Game.getHP},
	{"Kills", Game.getKillCount},
	{"Separator"},
	{"MapID", Game.getMapID, Game.colorMapID},
};

return Game;