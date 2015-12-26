----------------------
-- Helper functions --
----------------------

function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num));
end

function isnan(x) return x ~= x end

function esc(str)
	return (str:gsub('%%', '%%%%')
		:gsub('%^', '%%%^')
		:gsub('%$', '%%%$')
		:gsub('%(', '%%%(')
		:gsub('%)', '%%%)')
		:gsub('%.', '%%%.')
		:gsub('%[', '%%%[')
		:gsub('%]', '%%%]')
		:gsub('%*', '%%%*')
		:gsub('%+', '%%%+')
		:gsub('%-', '%%%-')
		:gsub('%?', '%%%?'));
end

function stringContains(haystack, needle)
	return type(string.find(haystack, esc(needle))) == "number";
end

function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	prefix = prefix or "0x";
	desiredLength = desiredLength or string.len(value);
	while string.len(value) < desiredLength do
		value = "0"..value;
	end
	return prefix..value;
end

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
		return bit.band(field, bit.bnot(bitmask));
	end
	return field;
end

function deepcompare(t1, t2, ignore_mt)
	local ty1 = type(t1);
	local ty2 = type(t2);
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1);
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
		local v2 = t2[k1];
		if v2 == nil or not deepcompare(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
		local v1 = t1[k2];
		if v1 == nil or not deepcompare(v1,v2) then return false end
	end
	return true;
end

-----------------
-- Game checks --
-----------------

local romName = gameinfo.getromname();

if stringContains(romName, "Donkey Kong 64") then
	Game = require "games.dk64";
elseif stringContains(romName, "Banjo-Tooie") or stringContains(romName, "Banjo to Kazooie no Daibouken 2") then
	Game = require "games.bt";
elseif stringContains(romName, "Banjo-Kazooie") or stringContains(romName, "Banjo to Kazooie no Daibouken") then
	Game = require "games.bk";
elseif stringContains(romName, "Diddy Kong Racing") then
	Game = require "games.dkr";
elseif stringContains(romName, "Rayman 2 - The Great Escape") then
	Game = require "games.rayman_2";
elseif stringContains(romName, "Super Mario 64") then
	Game = require "games.sm64";
elseif stringContains(romName, "Toy Story 2") then
	Game = require "games.ts2";
elseif stringContains(romName, "Ocarina of Time") or stringContains(romName, "Toki no Ocarina") then
	Game = require "games.oot";
elseif stringContains(romName, "Majora's Mask") or stringContains(romName, "Mujura no Kamen") then
	Game = require "games.mm";
elseif stringContains(romName, "Elmo's Letter Adventure") or stringContains(romName, "Elmo's Number Journey") then
	Game = require "games.elmo";
else
	print("This game is not currently supported.");
	return;
end

if not Game.detectVersion(romName) then
	print("This version of the game is not currently supported.");
	return;
end

--------------------
-- Load libraries --
--------------------

JSON = require "lib.JSON";
Stats = require "lib.Stats";
Lips = require "lib.lips.lips";
require "lib.DPrint";

--------------
-- Keybinds --
--------------
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm

--local decrease_precision_key = "Comma";
--local decrease_precision_pressed = false;

--local increase_precision_key = "Period";
--local increase_precision_pressed = false;

local reset_max_key = "Slash";
local reset_max_pressed = false;

--local switch_mode_key = "M";
--local switch_mode_pressed = false;

-----------
-- State --
-----------

local form_controls = {};
local mode = "Position";
local rotation_units = "Degrees";

-- Stops garbage min/max dx/dy/dz values
local firstframe = true;
previous_frame = emu.framecount();
current_frame = emu.framecount();

previous_map = "";
previous_map_value = 0;

x = 0.0;
y = 0.0;
z = 0.0;

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

local function decreasePrecision()
	precision = math.max(0, precision - 1);
	gui.cleartext();
	updateUIReadouts_ScriptHawk();
end

local function increasePrecision()
	precision = math.min(5, precision + 1);
	gui.cleartext();
	updateUIReadouts_ScriptHawk();
end

local function decreaseSpeed()
	Game.speedy_index = math.max(1, Game.speedy_index - 1);
	gui.cleartext();
	updateUIReadouts_ScriptHawk();
end

local function increaseSpeed()
	Game.speedy_index = math.min(#Game.speedy_speeds, Game.speedy_index + 1);
	gui.cleartext();
	updateUIReadouts_ScriptHawk();
end

-------------------------
-- Practice mode stuff --
-------------------------

local practice_save_slot = 0;
local practice_decrease_slot_pressed = false;
local practice_increase_slot_pressed = false;
local practice_load_slot_pressed = false;
local practice_save_slot_pressed = false;

local function decreaseSaveSlot()
	practice_save_slot = math.max(0, practice_save_slot - 1);
	gui.cleartext();
	updateUIReadouts_ScriptHawk();
end

local function increaseSaveSlot()
	practice_save_slot = math.min(9, practice_save_slot + 1);
	gui.cleartext();
	updateUIReadouts_ScriptHawk();
end

----------------------------
-- Other helper functions --
----------------------------

function searchPointers(base, range)
	local address = 0;
	local foundPointers = {};
	for address = 0x000000, 0x7FFFFC do
		local value = mainmemory.read_u32_be(address);
		if value >= base - range and value <= base + range then
			table.insert(foundPointers, {["Address"] = toHexString(address), ["Value"] = toHexString(value)});
			dprint(toHexString(address).." -> "..toHexString(value));
		end
	end
	print_deferred();
	return foundPointers;
end

function rotation_to_degrees(num)
	return ((num % Game.max_rot_units) / Game.max_rot_units) * 360;
end

two_pi = math.pi * 2;
function rotation_to_radians(num)
	return ((num % Game.max_rot_units) / Game.max_rot_units) * two_pi;
end

local function array_contains(array, value)
	if type(array) == "table" and #array > 0 then
		local i;
		for i=1,#array do
			if array[i] == value then
				return true;
			end
		end
	end
	return false;
end

local function toggleRotationUnits()
	if rotation_units == "Degrees" then
		rotation_units = "Radians";
	elseif rotation_units == "Radians" then
		rotation_units = "Units";
	else
		rotation_units = "Degrees";
	end
	gui.cleartext();
	updateUIReadouts_ScriptHawk();
end

local function formatRotation(num)
	num = num or 0;
	if isnan(num) then
		num = 0;
	end
	if rotation_units == "Degrees" then
		return ""..round(rotation_to_degrees(num), precision).."°";
	elseif rotation_units == "Radians" then
		return round(rotation_to_radians(num), precision);
	end
	return num;
end

local function toggleMode()
	if mode == 'Position' then
		mode = 'Rotation';
	elseif mode == 'Rotation' then
		mode = 'Practice';
	else
		mode = 'Position';
	end
	gui.cleartext();
	updateUIReadouts_ScriptHawk();
end

---------------
-- Telemetry --
---------------

local telemetryData = {};
local collecting_telemetry = false;

-- Outputs telemetry data as CSV to the console
local function outputTelemetry()
	local i = 1;
	dprint("Time (Frames),X Position,Y Position,Z Position,Dxz,Dy,Rotation X,Rotation Y,Rotation Z,");
	for i=1,#telemetryData do
		dprint(i..","..telemetryData[i]["X Position"]..","..telemetryData[i]["Y Position"]..","..telemetryData[i]["Z Position"]..","..telemetryData[i]["Dxz"]..","..telemetryData[i]["Dy"]..","..telemetryData[i]["Rotation X"]..","..telemetryData[i]["Rotation Y"]..","..telemetryData[i]["Rotation Z"]..",");
	end
	print_deferred();
end

local function startTelemetry()
	collecting_telemetry = true;
	forms.settext(form_controls["Toggle Telemetry Button"], "Stop Telemetry");
	telemetryData = {};
end

local function stopTelemetry()
	collecting_telemetry = false;
	forms.settext(form_controls["Toggle Telemetry Button"], "Start Telemetry");

	outputTelemetry();
	return;

	-- Output to file
	-- Output data to JSON
	--local json_data = JSON:encode_pretty(telemetryData);
	--local file = io.open("Lua/ScriptHawk/DK64_Y_Data.json", "w+");
	--if type(file) ~= "nil" then
	--io.output(file);
	--io.write(json_data);
	--io.close(file);
	--else
	--print("Error writing to file =(");
	--outputTelemetry();
	--end
end

local function toggleTelemetry()
	if collecting_telemetry then
		stopTelemetry();
	else
		startTelemetry();
	end
end

--------------
-- GUI Code --
--------------

local form_padding = 8;
local label_offset = 5;
local dropdown_offset = 1;
local long_label_width = 140;
local button_height = 23;

-- OSD
local gui_x_offset = 32;
local gui_y_offset = 32;
local row_height = 16;

local function row(row_num)
	return round(form_padding + button_height * row_num, 0);
end

local function col(col_num)
	return row(col_num);
end

local options_form = forms.newform(col(17), row(10), "ScriptHawk Options");

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Handle                                    Type                         Caption          Callback              X position   Y position                Width          Height      --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
form_controls["Mode Label"] =                forms.label(options_form,    "Mode:",                               col(0),      row(0) + label_offset,    44,            button_height);
form_controls["Mode Button"] =               forms.button(options_form,   mode,            toggleMode,           col(2),      row(0),                   64,            button_height);

form_controls["Precision Label"] =           forms.label(options_form,    "Precision:",                          col(0),      row(1) + label_offset,    54,            14);
form_controls["Decrease Precision Button"] = forms.button(options_form,   "-",             decreasePrecision,    col(4) - 28, row(1),                   button_height, button_height);
form_controls["Increase Precision Button"] = forms.button(options_form,   "+",             increasePrecision,    col(5) - 28, row(1),                   button_height, button_height);
form_controls["Precision Value Label"] =     forms.label(options_form,    precision,                             col(5),      row(1) + label_offset,    44,            14);

form_controls["Speed Label"] =               forms.label(options_form,    "Speed:",                              col(0),      row(2) + label_offset,    54,            14);
form_controls["Decrease Speed Button"] =     forms.button(options_form,   "-",             decreaseSpeed,        col(4) - 28, row(2),                   button_height, button_height);
form_controls["Increase Speed Button"] =     forms.button(options_form,   "+",             increaseSpeed,        col(5) - 28, row(2),                   button_height, button_height);
form_controls["Speed Value Label"] =         forms.label(options_form,    "0",                                   col(5),      row(2) + label_offset,    54,            14);

form_controls["Map Dropdown"] =              forms.dropdown(options_form, Game.maps,                             col(0),      row(3) + dropdown_offset, col(9) + 7,    button_height);
form_controls["Toggle Telemetry Button"] =   forms.button(options_form, "Start Telemetry", toggleTelemetry,      col(10),     row(3),                   col(4) + 8,    button_height);
form_controls["Map Checkbox"] =              forms.checkbox(options_form, "Take me there",                       col(0) + dropdown_offset, row(4) + dropdown_offset);
form_controls["Toggle Infinites Checkbox"] = forms.checkbox(options_form, "Infinites",                           col(0) + dropdown_offset, row(5) + dropdown_offset);

form_controls["Rotation Units Label"] =      forms.label(options_form,    "Units:",                              col(5),      row(0) + label_offset,    44,            14);
form_controls["Toggle Rotation Units Button"] = forms.button(options_form, rotation_units,  toggleRotationUnits, col(7),      row(0),                   64,            button_height);

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

-- TODO: More dynamic OSD code, maybe have the game module set it up rather than this mess
-- OSDFunctions table
-- OSDLabels table
-- Separator etc
function updateUIReadouts_ScriptHawk()
	-- Update form buttons etc
	forms.settext(form_controls["Speed Value Label"], Game.speedy_speeds[Game.speedy_index]);
	forms.settext(form_controls["Precision Value Label"], precision);
	forms.settext(form_controls["Mode Button"], mode);
	forms.settext(form_controls["Toggle Rotation Units Button"], rotation_units);
	if previous_map ~= forms.gettext(form_controls["Map Dropdown"]) then
		previous_map = forms.gettext(form_controls["Map Dropdown"]);
		previous_map_value = findMapValue();
	end

	-- Draw OSD
	local row = 0;

	if type(x) == "number" and type(y) == "number" and type(z) == "number" then
		gui.text(gui_x_offset, gui_y_offset + row_height * row, "X: "..(round(x, precision) or 0));
		row = row + 1;
		gui.text(gui_x_offset, gui_y_offset + row_height * row, "Y: "..(round(y, precision) or 0));
		row = row + 1;
		gui.text(gui_x_offset, gui_y_offset + row_height * row, "Z: "..(round(z, precision) or 0));
		row = row + 2;
		if type(Game.getFloor) == "function" then
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "Floor: "..round(Game.getFloor(), precision));
			row = row + 2;
		end
	end

	if type(dy) == "number" and type(d) == "number" then
		gui.text(gui_x_offset, gui_y_offset + row_height * row, "dY:  "..(round(dy, precision) or 0));
		row = row + 1;
		gui.text(gui_x_offset, gui_y_offset + row_height * row, "dXZ: "..(round(d, precision) or 0));
		row = row + 1;
		if type(Game.getBoost) == "function" then
			row = row + 1;
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "Boost: "..round(Game.getBoost(), precision));
			row = row + 1;
		end
		if type(Game.getVelocity) == "function" then
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "Velocity: "..round(Game.getVelocity(), precision));
			row = row + 1;
		end
		if type(Game.getAcceleration) == "function" then
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "Accel: "..round(Game.getAcceleration(), precision));
			row = row + 1;
		end
		if type(Game.getXVelocity) == "function" then
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "X Velocity: "..round(Game.getXVelocity(), precision));
			row = row + 1;
		end
		if type(Game.getXAcceleration) == "function" then
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "X Accel: "..round(Game.getXAcceleration(), precision));
			row = row + 1;
		end
		if type(Game.getYVelocity) == "function" then
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "Y Velocity: "..round(Game.getYVelocity(), precision));
			row = row + 1;
		end
		if type(Game.getYAcceleration) == "function" then
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "Y Accel: "..round(Game.getYAcceleration(), precision));
			row = row + 1;
		end
		if type(Game.getZVelocity) == "function" then
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "Z Velocity: "..round(Game.getZVelocity(), precision));
			row = row + 1;
		end
		if type(Game.getZAcceleration) == "function" then
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "Z Accel: "..round(Game.getZAcceleration(), precision));
			row = row + 1;
		end
		if type(Game.getLateralVelocity) == "function" then
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "Lateral Velocity: "..round(Game.getLateralVelocity(), precision));
			row = row + 1;
		end
		if type(Game.getLateralAcceleration) == "function" then
			gui.text(gui_x_offset, gui_y_offset + row_height * row, "Lateral Accel: "..round(Game.getLateralAcceleration(), precision));
			row = row + 1;
		end
		row = row + 1;
	end

	if type(max_dy) == "number" and type(max_d) == "number" then
		gui.text(gui_x_offset, gui_y_offset + row_height * row, "Max dY:  "..(round(max_dy, precision) or 0));
		row = row + 1;
		gui.text(gui_x_offset, gui_y_offset + row_height * row, "Max dXZ: "..(round(max_d, precision) or 0));
		row = row + 2;
	end

	if type(rot_x) == "number" and type(rot_y) == "number" and type(rot_z) == "number" then
		gui.text(gui_x_offset, gui_y_offset + row_height * row, "Rot X: "..formatRotation(rot_x));
		row = row + 1;
		gui.text(gui_x_offset, gui_y_offset + row_height * row, "Rot Y: "..formatRotation(rot_y));
		row = row + 1;
		gui.text(gui_x_offset, gui_y_offset + row_height * row, "Rot Z: "..formatRotation(rot_z));
		row = row + 1;
	end
