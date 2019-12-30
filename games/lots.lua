if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		map = 0x98, -- See Game.maps
		map_status = 0xA0, -- See Game.map_states
		building_status = 0xA1, -- See Game.building_states
		controller_input = 0xA5, -- Port_IOPort1, held
		new_controller_input = 0xA5, -- Port_IOPort1, newly pressed buttons
		demo_timer = 0x104, -- 2 bytes
		screen_x_tile = 0x10A,
		screen_x_pixel = 0x10F,
		map_type = 0x118, -- See Game.map_types
		loading_zone_destination_top_right = 0x119, -- See Game.maps
		loading_zone_destination_bottom_right = 0x11A, -- See Game.maps
		loading_zone_destination_top_left = 0x11B, -- See Game.maps
		loading_zone_destination_bottom_left = 0x11C, -- See Game.maps
		health = 0x129,
		recovery_status = 0x12B,
		recovery_timer = 0x12C, -- 2 bytes
		building_flag_progress = 0x142, -- How many progress flags are set for the current building?
		in_boss_fight = 0x151,
		boss_index = 0x152, -- See Game.bosses
		building_index = 0x169,
		continue_map = 0xCAE,
		continues_used = 0xCAF,
		movement_state = 0x401,
		movement_state_pre_damage = 0x429, -- When the damage animation ends, the movement state will be set to whatever value is here to return to whatever action Landau was doing before taking damage
		incoming_player_damage = 0x42B, -- The damage/heal that will be applied at the end of knockback
		x_position = 0x409, -- s16.8 fixed point (relative to screen)
		y_position = 0x406, -- 8.8 fixed point (relative to screen)
		x_velocity = 0x413, -- s16.8 fixed point
		y_velocity = 0x410, -- 8.8 fixed point
		facing_direction = 0x421,
		in_air = 0x422,
		sword_damage = 0xCA8,
		bow_damage = 0xCA9,
	},
	maps = {
		"01 - Swamp (Shagart +1L) (L)",
		"02 - Swamp (Shagart +1L) (R)",
		"03 - Swamp (Dwarle +1DR) (Lindon +1L) (L)",
		"04 - Swamp (Dwarle +1DR) (Lindon +1L) (R)",
		"05 - Swamp (Pharazon +1R) (L)",
		"06 - Swamp (Pharazon +1R) (R)",
		"07 - Swamp (Harfoot +1R) (Amon +2L) (L) (Demo)",
		"08 - Swamp (Harfoot +1R) (Amon +2L) (R)",
		"09 - Swamp (Ithile +3R) (L)",
		"0A - Swamp (Ithile +3R) (R)",
		"0B - Swamp (Dwarle +1UR) (L)",
		"0C - Swamp (Dwarle +1UR) (L)",
		"0D - Swamp (Varlin +1L) (L)",
		"0E - Swamp (Varlin +1L) (R)",
		"0F - Swamp (Pharazon +1DL) (L)",
		"10 - Swamp (Pharazon +1DL) (R)",
		"11 - Swamp (Ithile +1R) (L)",
		"12 - Swamp (Ithile +1R) (R)",
		"13 - Swamp (Harfoot +1L) (Medusa +3R) (L)",
		"14 - Swamp (Harfoot +1L) (Medusa +3R) (R)",
		"15 - Swamp (Pharazon +1UR) (R)",
		"16 - Swamp (Pharazon +1UR) (R)",
		"17 - Swamp (Shagart +1R) (L)",
		"18 - Swamp (Shagart +1R) (R)",
		"19 - Swamp (Lindon +1R) (Pirate +2L) (L)",
		"1A - Swamp (Lindon +1R) (Pirate +2L) (R)",
		"1B - Swamp (Pharazon +1UL) (L)",
		"1C - Swamp (Pharazon +1UL) (R)",
		"1D - Swamp (Castle Elder +1L) (L)",
		"1E - Swamp (Castle Elder +1L) (R)",
		"1F - Swamp (Ithile +1L) (Goblin +3R) (L)",
		"20 - Swamp (Ithile +1L) (Goblin +3R) (R)",
		"21 - Swamp (Varlin +1UL) (L)",
		"22 - Swamp (Varlin +1UL) (R)",
		"23 - Forest (Amon +1L) (Harfoot +2R) (L)",
		"24 - Forest (Amon +1L) (Harfoot +2R) (R)",
		"25 - Forest (Amon +1UL) (L)",
		"26 - Forest (Amon +1UL) (R)",
		".27 - Forest (Namo +1R) (Pharazon +2DL) (L)",
		"28 - Forest (Namo +1R) (Pharazon +2DL) (R)",
		".29 - Forest (Ulmo +1R) (L)",
		"2A - Forest (Ulmo +1R) (R)",
		"2B - Forest (Medusa +2R) (Harfoot +2L) (L)",
		"2C - Forest (Medusa +2R) (Harfoot +2L) (R)",
		"2D - Forest (Amon +1R) (L)",
		"2E - Forest (Amon +1R) (R)",
		"2F - Forest (???) (L)",
		"30 - Forest (???) (R)",
		"31 - Forest (Amon +1UL) (DL)",
		"32 - Forest (Amon +1UL) (R)",
		"33 - Forest (Amon +1UL) (UL)",
		"34 - Forest (Shagart +2L) (DL)",
		"35 - Forest (Shagart +2L) (R)",
		"36 - Forest (Shagart +2L) (UL)",
		"37 - Forest (Varlin +2UL) (Dwarle +2L) (DL)",
		"38 - Forest (Varlin +2UL) (Dwarle +2L) (R)",
		"39 - Forest (Varlin +2UL) (Dwarle +2L) (UL)",
		"3A - Coast (Dwarle +1L) (L)",
		"3B - Coast (Dwarle +1L) (R)",
		"3C - Coast (Ithile +2R) (L)",
		"3D - Coast (Ithile +2R) (R)",
		"3E - Coast (Shagart +2R) (L)",
		"3F - Coast (Shagart +2R) (R)",
		"40 - Cave (Dark Suma +1R) (L)",
		"41 - Cave (Dark Suma +1R) (R)",
		".42 - Cave (Necromancer +1R) (Ithile +3L) (L)",
		"43 - Cave (Necromancer +1R) (Ithile +3L) (R)",
		"44 - Mountains (Amon +2UL) (Pharazon +2R) (L)",
		"45 - Mountains (Amon +2UL) (Pharazon +2R) (R)",
		"46 - Mountains (Shagart +3R) (L)",
		"47 - Mountains (Shagart +3R) (R)",
		"48 - Mountains (Dwarle +1UR+1R) (L)",
		"49 - Mountains (Dwarle +1UR+1R) (R)",
		"4A - Mountains (???) (L)",
		"4B - Mountains (???) (R)",
		"4C - Mountains (Dwarle +1UR+???) (DL)",
		".4D - Mountains (Baruga +1L) (R)",
		"4E - Mountains (???) (UL)",
		"4F - Mountains (Pharazon +2UR) (DL)",
		"50 - Mountains (Pharazon +2UR) (R)",
		"51 - Mountains (Pharazon +2UR) (UL)",
		"52 - Mountains (???) (L)",
		"53 - Mountains (???) (R)",
		".54 - Mountains (Medusa +1R) (Harfoot +3L) (L)",
		"55 - Mountains (Medusa +1R) (Harfoot +3L) (R)",
		"56 - Mountains (Pharazon +1UL+3L+Stairs) (L)",
		"57 - Mountains (Pharazon +1UL+3L+Stairs) (R)",
		"58 - Mountains (Dark Suma +2R) (L)",
		"59 - Mountains (Dark Suma +2R) (R)",
		"5A - Dark Forest (Ithile +2L) (Necromancer +2R) (L)",
		"5B - Dark Forest (Ithile +2L) (Necromancer +2R) (R)",
		"5C - Dark Forest (Pirate +1L) (Lindon +2R) (L)",
		".5D - Dark Forest (Pirate +1L) (Lindon +2R) (R)",
		".5E - Harfoot (L)",
		".5F - Harfoot (R)",
		".60 - Ithile (L)",
		".61 - Ithile (R)",
		".62 - Amon (L)",
		".63 - Amon (R)",
		".64 - Amon (UL)",
		".65 - Amon (L) (Path Open)",
		".66 - Amon (R) (Path Open)",
		".67 - Amon (UL) (Path Open)",
		".68 - Dwarle (L)",
		".69 - Dwarle (R)",
		".6A - Dwarle (R Stairs)",
		".6B - Pharazon (L)",
		".6C - Pharazon (R)",
		".6D - Pharazon (UL)",
		".6E - Pharazon (DL, Stairs Spawned)",
		".6F - Pharazon (DR, Stairs Spawned)",
		".70 - Pharazon (UL, Stairs Spawned)",
		".71 - Pharazon (UR, Stairs Spawned)",
		"72 - Shagart (L)",
		"73 - Shagart (Door)",
		".74 - Shagart (Open) (L)",
		".75 - Shagart (Open) (Door)",
		".76 - Lindon (L)",
		".77 - Lindon (R)",
		".78 - Elder",
		"79 - Varlin (Glitched)", -- Hasn't been tested with correct flags set
		".7A - Varlin (DL, Closed)",
		".7B - Varlin (UL, Closed)",
		".7C - Varlin (DL, Open)",
		".7D - Varlin (UL, Open)",
		".7E - Dark Suma's Dungeon 1F (DL)",
		"7F - Dark Suma's Dungeon 1F (UL)",
		"80 - Dark Suma's Dungeon 2F",
		"81 - Dark Suma's Dungeon 3F",
		".82 - Ra Goan's Dungeon Entrance",
		"83 - Ra Goan's Dungeon Boss Room",
		"84 - Ra Goan's Dungeon B1F",
		"85 - Ra Goan's Dungeon B2F",
		"86 - Ra Goan's Dungeon B3F",
	},
	map_types = {
		[0x01] = "Swamp",
		[0x02] = "Forest",
		[0x03] = "Coast",
		[0x04] = "Cave",
		[0x05] = "Mountains",
		[0x06] = "Dark Forest",
		[0x07] = "Town",
		[0x08] = "Castle",
		[0x09] = "Dungeon (Suma)",
		[0x0A] = "Dungeon (Ra Goan)",
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
		[0x05] = "Ending",
		[0x06] = "Death",
	},
	buildings = { -- Game.Memory.building_index
		[0x01] = "Harfoot",
		[0x02] = "Amon",
		[0x03] = "Dwarle",
		[0x04] = "Ithile",
		[0x05] = "Pharazon",
		[0x06] = "Shagart", -- Unused but the progress flags are still set by Ra Goan
		[0x07] = "Lindon",
		[0x08] = "Ulmo", -- Tree
		[0x09] = "Mayor's Daughter", -- After Pirate
		[0x0A] = "Throwing The Book",
		[0x0B] = "Elder",
		[0x0C] = "Varlin",
	},
	movement_states = {
		[0x00] = "Walking (L)",
		[0x01] = "Walking (R)",
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
	bosses = { -- Game.Memory.boss_index
		[0x01] = "Ulmo",
		[0x02] = "Namo",
		[0x03] = "Baruga",
		[0x04] = "Medusa",
		[0x05] = "Necromancer",
		[0x06] = "Duels",
		[0x07] = "Pirate1",
		[0x08] = "Pirate2",
		[0x09] = "Pirate3",
		[0x0A] = "Pirate4",
		[0x0B] = "Dark Suma",
		[0x0C] = "Ra Goan",
	},
	takeMeThereType = "Button",
};

