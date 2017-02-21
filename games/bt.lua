if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

encircle_enabled = false;
realtime_flags = true;

local Game = {
	maps = {
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
		"GGM - Ordnance Storage",
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

		"HFP - Inside the UFO",

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
		"HFP - Lava Side",
		"HFP - Icy Side",
		"HFP - Lava Train Station",
		"HFP - Ice Train Station",
		"HFP - Chilli Billi",
		"HFP - Chilly Willy",
		"HFP - Kickball Stadium lobby",
		"HFP - Kickball Stadium 1",
		"HFP - Kickball Stadium 2",
		"HFP - Kickball Stadium 3",
		"HFP - Boggy's Igloo",
		"HFP - Icicle Grotto",
		"HFP - Inside the Volcano",
		"HFP - Mumbo's Skull",
		"HFP - Wumba's Wigwam",
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
		"IoH - Cliff Top",
		"IoH - Cliff Top - Mumbo's Skull",
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
		"HFP - Icy Side (still)",
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
		"MT - Targitzan's Slightly Sacred Chamber",
		"MT - Inside Targitzan's Temple",
		"MT - Targitzan's Temple Lobby",
		"MT - Targitzan's Really Sacred Chamber",
		"WW - Balloon burst (multiplayer)",
		"WW - Jump the Hoops (multiplayer)",
		"GI - Packing Game",
		"Cutscene - Zombified Throne Room",
		"MT - Kickball Arena 4",
		"HFP - Kickball Arena",
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
	},
	Memory = { -- Version order: Australia, Europe, Japan, USA
		["object_array_pointer"] = {0x13BBD0, 0x13BE60, 0x131020, 0x136EE0},
		["player_pointer"] = {0x13A210, 0x13A4A0, 0x12F660, 0x135490},
		["player_pointer_index"] = {0x13A25F, 0x13A4EF, 0x12F6AF, 0x1354DF},
		["flag_block_pointer"] = {0x1314F0, 0x131780, 0x126940, 0x12C770},
		["air"] = {0x12FDC0, 0x12FFD0, 0x125220, 0x12B050},
		["frame_timer"] = {0x083550, 0x083550, 0x0788F8, 0x079138},
		["linked_list_root"] = {0x13C380, 0x13C680, 0x131850, 0x137800},
		["map"] = {0x137B42, 0x137DD2, 0x12CF92, 0x132DC2},
		["map_trigger_target"] = {0x12C390, 0x12C5A0, 0x1217F0, 0x127640},
		["map_trigger"] = {0x12C392, 0x12C5A2, 0x1217F2, 0x127642},
		["iconAddress"] = {0x11FF95, 0x120155, 0x115325, 0x11B065},
		["healthAddresses"] = {
			[0x01] = {0x120584, 0x120794, 0x115A04, 0x11B644}, -- BK
			[0x10] = {0x12059F, 0x1207AF, 0x115A1F, 0x11B65F}, -- Banjo (Solo)
			[0x11] = {0x1205A8, 0x1207B8, 0x115A28, 0x11B668}, -- Mumbo
			[0x2E] = {0x1205AE, 0x1207BE, 0x115A19, 0x11B66E}, -- Detonator
			[0x2F] = {0x1205A5, 0x1207B5, 0x115A25, 0x11B665}, -- Submarine
			[0x30] = {0x1205B7, 0x1207C7, 0x115A37, 0x11B677}, -- T. Rex
			[0x31] = {0x120593, 0x1207A3, 0x115A13, 0x11B653}, -- Bee
			[0x32] = {0x120587, 0x120797, 0x115A07, 0x11B647}, -- Snowball
			[0x36] = {0x120596, 0x1207A6, 0x115A16, 0x11B656}, -- Washing Machine
			[0x5F] = {0x1205A2, 0x1207B2, 0x115A22, 0x11B662}, -- Kazooie (Solo)
		},
	},
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 },
	speedy_index = 7,
	rot_speed = 10,
	max_rot_units = 360,
};

--------------------
-- Region/Version --
--------------------

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
	{{0x11FA8F, 0x11FC4F, 0x114E1F, 0x11AB5F}, "WW: Big Top"},
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
	{{0x11FAB6, 0x11FC76, 0x114E46, 0x11AB86}, "TDL: Big T. Rex Skip"},
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
	[0x10] = "Feathery Flap",
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
	[0x21] = "Charging Shock Spring Jump",
	[0x22] = "Shock Spring Jump",
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
	[0x32] = "Idle", -- Washing Machine
	[0x33] = "Rolling", -- Washing Machine

	[0x35] = "Jumping", -- Washing Machine
	[0x36] = "Falling", -- Washing Machine
	[0x37] = "Cleaning", -- Washing Machine
	[0x38] = "Launching Underwear", -- Washing Machine
	[0x39] = "Swimming (A)",

	[0x3D] = "Falling (Splat)",
	[0x3E] = "Damaged", -- Washing Machine

	[0x41] = "Death",
	[0x42] = "Locked", -- Silo
	[0x43] = "Death", -- Washing Machine

	[0x45] = "Locked", -- Talon Trot, sliding
	[0x46] = "Knockback", -- Submarine
	[0x47] = "Entering Stilt Stride", -- Solo Kazooie
	[0x48] = "Idle", -- Solo Kazooie, Stilt Stride
	[0x49] = "Walking", -- Solo Kazooie, Stilt Stride
	[0x4A] = "Jumping", -- Solo Kazooie, Stilt Stride
	[0x4B] = "Exiting Stilt Stride", -- Solo Kazooie
	[0x4C] = "Landing", -- Water Surface

	[0x4F] = "Idle", -- Climbing
	[0x50] = "Climbing",

	[0x54] = "Drowning",

	[0x56] = "Knockback", -- Solo Banjo
	[0x57] = "Exiting Beak Bomb", -- BK

	[0x59] = "Damaged", -- Beak Bomb

	[0x5B] = "Throwing Object", -- Glowbo
	[0x5C] = "Knockback",
	[0x5D] = "Locked", -- Washing Machine, Loading Zones & Sliding
	[0x5E] = "Locked", -- Shack Pack, Talking, moving to target
	[0x5F] = "Locked", -- Shack pack, Talking
	[0x60] = "Locked", -- Snooze Pack, Talking, moving to target
	[0x61] = "Locked", -- Snooze Pack, Talking

	[0x65] = "Locked", -- Solo Kazooie, Swimming, Text Boxes
	[0x66] = "Locked", -- Solo Kazooie - Water surface?
	[0x67] = "Shooting Egg", -- Solo Kazooie
	[0x68] = "Pooping Egg", -- Solo Kazooie
	[0x69] = "Joining", -- Split up pad
	[0x6A] = "Joining", -- Split up pad
	[0x6B] = "Locked", -- Bee, Text Boxes
	[0x6C] = "Failed Flip", -- Solo Banjo Z+A
	[0x6D] = "Diving", -- Solo Banjo
	[0x6E] = "Locked", -- Sack Pack, Talking, moving to target
	[0x6F] = "Floating", -- Solo Banjo, CCL
	[0x70] = "Locked", -- Golden Goliath
	[0x71] = "Falling", -- Talon Trot
	[0x72] = "Recovering", -- Splat
	[0x73] = "Locked",
	[0x74] = "Locked", -- Mumbo's Skull
	[0x75] = "Locked", -- Signpost

	[0x77] = "Locked", -- Water Surface
	[0x78] = "Locked", -- Underwater
	[0x79] = "Locked", -- Talon Trot
	[0x7A] = "Walking", -- Damaging Ground, eg. quicksand
	[0x7B] = "Damaged", -- Talon Trot
	[0x7C] = "Clockwork Mouse", -- Canary Mary 3 & 4
	[0x7D] = "Damaged", -- Solo Banjo - Sack Pack

	[0x7F] = "Damaged", -- Underwater
	[0x80] = "Locked", -- Sack Pack, Talking
	[0x81] = "Swimming (A)", -- Solo Banjo
	[0x82] = "Swimming (B)", -- Solo Banjo
	[0x83] = "Knockback", -- Submarine on land
	[0x84] = "Joining", -- Talon Torpedo
	[0x85] = "Idle", -- Bee
	[0x86] = "Walking", -- Bee
	[0x87] = "Jumping", -- Bee
	[0x88] = "Falling", -- Bee
	[0x89] = "Damaged", -- Bee
	[0x8A] = "Death", -- Bee

	[0x8C] = "Flying", -- Bee
	[0x8D] = "Locked", -- Bee, Eyeball Plant FTT
	[0x8E] = "Knockback", -- Washing Machine
	[0x8F] = "Locked", -- Solo Kazooie
	[0x90] = "Swimming (A+B)", -- Solo Banjo
	[0x91] = "Damaged", -- Flying
	[0x92] = "Locked", -- Washing Machine, Elevators & Text Boxes
	[0x93] = "Locked", -- Solo Kazooie, Loading Zone, First Person Camera, Slipping

	[0x95] = "Jumping", -- Claw Clamber
	[0x96] = "Locked", -- Transforming
	[0x97] = "Locked", -- Underwater - Loading Zone
	[0x98] = "Locked", -- First person camera, some damage sources, loading zones

	[0x9A] = "Locked", -- Talon Trot, loading zone etc

	[0x9C] = "Jumping", -- Springy Step Shoes
	[0x9D] = "Locked", -- Bee, Loading Zones

	[0xA3] = "Knockback", -- Bee

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
	[0xB7] = "Pushcart", -- Canary Mary 1 & 2
	[0xB8] = "Splitting", -- Split up pad
	[0xB9] = "Splitting", -- Split up pad

	[0xBB] = "Idle", -- Solo Kazooie
	[0xBC] = "Creeping", -- Solo Kazooie
	[0xBD] = "Jumping", -- Solo Kazooie
	[0xBE] = "Gliding", -- Solo Kazooie

	[0xC1] = "Shock Spring Jump", -- Solo Kazooie
	[0xC2] = "Wing Whack", -- Solo Kazooie
	[0xC3] = "Charging Shock Spring Jump", -- Solo Kazooie
	[0xC4] = "Wing Whack", -- Solo Kazooie - Moving
	[0xC5] = "Hatching", -- Solo Kazooie
	[0xC6] = "Leg Spring", -- Solo Kazooie
	[0xC7] = "Walking", -- Solo Kazooie
	[0xC8] = "Entering Breegull Blaster",
	[0xC9] = "Exiting Breegull Blaster",
	[0xCA] = "Idle", -- Breegull Blaster

	[0xCE] = "Locked", -- Beak Bayonet, Loading Zone

	[0xD1] = "Walking", -- Breegull Blaster
	[0xD2] = "Beak Bayonet",

	[0xD6] = "Firing CK Egg", -- Breegull Blaster
	[0xD7] = "Clockwork Kazooie", -- Breegull Blaster
	[0xD8] = "Firing Egg", -- Breegull Blaster

	[0xDA] = "Damaged", -- Breegull Blaster
	[0xDB] = "Death", -- Breegull Blaster

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

	[0xED] = "Exiting Talon Torpedo",
	[0xEE] = "Falling (Splat)", -- Mumbo
	[0xEF] = "Landing", -- Mumbo
	[0xF0] = "Idle", -- Mumbo - Water Surface
	[0xF1] = "Paddling", -- Mumbo
	[0xF2] = "Locked", -- Mumbo, Swimming, Text Boxes
	[0xF3] = "Locked", -- Mumbo first person camera water surface
	[0xF4] = "Landing", -- Mumbo - Water Surface
	[0xF5] = "Locked", -- Mumbo
	[0xF6] = "Locked", -- Mumbo
	[0xF7] = "Attacking", -- Mumbo's Wand
	[0xF8] = "Failure", -- Golden Goliath, Premature Failure
	[0xF9] = "Idle", -- Golden Goliath
	[0xFA] = "Walking", -- Golden Goliath
	[0xFB] = "Jumping", -- Golden Goliath
	[0xFC] = "Kicking", -- Golden Goliath
	[0xFD] = "Failure", -- Golden Goliath, Run out of time

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

	[0x120] = "Death", -- Toxic Gas
	[0x121] = "Paying Coin", -- Van
	[0x122] = "Entering Taxi Pack",
	[0x123] = "Walking", -- Taxi Pack
	[0x124] = "Scooping", -- Taxi Pack
	[0x125] = "Idle", -- Taxi Pack
	[0x126] = "Jumping", -- Taxi Pack
	[0x127] = "Leaving Taxi Pack",

	[0x12B] = "Saucer of Peril",
	[0x12C] = "Swimming", -- Submarine
	[0x12D] = "Damaged", -- Submarine
	[0x12E] = "Death", -- Submarine
	[0x12F] = "Locked", -- Submarine - Signpost etc
	[0x130] = "Locked", -- Submarine - Loading Zone, Transforming etc
	[0x131] = "Idle", -- Submarine
	[0x132] = "Landing", -- Clockwork Kazooie
	[0x133] = "Falling", -- Clockwork Kazooie
	[0x134] = "Jumping", -- Clockwork Kazooie
	[0x135] = "Walking", -- Clockwork Kazooie
	[0x136] = "Idle", -- Clockwork Kazooie

	[0x138] = "Locked", -- Clockwork Kazooie, slipping, loading zones

	[0x13A] = "Knockback", -- Solo Kazooie
	[0x13B] = "Landing", -- Small T. Rex
	[0x13C] = "Death", -- Small T. Rex
	[0x13D] = "Locked", -- Small T. Rex
	[0x13E] = "Falling", -- Small T. Rex
	[0x13F] = "Jumping", -- Small T. Rex
	[0x140] = "Damaged", -- Small T. Rex
	[0x141] = "Knockback", -- Small T. Rex
	[0x142] = "Locked", -- Small T. Rex, Talking
	[0x143] = "Roar", -- Small T. Rex
	[0x144] = "Walking", -- Small T. Rex
	[0x145] = "Idle", -- Small T. Rex
	[0x146] = "Walking", -- Small T. Rex, Slow
	[0x147] = "Landing", -- Big T. Rex

	[0x149] = "Locked", -- Big T. Rex, Loading Zone
	[0x14A] = "Falling", -- Big T. Rex
	[0x14B] = "Jumping", -- Big T. Rex

	[0x14D] = "Knockback", -- Big T. Rex
	[0x14E] = "Locked", -- Big T. Rex, Talking
	[0x14F] = "Roar", -- Big T. Rex
	[0x150] = "Walking", -- Big T. Rex
	[0x151] = "Idle", -- Big T. Rex
	[0x152] = "Walking", -- Big T. Rex, Slow
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
	[0x161] = "Entering Flight", -- Solo Kazooie
	[0x162] = "Flying", -- Solo Kazooie
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

	[0x174] = "Beak Bomb", -- Solo Kazooie
	[0x175] = "Exiting Beak Bomb", -- Solo Kazooie
	[0x176] = "Recovering", -- Solo Kazooie, post splat

	[0x17B] = "Idle", -- On Wall, Claw Clamber
	[0x17C] = "Walking", -- On Wall, Claw Clamber
	[0x17D] = "Idle", -- Snowball
	[0x17E] = "Rolling", -- Snowball
	[0x17F] = "Jumping", -- Snowball
	[0x180] = "Falling", -- Snowball
	[0x181] = "Damaged", -- Snowball
	[0x182] = "Death", -- Snowball
	[0x183] = "Locked", -- Snowball, Loading Zone
	[0x184] = "Knockback", -- Snowball
	[0x185] = "Locked", -- Snowball, Text Boxes
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

-----------
-- Flags --
-----------

local flag_block_cache = {};
function clearFlagCache()
	flag_block_cache = {};
end
event.onloadstate(clearFlagCache, "ScriptHawk - Clear Flag Cache");

