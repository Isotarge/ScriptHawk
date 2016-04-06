-----------------------
-- Load JSON library --
-----------------------

--JSON = require "lib.JSON";

-----------------------

object_index = 1;
hide_non_animated = false;
local romName = gameinfo.getromname();

if not bizstring.contains(romName, "Banjo-Kazooie") and not bizstring.contains(romName, "Banjo to Kazooie no Daibouken") then
	print("This game is not currently supported.");
	return false;
end

local version;
local Game = {};

Game.Memory = {
	["x_velocity"] = {0x37CE88, 0x37CFB8, 0x37B6B8, 0x37C4B8},
	["y_velocity"] = {0x37CE8C, 0x37CFBC, 0x37B6BC, 0x37C4BC},
	["z_velocity"] = {0x37CE90, 0x37CFC0, 0x37B6C0, 0x37C4C0},
	["x_position"] = {0x37CF70, 0x37D0A0, 0x37B7A0, 0x37C5A0},
	["y_position"] = {0x37CF74, 0x37D0A4, 0x37B7A4, 0x37C5A4},
	["z_position"] = {0x37CF78, 0x37D0A8, 0x37B7A8, 0x37C5A8},
	["x_rotation"] = {0x37CF10, 0x37D040, 0x37B740, 0x37C540},
	["y_rotation"] = {0x37D060, 0x37D190, 0x37B890, 0x37C690},
	["facing_angle"] = {0x37D060, 0x37D190, 0x37B890, 0x37C690},
	["moving_angle"] = {0x37D064, 0x37D194, 0x37B894, 0x37C694},
	["z_rotation"] = {0x37D050, 0x37D180, 0x37B880, 0x37C680},
	["camera_rotation"] = {0x37E578, 0x37E6A8, 0x37CDA8, 0x37D96C},
	["previous_movement_state"] = {0x37DB30, 0x37DC60, 0x37C360, 0x37D160},
	["current_movement_state"] = {0x37DB34, 0x37DC64, 0x37C364, 0x37D164},
	["level_object_array_pointer"] = {0x36EAE0, 0x36F260, 0x36D760, 0x36E560},
	["struct_array_pointer"] = {nil, nil, nil, 0x36E7C8}, -- TODO: Other versions
};

if bizstring.contains(romName, "Europe") then
	version = 1;
elseif bizstring.contains(romName, "Japan") then
	version = 2;
elseif bizstring.contains(romName, "USA") and bizstring.contains(romName, "Rev A") then
	version = 3;
elseif bizstring.contains(romName, "USA") then
	version = 4;
else
	print("This version of the game is not currently supported.");
	return false;
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
	mainmemory.writefloat(Game.Memory.x_position[version] + 0x10, value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.y_position[version], value, true);
	mainmemory.writefloat(Game.Memory.y_position[version] + 0x10, value, true);

	-- Nullify gravity when setting Y position
	Game.setYVelocity(0);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_position[version], value, true);
	mainmemory.writefloat(Game.Memory.z_position[version] + 0x10, value, true);
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	return mainmemory.readfloat(Game.Memory.x_rotation[version], true);
end

function Game.getYRotation()
	return mainmemory.readfloat(Game.Memory.moving_angle[version], true);
end

function Game.getFacingAngle()
	return mainmemory.readfloat(Game.Memory.facing_angle[version], true);
end

function Game.getZRotation()
	return mainmemory.readfloat(Game.Memory.z_rotation[version], true);
end

function Game.setXRotation(value)
	mainmemory.writefloat(Game.Memory.x_rotation[version], value, true);

	-- Also set the target
	mainmemory.writefloat(Game.Memory.x_rotation[version] + 4, value, true);
end

function Game.setYRotation(value)
	mainmemory.writefloat(Game.Memory.moving_angle[version], value, true);
	mainmemory.writefloat(Game.Memory.facing_angle[version], value, true);
end

function Game.setZRotation(value)
	mainmemory.writefloat(Game.Memory.z_rotation[version], value, true);

	-- Also set the target
	mainmemory.writefloat(Game.Memory.z_rotation[version] + 4, value, true);
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	return mainmemory.readfloat(Game.Memory.x_velocity[version], true);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity[version], true);
end

function Game.colorYVelocity()
	if Game.getYVelocity() <= clip_vel then
		return 0xFF00FF00; -- Green
	end
end

function Game.getZVelocity()
	return mainmemory.readfloat(Game.Memory.z_velocity[version], true);
end

function Game.setXVelocity(value)
	return mainmemory.writefloat(Game.Memory.x_velocity[version], value, true);
end

function Game.setYVelocity(value)
	return mainmemory.writefloat(Game.Memory.y_velocity[version], value, true);
end

function Game.setZVelocity(value)
	return mainmemory.writefloat(Game.Memory.z_velocity[version], value, true);
end

-- Calculated VXZ
function Game.getVelocity()
	local VX = Game.getXVelocity();
	local VZ = Game.getZVelocity();
	return math.sqrt(VX*VX + VZ*VZ);
end

-- Slot data
local slot_base = 0x08;
local slot_size = 0x180;
local max_slots = 0x100;

-- Relative to slot start
slot_variables = {
	[0x00] = {["Type"] = "Pointer"}, -- TODO: Does this have anything to do with that huge linked list? Doesn't seem to
	[0x04] = {["Type"] = "Float", ["Name"] = {"X", "X Pos", "X Position"}},
	[0x08] = {["Type"] = "Float", ["Name"] = {"Y", "Y Pos", "Y Position"}},
	[0x0C] = {["Type"] = "Float", ["Name"] = {"Z", "Z Pos", "Z Position"}},
	[0x10] = {["Type"] = "u8", ["Name"] = "State"},

	[0x14] = {["Type"] = "Pointer", ["Name"] = "Animation Object Pointer", ["Fields"] = {
		[0x00] = {["Type"] = "Pointer"},
		[0x38] = {["Type"] = "u16_be", ["Name"] = "Animation Type"},
		[0x3C] = {["Type"] = "Float", ["Name"] = "Animation Timer"},
	}},
	[0x18] = {["Type"] = "Pointer"},

	[0x1C] = {["Type"] = "Float"},
	[0x20] = {["Type"] = "Float"},
	[0x24] = {["Type"] = "Float"},

	[0x28] = {["Type"] = "Float", ["Name"] = "Chase Velocity"},
	[0x2C] = {["Type"] = "Float"},
	[0x30] = {["Type"] = "Float"},

	[0x38] = {["Type"] = "u16_be", ["Name"] = "Movement Timer"},
	[0x3B] = {["Type"] = "Byte", ["Name"] = "Movement State"},

	[0x48] = {["Type"] = "Float", ["Name"] = "Race path progression"},
	[0x4C] = {["Type"] = "Float", ["Name"] = "Speed (rubberband)"},

	[0x50] = {["Type"] = "Float", ["Name"] = {"Facing Angle", "Facing", "Rot Y", "Rot. Y", "Y Rotation"}},

	[0x60] = {["Type"] = "Float", ["Name"] = "Recovery Timer"}, -- TTC Crab

	[0x64] = {["Type"] = "Float", ["Name"] = {"Moving Angle", "Moving", "Rot Y", "Rot. Y", "Y Rotation"}},
	[0x68] = {["Type"] = "Float", ["Name"] = {"Rot X", "Rot. X", "X Rotation"}},

	[0x7C] = {["Type"] = "Float", ["Name"] = "Popped Amount"},
	[0x80] = {["Type"] = "Float"},
	[0x84] = {["Type"] = "Float", ["Name"] = "Countdown timer?"},

	[0x90] = {["Type"] = "Float"},
	[0x94] = {["Type"] = "Float"},
	[0x98] = {["Type"] = "Float"},

	[0xBC] = {["Type"] = "u32_be", ["Name"] = "Spawn Actor ID"}, -- TODO: Better name for this, lifted from Runehero's C source
	[0xEB] = {["Type"] = "Byte", ["Name"] = "Flag 2"}, -- TODO: Better name for this, lifted from Runehero's C source

	[0x100] = {["Type"] = "Pointer"},
	[0x104] = {["Type"] = "Pointer"},

	[0x114] = {["Type"] = "Float", ["Name"] = "Sound timer?"}, -- Also used by Conga to decide when to throw orange
	[0x118] = {["Type"] = "Float"},
	[0x11C] = {["Type"] = "Float"},
	[0x120] = {["Type"] = "Float"},

	[0x125] = {["Type"] = "Byte", ["Name"] = "Transparancy"},
	[0x127] = {["Type"] = "Byte", ["Name"] = "Eye State"},
	[0x128] = {["Type"] = "Float", ["Name"] = "Scale"},

	[0x12C] = {["Type"] = "Pointer"},
	[0x130] = {["Type"] = "Pointer"},
	[0x14C] = {["Type"] = "Pointer", ["Name"] = "Bone Array 1 Pointer"},
	[0x150] = {["Type"] = "Pointer", ["Name"] = "Bone Array 2 Pointer"},

	[0x170] = {["Type"] = "Float"},
	[0x174] = {["Type"] = "Float"},
	[0x178] = {["Type"] = "Float"},
};

