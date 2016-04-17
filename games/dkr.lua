local Game = {};

local RDRAMBase = 0x80000000;
local RDRAMSize = 0x400000; -- Doubled with expansion pak

-- Checks whether a value falls within N64 RDRAM
local function isRDRAM(value)
	return type(value) == "number" and value >= 0 and value < RDRAMSize;
end

-- Checks whether a value is a pointer
local function isPointer(value)
	return type(value) == "number" and value >= RDRAMBase and value < RDRAMBase + RDRAMSize;
end

local player_object_pointer = 0x3FFFC0; -- Seems to be the same for all versions

-- Relative to objects in pointer list
-- TODO: Port this to an obeject model table, see BK, DK64, SM64
local x_pos = 0x0C; -- Float
local y_pos = x_pos + 4; -- Float
local z_pos = y_pos + 4; -- Float

local y_velocity = 0x20; -- Float
local velocity = 0xC4; -- Float
local lateral_velocity = 0xC8; -- Float

local wheel_array_pointer = 0x60;
	-- Relative to wheel array
	local wheel_array_size = 0x00; -- u32_be
	local wheel_array_base = 0x04; -- List of wheel object pointers

local camera_zoom = 0x12C;
local throttle = 0x14C; -- Float

local spin_timer = 0x206; -- s16_be

local powerup_quantity = 0x20B; -- Max 10

-- Values:
--	0x00 Blue 1
--	0x01 Blue 2
-- 	0x02 Blue 3
--	0x03 Red 1
--	0x04 Red 2
--	0x05 Red 3
--	0x06 Green 1
--	0x07 Green 2
--	0x08 Green 3
local powerup_type = 0x20C;

local bananas = 0x21D;
local max_bananas = 10;

local x_rot = 0x23A;
local y_rot = 0x238;
local z_rot = 0x23C;

local facing_angle = y_rot;

local boost_timer = 0x26B;
local silver_coins = 0x29A;

local map_freeze_values = {};

Game.maps = {
	"0x00 - Overworld",
	"0x01 - Bluey 1",
	"0x02 - Dragon Forest (Hub)",
	"0x03 - Fossil Canyon",
	"0x04 - Pirate Lagoon",
	"0x05 - Ancient lake",
	"0x06 - Walrus Cove",
	"0x07 - Hot Top Volcano",
	"0x08 - Whale Bay",
	"0x09 - Snowball Valley",
	"0x0A - Crescent Island",
	"0x0B - Fire Mountain",
	"0x0C - Dino Domain (Hub)",
	"0x0D - Everfrost Peak",
	"0x0E - Sherbert Island (Hub)",
	"0x0F - Spaceport Alpha",

	"0x10 - Horseshoe Gulch (Unused)",
	"0x11 - Spacedust Alley",
	"0x12 - Greenwood Village",
	"0x13 - Boulder Canyon",
	"0x14 - Windmill Plains",
	"0x15 - Intro",
	"0x16 - Character Select",
	"0x17 - Title Screen",
	"0x18 - Snowflake Mountain",
	"0x19 - Smokey Castle",
	"0x1A - Darkwater Beach",
	"0x1B - Icicle Pyramid",
	"0x1C - Frosty Village",
	"0x1D - Jungle Falls",
	"0x1E - Treasure Caves",
	"0x1F - Haunted Woods",

	"0x20 - Darkmoon Caverns",
	"0x21 - Star City",
	"0x22 - Trophy Race Results Screen",
	"0x23 - Future Fun Land (Hub)",
	"0x24 - Overworld (Opening Cutscene)",
	"0x25 - Wizpig 1",
	"0x26 - Dino 1",
	"0x27 - Menu Screen",
	"0x28 - Bubbler 1",
	"0x29 - Smokey 1",
	"0x2A - Overworld (Wizpig 1 opening cutscene)",
	"0x2B - Wizpig amulet cutscene",
	"0x2C - TT amulet cutscene",
	"0x2D - Overworld (FFL opening cutscene)",
	"0x2E - Dino 2",
	"0x2F - Toufool",

	"0x30 - Snowfool",
	"0x31 - Toufool again",
	"0x32 - Toufool again again",
	"0x33 - Toufool in space",
	"0x34 - Bluey 2",
	"0x35 - Bubbler 2",
	"0x36 - Smokey 2",
	"0x37 - Wizpig 2",
	"0x38 - Overworld (Fake credits)",
	"0x39 - Tricky's map (cutscene version)",
	"0x3A - Smokey's map (cutscene version)",
	"0x3B - Bluey's map (cutscene version)",
	"0x3C - Wizpig 1 cutscene",
	"0x3D - Bubbler's map (cutscene version)",
	"0x3E - Wizpig 2 cutscene",
	"0x3F - Overworld (Credits 1)",

	"0x40 - Overworld (Credits 2)",
	"0x41 - Overworld (misc cutscene 1)",
	"0x42 - Overworld (misc cutscene 2)",
	"0x43 - Overworld (misc cutscene 3)",
	"0x44 - Overworld (misc cutscene 4)",
	"0x45 - Overworld (misc cutscene 5)",
	"0x46 - ...",
	"0x47 - ...",
	"0x48 - ...",
	"0x49 - ...",
	"0x4A - ...",
	"0x4B - ...",
	"0x4C - ...",
	"0x4D - ",
	"0x4E - ",
	"0x4F - ",

	"0x50 - ",
	"0x51 - ",
	"0x52 - ",
	"0x53 - ",
	"0x54 - ",
	"0x55 - ",
	"0x56 - ",
	"0x57 - ",
	"0x58 - ",
	"0x59 - ",
	"0x5A - ",
	"0x5B - ",
	"0x5C - ",
	"0x5D - ",
	"0x5E - ",
	"0x5F - ",
};