local flag_block_size = 0xB0;
local flag_array = {
	-- 0x00 > 0
	{byte=0x00, bit=1, name="First Time Note Collection", type="FTT"},
	{byte=0x00, bit=2, name="First Time Glowbo Collection", type="FTT"},
	{byte=0x00, bit=3, name="First Time Egg Collection", type="FTT"},
	{byte=0x00, bit=4, name="First Time Red Feather Collection", type="FTT"},
	{byte=0x00, bit=5, name="First Time Gold Feather Collection", type="FTT"},
	{byte=0x00, bit=6, name="First Time Treble Clef Collection", type="FTT"},
	{byte=0x00, bit=7, name="First Time Health Collection", type="FTT"},
	-- 0x01 > 0
	-- 0x01 > 1
	{byte=0x01, bit=2, name="First Time Empty Honeycomb Collection", type="FTT"},
	-- 0x01 > 3
	-- 0x01 > 4
	{byte=0x01, bit=5, name="First Time Jinjo Collection", type="FTT"},
	-- 0x01 > 6
	-- 0x01 > 7
	-- 0x02 > 0
	-- 0x02 > 1
	{byte=0x02, bit=2, name="Signpost FTT", type="FTT"},
	-- 0x02 > 3
	{byte=0x02, bit=4, name="Klungo Intro Cutscene"},
	-- 0x02 > 5
	-- 0x02 > 6
	-- 0x02 > 7
	-- 0x03 > 0
	-- 0x03 > 1
	-- 0x03 > 2
	-- 0x03 > 3
	-- 0x03 > 4
	-- 0x03 > 5
	-- 0x03 > 6
	-- 0x03 > 7
	-- 0x04 > 0
	-- 0x04 > 1
	-- 0x04 > 2
	-- 0x04 > 3
	{byte=0x04, bit=4, name="Cheat Active: Open Up All World Doors", type="Cheat"},
	-- 0x04 > 5
	-- 0x04 > 6
	-- 0x04 > 7
	{byte=0x05, bit=0, name="Golden Goliath Instructions", type="FTT"},
	-- 0x05 > 1
	-- 0x05 > 2
	-- 0x05 > 3
	-- 0x05 > 4
	-- 0x05 > 5
	-- 0x05 > 6
	{byte=0x05, bit=7, name="First Time Minjo Aggro", type="FTT"},
	-- 0x06 > 0
	-- 0x06 > 1
	-- 0x06 > 2
	-- 0x06 > 3
	-- 0x06 > 4
	-- 0x06 > 5
	-- 0x06 > 6
	-- 0x06 > 7
	-- 0x07 > 0
	-- 0x07 > 1
	-- 0x07 > 2
	-- 0x07 > 3
	-- 0x07 > 4
	-- 0x07 > 5
	-- 0x07 > 6
	{byte=0x07, bit=7, name="First Time Cheato Page", type="FTT"},
	{byte=0x08, bit=0, name="Cheato FTT", type="FTT"},
	-- 0x08 > 1
	{byte=0x08, bit=2, name="Cheato Podium FTT", type="FTT"},
	-- 0x08 > 3
	-- 0x08 > 4
	-- 0x08 > 5
	-- 0x08 > 6
	-- 0x08 > 7
	-- 0x09 > 0
	-- 0x09 > 1
	-- 0x09 > 2
	-- 0x09 > 3
	-- 0x09 > 4
	-- 0x09 > 5
	-- 0x09 > 6
	-- 0x09 > 7
	-- 0x0A > 0
	-- 0x0A > 1
	-- 0x0A > 2
	-- 0x0A > 3
	-- 0x0A > 4
	{byte=0x0A, bit=5, name="Mumbo FTT", type="FTT"},
	-- 0x0A > 6
	-- 0x0A > 7
	-- 0x0B > 0
	-- 0x0B > 1
	-- 0x0B > 2
	-- 0x0B > 3
	-- 0x0B > 4
	-- 0x0B > 5
	-- 0x0B > 6
	-- 0x0B > 7
	-- 0x0C > 0 Targitzan Fight?
	-- 0x0C > 1
	-- 0x0C > 2
	-- 0x0C > 3
	-- 0x0C > 4
	-- 0x0C > 5
	-- 0x0C > 6
	{byte=0x0C, bit=7, name="Humba Wumba FTT", type="FTT"},
	-- 0x0D > 0
	-- 0x0D > 1
	-- 0x0D > 2
	-- 0x0D > 3
	-- 0x0D > 4
	-- 0x0D > 5
	-- 0x0D > 6
	-- 0x0D > 7
	-- 0x0E > 0
	-- 0x0E > 1
	{byte=0x0E, bit=2, name="First Time Mumbo Pad Text", type="FTT"},
	{byte=0x0E, bit=3, name="First Time Mumbo Pad Instructions", type="FTT"},
	-- 0x0E > 4
	{byte=0x0E, bit=5, name="WW: Big Al FTT", type="FTT"},
	-- 0x0E > 6
	{byte=0x0E, bit=7, name="WW: Big Al's Open", type="Physical"},
	{byte=0x0F, bit=0, name="WW: Salty Joe's Open", type="Physical"},

	-- 0x13 > 0
	{byte=0x13, bit=1, name="Klungo 1 Potion Chosen?"},
	{byte=0x13, bit=2, name="Jolly's Room Rented", type="Physical"},
	{byte=0x13, bit=3, name="Jolly FTT", type="FTT"},
	-- 0x13 > 4
	-- 0x13 > 5
	-- 0x13 > 6
	-- 0x13 > 7
	-- 0x14 > 0
	-- 0x14 > 1
	-- 0x14 > 2
	-- 0x14 > 3
	-- 0x14 > 4
	{byte=0x14, bit=5, name="JRL: Waste Pipe Drilled", type="Physical"},
	-- 0x14 > 6
	-- 0x14 > 7
	-- 0x15 > 0
	-- 0x15 > 1
	-- 0x15 > 2
	{byte=0x15, bit=3, name="Cheat Menu FTT", type="FTT"},
	-- 0x15 > 4
	-- 0x15 > 5
	{byte=0x15, bit=6, name="Humba Wumba: Glowbo Paid (MT)", type="Glowbo Paid"},
	{byte=0x15, bit=7, name="Humba Wumba: Glowbo Paid (GGM)", type="Glowbo Paid"},
	{byte=0x16, bit=0, name="Humba Wumba: Glowbo Paid (WW)", type="Glowbo Paid"},
	{byte=0x16, bit=1, name="Humba Wumba: Glowbo Paid (JRL)", type="Glowbo Paid"},
	{byte=0x16, bit=2, name="Humba Wumba: Glowbo Paid (TDL)", type="Glowbo Paid"},
	{byte=0x16, bit=3, name="Humba Wumba: Glowbo Paid (GI)", type="Glowbo Paid"},
	{byte=0x16, bit=4, name="Humba Wumba: Glowbo Paid (HFP)", type="Glowbo Paid"},
	{byte=0x16, bit=5, name="Humba Wumba: Glowbo Paid (CCL)", type="Glowbo Paid"},
	-- 0x16 > 6
	-- 0x16 > 7
	-- 0x17 > 0
	-- 0x17 > 1
	{byte=0x17, bit=2, name="Humba Wumba: Detransform Instructions", type="FTT"},
	-- 0x17 > 3
	{byte=0x17, bit=4, name="Captain Blackeye FTT", type="FTT"},
	-- 0x17 > 5
	-- 0x17 > 6
	-- 0x17 > 7
	-- 0x18 > 0
	{byte=0x18, bit=1, name="Mumbo's Magic: Sunlight: Oxygenated Water", type="Mumbo's Magic"},
	{byte=0x18, bit=2, name="Mumbo's Magic: Power: Star Spinner", type="Mumbo's Magic"},
	{byte=0x18, bit=3, name="Mumbo's Magic: Power: Saucer of Peril", type="Mumbo's Magic"},
	{byte=0x18, bit=4, name="Mumbo's Magic: Power: Dodgem Dome", type="Mumbo's Magic"},
	{byte=0x18, bit=5, name="Ability: Beak Barge", type="Ability"},
	{byte=0x18, bit=6, name="Ability: Beak Bomb", type="Ability"},
	{byte=0x18, bit=7, name="Ability: Beak Buster", type="Ability"},
	--{byte=0x19, bit=0, name="Ability: Seen Camera Tutorial???"}, -- Set on boot
	{byte=0x19, bit=1, name="Ability: Bear Punch Replacement Peck", type="Ability"},
	{byte=0x19, bit=2, name="Ability: Climb Trees", type="Ability"},
	{byte=0x19, bit=3, name="Ability: Blue Eggs", type="Ability"},
	{byte=0x19, bit=4, name="Ability: Feathery Flap", type="Ability"},
	{byte=0x19, bit=5, name="Ability: Flap Flip", type="Ability"},
	{byte=0x19, bit=6, name="Ability: Fly Pad", type="Ability"},
	{byte=0x19, bit=7, name="Ability: Full Jump Height", type="Ability"},
	{byte=0x1A, bit=0, name="Ability: Rat-a-tat Rap", type="Ability"},
	{byte=0x1A, bit=1, name="Ability: Roll", type="Ability"},
	{byte=0x1A, bit=2, name="Ability: Shock Spring Pad", type="Ability"},
	{byte=0x1A, bit=3, name="Ability: Wading Boots", type="Ability"},
	{byte=0x1A, bit=4, name="Ability: Dive", type="Ability"},
	{byte=0x1A, bit=5, name="Ability: Talon Trot", type="Ability"},
	{byte=0x1A, bit=6, name="Ability: Turbo Trainers", type="Ability"},
	{byte=0x1A, bit=7, name="Ability: Wonderwing", type="Ability"},
	--{byte=0x1B, bit=0, name="FT Note Door Molehill Seen?", type="FTT"}, -- Set on boot
	{byte=0x1B, bit=1, name="Ability: Grip Grab", type="Ability"},
	{byte=0x1B, bit=2, name="Ability: Breegull Blaster", type="Ability"},
	{byte=0x1B, bit=3, name="Ability: Egg Aim", type="Ability"},
	-- 0x1B > 4
	--{byte=0x1B, bit=5, name="Ability: Fire/Grenade Eggs???", type="Ability"},
	{byte=0x1B, bit=6, name="Ability: Bill Drill", type="Ability"},
	{byte=0x1B, bit=7, name="Ability: Beak Bayonet", type="Ability"},
	{byte=0x1C, bit=0, name="Ability: Airborne Egg Aiming", type="Ability"},
	{byte=0x1C, bit=1, name="Ability: Split Up", type="Ability"},
	{byte=0x1C, bit=2, name="Ability: Wing Whack", type="Ability"},
	{byte=0x1C, bit=3, name="Ability: Talon Torpedo", type="Ability"},
	{byte=0x1C, bit=4, name="Ability: Sub-Aqua Egg Aiming", type="Ability"},
	-- 0x1C > 5
	{byte=0x1C, bit=6, name="Ability: Shack Pack", type="Ability"},
	{byte=0x1C, bit=7, name="Ability: Glide", type="Ability"},
	{byte=0x1D, bit=0, name="Ability: Snooze Pack", type="Ability"},
	{byte=0x1D, bit=1, name="Ability: Leg Spring", type="Ability"},
	{byte=0x1D, bit=2, name="Ability: Claw Clamber Boots", type="Ability"},
	{byte=0x1D, bit=3, name="Ability: Springy Step Shoes", type="Ability"},
	{byte=0x1D, bit=4, name="Ability: Taxi Pack", type="Ability"},
	{byte=0x1D, bit=5, name="Ability: Hatch", type="Ability"},
	{byte=0x1D, bit=6, name="Ability: Pack Whack", type="Ability"},
	{byte=0x1D, bit=7, name="Ability: Sack Pack", type="Ability"},
	{byte=0x1E, bit=0, name="Ability: Amaze-O-Gaze Goggles", type="Ability"},
	{byte=0x1E, bit=1, name="Ability: Fire Eggs", type="Ability"},
	{byte=0x1E, bit=2, name="Ability: Grenade Eggs", type="Ability"},
	{byte=0x1E, bit=3, name="Ability: Clockwork Kazooie Eggs", type="Ability"},
	{byte=0x1E, bit=4, name="Ability: Ice Eggs", type="Ability"},
	-- 0x1E > 5
	{byte=0x1E, bit=6, name="FT Ability Use? (1)"}, -- Set on boot
	-- 0x1E > 7
	-- 0x1F > 0
	-- 0x1F > 1
	-- 0x1F > 2
	-- 0x1F > 3
	-- 0x1F > 4
	-- 0x1F > 5
	-- 0x1F > 6
	-- 0x1F > 7
	-- 0x20 > 0
	-- 0x20 > 1
	{byte=0x20, bit=2, name="FT Ability Use? (2)"}, -- Set on boot
	{byte=0x20, bit=3, name="FT Ability Use? (3)"}, -- Set on boot
	{byte=0x20, bit=4, name="FT Ability Use? (4)"}, -- Set on boot
	{byte=0x20, bit=5, name="FT Ability Use? (5)"}, -- Set on boot
	{byte=0x20, bit=6, name="FT Ability Use? (6)"}, -- Set on boot
	{byte=0x20, bit=7, name="FT Ability Use? (7)"}, -- Set on boot
	{byte=0x21, bit=0, name="FT Ability Use? (8)"}, -- Set on boot
	{byte=0x21, bit=1, name="FT Ability Use? (9)"}, -- Set on boot
	{byte=0x21, bit=2, name="FT Ability Use? (10)"}, -- Set on boot
	{byte=0x21, bit=3, name="FT Ability Use? (11)"}, -- Set on boot
	{byte=0x21, bit=4, name="FT Ability Use? (12)"}, -- Set on boot
	{byte=0x21, bit=5, name="FT Ability Use? (13)"}, -- Set on boot
	{byte=0x21, bit=6, name="FT Ability Use? (14)"}, -- Set on boot
	-- 0x21 > 7
	-- 0x22 > 0
	-- 0x22 > 1
	-- 0x22 > 2
	-- 0x22 > 3
	-- 0x22 > 4
	-- 0x22 > 5
	-- 0x22 > 6
	{byte=0x22, bit=7, name="Doubloon: Town Center Pole (1)", type="Doubloon"},
	{byte=0x23, bit=0, name="Doubloon: Town Center Pole (2)", type="Doubloon"},
	{byte=0x23, bit=1, name="Doubloon: Town Center Pole (3)", type="Doubloon"},
	{byte=0x23, bit=2, name="Doubloon: Town Center Pole (4)", type="Doubloon"},
	{byte=0x23, bit=3, name="Doubloon: Town Center Pole (5)", type="Doubloon"},
	{byte=0x23, bit=4, name="Doubloon: Town Center Pole (6)", type="Doubloon"},
	{byte=0x23, bit=5, name="Doubloon: Silo (1)", type="Doubloon"},
	{byte=0x23, bit=6, name="Doubloon: Silo (2)", type="Doubloon"},
	{byte=0x23, bit=7, name="Doubloon: Silo (3)", type="Doubloon"},
	{byte=0x24, bit=0, name="Doubloon: Silo (4)", type="Doubloon"},
	{byte=0x24, bit=1, name="Doubloon: Toxic Pool (1)", type="Doubloon"},
	{byte=0x24, bit=2, name="Doubloon: Toxic Pool (2)", type="Doubloon"},
	{byte=0x24, bit=3, name="Doubloon: Toxic Pool (3)", type="Doubloon"},
	{byte=0x24, bit=4, name="Doubloon: Toxic Pool (4)", type="Doubloon"},
	{byte=0x24, bit=5, name="Doubloon: Mumbo's Skull (1)", type="Doubloon"},
	{byte=0x24, bit=6, name="Doubloon: Mumbo's Skull (2)", type="Doubloon"},
	{byte=0x24, bit=7, name="Doubloon: Mumbo's Skull (3)", type="Doubloon"},
	{byte=0x25, bit=0, name="Doubloon: Mumbo's Skull (4)", type="Doubloon"},
	{byte=0x25, bit=1, name="Doubloon: Underground (1)", type="Doubloon"},
	{byte=0x25, bit=2, name="Doubloon: Underground (2)", type="Doubloon"},
	{byte=0x25, bit=3, name="Doubloon: Underground (3)", type="Doubloon"},
	{byte=0x25, bit=4, name="Doubloon: Shock Spring Alcove (1)", type="Doubloon"},
	{byte=0x25, bit=5, name="Doubloon: Shock Spring Alcove (2)", type="Doubloon"},
	{byte=0x25, bit=6, name="Doubloon: Shock Spring Alcove (3)", type="Doubloon"},
	-- 0x25 > 7 Doubloon: Captain Blackeye?
	-- 0x26 > 0 Doubloon: Captain Blackeye?
	{byte=0x26, bit=1, name="Doubloon: Near Jinjo (1)", type="Doubloon"},
	{byte=0x26, bit=2, name="Doubloon: Near Jinjo (2)", type="Doubloon"},
	{byte=0x26, bit=3, name="Doubloon: Near Jinjo (3)", type="Doubloon"},
	{byte=0x26, bit=4, name="Doubloon: Near Jinjo (4)", type="Doubloon"},
	-- 0x26 > 5
	-- 0x26 > 6
	-- 0x26 > 7
	-- 0x27 > 0
	-- 0x27 > 1
	-- 0x27 > 2
	-- 0x27 > 3
	{byte=0x27, bit=4, name="Chuffy: TDL Station Open", type="Physical"},
	{byte=0x27, bit=5, name="FT Doubloon Collection", type="FTT"},

	{byte=0x2C, bit=2, name="TDL: Wigwam Enlarged", type="Physical"},

	{byte=0x2F, bit=5, name="FT Jiggy Collection?"},
	{byte=0x2F, bit=7, name="Mrs. Bottles Intro Cutscene", type="FTT"},

	{byte=0x30, bit=0, name="Speccy Intro Text Seen", type="FTT"},
	{byte=0x30, bit=1, name="Amaze-O-Gaze Goggles Instructions Seen"},

	--{byte=0x32, bit=2, name="Klungo 2 Something?"},

	{byte=0x35, bit=1, name="Humba Wumba: No Glowbo Needed FTT", type="FTT"},

	{byte=0x37, bit=1, name="CCL: Rainbow Spawned", type="Physical"},

	{byte=0x38, bit=4, name="FT Enter Jinjo Village?"},
	-- 0x38 > 5
	-- 0x38 > 6
	-- 0x38 > 7
	-- 0x39 > 0
	-- 0x39 > 1
	-- 0x39 > 2
	-- 0x39 > 3
	{byte=0x39, bit=4, name="Jinjo: MT: Jade Snake Grove", type="Jinjo"},
	{byte=0x39, bit=5, name="Jinjo: MT: Roof of Stadium", type="Jinjo"},
	{byte=0x39, bit=6, name="Jinjo: MT: Targitzan's Temple", type="Jinjo"},
	{byte=0x39, bit=7, name="Jinjo: MT: Pool of Water", type="Jinjo"},
	{byte=0x3A, bit=0, name="Jinjo: MT: Bridge", type="Jinjo"},
	{byte=0x3A, bit=1, name="Jinjo: GGM: Water Storage", type="Jinjo"},
	{byte=0x3A, bit=2, name="Jinjo: GGM: Jail", type="Jinjo"},
	{byte=0x3A, bit=3, name="Jinjo: GGM: ??? (3)", type="Jinjo"},
	{byte=0x3A, bit=4, name="Jinjo: GGM: ??? (4)", type="Jinjo"},
	{byte=0x3A, bit=5, name="Jinjo: GGM: Mine Tracks", type="Jinjo"},
	{byte=0x3A, bit=6, name="Jinjo: WW: Big Top", type="Jinjo"},
	{byte=0x3A, bit=7, name="Jinjo: WW: Cave of Horrors", type="Jinjo"},
	{byte=0x3B, bit=0, name="Jinjo: WW: Van Door", type="Jinjo"},
	{byte=0x3B, bit=1, name="Jinjo: WW: Dodgem Dome", type="Jinjo"},
	{byte=0x3B, bit=2, name="Jinjo: WW: Cactus of Strength", type="Jinjo"},
	{byte=0x3B, bit=3, name="Jinjo: JRL: ??? (1)", type="Jinjo"},
	{byte=0x3B, bit=4, name="Jinjo: JRL: ??? (2)", type="Jinjo"},
	{byte=0x3B, bit=5, name="Jinjo: JRL: ??? (3)", type="Jinjo"},
	{byte=0x3B, bit=6, name="Jinjo: JRL: ??? (4)", type="Jinjo"},
	{byte=0x3B, bit=7, name="Jinjo: JRL: ??? (5)", type="Jinjo"},
	{byte=0x3C, bit=0, name="Jinjo: TDL: ??? (1)", type="Jinjo"},
	{byte=0x3C, bit=1, name="Jinjo: TDL: ??? (2)", type="Jinjo"},
	{byte=0x3C, bit=2, name="Jinjo: TDL: Big T. Rex Skip", type="Jinjo"},
	{byte=0x3C, bit=3, name="Jinjo: TDL: ??? (4)", type="Jinjo"},
	{byte=0x3C, bit=4, name="Jinjo: TDL: ??? (5)", type="Jinjo"},
	{byte=0x3C, bit=5, name="Jinjo: GI: ??? (1)", type="Jinjo"},
	{byte=0x3C, bit=6, name="Jinjo: GI: ??? (2)", type="Jinjo"},
	{byte=0x3C, bit=7, name="Jinjo: GI: ??? (3)", type="Jinjo"},
	{byte=0x3D, bit=0, name="Jinjo: GI: ??? (4)", type="Jinjo"},
	{byte=0x3D, bit=1, name="Jinjo: GI: ??? (5)", type="Jinjo"},
	{byte=0x3D, bit=2, name="Jinjo: HFP: Lava Waterfall", type="Jinjo"},
	{byte=0x3D, bit=3, name="Jinjo: HFP: Boiling Hot Pool", type="Jinjo"},
	{byte=0x3D, bit=4, name="Jinjo: HFP: Windy Hole", type="Jinjo"},
	{byte=0x3D, bit=5, name="Jinjo: HFP: Icicle Grotto", type="Jinjo"},
	{byte=0x3D, bit=6, name="Jinjo: HFP: Mildred Ice Cube", type="Jinjo"},
	{byte=0x3D, bit=7, name="Jinjo: CCL: Trash Can", type="Jinjo"},
	{byte=0x3E, bit=0, name="Jinjo: CCL: Cheese Wedge", type="Jinjo"},
	{byte=0x3E, bit=1, name="Jinjo: CCL: Central Cavern", type="Jinjo"},
	{byte=0x3E, bit=2, name="Jinjo: CCL: Mingy Jongo", type="Jinjo"},
	{byte=0x3E, bit=3, name="Jinjo: CCL: Wumba's", type="Jinjo"},
	{byte=0x3E, bit=4, name="Jinjo: IoH: Wooded Hollow", type="Jinjo"},
	{byte=0x3E, bit=5, name="Jinjo: IoH: Wasteland", type="Jinjo"},
	{byte=0x3E, bit=6, name="Jinjo: IoH: Cliff Top", type="Jinjo"},
	{byte=0x3E, bit=7, name="Jinjo: IoH: Plateau", type="Jinjo"},
	{byte=0x3F, bit=0, name="Jinjo: IoH: Spiral Mountain", type="Jinjo"},
	-- 0x3F > 1
	{byte=0x3F, bit=2, name="Honeycomb: MT: Entrance", type="Honeycomb"},
	{byte=0x3F, bit=3, name="Honeycomb: MT: Bovina", type="Honeycomb"},
	{byte=0x3F, bit=4, name="Honeycomb: MT: Treasure Chamber", type="Honeycomb"},
	{byte=0x3F, bit=5, name="Honeycomb: GGM: Boulder (Toxic Gas Cave)", type="Honeycomb"},
	{byte=0x3F, bit=6, name="Honeycomb: GGM: Boulder", type="Honeycomb"},
	{byte=0x3F, bit=7, name="Honeycomb: GGM: Train Station", type="Honeycomb"},
	{byte=0x40, bit=0, name="Honeycomb: WW: Space Zone", type="Honeycomb"},
	{byte=0x40, bit=1, name="Honeycomb: WW: Mumbo's Skull", type="Honeycomb"},
	{byte=0x40, bit=2, name="Honeycomb: WW: Crazy Castle Area", type="Honeycomb"},
	{byte=0x40, bit=3, name="Honeycomb: JRL: ??? (1)", type="Honeycomb"},
	{byte=0x40, bit=4, name="Honeycomb: JRL: Atlantis", type="Honeycomb"},
	{byte=0x40, bit=5, name="Honeycomb: JRL: Waste Pipe", type="Honeycomb"},
	{byte=0x40, bit=6, name="Honeycomb: TDL: ??? (1)", type="Honeycomb"},
	{byte=0x40, bit=7, name="Honeycomb: TDL: ??? (2)", type="Honeycomb"},
	{byte=0x41, bit=0, name="Honeycomb: TDL: ??? (3)", type="Honeycomb"},
	{byte=0x41, bit=1, name="Honeycomb: GI: ??? (1)", type="Honeycomb"},
	{byte=0x41, bit=2, name="Honeycomb: GI: Chimney", type="Honeycomb"},
	{byte=0x41, bit=3, name="Honeycomb: GI: ??? (3)", type="Honeycomb"},
	{byte=0x41, bit=4, name="Honeycomb: HFP: ??? (1)", type="Honeycomb"},
	{byte=0x41, bit=5, name="Honeycomb: HFP: ??? (2)", type="Honeycomb"},
	{byte=0x41, bit=6, name="Honeycomb: HFP: ??? (3)", type="Honeycomb"},
	{byte=0x41, bit=7, name="Honeycomb: CCL: Underground", type="Honeycomb"},
	{byte=0x42, bit=0, name="Honeycomb: CCL: ??? (2)", type="Honeycomb"},
	{byte=0x42, bit=1, name="Honeycomb: CCL: ??? (3)", type="Honeycomb"},
	{byte=0x42, bit=2, name="Honeycomb: IoH: Plateau", type="Honeycomb"},
	-- 0x42 > 3
	-- 0x42 > 4
	-- 0x42 > 5
	-- 0x42 > 6
	{byte=0x42, bit=7, name="Glowbo: MT: Mumbo's Skull", type="Glowbo"},
	{byte=0x43, bit=0, name="Glowbo: MT: Behind Wigwam", type="Glowbo"},
	{byte=0x43, bit=1, name="Glowbo: GGM: Near Entrance", type="Glowbo"},
	{byte=0x43, bit=2, name="Glowbo: GGM: Mine Entrance 2", type="Glowbo"},
	{byte=0x43, bit=3, name="Glowbo: WW: The Inferno", type="Glowbo"},
	{byte=0x43, bit=4, name="Glowbo: WW: Inside Wigwam", type="Glowbo"},
	{byte=0x43, bit=5, name="Glowbo: JRL: ??? (1)", type="Glowbo"},
	{byte=0x43, bit=6, name="Glowbo: JRL: ??? (2)", type="Glowbo"},
	{byte=0x43, bit=7, name="Glowbo: TDL: ??? (1)", type="Glowbo"},
	{byte=0x44, bit=0, name="Glowbo: TDL: ??? (2)", type="Glowbo"},
	{byte=0x44, bit=1, name="Glowbo: GI: ??? (1)", type="Glowbo"},
	{byte=0x44, bit=2, name="Glowbo: GI: ??? (2)", type="Glowbo"},
	{byte=0x44, bit=3, name="Glowbo: HFP: ??? (1)", type="Glowbo"},
	{byte=0x44, bit=4, name="Glowbo: HFP: ??? (2)", type="Glowbo"},
	{byte=0x44, bit=5, name="Glowbo: CCL: ??? (1)", type="Glowbo"},
	{byte=0x44, bit=6, name="Glowbo: CCL: ??? (2)", type="Glowbo"},
	{byte=0x44, bit=7, name="Glowbo: IoH: ??? (1)", type="Glowbo"},
	{byte=0x45, bit=0, name="Jiggy: MT: Targitzan", type="Jiggy"},
	{byte=0x45, bit=1, name="Jiggy: MT: Targitzan's Slightly Sacred Chamber", type="Jiggy"},
	{byte=0x45, bit=2, name="Jiggy: MT: ??? (3)", type="Jiggy"},
	{byte=0x45, bit=3, name="Jiggy: MT: ??? (4)", type="Jiggy"},
	{byte=0x45, bit=4, name="Jiggy: MT: ??? (5)", type="Jiggy"},
	{byte=0x45, bit=5, name="Jiggy: MT: Jade Snake Grove: Golden Goliath", type="Jiggy"},
	{byte=0x45, bit=6, name="Jiggy: MT: ??? (7)", type="Jiggy"},
	{byte=0x45, bit=7, name="Jiggy: MT: Pillars", type="Jiggy"},
	{byte=0x46, bit=0, name="Jiggy: MT: Top of Temple", type="Jiggy"},
	{byte=0x46, bit=1, name="Jiggy: MT: Ssslumber", type="Jiggy"},
	{byte=0x46, bit=2, name="Jiggy: GGM: ??? (1)", type="Jiggy"},
	{byte=0x46, bit=3, name="Jiggy: GGM: ??? (2)", type="Jiggy"},
	{byte=0x46, bit=4, name="Jiggy: GGM: Generator Cavern", type="Jiggy"},
	{byte=0x46, bit=5, name="Jiggy: GGM: ??? (4)", type="Jiggy"},
	{byte=0x46, bit=6, name="Jiggy: GGM: Ordnance Storage", type="Jiggy"},
	{byte=0x46, bit=7, name="Jiggy: GGM: ??? (6)", type="Jiggy"},
	{byte=0x47, bit=0, name="Jiggy: GGM: ??? (7)", type="Jiggy"},
	{byte=0x47, bit=1, name="Jiggy: GGM: Waterfall", type="Jiggy"},
	{byte=0x47, bit=2, name="Jiggy: GGM: Power Hut Basement", type="Jiggy"},
	{byte=0x47, bit=3, name="Jiggy: GGM: Flooded Caves", type="Jiggy"},
	{byte=0x47, bit=4, name="Jiggy: WW: ??? (1)", type="Jiggy"},
	{byte=0x47, bit=5, name="Jiggy: WW: ??? (2)", type="Jiggy"},
	{byte=0x47, bit=6, name="Jiggy: WW: ??? (3)", type="Jiggy"},
	{byte=0x47, bit=7, name="Jiggy: WW: ??? (4)", type="Jiggy"},
	{byte=0x48, bit=0, name="Jiggy: WW: ??? (5)", type="Jiggy"},
	{byte=0x48, bit=1, name="Jiggy: WW: Dive of Death", type="Jiggy"},
	{byte=0x48, bit=2, name="Jiggy: WW: ??? (7)", type="Jiggy"},
	{byte=0x48, bit=3, name="Jiggy: WW: Star Spinner", type="Jiggy"},
	{byte=0x48, bit=4, name="Jiggy: WW: The Inferno", type="Jiggy"},
	{byte=0x48, bit=5, name="Jiggy: WW: ??? (10)", type="Jiggy"},
	{byte=0x48, bit=6, name="Jiggy: JRL: ??? (1)", type="Jiggy"},
	{byte=0x48, bit=7, name="Jiggy: JRL: ??? (2)", type="Jiggy"},
	{byte=0x49, bit=0, name="Jiggy: JRL: ??? (3)", type="Jiggy"},
	{byte=0x49, bit=1, name="Jiggy: JRL: ??? (4)", type="Jiggy"},
	{byte=0x49, bit=2, name="Jiggy: JRL: Smuggler's Cavern", type="Jiggy"},
	{byte=0x49, bit=3, name="Jiggy: JRL: ??? (6)", type="Jiggy"},
	{byte=0x49, bit=4, name="Jiggy: JRL: ??? (7)", type="Jiggy"},
	{byte=0x49, bit=5, name="Jiggy: JRL: Seemee", type="Jiggy"},
	{byte=0x49, bit=6, name="Jiggy: JRL: ??? (9)", type="Jiggy"},
	{byte=0x49, bit=7, name="Jiggy: JRL: ??? (10)", type="Jiggy"},
	{byte=0x4A, bit=0, name="Jiggy: TDL: ??? (1)", type="Jiggy"},
	{byte=0x4A, bit=1, name="Jiggy: TDL: ??? (2)", type="Jiggy"},
	{byte=0x4A, bit=2, name="Jiggy: TDL: ??? (3)", type="Jiggy"},
	{byte=0x4A, bit=3, name="Jiggy: TDL: ??? (4)", type="Jiggy"},
	{byte=0x4A, bit=4, name="Jiggy: TDL: ??? (5)", type="Jiggy"},
	{byte=0x4A, bit=5, name="Jiggy: TDL: ??? (6)", type="Jiggy"},
	{byte=0x4A, bit=6, name="Jiggy: TDL: ??? (7)", type="Jiggy"},
	{byte=0x4A, bit=7, name="Jiggy: TDL: ??? (8)", type="Jiggy"},
	{byte=0x4B, bit=0, name="Jiggy: TDL: ??? (9)", type="Jiggy"},
	{byte=0x4B, bit=1, name="Jiggy: TDL: ??? (10)", type="Jiggy"},
	{byte=0x4B, bit=2, name="Jiggy: GI: Waste Disposal Underwater", type="Jiggy"},
	{byte=0x4B, bit=3, name="Jiggy: GI: Giant Fan", type="Jiggy"},
	{byte=0x4B, bit=4, name="Jiggy: GI: ??? (3)", type="Jiggy"},
	{byte=0x4B, bit=5, name="Jiggy: GI: ??? (4)", type="Jiggy"},
	{byte=0x4B, bit=6, name="Jiggy: GI: ??? (5)", type="Jiggy"},
	{byte=0x4B, bit=7, name="Jiggy: GI: ??? (6)", type="Jiggy"},
	{byte=0x4C, bit=0, name="Jiggy: GI: ??? (7)", type="Jiggy"},
	{byte=0x4C, bit=1, name="Jiggy: GI: ??? (8)", type="Jiggy"},
	{byte=0x4C, bit=2, name="Jiggy: GI: ??? (9)", type="Jiggy"},
	{byte=0x4C, bit=3, name="Jiggy: GI: Waste Disposal Box", type="Jiggy"},
	{byte=0x4C, bit=4, name="Jiggy: HFP: ??? (1)", type="Jiggy"},
	{byte=0x4C, bit=5, name="Jiggy: HFP: ??? (2)", type="Jiggy"},
	{byte=0x4C, bit=6, name="Jiggy: HFP: ??? (3)", type="Jiggy"},
	{byte=0x4C, bit=7, name="Jiggy: HFP: ??? (4)", type="Jiggy"},
	{byte=0x4D, bit=0, name="Jiggy: HFP: ??? (5)", type="Jiggy"},
	{byte=0x4D, bit=1, name="Jiggy: HFP: ??? (6)", type="Jiggy"},
	{byte=0x4D, bit=2, name="Jiggy: HFP: ??? (7)", type="Jiggy"},
	{byte=0x4D, bit=3, name="Jiggy: HFP: ??? (8)", type="Jiggy"},
	{byte=0x4D, bit=4, name="Jiggy: HFP: ??? (9)", type="Jiggy"},
	{byte=0x4D, bit=5, name="Jiggy: HFP: Lava Waterfall", type="Jiggy"},
	{byte=0x4D, bit=6, name="Jiggy: CCL: ??? (1)", type="Jiggy"},
	{byte=0x4D, bit=7, name="Jiggy: CCL: ??? (2)", type="Jiggy"},
	{byte=0x4E, bit=0, name="Jiggy: CCL: ??? (3)", type="Jiggy"},
	{byte=0x4E, bit=1, name="Jiggy: CCL: ??? (4)", type="Jiggy"},
	{byte=0x4E, bit=2, name="Jiggy: CCL: ??? (5)", type="Jiggy"},
	{byte=0x4E, bit=3, name="Jiggy: CCL: ??? (6)", type="Jiggy"},
	{byte=0x4E, bit=4, name="Jiggy: CCL: ??? (7)", type="Jiggy"},
	{byte=0x4E, bit=5, name="Jiggy: CCL: ??? (8)", type="Jiggy"},
	{byte=0x4E, bit=6, name="Jiggy: CCL: Superstash", type="Jiggy"},
	{byte=0x4E, bit=7, name="Jiggy: CCL: ??? (10)", type="Jiggy"},
	{byte=0x4F, bit=0, name="Jiggy: IoH: White Jinjo Family", type="Jiggy"},
	{byte=0x4F, bit=1, name="Jiggy: IoH: ??? (2)", type="Jiggy"},
	{byte=0x4F, bit=2, name="Jiggy: IoH: ??? (3)", type="Jiggy"},
	{byte=0x4F, bit=3, name="Jiggy: IoH: ??? (4)", type="Jiggy"},
	{byte=0x4F, bit=4, name="Jiggy: IoH: ??? (5)", type="Jiggy"},
	{byte=0x4F, bit=5, name="Jiggy: IoH: ??? (6)", type="Jiggy"},
	{byte=0x4F, bit=6, name="Jiggy: IoH: ??? (7)", type="Jiggy"},
	{byte=0x4F, bit=7, name="Jiggy: IoH: ??? (8)", type="Jiggy"},
	{byte=0x50, bit=0, name="Jiggy: IoH: ??? (9)", type="Jiggy"},
	{byte=0x50, bit=1, name="Jiggy: IoH: King Jingaling Intro", type="Jiggy"},
	-- 0x50 > 2
	-- 0x50 > 3
	-- 0x50 > 4
	-- 0x50 > 5
	-- 0x50 > 6
	-- 0x50 > 7
	-- 0x51 > 0
	-- 0x51 > 1
	-- 0x51 > 2
	-- 0x51 > 3
	-- 0x51 > 4
	-- 0x51 > 5
	-- 0x51 > 6
	-- 0x51 > 7
	-- 0x52 > 0
	-- 0x52 > 1
	-- 0x52 > 2
	-- 0x52 > 3
	-- 0x52 > 4
	-- 0x52 > 5
	-- 0x52 > 6
	-- 0x52 > 7
	-- 0x53 > 0
	-- 0x53 > 1
	-- 0x53 > 2
	-- 0x53 > 3
	-- 0x53 > 4
	-- 0x53 > 5
	{byte=0x53, bit=6, name="FT Jiggy Collection??"},
	-- 0x53 > 7
	-- 0x54 > 0
	-- 0x54 > 1
	-- 0x54 > 2
	-- 0x54 > 3
	-- 0x54 > 4
	-- 0x54 > 5
	-- 0x54 > 6
	-- 0x54 > 7 Set and cleared upon entering/exiting CCL overworld
	-- 0x55 > 0
	-- 0x55 > 1
	-- 0x55 > 2
	-- 0x55 > 3
	-- 0x55 > 4
	-- 0x55 > 5
	-- 0x55 > 6
	{byte=0x55, bit=7, name="GGM: Ordnance Storage Completed", type="Progress"},
	-- 0x56 > 0
	-- 0x56 > 1
	-- 0x56 > 2
	{byte=0x56, bit=3, name="Cheato Page: MT: Snake Heads", type="Cheato Page"},
	{byte=0x56, bit=4, name="Cheato Page: MT: Prison Compound", type="Cheato Page"},
	{byte=0x56, bit=5, name="Cheato Page: MT: Jade Snake Grove", type="Cheato Page"},
	{byte=0x56, bit=6, name="Cheato Page: GGM: ??? (1)", type="Cheato Page"},
	{byte=0x56, bit=7, name="Cheato Page: GGM: Level Entrance", type="Cheato Page"},
	{byte=0x57, bit=0, name="Cheato Page: GGM: Water Storage", type="Cheato Page"},
	{byte=0x57, bit=1, name="Cheato Page: WW: ??? (1)", type="Cheato Page"},
	{byte=0x57, bit=2, name="Cheato Page: WW: The Inferno (Van)", type="Cheato Page"},
	{byte=0x57, bit=3, name="Cheato Page: WW: ??? (3)", type="Cheato Page"},
	{byte=0x57, bit=4, name="Cheato Page: JRL: ??? (1)", type="Cheato Page"},
	{byte=0x57, bit=5, name="Cheato Page: JRL: ??? (2)", type="Cheato Page"},
	{byte=0x57, bit=6, name="Cheato Page: JRL: ??? (3)", type="Cheato Page"},
	{byte=0x57, bit=7, name="Cheato Page: TDL: Dippy's Pool", type="Cheato Page"},
	{byte=0x58, bit=0, name="Cheato Page: TDL: ??? (2)", type="Cheato Page"},
	{byte=0x58, bit=1, name="Cheato Page: TDL: ??? (3)", type="Cheato Page"},
	{byte=0x58, bit=2, name="Cheato Page: GI: ??? (1)", type="Cheato Page"},
	{byte=0x58, bit=3, name="Cheato Page: GI: ??? (2)", type="Cheato Page"},
	{byte=0x58, bit=4, name="Cheato Page: GI: ??? (3)", type="Cheato Page"},
	{byte=0x58, bit=5, name="Cheato Page: HFP: Lava Side", type="Cheato Page"},
	{byte=0x58, bit=6, name="Cheato Page: HFP: Icicle Grotto", type="Cheato Page"},
	{byte=0x58, bit=7, name="Cheato Page: HFP: Icy Side", type="Cheato Page"},
	{byte=0x59, bit=0, name="Cheato Page: CCL: ??? (1)", type="Cheato Page"},
	{byte=0x59, bit=1, name="Cheato Page: CCL: ??? (2)", type="Cheato Page"},
	{byte=0x59, bit=2, name="Cheato Page: CCL: ??? (3)", type="Cheato Page"},
	{byte=0x59, bit=3, name="Cheato Page: Spiral Mountain", type="Cheato Page"},
	-- 0x59 > 4
	-- 0x59 > 5
	-- 0x59 > 6
	-- 0x59 > 7
	-- 0x5A > 0
	-- 0x5A > 1
	-- 0x5A > 2
	-- 0x5A > 3
	{byte=0x5A, bit=4, name="Targitzan Statue (1)", type="Targitzan Statue"},
	{byte=0x5A, bit=5, name="Targitzan Statue (2)", type="Targitzan Statue"},
	{byte=0x5A, bit=6, name="Targitzan Statue (3)", type="Targitzan Statue"},
	{byte=0x5A, bit=7, name="Targitzan Statue (4)", type="Targitzan Statue"},
	{byte=0x5B, bit=0, name="Targitzan Statue (5)", type="Targitzan Statue"},
	{byte=0x5B, bit=1, name="Targitzan Statue (6)", type="Targitzan Statue"},
	{byte=0x5B, bit=2, name="Targitzan Statue (7)", type="Targitzan Statue"},
	{byte=0x5B, bit=3, name="Targitzan Statue (8)", type="Targitzan Statue"},
	{byte=0x5B, bit=4, name="Targitzan Statue (9)", type="Targitzan Statue"},
	{byte=0x5B, bit=5, name="Targitzan Statue (10)", type="Targitzan Statue"},
	{byte=0x5B, bit=6, name="Targitzan Statue (11)", type="Targitzan Statue"},
	{byte=0x5B, bit=7, name="Targitzan Statue (12)", type="Targitzan Statue"},
	{byte=0x5C, bit=0, name="Targitzan Statue (13)", type="Targitzan Statue"},
	{byte=0x5C, bit=1, name="Targitzan Statue (14)", type="Targitzan Statue"},
	{byte=0x5C, bit=2, name="Targitzan Statue (15)", type="Targitzan Statue"},
	{byte=0x5C, bit=3, name="Targitzan Statue (16)", type="Targitzan Statue"},
	{byte=0x5C, bit=4, name="Targitzan Statue (17)", type="Targitzan Statue"},
	{byte=0x5C, bit=5, name="Targitzan Statue (18)", type="Targitzan Statue"},
	{byte=0x5C, bit=6, name="Targitzan Statue (19)", type="Targitzan Statue"},
	{byte=0x5C, bit=7, name="Targitzan Statue (20)", type="Targitzan Statue"},
	{byte=0x5D, bit=0, name="Targitzan Statue (21)", type="Targitzan Statue"},
	{byte=0x5D, bit=1, name="Targitzan Statue (22)", type="Targitzan Statue"},
	{byte=0x5D, bit=2, name="Targitzan Statue (23)", type="Targitzan Statue"},
	{byte=0x5D, bit=3, name="Targitzan Statue (24)", type="Targitzan Statue"},
	{byte=0x5D, bit=4, name="Targitzan Statue (25)", type="Targitzan Statue"},
	{byte=0x5D, bit=5, name="FT Enter Digger Tunnel?"},
	-- 0x5D > 6
	{byte=0x5D, bit=7, name="FT Enter Digger Tunnel??"},
	{byte=0x5E, bit=0, name="Klungo 1 Defeated", type="Progress"},
	{byte=0x5E, bit=1, name="Klungo 2 Defeated", type="Progress"},
	-- 0x5E > 2
	-- 0x5E > 3
	-- 0x5E > 4
	-- 0x5E > 5
	-- 0x5E > 6
	-- 0x5E > 7
	-- 0x5F > 0
	-- 0x5F > 1
	-- 0x5F > 2
	-- 0x5F > 3
	-- 0x5F > 4
	-- 0x5F > 5
	-- 0x5F > 6
	-- 0x5F > 7
	-- 0x60 > 0
	-- 0x60 > 1
	-- 0x60 > 2
	-- 0x60 > 3
	-- 0x60 > 4
	{byte=0x60, bit=5, name="Silo: Jinjo Village", type="Silo"},
	{byte=0x60, bit=6, name="Silo: Wooded Hollow", type="Silo"},
	{byte=0x60, bit=7, name="Silo: Plateau", type="Silo"},
	{byte=0x61, bit=0, name="Silo: Pine Grove", type="Silo"},
	{byte=0x61, bit=1, name="Silo: Cliff Top", type="Silo"},
	{byte=0x61, bit=2, name="Silo: Wasteland", type="Silo"},
	{byte=0x61, bit=3, name="Silo: Quagmire", type="Silo"},
	{byte=0x61, bit=4, name="FT Silo Text", type="FTT"},
	{byte=0x61, bit=5, name="CCL: Ground Drilled (1)", type="Physical"},
	{byte=0x61, bit=6, name="CCL: Ground Drilled (2)", type="Physical"},
	{byte=0x61, bit=7, name="CCL: Ground Drilled (3)", type="Physical"},
	{byte=0x62, bit=0, name="CCL: Ground Drilled (4)", type="Physical"},
	{byte=0x62, bit=1, name="CCL: Ground Drilled (5)", type="Physical"},
	{byte=0x62, bit=2, name="CCL: Ground Drilled (6)", type="Physical"},
	{byte=0x62, bit=3, name="CCL: Ground Drilled (7)", type="Physical"},
	{byte=0x62, bit=4, name="CCL: Ground Drilled (8)", type="Physical"},
	-- 0x62 > 5
	{byte=0x62, bit=6, name="CCL: Seed Collected"},
	{byte=0x62, bit=7, name="Roysten Help Me Text", type="FTT"},
	-- 0x63 > 0
	-- 0x63 > 1
	-- 0x63 > 2
	-- 0x63 > 3
	-- 0x63 > 4
	-- 0x63 > 5
	{byte=0x63, bit=6, name="Humba Wumba: Big T. Rex FTT", type="FTT"},
	{byte=0x63, bit=7, name="Humba Wumba: Stony FTT", type="FTT"},
	{byte=0x64, bit=0, name="Humba Wumba: Detonator FTT", type="FTT"},
	{byte=0x64, bit=1, name="Humba Wumba: Van FTT", type="FTT"},
	{byte=0x64, bit=2, name="Humba Wumba: Submarine FTT", type="FTT"},
	{byte=0x64, bit=3, name="Humba Wumba: Baby T. Rex FTT", type="FTT"},
	{byte=0x64, bit=4, name="Humba Wumba: Washing Machine FTT", type="FTT"},
	{byte=0x64, bit=5, name="Humba Wumba: Snowball FTT", type="FTT"},
	{byte=0x64, bit=6, name="Humba Wumba: Bee FTT", type="FTT"},
	-- 0x64 > 7
	-- 0x65 > 0
	-- 0x65 > 1
	-- 0x65 > 2
	-- 0x65 > 3
	-- 0x65 > 4
	-- 0x65 > 5
	-- 0x65 > 6
	-- 0x65 > 7
	-- 0x66 > 0
	-- 0x66 > 1
	-- 0x66 > 2
	-- 0x66 > 3
	-- 0x66 > 4
	-- 0x66 > 5
	-- 0x66 > 6
	-- 0x66 > 7
	{byte=0x67, bit=0, name="King Jingaling Life Sapped"},
	-- 0x67 > 1
	-- 0x67 > 2
	-- 0x67 > 3
	-- 0x67 > 4
	-- 0x67 > 5
	-- 0x67 > 6
	{byte=0x67, bit=7, name="Jiggywiggy Temple Is Over There CS Seen", type="FTT"},
	-- 0x68 > 0
	-- 0x68 > 1
	-- 0x68 > 2
	-- 0x68 > 3
	-- 0x68 > 4
	-- 0x68 > 5
	-- 0x68 > 6
	-- 0x68 > 7
	-- 0x69 > 0
	-- 0x69 > 1
	-- 0x69 > 2
	-- 0x69 > 3
	-- 0x69 > 4
	-- 0x69 > 5
	-- 0x69 > 6
	-- 0x69 > 7
	-- 0x6A > 0
	-- 0x6A > 1
	-- 0x6A > 2
	-- 0x6A > 3
	-- 0x6A > 4
	-- 0x6A > 5
	-- 0x6A > 6
	{byte=0x6A, bit=7, name="Mumbo: Glowbo Paid (MT)", type="Glowbo Paid"},
	{byte=0x6B, bit=0, name="Mumbo: Glowbo Paid (GGM)", type="Glowbo Paid"},
	{byte=0x6B, bit=1, name="Mumbo: Glowbo Paid (WW)", type="Glowbo Paid"},
	{byte=0x6B, bit=2, name="Mumbo: Glowbo Paid (JRL)", type="Glowbo Paid"},
	{byte=0x6B, bit=3, name="Mumbo: Glowbo Paid (TDL)", type="Glowbo Paid"},
	{byte=0x6B, bit=4, name="Mumbo: Glowbo Paid (HFP)", type="Glowbo Paid"},
	{byte=0x6B, bit=5, name="Mumbo: Glowbo Paid (CCL)", type="Glowbo Paid"},
	-- 0x6B > 6
	{byte=0x6B, bit=7, name="Mumbo: Glowbo Paid (GI)", type="Glowbo Paid"},
	-- 0x6C > 0
	-- 0x6C > 1
	-- 0x6C > 2
	-- 0x6C > 3
	-- 0x6C > 4
	-- 0x6C > 5
	-- 0x6C > 6
	-- 0x6C > 7
	-- 0x6D > 0
	-- 0x6D > 1
	-- 0x6D > 2
	-- 0x6D > 3
	-- 0x6D > 4
	-- 0x6D > 5
	-- 0x6D > 6
	-- 0x6D > 7
	-- 0x6E > 0
	-- 0x6E > 1
	-- 0x6E > 2
	-- 0x6E > 3
	-- 0x6E > 4
	-- 0x6E > 5
	--{byte=0x6E, bit=6, name="FT Complete Jinjo Family?"},
	-- 0x6E > 7
	-- 0x6F > 0
	-- 0x6F > 1
	-- 0x6F > 2
	-- 0x6F > 3
	-- 0x6F > 4
	-- 0x6F > 5
	-- 0x6F > 6
	-- 0x6F > 7
	-- 0x70 > 0
	-- 0x70 > 1
	-- 0x70 > 2
	-- 0x70 > 3
	{byte=0x70, bit=4, name="Warp: MT: World Entry And Exit", type="Warp"},
	{byte=0x70, bit=5, name="Warp: MT: Outside Mumbo's Skull", type="Warp"},
	{byte=0x70, bit=6, name="Warp: MT: Prison Compound", type="Warp"},
	{byte=0x70, bit=7, name="Warp: MT: Near Wumba's Wigwam", type="Warp"},
	{byte=0x71, bit=0, name="Warp: MT: Kickball Stadium Lobby", type="Warp"},
	{byte=0x71, bit=1, name="Warp: GGM: World Entry And Exit", type="Warp"},
	{byte=0x71, bit=2, name="Warp: GGM: Outside Mumbo's Skull", type="Warp"},
	{byte=0x71, bit=3, name="Warp: GGM: Inside Wumba's Wigwam", type="Warp"},
	{byte=0x71, bit=4, name="Warp: GGM: Outside The Crushing Shed", type="Warp"},
	{byte=0x71, bit=5, name="Warp: GGM: Near The Train Station", type="Warp"},
	{byte=0x71, bit=6, name="Warp: WW: World Entry And Exit", type="Warp"},
	{byte=0x71, bit=7, name="Warp: WW: Behind The Big Top Tent", type="Warp"},
	{byte=0x72, bit=0, name="Warp: WW: Space Zone", type="Warp"},
	{byte=0x72, bit=1, name="Warp: WW: Outside Wumba's Wigwam", type="Warp"},
	{byte=0x72, bit=2, name="Warp: WW: Outside Mumbo's Skull", type="Warp"},
	{byte=0x72, bit=3, name="Warp: JRL: Town Center", type="Warp"},
	{byte=0x72, bit=4, name="Warp: JRL: Atlantis", type="Warp"},
	{byte=0x72, bit=5, name="Warp: JRL: Sunken Ship", type="Warp"},
	{byte=0x72, bit=6, name="Warp: JRL: Big Fish Cavern", type="Warp"},
	{byte=0x72, bit=7, name="Warp: JRL: Lockers Cavern", type="Warp"},
	{byte=0x73, bit=0, name="Warp: TDL: World Entry And Exit", type="Warp"},
	{byte=0x73, bit=1, name="Warp: TDL: Stomping Plains", type="Warp"},
	{byte=0x73, bit=2, name="Warp: TDL: Outside Mumbo's Skull", type="Warp"},
	{byte=0x73, bit=3, name="Warp: TDL: Outside Wumba's Wigwam", type="Warp"},
	{byte=0x73, bit=4, name="Warp: TDL: Top of The Mountain", type="Warp"},
	{byte=0x73, bit=5, name="Warp: GI: Floor 1 - Entrance Door", type="Warp"},
	{byte=0x73, bit=6, name="Warp: GI: Floor 2 - Outside Wumba's Wigwam", type="Warp"},
	{byte=0x73, bit=7, name="Warp: GI: Floor 3 - Outside Mumbo's Skull", type="Warp"},
	{byte=0x74, bit=0, name="Warp: GI: Floor 4 - Near The Crushers", type="Warp"},
	{byte=0x74, bit=1, name="Warp: GI: On The Roof Outside", type="Warp"},
	{byte=0x74, bit=2, name="Warp: HFP: Fire Side - Lower Area (Mumbo)", type="Warp"},
	{byte=0x74, bit=3, name="Warp: HFP: Fire Side - Upper Area", type="Warp"},
	{byte=0x74, bit=4, name="Warp: HFP: Ice Side - Upper Area", type="Warp"},
	{byte=0x74, bit=5, name="Warp: HFP: Ice Side - Lower Area (Wumba)", type="Warp"},
	{byte=0x74, bit=6, name="Warp: HFP: Ice Side - Inside Icicle Grotto", type="Warp"},
	{byte=0x74, bit=7, name="Warp: CCL: World Entry And Exit", type="Warp"},
	{byte=0x75, bit=0, name="Warp: CCL: Central Cavern", type="Warp"},
	-- 0x75 > 1
	-- 0x75 > 2
	-- 0x75 > 3
	{byte=0x75, bit=4, name="Warp: CK: Bottom of The Tower", type="Warp"},
	{byte=0x75, bit=5, name="Warp: CK: Top of The Tower", type="Warp"},
	-- 0x75 > 6
	-- 0x75 > 7
	-- 0x76 > 0
	-- 0x76 > 1
	-- 0x76 > 2
	-- 0x76 > 3
	-- 0x76 > 4
	-- 0x76 > 5
	-- 0x76 > 6
	-- 0x76 > 7
	-- 0x77 > 0
	-- 0x77 > 1
	-- 0x77 > 2
	-- 0x77 > 3
	-- 0x77 > 4
	-- 0x77 > 5
	-- 0x77 > 6
	-- 0x77 > 7
	-- 0x78 > 0
	-- 0x78 > 1
	-- 0x78 > 2
	-- 0x78 > 3
	{byte=0x78, bit=4, name="Ability: Dragon Kazooie", type="Ability"},
	-- 0x78 > 5
	{byte=0x78, bit=6, name="First Warp Available", type="FTT"},
	-- 0x78 > 7

	{byte=0x79, bit=4, name="JRL: Ground Drilled (1)", type="Physical"},
	{byte=0x79, bit=5, name="JRL: Ground Drilled (2)", type="Physical"},
	{byte=0x79, bit=6, name="JRL: Ground Drilled (3)", type="Physical"},
	{byte=0x79, bit=7, name="JRL: Ground Drilled (4)", type="Physical"},
	{byte=0x7A, bit=0, name="JRL: Ground Drilled (5)", type="Physical"},

	{byte=0x7C, bit=4, name="Jamjars First Time Text", type="FTT"},

	-- 0x7F > 0
	-- 0x7F > 1
	--{byte=0x7F, bit=2, name="Jamjars FTSomething?"},
	-- 0x7F > 3
	{byte=0x7F, bit=4, name="Jamjars First Lesson Intro", type="FTT"},
	-- 0x7F > 5
	-- 0x7F > 6
	-- 0x7F > 7
	-- 0x80 > 0
	{byte=0x80, bit=1, name="Mumbo Transform FTT", type="FTT"},
	-- 0x80 > 2
	{byte=0x80, bit=2, name="Canary Mary Intro Cutscene", type="FTT"}, -- Canary Cave
	-- 0x80 > 3
	-- 0x80 > 4
	-- 0x80 > 5
	-- 0x80 > 6
	-- 0x80 > 7
	-- 0x81 > 0
	-- 0x81 > 1
	-- 0x81 > 2
	-- 0x81 > 3
	-- 0x81 > 4
	-- 0x81 > 5
	-- 0x81 > 6
	-- 0x81 > 7
	-- 0x82 > 0
	-- 0x82 > 1
	-- 0x82 > 2
	-- 0x82 > 3
	{byte=0x82, bit=4, name="Jinjo Family FT Cutscene?"},
	--{byte=0x82, bit=5, name="FT Complete Jinjo Family?"},
	{byte=0x82, bit=6, name="Chilly Willy Intro Text", type="FTT"},
	{byte=0x82, bit=7, name="Chilli Billi Intro Text", type="FTT"},
	-- 0x83 > 0
	-- 0x83 > 1
	-- 0x83 > 2
	-- 0x83 > 3
	-- 0x83 > 4
	-- 0x83 > 5
	-- 0x83 > 6
	-- 0x83 > 7
	-- 0x84 > 0
	-- 0x84 > 1
	-- 0x84 > 2
	-- 0x84 > 3
	-- 0x84 > 4
	-- 0x84 > 5
	-- 0x84 > 6
	{byte=0x84, bit=7, name="Nest: MT: ??? (1)", type="Nest"},
	{byte=0x85, bit=0, name="Nest: MT: ??? (2)", type="Nest"},
	{byte=0x85, bit=1, name="Nest: MT: ??? (3)", type="Nest"},
	{byte=0x85, bit=2, name="Nest: MT: ??? (4)", type="Nest"},
	{byte=0x85, bit=3, name="Nest: MT: ??? (5)", type="Nest"},
	{byte=0x85, bit=4, name="Nest: MT: ??? (6)", type="Nest"},
	{byte=0x85, bit=5, name="Nest: MT: ??? (7)", type="Nest"},
	{byte=0x85, bit=6, name="Nest: MT: ??? (8)", type="Nest"},
	{byte=0x85, bit=7, name="Nest: MT: ??? (9)", type="Nest"},
	{byte=0x86, bit=0, name="Nest: MT: ??? (10)", type="Nest"},
	{byte=0x86, bit=1, name="Nest: MT: ??? (11)", type="Nest"},
	{byte=0x86, bit=2, name="Nest: MT: ??? (12)", type="Nest"},
	{byte=0x86, bit=3, name="Nest: MT: ??? (13)", type="Nest"},
	{byte=0x86, bit=4, name="Nest: MT: ??? (14)", type="Nest"},
	{byte=0x86, bit=5, name="Nest: MT: ??? (15)", type="Nest"},
	{byte=0x86, bit=6, name="Nest: MT: ??? (16)", type="Nest"},
	{byte=0x86, bit=7, name="Treble Clef: MT", type="Treble Clef"},
	{byte=0x87, bit=0, name="Nest: GGM: Hill by Crusher Shed (1)", type="Nest"},
	{byte=0x87, bit=1, name="Nest: GGM: Hill by Crusher Shed (2)", type="Nest"},
	{byte=0x87, bit=2, name="Nest: GGM: Hill by Crusher Shed (3)", type="Nest"},
	{byte=0x87, bit=3, name="Nest: GGM: Hill by Crusher Shed (4)", type="Nest"},
	{byte=0x87, bit=4, name="Nest: GGM: Near Prospector's Hut (1)", type="Nest"},
	{byte=0x87, bit=5, name="Nest: GGM: Near Prospector's Hut (2)", type="Nest"},
	{byte=0x87, bit=6, name="Nest: GGM: Near Prospector's Hut (3)", type="Nest"},
	{byte=0x87, bit=7, name="Nest: GGM: Near Prospector's Hut (4)", type="Nest"},
	{byte=0x88, bit=0, name="Nest: GGM: Near Prospector's Hut (5)", type="Nest"},
	{byte=0x88, bit=1, name="Nest: GGM: Outside Mumbo's Skull (1)", type="Nest"},
	{byte=0x88, bit=2, name="Nest: GGM: Outside Mumbo's Skull (2)", type="Nest"},
	{byte=0x88, bit=3, name="Nest: GGM: Outside Mumbo's Skull (3)", type="Nest"},
	{byte=0x88, bit=4, name="Nest: GGM: Fuel Depo (1)", type="Nest"},
	{byte=0x88, bit=5, name="Nest: GGM: Fuel Depo (2)", type="Nest"},
	{byte=0x88, bit=6, name="Nest: GGM: Fuel Depo (3)", type="Nest"},
	{byte=0x88, bit=7, name="Nest: GGM: Fuel Depo (4)", type="Nest"},
	{byte=0x89, bit=0, name="Treble Clef: GGM", type="Treble Clef"},
	{byte=0x89, bit=1, name="Nest: WW: Big Top Path (1)", type="Nest"},
	{byte=0x89, bit=2, name="Nest: WW: Big Top Path (2)", type="Nest"},
	{byte=0x89, bit=3, name="Nest: WW: Big Top Path (3)", type="Nest"},
	{byte=0x89, bit=4, name="Nest: WW: Big Top Path (4)", type="Nest"},
	{byte=0x89, bit=5, name="Nest: WW: Big Top Path (5)", type="Nest"},
	{byte=0x89, bit=6, name="Nest: WW: Big Top Path (6)", type="Nest"},
	{byte=0x89, bit=7, name="Nest: WW: Big Top Path (7)", type="Nest"},
	{byte=0x8A, bit=0, name="Nest: WW: Big Top Path (8)", type="Nest"},
	{byte=0x8A, bit=1, name="Nest: WW: ??? (9)", type="Nest"},
	{byte=0x8A, bit=2, name="Nest: WW: ??? (10)", type="Nest"},
	{byte=0x8A, bit=3, name="Nest: WW: ??? (11)", type="Nest"},
	{byte=0x8A, bit=4, name="Nest: WW: ??? (12)", type="Nest"},
	{byte=0x8A, bit=5, name="Nest: WW: Dive of Death (1)", type="Nest"},
	{byte=0x8A, bit=6, name="Nest: WW: Dive of Death (2)", type="Nest"},
	{byte=0x8A, bit=7, name="Nest: WW: ??? (15)", type="Nest"},
	{byte=0x8B, bit=0, name="Nest: WW: ??? (16)", type="Nest"},
	{byte=0x8B, bit=1, name="Treble Clef: WW", type="Treble Clef"},
	{byte=0x8B, bit=2, name="Nest: JRL: Town Center (1)", type="Nest"},
	{byte=0x8B, bit=3, name="Nest: JRL: Town Center (2)", type="Nest"},
	{byte=0x8B, bit=4, name="Nest: JRL: Town Center (3)", type="Nest"},
	{byte=0x8B, bit=5, name="Nest: JRL: ??? (4)", type="Nest"},
	{byte=0x8B, bit=6, name="Nest: JRL: ??? (5)", type="Nest"},
	{byte=0x8B, bit=7, name="Nest: JRL: ??? (6)", type="Nest"},
	{byte=0x8C, bit=0, name="Nest: JRL: ??? (7)", type="Nest"},
	{byte=0x8C, bit=1, name="Nest: JRL: Blubber's Hire (1)", type="Nest"},
	{byte=0x8C, bit=2, name="Nest: JRL: Blubber's Hire (2)", type="Nest"},
	{byte=0x8C, bit=3, name="Nest: JRL: Blubber's Hire (3)", type="Nest"},
	{byte=0x8C, bit=4, name="Nest: JRL: Pawno's Emporium (1)", type="Nest"},
	{byte=0x8C, bit=5, name="Nest: JRL: Pawno's Emporium (2)", type="Nest"},
	{byte=0x8C, bit=6, name="Nest: JRL: Pawno's Emporium (3)", type="Nest"},
	{byte=0x8C, bit=7, name="Nest: JRL: Jolly's Bar (1)", type="Nest"},
	{byte=0x8D, bit=0, name="Nest: JRL: Jolly's Bar (2)", type="Nest"},
	{byte=0x8D, bit=1, name="Nest: JRL: Jolly's Bar (3)", type="Nest"},
	{byte=0x8D, bit=2, name="Treble Clef: JRL", type="Treble Clef"},
	{byte=0x8D, bit=3, name="Nest: TDL: ??? (1)", type="Nest"},
	{byte=0x8D, bit=4, name="Nest: TDL: ??? (2)", type="Nest"},
	{byte=0x8D, bit=5, name="Nest: TDL: ??? (3)", type="Nest"},
	{byte=0x8D, bit=6, name="Nest: TDL: ??? (4)", type="Nest"},
	{byte=0x8D, bit=7, name="Nest: TDL: ??? (5)", type="Nest"},
	{byte=0x8E, bit=0, name="Nest: TDL: ??? (6)", type="Nest"},
	{byte=0x8E, bit=1, name="Nest: TDL: ??? (7)", type="Nest"},
	{byte=0x8E, bit=2, name="Nest: TDL: ??? (8)", type="Nest"},
	{byte=0x8E, bit=3, name="Nest: TDL: ??? (9)", type="Nest"},
	{byte=0x8E, bit=4, name="Nest: TDL: ??? (10)", type="Nest"},
	{byte=0x8E, bit=5, name="Nest: TDL: ??? (11)", type="Nest"},
	{byte=0x8E, bit=6, name="Nest: TDL: ??? (12)", type="Nest"},
	{byte=0x8E, bit=7, name="Nest: TDL: ??? (13)", type="Nest"},
	{byte=0x8F, bit=0, name="Nest: TDL: ??? (14)", type="Nest"},
	{byte=0x8F, bit=1, name="Nest: TDL: ??? (15)", type="Nest"},
	{byte=0x8F, bit=2, name="Nest: TDL: ??? (16)", type="Nest"},
	{byte=0x8F, bit=3, name="Treble Clef: TDL", type="Treble Clef"},
	{byte=0x8F, bit=4, name="Nest: GI: ??? (1)", type="Nest"},
	{byte=0x8F, bit=5, name="Nest: GI: ??? (2)", type="Nest"},
	{byte=0x8F, bit=6, name="Nest: GI: ??? (3)", type="Nest"},
	{byte=0x8F, bit=7, name="Nest: GI: ??? (4)", type="Nest"},
	{byte=0x90, bit=0, name="Nest: GI: ??? (5)", type="Nest"},
	{byte=0x90, bit=1, name="Nest: GI: ??? (6)", type="Nest"},
	{byte=0x90, bit=2, name="Nest: GI: ??? (7)", type="Nest"},
	{byte=0x90, bit=3, name="Nest: GI: ??? (8)", type="Nest"},
	{byte=0x90, bit=4, name="Nest: GI: ??? (9)", type="Nest"},
	{byte=0x90, bit=5, name="Nest: GI: ??? (10)", type="Nest"},
	{byte=0x90, bit=6, name="Nest: GI: ??? (11)", type="Nest"},
	{byte=0x90, bit=7, name="Nest: GI: ??? (12)", type="Nest"},
	{byte=0x91, bit=0, name="Nest: GI: ??? (13)", type="Nest"},
	{byte=0x91, bit=1, name="Nest: GI: ??? (14)", type="Nest"},
	{byte=0x91, bit=2, name="Nest: GI: ??? (15)", type="Nest"},
	{byte=0x91, bit=3, name="Nest: GI: ??? (16)", type="Nest"},
	{byte=0x91, bit=4, name="Treble Clef: GI", type="Treble Clef"},
	{byte=0x91, bit=5, name="Nest: HFP: ??? (1)", type="Nest"},
	{byte=0x91, bit=6, name="Nest: HFP: ??? (2)", type="Nest"},
	{byte=0x91, bit=7, name="Nest: HFP: ??? (3)", type="Nest"},
	{byte=0x92, bit=0, name="Nest: HFP: ??? (4)", type="Nest"},
	{byte=0x92, bit=1, name="Nest: HFP: ??? (5)", type="Nest"},
	{byte=0x92, bit=2, name="Nest: HFP: ??? (6)", type="Nest"},
	{byte=0x92, bit=3, name="Nest: HFP: ??? (7)", type="Nest"},
	{byte=0x92, bit=4, name="Nest: HFP: ??? (8)", type="Nest"},
	{byte=0x92, bit=5, name="Nest: HFP: ??? (9)", type="Nest"},
	{byte=0x92, bit=6, name="Nest: HFP: ??? (10)", type="Nest"},
	{byte=0x92, bit=7, name="Nest: HFP: ??? (11)", type="Nest"},
	{byte=0x93, bit=0, name="Nest: HFP: ??? (12)", type="Nest"},
	{byte=0x93, bit=1, name="Nest: HFP: ??? (13)", type="Nest"},
	{byte=0x93, bit=2, name="Nest: HFP: ??? (14)", type="Nest"},
	{byte=0x93, bit=3, name="Nest: HFP: ??? (15)", type="Nest"},
	{byte=0x93, bit=4, name="Nest: HFP: ??? (16)", type="Nest"},
	{byte=0x93, bit=5, name="Treble Clef: HFP", type="Treble Clef"},
	{byte=0x93, bit=6, name="Nest: CCL: ??? (1)", type="Nest"},
	{byte=0x93, bit=7, name="Nest: CCL: ??? (2)", type="Nest"},
	{byte=0x94, bit=0, name="Nest: CCL: ??? (3)", type="Nest"},
	{byte=0x94, bit=1, name="Nest: CCL: ??? (4)", type="Nest"},
	{byte=0x94, bit=2, name="Nest: CCL: ??? (5)", type="Nest"},
	{byte=0x94, bit=3, name="Nest: CCL: ??? (6)", type="Nest"},
	{byte=0x94, bit=4, name="Nest: CCL: ??? (7)", type="Nest"},
	{byte=0x94, bit=5, name="Nest: CCL: ??? (8)", type="Nest"},
	{byte=0x94, bit=6, name="Nest: CCL: ??? (9)", type="Nest"},
	{byte=0x94, bit=7, name="Nest: CCL: ??? (10)", type="Nest"},
	{byte=0x95, bit=0, name="Nest: CCL: ??? (11)", type="Nest"},
	{byte=0x95, bit=1, name="Nest: CCL: ??? (12)", type="Nest"},
	{byte=0x95, bit=2, name="Nest: CCL: ??? (13)", type="Nest"},
	{byte=0x95, bit=3, name="Nest: CCL: ??? (14)", type="Nest"},
	{byte=0x95, bit=4, name="Nest: CCL: ??? (15)", type="Nest"},
	{byte=0x95, bit=5, name="Nest: CCL: ??? (16)", type="Nest"},
	{byte=0x95, bit=6, name="Treble Clef: CCL", type="Treble Clef"},
	{byte=0x95, bit=7, name="Nest: IoH: Plateau GGM Sign (1)", type="Nest"},
	{byte=0x96, bit=0, name="Nest: IoH: Plateau GGM Sign (2)", type="Nest"},
	{byte=0x96, bit=1, name="Nest: IoH: Plateau Honey B. (1)", type="Nest"},
	{byte=0x96, bit=2, name="Nest: IoH: Plateau Honey B. (2)", type="Nest"},
	{byte=0x96, bit=3, name="Nest: IoH: Pine Grove (1)", type="Nest"},
	{byte=0x96, bit=4, name="Nest: IoH: Pine Grove (2)", type="Nest"},
	{byte=0x96, bit=5, name="Nest: IoH: Pine Grove Underwater (1)", type="Nest"},
	{byte=0x96, bit=6, name="Nest: IoH: Pine Grove Underwater (2)", type="Nest"},
	{byte=0x96, bit=7, name="Nest: IoH: Clff Top (1)", type="Nest"},
	{byte=0x97, bit=0, name="Nest: IoH: Clff Top (2)", type="Nest"},
	{byte=0x97, bit=1, name="Nest: IoH: Clff Top (3)", type="Nest"},
	{byte=0x97, bit=2, name="Nest: IoH: Clff Top (4)", type="Nest"},
	{byte=0x97, bit=3, name="Nest: IoH: Wasteland (1)", type="Nest"},
	{byte=0x97, bit=4, name="Nest: IoH: Wasteland (2)", type="Nest"},
	{byte=0x97, bit=5, name="Nest: IoH: Wasteland CCL Area (1)", type="Nest"},
	{byte=0x97, bit=6, name="Nest: IoH: Wasteland CCL Area (2)", type="Nest"},
	{byte=0x97, bit=7, name="Treble Clef: IoH: Jinjo Village", type="Treble Clef"},
	{byte=0x98, bit=0, name="First Time Altar of Knowledge Text", type="FTT"},

	{byte=0x99, bit=4, name="First Time Split Up Pad Text", type="FTT"},
	{byte=0x99, bit=5, name="First Time Split Up Text", type="FTT"},

	{byte=0x9A, bit=4, name="Mumbo's Magic: Levitate: Jiggy Boulder (Levitated?)", type="Mumbo's Magic"},
	{byte=0x9A, bit=5, name="Mumbo's Magic: Levitate: Jiggy Boulder (Placed?)", type="Mumbo's Magic"},

	{byte=0x9B, bit=5, name="First Time Mumbo in Wumba's Wigwam", type="FTT"},
	{byte=0x9B, bit=6, name="First Time Jamjars Cutscene", type="FTT"},

	{byte=0x9C, bit=1, name="JRL: Underground Doubloon Spawned (1)", type="Physical"},
	{byte=0x9C, bit=2, name="JRL: Underground Doubloon Spawned (2)", type="Physical"},
	{byte=0x9C, bit=3, name="JRL: Underground Doubloon Spawned (3)", type="Physical"},

	{byte=0x9D, bit=7, name="GGM: Ordnance Storage Boulder Drilled", type="Physical"},

	{byte=0x9E, bit=1, name="GGM: Gloomy Caverns Entrance Boulder Drilled", type="Physical"},
	{byte=0x9E, bit=2, name="GGM: Gloomy Caverns Boulder Drilled (1)", type="Physical"},
	{byte=0x9E, bit=3, name="GGM: Gloomy Caverns Boulder Drilled (2)", type="Physical"},

	{byte=0xA1, bit=4, name="Cheat Active: Double Maximum Feathers", type="Cheat"},
	{byte=0xA1, bit=5, name="Cheat Active: Double Maximum Eggs", type="Cheat"},
	{byte=0xA1, bit=6, name="Cheat Active: No Energy Loss From Falling", type="Cheat"},
	{byte=0xA1, bit=7, name="Cheat Active: Automatic Energy Regain", type="Cheat"},
	{byte=0xA2, bit=0, name="Cheat Active: Jolly's Jukebox", type="Cheat"},
	{byte=0xA2, bit=1, name="Cheat Active: Jiggywiggy Temple Signposts", type="Cheat"},
	{byte=0xA2, bit=2, name="Cheat Active: Fast Banjo", type="Cheat"},
	{byte=0xA2, bit=3, name="Cheat Active: Fast Baddies", type="Cheat"},
	{byte=0xA2, bit=4, name="Cheat Active: No Energy Or Air Loss", type="Cheat"},
	{byte=0xA2, bit=5, name="Cheat Active: Infinite Eggs And Feathers", type="Cheat"},
	-- 0xA2 > 6
	{byte=0xA2, bit=7, name="FT Enter Banjo's House"},
	{byte=0xA3, bit=0, name="Klungo Potion Chosen??"},
	{byte=0xA3, bit=1, name="FT Enter MT"},
	-- 0xA3 > 2 Targitzan Fight?
	{byte=0xA3, bit=3, name="FT Enter GGM"},
	-- 0xA3 > 4
	-- 0xA3 > 5
	{byte=0xA3, bit=6, name="FT Enter WW"},
	-- 0xA3 > 7
	-- 0xA4 > 0
	-- 0xA4 > 1
	{byte=0xA4, bit=2, name="FT Enter JRL"},
	-- 0xA4 > 3
	-- 0xA4 > 4
	-- 0xA4 > 5
	-- 0xA4 > 6
	-- 0xA4 > 7
	{byte=0xA5, bit=0, name="FT Enter TDL"},
	-- 0xA5 > 1
	{byte=0xA5, bit=2, name="FT Enter GI"},
	-- 0xA5 > 3
	{byte=0xA5, bit=4, name="FT Enter HFP"},
	-- 0xA5 > 5
	{byte=0xA5, bit=6, name="FT Enter CCL"},
	-- 0xA5 > 7
	-- 0xA6 > 0
	{byte=0xA6, bit=1, name="FT Enter CK"},
	-- 0xA6 > 2
	-- 0xA6 > 3
	-- 0xA6 > 4
	{byte=0xA6, bit=5, name="FT Enter IoH"},
	{byte=0xA6, bit=6, name="FT Enter Jinjo Village??"},
	-- 0xA6 > 7
	-- 0xA7 > 0
	{byte=0xA7, bit=1, name="FT Enter King Jingaling Cutscene"},
	{byte=0xA7, bit=3, name="FT Enter Bottles' House?"},
	-- 0xA7 > 4
	-- 0xA7 > 5
	{byte=0xA7, bit=6, name="Honey B. FTT", type="FTT"},
	{byte=0xA7, bit=7, name="First Time Turbo Trainers"},
	{byte=0xA8, bit=0, name="First Time Wading Boots"},
	{byte=0xA8, bit=1, name="First Time Springy Step Shoes"},
	-- 0xA8 > 2
	-- 0xA8 > 3
	{byte=0xA8, bit=4, name="First Boss Fight?"},
	-- 0xA8 > 5
	-- 0xA8 > 6
	-- 0xA8 > 7
	-- 0xA9 > 0
	-- 0xA9 > 1
	-- 0xA9 > 2
	-- 0xA9 > 3
	-- 0xA9 > 4
	-- 0xA9 > 5
	-- 0xA9 > 6
	-- 0xA9 > 7
	-- 0xAA > 0
	-- 0xAA > 1
	-- 0xAA > 2
	-- 0xAA > 3
	{byte=0xAA, bit=4, name="Mumbo's Magic: Summon: Golden Goliath", type="Mumbo's Magic"},
	{byte=0xAA, bit=5, name="Mumbo's Magic: Enlarge: Wumba's Wigwam", type="Mumbo's Magic"}, -- FT only, this doesn't actually enlarge the Wigwam
	-- 0xAA > 6
	-- 0xAA > 7
	{byte=0xAB, bit=0, name="Mumbo's Magic: Rain Dance", type="Mumbo's Magic"}, -- FT Only
	-- 0xAB > 1
	-- 0xAB > 2
	-- 0xAB > 3
	-- 0xAB > 4
	-- 0xAB > 5
	-- 0xAB > 6
	-- 0xAB > 7
	-- 0xAC > 0
	-- 0xAC > 1
	-- 0xAC > 2
	-- 0xAC > 3
	-- 0xAC > 4
	-- 0xAC > 5
	-- 0xAC > 6
	-- 0xAC > 7
	-- 0xAD > 0
	-- 0xAD > 1
	-- 0xAD > 2
	-- 0xAD > 3
	-- 0xAD > 4
	-- 0xAD > 5
	-- 0xAD > 6
	-- 0xAD > 7
	-- 0xAE > 0
	-- 0xAE > 1
	-- 0xAE > 2
	-- 0xAE > 3
	-- 0xAE > 4
	--{byte=0xAE, bit=5, name="FT Enter WW? Boggy Children?"},
	--{byte=0xAE, bit=6, name="FT Enter WW? Boggy Children?"},
	--{byte=0xAE, bit=7, name="FT Enter WW? Boggy Children?"},
	--{byte=0xAF, bit=1, name="FT Enter WW? Boggy Children?"},
	--{byte=0xAF, bit=0, name="FT Enter WW? Boggy Children?"},
	--{byte=0xAF, bit=2, name="FT Enter WW? Boggy Children?"},
	{byte=0xAF, bit=3, name="Cheat Active: Enable Homing Eggs", type="Cheat"},
	-- 0xAF > 4
	-- 0xAF > 5
	-- 0xAF > 6
	-- 0xAF > 7
};

