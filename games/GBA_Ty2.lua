if type(ScriptHawk) ~= "table" then -- An error message to inform the user that this is a game module, not a standalone script
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {}; -- This table stores the module's API function implementations and game state, it's returned to ScriptHawk at the end of the module code

local script_modes = {
	"Disabled",
	"List",
	"Examine",
};

local script_mode_index = 1;
script_mode = script_modes[script_mode_index];

--------------------
-- Region/Version --
--------------------

Game.Memory = {
	["player_ptr"] = {["Domain"] = "EWRAM", ["Address"] = 0x47EC},
    ["object_array_size"] = {["Domain"] = "IWRAM", ["Address"] = 0x16F8},
    ["object_list_ptr"] = {["Domain"] = "IWRAM", ["Address"] = 0x14A0},
    ["rangCount"] = {["Domain"] = "IWRAM", ["Address"] = 0xB06},
    --["player_ptr"] = {["Domain"] = "EWRAM", ["Address"] = {0x5B08}}, --may be better?
};

local player_struct = {
	[0xC] = {["Type"] = "s32_le", ["Name"] = "XPosition"},
    [0x10] = {["Type"] = "s32_le", ["Name"] = "YPosition"},
	[0x18] = {["Type"] = "s32_le", ["Name"] = "XVelocity"},
	[0x1C] = {["Type"] = "s32_le", ["Name"] = "YVelocity"},
    [0x74] = {["Type"] = "u32_le", ["Name"] = "1st Glide"},
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
        return nil;
    end
    return outPtr
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 }; -- D-Pad speeds, scale these appropriately with your game's coordinate system
Game.speedy_index = 7;

local movementStates = {
	[0x00] = "Idle",
    [0x01] = "Run",
    [0x02] = "Jump",
    [0x03] = "Fall",
    [0x04] = "Glide",
    [0x05] = "Rang Throw",
    [0x06] = "Damaged",
    [0x07] = "Run Skid",
    [0x09] = "Run Start",
    [0x0A] = "Landing",
    [0x0C] = "Bite",
    [0x0D] = "Interacting",
    [0x10] = "Fast Falling",
    [0x11] = "Fall Damage",
    [0x15] = "Platform Drop Through",
    [0x17] = "Looking",
    [0X19] = "Arial Bite",
}
function Game.getState()
    local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"]);
	playerPtr = parsePointer(playerPtr);
    if playerPtr ~= nil then
        local currentMovementState = memory.read_u8(playerPtr["Address"]+0x5D, playerPtr["Domain"]);
        --local direction = memory.read_u8_le(playerPtr["Address"]+0x16, playerPtr["Domain"]);
        if type(movementStates[currentMovementState]) ~= "nil" then
          return movementStates[currentMovementState];
	    else
		  return "Unknown ("..currentMovementState..")";
	   end
    end
    return nil
end

function Game.getRangCount()
    return (2 - memory.read_u16_le(Game.Memory.rangCount["Address"], Game.Memory.rangCount["Domain"]));
end
function Game.colorRangCount()
	local rangs = Game.getRangCount();
	if rangs == 0 then
		-- Color Y position values less than 0 red
		-- Format 0xAARRGGBB
		return 0xFFFF0000;
		-- LibScriptHawk also provides some common colors in a colors table, for example:
		-- return colors.red;
    elseif rangs == 2 then
        return 0xFF00FF00;
	end
end

function Game.getGlideFlag()
    local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"])
	playerPtr = parsePointer(playerPtr)
    if playerPtr ~= nil then
        local glideFlag = memory.read_u32_le(playerPtr["Address"]+0x74, playerPtr["Domain"])
        if  glideFlag == 0 then
            return false
        else
            return true
        end
    end
    return nil
end

function Game.colorGlideFlag()
	local glideFlag = Game.getGlideFlag();
	if glideFlag == true and Game.getRangCount() == 2 then
		-- Color Y position values less than 0 red
		-- Format 0xAARRGGBB
		return 0xFF00FF00;
	end
end

--------------
-- Position --
--------------

function Game.getXPosition()
    local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"])
	playerPtr = parsePointer(playerPtr)
    if playerPtr ~= nil then
        return memory.read_s32_le(playerPtr["Address"]+0x0C, playerPtr["Domain"]);
    end
    return 0
end

function Game.getYPosition()
    local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"])
	playerPtr = parsePointer(playerPtr)
    if playerPtr ~= nil then
        return -memory.read_s32_le(playerPtr["Address"]+0x10, playerPtr["Domain"]);
    end
    return 0
end

function Game.colorYVelocity()
	local yPosition = Game.getYVelocity();
	if yPosition < 0 then
		-- Color Y position values less than 0 red
		-- Format 0xAARRGGBB
		return 0xFFFF0000;
		-- LibScriptHawk also provides some common colors in a colors table, for example:
		-- return colors.red;
	end
end

function Game.setXPosition(value) -- Optional
    local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"])
	playerPtr = parsePointer(playerPtr)
    if playerPtr ~= nil then
        memory.write_s32_le(playerPtr["Address"]+0x0C, value, playerPtr["Domain"]);
    end
