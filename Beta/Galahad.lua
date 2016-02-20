-----------------------------------------------------------
-- An object viewer for Legend of Galahad on the Genesis --
-- Written by The8BitBeast, 2016                         --
-----------------------------------------------------------

local obj_index = 1;
local obj_size = 0x44;
local obj_start = 0x22B8;
local max_objects = 51;

--Form Controls
local formhandle;
local obj_extra_data;
local button_incr_obj_index;
local button_decr_obj_index;

local obj_x = 0x00; -- u16_be
local obj_y = 0x02; -- u16_be
local obj_cycle1 = 0x0C; -- u16 be
local obj_cycle2 = 0x10; -- u16_be
local obj_cycle3 = 0x14; -- u16_be
local obj_cycle4 = 0x20; -- u16_be Check these cycles
local obj_cycle4_bound = 0x24; -- u16_be
local obj_type = 0x28; -- u16_be
local obj_destructability = 0x2A; --Check this
local obj_health = 0x2C; -- u16_be
local obj_chest_type = 0x3A; -- u16_be
local obj_held_item = 0x3C; -- u16_be

--Tables
local object_types = {
	[0x00] = "Null",
	[0x01] = "Shop",
	[0x02] = "Dragon",
	[0x03] = "Jumping Barrel",
	[0x04] = "Platform",
	[0x05] = "Bridge",

	[0x07] = "Swinging Ball on Chain",

	[0x09] = "Fancy Spike",
	[0x0A] = "Guard",

	[0x0C] = "Waterfall Log",
	[0x0D] = "Big Plant Enemy",
	[0x0E] = "Health Pickup",
	[0x0F] = "Destroyed object / Pickup Spawner",
	[0x10] = "Destroyed Object / Pickup Spawner",
	[0x11] = "Roof Chain Spike Thing",
	[0x12] = "Grey Floor Spike",
	[0x13] = "Ant Enemy",
	[0x14] = "Killable Glitch Dragon Thing (W2 tileset)",

	--[0x16] = "",
	--[0x17] = "",
	--[0x18] = "",
	--[0x19] = "",
	--[0x1A] = "",
	--[0x1B] = "",
	--[0x1C] = "",
	--[0x1D] = "",
	--[0x1E] = "",
	--[0x1F] = "",
	--[0x20] = "",
	--[0x21] = "",
	--[0x22] = "",
	--[0x23] = "",
    --[0x24] = "",
	--TODO: Finish Table
};

local held_item = {
	[0x00] = "Nothing",
	[0x01] = "2 coins",
	--TODO: Finish Table
};

