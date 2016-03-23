-----------------------
-- Load JSON library --
-----------------------

--JSON = require "lib.JSON";

-----------------------

object_index = 1;
hide_non_animated = false;
local level_object_array_pointer;
local romName = gameinfo.getromname();

if not bizstring.contains(romName, "Banjo-Kazooie") and not bizstring.contains(romName, "Banjo to Kazooie no Daibouken") then
	print("This game is not currently supported.");
end

if bizstring.contains(romName, "Europe") then
	level_object_array_pointer = 0x36EAE0;
elseif bizstring.contains(romName, "Japan") then
	level_object_array_pointer = 0x36F260;
elseif bizstring.contains(romName, "USA") and bizstring.contains(romName, "Rev A") then
	level_object_array_pointer = 0x36D760;
elseif bizstring.contains(romName, "USA") then
	level_object_array_pointer = 0x36E560;
else
	print("This version of the game is not currently supported.");
	return false;
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

	[0x14] = {["Type"] = "Pointer", ["Name"] = "Animation Object Pointer"},
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

--------------
-- Analysis --
--------------

function find_root(object)
	local count = 0;
	while object > 0 do
		print(count..": .."..toHexString(object));
		object = mainmemory.read_u24_be(object + 1);
		count = count + 1;
	end
end
findRoot = find_root;

function resolve_variable_name(name)
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
resolveVariableName = resolve_variable_name;

function get_minimum_value(variable)
	if type(variable) == "string" then
		variable = resolve_variable_name(variable);
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
		variable = resolve_variable_name(variable);
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
		variable = resolve_variable_name(variable);
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

local animation_object_unknown_pointer = 0x00;
local animation_object_animation_type = 0x38;
local animation_object_animation_timer = 0x3C;

