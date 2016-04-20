local Game = {}; -- We'll put all of our functions in here and return it to ScriptHawk

--------------------
-- Region/Version --
--------------------

Game.Memory = { -- Lua has a maximum of 200 local variables per function, we use a table for memory addresses to get around this
	-- It's a 2 dimensional table, the first dimension is the name of the address
	-- the second dimension is an index for which version of the game was detected, set below by Game.detectVersion()
	-- Examples of how to access the memory address for X Position:
		-- Game.Memory.x_position[version]
		-- Game.Memory["x_position"][version]
	["x_position"] = {0x100000, 0x200000, 0x300000}, -- Example addresses
	["y_position"] = {0x100004, 0x200004, 0x300004},
	["z_position"] = {0x100008, 0x200008, 0x300008},
}

function Game.detectVersion(romName) -- TODO: Base this on ROM Hash, more reliable
	if stringContains(romName, "Europe") then -- stringContains is a pure Lua global function provided by ScriptHawk, intended to replace calls to bizstring.contains()
		version = 1; -- We use the version variable as an index for the Game.Memory table
	elseif stringContains(romName, "Japan") then
		version = 2;
	elseif stringContains(romName, "USA") then
		version = 3;
	else
		return false; -- Return false if this version of the game is not supported
	end

	return true; -- Return true if version detection is successful
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_index = 7;

function Game.isPhysicsFrame() -- Optional: If lag in your game is more complicated than a simple emu.islagged() call you should add the logic to detect it here
	-- Implementing this logic will result in smooth dY/dXZ calculation (no more flickering between 0 and the correct value)
	return not emu.islagged();
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.x_position[version], true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_position[version], true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_position[version], true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(Game.Memory.x_position[version], value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.y_position[version], value, true);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_position[version], value, true);
end

--------------
-- Rotation --
--------------

Game.rot_speed = 10; -- Determines how big a single step is when the D-Pad is in Rotation mode
Game.max_rot_units = 360; -- Maximum value of the Game's native rotation units

-- Rotation units can be fiddly sometimes.
-- These functions can return any number as long as it's consistent between get & set.
-- If the Game.max_rot_units value is correct (and minimum is 0) ScriptHawk will correctly convert in game units to both degrees (default) and radians

function Game.getXRotation()
	return 0; -- TODO
end

function Game.getYRotation()
	return 0; -- TODO
end

function Game.getZRotation()
	return 0; -- TODO
end

function Game.setXRotation(value)
	-- TODO
end

function Game.setYRotation(value)
	-- TODO
end

function Game.setZRotation(value)
	-- TODO
end

------------
-- Events --
------------

Game.maps = {
	"Map 1",
	"Map 2",
	"Crashes/Unknown 3", -- TODO: Unfortunately entries like this will still be shown in the dropdown, I'm still thinking about how to deal with this
	"Map 4",
};

Game.takeMeThereType = "Checkbox"; -- Optional: Can also be "Button". If not present will default to checkbox
function Game.setMap(value) -- Optional
	-- TODO: Set the Game's map index to the index selected by the dropdown
	-- The selected value will be passed into the function by ScriptHawk
end

function Game.applyInfinites() -- Optional: Toggled by a checkbox. If not present the checkbox will not appear
	-- TODO: Give the player infinite consumables using this function
end

local labelValue = 0;
function Game.initUI() -- Optional: Init any UI state here, mainly useful for setting up your form controls. Runs once at startup after successful version detection.
	-- Here are some examples for the most common UI control types
	ScriptHawkUI.form_controls["Example Dropdown"] = forms.dropdown(ScriptHawkUI.options_form, {"Option 1", "Option 2", "Option 3"}, ScriptHawkUI.col(0) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(7) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.col(9) + 7, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Example Button"] = forms.button(ScriptHawkUI.options_form, "Label", flagSetButtonHandler, ScriptHawkUI.col(10), ScriptHawkUI.row(7), 59, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Example Plus Button"] = forms.button(ScriptHawkUI.options_form, "-", function() labelValue = labelValue + 1 end, ScriptHawkUI.col(13) - 7, ScriptHawkUI.row(6), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Example Minus Button"] = forms.button(ScriptHawkUI.options_form, "+", function() labelValue = labelValue - 1 end, ScriptHawkUI.col(13) + ScriptHawkUI.button_height - 7, ScriptHawkUI.row(6), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Example Value Label"] = forms.label(ScriptHawkUI.options_form, "0", ScriptHawkUI.col(13) + ScriptHawkUI.button_height + 21, ScriptHawkUI.row(6) + ScriptHawkUI.label_offset, 54, 14);
	ScriptHawkUI.form_controls["Example Checkbox"] = forms.checkbox(ScriptHawkUI.options_form, "Label", ScriptHawkUI.col(10) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(6) + ScriptHawkUI.dropdown_offset);
end

function Game.eachFrame() -- Optional: This function will be executed once per frame
	-- TODO
end

function Game.realTime() -- Optional: This function will be executed as fast as possible, useful for OSD/UI that needs to be updated while emulation is paused
	forms.settext(ScriptHawkUI.form_controls["Example Value Label"], labelValue);
end

Game.OSDPosition = {2, 70}; -- Optional: OSD position in pixels from the top left corner of the screen, defaults to 2, 70 if not set by a game module
Game.OSD = { -- TODO: Example for color -- A third paramater can be added to these table entries, a function that returns a 32 bit int AARRGGBB color value for that OSD entry
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"dY"},
	{"dXZ"},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
	{"Rot. X", Game.getXRotation},
	{"Facing", Game.getYRotation},
	{"Rot. Z", Game.getZRotation},
};

return Game; -- Return your Game table to ScriptHawk