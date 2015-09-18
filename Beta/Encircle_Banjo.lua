-- Absolute
local banjo_x = 0x37C5A0;
local banjo_y = banjo_x + 4;
local banjo_z = banjo_y + 4;

local minigame_array_pointer = 0x36E560;

-- Relative to minigame_array
local slot_base = 0x28;
local max_slots = 0x100;
local num_slots = 0;
local slot_size = 0x180;
local radius = 1000;

-- Relative to slot
local x_pos = 0x164;
local y_pos = x_pos + 4;
local z_pos = y_pos + 4;

local function get_num_slots()
	local minigame_array_state = mainmemory.read_u24_be(minigame_array_pointer + 1);
	return math.min(max_slots, mainmemory.read_u32_be(minigame_array_state));
end

local function get_slot_base(index)
	local minigame_array_state = mainmemory.read_u24_be(minigame_array_pointer + 1);
	return minigame_array_state + slot_base + index * slot_size;
end

local function encircle_banjo()
	local i, x, z;

	local current_banjo_x = mainmemory.readfloat(banjo_x, true);
	local current_banjo_y = mainmemory.readfloat(banjo_y, true);
	local current_banjo_z = mainmemory.readfloat(banjo_z, true);
	local slot_base;

	num_slots = get_num_slots();
	radius = num_slots * 15;

	for i=0,num_slots do
		slot_base = get_slot_base(i);

		x = current_banjo_x + math.cos(math.pi * 2 * i / num_slots) * radius;
		z = current_banjo_z + math.sin(math.pi * 2 * i / num_slots) * radius;

		mainmemory.writefloat(slot_base + x_pos, x, true);
		mainmemory.writefloat(slot_base + y_pos, current_banjo_y, true);
		mainmemory.writefloat(slot_base + z_pos, z, true);
	end
end

event.onframestart(encircle_banjo, "encircle");