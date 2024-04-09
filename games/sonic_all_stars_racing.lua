if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

function mainmemory.read_s1616_le(address) -- Signed fixed point 16.16 little endian
	return mainmemory.read_s32_le(address) / 0x10000;
end

function mainmemory.write_s1616_le(address, value) -- Signed fixed point 16.16 little endian
	return mainmemory.write_u32_le(address, value * 0x10000);
end

local Game = {
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 },
	speedy_index = 7,
	rot_speed = 100,
	max_rot_units = 65535,
	squish_memory_table = true,
	Memory = { -- Version order: US, Europe
		player_pointer = {0x236238, 0},
		x_velocity = {0xA7C, 0}, -- s16.16le, relative to player
		z_velocity = {0xA84, 0}, -- s16.16le, relative to player
		x_position = {0x6C, 0}, -- s16.16le, relative to player
		y_position = {0x70, 0}, -- s16.16le, relative to player
		z_position = {0x74, 0}, -- s16.16le, relative to player
	},
};

function Game.getPlayer()
	return dereferencePointer(Game.Memory.player_pointer);
end

function Game.getXPosition()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.x_position);
	end
	return 0;
end

function Game.getYPosition()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.y_position);
	end
	return 0;
end

function Game.getZPosition()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.z_position);
	end
	return 0;
end

function Game.setXPosition(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s1616_le(player + Game.Memory.x_position, value);
	end
end

function Game.setYPosition(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s1616_le(player + Game.Memory.y_position, value);
	end
end

function Game.setZPosition(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s1616_le(player + Game.Memory.z_position, value);
	end
end

function Game.getXVelocity()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.x_velocity);
	end
	return 0;
end

function Game.setXVelocity(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s1616_le(player + Game.Memory.x_velocity, value);
	end
end

function Game.getZVelocity()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.z_velocity);
	end
	return 0;
end

function Game.setZVelocity(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s1616_le(player + Game.Memory.z_velocity, value);
	end
end

function Game.getVelocity()
	return math.abs(Game.getXVelocity()) + math.abs(Game.getZVelocity());
end

Game.OSD = {
	{"Player", hexifyOSD(Game.getPlayer, 6)},
	{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"X Velocity", Game.getXVelocity, category="position"},
	{"Z Velocity", Game.getZVelocity, category="position"},
	{"Separator"},
	{"Velocity", Game.getVelocity, category="position"},
	{"Separator"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
};

return Game;