function Game.getMapStatus()
	local status = mainmemory.readbyte(Game.Memory.map_status);
	if type(Game.map_states[status]) == "string" then
		status = Game.map_states[status];
	end
	if status == "Title Screen" then
		status = status.." ("..mainmemory.read_u16_le(Game.Memory.demo_timer)..")";
	end
	if type(status) == "string" then
		return status;
	end
	return "Unknown "..toHexString(status);
end

function Game.getBuildingStatus()
	local status = mainmemory.readbyte(Game.Memory.building_status);
	status = Game.building_states[status] or "Unknown "..toHexString(status);
	local buildingProgress = mainmemory.readbyte(Game.Memory.building_flag_progress);
	if status == "Building" then
		local buildingIndex = mainmemory.readbyte(Game.Memory.building_index);
		buildingIndex = Game.buildings[buildingIndex] or "Unknown "..toHexString(buildingIndex, 2);
		status = buildingIndex.." "..toHexString(buildingProgress, 1, "");
	elseif status == "Boss Fight" then
		local bossIndex = bit.band(0x7F, mainmemory.readbyte(Game.Memory.boss_index));
		bossIndex = Game.bosses[bossIndex] or "Unknown "..toHexString(bossIndex, 2);
		status = "Boss: "..bossIndex;
	end
	return status;