local flag_names = {};

for i = 1, #flag_array do
	if not flag_array[i].ignore then
		flag_names[i] = flag_array[i].name;
	end
end

function isKnown(byte, bit)
	for i = 1, #flag_array do
		if flag_array[i].byte == byte and flag_array[i].bit == bit then
			return true;
		end
	end
	return false;
end

function getFlagName(byte, bit)
	for i = 1, #flag_array do
		if byte == flag_array[i].byte and bit == flag_array[i].bit and not flag_array[i].ignore then
			return flag_array[i].name;
		end
	end
	return "Unknown at "..toHexString(byte)..">"..bit;
end

local function getFlagByName(flagName)
	for i = 1, #flag_array do
		if not flag_array[i].ignore and flagName == flag_array[i].name then
			return flag_array[i];
		end
	end
end

function setFlagByName(name)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		setFlag(flag.byte, flag.bit);
	end
end

function clearFlagByName(name)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		clearFlag(flag.byte, flag.bit);
	end
end

function setFlagsByType(_type)
	if type(_type) == "string" then
		if _type == "Note" then
			setFlagsByType("Nest");
			setFlagsByType("Treble Clef");
			return;
		end
		local numSet = 0;
		for i = 1, #flag_array do
			if flag_array[i]["type"] == _type then
				setFlag(flag_array[i].byte, flag_array[i].bit, true);
				numSet = numSet + 1;
			end
		end
		if numSet > 0 then
			print("Set "..numSet.." flags of type '".._type.."'");
		else
			print("No flags found of type '".._type.."'");
		end
	end
