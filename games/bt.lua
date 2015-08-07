local Game = {};

Game.maps = {
	                  "Unknown 0x0001", "Unknown 0x0002", "Unknown 0x0003", "Unknown 0x0004", "Unknown 0x0005", "Unknown 0x0006", "Unknown 0x0007", "Unknown 0x0008", "Unknown 0x0009", "Unknown 0x000A", "Unknown 0x000B", "Unknown 0x000C", "Unknown 0x000D", "Unknown 0x000E", "Unknown 0x000F",
	"Unknown 0x0010", "Unknown 0x0011", "Unknown 0x0012", "Unknown 0x0013", "Unknown 0x0014", "Unknown 0x0015", "Unknown 0x0016", "Unknown 0x0017", "Unknown 0x0018", "Unknown 0x0019", "Unknown 0x001A", "Unknown 0x001B", "Unknown 0x001C", "Unknown 0x001D", "Unknown 0x001E", "Unknown 0x001F",
	"Unknown 0x0020", "Unknown 0x0021", "Unknown 0x0022", "Unknown 0x0023", "Unknown 0x0024", "Unknown 0x0025", "Unknown 0x0026", "Unknown 0x0027", "Unknown 0x0028", "Unknown 0x0029", "Unknown 0x002A", "Unknown 0x002B", "Unknown 0x002C", "Unknown 0x002D", "Unknown 0x002E", "Unknown 0x002F",
	"Unknown 0x0030", "Unknown 0x0031", "Unknown 0x0032", "Unknown 0x0033", "Unknown 0x0034", "Unknown 0x0035", "Unknown 0x0036", "Unknown 0x0037", "Unknown 0x0038", "Unknown 0x0039", "Unknown 0x003A", "Unknown 0x003B", "Unknown 0x003C", "Unknown 0x003D", "Unknown 0x003E", "Unknown 0x003F",
	"Unknown 0x0040", "Unknown 0x0041", "Unknown 0x0042", "Unknown 0x0043", "Unknown 0x0044", "Unknown 0x0045", "Unknown 0x0046", "Unknown 0x0047", "Unknown 0x0048", "Unknown 0x0049", "Unknown 0x004A", "Unknown 0x004B", "Unknown 0x004C", "Unknown 0x004D", "Unknown 0x004E", "Unknown 0x004F",
	"Unknown 0x0050", "Unknown 0x0051", "Unknown 0x0052", "Unknown 0x0053", "Unknown 0x0054", "Unknown 0x0055", "Unknown 0x0056", "Unknown 0x0057", "Unknown 0x0058", "Unknown 0x0059", "Unknown 0x005A", "Unknown 0x005B", "Unknown 0x005C", "Unknown 0x005D", "Unknown 0x005E", "Unknown 0x005F",
	"Unknown 0x0060", "Unknown 0x0061", "Unknown 0x0062", "Unknown 0x0063", "Unknown 0x0064", "Unknown 0x0065", "Unknown 0x0066", "Unknown 0x0067", "Unknown 0x0068", "Unknown 0x0069", "Unknown 0x006A", "Unknown 0x006B", "Unknown 0x006C", "Unknown 0x006D", "Unknown 0x006E", "Unknown 0x006F",
	"Unknown 0x0070", "Unknown 0x0071", "Unknown 0x0072", "Unknown 0x0073", "Unknown 0x0074", "Unknown 0x0075", "Unknown 0x0076", "Unknown 0x0077", "Unknown 0x0078", "Unknown 0x0079", "Unknown 0x007A", "Unknown 0x007B", "Unknown 0x007C", "Unknown 0x007D", "Unknown 0x007E", "Unknown 0x007F",
	"Unknown 0x0080", "Unknown 0x0081", "Unknown 0x0082", "Unknown 0x0083", "Unknown 0x0084", "Unknown 0x0085", "Unknown 0x0086", "Unknown 0x0087", "Unknown 0x0088", "Unknown 0x0089", "Unknown 0x008A", "Unknown 0x008B", "Unknown 0x008C", "Unknown 0x008D", "Unknown 0x008E", "Unknown 0x008F",
	"Unknown 0x0090", "Unknown 0x0091", "Unknown 0x0092", "Unknown 0x0093", "Unknown 0x0094", "Unknown 0x0095", "Unknown 0x0096", "Unknown 0x0097", "Unknown 0x0098", "Unknown 0x0099", "Unknown 0x009A", "Unknown 0x009B", "Unknown 0x009C", "Unknown 0x009D", "Unknown 0x009E", "Unknown 0x009F",
	"Unknown 0x00A0", "Unknown 0x00A1", "Crash 0x00A2", "Crash 0x00A3", "Crash 0x00A4", "Crash 0x00A5", "Crash 0x00A6", "Crash 0x00A7", "Unknown 0x00A8", "Unknown 0x00A9", "Unknown 0x00AA", "Crash 0x00AB", "Crash 0x00AC",

	"SM - Grunty's Lair",
	"SM - Behind the waterfall",
	"SM - Spiral Mountain",

	"Crash 0x00B0", "Crash 0x00B1", "Unknown 0x00B2",	"Crash 0x00B3", "Unknown 0x00B4", "Crash 0x00B5", 

	"MT - Humba's wigwam",
	"MT - Mumbo's skull",
	"MT - Mayahem Temple",
	"MT - Prison Compound",

	"Unknown 0x00BA", "Unknown 0x00BB",

	"MT - Code chamber",

	"Crash 0x00BD", "Crash 0x00BE", "Unknown 0x00BF",
	"Crash 0x00C0", "Crash 0x00C1", "Crash 0x00C2", "Crash 0x00C3",

	"MT - Jade snake grove",
	"MT - Treasure chamber",
	"MT - Kickball arena",
	"0x00C7 - GGM",
	"MT - Kickball arena",
	"MT - Kickball arena",
	"0x00CA - GGM - Fuel depot",
	"0x00CB - GGM - Crushing shed",
	"0x00CC - GGM - Flooded caves",
	"0x00CD - GGM - Water storage",
	"0x00CE - GGM - Waterfall cavern",
	"0x00CF - GGM - Power hut basement",

	"GGM - Chuffy's cab",
	"GGM - Inside Chuffy's boiler",
	"GGM - Gloomy caverns",
	"GGM - Generator caverns",
	"GGM - Power hut",
	"GGM - Humba's wigwam",
	"WW - Witchy World",
	"GGM - Train station",
	"GGM - Prospectors hut",
	"GGM - Mumbo's skull",
	"GGM - Toxic gas cave",
	"GGM - Canary cave",
	"GGM - Ordnance storage",

	"WW - Dodgem dome lobby",
	"WW - Dodgem challenge 1 vs 1",
	"WW - Dodgem challenge 2 vs 1",
	"WW - Dodgem challenge 3 vs 1",
	"WW - Crazy castle stockade",
	"WW - Crazy castle lobby",
	"WW - Crazy castle pump room",
	"WW - Balloon burst game",
	"WW - Hoop hurry game",
	"WW - Star spinner",
	"WW - The inferno",

	"Crash 0x00E8",

	"GGM - Humba's wigwam",
	"WW - cave of horrors",
	"WW - haunted cavern",
	"WW - train station",
	"JRL - Jolly's",
	"JRL - Pawno's emporium",
	"JRL - Mumbo's skull",

	"Crash 0x00F0", "Unknown 0x00F1", "Unknown 0x00F2", "Crash 0x00F3",

	"JRL - Ancient Swimming Baths",

	"Crash 0x00F5",

	"JRL - Electric Eels lair",
	"JRL - Seaweed Sanctum",
	"JRL - Inside the big fish",
	"WW - Mr Patch",
	"JRL - temple of the fishes",

	"Crash 0x00FB",

	"JRL - Lord woo fak fak",

	"Crash 0x00FD", "Crash 0x00FE",

	"JRL - Blubber's wave race hire",

	"GI - Outside",
	"GI - Inside",
	"GI - Train station",
	"GI - Workers quarters",
	"GI - Trash compactor",
	"GI - Elevator shaft",
	"GI - Floor 2",
	"GI - Floor 2 (electromagnet chamber)",
	"GI - Floor 3",
	"GI - Floor 3 (boiler plant)",
	"GI - Floor 3 (packing room)",
	"GI - Floor 4",
	"GI - Floor 4 (cable room)",
	"GI - Floor 4 (quality control)",
	"GI - Floor 5",
	"GI - Basement",
	"GI - Basement (repair depot)",
	"GI - Basement (waste disposal)",

	"TL - Overworld",
	"TL - Terry's nest",
	"TL - train station",
	"TL - Oogle Boogles cave",
	"TL - Inside the mountain",
	"TL - River passage",
	"TL - Styracosaurus family cave",
	"TL - Unga Bunga's cave",
	"TL - Stomping plains",
	"TL - Bonfire caverns",

	"Crash 0x011C", "Crash 0x011D",

	"TL - Humba's Wigwam",
	"GI - Wide angle Humba's Wigwam",
	"JRL - Wide angle Humba's Wigwam",
	"GGM - Inside Chuffy's wagon",
	"0x0122 - ??? - Wide angle Humba's Wigwam",
	"TL - Inside Chompa's belly",
	"WW - Saucer of Peril",
	"GI - Water supply pipe",
	"GGM - Water supply pipe",

	"HP - Lava side",
	"HP - Icy side",
	"HP - Lava train station",
	"HP - Ice train station",
	"HP - Chilli Billi",
	"HP - Chilly Willy",
	"HP - colosseum kickball stadium lobby",
	"HP - colosseum kickball stadium - wide angle",
	"HP - colosseum kickball stadium - wide angle",
	"HP - colosseum kickball stadium - wide angle",
	"HP - Boggy's igloo",
	"HP - Icicle grotto",
	"HP - Inside the volcano",
	"HP - Mumbo's Skull",
	"HP - Humba's wigwam",

	"CCL - Cloud Cuckoo Land",
	"CCL - Inside the trashcan",
	"CCL - Inside the cheesewedge",
	"CCL - Zubba's nest",
	"CCL - central cavern",

	"WW - Crazy castle stockade (sop)",
	"WW - Star spinner (sop)",

	"CCL - Inside the pot'o'gold",
	"CCL - Mumbo's skull",
	"CCL - Mingy Jongo's skull",
	"CCL - Humba's wigwam",

	"0x0141 - Inside the digger tunnel (SM?)",

	"JV - Jinjo Village",
	"JV - Bottles house",
	"JV - King Jingalings throne room",
	"JV - Green Jinjo's house",
	"JV - Black Jinjo's house",
	"JV - Yellow Jinjo's house",
	"JV - Blue Jinjo's house",

	"Crash 0x0149",

	"JV - Brown Jinjo's house",
	"JV - Orange Jinjo's house",
	"JV - Purple Jinjo's house",
	"JV - Red Jinjo's house",
	"JV - White Jinjo's house",

	"WH - Wooded Hollow",
	"WH - Heggy's egg shed",
	"WH - Jiggywiggy's temple",

	"Plateau",
	"Plateau - Honey B's Hive",
	"Pine Grove",
	"Cliff top",
	"Cliff top - Mumbo's Skull",
	"Pine Grove - Humba's Wigwam",

	"Game select screen",
	"Opening cutscene",

	"Wasteland",
	"Inside another digger tunnel",
	"Quagmire",

	"CC - Cauldron Keep",
	"CC - The gatehouse",
	"CC - Tower of Tragedy",
	"CC - Gun chamber",

	"0x0161 - CCL",

	"GI - Floor 4 - Clinker's cavern",

	"GGM - Ordnance Storage entrance",
	"GGM - Ordnance Storage ",
	"GGM - Ordnance Storage (multiplayer)",

	"MT - (multiplayer)",
	"MT - (still)",
	"HP - Icy side (still)",
	"JV - Bottles' house (still)",
	"CC - Cauldron Keep - Gun room (still)",

	"Crash 0x016B", "Crash 0x016C", "Crash 0x016D", "Crash 0x016E",

	"GGM - Testing",
	"GGM - Testing",
	"GGM - Mumbo's skull",

	"GI - Mumbo's skull",

	"SM - Banjo's house",

	"Crash 0x0174", "Crash 0x0175",

	"WW - Mumbo's skull",

	"MT - Targitzan's slighty sacred temple",
	"MT - Inside Targitzan's temple",
	"MT - Targitzan's temple lobby",
	"MT - Targitzan's temple boss",

	"WW - Balloon burst (multiplayer)",
	"WW - Jump the hoops (multiplayer)",
	"GI - Packing game",
	"JV - Zombified throne room cutscene",
	"MT? - Mayan kickball arena",

	"Colosseum kickball arena",
	"JRL - Sea bottom cavern",
	"JRL - Submarine (multiplayer)",
	"TL - Chompa's belly (multiplayer)",

	"Crash 0x0184",

	"CCL - Trash can mini",
	"WW - Dodgems",
	"GI - sewer entrance",
	"CCL - Zubba's nest (multiplayer)",

	"Crash 0x0189",

	"0x018A - Inside HAG1",
	"0x018B - Intro screen",

	"Crash 0x018C",

	"0x018D - Jingaling zapped [Cutscene]",
	"0x018E - Meanwhile....Jingaling zapping [Cutscene]",
	"0x018F - B.O.B preparing to fire [cutscene]",
	"0x0190 - Jingaling getting zapped [cutscene]",
	"0x0191 - Sad Party at Bottles [cutscene]",
	"0x0192 - Bottles eating burnt food [cutscene]",
	"0x0193 - Bottle's energy restoring [cutscene]",
	"0x0194 - Banjo and Kazooie running into Gun Chamber [cutscene]",
	"0x0195 - Banjo and Kazooie at B.O.B's controls [cutscene]",
	"0x0196 - Kick about [cutscene]",
	"0x0197 - `I wonder what we'll hit...` Kazooie [cutscene]",
	"0x0198 - Jingaling restoring [cutscene]",
	"0x0199 - All Jinjos happy again [cutscene]",
	"0x019A - HAG1 - Final Boss",
	"0x019B - Jingaling's Zombified Palace",
	"0x019C - Roll the credits",
	"0x019D - End of credits",

	"Crash 0x019E", "Crash 0x019F",
	"Unknown 0x01A0", "Unknown 0x01A1", "Unknown 0x01A2", "Unknown 0x01A3", "Unknown 0x01A4", "Unknown 0x01A5",

	"JRL - Smuggler cavern",
	"JRL",
	"JRL - Atlantis",
	"JRL - Seabottom",

	"Crash 0x01AA", "Unknown 0x01AB", "Crash 0x01AC", "Crash 0x01AD"
};

