if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		["lives"] = 0x100, -- s8
		["p_meter"] = 0x106, -- u8?
		["viewport_x_position"] = 0x120, -- u16_le
		["viewport_y_position"] = 0x122, -- u16_le
		["taz_x_position"] = 0x150, -- s16_le
		["taz_y_position"] = 0x152, -- s16_le
		["velocity_aerial"] = 0x110, -- s8
		["velocity_ground"] = 0x111, -- s8
		["jump_height"] = 0x141, -- u8
	},
	speedy_speeds = {0},
	speedy_index = 1,
	rot_speed = 0,
	max_rot_units = 0,
};

function Game.detectVersion(romName, romHash)
	return true;
end

function Game.getXPosition()
	local viewportX = mainmemory.read_u16_le(Game.Memory.viewport_x_position);
	local tazX = mainmemory.read_s16_le(Game.Memory.taz_x_position);
	--return viewportX + tazX;
	return viewportX;
end

function Game.getYPosition()
	local viewportY = mainmemory.read_u16_le(Game.Memory.viewport_y_position);
	local tazY = mainmemory.read_s16_le(Game.Memory.taz_y_position);
	--return viewportY + tazY;
	return viewportY;
end

function Game.getZPosition()
	return 0;
end

function Game.setXPosition()
	return; -- TODO
end

function Game.setYPosition()
	return; -- TODO
end

function Game.setZPosition()
	return;
end

function Game.getJumpHeight()
	return mainmemory.read_u8(Game.Memory.jump_height);
end

function Game.colorJumpHeight()
	if Game.getJumpHeight() ~= 0 then
		return 0xFF00FF00; -- Green
	end
end

function Game.getPMeter()
	return mainmemory.read_u8(Game.Memory.p_meter);
end

function Game.getGroundVelocity()
	return mainmemory.read_s8(Game.Memory.velocity_ground);
end

function Game.getAerialVelocity()
	return mainmemory.read_s8(Game.Memory.velocity_aerial);
end

function Game.colorDX()
	local dX = ScriptHawk.getDX();
	if dX == 0 then
		return 0xFFFF0000; -- Red
	end
end

Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"dX", nil, Game.colorDX},
	{"dY"},
	{"Separator", 1},
	{"P Meter", Game.getPMeter},
	{"Velocity (Gnd)", Game.getGroundVelocity},
	{"Velocity (Air)", Game.getAerialVelocity},
	{"Jump", Game.getJumpHeight, Game.colorJumpHeight},
};

Game.OSDPosition = {114, 208};

return Game;