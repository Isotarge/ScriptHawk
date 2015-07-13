-- USA Defaults
file               = 0x7467c8;
training_barrel    = 0x7ed230;
menu_flags         = 0x7ed558;
kong_model_pointer = 0x7fbb4d;
tb_void_byte       = 0x7fbb63;
pointer_list       = 0x7fbff0;
kongbase           = 0x7fc950;
global_base        = 0x7fcc41;

key_base = {
	[0] = 0x7ed3af,
	[1] = 0x7ed057,
	[2] = 0x7ed3af
};

key_collected_bitmasks = {
	0x04,
	0x04,
	0x04,
	0x01,
	0x10,
	0x10,
	0x20,
	0x10
};

----------------------
-- Region Detection --
----------------------

romName = gameinfo.getromname();

if bizstring.contains(romName, "Europe") then
	file               = 0x740F18;
	training_barrel    = 0x7ed150;
	menu_flags         = 0x7ed478;
	kong_model_pointer = 0x7fba6d;
	tb_void_byte       = 0x7FBA83;
	pointer_list       = 0x7fbf10;
	kongbase           = 0x7fc890;
	global_base        = 0x7fcb81;
elseif bizstring.contains(romName, "Japan") then
	file               = 0x746088;
	training_barrel    = 0x7ed84c;
	menu_flags         = 0x7ed9c8;
	kong_model_pointer = 0x7fbfbd;
	tb_void_byte       = 0x7FBFD3;
	pointer_list       = 0x7fc460;
	kongbase           = 0x7fcde0;
	global_base        = 0x7fd0d1;

	key_base = {
		[0] = 0x7ED4C7,
		[1] = 0x7ED31B,
		[2] = 0x7ED673
	};
	
	key_collected_bitmasks = { -- TODO
		0xFF,
		0xFF,
		0xFF,
		0xFF,
		0xFF,
		0xFF,
		0xFF,
		0xFF
	};
elseif bizstring.contains(romName, "Kiosk") then
	file               = 0x7467c8; -- TODO
	training_barrel    = 0x7ed150; -- TODO
	menu_flags         = 0x7ed558; -- TODO
	kong_model_pointer = 0x7b5afd;
	tb_void_byte       = 0x7fbb63; -- TODO
	pointer_list       = 0x7f5e58;
	kongbase           = 0x7fc950; -- TODO
	global_base        = 0x7fcc41; -- TODO
end

---------------
-- Key stuff --
---------------

key_offsets = {
	0x00,
	0x06,
	0x0e,
	0x12,
	0x1a,
	0x21,
	0x24,
	0x2c
};

function keyGet(number)
	current_file = mainmemory.readbyte(file);
	if current_file >= 0 and current_file <= 2 then
		current_value = mainmemory.readbyte(key_base[current_file] + key_offsets[number]);
		new_value = bit.bor(current_value, key_collected_bitmasks[number]);
		mainmemory.write_u8(key_base[current_file] + key_offsets[number], new_value);
	end
end

function keyLose(number)
	current_file = mainmemory.readbyte(file);
	if current_file >= 0 and current_file <= 2 then
		current_value = mainmemory.readbyte(key_base[current_file] + key_offsets[number]);
		new_value = bit.bnot(bit.band(current_value, key_collected_bitmasks[number]));
		mainmemory.write_u8(key_base[current_file] + key_offsets[number], new_value);
	end
end

------------------
-- Unlock menus --
------------------

function unlock_menus ()
	for byte=0,7 do
		mainmemory.write_u8(menu_flags + byte, 0xff);
	end
end

event.onframestart(unlock_menus, "Unlock Menus");


------------------------------------
-- Never Slip                     --
-- Written by Isotarge, 2014-2015 --
------------------------------------

-- Pointers
local slope_object_pointer = 0x7f94b9;
local slope_object_pointer_2 = 0x7fd581;

-- Relative to slope object
local slope_timer = 0xc3;

-- Relative to kong object
local slope_byte = 0xDE;