end

function Game.setYPosition(value) -- Optional
    local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"])
	playerPtr = parsePointer(playerPtr)
    if playerPtr ~= nil then
        memory.write_s32_le(playerPtr["Address"]+0x10, value, playerPtr["Domain"]);
    end
end

--------------
-- Velocity --
--------------
    function Game.getXVelocity()
        local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"])
        playerPtr = parsePointer(playerPtr)
        if playerPtr ~= nil then
            return memory.read_s32_le(playerPtr["Address"]+0x18, playerPtr["Domain"]);
        end
    return 0
    end

    function Game.getYVelocity()
        local playerPtr = memory.read_u32_le(Game.Memory.player_ptr["Address"], Game.Memory.player_ptr["Domain"])
        playerPtr = parsePointer(playerPtr)
        if playerPtr ~= nil then
            return memory.read_s32_le(playerPtr["Address"]+0x1C, playerPtr["Domain"]);
        end
    return 0
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

-------------
-- Objects --
-------------
object_index = 2;
object_top_index = 1;
object_max_slots = 25;
local object_struct_size = 0xF8;

local object_indexes = {
    
     [0x0B] = "Moving Platform",
    
    [0x36] = "Crab Tank Enemy",
    [0x37] = "Cricket Bat Enemy",
    [0x38] = "Bird Enemy",
    [0x39] = "Spider Enemy",
    
    [0x3D] = "Checkpoint",
    [0x3E] = "Health Refill",
    
    [0x49] = "Robot Enemy",
    
    [0x4B] = "Opal Sack",
    
    [0x53] = "Secret Box",
    [0x54] = "Ninja Enemy",
    
    [0x59] = "Breakable Crystals",
    
    [0x5B] = "Warp Mushrooms",
    [0x5C] = "Bilby",
    
    [0x5E] = "Firebreathing Enemy",
    
    [0x60] = "Fish Enemy",
    
    [0x62] = "Tilting Platform",
    
    [0x65] = "Mech Suit Enemy",
    
    [0x69] = "Ranger Ken",
    
    [0x6D] = "Air Bubbles",
    [0x6E] = "Wood Gate",
    [0x6F] = "White Croc",   
    [0x70] = "Button",
    
    [0x72] = "Moving Platform",
    
    [0x7D] = "Breakable Rock Wall",
    
    [0x81] = "Liftable Rock",
    
    [0x92] = "Fire",
    [0x93] = "Leech",
};

--Object Structure
slot_variables = {
	[0x0C] = {["Type"] = "s32_le", ["Name"] = {"X", "X Pos", "X Position"}},
    [0x10] = {["Type"] = "s32_le", ["Name"] = {"Y", "Y Pos", "Y Position"}},
	[0x18] = {["Type"] = "s32_le", ["Name"] = {"dX", "X Vel", "X Velocity"}},
    [0x1C] = {["Type"] = "s32_le", ["Name"] = {"dY", "Y Vel", "Y Velocity"}},
};

local function getObjectSlotBase(index, addressPtr)
    if addressPtr == nil then
        addressPtr = Game.Memory.object_list_ptr;
        index = index - 1;
    end
    
    if index > 0 then
        nextPtr = memory.read_u32_le(addressPtr["Address"]+0x0C, addressPtr["Domain"]);
        nextPtr = parsePointer(nextPtr);
        if nextPtr ~= nil then
            return getObjectSlotBase(index-1, nextPtr);
        else
            return nil
        end
    else 
        local objectPtr = memory.read_u32_le(addressPtr["Address"]+0x04, addressPtr["Domain"]);
        return parsePointer(objectPtr);
    end
end

local function incrementObjectIndex()
    local tempObject = getObjectSlotBase(object_index + 1);
    if tempObject ~= nil then
        object_index = object_index + 1;
        if object_index > object_top_index - 1 + object_max_slots then
            object_top_index = object_index + 1 - object_max_slots;
        end
    end
end

local function decrementObjectIndex()
    if object_index - 1 > 0 then
        object_index = object_index - 1;
        if object_index < object_top_index then
            object_top_index = object_index;
        end
    end
end

function zipToSelectedObject()
    local objAddress = getObjectSlotBase(object_index);
    if objAddress ~= nil then
        local x = memory.read_u32_le(objAddress["Address"] + 0x0C, objAddress["Domain"]);
        local y = memory.read_u32_le(objAddress["Address"] + 0x10, objAddress["Domain"]);

        Game.setXPosition(x);
        Game.setYPosition(y);
    end
end

local function getVariableName(address)
	local variable = slot_variables[address];
	local nameType = type(variable.Name);

	if nameType == "string" then
		return variable.Name;
	elseif nameType == "table" then
		return variable.Name[1];
	end

	return variable.Type.." "..toHexString(address);
end

local function isBinary(var_type)
	return var_type == "Binary" or var_type == "Bitfield" or var_type == "Byte" or var_type == "Flag" or var_type == "Boolean";
end

local function isHex(var_type)
	return var_type == "Hex" or var_type == "Pointer" or var_type == "Z4_Unknown";
end

