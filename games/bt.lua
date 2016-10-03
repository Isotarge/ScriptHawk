local Game = {};

Game.maps = {
	"!Unknown 0x0001", "!Unknown 0x0002", "!Unknown 0x0003", "!Unknown 0x0004", "!Unknown 0x0005", "!Unknown 0x0006", "!Unknown 0x0007", "!Unknown 0x0008", "!Unknown 0x0009", "!Unknown 0x000A", "!Unknown 0x000B", "!Unknown 0x000C", "!Unknown 0x000D", "!Unknown 0x000E", "!Unknown 0x000F",
	"!Unknown 0x0010", "!Unknown 0x0011", "!Unknown 0x0012", "!Unknown 0x0013", "!Unknown 0x0014", "!Unknown 0x0015", "!Unknown 0x0016", "!Unknown 0x0017", "!Unknown 0x0018", "!Unknown 0x0019", "!Unknown 0x001A", "!Unknown 0x001B", "!Unknown 0x001C", "!Unknown 0x001D", "!Unknown 0x001E", "!Unknown 0x001F",
	"!Unknown 0x0020", "!Unknown 0x0021", "!Unknown 0x0022", "!Unknown 0x0023", "!Unknown 0x0024", "!Unknown 0x0025", "!Unknown 0x0026", "!Unknown 0x0027", "!Unknown 0x0028", "!Unknown 0x0029", "!Unknown 0x002A", "!Unknown 0x002B", "!Unknown 0x002C", "!Unknown 0x002D", "!Unknown 0x002E", "!Unknown 0x002F",
	"!Unknown 0x0030", "!Unknown 0x0031", "!Unknown 0x0032", "!Unknown 0x0033", "!Unknown 0x0034", "!Unknown 0x0035", "!Unknown 0x0036", "!Unknown 0x0037", "!Unknown 0x0038", "!Unknown 0x0039", "!Unknown 0x003A", "!Unknown 0x003B", "!Unknown 0x003C", "!Unknown 0x003D", "!Unknown 0x003E", "!Unknown 0x003F",
	"!Unknown 0x0040", "!Unknown 0x0041", "!Unknown 0x0042", "!Unknown 0x0043", "!Unknown 0x0044", "!Unknown 0x0045", "!Unknown 0x0046", "!Unknown 0x0047", "!Unknown 0x0048", "!Unknown 0x0049", "!Unknown 0x004A", "!Unknown 0x004B", "!Unknown 0x004C", "!Unknown 0x004D", "!Unknown 0x004E", "!Unknown 0x004F",
	"!Unknown 0x0050", "!Unknown 0x0051", "!Unknown 0x0052", "!Unknown 0x0053", "!Unknown 0x0054", "!Unknown 0x0055", "!Unknown 0x0056", "!Unknown 0x0057", "!Unknown 0x0058", "!Unknown 0x0059", "!Unknown 0x005A", "!Unknown 0x005B", "!Unknown 0x005C", "!Unknown 0x005D", "!Unknown 0x005E", "!Unknown 0x005F",
	"!Unknown 0x0060", "!Unknown 0x0061", "!Unknown 0x0062", "!Unknown 0x0063", "!Unknown 0x0064", "!Unknown 0x0065", "!Unknown 0x0066", "!Unknown 0x0067", "!Unknown 0x0068", "!Unknown 0x0069", "!Unknown 0x006A", "!Unknown 0x006B", "!Unknown 0x006C", "!Unknown 0x006D", "!Unknown 0x006E", "!Unknown 0x006F",
	"!Unknown 0x0070", "!Unknown 0x0071", "!Unknown 0x0072", "!Unknown 0x0073", "!Unknown 0x0074", "!Unknown 0x0075", "!Unknown 0x0076", "!Unknown 0x0077", "!Unknown 0x0078", "!Unknown 0x0079", "!Unknown 0x007A", "!Unknown 0x007B", "!Unknown 0x007C", "!Unknown 0x007D", "!Unknown 0x007E", "!Unknown 0x007F",
	"!Unknown 0x0080", "!Unknown 0x0081", "!Unknown 0x0082", "!Unknown 0x0083", "!Unknown 0x0084", "!Unknown 0x0085", "!Unknown 0x0086", "!Unknown 0x0087", "!Unknown 0x0088", "!Unknown 0x0089", "!Unknown 0x008A", "!Unknown 0x008B", "!Unknown 0x008C", "!Unknown 0x008D", "!Unknown 0x008E", "!Unknown 0x008F",
	"!Unknown 0x0090", "!Unknown 0x0091", "!Unknown 0x0092", "!Unknown 0x0093", "!Unknown 0x0094", "!Unknown 0x0095", "!Unknown 0x0096", "!Unknown 0x0097", "!Unknown 0x0098", "!Unknown 0x0099", "!Unknown 0x009A", "!Unknown 0x009B", "!Unknown 0x009C", "!Unknown 0x009D", "!Unknown 0x009E", "!Unknown 0x009F",
	"!Unknown 0x00A0", "!Unknown 0x00A1", "!Crash 0x00A2", "!Crash 0x00A3", "!Crash 0x00A4", "!Crash 0x00A5", "!Crash 0x00A6", "!Crash 0x00A7", "!Unknown 0x00A8", "!Unknown 0x00A9", "!Unknown 0x00AA", "!Crash 0x00AB", "!Crash 0x00AC",

	"SM - Grunty's Lair",
	"SM - Behind the waterfall",
	"SM - Spiral Mountain",

	"!Crash 0x00B0", "!Crash 0x00B1", "!Unknown 0x00B2", "!Crash 0x00B3", "!Unknown 0x00B4", "!Crash 0x00B5",

	"MT - Wumba's Wigwam",
	"MT - Mumbo's Skull",
	"MT",
	"MT - Prison Compound",

	"!Unknown 0x00BA", "!Unknown 0x00BB",

	"MT - Code Chamber",

	"!Crash 0x00BD", "!Crash 0x00BE", "!Unknown 0x00BF",
	"!Crash 0x00C0", "!Crash 0x00C1", "!Crash 0x00C2", "!Crash 0x00C3",

	"MT - Jade Snake Grove",
	"MT - Treasure Chamber",
	"MT - Kickball Arena 1",
	"GGM",
	"MT - Kickball Arena 2",
	"MT - Kickball Arena 3",
	"GGM - Fuel Depot",
	"GGM - Crushing Shed",
	"GGM - Flooded Caves",
	"GGM - Water Storage",
	"GGM - Waterfall Cavern",
	"GGM - Power Hut Basement",
	"GGM - Chuffy's Cab",
	"GGM - Inside Chuffy's Boiler",
	"GGM - Gloomy Caverns",
	"GGM - Generator Cavern",
	"GGM - Power Hut",
	"WW - Wumba's Wigwam",
	"WW",
	"GGM - Train Station",
	"GGM - Prospector's Hut",
	"GGM - Mumbo's Skull",
	"GGM - Toxic Gas Cave",
	"GGM - Canary Cave",
	"GGM - Ordnance storage",
	"WW - Dodgem Dome Lobby",
	"WW - Dodgem Challenge 1 vs 1",
	"WW - Dodgem Challenge 2 vs 1",
	"WW - Dodgem Challenge 3 vs 1",
	"WW - Crazy Castle Stockade",
	"WW - Crazy Castle Lobby",
	"WW - Crazy Castle Pump Room",
	"WW - Balloon Burst Game",
	"WW - Hoop Hurry",
	"WW - Star Spinner",
	"WW - The Inferno",

	"!Crash 0x00E8",

	"GGM - Wumba's Wigwam",
	"WW - Cave of Horrors",
	"WW - Haunted Cavern",
	"WW - Train Station",
	"JRL - Jolly's",
	"JRL - Pawno's Emporium",
	"JRL - Mumbo's Skull",

	"!Crash 0x00F0",

	"HP - Inside the UFO",

	"!Unknown 0x00F2", "!Crash 0x00F3",

	"JRL - Ancient Swimming Baths",

	"!Crash 0x00F5",

	"JRL - Electric Eel's lair",
	"JRL - Seaweed Sanctum",
	"JRL - Inside the Big Fish",
	"WW - Mr. Patch",
	"JRL - Temple of the Fishes",

	"!Crash 0x00FB",

	"JRL - Lord Woo Fak Fak",

	"!Crash 0x00FD", "!Crash 0x00FE",

	"JRL - Blubber's Wave Race Hire",
	"GI",
	"GI - Floor 1",
	"GI - Train Station",
	"GI - Workers Quarters",
	"GI - Trash Compactor",
	"GI - Elevator shaft",
	"GI - Floor 2",
	"GI - Floor 2 (Electromagnet Chamber)",
	"GI - Floor 3",
	"GI - Floor 3 (Boiler Plant)",
	"GI - Floor 3 (Packing Room)",
	"GI - Floor 4",
	"GI - Floor 4 (Cable Room)",
	"GI - Floor 4 (Quality Control)",
	"GI - Floor 5",
	"GI - Basement",
	"GI - Basement (Repair Depot)",
	"GI - Basement (Waste Disposal)",
	"TDL",
	"TDL - Terry's Nest",
	"TDL - Train Station",
	"TDL - Oogle Boogles cave",
	"TDL - Inside the mountain",
	"TDL - River Passage",
	"TDL - Styracosaurus Family Cave",
	"TDL - Unga Bunga's Cave",
	"TDL - Stomping Plains",
	"TDL - Bonfire Cavern",

	"!Crash 0x011C", "!Crash 0x011D",

	"TDL - Wumba's Wigwam (Small)",
	"GI - Wumba's Wigwam",
	"JRL - Wumba's Wigwam",
	"GGM - Inside Chuffy's Wagon",
	"TDL - Wumba's Wigwam (Big)",
	"TDL - Inside Chompa's Belly",
	"WW - Saucer of Peril",
	"GI - Water Supply Pipe",
	"GGM - Water Supply Pipe",
	"HP - Lava Side",
	"HP - Icy Side",
	"HP - Lava Train Station",
	"HP - Ice Train Station",
	"HP - Chilli Billi",
	"HP - Chilly Willy",
	"HP - Kickball Stadium lobby",
	"HP - Kickball Stadium 1",
	"HP - Kickball Stadium 2",
	"HP - Kickball Stadium 3",
	"HP - Boggy's Igloo",
	"HP - Icicle Grotto",
	"HP - Inside the Volcano",
	"HP - Mumbo's Skull",
	"HP - Wumba's Wigwam",
	"CCL",
	"CCL - Inside the Trash Can",
	"CCL - Inside the Cheese Wedge",
	"CCL - Zubba's Nest",
	"CCL - Central Cavern",
	"WW - Crazy Castle Stockade (Saucer)",
	"WW - Star Spinner (Saucer)",
	"CCL - Inside the Pot o' Gold",
	"CCL - Mumbo's Skull",
	"CCL - Mingy Jongo's Skull",
	"CCL - Wumba's Wigwam",
	"SM - Inside the Digger Tunnel",
	"JV",
	"JV - Bottles' House",
	"JV - King Jingaling's Throne Room",
	"JV - Green Jinjo's house",
	"JV - Black Jinjo's house",
	"JV - Yellow Jinjo's house",
	"JV - Blue Jinjo's house",

	"!Crash 0x0149",

	"JV - Brown Jinjo's house",
	"JV - Orange Jinjo's house",
	"JV - Purple Jinjo's house",
	"JV - Red Jinjo's house",
	"JV - White Jinjo's house",
	"IoH - Wooded Hollow",
	"IoH - Heggy's Egg Shed",
	"IoH - Jiggywiggy's Temple",
	"IoH - Plateau",
	"IoH - Plateau - Honey B's Hive",
	"IoH - Pine Grove",
	"IoH - Clifftop",
	"IoH - Clifftop - Mumbo's Skull",
	"IoH - Pine Grove - Wumba's Wigwam",
	"Game Select Screen",
	"Cutscene - Opening cutscene",
	"IoH - Wasteland",
	"IoH - Inside another digger tunnel",
	"IoH - Quagmire",
	"CK",
	"CK - The Gatehouse",
	"CK - Tower of Tragedy",
	"CK - Gun Chamber",
	"CCL - Canary Mary Race?",
	"GI - Floor 4 - Clinker's cavern",
	"GGM - Ordnance Storage Entrance",
	"GGM - Ordnance Storage ",
	"GGM - Ordnance Storage (multiplayer)",
	"MT - Targitzan's Temple (multiplayer)",
	"MT - (still)",
	"HP - Icy Side (still)",
	"JV - Bottles' House (still)",
	"CK - Gun Room (still)",

	"!Crash 0x016B", "!Crash 0x016C", "!Crash 0x016D", "!Crash 0x016E",

	"GGM - Testing 1",
	"GGM - Testing 2",
	"TDL - Mumbo's Skull",
	"GI - Mumbo's Skull",
	"SM - Banjo's House",

	"!Crash 0x0174", "!Crash 0x0175",

	"WW - Mumbo's Skull",
	"MT - Targitzan's Slighty Sacred Chamber",
	"MT - Inside Targitzan's Temple",
	"MT - Targitzan's Temple Lobby",
	"MT - Targitzan's Really Sacred Chamber",
	"WW - Balloon burst (multiplayer)",
	"WW - Jump the Hoops (multiplayer)",
	"GI - Packing Game",
	"Cutscene - Zombified Throne Room",
	"MT - Kickball Arena 4",
	"HP - Kickball Arena",
	"JRL - Sea Bottom Cavern",
	"JRL - Submarine (multiplayer)",
	"TDL - Chompa's Belly (multiplayer)",

	"!Crash 0x0184",

	"CCL - Trash Can Mini",
	"WW - Dodgems",
	"GI - Sewer Entrance",
	"CCL - Zubba's Nest (multiplayer)",

	"!Crash 0x0189",

	"CK - Inside HAG 1",
	"Intro Screen",

	"!Crash 0x018C",

	"Cutscene - Jingaling Zapped",
	"Cutscene - Meanwhile.... Jingaling Zapping",
	"Cutscene - B.O.B preparing to fire",
	"Cutscene - Jingaling Getting Zapped",
	"Cutscene - Sad Party at Bottles'",
	"Cutscene - Bottles Eating Burnt Food",
	"Cutscene - Bottles' energy restoring",
	"Cutscene - Banjo and Kazooie Running Into Gun Chamber",
	"Cutscene - Banjo and Kazooie at B.O.B's controls",
	"Cutscene - Kick About",
	"Cutscene - `I wonder what we'll hit...` Kazooie",
	"Cutscene - Jingaling Restoring",
	"Cutscene - All Jinjos Happy Again",

	"CK - HAG 1",
	"JV - Jingaling's Zombified Palace",

	"Cutscene - Roll the credits",
	"Cutscene - End of credits",

	"!Crash 0x019E", "!Crash 0x019F", "!Unknown 0x01A0", "!Unknown 0x01A1", "!Unknown 0x01A2", "!Unknown 0x01A3", "!Unknown 0x01A4", "!Unknown 0x01A5",

	"JRL - Smuggler's cavern",
	"JRL",
	"JRL - Atlantis",
	"JRL - Seabottom",
};