local function neverSlip()
	-- Patch the slope timer
	local slope_object = mainmemory.read_u24_be(slope_object_pointer);
	mainmemory.write_u8(slope_object + slope_timer, 0);
	
	-- Patch the Kong object
	local kong_model = mainmemory.read_u24_be(kong_model_pointer);
	local slope_value = mainmemory.read_u8(kong_model + slope_byte);
	mainmemory.write_u8(kong_model + slope_byte, math.max(3, slope_value));
end

----------------------------------
-- Refill Consumables           --
-- Based on research by Exchord --
----------------------------------

-- Maximum values
max_melons = 3;
max_health = max_melons * 4;

max_coins          = 50;
max_crystals       = 20;
max_film           = 10;
max_oranges        = 20;
max_musical_energy = 10;
max_standard_ammo  = 50;
max_homing_ammo    = 50;

-- Relative to global_base
standard_ammo = 0;
homing_ammo   = 2;
oranges       = 4;
crystals      = 5;
film          = 8;
health        = 10;
melons        = 11;

-- Kong index
DK     = 0;
Diddy  = 1;
Lanky  = 2;
Tiny   = 3;
Chunky = 4;

-- Pointers relative to Kong base
moves      = 0;
sim_slam   = 1;
weapon     = 2;
instrument = 4;
coins      = 7;
lives      = 9; -- This is used as instrument ammo in single player

function unlock_moves ()
	for kong=DK,Chunky do
		local base = kongbase + kong * 0x5e;
		mainmemory.write_u8(base + moves,      3);
		mainmemory.write_u8(base + sim_slam,   3);
		mainmemory.write_u8(base + weapon,     7);
		mainmemory.write_u8(base + instrument, 15);
	end
end

------------------------------------
-- Moonjump BizHawk Lua port      --
-- Based on work by SubDrag, 2006 --
------------------------------------
-- http://www.therwp.com/forums/showthread.php?t=7238

-- Relative to kong_model_pointer
local visibility = 0x63; -- 127 = visible

local x_pos = 0x7c;
local y_pos = 0x80;
local z_pos = 0x84;

local floor = 0xa4;
local angle = 0xe4;

local camera_focus_pointer = 0x178;

local kick_animation = 0x181;
local kick_animation_value = 0x29;

local kick_freeze = 0xc4;
local kick_freeze_value = 0xc020;

--------------
-- Keybinds --
--------------
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm

local decrease_precision_key = "Comma";
local decrease_precision_pressed = false;

local increase_precision_key = "Period";
local increase_precision_pressed = false;

local reset_max_key = "Slash";
local reset_max_pressed = false;

local switch_mode_key = "M";
local switch_mode_pressed = false;

local switch_moon_mode_key = "K";
local switch_moon_mode_pressed = false;

-----------
-- State --
-----------

-- Stops garbage min/max dx/dy/dz values
local firstframe = true;

x = 0.0;
y = 0.0;
z = 0.0;
floor_y = 0.0;

dx = 0.0;
dy = 0.0;
dz = 0.0;
d  = 0.0;

prev_x = 0.0;
prev_y = 0.0;
prev_z = 0.0;
prev_floor = 0.0;

max_dx = 0.0;
max_dy = 0.0;
max_dz = 0.0;
max_d  = 0.0;

local speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
local speedy_index = 7;

local rot_speed = 10;

-- Rounding precision
precision = 3;

local mode = "Position";
local moon_mode = "None";

local function decrease_precision()
	precision = math.max(0, precision - 1);
	updateUIReadouts_moonjump();
end

local function increase_precision()
	precision = math.min(5, precision + 1);
	updateUIReadouts_moonjump();
end

local function decrease_speedy_speed()
	speedy_index = math.max(1, speedy_index - 1);
	updateUIReadouts_moonjump();
end

