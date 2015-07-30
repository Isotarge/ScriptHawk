boggy_pointer = 0x36E560;

-- Slot data
slot_base = 0x28;
slot_size = 0x180;
number_of_slots = 0x60;

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
	[0x28] = {["Type"] = "Float", ["Name"] = "Progression along race path"}, 
	[0x2C] = {["Type"] = "Float", ["Name"] = "Speed (used for rubberbanding)"}, 

	[0x30] = {["Type"] = "Float", ["Name"] = "Facing Angle"},
	[0x38] = {["Type"] = "4_Unknown"},

	[0x44] = {["Type"] = "Float", ["Name"] = "Angle?"},
	[0x48] = {["Type"] = "Float", ["Name"] = "Angle?"},
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

	[0xF4] = {["Type"] = "Float", ["Name"] = "Varies between 0 and 1"},
	[0xF8] = {["Type"] = "Float"},
	[0xFC] = {["Type"] = "Float"},

	[0x100] = {["Type"] = "Float"},
	[0x104] = {["Type"] = "Byte"},
	[0x105] = {["Type"] = "Byte"},
	[0x106] = {["Type"] = "Byte"},
	[0x107] = {["Type"] = "Byte"},
	[0x108] = {["Type"] = "Float"},
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
	[0x164] = {["Type"] = "Float"},
	[0x168] = {["Type"] = "Float"},
	[0x16C] = {["Type"] = "Float"},

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

slot_data = {};

--------------------
-- Output Helpers --
--------------------

function is_binary(var_type)
	return var_type == "Byte";
end

function is_hex(var_type)
	return var_type == "Pointer" or var_type == "4_Unknown" or var_type == "Z4_Unknown";
end

function format_for_output(var_type, value)
	if is_binary(var_type) then
		local binstring = bizstring.binary(value);
		if binstring ~= "" then
			return binstring;
		end
		return "0";
	elseif is_hex(var_type) then
		return "0x"..bizstring.hex(value);
	end
	return ""..value;
end

------------
-- Output --
------------

function output_slot(index)
	if index > 0 and index < #slot_data then
		local i;
		local previous_type = "";
		local current_slot = slot_data[index];
		console.log("Starting output of slot "..index);
		for i=0,slot_size do
			if type(slot_variables[i]) == "table" then
				if slot_variables[i].Type ~= "Z4_Unknown" then
					if slot_variables[i].Type ~= previous_type then
						previous_type = slot_variables[i].Type;
						console.log("");
					end
					console.log("0x"..bizstring.hex(i).." "..(slot_variables[i].Type)..": "..format_for_output(slot_variables[i].Type, current_slot[i]));
				else
					--console.log("0x"..bizstring.hex(i).." Nothing interesting.");
				end
			end
		end
	end
end

function output_stats()
	console.log("------------------------------");
	console.log("-- Starting output of stats --");
	console.log("------------------------------");
	local i, min, max;
	local previous_type = "";
	for i=0,slot_size do
		if type(slot_variables[i]) == "table" then
			min = get_minimum_value(i);
			max = get_maximum_value(i);
			if slot_variables[i].Type ~= "Z4_Unknown" or min ~= max then
				if slot_variables[i].Type ~= previous_type then
					previous_type = slot_variables[i].Type;
					console.log("");
				end
				if type(slot_variables[i].Name) ~= "nil" then
					console.log("0x"..bizstring.hex(i).." "..(slot_variables[i].Type)..": "..format_for_output(slot_variables[i].Type, min).. " to "..format_for_output(slot_variables[i].Type, max).." - "..(slot_variables[i].Name));
				else
					console.log("0x"..bizstring.hex(i).." "..(slot_variables[i].Type)..": "..format_for_output(slot_variables[i].Type, min).. " to "..format_for_output(slot_variables[i].Type, max));
				end
			else
				--console.log("0x"..bizstring.hex(i).." Nothing interesting.");
			end
		end
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
	console.log("Variable name: '"..name.."' not found =(");
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
		console.log("Starting output of variable 0x"..bizstring.hex(variable));
		local i;
		for i=1,#slot_data do
			console.log("Slot "..i..": "..format_for_output(slot_variables[variable].Type, slot_data[i][variable]));
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
	local boggy_state = mainmemory.read_u24_be(boggy_pointer + 1);
	local i, current_slot_base;

	-- Clear out old data
	slot_data = {};

	for i=0,number_of_slots do
		current_slot_base = boggy_state + slot_base + i * slot_size;
		table.insert(slot_data, process_slot(current_slot_base));
	end

	output_stats();
end