local function fillBlankVariableSlots()
	local data_size = 0x04;
	for i = 0, slot_size - data_size, data_size do
		if type(slot_variables[i]) == "nil" then
			slot_variables[i] = {["Type"] = "Z4_Unknown"};
		end
	end
end
fillBlankVariableSlots();

local slot_data = {};

local RDRAMBase = 0x80000000;
local RDRAMSize = 0x400000; -- Doubled with expansion pak

-- Checks whether a value falls within N64 RDRAM
local function isRDRAM(value)
	return type(value) == "number" and value >= 0 and value < RDRAMSize;
end

-- Checks whether a value is a pointer
local function isPointer(value)
	return type(value) == "number" and value >= RDRAMBase and value < RDRAMBase + RDRAMSize;
end

--------------------
-- Output Helpers --
--------------------

function isBinary(var_type)
	return var_type == "Binary" or var_type == "Bitfield" or var_type == "Byte" or var_type == "Flag" or var_type == "Boolean";
end

function isHex(var_type)
	return var_type == "Hex" or var_type == "Pointer" or var_type == "Z4_Unknown";
end

-- TOOD: Use ScriptHawks' beefy implementation
function toHexString(value)
	value = string.format("%X", value or 0);
	if string.len(value) % 2 ~= 0 then
		value = "0"..value;
	end
	return "0x"..value;
end

function formatForOutput(var_type, value)
	if isBinary(var_type) then
		local binstring = bizstring.binary(value);
		if binstring ~= "" then
			return binstring;
		end
		return "0";
	elseif isHex(var_type) then
		return toHexString(value);
	end
	return ""..value;
end

function isInteresting(variable)
	local min = get_minimum_value(variable);
	local max = get_maximum_value(variable);
	return slot_variables[variable].Type ~= "Z4_Unknown" or min ~= max;
end

function getVariableName(address)
	local variable = slot_variables[address];
	local nameType = type(variable.Name);

	if nameType == "string" then
		return variable.Name;
	elseif nameType == "table" then
		return variable.Name[1];
	end

	return variable.Type.." "..toHexString(address);
end

------------
-- Output --
------------

function output_slot(index)
	if type(slot_data[index]) ~= "nil" then
		local previous_type = "";
		local current_slot = slot_data[index + 1];
		print("Starting output of slot "..index + 1);
		for i = 0, slot_size do
			if type(slot_variables[i]) == "table" then
				if slot_variables[i].Type ~= "Z4_Unknown" then
					if slot_variables[i].Type ~= previous_type then
						previous_type = slot_variables[i].Type;
						print("");
					end
					local variableName = getVariableName(i);
					print(toHexString(i).." "..variableName.." ("..(slot_variables[i].Type).."): "..formatForOutput(slot_variables[i].Type, current_slot[i]));
				end
			end
		end
	end
end
outputSlot = output_slot;

function output_stats()
	if #slot_data == 0 then
		print("Error: Slot data is empty, please run parseSlotData()");
		return;
	end
	print("------------------------------");
	print("-- Starting output of stats --");
	print("------------------------------");
	local min, max;
	local previous_type = "";
	for i = 0, slot_size do
		if type(slot_variables[i]) == "table" then
			if isInteresting(i) then
				min = get_minimum_value(i);
				max = get_maximum_value(i);
				if slot_variables[i].Type ~= previous_type then
					previous_type = slot_variables[i].Type;
					print("");
				end
				local variableName = getVariableName(i);
				print(toHexString(i).." "..(slot_variables[i].Type)..": "..formatForOutput(slot_variables[i].Type, min).. " to "..formatForOutput(slot_variables[i].Type, max).." - "..variableName);
			end
		end
	end
end
outputStats = output_stats;

function format_slot_data()
	local formatted_data = {};
	local relative_address, variable_data;
	for i = 1, #slot_data do
		formatted_data[i] = {};
		for relative_address, variable_data in pairs(slot_variables) do
			if type(variable_data) == "table" and isInteresting(relative_address) then
				local variableName = getVariableName(relative_address);
				formatted_data[i][toHexString(relative_address).." "..variableName] = {
					["Type"] = variable_data.Type,
					["Value"] = formatForOutput(variable_data.Type, slot_data[i][relative_address])
				};
			end
		end
	end
	return formatted_data;
end
formatSlotData = format_slot_data;

function json_slots()
	local json_data = JSON:encode_pretty(format_slot_data());
	local file = io.open("Lua/ScriptHawk/Level_Object_Array.json", "w+");
	if type(file) ~= "nil" then
		io.output(file);
		io.write(json_data);
		io.close(file);
	else
		print("Error writing to file =(");
	end
end
jsonSlots = json_slots;

--------------------
-- "Struct" stuff --
--------------------

struct_slot_size = 0x60;
struct_array_variables = {
	[0x00] = {["Name"] = "Renderer Pointer", ["Type"] = "Pointer", ["Fields"] = {
		[0x0E] = {["Name"] = "scale", ["Type"] = "u16_be"},
		[0x10] = {["Name"] = "x_pos", ["Type"] = "s16_be"},
		[0x12] = {["Name"] = "y_pos", ["Type"] = "s16_be"},
		[0x14] = {["Name"] = "z_pos", ["Type"] = "s16_be"},
	}},
	[0x04] = {["Name"] = "Unknown Pointer 0x04", ["Type"] = "Pointer"},
	[0x08] = {["Name"] = "Unknown Pointer 0x08", ["Type"] = "Pointer"},
};

function getStructData(pointer)
	local structData = {};
	table.insert(structData, {"Slot Base", toHexString(pointer)});
	table.insert(structData, {"Separator", 1});

	local rendererPointer = mainmemory.read_u32_be(pointer);
	if isPointer(rendererPointer) then
		rendererPointer = rendererPointer - RDRAMBase;
		table.insert(structData, {"Renderer Pointer", toHexString(rendererPointer)});
		table.insert(structData, {"Separator", 1});
		table.insert(structData, {"X", mainmemory.read_s16_be(rendererPointer + 0x10)});
		table.insert(structData, {"Y", mainmemory.read_s16_be(rendererPointer + 0x12)});
		table.insert(structData, {"Z", mainmemory.read_s16_be(rendererPointer + 0x14)});
		table.insert(structData, {"Scale", mainmemory.read_u16_be(rendererPointer + 0x0E)});
		table.insert(structData, {"Separator", 1});
	end
	table.insert(structData, {"Unknown Pointer 0x04", toHexString(mainmemory.read_u32_be(pointer + 0x04))});
	table.insert(structData, {"Unknown Pointer 0x08", toHexString(mainmemory.read_u32_be(pointer + 0x08))});
	table.insert(structData, {"Unknown Pointer 0x10", toHexString(mainmemory.read_u32_be(pointer + 0x10))});
	table.insert(structData, {"Unknown Pointer 0x1C", toHexString(mainmemory.read_u32_be(pointer + 0x1C))});
	table.insert(structData, {"Unknown Pointer 0x54", toHexString(mainmemory.read_u32_be(pointer + 0x54))});
	return structData;
end

--------------
-- Analysis --
--------------

function resolveVariableName(name) -- TODO: Get this function working for any object model
	-- Make sure comparisons are case insensitive
	name = string.upper(name);

	-- Comparison loop
	local relative_address, variable_data;
	for relative_address, variable_data in pairs(slot_variables) do
		if type(variable_data) == "table" then
			if type(variable_data.Name) == "string" and string.upper(variable_data.Name) == name then
				return relative_address;
			elseif type(variable_data.Name) == "table" then
				for i = 1, #variable_data.Name do
					if type(variable_data.Name[i]) == "string" and string.upper(variable_data.Name[i]) == name then
						return relative_address;
					end
				end
			end
		end
	end

	-- Default + Error
	print("Variable name: '"..name.."' not found =(");
	return 0x00;
end

function get_minimum_value(variable)
	if type(variable) == "string" then
		variable = resolveVariableName(variable);
	end
	local min = math.huge;
	if type(slot_variables[variable]) == "table" then
		for i = 1, #slot_data do
			min = math.min(min, slot_data[i][variable]);
		end
	end
	return min;