--------------------
-- Region/Version --
--------------------

-- Version order: Australia, Europe, Japan, USA
Game.Memory = {
	["player_pointer"] = {0x13A210, 0x13A4A0, 0x12F660, 0x135490},
	["player_pointer_index"] = {0x13A25F, 0x13A4EF, 0x12F6AF, 0x1354DF},
	["moves_pointer"] = {0x1314F0, 0x131780, 0x126940, 0x12C770},
	["air"] = {0x12FDC0, 0x12FFD0, 0x125220, 0x12B050},
	["frame_timer"] = {0x083550, 0x083550, 0x0788F8, 0x079138},
	["linked_list_root"] = {0x13C380, 0x13C680, 0x131850, 0x137800},
	["map"] = {0x12C390, 0x12C5A0, 0x1217F0, 0x127640},
	["map_trigger"] = {0x12C392, 0x12C5A2, 0x1217F2, 0x127642},
	["iconAddress"] = {0x11FF95, 0x120155, 0x115325, 0x11B065},
	["healthAddresses"] = {
		[0x01] = {0x120584, 0x120794, 0x115A04, 0x11B644}, -- BK
		[0x10] = {0x12059F, 0x1207AF, 0x115A1F, 0x11B65F}, -- Banjo (Solo)
		[0x11] = {0x1205A8, 0x1207B8, 0x115A28, 0x11B668}, -- Mumbo
		[0x2E] = {0x1205AE, 0x1207BE, 0x115A19, 0x11B66E}, -- Detonator
		[0x2F] = {0x1205A5, 0x1207B5, 0x115A25, 0x11B665}, -- Submarine
		[0x30] = {0x1205B7, 0x1207C7, 0x115A37, 0x11B677}, -- T-Rex
		[0x31] = {0x120593, 0x1207A3, 0x115A13, 0x11B653}, -- Bee
		[0x32] = {0x120587, 0x120797, 0x115A07, 0x11B647}, -- Snowball
		[0x36] = {0x120596, 0x1207A6, 0x115A16, 0x11B656}, -- Washing Machine
		[0x5F] = {0x1205A2, 0x1207B2, 0x115A22, 0x11B662}, -- Kazooie (Solo)
	},
};

