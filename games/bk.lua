local Game = {};

--------------------
-- Region/Version --
--------------------

-- Only patch US 1.0
local allowFurnaceFunPatch = false;

local slope_timer;
local y_vel;

local x_pos;
local y_pos;
local z_pos;

local x_rot;
local facing_angle;
local z_rot;

local map;
local gameTimeBase;
local vile_state_pointer;

local notes;

-- Relative to notes
local eggs = 4;
local red_feathers = 12;
local gold_feathers = 16;
local health = 32;
local health_containers = 36;
local lives = 40;
local air = 43;
local air_timer = 44;
local mumbo_tokens = 100;
local jiggies = 104;

local max_notes = 100;
local max_eggs = 200;
local max_red_feathers = 50;
local max_gold_feathers = 10;
local max_health = 16;
local max_health_containers = 16;
local max_lives = 9;
local max_air = 14;
local max_mumbo_tokens = 99;
local max_jiggies = 100;

local eep_checksum_offsets = {
	0x74,
	0xEC,
	0x164,
	0x1DC,
	0x1FC
};

local eep_checksum_values = {
	0x00000000,
	0x00000000,
	0x00000000,
	0x00000000,
	0x00000000
}

Game.maps = {
	"Spiral Mountain",
	"Mumbo's Mountain",
	"Unknown 0x03",
	"Unknown 0x04",
	"TTC - Pirate RBB Hold",
	"TTC - Nipper's Shell",
	"Treasure Trove Cove",
	"Unknown 0x08",
	"Unknown 0x09",
	"TTC - Sand Castle",
	"Clanker's Cavern",
	"MM - Termite Mound",
	"Bubblegloop Swamp",
	"MM - Mumbo's Skull",
	"Unknown 0x0F",
	"BGS - Crocodile Head",
	"BGS - Turtle",
	"Gobi's Valley",
	"GV - Pyramid 1 (Match the pairs)",
	"GV - Pyramid 2 (Maze)",
	"GV - Pyramid 3 (Water)",
	"GV - Pyramid 4 (Snake)",
	"Unknown 0x17",
	"Unknown 0x18",
	"Unknown 0x19",
	"GV - Sphinx",
	"Mad Monster Mansion",
	"MMM - Organ",
	"MMM - Cellar",
	"Intro - Start - Nintendo",
	"Intro - Start - Rareware",
	"Intro - End Scene 2: Not 100",
	"CC - Inside A",
	"CC - Inside B",
	"CC - Inside C",
	"MMM - Ouija Board",
	"MMM - Well",
	"MMM - Dining Room",
	"Freezeezy Peak",
	"MMM - Room 1",
	"MMM - Room 2",
	"MMM - Room 3: Fireplace",
	"MMM - Church",
	"MMM - Room 4: Bathroom",
	"MMM - Room 5: Bedroom",
	"MMM - Room 6: Floorboards",
	"MMM - Barrel",
	"MMM - Mumbo's Skull",
	"Rusty Bucket Bay",
	"Unknown 0x32",
	"Unknown 0x33",
	"RBB - Prop Room",
	"RBB - Warehouse 1",
	"RBB - Warehouse 2",
	"RBB - Container 1",
	"RBB - Container 3",
	"RBB - Crew Cabin",
	"RBB - Hold",
	"RBB - Store Room",
	"RBB - Galley",
	"RBB - Navigation Room",
	"RBB - Container 2",
	"RBB - Captain's Cabin",
	"CCW - Start",
	"FP - Boggy's Igloo",
	"Unknown 0x42",
	"CCW - Spring",
	"CCW - Summer",
	"CCW - Autumn",
	"CCW - Winter",
	"BGS - Mumbo's Skull",
	"FP - Mumbo's Skull",
	"Unknown 0x49",
	"CCW - Mumbo's Skull (Spring)",
	"CCW - Mumbo's Skull (Summer)",
	"CCW - Mumbo's Skull (Autumn)",
	"CCW - Mumbo's Skull (Winter)",
	"Unknown 0x4E",
	"Unknown 0x4F",
	"Unknown 0x50",
	"Unknown 0x51",
	"Unknown 0x52",
	"FP - Inside Xmas Tree",
	"Unknown 0x54",
	"Unknown 0x55",
	"Unknown 0x56",
	"Unknown 0x57",
	"Unknown 0x58",
	"Unknown 0x59",
	"CCW - Zubba's Hive (Summer)",
	"CCW - Zubba's Hive (Spring)",
	"CCW - Zubba's Hive (Autumn)",
	"Unknown 0x5D",
	"CCW - Nabnut's House (Spring)",
	"CCW - Nabnut's House (Summer)",
	"CCW - Nabnut's House (Autumn)",
	"CCW - Nabnut's House (Winter)",
	"CCW - Nabnut's Room 1 (Winter)",
	"CCW - Nabnut's Room 2 (Autumn)",
	"CCW - Nabnut's Room 2 (Winter)",
	"CCW - Top (Spring)",
	"CCW - Top (Summer)",
	"CCW - Top (Autumn)",
	"CCW - Top (Winter)",
	"Lair - Flr 1, Area 1: Mumbo",
	"Lair - Flr 1, Area 2",
	"Lair - Flr 1, Area 3",
	"Lair - Flr 1, Area 3a: Cauldron",
	"Lair - Flr 1, Area 4: Pirate RBB",
	"Lair - Flr 2, Area 1: Sand Chamber",
	"Lair - Flr 2, Area 2: Spooky/Advent",
	"Lair - Flr 1, Area 5: Pipes room",
	"Lair - Flr 1, Area 6: Lair statue",
	"Lair - Flr 1, Area 7: BGS/FP",
	"Unknown 0x73",
	"Lair - Flr 2, Area 4: Dark room",
	"Lair - Flr 2, Area 5: Crypt outside",
	"Lair - Flr 3, Area 1",
	"Lair - Flr 3, Area 2: RBB side",
	"Lair - Flr 3, Area 3",
	"Lair - Flr 3, Area 4: CCW trunks",
	"Lair - Flr 2, Area 5a: Crypt inside",
	"Intro - Grunties Lair 1 - Scene 1",
	"Intro - Inside Banjo's Cave 1 - Scenes 3,7",
	"Intro - Spiral 'A' - Scenes 2,4",
	"Intro - Spiral 'B' - Scenes 5,6",
	"FP - Wozza's Cave",
	"Lair - Flr 3, Area 4a",
	"Intro - Grunties Lair 2",
	"Intro - Grunties Lair 3 - Machine 1",
	"Intro - Grunties Lair 4 - Game Over",
	"Intro - Grunties Lair 5",
	"Intro - Spiral 'C'",
	"Intro - Spiral 'D'",
	"Intro - Spiral 'E'",
	"Intro - Spiral 'F'",
	"Intro - Inside Banjo's Cave 2",
	"Intro - Inside Banjo's Cave 3",
	"RBB - Anchor room",
	"SM - Banjo's House",
	"MMM - Septic Tank",
	"Lair - Furnace Fun",
	"TTC - Sea Castle",
	"Lair - Battlements",
	"SM - File Select Screen",
	"GV - Secret Chamber",
	"Lair - Flr 5, Area 1: Gruntie's rooms",
	"Intro - Spiral 'G'",
	"Intro - End Scene 3: All 100",
	"Intro - End Scene",
	"Intro - End Scene 4",
	"Intro - Grunty Threat 1",
	"Intro - Grunty Threat 2"
}

