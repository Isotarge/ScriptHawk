local Game = {};

local x_pos;
local y_pos;
local z_pos;

local facing_angle;

Game.maps = { "Not Implemented" };

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if bizstring.contains(romName, "Europe") then
		-- TODO
		return false;
	elseif bizstring.contains(romName, "Japan") then
		-- TODO
		return false;
	elseif bizstring.contains(romName, "USA") then
		x_pos = 0x0bb070;
		y_pos = 0x0bb074;
		z_pos = 0x0bb078;

		facing_angle = 0x0bb0b8;
	else
		return false;
	end

	return true;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { -100, -1000, -2000, -5000, -7500, -10000, -20000, -50000, -100000 };
Game.speedy_index = 4;

Game.rot_speed = 10;
Game.max_rot_units = 4096;

function Game.isPhysicsFrame()
	return not emu.islagged();
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.read_s32_be(x_pos);
end

function Game.getYPosition()
	return mainmemory.read_s32_be(y_pos);
end

function Game.getZPosition()
	return mainmemory.read_s32_be(z_pos);
end

function Game.setXPosition(value)
	mainmemory.write_s32_be(x_pos, value);
end

function Game.setYPosition(value)
	mainmemory.write_s32_be(y_pos, value);
end

function Game.setZPosition(value)
	mainmemory.write_s32_be(z_pos, value);
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	return mainmemory.read_u16_be(facing_angle);
end

function Game.getYRotation()
	return mainmemory.read_u16_be(facing_angle);
end

function Game.getZRotation()
	return mainmemory.read_u16_be(facing_angle);
end

function Game.setXRotation(value)
	mainmemory.write_u16_be(facing_angle, value);
end

function Game.setYRotation(value)
	mainmemory.write_u16_be(facing_angle, value);
end

function Game.setZRotation(value)
	mainmemory.write_u16_be(facing_angle, value);
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