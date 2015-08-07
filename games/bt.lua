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
	"Unknown 0x00A0", "Unknown 0x00A1", "FREEZE 0x00A2", "FREEZE 0x00A3", "FREEZE 0x00A4", "FREEZE 0x00A5", "FREEZE 0x00A6", "FREEZE 0x00A7", "Unknown 0x00A8", "Unknown 0x00A9", "Unknown 0x00AA", "FREEZE 0x00AB", "FREEZE 0x00AC",

	"0x00AD - Grunty's Lair",
	"0x00AE - SM - behind the waterfall",
	"0x00AF - Spiral Mountain",

	"FREEZE 0x00B0", "FREEZE 0x00B1", "Unknown 0x00B2",	"FREEZE 0x00B3", "Unknown 0x00B4", "FREEZE 0x00B5", 

	"0x00B6 - MT - Humba's wigwam",
	"0x00B7 - MT - Mumbo's skull",
	"0x00B8 - Mayahem Temple",
	"0x00B9 - MT - Prison Compound",

	"Unknown 0x00BA", "Unknown 0x00BB",

	"0x00BC - MT - Code chamber",

	"FREEZE 0x00BD", "FREEZE 0x00BE", "Unknown 0x00BF",
	"FREEZE 0x00C0", "FREEZE 0x00C1", "FREEZE 0x00C2", "FREEZE 0x00C3",

	"0x00C4 - MT - Jade snake grove",
	"0x00C5 - MT - Treasure chamber",
	"0x00C6 - MT - Kickball arena",
	"0x00C7 - GGM",
	"0x00C8 - MT - Kickball arena",
	"0x00C9 - MT - Kickball arena",
	"0x00CA - GGM - Fuel depot",
	"0x00CB - GGM - Crushing shed",
	"0x00CC - GGM - Flooded caves",
	"0x00CD - GGM - Water storage",
	"0x00CE - GGM - Waterfall cavern",
	"0x00CF - GGM - Power hut basement",

	"0x00D0 - GGM - Chuffy's cab",
	"0x00D1 - GGM - Inside Chuffy's boiler",
	"0x00D2 - GGM - Gloomy caverns",
	"0x00D3 - GGM - Generator caverns",
	"0x00D4 - GGM - Power hut",
	"0x00D5 - GGM - Humba's wigwam",
	"0x00D6 - Witchy World",
	"0x00D7 - GGM - Train station",
	"0x00D8 - GGM - Prospectors hut",
	"0x00D9 - GGM - Mumbo's skull",
	"0x00DA - GGM - Toxic gas cave",
	"0x00DB - GGM - Canary cave",
	"0x00DC - GGM - Ordnance storage",
	"0x00DD - WW - Dodgem dome lobby",
	"0x00DE - WW - Dodgem challenge 1 vs 1",
	"0x00DF - WW - Dodgem challenge 2 vs 1",

	"0x00E0 - WW - Dodgem challenge 3 vs 1",
	"0x00E1 - WW - Crazy castle stockade",
	"0x00E2 - WW - Crazy castle lobby",
	"0x00E3 - WW - Crazy castle pump room",
	"0x00E4 - WW - Balloon burst game",
	"0x00E5 - WW - Hoop hurry game",
	"0x00E6 - WW - Star spinner",
	"0x00E7 - WW - The inferno",

	"FREEZE 0x00E8",

	"0x00E9 - GGM - humba",
	"0x00EA - WW - cave of horrors",
	"0x00EB - WW - haunted cavern",
	"0x00EC - WW - train station",
	"0x00ED - JRL - Jolly's",
	"0x00EE - JRL - Pawno's emporium",
	"0x00EF - JRL - Mumbo's skull",

	"FREEZE 0x00F0", "Unknown 0x00F1", "Unknown 0x00F2", "FREEZE 0x00F3",

	"0x00F4 - JRL - Ancient Swimming Baths",

	"FREEZE 0x00F5",

	"0x00F6 - JRL - Electric Eels lair",
	"0x00F7 - JRL - Seaweed Sanctum",
	"0x00F8 - JRL - Inside the big fish",
	"0x00F9 - Mr Patch",
	"0x00FA - JRL - temple of the fishes",

	"FREEZE 0x00FB",

	"0x00FC - Lord woo fak fak",

	"FREEZE 0x00FD", "FREEZE 0x00FE",

	"0x00FF - JRL - Blubber's wave race hire",
	"0x0100 - GI - Outside",
	"0x0101 - GI - Inside",
	"0x0102 - GI - Train station",
	"0x0103 - GI - Workers quarters",
	"0x0104 - GI - Trash compactor",
	"0x0105 - GI - Elevator shaft",
	"0x0106 - GI - Floor 2",
	"0x0107 - GI - Floor 2 (electromagnet chamber)",
	"0x0108 - GI - Floor 3",
	"0x0109 - GI - Floor 3 (boiler plant)",
	"0x010A - GI - Floor 3 (packing room)",
	"0x010B - GI - Floor 4",
	"0x010C - GI - Floor 4 (cable room)",
	"0x010D - GI - Floor 4 (quality control)",
	"0x010E - GI - Floor 5",
	"0x010F - GI - Basement",

	"0x0110 - GI - Basement (repair depot)",
	"0x0111 - GI - Basement (waste disposal)",
	"0x0112 - TL",
	"0x0113 - TL - Terry's nest",
	"0x0114 - TL - train station",
	"0x0115 - TL - Oogle Boogles cave",
	"0x0116 - TL - Inside the mountain",
	"0x0117 - TL - River passage",
	"0x0118 - TL - Styracosaurus family cave",
	"0x0119 - TL - Unga Bunga's cave",
	"0x011A - TL - Stomping plains",
	"0x011B - TL - Bonfire caverns",

	"FREEZE 0x011C", "FREEZE 0x011D",

	"0x011E - TL - Humba's Wigwam",
	"0x011F - ??? - Wide angle Humba's Wigwam",

	"0x0120 - JRL - Wide angle Humba's Wigwam",
	"0x0121 - Inside Chuffy's wagon",
	"0x0122 - ??? - Wide angle Humba's Wigwam",
	"0x0123 - TL - Inside chompa's belly",
	"0x0124 - WW - Saucer of Peril",
	"0x0125 - GI - water supply pipe",
	"0x0126 - GGM - water supply pipe",
	"0x0127 - HP - Lava side",
	"0x0128 - HP - Icy side",
	"0x0129 - HP - lava train station",
	"0x012A - HP - ice train station",
	"0x012B - HP - Chilli Billi",
	"0x012C - HP - Chilly Willy",
	"0x012D - HP - colosseum kickball stadium lobby",
	"0x012E - HP - colosseum kickball stadium - wide angle",
	"0x012F - HP - colosseum kickball stadium - wide angle",

	"0x0130 - HP - colosseum kickball stadium - wide angle",
	"0x0131 - HP - Boggy's igloo",
	"0x0132 - HP - Icicle grotto",
	"0x0133 - HP - Inside the volcano",
	"0x0134 - ??? - Mumbo's Skull",
	"0x0135 - ??? - humba's wigwam",
	"0x0136 - CCL",
	"0x0137 - CCL - inside the trashcan",
	"0x0138 - CCL - inside the cheesewedge",
	"0x0139 - CCL - Zubba's nest",
	"0x013A - CCL - central cavern",
	"0x013B - WW - crazy castle stockade (sop)",
	"0x013C - WW - star spinner (sop)",
	"0x013D - CCL - Inside the pot'o'gold",
	"0x013E - CCL - Mumbo's skull",
	"0x013F - CCL - Mingy Jongo's skull",

	"0x0140 - CCL - Humba's wigwam",
	"0x0141 - Inside the digger tunnel",
	"0x0142 - Jinjo Village - Isle O Hags",
	"0x0143 - Bottles house",
	"0x0144 - JV - King Jingalings throne room",
	"0x0145 - JV - green jinjo's house",
	"0x0146 - JV - black jinjo's house",
	"0x0147 - JV - yellow jinjo's house",
	"0x0148 - JV - blue jinjo's house",

	"FREEZE 0x0149",

	"0x014A - JV - brown jinjo's house",
	"0x014B - JV - orange jinjo's house",
	"0x014C - JV - purple jinjo's house",
	"0x014D - JV - red jinjo's house",
	"0x014E - JV - white jinjo's house",
	"0x014F - Wooded Hollow - Isle'o'hags",

	"0x0150 - WH - Heggy's egg shed",
	"0x0151 - WH - Jiggywiggy's temple",
	"0x0152 - Plateau - Isle'o'hags",
	"0x0153 - Plateau - Honey B's Hive",
	"0x0154 - Pine Grove - Isle o hags",
	"0x0155 - Cliff top - Isle o hags",
	"0x0156 - Cliff top - Mumbo's skull",
	"0x0157 - ??? - Humba Wumba's wigwam",
	"0x0158 - Game select screen",
	"0x0159 - Opening cut scene",
	"0x015A - wasteland - isle o hags",
	"0x015B - inside another digger tunnel",
	"0x015C - Quagmire - Isle'o'hags",
	"0x015D - Cauldron Keep",
	"0x015E - Cauldron Keep - The gatehouse",
	"0x015F - Tower of Tragedy",

	"0x0160 - Cauldron Keep - Gun chamber",
	"0x0161 - CCL",
	"0x0162 - GI - Floor 4 - Clinker's cavern",
	"0x0163 - GGM - Ordnance Storage entrance",
	"0x0164 - GGM - Ordnance Storage game",
	"0x0165 - GGM - Ordnance Storage game Multi",
	"0x0166 - MT - Multi",
	"0x0167 - MT - still",
	"0x0168 - HP - Icy side still",
	"0x0169 - Bottles house still",
	"0x016A - Cauldron Keep - Gun room still",

	"FREEZE 0x016B", "FREEZE 0x016C", "FREEZE 0x016D", "FREEZE 0x016E",

	"0x016F - GGM - Testing",
	"0x0170 - GGM - Testing",
	"0x0171 - GGM - Mumbo's skull",
	"0x0172 - GI - Mumbo's skull",
	"0x0173 - SM - Banjo's house",

	"FREEZE 0x0174", "FREEZE 0x0175",

	"0x0176 - WW - Mumbo's skull",
	"0x0177 - MT - Targitzan's slighty sacred temple",
	"0x0178 - MT - Inside targitzans temple",
	"0x0179 - MT - Targitzan temple lobby",
	"0x017A - MT - Targitzan's temple boss",
	"0x017B - Balloon burst (multiplayer)",
	"0x017C - Jump the hoops (multiplayer)",
	"0x017D - Grunty Industries packing game",
	"0x017E - Zombified throne room cutscene",
	"0x017F - Mayan kickball arena",

	"0x0180 - Colosseum kickball arena",
	"0x0181 - JRL - sea bottom cavern",
	"0x0182 - JRL - submarine multi",
	"0x0183 - TL - Chompa's belly (multiplayer)",

	"FREEZE 0x0184",

	"0x0185 - CCL - Trash can mini",
	"0x0186 - Dodgems",
	"0x0187 - GI - sewer entrance",
	"0x0188 - CCL - Zubba's nest multi",

	"FREEZE 0x0189",

	"0x018A - Inside HAG1",
	"0x018B - Intro screen",

	"FREEZE 0x018C",

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

	"FREEZE 0x019E", "FREEZE 0x019F",
	"Unknown 0x01A0", "Unknown 0x01A1", "Unknown 0x01A2", "Unknown 0x01A3", "Unknown 0x01A4", "Unknown 0x01A5",

	"0x01A6 - Smuggler cavern",
	"0x01A7 - JRL",
	"0x01A8 - JRL - Atlantis",
	"0x01A9 - JRL - Seabottom",

	"FREEZE 0x01AA", "Unknown 0x01AB", "FREEZE 0x01AC", "FREEZE 0x01AD"
};

--------------------
-- Region/Version --
--------------------

local linked_list_root;
local map;
local map_trigger;

function Game.detectVersion(romName)
	if bizstring.contains(romName, "Europe") then
		-- TODO
		return false;
	elseif bizstring.contains(romName, "Japan") then
		-- TODO
		return false;
	elseif bizstring.contains(romName, "USA") then
		linked_list_root = 0x137800;
		map = 0x127640;
		map_trigger = 0x127642;
	else
		return false;
	end

	return true;
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