local function increase_speedy_speed()
	speedy_index = math.min(#speedy_speeds, speedy_index + 1);
	updateUIReadouts_moonjump();
end

local function invisify()
	local kong_model = mainmemory.read_u24_be(kong_model_pointer);
	mainmemory.writebyte(kong_model + visibility, 0x00);
	updateUIReadouts_moonjump();
end

local function visify()
	local kong_model = mainmemory.read_u24_be(kong_model_pointer);
	mainmemory.writebyte(kong_model + visibility, 0x7f);
	updateUIReadouts_moonjump();
end

local current_invisify = "Invisify";
local function toggle_invisify()
	if current_invisify == "Invisify" then
		invisify();
		current_invisify = "Visify";
	else
		visify();
		current_invisify = "Invisify";
	end
	updateUIReadouts_moonjump();
end

local function clear_tb_void()
	tb_void_byte_val = mainmemory.readbyte(tb_void_byte);
	mainmemory.writebyte(tb_void_byte, bit.bor(tb_void_byte_val, 0x30));
end

local function force_pause()
	mainmemory.writebyte(tb_void_byte, 0x31);
end

local function toggle_mode()
	if mode == 'Position' then
		mode = 'Rotation';
	else
		mode = 'Position';
	end
	updateUIReadouts_moonjump();
end

local function toggle_moonmode()
	if moon_mode == 'None' then
		moon_mode = 'Kick';
	elseif moon_mode == 'Kick' then
		moon_mode = 'All';
	elseif moon_mode == 'All' then
		moon_mode = 'None';
	end
	updateUIReadouts_moonjump();
end

local function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", (num or 0)));
end

local function null_check(value)
	return value ~= nil and (value > 0) ~= (value <= 0);
end

local function rotation_to_degrees(num)
	return ((num % 4096) / 4096) * 360;
end

two_pi = math.pi * 2;
local function rotation_to_radians(num)
	return ((num % 4096) / 4096) * two_pi;
end

local rotation_units = "Degrees";
local function toggle_rotation_units()
	if rotation_units == "Degrees" then
		rotation_units = "Radians";
	elseif rotation_units == "Radians" then
		rotation_units = "Units";
	else
		rotation_units = "Degrees";
	end
	updateUIReadouts_moonjump();
end

local function formatRotation(num)
	if rotation_units == "Degrees" then
		return round(rotation_to_degrees(num), precision).."°";
	elseif rotation_units == "Radians" then
		return round(rotation_to_radians(num), precision);
	else
		return num;
	end
end

--------------
-- GUI Code --
--------------

local form_padding = 8;
local label_offset = 4;
local long_label_width = 140;
local button_height = 24;

local function row(row_num)
	return round(form_padding + button_height * row_num, 0);
end

local function col(col_num)
	return row(col_num);
end

local options_form = forms.newform(col(17), row(10), "Moonjump Options");

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--    Handle                                 Type                         Caption             Callback                   X position   Y position             Width             Height      --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local options_mode_label =                   forms.label(options_form,    "Mode:",                                       col(0),      row(0) + label_offset, 48,               button_height);
local options_mode_button =                  forms.button(options_form,   mode,               toggle_mode,               col(2),      row(0),                64,               button_height);

local options_moon_mode_label =              forms.label(options_form,    "Moon:",                                       col(0),      row(1) + label_offset, 48,               button_height);
local options_moon_mode_button =             forms.button(options_form,   moon_mode,          toggle_moonmode,           col(2),      row(1),                64,               button_height);

local options_precision_label =              forms.label(options_form,    "Precision:",                                  col(0),      row(2) + label_offset, 54,               14);
local options_decrease_precision_button =    forms.button(options_form,   "-",                decrease_precision,        col(4) - 32, row(2),                button_height,    button_height);
local options_increase_precision_button =    forms.button(options_form,   "+",                increase_precision,        col(5) - 32, row(2),                button_height,    button_height);
local options_precision_value_label =        forms.label(options_form,    precision,                                     col(5),      row(2) + label_offset, 54,               14);

local options_speedy_speed_label =           forms.label(options_form,    "Speed:",                                      col(0),      row(3) + label_offset, 54,               14);
local options_decrease_speedy_speed_button = forms.button(options_form,   "-",                decrease_speedy_speed,     col(4) - 32, row(3),                button_height,    button_height);
local options_increase_speedy_speed_button = forms.button(options_form,   "+",                increase_speedy_speed,     col(5) - 32, row(3),                button_height,    button_height);
local options_speedy_speed_value_label =     forms.label(options_form,    speedy_speeds[speedy_index],                   col(5),      row(3) + label_offset, 54,               14);

local options_toggle_neverslip =             forms.checkbox(options_form, "Never Slip",                                  col(0),      row(4));
local options_toggle_infinites =             forms.checkbox(options_form, "Infinites",                                   col(0),      row(5));
local options_toggle_homing_ammo =           forms.checkbox(options_form, "Homing Ammo",                                 col(0),      row(6));
local options_toggle_tbarrels =              forms.checkbox(options_form, "Training Barrels",                            col(0),      row(7));

local options_rot_units_label =              forms.label(options_form,    "Units:",                                      col(5),      row(0) + label_offset, 48,               14);
local options_toggle_rot_units_button =      forms.button(options_form,   rotation_units,     toggle_rotation_units,     col(7),      row(0),                64,               button_height);

local options_toggle_invisify_button =       forms.button(options_form,   "Invisify",         toggle_invisify,           col(5),      row(4),                col(4) + 8,       button_height);
local options_clear_tb_void_button =         forms.button(options_form,   "Clear TB void",    clear_tb_void,             col(5),      row(5),                col(4) + 8,       button_height);
local options_force_pause_button =           forms.button(options_form,   "Force Pause",      force_pause,               col(5),      row(6),                col(4) + 8,       button_height);
local options_unlock_moves_button =          forms.button(options_form,   "Unlock Moves",     unlock_moves,              col(5),      row(7),                col(4) + 8,       button_height);

local options_get_key1_button =              forms.button(options_form,   "Get Key 1",        function() keyGet(1) end,  col(10),     row(0),                64,               button_height);
local options_lose_key1_button =             forms.button(options_form,   "Lose Key",         function() keyLose(1) end, col(13),     row(0),                64,               button_height);
local options_get_key2_button =              forms.button(options_form,   "Get Key 2",        function() keyGet(2) end,  col(10),     row(1),                64,               button_height);
local options_lose_key2_button =             forms.button(options_form,   "Lose Key",         function() keyLose(2) end, col(13),     row(1),                64,               button_height);
local options_get_key3_button =              forms.button(options_form,   "Get Key 3",        function() keyGet(3) end,  col(10),     row(2),                64,               button_height);
local options_lose_key3_button =             forms.button(options_form,   "Lose Key",         function() keyLose(3) end, col(13),     row(2),                64,               button_height);
local options_get_key4_button =              forms.button(options_form,   "Get Key 4",        function() keyGet(4) end,  col(10),     row(3),                64,               button_height);
local options_lose_key4_button =             forms.button(options_form,   "Lose Key",         function() keyLose(4) end, col(13),     row(3),                64,               button_height);
local options_get_key5_button =              forms.button(options_form,   "Get Key 5",        function() keyGet(5) end,  col(10),     row(4),                64,               button_height);
local options_lose_key5_button =             forms.button(options_form,   "Lose Key",         function() keyLose(5) end, col(13),     row(4),                64,               button_height);
local options_get_key6_button =              forms.button(options_form,   "Get Key 6",        function() keyGet(6) end,  col(10),     row(5),                64,               button_height);
local options_lose_key6_button =             forms.button(options_form,   "Lose Key",         function() keyLose(6) end, col(13),     row(5),                64,               button_height);
local options_get_key7_button =              forms.button(options_form,   "Get Key 7",        function() keyGet(7) end,  col(10),     row(6),                64,               button_height);
local options_lose_key7_button =             forms.button(options_form,   "Lose Key",         function() keyLose(7) end, col(13),     row(6),                64,               button_height);
local options_get_key8_button =              forms.button(options_form,   "Get Key 8",        function() keyGet(8) end,  col(10),     row(7),                64,               button_height);
local options_lose_key8_button =             forms.button(options_form,   "Lose Key",         function() keyLose(8) end, col(13),     row(7),                64,               button_height);

local function updateUIReadouts_moonjump()
	forms.settext(options_speedy_speed_value_label, speedy_speeds[speedy_index]);
	forms.settext(options_precision_value_label, precision);
	forms.settext(options_mode_button, mode);
	forms.settext(options_moon_mode_button, moon_mode);
	forms.settext(options_toggle_rot_units_button, rotation_units);
	forms.settext(options_toggle_invisify_button, current_invisify);
end

local function gofast(rel_pointer, speed)
	local kong_model = mainmemory.read_u24_be(kong_model_pointer);
	local pos = mainmemory.readfloat(kong_model + rel_pointer, true);
	mainmemory.writefloat(kong_model + rel_pointer, pos + speed, true);
end

local function rotate(axis, amount)
	local kong_model = mainmemory.read_u24_be(kong_model_pointer);
	local current_value = mainmemory.read_u16_be(kong_model + angle + axis * 2);
	mainmemory.write_u16_be(kong_model + angle + axis * 2, (current_value + amount) % 4096);
end

local function mainloop()
	if not emu.islagged() then
		joypad_pressed = joypad.getimmediate();
		if joypad_pressed["P1 L"] then
			gofast(y_pos, speedy_speeds[speedy_index]);
		end
		if mode == 'Position' then
			rot_rad = rotation_to_radians(rot_y);
			if joypad_pressed["P1 DPad U"] then
				gofast(x_pos, speedy_speeds[speedy_index] * math.sin(rot_rad));
				gofast(z_pos, speedy_speeds[speedy_index] * math.cos(rot_rad));
			end
			if joypad_pressed["P1 DPad D"] then
				gofast(x_pos, -1.0 * (speedy_speeds[speedy_index] * math.sin(rot_rad)));
				gofast(z_pos, -1.0 * (speedy_speeds[speedy_index] * math.cos(rot_rad)));
			end
			if joypad_pressed["P1 DPad L"] then
				gofast(x_pos, speedy_speeds[speedy_index] * math.cos(rot_rad));
				gofast(z_pos, -1.0 * (speedy_speeds[speedy_index] * math.sin(rot_rad)));
			end
			if joypad_pressed["P1 DPad R"] then
				gofast(x_pos, -1.0 * (speedy_speeds[speedy_index] * math.cos(rot_rad)));
				gofast(z_pos, speedy_speeds[speedy_index] * math.sin(rot_rad));
			end
		end
		if mode == 'Rotation' then
			if joypad_pressed["P1 DPad U"] then
				rotate(0, rot_speed);
			end
			if joypad_pressed["P1 DPad D"] then
				rotate(0, -rot_speed);
			end
			if joypad_pressed["P1 DPad L"] then
				rotate(2, -rot_speed);
			end
			if joypad_pressed["P1 DPad R"] then
				rotate(2, rot_speed);
			end
		end

		-- Moves, Consumables
		if forms.ischecked(options_toggle_infinites) then
			mainmemory.write_u8(global_base + standard_ammo, max_standard_ammo);
			if forms.ischecked(options_toggle_homing_ammo) then
				mainmemory.write_u8(global_base + homing_ammo, max_homing_ammo);
			else
				mainmemory.write_u8(global_base + homing_ammo, 0);
			end
			mainmemory.write_u8(global_base + oranges,  max_oranges);
			mainmemory.write_u16_be(global_base + crystals, max_crystals * 150);
			mainmemory.write_u8(global_base + film,     max_film);
			mainmemory.write_u8(global_base + health,   max_health);
			mainmemory.write_u8(global_base + melons,   max_melons);
			for kong=DK,Chunky do
				local base = kongbase + kong * 0x5e;
				mainmemory.write_u8(base + coins, max_coins);
				mainmemory.write_u8(base + lives, max_musical_energy);
			end
		end

		if forms.ischecked(options_toggle_tbarrels) then
			mainmemory.write_u8(training_barrel, 0xff);
		end
		
		if forms.ischecked(options_toggle_neverslip) then
			neverSlip();
		end
	end
end

function handle_input()
	input_table = input.get();

	-- Hold down key prevention
	if input_table[decrease_precision_key] == nil then
		decrease_precision_pressed = false;
	end

	if input_table[increase_precision_key] == nil then
		increase_precision_pressed = false;
	end

	if input_table[reset_max_key] == nil then
		reset_max_pressed = false;
	end

	if input_table[switch_mode_key] == nil then
		switch_mode_pressed = false;
	end

	if input_table[switch_moon_mode_key] == nil then
		switch_moon_mode_pressed = false;
	end

	-- Check for key presses
	if input_table[decrease_precision_key] == true and decrease_precision_pressed == false then
		decrease_precision();
		decrease_precision_pressed = true;
	end

	if input_table[increase_precision_key] == true and increase_precision_pressed == false then
		increase_precision();
		increase_precision_pressed = true;
	end

	if input_table[reset_max_key] == true and reset_max_pressed == false then
		max_dx = 0.0;
		max_dy = 0.0;
		max_dz = 0.0;
		max_d = 0.0;
		reset_max_pressed = true;
	end

	if input_table[switch_mode_key] == true and switch_mode_pressed == false then
		toggle_mode();
		switch_mode_pressed = true;
	end

	if input_table[switch_moon_mode_key] == true and switch_moon_mode_pressed == false then
		toggle_moonmode();
		switch_moon_mode_pressed = true;
	end
end

local function plot_pos()
	local kong_model = mainmemory.read_u24_be(kong_model_pointer);

	x       = mainmemory.readfloat(kong_model + x_pos, true);
	y       = mainmemory.readfloat(kong_model + y_pos, true);
	z       = mainmemory.readfloat(kong_model + z_pos, true);
	floor_y = mainmemory.readfloat(kong_model + floor, true);

	rot_x = mainmemory.read_u16_be(kong_model + angle + 0);
	rot_y = mainmemory.read_u16_be(kong_model + angle + 2);
	rot_z = mainmemory.read_u16_be(kong_model + angle + 4);
	rot_l = mainmemory.read_u16_be(kong_model + angle + 6);

	if firstframe then
		prev_x = x;
		prev_y = y;
		prev_z = z;
		prev_floor = floor_y;

		firstframe = false;
	end

	if not emu.islagged() then
		dx = x - prev_x;
		dy = y - prev_y;
		dz = z - prev_z;
		d = math.sqrt(dx*dx + dz*dz);

		if (max_dx ~= nil and max_dy ~= nil and max_dz ~= nil and max_d ~= nil) and (dx ~= nil and dy ~= nil and dz ~= nil and d ~= nil) then
			if math.abs(dx) > max_dx then max_dx = math.abs(dx) end
			if math.abs(dy) > max_dy then max_dy = math.abs(dy) end
			if math.abs(dz) > max_dz then max_dz = math.abs(dz) end
			if d > max_d then max_d = d end
		end

		prev_x = x;
		prev_y = y;
		prev_z = z;
		prev_floor = floor_y;

		-- Moonkick
		if moon_mode == 'All' or (moon_mode == 'Kick' and mainmemory.readbyte(kong_model + kick_animation) == kick_animation_value) then
			mainmemory.write_u16_be(kong_model + kick_freeze, kick_freeze_value);
		end
	end

	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	if null_check(x) and null_check(y) and null_check(z) and null_check(floor_y) then
		gui.text(gui_x, gui_y + height * row, "X: "..round(x, precision));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "Y: "..round(y, precision));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "Z: "..round(z, precision));
		row = row + 2;
		gui.text(gui_x, gui_y + height * row, "Floor: "..round(floor_y, precision));
		row = row + 2;
	end

	if null_check(dy) and null_check(d) then
		gui.text(gui_x, gui_y + height * row, "dY:  "..round(dy, precision));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "dXZ: "..round(d, precision));
		row = row + 2;
	end

	if null_check(max_dy) and null_check(max_d) then
		gui.text(gui_x, gui_y + height * row, "Max dY:  "..round(max_dy, precision));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "Max dXZ: "..round(max_d, precision));
		row = row + 2;
	end

	if null_check(rot_x) and null_check(rot_y) and null_check(rot_z) and null_check(rot_l) then
		gui.text(gui_x, gui_y + height * row, "Rot X: "..formatRotation(rot_x));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "Rot Y: "..formatRotation(rot_y));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "Rot Z: "..formatRotation(rot_z));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "Rot L: "..formatRotation(rot_l));
		row = row + 2;
	end

	updateUIReadouts_moonjump();
end

event.onframestart(mainloop, "Moonjump");
event.onframestart(handle_input, "Keyboard input handler");
event.onframestart(plot_pos, "Plot position");