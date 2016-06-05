local object_array_base = 0x300;
local object_size = 0x20;
local object_array_capacity = 30;

local object_fields = {
	["object_type"] = 0x00, -- Byte
	["object_types"] = {
		[0x01] = "Player",
		--[0x18] = "Unknown 0x18", -- Title Screen
		[0x22] = "Bubble", -- Big Frog
		[0x23] = "Big Frog",
		[0x24] = "Octopus", -- Arm segment
		[0x2B] = "Dying", -- Small enemy
		[0x2D] = "Bird", -- Left
		[0x2E] = "Fish", -- Big Left
		[0x2F] = "Frog", -- Small, Grounded
		[0x30] = "Fish", -- Small Left
		[0x31] = "Seahorse", -- Left
		[0x32] = "Seahorse", -- Right
		[0x34] = "Fish", -- Small Right
		[0x35] = "Fish", -- Big Right
		[0x33] = "Bird", -- Right
		[0x36] = "Frog", -- Small, Jumping
		[0x38] = "Box Particle",
		[0x39] = "Box Particle",
		[0x3A] = "Box Particle",
		[0x3B] = "Box Particle",
		[0x3C] = "Money",
		[0x3E] = "Scorpion", -- Left
		[0x3F] = "Scorpion", -- Right
		[0x44] = "Rice Cake",
		--[0x46] = "Unknown Enemy 0x46",
		--[0x48] = "Unknown Enemy 0x48",
		[0x4E] = "Ring",
		[0x4F] = "Ghost",
		--[0x55] = "Unknown Enemy 0x55",
	},
	["state"] = 0x01, -- Byte
	["x_position"] = 0x0C, -- Byte
	["y_position"] = 0x0E, -- Byte
};

function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	prefix = prefix or "0x";
	desiredLength = desiredLength or string.len(value);
	while string.len(value) < desiredLength do
		value = "0"..value;
	end
	return prefix..value;
end

function draw_ui()
	local gui_x = 2;
	local gui_y = 2;
	local row = 0;
	local height = 16;

	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType ~= 0 then
			if type(object_fields.object_types[objectType]) ~= "nil" then
				objectType = object_fields.object_types[objectType];
			else
				objectType = "Unknown ("..toHexString(objectType)..")";
			end
			local xPosition = mainmemory.readbyte(objectBase + object_fields.x_position);
			local yPosition = mainmemory.readbyte(objectBase + object_fields.y_position);
			gui.text(gui_x, gui_y + height * row, xPosition..", "..yPosition.." - "..objectType.." "..toHexString(objectBase), nil, nil, 'bottomright');
			row = row + 1;
		end
	end

	--local examine_data = getExamineData(getObjectBase(object_index));
	--for i = #examine_data, 1, -1 do
	--	if examine_data[i][1] ~= "Separator" then
	--		gui.text(gui_x, gui_y + height * row, examine_data[i][1]..": "..examine_data[i][2], nil, nil, 'bottomright');
	--		row = row + 1;
	--	else
	--		row = row + examine_data[i][2];
	--	end
	--end
end

while true do
	draw_ui();
	emu.yield();
end