end

--------------------
-- Core functions --
--------------------

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
	joypad_pressed = joypad.getimmediate();

	-- Calculate speed for D-Pad and L button
	local speedy_speed_XZ = Game.speedy_speeds[Game.speedy_index];
	local speedy_speed_Y = Game.speedy_speeds[Game.speedy_index];
	if Game.speedy_invert_XZ then
		speedy_speed_XZ = speedy_speed_XZ * -1;
	end
	if Game.speedy_invert_Y then
		speedy_speed_Y = speedy_speed_Y * -1;
	end

	if Game.isPhysicsFrame() then
		if mode == 'Position' and type(rot_y) ~= "nil" then
			rot_rad = rotation_to_radians(rot_y);
			if joypad_pressed["P1 DPad U"] then
				gofast("x", speedy_speed_XZ * math.sin(rot_rad));
				gofast("z", speedy_speed_XZ * math.cos(rot_rad));
			end
			if joypad_pressed["P1 DPad D"] then
				gofast("x", -1.0 * (speedy_speed_XZ * math.sin(rot_rad)));
				gofast("z", -1.0 * (speedy_speed_XZ * math.cos(rot_rad)));
			end
			if joypad_pressed["P1 DPad L"] then
				gofast("x", speedy_speed_XZ * math.cos(rot_rad));
				gofast("z", -1.0 * (speedy_speed_XZ * math.sin(rot_rad)));
			end
			if joypad_pressed["P1 DPad R"] then
				gofast("x", -1.0 * (speedy_speed_XZ * math.cos(rot_rad)));
				gofast("z", speedy_speed_XZ * math.sin(rot_rad));
			end
			if joypad_pressed["P1 L"] then
				gofast("y", speedy_speed_Y);
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
			if joypad_pressed["P1 L"] then
				-- TODO: Scale up I guess?
				gofast("y", speedy_speed_Y);
			end
		end
	end

	if mode == 'Practice' then
		-- Hold down prevention
		if not joypad_pressed["P1 DPad L"] then
			practice_decrease_slot_pressed = false;
		end
		if not joypad_pressed["P1 DPad R"] then
			practice_increase_slot_pressed = false;
		end
		if not joypad_pressed["P1 DPad U"] then
			practice_save_slot_pressed = false;
		end
		if not joypad_pressed["P1 DPad D"] and not joypad_pressed["P1 L"] then
			practice_load_slot_pressed = false;
		end

		if joypad_pressed["P1 DPad U"] and not practice_save_slot_pressed then
			savestate.saveslot(practice_save_slot);
			practice_save_slot_pressed = true;
		end
		if (joypad_pressed["P1 DPad D"] or joypad_pressed["P1 L"]) and not practice_load_slot_pressed then
			savestate.loadslot(practice_save_slot);
			practice_load_slot_pressed = true;
		end
		if joypad_pressed["P1 DPad L"] and not practice_decrease_slot_pressed then
			decreaseSaveSlot();
			gui.addmessage("Switched to save slot "..practice_save_slot);
			practice_decrease_slot_pressed = true;
		end
		if joypad_pressed["P1 DPad R"] and not practice_increase_slot_pressed then
			increaseSaveSlot();
			gui.addmessage("Switched to save slot "..practice_save_slot);
			practice_increase_slot_pressed = true;
		end
	end

	if forms.ischecked(form_controls["Toggle Infinites Checkbox"]) then
		Game.applyInfinites();
	end

	if forms.ischecked(form_controls["Map Checkbox"]) then
		Game.setMap(previous_map_value);
	end
