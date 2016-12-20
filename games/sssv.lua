local Game = {
	Memory = { -- Version order: USA N64, Europe N64
		["current_animal_list_index"] = {0x3D5534, 0x3D5624},
		["animal_list_pointer_base"] = {0x1DDD88, 0x1DDDA8},
		["map_index"] = {0x3F2D39, 0x3F2E29},
	},
	rot_speed = 10,
	max_rot_units = 360,
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 },
	speedy_index = 7,
	takeMeThereType = "Checkbox",
};

--------------------
-- Region/Version --
--------------------

local max_health = 0x82;
local max_A_skill = 0x400;
local max_B_skill = 0x400;

function Game.detectVersion(romName, romHash)
	if romHash == "E5E09205AA743A9E5043A42DF72ADC379C746B0B" then -- USA N64
		version = 1;
		return true;
	elseif romHash == "23710541BB3394072740B0F0236A7CB1A7D41531" then -- Europe N64
		version = 2;
		return true;
	end
	return false;
end

-----------------------------
-- Animal Variable Offsets --
-----------------------------
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

function Game.getCurrentAnimalVariablePointer()
	local animalObjectPointer = dereferencePointer(mainmemory.read_u16_be(Game.Memory.current_animal_list_index[version]) * 0x08 + Game.Memory.animal_list_pointer_base[version] + 0x04);
	if isRDRAM(animalObjectPointer) then
		return animalObjectPointer;
	end
end

function Game.getCurrentAnimalInfoPointer()
	local animalObjectPointer = dereferencePointer(mainmemory.read_u16_be(Game.Memory.current_animal_list_index[version]) * 0x08 + Game.Memory.animal_list_pointer_base[version]);
	if isRDRAM(animalObjectPointer) then
		return animalObjectPointer;
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
};

function Game.getCurrentAnimalType()
	local currentAnimalType = Game.getCurrentAnimalInfoPointer();
	if isRDRAM(currentAnimalType) then
		currentAnimalType = mainmemory.read_u16_be(currentAnimalType + animal_struct_offsets.animal_type);
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
		return mainmemory.read_u32_be(animalPointer + animal_variable_offsets.x_position) / 0x10000;
	end
	return 0;
end

function Game.getYPosition()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		return mainmemory.read_u32_be(animalPointer + animal_variable_offsets.y_position) / 0x10000;
	end
	return 0;
end

function Game.getZPosition()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		return mainmemory.read_u32_be(animalPointer + animal_variable_offsets.z_position) / 0x10000;
	end
	return 0;
end

function Game.setXPosition(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.x_position, value * 0x10000);
	end
end

function Game.setYPosition(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.y_position, value * 0x10000);
		Game.setYVelocity(0);
	end
end

function Game.setZPosition(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.z_position, value * 0x10000);
	end
end

--------------
-- Rotation --
--------------

function Game.getYRotation()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		return mainmemory.read_u16_be(animalPointer + animal_variable_offsets.y_rotation);
	end
	return 0;
end

function Game.setYRotation(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		mainmemory.write_u16_be(animalPointer + animal_variable_offsets.y_rotation, value);
	end
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		return mainmemory.read_u16_be(animalPointer + animal_variable_offsets.x_velocity) / 0x10000;
	end
	return 0;
end

function Game.getYVelocity()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		return mainmemory.read_u16_be(animalPointer + animal_variable_offsets.y_velocity) / 0x10000;
	end
	return 0;
end

function Game.getZVelocity()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		return mainmemory.read_u16_be(animalPointer + animal_variable_offsets.z_velocity) / 0x10000;
	end
	return 0;
end

function Game.setXVelocity(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.x_velocity, value * 0x10000);
	end
end

function Game.setYVelocity(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.y_velocity;
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.y_velocity, value * 0x10000);
	end
end

function Game.setZVelocity(value)
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.z_velocity;
		mainmemory.write_u32_be(animalPointer, value*0x10000);
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
	[0x01] = "Smashing Start",
	[0x02] = "Have A Nice Day",
	[0x03] = "Honeymoon Lagoon",
	[0x04] = "The Battery Farm",
	[0x05] = "The Engine Room",
	[0x06] = "Fat Bear Mountain",
	[0x07] = "Rocky Hard Place",
	[0x08] = "Stinky Sewer",
	[0x09] = "Rat-O-Matic",
	[0x0A] = "Give A Dog A Bonus",
	[0x0B] = "Snow Joke",
	[0x0C] = "Ice 'n' Easy Does It",
	[0x0D] = "Penguin Playpen",
	[0x0E] = "Pinball Blizzard",
	[0x0F] = "Hoppa Choppa",
	[0x10] = "Something Fishy",
	[0x11] = "Walrace 64",
	[0x12] = "Jungle Japes",
	[0x13] = "Jungle Doldrums",
	[0x14] = "Swamp Of Eternal Stench",
	[0x15] = "Weight For It!",
	[0x16] = "Jungle Jumps",
	[0x17] = "Evo's Escape",
	[0x18] = "Fun In The Sun",
	[0x19] = "Hot Cross Buns",
	[0x1A] = "Sting In The Tail",
	[0x1B] = "Borassic Park",
	[0x1C] = "Whirlwind Tour",
	[0x1D] = "Shifting Sands",
	[0x1E] = "Punch up Pyramid",
	[0x1F] = "Big Celebration Parade",
	[0x20] = "!Unknown 0x20",
	[0x21] = "GLITCH LEVEL #1",
	[0x22] = "GLITCH LEVEL #2",
	[0x23] = "Credits",
	[0x24] = "Intro",
};

function Game.setMap(index)
	mainmemory.writebyte(Game.Memory.map_index[version], index);
end

function Game.applyInfinites()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.health, max_health * 0x10000);
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.A_skill_energy, max_A_skill * 0x10000);
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.B_skill_energy, max_B_skill * 0x10000);
	end
end

Game.OSDPosition = {2, 70};
Game.OSD = {
	{"Animal", Game.getCurrentAnimalType},
	{"Separator", 1},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"Y Velocity", Game.getYVelocity},
	{"Velocity", Game.getVelocity},
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

return Game;