end

function Game.getMap()
	local map = mainmemory.readbyte(Game.Memory.map);
	return Game.maps[map] or "Unknown "..toHexString(map);
end

function Game.getTLMap()
	local map = mainmemory.readbyte(Game.Memory.loading_zone_destination_top_left);
	return Game.maps[map] or "Unknown "..toHexString(map);
end

function Game.getBLMap()
	local map = mainmemory.readbyte(Game.Memory.loading_zone_destination_bottom_left);
	return Game.maps[map] or "Unknown "..toHexString(map);
end

function Game.getTRMap()
	local map = mainmemory.readbyte(Game.Memory.loading_zone_destination_top_right);
	return Game.maps[map] or "Unknown "..toHexString(map);
end

function Game.getBRMap()
	local map = mainmemory.readbyte(Game.Memory.loading_zone_destination_bottom_right);
	return Game.maps[map] or "Unknown "..toHexString(map);
end

function Game.getContinue()
	local map = mainmemory.readbyte(Game.Memory.continue_map);
	return Game.maps[map] or "Unknown "..toHexString(map);
end

function Game.setMap(value)
	mainmemory.writebyte(Game.Memory.map, value);
	mainmemory.writebyte(Game.Memory.building_status, 1);
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultXOffset = -8;
	ScriptHawk.hitboxDefaultYOffset = -16;
	ScriptHawk.hitboxDefaultWidth = 16;
	ScriptHawk.hitboxDefaultHeight = 16;
	ScriptHawk.hitboxDefaultColor = colors.red;
	return true;
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.health, 0x30);
	--mainmemory.writebyte(Game.Memory.continues_used, 1);
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

function Game.write_s16_8(base, value)
	local major = math.floor(value);
	local sub = (value - major) * 256;
	mainmemory.writebyte(base, sub);
	mainmemory.write_s16_le(base + 1, major);
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

function Game.colorRecoveryTimer()
	if Game.isRecovering() then
		return colors.red;
	end
	return colors.white;
end

function Game.getHealth()
	return mainmemory.readbyte(Game.Memory.health);
end

function Game.getHealthOSD()
	local healthString = Game.getHealth().."/48";
	if Game.isRecovering() then
		healthString = healthString.." ("..Game.getRecoveryTimer()..")";
	end
	return healthString;
end

function Game.getContinuesUsed()
	return mainmemory.readbyte(Game.Memory.continues_used);
end

function Game.getMapX()
	return mainmemory.readbyte(Game.Memory.screen_x_tile) * 8 + (7 - mainmemory.readbyte(Game.Memory.screen_x_pixel));
end

function Game.getXPosition()
	return Game.getMapX() + Game.read_s16_8(Game.Memory.x_position);
end

function Game.getYPosition()
	return mainmemory.read_u16_le(Game.Memory.y_position) / 256;
end

function Game.getXVelocity()
	return Game.read_s16_8(Game.Memory.x_velocity);
end

function Game.colorXVelocity()
	local xVel = math.abs(Game.getXVelocity());
	if xVel >= 2 then
		return colors.green;
	end
	if xVel > 0 and xVel < 1 then
		return getColor(1 - xVel);
	end
	return colors.white;
end

function Game.greenIfStartingJumpChain()
	local xVel = math.abs(Game.getXVelocity());
	if xVel >= 2 then
		local movementState = Game.getMovementState();
		local isGrounded = Game.isGrounded();
		if movementState ~= "Damaged" and isGrounded then
			return colors.green;
		end
	end
	return colors.white;
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

