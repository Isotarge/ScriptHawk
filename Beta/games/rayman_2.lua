local Game = {};

local x_pos = 0x1C6B34;
local y_pos = 0x1C6B3C;
local z_pos = 0x1C6B38;

local x_rot = 0x1C69BC; -- TODO
local y_rot = 0; -- TODO
local z_rot = 0x1C69C0; -- TODO

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

Game.speedy_speeds = { .001, .01, .1, 1 };
Game.speedy_index = 4;

Game.rot_speed = 0.05;
Game.max_rot_units = 2.0;

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
	return mainmemory.readfloat(x_rot, true) + 1;
end

function Game.getYRotation()
	return mainmemory.readfloat(y_rot, true) + 1;
end

function Game.getZRotation()
	return mainmemory.readfloat(z_rot, true) + 1;
end

function Game.setXRotation(value)
	mainmemory.writefloat(x_rot, value - 1, true);
end

function Game.setYRotation(value)
	mainmemory.writefloat(y_rot, value - 1, true);
end

function Game.setZRotation(value)
	mainmemory.writefloat(z_rot, value - 1, true);
end

------------
-- Events --
------------

function Game.setMap(value)
	
end

function Game.eachFrame()
	
end

return Game;