-- PAL 0x7fbf10
-- JP 0x7fc460
pointer_list = 0x7fbff0;
object_pointers = {};
object_index = 1;
max_objects = 0xff;

-- camera_pointer = 0x7f5d10;
camera_pointer = 0x7fb968;
camera_focus_pointer = 0x178;
visibility = 0x63; -- 127 = visible

kong_pointer = 0x7fbb4c;
grab_pointer = 0x32c;
model_pointer = 0x00;

grab_script_mode = "Grab";

-- Keybinds
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm
decrease_object_index_key = "B";
increase_object_index_key = "N";
grab_object_key = "V";
switch_grab_script_mode_key = "C";

decrease_object_index_pressed = false;
increase_object_index_pressed = false;
grab_object_pressed = false;
switch_mode_pressed = false;

function switch_grab_script_mode()
	if grab_script_mode == "Grab" then
		grab_script_mode = "Camera";
	else
		grab_script_mode = "Grab";
	end
end

function process_input ()
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

function grab_object ()
	if grab_script_mode == "Grab" then
		kong_object = mainmemory.read_u24_be(kong_pointer + 1);
		if object_index <= #object_pointers then
			mainmemory.writebyte(kong_object + grab_pointer, 0x80);
			mainmemory.write_u24_be(kong_object + grab_pointer + 1, object_pointers[object_index]);
			mainmemory.writebyte(kong_object + grab_pointer + 4, 0x80);
			mainmemory.write_u24_be(kong_object + grab_pointer + 4 + 1, object_pointers[object_index]);
		end
	elseif grab_script_mode == "Camera" then
		camera_object = mainmemory.read_u24_be(camera_pointer + 1);
		if object_index <= #object_pointers then
			mainmemory.writebyte(camera_object + camera_focus_pointer, 0x80);
			mainmemory.write_u24_be(camera_object + camera_focus_pointer + 1, object_pointers[object_index]);
		end
	end
end

function pull_objects ()
	object_pointers = {};
	object_found = true;
	object_no = 0;
	kong_object = mainmemory.read_u24_be(kong_pointer + 1);
	camera_object = mainmemory.read_u24_be(camera_pointer + 1);

	while object_found do
		pointer = mainmemory.read_u24_be(pointer_list + (object_no * 4) + 1);
		object_found = (pointer ~= 0xffffff) and (pointer ~= 0x000000) and (object_no <= max_objects);

		if object_found then
			if (grab_script_mode == "Grab" and (pointer ~= kong_object)) or (grab_script_mode == "Camera" and (pointer ~= camera_object)) then
				object_model_pointer = mainmemory.read_u24_be(pointer + model_pointer + 1);
				if object_model_pointer ~= 0x000000 then
					table.insert(object_pointers, pointer);
				end
			end
			object_no = object_no + 1;
		end
	end

	object_index = math.min(object_index, math.max(1, #object_pointers));

	gui_x = 32;
	gui_y = 32;
	row = 0;
	height = 16;

	gui.text(gui_x, gui_y + height * row, "Index: "..object_index.."/"..#object_pointers, null, null, 'bottomright');
	row = row + 1;
	if grab_script_mode == "Grab" then
		gui.text(gui_x, gui_y + height * row, string.format("Grabbed object:  0x%06x", mainmemory.read_u24_be(kong_object + grab_pointer + 1)), null, null, 'bottomright');
		row = row + 1;
	elseif grab_script_mode == "Camera" then
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

event.onframestart(pull_objects, "Evaluate Object Pointer List");
event.onframestart(process_input, "Grab Object Keybinds");