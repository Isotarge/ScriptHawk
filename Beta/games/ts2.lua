local Game = {};

local x_pos = 0x0bb070;
local y_pos = 0x0bb074;
local z_pos = 0x0bb078;

local x_rot = 0x0bb0b8;
local y_rot = x_rot;
local z_rot = y_rot;

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
	return mainmemory.read_u16_be(x_rot);
end

function Game.getYRotation()
	return mainmemory.read_u16_be(y_rot);
end

function Game.getZRotation()
	return mainmemory.read_u16_be(z_rot);
end

function Game.setXRotation(value)
	mainmemory.write_u16_be(x_rot, value);
end

function Game.setYRotation(value)
	mainmemory.write_u16_be(y_rot, value);
end

function Game.setZRotation(value)
	mainmemory.write_u16_be(z_rot, value);
end

------------
-- Events --
------------

function Game.setMap(value)
	
end

function Game.eachFrame()
	
end

return Game;