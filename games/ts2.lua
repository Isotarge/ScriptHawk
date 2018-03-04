if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = { -- Version order: France, Europe, USA, German 1.1, German 1.0
		global_timer = {0x0A3A00, 0x0A3360, 0x0A3040, 0x0A3A20, 0x0A3A00}, -- u32_be
		x_position = {0x0BBB40, 0x0BB460, 0x0BB070, 0x0BBB60, 0x0BBB40}, -- s32_be
		y_position = {0x0BBB44, 0x0BB464, 0x0BB074, 0x0BBB64, 0x0BBB44}, -- s32_be
		z_position = {0x0BBB48, 0x0BB468, 0x0BB078, 0x0BBB68, 0x0BBB48}, -- s32_be
		facing_angle = {0x0BBB88, 0x0BB4A8, 0x0BB0B8, 0x0BBBA8, 0x0BBB88}, -- u16_be
	};
};

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	if emu.getsystemid() == "N64" then
		if romHash == "A9F97E22391313095D2C2FBAF81FB33BFA2BA7C6" then -- France
			version = 1;
		elseif romHash == "92015E5254CBBAD1BC668ECB13A4B568E5F55052" then -- Europe
			version = 2;
		elseif romHash == "982AD2E1E44C6662C88A77367BC5DF91C51531BF" then -- USA
			version = 3;
		elseif romHash == "EAE83C07E2E777D8E71A5BE6120AED03D7E67782" then -- German 1.1
			version = 4;
		elseif romHash == "F8FBB100227015BE8629243F53D70F29A2A14315" then -- German 1.0
			version = 5;
		else
			return false;
		end
	else
		return false;
	end
	return true;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { 100, 1000, 2000, 5000, 7500, 10000, 20000, 50000, 100000 };
Game.speedy_index = 4;
Game.speedy_invert_LR = true;
Game.speedy_invert_Y = true;

Game.rot_speed = 10;
Game.max_rot_units = 4096;

local global_timer = {
	previous = -1,
	current = -1,
};

function Game.isPhysicsFrame()
	return global_timer.current ~= global_timer.previous;
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.read_s32_be(Game.Memory.x_position[version]);
end

function Game.getYPosition()
	return mainmemory.read_s32_be(Game.Memory.y_position[version]);
end

function Game.getZPosition()
	return mainmemory.read_s32_be(Game.Memory.z_position[version]);
end

function Game.setXPosition(value)
	mainmemory.write_s32_be(Game.Memory.x_position[version], value);
end

function Game.setYPosition(value)
	mainmemory.write_s32_be(Game.Memory.y_position[version], value);
end

function Game.setZPosition(value)
	mainmemory.write_s32_be(Game.Memory.z_position[version], value);
end

--------------
-- Rotation --
--------------

function Game.getYRotation()
	return mainmemory.read_u16_be(Game.Memory.facing_angle[version]);
end

function Game.setYRotation(value)
	mainmemory.write_u16_be(Game.Memory.facing_angle[version], value);
end

function Game.eachFrame()
	global_timer.previous = global_timer.current;
	global_timer.current = mainmemory.read_u32_be(Game.Memory.global_timer[version]);
end

Game.OSD = {
	{"X"},
	{"Y"},
	{"Z"},
	{"Separator"},
	{"dY"},
	{"dXZ"},
	{"Separator"},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator"},
	--{"Rot. X", Game.getXRotation}, -- TODO
	{"Facing", Game.getYRotation},
	--{"Rot. Z", Game.getZRotation}, -- TODO
};

return Game;