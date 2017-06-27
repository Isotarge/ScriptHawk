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
	-- Lua has a maximum of 200 local variables per function, we use a table to store memory addresses to get around this
	-- It's a 2 dimensional table, the first dimension is the name of the address
	-- the second dimension is an index for which version of the game was detected, set below by Game.detectVersion()
	-- Examples of how to access the memory address for X Position:
		-- Game.Memory.x_position[version] -- Preferred
		-- Game.Memory["x_position"][version]
		-- Game["Memory"]["x_position"][version]
	["x_position"] = {0x0E98}, -- Example addresses
	["y_position"] = {0x0E9C},
	["x_velocity"] = {0x0EA0},
    ["y_velocity"] = {0x0EA4},
    ["current_movement_state"] = {0x0F38},
};

function Game.detectVersion(romName, romHash) -- Modules should ideally use ROM hash rather than name, but both are passed in by ScriptHawk
	if romHash == "C1058CC2482B91204100CC8515DA99AEB06773F5" then -- US
        version = 1; -- We use the version variable as an index for the Game.Memory table
	elseif romHash == "84AFA7108E4D604E7B1A6D105DF5760869A247FA" then --JP
		version = 2;
	else
		return false; -- Return false if this version of the game is not supported
	end

	return true; -- Return true if version detection is successful
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

-----------------------------
-- 16.16 numbers are weird --
-----------------------------
function Game.read_16_16(address)
    local value =  mainmemory.read_u16_le(address)/0x10000;
    value = value + mainmemory.read_s16_le(address+0x02);
    return value;
end

function Game.write_16_16(address, value)
    mainmemory.write_s16_le(address+0x02, value);
    mainmemory.write_u16_le(address, ((value*0x10000) % 0x10000));
    return value;
end


--------------
-- Position --
--------------

function Game.getXPosition()
	return Game.read_16_16(Game.Memory.x_position[version]);
end

function Game.getYPosition()
	return Game.read_16_16(Game.Memory.y_position[version]);
end

function Game.getZPosition()
	return 0;
end

function Game.colorYPosition()
	local yPosition = Game.getYPosition();
	if yPosition < 0 then
		-- Color Y position values less than 0 red
		-- Format 0xAARRGGBB
		return 0xFFFF0000;
	end
end

function Game.setXPosition(value)
    Game.write_16_16(Game.Memory.x_position[version],value);
end

function Game.setYPosition(value)
	Game.write_16_16(Game.Memory.y_position[version],value);
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	return Game.read_16_16(Game.Memory.x_velocity[version]);
end

function Game.getYVelocity()
	return Game.read_16_16(Game.Memory.y_velocity[version]);
end

function Game.colorYPosition()
	local yPosition = Game.getYPosition();
	if yPosition < 0 then
		-- Color Y position values less than 0 red
		-- Format 0xAARRGGBB
		return 0xFFFF0000;
	end
end

function Game.setXVelocity(value)
    Game.write_16_16(Game.Memory.x_velocity[version],value);
end

function Game.setYVelocity(value)
	Game.write_16_16(Game.Memory.y_velocity[version],value);
end

--------------------
-- Movement State --
--------------------

