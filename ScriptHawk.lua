----------------------
-- Helper functions --
----------------------

function fileExists(name)
	if type(name) == 'string' then
		local f = io.open(name, "r");
		if f ~= nil then
			io.close(f);
			return true;
		end
	end
	return false;
end

function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num));
end

function isnan(x) return x ~= x end

function divisibleBy(number, divisor)
	if type(number) == "number" and (not isnan(number)) and number ~= 0 and type(divisor) == "number" and (not isnan(divisor)) and divisor ~= 0 then
		local divValue = number / divisor;
		return math.floor(divValue) == divValue;
	end
	return false;
end

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
getBit = get_bit;
check_bit = get_bit;
checkBit = check_bit;

function set_bit(field, index)
	if index < 32 then
		local bitmask = math.pow(2, index);
		return bit.bor(bitmask, field);
	end
	return field;
end
setBit = set_bit;

function clear_bit(field, index)
	if index < 32 then
		local bitmask = math.pow(2, index);
		return bit.band(field, bit.bnot(bitmask));
	end
	return field;
end
clearBit = clear_bit;

function toggle_bit(field, index)
	if getBit(field, index) then
		return clearBit(field, index);
	end
	return setBit(field, index);
end
toggleBit = toggle_bit;

function deepcompare(t1, t2, ignore_mt)
	local ty1 = type(t1);
	local ty2 = type(t2);
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1);
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1, v1 in pairs(t1) do
		local v2 = t2[k1];
		if v2 == nil or not deepcompare(v1,v2) then return false end
	end
	for k2, v2 in pairs(t2) do
		local v1 = t1[k2];
		if v1 == nil or not deepcompare(v1,v2) then return false end
	end
	return true;
end

--       a  r  g  b
-- 0.0 = 7F 00 FF 00 = Green
-- 0.5 = 7F FF FF 00 = Yellow
-- 1.0 = 7F FF 00 00 = Red
function getColour(ratio, alpha)
	local green = 255;
	local red = 255;
	alpha = alpha or 255;

	if ratio > 0.5 then
		green = 255 - round(((ratio - 0.5) * 2) * 255);
		red = 255;
	elseif ratio < 0.5 then
		red = round((ratio * 2) * 255);
		green = 255;
	end

	return (alpha * 0x01000000) + (red * 0x00010000) + (green * 0x00000100);
end
getColor = getColour; -- To speak Americano

-- Finds the root of a linked list
function find_root(object)
	local count = 0;
	while object > 0 do
		dprint(count..": "..toHexString(object));
		object = mainmemory.read_u24_be(object + 1);
		count = count + 1;
	end
	print_deferred();
end
findRoot = find_root;

-- Finds the root of a linked list, outputting object size
function find_root_size(object)
	local count = 0;
	while object > 0 do
		dprint(count..": "..toHexString(object).." Size: "..toHexString(mainmemory.read_u32_be(object + 4)));
		object = mainmemory.read_u24_be(object + 1);
		count = count + 1;
	end
	print_deferred();
end
findRootSize = find_root_size;

-- Finds the end of a linked list, outputting object size
function traverse_size(object, minimumPrintSize, maximumPrintSize) -- TODO: Set prefix to nil in toHexString
	minimumPrintSize = minimumPrintSize or -math.huge;
	maximumPrintSize = maximumPrintSize or math.huge;
	local count = 0;
	local size = 0;
	local prev = 0;
	repeat
		count = count + 1;
		size = mainmemory.read_u32_be(object + 4);
		if size >= minimumPrintSize and size <= maximumPrintSize then
			dprint(count..": "..toHexString(object + 0x10).." "..(object + 0x10).." Size: "..toHexString(size));
		end
		object = object + 0x10 + size;
		prev = mainmemory.read_u32_be(object);
	until prev == 0 or not (object > 0 and object < 0x800000);
	print_deferred();
end
traverseSize = traverse_size;

function replace_u32_be(find, replace)
	for i = 0, 0x7FFFFF, 4 do
		if mainmemory.read_u32_be(i) == find then
			dprint("Replaced "..toHexString(i, 6));
			mainmemory.write_u32_be(i, replace);
		end
	end
	print_deferred();
