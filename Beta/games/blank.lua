local Game = {};

local x_pos = 0;
local y_pos = 0;
local z_pos = 0;

local x_rot = 0;
local y_rot = 0;
local z_rot = 0;

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

Game.rot_speed = 10;
Game.max_rot_units = 360;

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
	return 0;
end

function Game.getYRotation()
	return 0;
end

function Game.getZRotation()
	return 0;
end

function Game.setXRotation(value)
	
end

function Game.setYRotation(value)
	
end

function Game.setZRotation(value)
	
end

------------
-- Events --
------------

function Game.setMap(value)
	
end

function Game.eachFrame()
	
end

return Game;