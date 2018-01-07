if type(ScriptHawk) ~= "table" then -- An error message to inform the user that this is a game module, not a standalone script
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {}; -- This table stores the module's API function implementations and game state, it's returned to ScriptHawk at the end of the module code

--------------------
-- Region/Version --
--------------------

Game.Memory = {
	["player_ptr"] = {["Domain"] = "EWRAM", ["Address"] = 0x47EC},
    --["player_ptr"] = {["Domain"] = "EWRAM", ["Address"] = {0x5B08}}, --may be better?
};

local player_struct = {
	[0xC] = {["Type"] = "s32_le", ["Name"] = "XPosition"},
    [0x10] = {["Type"] = "s32_le", ["Name"] = "YPosition"},
	[0x18] = {["Type"] = "s32_le", ["Name"] = "XVelocity"},
	[0x1C] = {["Type"] = "s32_le", ["Name"] = "YVelocity"},
};

function Game.detectVersion(romName, romHash) -- Modules should ideally use ROM hash rather than name, but both are passed in by ScriptHawk
	if string.contains(romName, "Europe") then -- string.contains is a pure Lua global function provided by ScriptHawk, intended to replace calls to bizstring.contains() for portability reasons
		version = 1; -- We use the version variable as an index for the Game.Memory table
	elseif string.contains(romName, "Japan") then
		version = 2;
	elseif string.contains(romName, "USA") then
		version = 3;
	else
		return false; -- Return false if this version of the game is not supported
	end

	return true; -- Return true if version detection is successful
end

function parsePointer(inPtr)
    local outPtr = {};
    if (inPtr>= 0x02000000) and (inPtr < 0x02040000) then
        outPtr["Domain"] = "EWRAM";
        outPtr["Address"] = inPtr - 0x02000000;
    elseif (inPtr>= 0x03000000) and (inPtr < 0x03008000) then
        outPtr["Domain"] = "IWRAM";
        outPtr["Address"] = inPtr - 0x03000000;
    else
        return false;
    end
    return outPtr
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 }; -- D-Pad speeds, scale these appropriately with your game's coordinate system
Game.speedy_index = 7;

function Game.isPhysicsFrame() -- Optional: If lag in your game is more complicated than a simple emu.islagged() call you should add the logic to detect it here
	-- Implementing this logic will result in smooth dY/dXZ calculation (no more flickering between 0 and the correct value)
	return not emu.islagged();
end

--------------
-- Position --
--------------

function Game.getXPosition()
    local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"])
	playerPtr = parsePointer(playerPtr)
    if playerPtr ~= false then
        return memory.read_s32_le(playerPtr["Address"]+0xC, playerPtr["Domain"]);
    end
    return 0
end

function Game.getYPosition()
    local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"])
	playerPtr = parsePointer(playerPtr)
    if playerPtr ~= false then
        return -memory.read_s32_le(playerPtr["Address"]+0x10, playerPtr["Domain"]);
    end
    return 0
end

function Game.colorYPosition()
	local yPosition = Game.getYPosition();
	if yPosition < 0 then
		-- Color Y position values less than 0 red
		-- Format 0xAARRGGBB
		return 0xFFFF0000;
		-- LibScriptHawk also provides some common colors in a colors table, for example:
		-- return colors.red;
	end
end

function Game.setXPosition(value) -- Optional
	--mainmemory.writefloat(Game.Memory.x_position[version], value, true);
end

function Game.setYPosition(value) -- Optional
	--mainmemory.writefloat(Game.Memory.y_position[version], value, true);
end

--------------
-- Velocity --
--------------
    function Game.getXVelocity()
        local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"])
        playerPtr = parsePointer(playerPtr)
        if playerPtr ~= false then
            return memory.read_s32_le(playerPtr["Address"]+0x18, playerPtr["Domain"]);
        end
    end

    function Game.getYVelocity()
        local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"])
        playerPtr = parsePointer(playerPtr)
        if playerPtr ~= false then
            return memory.read_s32_le(playerPtr["Address"]+0x1C, playerPtr["Domain"]);
        end
    end

--------------
-- Rotation --
--------------

Game.rot_speed = 10; -- Determines how big a single step is when the D-Pad is in Rotation mode
Game.max_rot_units = 360; -- Maximum value of the Game's native rotation units

-- Rotation units can be fiddly sometimes.
-- These functions can return any number as long as it's consistent between get & set.
-- If the Game.max_rot_units value is correct (and minimum is 0) ScriptHawk will correctly convert in game units to both degrees (default) and radians

function Game.getXRotation() -- Optional
	--return mainmemory.readfloat(Game.Memory.x_rotation[version], true);
end

function Game.getYRotation() -- Optional
	--return mainmemory.readfloat(Game.Memory.y_rotation[version], true);
end

function Game.getZRotation() -- Optional
	--return mainmemory.readfloat(Game.Memory.z_rotation[version], true);
end

function Game.setXRotation(value) -- Optional
	--mainmemory.writefloat(Game.Memory.x_rotation[version], value, true);
end

function Game.setYRotation(value) -- Optional
	--mainmemory.writefloat(Game.Memory.y_rotation[version], value, true);
end

function Game.setZRotation(value) -- Optional
	--mainmemory.writefloat(Game.Memory.z_rotation[version], value, true);
end

------------
-- Events --
------------

Game.maps = {
	"Map 1",
	"Map 2",
	"!Crash 3", -- Prefixing a map with '!' will hide it from the dropdown menu without misaligning the automatic index calculation
	"Map 4",
};

Game.takeMeThereType = "Checkbox"; -- Optional. If not present will default to checkbox

function Game.setMap(index) -- Optional
	-- Set the Game's map index to the index selected in the dropdown
	mainmemory.writebyte(Game.Memory.map_index[version], index);
end

function Game.applyInfinites() -- Optional: Toggled by a checkbox. If this function is not present in the module, the checkbox will not appear
	-- TODO: Give the player infinite consumables
end

local labelValue = 0;
function Game.initUI() -- Optional: Init any UI state here, mainly useful for setting up your form controls. Runs once at startup after successful version detection.

	ScriptHawk.UI.form_controls["Example Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Label", ScriptHawk.UI.col(10) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);
end


function Game.drawUI()
	
end

function Game.eachFrame() -- Optional: This function will be executed once per frame
	-- TODO
end

function Game.realTime() -- Optional: This function will be executed as fast as possible
	-- TODO
end

Game.OSDPosition = {2, 70}; -- Optional: OSD position in pixels from the top left corner of the screen, defaults to 2, 70 if not set by a game module
Game.OSD = {
	{"X", Game.getXPosition},
	--{"Y", Game.getYPosition, Game.colorYPosition}, -- A third parameter can be added to these table entries, a function that returns a 32 bit int AARRGGBB color value for that OSD entry
	{"Y", Game.getYPosition},
    {"Separator", 1},
    {"X Vel", Game.getXVelocity},
	{"Y Vel", Game.getYVelocity},
	{"dY"},
	{"dXZ"},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
};

return Game; -- Return your Game table to ScriptHawk