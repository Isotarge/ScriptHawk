local Game = {}; -- This table stores the module's API function implementations and game state, it's returned to ScriptHawk at the end of the module code

--------------------
-- Region/Version --
--------------------

local max_health = 0x82;
local max_A_skill = 0x400;
local max_B_skill = 0x400;

Game.Memory = {
	-- Lua has a maximum of 200 local variables per function, we use a table to store memory addresses to get around this
	-- It's a 2 dimensional table, the first dimension is the name of the address
	-- the second dimension is an index for which version of the game was detected, set below by Game.detectVersion()
	-- Examples of how to access the memory address for X Position:
		-- Game.Memory.x_position[version] -- Preferred
		-- Game.Memory["x_position"][version]
		-- Game["Memory"]["x_position"][version]
	["current_animal_list_index"] = {0x3D5534, 0x3D5624}, -- Example addresses
	["animal_list_pointer_base"] = {0x1DDD88, 0x1DDDA8},
	--["map_index"] = {0x10000C, 0x20000C},
};



function Game.detectVersion(romName, romHash) -- Modules should ideally use ROM hash rather than name, but both are passed in by ScriptHawk
	if romHash == "E5E09205AA743A9E5043A42DF72ADC379C746B0B" then --USA
		version = 1;
	elseif romHash == "23710541BB3394072740B0F0236A7CB1A7D41531" then --Europe
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
	
	A_skill_energy = 0x2E0,
	B_skill_energy = 0x2E4
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
	[0x00] = "Seagull",
	[0x01] = "Lion",
	[0x02] = "Hippo",
	
	[0x04] = "Racing Dog",
	[0x05] = "Flying Dog",
	
	[0x0A] = "Rabbit",
	[0x0B] = "Heli-Rabbit",
	
	[0x0D] = "King Rat",
	[0x0E] = "Parrot",
	
	[0x12] = "Racing Mouse",
	
	[0x16] = "Bear",
	
	[0x18] = "Racing Bear",
	
	[0x1A] = "Racing Fox",
	[0x1B] = "Tortoise Tank",
	[0x1C] = "Racing Tortoise",
	
	[0x1E] = "Piranha",
	[0x1F] = "Dog",
	[0x20] = "Rat",
	[0x21] = "Sheep",
	[0x22] = "Ram",
	[0x23] = "Spring Sheep",
	[0x24] = "Spring Ram",
	[0x25] = "Penguin",
	[0x26] = "Polar Bear",
	[0x27] = "Polar Tank",
	[0x28] = "Husky",
	
	[0x2A] = "Ski Husky",
	
	[0x2C] = "Walrus",
	[0x2D] = "Vulture",
	[0x2E] = "Camel",
	[0x2F] = "Cannon Camel",
	
	[0x31] = "Pogo Kangaroo",
	[0x32] = "Boxing Kangaroo",
	[0x33] = "Desert Fox",
	[0x34] = "Armed Desert Fox",
	[0x35] = "Scorpion",
	[0x36] = "Gorilla",
	
	[0x38] = "Elephant",
	[0x39] = "Hyena",
	
	[0x3B] = "Chameleon",
	
	[0x3D] = "EVO (Chip)",
	
	[0x3F] = "EVO (Transfer)",
	
	[0x40] = "King Penguin",

	[0x42] = "Cool Cod",
	[0x43] = "Evo Robot",
}

function Game.getCurrentAnimalType()
	local currentAnimalType = Game.getCurrentAnimalInfoPointer();
	if isRDRAM(currentAnimalType) then
		currentAnimalType = currentAnimalType + animal_struct_offsets.animal_type;
		currentAnimalType = mainmemory.read_u16_be(currentAnimalType);
		if type(animalTypes[currentAnimalType]) ~= "nil" then
			return animalTypes[currentAnimalType];
		else
			return "Unknown ("..toHexString(currentAnimalType)..")";
		end
	else
		return " ";
	end
end



--------------
-- Position --
--------------

function Game.getXPosition()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.x_position;
		return mainmemory.read_u32_be(animalPointer)/0xFFFF;
	else
		return 0;	
	end
end

function Game.getYPosition()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.y_position;
		return mainmemory.read_u32_be(animalPointer)/0xFFFF;
	else
		return 0;	
	end
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
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.z_position;
		return mainmemory.read_u32_be(animalPointer)/0xFFFF;
	else
		return 0;	
	end
end

function Game.setXPosition(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.x_position;
		mainmemory.write_u32_be(animalPointer, value*0xFFFF);
	end
	return;
end

function Game.setYPosition(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.y_position;
		mainmemory.write_u32_be(animalPointer, value*0xFFFF);
		Game.setYVelocity(0);
	end
	return;
end

function Game.setZPosition(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.z_position;
		mainmemory.write_u32_be(animalPointer, value*0xFFFF);
	end
	return;
end

--------------
-- Rotation --
--------------

Game.rot_speed = 10; -- Determines how big a single step is when the D-Pad is in Rotation mode
Game.max_rot_units = 360; -- Maximum value of the Game's native rotation units

-- Rotation units can be fiddly sometimes.
-- These functions can return any number as long as it's consistent between get & set.
-- If the Game.max_rot_units value is correct (and minimum is 0) ScriptHawk will correctly convert in game units to both degrees (default) and radians

function Game.getYRotation() -- Optional
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.y_rotation;
		return mainmemory.read_u16_be(animalPointer);
	else 
		return 0
	end
end

function Game.setYRotation(value) -- Optional
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.y_rotation;
		mainmemory.write_u16_be(animalPointer, value);
	end
	return;
end


--------------
-- Velocity --
--------------

function Game.getXVelocity()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.x_velocity;
		return mainmemory.read_u16_be(animalPointer)/0xFFFF;
	else
		return 0;
	end
	
end

function Game.getYVelocity()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.y_velocity;
		return mainmemory.read_u16_be(animalPointer)/0xFFFF;
	else
		return 0;
	end
end

function Game.colorYVelocity()
	if Game.getYVelocity() <= clip_vel then
		return 0xFF00FF00; -- Green
	end
end

function Game.getZVelocity()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.z_velocity;
		return mainmemory.read_u16_be(animalPointer)/0xFFFF;
	else
		return 0;
	end
end

function Game.setXVelocity(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.x_velocity;
		mainmemory.write_u32_be(animalPointer, value*0xFFFF);
	end
	return
end

function Game.setYVelocity(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.y_velocity;
		mainmemory.write_u32_be(animalPointer, value*0xFFFF);
	end
	return
end

function Game.setZVelocity(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.z_velocity;
		mainmemory.write_u32_be(animalPointer, value*0xFFFF);
	end
	return
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
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		local value = max_health;
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.health, value*0xFFFF);
		value = max_A_skill;
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.A_skill_energy, value*0xFFFF);
		value = max_B_skill;
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.B_skill_energy, value*0xFFFF);
	end
	
	return;
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
	--{"Rot. X", Game.getXRotation},
	{"Facing", Game.getYRotation},
	--{"Rot. Z", Game.getZRotation},
};

return Game; -- Return your Game table to ScriptHawk