-- Code
function getExamineData(pointer)
	local examine_data = {};
	table.insert(examine_data,{"Object Number", obj_index});

	local objTypeValue = mainmemory.read_u16_be(pointer + obj_type);
	if type(object_types[objTypeValue]) ~= "nil" then
		objTypeValue = bizstring.hex(objTypeValue)..": "..object_types[objTypeValue];
	else
		objTypeValue = bizstring.hex(objTypeValue)..": Unknown";
	end
	table.insert(examine_data, {"Obj Type", objTypeValue});

	table.insert(examine_data, {"X", mainmemory.read_u16_be(pointer + obj_x)});
	table.insert(examine_data, {"Y", mainmemory.read_u16_be(pointer + obj_y)});
	table.insert(examine_data, {"Health", mainmemory.read_u16_be(pointer + obj_health)});

	local objHeldValue = mainmemory.read_u16_be(pointer + obj_held_item);
	if type(held_item[objHeldValue]) ~= "nil" then
		objHeldValue = bizstring.hex(objHeldValue)..": "..held_item[objHeldValue];
	else
		objHeldValue = bizstring.hex(objHeldValue)..": Respawn Timer / No item";
	end
	table.insert(examine_data, {"Held item", objHeldValue});

	if forms.ischecked(obj_extra_data) then
		table.insert(examine_data, {"0x04", mainmemory.read_u16_be(pointer + 0x04)});
		table.insert(examine_data, {"0x06", mainmemory.read_u16_be(pointer + 0x06)});
		table.insert(examine_data, {"0x08", mainmemory.read_u16_be(pointer + 0x08)});
		table.insert(examine_data, {"0x0A", mainmemory.read_u16_be(pointer + 0x0A)});
		table.insert(examine_data, {"0x0C: Cycle 1", mainmemory.read_u16_be(pointer + 0x0C)});
		table.insert(examine_data, {"0x0E", mainmemory.read_u16_be(pointer + 0x0E)});
		table.insert(examine_data, {"0x10: Cycle 2", mainmemory.read_u16_be(pointer + 0x10)});
		table.insert(examine_data, {"0x12", mainmemory.read_u16_be(pointer + 0x12)});
		table.insert(examine_data, {"0x14: Cycle 3", mainmemory.read_u16_be(pointer + 0x14)});
		table.insert(examine_data, {"0x16", mainmemory.read_u16_be(pointer + 0x16)});
		table.insert(examine_data, {"0x18", mainmemory.read_u16_be(pointer + 0x18)});
		table.insert(examine_data, {"0x1A", mainmemory.read_u16_be(pointer + 0x1A)});
		table.insert(examine_data, {"0x1C", mainmemory.read_u16_be(pointer + 0x1C)});
		table.insert(examine_data, {"0x1E", mainmemory.read_u16_be(pointer + 0x1E)});
		table.insert(examine_data, {"0x20: Cycle 4", mainmemory.read_u16_be(pointer + 0x20)});
		table.insert(examine_data, {"0x22", mainmemory.read_u16_be(pointer + 0x22)});
		table.insert(examine_data, {"0x24: Bound for cycle 4", mainmemory.read_u16_be(pointer + 0x24)});
		table.insert(examine_data, {"0x26", mainmemory.read_u16_be(pointer + 0x26)});
		table.insert(examine_data, {"0x2A: Destructibility", mainmemory.read_u16_be(pointer + 0x2A)});
		table.insert(examine_data, {"0x2E", mainmemory.read_u16_be(pointer + 0x2E)});
		table.insert(examine_data, {"0x30", mainmemory.read_u16_be(pointer + 0x30)});
		table.insert(examine_data, {"0x32", mainmemory.read_u16_be(pointer + 0x32)});
		table.insert(examine_data, {"0x34", mainmemory.read_u16_be(pointer + 0x34)});
		table.insert(examine_data, {"0x36", mainmemory.read_u16_be(pointer + 0x36)});
		table.insert(examine_data, {"0x38", mainmemory.read_u16_be(pointer + 0x38)});
		table.insert(examine_data, {"0x3A: Chest Type", mainmemory.read_u16_be(pointer + obj_chest_type)});
		table.insert(examine_data, {"0x3E", mainmemory.read_u16_be(pointer + 0x3E)});
		table.insert(examine_data, {"0x40", mainmemory.read_u16_be(pointer + 0x40)});
		table.insert(examine_data, {"0x42", mainmemory.read_u16_be(pointer + 0x42)});
	end
	return examine_data;
end

function fetch_address(index)
	obj_address = obj_start+obj_size*(index-1)
end

function draw_ui()
	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	local examine_data = getExamineData(fetch_address(obj_index));
	for i = #examine_data, 1, -1 do
		if examine_data[i][1] ~= "Separator" then
			gui.text(gui_x, gui_y + height * row, examine_data[i][1]..": "..examine_data[i][2], nil, nil, 'bottomright');
			row = row + 1;
		else
			row = row + examine_data[i][2];
		end
	end
end

function fetch_address(index)
	return obj_start + obj_size * (index - 1);
end

local function incr_obj_index()
	obj_index = math.min(max_objects, obj_index + 1);
end

local function decr_obj_index()
	obj_index = math.max(1, obj_index - 1);
end

formhandle = forms.newform(500, 250, "Galahad");
obj_extra_data = forms.checkbox(formhandle, "Show all", 50, 50);
button_incr_obj_index = forms.button(formhandle, "+", incr_obj_index, 50, 70, 20, 20);
button_decr_obj_index = forms.button(formhandle, "-", decr_obj_index, 150, 70, 20, 20);

event.onframestart(draw_ui , "ScriptHawk - Galahad object list OSD");