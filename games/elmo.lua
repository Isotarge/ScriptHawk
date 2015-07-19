local Game = {};

local elmo_pointer = 0x106888;

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
	if bizstring.contains(romName, "Europe") then
		-- TODO
	elseif bizstring.contains(romName, "Japan") then
		-- TODO
	elseif bizstring.contains(romName, "USA") then
		-- TODO
	end
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_index = 7;

Game.rot_speed = 0.1;
Game.max_rot_units = 2;

function Game.isPhysicsFrame()
	return not emu.islagged();
end

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
	-- TODO
end

function Game.setYRotation(value)
	-- TODO
end

function Game.setZRotation(value)
	-- TODO
end

------------
-- Events --
------------

function Game.setMap(value)
	-- TODO
end

function Game.applyInfinites()
	-- TODO
end

function Game.initUI(form_handle, col, row, button_height, label_offset, dropdown_offset)
	-- TODO
end

function Game.eachFrame()
	-- TODO
end

return Game;