local romName = gameinfo.getromname();
local Game = require "games.blank";

if bizstring.contains(romName, "Donkey Kong 64") then
	Game = require "games.dk64";
elseif bizstring.contains(romName, "Banjo-Kazooie") or (bizstring.contains(romName, "Banjo to Kazooie no Daibouken") and not bizstring.contains(romName, "2")) then
	Game = require "games.bk";
elseif bizstring.contains(romName, "Rayman 2 - The Great Escape") then
	Game = require "games.rayman_2";
elseif bizstring.contains(romName, "Super Mario 64") then
	Game = require "games.sm64";
elseif bizstring.contains(romName, "Toy Story 2") then
	Game = require "games.ts2";
elseif bizstring.contains(romName, "Ocarina of Time") or bizstring.contains(romName, "Toki no Ocarina") then
	Game = require "games.oot";
elseif bizstring.contains(romName, "Majora's Mask") or bizstring.contains(romName, "Mujura no Kamen") then
	Game = require "games.mm";
elseif bizstring.contains(romName, "Elmo's Letter Adventure") or bizstring.contains(romName, "Elmo's Number Journey") then
	Game = require "games.elmo";
else
	console.log("This game is not currently supported.");
	return;
end

if not Game.detectVersion(romName) then
	console.log("This version of the game is not currently supported.");
	return;
end

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

-----------
-- State --
-----------

local mode = "Position";
local rotation_units = "Degrees";

-- Stops garbage min/max dx/dy/dz values
local firstframe = true;

previous_map = "";
previous_map_value = 0;

x = 0.0;
y = 0.0;
z = 0.0;
-- TODO
-- floor_y = 0.0

dx = 0.0;
dy = 0.0;
dz = 0.0;
d  = 0.0;

prev_x = 0.0;
prev_y = 0.0;
prev_z = 0.0;

max_dx = 0.0;
max_dy = 0.0;
max_dz = 0.0;
max_d  = 0.0;

-- Rounding precision
precision = 3;

local function decrease_precision()
	precision = math.max(0, precision - 1);
	updateUIReadouts_moonjumpGameAgnostic();
end

local function increase_precision()
	precision = math.min(5, precision + 1);
	updateUIReadouts_moonjumpGameAgnostic();
end

local function decrease_speedy_speed()
	Game.speedy_index = math.max(1, Game.speedy_index - 1);
	updateUIReadouts_moonjumpGameAgnostic();
end