function Game.detectVersion(romName, romHash)
	if romHash == "4CA2D332F6E6B018777AFC6A8B7880B38B6DFB79" then -- Australia
		version = 1;
	elseif romHash == "93BF2FAC1387320AD07251CB4B64FD36BAC1D7A6" then -- Europe
		version = 2;
	elseif romHash == "5A5172383037D171F121790959962703BE1F373C" then -- Japan
		version = 3;
	elseif romHash == "AF1A89E12B638B8D82CC4C085C8E01D4CBA03FB3" then -- USA
		version = 4;
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
	local frameTimerValue = mainmemory.read_s32_be(Game.Memory.frame_timer[version]);
	return frameTimerValue <= 0 and not emu.islagged();
end

-------------------
-- Player object --
-------------------

-- Relative to objects in linked list, including player
local previous_item = 0x00;
local next_item = 0x04;

local slope_pointer_index = 40 * 4;
local velocity_pointer_index = 50 * 4;
local rot_x_pointer_index = 55 * 4;
local position_pointer_index = 57 * 4;
local rot_z_pointer_index = 61 * 4;
local rot_y_pointer_index = 62 * 4;
local movement_state_pointer_index = 72 * 4;

-- Relative to Position object
local x_pos = 0x00;
local y_pos = x_pos + 4;
local z_pos = y_pos + 4;

-- Relative to Rot X object
local x_rot_current = 0x00;
local x_rot_target = x_rot_current + 4;

-- Relative to Rot Y object
local facing_angle = 0x00;
local moving_angle = facing_angle + 4;
local y_rot_current = facing_angle;
local y_rot_target = moving_angle;

-- Relative to Rot Z object
local z_rot_current = 0x00;
local z_rot_target = z_rot_current + 4;

-- Relative to Slope object
local slope_timer = 0x38;

-- Relative to Velocity object
local x_velocity = 0x10;
local y_velocity = 0x14;
local z_velocity = 0x18;

function Game.getPlayerObject()
	local playerPointerIndex = mainmemory.readbyte(Game.Memory.player_pointer_index[version]);
	local playerObject = dereferencePointer(Game.Memory.player_pointer[version] + 4 * playerPointerIndex);
	if isRDRAM(playerObject) then
		return playerObject;
	end
end

function Game.getPlayerSubObject(index)
	local player = Game.getPlayerObject();
	if isRDRAM(player) then
		return dereferencePointer(player + index);
	end
end

function output_objects()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		dprint("Player: "..toHexString(playerObject, nil, ""));
		dprint("Position: "..toHexString(dereferencePointer(playerObject + position_pointer_index), nil, ""));
		dprint("Rot X: "..toHexString(dereferencePointer(playerObject + rot_x_pointer_index), nil, ""));
		dprint("Rot Y: "..toHexString(dereferencePointer(playerObject + rot_y_pointer_index), nil, ""));
		dprint("Rot Z: "..toHexString(dereferencePointer(playerObject + rot_z_pointer_index), nil, ""));
		dprint("Slope: "..toHexString(dereferencePointer(playerObject + slope_pointer_index), nil, ""));
		dprint("Velocity: "..toHexString(dereferencePointer(playerObject + velocity_pointer_index), nil, ""));
		dprint("Movement State: "..toHexString(dereferencePointer(playerObject + movement_state_pointer_index), nil, ""));
		print_deferred();
	else
		print("Can't get a read...");
	end
end

----------------
-- Jinjo Dump --
----------------

JinjoAddresses = {
	{{0x11FA71, 0x11FC31, 0x114E01, 0x11AB41}, "MT: Jade Snake Grove"},
	{{0x11FA74, 0x11FC34, 0x114E04, 0x11AB44}, "MT: Roof of Stadium"},
	{{0x11FA77, 0x11FC37, 0x114E07, 0x11AB47}, "MT: Targitzan's Temple"},
	{{0x11FA7A, 0x11FC3A, 0x114E0A, 0x11AB4A}, "MT: Pool of Water"},
	{{0x11FA7D, 0x11FC3D, 0x114E0D, 0x11AB4D}, "MT: Bridge"},
	{{0x11FA80, 0x11FC40, 0x114E10, 0x11AB50}, "GGM: Water Storage"},
	{{0x11FA83, 0x11FC43, 0x114E13, 0x11AB53}, "GGM: Jail"},
	{{0x11FA86, 0x11FC46, 0x114E16, 0x11AB56}, "GGM: Toxic Gas Cave"},
	{{0x11FA89, 0x11FC49, 0x114E19, 0x11AB59}, "GGM: Boulder"},
	{{0x11FA8C, 0x11FC4C, 0x114E1C, 0x11AB5C}, "GGM: Mine Tracks"},
	{{0x11FA8F, 0x11FC4F, 0x114E1F, 0x11AB5F}, "WW: Tent"},
	{{0x11FA92, 0x11FC52, 0x114E22, 0x11AB62}, "WW: Cave of Horrors"},
	{{0x11FA95, 0x11FC55, 0x114E25, 0x11AB65}, "WW: Van Door"},
	{{0x11FA98, 0x11FC58, 0x114E28, 0x11AB68}, "WW: Dodgem Dome"},
	{{0x11FA9B, 0x11FC5B, 0x114E2B, 0x11AB6B}, "WW: Cactus of Strength"},
	{{0x11FA9E, 0x11FC5E, 0x114E2E, 0x11AB6E}, "JRL: Lagoon Alcove"},
	{{0x11FAA1, 0x11FC61, 0x114E31, 0x11AB71}, "JRL: Blubber"},
	{{0x11FAA4, 0x11FC64, 0x114E34, 0x11AB74}, "JRL: Big Fish"},
	{{0x11FAA7, 0x11FC67, 0x114E37, 0x11AB77}, "JRL: Seaweed Sanctum"},
	{{0x11FAAA, 0x11FC6A, 0x114E3A, 0x11AB7A}, "JRL: Sunken Ship"},	
	{{0x11FAAD, 0x11FC6D, 0x114E3D, 0x11AB7D}, "TDL: Talon Torpedo"},
	{{0x11FAB0, 0x11FC70, 0x114E40, 0x11AB80}, "TDL: Cutscene Skip"},
	{{0x11FAB3, 0x11FC73, 0x114E43, 0x11AB83}, "TDL: Beside Rocknut"},
	{{0x11FAB6, 0x11FC76, 0x114E46, 0x11AB86}, "TDL: Big T-Rex Skip"},
	{{0x11FAB9, 0x11FC79, 0x114E49, 0x11AB89}, "TDL: Stomping Plains"},
	{{0x11FABC, 0x11FC7C, 0x114E4C, 0x11AB8C}, "GI: Floor 5"},
	{{0x11FABF, 0x11FC7F, 0x114E4F, 0x11AB8F}, "GI: Leg Spring"},
	{{0x11FAC2, 0x11FC82, 0x114E52, 0x11AB92}, "GI: Toxic Waste"},
	{{0x11FAC5, 0x11FC85, 0x114E55, 0x11AB95}, "GI: Boiler Plant"},
	{{0x11FAC8, 0x11FC88, 0x114E58, 0x11AB98}, "GI: Outside"},
	{{0x11FACB, 0x11FC8B, 0x114E5B, 0x11AB9B}, "HFP: Lava Waterfall"},
	{{0x11FACE, 0x11FC8E, 0x114E5E, 0x11AB9E}, "HFP: Boiling Hot Pool"},
	{{0x11FAD1, 0x11FC91, 0x114E61, 0x11ABA1}, "HFP: Windy Hole"},
	{{0x11FAD4, 0x11FC94, 0x114E64, 0x11ABA4}, "HFP: Icicle Grotto"},
	{{0x11FAD7, 0x11FC97, 0x114E67, 0x11ABA7}, "HFP: Mildred Ice Cube"},
	{{0x11FADA, 0x11FC9A, 0x114E6A, 0x11ABAA}, "CCL: Trash Can"},
	{{0x11FADD, 0x11FC9D, 0x114E6D, 0x11ABAD}, "CCL: Cheese Wedge"},
	{{0x11FAE0, 0x11FCA0, 0x114E70, 0x11ABB0}, "CCL: Central Cavern"},
	{{0x11FAE3, 0x11FCA3, 0x114E73, 0x11ABB3}, "CCL: Mingy Jongo"},
	{{0x11FAE6, 0x11FCA6, 0x114E76, 0x11ABB6}, "CCL: Wumba's"},
	{{0x11FAE9, 0x11FCA9, 0x114E79, 0x11ABB9}, "IoH: Wooded Hollow"},
	{{0x11FAEC, 0x11FCAC, 0x114E7C, 0x11ABBC}, "IoH: Wasteland"},
	{{0x11FAEF, 0x11FCAF, 0x114E7F, 0x11ABBF}, "IoH: Cliff Top"},
	{{0x11FAF2, 0x11FCB2, 0x114E82, 0x11ABC2}, "IoH: Plateau"},
	{{0x11FAF5, 0x11FCB5, 0x114E85, 0x11ABC5}, "IoH: Spiral Mountain"},
};