end

function clearFlag(byte, bit)
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit < 8 then
		local flags = dereferencePointer(Game.Memory.flag_block_pointer[version]);
		if isRDRAM(flags) then
			currentValue = mainmemory.readbyte(flags + byte);
			mainmemory.writebyte(flags + byte, clear_bit(currentValue, bit));
		end
	end
end

function clearFlagsByType(_type)
	if type(_type) == "string" then
		if _type == "Note" then
			clearFlagsByType("Nest");
			clearFlagsByType("Treble Clef");
			return;
		end
		local numSet = 0;
		for i = 1, #flag_array do
			if flag_array[i]["type"] == _type then
				clearFlag(flag_array[i].byte, flag_array[i].bit, true);
				numSet = numSet + 1;
			end
		end
		if numSet > 0 then
			print("Cleared "..numSet.." flags of type '".._type.."'");
		else
			print("No flags found of type '".._type.."'");
		end
	end
end

function setFlag(byte, bit)
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit < 8 then
		local flags = dereferencePointer(Game.Memory.flag_block_pointer[version]);
		if isRDRAM(flags) then
			currentValue = mainmemory.readbyte(flags + byte);
			mainmemory.writebyte(flags + byte, set_bit(currentValue, bit));
		end
	end
end

function clearAllFlags()
	local flagBlock = dereferencePointer(Game.Memory.flag_block_pointer[version]);
	if isRDRAM(flagBlock) then
		for byte = 0, flag_block_size - 1 do
			mainmemory.writebyte(flagBlock + byte, 0x00);
		end
	end