end
getMinimumValue = get_minimum_value;

function get_maximum_value(variable)
	if type(variable) == "string" then
		variable = resolveVariableName(variable);
	end
	local max = -math.huge;
	if type(slot_variables[variable]) == "table" then
		for i = 1, #slot_data do
			max = math.max(max, slot_data[i][variable]);
		end
	end
	return max;
end
getMaximumValue = get_maximum_value;

function get_all_unique(variable)
	if type(variable) == "string" then
		variable = resolveVariableName(variable);
	end
	if type(slot_variables[variable]) == "table" then
		local unique_values = {};
		local value, count;
		if type(slot_data) ~= "table" or #slot_data == 0 then
			parseSlotData();
		end
		for i = 1, #slot_data do
			value = formatForOutput(slot_variables[variable].Type, slot_data[i][variable]);
			if type(unique_values[value]) ~= "nil" then
				unique_values[value] = unique_values[value] + 1;
			else
				unique_values[value] = 1;
			end
		end

		-- Output the findings
		print("Starting output of variable "..toHexString(variable));
		for value, count in pairs(unique_values) do
			print(""..value.." appears "..count.." times");
		end
	end
end
getAllUnique = get_all_unique;

local animation_object_unknown_pointer = 0x00; -- TODO: Stop using local constants for this stuff, they're in the slot_variables array now
local animation_object_animation_type = 0x38;
local animation_object_animation_timer = 0x3C;

