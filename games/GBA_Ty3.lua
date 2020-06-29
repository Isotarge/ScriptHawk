if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		player_ptr = {Domain="IWRAM", Address=0x17A4},
		--object_array_size = {Domain="IWRAM", Address=0x16F8},
		--object_list_ptr = {Domain="IWRAM", Address=0x14A0},
		--rangCount = {Domain="IWRAM", Address=0xB06},
		--player_ptr = {Domain="EWRAM", Address={0x5B08}}, -- May be better?
	},
};

local script_modes = {
	"Disabled",
--	"List",
--	"Examine",
};

local script_mode_index = 1;
local script_mode = script_modes[script_mode_index];

--------------------
-- Region/Version --
--------------------

local player_struct = {
	[0xC] = {type="s32_le", name="XPosition"},
	[0x10] = {type="s32_le", name="YPosition"},
	[0x20] = {type="s32_le", name="XVelocity"},
	[0x24] = {type="s32_le", name="YVelocity"},
	[0x71] = {type="u8_le", name="State"},
	--[0x74] = {type="u32_le", name="1st Glide"},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

-------------------
-- Physics/Scale --
-------------------

function Game.getPlayer()
	return dereferencePointer(Game.Memory.player_ptr);
end

local movementStates = {
	[0x00] = "Idle",
	[0x01] = "Run",
	[0x02] = "Jump",
	[0x03] = "Fall",
	[0x04] = "Glide",
	[0x05] = "Rang Throw",
	[0x06] = "Damaged",
	[0x07] = "Run Skid",
	[0x08] = "Run Start",
	[0x09] = "Run Accel",
	[0x0A] = "Landing",
	[0x0C] = "Bite",
	[0x0D] = "Interacting",
	[0x10] = "Fast Falling",
	[0x11] = "Fall Damage",
	[0x15] = "Platform Drop Through",
	[0x17] = "Looking",
	[0X19] = "Arial Bite",
};

function Game.getState()
	local player = Game.getPlayer();
	if player ~= nil then
		local currentMovementState = memory.read_u8(player.Address + 0x71, player.Domain);
--		--local direction = memory.read_u8_le(player.Address + 0x16, player.Domain);
		return movementStates[currentMovementState] or "Unknown ("..currentMovementState..")";
	end
end

function Game.getRangCount()
	local player = Game.getPlayer();
	if player ~= nil then
		local rang_bit = memory.read_u16_le(player.Address + 0x122, player.Domain);
		local rang_cnt = bit.band(rang_bit, 0x0001) + bit.band(bit.rshift(rang_bit,1), 0x0001);
		return rang_cnt;
	end
	return 0;
end

function Game.colorRangCount()
	local rangs = Game.getRangCount();
	if rangs == 0 then
		return colors.red;
	elseif rangs == 2 then
		return colors.green;
	end
end

function Game.getGlideFlag()
	local player = Game.getPlayer();
	if player ~= nil then
		local glideFlag = memory.read_u8(player.Address + 0x157, player.Domain);
		return glideFlag ~= 0;
	end
end

function Game.colorGlideFlag()
	local glideFlag = Game.getGlideFlag();
	if glideFlag == true and Game.getRangCount() == 2 then
		return colors.green;
	end
end

--------------
-- Position --
--------------

function Game.getXPosition()
	local player = Game.getPlayer();
	if player ~= nil then
		return memory.read_s32_le(player.Address + 0x0C, player.Domain);
	end
	return 0
end

function Game.getYPosition()
	local player = Game.getPlayer();
	if player ~= nil then
		return -memory.read_s32_le(player.Address + 0x10, player.Domain);
	end
	return 0;
end


function Game.setXPosition(value)
	local player = Game.getPlayer();
	if player ~= nil then
		memory.write_s32_le(player.Address + 0x0C, value, player.Domain);
	end
end

function Game.setYPosition(value)
	local player = Game.getPlayer();
	if player ~= nil then
		memory.write_s32_le(player.Address + 0x10, value, player.Domain);
	end
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	local player = Game.getPlayer();
	if player ~= nil then
		return memory.read_s32_le(player.Address + 0x20, player.Domain);
	end
	return 0;
end

function Game.getYVelocity()
	local player = Game.getPlayer();
	if player ~= nil then
		return memory.read_s32_le(player.Address + 0x24, player.Domain);
	end
	return 0;
end

function Game.colorYVelocity()
	local yVelocity = Game.getYVelocity();
	if yVelocity < 0 then
		return colors.red;
	end
end

------------
-- Events --
------------

local function toggleObjectAnalysisToolsMode()
	script_mode_index = script_mode_index + 1;
	if script_mode_index > #script_modes then
		script_mode_index = 1;
	end
	script_mode = script_modes[script_mode_index];
end


Game.OSD = {
	{"State", Game.getState, category="state"},
	{"Rang #", Game.getRangCount, Game.colorRangCount, category="boomerang"},
	{"SuperJump", Game.getGlideFlag, Game.colorGlideFlag, category="superjump"},
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