end

local function handleInput()
	input_table = input.get();

	-- Hold down key prevention
	--if input_table[decrease_precision_key] == nil then
	--	decrease_precision_pressed = false;
	--end

	--if input_table[increase_precision_key] == nil then
	--	increase_precision_pressed = false;
	--end

	if input_table[reset_max_key] == nil then
		reset_max_pressed = false;
	end

	--if input_table[switch_mode_key] == nil then
	--	switch_mode_pressed = false;
	--end

	-- Check for key presses
	--if input_table[decrease_precision_key] == true and decrease_precision_pressed == false then
	--	decreasePrecision();
	--	decrease_precision_pressed = true;
	--end

	--if input_table[increase_precision_key] == true and increase_precision_pressed == false then
	--	increasePrecision();
	--	increase_precision_pressed = true;
	--end

	if input_table[reset_max_key] == true and reset_max_pressed == false then
		max_dx = 0.0;
		max_dy = 0.0;
		max_dz = 0.0;
		max_d = 0.0;
		reset_max_pressed = true;
	end

	--if input_table[switch_mode_key] == true and switch_mode_pressed == false then
	--	toggleMode();
	--	switch_mode_pressed = true;
	--end
end

local function plot_pos()
	Game.eachFrame();

	previous_frame = current_frame;
	current_frame = emu.framecount();

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
		if math.abs(current_frame - previous_frame) > 1 then
			dx = 0;
			dy = 0;
			dz = 0;
			max_dx = 0.0;
			max_dy = 0.0;
			max_dz = 0.0;
			max_d = 0.0;
		else
			dx = x - prev_x;
			dy = y - prev_y;
			dz = z - prev_z;
		end

		d = math.sqrt(dx*dx + dz*dz);

		if (max_dx ~= nil and max_dy ~= nil and max_dz ~= nil and max_d ~= nil) and (dx ~= nil and dy ~= nil and dz ~= nil and d ~= nil) then
			if math.abs(dx) > max_dx then max_dx = math.abs(dx) end
			if math.abs(dy) > max_dy then max_dy = math.abs(dy) end
			if math.abs(dz) > max_dz then max_dz = math.abs(dz) end
			if math.abs(current_frame-previous_frame) > 1 then
				max_dx=0; max_dy=0; max_dz=0;
				max_d=0;
			end
			if d > max_d then max_d = d end
		end

		prev_x = x;
		prev_y = y;
		prev_z = z;

		-- Telemetry
		if collecting_telemetry then
			local temp_telemetry_data = {
				["X Position"] = x,
				["Y Position"] = y,
				["Z Position"] = z,
				["Dxz"] = d,
				["Dy"] = dy,
				["Rotation X"] = rot_x,
				["Rotation Y"] = rot_y,
				["Rotation Z"] = rot_z
			}
			table.insert(telemetryData, temp_telemetry_data);
		end
	end

	updateUIReadouts_ScriptHawk();
end

event.onframestart(handleInput, "ScriptHawk - Keyboard input handler");
event.onframestart(mainloop, "ScriptHawk - Controller input handler");
event.onframestart(plot_pos, "ScriptHawk - Update position each frame");
event.onloadstate(plot_pos, "ScriptHawk - Update position on load state");