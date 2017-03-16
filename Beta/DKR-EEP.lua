local slot_size = 0x28;
local number_of_slots = 3;

local slot_data = {};

local function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	prefix = prefix or "0x";
	desiredLength = desiredLength or string.len(value);
	while string.len(value) < desiredLength do
		value = "0"..value;
	end
	return prefix..value;
end

local function checksum_16(b, start)
	local sum = 0;
	local i = start or 1;

	while i < #b do
		sum = sum + b[i];
		sum = sum + b[i + 1] * 256;
		i = i + 2;
	end
	print("Raw sum: "..toHexString(sum));

	sum = bit.rshift(sum, 16) + bit.band(sum, 0xffff);
	sum = sum + bit.rshift(sum, 16);
	sum = bit.bnot(sum);
	sum = bit.band(sum, 0xffff); -- truncate to 16 bits
	return sum
end

local f_name = 1;
local f_base = 2;
local f_length = 3;

local fields = {
	{"Checksum", 0x00, 2},
	{"TT Text", 0x23, 1},
};

local function getFieldByIndex(index)
	for i = 1, #fields do
		if index >= fields[i][f_base] and index < fields[i][f_base] + fields[i][f_length] then
			return fields[i][f_name];
		end
	end
	return "Unknown";
end

local function analyseSlots()
	local diffFound = false;
	local newSlotData = {};
	for i = 1, number_of_slots do
		newSlotData[i] = memory.readbyterange(slot_size * (i - 1), slot_size, "EEPROM");
	end
	if #slot_data == number_of_slots then
		for i = 1, #slot_data do
			for j = 0, slot_size do
				if slot_data[i][j + 1] ~= newSlotData[i][j + 1] then
					local fieldName = getFieldByIndex(j);
					if fieldName ~= "Unknown" then
						print("Diff at "..i.."->"..toHexString(j, 2)..": "..toHexString(slot_data[i][j + 1], 2).."->"..toHexString(newSlotData[i][j + 1], 2).." ("..fieldName..")");
					else
						print("Diff at "..i.."->"..toHexString(j, 2)..": "..toHexString(slot_data[i][j + 1], 2).."->"..toHexString(newSlotData[i][j + 1], 2));
					end
					diffFound = true;
				end
			end
			if diffFound then
				print("Checksum "..i..": "..toHexString(checksum_16(newSlotData[i], 3), 4).." Actual: "..toHexString(newSlotData[i][1],2)..toHexString(newSlotData[i][1],2,""));
			end
		end
		if diffFound then
			print();
		end
	end

	slot_data = newSlotData;
end

event.onframestart(analyseSlots, "Analyse slots");