local animation_types = {
	[0x01] = "Banjo Ducking",
	[0x02] = "Banjo Walking (Slow)",
	[0x03] = "Banjo Walking",
	[0x05] = "Banjo Punching",
	[0x07] = "Kazooie Leaving Talon Trot",
	[0x08] = "Banjo Jumping",
	[0x09] = "Banjo Dying",
	[0x0A] = "Banjo Climbing",
	[0x0C] = "Banjo Running",
	[0x0E] = "Banjo Skidding",
	[0x0F] = "Banjo Damaged", -- "Banjo Hit"
	[0x10] = "Bigbutt Charging",
	[0x11] = "Banjo Running (Wonderwing)",
	[0x15] = "Kazooie Walking (Talon Trot)",
	[0x16] = "Kazooie Entering Talon Trot",
	[0x17] = "Kazooie Flutter", -- "Kazooie Hover"
	[0x18] = "Kazooie Feathery Flap",
	[0x19] = "Kazooie Rat-A-Tat Rap (Loop)",
	[0x1A] = "Kazooie Rat-A-Tat Rap (Start)",
	[0x1B] = "Banjo Jumping (Wonderwing)",
	[0x1C] = "Kazooie Beak Barge",
	[0x1D] = "Kazooie Beak Buster",
	[0x21] = "Bigbutt Skidding",
	[0x22] = "Banjo Entering Wonderwing",
	[0x23] = "Banjo (Wonderwing)",
	[0x24] = "Yum-Yum Hopping",
	[0x26] = "Kazooie (Talon Trot)",
	[0x27] = "Kazooie Jumping (Talon Trot)",
	[0x28] = "Banjo Termite Hurt",
	[0x29] = "Banjo Termite Dying",
	[0x2A] = "Kazooie Shooting Egg",
	[0x2B] = "Kazooie Pooping Egg",
	[0x2C] = "Snippet Walking",
	[0x2D] = "Jinjo",
	[0x2E] = "Banjo Jiggy Jig",
	[0x2F] = "Jinjo Help",
	[0x30] = "Gripped Jiggy Jig", -- TODO: Better name
	[0x31] = "Jinjo Hopping",
	[0x32] = "Bigbutt Attacking",
	[0x33] = "Bigbutt Eating",
	[0x34] = "Bigbutt Kill", -- TODO: What is this exactly?
	[0x35] = "Bigbutt Alerted",
	[0x36] = "Bigbutt Walking",
	[0x38] = "Banjo Flying",
	[0x39] = "Banjo Swimming (Surface)",
	[0x3C] = "Banjo Diving",
	[0x3D] = "Banjo Shock Spring", -- TODO: Names
	[0x3E] = "Banjo Fly Crash",
	[0x3F] = "Kazooie Swimming (Underwater)",
	[0x40] = "Kazooie Wading Boots (Start)",
	[0x41] = "Kazooie Wading Boots",
	[0x42] = "Kazooie Wading Boots Walking",
	[0x43] = "Kazooie Starting Beakbomb",
	[0x44] = "Kazooie Turbo Trainers",
	[0x45] = "Kazooie Taking Flight",
	[0x47] = "Kazooie Beak Bomb",
	[0x48] = "Kazooie Shock Spring Start",
	[0x49] = "Kazooie Shock Sprint Jump",
	[0x4B] = "Banjo Backflip",
	[0x4C] = "Banjo Backflip Transition",
	[0x4D] = "Banjo Hurt",
	[0x4E] = "MM Hut Smashing",
	[0x4F] = "Banjo Water Splash",
	[0x51] = "Conga",
	[0x52] = "Conga Hurt",
	[0x53] = "Conga Defeated",
	[0x54] = "Conga Throwing",
	[0x55] = "Conga Beating Chest",
	[0x56] = "Conga Raising Arms",
	[0x57] = "Banjo Swimming", -- TODO: Details, under/surface
	[0x58] = "Banjo Swimming",
	[0x59] = "Banjo Sliding (Back)",
	[0x5A] = "Banjo Sliding (Front)",
	[0x5B] = "Chimpy Hopping",
	[0x5C] = "Chimpy",
	[0x5D] = "Chimpy Walking",
	[0x5E] = "Ticker",
	[0x5F] = "Ticker Walking",
	[0x60] = "Banjo Termite Jumping",
	[0x61] = "Banjo Backflip Ending",
	[0x62] = "Grublin",
	[0x63] = "Grublin Sneaking",
	[0x64] = "Grublin Jumping", -- TODO: Alerted?
	[0x65] = "Beehive Dying",
	[0x66] = "Kazooie Damaged (Talon Trot)",
	[0x67] = "Wading Boots",
	[0x68] = "Banjo Falling",
	[0x69] = "Banjo Riding Tumblar",
	[0x6A] = "Mumbo Sleeping",
	[0x6B] = "Mumbo Waking",
	[0x6C] = "Mumbo",
	[0x6D] = "Mumbo Transforming",
	[0x6E] = "Mumbo Unknown (0x6E)", -- TODO: What is this exactly?
	[0x6F] = "Banjo",
	[0x70] = "Banjo (Underwater)",
	[0x71] = "Banjo Swimming (Slow)",
	[0x72] = "Banjo (Holding Item)",
	[0x73] = "Banjo Walking (Holding Item)",
	[0x77] = "Banjo Lose Minigame",
	[0x78] = "Snacker Swimming",
	[0x79] = "Mumbo Concert Playing Instrument",
	[0x7A] = "Banjo Concert Angry",
	[0x7B] = "Banjo Concert Play",
	[0x7C] = "Banjo Concert End",
	[0x7D] = "Tooty Concert Start",
	[0x7E] = "Banjo Concert Start",
	[0x7F] = "Concert Cutscene",
	[0x80] = "Concert Timer",
	[0x81] = "Concert Unknown (0x81)", -- TODO: What is this exactly?
	[0x82] = "Mumbo Concert Dance",
	[0x83] = "Tooty Concert Dance",
	[0x84] = "Tooty Hopping",
	[0x8C] = "Rareware Logo Falling",
	[0x8F] = "Nintendo Logo Walking",
	[0x90] = "Nintendo Logo Shrugging",
	[0x91] = "Frog Hopping (Concert)",
	[0x92] = "Shrapnel Chasing",
	[0x93] = "Tooty Running (Concert)",
	[0x94] = "Grublin Dying",
	[0x95] = "Kazooie Taunting Banjo",
	[0x96] = "Snippet Recovering",
	[0x97] = "Snipped Dying",
	[0x9A] = "Ripper", -- TODO: Appearing?
	[0x9B] = "Ripper Chasing",
	[0x9D] = "Nibbly Chasing", -- Bat
	[0x9E] = "Tee-Hee",
	[0x9F] = "Tee-Hee Alerted",
	[0xA0] = "Pumpkin Banjo, Walking, Bouncing",
	[0xA1] = "Pumpkin Banjo Jumping",
	[0xA2] = "Conga Throwing", -- Retaliation
	[0xA3] = "Napper Sleeping",
	[0xA4] = "Napper Looking Around",
	[0xA5] = "Napper Waking",
	[0xA6] = "Napper Alerted",
	[0xA7] = "Motzhand",
	[0xA8] = "Motzhand Playing",
	[0xA9] = "Pot", -- MMM
	[0xAA] = "Yum-Yum",
	[0xAB] = "Yum-Yum Eating",
	[0xAC] = "Tee-Hee Chasing",
	[0xAd] = "Nibbly Taking Flight", -- Bat
	[0xAE] = "Nibbly", -- Bat
	[0xB0] = "Banjo Falling",
	[0xB1] = "Banjo Climbing",
	[0xB2] = "Banjo Climbing (Freeze)",
	[0xB3] = "Chump",
	[0xB4] = "Chump Chomping",
	[0xB5] = "Blubber Walking",
	[0xB6] = "Blubber Crying",
	[0xB7] = "Blubber Danceing",
	[0xB8] = "Blubber Running",
	[0xB9] = "Banjo Drowning",
	[0xBC] = "Lockup",
	[0xBB] = "Nipper Tired",
	[0xBE] = "Nipper Hurt",
	[0xBF] = "Nipper Attacking",
	[0xC0] = "Nipper",
	[0xC1] = "Littlebounce", -- TODO: What is this?
	[0xC2] = "Wobblybounce", -- TODO: What is this?
	[0xC3] = "Clanker",
	[0xC4] = "Clanker Mouth Open",
	[0xC5] = "Grabba Appearing",
	[0xC6] = "Grabba Hiding",
	[0xC7] = "Grabba",
	[0xC8] = "Grabba Defeated",
	[0xC9] = "Carpet", -- GV
	[0xCA] = "Gloop Swimming",
	[0xCB] = "Gloop Blowing Bubble",
	[0xCC] = "Banjo Beak Bomb (Ending)",
	[0xCD] = "Green Grate near RBB... (4B1)", -- TODO: Better name
	[0xCE] = "Rubee",
	[0xCF] = "Histup Raised",
	[0xD0] = "Histup Rising",
	[0xD1] = "Rubee's Pot",
	[0xD2] = "Banjo Getting Up",
	[0xD3] = "Banjo Hurt (Beak Bomb)",
	[0xD4] = "Switch Down", -- Witch Switch (MM), Shock Spring Pad Switch (GV Lobby)
	[0xD5] = "Switch Up",
	[0xD6] = "Turbo Trainers",
	[0xD9] = "Gobi",
	[0xDA] = "Gobi Pulling Back",
	[0xDB] = "Flibbit Hopping",
	[0xDC] = "Gobi's Rope Pulling",
	[0xDD] = "Gobi's Rope",
	[0xDF] = "Rubee Petting Toots",
	[0xE0] = "Crocodile Banjo Walking",
	[0xE1] = "Crocodile Banjo",
	[0xE2] = "Histup Peeking", -- Snake
	[0xE3] = "Rubee",
	[0xE4] = "Rubee Playing",
	[0xE5] = "Grabba Shadow Spawning",
	[0xE6] = "Grabba Shadow",
	[0xE7] = "Grabba Shadow Hiding",
	[0xE8] = "Grabba Shadow Defeated",
	[0xE9] = "Slappa Appearing", -- Purple Hand
	[0xEA] = "Slappa Moving",
	[0xEB] = "Slappa Slapping",
	[0xEC] = "Slappa Getting up",
	[0xED] = "Ancient Ones Leave (And appear?)",
	[0xEE] = "Slappa Dying", -- Plays 0.001 seconds before he falls apart
	[0xEF] = "Slappa Hurt",
	[0xF0] = "Mini-Jinxy Eating",
	[0xF1] = "Carpet", -- GV
	[0xF4] = "Gobi Relaxing",
	[0xF6] = "Banjo Punishing Kazooie",
	[0xF7] = "Gobi Happy",
	[0xF8] = "Gobi Running",
	[0xF9] = "Buzzbomb Flying", -- cutscene dragonfly
	[0xFA] = "Flibbit", -- Frog
	[0xFB] = "Flibbit Turning",
	[0xFC] = "Gobi Giving water",
	[0xFD] = "Gobi Getting up",
	[0xFE] = "Trunker Short",
	[0xFF] = "Trunker Growing",
	-- [0x100] = "blagh.noidea", -- (Gobi's Water? 80387CBC) -- TODO: What is this
	[0x101] = "Tanktup's Head",
	[0x102] = "Tanktup's Head Pounded",
	[0x103] = "Tanktup's BL Leg Hit",
	[0x104] = "Tanktup's FL Leg Hit",
	[0x105] = "Tanktup's FR Leg Hit",
	[0x106] = "Tanktup's BR Leg Hit",
	[0x107] = "Tanktup Spawning Jiggy",
	[0x108] = "Sir Slush",
	[0x109] = "Sir Slush Attacking",
	[0x10C] = "Banjo Ducking & Turning",
	[0x10D] = "Banjo Hit (Flying)",
	[0x10E] = "Buzzbomb Prepare charge",
	[0x10F] = "Buzzbomb Charging",
	[0x110] = "Buzzbomb Falling From Sky", -- Concert
	[0x111] = "Buzzbomb Dying",
	[0x112] = "Flibbit Dying (Start)", -- Frog
	[0x113] = "Flibbit Dying (Finish)",
	[0x116] = "Banjo Look Duck", -- TODO: What are these?
	[0x117] = "Jellyfish (Unknown) 0x117", -- TODO: What are these? Whipcrack?
	[0x11B] = "Banjo Throwomg Item", -- TODO: Confirm
	[0x11C] = "Crocodile Banjo Jumping",
	[0x11D] = "Crocodile Banjo Hurt",
	[0x11E] = "Crocodile Banjo Dying",
	[0x11F] = "Walrus Banjo",
	[0x120] = "Walrus Banjo Hopping",
	[0x121] = "Walrus Banjo Jumping",
	[0x122] = "Crocodile Banjo Biting",
	[0x123] = "Crocodile Banjo Grossed Out",
	[0x124] = "Mr. Vile Eating",
	[0x125] = "Red Yumblie Spawning",
	[0x126] = "Red Yumblie Leaving",
	[0x127] = "Red Yumblie",
	[0x128] = "Yellow Grumblie Spawning",
	[0x129] = "Yellow Grumblie Leaving",
	[0x12A] = "Yellow Grumblie",
	[0x12B] = "Tiptup looking around, shrugging",
	[0x12C] = "Tiptup Tapping",
	[0x12D] = "Choir",
	[0x12E] = "Choir Singing",
	[0x12F] = "Choir Hurt",
	[0x130] = "Jinjo Circling (Start)",
	[0x131] = "Jinjo Circling (End)",
	[0x132] = "Floatsam Bouncing",
	[0x133] = "Nipper Dying",
	[0x137] = "Grimlet Attacking", -- Pipe
	[0x138] = "Text Shadow Animation",
	[0x139] = "Bottles Disappearing",
	[0x13A] = "Bottles Appearing",
	[0x13B] = "Bottles Scratching",
	[0x13C] = "Bottles' Molehill", -- Bottles going in
	[0x13D] = "Bottles' Molehill", -- Bottles coming out
	[0x13E] = "Snorkel Swimming",
	[0x13F] = "Snorkel Stuck",
	[0x141] = "Anchor On Snorkel",
	[0x142] = "Anchor Rising",
	[0x143] = "Button", -- Snowman, Xmas tree
	[0x144] = "Jinxy Sniffing",
	[0x145] = "Jinxy Sneezing",
	[0x146] = "Boss Boombox Appearing",
	[0x147] = "Boombox Hopping",
	[0x148] = "Boombox Exploding",
	[0x149] = "Banjo Landing (Damaging)",
	[0x14A] = "Banjo Listening",
	[0x14B] = "Croctus", -- BGS, feed egg
	[0x14C] = "Boggy",
	[0x14D] = "Boggy Hit",
	[0x14E] = "Boggy Laying Down",
	[0x14F] = "Boggy Running",
	[0x150] = "Boggy On Sled",
	[0x151] = "Race Flag Hit",
	[0x152] = "Race Flag",
	[0x153] = "Gold Chest Spawning",
	[0x154] = "Snacker Eating ", -- Shark
	[0x155] = "Snippet Get Up",
	[0x156] = "Mutie Snippet Walking",
	[0x157] = "Mutie Snippet Flip upside down",
	[0x158] = "Mutie Snippet Stuck upside down",
	[0x159] = "Mutie Snippet Get up",
	[0x15A] = "Grille Chompa Attack",
	[0x15B] = "Grille Chompa Dying",
	[0x15C] = "Whiplash",
	[0x15D] = "Whiplash Attack",
	[0x15F] = "Concert Banjo Before Start (Keeps him off screen)",
	[0x160] = "Concert Bug Crawling",
	[0x162] = "Toots",
	[0x163] = "Cutscene Buzzbomb Smack",
	-- [0x164] = "rotatetowardground+nosegrowning and shrinking. (Toots/Happy?)", -- TODO
	[0x165] = "Beehive",
	[0x166] = "Gold Chest Bouncing",
	[0x167] = "Banjo/MoveVeryLittle (used in small cutscenes)",
	-- [0x168] = "twisted, nose really tiny. (BeforeRareLogoAppears)", -- TODO
	-- [0x169] = "BetaVent/Open (Shooting out smoke)", -- TODO
	[0x16B] = "Snare-Bear Snapping",
	[0x16C] = "Snare-Bear",
	[0x16D] = "Twinklie Present Opening",
	[0x16E] = "Mumbo Reclining", -- CCW Summer
	[0x16F] = "Zubba Flying Moving",
	[0x170] = "Zubba Flying",
	[0x171] = "Zubba Falling",
	[0x172] = "Zubba Landing",
	[0x173] = "Flower Sprouting (Spring)",
	[0x174] = "Flower Sprouting (Summer)",
	[0x175] = "Flower Sprouting (Autumn)",
	[0x176] = "Gobi Yawning",
	[0x177] = "Gobi Sleeping",
	[0x178] = "Twinklie Spawning",
	[0x179] = "Boggy Signaling (Speed up slowpoke!)",
	[0x17A] = "Boggy Lookingback (On sled)",
	-- [0x17B] = "Boggy Something.." -- TODO
	[0x17C] = "Twinklie Twinkling",
	[0x17D] = "Spawn of Boggy Happy", -- Groggy, Moggy, Soggy
	[0x17E] = "Spawn of Boggy Sad", -- Groggy, Moggy, Soggy
	[0x17F] = "Mumbo Sweeping",
	[0x180] = "Mumbo Rotating", -- With broom!
	[0x181] = "Flower (Spring)",
	[0x182] = "Flower (Summer)",
	[0x183] = "Flower (Fall)",
	[0x184] = "Big Clucker Attacking (Short)",
	[0x185] = "Big Clucker Attacking (Long)",
	[0x186] = "Big Clucker Dying",
	-- [0x187] rotateodd and go in ground. -- TODO
	[0x188] = "Pumpkin Banjo Dying",
	[0x189] = "Floatsam Dying",
	[0x18A] = "Present", -- FP
	-- [0x18D] = "rotate to standing mode, and back.", -- TODO
	-- [0x18E] = "rock sideways gently", -- TODO
	[0x18F] = "Spring Eyrie Yawn -> Sleep", -- Names
	[0x190] = "Spring Eyrie Baby Sleeping",
	[0x191] = "Summer Eyrie Waiting For Food",
	[0x192] = "Summer Eyrie Finished Eating > Grow",
	[0x193] = "Summer Eyrie Yawn Fall to Ground",
	[0x194] = "Summer Eyrie Sleeping",
	[0x195] = "Fall Eyrie Waiting For Food",
	[0x196] = "Fall Eyrie Finished Eating > Grow",
	[0x197] = "Fall Eyrie Yawn Fall to Ground",
	[0x198] = "Fall Eyrie Sleeping",
	[0x199] = "Winter Eyrie Tweet-Tweet",
	[0x19A] = "Winter Eyire Tweet > Flying",
	[0x19B] = "Banjo Transforming",
	[0x19C] = "Walrus Banjo Hurt",
	[0x19D] = "Walrus Banjo Dying",
	[0x19E] = "Walrus Banjo On Sled",
	[0x19F] = "Walrus Banjo Before Lose Race",
	[0x1A0] = "Unknown Dying (0x1A0)",
	[0x1A1] = "Sled", -- FP
	[0x1A2] = "Nabnut Sleeping",
	[0x1A3] = "Nabnut",
	[0x1A4] = "Nabnut Eating",
	[0x1A6] = "Gnawty",
	[0x1A7] = "Gnawty Happy",
	[0x1A8] = "Gnawty Walking",
	[0x1A9] = "Banjo Walrus Lost Race",
	[0x1AA] = "Boggy Won Race",
	[0x1AB] = "Boggy Lost Race",
	[0x1AC] = "Wozza Holding Jiggy",
	[0x1AD] = "Wozza Handing Jiggy",
	[0x1AE] = "Wozza Hopping Away",
	[0x1AF] = "Twinkly Muncher Dying",
	[0x1B0] = "Twinkly Muncher Appearing", -- NAME
	[0x1B1] = "Twinklie Muncher",
	[0x1B2] = "Twinklie Muncher Munching",
	[0x1B3] = "Wozza Before Stop", -- TODO: Better name
	[0x1B4] = "Wozza Bodyblocking",
	[0x1B5] = "Wozza Giving Jiggy",
	[0x1B6] = "Wozza Throwing...Freezehalfway", -- TODO: Better name
	[0x1B7] = "Green Mist", -- Intro
	[0x1B8] = "Door Opening", -- Intro
	[0x1B9] = "Grunty", -- Intro
	[0x1BB] = "Grunty Picking Nose", -- Intro
	[0x1BD] = "Grunty Angry at Dingpot ", -- Intro
	[0x1BE] = "Grunty Throwing Booger ", -- Intro
	[0x1BF] = "Grunty Shocked > Confused ", -- Intro
	[0x1C0] = "Grunty Walking", -- Intro
	[0x1C2] = "Door Closing", -- Intro
	[0x1C4] = "Grunty's Broomstick Flying", -- Intro
	[0x1C5] = "Grunty Flying", -- Intro
	[0x1C7] = "Banjo Sleeping", -- Intro
	[0x1C8] = "Banjo Waking Up", -- Intro
	[0x1C9] = "Bedsheets Banjo Sleeping", -- Intro
	[0x1CA] = "Bedsheets Banjo Awake", -- Intro
	[0x1CB] = "Kazooie Appearing", -- Intro
	[0x1CD] = "Kazooie Inside Backpack", -- Intro
	[0x1CE] = "Curtain", -- Banjo's house
	[0x1CF] = "Kazooie Uneasy",
	[0x1D0] = "Tooty Hopping",
	[0x1D3] = "Kazooie Waking Banjo",
	[0x1D4] = "Kazooie Falling",
	[0x1D5] = "Tooty Chattering Teeth",
	[0x1D6] = "Grublin Walking",
	[0x1D7] = "Grublin Alerted",
	[0x1D8] = "Grublin Chasing",
	[0x1D9] = "Grublin Dying",
	[0x1DA] = "Snippet",
	[0x1DB] = "Mutie Snippet",
	[0x1DC] = "Bee Banjo Flying",
	[0x1DD] = "Bee Banjo Walking",
	[0x1DE] = "Bee Banjo",
	[0x1DF] = "Bee Banjo Unknown 0x1DF", -- TODO: "tiyhop"
	[0x1E0] = "Bee Banjo Hurt",
	[0x1E1] = "Bee Banjo Dying",
	[0x1E2] = "Bee Banjo Jumping",
	[0x1E3] = "GV Brick Wall Smashing",
	[0x1E4] = "Limbo", -- Skeleton
	[0x1E5] = "Limbo Alerted",
	[0x1E6] = "Limbo Chasing",
	[0x1E7] = "Limbo Breaking",
	[0x1E8] = "Limbo Rising",
	[0x1E9] = "Mum-Mum",
	[0x1EA] = "Mum-Mum Curling",
	[0x1EB] = "Mum-Mum Uncurling",
	[0x1ED] = "Ripper Damaged",
	[0x1EE] = "Ripper Dying",
	-- [0x1EF] = "noseforward>back", -- TODO: Switch?
	[0x1F0] = "Web (Floor)",
	[0x1F1] = "Web Dying (Floor)",
	[0x1F2] = "Web (Wall)",
	[0x1F3] = "Web Dying (Wall)",
	[0x1F4] = "Shrapnel",
	[0x1F5] = "Jiggy Transition",
	-- [0x1F6] = "looks like some diver hitting a ground of play-doh.", -- TODO
	[0x1F7] = "Kazooie Feathers Poof (End intro)", -- TODO: Better names
	[0x1F8] = "Bottles PointAtGrunty",
	[0x1F9] = "Tooty Confused",
	[0x1FA] = "Sexy Grunty Walking",
	[0x1FB] = "Sexy Grunty Checking herself out",
	[0x1FC] = "Ugly Tooty Walking",
	[0x1FD] = "Ugly Tooty Punching",
	[0x1FE] = "Machine Door Opening",
	[0x1FF] = "Machine Door Closing",
	[0x200] = "Static Machine Door Up",
	[0x201] = "Klungo Limping",
	[0x202] = "Klungo Pushing Button",
	[0x204] = "Grunty Falling",
	[0x205] = "Dingpot wap", -- TODO: wat
	[0x206] = "Dingpot",
	[0x207] = "Grunty Crammed in Machine",
	[0x208] = "Goldfish", -- Banjo's house
	[0x209] = "Cuckoo Clock",
	[0x20A] = "Cuckoo Clock Chiming",
	[0x20B] = "Grunty Falling", -- Ending
	-- [0x20C] = "stretch,shrink, arms spread out.", -- TODO
	[0x20D] = "Klungo Lever down",
	[0x20E] = "Machine Lever down", -- Game Over
	[0x20F] = "Klungo Laughing",
	[0x210] = "Machine", -- Ugly Tooty trying to get out
	-- [0x211] = "nosemoveleftright", -- TODO
	[0x212] = "Cauldron Activating",
	[0x213] = "Cauldron Sleeping",
	[0x214] = "Cauldron Activated",
	[0x215] = "Cauldron Teleporting",
	[0x216] = "Cauldron Rejected",
	[0x217] = "Transform Pad",
	-- [0x218] = "spin randomly, nose stretch (Two poles...)", --TODO: Door?
	-- [0x219] = "twistedup.", -- TODO
	[0x21A] = "Eyrie Eating", -- Summer
	[0x21B] = "Eyrie Eating", -- Autumn
	[0x21D] = "Eyrie Flying",
	[0x21E] = "Eyrie Pooping Jiggy",
	[0x220] = "Sir. Slush",
	[0x221] = "Wozza", -- In Cave
	[0x222] = "Boggy Sleeping",
	[0x223] = "Topper", -- Carrot gets it
	[0x224] = "Topper Dying",
	[0x225] = "Colliwobble",
	[0x226] = "Bawl",
	[0x227] = "Bawl Dying",
	-- [0x228] = "Banjo On led", -- TODO: wat
	[0x229] = "Whipcrack Attacking",
	[0x22A] = "Whipcrack",
	[0x22B] = "Nabnut Fat",
	[0x22C] = "Nabnut Crying",
	[0x22D] = "Nabnut Happy",
	[0x22E] = "Nabnut",
	[0x22F] = "Nabnut Running",
	[0x230] = "Mrs. Nanbut Sleeping",
	[0x231] = "Nabnut's Bedsheets",
	-- [0x232] = "freezeani", -- TODO
	[0x233] = "Chinker", -- Ice Cube
	[0x234] = "Snare-Bear (Winter)",
	-- [0x235] = "freezeani?  (Two poles... GV)", -- TODO: Door?
	[0x236] = "Pumpkin Banjo Hurt",
	[0x237] = "Twinklie Present",
	[0x238] = "Loggo Hop",
	[0x239] = "Leaky Hop",
	[0x23A] = "Gobi Fly", -- TODO: is this that scarab beetle thing?
	[0x23B] = "Gobi Fly Prepare Attack",
	[0x23C] = "Gobi Fly Charge",
	[0x23D] = "Gobi Fly Dying",
	[0x23E] = "Portrait Chompa (Picture Monster)",
	[0x23F] = "Portrait",
	[0x240] = "Loggo Flush", -- Toilet
	-- [0x241] = "noidea..", (moveup from ground, hide in ground)
	[0x242] = "Gobi Relaxing",
	[0x243] = "Grublin-Hood",
	[0x244] = "Grublin-Hood Alerted",
	[0x245] = "Grublin-Hood Chasing",
	[0x246] = "Grublin-Hood Dying",
	-- [0x247] = "Nosebounce", -- TODO
	-- [0x248] = "Boingboingbacktensely", -- TODO
	-- [0x249] = "Huge.. Turnaround stop wobble wobble", -- TODO
	[0x24A] = "Banjo Cook Cooking",
	[0x24B] = "Banjo Cook Activated",
	[0x24C] = "Banjo Cook Flip",
	[0x24D] = "Banjo On Bed Sleeping",
	[0x24E] = "Banjo On Bed Activated",
	[0x24F] = "Banjo On Bed Spring",
	[0x250] = "Banjo Playing Gameboy",
	[0x251] = "Banjo Playing Gameboy Activated",
	[0x252] = "Banjo Playing Gameboy Spring",
	[0x253] = "Big Butt Hit ", -- Bull
	[0x254] = "Big Butt Fall",
	[0x255] = "Big Butt Get Up",
	-- [0x256] = "move up from ground, go back down.",
	[0x257] = "Grunty Green Spell", -- Flying
	[0x258] = "Grunty Hurt",
	[0x259] = "Grunty Hurt",
	[0x25A] = "Grunty Fireball Spell", -- Flying
	[0x25B] = "Nabnut Acorn Bouncing",
	[0x25C] = "Grunty Phase 1 Swooping",
	-- [0x25D] = "Grunty SmackOnCastle Fixselfup Hopup", -- TODO
	[0x25E] = "Grunty Phase 1 Vulnerable",
	[0x25F] = "Grunty",
	[0x260] = "Grunty Fireball Spell", -- Landed
	[0x261] = "Grunty Green Spell", -- Landed
	[0x262] = "Jinjo Statue Rising", -- TODO: Also diving?
	[0x263] = "Grunty Fall off Broom",
	[0x264] = "Jinjo Statue Activating",
	[0x265] = "Jinjo Statue",
	-- [0x266] = "Grunty/Falling down tower", -- TODO
	-- [0x267] = "Grunty?", -- TODO
	[0x268] = "Big Blue Egg",
	[0x269] = "Big Red Feather",
	[0x26A] = "Big Gold Feather",
	[0x26B] = "Brentilda",
	[0x26C] = "Brentilda Hands on Hips",
	[0x26D] = "Gruntling",
	[0x26E] = "Gruntling Alerted", -- RARR
	[0x26F] = "Gruntling Chasing",
	[0x270] = "Gruntling Dying",
	[0x271] = "DoG", -- TODO: Verify
	[0x272] = "Cheato",
	[0x273] = "Snacker Hurt",
	[0x274] = "Snacker Dying",
	[0x275] = "Jinjonator Activating", -- TODO: Verify
	[0x276] = "Jinjonator Charging",
	-- [0x277] = "Jinjonator ReadyToAttackPose (I think)" -- TODO: Verify
	[0x278] = "Jinjonator Recoil",
	-- [0x279] = "Grunty JawDrop > Shiver", -- TODO: Verify
	[0x27A] = "Grunty Hurt by Jinjonator",
	[0x27B] = "Jinjonator? (spin spin spin, stop far way, shake)", -- TODO: What is this?
	[0x27C] = "Jinjonator Charging",
	[0x27D] = "Jinjonator Final Hit",
	[0x27E] = "Jinjonator Taking Flight",
	[0x27F] = "Jinjonator Circling",
	[0x280] = "Jinjonator Attacking",
	[0x281] = "Wishy-Washy-Banjo 'Doooohh....'",
	[0x282] = "Banjo Unlocking Note Door",
	[0x283] = "Grunty Chattering Teeth",
	[0x284] = "PRESS START Appearing",
	[0x285] = "PRESS START",
	[0x286] = "NO CONTROLLER Appearing",
	[0x287] = "NO CONTROLLER",
	[0x288] = "Flibbit Hurt",
	[0x289] = "Gnawty Swimming",
	[0x28A] = "Grunty's Washing Machine", -- Furnace Fun
	[0x28B] = "Grunty",
	[0x28C] = "Grunty Doll",
	[0x28D] = "Grunty Walking",
	[0x28E] = "Tooty Looking Around",
	[0x28F] = "Dingpot",
	[0x290] = "Dingpot Shooting",
	[0x291] = "Mumbo Flipping Food",
	[0x292] = "Food Flipping",
	[0x293] = "Banjo Drinking",
	[0x294] = "Mumbo Screaming",
	[0x295] = "Banjo's Chair Breaking", -- Also music trigger for N64 Cutscene
	[0x296] = "Bottles Eating corn",
	[0x297] = "Mumbo Skidding", -- Giving flower to Sexy Grunty
	[0x299] = "Bottles Falling off chair",
	[0x29A] = "Banjo Drunk", -- Ending
	[0x29B] = "Kazooie Hits Banjo",
	[0x29C] = "Yellow Jinjo Waving & Whistling", -- Ending
	[0x29D] = "Melon Babe Walking",
	[0x29E] = "Blubber On Jetski",
	[0x29F] = "Blubber Cheering on JetSki",
	-- [0x2A0] = "Drapes Boom Up", -- TODO
	[0x2A1] = "Banjo's Hand Dropping Jiggy",
	[0x2A2] = "Banjo's Hand",
	[0x2A3] = "Banjo's Hand Turning Jiggy (Right)",
	[0x2A4] = "Banjo's Hand Turning Jiggy (Left)",
	[0x2A5] = "Banjo's Hand Grabbing Jiggy",
	[0x2A6] = "Banjo's Hand Thumbs Up",
	[0x2A7] = "Banjo's Hand Placing Jiggy",
	[0x2A8] = "Banjo's Hand Thumbs Down",
	[0x2A9] = "Nibbly Falling", -- Bat
	[0x2AA] = "Nibbly Dying", -- Bat
	[0x2AB] = "Tee-Hee Dying",
	[0x2AC] = "Grunty Upset", -- After Banjo completes Furnace Fun
	[0x2AD] = "Grunty Looking",
	[0x2AE] = "Tree Shaking (Mumbo)", -- TODO: Better names from here on
	[0x2AF] = "Mumbo Sliding down tree",
	[0x2B0] = "Mumbo on tree (waving pictures)",
	[0x2B1] = "Mumbo falling from tree",
	[0x2B2] = "Bottles Eating watermelon",
	[0x2B3] = "Mumbo Hit by Coconuts",
	[0x2B4] = "Mumbo shake head sitting down",
	[0x2B5] = "Mumbo Jumping > Running", -- After MelonBabe
	[0x2B6] = "Klungo Pushing rock",
	[0x2B7] = "Klungo Tired",
	[0x2B8] = "Tooty Drinking", -- Coconut
	[0x2B9] = "Grunty's Rock",
	[0x2BA] = "Kazooie Talking", -- To Bottles
	[0x2BB] = "Mumbo Running", -- After MelonBabe
	[0x2BC] = "Mumbo Talking", -- About pictures, on ground
	[0x2C0] = "Piranha Dying", -- TODO: Where is this used?
	[0x2C5] = "Grunty Preparing charge",
	[0x2C6] = "Mumbo's Hand",
	[0x2C7] = "Mumbo's Hand Appearing",
	[0x2C8] = "Mumbo's Hand Leaving",
};

function getNumSlots()
	if script_mode == "Examine" or script_mode == "List" then -- Model 1
		local levelObjectArray = mainmemory.read_u32_be(Game.Memory.level_object_array_pointer[version]);
		if isPointer(levelObjectArray) then
			levelObjectArray = levelObjectArray - RDRAMBase;
			return math.min(max_slots, mainmemory.read_u32_be(levelObjectArray));
		end
	else -- Model 2
		local structArray = mainmemory.read_u32_be(Game.Memory.struct_array_pointer[version]);
		if isPointer(structArray) then
			structArray = structArray - RDRAMBase;
			return ((mainmemory.read_u32_be(structArray - 0x0C) - RDRAMBase) - structArray) / struct_slot_size;
		end
	end
	return 0;
end

function setAnimationType(index, animationType)
	local level_object_array = mainmemory.read_u24_be(Game.Memory.level_object_array_pointer[version] + 1);
	local numSlots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));
	local objectSlotBase = get_slot_base(level_object_array, index);
	local animationObjectPointer = mainmemory.read_u32_be(objectSlotBase + 0x14);
	if isPointer(animationObjectPointer) then
		animationObjectPointer = animationObjectPointer - RDRAMBase;
		mainmemory.write_u32_be(animationObjectPointer + animation_object_animation_type, animationType);
	end
