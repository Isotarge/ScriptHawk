local Game = {};

local x_pos;
local y_pos;
local z_pos;

local facing_angle;

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	if emu.getsystemid() == "N64" then
		if romHash == "A9F97E22391313095D2C2FBAF81FB33BFA2BA7C6" then -- France
			-- TODO
		elseif romHash == "92015E5254CBBAD1BC668ECB13A4B568E5F55052" then -- Europe
			-- TODO
		elseif romHash == "982AD2E1E44C6662C88A77367BC5DF91C51531BF" then -- USA
			x_pos = 0x0BB070;
			y_pos = 0x0BB074;
			z_pos = 0x0BB078;

			facing_angle = 0x0BB0B8;
			return true;
		elseif romHash == "EAE83C07E2E777D8E71A5BE6120AED03D7E67782" then -- German 1.1
			-- TODO
		elseif romHash == "F8FBB100227015BE8629243F53D70F29A2A14315" then -- German 1.0
			-- TODO
		end
	end
	return false;
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
	mainmemory.write_u16_be(facing_angle, value); -- TODO
end

function Game.setYRotation(value)
	mainmemory.write_u16_be(facing_angle, value);
end

function Game.setZRotation(value)
	mainmemory.write_u16_be(facing_angle, value); -- TODO
end

Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"dY"},
	{"dXZ"},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
	--{"Rot. X", Game.getXRotation}, -- TODO
	{"Facing", Game.getYRotation},
	--{"Rot. Z", Game.getZRotation}, -- TODO
};

return Game;