end

function setAllFlags()
	local flagBlock = dereferencePointer(Game.Memory.flag_block_pointer[version]);
	if isRDRAM(flagBlock) then
		for byte = 0, flag_block_size - 1 do
			mainmemory.writebyte(flagBlock + byte, 0xFF);
		end
	end
end

function checkFlag(byte, bit, suppressPrint)
	if type(byte) == "string" then
		local flag = getFlagByName(byte);
		if type(flag) == "table" then
			byte = flag.byte;
			bit = flag.bit;
		end
	end
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit < 8 then
		local flagBlock = dereferencePointer(Game.Memory.flag_block_pointer[version]);
		if isRDRAM(flagBlock) then
			local currentValue = mainmemory.readbyte(flagBlock + byte);
			if check_bit(currentValue, bit) then
				if not suppressPrint then
					print(getFlagName(byte, bit).." is SET");
				end
				return true;
			else
				if not suppressPrint then
					print(getFlagName(byte, bit).." is NOT set");
				end
				return false;
			end
		end
	else
		if not suppressPrint then
			print("Warning: Flag not found");
		end
	end
	return false;
end

function checkFlags()
	local flagBlock = dereferencePointer(Game.Memory.flag_block_pointer[version]);
	if isRDRAM(flagBlock) then
		for byte = 0, flag_block_size - 1 do
			local currentValue = mainmemory.readbyte(flagBlock + byte);
			local previousValue = flag_block_cache[byte];
			if previousValue == nil then
				previousValue = currentValue;
			end
			for bit = 0, 7 do
				local isSet = check_bit(currentValue, bit);
				local wasSet = check_bit(previousValue, bit);
				if isSet and not wasSet then
					if isKnown(byte, bit) then
						dprint("Flag "..toHexString(byte, 2)..">"..bit..": \""..getFlagName(byte, bit).."\" was set on frame "..emu.framecount());
					else
						dprint("{byte="..toHexString(byte, 2)..", bit="..bit..", name=\"Name\"},");
					end
				elseif not isSet and wasSet then
					dprint("Flag "..toHexString(byte, 2)..">"..bit..": \""..getFlagName(byte, bit).."\" was cleared on frame "..emu.framecount());
				end
			end
			flag_block_cache[byte] = currentValue;
		end
		print_deferred();
	end
