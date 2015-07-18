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
	if bizstring.contains(romName, "Europe") or bizstring.contains(romName, "(E)") then
		if bizstring.contains(romName, "Rev A") then
			-- TODO
		elseif bizstring.contains(romName, "Master Quest") then
			x_pos = 0x1D9394;
			facing_angle = 0x1D9426;
		else
			x_pos = 0x1D8A94;
			facing_angle = 0x1D8B26;
		end
	elseif bizstring.contains(romName, "Japan") then
		-- TODO
	elseif bizstring.contains(romName, "USA") then
		if bizstring.contains(romName, "Rev A") then
			-- TODO
		elseif bizstring.contains(romName, "Rev B") then
			x_pos = 0x1DB314;
			facing_angle = 0x1DB3A6;
		else
			-- TODO
		end
	end
	y_pos = x_pos + 4;
	z_pos = y_pos + 4;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, };
Game.speedy_index = 4;

Game.rot_speed = 10;
Game.max_rot_units = 0xffff;

function Game.isPhysicsFrame()
	return not emu.islagged();
end

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