end

function setAnimationObjectFloat(index, var, value)
	local level_object_array = mainmemory.read_u24_be(Game.Memory.level_object_array_pointer[version] + 1);
	local numSlots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));
	local objectSlotBase = get_slot_base(level_object_array, index);
	local animationObjectPointer = mainmemory.read_u32_be(objectSlotBase + 0x14);
	if isPointer(animationObjectPointer) then
		animationObjectPointer = animationObjectPointer - RDRAMBase;
		mainmemory.writefloat(animationObjectPointer + var, value, true);
	end
end

function set_all(variable, value)
	if type(variable) == "string" then
		variable = resolveVariableName(variable);
	end
	if type(slot_variables[variable]) == "table" then
		local level_object_array = mainmemory.read_u24_be(Game.Memory.level_object_array_pointer[version] + 1);
		local numSlots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));

		local currentSlotBase;
		for i = 0, numSlots - 1 do
			currentSlotBase = get_slot_base(level_object_array, i);
			if slot_variables[variable].Type == "Float" then
				--print("writing float to slot "..i);
				mainmemory.writefloat(currentSlotBase + variable, value, true);
			elseif isHex(slot_variables[variable].Type) then
				--print("writing u32_be to slot "..i);
				mainmemory.write_u32_be(currentSlotBase + variable, value);
			elseif slot_variables[variable].Type == "u16_be" then
				mainmemory.write_u16_be(currentSlotBase + variable, value);
			else
				--print("writing byte to slot "..i);
				mainmemory.writebyte(currentSlotBase + variable, value);
			end
		end
	end