end

max_string_length = 25;
function readNullTerminatedString(base)
	local builtString = "";
	local length = 0;
	local nextByte = mainmemory.readbyte(base + length);
	repeat
		builtString = builtString..string.char(nextByte);
		length = length + 1;
		nextByte = mainmemory.readbyte(base + length);
	until nextByte == 0 or length > max_string_length;
	return builtString;
end

--------------------
-- Load libraries --
--------------------

JSON = require "lib.JSON";
Stats = require "lib.Stats";
lips = require "lips.init";
require "lib.DPrint";

-----------------------
-- Keybind framework --
-----------------------
ScriptHawk = {};

ScriptHawk.keybindsFrame = {};
ScriptHawk.keybindsRealtime = {};

ScriptHawk.joypadBindsFrame = {};
ScriptHawk.joypadBindsRealtime = {};

function ScriptHawk.bind(keybindArray, key, callback, preventHold)
	if type(keybindArray) == "table" and type(key) == "string" and type(callback) == "function" then
		if type(preventHold) ~= 'boolean' then
			preventHold = true;
		end
		table.insert(keybindArray, {['key'] = key, ['callback'] = callback, ['pressed'] = false, ['preventHold'] = preventHold});
	end
end

function ScriptHawk.bindKeyRealtime(key, callback, preventHold)
	ScriptHawk.bind(ScriptHawk.keybindsRealtime, key, callback, preventHold);
end

function ScriptHawk.bindKeyFrame(key, callback, preventHold)
	ScriptHawk.bind(ScriptHawk.keybindsFrame, key, callback, preventHold);
end

function ScriptHawk.bindJoypadFrame(key, callback, preventHold)
	ScriptHawk.bind(ScriptHawk.joypadBindsFrame, key, callback, preventHold);
end

function ScriptHawk.bindJoypadRealtime(key, callback, preventHold)
	ScriptHawk.bind(ScriptHawk.joypadBindsRealtime, key, callback, preventHold);
end

function ScriptHawk.unbind(keybinds, key)
	if type(key) == "string" then
		for i, keybind in ipairs(keybinds) do
			if key == keybind.key then
				table.remove(keybinds, i);
			end
		end
	end
end

function ScriptHawk.processKeybinds(keybinds)
	local input_table = input.get();

	for i, keybind in ipairs(keybinds) do
		if not input_table[keybind.key] then
			keybind.pressed = false;
		end
		if input_table[keybind.key] and (not keybind.preventHold or not keybind.pressed) then
			keybind.callback();
			keybind.pressed = true;
		end
	end
end

function ScriptHawk.processJoypadBinds(joypadBinds)
	local input_table = joypad.getimmediate();

	for i, joypadBind in ipairs(joypadBinds) do
		if not input_table[joypadBind.key] then
			joypadBind.pressed = false;
		end
		if input_table[joypadBind.key] and (not joypadBind.preventHold or not joypadBind.pressed) then
			joypadBind.callback();
			joypadBind.pressed = true;
		end
	end
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
elseif stringContains(romName, "Legend of Galahad") then
	Game = require "beta.Galahad";
	return;
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
	return false;
end

if not Game.detectVersion(romName) then
	print("This version of the game is not currently supported.");
	return false;
end

----------------
-- ASM Loader --
----------------

-- Output gameshark code
function outputGamesharkCode(bytes, base, skipZeroes)
	skipZeroes = skipZeroes or false;
	skippedZeroes = 0;
	if type(bytes) == "table" and #bytes > 0 and #bytes % 2 == 0 then
		for i = 1, #bytes, 2 do
			if not (skipZeroes and bytes[i] == 0x00 and bytes[i + 1] == 0x00) then
				dprint("81"..toHexString(base + i - 1, 6, "").." "..toHexString(bytes[i], 2, "")..toHexString(bytes[i + 1], 2, ""));
			else
				skippedZeroes = skippedZeroes + 1;
			end
		end
	end
	return skippedZeroes;
