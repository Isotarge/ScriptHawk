local Game = {};

local elmo_pointer;

-- Relative to elmo object
-- TODO: Move to object model table
local x_pos = 0x24;
local y_pos = x_pos + 4;
local z_pos = y_pos + 4;

local facing_angle = 0x1B8;

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	if emu.getsystemid() == "N64" then
		if romHash == "7195EA96D9FE5DE065AF61F70D55C92C8EE905E6" then -- Number Journey, N64, USA
			elmo_pointer = 0x106C84;
			return true;
		end

		if romHash == "97777CA06F4E8AFF8F1E95033CC8D3833BE40F76" then -- Letter Adventure, N64, USA
			elmo_pointer = 0x106888;
			return true;
		end
	end

	return false;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_index = 7;

Game.rot_speed = 0.1;
Game.max_rot_units = 2;

--------------
-- Position --
--------------

function Game.getXPosition()
	local elmoObject = dereferencePointer(elmo_pointer);
	if isRDRAM(elmoObject) then
		return mainmemory.readfloat(elmoObject + x_pos, true);
	end
	return 0;
end

function Game.getYPosition()
	local elmoObject = dereferencePointer(elmo_pointer);
	if isRDRAM(elmoObject) then
		return mainmemory.readfloat(elmoObject + y_pos, true);
	end
	return 0;
end

function Game.getZPosition()
	local elmoObject = dereferencePointer(elmo_pointer);
	if isRDRAM(elmoObject) then
		return mainmemory.readfloat(elmoObject + z_pos, true);
	end
	return 0;
end

function Game.setXPosition(value)
	local elmoObject = dereferencePointer(elmo_pointer);
	if isRDRAM(elmoObject) then
		mainmemory.writefloat(elmoObject + x_pos, value, true);
	end
end

function Game.setYPosition(value)
	local elmoObject = dereferencePointer(elmo_pointer);
	if isRDRAM(elmoObject) then
		mainmemory.writefloat(elmoObject + y_pos, value, true);
	end
end

function Game.setZPosition(value)
	local elmoObject = dereferencePointer(elmo_pointer);
	if isRDRAM(elmoObject) then
		mainmemory.writefloat(elmoObject + z_pos, value, true);
	end
end

--------------
-- Rotation --
--------------

function Game.getYRotation()
	local elmoObject = dereferencePointer(elmo_pointer);
	if isRDRAM(elmoObject) then
		return mainmemory.readfloat(elmoObject + facing_angle, true) + 1;
	end
	return 0;
end

function Game.setYRotation(value)
	local elmoObject = dereferencePointer(elmo_pointer);
	if isRDRAM(elmoObject) then
		return mainmemory.writefloat(elmoObject + facing_angle, value - 1, true);
	end
end

return Game;