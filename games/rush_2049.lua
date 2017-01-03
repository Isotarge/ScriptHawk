local Game = {
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 },
	speedy_index = 7,
	rot_speed = 100,
	max_rot_units = 65535,
	Memory = { -- Version order: N64 USA, N64 PAL
		["velocity"] = {0x14A298, 0x170D70},
		["x_position"] = {0x14A47C, 0x170F54},
		["y_position"] = {0x14A480, 0x170F58},
		["z_position"] = {0x14A484, 0x170F5C},
	},
};

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	if romHash == "3F99351D7BB61656614BDB2AA1A90CFE55D1922C" then -- N64 USA
		version = 1;
	elseif romHash == "61373D4758ECA3FA831BEAC27B4D4C250845F80C" then -- N64 PAL
		version = 2;
	else
		return false;
	end

	return true;
end

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
	return mainmemory.writefloat(Game.Memory.x_position[version], value, true);
end

function Game.setYPosition(value)
	return mainmemory.writefloat(Game.Memory.y_position[version], value, true);
end

function Game.setZPosition(value)
	return mainmemory.writefloat(Game.Memory.z_position[version], value, true);
end

function Game.getVelocity()
	return mainmemory.readfloat(Game.Memory.velocity[version], true);
end

function Game.setVelocity(value)
	return mainmemory.writefloat(Game.Memory.velocity[version], value, true);
end

return Game;