end
setAll = set_all;

-------------------
-- More analysis --
-------------------

-- Example call

--function condition(slot)
--	return value > 0;
--end

--get_variables({0x28, 0x2C, 0x30}, condition);

function db_select(variables, slots)
	local current_slot, value;
	local pulled_data = {};
	for i = 1, #variables do
		for j = 1, #slots do
			current_slot = slot_data[slots[j]];
			value = current_slot[variables[i]];
			if pulled_data[variables[i]] == nil then
				pulled_data[variables[i]] = {};
			end
			table.insert(pulled_data[variables[i]], value);
		end
	end
	return pulled_data;
end
dbSelect = db_select;

function db_not(slots)
	local slot_found;
	local matchedSlots = {};
	for i = 1, #slot_data do
		slot_found = false;
		if #slots > 0 then
			for j = 1, #slots do
				if i == slots[j] then
					slot_found = true;
				end
			end
		end
		if not slot_found then
			table.insert(matchedSlots, i);
		end
	end
	return matchedSlots;
end
dbNot = db_not;

function db_where(condition)
	local matchedSlots = {};
	if condition ~= nil then
		for i = 1, #slot_data do
			if condition(slot_data[i]) then
				table.insert(matchedSlots, i);
			end
		end
	end
	return matchedSlots;