local movementStates = {
	[0x00] = "Idle (L)",
    [0x01] = "Idle (R)",
    [0x02] = "Idle: Looking Up (L)",
    [0x03] = "Idle: Looking Up (R)",
    [0x04] = "Crouching (L)",
    [0x05] = "Crouching (R)",
    [0x06] = "Walking (L)",
    [0x07] = "Walking (R)",
    [0x08] = "Running (L)",
    [0x09] = "Running (R)",
    [0x0A] = "Jumping (L)",
    [0x0B] = "Jumping (R)",
    [0x0C] = "Freefall (L)",
    [0x0D] = "Freefall (R)",
    [0x0E] = "Falling (L)",
    [0x0F] = "Falling (R)",
    [0x10] = "Landing (L)",
    [0x11] = "Landing (R)",
    [0x12] = "Drilling: Up (L)",
    [0x13] = "Drilling: Up (R)",
    [0x14] = "Drilling: Down (L)",
    [0x15] = "Drilling: Down (R)",
    [0x16] = "Drilling (L)",
    [0x17] = "Drilling (R)",
    [0x18] = "Damaged (L)",
    [0x19] = "Damaged (R)",
    [0x1A] = "KickBack (L)",
    [0x1B] = "KickBack (R)",
    [0x1C] = "Drilling: Wall (L)",
    [0x1D] = "Drilling: Wall (R)",
    
    [0x20] = "Tunnel: Idle (L)",
    [0x21] = "Tunnel (L)",
    [0x22] = "Tunnel: Idle (R)",
    [0x23] = "Tunnel (R)",
    
    [0x24] = "Teetering (L)",
    [0x25] = "Teetering (R)",
    [0x26] = "Entering Door (L)",
    [0x27] = "Entering Door (R)",
    [0x28] = "Exiting Door (L)",
    [0x29] = "Exiting Door (R)",
    [0x2A] = "Drill Socket (L)",
    [0x2B] = "Drill Socket (R)",
    [0x2C] = "Looking (L)",
    [0x2D] = "Looking (R)",
    [0x2E] = "Looking: Up (L)",
    [0x2F] = "Looking: Up (R)",
    [0x30] = "Looking: Down (L)",
    [0x31] = "Looking: Down (R)",
    [0x32] = "Drilling: Walking (L)",
    [0x33] = "Drilling: Walking (R)",
    [0x34] = "Drilling: Back Walking (L)",
    [0x35] = "Drilling: Back Walking (R)",
    
    [0x3E] = "Drilling: Stuck in block (L)",
    [0x3F] = "Drilling: Stuck in block (R)",
    
    [0x42] = "Grabbing Gear (L)",
    [0x43] = "Grabbing Gear (R)",
    [0x45] = "Grabbing Gear Jig",
    
    [0x50] = "Drill Socket: Idle (L)",
    [0x51] = "Drill Socket: Idle (R)",
    [0x57] = "Swimming: Idle (L)",
    [0x58] = "Swimming: Idle (R)",
    [0x58] = "Swimming Up (R)",
    [0x59] = "Swimming Up (L)",
    [0x5A] = "Swimming Down (L)",
    [0x5B] = "Swimming Down (R)",
    [0x5C] = "Swimming (L)",
    [0x5D] = "Swimming (R)",
    [0x5F] = "Swimming: Up Idle (R)",
    [0x5F] = "Swimming: Up Idle (L)",
    [0x60] = "Swimming: Down Idle (L)",
    [0x61] = "Swimming: Down Idle (R)",
    [0x62] = "Swimming: Idle (L)",
    [0x63] = "Swimming: Idle (R)",
    [0x64] = "Swimming: Damaged (L)",
    [0x65] = "Swimming: Damaged (R)",
    
    [0x67] = "Wall Object: Grabbing (L)",
    [0x68] = "Wall Object: Grabbing (R)",
    [0x69] = "Wall Object: Idle (L)",
    [0x6A] = "Wall Object: Idle (R)",
    [0x6B] = "Wall Object: Falling (L)",
    [0x6C] = "Wall Object: Falling (R)",
    [0x6D] = "Wall Object: Walking (L)",
    [0x6E] = "Wall Object: Walking (R)",
    [0x6F] = "Wall Object: Placing (L)",
    [0x70] = "Wall Object: Placing (R)",
    
    [0x82] = "Slide Start (L)",
    [0x83] = "Slide Start (R)",
    [0x84] = "Slide (L)",
    [0x85] = "Slide (R)",
    [0x86] = "Slide End (L)",
    [0x87] = "Slide End (R)",
    
    [0x99] = "Looking: Backwards (L)",
    [0x9A] = "Looking: Backwards (R)",
    [0x9B] = "Looking: Forwards (L)",
    [0x9C] = "Looking: Forwards (R)",
    
    [0xBD] = "Loading Zone",
};

