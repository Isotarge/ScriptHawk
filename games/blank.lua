if type(ScriptHawk) ~= "table" then -- An error message to inform the user that this is a game module, not a standalone script
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = { -- This table stores the module's API function implementations and game state, it's returned to ScriptHawk at the end of the module code
	Memory = {
		-- Lua has a maximum of 200 local variables per function, we use a table to store memory addresses to get around this
		-- It's a 2 dimensional table, the first dimension is the name of the address
		-- the second dimension is an index for which version of the game was detected, set below by Game.detectVersion()
		-- Game.detectVersion() will squish these tables down into a single address based on which version is detected
		x_position = {0x100000, 0x200000, 0x300000}, -- Example addresses
		y_position = {0x100004, 0x200004, 0x300004},
		z_position = {0x100008, 0x200008, 0x300008},
		x_rotation = {0x100010, 0x200010, 0x300010},
		y_rotation = {0x100014, 0x200014, 0x300014},
		z_rotation = {0x100018, 0x200018, 0x300018},
		map_index = {0x10000C, 0x20000C, 0x30000C},
	},
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 }, -- D-Pad speeds, scale these appropriately with your game's coordinate system
	speedy_index = 7, -- Default speed, index into the speedy_speeds table
};

--------------------
-- Region/Version --
--------------------

-- Modules should ideally use ROM hash rather than name, but both are passed in by ScriptHawk
-- This function is optional, if you add version=n to the supportedGames entry for your module in ScriptHawk.lua, Game.version will be automatically populated by ScriptHawk on module startup
function Game.detectVersion(romName, romHash)
	if string.contains(romName, "Europe") then -- string.contains is a pure Lua global function provided by LibScriptHawk, intended to replace calls to bizstring.contains() for portability reasons
		Game.version = 1; -- We use the version variable as an index for the Game.Memory table
	elseif string.contains(romName, "Japan") then
		Game.version = 2;
	elseif string.contains(romName, "USA") then
		Game.version = 3;
	else
		return false; -- Return false if this version of the game is not supported
	end

	-- Squish Game.Memory tables down to a single address for the relevant version
	-- If you include this code snippet in your module, you can access Game.Memory addresses in a cleaner fashion
	-- Game.Memory.address[Game.version] becomes Game.Memory.address
	-- If you specify Game.squish_memory_table = true, this snippet will be run automatically on module startup by ScriptHawk
	for k, v in pairs(Game.Memory) do
		Game.Memory[k] = v[Game.version];
	end

	return true; -- Return true if version detection is successful
end

-------------------
-- Physics/Scale --
-------------------

-- Optional: If lag in your game is more complicated than a simple emu.islagged() call you should add the logic to detect it here
function Game.isPhysicsFrame()
	-- Implementing this logic will result in smooth dY/dXZ calculation (no more flickering between 0 and the correct value)
	return not emu.islagged();
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.x_position, true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_position, true);
end

-- Optional
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

-- Optional, 2D games don't need to implement this
function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_position, true);
end

-- Optional
function Game.setXPosition(value)
	mainmemory.writefloat(Game.Memory.x_position, value, true);
end

-- Optional
function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.y_position, value, true);
end

-- Optional, 2D games don't need to implement this
function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_position, value, true);
end

--------------
-- Rotation --
--------------

Game.rot_speed = 10; -- Determines how big a single step is when the D-Pad is in Rotation mode
Game.max_rot_units = 360; -- Maximum value of the Game's native rotation units

-- Rotation units can be fiddly sometimes.
-- These functions can return any number as long as it's consistent between get & set.
-- If the Game.max_rot_units value is correct (and minimum is 0) ScriptHawk will correctly convert in game units to both degrees (default) and radians

-- Optional
function Game.getXRotation()
	return mainmemory.readfloat(Game.Memory.x_rotation, true);
end

-- Optional
function Game.getYRotation()
	return mainmemory.readfloat(Game.Memory.y_rotation, true);
end

-- Optional
function Game.getZRotation()
	return mainmemory.readfloat(Game.Memory.z_rotation, true);
end

-- Optional
function Game.setXRotation(value)
	mainmemory.writefloat(Game.Memory.x_rotation, value, true);