local animation_types = {
	[0x10] = "Bigbutt Running",
	[0x2C] = "Snippet Walking",
	[0x2D] = "Jinjo Idle",
	[0x2F] = "Jinjo Waving",
	[0x31] = "Jinjo", -- TODO: What is this exactly?
	[0x32] = "Bigbutt Attacking",
	[0x33] = "Bigbutt Eating Grass",
	[0x35] = "Bigbutt Alerted",
	[0x36] = "Bigbutt Walking",
	[0x51] = "Conga Idle",
	[0x52] = "Conga Hurt",
	[0x54] = "Conga Throwing",
	[0x55] = "Conga Beating Chest",
	[0x56] = "Conga Raising Arms",
	[0x5B] = "Chimpy",
	[0x5C] = "Chimpy",
	[0x5D] = "Chimpy",
	[0x5E] = "Termite Idle",
	[0x5F] = "Termite Walking",
	[0x62] = "Grublin Idle",
	[0x65] = "Beehive Dying",
	[0x67] = "Wading Boots",
	[0x6A] = "Mumbo Sleeping",
	[0x6B] = "Mumbo Waking",
	[0x6C] = "Mumbo Idle",
	[0x6D] = "Mumbo Transforming",
	[0x92] = "Shrapnel Chasing",
	[0x96] = "Snippet Recovering",
	[0x9A] = "Ripper Idle",
	[0x9B] = "Ripper Chasing",
	[0x9D] = "Nibbly Chasing", -- Bat
	[0x9E] = "Green Ghost Idle",
	[0x9F] = "Green Ghost Alerted",
	[0xA2] = "Conga Throwing", -- Retaliation
	[0xA9] = "Pot", -- MMM
	[0xAC] = "Green Ghost Chasing",
	[0xAE] = "Nibbly Idle", -- Bat
	[0xB3] = "Chump Idle",
	[0xB4] = "Chump Chomping",
	[0xC9] = "Carpet", -- GV
	[0xD1] = "Rubee's Pot",
	[0xD4] = "Switch", -- Witch Switch (MM), Shock Spring Pad Switch (GV Lobby)
	[0xD6] = "Turbo Trainers",
	[0xDF] = "Rubee",
	[0xE3] = "Rubee",
	[0xF1] = "Carpet", -- GV
	[0x101] = "Tanktup's Head",
	[0x102] = "Tanktup's Head Pounded",
	[0x107] = "Tanktup Spawning Jiggy",
	[0x108] = "Sir Slush Idle",
	[0x109] = "Sir Slush Attacking",
	[0x130] = "Jinjo Circling", -- TODO: Used outside Grunty fight?
	[0x131] = "Jinjo Circling", -- TODO: How does this work
	[0x13A] = "Bottles", -- TODO: Details
	[0x13B] = "Bottles", -- TODO: Details
	[0x13D] = "Bottles", -- TODO: Details
	[0x143] = "Button", -- Snowman, Xmas tree
	[0x14B] = "Croctus", -- BGS, feed egg
	[0x14E] = "Boggy", -- Lying on back
	[0x162] = "Toots",
	[0x165] = "Beehive",
	[0x16B] = "Snare-Bear Snapping",
	[0x16C] = "Snare-Bear Idle",
	[0x16D] = "Twinklie Present",
	[0x16E] = "Mumbo Reclining", -- CCW Summer
	[0x178] = "Twinklie Spawning",
	[0x17C] = "Twinklie Twinkling",
	[0x17E] = "Spawn of Boggy",
	[0x17F] = "Mumbo Sweeping",
	[0x180] = "Mumbo Rotating",
	[0x18A] = "Present", -- FP
	[0x1A1] = "Sled", -- FP
	[0x1B1] = "Twinklie Muncher Idle",
	[0x1B2] = "Twinklie Muncher Munching",
	[0x1B4] = "Wozza Bodyblocking",
	[0x1C5] = "Grunty Flying",
	[0x1CE] = "Curtain", -- Banjo's house
	[0x1D5] = "Tooty Chattering Teeth",
	[0x1D6] = "Grublin Walking",
	[0x1D7] = "Grublin Alerted",
	[0x1D8] = "Grublin Chasing",
	[0x1DA] = "Snippet Idle",
	[0x1E4] = "Skeleton Idle",
	[0x1E5] = "Skeleton Alerted",
	[0x1E6] = "Skeleton Chasing",
	[0x1E9] = "Mum-Mum Idle",
	[0x1ED] = "Ripper Damaged",
	[0x1EE] = "Ripper Dying",
	[0x1F0] = "Web Idle",
	[0x1F1] = "Web Dying",
	[0x1F4] = "Shrapnel Idle",
	[0x208] = "Goldfish", -- Banjo's house
	[0x209] = "Cuckoo Clock Idle",
	[0x20A] = "Cuckoo Clock Chiming",
	[0x212] = "Cauldron Activating",
	[0x213] = "Cauldron Sleeping",
	[0x214] = "Cauldron Activated",
	[0x215] = "Cauldron Teleporting",
	[0x216] = "Cauldron Rejected",
	[0x217] = "Transform Pad",
	[0x220] = "Sir. Slush",
	[0x223] = "Topper Idle", -- Carrot gets it
	[0x225] = "Colliwobble Idle",
	[0x226] = "Bawl Idle",
	[0x233] = "Ice Cube", -- TODO: More info
	[0x234] = "Snare-Bear (Winter)",
	[0x237] = "Twinklie Present",
	[0x23F] = "Portrait",
	[0x243] = "Grublin-Hood Idle",
	[0x244] = "Grublin-Hood Alerted",
	[0x245] = "Grublin-Hood Chasing",
	[0x246] = "Grublin-Hood Dying",
	[0x257] = "Grunty Green Spell", -- Flying
	[0x258] = "Grunty Hurt",
	[0x259] = "Grunty Hurt",
	[0x25A] = "Grunty Fireball Spell", -- Flying
	[0x25C] = "Grunty Phase 1 Swooping",
	[0x25E] = "Grunty Phase 1 Vulnerable",
	[0x25F] = "Grunty Idle",
	[0x260] = "Grunty Fireball Spell", -- Landed
	[0x261] = "Grunty Green Spell", -- Landed
	[0x262] = "Jinjo Statue Rising", -- TODO: Also diving?
	[0x264] = "Jinjo Statue Activating",
	[0x265] = "Jinjo Statue",
	[0x268] = "Big Blue Egg",
	[0x269] = "Big Red Feather",
	[0x26A] = "Big Gold Feather",
	[0x26B] = "Brentilda Idle",
	[0x26C] = "Brentilda Hands on Hips",
	[0x26D] = "Gruntling Idle",
	[0x26F] = "Gruntling Chasing",
	[0x271] = "DoG", -- TODO: Verify
	[0x272] = "Cheato",
	[0x275] = "Jinjonator Activating", -- TODO: verify
	[0x276] = "Jinjonator Charging",
	[0x278] = "Jinjonator Recoil",
	[0x27A] = "Grunty Hurt by Jinjonator",
	[0x27C] = "Jinjonator Charging",
	[0x27D] = "Jinjonator Final Hit",
	[0x27F] = "Jinjonator Circling",
	[0x283] = "Grunty Chattering Teeth",
	[0x28B] = "Grunty",
	[0x28C] = "Grunty Doll",
	[0x28E] = "Tooty Looking Left & Right",
	[0x28F] = "Dingpot",
	[0x290] = "Dingpot Shooting",
};

