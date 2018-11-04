if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 },
	speedy_index = 7,
	rot_speed = 100,
	max_rot_units = 65535,
	squish_memory_table = true,
	Memory = { -- Version order: N64 USA, N64 PAL
		cheat_base = {0x11648C, 0x118E84},
		number_of_cheats = {22, 24},
		velocity = {0x14A298, 0x170D70},
		x_position = {0x14A47C, 0x170F54},
		y_position = {0x14A480, 0x170F58},
		z_position = {0x14A484, 0x170F5C},
	},
};

function Game.unlockCheats()
	for i = 1, Game.Memory.number_of_cheats do
		mainmemory.writebyte(Game.Memory.cheat_base + i - 1, 0x01);
	end
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
	return mainmemory.writefloat(Game.Memory.x_position, value, true);
end

function Game.setYPosition(value)
	return mainmemory.writefloat(Game.Memory.y_position, value, true);
end

function Game.setZPosition(value)
	return mainmemory.writefloat(Game.Memory.z_position, value, true);
end

function Game.getVelocity()
	return mainmemory.readfloat(Game.Memory.velocity, true);
end

function Game.setVelocity(value)
	return mainmemory.writefloat(Game.Memory.velocity, value, true);
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.button(10, 0, {4, 10}, nil, nil, "Unlock Cheats", Game.unlockCheats);
	end
end

Game.OSD = {
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"Velocity", Game.getVelocity, category="speed"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
};

return Game;