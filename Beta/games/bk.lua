local Game = {};

--------------------
-- Region/Version --
--------------------

local x_pos;
local y_pos;
local z_pos;

local x_rot;
local y_rot;
local z_rot;

local map;

local notes;
local eggs;
local red_feathers;
local gold_feathers;
local health;
local lives;
local air;
local mumbo_tokens;
local jiggies;

local max_notes = 100;
local max_eggs = 200;
local max_red_feathers = 50;
local max_gold_feathers = 10;
local max_health = 69;
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
		x_pos = 0x37cf70;
		x_rot = 0x37d064;
		map = 0x37F2C5;

		notes         = 0x386943;
		eggs          = 0x386947;
		red_feathers  = 0x38694F;
		gold_feathers = 0x386953;
		health        = 0x386963;
		lives         = 0x38696B;
		air           = 0x38696E;
		mumbo_tokens  = 0x3869A7;
		jiggies       = 0x3869AB;
	elseif bizstring.contains(romName, "Japan") then
		x_pos = 0x37d0a0;
		x_rot = 0x37d194;
		map = 0x37F405;
		
		-- TODO - Collectables
	elseif bizstring.contains(romName, "USA") and not bizstring.contains(romName, "Rev A") then
		x_pos = 0x37c5a0;
		x_rot = 0x37c694;
		map = 0x37E8F5;

		notes         = 0x385F63;
		eggs          = 0x385F67;
		red_feathers  = 0x385F6F;
		gold_feathers = 0x385F73;
		health        = 0x385F83;
		lives         = 0x385F8B;
		air           = 0x385F8E;
		mumbo_tokens  = 0x385FC7;
		jiggies       = 0x385FCB;
	elseif bizstring.contains(romName, "USA") and bizstring.contains(romName, "Rev A") then
		x_pos = 0x37b7a0;
		x_rot = 0x37b894;
		map = 0x37DAF5;

		notes         = 0x385183;
		eggs          = 0x385187;
		red_feathers  = 0x38518F;
		gold_feathers = 0x385193;
		health        = 0x3851A3;
		lives         = 0x3851AB;
		air           = 0x3851AE;
		mumbo_tokens  = 0x3851E7;
		jiggies       = 0x3851EB;
	end

	y_pos = x_pos + 4;
	z_pos = y_pos + 4;
	y_rot = x_rot;
	z_rot = x_rot;

	-- Read EEPROM checksums
	if memory.usememorydomain("EEPROM") then
		local i;
		for i=1,#eep_checksum_offsets do
			eep_checksum_values[i] = memory.read_u32_be(eep_checksum_offsets[i]);
		end
	end
	memory.usememorydomain("RDRAM");
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_index = 7;

Game.rot_speed = 10;
Game.max_rot_units = 360;

function Game.isPhysicsFrame()
	return not emu.islagged();
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
	return mainmemory.readfloat(y_rot, true);
end

function Game.getZRotation()
	return mainmemory.readfloat(z_rot, true);
end

function Game.setXRotation(value)
	mainmemory.writefloat(x_rot, value, true);
end

function Game.setYRotation(value)
	mainmemory.writefloat(y_rot, value, true);
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
	mainmemory.writebyte(eggs, max_eggs);
	mainmemory.writebyte(red_feathers, max_red_feathers);
	mainmemory.writebyte(gold_feathers, max_gold_feathers);
	mainmemory.writebyte(health, max_health);
	mainmemory.writebyte(lives, max_lives);
	mainmemory.writebyte(air, max_air);
	mainmemory.writebyte(mumbo_tokens, max_mumbo_tokens);
	mainmemory.writebyte(jiggies, max_jiggies);
end

function Game.initUI(form_handle, col, row, button_height, label_offset, dropdown_offset)
	-- TODO
end

function Game.eachFrame()
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