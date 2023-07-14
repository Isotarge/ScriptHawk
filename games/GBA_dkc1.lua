if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
        pos_ptr = {Domain = "IWRAM", Address = 0xE18},
	},
};

local script_modes = {
	"Disabled",
};

local script_mode_index = 1;
local script_mode = script_modes[script_mode_index];

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

--------------
-- Position --
--------------

function Game.getXPosition()
	local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address, posInfo.Domain);
	end
	return 0;
end

function Game.getYPosition()
	local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x04, posInfo.Domain);
	end
	return 0;
end

function Game.colorYVelocity()
	local yVelocity = Game.getYVelocity();
	if yVelocity > 0 then
		return colors.red;
	end
end

function Game.setXPosition()
	local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
		return memory.write_s32_le(posInfo.Address, posInfo.Domain);
	end
	return 0;
end

function Game.setYPosition()
	local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
		return memory.write_s32_le(posInfo.Address + 0x04, posInfo.Domain);
	end
	return 0;
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
    local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
        posInfo.Address = posInfo.Address + 0x98;
		local speedInfo = dereferencePointer(posInfo);
        if speedInfo ~= nil then
            return memory.read_s32_le(speedInfo.Address + 0x18, speedInfo.Domain);
        end
	end
	return 0;
end

function Game.getYVelocity()
    local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
        posInfo.Address = posInfo.Address + 0x98;
		local speedInfo = dereferencePointer(posInfo);
        if speedInfo ~= nil then
            return memory.read_s32_le(speedInfo.Address + 0x1C, speedInfo.Domain);
        end
	end
	return 0;
end

function Game.setXVelocity()
    local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
        posInfo.Address = posInfo.Address + 0x98;
		local speedInfo = dereferencePointer(posInfo);
        if speedInfo ~= nil then
            return memory.write_s32_le(speedInfo.Address + 0x18, speedInfo.Domain);
        end
	end
	return 0;
end

function Game.setYVelocity()
    local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
        posInfo.Address = posInfo.Address + 0x98;
		local speedInfo = dereferencePointer(posInfo);
        if speedInfo ~= nil then
            return memory.write_s32_le(speedInfo.Address + 0x1C, speedInfo.Domain);
        end
	end
	return 0;
end



Game.OSD = {
	{"X", category="position"},
	{"Y", category="position"},
	{"Separator"},
	{"X Vel", Game.getXVelocity, category="speed"},
	{"Y Vel", Game.getYVelocity, Game.colorYVelocity, category="speed"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"},
};

return Game;