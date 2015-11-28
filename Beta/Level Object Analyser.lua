-----------------------
-- Load JSON library --
-----------------------

--JSON = require "lib.JSON";

-----------------------

local level_object_array_pointer = 0x36E560;

-- Slot data
local slot_base = 0x28;
local slot_size = 0x180;
local max_slots = 0x100;

-- Relative to slot start
slot_variables = {
	[0x00] = {["Type"] = "Float"},
	[0x04] = {["Type"] = "Float"},
	[0x08] = {["Type"] = "Float"},
	[0x0C] = {["Type"] = "Float"},

	[0x10] = {["Type"] = "Float"},
	[0x14] = {["Type"] = "Float"},

	[0x18] = {["Type"] = "Byte"},
	[0x19] = {["Type"] = "Byte"},
	[0x1A] = {["Type"] = "Byte"},
	[0x1B] = {["Type"] = "Byte"},
	[0x1C] = {["Type"] = "Byte"},
	[0x1D] = {["Type"] = "Byte"},
	[0x1E] = {["Type"] = "Byte"},
	[0x1F] = {["Type"] = "Byte"},

	[0x24] = {["Type"] = "4_Unknown"},
	[0x28] = {["Type"] = "Float", ["Name"] = "Race path progression"}, 
	[0x2C] = {["Type"] = "Float", ["Name"] = "Speed (rubberband)"}, 

	[0x30] = {["Type"] = "Float", ["Name"] = "Rotation Y"},
	[0x38] = {["Type"] = "4_Unknown"},

	[0x44] = {["Type"] = "Float", ["Name"] = "Angle"},
	[0x48] = {["Type"] = "Float", ["Name"] = "Rotation X"},
	[0x4C] = {["Type"] = "Float"},

	[0x54] = {["Type"] = "Float"},
	[0x58] = {["Type"] = "4_Unknown"},

	[0x6C] = {["Type"] = "Float", ["Name"] = "Countdown timer?"},

	[0x70] = {["Type"] = "Float"},
	[0x74] = {["Type"] = "Byte"},
	[0x75] = {["Type"] = "Byte"},
	[0x76] = {["Type"] = "Byte"},
	[0x77] = {["Type"] = "Byte"},
	[0x78] = {["Type"] = "Float"},

	[0x80] = {["Type"] = "Float"},
	[0x84] = {["Type"] = "Float"},
	[0x88] = {["Type"] = "Float"},
	[0x8C] = {["Type"] = "4_Unknown"},

	[0xA4] = {["Type"] = "Float"},
	[0xA8] = {["Type"] = "Float"},
	[0xAC] = {["Type"] = "Float"},

	[0xB0] = {["Type"] = "Float"},
	[0xB4] = {["Type"] = "Float"},
	[0xB8] = {["Type"] = "Float"},

	[0xC0] = {["Type"] = "Float"},
	[0xC4] = {["Type"] = "Float"},
	[0xC8] = {["Type"] = "Byte"},
	[0xC9] = {["Type"] = "Byte"},
	[0xCA] = {["Type"] = "Byte"},
	[0xCB] = {["Type"] = "Byte"},
	[0xCC] = {["Type"] = "Float"},

	[0xD0] = {["Type"] = "Float"},
	[0xD4] = {["Type"] = "Byte"},
	[0xD5] = {["Type"] = "Byte"},
	[0xD6] = {["Type"] = "Byte"},
	[0xD7] = {["Type"] = "Byte"},
	[0xD8] = {["Type"] = "Float"},
	[0xDC] = {["Type"] = "Float"},

	[0xE0] = {["Type"] = "Pointer"},
	[0xE4] = {["Type"] = "Pointer"},

	[0xF4] = {["Type"] = "Float", ["Name"] = "Between 0 and 1"},
	[0xF8] = {["Type"] = "Float"},
	[0xFC] = {["Type"] = "Float"},

	[0x100] = {["Type"] = "Float"},
	[0x104] = {["Type"] = "Byte"},
	[0x105] = {["Type"] = "Byte"},
	[0x106] = {["Type"] = "Byte"},
	[0x107] = {["Type"] = "Byte"},
	[0x108] = {["Type"] = "Float", ["Name"] = "Scale"},
	[0x10C] = {["Type"] = "Pointer"},

	[0x110] = {["Type"] = "Pointer"},
	[0x118] = {["Type"] = "4_Unknown"},

	[0x120] = {["Type"] = "Float"},
	[0x124] = {["Type"] = "Float"},
	[0x12C] = {["Type"] = "Pointer"},

	[0x130] = {["Type"] = "Pointer"},
	[0x134] = {["Type"] = "4_Unknown"},

	[0x140] = {["Type"] = "Pointer"},
	[0x144] = {["Type"] = "Byte"},
	[0x145] = {["Type"] = "Byte"},
	[0x146] = {["Type"] = "Byte"},
	[0x147] = {["Type"] = "Byte"},
	[0x14C] = {["Type"] = "4_Unknown"},

	[0x150] = {["Type"] = "Float"},
	[0x154] = {["Type"] = "Float"},
	[0x158] = {["Type"] = "Float"},

	[0x160] = {["Type"] = "Pointer"},
	[0x164] = {["Type"] = "Float", ["Name"] = "X Position"},
	[0x168] = {["Type"] = "Float", ["Name"] = "Y Position"},
	[0x16C] = {["Type"] = "Float", ["Name"] = "Z Position"},

	[0x170] = {["Type"] = "4_Unknown"},
	[0x174] = {["Type"] = "Pointer"},
	[0x178] = {["Type"] = "Pointer"},
	[0x17C] = {["Type"] = "Float"}
};

