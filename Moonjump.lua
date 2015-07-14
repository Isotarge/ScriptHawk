-- USA Defaults
kong_model_pointer = 0x7fbb4d;

----------------------
-- Region Detection --
----------------------

romName = gameinfo.getromname();

if bizstring.contains(romName, "Europe") then
	kong_model_pointer = 0x7fba6d;
elseif bizstring.contains(romName, "Japan") then
	kong_model_pointer = 0x7fbfbd;
elseif bizstring.contains(romName, "Kiosk") then
	kong_model_pointer = 0x7b5afd;
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

local options_rot_units_label =              forms.label(options_form,    "Units:",                                      col(5),      row(0) + label_offset, 48,               14);
local options_toggle_rot_units_button =      forms.button(options_form,   rotation_units,     toggle_rotation_units,     col(7),      row(0),                64,               button_height);

local function updateUIReadouts_moonjump()
	forms.settext(options_speedy_speed_value_label, speedy_speeds[speedy_index]);
	forms.settext(options_precision_value_label, precision);
	forms.settext(options_mode_button, mode);
	forms.settext(options_moon_mode_button, moon_mode);
	forms.settext(options_toggle_rot_units_button, rotation_units);
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