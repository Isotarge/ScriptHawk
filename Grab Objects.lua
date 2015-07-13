local pointer_list;
local kong_model_pointer;
-- camera_pointer = 0x7f5d10; -- TODO: What is this value?
local camera_pointer = 0x7fb968; -- TODO: Find on all versions of the game

local romName = gameinfo.getromname();

if bizstring.contains(romName, "Donkey Kong 64") then
	if bizstring.contains(romName, "USA") then
		pointer_list = 0x7fbff0;
		kong_model_pointer = 0x7fbb4d;
	elseif bizstring.contains(romName, "Europe") then
		pointer_list = 0x7fbf10;
		kong_model_pointer = 0x7fba6d;
	elseif bizstring.contains(romName, "Japan") then
		pointer_list = 0x7fc460;
		kong_model_pointer = 0x7fbfbd;
	elseif bizstring.contains(romName, "Kiosk") then
		pointer_list = 0x7f5e58;
		kong_model_pointer = 0x7b5afd;
	end
else
	console.log("This game is not supported.");
	return;
end

local object_pointers = {};
local object_index = 1;
local max_objects = 0xff;

local radius = 100;
local shade_byte = 0x16D;

local x_pos = 0x7c;
local y_pos = 0x80;
local z_pos = 0x84;
local shade_byte = 0x16D;

local camera_focus_pointer = 0x178;
local visibility = 0x63; -- 127 = visible

local grab_pointer = 0x32c;
local model_pointer = 0x00;

local grab_script_mode = "Grab";

-- Keybinds
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm
local decrease_object_index_key = "B";
local increase_object_index_key = "N";
local grab_object_key = "V";
local switch_grab_script_mode_key = "C";

local decrease_object_index_pressed = false;
local increase_object_index_pressed = false;
local grab_object_pressed = false;
local switch_mode_pressed = false;

local function switch_grab_script_mode()
	if grab_script_mode == 'Grab' then
		grab_script_mode = 'Camera';
	elseif grab_script_mode == 'Camera' then
		grab_script_mode = 'Encircle';
	elseif grab_script_mode == 'Encircle' then
		grab_script_mode = 'Grab';
	end
end

local function grab_object()
	if grab_script_mode == "Grab" then
		local kong_object = mainmemory.read_u24_be(kong_model_pointer);
		if object_index <= #object_pointers then
			mainmemory.writebyte(kong_object + grab_pointer, 0x80);
			mainmemory.write_u24_be(kong_object + grab_pointer + 1, object_pointers[object_index]);
			mainmemory.writebyte(kong_object + grab_pointer + 4, 0x80);
			mainmemory.write_u24_be(kong_object + grab_pointer + 4 + 1, object_pointers[object_index]);
		end
	elseif grab_script_mode == "Camera" then
		local camera_object = mainmemory.read_u24_be(camera_pointer + 1);
		if object_index <= #object_pointers then
			mainmemory.writebyte(camera_object + camera_focus_pointer, 0x80);
			mainmemory.write_u24_be(camera_object + camera_focus_pointer + 1, object_pointers[object_index]);
		end
	end
end

local function encircle_kong()
	local i, x, z;

	local kong_object = mainmemory.read_u24_be(kong_model_pointer);
	local kong_x = mainmemory.readfloat(kong_object + x_pos, true);
	local kong_y = mainmemory.readfloat(kong_object + y_pos, true);
	local kong_z = mainmemory.readfloat(kong_object + z_pos, true);

	for i=1,#object_pointers do
		x = kong_x + math.cos(math.pi * 2 * i / #object_pointers) * radius;
		z = kong_z + math.sin(math.pi * 2 * i / #object_pointers) * radius;

		mainmemory.writefloat(object_pointers[i] + x_pos, x, true);
		mainmemory.writefloat(object_pointers[i] + y_pos, kong_y, true);
		mainmemory.writefloat(object_pointers[i] + z_pos, z, true);
	end
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

	if input_table[grab_object_key] == nil then
		grab_object_pressed = false;
	end

	if input_table[switch_grab_script_mode_key] == nil then
		switch_grab_script_mode_pressed = false;
	end

	-- Check for key presses
	if input_table[decrease_object_index_key] == true and decrease_object_index_pressed == false then
		object_index = math.max(1, object_index - 1);
		decrease_object_index_pressed = true;
	end

	if input_table[increase_object_index_key] == true and increase_object_index_pressed == false then
		object_index = math.min(#object_pointers, object_index + 1);
		increase_object_index_pressed = true;
	end

	if input_table[grab_object_key] == true and grab_object_pressed == false then
		grab_object();
		grab_object_pressed = true;
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

	gui.text(gui_x, gui_y + height * row, "Index: "..object_index.."/"..#object_pointers, null, null, 'bottomright');
	row = row + 1;
	if grab_script_mode == "Grab" then
		local kong_object = mainmemory.read_u24_be(kong_model_pointer);
		gui.text(gui_x, gui_y + height * row, string.format("Grabbed object:  0x%06x", mainmemory.read_u24_be(kong_object + grab_pointer + 1)), null, null, 'bottomright');
		row = row + 1;
	elseif grab_script_mode == "Camera" then
		local camera_object = mainmemory.read_u24_be(camera_pointer + 1);
		gui.text(gui_x, gui_y + height * row, string.format("Focused object:  0x%06x", mainmemory.read_u24_be(camera_object + camera_focus_pointer + 1)), null, null, 'bottomright');
		row = row + 1;
	end
	if (#object_pointers > 0) then
		gui.text(gui_x, gui_y + height * row, string.format("Selected object: 0x%06x", object_pointers[object_index] or 0), null, null, 'bottomright');
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, string.format("Model pointer: 0x%06x", mainmemory.read_u24_be(object_pointers[object_index] + model_pointer + 1)), null, null, 'bottomright');
		row = row + 1;
	end
	gui.text(gui_x, gui_y + height * row, "Mode: "..grab_script_mode, null, null, 'bottomright');
	row = row + 1;
end

local function pull_objects()
	object_pointers = {};
	local object_found = true;
	local object_no = 0;
	local kong_object = mainmemory.read_u24_be(kong_model_pointer);
	local camera_object = mainmemory.read_u24_be(camera_pointer + 1);

	while object_found do
		local pointer = mainmemory.read_u24_be(pointer_list + (object_no * 4) + 1);
		object_found = (pointer ~= 0xffffff) and (pointer ~= 0x000000) and (object_no <= max_objects);

		if object_found then
			if ((grab_script_mode == "Grab" or grab_script_mode == "Encircle") and (pointer ~= kong_object)) or (grab_script_mode == "Camera" and (pointer ~= camera_object)) then
				local object_model_pointer = mainmemory.read_u24_be(pointer + model_pointer + 1);
				if object_model_pointer ~= 0x000000 then
					table.insert(object_pointers, pointer);
				end
			end
			object_no = object_no + 1;
		end
	end

	-- Clamp index
	object_index = math.min(object_index, math.max(1, #object_pointers));

	if grab_script_mode == "Encircle" then
		encircle_kong();
	end

	draw_gui();
end

event.onframestart(pull_objects, "Evaluate Object Pointer List");
event.onframestart(process_input, "Grab Object Keybinds");