function setAnimationType(index, animationType)
	local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
	local numSlots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));
	local objectSlotBase = get_slot_base(level_object_array, index);
	local animationObjectPointer = mainmemory.read_u32_be(objectSlotBase + 0x14);
	if isPointer(animationObjectPointer) then
		animationObjectPointer = animationObjectPointer - RDRAMBase;
		mainmemory.write_u32_be(animationObjectPointer + animation_object_animation_type, animationType);
	end
end

function setAnimationObjectFloat(index, var, value)
	local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
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
		variable = resolve_variable_name(variable);
	end
	if type(slot_variables[variable]) == "table" then
		local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
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

	local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
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
		variable = resolve_variable_name(variable);
	end
	if type(slot_variables[variable]) == "table" then
		local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
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
	local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
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
	local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
	local slotBase = getSlotBase(level_object_array, object_index);

	local x = mainmemory.readfloat(slotBase + 0x04, true);
	local y = mainmemory.readfloat(slotBase + 0x08, true);
	local z = mainmemory.readfloat(slotBase + 0x0C, true);

	if Game ~= nil then
		Game.setXPosition(x);
		Game.setYPosition(y);
		Game.setZPosition(z);
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

function fetch_address(index)
	local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
	return getSlotBase(level_object_array, index);
end

function draw_ui()
	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
	local numSlots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));
	gui.text(gui_x, gui_y + height * row, "Index: "..(object_index).."/"..(numSlots), nil, nil, 'bottomright');
	row = row + 1;

	if script_mode == "Examine" then
		local examine_data = getExamineData(fetch_address(object_index));
		for i = #examine_data, 1, -1 do
			if examine_data[i][1] ~= "Separator" then
				gui.text(gui_x, gui_y + height * row, examine_data[i][2].." - "..examine_data[i][1], nil, nil, 'bottomright');
				row = row + 1;
			else
				row = row + examine_data[i][2];
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
					gui.text(gui_x, gui_y + height * row, i..": "..string.format("0x%06x", currentSlotBase or 0), color, nil, 'bottomright');
					row = row + 1;
				end
			else
				gui.text(gui_x, gui_y + height * row, animationType.." "..i..": "..string.format("0x%06x", currentSlotBase or 0), color, nil, 'bottomright');
				row = row + 1;
			end
		end
	end
end

local function incr_object_index()
	local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
	local numSlots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));
	object_index = object_index + 1;
	if object_index > numSlots then
		object_index = 1;
	end
end

local function decr_object_index()
	object_index = object_index - 1;
	if object_index <= 0 then
		local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
		local numSlots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));
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