end

local function formatOutputString(caption, value, max)
	return caption..value.."/"..max.." or "..round(value / max * 100, 2).."%";
end

function flagStats(verbose)
	local abilitiesKnown = 0;
	local cheatoPagesKnown = 0; local maxCheatoPages = 25;
	local glowbosKnown = 0; local maxGlowbos = 17;
	local honeycombsKnown = 0; local maxHoneycombs = 25;
	local jiggiesKnown = 0; local maxJiggies = 90;
	local jinjosKnown = 0; local maxJinjos = 45;
	local notesKnown = 0; local maxNotes = 900;
	local silosKnown = 0; local maxSilos = 7;
	local warpsKnown = 0; local maxWarps = 39; -- I think this is right?

	local untypedFlags = 0;
	local flagsWithUnknownType = 0;
	local flagsWithMap = 0;

	-- Setting this to true warns the user of flags without types
	verbose = verbose or false;

	local flag, name, flagType, validType;
	for i = 1, #flag_array do
		flag = flag_array[i];
		name = flag["name"];
		flagType = flag["type"];
		validType = false;
		if flagType == "Ability" then
			abilitiesKnown = abilitiesKnown + 1;
			validType = true;
		elseif flagType == "Cheato Page" then
			cheatoPagesKnown = cheatoPagesKnown + 1;
			validType = true;
		elseif flagType == "Glowbo" then
			glowbosKnown = glowbosKnown + 1;
			validType = true;
		elseif flagType == "Honeycomb" then
			honeycombsKnown = honeycombsKnown + 1;
			validType = true;
		elseif flagType == "Jiggy" then
			jiggiesKnown = jiggiesKnown + 1;
			validType = true;
		elseif flagType == "Jinjo" then
			jinjosKnown = jinjosKnown + 1;
			validType = true;
		elseif flagType == "Nest" then
			notesKnown = notesKnown + 5;
			validType = true;
		elseif flagType == "Silo" then
			silosKnown = silosKnown + 1;
			validType = true;
		elseif flagType == "Treble Clef" then
			notesKnown = notesKnown + 20;
			validType = true;
		elseif flagType == "Warp" then
			warpsKnown = warpsKnown + 1;
			validType = true;
		end
		if flagType == nil then
			untypedFlags = untypedFlags + 1;
			if verbose then
				dprint("Warning: Flag without type at "..toHexString(flag.byte, 2)..">"..flag["bit"].." with name: \""..name.."\"");
			end
		else
			if flagType == "Cheat" then
				validType = true;
			elseif flagType == "Doubloon" then
				validType = true;
			elseif flagType == "FTT" then
				validType = true;
			elseif flagType == "Mumbo's Magic" then
				validType = true;
			elseif flagType == "Progress" then
				validType = true;
			elseif flagType == "Targitzan Statue" then
				validType = true;
			elseif flagType == "Unknown" then
				validType = true;
			end
			if not validType then
				flagsWithUnknownType = flagsWithUnknownType + 1;
				if verbose then
					dprint("Warning: Flag with unknown type at "..toHexString(flag.byte, 2)..">"..flag["bit"].." with name: \""..name.."\"".." and type: \""..flagType.."\"");
				end
			end
		end
		if flag.map ~= nil or flag.nomap == true then
			flagsWithMap = flagsWithMap + 1;
		elseif verbose then
			dprint("Warning: Flag without map tag at "..toHexString(flag.byte, 2)..">"..flag["bit"].." with name: \""..name.."\"");
		end
	end

	local knownFlags = #flag_array;
	local totalFlags = flag_block_size * 8;

	dprint("Block size: "..toHexString(flag_block_size));
	dprint(formatOutputString("Flags known: ", knownFlags, totalFlags));
	dprint(formatOutputString("Without types: ", untypedFlags, knownFlags));
	dprint(formatOutputString("Unknown types: ", flagsWithUnknownType, knownFlags));
	dprint(formatOutputString("With map tag: ", flagsWithMap, knownFlags));
	dprint("");
	dprint(formatOutputString("Jiggies: ", jiggiesKnown, maxJiggies));
	dprint(formatOutputString("Jinjos: ", jinjosKnown, maxJinjos));
	dprint(formatOutputString("Notes: ", notesKnown, maxNotes));
	dprint("");
	dprint("Abilities: "..abilitiesKnown);
	dprint(formatOutputString("Cheato Pages: ", cheatoPagesKnown, maxCheatoPages));
	dprint(formatOutputString("Honeycombs: ", honeycombsKnown, maxHoneycombs));
	dprint(formatOutputString("Glowbos: ", glowbosKnown, maxGlowbos));
	dprint(formatOutputString("Silos: ", silosKnown, maxSilos));
	dprint(formatOutputString("Warps: ", warpsKnown, maxWarps));
	dprint("");
	print_deferred();
