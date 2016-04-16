local Game = {};

local elmo_pointer;

-- Relative to elmo object
local x_pos = 0x24;
local y_pos = x_pos + 4;
local z_pos = y_pos + 4;

local facing_angle = 0x1b8;

Game.maps = { "Not Implemented" };

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if emu.getsystemid() == "N64" then
		if stringContains(romName, "Number Journey") and stringContains(romName, "USA") then
			elmo_pointer = 0x106C84;
			return true;
		end

		if stringContains(romName, "Letter Adventure") and stringContains(romName, "USA") then
			elmo_pointer = 0x106888;
			return true;
		end
	end

	return false;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_index = 7;

Game.rot_speed = 0.1;
Game.max_rot_units = 2;

--------------
-- Position --
--------------

function Game.getXPosition()
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	return mainmemory.readfloat(elmo_object + x_pos, true);
end

function Game.getYPosition()
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	return mainmemory.readfloat(elmo_object + y_pos, true);
end

function Game.getZPosition()
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	return mainmemory.readfloat(elmo_object + z_pos, true);
end

function Game.setXPosition(value)
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	mainmemory.writefloat(elmo_object + x_pos, value, true);
end

function Game.setYPosition(value)
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	mainmemory.writefloat(elmo_object + y_pos, value, true);
end

function Game.setZPosition(value)
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	mainmemory.writefloat(elmo_object + z_pos, value, true);
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	return mainmemory.readfloat(elmo_object + facing_angle, true) + 1;
end

function Game.getYRotation()
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	return mainmemory.readfloat(elmo_object + facing_angle, true) + 1;
end

function Game.getZRotation()
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	return mainmemory.readfloat(elmo_object + facing_angle, true) + 1;
end

function Game.setXRotation(value)
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	return mainmemory.writefloat(elmo_object + facing_angle, value - 1, true);
end

function Game.setYRotation(value)
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	return mainmemory.writefloat(elmo_object + facing_angle, value - 1, true);
end

function Game.setZRotation(value)
	local elmo_object = mainmemory.read_u24_be(elmo_pointer + 1);
	return mainmemory.writefloat(elmo_object + facing_angle, value - 1, true);
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