end

-- Optional
function Game.setYRotation(value)
	mainmemory.writefloat(Game.Memory.y_rotation, value, true);
end

-- Optional
function Game.setZRotation(value)
	mainmemory.writefloat(Game.Memory.z_rotation, value, true);
end

------------
-- Events --
------------

-- Optional
Game.maps = {
	"Map 1",
	"Map 2",
	"!Crash 3", -- Prefixing a map with '!' will hide it from the dropdown menu without misaligning the automatic index calculation
	"Map 4",
};

-- Optional
-- Checkbox:
	-- Will be called each frame while the checkbox is checked
	-- Should not reload the map instantly
	-- Should take effect after walking through a door
-- Button:
	-- Will be called exacty once when the button is pressed
	-- Should load the selected map as soon as possible after the button is pressed
Game.takeMeThereType = "Checkbox"; -- Optional. If not present will default to checkbox

-- Optional
function Game.setMap(index)
	-- Set the Game's map index to the index selected in the dropdown
	mainmemory.writebyte(Game.Memory.map_index, index);
end

-- Optional: Toggled by a checkbox. If this function is not present in the module, the checkbox will not appear
function Game.applyInfinites()
	-- TODO: Give the player infinite consumables
end

function Game.buttonHandler()
	print("Example button was pressed!");
end

local labelValue = 0;
function Game.initUI() -- Optional: Init any UI state here, mainly useful for setting up your form controls. Runs once at startup after successful version detection.
	-- Here are some examples for the most common UI control types
	ScriptHawk.UI.form_controls["Example Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, {"Option 1", "Option 2", "Option 3"}, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 7, ScriptHawk.UI.button_height);
	ScriptHawk.UI.button(10,                                    7, {59},                          nil, "Example Button",       "Label", Game.buttonHandler);
	ScriptHawk.UI.button({13, -7},                              6, {ScriptHawk.UI.button_height}, nil, "Example Plus Button",  "-",     function() labelValue = labelValue + 1 end);
	ScriptHawk.UI.button({13, ScriptHawk.UI.button_height - 7}, 6, {ScriptHawk.UI.button_height}, nil, "Example Minus Button", "+",     function() labelValue = labelValue - 1 end);
	ScriptHawk.UI.form_controls["Example Value Label"] = forms.label(ScriptHawk.UI.options_form, "0", ScriptHawk.UI.col(13) + ScriptHawk.UI.button_height + 21, ScriptHawk.UI.row(6) + ScriptHawk.UI.label_offset, 54, 14);
	ScriptHawk.UI.checkbox(10, 6, "Example Checkbox", "Label");
end

-- Optional: This function should be used to draw to the screen or update form controls
-- When emulation is running it will be called once per frame
-- When emulation is paused it will be called as fast as possible
function Game.drawUI()
	forms.settext(ScriptHawk.UI.form_controls["Example Value Label"], labelValue);
end

-- Optional: This function will be executed when a savestate is loaded, before the call to Game.eachFrame()
function Game.onLoadState()
	print("Savestate loaded!");
end

-- Optional: This function will be executed once per frame
function Game.eachFrame()
	if ScriptHawk.UI.isChecked("Example Checkbox") then
		print("Example checkbox is checked!");
	end
end

-- Optional: This function will be executed as fast as possible
function Game.realTime()
	-- TODO
end

Game.OSDPosition = {2, 76}; -- Optional: OSD position in pixels from the top left corner of the screen, defaults to 2, 76 if not set by a game module
Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition, Game.colorYPosition}, -- A third parameter can be added to these table entries, a function that returns a 32 bit int AARRGGBB color value for that OSD entry
	{"Z", Game.getZPosition, category="position"}, -- A category tag can be added for modifyOSD(). If no tag is added, then the osd line is unmodifyable
	{"Separator"},
	{"dY"},
	{"dXZ"},
	{"Separator"},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator"},
	{"Rot. X", Game.getXRotation},
	{"Facing", Game.getYRotation},
	{"Rot. Z", Game.getZRotation},
};

return Game; -- Return your Game table to ScriptHawk