end

local function flagSetButtonHandler()
	setFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagClearButtonHandler()
	clearFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagCheckButtonHandler()
	checkFlag(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

--------------------
-- Object Model 1 --
--------------------

local slot_base = 0x10;
local slot_size = 0x9C;
object_index = 1;

object_model1 = {
	["id_struct"] = 0x00, -- Pointer
	["x_position"] = 0x04, -- Float
	["y_position"] = 0x08, -- Float
	["z_position"] = 0x0C, -- Float
	["scale"] = 0x38, -- Float
	["y_rotation"] = 0x48, -- Float
	["z_rotation"] = 0x4C, -- Float
	["models"] = {
		--TODO: Import list from
			-- http://thumbsupmaster.blogspot.com.au/p/banjo-tooie-image-modifications.html
			-- http://bsfree.shadowflareindustries.com/index.php?s=39&d=6&g=15729&c=72210
			-- https://www.youtube.com/watch?v=9DDV52RXyiM
			-- Wumba's Wigwam https://banjosbackpack.com/forums/showthread.php?8165-Wumba-s-Wigwam-BT-Setup-Viewer
			-- Possibly other sources
		[0x5EE] = "Boggy's Sled",
		[0x629] = "Molehill",
		[0x610] = "Jiggy",
		[0x612] = "Empty Honeycomb",
		[0x615] = "Beehive",
		[0x616] = "Wading Boots",
		[0x617] = "Turbo Trainers",
		[0x635] = "Shock Spring Pad",
		[0x636] = "Fly Pad",
		[0x63B] = "Ice Key",
		[0x641] = "Warp Pad",
		[0x643] = "Jinjo",
		[0x644] = "Star Pad", -- Prison Compound
		[0x645] = "Moon Pad", -- Prison Compound
		[0x646] = "Sun Pad", -- Prison Compound
		[0x650] = "Old King Coal",
		[0x65E] = "Gruntydactyl",
		[0x65F] = "Ssslumber",
		[0x660] = "Bovina",
		[0x661] = "Officer Unogopaz",
		[0x662] = "Globble", -- Fly, Bovina
		[0x663] = "Sput Sput",
		[0x664] = "Blowdart",
		[0x665] = "Mumbo", -- Also Mingy Jongo?
		[0x666] = "Snapdragon",
		[0x667] = "Moggy",
		[0x66B] = "Chief Bloatazin",
		[0x66D] = "Dilberta",
		[0x66E] = "Dragunda",
		[0x66F] = "Diggit",
		--[0x670] = "!Crash",
		[0x671] = "Ugger",
		--[0x672] = "!Crash",
		[0x673] = "Golden Goliath",
		[0x675] = "Humba Wumba",
		[0x676] = "Stony", -- NPC
		--[0x677] = "!Crash",
		--[0x678] = "!Crash",
		--[0x679] = "!Crash",
		[0x67B] = "Canary Mary",
		[0x67C] = "Minecart", -- Canary Mary Race
		[0x67D] = "Cage", -- Canary Mary
		--[0x67E] = "!Crash",
		--[0x67F] = "!Crash",
		[0x680] = "Waterfall Grate Switch", -- GGM
		[0x681] = "Waterfall Grate", -- GGM
		[0x682] = "Boulder", -- Bill Drill
		[0x68F] = "Bang Box",
		[0x693] = "Conga",
		[0x6A1] = "TNT",
		[0x6A2] = "Rareware Box", -- SM
		[0x6A9] = "Chuffy", -- Train
		[0x6AD] = "Salty Joe",
		[0x6AE] = "Big Al",
		[0x6AF] = "Burger",
		[0x6B0] = "Fries",
		[0x6B7] = "Mrs. Boggy",
		[0x6BD] = "Bouncy Castle",
		[0x6C3] = "Pawno",
		[0x6C7] = "Tiptup Jr.",
		[0x6C8] = "Tiptup",
		[0x6C9] = "Fruity",
		[0x6CC] = "Scrut",
		[0x6CD] = "Alien",
		[0x6CE] = "Whirlweed",
		[0x6D0] = "Inky",
		[0x6D1] = "Chris P. Bacon",
		[0x6D2] = "Blubbul",
		[0x6D3] = "Stomponadon",
		[0x6D4] = "Captain Blackeye",
		[0x6D6] = "Jolly Roger",
		[0x6D8] = "Merry Maggie Malpass",
		[0x6DA] = "Terry",
		[0x6DB] = "Captain Blubber",
		[0x6EA] = "Nest (Eggs)",
		[0x6EC] = "Nest (Note)",
		[0x6ED] = "Nest (Treble Clef)",
		[0x6EF] = "Nest (Feathers)",
		[0x6FA] = "Roysten",
		[0x6FC] = "UFO", -- Cutscene
		[0x6FE] = "Rareware Box",
		[0x700] = "Rareware Box",
		[0x704] = "Honeycomb",
		[0x705] = "Honeycomb (Skill/Random)",
		[0x707] = "Klungo",
		[0x759] = "Moggy", -- Boggy
		[0x75A] = "Soggy", -- Boggy
		[0x75B] = "Groggy", -- Boggy
		[0x766] = "Glowbo",
		[0x76B] = "Zubba (Red)",
		[0x76C] = "Zubba (Green)",
		[0x76D] = "Zubba (Blue)",
		[0x776] = "Boxing Glove", -- Mr. Patch Fight
		[0x787] = "Cheato",
		[0x788] = "Gobi",
		[0x789] = "Billy Bob",
		[0x78A] = "Billy Bob (Inactive)",
		[0x7A2] = "Signpost",
		[0x7A7] = "Dingpot",
		[0x7AC] = "Ice Cube",
		[0x7BF] = "Ticket", -- Big Top
		[0x7C0] = "Doubloon",
		[0x7C5] = "Twinkly (Blue)",
		[0x7C6] = "Twinkly (Green)",
		[0x7C7] = "Twinkly (Red)",
		[0x7D4] = "Piggles", -- JRL Piglet
		[0x7D5] = "Trotty", -- JRL Piglet
		[0x7D6] = "Jamjars",
		[0x7D7] = "Silo", -- Jamjars
		[0x7D8] = "Green Mumbo Pad",
		[0x7D9] = "Blue Mumbo Pad",
		[0x7DA] = "Purple Mumbo Pad",
		[0x7DB] = "Yellow Mumbo pad",
		[0x7DC] = "Cyan Mumbo Pad",
		[0x7DD] = "Red Mumbo Pad",
		[0x7DE] = "Orange Mumbo Pad",
		[0x7DF] = "Grey Mumbo Pad",
		[0x7E0] = "Purple Mumbo Pad",
		[0x7E1] = "Kazooie Split Pad",
		[0x7E2] = "Banjo Split Pad",
		[0x7E4] = "Bazza",
		[0x7E5] = "Oogle Boogle",
		[0x7E9] = "Dippy",
		[0x7EA] = "Nutta",
		[0x7EC] = "Boltoid",
		[0x7EE] = "Unga Bunga",
		[0x7EF] = "Sabreman",
		[0x7F3] = "Cheato Page",
		[0x7F4] = "Targitzan",
		[0x7F5] = "Alien Child (Pink)",
		[0x7F6] = "Alien Child (Blue)",
		[0x7F7] = "Alien Child (Yellow)",
		[0x7F9] = "Lord Woo Fak Fak",
		[0x7FC] = "Chilli Billi",
		[0x7FE] = "Keelhaul",
		[0x7FF] = "Guvnor", -- GI Worker Enemy
		[0x801] = "Cannon", -- Dragon Fights
		[0x803] = "Skivvy", -- GI Worker
		[0x806] = "Germ",
		[0x807] = "Alien Dad",
		[0x808] = "Guffo",
		[0x81C] = "Bigfoot",
		[0x81E] = "Biggafoot",
		[0x83D] = "Overalls", -- GI Worker
		[0x854] = "Mumbo Jumbo",
		[0x85F] = "Zubba",
		[0x862] = "Banjo's Hand", -- File Select
		[0x88F] = "S'Hard",
		[0x896] = "King Jingaling",
		[0x898] = "Throne", -- King Jingaling
		[0x89C] = "Weldar Fireball",
		[0x89F] = "Onion",
		[0x8C3] = "Bottles (Burnt)",
		[0x8C8] = "BOB Control Panel",
		[0x8F1] = "Boggy",
		[0x8FA] = "Fish", -- Boggy's
		[0x8FE] = "HAG 1",
		[0x8FF] = "Rocknut",
		[0x900] = "Gobgoyle",
		[0x901] = "HAG 1",
		[0x902] = "Gobgoyle",
		[0x909] = "Bigga-Bazza",
		[0x90A] = "Bigga-Bazza",
		[0x90B] = "Mrs. Bottles",
		[0x90C] = "Klungo", -- Hurt
		[0x90D] = "Klungo", -- Very Hurt
		[0x90E] = "Bottles (Angel)",
		[0x90F] = "Bottles (Devil)",
		[0x910] = "B-K Cartridge",
		[0x911] = "Gold Idol",
		[0x913] = "Jade Idol", -- Targitzan's Temple
		[0x915] = "George", -- Ice Cube
		[0x916] = "Mildred", -- Ice Cube
		[0x917] = "Warp Silo",
		[0x918] = "Honey B.",
		[0x919] = "Speccy", -- Bottles' Child
		[0x91A] = "Goggles", -- Bottles' Child
		[0x92B] = "Jelly", -- CCL
		[0x92D] = "Jelly Castle", -- CCL
		[0x935] = "Master Jiggywiggy",
		[0x937] = "Disciple of Jiggywiggy",
		[0x93D] = "Fries Button",
		[0x977] = "Jiggywiggy's Altar of Knowledge",
		[0x99C] = "Jukebox",
		[0x9A2] = "Applause Sign",
	},
};

function getNumSlots()
	local objectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
	if isRDRAM(objectArray) then
		local blockEnd = dereferencePointer(objectArray - 0x0C);
		if isRDRAM(blockEnd) then
			return math.floor(((blockEnd - objectArray) - slot_base) / slot_size);
		end
	end
	return 0;
end

function getSlotBase(index)
	--if index < 0 or index > getNumSlots() then
	--	print("Warning: OOB call to getSlotBase() with index"..index);
	--end
	return slot_base + index * slot_size;
end

local function incrementObjectIndex()
	object_index = object_index + 1;
	if object_index > getNumSlots() then
		object_index = 1;
	end
end

local function decrementObjectIndex()
	object_index = object_index - 1;
	if object_index <= 0 then
		object_index = getNumSlots();
	end
end

local script_modes = {
	"Disabled",
	"List",
	--"Examine"
};

local script_mode_index = 1;
script_mode = script_modes[script_mode_index];

local function toggleObjectAnalysisToolsMode()
	script_mode_index = script_mode_index + 1;
	if script_mode_index > #script_modes then
		script_mode_index = 1;
	end
	script_mode = script_modes[script_mode_index];
end

function getObjectModel1Pointers()
	local pointers = {};
	local objectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
	if isRDRAM(objectArray) then
		local num_slots = getNumSlots();
		for i = 0, num_slots - 1 do
			table.insert(pointers, objectArray + getSlotBase(i)); -- TODO: Check for bone arrays before adding to table, we don't want to move stuff we can't see
		end
	end
	return pointers;
end

function setObjectModel1Position(pointer, x, y, z)
	if isRDRAM(pointer) then
		mainmemory.writefloat(pointer + object_model1.x_position, x, true);
		mainmemory.writefloat(pointer + object_model1.y_position, y, true);
		mainmemory.writefloat(pointer + object_model1.z_position, z, true);
	end
end

function zipTo(index)
	local objectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
	if isRDRAM(objectArray) then
		local objectPointer = objectArray + getSlotBase(index);
		local xPos = mainmemory.readfloat(objectPointer + object_model1.x_position, true);
		local yPos = mainmemory.readfloat(objectPointer + object_model1.y_position, true);
		local zPos = mainmemory.readfloat(objectPointer + object_model1.z_position, true);
		Game.setPosition(xPos, yPos, zPos);
	end
end

function zipToSelectedObject()
	zipTo(object_index - 1);
end

function everythingIs(modelIndex)
	local model1Pointers = getObjectModel1Pointers();
	if #model1Pointers > 0 then
		for i = 1, #model1Pointers do
			local objectIDPointer = dereferencePointer(model1Pointers[i] + object_model1.id_struct);
			if isRDRAM(objectIDPointer) then
				mainmemory.write_u16_be(objectIDPointer + 0x14, modelIndex);
			end
		end
	end
end

local green_highlight = 0xFF00FF00;
local yellow_highlight = 0xFFFFFF00;

function Game.drawUI()
	if script_mode == "Disabled" then
		return;
	end

	local row = 0;

	local objectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
	local numSlots = getNumSlots();

	gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, "Mode: "..script_mode, nil, 'bottomright');
	row = row + 1;
	gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, "Index: "..(object_index).."/"..(numSlots), nil, 'bottomright');
	row = row + 1;

	if script_mode == "Examine" and isRDRAM(objectArray) then
		local examine_data = getExamineData(objectArray + getSlotBase(object_index));
		for i = #examine_data, 1, -1 do
			if examine_data[i][1] ~= "Separator" then
				gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, examine_data[i][2].." - "..examine_data[i][1], nil, 'bottomright');
				row = row + 1;
			else
				row = row + examine_data[i][2];
			end
		end
	end

	if script_mode == "List" and isRDRAM(objectArray) then
		for i = numSlots, 1, -1 do
			local currentSlotBase = objectArray + getSlotBase(i - 1);

			local animationType = "Unknown";
			local objectIDPointer = dereferencePointer(currentSlotBase + object_model1.id_struct);
			if isRDRAM(objectIDPointer) then
				local modelIndex = mainmemory.read_u16_be(objectIDPointer + 0x14);
				if type(object_model1.models[modelIndex]) == "string" then
					animationType = object_model1.models[modelIndex];
				else
					animationType = toHexString(modelIndex);
				end
			end

			local color = nil;
			if object_index == i then
				color = yellow_highlight;
			end

			local xPos = mainmemory.readfloat(currentSlotBase + object_model1.x_position, true);
			local yPos = mainmemory.readfloat(currentSlotBase + object_model1.y_position, true);
			local zPos = mainmemory.readfloat(currentSlotBase + object_model1.z_position, true);

			gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, round(xPos, precision)..", "..round(yPos, precision)..", "..round(zPos, precision).." - "..animationType.." "..i..": "..toHexString(currentSlotBase or 0), color, 'bottomright');
			row = row + 1;
		end
	end
