-----------------------------------------------------------
-- An object viewer for Legend of Galahad on the Genesis --
-- Written by The8bitbeast, 2016                         --
-----------------------------------------------------------

--------------
-- UI State --
--------------

local object_index = 1;
local max_objects = 51;

function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	prefix = prefix or "0x";
	desiredLength = desiredLength or string.len(value);
	while string.len(value) < desiredLength do
		value = "0"..value;
	end
	return prefix..value;
end

local increment_object_index_key = "M";
local increment_object_index_pressed = false;
local decrement_object_index_key = "N";
local decrement_object_index_pressed = false;

local function increment_object_index()
	object_index = object_index + 1;
	if object_index > max_objects then
		object_index = 1;
	end
end

local function decrement_object_index()
	object_index = object_index - 1;
	if object_index < 1 then
		object_index = max_objects;
	end
end

local formhandle = forms.newform(320, 200, "Galahad");
local checkbox_extra_data = forms.checkbox(formhandle, "Show all", 17, 8);
local checkbox_list_mode = forms.checkbox(formhandle, "List mode", 17, 32);
local button_increment_object_index = forms.button(formhandle, "-", decrement_object_index, 16, 56, 32, 32);
local button_decrement_object_index = forms.button(formhandle, "+", increment_object_index, 48, 56, 32, 32);

------------------------------
-- Object Model Information --
------------------------------

local object_size = 0x44;
local object_start = 0x22B8;

local object_x = 0x00; -- u16_be
local object_y = 0x02; -- u16_be
local object_cycle1 = 0x0C; -- u16 be
local object_cycle2 = 0x10; -- u16_be
local object_cycle3 = 0x14; -- u16_be

local object_respawn_timer = 0x1E; -- s16_be
local object_respawn_timer_cap = 0x22; -- s16_be
local object_respawn_x_position = 0x40;
local object_respawn_y_position = 0x42;

local object_cycle4 = 0x20; -- u16_be Check these cycles
local object_cycle4_bound = 0x24; -- u16_be
local object_animation_frame = 0x26; -- u16_be
local object_type = 0x28; -- u16_be
local object_destructibility = 0x2A; --Check this
local object_health = 0x2C; -- u16_be
local object_chest_type = 0x3A; -- u16_be
local object_held_item = 0x3C; -- u16_be

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

function getObjectBase(index)
	return object_start + object_size * (index - 1);
end

function getExamineData(objectBase)
	local examine_data = {};
	table.insert(examine_data, {"Object Index", object_index.." ("..toHexString(objectBase)..")"});

	local objectTypeValue = mainmemory.read_u16_be(objectBase + object_type);
	if type(object_types[objectTypeValue]) ~= "nil" then
		objectTypeValue = object_types[objectTypeValue].." ("..toHexString(objectTypeValue)..")";
	else
		objectTypeValue = "Unknown ("..toHexString(objectTypeValue)..")";
	end
	table.insert(examine_data, {"Object Type", objectTypeValue});

	table.insert(examine_data, {"X", mainmemory.read_u16_be(objectBase + object_x)});
	table.insert(examine_data, {"Y", mainmemory.read_u16_be(objectBase + object_y)});
	table.insert(examine_data, {"Animation Frame", mainmemory.read_u16_be(objectBase + object_animation_frame)});

	table.insert(examine_data, {"Health", mainmemory.read_u16_be(objectBase + object_health)});
	table.insert(examine_data, {"Destructibility", mainmemory.read_u16_be(objectBase + object_destructibility)});

	local objHeldValue = mainmemory.read_u16_be(objectBase + object_held_item);
	if type(held_item[objHeldValue]) ~= "nil" then
		objHeldValue = held_item[objHeldValue].." ("..toHexString(objHeldValue)..")";
	else
		objHeldValue = "Respawn Timer / No item ("..toHexString(objHeldValue)..")";
	end
	table.insert(examine_data, {"Held item", objHeldValue});
	table.insert(examine_data, {"Chest Type", mainmemory.read_u16_be(objectBase + object_chest_type)});

	table.insert(examine_data, {"Cycle 1", mainmemory.read_u16_be(objectBase + object_cycle1)});
	table.insert(examine_data, {"Cycle 2", mainmemory.read_u16_be(objectBase + object_cycle2)});
	table.insert(examine_data, {"Cycle 3", mainmemory.read_u16_be(objectBase + object_cycle3)});
	table.insert(examine_data, {"Cycle 4", mainmemory.read_u16_be(objectBase + object_cycle4)});
	table.insert(examine_data, {"Cycle 4 Bound", mainmemory.read_u16_be(objectBase + object_cycle4_bound)});

	table.insert(examine_data, {"Respawn Timer", mainmemory.read_s16_be(objectBase + object_respawn_timer)});
	table.insert(examine_data, {"Respawn Timer Cap", mainmemory.read_s16_be(objectBase + object_respawn_timer_cap)});
	table.insert(examine_data, {"Respawn X Position", mainmemory.read_u16_be(objectBase + object_respawn_x_position)});
	table.insert(examine_data, {"Respawn Y Position", mainmemory.read_u16_be(objectBase + object_respawn_y_position)});

	if forms.ischecked(checkbox_extra_data) then
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

function process_input()
	input_table = input.get();

	-- Hold down key prevention
	if input_table[decrement_object_index_key] == nil then
		decrement_object_index_pressed = false;
	end

	if input_table[increment_object_index_key] == nil then
		increment_object_index_pressed = false;
	end

	-- Check for key presses
	if input_table[decrement_object_index_key] == true and not decrement_object_index_pressed then
		decrement_object_index();
		decrement_object_index_pressed = true;
	end

	if input_table[increment_object_index_key] == true and not increment_object_index_pressed then
		increment_object_index();
		increment_object_index_pressed = true;
	end
end

function draw_ui()
	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	if forms.ischecked(checkbox_list_mode) then
		for i = max_objects, 1, -1 do
			local objectBase = getObjectBase(i - 1);
			local objectType = mainmemory.read_u16_be(objectBase + object_type);
			if objectType ~= 0 or forms.ischecked(checkbox_extra_data) then
				if type(object_types[objectType]) ~= "nil" then
					objectType = object_types[objectType].." ("..toHexString(objectType)..")";
				else
					objectType = "Unknown ("..toHexString(objectType)..")";
				end
				local color = nil;
				if i == object_index then
					color = 0xFFFFFF00; -- Yellow
				end
				gui.text(gui_x, gui_y + height * row, objectType.." ("..toHexString(objectBase)..") "..i, color, 'bottomright');
				row = row + 1;
			end
		end
	else
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

event.onframestart(process_input, "ScriptHawk - Galahad object list Keybinds");
event.onframestart(draw_ui, "ScriptHawk - Galahad object list OSD");