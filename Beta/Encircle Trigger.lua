local function isPointer(value)
	return value >= 0x80000000 and value <= 0x807FFFFF;
end

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

local slot_unknown_counter = 0x3A; -- u16_be

-- Relative to model pointer
local model_x_pos = 0x00; -- Float
local model_y_pos = model_x_pos + 4; -- Float
local model_z_pos = model_y_pos + 4; -- Float
local model_scale = 0x0C;

local model_rot_x = 0x10; -- Float
local model_rot_y = model_rot_x + 4; -- Float
local model_rot_z = model_rot_y + 4; -- Float

function getArraySize()
	local trigger_array = mainmemory.read_u24_be(trigger_array_pointer + 1);
	if trigger_array > 0 and trigger_array < 0x7FFFFF then
		return mainmemory.read_u32_be(trigger_array - 0x0C) / slot_size;
	end
	return 0;
end

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

--0x63
--0x65
function setByteModel(relative_address, value)
	local arrayCount = mainmemory.read_u32_be(trigger_array_count);
	for i = 0, arrayCount - 1 do
		local modelBase = getModelBase(i);
		if modelBase >= 0 and modelBase <= 0x7FFFFF then
			mainmemory.writebyte(modelBase + relative_address, value);
		end
	end
end

-----------------------
-- Encircle bollocks --
-----------------------

local Game = {};
object_pointers = {};
object_index = 1;

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

function populateObjectPointerList()
	object_pointers = {};
	num_slots = mainmemory.read_u32_be(trigger_array_count);

	-- Fill and sort pointer list
	for i = 0, num_slots - 1 do
		table.insert(object_pointers, getSlotBase(i));
	end
	table.sort(object_pointers);
end