function Game.detectVersion(romName)
	if bizstring.contains(romName, "Europe") then
		slope_timer = 0x37CCB4;
		y_vel = 0x37CE8C;
		x_pos = 0x37cf70;
		x_rot = 0x37d064;
		map = 0x37F2C5;
		notes = 0x386943;
		gameTimeBase = 0x3869E4;
		vile_state_pointer = 0x36EAE0;
	elseif bizstring.contains(romName, "Japan") then
		slope_timer = 0x37CDE4;
		y_vel = 0x37CFBC;
		x_pos = 0x37d0a0;
		x_rot = 0x37d194;
		map = 0x37F405;
		notes = 0x386AA3;
		gameTimeBase = 0x386B44;
		vile_state_pointer = 0x36F260;
	elseif bizstring.contains(romName, "USA") and bizstring.contains(romName, "Rev A") then
		slope_timer = 0x37B4E4;
		y_vel = 0x37B6BC;
		x_pos = 0x37b7a0;
		x_rot = 0x37b894;
		map = 0x37DAF5;
		notes = 0x385183;
		gameTimeBase = 0x385224;
		vile_state_pointer = 0x36D760;
	elseif bizstring.contains(romName, "USA") then
		allowFurnaceFunPatch = true;
		slope_timer = 0x37C2E4;
		y_vel = 0x37C4BC;
		x_pos = 0x37c5a0;
		x_rot = 0x37c694;
		map = 0x37E8F5;
		notes = 0x385F63;
		gameTimeBase = 0x386004;
		vile_state_pointer = 0x36E560;
	else
		return false;
	end

	y_pos = x_pos + 4;
	z_pos = y_pos + 4;
	facing_angle = x_rot;
	z_rot = x_rot;

	-- Read EEPROM checksums
	if memory.usememorydomain("EEPROM") then
		local i;
		for i=1,#eep_checksum_offsets do
			eep_checksum_values[i] = memory.read_u32_be(eep_checksum_offsets[i]);
		end
	end
	memory.usememorydomain("RDRAM");

	return true;
