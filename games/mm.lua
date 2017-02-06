if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {};

-- TODO: Game.Memory table
local x_pos;
local y_pos;
local z_pos;

local x_rot;
local facing_angle;
local y_rot;

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	if romHash == "BB4E4757D10727C7584C59C1F2E5F44196E9C293" then -- Europe 1.1
		x_pos = 0x3F7614;
		facing_angle = 0x3F76AE;
	elseif romHash == "C04599CDAFEE1C84A7AF9A71DF68F139179ADA84" then -- Europe 1.0
		x_pos = 0x3F7274;
		facing_angle = 0x3F730E;
	elseif romHash == "B38B71D2961DFFB523020A67F4807A4B704E347A" then -- Europe Beta
		return false; -- TODO
	elseif romHash == "41FDB879AB422EC158B4EAFEA69087F255EA8589" then -- Japan 1.1
		x_pos = 0x400284;
		facing_angle = 0x40031E;
	elseif romHash == "5FB2301AACBF85278AF30DCA3E4194AD48599E36" then -- Japan 1.0
		x_pos = 0x3FFFC4;
		facing_angle = 0x40005E;
	elseif romHash == "D6133ACE5AFAA0882CF214CF88DABA39E266C078" then -- USA 1.0
		x_pos = 0x3FFDD4;
		facing_angle = 0x3FFE6E;
	elseif romHash == "2F0744F2422B0421697A74B305CB1EF27041AB11" then -- USA Demo
		return false; -- TODO
	else
		return false;
	end

	y_pos = x_pos + 4;
	z_pos = y_pos + 4;

	x_rot = facing_angle - 2;
	z_rot = facing_angle + 2;

	dprint("While ScriptHawk does have basic support for OOT/MM there are people who are much more dedicated to these games than I will ever be.");
	dprint("Check out the great work at the following GitHub repos for more comprehensive support:");
	dprint("https://github.com/notwa/mm/tree/master/Lua");
	dprint("https://github.com/RainingChain/Z64LuaHooks");
	dprint("https://github.com/mattpilla/Majora-s-Mask-Lua-Scripts");
	dprint("https://github.com/glankk/gz");
	print_deferred();

	return true;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { 1, 5, 10 };
Game.speedy_index = 2;

Game.rot_speed = 64;
Game.max_rot_units = 0xFFFF;

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

return Game;