local function encircle_player()
	if encircle_enabled then
		local current_player_x = Game.getXPosition();
		local current_player_y = Game.getYPosition();
		local current_player_z = Game.getZPosition();

		-- Iterate and set position
		local x, z, modelPointer;
		for i = 1, #object_pointers do
			x = current_player_x + math.cos(math.pi * 2 * i / #object_pointers) * radius;
			z = current_player_z + math.sin(math.pi * 2 * i / #object_pointers) * radius;

			-- Set hitbox X, Y, Z
			mainmemory.writefloat(object_pointers[i] + slot_x_pos, x, true);
			mainmemory.writefloat(object_pointers[i] + slot_y_pos, current_player_y, true);
			mainmemory.writefloat(object_pointers[i] + slot_z_pos, z, true);

			-- Set model X, Y, Z
			modelPointer = mainmemory.read_u24_be(object_pointers[i] + slot_model_pointer + 1);
			if modelPointer > 0 and modelPointer <= 0x7FFFFF then
				mainmemory.writefloat(modelPointer + model_x_pos, x, true);
				mainmemory.writefloat(modelPointer + model_y_pos, current_player_y, true);
				mainmemory.writefloat(modelPointer + model_z_pos, z, true);
			end
		end
	end
end
event.onframestart(encircle_player, "ScriptHawk - Encircle: Object type 2");

-----------------
-- UI Bollocks --
-----------------

grab_script_mode = "Examine";

local decrease_object_index_key = "N";
local increase_object_index_key = "M";
local switch_grab_script_mode_key = "C";

local decrease_object_index_pressed = false;
local increase_object_index_pressed = false;
local switch_mode_pressed = false;

local green_highlight = 0xFF00FF00;
local yellow_highlight = 0xFFFFFF00;

local function switch_grab_script_mode()
	if grab_script_mode == 'Examine' then
		grab_script_mode = 'List';
	else
		grab_script_mode = 'Examine';
	end
end

local function getExamineData(pointer)
	local examine_data = {};

	local modelPointer = mainmemory.read_u32_be(pointer + slot_model_pointer);
	local hasModel = isPointer(modelPointer);

	local xPos = mainmemory.readfloat(pointer + slot_x_pos, true);
	local yPos = mainmemory.readfloat(pointer + slot_y_pos, true);
	local zPos = mainmemory.readfloat(pointer + slot_z_pos, true);
	local hasPosition = xPos ~= 0 or yPos ~= 0 or zPos ~= 0 or hasModel;

	table.insert(examine_data, { "Slot base", string.format("0x%06x", pointer) });
	table.insert(examine_data, { "Separator", 1 });

	if hasPosition then
		table.insert(examine_data, { "Hitbox X", xPos });
		table.insert(examine_data, { "Hitbox Y", yPos });
		table.insert(examine_data, { "Hitbox Z", zPos });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Hitbox Scale", mainmemory.readfloat(pointer + slot_scale, true) });
		table.insert(examine_data, { "Separator", 1 });
	end

	table.insert(examine_data, { "Unknown Pointer", string.format("0x%08x", mainmemory.read_u32_be(pointer + slot_unknown_pointer, true)) });
	table.insert(examine_data, { "Unknown Counter", mainmemory.read_u16_be(pointer + slot_unknown_counter) });

	if hasModel then
		modelPointer = modelPointer - 0x80000000;
		table.insert(examine_data, { "Model Base", string.format("0x%08x", modelPointer) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Model X", mainmemory.readfloat(modelPointer + model_x_pos, true) });
		table.insert(examine_data, { "Model Y", mainmemory.readfloat(modelPointer + model_y_pos, true) });
		table.insert(examine_data, { "Model Z", mainmemory.readfloat(modelPointer + model_z_pos, true) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Model Scale", mainmemory.readfloat(modelPointer + model_scale, true) });
		table.insert(examine_data, { "Separator", 1 });
	end

	return examine_data;
end

local function process_input()
	input_table = input.get();

	-- Hold down key prevention
	if input_table[decrease_object_index_key] == nil then
		decrease_object_index_pressed = false;
	end

	if input_table[increase_object_index_key] == nil then
		increase_object_index_pressed = false;
	end

	if input_table[switch_grab_script_mode_key] == nil then
		switch_grab_script_mode_pressed = false;
	end

	-- Check for key presses
	if input_table[decrease_object_index_key] == true and decrease_object_index_pressed == false then
		object_index = object_index - 1;
		if object_index <= 0 then
			object_index = #object_pointers;
		end
		decrease_object_index_pressed = true;
	end

	if input_table[increase_object_index_key] == true and increase_object_index_pressed == false then
		object_index = object_index + 1;
		if object_index > #object_pointers then
			object_index = 1;
		end
		increase_object_index_pressed = true;
	end

	if input_table[switch_grab_script_mode_key] == true and switch_grab_script_mode_pressed == false then
		switch_grab_script_mode();
		switch_grab_script_mode_pressed = true;
	end
end

local function draw_gui()
	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	populateObjectPointerList();

	gui.text(gui_x, gui_y + height * row, "Mode: "..grab_script_mode, nil, nil, 'bottomright');
	row = row + 1;

	gui.text(gui_x, gui_y + height * row, "Array Size: "..getArraySize(), nil, nil, 'bottomright');
	row = row + 1;

	gui.text(gui_x, gui_y + height * row, "Index: "..object_index.."/"..#object_pointers, nil, nil, 'bottomright');
	row = row + 1;

	if #object_pointers > 0 and object_index <= #object_pointers then
		if grab_script_mode == "Examine" then
			local examine_data = getExamineData(object_pointers[object_index]);
			for i = #examine_data, 1, -1 do
				if examine_data[i][1] ~= "Separator" then
					gui.text(gui_x, gui_y + height * row, examine_data[i][1]..": "..examine_data[i][2], nil, nil, 'bottomright');
					row = row + 1;
				else
					row = row + examine_data[i][2];
				end
			end
		end

		if grab_script_mode == "List" then
			for i = #object_pointers, 1, -1 do
				if object_index == i then
					gui.text(gui_x, gui_y + height * row, i..": "..string.format("0x%06x", object_pointers[i] or 0), green_highlight, nil, 'bottomright');
				else
					if object_pointers[i] == kongObject then
						gui.text(gui_x, gui_y + height * row, i..": "..string.format("0x%06x", object_pointers[i] or 0), yellow_highlight, nil, 'bottomright');
					else
						gui.text(gui_x, gui_y + height * row, i..": "..string.format("0x%06x", object_pointers[i] or 0), nil, nil, 'bottomright');
					end
				end
				row = row + 1;
			end
		end
	end
end
event.onframestart(populateObjectPointerList, "ScriptHawk - Populate Object Model 2 Pointers");
event.onframestart(process_input, "ScriptHawk - Object Model 2 Input");
event.onframestart(draw_gui, "ScriptHawk - Draw Object Model 2 OSD");

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