end

local code = {};

function codeWriter(...)
	table.insert(code, tonumber(arg[2], 16));
end

function loadASMPatch(code_filename, suppress_print)
	if Game.supportsASMHacks then
		if not fileExists(code_filename) then
			code_filename = forms.openfile(nil, nil, "R4300i Assembly Code|*.asm|All Files (*.*)|*.*");
			if not fileExists(code_filename) then
				if not suppress_print then
					print("No code loaded, aborting mission...");
				end
				return false;
			end
		end

		-- Open the file and assemble the code
		code = {};
		local result = lips(code_filename, codeWriter, {['unsafe'] = true, ['offset'] = Game.ASMCodeBase + 0x80000000});

		if #code == 0 then
			if not suppress_print then
				print(result);
				print("The code did not compile correctly, check for errors in your source.");
			end
			return false;
		end

		if #code > Game.ASMMaxCodeSize then
			if not suppress_print then
				print("The compiled code was too large to safely inject into the game.");
			end
			return false;
		end

		-- Patch the code
		for i = 1, #code do
			mainmemory.writebyte(Game.ASMCodeBase + (i - 1), code[i]);
		end

		-- Patch the hook
		for i = 1, #Game.ASMHook do
			mainmemory.writebyte(Game.ASMHookBase + (i - 1), Game.ASMHook[i]);
		end

		-- Hacky, yes, but if we're using dynarec the patched code pages don't get marked as dirty
		-- Quickest and easiest way around this is to save and reload a state
		local ss_fn = 'lips/temp.state'
		savestate.save(ss_fn)
		savestate.load(ss_fn)

		if not suppress_print then
			outputGamesharkCode(Game.ASMHook, Game.ASMHookBase, false);
			outputGamesharkCode(code, Game.ASMCodeBase, false);

			dprint("Patched code ("..#code.." bytes)");
			dprint("Patched hook ("..#Game.ASMHook.." bytes)");
			dprint("Done!");
			print_deferred();
		end
		return true;
	else
		if not suppress_print then
			print("This game does not support ASM hacks.");
		end
		return false;
	end
end

-------------
-- Texture --
-------------

-- Pixel format: 16bit RGBA 5551
-- RRRR RGGG GGBB BBBA
local rgba5551_color_constants = {
	["Red"] = 0x0800,
	["Green"] = 0x0040,
	["Blue"] = 0x0002,
};

function replaceTextureRGBA5551(filename, base, size)
	if not fileExists(filename) then
		filename = forms.openfile(nil, nil, "All Files (*.*)|*.*");
		if not fileExists(filename) then
			print("No image selected. Exiting.");
			return;
		end
	end

	local input_file = assert(io.open(filename, "rb"));
	for i = 0, size - 1 do
		local r = math.floor(string.byte(input_file:read(1)) / 8) * rgba5551_color_constants["Red"];
		local g = math.floor(string.byte(input_file:read(1)) / 8) * rgba5551_color_constants["Green"];
		local b = math.floor(string.byte(input_file:read(1)) / 8) * rgba5551_color_constants["Blue"];
		local a = 1;

		mainmemory.write_u16_be(base + (i * 2), r + g + b + a);
	end

	input_file:close();
end

-----------
-- State --
-----------

local mode = "Position";
local rotation_units = "Degrees";

-- Stops garbage min/max dx/dy/dz values
local firstframe = true;
previous_frame = emu.framecount();
current_frame = emu.framecount();

previous_map = "";
previous_map_value = 0;

local dx = 0.0;
local dy = 0.0;
local dz = 0.0;
local d  = 0.0;
local odometer = 0.0;

local prev_x = 0.0;
local prev_y = 0.0;
local prev_z = 0.0;

local max_dx = 0.0;
local max_dy = 0.0;
local max_dz = 0.0;
local max_d  = 0.0;

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

local function decreaseSaveSlot()
	if mode == "Practice" then
		practice_save_slot = math.max(0, practice_save_slot - 1);
		gui.cleartext();
		gui.addmessage("Switched to save slot "..practice_save_slot);
		updateUIReadouts_ScriptHawk();
	end
end

local function increaseSaveSlot()
	if mode == "Practice" then
		practice_save_slot = math.min(9, practice_save_slot + 1);
		gui.cleartext();
		gui.addmessage("Switched to save slot "..practice_save_slot);
		updateUIReadouts_ScriptHawk();
	end
end

local function loadPracticeSlot()
	if mode == "Practice" then
		savestate.loadslot(practice_save_slot);
		gui.cleartext();
		updateUIReadouts_ScriptHawk();
	end
end

local function savePracticeSlot()
	if mode == "Practice" then
		savestate.saveslot(practice_save_slot);
		gui.cleartext();
		updateUIReadouts_ScriptHawk();
	end
end

-- Practice mode JoypadBinds
ScriptHawk.bindJoypadRealtime("P1 DPad L", decreaseSaveSlot, true);
ScriptHawk.bindJoypadRealtime("P1 DPad R", increaseSaveSlot, true);
ScriptHawk.bindJoypadRealtime("P1 DPad U", savePracticeSlot, true);
ScriptHawk.bindJoypadRealtime("P1 DPad D", loadPracticeSlot, true);
ScriptHawk.bindJoypadRealtime("P1 L", loadPracticeSlot, true);

----------------------------
-- Other helper functions --
----------------------------

function searchPointers(base, range, allowLater)
	local foundPointers = {};
	allowLater = allowLater or false;
	for address = 0x000000, 0x7FFFFC, 4 do
		local value = mainmemory.read_u32_be(address);
		if allowLater then
			if value >= base - range and value <= base + range then
				table.insert(foundPointers, {["Address"] = toHexString(address), ["Value"] = toHexString(value)});
				dprint(toHexString(address).." -> "..toHexString(value));
			end
		else
			if value >= base - range and value <= base then
				table.insert(foundPointers, {["Address"] = toHexString(address), ["Value"] = toHexString(value)});
				dprint(toHexString(address).." -> "..toHexString(value));
			end
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

function array_contains(array, value)
	if type(array) == "table" then
		-- TODO: Special check for index zero because ipairs doesn't support starting from 0?
		if type(array[0]) ~= "nil" then
			if array[0] == value then
				return true;
			end
		end

		-- Carry on
		for i, v in ipairs(array) do
			if v == value then
				return true;
			end
		end
	end
	return false;
end
arrayContains = array_contains;

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

telemetryData = {};
local collecting_telemetry = false;

function getTelemetryHeaderString()
	local headerString = "Time (Frames),";
	for i, v in ipairs(Game.OSD) do
		if type(v) == "table" then
			if v[1] ~= "Separator" then
				headerString = headerString..v[1]..",";
			end
		end
	end
	return headerString;
end

-- Outputs telemetry data as CSV to the console
local function outputTelemetry()
	-- Print CSV header
	dprint(getTelemetryHeaderString());

	-- Print CSV values
	for i = 1, #telemetryData do
		local outputString = i..",";
		for k, v in ipairs(telemetryData[i]) do
			outputString = outputString..(v)..",";
		end
		dprint(outputString);
	end

	print_deferred();
end

local function startTelemetry()
	collecting_telemetry = true;
	forms.settext(ScriptHawkUI.form_controls["Toggle Telemetry Button"], "Stop Telemetry");
	telemetryData = {};
end

local function stopTelemetry()
	collecting_telemetry = false;
	forms.settext(ScriptHawkUI.form_controls["Toggle Telemetry Button"], "Start Telemetry");

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

--------------------
-- UI State Table --
--------------------

ScriptHawkUI = {
	["form_controls"] = {}, -- TODO: Make game modules use this table for their own controls mayb?
	["form_padding"] = 8,
	["label_offset"] = 5,
	["dropdown_offset"] = 1,
	["long_label_width"] = 140,
	["button_height"] = 23,
};

-------------
-- UI Code --
-------------

function ScriptHawkUI.row(row_num)
	return round(ScriptHawkUI.form_padding + ScriptHawkUI.button_height * row_num, 0);
end

function ScriptHawkUI.col(col_num)
	return ScriptHawkUI.row(col_num);
end

ScriptHawkUI.options_form = forms.newform(ScriptHawkUI.col(17), ScriptHawkUI.row(10), "ScriptHawk Options");

-- Handle, Type, Caption, Callback, X position, Y position, Width, Height
ScriptHawkUI.form_controls["Mode Label"] = forms.label(ScriptHawkUI.options_form, "Mode:", ScriptHawkUI.col(0), ScriptHawkUI.row(0) + ScriptHawkUI.label_offset, 44, ScriptHawkUI.button_height);
ScriptHawkUI.form_controls["Mode Button"] = forms.button(ScriptHawkUI.options_form, mode, toggleMode, ScriptHawkUI.col(2), ScriptHawkUI.row(0), 64, ScriptHawkUI.button_height);

ScriptHawkUI.form_controls["Precision Label"] = forms.label(ScriptHawkUI.options_form, "Precision:", ScriptHawkUI.col(0), ScriptHawkUI.row(1) + ScriptHawkUI.label_offset, 54, 14);
ScriptHawkUI.form_controls["Decrease Precision Button"] = forms.button(ScriptHawkUI.options_form, "-", decreasePrecision, ScriptHawkUI.col(4) - 28, ScriptHawkUI.row(1), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
ScriptHawkUI.form_controls["Increase Precision Button"] = forms.button(ScriptHawkUI.options_form, "+", increasePrecision, ScriptHawkUI.col(5) - 28, ScriptHawkUI.row(1), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
ScriptHawkUI.form_controls["Precision Value Label"] = forms.label(ScriptHawkUI.options_form, precision, ScriptHawkUI.col(5), ScriptHawkUI.row(1) + ScriptHawkUI.label_offset, 44, 14);

ScriptHawkUI.form_controls["Speed Label"] = forms.label(ScriptHawkUI.options_form, "Speed:", ScriptHawkUI.col(0), ScriptHawkUI.row(2) + ScriptHawkUI.label_offset, 54, 14);
ScriptHawkUI.form_controls["Decrease Speed Button"] = forms.button(ScriptHawkUI.options_form, "-", decreaseSpeed, ScriptHawkUI.col(4) - 28, ScriptHawkUI.row(2), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
ScriptHawkUI.form_controls["Increase Speed Button"] = forms.button(ScriptHawkUI.options_form, "+", increaseSpeed, ScriptHawkUI.col(5) - 28, ScriptHawkUI.row(2), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
ScriptHawkUI.form_controls["Speed Value Label"] = forms.label(ScriptHawkUI.options_form, "0", ScriptHawkUI.col(5), ScriptHawkUI.row(2) + ScriptHawkUI.label_offset, 54, 14);

ScriptHawkUI.form_controls["Map Dropdown"] = forms.dropdown(ScriptHawkUI.options_form, Game.maps, ScriptHawkUI.col(0), ScriptHawkUI.row(3) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.col(9) + 7, ScriptHawkUI.button_height);
ScriptHawkUI.form_controls["Toggle Telemetry Button"] = forms.button(ScriptHawkUI.options_form, "Start Telemetry", toggleTelemetry, ScriptHawkUI.col(10), ScriptHawkUI.row(3), ScriptHawkUI.col(4) + 8, ScriptHawkUI.button_height);
ScriptHawkUI.form_controls["Map Checkbox"] = forms.checkbox(ScriptHawkUI.options_form, "Take me there", ScriptHawkUI.col(0) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(4) + ScriptHawkUI.dropdown_offset);
ScriptHawkUI.form_controls["Toggle Infinites Checkbox"] = forms.checkbox(ScriptHawkUI.options_form, "Infinites", ScriptHawkUI.col(0) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(5) + ScriptHawkUI.dropdown_offset);

ScriptHawkUI.form_controls["Rotation Units Label"] = forms.label(ScriptHawkUI.options_form, "Units:", ScriptHawkUI.col(5), ScriptHawkUI.row(0) + ScriptHawkUI.label_offset, 44, 14);
ScriptHawkUI.form_controls["Toggle Rotation Units Button"] = forms.button(ScriptHawkUI.options_form, rotation_units, toggleRotationUnits, ScriptHawkUI.col(7), ScriptHawkUI.row(0), 64, ScriptHawkUI.button_height);

-- Init any custom UI that the game module uses
Game.initUI();

local function findMapValue()
	for i = 1, #Game.maps do
		if Game.maps[i] == previous_map then
			return i;
		end
	end
	return 0;
end

-- Check for missing OSD definitions
if type(Game.OSD) ~= "table" then
	Game.OSD = {
		{"X", Game.getXPosition},
		{"Y", Game.getYPosition},
		{"Z", Game.getZPosition},
		{"Separator", 1},
		{"dY"},
		{"dXZ"},
		{"Separator", 1},
		{"Max dY"},
		{"Max dXZ"},
		{"Odometer"},
		{"Separator", 1},
		{"Rot. X", Game.getXRotation},
		{"Facing", Game.getYRotation},
		{"Rot. Z", Game.getZRotation},
	};
end

if type(Game.OSDPosition) ~= "table" then
	Game.OSDPosition = {2, 70};
end

if type(Game.OSDRowHeight) ~= "number" then
	Game.OSDRowHeight = 16;
end

local angleKeywords = {
	"Rot X", "Rot Y", "Rot Z", "Rot",
	"Rot. X", "Rot. Y", "Rot. Z", "Rot.",
	"Rotation X", "Rotation Y", "Rotation Z", "Rotation",
	"Facing", "Moving", "Angle"
};

function updateUIReadouts_ScriptHawk()
	-- Update form buttons etc
	forms.settext(ScriptHawkUI.form_controls["Speed Value Label"], Game.speedy_speeds[Game.speedy_index]);
	forms.settext(ScriptHawkUI.form_controls["Precision Value Label"], precision);
	forms.settext(ScriptHawkUI.form_controls["Mode Button"], mode);
	forms.settext(ScriptHawkUI.form_controls["Toggle Rotation Units Button"], rotation_units);
	if previous_map ~= forms.gettext(ScriptHawkUI.form_controls["Map Dropdown"]) then
		previous_map = forms.gettext(ScriptHawkUI.form_controls["Map Dropdown"]);
		previous_map_value = findMapValue();
	end

	-- Draw OSD
	local row = 0;
	local OSDX = Game.OSDPosition[1];
	local OSDY = Game.OSDPosition[2];

	for i = 1, #Game.OSD do
		local label = Game.OSD[i][1];
		local value = Game.OSD[i][2];
		local color = Game.OSD[i][3];

		if label ~= "Separator" then
			-- Detect special keywords
			if label == "dY" or label == "DY" then
				value = dy or 0;
			end
			if label == "dXZ" or label == "DXZ" then
				value = d or 0;
			end

			if label == "Max dY" or label == "Max DY" then
				value = max_dy or 0;
			end
			if label == "Max dXZ" or label == "Max DXZ" then
				value = max_d or 0;
			end
			if label == "Odometer" then
				value = odometer or 0;
			end

			-- Get the value
			if type(value) == "function" then
				value = value();
			end

			-- Round the value
			if type(value) == "number" then
				value = round(value, precision);
			end

			-- Detect and format rotation based on a keyword search
			for j = 1, #angleKeywords do
				if label == angleKeywords[j] then
					value = formatRotation(value);
				end
			end

			if type(color) == "function" then
				color = color();
			end

			gui.text(OSDX, OSDY + Game.OSDRowHeight * row, label..": "..value, color);
		else
			if type(value) == "number" and value > 1 then
				row = row + value - 1;
			end
		end
		row = row + 1;
	end
end

--------------------
-- Core functions --
--------------------

if type(Game.setPosition) == "nil" then
	function Game.setPosition(x, y, z)
		Game.setXPosition(x);
		Game.setYPosition(y);
		Game.setZPosition(z);
	end
end

if type(Game.setRotation) == "nil" then
	function Game.setRotation(x, y, z)
		Game.setXRotation(x);
		Game.setYRotation(y);
		Game.setZRotation(z);
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
		if mode == 'Position' then
			rot_rad = rotation_to_radians(Game.getYRotation());
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
				gofast("y", speedy_speed_Y);
			end
		end
	end

	if forms.ischecked(ScriptHawkUI.form_controls["Toggle Infinites Checkbox"]) then
		Game.applyInfinites();
	end

	if forms.ischecked(ScriptHawkUI.form_controls["Map Checkbox"]) then
		Game.setMap(previous_map_value);
	end
end

local function plot_pos()
	ScriptHawk.processKeybinds(ScriptHawk.keybindsFrame);
	ScriptHawk.processKeybinds(ScriptHawk.joypadBindsFrame);
	Game.eachFrame();

	previous_frame = current_frame;
	current_frame = emu.framecount();

	local x = Game.getXPosition();
	local y = Game.getYPosition();
	local z = Game.getZPosition();

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
		odometer = odometer + d;

		if (max_dx ~= nil and max_dy ~= nil and max_dz ~= nil and max_d ~= nil) and (dx ~= nil and dy ~= nil and dz ~= nil and d ~= nil) then
			if math.abs(dx) > max_dx then max_dx = math.abs(dx) end
			if math.abs(dy) > max_dy then max_dy = math.abs(dy) end
			if math.abs(dz) > max_dz then max_dz = math.abs(dz) end
			if math.abs(current_frame-previous_frame) > 1 then
				max_dx = 0; max_dy = 0; max_dz = 0;
				max_d = 0;
			end
			if d > max_d then max_d = d end
		end

		prev_x = x;
		prev_y = y;
		prev_z = z;

		-- Telemetry
		if collecting_telemetry then
			local tempTelemetryData = {};
			for i = 1, #Game.OSD do
				local label = Game.OSD[i][1];
				local value = Game.OSD[i][2];

				if label ~= "Separator" then
					-- Detect special keywords
					if label == "dY" or label == "DY" then
						value = dy or 0;
					end
					if label == "dXZ" or label == "DXZ" then
						value = d or 0;
					end

					if label == "Max dY" or label == "Max DY" then
						value = max_dy or 0;
					end
					if label == "Max dXZ" or label == "Max DXZ" then
						value = max_d or 0;
					end
					if label == "Odometer" then
						value = odometer or 0;
					end

					-- Get the value
					if type(value) == "function" then
						value = value();
					end

					-- Round the value
					if type(value) == "number" then
						value = round(value, precision);
					end

					-- Detect and format rotation based on a keyword search
					for j = 1, #angleKeywords do
						if label == angleKeywords[j] then
							value = formatRotation(value);
						end
					end

					table.insert(tempTelemetryData, value);
				end
			end
			table.insert(telemetryData, tempTelemetryData);
		end
	end

	updateUIReadouts_ScriptHawk();
end

event.onframestart(mainloop, "ScriptHawk - Controller input handler");
event.onframestart(plot_pos, "ScriptHawk - Update position each frame");
event.onloadstate(plot_pos, "ScriptHawk - Update position on load state");

--------------
-- Keybinds --
--------------
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm

--ScriptHawk.bindKeyRealtime("Comma", decreasePrecision, true);
--ScriptHawk.bindKeyRealtime("Period", increasePrecision, true);

function ScriptHawk.resetMax()
	max_dx = 0.0;
	max_dy = 0.0;
	max_dz = 0.0;
	max_d = 0.0;
	odometer = 0.0;
	reset_max_pressed = true;
end
ScriptHawk.bindKeyRealtime("Slash", ScriptHawk.resetMax, true);
--ScriptHawk.bindKeyRealtime("M", toggleMode, true);

while true do
	ScriptHawk.processKeybinds(ScriptHawk.keybindsRealtime);
	ScriptHawk.processJoypadBinds(ScriptHawk.joypadBindsRealtime);
	updateUIReadouts_ScriptHawk();
	-- TODO: Game.realtime() update method thingo
	emu.yield();
end