function fill_blank_variable_slots()
	local i;
	local data_size = 0x04;
	for i=0, slot_size - data_size, data_size do
		if type(slot_variables[i]) == "nil" then
			slot_variables[i] = {["Type"] = "Z4_Unknown"};
		end
	end
end

fill_blank_variable_slots();

local slot_data = {};

--------------------
-- Output Helpers --
--------------------

function is_binary(var_type)
	return var_type == "Byte";
end

function is_hex(var_type)
	return var_type == "Pointer" or var_type == "4_Unknown" or var_type == "Z4_Unknown";
end

function toHexString(value)
	value = string.format("%X", value or 0);
	if string.len(value) % 2 ~= 0 then
		value = "0"..value;
	end
	return "0x"..value;
end

function format_for_output(var_type, value)
	if is_binary(var_type) then
		local binstring = bizstring.binary(value);
		if binstring ~= "" then
			return binstring;
		end
		return "0";
	elseif is_hex(var_type) then
		return toHexString(value);
	end
	return ""..value;
end

function is_interesting(variable)
	local min = get_minimum_value(variable);
	local max = get_maximum_value(variable);
	return slot_variables[variable].Type ~= "Z4_Unknown" or min ~= max;
end

------------
-- Output --
------------

function output_slot(index)
	if index > 0 and index < #slot_data then
		local i;
		local previous_type = "";
		local current_slot = slot_data[index + 1];
		print("Starting output of slot "..index + 1);
		for i=0,slot_size do
			if type(slot_variables[i]) == "table" then
				if slot_variables[i].Type ~= "Z4_Unknown" then
					if slot_variables[i].Type ~= previous_type then
						previous_type = slot_variables[i].Type;
						print("");
					end
					if type(slot_variables[i].Name) == "string" then
						print(toHexString(i).." "..(slot_variables[i].Name).." ("..(slot_variables[i].Type).."): "..format_for_output(slot_variables[i].Type, current_slot[i]));
					else
						print(toHexString(i).." "..(slot_variables[i].Type)..": "..format_for_output(slot_variables[i].Type, current_slot[i]));
					end
				else
					--print(toHexString(i).." Nothing interesting.");
				end
			end
		end
	end
end

function output_stats()
	print("------------------------------");
	print("-- Starting output of stats --");
	print("------------------------------");
	local i, min, max;
	local previous_type = "";
	for i=0,slot_size do
		if type(slot_variables[i]) == "table" then
			if is_interesting(i) then
				min = get_minimum_value(i);
				max = get_maximum_value(i);
				if slot_variables[i].Type ~= previous_type then
					previous_type = slot_variables[i].Type;
					print("");
				end
				if type(slot_variables[i].Name) ~= "nil" then
					print(toHexString(i).." "..(slot_variables[i].Type)..": "..format_for_output(slot_variables[i].Type, min).. " to "..format_for_output(slot_variables[i].Type, max).." - "..(slot_variables[i].Name));
				else
					print(toHexString(i).." "..(slot_variables[i].Type)..": "..format_for_output(slot_variables[i].Type, min).. " to "..format_for_output(slot_variables[i].Type, max));
				end
			else
				--print(toHexString(i).." Nothing interesting.");
			end
		end
	end
end

function format_slot_data()
	local formatted_data = {};
	local i;
	local relative_address, variable_data;
	for i=1,#slot_data do
		formatted_data[i] = {};
		for relative_address, variable_data in pairs(slot_variables) do
			if type(variable_data) == "table" and is_interesting(relative_address) then
				if type(variable_data.Name) == "string" then
					formatted_data[i][toHexString(relative_address).." "..variable_data.Name] = {
						["Type"] = variable_data.Type,
						["Value"] = format_for_output(variable_data.Type, slot_data[i][relative_address])
					};
				else
					formatted_data[i][toHexString(relative_address).." "..variable_data.Type] = {
						["Value"] = format_for_output(variable_data.Type, slot_data[i][relative_address])
					};
				end
			end
		end
	end
	return formatted_data;