local object_size = 0x40;
local object_array_base = 0x400;
local object_array_capacity = 24;
local object_fields = {
	object_type = 0x00,
	is_initialized = 0x03, -- Byte, non zero means the object has the correct constants initted (hitbox etc) and should be drawn
	x_position = 0x09, -- s16.8 fixed point (relative to screen)
	y_position = 0x06, -- 8.8 fixed point (relative to screen)
	x_velocity = 0x13, -- s16.8 fixed point
	y_velocity = 0x10, -- 8.8 fixed point
	hitbox_y_offset = 0x16,
	hitbox_height = 0x17,
	hitbox_x_offset = 0x18,
	hitbox_width = 0x19,
	object_loaded = 0x0B,
	score_value = 0x1B, -- Upper 4 bits, not sure what the lower 4 are used for
	score_values = { -- Table is at 0x1787 in ROM (BCD, 3 bytes each), might be different on J
		[0x0] = 0,
		[0x1] = 1000,
		[0x2] = 2000,
		[0x3] = 3000,
		[0x4] = 10000,
		[0x5] = 20000,
		[0x6] = 30000,
		[0x7] = 40000,
		[0x8] = 50000,
		[0x9] = 60000,
		[0xA] = 70000,
		[0xB] = 80000,
		[0xC] = 2093400, -- Reads code as data, prolly different on J?
		[0xD] = 1629170, -- Reads code as data, prolly different on J?
		[0xE] = 2093320, -- Reads code as data, prolly different on J?
		[0xF] = 2096210, -- Reads code as data, prolly different on J?
	},
	respawn_timer = 0x30,
	currentHP = 0x3A,
	bossHP = 0x34,
	boss_defeated = 0x3E,
	boss_teleport_timer = 0x22,
	boss_flash_timer = 0x24,
	sign = {
		index = 0x0E,
		indexes = {
			[0x00] = "Harfoot", -- Village
			[0x01] = "Amon", -- Village
			[0x02] = "Dwarle", -- Village
			[0x03] = "Ithile", -- Village
			[0x04] = "Pharazon", -- Town
			[0x05] = "Shagart", -- Town
			[0x06] = "Lindon", -- Town
			[0x07] = "Varlin", -- Castle
			[0x08] = "Elder", -- Castle
			-- 0x09+ is just garbage data
		},
		timer = 0x0F, -- Byte
	},
	object_types = {
		--[0x00] = "Null",
		[0x01] = {name="Landau"},
		[0x02] = {name="Arrow"},
		[0x03] = {name="Sword Upgrade"},
		[0x04] = {name="Arrow Upgrade"},
		[0x05] = {name="Sign"},
		[0x06] = {name="Null"}, -- Empty behaviour handler
		[0x07] = {name="Null"}, -- Empty behaviour handler
		[0x08] = {name="Null"}, -- Empty behaviour handler
		[0x09] = {name="Null"}, -- Empty behaviour handler
		[0x0A] = {name="Null"}, -- Empty behaviour handler
		[0x0B] = {name="Null"}, -- Empty behaviour handler
		[0x0C] = {name="Null"}, -- Empty behaviour handler
		[0x0D] = {name="Null"}, -- Empty behaviour handler
		[0x0E] = {name="Null"}, -- Empty behaviour handler
		[0x0F] = {name="Null"}, -- Empty behaviour handler
		[0x10] = {name="Slime"}, -- Dungeon
		[0x11] = {name="Eye Part"}, -- Forest
		[0x12] = {name="Giant Bat"},
		[0x13] = {name="Bird"},
		[0x14] = {name="Killer Fish"},
		[0x15] = {name="Clown"},
		[0x16] = {name="Knight"},
		[0x17] = {name="Scorpion"},
		[0x18] = {name="Spider"}, -- Mountain
		[0x19] = {name="White Wolf"},
		[0x1A] = {name="Caterpillar"},
		[0x1B] = {name="Eye Part"}, -- Forest
		[0x1C] = {name="Skeleton"},
		[0x1D] = {name="Demon"}, -- Red Flying Thingy
		[0x1E] = {name="Snake"},
		[0x1F] = {name="Giant Bat"},
		[0x20] = {name="Straw Fly"}, -- Floating up and down and shooting (forest plant killymajig)
		[0x21] = {name="Book Thief"},
		[0x22] = {name="Dragon"}, -- Unused?
		[0x23] = {name="Dark Shunaida"}, -- Mountain
		[0x24] = {name="Lizard Man"}, -- Red, forest, jumps
		[0x25] = {name="Dagon"}, -- Green, jumps from bottom of screen
		[0x26] = {name="Zombie"}, -- Cave, shoots projectiles
		[0x27] = {name="Damaged"}, -- Killed Knight
		[0x28] = {name="Snake"}, -- Cave, shoots projectiles
		[0x29] = {name="Projectile"}, -- Straw Fly
		[0x2A] = {name="Damaged"}, -- Killed or off edge of screen
		[0x2B] = {name="Tree Spirit", isBoss=true},
		[0x2C] = {name="Projectile"}, -- Tree Spirit
		[0x2D] = {name="Projectile"}, -- Tree Spirit
		[0x2E] = {name="Necromancer", isBoss=true},
		[0x2F] = {name="Stone Hammer", isBoss=true}, -- Second Duel
		[0x30] = {name="Dark Suma", isBoss=true},
		[0x31] = {name="Clone", isBoss=true}, -- Necromancer's Minion
		[0x32] = {name="Golden Guard", isBoss=true}, -- Third Duel
		[0x33] = {name="Paradin", isBoss=true}, -- Fifth Duel
		[0x34] = {name="Pirate", isBoss=true},
		[0x35] = {name="Projectile"}, -- Pirate Boss' Sword
		[0x36] = {name="Medusa", isBoss=true},
		[0x37] = {name="Baruga", isBoss=true},
		[0x38] = {name="Null"},  -- Empty behaviour handler
		[0x39] = {name="Court Jester", isBoss=true}, -- Fourth Duel
		[0x3A] = {name="The Ripper", isBoss=true}, -- First Duel
		[0x3B] = {name="Projectile"}, -- Baruga
		[0x3C] = {name="Projectile"}, -- Court Jester
		[0x3D] = {name="Skull"}, -- Dark Suma
		[0x3E] = {name="Projectile"}, -- Dark Suma
		[0x3F] = {name="Shield"}, -- Ra Goan
		[0x40] = {name="Projectile"}, -- Ra Goan
		[0x41] = {name="Projectile"}, -- Ra Goan
		[0x42] = {name="Ra Goan", isBoss=true},
		-- This is the end of the table in ROM, anything later will be using garbage data
	},
};