--------------------
-- Region/Version --
--------------------

local linked_list_root;
local map;
local map_trigger;

function Game.detectVersion(romName)
	if bizstring.contains(romName, "Australia") then
		linked_list_root = 0x13C380;
		map = 0x127640; -- TODO
		map_trigger = 0x127642; -- TODO
	elseif bizstring.contains(romName, "Europe") then
		linked_list_root = 0x13C680;
		map = 0x127640; -- TODO
		map_trigger = 0x127642; -- TODO
	elseif bizstring.contains(romName, "Japan") then
		linked_list_root = 0x131850;
		map = 0x127640; -- TODO
		map_trigger = 0x127642; -- TODO
	elseif bizstring.contains(romName, "USA") then
		linked_list_root = 0x137800;
		map = 0x127640;
		map_trigger = 0x127642;
	else
		return false;
	end

	return true;
end

local function find_root(object)
	while object > 0 do
		console.log(bizstring.hex(object));
		object = mainmemory.read_u24_be(object + 1);
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
	return not emu.islagged();
end

--------------------------
-- Position object shit --
--------------------------

-- Update this each frame
local BK_Object_Base = 0x00;

local x_pos = 0x00;
local y_pos = 0x04;
local z_pos = 0x08;

local facing_angle = 0xd8;

