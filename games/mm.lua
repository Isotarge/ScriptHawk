local Game = {};

local x_pos;
local y_pos;
local z_pos;

local x_rot;
local facing_angle;
local y_rot;

Game.maps = { "Not Implemented" };

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if stringContains(romName, "Europe") or stringContains(romName, "(E)") then
		if stringContains(romName, "Rev A") then
			x_pos = 0x3F7614;
			facing_angle = 0x3F76AE;
		else
			x_pos = 0x3F7274;
			facing_angle = 0x3F730E;
		end
	elseif stringContains(romName, "Japan") then
		if stringContains(romName, "Rev A") then
			x_pos = 0x400284;
			facing_angle = 0x40031E;
		else
			x_pos = 0x3FFFC4;
			facing_angle = 0x40005E;
		end
	elseif stringContains(romName, "USA") then
		x_pos = 0x3FFDD4;
		facing_angle = 0x3FFE6E;
	else
		return false;
	end

	y_pos = x_pos + 4;
	z_pos = y_pos + 4;

	x_rot = facing_angle - 2;
	z_rot = facing_angle + 2;

	print("While ScriptHawk does have basic support for OOT/MM there are people who are much more dedicated to these games than I will ever be.");
	print("Check out the great work at the following GitHub repos for more comprehensive support:");
	print("https://github.com/notwa/mm/tree/master/Lua");
	print("https://github.com/RainingChain/Z64LuaHooks");

	return true;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { 1, 5, 10 };
Game.speedy_index = 2;

Game.rot_speed = 64;
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
	return mainmemory.read_u16_be(x_rot);
end

function Game.getYRotation()
	return mainmemory.read_u16_be(facing_angle);
end

function Game.getZRotation()
	return mainmemory.read_u16_be(z_rot);
end

function Game.setXRotation(value)
	mainmemory.write_u16_be(x_rot, value);
end

function Game.setYRotation(value)
	mainmemory.write_u16_be(facing_angle, value);
end

function Game.setZRotation(value)
	mainmemory.write_u16_be(z_rot, value);
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