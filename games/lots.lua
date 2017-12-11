if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		map = 0x98,
		map_status = 0xA0,
		building_status = 0xA1,
		demo_timer = 0x104, -- 2 bytes
		screen_x_position = 0x10A,
		health = 0x129,
		recovery_status = 0x12B,
		recovery_timer = 0x12C, -- 2 bytes
		continue_map = 0xCAE,
		continues_used = 0xCAF,
		movement_state = 0x401,
		x_position = 0x40A, -- 1 byte (screen)
		y_position = 0x407, -- 1 byte (screen)
		x_velocity = 0x413, -- 3 byte
		y_velocity = 0x410, -- 2 byte
		facing_direction = 0x421,
		in_air = 0x422,
		sword_damage = 0xCA8,
		bow_damage = 0xCA9,
		--[[
		0x44A	b	u	0	Main RAM	Arrow X Position (Screen)
		0x507	b	u	0	Main RAM	Boss Y Position (Screen)
		0x50A	b	u	0	Main RAM	Boss X Position (Screen)
		0x511	b	s	0	Main RAM	Boss Y Velocity
		0x522	b	u	0	Main RAM	Boss Teleport Timer
		0x524	b	u	0	Main RAM	Boss Flash Timer
		0x534	b	u	0	Main RAM	Boss Health
		0x591	b	s	0	Main RAM	Skeleton Y Velocity
		0x5B4	b	u	0	Main RAM	Boss Minion Health
		0xCA0	b	u	0	Main RAM	Book is burnable
		--]]
	},
	maps = {
		"01 - Swamp (Shagart +1L) (Left)",
		"02 - Swamp (Shagart +1L) (Right)",
		"03 - Swamp (Dwarle +1DR) (Lindon +1L) (Left)",
		"04 - Swamp (Dwarle +1DR) (Lindon +1L) (Right)",
		"05 - Swamp (Pharazon +1R) (Left)",
		"06 - Swamp (Pharazon +1R) (Right)",
		"07 - Swamp (Harfoot +1R) (Left) (Demo)",
		"08 - Swamp (Harfoot +1R) (Right)",
		"09 - Swamp (Ithile +3R) (Left)",
		"0A - Swamp (Ithile +3R) (Right)",
		"0B - Swamp (Dwarle +1UR) (Left)",
		"0C - Swamp (Dwarle +1UR) (Left)",
		"0D - Swamp (Varlin +1L) (Left)",
		"0E - Swamp (Varlin +1L) (Right)",
		"0F - Swamp (Pharazon +1DL) (Left)",
		"10 - Swamp (Pharazon +1DL) (Right)",
		"11 - Swamp (Ithile +1R) (Left)",
		"12 - Swamp (Ithile +1R) (Right)",
		"13 - Swamp (Harfoot +1L) (Left)",
		"14 - Swamp (Harfoot +1L) (Right)",
		"15 - Swamp (Pharazon +1UR) (Right)",
		"16 - Swamp (Pharazon +1UR) (Right)",
		"17 - Swamp (Shagart +1R) (Left)",
		"18 - Swamp (Shagart +1R) (Right)",
		"19 - Swamp (Lindon +1R) (Left)",
		"1A - Swamp (Lindon +1R) (Right)",
		"1B - Swamp (Pharazon +1UL) (Left)",
		"1C - Swamp (Pharazon +1UL) (Right)",
		"1D - Swamp (Castle Elder +1L) (Left)",
		"1E - Swamp (Castle Elder +1L) (Right)",
		"1F - Swamp (Ithile +1L) (Left)",
		"20 - Swamp (Ithile +1L) (Right)",
		"21 - Swamp (Varlin +1UL) (Left)",
		"22 - Swamp (Varlin +1UL) (Right)",
		"23 - Forest (Amon +1L) (Left)",
		"24 - Forest (Amon +1L) (Right)",
		"25 - Forest (Amon +1UL) (Left)",
		"26 - Forest (Amon +1UL) (Right)",
		"27 - Forest (Pharazon +2DL) (Namo +1R) (Left)",
		"28 - Forest (Pharazon +2DL) (Namo +1R) (Right)",
		"29 - Forest (Ulmo +1R) (Left)",
		"2A - Forest (Ulmo +1R) (Left)",
		"2B - Forest (Harfoot +2L) (Left)",
		"2C - Forest (Harfoot +2L) (Right)",
		"2D - Forest (Amon +1R) (Left)",
		"2E - Forest (Amon +1R) (Right)",
		"2F - Forest (???) (Left)",
		"30 - Forest (???) (Right)",
		"31 - Forest (???) (Bottom Left)",
		"32 - Forest (???) (Right)",
		"33 - Forest (???) (Top Left)",
		"34 - Forest (Shagart +2L) (Bottom Left)",
		"35 - Forest (Shagart +2L) (Right)",
		"36 - Forest (Shagart +2L) (Top Left, Stairs)",
		"37 - Forest (Varlin +2UL) (Dwarle +2L) (Bottom Left)",
		"38 - Forest (Varlin +2UL) (Dwarle +2L) (Right)",
		"39 - Forest (Varlin +2UL) (Dwarle +2L) (Top Left, Stairs)",
		"3A - Coast (Dwarle +1L) (Left)",
		"3B - Coast (Dwarle +1L) (Right)",
		"3C - Coast (Ithile +2R) (Left)",
		"3D - Coast (Ithile +2R) (Right)",
		"3E - Coast (???) (Left)",
		"3F - Coast (???) (Right)",
		"40 - Cave (Ragoan +1R) (Left)",
		"41 - Cave (Ragoan +1R) (Right)",
		"42 - Cave (Ithile +3L) (Goblin +1R) (Left)",
		"43 - Cave (Ithile +3L) (Goblin +1R) (Right)",
		"44 - Mountains (Amon +2UL) (Pharazon +2R) (Left)",
		"45 - Mountains (Amon +2UL) (Pharazon +2R) (Right)",
		"46 - Mountains (???) (Left)",
		"47 - Mountains (???) (Right)",
		"48 - Mountains (???) (Left)",
		"49 - Mountains (???) (Right)",
		"4A - Mountains (???) (Left)",
		"4B - Mountains (???) (Right)",
		"4C - Mountains (???) (Bottom Left)",
		"4D - Mountains (???) (Right)",
		"4E - Mountains (???) (Top Left)",
		"4F - Mountains (Pharazon +2UR) (Bottom Left)",
		"50 - Mountains (Pharazon +2UR) (Right)",
		"51 - Mountains (Pharazon +2UR) (Top Left Stairs)",
		"52 - Mountains (???) (Left)",
		"53 - Mountains (???) (Right)",
		"54 - Mountains 3 (Harfoot +3L) (Statue +1R) (left)",
		"55 - Mountains 3 (Harfoot +3L) (Statue +1R) (right)",
		"56 - Mountains 3 (Pharazon +1UL+3L+Stairs) (Left)",
		"57 - Mountains 3 (Pharazon +1UL+3L+Stairs) (Right)",
		"58 - Mountains 2 (Ra goan +2R) (Left)",
		"59 - Mountains 2 (Ra goan +2R) (Right)",
		"5A - Dark Forest (Ithile +2L) (Left)",
		"5B - Dark Forest (Ithile +2L) (Right)",
		"5C - Dark Forest (Pirate +1L) (Left)",
		"5D - Dark Forest (Pirate +1L) (Right)",
		"5E - Harfoot (Left)",
		"5F - Harfoot (Right)",
		"60 - Ithile (left)",
		"61 - Ithile (right)",
		"62 - Amon (Left)",
		"63 - Amon (Right)",
		"64 - Amon (Left Stairs)",
		"65 - Amon (Left)", -- Unused?
		"66 - Amon (Right)", -- Unused?
		"67 - Amon (Left Stairs)", -- Unused?
		"68 - Dwarle (Left)",
		"69 - Dwarle (Right)",
		"6A - Dwarle (Right Stairs)",
		"6B - Pharazon (Left)",
		"6C - Pharazon (Right)",
		"6D - Pharazon (Left Stairs)",
		"6E - Pharazon (Bottom Left, Stairs Spawned)",
		"6F - Pharazon (Bottom Right, Stairs Spawned)",
		"70 - Pharazon (Left Stairs, Stairs Spawned)",
		"71 - Pharazon (Top Right, Stairs Spawned)",
		"72 - Shagart (Left)",
		"73 - Shagart (Door)",
		"74 - Shagart (Open) (Left)",
		"75 - Shagart (Open) (Door)",
		"76 - Lindon (Left)",
		"77 - Lindon (Right)",
		"78 - Castle Elder",
		"79 - Glitched version of Varlin [UNTESTED, HASN'T BEEN TESTED WITH CORRECT FLAGS SET]",
		"7A - Varlin (Bottom Left, Closed)",
		"7B - Varlin (Top Left, Closed)",
		"7C - Varlin (Bottom Left, Open)",
		"7D - Varlin (Top Left, Open)",
		"7E - Ra Goan's dungeon 1F (Bottom Left)",
		"7F - Ra Goan's dungeon 1F (Top Left)",
		"80 - Ra Goan's dungeon 2F",
		"81 - Ra Goan's dungeon 3F",
		"82 - Shagart Dungeon, Entrance",
		"83 - Shagart Dungeon, Boss Room",
		"84 - Shagart Dungeon, B1F",
		"85 - Shagart Dungeon, B2F",
		"86 - Shagart Dungeon, B3F",
	},
	map_states = {
		[0x00] = "Reset",
		[0x01] = "Map",
		[0x02] = "Sega logo",
		[0x03] = "Title Screen",
		[0x04] = "Demo",
		[0x05] = "Start Game",
		[0x06] = "Story",
	},
	building_states = {
		[0x00] = "Map",
		[0x01] = "Load Map",
		[0x02] = "Building",
		[0x03] = "Boss Fight",
		[0x04] = "Map Screen",
		[0x05] = "Game End Sequence",
		[0x06] = "Death",
	},
	movement_states = {
		[0x00] = "Idle (L)",
		[0x01] = "Idle (R)",
		[0x02] = "Jumping (L)",
		[0x03] = "Jumping (R)",
		[0x04] = "Falling (L)",
		[0x05] = "Falling (R)",
		[0x06] = "Crouching (L)",
		[0x07] = "Crouching (R)",
		[0x08] = "Sword (L)",
		[0x09] = "Sword (R)",
		[0x0A] = "Bow (L)",
		[0x0B] = "Bow (R)",
		[0x0C] = "Crouching Bow (L)",
		[0x0D] = "Crouching Bow (R)",
		[0x0E] = "Death",
		[0x10] = "Damaged",
		[0x12] = "Crouching Sword (L)",
		[0x13] = "Crouching Sword (R)",
	},
	takeMeThereType = "Button",
};

