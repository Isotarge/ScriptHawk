if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = { -- Version order: Europe N64, USA N64
		health = {0x1BC54D, 0x1BC64D}, -- Byte
		x_pos = {0x1C6A34, 0x1C6B34}, -- Float, ordered X, Z, Y in memory
		y_pos = {0x1C6A3C, 0x1C6B3C}, -- Float
		z_pos = {0x1C6A38, 0x1C6B38}, -- Float
		x_velocity = {0x1C69F4, 0x1C6AF4}, -- Float, ordered X, Z, Y in memory
		y_velocity = {0x1C69FC, 0x1C6AFC}, -- Float
		z_velocity = {0x1C69F8, 0x1C6AF8}, -- Float
		rot_base = {0x1C68BC, 0x1C69BC},
	},
	speedy_speeds = { .001, .01, .1, 1 },
	speedy_index = 4,
	rot_speed = 0.05,
	max_rot_units = 360,
};

-- Relative to rot_base
local sine = 0x00; -- Float
local sine_mirror = 0x10; -- Float

local cosine = 0x04; -- Float
local cosine_inverse = 0x0C; -- Float

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	if emu.getsystemid() == "N64" then
		if romHash == "619AB27EA1645399439AD324566361D3E7FF020E" then -- Europe N64
			version = 1;
			return true;
		elseif romHash == "50558356B059AD3FBAF5FE95380512B9DCEAAF52" then -- USA N64
			version = 2;
			return true;
		end
	end
	return false;
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.health[version], 30); -- Set Health
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.x_pos[version], true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_pos[version], true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_pos[version], true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(Game.Memory.x_pos[version], value, true);
end

function Game.setYPosition(value)
	Game.setYVelocity(0);
	mainmemory.writefloat(Game.Memory.y_pos[version], value, true);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_pos[version], value, true);
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

function Game.getZVelocity()
	return mainmemory.readfloat(Game.Memory.z_velocity[version], true);
end

function Game.getVelocity()
	local vX = Game.getXVelocity();
	local vZ = Game.getZVelocity();
	return math.sqrt(vX*vX + vZ*vZ);
end

function Game.setXVelocity(value)
	mainmemory.writefloat(Game.Memory.x_velocity[version], value, true);
end

function Game.setYVelocity(value)
	mainmemory.writefloat(Game.Memory.y_velocity[version], value, true);
end

function Game.setZVelocity(value)
	mainmemory.writefloat(Game.Memory.z_velocity[version], value, true);
end

--------------
-- Rotation --
--------------

--[[
	Rotation is weird in this game
	There's 4 addresses associated
	Sine, cosine and their inverse
--]]

function Game.getYRotation()
	local currentSine = mainmemory.readfloat(Game.Memory.rot_base[version] + sine, true);
	local currentCosine = mainmemory.readfloat(Game.Memory.rot_base[version] + cosine, true);
	if currentSine > 0 then
		return math.deg(math.acos(currentCosine));
	end
	return 360 - math.deg(math.acos(currentCosine));
end

function Game.setYRotation(value)
	local sineValue = math.sin(math.rad(value));
	local cosineValue = math.cos(math.rad(value));

	-- Set the sine values
	mainmemory.writefloat(Game.Memory.rot_base[version] + sine, sineValue, true);
	mainmemory.writefloat(Game.Memory.rot_base[version] + sine_mirror, sineValue, true);

	-- Set the cosine values
	mainmemory.writefloat(Game.Memory.rot_base[version] + cosine, cosineValue, true);
	mainmemory.writefloat(Game.Memory.rot_base[version] + cosine_inverse, cosineValue * -1, true);
end

return Game;