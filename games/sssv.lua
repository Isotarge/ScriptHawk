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
	["current_animal_list_index"] = {0x3D5534, 0x200000}, -- Example addresses
	["animal_list_pointer_base"] = {0x1DDD88, 0x200000},
	--["map_index"] = {0x10000C, 0x20000C},
};



function Game.detectVersion(romName, romHash) -- Modules should ideally use ROM hash rather than name, but both are passed in by ScriptHawk
	if romHash == "E5E09205AA743A9E5043A42DF72ADC379C746B0B" then --USA
		version = 1;
	elseif romHash == "BB359A75941DF74BF7290212C89FBC6E2C5601FE" then --Europe
		version = 2;
	else
		return false; -- Return false if this version of the game is not supported
	end

	return true; -- Return true if version detection is successful
end
---------------------------
-- Animal Variable Offsets --
---------------------------
local animal_variable_offsets = {
	x_position = 0x04,
	z_position = 0x08,
	y_position = 0x0C,
	
	x_velocity = 0x1C,
	z_velocity = 0x20,
	y_velocity = 0x24,
	
	y_rotation = 0x2C,
	
	health = 0x14C,
};

---------------------------
-- Animal Struct Offsets --
---------------------------
local animal_struct_offsets = {
	animal_type = 0x9C,
};

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 }; -- D-Pad speeds, scale these appropriately with your game's coordinate system
Game.speedy_index = 7;

function Game.isPhysicsFrame() -- Optional: If lag in your game is more complicated than a simple emu.islagged() call you should add the logic to detect it here
	-- Implementing this logic will result in smooth dY/dXZ calculation (no more flickering between 0 and the correct value)
	return not emu.islagged();
end



function Game.getCurrentAnimalVariablePointer()
	local animalObjectPointer = dereferencePointer(mainmemory.read_u16_be(Game.Memory.current_animal_list_index[version])*0x08+Game.Memory.animal_list_pointer_base[version]+0x04);
	if isRDRAM(animalObjectPointer) then
		return animalObjectPointer
	else
		return nil
	end
end

function Game.getCurrentAnimalInfoPointer()
	local animalObjectPointer = dereferencePointer(mainmemory.read_u16_be(Game.Memory.current_animal_list_index[version])*0x08+Game.Memory.animal_list_pointer_base[version]);
	if isRDRAM(animalObjectPointer) then
		return animalObjectPointer
	else
		return nil
	end
end

-----------------
-- Animal Type --
-----------------
local animalTypes = {
	[0] = "Null",
	
	[0x04] = "Racing Dog",
	
	[0x12] = "Racing Mouse",
	
	[0x16] = "Bear",
	
	[0x18] = "Racing Bear",
	
	[0x1A] = "Racing Fox",
	
	[0x1F] = "Dog",
	[0x20] = "Rat",
	[0x21] = "Sheep",
	[0x22] = "Ram",
	
	[0x3D] = "EVO",

	[0x3F] = "EVO (Transfer)",
}

function Game.getCurrentAnimalType()
	local currentAnimalType = Game.getCurrentAnimalInfoPointer();
	currentAnimalType = mainmemory.read_u16_be(currentAnimalType+animal_struct_offsets.animal_type);
	if type(animalTypes[currentAnimalType]) ~= "nil" then
		return animalTypes[currentAnimalType];
	else
		return "Unknown ("..toHexString(currentAnimalType)..")";
	end
end



--------------
-- Position --
--------------

function Game.getXPosition()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.read_u32_be(animalPointer+animal_variable_offsets.x_position)/0xFFFF;
end

function Game.getYPosition()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.read_u32_be(animalPointer+animal_variable_offsets.y_position)/0xFFFF;
end

function Game.colorYPosition()
	local yPosition = Game.getYPosition();
	if yPosition < 0 then
		 --Color Y position values less than 0 red
		 --Format 0xAARRGGBB
		return 0xFFFF0000;
	end
end

function Game.getZPosition()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.read_u32_be(animalPointer+animal_variable_offsets.z_position)/0xFFFF;
end