function Game.getHitboxes()
	local hitboxes = {};

	for i = 0, object_array_capacity do
		local hitbox = {
			objectBase = object_array_base + (i * object_size);
		};
		local objectType = mainmemory.readbyte(hitbox.objectBase + object_fields.object_type);
		local objectLoaded = mainmemory.readbyte(hitbox.objectBase + object_fields.is_initialized);
		local screenX = Game.getMapX();
		if objectType > 0 and objectLoaded ~= 0 then
			hitbox.dragTag = hitbox.objectBase;
			hitbox.x = Game.read_s16_8(hitbox.objectBase + object_fields.x_position);
			hitbox.y = mainmemory.read_u16_le(hitbox.objectBase + object_fields.y_position) / 256;

			hitbox.currentHP = mainmemory.readbyte(hitbox.objectBase + object_fields.currentHP);
			hitbox.objectType = "Unknown "..toHexString(objectType);

			hitbox.xOffset = mainmemory.read_s8(hitbox.objectBase + object_fields.hitbox_x_offset);
			hitbox.yOffset = mainmemory.read_s8(hitbox.objectBase + object_fields.hitbox_y_offset);
			hitbox.width = mainmemory.read_s8(hitbox.objectBase + object_fields.hitbox_width);
			hitbox.height = mainmemory.read_s8(hitbox.objectBase + object_fields.hitbox_height);

			if type(object_fields.object_types[objectType]) == "table" then
				local objectTypeTable = object_fields.object_types[objectType];

				hitbox.objectType = objectTypeTable.name or hitbox.objectType;
				hitbox.color = objectTypeTable.color or colors.white;

				if objectTypeTable.isBoss then
					hitbox.currentHP = mainmemory.readbyte(hitbox.objectBase + object_fields.bossHP);
				elseif hitbox.objectType == "Landau" then
					hitbox.currentHP = Game.getHealth();
				end
			end
			table.insert(hitboxes, hitbox);
		end
	end
	return hitboxes;
end

function Game.setHitboxPosition(hitbox, x, y)
	Game.write_s16_8(hitbox.objectBase + object_fields.x_position, x);
	mainmemory.write_u16_le(hitbox.objectBase + object_fields.y_position, y * 256);
end

function Game.getHitboxMouseOverText(hitbox)
	return {
		hitbox.objectType,
		toHexString(hitbox.objectBase).." "..round(hitbox.x)..","..round(hitbox.y),
		hitbox.currentHP.."HP",
	};
end

function Game.getHitboxStaticText(hitbox)
	if hitbox.currentHP > 0 then
		return hitbox.currentHP;
	end
end

function Game.getHitboxListText(hitbox)
	return round(hitbox.x)..", "..round(hitbox.y).." - "..hitbox.objectType.." "..hitbox.currentHP.."HP "..toHexString(hitbox.objectBase);
end

function Game.killEnemies()
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		local objectLoaded = mainmemory.readbyte(objectBase + object_fields.is_initialized);
		if objectType > 0 and objectLoaded > 0 then
			if type(object_fields.object_types[objectType]) == "table" then
				local objectTypeTable = object_fields.object_types[objectType];
				if objectTypeTable.isBoss then
					mainmemory.writebyte(objectBase + object_fields.bossHP, 0);
				else
					mainmemory.writebyte(objectBase + object_fields.currentHP, 0);
				end
			end
		end
	end
end

----------------
-- Flag stuff --
----------------

local flag_block_base = 0xC00;
local flag_block_size = 0xAD;

local flag_block_cache = {};
local flag_names = {};

