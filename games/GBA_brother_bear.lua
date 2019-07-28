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

function Game.getXPosition(charIndex)
    if charIndex == nil then
        charIndex = 0;
    end
    local bearPtr = {Domain = Game.Memory.p1_ptr.Domain, Address = Game.Memory.p1_ptr.Address + 0x04*charIndex};
	local posInfo = dereferencePointer(bearPtr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x04, posInfo.Domain);
	end
	return toHexString(Game.Memory.p1_ptr.Address)
end

function Game.getYPosition(charIndex)
    if charIndex == nil then
        charIndex = 0;
    end
    local bearPtr = {Domain = Game.Memory.p1_ptr.Domain, Address = Game.Memory.p1_ptr.Address + 0x04*charIndex};
	local posInfo = dereferencePointer(bearPtr)
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

local bearState = {
	{ prev_position = {x = 0, y = 0}, d = {x = 0, y = 0} },
    { prev_position = {x = 0, y = 0}, d = {x = 0, y = 0} },
};

--------------
-- Velocity --
--------------

function Game.getdX(charIndex)
    if type(charIndex) ~= "number" or charIndex < 0 or charIndex > 1 then
		player = 0;
	end
	return bearState[charIndex + 1].d.x
end

function Game.getdY(charIndex)
    if type(charIndex) ~= "number" or charIndex < 0 or charIndex > 1 then
		player = 0;
	end
	return bearState[charIndex + 1].d.y
end

function Game.getXVelocity(charIndex)
    local bearPtr = {Domain = Game.Memory.p1_ptr.Domain, Address = Game.Memory.p1_ptr.Address + 0x04*charIndex};
	local posInfo = dereferencePointer(bearPtr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x244, posInfo.Domain);
	end
	return 0
end

function Game.getYVelocity(charIndex)
    local bearPtr = {Domain = Game.Memory.p1_ptr.Domain, Address = Game.Memory.p1_ptr.Address + 0x04*charIndex};
	local posInfo = dereferencePointer(bearPtr)
	if posInfo ~= nil then
		return memory.read_s32_le(posInfo.Address + 0x254, posInfo.Domain);
	end
	return 0
end

------------
-- Events --
------------
local player2OSD = {
		{"B2", "", category="player"},
		{"X", function() return Game.getXPosition(1) end, category="position"},
	    {"Y", function() return Game.getYPosition(1) end, category="position"},
	    {"X Vel", function() return Game.getXVelocity(1) end, category="speed"},
	    {"Y Vel", function() return Game.getXVelocity(1) end,  category="speed"},
        {"dX", function() return Game.getdX(1) end, category="speed"},
	    {"dY", function() return Game.getdY(1) end,  category="speed"},
        {"Separator"},
};

local function buildOSD()
	local OSD = {
        {"B1", "", category="player"},
		{"X", function() return Game.getXPosition(0) end, category="position"},
	    {"Y", function() return Game.getYPosition(0) end, category="position"},
	    {"X Vel", function() return Game.getXVelocity(0) end, category="speed"},
	    {"Y Vel", function() return Game.getXVelocity(0) end,  category="speed"},
        {"dX", function() return Game.getdX(0) end, category="speed"},
	    {"dY", function() return Game.getdY(0) end,  category="speed"},
        {"Separator"},
	};

    local bearPtr = {Domain = Game.Memory.p1_ptr.Domain, Address = Game.Memory.p1_ptr.Address + 0x04};
    if dereferencePointer(bearPtr) ~= nil then
        OSD = table.join(OSD, player2OSD);
    end

	return OSD;
end

-- Used to dynamically update OSD based on which players are in the battle
local currentOSDBools = false;
Game.OSD = buildOSD();

function Game.eachFrame()
	-- Dynamically update OSD based on which players are in the battle
	local OSDBools = false;
	local changeDetected = false;
    local bearPtr = {Domain = Game.Memory.p1_ptr.Domain, Address = Game.Memory.p1_ptr.Address + 0x04};
    if dereferencePointer(bearPtr) ~= nil then
        OSDBools = true;
    end
    if OSDBools ~= currentOSDBools then
        changeDetected = true;
    end
    for i = 1,2 do
        local bearX = Game.getXPosition(i-1);
        local bearY = Game.getYPosition(i-1);
        bearState[i].d.x = bearX - bearState[i].prev_position.x;
        bearState[i].d.y = bearY - bearState[i].prev_position.y;
        bearState[i].prev_position.x = bearX;
        bearState[i].prev_position.y = bearY;
	end
    if changeDetected then
        Game.OSD = buildOSD();
        currentOSDBools = OSDBools;
	end
end

return Game;