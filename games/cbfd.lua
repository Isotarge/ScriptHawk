local Game = {};

--------------------
-- Region/Version --
--------------------

Game.Memory = { -- Version order: Europe, USA
	["x_position"] = {0x0CC704, 0x0CC2E4}, -- Float
	["y_position"] = {0x0CC708, 0x0CC2E8}, -- Float
	["z_position"] = {0x0CC70C, 0x0CC2EC}, -- Float
	["y_velocity"] = {0x0CC710, 0x0CC2F0}, -- Float
	["velocity"] = {0x0CC72C, 0x0CC30C}, -- Float
	["moving_angle"] = {0x0CC766, 0x0CC346}, -- u16_be
	["facing_angle"] = {0x0CC76A, 0x0CC34A}, -- u16_be
};

function Game.detectVersion(romName, romHash)
	if romHash == "EE7BC6656FD1E1D9FFB3D19ADD759F28B88DF710" then -- Europe
		version = 1;
		return true;
	elseif romHash == "4CBADD3C4E0729DEC46AF64AD018050EADA4F47A" then -- USA
		version = 2;
		return true;
	end

	return false;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100, 200 };
Game.speedy_index = 8;

function Game.isPhysicsFrame()
	return not emu.islagged(); -- TODO: Research lag in this game
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
end

function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.y_position[version], value, true);
	Game.setYVelocity(0);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_position[version], value, true);
end

function Game.getVelocity()
	return mainmemory.readfloat(Game.Memory.velocity[version], true);
end

function Game.setVelocity(value)
	return mainmemory.writefloat(Game.Memory.velocity[version], value, true);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity[version], true);
end

function Game.setYVelocity(value)
	return mainmemory.writefloat(Game.Memory.y_velocity[version], value, true);
end

--------------
-- Rotation --
--------------

Game.rot_speed = 16;
Game.max_rot_units = 0xFFFF;

function Game.getXRotation()
	return 0; -- TODO
end

function Game.getYRotation()
	return (mainmemory.read_u16_be(Game.Memory.moving_angle[version]) + Game.max_rot_units / 4) % Game.max_rot_units; -- TODO: Fix this for all modules with a dpad angle offset
end

function Game.getZRotation()
	return 0; -- TODO
end

function Game.setXRotation(value)
	-- TODO
end

function Game.setYRotation(value)
	mainmemory.write_u16_be(Game.Memory.moving_angle[version], (value - Game.max_rot_units / 4) % Game.max_rot_units);
end

function Game.setZRotation(value)
	-- TODO
end

------------
-- Events --
------------

Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"dY"},
	{"dXZ"},
	{"Velocity", Game.getVelocity};
	{"Y Velocity", Game.getYVelocity},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
	--{"Rot. X", Game.getXRotation},
	{"Moving", Game.getYRotation},
	--{"Rot. Z", Game.getZRotation},
};

return Game;