local flag_array = {
	{byte=0xC00, name="Tree Spirit Defeated"},
	{byte=0xC01, name="Baruga Defeated"},
	{byte=0xC02, name="Medusa Defeated"},
	{byte=0xC03, name="Necromancer Defeated"},
	{byte=0xC04, name="Duels Defeated"},
	{byte=0xC05, name="Pirate Defeated"},
	{byte=0xC06, name="Dark Suma Defeated"},
	{byte=0xC07, name="Ra Goan Defeated"},
	{byte=0xC11, name="Game Started"},
	{byte=0xC12, name="Ulmo Tree Available"},
	{byte=0xC13, name="Tree Spirit Spawned"}, -- Namo NPC End
	-- {byte=0xC14, name="Tree Spirit defeated?"},
	-- {byte=0xC15, name="Necromancer defeated?"},
	{byte=0xC16, name="Daughter Returned To Lindon"}, -- After Pirate Boss
	-- {byte=0xC17, name="duels defeated?"},
	-- {byte=0xC18, name="suma defeated?"},
	{byte=0xC19, name="Medusa Spawned"}, -- Also requires Herb
	-- {byte=0xC1A, name="Pharazon: daughter knows more details"},
	-- {byte=0xC1B, name="Progress 0x0B},
	-- {byte=0xC1C, name="Baruga Defeated?"},
	{byte=0xC1D, name="Varlin Open"}, -- Medusa Defeated?
	-- {byte=0xC1E, name="Unknown - Set by Ra Goan"},
	{byte=0xC21, name="Harfoot FTT"},
	{byte=0xC22, name="Harfoot: Rest Here Text"},
	{byte=0xC23, name="Harfoot: Rest Here Text 2"},
	{byte=0xC24, name="Harfoot: Rest Here Text 3"},
	{byte=0xC25, name="Harfoot: Rest Here Text 4"},
	{byte=0xC26, name="Harfoot: Rest Here Text 5"},
	{byte=0xC27, name="Harfoot: Medusa Text", max_value=0x81},
	-- {byte=0xC28, name="Unknown - Set by Ra Goan"},
	{byte=0xC29, name="Harfoot: Persevere Text"},
	-- {byte=0xC2A, name="Unknown - Set by Ra Goan"},
	-- {byte=0xC2B, name="Unknown - Set by Ra Goan"},
	{byte=0xC2C, name="Harfoot: Persevere Text 2"}, -- After Baruga
	{byte=0xC2D, name="Harfoot: Congratulation Text"}, -- After Medusa
	{byte=0xC2E, name="Harfoot: Congratulation Text 2"}, -- After Ra Goan
	{byte=0xC31, name="Amon FTT"},
	{byte=0xC32, name="Amon: Tree People Text"},
	{byte=0xC33, name="Amon: Namo Directions Text"},
	{byte=0xC34, name="Amon: First of Three Tests Text"},
	{byte=0xC35, name="Amon: Destroy Book Text"},
	{byte=0xC36, name="Amon: Book Stolen Text"},
	{byte=0xC37, name="Amon: Pharazon Path"},
	{byte=0xC38, name="Amon: Just One More Text"},
	{byte=0xC39, name="Amon: Destroy Book Text 2"},
	-- {byte=0xC2A, name="Unknown - Set by Ra Goan"},
	-- {byte=0xC2B, name="Unknown - Set by Ra Goan"},
	{byte=0xC3C, name="Amon: Sword Upgrade Text"}, -- After Baruga
	{byte=0xC3D, name="Amon: Go To Varlin Text"},
	{byte=0xC3E, name="Amon: After Ra Goan Text"}, -- Book Stolen in my flag set, probably a real message though
	{byte=0xC41, name="Dwarle FTT"},
	{byte=0xC42, name="Dwarle: Daughter Missing Text"},
	{byte=0xC43, name="Dwarle: Daughter Missing Text 2"},
	{byte=0xC44, name="Dwarle: Daughter Missing Text 3"},
	{byte=0xC45, name="Dwarle: Brave Landau Text"},
	-- {byte=0xC46, name="Unknown - Set by Ra Goan"},
	{byte=0xC47, name="Dwarle: Brave Landau Text 2"},
	-- {byte=0xC48, name="Baruga Defeated?"},
	{byte=0xC49, name="Dwarle: Kill The Beast Text"},
	-- {byte=0xC4A, name="Baruga Defeated?"},
	-- {byte=0xC4B, name="Baruga Defeated?"},
	{byte=0xC4C, name="Dwarle: Ra Goan Restoration Text"},
	{byte=0xC4D, name="Dwarle: Lindon Via Shagart Text"},
	{byte=0xC4E, name="Dwarle: Rule Our Country Well Text"}, -- After Ra Goan
	{byte=0xC51, name="Ithile FTT"},
	{byte=0xC52, name="Ithile: Brave Men Text"},
	{byte=0xC53, name="Ithile: Brave Men Text 2"},
	{byte=0xC54, name="Ithile: Necromancer Text"},
	{byte=0xC55, name="Ithile: Bow Upgrade Text"}, -- Also Shagart->Dwarle
	{byte=0xC56, name="Ithile: Rest Here Text"},
	{byte=0xC57, name="Ithile: Rest Here Text 2"}, -- After Medusa
	-- {byte=0xC58, name="Unknown - Set by Ra Goan"},
	{byte=0xC59, name="Ithile: Rest Here Text 3"}, -- After Medusa
	-- {byte=0xC5A, name="Unknown - Set by Ra Goan"},
	-- {byte=0xC5B, name="Unknown - Set by Ra Goan"},
	{byte=0xC5C, name="Ithile: Rest Here Text 4"}, -- After Baruga?
	{byte=0xC5D, name="Ithile: Rest Here Text 5"}, -- After Medusa
	{byte=0xC5E, name="Ithile: Rule Our Country Well Text"}, -- After Ra Goan
	{byte=0xC61, name="Pharazon FTT"},
	{byte=0xC62, name="Pharazon: People of Ithile Text"},
	{byte=0xC63, name="Pharazon: Tree Spirits Text"},
	{byte=0xC64, name="Pharazon: Shagart Den of Thieves Text"},
	{byte=0xC65, name="Pharazon: Shagart Den of Thieves Text 2"},
	{byte=0xC66, name="Pharazon: Brave Landau Text"},
	{byte=0xC67, name="Pharazon: Path to Amon Text"},
	{byte=0xC68, name="Pharazon: Shagart Strange People Text"},
	{byte=0xC69, name="Pharazon: Shagart Strange People Text 2"},
	{byte=0xC6C, name="Pharazon: Shagart Strange People Text 3"}, -- After Baruga?
	{byte=0xC6D, name="Pharazon: Shagart Strange People Text 4"},
	{byte=0xC6E, name="Pharazon: Rule Our Country Well Text"}, -- After Ra Goan
	{byte=0xC71, name="Shagart FTT"},
	{byte=0xC72, name="Shagart Progress 1"}, -- Set by Ra Goan
	{byte=0xC73, name="Shagart Progress 2"}, -- Set by Ra Goan
	{byte=0xC74, name="Shagart Progress 3"}, -- Set by Ra Goan
	{byte=0xC75, name="Shagart Progress 4"}, -- Set by Ra Goan
	{byte=0xC76, name="Shagart Progress 5"}, -- Set by Ra Goan
	{byte=0xC77, name="Shagart Progress 6"}, -- Set by Ra Goan
	{byte=0xC78, name="Shagart Progress 7"}, -- Set by Ra Goan
	{byte=0xC79, name="Shagart Progress 8"}, -- Set by Ra Goan
	{byte=0xC7A, name="Shagart Progress 9"}, -- Set by Ra Goan
	{byte=0xC7B, name="Shagart Progress A"}, -- Set by Ra Goan
	{byte=0xC7C, name="Shagart Progress B"}, -- Set by Ra Goan
	{byte=0xC7D, name="Shagart Progress C"}, -- Set by Ra Goan
	{byte=0xC81, name="Lindon FTT"},
	{byte=0xC82, name="Lindon: Brave Men Text"},
	{byte=0xC83, name="Lindon: Brave Men Text 2"},
	{byte=0xC84, name="Lindon: Brave Men Text 3"},
	{byte=0xC85, name="Lindon: Kidnapping Text"},
	{byte=0xC86, name="Lindon: Rest Here Text"},
	{byte=0xC87, name="Lindon: Rest Here Text 2"},
	-- {byte=0xC88, name="Unknown - Set by Ra Goan"},
	{byte=0xC89, name="Lindon: Rest Here Text 3"},
	-- {byte=0xC8A, name="Unknown - Set by Ra Goan"},
	-- {byte=0xC8B, name="Unknown - Set by Ra Goan"},
	-- {byte=0xC8C, name="Unknown - Set by Ra Goan"},
	{byte=0xC8D, name="Lindon: Rest Here Text 4"},
	{byte=0xC8E, name="Lindon: Rule Our Country Well Text"},
	{byte=0xC91, name="Ulmo FTT"},
	{byte=0xC92, name="Ulmo: Namo Directions Text"},
	{byte=0xC93, name="Ulmo: Destroy Book Text", max_value=0x81},
	{byte=0xC94, name="Ulmo: Destroy Book Text 2"},
	{byte=0xC95, name="Ulmo: Destroy Book Text 3"},
	-- {byte=0xC96, name="Ulmo: Progress 5"}, -- Set by Ra Goan
	{byte=0xC97, name="Ulmo: Destroy Book Text 4"}, -- After Duels
	-- {byte=0xC98, name="Ulmo: Progress 7"}, -- Set by Ra Goan
	{byte=0xC99, name="Ulmo: Destroy Book Text 5"}, -- After Duels
	-- {byte=0xC9A, name="Ulmo: Progress 9"}, -- Set by Ra Goan
	-- {byte=0xC9B, name="Ulmo: Progress A"}, -- Set by Ra Goan
	{byte=0xC9C, name="Ulmo: Cast Book Into Fire Text"},
	-- {byte=0xC9D, name="Ulmo: Progress C"}, -- Set by Ra Goan
	{byte=0xCA0, name="Baruga Spawned"}, -- Book Burnable?
	{byte=0xCA1, name="Necromancer Spawned"},
	{byte=0xCA2, name="Pirate Spawned"}, -- Also Lindon/Dwarle open?
	{byte=0xCA3, name="Path to Amon Open"}, -- Suma spawned?
	-- {byte=0xCA4, name="Unknown - Set by Ra Goan"},
	{byte=0xCA8, name="Sword Damage", max_value=0x03},
	{byte=0xCA9, name="Bow Damage", max_value=0x03},
	{byte=0xCAA, name="Inventory: Book"},
	{byte=0xCAB, name="Inventory: Tree Limb"},
	{byte=0xCAC, name="Inventory: Herb"},
	-- {byte=0xCAD, name="???"},
};

-- Fill flag names and flags by map
if #flag_array > 0 then
	for i = 1, #flag_array do
		if not flag_array[i].ignore then
			flag_names[i] = flag_array[i].name;
		end
	end
else
	print("Warning: No flags found");
	flag_names = {"None"};
end

local function clearFlagCache()
	flag_block_cache = {};
end

local function getFlag(byte)
	for i = 1, #flag_array do
		if byte == flag_array[i].byte then
			return flag_array[i];
		end
	end
	return {byte=byte, name="Unknown at "..toHexString(byte)};
end

local function isFlagFound(byte)
	return getFlag(byte) ~= nil;
end

local function getFlagByName(flagName)
	for i = 1, #flag_array do
		if not flag_array[i].ignore and flagName == flag_array[i].name then
			return flag_array[i];
		end
	end
end

function Game.getFlagName(byte)
	for i = 1, #flag_array do
		if byte == flag_array[i].byte and not flag_array[i].ignore then
			return flag_array[i].name;
		end
	end
	return "Unknown at "..toHexString(byte);
end

function checkFlags(showKnown)
	local flagBlock = mainmemory.readbyterange(flag_block_base, flag_block_size + 1);

	if #flag_block_cache == flag_block_size then
		local flagFound = false;
		local knownFlagsFound = 0;
		local currentFlag, currentValue, previousValue;

		for i = 0, #flag_block_cache do
			currentValue = flagBlock[i];
			previousValue = flag_block_cache[i];
			if currentValue ~= previousValue then
				currentFlag = getFlag(flag_block_base + i);
				if not currentFlag.ignore then
					if currentValue == 0 then
						dprint("Flag "..toHexString(currentFlag.byte, 2)..': "'..currentFlag.name..'" was cleared on frame '..emu.framecount());
					elseif previousValue == 0 then
						dprint("Flag "..toHexString(currentFlag.byte, 2)..': "'..currentFlag.name..'" was set with value '..toHexString(currentValue, 2).." on frame "..emu.framecount());
					elseif currentValue > previousValue then
						dprint("Flag "..toHexString(currentFlag.byte, 2)..': "'..currentFlag.name..'" value increased from '..toHexString(previousValue, 2).." to "..toHexString(currentValue, 2).." on frame "..emu.framecount());
					elseif currentValue < previousValue then
						dprint("Flag "..toHexString(currentFlag.byte, 2)..': "'..currentFlag.name..'" value decreased from '..toHexString(previousValue, 2).." to "..toHexString(currentValue, 2).." on frame "..emu.framecount());
					end
				end
			end
		end
		flag_block_cache = flagBlock;
		if not showKnown then
			if knownFlagsFound > 0 then
				dprint(knownFlagsFound.." Known flags skipped");
			end
			if not flagFound then
				dprint("No unknown flags were changed");
			end
		end
	else
		flag_block_cache = flagBlock;
		dprint("Populated flag block cache");
	end
	print_deferred();
end

function setFlagByName(name)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		if type(flag.max_value) == "number" then
			mainmemory.writebyte(flag.byte, flag.max_value);
		else
			mainmemory.writebyte(flag.byte, 0x01);
		end
	end
end

function clearFlagByName(name)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		mainmemory.writebyte(flag.byte, 0);
	end
end

function checkFlag(name)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		local value = mainmemory.readbyte(flag.byte);
		if value > 0 then
			if type(flag.max_value) == "number" then
				if value == flag.max_value then
					print("The flag "..flag.name.." is SET");
					return true;
				elseif value < flag.max_value then
					print("The flag "..flag.name.." is SET (but at lower than maximum recorded value)");
					return true;
				elseif value > flag.max_value then
					print("The flag "..flag.name.." is SET (but at greater than maximum recorded value)");
					return true;
				end
			else
				print("The flag "..flag.name.." is SET");
				return true;
			end
		else
			print("The flag "..flag.name.." is NOT SET");
			return false;
		end
	end
	print('The flag "'..name..'" is currently unknown');
end

function checkBuildingProgress()
	local highestQuestProgress = 1;
	local questProgress = {
		false, false, false, false,
		false, false, false, false,
		false, false, false, false,
		false, false, false,
	};
	-- Calculate quest progress
	for flagAddress = 0xC11, 0xC1E do
		questProgress[flagAddress - 0xC10] = mainmemory.readbyte(flagAddress) > 0;
		if questProgress[flagAddress - 0xC10] then
			highestQuestProgress = flagAddress - 0xC10;
		end
	end
	for buildingIndex = 0x01, 0x0C do
		local buildingProgress = {
			false, false, false, false,
			false, false, false, false,
			false, false, false, false,
			false, false, false,
		};
		local flagBase = 0xC21 + (buildingIndex - 1) * 0x10;
		local buildingString = Game.buildings[buildingIndex] or "Unknown "..toHexString(buildingIndex);
		for flagIndex = 0x00, 0x0E do
			buildingProgress[flagIndex] = mainmemory.readbyte(flagBase + flagIndex) > 0;
			if flagIndex == highestQuestProgress then
				buildingString = buildingString.." -> "..toHexString(flagIndex, 1).." |";
			elseif questProgress[flagIndex] and not buildingProgress[flagIndex] then
				buildingString = buildingString.." -> "..toHexString(flagIndex, 1);
			end
		end
		print(buildingString);
	end
end

local function flagSetButtonHandler()
	setFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagClearButtonHandler()
	clearFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagCheckButtonHandler()
	checkFlag(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

function Game.onLoadState()
	clearFlagCache();
end

function Game.eachFrame()
	checkFlags(true);
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.button(10, 6, {4, 10}, nil, "Check Building Button", "Check Buildings", checkBuildingProgress);
		ScriptHawk.UI.button(10, 7, {46}, nil, "Set Flag Button", "Set", flagSetButtonHandler);
		ScriptHawk.UI.button(12, 7, {46}, nil, "Check Flag Button", "Check", flagCheckButtonHandler);
		ScriptHawk.UI.button(14, 7, {46}, nil, "Clear Flag Button", "Clear", flagClearButtonHandler);
	else
		-- Use a bigger check flags button if the others are hidden by TASSafe
		ScriptHawk.UI.button(10, 6, {4, 10}, nil, "Check Building Button", "Check Buildings", checkBuildingProgress);
		ScriptHawk.UI.button(10, 7, {4, 10}, nil, "Check Flag Button", "Check Flag", flagCheckButtonHandler);
	end
	ScriptHawk.UI.form_controls["Flag Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, flag_names, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);
end

Game.OSD = {
	{"Map", Game.getMap, category="mapData"},
	--{"TL LZ", Game.getTLMap, category="mapData"},
	--{"BL LZ", Game.getBLMap, category="mapData"},
	--{"TR LZ", Game.getTRMap, category="mapData"},
	--{"BR LZ", Game.getBRMap, category="mapData"},
	{"Continue", Game.getContinue, category="continues"},
	{"Continues Used", function() return Game.getContinuesUsed().."/10"; end, category="continues"},
	{"Status", Game.getMapStatus, category="mapData"},
	{"Status", Game.getBuildingStatus, category="mapData"},
	{"Separator"},
	{"Health", Game.getHealthOSD, Game.colorRecoveryTimer, category="health"},
	{"Movement", Game.getMovementState, Game.greenIfStartingJumpChain, category="movement"},
	{"X", category="position"},
	{"Y", category="position"},
	{"X Velocity", Game.getXVelocity, Game.colorXVelocity, category="speed"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"dX", category="positionStats"},
	{"dY", category="positionStats"},
	{"Grounded", Game.isGrounded, Game.greenIfStartingJumpChain, category="position"},
};

return Game;