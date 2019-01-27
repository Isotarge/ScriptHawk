if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		screen_x = 0x566, -- s16_be
		screen_y = 0x568, -- s16_be
		x_velocity = 0xF43, -- s8
		y_velocity = 0xF44, -- s8
		bombs = 0x146A, -- w,u
		coins = 0x146C, -- w,u
		health = 0x1471, -- b,u
		armor_type = 0x1474, -- w,u
		sword_type = 0x147C, -- w,u
		lives = 0x13E6, -- w,u
		charge_1 = 0x13FB, -- b,h
		charge_2 = 0x13FC, -- b,h
		got_key = 0x1428, -- b,u
		stage = 0x1432, -- w,u
	},
	maps = {
		"1-1",
		"1-2",
		"1-3",
		"1-4",
		"1-5",
		"1-6",
		"1-7",
		"2-1",
		"2-2",
		"2-3",
		"2-4",
		"2-5",
		"2-6",
		"2-7",
		"3-1",
		"3-2",
		"3-3",
		"3-4",
		"3-5",
		"3-6",
		"!21",
		"3-7 Wizard",
	},
	swords = {
		["Training Sword"] = 0,
		["Short Sword"] = 1,
		["Long Sword (1)"] = 2,
		["Long Sword (2)"] = 3,
		["Force Blade"] = 4,
		["Tempest Blade"] = 5,
		["Lion Blade"] = 6,
	},
};

function Game.setMap(index)
	mainmemory.write_u16_be(Game.Memory.stage, index);
end

function Game.setSword(index)
	mainmemory.write_u16_be(Game.Memory.sword_type, index);
end

function Game.setSwordFromDropdown()
	local sword = forms.gettext(ScriptHawk.UI.form_controls.sword_dropdown);
	Game.setSword(Game.swords[sword]);
end

function Game.getScreenXPosition()
	return mainmemory.read_s16_be(Game.Memory.screen_x);
end

function Game.getScreenYPosition()
	return mainmemory.read_s16_be(Game.Memory.screen_y);
end

function Game.getCharge()
	return mainmemory.readbyte(Game.Memory.charge_1)..","..mainmemory.readbyte(Game.Memory.charge_2);
end

function Game.getXVelocity()
	return mainmemory.read_s8(Game.Memory.x_velocity);
end

function Game.getYVelocity()
	return mainmemory.read_s8(Game.Memory.y_velocity);
end

-----------------------------------------------------------
-- An object viewer for Legend of Galahad on the Genesis --
-- Originally written by The8bitbeast, 2016              --
-- Ported to a ScriptHawk module by Isotarge, 2018       --
-----------------------------------------------------------

local object_tools_modes = {
	"None",
	"List",
	"Examine",
};
local object_tools_mode_index = 1;
local object_tools_mode = object_tools_modes[object_tools_mode_index];

local function toggleObjectAnalysisToolsMode()
	object_tools_mode_index = object_tools_mode_index + 1;
	if object_tools_mode_index > #object_tools_modes then
		object_tools_mode_index = 1;
	end
	object_tools_mode = object_tools_modes[object_tools_mode_index];
end

local object_index = 1;
local max_objects = 51;

local function incrementObjectIndex()
	object_index = object_index + 1;
	if object_index > max_objects then
		object_index = 1;
	end
end

local function decrementObjectIndex()
	object_index = object_index - 1;
	if object_index < 1 then
		object_index = max_objects;
	end
end

