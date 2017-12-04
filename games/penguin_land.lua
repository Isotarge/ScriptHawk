if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		death_timer = 0x170,
		bird_spawn_timer = 0x181,
		igt_precise = 0x11C, -- u16_le
		igt_screen = 0x11D, -- byte
		lives = 0x119,
		round = 0x10B,
		movement_state = 0x113,
		x_position = 0x408, -- Byte
		y_position = 0x406, -- Byte
		x_velocity = 0x40F, -- s16_le
		y_velocity = 0x40D, -- s16_le
		egg_x_position = 0x448, -- Byte
		egg_y_position = 0x446, -- Byte
		egg_x_velocity = 0x44F, -- s16_le
		egg_y_velocity = 0x44D, -- s16_le
	},
	speedy_speeds = {0},
	speedy_index = 1,
	max_rot_units = 0,
};

function Game.detectVersion(romName, romHash)
	return true;
end

function Game.getLives()
	return mainmemory.readbyte(Game.Memory.lives);
end

function Game.getRound()
	return mainmemory.readbyte(Game.Memory.round);
end

function Game.getIGT()
	return mainmemory.read_u16_le(Game.Memory.igt_precise);
end

function Game.getXPosition()
	return mainmemory.readbyte(Game.Memory.x_position);
end

function Game.getYPosition()
	return mainmemory.readbyte(Game.Memory.y_position);
end

function Game.getXVelocity()
	return mainmemory.read_s16_le(Game.Memory.x_velocity) / 256;
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(Game.Memory.y_velocity) / 256;
end

function Game.getEggXPosition()
	return mainmemory.readbyte(Game.Memory.egg_x_position);
end

function Game.getEggYPosition()
	return mainmemory.readbyte(Game.Memory.egg_y_position);
end

function Game.getEggXVelocity()
	return mainmemory.read_s16_le(Game.Memory.egg_x_velocity) / 256;
end

function Game.getEggYVelocity()
	return mainmemory.read_s16_le(Game.Memory.egg_y_velocity) / 256;
end

Game.OSDPosition = {2, 70};
Game.OSD = {
	{"Round", Game.getRound},
	{"Lives", Game.getLives},
	{"IGT", Game.getIGT},
	{"Separator", 1},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"Separator", 1},
	{"Egg X", Game.getEggXPosition},
	{"Egg Y", Game.getEggYPosition},
	{"Egg X Velocity", Game.getEggXVelocity},
	{"Egg Y Velocity", Game.getEggYVelocity},
};

return Game;