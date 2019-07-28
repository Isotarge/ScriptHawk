if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
        pos_ptr = {Domain = "IWRAM", Address = 0x438},
        --pos_ptr = {Domain = "IWRAM", Address = 0x7A44},
		xPos = {Domain="IWRAM", Address=0x4B04},
        yPos = {Domain="IWRAM", Address=0x4B08},
		--object_array_size = {Domain="IWRAM", Address=0x16F8},
		--object_list_ptr = {Domain="IWRAM", Address=0x14A0},
		--rangCount = {Domain="IWRAM", Address=0xB06},
		--player_ptr = {Domain="EWRAM", Address={0x5B08}}, -- May be better?
	},
};

local script_modes = {
	"Disabled",
	--"List",
	--"Examine",
};

local script_mode_index = 1;
local script_mode = script_modes[script_mode_index];

--------------------
-- Region/Version --
--------------------

--local player_struct = {
--	[0xC] = {type="s32_le", name="XPosition"},
--	[0x10] = {type="s32_le", name="YPosition"},
--	[0x18] = {type="s32_le", name="XVelocity"},
--	[0x1C] = {type="s32_le", name="YVelocity"},
--	[0x74] = {type="u32_le", name="1st Glide"},
--};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

-------------------
-- Physics/Scale --
-------------------

--function Game.getPlayer()
--	return dereferencePointer(Game.Memory.player_ptr);
--end

-- local movementStates = {
--	[0x00] = "Idle",
--	[0x01] = "Run",
--	[0x02] = "Jump",
--	[0x03] = "Fall",
--	[0x04] = "Glide",
--	[0x05] = "Rang Throw",
--	[0x06] = "Damaged",
--	[0x07] = "Run Skid",
--	[0x09] = "Run Start",
--	[0x0A] = "Landing",
--	[0x0C] = "Bite",
--	[0x0D] = "Interacting",
--	[0x10] = "Fast Falling",
--	[0x11] = "Fall Damage",
--	[0x15] = "Platform Drop Through",
--	[0x17] = "Looking",
--	[0X19] = "Arial Bite",
--};

-- function Game.getState()
--	local player = Game.getPlayer();
--	if player ~= nil then
--		local currentMovementState = memory.read_u8(player.Address + 0x5D, player.Domain);
--		--local direction = memory.read_u8_le(player.Address + 0x16, player.Domain);
--		return movementStates[currentMovementState] or "Unknown ("..currentMovementState..")";
--	end
-- end

--------------
-- Position --
--------------

function Game.getXPosition()
    return memory.read_s32_le(Game.Memory.xPos.Address, Game.Memory.xPos.Domain);
end

function Game.getYPosition()
	return memory.read_s32_le(Game.Memory.yPos.Address, Game.Memory.yPos.Domain);
end

function Game.colorYVelocity()
	local yVelocity = Game.getYVelocity();
	if yVelocity > 0 then
		return colors.red;
	end
end

function Game.setXPosition(value)
    return memory.write_s32_le(Game.Memory.xPos.Address, value, Game.Memory.xPos.Domain);
end

function Game.setYPosition(value)
	return memory.write_s32_le(Game.Memory.yPos.Address, value, Game.Memory.yPos.Domain);
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x24, posInfo.Domain);
	end
	return 0;
end

function Game.getYVelocity()
	local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x28, posInfo.Domain);
	end
	return 0;
end

function Game.setXVelocity()
	local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
		return memory.write_s32_le(posInfo.Address + 0x24, value, posInfo.Domain);
	end
	return 0;
end

function Game.setYVelocity()
	local posInfo = dereferencePointer(Game.Memory.pos_ptr)
	if posInfo ~= nil then
		return memory.write_s32_le(posInfo.Address + 0x28, value, posInfo.Domain);
	end
	return 0;
end

------------
-- Events --
------------


Game.OSD = {
	--{"State", Game.getState, category="state"},
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