----------------------
-- Linked List shit --
----------------------

local function is_pointer(number)
	return number >= 0x80000000 and number <= 0x803FFFFF;
end

-- Relative to object base
local previous_item = 0x00;
local next_item = 0x04;
local bk_pos_pointer = 61 * 4;

local function get_bk_address()
	local BK_Found = false;
	local bk_pointer, i;

	-- Get first object in linked list
	local object_base = mainmemory.read_u24_be(linked_list_root + next_item + 1);

	-- Iterate through linked list looking for pointer list, including pointer to BK Position
	while not BK_Found and object_base > 0 do
		-- Check if current linked list object has a pointer in the correct spot
		bk_pointer = mainmemory.read_u32_be(object_base + bk_pos_pointer);
		if is_pointer(bk_pointer) then
			BK_Found = true;

			-- Check for pointers near BK pointer to make sure
			for i=0,27 do
				if not is_pointer(mainmemory.read_u32_be(object_base + bk_pos_pointer + (i * 4))) then
					BK_Found = false;
				end
			end
		end

		-- Get next object in linked list
		object_base = mainmemory.read_u24_be(object_base + next_item + 1);
	end

	if BK_Found then
		return bk_pointer - 0x80000000;
	end
end

--------------
-- Position --
--------------

function Game.getXPosition()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + x_pos, true);
	end
	return 0;