JinjoColors = {
	[0] = "White",
	[1] = "Orange",
	[2] = "Yellow",
	[3] = "Brown",
	[4] = "Green",
	[5] = "Red",
	[6] = "Blue",
	[7] = "Purple",
	[8] = "Black",
};

knownPatterns = { -- To test for more patterns: Freeze u32_be 0x12C7F0 at a desired value and create a new file then run isKnownPattern(), tested up to 0xFF inclusive
	{0, 1, 8, 7, 1, 6, 6, 4, 2, 2, 2, 3, 4, 3, 6, 3, 4, 5, 4, 4, 3, 5, 6, 8, 5, 5, 5, 6, 7, 8, 6, 8, 8, 7, 7, 6, 7, 8, 5, 7, 7, 8, 8, 8, 7}, -- 1
	{0, 2, 2, 4, 7, 3, 7, 2, 6, 4, 8, 3, 4, 3, 7, 6, 5, 5, 8, 6, 6, 4, 8, 3, 1, 5, 5, 5, 5, 1, 6, 7, 4, 6, 6, 7, 7, 7, 8, 7, 8, 8, 8, 8, 8},
	{0, 2, 5, 2, 1, 1, 6, 3, 6, 3, 7, 3, 7, 2, 7, 6, 3, 8, 7, 6, 8, 7, 7, 7, 7, 4, 5, 5, 4, 6, 5, 8, 6, 4, 5, 8, 8, 6, 5, 8, 4, 4, 8, 8, 8},
	{0, 3, 6, 5, 8, 8, 4, 8, 5, 8, 7, 2, 6, 8, 1, 1, 8, 3, 8, 4, 6, 2, 7, 6, 6, 7, 2, 4, 3, 7, 7, 6, 5, 3, 6, 5, 4, 8, 7, 8, 5, 5, 7, 7, 4},
	{0, 4, 7, 3, 1, 4, 5, 4, 3, 2, 4, 8, 7, 3, 5, 8, 1, 2, 3, 8, 6, 4, 8, 5, 8, 2, 6, 6, 5, 7, 8, 5, 5, 7, 8, 6, 7, 7, 6, 8, 8, 7, 7, 6, 6},
	{0, 6, 6, 1, 3, 5, 7, 3, 4, 7, 5, 6, 4, 8, 7, 8, 5, 5, 4, 8, 1, 2, 3, 2, 3, 2, 4, 7, 4, 8, 8, 8, 7, 7, 6, 7, 5, 8, 5, 7, 6, 8, 8, 6, 6},
	{0, 7, 5, 8, 4, 6, 4, 1, 6, 5, 3, 6, 4, 1, 3, 8, 6, 2, 7, 2, 5, 5, 2, 4, 4, 6, 5, 3, 7, 8, 3, 5, 8, 7, 8, 6, 7, 7, 8, 8, 6, 7, 8, 8, 7},
	{1, 6, 7, 3, 0, 7, 8, 6, 1, 6, 5, 6, 3, 5, 5, 5, 4, 6, 3, 7, 4, 8, 2, 5, 3, 8, 7, 7, 4, 8, 6, 5, 4, 8, 8, 4, 7, 8, 8, 6, 2, 8, 7, 2, 7},
	{2, 1, 2, 1, 5, 3, 6, 8, 7, 8, 2, 7, 7, 7, 4, 3, 7, 4, 5, 8, 5, 6, 3, 0, 8, 4, 4, 4, 8, 6, 6, 8, 6, 3, 6, 8, 5, 5, 6, 5, 7, 7, 7, 8, 8},
	{2, 2, 1, 8, 6, 5, 1, 2, 8, 6, 3, 5, 4, 5, 4, 7, 7, 6, 0, 4, 6, 4, 3, 7, 7, 3, 5, 5, 3, 4, 8, 5, 8, 7, 7, 7, 6, 8, 7, 6, 8, 6, 8, 8, 8}, -- 10
	{2, 4, 0, 5, 7, 6, 5, 5, 4, 2, 4, 3, 7, 7, 5, 6, 2, 8, 8, 7, 4, 6, 4, 3, 1, 6, 6, 6, 6, 7, 3, 5, 1, 3, 8, 5, 7, 7, 7, 8, 8, 8, 8, 8, 8},
	{2, 4, 6, 7, 0, 3, 7, 8, 6, 4, 7, 5, 7, 2, 7, 1, 1, 3, 3, 6, 2, 8, 5, 8, 4, 3, 8, 8, 6, 7, 5, 4, 8, 6, 6, 6, 5, 8, 4, 7, 7, 8, 8, 5, 5},
	{2, 6, 5, 5, 2, 1, 7, 1, 6, 0, 3, 4, 7, 2, 6, 5, 4, 5, 3, 5, 5, 4, 7, 3, 6, 3, 8, 8, 4, 7, 7, 7, 6, 8, 8, 6, 4, 8, 7, 6, 8, 7, 8, 8, 8},
	{2, 8, 4, 3, 3, 2, 2, 4, 4, 7, 5, 1, 1, 3, 8, 4, 6, 3, 7, 5, 7, 6, 8, 4, 5, 8, 7, 5, 0, 7, 5, 8, 5, 6, 7, 6, 6, 7, 8, 6, 7, 8, 8, 8, 6},
	{3, 4, 7, 0, 7, 2, 3, 8, 2, 2, 4, 7, 1, 6, 7, 5, 3, 5, 7, 3, 7, 5, 8, 7, 5, 4, 8, 6, 4, 6, 1, 7, 4, 8, 8, 8, 8, 8, 6, 8, 5, 6, 5, 6, 6},
	{3, 6, 6, 7, 8, 3, 7, 2, 5, 3, 8, 8, 7, 7, 2, 2, 8, 5, 6, 7, 8, 5, 0, 7, 6, 4, 7, 7, 8, 4, 1, 1, 5, 8, 4, 6, 6, 5, 8, 4, 3, 8, 4, 5, 6},
	{3, 8, 5, 5, 0, 4, 3, 6, 8, 4, 4, 5, 3, 6, 4, 8, 4, 1, 8, 1, 3, 5, 6, 2, 8, 2, 6, 8, 6, 5, 8, 6, 7, 2, 8, 5, 8, 6, 7, 7, 7, 7, 7, 7, 7},
	{4, 1, 1, 5, 4, 8, 4, 2, 6, 3, 5, 4, 7, 6, 6, 6, 7, 5, 2, 3, 6, 2, 5, 3, 3, 8, 4, 6, 5, 6, 5, 0, 8, 7, 7, 8, 7, 7, 7, 7, 8, 8, 8, 8, 8},
	{4, 3, 0, 2, 5, 1, 8, 5, 8, 2, 8, 6, 2, 4, 1, 7, 6, 6, 8, 4, 5, 4, 7, 6, 5, 6, 3, 6, 7, 6, 3, 8, 4, 3, 7, 7, 5, 8, 8, 5, 7, 8, 8, 7, 7},
	{4, 8, 2, 7, 3, 7, 0, 8, 3, 1, 7, 4, 6, 1, 4, 5, 8, 2, 2, 7, 3, 6, 6, 4, 6, 8, 5, 5, 4, 3, 7, 7, 7, 6, 7, 8, 5, 5, 6, 8, 8, 8, 8, 6, 5}, -- 20
	{5, 1, 2, 7, 1, 2, 5, 3, 0, 7, 2, 5, 8, 8, 3, 5, 7, 7, 3, 7, 6, 8, 7, 4, 8, 4, 3, 8, 6, 8, 5, 4, 6, 8, 7, 8, 6, 8, 5, 7, 4, 6, 4, 6, 6},
	{5, 3, 1, 5, 3, 3, 0, 6, 3, 7, 7, 6, 6, 6, 5, 1, 2, 8, 8, 8, 2, 5, 2, 4, 8, 8, 6, 5, 5, 6, 4, 6, 4, 8, 4, 8, 4, 8, 7, 7, 8, 7, 7, 7, 7},
	{5, 3, 7, 6, 5, 6, 6, 8, 7, 4, 1, 1, 8, 4, 0, 6, 5, 3, 7, 6, 3, 5, 5, 6, 7, 2, 8, 3, 6, 2, 4, 5, 7, 4, 8, 7, 2, 4, 7, 7, 8, 8, 8, 8, 8},
	{5, 5, 6, 4, 6, 7, 1, 2, 1, 5, 6, 2, 5, 5, 2, 0, 5, 4, 3, 7, 3, 8, 6, 7, 8, 3, 7, 3, 6, 6, 6, 4, 7, 7, 7, 7, 4, 8, 4, 8, 8, 8, 8, 8, 8},
	{5, 7, 5, 2, 7, 8, 5, 6, 4, 6, 2, 3, 3, 7, 0, 4, 1, 4, 7, 4, 3, 6, 1, 5, 7, 7, 5, 7, 2, 5, 8, 7, 3, 4, 8, 6, 6, 6, 6, 8, 8, 8, 8, 8, 8},
	{5, 8, 3, 0, 1, 6, 6, 6, 4, 1, 4, 5, 6, 2, 4, 2, 6, 5, 4, 8, 3, 7, 7, 5, 2, 5, 7, 3, 8, 8, 5, 7, 6, 4, 8, 7, 6, 8, 7, 3, 7, 8, 7, 8, 8},
	{7, 0, 2, 4, 8, 5, 8, 3, 5, 8, 7, 7, 4, 4, 8, 4, 3, 3, 3, 4, 6, 8, 1, 8, 1, 5, 6, 5, 6, 7, 6, 5, 8, 2, 2, 5, 8, 6, 8, 6, 7, 6, 7, 7, 7},
	{7, 2, 1, 2, 0, 7, 3, 6, 8, 4, 8, 5, 1, 5, 2, 6, 4, 7, 3, 8, 3, 5, 5, 3, 4, 6, 7, 5, 4, 8, 5, 4, 7, 8, 7, 7, 6, 7, 6, 6, 8, 6, 8, 8, 8},
	{7, 3, 0, 8, 2, 8, 7, 2, 1, 3, 7, 4, 3, 5, 2, 1, 6, 4, 6, 7, 4, 6, 7, 6, 6, 7, 3, 5, 4, 5, 4, 8, 8, 8, 6, 7, 8, 5, 8, 7, 6, 5, 8, 5, 8},
	{7, 5, 5, 8, 5, 3, 8, 6, 8, 7, 8, 5, 2, 1, 4, 4, 3, 5, 5, 0, 6, 3, 8, 4, 3, 8, 4, 8, 7, 8, 4, 1, 2, 2, 6, 7, 6, 7, 8, 7, 6, 7, 7, 6, 6}, -- 30
	{7, 5, 7, 6, 3, 0, 2, 4, 4, 1, 5, 2, 4, 5, 6, 1, 4, 7, 5, 5, 8, 3, 8, 8, 8, 8, 2, 6, 7, 3, 7, 5, 3, 8, 4, 6, 7, 6, 8, 8, 8, 6, 7, 6, 7},
	{7, 7, 4, 6, 7, 4, 3, 0, 2, 8, 4, 6, 7, 8, 6, 3, 4, 8, 2, 8, 1, 6, 1, 8, 8, 7, 6, 8, 4, 8, 2, 6, 3, 8, 5, 3, 6, 5, 5, 7, 7, 5, 5, 7, 5},
	{7, 7, 6, 4, 5, 1, 6, 7, 7, 2, 1, 3, 7, 0, 4, 6, 7, 7, 7, 3, 6, 5, 2, 6, 2, 3, 5, 6, 4, 3, 4, 4, 8, 8, 8, 6, 5, 8, 8, 5, 8, 8, 8, 5, 8},
};