--------------------
-- Region/Version --
--------------------

-- Version order: PAL 1.1, PAL 1.0, JP, US 1.1, US 1.0
Game.Memory = {
	["is_paused"] = {0x123B24, 0x1235A4, 0x124F84, 0x123A94, 0x123514},
	["get_ready"] = {0x11B3C3, 0x11AE43, 0x11C823, 0x11B333, 0x11ADB3},
	["cheat_menu"] = {0x0E03AC, 0x0DFE2C, 0x0E17FC, 0x0E031C, 0x0DFD9C},
	["pointer_list"] = {0x11B468, 0x11AEE8, 0x11C8C8, 0x11B3D8, 0x11AE58},
	["num_objects"] = {0x11B46C, 0x11AEEC, 0x11C8CC, 0x11B3DC, 0x11AE5C},
};

function Game.detectVersion(romName)
	if stringContains(romName, "Europe") and stringContains(romName, "Rev A") then
		version = 1;
		map_freeze_values = {
			0x121777, 0x123B07, 0x208699 -- TODO: Double check these
		};
	elseif stringContains(romName, "Europe") then
		version = 2;
		map_freeze_values = {
			0x11AF3B, 0x1211F7, 0x1212E2, 0x123587, 0x206BB5, 0x206C3B, 0x207EA9 -- TODO: Double check these
		};
	elseif stringContains(romName, "Japan") then
		version = 3;
		map_freeze_values = {
			0x11C91B, 0x122BD7, 0x122CC2, 0x124F67, 0x1FD4A5, 0x1FD52B, 0x1FE729 -- TODO: Double check these
		};
	elseif stringContains(romName, "USA") and stringContains(romName, "Rev A") then
		version = 4;
		map_freeze_values = {
			0x1216E7, 0x123A77, 0x1FD209 -- TODO: Double check these
		};
	elseif stringContains(romName, "USA") then
		version = 5;
		map_freeze_values = {
			0x121167, 0x121252, 0x1234F7, 0x1FCA19 -- TODO: Double check these
		};
	else
		return false;
	end

	return true;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_invert_XZ = true;
Game.speedy_index = 7;

Game.rot_speed = 100;
Game.max_rot_units = 65535;

function Game.getVelocity()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.readfloat(player_object + velocity, true);
	end
	return 0;
end