end

local function neverSlip()
	mainmemory.writefloat(slope_timer, 0.0, true);
end

---------------------
-- Game time stuff --
---------------------

local previousGameTime = {0,0,0,0,0,0,0,0,0,0};
local gameTime = {0,0,0,0,0,0,0,0,0,0};

local function checkGameTime()
	previousGameTime = gameTime;	
	gameTime = {};

	local i;
	for i=0,10 do
		gameTime[i + 1] = mainmemory.readfloat(gameTimeBase + (i * 4), true);
	end
end

local function gameTimeHasChanged()
	for i=1,#gameTime do
		if previousGameTime[i] ~= gameTime[i] then
			return true;
		end
	end
	return false;
end

-----------------------
-- Furnace fun stuff --
-----------------------

local options_allow_ff_patch;

local function applyFurnaceFunPatch()
	if allowFurnaceFunPatch and forms.ischecked(options_allow_ff_patch) then
		mainmemory.write_u16_be(0x320064, 0x080a);
		mainmemory.write_u16_be(0x320066, 0x1840);

		mainmemory.write_u16_be(0x286100, 0xac86);
		mainmemory.write_u16_be(0x286102, 0x2dc8);
		mainmemory.write_u16_be(0x286104, 0x0c0c);
		mainmemory.write_u16_be(0x286106, 0x8072);

		mainmemory.write_u16_be(0x28610C, 0x080c);
		mainmemory.write_u16_be(0x28610E, 0x801b);
	end
end

----------------------
-- Vile state stuff --
----------------------

-- Wave UI
local options_wave_button;
local options_heart_button;
local options_fire_all_button;

local game_type = 0x90;

local previous_game_type = 0x91
local player_score = 0x92;
local vile_score = 0x93;

local minigame_timer = 0x94;

local number_of_slots = 25;
local slot_base = 0x318;
local slot_size = 0x180;

-- Relative to slot base + (slot number * slot size)

-- 00000 0x00 disabled
-- 00100 0x04 idle
-- 01000 0x08 rising
-- 01100 0x0c alive
-- 10000 0x10 falling (no eat)
-- 10100 0x14 eaten
local slot_state = 0x00;

-- Float 0-1
local popped_amount = 0x6c;

-- 0x00 = yum, > 0x00 = grum
local slot_type = 0x70;

-- Float 0-15?
local slot_timer = 0x74;

local function getSlotBase(index)
	if index < 12 then
		return slot_base + (index - 1) * slot_size;
	end
	return slot_base + index * slot_size;
end

local function fireSlot(vile_state, index, slotType)
	current_slot_base = getSlotBase(index);
	mainmemory.writebyte(vile_state + current_slot_base + slot_state, 0x08);
	mainmemory.writebyte(vile_state + current_slot_base + slot_type, slotType);
	mainmemory.writefloat(vile_state + current_slot_base + popped_amount, 1.0, true);
	mainmemory.writefloat(vile_state + current_slot_base + slot_timer, 0.0, true);
end

local vileMap = {
	{ 22, 24, 16 },
	{ 21, 23, 14, 15 },
	{ 20, 19, 17, 13, 12 },
	{ 9,  18, 11, 4 },
	{ 10, 7,  8,  2,  1  },
	{ 6,  5,  3,  0 }
};

local heart = {
	{2, 2}, {2, 3},
	{3, 2}, {3, 3}, {3, 4},
	{4, 2}, {4, 3},
	{5, 3}
};

local waveFrames = {
	{ {3, 1}, {5, 1} },
	{ {2, 1}, {4, 1}, {6, 1} },
	{ {1, 1}, {3, 2}, {5, 2} },
	{ {2, 2}, {4, 2}, {6, 2} },
	{ {1, 2}, {3, 3}, {5, 3} },
	{ {2, 3}, {4, 3}, {6, 3} },
	{ {1, 3}, {3, 4}, {5, 4} },
	{ {2, 4}, {4, 4}, {6, 4} },
	{ {3, 5}, {5, 5} }
}