function Game.getMapStatus()
	local status = mainmemory.readbyte(Game.Memory.map_status);
	if type(Game.map_states[status]) == "string" then
		return Game.map_states[status];
	end
	return "Unknown "..toHexString(status);
end

function Game.getBuildingStatus()
	local status = mainmemory.readbyte(Game.Memory.building_status);
	if type(Game.building_states[status]) == "string" then
		return Game.building_states[status];
	end
	return "Unknown "..toHexString(status);
end

function Game.getMap()
	local map = mainmemory.readbyte(Game.Memory.map);
	if type(Game.maps[map]) == "string" then
		return Game.maps[map];
	end
	return "Unknown "..toHexString(map);
end

function Game.getContinue()
	local map = mainmemory.readbyte(Game.Memory.continue_map);
	if type(Game.maps[map]) == "string" then
		return Game.maps[map];
	end
	return "Unknown "..toHexString(map);
end

function Game.setMap(value)
	mainmemory.writebyte(Game.Memory.map, value);
	mainmemory.writebyte(Game.Memory.building_status, 1);
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.health, 0x30);
	mainmemory.writebyte(Game.Memory.continues_used, 0);
end

function Game.read_u16_8(base)
	local major = mainmemory.read_u16_le(base + 1);
	local sub = mainmemory.readbyte(base) / 256;
	return major + sub;