function Game.setXPosition(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.write_u32_be(animalPointer+animal_variable_offsets.x_position, value*0xFFFF);
end

function Game.setYPosition(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.write_u32_be(animalPointer+animal_variable_offsets.y_position, value*0xFFFF);
end

function Game.setZPosition(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.write_u32_be(animalPointer+animal_variable_offsets.z_position, value*0xFFFF);
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
	return 0x00;
end

function Game.getYRotation() -- Optional
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.read_u16_be(animalPointer+animal_variable_offsets.y_rotation);
end

function Game.getZRotation() -- Optional
	--return mainmemory.readfloat(Game.Memory.z_rotation[version], true);
	return 0x00;
end

function Game.setXRotation(value) -- Optional
	--mainmemory.writefloat(Game.Memory.x_rotation[version], value, true);
	return 0x00;
end

function Game.setYRotation(value) -- Optional
	function Game.getYRotation() -- Optional
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.write_u16_be(animalPointer+animal_variable_offsets.y_rotation, value);
end
end

function Game.setZRotation(value) -- Optional
	--mainmemory.writefloat(Game.Memory.z_rotation[version], value, true);
	return 0x00;
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.read_u16_be(animalPointer+animal_variable_offsets.x_velocity)/0xFFFF;
end

function Game.getYVelocity()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.read_u16_be(animalPointer+animal_variable_offsets.y_velocity)/0xFFFF;
end

function Game.colorYVelocity()
	if Game.getYVelocity() <= clip_vel then
		return 0xFF00FF00; -- Green
	end
end

function Game.getZVelocity()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.read_u16_be(animalPointer+animal_variable_offsets.z_velocity)/0xFFFF;
end

function Game.setXVelocity(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.write_u32_be(animalPointer+animal_variable_offsets.x_velocity, value*0xFFFF);
end

function Game.setYVelocity(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.write_u32_be(animalPointer+animal_variable_offsets.x_velocity, value*0xFFFF);
end

function Game.setZVelocity(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	return mainmemory.write_u32_be(animalPointer+animal_variable_offsets.x_velocity, value*0xFFFF);
end

function Game.getVelocity() -- Calculated VXZ
	local vX = Game.getXVelocity();
	local vZ = Game.getZVelocity();
	return math.sqrt(vX*vX + vZ*vZ);
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
	--mainmemory.writebyte(Game.Memory.map_index[version], index);
end

function Game.applyInfinites() -- Optional: Toggled by a checkbox. If this function is not present in the module, the checkbox will not appear
	-- TODO: Give the player infinite consumables
end

local labelValue = 0;
function Game.initUI() -- Optional: Init any UI state here, mainly useful for setting up your form controls. Runs once at startup after successful version detection.
	-- Here are some examples for the most common UI control types
	ScriptHawk.UI.form_controls["Example Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, {"Option 1", "Option 2", "Option 3"}, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 7, ScriptHawk.UI.button_height);
	--ScriptHawk.UI.form_controls["Example Button"] = forms.button(ScriptHawk.UI.options_form, "Label", flagSetButtonHandler, ScriptHawk.UI.col(10), ScriptHawk.UI.row(7), 59, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Example Plus Button"] = forms.button(ScriptHawk.UI.options_form, "-", function() labelValue = labelValue + 1 end, ScriptHawk.UI.col(13) - 7, ScriptHawk.UI.row(6), ScriptHawk.UI.button_height, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Example Minus Button"] = forms.button(ScriptHawk.UI.options_form, "+", function() labelValue = labelValue - 1 end, ScriptHawk.UI.col(13) + ScriptHawk.UI.button_height - 7, ScriptHawk.UI.row(6), ScriptHawk.UI.button_height, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Example Value Label"] = forms.label(ScriptHawk.UI.options_form, "0", ScriptHawk.UI.col(13) + ScriptHawk.UI.button_height + 21, ScriptHawk.UI.row(6) + ScriptHawk.UI.label_offset, 54, 14);
	ScriptHawk.UI.form_controls["Example Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Label", ScriptHawk.UI.col(10) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);
end

-- Optional: This function should be used to draw to the screen or update form controls
-- When emulation is running it will be called once per frame
-- When emulation is paused it will be called as fast as possible
function Game.drawUI()
	forms.settext(ScriptHawk.UI.form_controls["Example Value Label"], labelValue);
end

function Game.eachFrame() -- Optional: This function will be executed once per frame
	-- TODO
end

function Game.realTime() -- Optional: This function will be executed as fast as possible
	-- TODO
end

Game.OSDPosition = {2, 70}; -- Optional: OSD position in pixels from the top left corner of the screen, defaults to 2, 70 if not set by a game module
Game.OSD = {
	{"Animal", Game.getCurrentAnimalType},
	{"Separator", 1},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition, Game.colorYPosition}, -- A third parameter can be added to these table entries, a function that returns a 32 bit int AARRGGBB color value for that OSD entry
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