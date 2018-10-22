if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	squish_memory_table = true,
	Memory = {
		-- Version order:
			-- 1: Number Journey, N64, USA
			-- 2: Letter Adventure, N64, USA
		elmo_pointer = {0x106C84, 0x106888},
	},
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 },
	speedy_index = 7,
	rot_speed = 0.1,
	max_rot_units = 2,
};

local player_fields = {
	x_pos = 0x24,
	y_pos = 0x28,
	z_pos = 0x2C,
	facing_angle = 0x1B8,
};

--------------
-- Position --
--------------

function Game.getXPosition()
	local elmoObject = dereferencePointer(Game.Memory.elmo_pointer);
	if isRDRAM(elmoObject) then
		return mainmemory.readfloat(elmoObject + player_fields.x_pos, true);
	end
	return 0;
end

function Game.getYPosition()
	local elmoObject = dereferencePointer(Game.Memory.elmo_pointer);
	if isRDRAM(elmoObject) then
		return mainmemory.readfloat(elmoObject + player_fields.y_pos, true);
	end
	return 0;
end

function Game.getZPosition()
	local elmoObject = dereferencePointer(Game.Memory.elmo_pointer);
	if isRDRAM(elmoObject) then
		return mainmemory.readfloat(elmoObject + player_fields.z_pos, true);
	end
	return 0;
end

function Game.setXPosition(value)
	local elmoObject = dereferencePointer(Game.Memory.elmo_pointer);
	if isRDRAM(elmoObject) then
		mainmemory.writefloat(elmoObject + player_fields.x_pos, value, true);
	end
end

function Game.setYPosition(value)
	local elmoObject = dereferencePointer(Game.Memory.elmo_pointer);
	if isRDRAM(elmoObject) then
		mainmemory.writefloat(elmoObject + player_fields.y_pos, value, true);
	end
end

function Game.setZPosition(value)
	local elmoObject = dereferencePointer(Game.Memory.elmo_pointer);
	if isRDRAM(elmoObject) then
		mainmemory.writefloat(elmoObject + player_fields.z_pos, value, true);
	end
end

--------------
-- Rotation --
--------------

function Game.getYRotation()
	local elmoObject = dereferencePointer(Game.Memory.elmo_pointer);
	if isRDRAM(elmoObject) then
		return mainmemory.readfloat(elmoObject + player_fields.facing_angle, true) + 1;
	end
	return 0;
end

function Game.setYRotation(value)
	local elmoObject = dereferencePointer(Game.Memory.elmo_pointer);
	if isRDRAM(elmoObject) then
		return mainmemory.writefloat(elmoObject + player_fields.facing_angle, value - 1, true);
	end
end

return Game;