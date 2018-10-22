if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	squish_memory_table = true,
	Memory = { -- Version order: USA N64, Europe N64
		current_animal_list_index = {0x3D5534, 0x3D5624},
		animal_list_pointer_base = {0x1DDD88, 0x1DDDA8},
		map_index = {0x3F2D39, 0x3F2E29},
	},
	rot_speed = 10,
	max_rot_units = 360,
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 },
	speedy_index = 7,
	takeMeThereType = "Checkbox",
};

local max_health = 0x82;
local max_A_skill = 0x400;
local max_B_skill = 0x400;

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

function Game.getCurrentAnimalIndex()
	return mainmemory.read_u16_be(Game.Memory.current_animal_list_index);
end

function Game.getAnimalVariablePointer(levelAnimalIndex)
	return dereferencePointer(levelAnimalIndex * 0x08 + Game.Memory.animal_list_pointer_base + 0x04);
end

function Game.getCurrentAnimalVariablePointer()
	return Game.getAnimalVariablePointer(Game.getCurrentAnimalIndex());
end

function Game.getAnimalInfoPointer(levelAnimalIndex)
	local animalObjectPointer = dereferencePointer(levelAnimalIndex * 0x08 + Game.Memory.animal_list_pointer_base);
	if isRDRAM(animalObjectPointer) then
		return animalObjectPointer;
	end
end

function Game.getCurrentAnimalInfoPointer()
	return Game.getAnimalInfoPointer(Game.getCurrentAnimalIndex());
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

function Game.getAnimalType(levelAnimalIndex)
	local animalType = Game.getAnimalInfoPointer(levelAnimalIndex);
	if isRDRAM(animalType) then
		animalType = mainmemory.read_u16_be(animalType + animal_struct_offsets.animal_type);
		return animalTypes[animalType] or "Unknown ("..toHexString(animalType)..")";
	else
		return " ";
	end
end

function Game.getCurrentAnimalType()
	return Game.getAnimalType(Game.getCurrentAnimalIndex());
end

--------------
-- Position --
--------------

-- Player Specific
function Game.getXPosition()
	return Game.getAnimalXPosition(Game.getCurrentAnimalIndex());
end

function Game.getYPosition()
	return Game.getAnimalYPosition(Game.getCurrentAnimalIndex());
end

function Game.getZPosition()
	return Game.getAnimalZPosition(Game.getCurrentAnimalIndex());
end

function Game.setXPosition(value)
	return Game.setAnimalXPosition(value, Game.getCurrentAnimalIndex());
end

function Game.setYPosition(value)
	return Game.setAnimalYPosition(value, Game.getCurrentAnimalIndex());
end

function Game.setZPosition(value)
	return Game.setAnimalZPosition(value, Game.getCurrentAnimalIndex());
end

-- Current map animals
function Game.getAnimalXPosition(levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		return mainmemory.read_u32_be(animalPointer + animal_variable_offsets.x_position) / 0x10000;
	end
	return 0;
end

function Game.getAnimalYPosition(levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		return mainmemory.read_u32_be(animalPointer + animal_variable_offsets.y_position) / 0x10000;
	end
	return 0;
end

function Game.getAnimalZPosition(levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		return mainmemory.read_u32_be(animalPointer + animal_variable_offsets.z_position) / 0x10000;
	end
	return 0;
end

function Game.setAnimalXPosition(value,levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.x_position, value * 0x10000);
	end
end

function Game.setAnimalYPosition(value,levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.y_position, value * 0x10000);
		Game.setAnimalYVelocity(0, levelAnimalIndex);
	end
end

function Game.setAnimalZPosition(value,levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.z_position, value * 0x10000);
	end
end

--------------
-- Rotation --
--------------

-- Player specific
function Game.getYRotation()
	return Game.getAnimalYRotation(Game.getCurrentAnimalIndex());
end

function Game.setYRotation(value)
	return Game.setAnimalYRotation(value, Game.getCurrentAnimalIndex());
end

-- Current map animals
function Game.getAnimalYRotation(levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		return mainmemory.read_u16_be(animalPointer + animal_variable_offsets.y_rotation);
	end
	return 0;
end

function Game.setAnimalYRotation(value, levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		mainmemory.write_u16_be(animalPointer + animal_variable_offsets.y_rotation, value);
	end
end

--------------
-- Velocity --
--------------

-- Player specific
function Game.getXVelocity()
	return Game.getAnimalXVelocity(Game.getCurrentAnimalIndex());
end

function Game.getYVelocity()
	return Game.getAnimalYVelocity(Game.getCurrentAnimalIndex());
end

function Game.getZVelocity()
	return Game.getAnimalZVelocity(Game.getCurrentAnimalIndex());
end

function Game.setXVelocity(value)
	return Game.setAnimalXVelocity(value, Game.getCurrentAnimalIndex());
end

function Game.setYVelocity(value)
	return Game.setAnimalYVelocity(value, Game.getCurrentAnimalIndex());
end

function Game.setZVelocity(value)
	return Game.setAnimalZVelocity(value, Game.getCurrentAnimalIndex());
end

function Game.getVelocity() -- Calculated vXZ
	return Game.getAnimalVelocity(Game.getCurrentAnimalIndex());
end

-- Current map animals
function Game.getAnimalXVelocity(levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		return mainmemory.read_u16_be(animalPointer + animal_variable_offsets.x_velocity) / 0x10000;
	end
	return 0;
end

function Game.getAnimalYVelocity(levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		return mainmemory.read_u16_be(animalPointer + animal_variable_offsets.y_velocity) / 0x10000;
	end
	return 0;
end

function Game.getAnimalZVelocity(levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		return mainmemory.read_u16_be(animalPointer + animal_variable_offsets.z_velocity) / 0x10000;
	end
	return 0;
end

function Game.setAnimalXVelocity(value, levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.x_velocity, value * 0x10000);
	end
end

function Game.setAnimalYVelocity(value, levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		animalPointer = animalPointer + animal_variable_offsets.y_velocity;
		mainmemory.write_u32_be(animalPointer, value * 0x10000);
	end
end

function Game.setAnimalZVelocity(value, levelAnimalIndex)
	local animalPointer = Game.getAnimalVariablePointer(levelAnimalIndex);
	if isRDRAM(animalPointer) then
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.z_velocity, value * 0x10000);
	end
end

function Game.getAnimalVelocity(levelAnimalIndex) -- Calculated vXZ
	local vX = Game.getAnimalXVelocity(levelAnimalIndex);
	local vZ = Game.getAnimalZVelocity(levelAnimalIndex);
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
	mainmemory.writebyte(Game.Memory.map_index, index);
end

function Game.applyInfinites()
	local animalPointer = Game.getCurrentAnimalVariablePointer();
	if isRDRAM(animalPointer) then
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.health, max_health * 0x10000);
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.A_skill_energy, max_A_skill * 0x10000);
		mainmemory.write_u32_be(animalPointer + animal_variable_offsets.B_skill_energy, max_B_skill * 0x10000);
	end
end

Game.OSD = {
	{"Animal", Game.getCurrentAnimalType, category="animal"},
	{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"Velocity", Game.getVelocity, category="speed"},
	{"Separator"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"},
	--{"Rot. X", Game.getXRotation, category="angleMore"},
	{"Facing", Game.getYRotation, category="angle"},
	--{"Rot. Z", Game.getZRotation, category="angleMore"},
};

return Game;