function getCurrentPattern()
	local pattern = {};
	for i = 1, #JinjoAddresses do
		table.insert(pattern, mainmemory.readbyte(JinjoAddresses[i][1][version]));
	end
	return pattern;
end

function printCurrentPattern()
	local patternString = "{";
	local pattern = getCurrentPattern();
	for i = 1, #pattern do
		patternString = patternString..pattern[i]..", ";
	end
	print(patternString.."},");
end

function isKnownPattern()
	local currentPattern = getCurrentPattern();
	for i = 1, #knownPatterns do
		local patternMatch = true;
		for j = 1, #currentPattern do
			if currentPattern[j] ~= knownPatterns[i][j] then
				patternMatch = false;
			end
		end
		if patternMatch then
			return tostring(true).." index: "..i;
		end
	end
	console.clear();
	printCurrentPattern();
	return false;
end

--------------
-- Position --
--------------

function Game.getXPosition()
	local positionObject = Game.getPlayerSubObject(position_pointer_index);
	if isRDRAM(positionObject) then
		return mainmemory.readfloat(positionObject + x_pos, true);
	end
	return 0;
end

function Game.getYPosition()
	local positionObject = Game.getPlayerSubObject(position_pointer_index);
	if isRDRAM(positionObject) then
		return mainmemory.readfloat(positionObject + y_pos, true);
	end
	return 0;
end

function Game.getZPosition()
	local positionObject = Game.getPlayerSubObject(position_pointer_index);
	if isRDRAM(positionObject) then
		return mainmemory.readfloat(positionObject + z_pos, true);
	end
	return 0;
end

function Game.setXPosition(value)
	local positionObject = Game.getPlayerSubObject(position_pointer_index);
	if isRDRAM(positionObject) then
		mainmemory.writefloat(positionObject + x_pos, value, true);
		mainmemory.writefloat(positionObject + x_pos + 12, value, true);
		mainmemory.writefloat(positionObject + x_pos + 24, value, true);
	end
end

function Game.setYPosition(value)
	local positionObject = Game.getPlayerSubObject(position_pointer_index);
	if isRDRAM(positionObject) then
		mainmemory.writefloat(positionObject + y_pos, value, true);
		mainmemory.writefloat(positionObject + y_pos + 12, value, true);
		mainmemory.writefloat(positionObject + y_pos + 24, value, true);
		Game.setYVelocity(0);
	end
end

function Game.setZPosition(value)
	local positionObject = Game.getPlayerSubObject(position_pointer_index);
	if isRDRAM(positionObject) then
		mainmemory.writefloat(positionObject + z_pos, value, true);
		mainmemory.writefloat(positionObject + z_pos + 12, value, true);
		mainmemory.writefloat(positionObject + z_pos + 24, value, true);
	end
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	local velocityObject = Game.getPlayerSubObject(velocity_pointer_index);
	if isRDRAM(velocityObject) then
		return mainmemory.readfloat(velocityObject + x_velocity, true);
	end
	return 0;
end

function Game.getYVelocity()
	local velocityObject = Game.getPlayerSubObject(velocity_pointer_index);
	if isRDRAM(velocityObject) then
		return mainmemory.readfloat(velocityObject + y_velocity, true);
	end
	return 0;
end