end

-- Keybinds
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm
ScriptHawk.bindKeyRealtime("Z", zipToSelectedObject, true);
ScriptHawk.bindKeyRealtime("C", toggleObjectAnalysisToolsMode, true);
ScriptHawk.bindKeyRealtime("N", decrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("M", incrementObjectIndex, true);

--------------
-- Encircle --
--------------

local dynamic_radius_factor = 15;
y_stagger_amount = 10;

-- Relative to objectArray
local max_slots = 0x100;
radius = 1000;

local function encircle_banjo()
	local current_banjo_x = Game.getXPosition();
	local current_banjo_y = Game.getYPosition();
	local current_banjo_z = Game.getZPosition();
	local x, y, z;

	--radius = 1000
	--if forms.ischecked(ScriptHawk.UI.form_controls.dynamic_radius_checkbox) then
	--	radius = getNumSlots() * dynamic_radius_factor;
	--end

	local currentPointers = getObjectModel1Pointers();
	for i = 1, #currentPointers do
		x = current_banjo_x + math.cos(math.pi * 2 * i / #currentPointers) * radius;
		y = current_banjo_y + i * y_stagger_amount;
		z = current_banjo_z + math.sin(math.pi * 2 * i / #currentPointers) * radius;
		setObjectModel1Position(currentPointers[i], x, y, z);
	end
end

------------
-- Events --
------------

Game.takeMeThereType = "Button";
function Game.setMap(value)
	local trigger_value = mainmemory.read_u16_be(Game.Memory.map_trigger[version]);
	if trigger_value == 0 then
		mainmemory.write_u16_be(Game.Memory.map_trigger_target[version], value);

		-- Force game to reload with desired map
		mainmemory.write_u16_be(Game.Memory.map_trigger[version], 0x0101);
	end
end

function Game.getMap()
	return mainmemory.read_u16_be(Game.Memory.map[version]);
end

function Game.getMapOSD()
	local currentMap = Game.getMap();
	local currentMapName = "Unknown";
	if Game.maps[currentMap] ~= nil then
		currentMapName = Game.maps[currentMap];
	end
	return currentMapName.." ("..toHexString(currentMap)..")";
end

local max_air = 60; -- TODO: This changes once you finish Roysten's quest, how to you get this information out of the game?

function Game.applyInfinites()
	-- TODO: Eggs, Feathers etc
	--if version == 4 then -- TODO: Other versions
		--mainmemory.write_u16_be(0x0D1A58, 0x0000); -- Janky infinite egg/feather code, I don't like this
	--end
	--setFlagsByType("Glowbo");
	mainmemory.writefloat(Game.Memory.air[version], max_air, true);
	Game.setCurrentHealth(Game.getMaxHealth());
end

local move_levels = {
	["0. All + Dragon Kazooie"]  = {0xFFFFFFFF, 0xFFFFFFFF, true},
	["1. All"]  = {0xFFFFFFFF, 0xFFFFFFFF, false},
	["2. None"] = {0xE0FFFF01, 0x00004000, false},
};

local function unlock_moves()
	local level = forms.gettext(ScriptHawk.UI.form_controls.moves_dropdown);
	local flagBlock = dereferencePointer(Game.Memory.flag_block_pointer[version]);
	if isRDRAM(flagBlock) then
		mainmemory.write_u32_be(flagBlock + 0x18, move_levels[level][1]);
		mainmemory.write_u32_be(flagBlock + 0x1C, move_levels[level][2]);
		if move_levels[level][3] then
			setFlagByName("Ability: Dragon Kazooie");
		else
			clearFlagByName("Ability: Dragon Kazooie");
		end
	end
end

function Game.initUI()
	-- Flag stuff
	ScriptHawk.UI.form_controls["Flag Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, flag_names, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Set Flag Button"] = forms.button(ScriptHawk.UI.options_form, "Set", flagSetButtonHandler, ScriptHawk.UI.col(10), ScriptHawk.UI.row(7), 46, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Check Flag Button"] = forms.button(ScriptHawk.UI.options_form, "Check", flagCheckButtonHandler, ScriptHawk.UI.col(12), ScriptHawk.UI.row(7), 46, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Clear Flag Button"] = forms.button(ScriptHawk.UI.options_form, "Clear", flagClearButtonHandler, ScriptHawk.UI.col(14), ScriptHawk.UI.row(7), 46, ScriptHawk.UI.button_height);

	ScriptHawk.UI.form_controls.toggle_neverslip = forms.checkbox(ScriptHawk.UI.options_form, "Never Slip", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);

	-- Moves
	ScriptHawk.UI.form_controls.moves_dropdown = forms.dropdown(ScriptHawk.UI.options_form, { "0. All + Dragon Kazooie", "1. All", "2. None" }, ScriptHawk.UI.col(10) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);
	ScriptHawk.UI.form_controls.moves_button = forms.button(ScriptHawk.UI.options_form, "Unlock Moves", unlock_moves, ScriptHawk.UI.col(5), ScriptHawk.UI.row(6), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);

	flagStats();
end

function Game.eachFrame()
	if forms.ischecked(ScriptHawk.UI.form_controls.toggle_neverslip) then
		neverSlip();
	end
	if realtime_flags then
		checkFlags();
	end
	if encircle_enabled then
		encircle_banjo();
	end
end

Game.OSDPosition = {2, 70};
Game.OSD = {
	{"Map", Game.getMapOSD},
	{"Separator", 1},
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