function Game.setVelocity(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		mainmemory.writefloat(player_object + velocity, value, true);
	end
end

function Game.getLateralVelocity()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.readfloat(player_object + lateral_velocity, true);
	end
	return 0;
end

function Game.setLateralVelocity(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		mainmemory.writefloat(player_object + lateral_velocity, value, true);
	end
end

function Game.getSpinTimer()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.read_s16_be(player_object + spin_timer);
	end
	return 0;
end

function Game.colorSpinTimer()
	local spinTimer = Game.getSpinTimer();
	spinTimer = math.abs(spinTimer);
	spinTimer = math.min(spinTimer, 80);
	spinTimer = spinTimer / 80;
	if spinTimer == 0 then
		return 0xFFFFFFFF; -- White
	end
	return getColor(spinTimer);
end

function Game.getYVelocity()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.readfloat(player_object + y_velocity, true);
	end
	return 0;
end

function Game.setYVelocity(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		mainmemory.writefloat(player_object + y_velocity, value, true);
	end
end

function Game.getBoost()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.read_s8(player_object + boost_timer);
	end
	return 0;
end

function Game.getThrottle()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.readfloat(player_object + throttle, true);
	end
	return 0;
end

function Game.getBananas()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.readbyte(player_object + bananas);
	end
	return 0;
end

--------------
-- Position --
--------------

function Game.getXPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.readfloat(player_object + x_pos, true);
	end
	return 0;
end

function Game.getYPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.readfloat(player_object + y_pos, true);
	end
	return 0;
end

function Game.getZPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.readfloat(player_object + z_pos, true);
	end
	return 0;
end

function Game.setXPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		mainmemory.writefloat(player_object + x_pos, value, true);
	end
end

function Game.setYPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		mainmemory.writefloat(player_object + y_pos, value, true);
		Game.setYVelocity(0);
	end
end

function Game.setZPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		mainmemory.writefloat(player_object + z_pos, value, true);
	end
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.read_u16_be(player_object + x_rot);
	end
	return 0;
end

function Game.getYRotation()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.read_u16_be(player_object + facing_angle);
	end
	return 0;
end

function Game.getZRotation()
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		return mainmemory.read_u16_be(player_object + z_rot);
	end
	return 0;
end

function Game.setXRotation(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		mainmemory.write_u16_be(player_object + x_rot, value);
	end
end

function Game.setYRotation(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		mainmemory.write_u16_be(player_object + facing_angle, value);
	end
end

function Game.setZRotation(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		mainmemory.write_u16_be(player_object + z_rot, value);
	end
end

-----------------------------
-- Optimal tapping script  --
-- Written by Faschz, 2015 --
-----------------------------

local get_ready_yellow_max = 36;
local get_ready_yellow_min = 20;
local get_ready_blue_max = 18;
local get_ready_blue_min = 6;

local otap_checkbox;
local otap_boost_dropdown;
local otap_enabled = false;

local otap_startFrame = emu.framecount();
local otap_startLag = emu.lagcount();

-- TODO: Adjust velocity thresholds based on lateral velocity
-- TODO: Adjust velocity thresholds based on bananas
-- TODO: Adjust velocity thresholds based on character
-- Numbers optimized for TT with 0 bananas
velocity_min = -9.212730408;
velocity_med = -12.34942532;
velocity_max = -14.22209072;

local function enableOptimalTap()
	otap_startFrame = emu.framecount();
	otap_startLag = emu.lagcount();
	otap_enabled = true;
	print("Auto tapper (by Faschz) enabled.");
end

local function disableOptimalTap()
	otap_enabled = false;
	print("Auto tapper (by Faschz) disabled.");
end

local function optimalTap()
	local _velocity = Game.getVelocity();
	local _bananas = Game.getBananas();
	local boost = Game.getBoost();
	local getReady = mainmemory.readbyte(Game.Memory.get_ready[version]);
	local isPaused = mainmemory.read_u16_be(Game.Memory.is_paused[version]);

	local boostType = forms.getproperty(otap_boost_dropdown, "SelectedItem");

	-- Don't press A if we're paused
	if isPaused ~= 0 then -- TODO: This check isn't perfect, it's still possible that it'll tap A and close the menu, I think we need a menu object pointer or something
		--print("Don't press A, we're paused.");
		return;
	end

	-- Don't press A if we're boosting
	if boost > 0 then
		return;
	end

	-- Get a zipper at the start of the race
	if getReady ~= 0 and boostType ~= "None" then
		local boostMin = 0;
		local boostMax = 0;

		if boostType == "Blue" then
			boostMin = get_ready_blue_min;
			boostMax = get_ready_blue_max;
		elseif boostType == "Yellow" then
			boostMin = get_ready_yellow_min;
			boostMax = get_ready_yellow_max;
		end

		local shouldWeTap = getReady >= boostMin and getReady <= boostMax and boost == 0;
		joypad.set({["A"] = shouldWeTap}, 1);
		return;
	end

	-- Bot taps A once every modulo frames
	local modulo = 1;

	if _velocity >= velocity_min then
		modulo = 1;
	elseif _velocity >= velocity_med and _velocity < velocity_min then
		modulo = 2;
	elseif _velocity >= velocity_max and _velocity < velocity_med then
		modulo = 3;
	elseif _velocity < velocity_max then
		modulo = 4;
	end

	local shouldWeTap = (emu.framecount() - (otap_startFrame + (emu.lagcount() - otap_startLag))) % modulo == 0;
	joypad.set({["A"] = shouldWeTap}, 1);
end

--------------------
-- Boost analysis --
--------------------

local boostFrames = 0;
local output_boost_stats_checkbox;

local function outputBoostStats()
	if Game.isPhysicsFrame() and forms.ischecked(output_boost_stats_checkbox) then
		local boost = Game.getBoost();
		local getReady = mainmemory.readbyte(Game.Memory.get_ready[version]);
		if boost > 0 and getReady == 0 then
			local aPressed = joypad.getimmediate()["P1 A"];
			if aPressed then
				print("Frame: "..boostFrames.." Boost: "..boost.." (A Pressed)");
			else
				print("Frame: "..boostFrames.." Boost: "..boost);
			end
			boostFrames = boostFrames + 1;
		else
			if boostFrames > 0 then
				print("Boost ended");
			end
			boostFrames = 0;
		end
	end
end

--------------------
-- Get ready jank --
--------------------

-- Blue UI
local options_get_ready_blue_max_label;
local options_decrease_get_ready_blue_max_button;
local options_increase_get_ready_blue_max_button;
local options_get_ready_blue_max_value_label;

local options_get_ready_blue_min_label;
local options_decrease_get_ready_blue_min_button;
local options_increase_get_ready_blue_min_button;
local options_get_ready_blue_min_value_label;

local function increase_get_ready_blue_max()
	get_ready_blue_max = math.min(80, get_ready_blue_max + 1);
	forms.settext(options_get_ready_blue_max_value_label, get_ready_blue_max);
end

local function decrease_get_ready_blue_max()
	get_ready_blue_max = math.max(0, get_ready_blue_max - 1);
	forms.settext(options_get_ready_blue_max_value_label, get_ready_blue_max);
end

local function increase_get_ready_blue_min()
	get_ready_blue_min = math.min(80, get_ready_blue_min + 1);
	forms.settext(options_get_ready_blue_min_value_label, get_ready_blue_min);
end

local function decrease_get_ready_blue_min()
	get_ready_blue_min = math.max(0, get_ready_blue_min - 1);
	forms.settext(options_get_ready_blue_min_value_label, get_ready_blue_min);
end

-- Yellow UI
local options_get_ready_yellow_max_label;
local options_decrease_get_ready_yellow_max_button;
local options_increase_get_ready_yellow_max_button;
local options_get_ready_yellow_max_value_label;

local options_get_ready_yellow_min_label;
local options_decrease_get_ready_yellow_min_button;
local options_increase_get_ready_yellow_min_button;
local options_get_ready_yellow_min_value_label;

local function increase_get_ready_yellow_max()
	get_ready_yellow_max = math.min(80, get_ready_yellow_max + 1);
	forms.settext(options_get_ready_yellow_max_value_label, get_ready_yellow_max);
end

local function decrease_get_ready_yellow_max()
	get_ready_yellow_max = math.max(0, get_ready_yellow_max - 1);
	forms.settext(options_get_ready_yellow_max_value_label, get_ready_yellow_max);
end

local function increase_get_ready_yellow_min()
	get_ready_yellow_min = math.min(80, get_ready_yellow_min + 1);
	forms.settext(options_get_ready_yellow_min_value_label, get_ready_yellow_min);
end

local function decrease_get_ready_yellow_min()
	get_ready_yellow_min = math.max(0, get_ready_yellow_min - 1);
	forms.settext(options_get_ready_yellow_min_value_label, get_ready_yellow_min);
end

--------------
-- Encircle --
--------------

local encircle_checkbox;

local radius = 1000;

local function get_num_slots()
	return mainmemory.read_u32_be(Game.Memory.num_objects[version]);
end

local function get_slot_base(pointerList, index)
	return mainmemory.read_u24_be(pointerList + (index * 4) + 1);
end

local function encircle_player()
	local playerObject = mainmemory.read_u24_be(player_object_pointer + 1);
	local current_player_x = Game.getXPosition();
	local current_player_y = Game.getYPosition();
	local current_player_z = Game.getZPosition();
	local x, z;

	local pointerList = mainmemory.read_u32_be(Game.Memory.pointer_list[version]);
	if not isPointer(pointerList) then
		return;
	end
	pointerList = pointerList - RDRAMBase;

	local num_slots = get_num_slots();

	-- Populate and sort pointer list
	local currentPointers = {};
	for i = 0, num_slots - 1 do
		local slotBase = get_slot_base(pointerList, i);
		if slotBase ~= playerObject and slotBase > 0x000000 and slotBase < 0x800000 then
			table.insert(currentPointers, slotBase);
		end
	end
	table.sort(currentPointers);

	-- Iterate and set position
	for i = 1, #currentPointers do
		x = current_player_x + math.cos(math.pi * 2 * i / #currentPointers) * radius;
		z = current_player_z + math.sin(math.pi * 2 * i / #currentPointers) * radius;

		mainmemory.writefloat(currentPointers[i] + x_pos, x, true);
		mainmemory.writefloat(currentPointers[i] + y_pos, current_player_y, true);
		mainmemory.writefloat(currentPointers[i] + z_pos, z, true);
	end
end

------------
-- Events --
------------

function Game.setMap(value)
	value = value - 1;
	for i = 1, #map_freeze_values do
		mainmemory.writebyte(map_freeze_values[i], value);
	end
end

function Game.applyInfinites()
	-- Unlock cheat menu
	mainmemory.write_u32_be(Game.Memory.cheat_menu[version], 0xFFFFFFFF);

	-- Player object bizzo
	local player_object = mainmemory.read_u32_be(player_object_pointer);
	if isPointer(player_object) then
		player_object = player_object - RDRAMBase;
		mainmemory.writebyte(player_object + bananas, max_bananas);
		mainmemory.writebyte(player_object + powerup_quantity, 1);
		--mainmemory.write_s8(player_object + boost_timer, 1);
		mainmemory.writebyte(player_object + silver_coins, 8);
	end
end

function Game.initUI()
	output_boost_stats_checkbox = forms.checkbox(ScriptHawkUI.options_form, "Boost info", ScriptHawkUI.col(5) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(4) + ScriptHawkUI.dropdown_offset);
	encircle_checkbox = forms.checkbox(ScriptHawkUI.options_form, "Encircle (beta)", ScriptHawkUI.col(5) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(5) + ScriptHawkUI.dropdown_offset);

	otap_checkbox = forms.checkbox(ScriptHawkUI.options_form, "Auto tapper", ScriptHawkUI.col(0) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(6) + ScriptHawkUI.dropdown_offset);
	otap_boost_dropdown = forms.dropdown(ScriptHawkUI.options_form, {"Yellow", "Blue", "None"}, ScriptHawkUI.col(0) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(7) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.col(4), ScriptHawkUI.button_height);

	local blue_col_base = 5;
	local yellow_col_base = 11;

	-- Get ready paramater, blue min
	options_get_ready_blue_min_label = forms.label(ScriptHawkUI.options_form, "BMin:", ScriptHawkUI.col(blue_col_base), ScriptHawkUI.row(6) + ScriptHawkUI.label_offset, 40, 14);
	options_decrease_get_ready_blue_min_button = forms.button(ScriptHawkUI.options_form, "-", decrease_get_ready_blue_min, ScriptHawkUI.col(blue_col_base + 3) - 28, ScriptHawkUI.row(6), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	options_increase_get_ready_blue_min_button = forms.button(ScriptHawkUI.options_form, "+", increase_get_ready_blue_min, ScriptHawkUI.col(blue_col_base + 4) - 28, ScriptHawkUI.row(6), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	options_get_ready_blue_min_value_label = forms.label(ScriptHawkUI.options_form, get_ready_blue_min, ScriptHawkUI.col(blue_col_base + 4), ScriptHawkUI.row(6) + ScriptHawkUI.label_offset, 32, 14);

	-- Get ready paramater, blue max
	options_get_ready_blue_max_label = forms.label(ScriptHawkUI.options_form, "BMax:", ScriptHawkUI.col(blue_col_base), ScriptHawkUI.row(7) + ScriptHawkUI.label_offset, 40, 14);
	options_decrease_get_ready_blue_max_button = forms.button(ScriptHawkUI.options_form, "-", decrease_get_ready_blue_max, ScriptHawkUI.col(blue_col_base + 3) - 28, ScriptHawkUI.row(7), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	options_increase_get_ready_blue_max_button = forms.button(ScriptHawkUI.options_form, "+", increase_get_ready_blue_max, ScriptHawkUI.col(blue_col_base + 4) - 28, ScriptHawkUI.row(7), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	options_get_ready_blue_max_value_label = forms.label(ScriptHawkUI.options_form, get_ready_blue_max, ScriptHawkUI.col(blue_col_base + 4), ScriptHawkUI.row(7) + ScriptHawkUI.label_offset, 32, 14);

	-- Get ready paramater, yellow min
	options_get_ready_yellow_min_label = forms.label(ScriptHawkUI.options_form, "YMin:", ScriptHawkUI.col(yellow_col_base), ScriptHawkUI.row(6) + ScriptHawkUI.label_offset, 40, 14);
	options_decrease_get_ready_yellow_min_button = forms.button(ScriptHawkUI.options_form, "-", decrease_get_ready_yellow_min, ScriptHawkUI.col(yellow_col_base + 3) - 28, ScriptHawkUI.row(6), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	options_increase_get_ready_yellow_min_button = forms.button(ScriptHawkUI.options_form, "+", increase_get_ready_yellow_min, ScriptHawkUI.col(yellow_col_base + 4) - 28, ScriptHawkUI.row(6), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	options_get_ready_yellow_min_value_label = forms.label(ScriptHawkUI.options_form, get_ready_yellow_min, ScriptHawkUI.col(yellow_col_base + 4), ScriptHawkUI.row(6) + ScriptHawkUI.label_offset, 32, 14);

	-- Get ready paramater, yellow max
	options_get_ready_yellow_max_label = forms.label(ScriptHawkUI.options_form, "YMax:", ScriptHawkUI.col(yellow_col_base), ScriptHawkUI.row(7) + ScriptHawkUI.label_offset, 40, 14);
	options_decrease_get_ready_yellow_max_button = forms.button(ScriptHawkUI.options_form, "-", decrease_get_ready_yellow_max, ScriptHawkUI.col(yellow_col_base + 3) - 28, ScriptHawkUI.row(7), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	options_increase_get_ready_yellow_max_button = forms.button(ScriptHawkUI.options_form, "+", increase_get_ready_yellow_max, ScriptHawkUI.col(yellow_col_base + 4) - 28, ScriptHawkUI.row(7), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	options_get_ready_yellow_max_value_label = forms.label(ScriptHawkUI.options_form, get_ready_yellow_max, ScriptHawkUI.col(yellow_col_base + 4), ScriptHawkUI.row(7) + ScriptHawkUI.label_offset, 32, 14);
end

function Game.eachFrame()
	if not otap_enabled and forms.ischecked(otap_checkbox) then
		enableOptimalTap();
	end

	if otap_enabled and not forms.ischecked(otap_checkbox) then
		disableOptimalTap();
	end

	if otap_enabled then
		optimalTap();
	end

	if forms.ischecked(encircle_checkbox) then
		encircle_player();
	end

	outputBoostStats();
end

Game.OSDPosition = {2, 70}
Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"dY"},
	{"dXZ"},
	{"Separator", 1},
	{"Spin Timer", Game.getSpinTimer, Game.colorSpinTimer},
	{"Boost", Game.getBoost},
	{"Velocity", Game.getVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"Lateral Velocity", Game.getLateralVelocity},
	--{"Lateral Acceleration", Game.getLateralAcceleration}, -- TODO: Is this a thing?
	{"Throttle", Game.getThrottle},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
	{"Rot. X", Game.getXRotation},
	{"Facing", Game.getYRotation},
	--{"Moving", Game.getMovingRotation}, -- TODO
	{"Rot. Z", Game.getZRotation},
};

return Game;