function Game.getZVelocity()
	local velocityObject = Game.getPlayerSubObject(velocity_pointer_index);
	if isRDRAM(velocityObject) then
		return mainmemory.readfloat(velocityObject + z_velocity, true);
	end
	return 0;
end

function Game.getVelocity() -- Calculated VXZ
	local vX = Game.getXVelocity();
	local vZ = Game.getZVelocity();
	return math.sqrt(vX*vX + vZ*vZ);
end

function Game.setXVelocity(value)
	local velocityObject = Game.getPlayerSubObject(velocity_pointer_index);
	if isRDRAM(velocityObject) then
		mainmemory.writefloat(velocityObject + x_velocity, value, true);
	end
end

function Game.setYVelocity(value)
	local velocityObject = Game.getPlayerSubObject(velocity_pointer_index);
	if isRDRAM(velocityObject) then
		mainmemory.writefloat(velocityObject + y_velocity, value, true);
	end
end

function Game.setZVelocity(value)
	local velocityObject = Game.getPlayerSubObject(velocity_pointer_index);
	if isRDRAM(velocityObject) then
		mainmemory.writefloat(velocityObject + z_velocity, value, true);
	end
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	local rotationObject = Game.getPlayerSubObject(rot_x_pointer_index);
	if isRDRAM(rotationObject) then
		return mainmemory.readfloat(rotationObject + x_rot_current, true);
	end
	return 0;
end

function Game.getYRotation()
	local rotationObject = Game.getPlayerSubObject(rot_y_pointer_index);
	if isRDRAM(rotationObject) then
		return mainmemory.readfloat(rotationObject + facing_angle, true);
	end
	return 0;
end

function Game.getMovingAngle()
	local rotationObject = Game.getPlayerSubObject(rot_y_pointer_index);
	if isRDRAM(rotationObject) then
		return mainmemory.readfloat(rotationObject + moving_angle, true);
	end
	return 0;
end

function Game.getZRotation()
	local rotationObject = Game.getPlayerSubObject(rot_z_pointer_index);
	if isRDRAM(rotationObject) then
		return mainmemory.readfloat(rotationObject + z_rot_current, true);
	end
	return 0;
end

function Game.setXRotation(value)
	local rotXObject = Game.getPlayerSubObject(rot_x_pointer_index);
	if isRDRAM(rotXObject) then
		mainmemory.writefloat(rotXObject + x_rot_current, value, true);
		mainmemory.writefloat(rotXObject + x_rot_target, value, true);
	end
end

function Game.setYRotation(value)
	local rotYObject = Game.getPlayerSubObject(rot_y_pointer_index);
	if isRDRAM(rotYObject) then
		mainmemory.writefloat(rotYObject + facing_angle, value, true);
		mainmemory.writefloat(rotYObject + moving_angle, value, true);
	end
end

function Game.setZRotation(value)
	local rotZObject = Game.getPlayerSubObject(rot_z_pointer_index);
	if isRDRAM(rotZObject) then
		mainmemory.writefloat(rotZObject + z_rot_current, value, true);
		mainmemory.writefloat(rotZObject + z_rot_target, value, true);
	end
end

----------------
-- Never Slip --
----------------

local function neverSlip()
	local slope_object = Game.getPlayerSubObject(slope_pointer_index);
	if isRDRAM(slope_object) then
		mainmemory.writefloat(slope_object + slope_timer, 0.0, true);
	end
end

function Game.getSlopeTimer()
	local slope_object = Game.getPlayerSubObject(slope_pointer_index);
	if isRDRAM(slope_object) then
		return mainmemory.readfloat(slope_object + slope_timer, true);
	end
	return 0;
end

function Game.colorSlopeTimer()
	if forms.ischecked(ScriptHawk.UI.form_controls.toggle_neverslip) then
		return 0xFF00FFFF; -- Light blue
	end
	local slopeTimer = Game.getSlopeTimer();
	if slopeTimer >= 0.75 then
		return getColor(slopeTimer);
	end
end

-----------------
-- Moves stuff --
-----------------

local move_levels = {
	["0. None"] = {0xE0FFFF01, 0x00004000, false},
	["1. All"]  = {0xFFFFFFFF, 0xFFFFFFFF, false},
	["2. All + Dragon Kazooie"]  = {0xFFFFFFFF, 0xFFFFFFFF, true},
};

local function unlock_moves()
	local level = forms.gettext(ScriptHawk.UI.form_controls.moves_dropdown);
	local movesObject = dereferencePointer(Game.Memory.moves_pointer[version]);
	if isRDRAM(movesObject) then
		mainmemory.write_u32_be(movesObject + 0x18, move_levels[level][1]);
		mainmemory.write_u32_be(movesObject + 0x1C, move_levels[level][2]);
		if move_levels[level][3] then
			mainmemory.writebyte(movesObject + 0x78, 0xFF); -- Unlock dragon kazooie
		else
			mainmemory.writebyte(movesObject + 0x78, 0x00); -- Lock dragon kazooie
		end
	end
end

