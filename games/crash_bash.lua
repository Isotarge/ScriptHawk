if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	max_rot_units = 4096,
	rot_speed = 16,
	speedy_index = 7,
	speedy_speeds = {
		0.001, 0.01, 0.1, 1, 5, 10, 20, 50, 100
	},
	squish_memory_table = true,
	Memory = { -- Version order: USA, Europe
		--global_timer = {0x4E0D8, 0x4EA2C},
		global_timer = {0x5B690, 0x5D274},
		warp_room_2_unlocked = {0x5A780, 0x5C564},
		warp_room_3_unlocked = {0x5A792, 0x5C576},
		warp_room_4_unlocked = {0x5A785, 0x5C569},
		warp_room_5_unlocked = {0x5A79B, 0x5C57F},
		p1_x_position_warp_room = {0x9EEA0, nil}, -- Fixed point
		p1_z_position_warp_room = {0x9EEA4, nil}, -- Fixed point
		-- PLAYER 1
		p1_pointer =     {0x9D530, 0x9BA6C}, -- Game.minigamePlayer
		p1_health =      {0x9D562, 0x9BA9E},
		p1_tank_health = {0xCAD50, 0xC9638},
		p1_mines =       {0xCAD78, 0xC9660},
		-- PLAYER 2
		p2_pointer =     {0x9D59C, 0x9BAD8}, -- Game.minigamePlayer
		p2_health =      {0x9D5CE, 0x9BB0A},
		p2_tank_health = {0xCADF4, 0xC96DC},
		p2_mines =       {0xCAE1C, 0xC9704},
		-- PLAYER 3
		p3_pointer =     {0x9D608, 0x9BB44}, -- Game.minigamePlayer
		p3_health =      {0x9D63A, 0x9BB76},
		p3_tank_health = {0xCAE98, 0xC9780},
		p3_mines =       {0xCAEC0, 0xC97A8},
		-- PLAYER 4
		p4_pointer =     {0x9D674, 0x9BBB0}, -- Game.minigamePlayer
		p4_health =      {0x9D6A6, 0x9BBE2},
		p4_tank_health = {0xCAF3C, 0xC9824},
		p4_mines =       {0xCAF64, 0xC984C},
	},
	minigamePlayer = {
		x_pos = 0x10, -- Signed fixed point 16.16 little endian
		y_pos = 0x14, -- Signed fixed point 16.16 little endian
		z_pos = 0x18, -- Signed fixed point 16.16 little endian
		-- TODO: Rotation
		-- TODO: Velocity
	},
};

local global_timer = {
	current = 0,
	previous = 0,
};

function mainmemory.read_s1616_le(address) -- Signed fixed point 16.16 little endian
	return mainmemory.read_s32_le(address) / 0x10000;
end

function mainmemory.write_s1616_le(address, value) -- Signed fixed point 16.16 little endian
	return mainmemory.write_u32_le(address, value * 0x10000);
end

function mainmemory.read_s2012_le(address) -- Signed fixed point 20.12 little endian
	return mainmemory.read_s32_le(address) / 0x1000;
end

function mainmemory.write_s2012_le(address, value) -- Signed fixed point 20.12 little endian
	return mainmemory.write_u32_le(address, value * 0x1000);
end

function mainmemory.read_s248_le(address) -- Signed fixed point 24.8 little endian
	return mainmemory.read_s32_le(address) / 0x100;
end

function mainmemory.write_s248_le(address, value) -- Signed fixed point 24.8 little endian
	return mainmemory.write_u32_le(address, value * 0x100);
end

function Game.unlockWarpRooms()
	mainmemory.writebyte(Game.Memory.warp_room_2_unlocked, 1);
	mainmemory.writebyte(Game.Memory.warp_room_3_unlocked, 1);
	mainmemory.writebyte(Game.Memory.warp_room_4_unlocked, 1);
	mainmemory.writebyte(Game.Memory.warp_room_5_unlocked, 1);
end