local function formatForOutput(var_type, value)
	if isBinary(var_type) then
		local binstring = toBinaryString(value);
		if binstring ~= "" then
			return binstring;
		end
		return "0";
	elseif isHex(var_type) then
		return toHexString(value);
	end
	return ""..value;
end

function getExamineData(slotBase) -- TODO: Improve this based on SM64 module implementation
	local current_slot_variables = {};
    --get slot size
    local objectType = memory.read_u32_le((slotBase["Address"]) + 0x04, slotBase["Domain"]);
    local slot_size = 0xF8;
    
    --generate table
	for relative_address = 0, slot_size do
		local variable_data = slot_variables[relative_address];
		if type(variable_data) == "table" then
			local variableName = getVariableName(relative_address);
			if variable_data.Type == "s32_le" then
				table.insert(current_slot_variables, {variableName, formatForOutput(variable_data.Type, memory.read_s32_le((slotBase["Address"]) + relative_address, slotBase["Domain"]))});
                --table.insert(current_slot_variables, {variableName, "Test"});
			end
		end
	end
	return current_slot_variables;
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


local function toggleObjectAnalysisToolsMode()
	script_mode_index = script_mode_index + 1;
	if script_mode_index > #script_modes then
		script_mode_index = 1;
	end
	script_mode = script_modes[script_mode_index];
end

function Game.drawUI()
    local row = 0;
	if script_mode == "Disabled" then
		return;
	
    elseif script_mode == "Examine" then
        gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, "Mode: "..script_mode, nil, 'bottomright');
        row = row + 1;
        
        local currentSlotBase = getObjectSlotBase(object_index);
        local examine_data = getExamineData(currentSlotBase);
		
        for i = #examine_data, 1, -1 do
			if examine_data[i][1] ~= "Separator" then
				gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, examine_data[i][2].." - "..examine_data[i][1], nil, 'bottomright');
				row = row + 1;
			else
				row = row + examine_data[i][2];
			end
		end
        
        if memory.read_u32_le(currentSlotBase["Address"], currentSlotBase["Domain"]) ~= 0 then
            local actorType = "Unknown";    
            local objectType = memory.read_u32_le(currentSlotBase["Address"] + 0x04, currentSlotBase["Domain"]);
            if object_indexes[objectType] ~= nil then
                actorType = object_indexes[objectType];
            else
                actorType = "Unknown("..toHexString(objectType)..")";
            end
            gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, actorType.." "..object_index..": "..toHexString(currentSlotBase["Address"] or 0), nil, 'bottomright');
            row = row + 1;

        end
        return;
    
    elseif script_mode == "List" then
        gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, "Mode: "..script_mode, nil, 'bottomright');
        row = row + 1;
        
        local object_list = Game.Memory.object_list_ptr;
        local objectcount = object_max_slots;
        local printlist = {};
        for i = object_top_index-1+objectcount,object_top_index,-1  do
            currentSlotBase = getObjectSlotBase(i);
            if currentSlotBase ~= nil then
                local actorType = "Unknown";    
                local objectType = memory.read_u32_le(currentSlotBase["Address"] + 0x04, currentSlotBase["Domain"]);
                if object_indexes[objectType] ~= nil then
                    actorType = object_indexes[objectType];
                    printlist[i] = actorType.." "..i..": "..toHexString(currentSlotBase["Address"] or 0);
                else
                    actorType = "Unknown("..toHexString(objectType)..")";
                    printlist[i] = actorType.." "..i..": "..toHexString(currentSlotBase["Address"] or 0);
                end
            end
        end
        for i = object_top_index-1+objectcount,object_top_index,-1 do
            local color = nil;
            if object_index == i then
                color = colors.yellow;
            end
            if(printlist[i] ~= nil) then
                gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, printlist[i], color, 'bottomright');
                row = row + 1;
            end
        end
    end
end

function Game.eachFrame() -- Optional: This function will be executed once per frame
	-- TODO
end

function Game.realTime() -- Optional: This function will be executed as fast as possible
	-- TODO
end

Game.OSDPosition = {2, 70}; -- Optional: OSD position in pixels from the top left corner of the screen, defaults to 2, 70 if not set by a game module
Game.OSD = {
    {"State", Game.getState},
    {"Rang #", Game.getRangCount,Game.colorRangCount},
    {"SuperJump", Game.getGlideFlag, Game.colorGlideFlag},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition}, -- A third parameter can be added to these table entries, a function that returns a 32 bit int AARRGGBB color value for that OSD entry
    {"Separator", 1},
    {"X Vel", Game.getXVelocity},
	{"Y Vel", Game.getYVelocity, Game.colorYVelocity},
	{"dY"},
	{"dXZ"},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
};

ScriptHawk.bindKeyRealtime("Z", zipToSelectedObject, true);
ScriptHawk.bindKeyRealtime("C", toggleObjectAnalysisToolsMode, true);
ScriptHawk.bindMouse("mousewheelup", decrementObjectIndex);
ScriptHawk.bindMouse("mousewheeldown", incrementObjectIndex);


return Game; -- Return your Game table to ScriptHawk