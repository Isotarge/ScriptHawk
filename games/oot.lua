if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	speedy_speeds = { 1, 5, 10 },
	speedy_index = 2,
	rot_speed = 64,
	max_rot_units = 0xFFFF,
};

-- TODO: Game.Memory table
local x_pos;
local y_pos;
local z_pos;

local x_rot;
local facing_angle;
local z_rot;

--------------------
-- Region/Version --
--------------------

-- TODO: Sort out these versions
--["50BEBEDAD9E0F10746A52B07239E47FA6C284D03"] = {moduleName = "games.oot", friendlyName = "Legend of Zelda, The - Ocarina of Time - Master Quest (USA) (Debug Edition)"},
--["8B5D13AAC69BFBF989861CFDC50B1D840945FC1D"] = {moduleName = "games.oot", friendlyName = "Legend of Zelda, The - Ocarina of Time - Master Quest (USA) (GC)"},
--["DD14E143C4275861FE93EA79D0C02E36AE8C6C2F"] = {moduleName = "games.oot", friendlyName = "Zelda no Densetsu - Toki no Ocarina (Japan) (GC)"},

function Game.detectVersion(romName, romHash)
	if romHash == "CFBB98D392E4A9D39DA8285D10CBEF3974C2F012" then -- Europe 1.1
		x_pos = 0x1D8AD4;
		facing_angle = 0x1D8B66;
	--elseif string.contains(romName, "Master Quest") then -- TODO: uh, this was lumped in with PAL?
	--	x_pos = 0x1D9394;
	--	facing_angle = 0x1D9426;
	elseif romHash == "328A1F1BEBA30CE5E178F031662019EB32C5F3B5" then -- Europe 1.0
		x_pos = 0x1D8A94;
		facing_angle = 0x1D8B26;
	elseif romHash == "DBFC81F655187DC6FEFD93FA6798FACE770D579D" then -- Japan 1.1
		x_pos = 0x1DAC14;
		facing_angle = 0x1DACA6;
	elseif romHash == "FA5F5942B27480D60243C2D52C0E93E26B9E6B86" then -- Japan 1.2
		x_pos = 0x1DB314;
		facing_angle = 0x1DB3A6;
	elseif romHash == "C892BBDA3993E66BD0D56A10ECD30B1EE612210F" then -- Japan 1.0
		x_pos = 0x1DAA54;
		facing_angle = 0x1DAAE6;
	elseif romHash == "D3ECB253776CD847A5AA63D859D8C89A2F37B364" then -- USA 1.1
		x_pos = 0x1DAC14;
		facing_angle = 0x1DACA6;
	elseif romHash == "41B3BDC48D98C48529219919015A1AF22F5057C2" then -- USA 1.2
		x_pos = 0x1DB314;
		facing_angle = 0x1DB3A6;
	elseif romHash == "AD69C91157F6705E8AB06C79FE08AAD47BB57BA7" then -- USA 1.0
		x_pos = 0x1DAA54;
		facing_angle = 0x1DAAE6;
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