end

function Game.getYPosition()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + y_pos, true);
	end
	return 0;
end

function Game.getZPosition()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + z_pos, true);
	end
	return 0;
end

function Game.setXPosition(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + x_pos, value, true);
	end
end

function Game.setYPosition(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + y_pos, value, true);
	end
end

function Game.setZPosition(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + z_pos, value, true);
	end
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + facing_angle, true);
	end
	return 0;
end

function Game.getYRotation()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + facing_angle, true);
	end
	return 0;
end

function Game.getZRotation()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + facing_angle, true);
	end
	return 0;
end

function Game.setXRotation(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + facing_angle, value, true);
	end
end

function Game.setYRotation(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + facing_angle, value, true);
	end
end

function Game.setZRotation(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + facing_angle, value, true);
	end
end

------------
-- Events --
------------

function Game.setMap(value)
	local trigger_value = mainmemory.read_u16_be(map_trigger);
	if trigger_value == 0 then
		console.log("Travelling to "..value);
		mainmemory.write_u16_be(map, value);
		mainmemory.write_u16_be(map_trigger, 0x0101);
	end
end

function Game.applyInfinites()
	-- TODO
end

function Game.initUI(form_handle, col, row, button_height, label_offset, dropdown_offset)
	-- TODO
end

function Game.eachFrame()
	BK_object_base = get_bk_address();
end

return Game;