end
dbWhere = db_where;

----------------------
-- Data acquisition --
----------------------

function get_slot_base(object_array, index)
	return object_array + slot_base + index * slot_size;
end
getSlotBase = get_slot_base;

function address_to_slot(address)
	address = address or 0;
	if address < 0x000000 or address > 0x7FFFFF then
		print("Address: "..toHexString(address).." is out of RDRAM range.");
	end

	local level_object_array = mainmemory.read_u24_be(Game.Memory.level_object_array_pointer[version] + 1);
	local numSlots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));
	local position = address - level_object_array - slot_base;
	local relativeToObject = position % slot_size;
	local objectNumber = math.floor(position / slot_size);
	if objectNumber >= 0 and objectNumber <= numSlots then
		print("Object number "..objectNumber.." address relative "..toHexString(relativeToObject));
	else
		print("Address: "..toHexString(address).." is out of range of the object array.");
	end
end
addressToSlot = address_to_slot;

function outputAllAddresses(variable)
	if type(variable) == "string" then
		variable = resolveVariableName(variable);
	end
	if type(slot_variables[variable]) == "table" then
		local level_object_array = mainmemory.read_u24_be(Game.Memory.level_object_array_pointer[version] + 1);
		local numSlots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));

		local currentSlotBase;
		for i = 0, numSlots - 1 do
			currentSlotBase = get_slot_base(level_object_array, i);
			print(toHexString(currentSlotBase + variable));
		end
	end
end

function process_slot(slot_base)
	local current_slot_variables = {};
	local relative_address, variable_data;
	for relative_address, variable_data in pairs(slot_variables) do
		if type(variable_data) == "table" then
			if variable_data.Type == "Byte" then
				current_slot_variables[relative_address] = mainmemory.readbyte(slot_base + relative_address);
			elseif variable_data.Type == "u16_be" then
				current_slot_variables[relative_address] = mainmemory.read_u16_be(slot_base + relative_address);
			elseif variable_data.Type == "Z4_Unknown" or variable_data.Type == "Pointer" then
				current_slot_variables[relative_address] = mainmemory.read_u32_be(slot_base + relative_address);
			elseif variable_data.Type == "Float" then
				current_slot_variables[relative_address] = mainmemory.readfloat(slot_base + relative_address, true);
			end
		end
	end
	return current_slot_variables;
end
processSlot = process_slot;