function getSlotIndex(row, col)
	row = math.max(row, 1);
	if row <= #vileMap then
		col = math.max(col, 1);
		col = math.min(col, #vileMap[row]);
		return vileMap[row][col] + 1;
	end
	return 1;
end

local waving = false;
local wave_counter = 0;
local wave_delay = 10;
local wave_frame = 1;
local wave_colour = 0;

local function initWave()
	waving = true;
	wave_frame = 1;
	wave_counter = 0;
	wave_colour = math.random(0, 1);
end

local function updateWave()
	if waving then
		wave_counter = wave_counter + 1;
		if wave_counter == wave_delay then
			local i;
			local vile_state = mainmemory.read_u24_be(vile_state_pointer + 1);
			for i=1,#waveFrames[wave_frame] do
				fireSlot(vile_state, getSlotIndex(waveFrames[wave_frame][i][1], waveFrames[wave_frame][i][2]), wave_colour);
			end
			wave_counter = 0;
			wave_frame = wave_frame + 1;
		end
		if wave_frame > #waveFrames then
			waving = false;
		end
	end
end

local function doHeart()
	local vile_state = mainmemory.read_u24_be(vile_state_pointer + 1);
	local i;

	for i=1,#heart do
		fireSlot(vile_state, getSlotIndex(heart[i][1], heart[i][2]), 0);
	end
end

local function fireAllSlots()
	local vile_state = mainmemory.read_u24_be(vile_state_pointer + 1);
	local i;

	local colour = math.random(0, 1);
	for i=1,number_of_slots do
		fireSlot(vile_state, i, colour);
	end
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_index = 7;

Game.rot_speed = 10;
Game.max_rot_units = 360;

function Game.isPhysicsFrame()
	return (not emu.islagged()) and gameTimeHasChanged();
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(x_pos, true);
end

function Game.getYPosition()
	return mainmemory.readfloat(y_pos, true);
end

function Game.getZPosition()
	return mainmemory.readfloat(z_pos, true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(x_pos, value, true);
	mainmemory.writefloat(x_pos + 0x10, value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(y_pos, value, true);
	mainmemory.writefloat(y_pos + 0x10, value, true);

	-- Nullify gravity when setting Y position
	mainmemory.write_u16_be(y_vel, 17376);
end

function Game.setZPosition(value)
	mainmemory.writefloat(z_pos, value, true);
	mainmemory.writefloat(z_pos + 0x10, value, true);
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	return mainmemory.readfloat(x_rot, true);
end

function Game.getYRotation()
	return mainmemory.readfloat(facing_angle, true);
end

function Game.getZRotation()
	return mainmemory.readfloat(z_rot, true);
end

function Game.setXRotation(value)
	mainmemory.writefloat(x_rot, value, true);
end

function Game.setYRotation(value)
	mainmemory.writefloat(facing_angle, value, true);
end

function Game.setZRotation(value)
	mainmemory.writefloat(z_rot, value, true);
end

------------
-- Events --
------------

function Game.setMap(value)
	if value >= 1 and value <= #Game.maps then
		mainmemory.writebyte(map, value);
	end
end

function Game.applyInfinites()
	mainmemory.writebyte(notes, max_notes);
	mainmemory.writebyte(notes + eggs, max_eggs);
	mainmemory.writebyte(notes + red_feathers, max_red_feathers);
	mainmemory.writebyte(notes + gold_feathers, max_gold_feathers);
	mainmemory.writebyte(notes + health, max_health);
	mainmemory.writebyte(notes + lives, max_lives);
	mainmemory.writebyte(notes + air, max_air);
	mainmemory.writebyte(notes + mumbo_tokens, max_mumbo_tokens);
	mainmemory.writebyte(notes + jiggies, max_jiggies);
end

local options_toggle_neverslip;

function Game.initUI(form_handle, col, row, button_height, label_offset, dropdown_offset)
	options_toggle_neverslip = forms.checkbox(form_handle, "Never Slip", col(0), row(6));
	options_allow_ff_patch = forms.checkbox(form_handle, "Allow FF patch", col(0), row(7));
	options_wave_button = forms.button(form_handle, "Wave", initWave, col(5), row(4), col(4) + 8, button_height);
	options_heart_button = forms.button(form_handle, "Heart", doHeart, col(5), row(5), col(4) + 8, button_height);
	options_fire_all_button = forms.button(form_handle, "Fire all", fireAllSlots, col(5), row(6), col(4) + 8, button_height);
end

function Game.eachFrame()
	-- Furnace fun patch
	applyFurnaceFunPatch();

	checkGameTime();
	updateWave();

	if forms.ischecked(options_toggle_neverslip) then
		neverSlip();
	end

	-- Check EEPROM checksums
	if memory.usememorydomain("EEPROM") then
		local i, checksum_value;
		for i=1,#eep_checksum_offsets do
			checksum_value = memory.read_u32_be(eep_checksum_offsets[i]);
			if eep_checksum_values[i] ~= checksum_value then
				console.log("Wrote slot "..i.." old checksum: "..bizstring.hex(eep_checksum_values[i]).." new checksum: "..bizstring.hex(checksum_value));
				eep_checksum_values[i] = checksum_value;
			end
		end
	end
	memory.usememorydomain("RDRAM");
end

return Game;