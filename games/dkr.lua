local Game = {};

local player_object_pointer = 0x3FFFC0; -- TODO: Does this work for all versions?

local x_pos = 0x0C;
local y_pos = x_pos + 4;
local z_pos = y_pos + 4;

local velocity = 0xC0;

local x_rot = 0;
local facing_angle = 0;
local z_rot = 0;

Game.maps = { "Not Implemented" };

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if bizstring.contains(romName, "Europe") then
		-- TODO
	elseif bizstring.contains(romName, "Japan") then
		player_object_pointer = 0x3FFFC0;
	elseif bizstring.contains(romName, "USA") then
		-- TODO
	else
		return false;
	end

	return true;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_index = 7;

Game.rot_speed = 10;
Game.max_rot_units = 360;

function Game.isPhysicsFrame()
	return not emu.islagged();
end

--------------
-- Position --
--------------

function Game.getXPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.readfloat(player_object + x_pos, true);
end

function Game.getYPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.readfloat(player_object + y_pos, true);
end

function Game.getZPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.readfloat(player_object + z_pos, true);
end

function Game.setXPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	mainmemory.writefloat(player_object + x_pos, value, true);
end

function Game.setYPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	mainmemory.writefloat(player_object + y_pos, value, true);
end

function Game.setZPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	mainmemory.writefloat(player_object + z_pos, value, true);
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	-- TODO
	return 0;
end

function Game.getYRotation()
	-- TODO
	return 0;
end

function Game.getZRotation()
	-- TODO
	return 0;
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