local movementStates = {
	[0x00] = "Null",
	[0x01] = "Idle",
	[0x02] = "Walking", -- Slow
	[0x03] = "Walking", -- Medium
	[0x04] = "Walking", -- Fast
	[0x05] = "Jumping",
	[0x06] = "Pecking", -- Bear Punch replacement
	[0x07] = "Crouching",
	[0x08] = "Jumping", -- Talon Trot
	[0x09] = "Shooting Egg", -- BK on ground
	[0x0A] = "Pooping Egg", -- BK on ground

	[0x0C] = "Slipping",

	[0x0E] = "Damaged",
	[0x0F] = "Beak Buster",
	[0x10] = "Featherty Flap",
	[0x11] = "Rat-a-tat Rap",
	[0x12] = "Flap Flip",
	[0x13] = "Beak Barge",
	[0x14] = "Entering Talon Trot",
	[0x15] = "Idle", -- Talon Trot
	[0x16] = "Walking", -- Talon Trot
	[0x17] = "Leaving Talon Trot",

	[0x19] = "Swimming (A+B)",
	[0x1A] = "Entering Wonderwing",
	[0x1B] = "Idle", -- Wonderwing
	[0x1C] = "Walking", -- Wonderwing
	[0x1D] = "Jumping", -- Wonderwing
	[0x1E] = "Leaving Wonderwing",

	[0x20] = "Landing",

	[0x23] = "Taking Flight",
	[0x24] = "Flying",
	[0x25] = "Entering Stilt Stride",
	[0x26] = "Idle", -- Stilt Stride
	[0x27] = "Walking", -- Stilt Stride
	[0x28] = "Jumping", -- Stilt Stride
	[0x29] = "Leaving Stilt Stride",
	[0x2A] = "Beak Bomb",
	[0x2B] = "Idle", -- Underwater
	[0x2C] = "Swimming (B)",
	[0x2D] = "Idle", -- Water Surface
	[0x2E] = "Paddling", -- Water Surface
	[0x2F] = "Falling",
	[0x30] = "Diving",
	[0x31] = "Rolling",

	[0x39] = "Swimming (A)",

	[0x3D] = "Falling (Splat)",

	[0x41] = "Death",

	[0x45] = "Locked", -- Talon Trot, sliding

	[0x4C] = "Landing", -- Water Surface

	[0x4F] = "Idle", -- Climbing
	[0x50] = "Climbing",

	[0x54] = "Drowning",

	[0x56] = "Knockback", -- Solo Banjo

	[0x59] = "Damaged", -- Beak Bomb

	[0x5B] = "Throwing Object", -- Glowbo
	[0x5C] = "Knockback",

	[0x5E] = "Locked", -- Shack Pack, Talking, moving to target
	[0x5F] = "Locked", -- Shack pack, Talking
	[0x60] = "Locked", -- Snooze Pack, Talking, moving to target
	[0x61] = "Locked", -- Snooze Pack, Talking

	[0x66] = "Locked", -- Solo Kazooie - Water surface?
	[0x67] = "Shooting Egg", -- Solo Kazooie
	[0x68] = "Pooping Egg", -- Solo Kazooie
	[0x69] = "Joining", -- Split up pad
	[0x6A] = "Joining", -- Split up pad

	[0x6C] = "Backflip", -- Solo Banjo -- TODO: What is the name for this?
	[0x6D] = "Diving", -- Solo Banjo

	[0x6E] = "Locked", -- Sack Pack, Talking, moving to target
	[0x6F] = "Floating", -- Solo Banjo, CCL

	[0x71] = "Falling", -- Talon Trot
	[0x72] = "Recovering", -- Splat
	[0x73] = "Locked",
	[0x74] = "Locked", -- Mumbo's Skull
	[0x75] = "Locked", -- Signpost

	[0x77] = "Locked", -- Water Surface
	[0x78] = "Locked", -- Underwater

	[0x7A] = "Walking", -- Damaging Ground, eg. quicksand

	[0x7D] = "Damaged", -- Solo Banjo - Sack Pack

	[0x7F] = "Damaged", -- Underwater
	[0x80] = "Locked", -- Sack Pack, Talking
	[0x81] = "Swimming (A)", -- Solo Banjo
	[0x82] = "Swimming (B)", -- Solo Banjo
	[0x83] = "Knockback", -- Submarine on land

	[0x8F] = "Locked", -- Solo Kazooie

	[0x90] = "Swimming (A+B)", -- Solo Banjo
	[0x91] = "Damaged", -- Flying

	[0x93] = "Locked", -- Solo Kazooie, Loading Zone, First Person Camera, Slipping

	[0x95] = "Jumping", -- Claw Clamber
	[0x96] = "Locked", -- Transforming
	[0x97] = "Locked", -- Underwater - Loading Zone
	[0x98] = "Locked", -- First person camera, some damage sources, loading zones

	[0x9A] = "Locked", -- Talon Trot, loading zone etc

	[0x9C] = "Jumping", -- Springy Step Shoes

	[0xA6] = "Idle", -- Grip Grab
	[0xA7] = "Moving", -- Grip Grab
	[0xA8] = "Grabbing Ledge", -- Grip Grab
	[0xA9] = "Pecking", -- Grip Grab
	[0xAA] = "Pulling up", -- Grip Grab
	[0xAB] = "Death", -- Stony
	[0xAC] = "Locked", -- Stony - Loading zone, transformation
	[0xAD] = "Falling", -- Stony
	[0xAE] = "Jumping", -- Stony
	[0xAF] = "Damaged", -- Stony
	[0xB0] = "Knockback", -- Stony
	[0xB1] = "Locked", -- Stony
	[0xB2] = "Walking", -- Stony
	[0xB3] = "Idle", -- Stony
	[0xB4] = "Diving", -- Stony

	[0xB6] = "Bill Drill",

	[0xB8] = "Splitting", -- Split up pad
	[0xB9] = "Splitting", -- Split up pad

	[0xBB] = "Idle", -- Solo Kazooie
	[0xBC] = "Creeping", -- Solo Kazooie
	[0xBD] = "Jumping", -- Solo Kazooie
	[0xBE] = "Gliding", -- Solo Kazooie

	[0xC2] = "Wing Whack", -- Solo Kazooie

	[0xC4] = "Wing Whack", -- Solo Kazooie - Moving
	[0xC5] = "Hatching", -- Solo Kazooie
	[0xC6] = "Leg Spring", -- Solo Kazooie
	[0xC7] = "Walking", -- Solo Kazooie

	[0xCA] = "Idle", -- Breegull Blaster

	[0xD1] = "Walking", -- Breegull Blaster
	[0xD2] = "Beak Bayonet",

	[0xD6] = "Firing CK Egg", -- Breegull Blaster
	[0xD7] = "Clockwork Kazooie", -- Breegull Blaster
	[0xD8] = "Firing Egg", -- Breegull Blaster

	[0xDA] = "Damaged", -- Breegull Blaster

	[0xDD] = "Crouching", -- Solo Kazooie
	[0xDE] = "Landing", -- Solo Kazooie
	[0xDF] = "Falling", -- Solo Kazooie
	[0xE0] = "Falling (Splat)", -- Solo Kazooie

	[0xE4] = "Pack Whack", -- Solo Banjo
	[0xE5] = "Idle", -- Mumbo
	[0xE6] = "Walking", -- Mumbo, slow
	[0xE7] = "Walking", -- Mumbo, fast
	[0xE8] = "Jumping", -- Mumbo
	[0xE9] = "Falling", -- Mumbo
	[0xEA] = "Damaged", -- Mumbo
	[0xEB] = "Death", -- Mumbo

	[0xEE] = "Falling (Splat)", -- Mumbo
	[0xEF] = "Landing", -- Mumbo
	[0xF0] = "Idle", -- Mumbo - Water Surface
	[0xF1] = "Paddling", -- Mumbo

	[0xF3] = "Locked", -- Mumbo first person camera water surface
	[0xF4] = "Landing", -- Mumbo - Water Surface
	[0xF5] = "Locked", -- Mumbo
	[0xF6] = "Locked", -- Mumbo
	[0xF7] = "Attacking", -- Mumbo's Wand

	[0xF9] = "Idle", -- Golden Goliath
	[0xFA] = "Walking", -- Golden Goliath
	[0xFB] = "Jumping", -- Golden Goliath
	[0xFC] = "Kicking", -- Golden Goliath

	[0xFF] = "Recovering", -- Mumbo
	[0x100] = "Damaged", -- Solo Kazooie
	[0x101] = "Death", -- Solo Kazooie
	[0x102] = "Death", -- Solo Banjo - Sack Pack
	[0x103] = "Death", -- Solo Banjo

	[0x104] = "Death", -- Detonator
	[0x105] = "Locked", -- Detonator, Loading Zone, First Person Camera

	[0x107] = "Jumping", -- Detonator
	[0x108] = "Walking", -- Detonator
	[0x109] = "Damaged", -- Detonator
	[0x10A] = "Knockback", -- Detonator
	[0x10B] = "Locked", -- Detonator, Talking
	[0x10C] = "Idle", -- Detonator
	[0x10D] = "Detonating", -- Detonator, Scripted
	[0x10E] = "Detonating", -- Detonator
	[0x10F] = "Idle", -- Detonator, Water Surface
	[0x110] = "Paddling", -- Detonator, Water Surface
	[0x111] = "Landing", -- Detonator, Water Surface

	[0x113] = "Locked", -- Van - Loading zone etc
	[0x114] = "Falling", -- Van
	[0x115] = "Jumping", -- Van
	[0x116] = "Driving", -- Van

	[0x118] = "Knockback", -- Van
	[0x119] = "Locked", -- Van
	[0x11A] = "Idle", -- Van

	[0x11C] = "Paddling", -- Van
	[0x11D] = "Landing", -- Van - Water Surface
	[0x11E] = "Casting Spell", -- Mumbo

	[0x121] = "Paying Coin", -- Van
	[0x122] = "Entering Taxi Pack",
	[0x123] = "Walking", -- Taxi Pack
	[0x124] = "Scooping", -- Taxi Pack
	[0x125] = "Idle", -- Taxi Pack
	[0x126] = "Jumping", -- Taxi Pack
	[0x127] = "Leaving Taxi Pack",

	[0x12C] = "Swimming", -- Submarine
	[0x12D] = "Damaged", -- Submarine
	[0x12E] = "Death", -- Submarine
	[0x12F] = "Locked", -- Submarine - Signpost etc
	[0x130] = "Locked", -- Submarine - Loading Zone, Transforming etc
	[0x131] = "Idle", -- Submarine
	[0x132] = "Landing", -- Clockwork Kazooie
	[0x134] = "Jumping", -- Clockwork Kazooie
	[0x135] = "Walking", -- Clockwork Kazooie
	[0x136] = "Idle", -- Clockwork Kazooie

	[0x138] = "Locked", -- Clockwork Kazooie, slipping, loading zones

	[0x13A] = "Knockback", -- Solo Kazooie
	[0x13B] = "Landing", -- Small T-Rex
	[0x13C] = "Death", -- Small T-Rex
	[0x13D] = "Locked", -- Small T-Rex
	[0x13E] = "Falling", -- Small T-Rex
	[0x13F] = "Jumping", -- Small T-Rex
	[0x140] = "Damaged", -- Small T-Rex
	[0x141] = "Knockback", -- Small T-Rex
	[0x142] = "Locked", -- Small T-Rex, Talking
	[0x143] = "Roar", -- Small T-Rex
	[0x144] = "Walking", -- Small T-Rex
	[0x145] = "Idle", -- Small T-Rex
	[0x146] = "Walking", -- Small T-Rex, Slow
	[0x147] = "Landing", -- Big T-Rex

	[0x149] = "Locked", -- Big T-Rex, Loading Zone
	[0x14A] = "Falling", -- Big T-Rex
	[0x14B] = "Jumping", -- Big T-Rex

	[0x14E] = "Locked", -- Big T-Rex, Talking
	[0x14F] = "Roar", -- Big T-Rex
	[0x150] = "Walking", -- Big T-Rex
	[0x151] = "Idle", -- Big T-Rex
	[0x152] = "Walking", -- Big T-Rex, Slow
	[0x153] = "Entering Talon Torpedo",
	[0x154] = "Swimming", -- Talon Torpedo

	[0x157] = "Deploying Talon Torpedo",

	[0x159] = "Swimming (A)", -- Talon Torpedo

	[0x15B] = "Damaged", -- Solo Kazooie - Gliding
	[0x15C] = "Feathery Flap", -- Solo Kazooie
	[0x15D] = "Idle", -- Solo Kazooie - Water Surface
	[0x15E] = "Paddling", -- Solo Kazooie
	[0x15F] = "Diving", -- Solo Kazooie
	[0x160] = "Landing", -- Solo Kazooie - Water Surface

	[0x163] = "Entering Sack Pack",
	[0x164] = "Leaving Sack Pack",
	[0x165] = "Idle", -- Sack Pack
	[0x166] = "Walking", -- Sack Pack

	[0x169] = "Jumping", -- Sack Pack
	[0x16A] = "Entering Shack Pack",
	[0x16B] = "Leaving Shack Pack",
	[0x16C] = "Idle", -- Shack Pack
	[0x16D] = "Walking", -- Shack Pack
	[0x16E] = "Jumping", -- Shack Pack
	[0x16F] = "Snoozing", -- Snooze Pack

	[0x171] = "Entering Snooze Pack",
	[0x172] = "Leaving Snooze Pack",

	[0x176] = "Recovering", -- Solo Kazooie, post splat

	[0x17B] = "Idle", -- On Wall, Claw Clamber
	[0x17C] = "Walking", -- On Wall, Claw Clamber
	[0x17D] = "Idle", -- Snowball
	[0x17E] = "Rolling", -- Snowball
	[0x17F] = "Jumping", -- Snowball

	[0x181] = "Damaged", -- Snowball

	[0x186] = "Jumping", -- Solo Kazooie - Springy Step Shoes
	[0x187] = "Idle", -- Solo Kazooie - On Wall, Claw Clamber
	[0x188] = "Walking", -- Solo Kazooie - On Wall, Claw Clamber
	[0x189] = "Breegull Bash",
	[0x18A] = "Breathing Fire", -- BK
	[0x18B] = "Breathing Fire", -- Solo Kazooie
};

