local Game = {};

-- USA Defaults
local x_pos = 0x33b1ac;
local y_pos;
local z_pos;

local x_rot = 0x33b19c;
local y_rot;
local z_rot;

local map = 0x32DDF8;

Game.maps = {
	"Unknown 1",
	"Unknown 2",
	"Unknown 3",
	"Big Boo's Haunt",
	"Cool, Cool Mountain",
	"Inside Peach's Castle",
	"Hazy Maze Cave",
	"Shifting Sand Land",
	"Bob-omb Battlefield",
	"Snowman's Land",
	"Wet-Dry World",
	"Jolly Roger Bay",
	"Tiny-Huge Island",
	"Tick Tock Clock",
	"Rainbow Ride",
	"Outside the Castle",
	"Bowser in the Dark World",
	"Vanish Cap Under the Moat",
	"Bowser in the Fire Sea",
	"The Secret Aquarium",
	"Bowser in the Sky",
	"Lethal Lava Land",
	"Dire, Dire Docks",
	"Whomp's Fortress",
	"'The End' Picture",
	"Castle Courtyard",
	"The Princess's Secret Slide",
	"Cavern of the Metal Cap",
	"Tower of the Wing Cap",
	"Bowser in the Dark World Boss",
	"Wing Mario Over the Rainbow",
	"Unknown 32",
	"Bowser in the Fire Sea Boss",
	"Bowser in the Sky Boss",
	"Unknown 35",
	"Tall Tall Mountain",
	"Unknown 37",
	"Unknown 38"
};

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if bizstring.contains(romName, "Europe") then
		x_rot = 0x30945c;
		x_pos = 0x30946c;
		map = 0x2F9FC8;
	elseif bizstring.contains(romName, "Japan") and not bizstring.contains(romName, "Shindou Edition") then
		x_rot = 0x339e2c;
		x_pos = 0x339e3c;
		map = 0x32CE98;
	elseif bizstring.contains(romName, "Japan") and bizstring.contains(romName, "Shindou Edition") then
		x_rot = 0x31d9ec;
		x_pos = 0x31d9fc;
		map = 0x30D528;
	end
	y_pos = x_pos + 4;
	z_pos = y_pos + 4;
	y_rot = x_rot;
	z_rot = x_rot;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_index = 7;

Game.rot_speed = 100;
Game.max_rot_units = 65536;

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
	return mainmemory.read_u32_be(x_rot);
end

function Game.getYRotation()
	return mainmemory.read_u32_be(y_rot);
end

function Game.getZRotation()
	return mainmemory.read_u32_be(z_rot);
end

function Game.setXRotation(value)
	return mainmemory.write_u32_be(x_rot, value);
end

function Game.setYRotation(value)
	return mainmemory.write_u32_be(y_rot, value);
end

function Game.setZRotation(value)
	return mainmemory.write_u32_be(z_rot, value);
end

------------
-- Events --
------------

function Game.setMap(value)
	if value >= 1 and value <= #Game.maps then
		mainmemory.write_u16_be(map, value);
	end
end

function Game.initUI(form_handle, col, row, button_height)
	
end

function Game.eachFrame()
	
end

return Game;