function parse_slot_data()
	local level_object_array = mainmemory.read_u24_be(Game.Memory.level_object_array_pointer[version] + 1);
	local numSlots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));

	-- Clear out old data
	slot_data = {};

	local currentSlotBase;
	for i = 0, numSlots - 1 do
		currentSlotBase = get_slot_base(level_object_array, i);
		table.insert(slot_data, process_slot(currentSlotBase));
	end

	output_stats();
end
parseSlotData = parse_slot_data;

function zipToSelectedObject()
	if script_mode == "Examine" or script_mode == "List" then -- Model 1
		local levelObjectArray = mainmemory.read_u24_be(Game.Memory.level_object_array_pointer[version]);
		if isPointer(levelObjectArray) then
			local slotBase = getSlotBase(levelObjectArray, object_index);

			local x = mainmemory.readfloat(slotBase + 0x04, true);
			local y = mainmemory.readfloat(slotBase + 0x08, true);
			local z = mainmemory.readfloat(slotBase + 0x0C, true);

			Game.setXPosition(x);
			Game.setYPosition(y);
			Game.setZPosition(z);
		end
	else
		local structArray = mainmemory.read_u32_be(Game.Memory.struct_array_pointer[version]);
		if isPointer(structArray) then
			structArray = structArray - RDRAMBase;
			local rendererPointer = mainmemory.read_u32_be(structArray + object_index * struct_slot_size);
			if isPointer(rendererPointer) then
				rendererPointer = rendererPointer - RDRAMBase;
				local x = mainmemory.read_s16_be(rendererPointer + 0x10);
				local y = mainmemory.read_s16_be(rendererPointer + 0x12);
				local z = mainmemory.read_s16_be(rendererPointer + 0x14);

				Game.setXPosition(x);
				Game.setYPosition(y);
				Game.setZPosition(z);
			end
		end
	end
end

---------------
-- OSD Stuff --
---------------

local green_highlight = 0xFF00FF00;
local yellow_highlight = 0xFFFFFF00;

local script_modes = {
	"List",
	"Examine",
	"List Struct",
	"Examine Struct",
};

local script_mode_index = 1;
script_mode = script_modes[script_mode_index];

local function switch_script_mode()
	script_mode_index = script_mode_index + 1;
	if script_mode_index > #script_modes then
		script_mode_index = 1;
	end
	script_mode = script_modes[script_mode_index];
end

function getExamineData(slot_base)
	local current_slot_variables = {};
	local relative_address, variable_data;
	for relative_address = 0, slot_size do
		variable_data = slot_variables[relative_address];
		if type(variable_data) == "table" then
			local variableName = getVariableName(relative_address);
			if variable_data.Type == "Byte" then
				table.insert(current_slot_variables, {variableName, formatForOutput(variable_data.Type, mainmemory.readbyte(slot_base + relative_address))});
			elseif variable_data.Type == "u16_be" then
				table.insert(current_slot_variables, {variableName, formatForOutput(variable_data.Type, mainmemory.read_u16_be(slot_base + relative_address))});
			elseif variable_data.Type == "Z4_Unknown" then
				-- Don't print yo
			elseif variable_data.Type == "Pointer" or variable_data.Type == "u32_be" then
				table.insert(current_slot_variables, {variableName, formatForOutput(variable_data.Type, mainmemory.read_u32_be(slot_base + relative_address))});
			elseif variable_data.Type == "Float" then
				table.insert(current_slot_variables, {variableName, formatForOutput(variable_data.Type, mainmemory.readfloat(slot_base + relative_address, true))});
			end
		end
	end
	return current_slot_variables;
end

function draw_ui()
	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	local level_object_array = mainmemory.read_u24_be(Game.Memory.level_object_array_pointer[version] + 1);
	local structArray = mainmemory.read_u32_be(Game.Memory.struct_array_pointer[version]);
	if isPointer(structArray) then
		structArray = structArray - RDRAMBase;
	end
	local numSlots = getNumSlots();

	gui.text(gui_x, gui_y + height * row, "Mode: "..script_mode, nil, nil, 'bottomright');
	row = row + 1;
	gui.text(gui_x, gui_y + height * row, "Index: "..(object_index).."/"..(numSlots), nil, nil, 'bottomright');
	row = row + 1;

	if script_mode == "Examine" then
		local examine_data = getExamineData(getSlotBase(level_object_array, object_index));
		for i = #examine_data, 1, -1 do
			if examine_data[i][1] ~= "Separator" then
				gui.text(gui_x, gui_y + height * row, examine_data[i][2].." - "..examine_data[i][1], nil, nil, 'bottomright');
				row = row + 1;
			else
				row = row + examine_data[i][2];
			end
		end
	end

	if script_mode == "Examine Struct" then
		if isRDRAM(structArray) then
			local structData = getStructData(structArray + object_index * struct_slot_size)
			for i = #structData, 1, -1 do
				if structData[i][1] ~= "Separator" then
					gui.text(gui_x, gui_y + height * row, structData[i][2].." - "..structData[i][1], nil, nil, 'bottomright');
					row = row + 1;
				else
					row = row + structData[i][2];
				end
			end
		end
	end

	if script_mode == "List" then
		for i = numSlots, 1, -1 do
			local currentSlotBase = get_slot_base(level_object_array, i);

			local animationType = "Unknown";
			local animationObjectPointer = mainmemory.read_u32_be(currentSlotBase + 0x14);
			if isPointer(animationObjectPointer) then
				animationObjectPointer = animationObjectPointer - RDRAMBase;
				animationType = mainmemory.read_u32_be(animationObjectPointer + animation_object_animation_type);
				if type(animation_types[animationType]) == "string" then
					animationType = animation_types[animationType];
				else
					animationType = toHexString(animationType);
				end
			end

			local color = nil;
			if object_index == i then
				color = yellow_highlight;
			end

			if animationType == "Unknown" then
				local boneArray1 = mainmemory.read_u32_be(currentSlotBase + 0x14C);
				local boneArray2 = mainmemory.read_u32_be(currentSlotBase + 0x150);
				if not hide_non_animated or (isPointer(boneArray1) or isPointer(boneArray2)) then
					gui.text(gui_x, gui_y + height * row, i..": "..toHexString(currentSlotBase or 0), color, nil, 'bottomright');
					row = row + 1;
				end
			else
				gui.text(gui_x, gui_y + height * row, animationType.." "..i..": "..toHexString(currentSlotBase or 0), color, nil, 'bottomright');
				row = row + 1;
			end
		end
	end
	
	if script_mode == "List Struct" then
		if isRDRAM(structArray) then
			for i = 0, numSlots - 1 do
				local rendererPointer = mainmemory.read_u32_be(structArray + i * struct_slot_size);
				if isPointer(rendererPointer) then
					gui.text(gui_x, gui_y + height * row, i..": "..toHexString(structArray + i * struct_slot_size), nil, nil, 'bottomright');
					row = row + 1;
				end
			end
		end
	end
end

local function incr_object_index()
	local numSlots = getNumSlots();
	object_index = object_index + 1;
	if object_index > numSlots then
		object_index = 1;
	end
end

local function decr_object_index()
	object_index = object_index - 1;
	if object_index <= 0 then
		local numSlots = getNumSlots();
		object_index = numSlots;
	end
end

-- Keybinds
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm
local decrease_object_index_key = "N";
local increase_object_index_key = "M";
local switch_script_mode_key = "C";
local zip_key = "Z";

local decrease_object_index_pressed = false;
local increase_object_index_pressed = false;
local switch_mode_pressed = false;
local zip_pressed = false;

local function process_input()
	input_table = input.get();

	-- Hold down key prevention
	if input_table[decrease_object_index_key] == nil then
		decrease_object_index_pressed = false;
	end

	if input_table[increase_object_index_key] == nil then
		increase_object_index_pressed = false;
	end

	if input_table[switch_script_mode_key] == nil then
		switch_script_mode_pressed = false;
	end

	if input_table[zip_key] == nil then
		zip_pressed = false;
	end

	-- Check for key presses
	if input_table[decrease_object_index_key] == true and decrease_object_index_pressed == false then
		decr_object_index();
		decrease_object_index_pressed = true;
	end

	if input_table[increase_object_index_key] == true and increase_object_index_pressed == false then
		incr_object_index();
		increase_object_index_pressed = true;
	end

	if input_table[switch_script_mode_key] == true and switch_script_mode_pressed == false then
		switch_script_mode();
		switch_script_mode_pressed = true;
	end

	if input_table[zip_key] == true and zip_pressed == false then
		zipToSelectedObject();
		zip_pressed = true;
	end
end

event.onframestart(draw_ui, "ScriptHawk - Examine BK Level Objects");
event.onframestart(process_input, "ScriptHawk - Process input");