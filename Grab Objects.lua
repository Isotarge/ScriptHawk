local pointer_list;
local kong_model_pointer;
local camera_pointer;
safeMode = true;

local romName = gameinfo.getromname();

if bizstring.contains(romName, "Donkey Kong 64") then
	if bizstring.contains(romName, "USA") and not bizstring.contains(romName, "Kiosk") then
		pointer_list = 0x7fbff0;
		camera_pointer = 0x7fb968;
		kong_model_pointer = 0x7fbb4d;
	elseif bizstring.contains(romName, "Europe") then
		pointer_list = 0x7fbf10;
		camera_pointer = 0x7fb888;
		kong_model_pointer = 0x7fba6d;
	elseif bizstring.contains(romName, "Japan") then
		pointer_list = 0x7fc460;
		camera_pointer = 0x7fbdd8;
		kong_model_pointer = 0x7fbfbd;
	elseif bizstring.contains(romName, "Kiosk") then
		pointer_list = 0x7b5e58;
		camera_pointer = 0x7b5918; -- TODO: Does this work?
		kong_model_pointer = 0x7b5afd;
		grab_pointer = 0x2F4;
	end
else
	print("This game is not supported.");
	return;
end

local object_pointers = {};
local object_index = 1;
local max_objects = 0xFF;
local radius = 100;

local actor_types = {
	[2] = "DK",
	[3] = "Diddy",
	[4] = "Lanky",
	[5] = "Tiny",
	[6] = "Chunky",
	[7] = "Krusha",
	[8] = "Rambi",
	[9] = "Enguarde",
	[18] = "Rambi Box",
	[26] = "TNT Barrel",
	[27] = "TNT Barrel Spawner (Armydillo)",
	[28] = "Bonus Barrel", -- TODO: all types?
	[32] = "Swinging Light",
	[33] = "Vine (Brown)",
	[36] = "Peanut",
	[40] = "Mini Monkey barrel",
	[42] = "Grape",
	[43] = "Feather",
	[48] = "Coconut",
	[49] = "Rocketbarrel",
	[57] = "Strong Kong Barrel",
	[58] = "Swinging Light",
	[61] = "Boulder",
	[63] = "Vase (O)",
	[64] = "Vase (:)",
	[65] = "Vase (Triangle)",
	[66] = "Vase (+)",
	[69] = "Vine (Green)",
	[72] = "Boss Key",
	[85] = "Steel Keg",
	[98] = "Tag Barrel",
	[97] = "TNT Barrel Spawner (Dogadon)",
	[114] = "DK Balloon", -- TODO: Verify
	[115] = "K. Lumsy's Cage", -- TODO: Also rabbit race finish line?
	[130] = "Apple (Fungi)",
	[133] = "Barrel",
	[134] = "Training Barrel",
	[136] = "Tag Barrel",
	[138] = "B. Locker",
	[139] = "Rainbow Coin Patch",
	[163] = "Banana Fairy (BFI)",
	[167] = "Cannon",
	[176] = "Timer", -- Training barrel
	[178] = "Beaver (Blue)",
	[182] = "Barrel Enemy (Normal)",
	[183] = "Zinger",
	[184] = "Snide",
	[185] = "Armydillo",
	[187] = "Klump",
	[188] = "Camera",
	[189] = "Cranky",
	[190] = "Funky",
	[191] = "Candy",
	[197] = "Trapped Diddy",
	[199] = "Trapped Tiny",
	[201] = "Llama",
	[203] = "Padlock (T&S)",
	[204] = "Mad Jack",
	[205] = "Klaptrap (Green)",
	[206] = "Zinger",
	[212] = "Beaver (Gold)",
	[216] = "Pufftoss",
	[224] = "Mushroom Enemy",
	[226] = "Troff",
	[235] = "Robo-Kremling",
	[234] = "Scoff",
	[236] = "Dogadon",
	[238] = "Kremling",
	[241] = "Kasplat (DK)",
	[242] = "Kasplat (Diddy)",
	[243] = "Kasplat (Lanky)",
	[244] = "Kasplat (Tiny)",
	[245] = "Kasplat (Chunky)",
	[248] = "Banana Fairy",
	[252] = "Rabbit (Fungi)",
	[254] = "Fake DK", -- TODO: Also used on main menu & DK Rap?
	[261] = "Robo-Zinger",
	[264] = "Squawks",
	[270] = "Domino Enemy",
	[271] = "Dice Enemy",
	[275] = "K. Lumsy",
	[291] = "Kosha",
	[333] = "Unknown on main menu",
	[334] = "Padlock (K. Lumsy)",
}

-- Relative to objects found in the pointer list
local model_pointer = 0x00;
local rendering_parameters_pointer = 0x04;
local current_bone_array_pointer = 0x08;

local hand_state = 0x47; -- Bitfield
local actor_type = 0x58; -- TODO: Document values for this
local visibility = 0x63; -- 127 = visible