-- Keybinds
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm
ScriptHawk.bindKeyRealtime("C", toggleObjectAnalysisToolsMode, true);
ScriptHawk.bindKeyRealtime("N", decrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("M", incrementObjectIndex, true);
ScriptHawk.bindMouse("mousewheelup", decrementObjectIndex);
ScriptHawk.bindMouse("mousewheeldown", incrementObjectIndex);

function Game.getKey()
	mainmemory.writebyte(Game.Memory.got_key, 1);
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.button(0, 6, {4, 10}, nil, nil, "Get Key", Game.getKey);

		-- Sword
		ScriptHawk.UI.form_controls.sword_dropdown = forms.dropdown(ScriptHawk.UI.options_form, {"Training Sword", "Short Sword", "Long Sword (1)", "Long Sword (2)", "Force Blade", "Tempest Blade", "Lion Blade"}, ScriptHawk.UI.col(5) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 8, ScriptHawk.UI.button_height);
		ScriptHawk.UI.button(0, 7, {4, 10}, nil, nil, "Set Sword", Game.setSwordFromDropdown);
	end

	ScriptHawk.UI.checkbox(10, 6, "checkbox_extra_data", "Show All");
	ScriptHawk.UI.button({13, - 7}, 7, {ScriptHawk.UI.button_height}, nil, "button_decrement_object_index", "-", decrementObjectIndex);
	ScriptHawk.UI.button({13, ScriptHawk.UI.button_height - 7}, 7, {ScriptHawk.UI.button_height}, nil, "button_increment_object_index", "+", incrementObjectIndex);
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.applyInfinites()
	mainmemory.write_u16_be(Game.Memory.bombs, 99);
	mainmemory.write_u16_be(Game.Memory.coins, 9999);
	mainmemory.writebyte(Game.Memory.health, 6);
	mainmemory.write_u16_be(Game.Memory.lives, 9);
end

------------------------------
-- Object Model Information --
------------------------------

local object_size = 0x44;
local object_start = 0x22B8;

local object = {
	x = 0x00, -- u16_be
	y = 0x02, -- u16_be
	cycle1 = 0x0C, -- u16 be
	cycle2 = 0x10, -- u16_be
	cycle3 = 0x14, -- u16_be
	cycle4 = 0x20, -- u16_be Check these cycles
	cycle4_bound = 0x24, -- u16_be

	respawn_timer = 0x1E, -- s16_be
	respawn_timer_cap = 0x22, -- s16_be
	respawn_x_position = 0x40,
	respawn_y_position = 0x42,

	animation_frame = 0x26, -- u16_be
	type = 0x28, -- u16_be
	destructibility = 0x2A, -- Check this
	health = 0x2C, -- u16_be
	chest_type = 0x3A, -- u16_be
	held_item = 0x3C, -- u16_be
};

local object_types = {
	[0x00] = "Null",
	[0x01] = "Shop",
	[0x02] = "Dragon",
	[0x03] = "Jumping Barrel",
	[0x04] = "Platform",
	[0x05] = "Bridge",

	[0x07] = "Swinging Ball on Chain",
	[0x08] = "Destroyed Object / Pickup Spawner",
	[0x09] = "Fancy Spike",
	[0x0A] = "Guard",
	[0x0B] = "Horse and Cart",
	[0x0C] = "Waterfall Log",
	[0x0D] = "Big Plant Enemy",
	[0x0E] = "Pickup", -- Health, Coin
	[0x0F] = "Destroyed Object / Pickup Spawner",
	[0x10] = "Destroyed Object / Pickup Spawner",
	[0x11] = "Roof Chain Spike Thing",
	[0x12] = "Grey Floor Spike",
	[0x13] = "Ant Enemy",
	[0x14] = "Killable Glitch Dragon Thing (W2 tileset)",

	[0x1B] = "Goblin (Bow)",
	[0x1C] = "Falling Rock",

	[0x20] = "Chest",
	[0x21] = "Level End Portal",

	[0x38] = "Spawning Object", -- Guard?

	[0x43] = "Big Bat", -- Gold
	--TODO: Finish Table
};

local held_item = {
	[0x00] = "Nothing",
	[0x01] = "2 coins",
	--TODO: Finish Table
};

----------
-- Code --
----------

local function getObjectBase(index)
	return object_start + object_size * (index - 1);
end

local function getExamineData(objectBase)
	local examine_data = {};
	table.insert(examine_data, {"Object Index", object_index.." ("..toHexString(objectBase)..")"});

	local objectTypeValue = mainmemory.read_u16_be(objectBase + object.type);
	objectTypeValue = (object_types[objectTypeValue] or "Unknown").." ("..toHexString(objectTypeValue)..")";
	table.insert(examine_data, {"Object Type", objectTypeValue});

	table.insert(examine_data, {"X", mainmemory.read_u16_be(objectBase + object.x)});
	table.insert(examine_data, {"Y", mainmemory.read_u16_be(objectBase + object.y)});
	table.insert(examine_data, {"Animation Frame", mainmemory.read_u16_be(objectBase + object.animation_frame)});

	table.insert(examine_data, {"Health", mainmemory.read_u16_be(objectBase + object.health)});
	table.insert(examine_data, {"Destructibility", mainmemory.read_u16_be(objectBase + object.destructibility)});

	local objHeldValue = mainmemory.read_u16_be(objectBase + object.held_item);
	objHeldValue = (held_item[objHeldValue] or "Respawn Timer / No item").." ("..toHexString(objHeldValue)..")";
	table.insert(examine_data, {"Held item", objHeldValue});
	table.insert(examine_data, {"Chest Type", mainmemory.read_u16_be(objectBase + object.chest_type)});

	table.insert(examine_data, {"Cycle 1", mainmemory.read_u16_be(objectBase + object.cycle1)});
	table.insert(examine_data, {"Cycle 2", mainmemory.read_u16_be(objectBase + object.cycle2)});
	table.insert(examine_data, {"Cycle 3", mainmemory.read_u16_be(objectBase + object.cycle3)});
	table.insert(examine_data, {"Cycle 4", mainmemory.read_u16_be(objectBase + object.cycle4)});
	table.insert(examine_data, {"Cycle 4 Bound", mainmemory.read_u16_be(objectBase + object.cycle4_bound)});

	table.insert(examine_data, {"Respawn Timer", mainmemory.read_s16_be(objectBase + object.respawn_timer)});
	table.insert(examine_data, {"Respawn Timer Cap", mainmemory.read_s16_be(objectBase + object.respawn_timer_cap)});
	table.insert(examine_data, {"Respawn X Position", mainmemory.read_u16_be(objectBase + object.respawn_x_position)});
	table.insert(examine_data, {"Respawn Y Position", mainmemory.read_u16_be(objectBase + object.respawn_y_position)});

	if ScriptHawk.UI.ischecked("checkbox_extra_data") then
		table.insert(examine_data, {"0x04", mainmemory.read_u16_be(objectBase + 0x04)});
		table.insert(examine_data, {"0x06", mainmemory.read_u16_be(objectBase + 0x06)});
		table.insert(examine_data, {"0x08", mainmemory.read_u16_be(objectBase + 0x08)});
		table.insert(examine_data, {"0x0A", mainmemory.read_u16_be(objectBase + 0x0A)});
		table.insert(examine_data, {"0x0E", mainmemory.read_u16_be(objectBase + 0x0E)});
		table.insert(examine_data, {"0x12", mainmemory.read_u16_be(objectBase + 0x12)}); -- Cycle
		table.insert(examine_data, {"0x16", mainmemory.read_u16_be(objectBase + 0x16)}); -- Cycle cap
		table.insert(examine_data, {"0x18", mainmemory.read_u16_be(objectBase + 0x18)});
		table.insert(examine_data, {"0x1A", mainmemory.read_u16_be(objectBase + 0x1A)});
		table.insert(examine_data, {"0x1C", mainmemory.read_u16_be(objectBase + 0x1C)});
		table.insert(examine_data, {"0x2E", mainmemory.read_u16_be(objectBase + 0x2E)});
		table.insert(examine_data, {"0x30", mainmemory.read_u16_be(objectBase + 0x30)});
		table.insert(examine_data, {"0x32", mainmemory.read_u16_be(objectBase + 0x32)});
		table.insert(examine_data, {"0x34", mainmemory.read_u16_be(objectBase + 0x34)});
		table.insert(examine_data, {"0x36", mainmemory.read_u16_be(objectBase + 0x36)});
		table.insert(examine_data, {"0x38", mainmemory.read_u16_be(objectBase + 0x38)});
		table.insert(examine_data, {"0x3E", mainmemory.read_u16_be(objectBase + 0x3E)});
	end
	return examine_data;
end

function Game.drawUI()
	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	if object_tools_mode == "List" then
		for i = max_objects, 1, -1 do
			local objectBase = getObjectBase(i - 1);
			local objectType = mainmemory.read_u16_be(objectBase + object.type);
			if objectType ~= 0 or ScriptHawk.UI.ischecked("checkbox_extra_data") then
				objectType = (object_types[objectType] or "Unknown").." ("..toHexString(objectType)..")";
				local color = nil;
				if i == object_index then
					color = colors.yellow;
				end
				gui.text(gui_x, gui_y + height * row, objectType.." ("..toHexString(objectBase)..") "..i, color, 'bottomright');
				row = row + 1;
			end
		end
	elseif object_tools_mode == "Examine" then
		local examine_data = getExamineData(getObjectBase(object_index));
		for i = #examine_data, 1, -1 do
			if examine_data[i][1] ~= "Separator" then
				gui.text(gui_x, gui_y + height * row, examine_data[i][1]..": "..examine_data[i][2], nil, 'bottomright');
				row = row + 1;
			else
				row = row + examine_data[i][2];
			end
		end
	end
end

Game.OSD = {
	{"Screen X", Game.getScreenXPosition, category="screenPosition"},
	{"Screen Y", Game.getScreenYPosition, category="screenPosition"},
	{"X Velocity", Game.getXVelocity, category="speed"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"Charge", Game.getCharge, category="charge"},
};

return Game;