function Game.getCurrentMovementState()
	local movementStateObject = Game.getPlayerSubObject(movement_state_pointer_index);
	if isRDRAM(movementStateObject) then
		local movementState = mainmemory.read_u32_be(movementStateObject + 4);
		if type(movementStates[movementState]) == "string" then
			return movementStates[movementState];
		end
		return toHexString(movementState);
	end
	return "Unknown";
end

function Game.getPreviousMovementState()
	local movementStateObject = Game.getPlayerSubObject(movement_state_pointer_index);
	if isRDRAM(movementStateObject) then
		local movementState = mainmemory.read_u32_be(movementStateObject + 0);
		if type(movementStates[movementState]) == "string" then
			return movementStates[movementState];
		end
		return toHexString(movementState);
	end
	return "Unknown";
end

function Game.setMovementState(state)
	local movementStateObject = Game.getPlayerSubObject(movement_state_pointer_index);
	if isRDRAM(movementStateObject) then
		mainmemory.write_u32_be(movementStateObject + 4, state);
	end
end

------------
-- Health --
------------

function Game.getCurrentHealth()
	local currentTransformation = mainmemory.readbyte(Game.Memory.iconAddress[version]);
	if type(Game.Memory.healthAddresses[currentTransformation]) == 'table' then
		return mainmemory.read_u8(Game.Memory.healthAddresses[currentTransformation][version]);
	end
	return 1;
end

function Game.setCurrentHealth(value)
	local currentTransformation = mainmemory.readbyte(Game.Memory.iconAddress[version]);
	if type(Game.Memory.healthAddresses[currentTransformation]) == 'table' then
		value = value or 0;
		value = math.max(0x00, value);
		value = math.min(0xFF, value);
		return mainmemory.write_u8(Game.Memory.healthAddresses[currentTransformation][version], value);
	end
end

function Game.getMaxHealth()
	local currentTransformation = mainmemory.readbyte(Game.Memory.iconAddress[version]);
	if type(Game.Memory.healthAddresses[currentTransformation]) == 'table' then
		return mainmemory.read_u8(Game.Memory.healthAddresses[currentTransformation][version] + 1);
	end
	return 1;
end

function Game.setMaxHealth(value)
	local currentTransformation = mainmemory.readbyte(Game.Memory.iconAddress[version]);
	if type(Game.Memory.healthAddresses[currentTransformation]) == 'table' then
		value = value or 0;
		value = math.max(0x00, value);
		value = math.min(0xFF, value);
		return mainmemory.write_u8(Game.Memory.healthAddresses[currentTransformation][version] + 1, value);
	end
end

function outputHealth()
	print("Health: "..Game.getCurrentHealth().."/"..Game.getMaxHealth());
end

function dumpPointerListStrings()
	local object;
	local index = 0;
	repeat
		object = dereferencePointer(0x126738 + index * 4);
		if isRDRAM(object) then
			local string = "Unknown";
			local checkPointerOffset = 0x3C;
			repeat
				checkPointerOffset = checkPointerOffset + 4;
				checkPointer = dereferencePointer(object + checkPointerOffset);
			until not isRDRAM(checkPointer);
			string = readNullTerminatedString(object + checkPointerOffset);

			print(index.." "..toHexString(object)..": "..string);
		end
		index = index + 1;
	until not isRDRAM(object);
end

------------
-- Events --
------------

Game.takeMeThereType = "Button";
function Game.setMap(value)
	local trigger_value = mainmemory.read_u16_be(Game.Memory.map_trigger[version]);
	if trigger_value == 0 then
		mainmemory.write_u16_be(Game.Memory.map[version], value);

		-- Force game to reload with desired map
		mainmemory.write_u16_be(Game.Memory.map_trigger[version], 0x0101);
	end
end

local max_air = 60; -- TODO: This changes once you finish Roysten's quest, how to you get this information out of the game?

function Game.applyInfinites()
	-- TODO: Eggs, feathers, glowbos etc
	--if version == 4 then -- TODO: Other versions
		--mainmemory.write_u16_be(0x0D1A58, 0x0000); -- Janky infinite egg/feather code, I don't like this
	--end
	mainmemory.writefloat(Game.Memory.air[version], max_air, true);
	Game.setCurrentHealth(Game.getMaxHealth());
end

function Game.initUI()
	ScriptHawk.UI.form_controls.toggle_neverslip = forms.checkbox(ScriptHawk.UI.options_form, "Never Slip", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);

	-- Moves
	ScriptHawk.UI.form_controls.moves_dropdown = forms.dropdown(ScriptHawk.UI.options_form, { "0. None", "1. All", "2. All + Dragon Kazooie" }, ScriptHawk.UI.col(10) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset);
	ScriptHawk.UI.form_controls.moves_button = forms.button(ScriptHawk.UI.options_form, "Unlock Moves", unlock_moves, ScriptHawk.UI.col(5), ScriptHawk.UI.row(7), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
end

function Game.eachFrame()
	if forms.ischecked(ScriptHawk.UI.form_controls.toggle_neverslip) then
		neverSlip();
	end
end

Game.OSDPosition = {2, 70}
Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"dY"},
	{"dXZ"},
	{"Velocity", Game.getVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
	{"Rot. X", Game.getXRotation},
	{"Facing", Game.getYRotation},
	{"Moving", Game.getMovingAngle},
	{"Rot. Z", Game.getZRotation},
	{"Separator", 1},
	{"Movement", Game.getCurrentMovementState},
	{"Slope Timer", Game.getSlopeTimer, Game.colorSlopeTimer},
};

return Game;