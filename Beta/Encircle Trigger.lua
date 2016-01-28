-- Things in this array
	-- GB's
	-- Doors in helm
	-- K. Rool's chair
	-- Gorilla Grab
	-- Bananaporters
	-- DK portals
	-- Trees
	-- Instrument pads
	-- Wrinkly doors

local kong_object_pointer = 0x7FBB4D;
local trigger_array_pointer = 0x7F6000;
local trigger_array_count = trigger_array_pointer + 4; -- u32_be

local slot_size = 0x90;

-- Relative to trigger slot
local slot_x_pos = 0x00; -- Float
local slot_y_pos = slot_x_pos + 4; -- Float
local slot_z_pos = slot_y_pos + 4; -- Float

local slot_scale = 0x0C; -- Float

local slot_model_pointer = 0x20;
local slot_unknown_pointer = 0x24;

-- Relative to model pointer
local model_x_pos = 0x00; -- Float
local model_y_pos = model_x_pos + 4; -- Float
local model_z_pos = model_y_pos + 4; -- Float
local model_scale = 0x0C;

local model_rot_x = 0x10; -- Float
local model_rot_y = model_rot_x + 4; -- Float
local model_rot_z = model_rot_y + 4; -- Float

function getSlotBase(index)
	local trigger_array = mainmemory.read_u24_be(trigger_array_pointer + 1);
	return trigger_array + index * slot_size;
end

function getModelBase(index)
	local trigger_array = mainmemory.read_u24_be(trigger_array_pointer + 1);
	return mainmemory.read_u24_be(trigger_array + index * slot_size + slot_model_pointer + 1);
end

function setScale(desiredScale)
	local arrayCount = mainmemory.read_u32_be(trigger_array_count);
	for i = 0, arrayCount - 1 do
		mainmemory.writefloat(getSlotBase(i) + slot_scale, desiredScale, true);
	end
end

function setFloat(relative_address, value)
	local arrayCount = mainmemory.read_u32_be(trigger_array_count);
	for i = 0, arrayCount - 1 do
		mainmemory.writefloat(getSlotBase(i) + relative_address, value, true);
	end
end

function setFloatModel(relative_address, value)
	local arrayCount = mainmemory.read_u32_be(trigger_array_count);
	for i = 0, arrayCount - 1 do
		local modelBase = getModelBase(i);
		if modelBase >= 0 and modelBase <= 0x7FFFFF then
			mainmemory.writefloat(modelBase + relative_address, value, true);
		end
	end
end

-----------------------
-- Encircle bollocks --
-----------------------

local Game = {};

radius = 200;
encircle_enabled = false;

-- Relative to player object
local x_pos = 0x7C;
local y_pos = x_pos + 4;
local z_pos = y_pos + 4;

local function getKongObject() -- TODO: Cache this
	return mainmemory.read_u24_be(kong_object_pointer);
end

function Game.getXPosition()
	return mainmemory.readfloat(getKongObject() + x_pos, true);
end

function Game.getYPosition()
	return mainmemory.readfloat(getKongObject() + y_pos, true);
end

function Game.getZPosition()
	return mainmemory.readfloat(getKongObject() + z_pos, true);
end

local function encircle_player()
	if encircle_enabled then
		local current_player_x = Game.getXPosition();
		local current_player_y = Game.getYPosition();
		local current_player_z = Game.getZPosition();
		local currentPointers = {};

		num_slots = mainmemory.read_u32_be(trigger_array_count);

		-- Fill and sort pointer list
		for i = 0, num_slots - 1 do
			table.insert(currentPointers, getSlotBase(i));
		end
		table.sort(currentPointers);

		-- Iterate and set position
		local x, z, modelPointer;
		for i = 1, #currentPointers do
			x = current_player_x + math.cos(math.pi * 2 * i / #currentPointers) * radius;
			z = current_player_z + math.sin(math.pi * 2 * i / #currentPointers) * radius;

			-- Set hitbox X, Y, Z
			mainmemory.writefloat(currentPointers[i] + slot_x_pos, x, true);
			mainmemory.writefloat(currentPointers[i] + slot_y_pos, current_player_y, true);
			mainmemory.writefloat(currentPointers[i] + slot_z_pos, z, true);

			-- Set model X, Y, Z
			modelPointer = mainmemory.read_u24_be(currentPointers[i] + slot_model_pointer + 1);
			if modelPointer > 0 and modelPointer <= 0x7FFFFF then
				mainmemory.writefloat(modelPointer + model_x_pos, x, true);
				mainmemory.writefloat(modelPointer + model_y_pos, current_player_y, true);
				mainmemory.writefloat(modelPointer + model_z_pos, z, true);
			end
		end
	end
end
event.onframestart(encircle_player, "ScriptHawk - Encircle: Object type 2");

-------------------
-- For papa cfox --
-------------------

local linked_list_pointer = 0x7F0990;

local list_previous_pointer = 0x00; -- pointer
local list_size = 0x04; -- u32be

max_length = 0x40;

function setText(pointer, message)
	local messageLength = math.min(string.len(message), max_length);
	for i = 1, messageLength do
		mainmemory.writebyte(pointer + i - 1, string.byte(message, i));
	end
	mainmemory.writebyte(pointer + messageLength, 0x00);
end

function setDKTV(message)
	local linkedListRoot = mainmemory.read_u24_be(linked_list_pointer + 1);
	local linkedListSize = mainmemory.read_u32_be(linked_list_pointer + 4);
	local totalSize = 0;
	local currentPointer = linkedListRoot;
	while totalSize < linkedListSize do
		local currentObjectSize = mainmemory.read_u32_be(currentPointer + 4);
		currentPointer = currentPointer + 0x10;
		if currentObjectSize == 0x40 then
			if mainmemory.read_u32_be(currentPointer) == 0x444B2054 then
				setText(currentPointer, message);
			end
		end
		currentPointer = currentPointer + currentObjectSize;
		totalSize = currentPointer - linkedListRoot;
	end
	
end