local function increase_speedy_speed()
	Game.speedy_index = math.min(#Game.speedy_speeds, Game.speedy_index + 1);
	updateUIReadouts_moonjumpGameAgnostic();
end

--------------------------------
-- Bit manipulation functions --
--------------------------------

function get_bit(field, index)
	if index < 32 then
		local bitmask = math.pow(2, index);
		return bit.band(bitmask, field) == bitmask;
	end
	return false;
end

function set_bit(field, index)
	if index < 32 then
		local bitmask = math.pow(2, index);
		return bit.bor(bitmask, field);
	end
	return field;
end

function clear_bit(field, index)
	if index < 32 then
		local bitmask = math.pow(2, index);
		return bit.bnot(bit.band(field, bitmask));
	end
	return field;
end

----------------------------
-- Other helper functions --
----------------------------

local function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", (num or 0)));
end

local function rotation_to_degrees(num)
	return ((num % Game.max_rot_units) / Game.max_rot_units) * 360;
end

two_pi = math.pi * 2;
local function rotation_to_radians(num)
	return ((num % Game.max_rot_units) / Game.max_rot_units) * two_pi;
end

local function array_contains(array, value)
	local i;
	if #array > 0 then
		for i=1,#array do
			if array[i] == value then
				return true;
			end
		end
	end
	return false;
end

local function toggle_rotation_units()
	if rotation_units == "Degrees" then
		rotation_units = "Radians";
	elseif rotation_units == "Radians" then
		rotation_units = "Units";
	else
		rotation_units = "Degrees";
	end
	updateUIReadouts_moonjumpGameAgnostic();
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

local function toggle_mode()
	if mode == 'Position' then
		mode = 'Rotation';
	else
		mode = 'Position';
	end
	updateUIReadouts_moonjumpGameAgnostic();
end

--------------
-- GUI Code --
--------------

local form_padding = 8;
local label_offset = 5;
local dropdown_offset = 1;
local long_label_width = 140;
local button_height = 23;

local function row(row_num)
	return round(form_padding + button_height * row_num, 0);
end

local function col(col_num)
	return row(col_num);
end

local options_form = forms.newform(col(17), row(10), "ScriptHawk Options");

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Handle                              Type                         Caption             Callback                     X position   Y position                Width             Height      --
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local options_mode_label =                   forms.label(options_form,    "Mode:",                                   col(0),      row(0) + label_offset,    44,               button_height);
local options_mode_button =                  forms.button(options_form,   mode,               toggle_mode,           col(2),      row(0),                   64,               button_height);

local options_precision_label =              forms.label(options_form,    "Precision:",                              col(0),      row(1) + label_offset,    54,               14);
local options_decrease_precision_button =    forms.button(options_form,   "-",                decrease_precision,    col(4) - 28, row(1),                   button_height,    button_height);
local options_increase_precision_button =    forms.button(options_form,   "+",                increase_precision,    col(5) - 28, row(1),                   button_height,    button_height);
local options_precision_value_label =        forms.label(options_form,    precision,                                 col(5),      row(1) + label_offset,    54,               14);

local options_speedy_speed_label =           forms.label(options_form,    "Speed:",                                  col(0),      row(2) + label_offset,    54,               14);
local options_decrease_speedy_speed_button = forms.button(options_form,   "-",                decrease_speedy_speed, col(4) - 28, row(2),                   button_height,    button_height);
local options_increase_speedy_speed_button = forms.button(options_form,   "+",                increase_speedy_speed, col(5) - 28, row(2),                   button_height,    button_height);
local options_speedy_speed_value_label =     forms.label(options_form,    "0",                                       col(5),      row(2) + label_offset,    54,               14);

local options_map_dropdown =                 forms.dropdown(options_form, Game.maps,                                 col(0),      row(3) + dropdown_offset, col(9) + 7,       button_height);
local options_map_checkbox =                 forms.checkbox(options_form, "Take me there",              col(0) + dropdown_offset, row(4) + dropdown_offset);
local options_toggle_infinites =             forms.checkbox(options_form, "Infinites",                  col(0) + dropdown_offset, row(5) + dropdown_offset);

local options_rot_units_label =              forms.label(options_form,    "Units:",                                  col(5),      row(0) + label_offset,    44,               14);
local options_toggle_rot_units_button =      forms.button(options_form,   rotation_units,     toggle_rotation_units, col(7),      row(0),                   64,               button_height);

-- Init any custom UI that the game module uses
Game.initUI(options_form, col, row, button_height, label_offset, dropdown_offset);

local function findMapValue()
	for i=1,#Game.maps do
		if Game.maps[i] == previous_map then
			return i;
		end
	end
	return 0;
end

function updateUIReadouts_moonjumpGameAgnostic()
	forms.settext(options_speedy_speed_value_label, Game.speedy_speeds[Game.speedy_index]);
	forms.settext(options_precision_value_label, precision);
	forms.settext(options_mode_button, mode);
	forms.settext(options_toggle_rot_units_button, rotation_units);
	if previous_map ~= forms.gettext(options_map_dropdown) then
		previous_map = forms.gettext(options_map_dropdown);
		previous_map_value = findMapValue();
	end
end

local function gofast(axis, speed)
	if axis == "x" then
		Game.setXPosition(Game.getXPosition() + speed);
	elseif axis == "y" then
		Game.setYPosition(Game.getYPosition() + speed);
	elseif axis == "z" then
		Game.setZPosition(Game.getZPosition() + speed);
	end
end

local function rotate(axis, amount)
	if axis == "x" then
		Game.setXRotation((Game.getXRotation() + amount) % Game.max_rot_units);
	elseif axis == "y" then
		Game.setYRotation((Game.getYRotation() + amount) % Game.max_rot_units);
	elseif axis == "z" then
		Game.setZRotation((Game.getZRotation() + amount) % Game.max_rot_units);
	end
end

local function mainloop()
	if Game.isPhysicsFrame() then
		joypad_pressed = joypad.getimmediate();
		if joypad_pressed["P1 L"] then
			gofast("y", Game.speedy_speeds[Game.speedy_index]);
		end
		if mode == 'Position' and type(rot_y) ~= "nil" then
			rot_rad = rotation_to_radians(rot_y);
			if joypad_pressed["P1 DPad U"] then
				gofast("x", Game.speedy_speeds[Game.speedy_index] * math.sin(rot_rad));
				gofast("z", Game.speedy_speeds[Game.speedy_index] * math.cos(rot_rad));
			end
			if joypad_pressed["P1 DPad D"] then
				gofast("x", -1.0 * (Game.speedy_speeds[Game.speedy_index] * math.sin(rot_rad)));
				gofast("z", -1.0 * (Game.speedy_speeds[Game.speedy_index] * math.cos(rot_rad)));
			end
			if joypad_pressed["P1 DPad L"] then
				gofast("x", Game.speedy_speeds[Game.speedy_index] * math.cos(rot_rad));
				gofast("z", -1.0 * (Game.speedy_speeds[Game.speedy_index] * math.sin(rot_rad)));
			end
			if joypad_pressed["P1 DPad R"] then
				gofast("x", -1.0 * (Game.speedy_speeds[Game.speedy_index] * math.cos(rot_rad)));
				gofast("z", Game.speedy_speeds[Game.speedy_index] * math.sin(rot_rad));
			end
		end
		if mode == 'Rotation' then
			if joypad_pressed["P1 DPad U"] then
				rotate("x", Game.rot_speed);
			end
			if joypad_pressed["P1 DPad D"] then
				rotate("x", -Game.rot_speed);
			end
			if joypad_pressed["P1 DPad L"] then
				rotate("z", -Game.rot_speed);
			end
			if joypad_pressed["P1 DPad R"] then
				rotate("z", Game.rot_speed);
			end
		end
	end

	if forms.ischecked(options_toggle_infinites) then
		Game.applyInfinites();
	end

	if forms.ischecked(options_map_checkbox) then
		Game.setMap(previous_map_value);
	end
end

local function handle_input()
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
end

local function plot_pos()
	Game.eachFrame();

	x = Game.getXPosition();
	y = Game.getYPosition();
	z = Game.getZPosition();

	rot_x = Game.getXRotation();
	rot_y = Game.getYRotation();
	rot_z = Game.getZRotation();

	if firstframe then
		prev_x = x;
		prev_y = y;
		prev_z = z;

		firstframe = false;
	end

	if Game.isPhysicsFrame() then
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
	end

	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	if type(x) ~= "nil" and type(y) ~= "nil" and type(z) ~= "nil" then
		gui.text(gui_x, gui_y + height * row, "X: "..round(x, precision));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "Y: "..round(y, precision));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "Z: "..round(z, precision));
		row = row + 2;
		--gui.text(gui_x, gui_y + height * row, "Floor: "..round(floor_y, precision));
		--row = row + 2;
	end

	if type(dy) ~= "nil" and type(d) ~= "nil" then
		gui.text(gui_x, gui_y + height * row, "dY:  "..round(dy, precision));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "dXZ: "..round(d, precision));
		row = row + 2;
	end

	if type(max_dy) ~= "nil" and type(max_d) ~= "nil" then
		gui.text(gui_x, gui_y + height * row, "Max dY:  "..round(max_dy, precision));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "Max dXZ: "..round(max_d, precision));
		row = row + 2;
	end

	if type(rot_x) ~= "nil" and type(rot_y) ~= "nil" and type(rot_z) ~= "nil" then
		gui.text(gui_x, gui_y + height * row, "Rot X: "..formatRotation(rot_x));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "Rot Y: "..formatRotation(rot_y));
		row = row + 1;
		gui.text(gui_x, gui_y + height * row, "Rot Z: "..formatRotation(rot_z));
		row = row + 1;
		--gui.text(gui_x, gui_y + height * row, "Rot L: "..formatRotation(rot_l));
		--row = row + 2;
	end

	updateUIReadouts_moonjumpGameAgnostic();
end

event.onframestart(handle_input, "Keyboard input handler");
event.onframestart(plot_pos, "Plot position");
event.onframestart(mainloop, "Moonjump");