if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	speedy_speeds = { .001, .01, .1, .2, .3, .5, .75, 1, 5 },
	speedy_index = 5,
	speedy_invert_xz = true,
	max_rot_units = 360,
	Memory = {
		x_position = 0x1CFF64, -- Float
		y_position = 0x1CFF6C, -- Float
		z_position = 0x1CFF68, -- Float
		x_velocity = 0x1CFED4, -- Float
		y_velocity = 0x1CFEDC, -- Float
		z_velocity = 0x1CFED8, -- Float
		rot_sine = 0x1CFF34, -- TODO: This rotation stuff is kinda borked still, just copy pasted from the Rayman 2 module, figure it out properly
		--rot_sine_mirror = 0x1CFF38,
		rot_cosine = 0x1CFF44,
		--rot_cosine_inverse = 0x1CFF48,
	},
};

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.x_position, true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(Game.Memory.x_position, value, true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_position, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.y_position, value, true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_position, true);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_position, value, true);
end

function Game.getXVelocity()
	return mainmemory.readfloat(Game.Memory.x_velocity, true);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity, true);
end

function Game.getZVelocity()
	return mainmemory.readfloat(Game.Memory.z_velocity, true);
end

function Game.getVelocity() -- Calculated VXZ
	local vX = Game.getXVelocity();
	local vZ = Game.getZVelocity();
	return math.sqrt(vX*vX + vZ*vZ);
end

--------------
-- Rotation --
--------------

function Game.getYRotation()
	local currentSine = mainmemory.readfloat(Game.Memory.rot_sine, true);
	local currentCosine = mainmemory.readfloat(Game.Memory.rot_cosine, true);
	if currentSine > 0 then
		return math.deg(math.acos(currentCosine));
	end
	return 360 - math.deg(math.acos(currentCosine));
end

function Game.setYRotation(value)
	local sineValue = math.sin(math.rad(value));
	local cosineValue = math.cos(math.rad(value));

	-- Set the sine values
	mainmemory.writefloat(Game.Memory.rot_sine, sineValue, true);
	--mainmemory.writefloat(Game.Memory.rot_sine_mirror, sineValue, true);

	-- Set the cosine values
	mainmemory.writefloat(Game.Memory.rot_cosine, cosineValue, true);
	--mainmemory.writefloat(Game.Memory.rot_cosine_inverse, cosineValue * -1, true);
end

Game.OSD = {
	{"X"},
	{"Y"},
	{"Z"},
	{"Separator"},
	--{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	--{"Z Velocity", Game.getZVelocity},
	{"Velocity", Game.getVelocity},
	{"Separator"},
	{"dY"},
	{"dXZ"},
	{"Separator"},
	{"Facing", Game.getYRotation},
};

return Game;