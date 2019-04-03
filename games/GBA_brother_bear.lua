if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
        p1_ptr = {Domain = "EWRAM", Address = 0xD554},
        p2_ptr = {Domain = "EWRAM", Address = 0xD558},
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

local function parsePointer(inPtr)
	if (inPtr >= 0x02000000) and (inPtr < 0x02040000) then
		return {
			Domain = "EWRAM",
			Address = inPtr - 0x02000000,
		};
	elseif (inPtr>= 0x03000000) and (inPtr < 0x03008000) then
		return {
			Domain = "IWRAM",
			Address = inPtr - 0x03000000,
		};
	end
end

function dereferencePointer(inPtr)
	return parsePointer(memory.read_u32_le(inPtr.Address, inPtr.Domain));
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

function Game.getXPos_P1()
	local posInfo = dereferencePointer(Game.Memory.p1_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x04, posInfo.Domain);
	end
	return 0
end

function Game.getYPos_P1()
	local posInfo = dereferencePointer(Game.Memory.p1_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x08, posInfo.Domain);
	end
	return 0
end

function Game.getXPos_P2()
	local posInfo = dereferencePointer(Game.Memory.p2_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x04, posInfo.Domain);
	end
	return 0
end

function Game.getYPos_P2()
	local posInfo = dereferencePointer(Game.Memory.p2_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x08, posInfo.Domain);
	end
	return 0
end

function Game.colorYVelocity(charIndex)
    if charIndex == nil then
        charIndex = 0;
    end
	local yVelocity = Game.getYVelocity(charIndex);
	if yVelocity > 0 then
		return colors.red;
	end
end


--------------
-- Velocity --
--------------

function Game.getXVel_P1()
	local posInfo = dereferencePointer(Game.Memory.p1_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x244, posInfo.Domain);
	end
	return 0;
end

function Game.getYVel_P1()
	local posInfo = dereferencePointer(Game.Memory.p1_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x254, posInfo.Domain);
	end
	return 0;
end

function Game.getXVel_P2()
	local posInfo = dereferencePointer(Game.Memory.p2_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x244, posInfo.Domain);
	end
	return 0;
end

function Game.getYVel_P2()
	local posInfo = dereferencePointer(Game.Memory.p2_ptr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x254, posInfo.Domain);
	end
	return 0;
end

------------
-- Events --
------------


Game.OSD = {
	--{"State", Game.getState, category="state"},
	{"B1 X", Game.getXPos_P1, category="position"},
	{"B1 Y", Game.getYPos_P1, category="position"},
	{"B1 X Vel", Game.getXVel_P1, category="speed"},
	{"B1 Y Vel", Game.getYVel_P1,  category="speed"},
	--{"B1 dY", category="positionStats"},
	--{"B1 dXZ", category="positionStats"},
	{"Separator"},
    {"B2 X", Game.getXPos_P2, category="position"},
	{"B2 Y", Game.getYPos_P2, category="position"},
	{"B2 X Vel", Game.getXVel_P2, category="speed"},
	{"B2 Y Vel", Game.getXVel_P2,  category="speed"},
    --{"B2 dY", category="positionStats"},
	--{"B2 dXZ", category="positionStats"},
	{"Separator"},
	--{"Max dY", category="positionStatsMore"},
	--{"Max dXZ", category="positionStatsMore"},
	--{"Odometer", category="positionStatsMore"},
	--{"Separator"},
};

return Game;