end

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

--------------
-- Analysis --
--------------

function resolve_variable_name(name)
	-- Make sure comparisons are case insensitive
	name = bizstring.toupper(name);

	-- Comparison loop
	local relative_address, variable_data;
	for relative_address, variable_data in pairs(slot_variables) do
		if type(variable_data) == "table" and type(variable_data.Name) ~= "nil" and bizstring.toupper(variable_data.Name) == name then
			return relative_address;
		end
	end

	-- Default + Error
	print("Variable name: '"..name.."' not found =(");
	return 0x00;
end

function get_minimum_value(variable)
	if type(variable) == "string" then
		variable = resolve_variable_name(variable);
	end
	if type(slot_variables[variable]) == "table" then
		local i;
		local min = slot_data[1][variable];
		for i=1,#slot_data do
			if slot_data[i][variable] < min then
				min = slot_data[i][variable];
			end
		end
		return min;
	end
	return 0;
end

function get_maximum_value(variable)
	if type(variable) == "string" then
		variable = resolve_variable_name(variable);
	end
	if type(slot_variables[variable]) == "table" then
		local i;
		local max = slot_data[1][variable];
		for i=1,#slot_data do
			if slot_data[i][variable] > max then
				max = slot_data[i][variable];
			end
		end
		return max;
	end
	return 0;
end

function get_all_unique(variable)
	if type(variable) == "string" then
		variable = resolve_variable_name(variable);
	end
	if type(slot_variables[variable]) == "table" then
		local unique_values = {};
		local i, value, count;
		for i=1,#slot_data do
			value = format_for_output(slot_variables[variable].Type, slot_data[i][variable]);
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

function set_all(variable, value)
	if type(variable) == "string" then
		variable = resolve_variable_name(variable);
	end
	if type(slot_variables[variable]) == "table" then
		local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
		local num_slots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));

		local i, current_slot_base;
		for i=0,num_slots - 1 do
			current_slot_base = get_slot_base(level_object_array, i);
			if slot_variables[variable].Type == "Float" then
				--print("writing float to slot "..i);
				mainmemory.writefloat(current_slot_base + variable, value, true);
			elseif is_hex(slot_variables[variable].Type) then
				--print("writing u32_be to slot "..i);
				mainmemory.write_u32_be(current_slot_base + variable, value);
			else
				--print("writing byte to slot "..i);
				mainmemory.writebyte(current_slot_base + variable, value);
			end
		end
	end
end

-------------------
-- More analysis --
-------------------

-- Example call

--function condition(slot)
--	return value > 0;
--end

--get_variables({0x28, 0x2C, 0x30}, condition);

function db_select(variables, slots)
	local i, j;
	local current_slot, value;
	local pulled_data = {};
	for i=1,#variables do
		for j=1,#slots do
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

function db_not(slots)
	local i, j, slot_found;
	local matched_slots = {};
	for i=1,#slot_data do
		slot_found = false;
		if #slots > 0 then
			for j=1,#slots do
				if i == slots[j] then
					slot_found = true;
				end
			end
		end
		if not slot_found then
			table.insert(matched_slots, i);
		end
	end
	return matched_slots;
end

function db_where(condition)
	local matched_slots = {};
	if condition ~= nil then
		local i;
		for i=1,#slot_data do
			if condition(slot_data[i]) then
				table.insert(matched_slots, i);
			end
		end
	end
	return matched_slots;
end

----------------------
-- Data acquisition --
----------------------

function get_slot_base(object_array, index)
	return object_array + slot_base + index * slot_size;
end

function process_slot(slot_base)
	local current_slot_variables = {};
	local relative_address, variable_data;
	for relative_address, variable_data in pairs(slot_variables) do
		if type(variable_data) == "table" then
			if variable_data.Type == "Byte" then
				current_slot_variables[relative_address] = mainmemory.readbyte(slot_base + relative_address);
			elseif variable_data.Type == "4_Unknown" or variable_data.Type == "Z4_Unknown" or variable_data.Type == "Pointer" then
				current_slot_variables[relative_address] = mainmemory.read_u32_be(slot_base + relative_address);
			elseif variable_data.Type == "Float" then
				current_slot_variables[relative_address] = mainmemory.readfloat(slot_base + relative_address, true);
			end
		end
	end
	return current_slot_variables;
end

function parse_slot_data()
	local level_object_array = mainmemory.read_u24_be(level_object_array_pointer + 1);
	local num_slots = math.min(max_slots, mainmemory.read_u32_be(level_object_array));

	-- Clear out old data
	slot_data = {};

	local i, current_slot_base;
	for i=0,num_slots - 1 do
		current_slot_base = get_slot_base(level_object_array, i);
		table.insert(slot_data, process_slot(current_slot_base));
	end

	output_stats();
end