local specular_highlight = 0x6D;

local shadow_width = 0x6E;
local shadow_height = 0x6F;

local x_pos = 0x7C;
local y_pos = 0x80;
local z_pos = 0x84;

local visibility = 0x63; -- 127 = visible

local floor = 0xA4;
local distance_from_floor = 0xB4;

local velocity = 0xB8;
local acceleration = 0xBC; -- Seems wrong

local y_velocity = 0xC0;
local y_acceleration = 0xC4;

local gravity_strength = 0xC8;

local light_thing = 0xCC; -- Values 0x00->0x14

local x_rot = 0xE4;
local y_rot = 0xE6;
local z_rot = 0xE8;

local shade_byte = 0x16D;

local tb_kickout_timer = 0x1B4;

local camera_focus_pointer = 0x178; -- TODO: Verify for all versions
local grab_pointer = 0x32c;

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
		grab_script_mode = 'Examine';
	elseif grab_script_mode == 'Examine' then
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

local function getExamineData(pointer)
	local examine_data = {};

	table.insert(examine_data, { "X", mainmemory.readfloat(pointer + x_pos, true) });
	table.insert(examine_data, { "Y", mainmemory.readfloat(pointer + y_pos, true) });
	table.insert(examine_data, { "Z", mainmemory.readfloat(pointer + z_pos, true) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Rot X", mainmemory.read_u16_be(pointer + x_rot) });
	table.insert(examine_data, { "Rot Y", mainmemory.read_u16_be(pointer + y_rot) });
	table.insert(examine_data, { "Rot Z", mainmemory.read_u16_be(pointer + z_rot) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Velocity", mainmemory.readfloat(pointer + velocity, true) });
	table.insert(examine_data, { "Y Velocity", mainmemory.readfloat(pointer + y_velocity, true) });
	table.insert(examine_data, { "Y Accel", mainmemory.readfloat(pointer + y_acceleration, true) });
	table.insert(examine_data, { "Separator", 1 });

	local currentActorType = mainmemory.read_u32_be(pointer + actor_type);
	if type(actor_types[currentActorType]) ~= "nil" then
		currentActorType = actor_types[currentActorType];
	end
	table.insert(examine_data, { "Actor type", currentActorType });
	table.insert(examine_data, { "Hand state", mainmemory.readbyte(pointer + hand_state) });
	table.insert(examine_data, { "Specular highlight", mainmemory.readbyte(pointer + specular_highlight) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Shadow width", mainmemory.readbyte(pointer + shadow_width) });
	table.insert(examine_data, { "Shadow height", mainmemory.readbyte(pointer + shadow_height) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Shade byte", mainmemory.readbyte(pointer + shade_byte) });
	table.insert(examine_data, { "Visibility", mainmemory.readbyte(pointer + visibility) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Grab pointer", string.format("0x%08x", mainmemory.read_u32_be(pointer + grab_pointer)) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "TB kickout timer", mainmemory.read_u32_be(pointer + tb_kickout_timer) });

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
		object_index = math.max(1, object_index);
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

	if #object_pointers > 0 and object_index <= #object_pointers then
		gui.text(gui_x, gui_y + height * row, string.format("Selected object: 0x%06x", object_pointers[object_index] or 0), null, null, 'bottomright');
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, string.format("Model pointer: 0x%06x", mainmemory.read_u24_be(object_pointers[object_index] + model_pointer + 1)), null, null, 'bottomright');
		row = row + 1;

		if grab_script_mode == "Examine" or not safeMode or true then
			local examine_data = getExamineData(object_pointers[object_index]);
			local i;
			for i=#examine_data,1,-1 do
				if examine_data[i][1] ~= "Separator" then
					gui.text(gui_x, gui_y + height * row, examine_data[i][1]..": "..examine_data[i][2], null, null, 'bottomright');
					row = row + 1;
				else
					row = row + examine_data[i][2];
				end
			end
		end
	end
	gui.text(gui_x, gui_y + height * row, "Mode: "..grab_script_mode, null, null, 'bottomright');
	row = row + 1;
end

local function isValidObject(pointer, kong_object, camera_object)
	if not safeMode then
		return true;
	end

	if grab_script_mode == "Examine" then
		return true;
	end

	if grab_script_mode == "Camera" and pointer ~= camera_object then
		return true;
	end

	if grab_script_mode == "Grab" or grab_script_mode == "Encircle" then
		if pointer ~= kong_object then
			return true;
		end
	end
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
			if isValidObject(pointer, kong_object, camera_object) then
				local object_model_pointer = mainmemory.read_u24_be(pointer + model_pointer + 1);
				if object_model_pointer ~= 0x000000 or not safeMode then
					table.insert(object_pointers, pointer);
				end
			end
		end
		object_no = object_no + 1;
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