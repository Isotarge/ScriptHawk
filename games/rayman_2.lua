local Game = {};

local x_pos;
local y_pos;
local z_pos;

local rot_base;

local sine = 0x00;
local sine_mirror = 0x10;

local cosine = 0x04;
local cosine_inverse = 0x0C;

Game.maps = { "Not Implemented" };

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if stringContains(romName, "Europe") then
		-- TODO
		return false;
	elseif stringContains(romName, "Japan") then
		-- TODO
		return false;
	elseif stringContains(romName, "USA") then
		-- TODO: Get this working on every map
		x_pos = 0x1C6B34;
		rot_base = 0x1C69BC;
	else
		return false;
	end

	z_pos = x_pos + 4; -- Ordered X, Z, Y in memory
	y_pos = z_pos + 4;

	return true;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1 };
Game.speedy_index = 4;

Game.rot_speed = 0.05;
Game.max_rot_units = 360;

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(x_pos, true);
end

function Game.getYPosition()
	return mainmemory.readfloat(y_pos, true);
end

function Game.getZPosition()
	return mainmemory.readfloat(z_pos, true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(x_pos, value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(y_pos, value, true);
end

function Game.setZPosition(value)
	mainmemory.writefloat(z_pos, value, true);
end

--------------
-- Rotation --
--------------

--[[
	Rotation is weird in this game
	There's 4 addresses associated
	Sine, cosine and their inverse
]]--

function Game.getXRotation()
	--return mainmemory.readfloat(x_rot, true) + 1;
	return 0;
end

function Game.getYRotation()
	local currentSine = mainmemory.readfloat(rot_base + sine, true);
	local currentCosine = mainmemory.readfloat(rot_base + cosine, true);
	if currentSine > 0 then
		return math.deg(math.acos(currentCosine));
	end
	return 360 - math.deg(math.acos(currentCosine));
end

function Game.getZRotation()
	--return mainmemory.readfloat(z_rot, true) + 1;
	return 0;
end

function Game.setXRotation(value)
	--mainmemory.writefloat(x_rot, value - 1, true);
end

function Game.setYRotation(value)
	local sineValue = math.sin(math.rad(value));
	local cosineValue = math.cos(math.rad(value));

	-- Set the sine values
	mainmemory.writefloat(rot_base + sine, sineValue, true);
	mainmemory.writefloat(rot_base + sine_mirror, sineValue, true);

	-- Set the cosine values
	mainmemory.writefloat(rot_base + cosine, cosineValue, true);
	mainmemory.writefloat(rot_base + cosine_inverse, cosineValue * -1, true);
end

function Game.setZRotation(value)
	--mainmemory.writefloat(z_rot, value - 1, true);
end

------------
-- Events --
------------

function Game.setMap(value)
	-- TODO
end

function Game.initUI()
	-- TODO
end

function Game.eachFrame()
	-- TODO
end

return Game;