function Game.applyInfinites()
	local max_health = 0x14;
	local max_tank_health = 0x63;
	local max_mines = 0x03;

	mainmemory.writebyte(Game.Memory.p1_health, max_health);
	mainmemory.writebyte(Game.Memory.p1_tank_health, max_tank_health);
	mainmemory.writebyte(Game.Memory.p1_mines, max_mines);

	--[[
	mainmemory.writebyte(Game.Memory.p2_health, max_health);
	mainmemory.writebyte(Game.Memory.p2_tank_health, max_tank_health);
	mainmemory.writebyte(Game.Memory.p2_mines, max_mines);

	mainmemory.writebyte(Game.Memory.p3_health, max_health);
	mainmemory.writebyte(Game.Memory.p3_tank_health, max_tank_health);
	mainmemory.writebyte(Game.Memory.p3_mines, max_mines);

	mainmemory.writebyte(Game.Memory.p4_health, max_health);
	mainmemory.writebyte(Game.Memory.p4_tank_health, max_tank_health);
	mainmemory.writebyte(Game.Memory.p4_mines, max_mines);
	--]]
end

function Game.getMinigamePlayer(playerIndex)
	playerIndex = playerIndex or 0;
	return dereferencePointer(Game.Memory.p1_pointer + playerIndex * 0x6C);
end

function Game.getXPosition(playerIndex)
	local minigamePlayer = Game.getMinigamePlayer(playerIndex);
	if isRAM(minigamePlayer) then
		return mainmemory.read_s248_le(minigamePlayer + Game.minigamePlayer.x_pos);
	end
	return 0;
end

function Game.getYPosition(playerIndex)
	local minigamePlayer = Game.getMinigamePlayer(playerIndex);
	if isRAM(minigamePlayer) then
		return mainmemory.read_s248_le(minigamePlayer + Game.minigamePlayer.y_pos);
	end
	return 0;
end

function Game.getZPosition(playerIndex)
	local minigamePlayer = Game.getMinigamePlayer(playerIndex);
	if isRAM(minigamePlayer) then
		return mainmemory.read_s248_le(minigamePlayer + Game.minigamePlayer.z_pos);
	end
	return 0;
end

function Game.setXPosition(value, playerIndex)
	local minigamePlayer = Game.getMinigamePlayer(playerIndex);
	if isRAM(minigamePlayer) then
		mainmemory.write_s248_le(minigamePlayer + Game.minigamePlayer.x_pos, value);
	end
end

function Game.setYPosition(value, playerIndex)
	local minigamePlayer = Game.getMinigamePlayer(playerIndex);
	if isRAM(minigamePlayer) then
		mainmemory.write_s248_le(minigamePlayer + Game.minigamePlayer.y_pos, value);
	end
end

function Game.setZPosition(value, playerIndex)
	local minigamePlayer = Game.getMinigamePlayer(playerIndex);
	if isRAM(minigamePlayer) then
		mainmemory.write_s248_le(minigamePlayer + Game.minigamePlayer.z_pos, value);
	end
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.initUI()
	ScriptHawk.UI.button(0, 6, {4, 10}, nil, nil, "Unlock Rooms", Game.unlockWarpRooms);
end

function Game.eachFrame()
	global_timer.previous = global_timer.current;
	global_timer.current = mainmemory.read_u32_le(Game.Memory.global_timer);
end

function Game.isPhysicsFrame()
	return global_timer.current ~= global_timer.previous;
end

Game.OSD = {
	{"P1", hexifyOSD(function() return Game.getMinigamePlayer(0) end)},
	{"P1 X", function() return Game.getXPosition(0) end},
	{"P1 Y", function() return Game.getYPosition(0) end},
	{"P1 Z", function() return Game.getZPosition(0) end},
	{"Separator"},
	{"dY"},
	{"dXZ"},
	{"Separator"},
	{"P2", hexifyOSD(function() return Game.getMinigamePlayer(1) end)},
	{"P2 X", function() return Game.getXPosition(1) end},
	{"P2 Y", function() return Game.getYPosition(1) end},
	{"P2 Z", function() return Game.getZPosition(1) end},
	{"Separator"},
	{"P3", hexifyOSD(function() return Game.getMinigamePlayer(2) end)},
	{"P3 X", function() return Game.getXPosition(2) end},
	{"P3 Y", function() return Game.getYPosition(2) end},
	{"P3 Z", function() return Game.getZPosition(2) end},
	{"Separator"},
	{"P4", hexifyOSD(function() return Game.getMinigamePlayer(3) end)},
	{"P4 X", function() return Game.getXPosition(3) end},
	{"P4 Y", function() return Game.getYPosition(3) end},
	{"P4 Z", function() return Game.getZPosition(3) end},
};

return Game;