function Game.getCurrentMovementState()
	local currentMovementState = mainmemory.read_u32_le(Game.Memory.current_movement_state[version]);
	if type(movementStates[currentMovementState]) ~= "nil" then
            return movementStates[currentMovementState];
	else
	   return "Unknown ("..currentMovementState..")";
    end
end

function Game.colorCurrentMovementState()
	local stringMovementState = Game.getCurrentMovementState();
	--if stringMovementState == "Slipping" or stringMovementState == "Skidding" or stringMovementState == "Recovering" or stringMovementState == "Knockback" then
	--	return 0xFFFFFF00; -- Yellow
	--end
	if stringMovementState == "Damaged (L)" 
        or stringMovementState == "Damaged (R)" 
        or stringMovementState == "Swimming: Damaged (L)" 
        or stringMovementState == "Swimming: Damaged (R)" then
		return 0xFFFF0000; -- Red
	end
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

-- Checkbox:
	-- Will be called each frame while the checkbox is checked
	-- Should not reload the map instantly
	-- Should take effect after walking through a door
-- Button:
	-- Will be called exacty once when the button is pressed
	-- Should load the selected map as soon as possible after the button is pressed
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
	-- Here are some examples for the most common UI control types
	--ScriptHawk.UI.form_controls["Example Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, {"Option 1", "Option 2", "Option 3"}, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 7, ScriptHawk.UI.button_height);
	--ScriptHawk.UI.form_controls["Example Button"] = forms.button(ScriptHawk.UI.options_form, "Label", flagSetButtonHandler, ScriptHawk.UI.col(10), ScriptHawk.UI.row(7), 59, ScriptHawk.UI.button_height);
	--ScriptHawk.UI.form_controls["Example Plus Button"] = forms.button(ScriptHawk.UI.options_form, "-", function() labelValue = labelValue + 1 end, ScriptHawk.UI.col(13) - 7, ScriptHawk.UI.row(6), ScriptHawk.UI.button_height, ScriptHawk.UI.button_height);
	--ScriptHawk.UI.form_controls["Example Minus Button"] = forms.button(ScriptHawk.UI.options_form, "+", function() labelValue = labelValue - 1 end, ScriptHawk.UI.col(13) + ScriptHawk.UI.button_height - 7, ScriptHawk.UI.row(6), ScriptHawk.UI.button_height, ScriptHawk.UI.button_height);
	--ScriptHawk.UI.form_controls["Example Value Label"] = forms.label(ScriptHawk.UI.options_form, "0", ScriptHawk.UI.col(13) + ScriptHawk.UI.button_height + 21, ScriptHawk.UI.row(6) + ScriptHawk.UI.label_offset, 54, 14);
	--ScriptHawk.UI.form_controls["Example Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Label", ScriptHawk.UI.col(10) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);
end

-- Optional: This function should be used to draw to the screen or update form controls
-- When emulation is running it will be called once per frame
-- When emulation is paused it will be called as fast as possible
function Game.drawUI()
	--forms.settext(ScriptHawk.UI.form_controls["Example Value Label"], labelValue);
end

function Game.eachFrame() -- Optional: This function will be executed once per frame
	-- TODO
end

function Game.realTime() -- Optional: This function will be executed as fast as possible
	-- TODO
end

Game.OSDPosition = {2, 70}; -- Optional: OSD position in pixels from the top left corner of the screen, defaults to 2, 70 if not set by a game module
Game.OSD = {
    {"Movement", Game.getCurrentMovementState, Game.colorCurrentMovementState},
    {"Separator", 1},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition, Game.colorYPosition}, -- A third parameter can be added to these table entries, a function that returns a 32 bit int AARRGGBB color value for that OSD entry
    {"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity, Game.colorYPosition}, -- A third parameter can be added to these table entries, a function that returns a 32 bit int AARRGGBB color value for that OSD entry
	{"Separator", 1},
	{"dX"},
	{"dY"},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
};

return Game; -- Return your Game table to ScriptHawk