end

function Game.read_s16_8(base)
	local major = mainmemory.read_s16_le(base + 1);
	local sub = mainmemory.readbyte(base) / 256;
	return major + sub;
end

function Game.isGrounded()
	return mainmemory.readbyte(Game.Memory.in_air) == 0x00;
end

function Game.isRecovering()
	return mainmemory.readbyte(Game.Memory.recovery_status) ~= 0x00;
end

function Game.getRecoveryTimer()
	return mainmemory.read_u16_le(Game.Memory.recovery_timer);
end

function Game.getHealth()
	return mainmemory.readbyte(Game.Memory.health);
end

function Game.getContinuesUsed()
	return mainmemory.readbyte(Game.Memory.continues_used);
end

function Game.getXPosition()
	return mainmemory.readbyte(Game.Memory.x_position);
end

function Game.getYPosition()
	return mainmemory.readbyte(Game.Memory.y_position);
end

function Game.getXVelocity()
	return Game.read_s16_8(Game.Memory.x_velocity);
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(Game.Memory.y_velocity) / 256;
end

function Game.getMovementState()
	local state = mainmemory.readbyte(Game.Memory.movement_state);
	if type(Game.movement_states[state]) == "string" then
		return Game.movement_states[state];
	end
	return "Unknown "..toHexString(state);
end

function Game.eachFrame()
	if Game.isRecovering() then
		Game.OSD = Game.recoveryOSD;
	else
		Game.OSD = Game.standardOSD;
	end
end

Game.OSDPosition = {2, 70};
Game.standardOSD = {
	{"Map", Game.getMap},
	{"Status", Game.getMapStatus},
	{"Status", Game.getBuildingStatus},
	{"Separator", 1},
	{"Continue", Game.getContinue},
	{"Continues Used", function() return Game.getContinuesUsed().."/10"; end},
	{"Health", function() return Game.getHealth().."/48"; end},
	{"Separator", 1},
	{"Movement", Game.getMovementState},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"dX"},
	{"dY"},
	{"Grounded", Game.isGrounded},
};
Game.recoveryOSD = {
	{"Map", Game.getMap},
	{"Status", Game.getMapStatus},
	{"Status", Game.getBuildingStatus},
	{"Separator", 1},
	{"Continue", Game.getContinue},
	{"Continues Used", function() return Game.getContinuesUsed().."/10"; end},
	{"Health", function() return Game.getHealth().."/48"; end},
	{"Separator", 1},
	{"Movement", Game.getMovementState},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"dX"},
	{"dY"},
	{"Grounded", Game.isGrounded},
	{"Recovery", Game.getRecoveryTimer},
};
Game.OSD = Game.standardOSD;

return Game;