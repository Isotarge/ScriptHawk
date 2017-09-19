if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

encircle_enabled = false;
object_filter = nil; -- String

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
		"!Unknown 0x00A0",

		"Cutscene - Two Years have passed..",
		"Cutscene - Hag 1 Arrives",
		"Cutscene - Arrival of Mingella & Blobbelda",
		"Cutscene - Revival of Gruntilda",
		"Cutscene - Gruntilda casts the spell",
		"Cutscene - Hag 1 leaves",
		"Cutscene - Banjo vows to defeat Grunty",
		"Cutscene - Playing Poker",
		"Cutscene - Earthquake",
		"Cutscene - Mumbo takes a look outside",
		"Cutscene - Mumbo warns Banjo & Bottles",
		"Cutscene - Banjo's house is destroyed",

		"SM - Grunty's Lair",
		"SM - Behind the waterfall",
		"SM - Spiral Mountain",

		"!Crash 0x00B0", "!Crash 0x00B1", "!Unknown 0x00B2", "!Crash 0x00B3", "!Unknown 0x00B4", "!Crash 0x00B5",

		"MT - Wumba's Wigwam",
		"MT - Mumbo's Skull",
		"MT",
		"MT - Prison Compound",
		"MT - Columns Vault",
		"MT - Mayan Kickball Stadium (Lobby)",
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

		"JRL - Inside the UFO",

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
		"GI - Workers' Quarters",
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
		"TDL - Oogle Boogles' Cave",
		"TDL - Inside the Mountain",
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
		"CCL - Zubbas' Nest",
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
		"CCL - Canary Mary Race",
		"GI - Floor 4 (Clinker's Cavern)",
		"GGM - Ordnance Storage Entrance",
		"GI - Clinker's Cavern (multiplayer)",
		"GGM - Ordnance Storage (multiplayer)",
		"MT - Targitzan's Temple (multiplayer)",
		"MT - (character parade)",
		"HFP - Icy Side (character parade)",
		"JV - Bottles' House (character parade)",
		"CK - Gun Chamber (character parade)",

		"!Crash 0x016B", "!Crash 0x016C", "!Crash 0x016D", "!Crash 0x016E",

		"GGM - Canary Mary Race (1)",
		"GGM - Canary Mary Race (2)",
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
		"CCL - Zubbas' Nest (multiplayer)",
		"CK - Tower of Tragedy Quiz (Multiplayer)",
		"CK - Inside HAG 1",
		"Intro Screen",
		"Cutscene - Introduction to B.O.B.",
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
		"Cutscene - Character Parade",

		"!Crash 0x019E", "!Crash 0x019F", "!Unknown 0x01A0", "!Unknown 0x01A1", "!Unknown 0x01A2", "!Unknown 0x01A3", "!Unknown 0x01A4", "!Unknown 0x01A5",

		"JRL - Smuggler's cavern",
		"JRL",
		"JRL - Atlantis",
		"JRL - Sea Bottom",
	},
	Memory = { -- Version order: Australia, Europe, Japan, USA
		["consumable_base"] = {0x11FFB0, 0x120170, 0x115340, 0x11B080},
		["consumable_pointer"] = {0x12FFC0, 0x1301D0, 0x125420, 0x12B250},
		["object_array_pointer"] = {0x13BBD0, 0x13BE60, 0x131020, 0x136EE0},
		["player_pointer"] = {0x13A210, 0x13A4A0, 0x12F660, 0x135490},
		["player_pointer_index"] = {0x13A25F, 0x13A4EF, 0x12F6AF, 0x1354DF},
		["global_flag_base"] = {0x131500, 0x131790, 0x126950, 0x12C780},
		["camera_pointer_pointer"] = {0x12C478, 0x12C688, 0x1218D8, 0x127728},
		["flag_block_pointer"] = {0x1314F0, 0x131780, 0x126940, 0x12C770},
		["air"] = {0x12FDC0, 0x12FFD0, 0x125220, 0x12B050},
		["frame_timer"] = {0x083550, 0x083550, 0x0788F8, 0x079138},
		["linked_list_root"] = {0x13C380, 0x13C680, 0x131850, 0x137800},
		["map"] = {0x137B42, 0x137DD2, 0x12CF92, 0x132DC2},
		["map_trigger_target"] = {0x12C390, 0x12C5A0, 0x1217F0, 0x127640},
		["map_trigger"] = {0x12C392, 0x12C5A2, 0x1217F2, 0x127642},
		["DCW_location"] = {0x12C33A, 0x12C54A, 0x12179A, 0x1275EA},
		["character_state"] = {0x13BC53, 0x13BEE3, 0x1310A3, 0x136F63},
		["character_change"] = {0x12BD9C, 0x12BFAC, 0x1211FC, 0x12704C},
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
	character_states = {
		-- 0 Occurs during game boot-up
		[1] = "Banjo-Kazooie", -- Doesn't matter if you're Dragon Kazooie
		[2] = "Snowball",
		-- 3 is Unknown
		[4] = "Cutscene", -- Cutscene happening in another map to activation point
		-- 5 is Unknown
		[6] = "Bee",
		[7] = "Washing Machine",
		[8] = "Stony",
		[9] = "Breegull Blaster",
		[10] = "Banjo",
		[11] = "Kazooie", -- Doesn't matter if you're Dragon Kazooie
		[12] = "Submarine",
		[13] = "Mumbo",
		[14] = "Golden Goliath",
		[15] = "Detonator",
		[16] = "Van",
		[17] = "Clockwork Kazooie",
		[18] = "Small T-Rex",
		[19] = "Big T-Rex"
	},
	character_change_lookup = {
		["BK"] = 1,
		["Snowball"] = 2,
		["Cutscene"] = 4,
		["Bee"] = 6,
		["W. Machine"] = 7,
		["Stony"] = 8,
		["Breegull B."] = 9,
		["Solo Banjo"] = 10,
		["Solo Kazooie"] = 11,
		["Submarine"] = 12,
		["Mumbo"] = 13,
		["G. Goliath"] = 14,
		["Detonator"] = 15,
		["Van"] = 16,
		["Cwk Kazooie"] = 17,
		["Small T-Rex"] = 18,
		["Big T-Rex"] = 19
	};
};

local function checksumToString(checksum)
	return toHexString(checksum[1], 8)..toHexString(checksum[2], 8, "");
end

local function readChecksum(address)
	return {memory.read_u32_be(address, "EEPROM"), memory.read_u32_be(address + 4, "EEPROM")};
end

local function checksumsMatch(checksum1, checksum2)
	return checksum1[1] == checksum2[1] and checksum1[2] == checksum2[2];
end

local eep_checksum = {
	{ address = 0x78, value = {0, 0} }, -- Global Flags (1)
	{ address = 0xF8, value = {0, 0} }, -- Global Flags (2)
	{ address = 0x2B8, value = {0, 0} }, -- Save Slot 1
	{ address = 0x478, value = {0, 0} }, -- Save Slot 2
	{ address = 0x638, value = {0, 0} }, -- Save Slot 3
	{ address = 0x7F8, value = {0, 0} }, -- Save Slot 4
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

	-- Read EEPROM checksums
	for i = 1, #eep_checksum do
		eep_checksum[i].value = readChecksum(eep_checksum[i].address);
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
	return dereferencePointer(Game.Memory.player_pointer[version] + 4 * playerPointerIndex);
end

function Game.getCameraObject()
	local cameraPointerPointer = dereferencePointer(Game.Memory.camera_pointer_pointer[version]);
	if isRDRAM(cameraPointerPointer) then
		return dereferencePointer(cameraPointerPointer + 4);
	end
end

function Game.getPlayerSubObject(index)
	local player = Game.getPlayerObject();
	if isRDRAM(player) then
		return dereferencePointer(player + index);
	end
end

function Game.getCameraSubObject(index)
	local camera = Game.getCameraObject();
	if isRDRAM(camera) then
		return dereferencePointer(camera + index);
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

local JinjoAddresses = {
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

local JinjoColors = {
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

local knownPatterns = { -- To test for more patterns: Freeze u32_be 0x12C7F0 at a desired value and create a new file then run isKnownPattern(), tested up to 0xFF inclusive
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

---------------------
-- Camera Position --
---------------------

camera_lock = {
	x = 0,
	y = 0,
	z = 0,
	enabled = false,
};

function Game.enableCameraLock()
	camera_lock.x = Game.getCameraXPosition();
	camera_lock.y = Game.getCameraYPosition();
	camera_lock.z = Game.getCameraZPosition();
	camera_lock.enabled = true;
end

function Game.getCameraXPosition()
	local cameraObject = Game.getCameraObject();
	if isRDRAM(cameraObject) then
		return mainmemory.readfloat(cameraObject + 0x74, true);
	end
	return 0;
end

function Game.getCameraYPosition()
	local cameraObject = Game.getCameraObject();
	if isRDRAM(cameraObject) then
		return mainmemory.readfloat(cameraObject + 0x78, true);
	end
	return 0;
end

function Game.getCameraZPosition()
	local cameraObject = Game.getCameraObject();
	if isRDRAM(cameraObject) then
		return mainmemory.readfloat(cameraObject + 0x7C, true);
	end
	return 0;
end

function Game.setCameraXPosition(value)
	local cameraObject = Game.getCameraObject();
	if isRDRAM(cameraObject) then
		mainmemory.writefloat(cameraObject + 0x74, value, true);
	end
end

function Game.setCameraYPosition(value)
	local cameraObject = Game.getCameraObject();
	if isRDRAM(cameraObject) then
		mainmemory.writefloat(cameraObject + 0x78, value, true);
	end
end

function Game.setCameraZPosition(value)
	local cameraObject = Game.getCameraObject();
	if isRDRAM(cameraObject) then
		mainmemory.writefloat(cameraObject + 0x7C, value, true);
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
	[0x3A] = "Idle", -- With Gold Idol
	[0x3B] = "Walking", -- With Gold Idol

	[0x3D] = "Falling (Splat)",
	[0x3E] = "Damaged", -- Washing Machine

	[0x40] = "Locked", -- CWK Kazooie Explosion (under some conditions)
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

	[0x58] = "Damaged", -- Crash Landing
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
	[0x76] = "Locked", -- Flying
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
	[0x94] = "Locked", -- CWK Kazooie Explosion (under some conditions)
	[0x95] = "Jumping", -- Claw Clamber
	[0x96] = "Locked", -- Transforming
	[0x97] = "Locked", -- Underwater - Loading Zone
	[0x98] = "Locked", -- First person camera, some damage sources, loading zones

	[0x9A] = "Locked", -- Talon Trot, loading zone etc

	[0x9C] = "Jumping", -- Springy Step Shoes
	[0x9D] = "Locked", -- Bee, Loading Zones

	[0x9F] = "Creeping", -- With Gold Idol
	[0xA0] = "Locked", -- With Gold Idol, Detection

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
	[0xCB] = "Entering First Person", -- Breegull Blaster

	[0xCE] = "Locked", -- Breegull Blaster, Loading Zone

	[0xD0] = "Locked", -- Breegull Blaster
	[0xD1] = "Walking", -- Breegull Blaster
	[0xD2] = "Beak Bayonet",

	[0xD6] = "Firing Egg", -- Breegull Blaster
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
	[0xFE] = "Locked", -- Golden Goliath, Loading Zone
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
	[0x11B] = "Idle", -- Van, Surface Swimming
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

	[0x12A] = "Driving", -- Dodgem Car
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
	[0x137] = "Locked", -- Clockwork Kazooie, Loading Zone
	[0x138] = "Locked", -- Clockwork Kazooie, Slipping, Loading Zone

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

function dumpPointerListStrings()
	local object;
	local index = 0;
	repeat
		object = dereferencePointer(0x126738 + index * 4);
		if isRDRAM(object) then
			local string = "Unknown";
			local checkPointerOffset = 0x3C;
			local checkPointer = 0;
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

local global_flag_block_cache = {};
local flag_block_cache = {};
function clearFlagCache()
	global_flag_block_cache = {};
	flag_block_cache = {};
end
event.onloadstate(clearFlagCache, "ScriptHawk - Clear Flag Cache");

local global_flag_block_size = 0x10;
local global_flag_array = {
	-- 0x00 > 0
	{byte=0x00, bit=1, name="Widescreen Enabled"},
	{byte=0x00, bit=2, name="Screen Alignment X", ignore=true},
	{byte=0x00, bit=3, name="Screen Alignment X", ignore=true},
	{byte=0x00, bit=4, name="Screen Alignment X", ignore=true},
	{byte=0x00, bit=5, name="Screen Alignment X", ignore=true},
	{byte=0x00, bit=6, name="Screen Alignment X", ignore=true},
	{byte=0x00, bit=7, name="Screen Alignment X", ignore=true},
	{byte=0x01, bit=0, name="Screen Alignment Y", ignore=true},
	{byte=0x01, bit=1, name="Screen Alignment Y", ignore=true},
	{byte=0x01, bit=2, name="Screen Alignment Y", ignore=true},
	{byte=0x01, bit=3, name="Screen Alignment Y", ignore=true},
	{byte=0x01, bit=4, name="Screen Alignment Y", ignore=true},
	{byte=0x01, bit=5, name="Screen Alignment Y", ignore=true},
	{byte=0x01, bit=6, name="Screen Alignment Y", ignore=true},
	{byte=0x01, bit=7, name="Screen Alignment Y", ignore=true},
	{byte=0x02, bit=0, name="Boss Replay: Klungo 1", type="Boss Replay"},
	{byte=0x02, bit=1, name="Boss Replay: Klungo 2", type="Boss Replay"},
	{byte=0x02, bit=2, name="Boss Replay: Klungo 3", type="Boss Replay"},
	{byte=0x02, bit=3, name="Boss Replay: Targitzan", type="Boss Replay"},
	{byte=0x02, bit=4, name="Boss Replay: Old King Coal", type="Boss Replay"},
	{byte=0x02, bit=5, name="Boss Replay: Mr. Patch", type="Boss Replay"},
	{byte=0x02, bit=6, name="Boss Replay: Lord Woo Fak Fak", type="Boss Replay"},
	{byte=0x02, bit=7, name="Boss Replay: Terry", type="Boss Replay"},
	{byte=0x03, bit=0, name="Boss Replay: Weldar", type="Boss Replay"},
	{byte=0x03, bit=1, name="Boss Replay: Chilly Willy", type="Boss Replay"},
	{byte=0x03, bit=2, name="Boss Replay: Chilli Billi", type="Boss Replay"},
	{byte=0x03, bit=3, name="Boss Replay: Mingy Jongo", type="Boss Replay"},
	{byte=0x03, bit=4, name="Boss Replay: Hag 1", type="Boss Replay"},
	-- 0x03 > 5 Unknown, but cleared by GS code
	-- 0x03 > 6 Unknown, but cleared by GS code
	-- 0x03 > 7 Unknown, but cleared by GS code
	-- 0x04 > 0
	-- 0x04 > 1
	-- 0x04 > 2
	-- 0x04 > 3
	-- 0x04 > 4
	-- 0x04 > 5
	-- 0x04 > 6
	-- 0x04 > 7
	-- 0x05 > 0 Unknown, but cleared by GS code
	-- 0x05 > 1 Unknown, but cleared by GS code
	-- 0x05 > 2 Unknown, but cleared by GS code
	{byte=0x05, bit=3, name="Minigame Replay: Mayan Kickball (Quarterfinal)", type="Minigame Replay"},
	{byte=0x05, bit=4, name="Minigame Replay: Mayan Kickball (Semifinal)", type="Minigame Replay"},
	{byte=0x05, bit=5, name="Minigame Replay: Mayan Kickball (Final)", type="Minigame Replay"},
	{byte=0x05, bit=6, name="Minigame Replay: Ordnance Storage", type="Minigame Replay"},
	{byte=0x05, bit=7, name="Minigame Replay: Dodgems Challenge (1-on-1)", type="Minigame Replay"},
	{byte=0x06, bit=0, name="Minigame Replay: Dodgems Challenge (2-on-1)", type="Minigame Replay"},
	{byte=0x06, bit=1, name="Minigame Replay: Dodgems Challenge (3-on-1)", type="Minigame Replay"},
	{byte=0x06, bit=2, name="Minigame Replay: Hoop Hurry Challenge", type="Minigame Replay"},
	{byte=0x06, bit=3, name="Minigame Replay: Balloon Burst Challenge", type="Minigame Replay"},
	{byte=0x06, bit=4, name="Minigame Replay: Saucer of Peril Ride", type="Minigame Replay"},
	{byte=0x06, bit=5, name="Minigame Replay: Mini-Sub Challenge", type="Minigame Replay"},
	{byte=0x06, bit=6, name="Minigame Replay: Chompa's Belly", type="Minigame Replay"},
	{byte=0x06, bit=7, name="Minigame Replay: Clinker's Cavern", type="Minigame Replay"},
	{byte=0x07, bit=0, name="Minigame Replay: Twinklies Packing", type="Minigame Replay"},
	{byte=0x07, bit=1, name="Minigame Replay: Colosseum Kickball (Quarterfinal)", type="Minigame Replay"},
	{byte=0x07, bit=2, name="Minigame Replay: Colosseum Kickball (Semifinal)", type="Minigame Replay"},
	{byte=0x07, bit=3, name="Minigame Replay: Colosseum Kickball (Final)", type="Minigame Replay"},
	{byte=0x07, bit=4, name="Minigame Replay: Pot o' Gold", type="Minigame Replay"},
	{byte=0x07, bit=5, name="Minigame Replay: Trash Can Germs", type="Minigame Replay"},
	{byte=0x07, bit=6, name="Minigame Replay: Zubbas' Hive", type="Minigame Replay"},
	{byte=0x07, bit=7, name="Minigame Replay: Tower of Tragedy Quiz (Round 1)", type="Minigame Replay"},
	{byte=0x08, bit=0, name="Minigame Replay: Tower of Tragedy Quiz (Round 2)", type="Minigame Replay"},
	{byte=0x08, bit=1, name="Minigame Replay: Tower of Tragedy Quiz (Round 3)", type="Minigame Replay"},
	{byte=0x08, bit=2, name="Cinema Replay: Opening Story", type="Cinema Replay"},
	{byte=0x08, bit=3, name="Cinema Replay: King Jingaling Gets Zapped", type="Cinema Replay"},
	{byte=0x08, bit=4, name="Cinema Replay: Bottles and Jingaling Restored", type="Cinema Replay"},
	{byte=0x08, bit=5, name="Cinema Replay: Grunty Defeated", type="Cinema Replay"},
	{byte=0x08, bit=6, name="Cinema Replay: Credits", type="Cinema Replay"},
	{byte=0x08, bit=7, name="Cinema Replay: Character Parade", type="Cinema Replay"},
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
	{byte=0x0A, bit=3, name="Jinjo in Multiplayer"},
	-- 0x0A > 4
	-- 0x0A > 5
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
	-- 0x0C > 0
	{byte=0x0C, bit=1, name="Screen Scale", ignore=true},
	{byte=0x0C, bit=2, name="Screen Scale", ignore=true},
	{byte=0x0C, bit=3, name="Screen Scale", ignore=true},
	{byte=0x0C, bit=4, name="Screen Scale", ignore=true},
	{byte=0x0C, bit=5, name="Screen Scale", ignore=true},
	{byte=0x0C, bit=7, name="Screen Scale", ignore=true},
	{byte=0x0D, bit=0, name="Screen Scale", ignore=true},
	{byte=0x0D, bit=1, name="Screen Scale", ignore=true},
	{byte=0x0D, bit=2, name="Screen Scale", ignore=true},
	{byte=0x0D, bit=3, name="Screen Scale", ignore=true},
};

local flag_block_size = 0xB0;
local flag_array = {
	-- 0x00 > 0
	{byte=0x00, bit=1, name="First Time Note Collection", nomap=true, type="FTT"},
	{byte=0x00, bit=2, name="First Time Glowbo Collection", nomap=true, type="FTT"},
	{byte=0x00, bit=3, name="First Time Egg Collection", nomap=true, type="FTT"},
	{byte=0x00, bit=4, name="First Time Red Feather Collection", nomap=true, type="FTT"},
	{byte=0x00, bit=5, name="First Time Gold Feather Collection", nomap=true, type="FTT"},
	{byte=0x00, bit=6, name="First Time Treble Clef Collection", nomap=true, type="FTT"},
	{byte=0x00, bit=7, name="First Time Health Collection", nomap=true, type="FTT"},
	-- 0x01 > 0
	-- 0x01 > 1
	{byte=0x01, bit=2, name="First Time Empty Honeycomb Collection", nomap=true, type="FTT"},
	-- 0x01 > 3
	-- 0x01 > 4
	{byte=0x01, bit=5, name="First Time Jinjo Collection", nomap=true, type="FTT"},
	-- 0x01 > 6
	-- 0x01 > 7
	-- 0x02 > 0
	-- 0x02 > 1
	{byte=0x02, bit=2, name="Signpost FTT", nomap=true, type="FTT"},
	{byte=0x02, bit=3, name="ToT Completed?", type="Progress"},
	{byte=0x02, bit=4, name="Klungo Intro Cutscene"},
	-- 0x02 > 5
	-- 0x02 > 6
	-- 0x02 > 7
	-- 0x03 > 0
	-- 0x03 > 1
	-- 0x03 > 2
	{byte=0x03, bit=3, name="Hag 1 Defeated", type="Progress"},
	{byte=0x03, bit=4, name="Hag 1 Intro Cutscene", type="FTT"},
	{byte=0x03, bit=5, name="JRL: Sunken Ship Jinjo Chest Smashed", type="Physical"},
	-- 0x03 > 6
	-- 0x03 > 7
	-- 0x04 > 0
	{byte=0x04, bit=1, name="HFP: Stone Building Destroyed", type="Physical"},
	-- 0x04 > 2
	{byte=0x04, bit=3, name="Cheat Available: Jiggywiggyspecial", type="Cheat Available"},
	{byte=0x04, bit=4, name="Cheat Active: Open Up All World Doors", type="Cheat"},
	{byte=0x04, bit=5, name="MT: Bovina FTT", type="FTT"},
	-- 0x04 > 6
	-- 0x04 > 7
	{byte=0x05, bit=0, name="Golden Goliath Instructions", type="FTT"},
	-- 0x05 > 1 MT Prison Compound Something?
	-- 0x05 > 2
	-- 0x05 > 3
	{byte=0x05, bit=4, name="GGM: FT Detonator Talk To Canary Mary", type="FTT"},
	{byte=0x05, bit=5, name="FT Enter Wumba's Wigwam Pine Grove", type="FTT"},
	{byte=0x05, bit=6, name="Mega Glowbo"},
	{byte=0x05, bit=7, name="First Time Minjo Aggro", type="FTT"},
	{byte=0x06, bit=0, name="MT: Officer Unogopaz FTT", type="FTT"},
	-- 0x06 > 1
	{byte=0x06, bit=2, name="MT: Gold Relic Returned", type="Physical"},
	{byte=0x06, bit=3, name="MT: Dilberta Intro", type="FTT"},
	{byte=0x06, bit=4, name="MT: Dilberta in GGM", type="Progress"},
	-- 0x06 > 5
	-- 0x06 > 6
	-- 0x06 > 7
	-- 0x07 > 0
	-- 0x07 > 1
	-- 0x07 > 2
	-- 0x07 > 3
	-- 0x07 > 4
	-- 0x07 > 5
	{byte=0x07, bit=6, name="GGM: Canary Mary Freed (1)", type="Progress"},
	{byte=0x07, bit=7, name="First Time Cheato Page", type="FTT"},
	{byte=0x08, bit=0, name="Cheato FTT", type="FTT"},
	{byte=0x08, bit=1, name="Cheato: Code Chamber Clue Given", type="FTT"},
	{byte=0x08, bit=2, name="Cheato: Podium FTT", type="FTT"},
	{byte=0x08, bit=3, name="Cheato: Code Chamber Instructions Given", type="FTT"},
	{byte=0x08, bit=4, name="Cheato: Feathers", type="Cheato"},
	{byte=0x08, bit=5, name="Cheato: Eggs", type="Cheato"},
	{byte=0x08, bit=6, name="Cheato: Fallproof", type="Cheato"},
	{byte=0x08, bit=7, name="Cheato: Honeyback", type="Cheato"},
	{byte=0x09, bit=0, name="Cheato: Jukebox", type="Cheato"},
	{byte=0x09, bit=1, name="Cheat Available: Feathers", type="Cheat Available"},
	{byte=0x09, bit=2, name="Cheat Available: Eggs", type="Cheat Available"},
	{byte=0x09, bit=3, name="Cheat Available: Fallproof", type="Cheat Available"},
	{byte=0x09, bit=4, name="Cheat Available: Honeyback", type="Cheat Available"},
	{byte=0x09, bit=5, name="Cheat Available: Jukebox", type="Cheat Available"},
	{byte=0x09, bit=6, name="Cheato: Getjiggy", type="Cheato"},
	{byte=0x09, bit=7, name="Cheat Available: Getjiggy", type="Cheat Available"},
	{byte=0x0A, bit=0, name="Cheat Available: Superbanjo", type="Cheat Available"},
	{byte=0x0A, bit=1, name="Cheat Available: Superbaddy", type="Cheat Available"},
	{byte=0x0A, bit=2, name="Cheat Available: Honeyking", type="Cheat Available"},
	-- 0x0A > 3
	-- 0x0A > 4
	{byte=0x0A, bit=5, name="Mumbo FTT", type="FTT"},
	{byte=0x0A, bit=6, name="GGM: Canary Cave Entrance Cleared", type="Physical"},
	-- 0x0A > 7
	-- 0x0B > 0
	-- 0x0B > 1
	{byte=0x0B, bit=2, name="GGM: Bullion Bill Intro", type="FTT"},
	{byte=0x0B, bit=3, name="GGM: Dilberta Quest Complete", type="Progress"},
	-- 0x0B > 4
	-- 0x0B > 5
	{byte=0x0B, bit=6, name="GGM: Old King Coal Defeated?", type="Progress"},
	-- 0x0B > 7
	-- 0x0C > 0 Start of Targitzan Fight?
	--{byte=0x0C, bit=1, name="WW: Dino Door Smashed?"},
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
	{byte=0x0D, bit=5, name="GGM: Levitate Chuffy (1)", type="Mumbo's Magic"},
	-- 0x0D > 6
	{byte=0x0D, bit=7, name="WW: Gobi Freed", type="Progress"},
	--{byte=0x0E, bit=0, name="WW: Dino Door Smashed?"},
	{byte=0x0E, bit=1, name="WW: Cave of Horrors: Jinjo Door Smashed", type="Physical"},
	{byte=0x0E, bit=2, name="First Time Mumbo Pad Text", type="FTT"},
	{byte=0x0E, bit=3, name="First Time Mumbo Pad Instructions", type="FTT"},
	-- 0x0E > 4
	{byte=0x0E, bit=5, name="WW: Big Al FTT", type="FTT"},
	-- 0x0E > 6
	{byte=0x0E, bit=7, name="WW: Big Al's Open", type="Physical"},
	{byte=0x0F, bit=0, name="WW: Salty Joe's Open", type="Physical"},
	-- 0x0F > 1
	-- 0x0F > 2
	-- 0x0F > 3
	-- 0x0F > 4
	-- 0x0F > 5
	-- 0x0F > 6
	-- 0x0F > 7
	-- 0x10 > 0
	-- 0x10 > 1
	-- 0x10 > 2
	-- 0x10 > 3
	-- 0x10 > 4
	-- 0x10 > 5
	-- 0x10 > 6
	-- 0x10 > 7
	-- 0x11 > 0
	{byte=0x11, bit=1, name="MT: Jade Snake Grove Door Smashed", type="Physical"},
	{byte=0x11, bit=2, name="WW: Crazy Castle Pump Activated", type="Physical"},
	-- 0x11 > 3
	{byte=0x11, bit=4, name="JRL: Pawno's Jiggy Purchased", type="Progress"},
	{byte=0x11, bit=5, name="JRL: Pawno's Cheato Page Purchased", type="Progress"},
	{byte=0x11, bit=6, name="JRL: UFO Leaves JRL", type="Progress"},
	{byte=0x11, bit=7, name="Klungo 3 Something??"},
	{byte=0x12, bit=0, name="WW: Moggy FTT", type="FTT"},
	-- 0x12 > 1
	-- 0x12 > 2
	-- 0x12 > 3
	-- 0x12 > 4
	-- 0x12 > 5
	-- 0x12 > 6
	-- 0x12 > 7
	{byte=0x13, bit=0, name="JRL: Merry Maggie Malpass Rescued", type="Progress"},
	{byte=0x13, bit=1, name="Klungo 1 Potion Chosen?"},
	{byte=0x13, bit=2, name="JRL: Jolly's Room Rented", type="Physical"},
	{byte=0x13, bit=3, name="JRL: Jolly FTT", type="FTT"},
	{byte=0x13, bit=4, name="JRL: Merry Maggie Malpass in Jolly's FTT", type="FTT"},
	{byte=0x13, bit=5, name="TDL: Stomponadon Intro Cutscene", type="Cutscene"},
	-- 0x13 > 6
	-- 0x13 > 7
	-- 0x14 > 0
	{byte=0x14, bit=1, name="MT: Prison Compound Door Smashed", type="Physical"},
	-- 0x14 > 2
	{byte=0x14, bit=3, name="JRL: Water Supply Pipe Grate Smashed (Sunken Ship)", type="Physical"},
	{byte=0x14, bit=4, name="JRL: Water Supply Pipe Grate Smashed (Smuggler's Cavern)", type="Physical"},
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
	{byte=0x16, bit=6, name="Humba Wumba: Glowbo Paid (IoH)", type="Glowbo Paid"},
	-- 0x16 > 7
	-- 0x17 > 0
	-- 0x17 > 1
	{byte=0x17, bit=2, name="Humba Wumba: Detransform Instructions", type="FTT"},
	{byte=0x17, bit=3, name="MT: Treasure Chamber > TDL Door Open", type="Physical"},
	{byte=0x17, bit=4, name="JRL: Captain Blackeye FTT", type="FTT"},
	{byte=0x17, bit=5, name="TDL: Terry Defeated", type="Progress"},
	-- 0x17 > 6
	-- 0x17 > 7
	-- 0x18 > 0
	{byte=0x18, bit=1, name="Mumbo's Magic: Sunlight: Oxygenated Water", type="Mumbo's Magic"},
	{byte=0x18, bit=2, name="Mumbo's Magic: Power: Star Spinner", type="Mumbo's Magic"},
	{byte=0x18, bit=3, name="Mumbo's Magic: Power: Saucer of Peril", type="Mumbo's Magic"},
	{byte=0x18, bit=4, name="Mumbo's Magic: Power: Dodgem Dome", type="Mumbo's Magic"},
	{byte=0x18, bit=5, name="Ability: Beak Barge", nomap=true, type="Ability"},
	{byte=0x18, bit=6, name="Ability: Beak Bomb", nomap=true, type="Ability"},
	{byte=0x18, bit=7, name="Ability: Beak Buster", nomap=true, type="Ability"},
	--{byte=0x19, bit=0, name="Ability: Seen Camera Tutorial?"}, -- Set on boot
	{byte=0x19, bit=1, name="Ability: Bear Punch Replacement Peck", nomap=true, type="Ability"},
	{byte=0x19, bit=2, name="Ability: Climb Trees", nomap=true, type="Ability"},
	{byte=0x19, bit=3, name="Ability: Blue Eggs", nomap=true, type="Ability"},
	{byte=0x19, bit=4, name="Ability: Feathery Flap", nomap=true, type="Ability"},
	{byte=0x19, bit=5, name="Ability: Flap Flip", nomap=true, type="Ability"},
	{byte=0x19, bit=6, name="Ability: Fly Pad", nomap=true, type="Ability"},
	{byte=0x19, bit=7, name="Ability: Full Jump Height", nomap=true, type="Ability"},
	{byte=0x1A, bit=0, name="Ability: Rat-a-tat Rap", nomap=true, type="Ability"},
	{byte=0x1A, bit=1, name="Ability: Roll", nomap=true, type="Ability"},
	{byte=0x1A, bit=2, name="Ability: Shock Spring Pad", nomap=true, type="Ability"},
	{byte=0x1A, bit=3, name="Ability: Wading Boots", nomap=true, type="Ability"},
	{byte=0x1A, bit=4, name="Ability: Dive", nomap=true, type="Ability"},
	{byte=0x1A, bit=5, name="Ability: Talon Trot", nomap=true, type="Ability"},
	{byte=0x1A, bit=6, name="Ability: Turbo Trainers", nomap=true, type="Ability"},
	{byte=0x1A, bit=7, name="Ability: Wonderwing", nomap=true, type="Ability"},
	--{byte=0x1B, bit=0, name="FT Note Door Molehill Seen?", type="FTT"}, -- Set on boot
	{byte=0x1B, bit=1, name="Ability: Grip Grab", type="Ability"},
	{byte=0x1B, bit=2, name="Ability: Breegull Blaster", type="Ability"},
	{byte=0x1B, bit=3, name="Ability: Egg Aim", type="Ability"},
	-- 0x1B > 4
	--{byte=0x1B, bit=5, name="Ability: Fire/Grenade Eggs?", type="Ability"},
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
	{byte=0x1E, bit=7, name="Ability: Breegull Bash", type="Ability"},
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
	{byte=0x25, bit=7, name="Doubloon: Captain Blackeye (1)", type="Doubloon"},
	{byte=0x26, bit=0, name="Doubloon: Captain Blackeye (2)", type="Doubloon"},
	{byte=0x26, bit=1, name="Doubloon: Near Jinjo (1)", type="Doubloon"},
	{byte=0x26, bit=2, name="Doubloon: Near Jinjo (2)", type="Doubloon"},
	{byte=0x26, bit=3, name="Doubloon: Near Jinjo (3)", type="Doubloon"},
	{byte=0x26, bit=4, name="Doubloon: Near Jinjo (4)", type="Doubloon"},
	-- 0x26 > 5
	-- 0x26 > 6
	-- 0x26 > 7
	-- 0x27 > 0
	-- 0x27 > 1
	{byte=0x27, bit=2, name="WW: Pump Room Grate Smashed", type="Physical"},
	-- 0x27 > 3
	{byte=0x27, bit=4, name="Chuffy: TDL Station Open", type="Physical"},
	{byte=0x27, bit=5, name="FT Doubloon Collection", type="FTT"},
	-- 0x27 > 6
	-- 0x27 > 7
	-- 0x28 > 0
	{byte=0x28, bit=1, name="GI: Loggo FTT", type="FTT"},
	-- 0x28 > 2
	-- 0x28 > 3
	-- 0x28 > 4
	-- 0x28 > 5
	-- 0x28 > 6
	-- 0x28 > 7
	-- 0x29 > 0
	-- 0x29 > 1
	-- 0x29 > 2
	{byte=0x29, bit=3, name="TDL: Terry's Nest Drilled", type="Physical"},
	{byte=0x29, bit=4, name="GI: Weldar Intro Cutscene", type="FTT"},
	-- 0x29 > 5
	-- 0x29 > 6
	-- 0x29 > 7
	-- 0x2A > 0
	{byte=0x2A, bit=1, name="GGM: Old King Coal Intro Cutscene", type="FTT"},
	-- 0x2A > 2
	-- 0x2A > 3
	-- 0x2A > 4
	-- 0x2A > 5
	-- 0x2A > 6
	-- 0x2A > 7
	-- 0x2B > 0
	{byte=0x2B, bit=1, name="GI: Bathroom Door Smashed", type="Physical"},
	{byte=0x2B, bit=2, name="MT: Kickball Stadium Link Open", type="Physical"},
	-- 0x2B > 3
	-- 0x2B > 4
	-- 0x2B > 5
	-- 0x2B > 6
	-- 0x2B > 7
	-- 0x2C > 0
	-- 0x2C > 1
	{byte=0x2C, bit=2, name="TDL: Wigwam Enlarged", type="Physical"},
	{byte=0x2C, bit=3, name="MT: Treasure Chamber Open", type="Physical"},
	{byte=0x2C, bit=4, name="GI: Weldar Defeated", type="Progress"},
	-- 0x2C > 5
	{byte=0x2C, bit=6, name="GI: Toxic Waste Pool Raised", type="Physical"},
	-- 0x2C > 7
	-- 0x2D > 0
	-- 0x2D > 1
	-- 0x2D > 2
	-- 0x2D > 3
	-- 0x2D > 4
	-- 0x2D > 5
	-- 0x2D > 6
	-- 0x2D > 7
	-- 0x2E > 0
	-- 0x2E > 1
	-- 0x2E > 2
	-- 0x2E > 3
	-- 0x2E > 4
	-- 0x2E > 5
	-- 0x2E > 6
	{byte=0x2E, bit=7, name="WW: FT Pick Up Big Top Ticket", type="FTT"},
	{byte=0x2F, bit=0, name="GI: Trash Compactor FTT", type="FTT"},
	-- 0x2F > 1
	-- 0x2F > 2
	-- 0x2F > 3
	-- 0x2F > 4
	{byte=0x2F, bit=5, name="FT Jiggy Collection?"},
	-- 0x2F > 6
	{byte=0x2F, bit=7, name="IoH: Mrs. Bottles Intro Cutscene", type="FTT"},
	{byte=0x30, bit=0, name="IoH: Speccy Intro Text Seen", type="FTT"},
	{byte=0x30, bit=1, name="IoH: Amaze-O-Gaze Goggles Instructions Seen"},
	-- 0x30 > 2
	{byte=0x30, bit=3, name="GI: Main Entrance Open", type="Physical"},
	{byte=0x30, bit=4, name="CK: Dingpot FTT", type="FTT"},
	{byte=0x30, bit=5, name="WW: First Time Enter Hoop Hurry"},
	{byte=0x30, bit=6, name="WW: First Time Enter Balloon Burst"},
	-- 0x30 > 7
	{byte=0x31, bit=0, name="GI: Toxic Waste Plant Battery?", type="Progress"},
	-- 0x31 > 1
	-- 0x31 > 2
	-- 0x31 > 3
	{byte=0x31, bit=4, name="GI: Toxic Waste Plant Battery??", type="Progress"},
	-- 0x31 > 5
	-- 0x31 > 6
	-- 0x31 > 7
	-- 0x32 > 0
	-- 0x32 > 1
	{byte=0x32, bit=2, name="Klungo 2 Something?"},
	{byte=0x32, bit=3, name="GI: Floor 1: Backup Defeated", type="Progress"},
	-- 0x32 > 4
	-- 0x32 > 5
	-- 0x32 > 6
	{byte=0x32, bit=7, name="SM: Roysten Rescued", type="Ability"},
	-- 0x33 > 0
	-- 0x33 > 1
	-- 0x33 > 2
	-- 0x33 > 3
	-- 0x33 > 4
	-- 0x33 > 5
	{byte=0x33, bit=6, name="HFP: Gobi in Train Station", type="Progress"},
	-- 0x33 > 7
	-- 0x34 > 0
	-- 0x34 > 1
	-- 0x34 > 2
	-- 0x34 > 3
	-- 0x34 > 4
	-- 0x34 > 5
	-- 0x34 > 6
	-- 0x34 > 7
	-- 0x35 > 0
	{byte=0x35, bit=1, name="Humba Wumba: No Glowbo Needed FTT", type="FTT"},
	-- 0x35 > 2
	-- 0x35 > 3
	-- 0x35 > 4
	-- 0x35 > 5
	-- 0x35 > 6
	-- 0x35 > 7
	-- 0x36 > 0
	-- 0x36 > 1
	-- 0x36 > 2
	{byte=0x36, bit=3, name="CCL: Pot o' Gold Activated", type="Physical"},
	-- 0x36 > 4
	-- 0x36 > 5
	-- 0x36 > 6
	-- 0x36 > 7
	-- 0x37 > 0
	{byte=0x37, bit=1, name="CCL: Rainbow Spawned", type="Physical"},
	{byte=0x37, bit=2, name="CCL: FT Attempt Pot o' Gold?"},
	-- 0x37 > 3
	-- 0x37 > 4
	-- 0x37 > 5
	-- 0x37 > 6
	-- 0x37 > 7
	-- 0x38 > 0
	-- 0x38 > 1
	-- 0x38 > 2
	{byte=0x38, bit=3, name="FT Enter CK?"},
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
	{byte=0x3A, bit=3, name="Jinjo: GGM: Toxic Gas Cave", type="Jinjo"},
	{byte=0x3A, bit=4, name="Jinjo: GGM: Boulder", type="Jinjo"},
	{byte=0x3A, bit=5, name="Jinjo: GGM: Mine Tracks", type="Jinjo"},
	{byte=0x3A, bit=6, name="Jinjo: WW: Big Top", type="Jinjo"},
	{byte=0x3A, bit=7, name="Jinjo: WW: Cave of Horrors", type="Jinjo"},
	{byte=0x3B, bit=0, name="Jinjo: WW: Van Door", type="Jinjo"},
	{byte=0x3B, bit=1, name="Jinjo: WW: Dodgem Dome", type="Jinjo"},
	{byte=0x3B, bit=2, name="Jinjo: WW: Cactus of Strength", type="Jinjo"},
	{byte=0x3B, bit=3, name="Jinjo: JRL: Lagoon Alcove", type="Jinjo"},
	{byte=0x3B, bit=4, name="Jinjo: JRL: Blubber", type="Jinjo"},
	{byte=0x3B, bit=5, name="Jinjo: JRL: Big Fish", type="Jinjo"},
	{byte=0x3B, bit=6, name="Jinjo: JRL: Seaweed Sanctum", type="Jinjo"},
	{byte=0x3B, bit=7, name="Jinjo: JRL: Sunken Ship", type="Jinjo"},
	{byte=0x3C, bit=0, name="Jinjo: TDL: Talon Torpedo", type="Jinjo"},
	{byte=0x3C, bit=1, name="Jinjo: TDL: Cutscene Skip", type="Jinjo"},
	{byte=0x3C, bit=2, name="Jinjo: TDL: Beside Rocknut", type="Jinjo"},
	{byte=0x3C, bit=3, name="Jinjo: TDL: Big T. Rex Skip", type="Jinjo"},
	{byte=0x3C, bit=4, name="Jinjo: TDL: Stomping Plains", type="Jinjo"},
	{byte=0x3C, bit=5, name="Jinjo: GI: Floor 5", type="Jinjo"},
	{byte=0x3C, bit=6, name="Jinjo: GI: Leg Spring", type="Jinjo"},
	{byte=0x3C, bit=7, name="Jinjo: GI: Toxic Waste", type="Jinjo"},
	{byte=0x3D, bit=0, name="Jinjo: GI: Boiler Plant", type="Jinjo"},
	{byte=0x3D, bit=1, name="Jinjo: GI: Outside", type="Jinjo"},
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
	{byte=0x3F, bit=1, name="JRL: Sunken Ship Jinjo Spawned", type="Physical"},
	{byte=0x3F, bit=2, name="Honeycomb: MT: Entrance", type="Honeycomb"},
	{byte=0x3F, bit=3, name="Honeycomb: MT: Bovina", type="Honeycomb"},
	{byte=0x3F, bit=4, name="Honeycomb: MT: Treasure Chamber", type="Honeycomb"},
	{byte=0x3F, bit=5, name="Honeycomb: GGM: Boulder (Toxic Gas Cave)", type="Honeycomb"},
	{byte=0x3F, bit=6, name="Honeycomb: GGM: Boulder", type="Honeycomb"},
	{byte=0x3F, bit=7, name="Honeycomb: GGM: Train Station", type="Honeycomb"},
	{byte=0x40, bit=0, name="Honeycomb: WW: Space Zone", type="Honeycomb"},
	{byte=0x40, bit=1, name="Honeycomb: WW: Mumbo's Skull", type="Honeycomb"},
	{byte=0x40, bit=2, name="Honeycomb: WW: Crazy Castle Area", type="Honeycomb"},
	{byte=0x40, bit=3, name="Honeycomb: JRL: Seemee", type="Honeycomb"},
	{byte=0x40, bit=4, name="Honeycomb: JRL: Atlantis", type="Honeycomb"},
	{byte=0x40, bit=5, name="Honeycomb: JRL: Waste Pipe", type="Honeycomb"},
	{byte=0x40, bit=6, name="Honeycomb: TDL: Central Area", type="Honeycomb"},
	{byte=0x40, bit=7, name="Honeycomb: TDL: Styracosaurus Family Cave", type="Honeycomb"},
	{byte=0x41, bit=0, name="Honeycomb: TDL: River Passage", type="Honeycomb"},
	{byte=0x41, bit=1, name="Honeycomb: GI: Floor 3", type="Honeycomb"},
	{byte=0x41, bit=2, name="Honeycomb: GI: Train Station", type="Honeycomb"},
	{byte=0x41, bit=3, name="Honeycomb: GI: Chimney", type="Honeycomb"},
	{byte=0x41, bit=4, name="Honeycomb: HFP: Inside the Volcano", type="Honeycomb"},
	{byte=0x41, bit=5, name="Honeycomb: HFP: Train Station", type="Honeycomb"},
	{byte=0x41, bit=6, name="Honeycomb: HFP: Lava Side", type="Honeycomb"},
	{byte=0x41, bit=7, name="Honeycomb: CCL: Underground", type="Honeycomb"},
	{byte=0x42, bit=0, name="Honeycomb: CCL: Trash Can", type="Honeycomb"},
	{byte=0x42, bit=1, name="Honeycomb: CCL: Pot o' Gold", type="Honeycomb"},
	{byte=0x42, bit=2, name="Honeycomb: IoH: Plateau", type="Honeycomb"},
	-- 0x42 > 3 JRL Sea Bottom Location?
	-- 0x42 > 4
	-- 0x42 > 5
	{byte=0x42, bit=6, name="GGM: Toxic Gas Cave Boulder Drilled (Empty Honeycomb)", type="Physical"},
	{byte=0x42, bit=7, name="Glowbo: MT: Mumbo's Skull", type="Glowbo"},
	{byte=0x43, bit=0, name="Glowbo: MT: Behind Wumba's Wigwam", type="Glowbo"},
	{byte=0x43, bit=1, name="Glowbo: GGM: Near Entrance", type="Glowbo"},
	{byte=0x43, bit=2, name="Glowbo: GGM: Mine Entrance 2", type="Glowbo"},
	{byte=0x43, bit=3, name="Glowbo: WW: The Inferno", type="Glowbo"},
	{byte=0x43, bit=4, name="Glowbo: WW: Inside Wumba's Wigwam", type="Glowbo"},
	{byte=0x43, bit=5, name="Glowbo: JRL: Pawno's Emporium", type="Glowbo"},
	{byte=0x43, bit=6, name="Glowbo: JRL: Under Wumba's Wigwam", type="Glowbo"},
	{byte=0x43, bit=7, name="Glowbo: TDL: Near Unga Bunga's Cave Entrance", type="Glowbo"},
	{byte=0x44, bit=0, name="Glowbo: TDL: Behind Mumbo's Skull", type="Glowbo"},
	{byte=0x44, bit=1, name="Glowbo: GI: Floor 2", type="Glowbo"},
	{byte=0x44, bit=2, name="Glowbo: GI: Floor 3", type="Glowbo"},
	{byte=0x44, bit=3, name="Glowbo: HFP: Lava Side", type="Glowbo"},
	{byte=0x44, bit=4, name="Glowbo: HFP: Icy Side", type="Glowbo"},
	{byte=0x44, bit=5, name="Glowbo: CCL: Overworld (Underwater)", type="Glowbo"},
	{byte=0x44, bit=6, name="Glowbo: CCL: Central Cavern (Underwater)", type="Glowbo"},
	{byte=0x44, bit=7, name="Glowbo: IoH: Cliff Top", type="Glowbo"},
	{byte=0x45, bit=0, name="Jiggy: MT: Targitzan", type="Jiggy"},
	{byte=0x45, bit=1, name="Jiggy: MT: Targitzan's Slightly Sacred Chamber", type="Jiggy"},
	{byte=0x45, bit=2, name="Jiggy: MT: Kickball", type="Jiggy"},
	{byte=0x45, bit=3, name="Jiggy: MT: Bovina", type="Jiggy"},
	{byte=0x45, bit=4, name="Jiggy: MT: Treasure Chamber", type="Jiggy"},
	{byte=0x45, bit=5, name="Jiggy: MT: Jade Snake Grove: Golden Goliath", type="Jiggy"},
	{byte=0x45, bit=6, name="Jiggy: MT: Prison Compound Quicksand", type="Jiggy"},
	{byte=0x45, bit=7, name="Jiggy: MT: Pillars", type="Jiggy"},
	{byte=0x46, bit=0, name="Jiggy: MT: Top of Temple", type="Jiggy"},
	{byte=0x46, bit=1, name="Jiggy: MT: Ssslumber", type="Jiggy"},
	{byte=0x46, bit=2, name="Jiggy: GGM: Old King Coal", type="Jiggy"},
	{byte=0x46, bit=3, name="Jiggy: GGM: Canary Mary Race", type="Jiggy"},
	{byte=0x46, bit=4, name="Jiggy: GGM: Generator Cavern", type="Jiggy"},
	{byte=0x46, bit=5, name="Jiggy: GGM: Waterfall Cavern", type="Jiggy"},
	{byte=0x46, bit=6, name="Jiggy: GGM: Ordnance Storage", type="Jiggy"},
	{byte=0x46, bit=7, name="Jiggy: GGM: Dilberta", type="Jiggy"},
	{byte=0x47, bit=0, name="Jiggy: GGM: Crushing Shed", type="Jiggy"},
	{byte=0x47, bit=1, name="Jiggy: GGM: Waterfall", type="Jiggy"},
	{byte=0x47, bit=2, name="Jiggy: GGM: Power Hut Basement", type="Jiggy"},
	{byte=0x47, bit=3, name="Jiggy: GGM: Flooded Caves", type="Jiggy"},
	{byte=0x47, bit=4, name="Jiggy: WW: Hoop Hurry", type="Jiggy"},
	{byte=0x47, bit=5, name="Jiggy: WW: Dodgems", type="Jiggy"},
	{byte=0x47, bit=6, name="Jiggy: WW: Mr. Patch", type="Jiggy"},
	{byte=0x47, bit=7, name="Jiggy: WW: Saucer of Peril", type="Jiggy"},
	{byte=0x48, bit=0, name="Jiggy: WW: Balloon Burst", type="Jiggy"},
	{byte=0x48, bit=1, name="Jiggy: WW: Dive of Death", type="Jiggy"},
	{byte=0x48, bit=2, name="Jiggy: WW: Mrs. Boggy", type="Jiggy"},
	{byte=0x48, bit=3, name="Jiggy: WW: Star Spinner", type="Jiggy"},
	{byte=0x48, bit=4, name="Jiggy: WW: The Inferno", type="Jiggy"},
	{byte=0x48, bit=5, name="Jiggy: WW: Cactus of Strength", type="Jiggy"},
	{byte=0x48, bit=6, name="Jiggy: JRL: Mini-Sub Challenge", type="Jiggy"},
	{byte=0x48, bit=7, name="Jiggy: JRL: Tiptup", type="Jiggy"},
	{byte=0x49, bit=0, name="Jiggy: JRL: Chris P. Bacon", type="Jiggy"},
	{byte=0x49, bit=1, name="Jiggy: JRL: Piglet's Pool", type="Jiggy"},
	{byte=0x49, bit=2, name="Jiggy: JRL: Smuggler's Cavern", type="Jiggy"},
	{byte=0x49, bit=3, name="Jiggy: JRL: Merry Maggie Malpass", type="Jiggy"},
	{byte=0x49, bit=4, name="Jiggy: JRL: Lord Woo Fak Fak", type="Jiggy"},
	{byte=0x49, bit=5, name="Jiggy: JRL: Seemee", type="Jiggy"},
	{byte=0x49, bit=6, name="Jiggy: JRL: Pawno's", type="Jiggy"},
	{byte=0x49, bit=7, name="Jiggy: JRL: UFO", type="Jiggy"},
	{byte=0x4A, bit=0, name="Jiggy: TDL: Under Terry's Nest", type="Jiggy"},
	{byte=0x4A, bit=1, name="Jiggy: TDL: Dippy", type="Jiggy"},
	{byte=0x4A, bit=2, name="Jiggy: TDL: Scrotty", type="Jiggy"},
	{byte=0x4A, bit=3, name="Jiggy: TDL: Terry Defeated", type="Jiggy"},
	{byte=0x4A, bit=4, name="Jiggy: TDL: Oogle Boogle Tribe", type="Jiggy"},
	{byte=0x4A, bit=5, name="Jiggy: TDL: Chompa's Belly", type="Jiggy"},
	{byte=0x4A, bit=6, name="Jiggy: TDL: Terry's Babies Hatched", type="Jiggy"},
	{byte=0x4A, bit=7, name="Jiggy: TDL: Stomping Plains", type="Jiggy"},
	{byte=0x4B, bit=0, name="Jiggy: TDL: Rocknut Tribe", type="Jiggy"},
	{byte=0x4B, bit=1, name="Jiggy: TDL: Code of the Dinosaurs", type="Jiggy"},
	{byte=0x4B, bit=2, name="Jiggy: GI: Waste Disposal Underwater", type="Jiggy"},
	{byte=0x4B, bit=3, name="Jiggy: GI: Weldar", type="Jiggy"},
	{byte=0x4B, bit=4, name="Jiggy: GI: Clinker's Cavern", type="Jiggy"},
	{byte=0x4B, bit=5, name="Jiggy: GI: Laundry", type="Jiggy"},
	{byte=0x4B, bit=6, name="Jiggy: GI: Floor 5", type="Jiggy"},
	{byte=0x4B, bit=7, name="Jiggy: GI: Quality Control", type="Jiggy"},
	{byte=0x4C, bit=0, name="Jiggy: GI: Floor 1 Guarded", type="Jiggy"},
	{byte=0x4C, bit=1, name="Jiggy: GI: Trash Compactor", type="Jiggy"},
	{byte=0x4C, bit=2, name="Jiggy: GI: Packing Room", type="Jiggy"},
	{byte=0x4C, bit=3, name="Jiggy: GI: Waste Disposal Box", type="Jiggy"},
	{byte=0x4C, bit=4, name="Jiggy: HFP: Dragon Brothers Defeated", type="Jiggy"},
	{byte=0x4C, bit=5, name="Jiggy: HFP: Inside the Volcano", type="Jiggy"},
	{byte=0x4C, bit=6, name="Jiggy: HFP: Sabreman", type="Jiggy"},
	{byte=0x4C, bit=7, name="Jiggy: HFP: Boggy", type="Jiggy"},
	{byte=0x4D, bit=0, name="Jiggy: HFP: Icy Side Train Station", type="Jiggy"},
	{byte=0x4D, bit=1, name="Jiggy: HFP: Oil Drill", type="Jiggy"},
	{byte=0x4D, bit=2, name="Jiggy: HFP: Stomping Plains Connection", type="Jiggy"},
	{byte=0x4D, bit=3, name="Jiggy: HFP: Kickball", type="Jiggy"},
	{byte=0x4D, bit=4, name="Jiggy: HFP: Alien", type="Jiggy"},
	{byte=0x4D, bit=5, name="Jiggy: HFP: Lava Waterfall", type="Jiggy"},
	{byte=0x4D, bit=6, name="Jiggy: CCL: Mingy Jongo", type="Jiggy"},
	{byte=0x4D, bit=7, name="Jiggy: CCL: Mr. Fit", type="Jiggy"},
	{byte=0x4E, bit=0, name="Jiggy: CCL: Pot o' Gold", type="Jiggy"},
	{byte=0x4E, bit=1, name="Jiggy: CCL: Canary Mary", type="Jiggy"},
	{byte=0x4E, bit=2, name="Jiggy: CCL: Zubba's Nest", type="Jiggy"},
	{byte=0x4E, bit=3, name="Jiggy: CCL: Eyeballus Jiggium Plant", type="Jiggy"},
	{byte=0x4E, bit=4, name="Jiggy: CCL: Cheese Wedge", type="Jiggy"},
	{byte=0x4E, bit=5, name="Jiggy: CCL: Trash Can", type="Jiggy"},
	{byte=0x4E, bit=6, name="Jiggy: CCL: Superstash", type="Jiggy"},
	{byte=0x4E, bit=7, name="Jiggy: CCL: Jelly Castle", type="Jiggy"},
	{byte=0x4F, bit=0, name="Jiggy: IoH: White Jinjo Family", type="Jiggy"},
	{byte=0x4F, bit=1, name="Jiggy: IoH: Orange Jinjo Family", type="Jiggy"},
	{byte=0x4F, bit=2, name="Jiggy: IoH: Yellow Jinjo Family", type="Jiggy"},
	{byte=0x4F, bit=3, name="Jiggy: IoH: Brown Jinjo Family", type="Jiggy"},
	{byte=0x4F, bit=4, name="Jiggy: IoH: Green Jinjo Family", type="Jiggy"},
	{byte=0x4F, bit=5, name="Jiggy: IoH: Red Jinjo Family", type="Jiggy"},
	{byte=0x4F, bit=6, name="Jiggy: IoH: Blue Jinjo Family", type="Jiggy"},
	{byte=0x4F, bit=7, name="Jiggy: IoH: Purple Jinjo Family", type="Jiggy"},
	{byte=0x50, bit=0, name="Jiggy: IoH: Black Jinjo Family", type="Jiggy"},
	{byte=0x50, bit=1, name="Jiggy: IoH: King Jingaling Intro", type="Jiggy"},
	{byte=0x50, bit=2, name="MT: Bovina Jiggy Spawned", type="Physical"},
	{byte=0x50, bit=3, name="MT: Kickball Jiggy Spawned", type="Physical"},
	{byte=0x50, bit=4, name="MT: Ssslumber Jiggy Spawned", type="Physical"},
	{byte=0x50, bit=5, name="MT: Gold Relic Jiggy Spawned", type="Physical"},
	{byte=0x50, bit=6, name="GGM: Canary Mary Jiggy Spawned", type="Physical"},
	{byte=0x50, bit=7, name="GGM: Old King Coal Jiggy Spawned?", type="Physical"},
	{byte=0x51, bit=0, name="WW: Cactus of Strength Jiggy Spawned", type="Physical"},
	-- 0x51 > 1
	-- 0x51 > 2
	-- 0x51 > 3
	-- 0x51 > 4
	{byte=0x51, bit=5, name="WW: Hoop Hurry Jiggy Spawned", type="Physical"},
	-- 0x51 > 6
	{byte=0x51, bit=7, name="JRL: Merry Maggie Malpass Jiggy Spawned", type="Physical"},
	-- 0x52 > 0
	-- 0x52 > 1
	-- 0x52 > 2
	-- 0x52 > 3
	-- 0x52 > 4
	{byte=0x52, bit=5, name="GGM: Dilberta Jiggy Spawned", type="Physical"},
	-- 0x52 > 6
	-- 0x52 > 7
	-- 0x53 > 0
	{byte=0x53, bit=1, name="TDL: Terry Defeated Jiggy Spawned", type="Physical"},
	-- 0x53 > 2
	-- 0x53 > 3
	-- 0x53 > 4
	{byte=0x53, bit=5, name="CCL: Pot o' Gold Jiggy Spawned", type="Physical"},
	{byte=0x53, bit=6, name="FT Jiggy Collection??"}, -- King Jingaling Intro Jiggy Spawned?
	-- 0x53 > 7
	-- 0x54 > 0
	-- 0x54 > 1
	-- 0x54 > 2
	{byte=0x54, bit=3, name="JRL: UFO Jiggy Spawned?", type="Physical"},
	-- 0x54 > 4
	-- 0x54 > 5
	-- 0x54 > 6
	-- 0x54 > 7 Set and cleared upon entering/exiting CCL overworld
	{byte=0x55, bit=0, name="CCL: Mingy Jongo Defeated", type="Progress"},
	-- 0x55 > 1
	{byte=0x55, bit=2, name="WW: Balloon Burst Jiggy Spawned", type="Physical"},
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
	{byte=0x56, bit=6, name="Cheato Page: GGM: Canary Mary Race", type="Cheato Page"},
	{byte=0x56, bit=7, name="Cheato Page: GGM: Level Entrance", type="Cheato Page"},
	{byte=0x57, bit=0, name="Cheato Page: GGM: Water Storage", type="Cheato Page"},
	{byte=0x57, bit=1, name="Cheato Page: WW: Haunted Cavern", type="Cheato Page"},
	{byte=0x57, bit=2, name="Cheato Page: WW: The Inferno (Van)", type="Cheato Page"},
	{byte=0x57, bit=3, name="Cheato Page: WW: Saucer of Peril", type="Cheato Page"},
	{byte=0x57, bit=4, name="Cheato Page: JRL: Pawno's", type="Cheato Page"},
	{byte=0x57, bit=5, name="Cheato Page: JRL: Seemee", type="Cheato Page"},
	{byte=0x57, bit=6, name="Cheato Page: JRL: Ancient Swimming Baths", type="Cheato Page"},
	{byte=0x57, bit=7, name="Cheato Page: TDL: Dippy's Pool", type="Cheato Page"},
	{byte=0x58, bit=0, name="Cheato Page: TDL: Inside the Mountain", type="Cheato Page"},
	{byte=0x58, bit=1, name="Cheato Page: TDL: Boulder", type="Cheato Page"},
	{byte=0x58, bit=2, name="Cheato Page: GI: Loggo", type="Cheato Page"},
	{byte=0x58, bit=3, name="Cheato Page: GI: Floor 2", type="Cheato Page"},
	{byte=0x58, bit=4, name="Cheato Page: GI: Repair Depot", type="Cheato Page"},
	{byte=0x58, bit=5, name="Cheato Page: HFP: Lava Side", type="Cheato Page"},
	{byte=0x58, bit=6, name="Cheato Page: HFP: Icicle Grotto", type="Cheato Page"},
	{byte=0x58, bit=7, name="Cheato Page: HFP: Icy Side", type="Cheato Page"},
	{byte=0x59, bit=0, name="Cheato Page: CCL: Canary Mary", type="Cheato Page"},
	{byte=0x59, bit=1, name="Cheato Page: CCL: Pot o' Gold", type="Cheato Page"},
	{byte=0x59, bit=2, name="Cheato Page: CCL: Zubbas' Nest", type="Cheato Page"},
	{byte=0x59, bit=3, name="Cheato Page: Spiral Mountain", type="Cheato Page"},
	{byte=0x59, bit=4, name="JRL: Pawno's Cheato Page Spawned?", type="Physical"},
	-- 0x59 > 5
	{byte=0x59, bit=6, name="WW: Saucer of Peril Cheato Page Spawned", type="Physical"},
	{byte=0x59, bit=7, name="GGM: Canary Mary Cheato Page Spawned", type="Physical"},
	{byte=0x5A, bit=0, name="CCL: Pot o' Gold Cheato Page Spawned", type="Physical"},
	{byte=0x5A, bit=1, name="GI: Loggo Cheato Page Spawned", type="Physical"},
	{byte=0x5A, bit=2, name="CCL: Zubbas' Nest Cheato Page Spawned", type="Physical"},
	{byte=0x5A, bit=3, name="CCL: Canary Mary Cheato Page Spawned", type="Physical"},
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
	{byte=0x5E, bit=2, name="Klungo 3 Defeated", type="Progress"},
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
	-- 0x5F > 7 Dippy Something
	-- 0x60 > 0 Dippy Something
	-- 0x60 > 1
	-- 0x60 > 2
	-- 0x60 > 3
	-- 0x60 > 4 MT Prison Compound Something
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
	{byte=0x63, bit=2, name="First Time BK Cart Text", type="FTT"},
	-- 0x63 > 3
	{byte=0x63, bit=4, name="JRL: Jukebox is Broken FTT", type="FTT"},
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
	{byte=0x64, bit=7, name="Humba Wumba: Dragon Kazooie FTT", type="FTT"},
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
	{byte=0x66, bit=3, name="IoH: Jiggywiggy's Temple Intro Cutscene", type="FTT"},
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
	{byte=0x67, bit=6, name="MT: Code Chamber Door Smashed", type="Physical"},
	{byte=0x67, bit=7, name="Jiggywiggy Temple Is Over There CS Seen", type="FTT"},
	-- 0x68 > 0
	-- 0x68 > 1
	-- 0x68 > 2
	-- 0x68 > 3
	-- 0x68 > 4
	-- 0x68 > 5
	-- 0x68 > 6
	{byte=0x68, bit=7, name="MT: Targitzan Defeated", type="Progress"},
	-- 0x69 > 0
	-- 0x69 > 1
	-- 0x69 > 2
	-- 0x69 > 3
	-- 0x69 > 4
	{byte=0x69, bit=5, name="HFP: UFO Landed", type="Progress"},
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
	{byte=0x6C, bit=0, name="CCL: Superstash FTT", type="FTT"},
	{byte=0x6C, bit=1, name="CCL: Superstash: 1 Switch Hit", type="Physical"},
	{byte=0x6C, bit=2, name="CCL: Superstash: 9 Switch Hit", type="Physical"},
	{byte=0x6C, bit=3, name="CCL: Superstash: 8 Switch Hit", type="Physical"},
	{byte=0x6C, bit=4, name="CCL: Superstash: 4 Switch Hit", type="Physical"},
	{byte=0x6C, bit=5, name="CCL: Superstash: Opened", type="Physical"},
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
	{byte=0x6E, bit=5, name="JRL: Mumbo's Skull Wall Smashed", type="Physical"},
	{byte=0x6E, bit=6, name="FT Complete Jinjo Family?"},
	-- 0x6E > 7
	-- 0x6F > 0 JRL Sea Bottom Location?
	-- 0x6F > 1 JRL Sea Bottom Location?
	-- 0x6F > 2
	-- 0x6F > 3
	-- 0x6F > 4 JRL Sea Bottom Location?
	-- 0x6F > 5 JRL Sea Bottom Location?
	-- 0x6F > 6
	-- 0x6F > 7
	-- 0x70 > 0
	-- 0x70 > 1
	{byte=0x70, bit=2, name="SM: Jinjo Door Smashed", type="Physical"},
	{byte=0x70, bit=3, name="JRL: UFO Door Smashed", type="Physical"},
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
	{byte=0x77, bit=7, name="IoH: Heggy: Yellow Egg Hatched", type="Progress"},
	-- 0x77 > 2
	{byte=0x77, bit=3, name="Mystery Egg: Blue Acquired", type="Mystery Egg"},
	{byte=0x77, bit=4, name="Mystery Egg: Blue Hatched", type="Mystery Egg"},
	{byte=0x77, bit=5, name="Mystery Egg: Pink Acquired", type="Mystery Egg"},
	{byte=0x77, bit=6, name="Mystery Egg: Pink Hatched", type="Mystery Egg"},
	-- 0x77 > 7
	{byte=0x78, bit=0, name="IoH: Heggy FTT", type="FTT"},
	-- 0x78 > 1
	{byte=0x78, bit=2, name="IoH: Pine Grove Door Open", type="Physical"},
	-- 0x78 > 3
	{byte=0x78, bit=4, name="Ability: Dragon Kazooie", type="Ability"},
	{byte=0x78, bit=5, name="IoH: Disciple of Jiggywiggy FTT", type="FTT"},
	{byte=0x78, bit=6, name="First Warp Available", type="FTT"},
	-- 0x78 > 7
	{byte=0x79, bit=0, name="IoH: Pine Grove: Kazooie Boulder Smashed", type="Physical"},
	-- 0x79 > 1
	-- 0x79 > 2
	-- 0x79 > 3
	{byte=0x79, bit=4, name="JRL: Ground Drilled (1)", type="Physical"},
	{byte=0x79, bit=5, name="JRL: Ground Drilled (2)", type="Physical"},
	{byte=0x79, bit=6, name="JRL: Ground Drilled (3)", type="Physical"},
	{byte=0x79, bit=7, name="JRL: Ground Drilled (4)", type="Physical"},
	{byte=0x7A, bit=0, name="JRL: Ground Drilled (5)", type="Physical"},
	-- 0x7A > 1
	-- 0x7A > 2
	-- 0x7A > 3
	-- 0x7A > 4
	-- 0x7A > 5
	-- 0x7A > 6
	-- 0x7A > 7
	-- 0x7B > 0
	-- 0x7B > 1
	-- 0x7B > 2
	-- 0x7B > 3
	-- 0x7B > 4
	-- 0x7B > 5
	-- 0x7B > 6
	-- 0x7B > 7
	{byte=0x7C, bit=0, name="CCL: Mingy Jongo FTT", type="FTT"},
	-- 0x7C > 1
	-- 0x7C > 2
	-- 0x7C > 3
	{byte=0x7C, bit=4, name="Jamjars First Time Text", type="FTT"},
	-- 0x7C > 5
	{byte=0x7C, bit=6, name="First Time Skill Stop Text", type="FTT"},
	-- 0x7C > 7 Jiggy Boulder Crushed?
	{byte=0x7D, bit=0, name="GGM: Jiggy Boulder Piece Collected (1)", type="Physical"},
	{byte=0x7D, bit=1, name="GGM: Jiggy Boulder Piece Collected (2)", type="Physical"},
	{byte=0x7D, bit=2, name="GGM: Jiggy Boulder Piece Collected (3)", type="Physical"},
	-- 0x7D > 1
	-- 0x7D > 2
	-- 0x7D > 3
	-- 0x7D > 4
	-- 0x7D > 5
	-- 0x7D > 6
	-- 0x7D > 7
	-- 0x7E > 0
	-- 0x7E > 1
	-- 0x7E > 2
	-- 0x7E > 3
	-- 0x7E > 4
	-- 0x7E > 5
	-- 0x7E > 6
	-- 0x7E > 7
	-- 0x7F > 0
	-- 0x7F > 1
	{byte=0x7F, bit=2, name="First Time Jamjars Health Refill", type="FTT"},
	-- 0x7F > 3 Something in the Mingy Jongo fight
	{byte=0x7F, bit=4, name="Jamjars First Lesson Intro", type="FTT"},
	-- 0x7F > 5
	-- 0x7F > 6
	-- 0x7F > 7
	-- 0x80 > 0
	{byte=0x80, bit=1, name="Mumbo Transform FTT", type="FTT"},
	-- 0x80 > 2
	{byte=0x80, bit=2, name="Canary Mary Intro Cutscene", type="FTT"}, -- Canary Cave
	-- 0x80 > 3
	{byte=0x80, bit=4, name="GI: Skivvy FTT", type="FTT"},
	-- 0x80 > 5
	-- 0x80 > 6
	-- 0x80 > 7
	-- 0x81 > 0
	-- 0x81 > 1
	-- 0x81 > 2
	-- 0x81 > 3
	{byte=0x81, bit=4, name="MT: Ssslumber FTT", type="FTT"},
	-- 0x81 > 5
	{byte=0x81, bit=6, name="CK: Drawbridge Open", type="Physical"},
	-- 0x81 > 7
	-- 0x82 > 0
	-- 0x82 > 1
	-- 0x82 > 2
	-- 0x82 > 3
	{byte=0x82, bit=4, name="Jinjo Family FT Cutscene?"},
	{byte=0x82, bit=5, name="FT Complete Jinjo Family??"},
	{byte=0x82, bit=6, name="Chilly Willy Intro Text", type="FTT"},
	{byte=0x82, bit=7, name="Chilli Billi Intro Text", type="FTT"},
	{byte=0x83, bit=0, name="ToT: Set After Round 3 (1)"},
	{byte=0x83, bit=1, name="ToT: Set After Round 3 (2)"},
	{byte=0x83, bit=2, name="ToT: Toggled Between Rounds?"},
	{byte=0x83, bit=3, name="ToT: Toggled Between Rounds??"},
	{byte=0x83, bit=4, name="ToT: Set After Round 3 (3)"},
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
	{byte=0x84, bit=7, name="Nest: MT: Central Path (1)", type="Nest"},
	{byte=0x85, bit=0, name="Nest: MT: Central Path (2)", type="Nest"},
	{byte=0x85, bit=1, name="Nest: MT: Central Path (3)", type="Nest"},
	{byte=0x85, bit=2, name="Nest: MT: Central Path (4)", type="Nest"},
	{byte=0x85, bit=3, name="Nest: MT: Central Path (5)", type="Nest"},
	{byte=0x85, bit=4, name="Nest: MT: Central Path (6)", type="Nest"},
	{byte=0x85, bit=5, name="Nest: MT: Central Path (7)", type="Nest"},
	{byte=0x85, bit=6, name="Nest: MT: Central Path (8)", type="Nest"},
	{byte=0x85, bit=7, name="Nest: MT: Central Path (9)", type="Nest"},
	{byte=0x86, bit=0, name="Nest: MT: Central Path (10)", type="Nest"},
	{byte=0x86, bit=1, name="Nest: MT: Central Path (11)", type="Nest"},
	{byte=0x86, bit=2, name="Nest: MT: Central Path (12)", type="Nest"},
	{byte=0x86, bit=3, name="Nest: MT: Temple Path (1)", type="Nest"},
	{byte=0x86, bit=4, name="Nest: MT: Temple Path (2)", type="Nest"},
	{byte=0x86, bit=5, name="Nest: MT: Temple Path (3)", type="Nest"},
	{byte=0x86, bit=6, name="Nest: MT: Mumbo's Skull Entrance", type="Nest"},
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
	{byte=0x8A, bit=1, name="Nest: WW: Area 51 Gate (1)", type="Nest"},
	{byte=0x8A, bit=2, name="Nest: WW: Area 51 Gate (2)", type="Nest"},
	{byte=0x8A, bit=3, name="Nest: WW: Dodgem Dome Entrance (1)", type="Nest"},
	{byte=0x8A, bit=4, name="Nest: WW: Dodgem Dome Entrance (2)", type="Nest"},
	{byte=0x8A, bit=5, name="Nest: WW: Dive of Death (1)", type="Nest"},
	{byte=0x8A, bit=6, name="Nest: WW: Dive of Death (2)", type="Nest"},
	{byte=0x8A, bit=7, name="Nest: WW: Crazy Castle Entrance (1)", type="Nest"},
	{byte=0x8B, bit=0, name="Nest: WW: Crazy Castle Entrance (2)", type="Nest"},
	{byte=0x8B, bit=1, name="Treble Clef: WW", type="Treble Clef"},
	{byte=0x8B, bit=2, name="Nest: JRL: Town Center (1)", type="Nest"},
	{byte=0x8B, bit=3, name="Nest: JRL: Town Center (2)", type="Nest"},
	{byte=0x8B, bit=4, name="Nest: JRL: Town Center (3)", type="Nest"},
	{byte=0x8B, bit=5, name="Nest: JRL: Blubbul (1)", type="Nest"},
	{byte=0x8B, bit=6, name="Nest: JRL: Blubbul (2)", type="Nest"},
	{byte=0x8B, bit=7, name="Nest: JRL: Eel's Lair Entrance (1)", type="Nest"},
	{byte=0x8C, bit=0, name="Nest: JRL: Eel's Lair Entrance (2)", type="Nest"},
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
	{byte=0x8D, bit=3, name="Nest: TDL: Near Train Station (1)", type="Nest"},
	{byte=0x8D, bit=4, name="Nest: TDL: Near Train Station (2)", type="Nest"},
	{byte=0x8D, bit=5, name="Nest: TDL: Near Train Station (3)", type="Nest"},
	{byte=0x8D, bit=6, name="Nest: TDL: Near Waterfall (1)", type="Nest"},
	{byte=0x8D, bit=7, name="Nest: TDL: Near Waterfall (2)", type="Nest"},
	{byte=0x8E, bit=0, name="Nest: TDL: Near Waterfall (3)", type="Nest"},
	{byte=0x8E, bit=1, name="Nest: TDL: Climbing to Nest (1)", type="Nest"},
	{byte=0x8E, bit=2, name="Nest: TDL: Climbing to Nest (2)", type="Nest"},
	{byte=0x8E, bit=3, name="Nest: TDL: Climbing to Nest (3)", type="Nest"},
	{byte=0x8E, bit=4, name="Nest: TDL: Climbing to Nest (4)", type="Nest"},
	{byte=0x8E, bit=5, name="Nest: TDL: Climbing to Nest (5)", type="Nest"},
	{byte=0x8E, bit=6, name="Nest: TDL: Climbing to Nest (6)", type="Nest"},
	{byte=0x8E, bit=7, name="Nest: TDL: River Passage (1)", type="Nest"},
	{byte=0x8F, bit=0, name="Nest: TDL: River Passage (2)", type="Nest"},
	{byte=0x8F, bit=1, name="Nest: TDL: River Passage (3)", type="Nest"},
	{byte=0x8F, bit=2, name="Nest: TDL: River Passage (4)", type="Nest"},
	{byte=0x8F, bit=3, name="Treble Clef: TDL", type="Treble Clef"},
	{byte=0x8F, bit=4, name="Nest: GI: Train Station (1)", type="Nest"},
	{byte=0x8F, bit=5, name="Nest: GI: Train Station (2)", type="Nest"},
	{byte=0x8F, bit=6, name="Nest: GI: Train Station (3)", type="Nest"},
	{byte=0x8F, bit=7, name="Nest: GI: Floor 1 (1)", type="Nest"},
	{byte=0x90, bit=0, name="Nest: GI: Floor 1 (2)", type="Nest"},
	{byte=0x90, bit=1, name="Nest: GI: Floor 2 (1)", type="Nest"},
	{byte=0x90, bit=2, name="Nest: GI: Floor 2 (2)", type="Nest"},
	{byte=0x90, bit=3, name="Nest: GI: Floor 2 (3)", type="Nest"},
	{byte=0x90, bit=4, name="Nest: GI: Floor 2 (4)", type="Nest"},
	{byte=0x90, bit=5, name="Nest: GI: Floor 2 (5)", type="Nest"},
	{byte=0x90, bit=6, name="Nest: GI: Waste Disposal (1)", type="Nest"},
	{byte=0x90, bit=7, name="Nest: GI: Waste Disposal (2)", type="Nest"},
	{byte=0x91, bit=0, name="Nest: GI: Air Conditioning Plant (1)", type="Nest"},
	{byte=0x91, bit=1, name="Nest: GI: Air Conditioning Plant (2)", type="Nest"},
	{byte=0x91, bit=2, name="Nest: GI: Floor 3 (1)", type="Nest"},
	{byte=0x91, bit=3, name="Nest: GI: Floor 3 (2)", type="Nest"},
	{byte=0x91, bit=4, name="Treble Clef: GI", type="Treble Clef"},
	{byte=0x91, bit=5, name="Nest: HFP: Lava Side: Cliff (1)", type="Nest"},
	{byte=0x91, bit=6, name="Nest: HFP: Lava Side: Cliff (2)", type="Nest"},
	{byte=0x91, bit=7, name="Nest: HFP: Lava Side: Cliff (3)", type="Nest"},
	{byte=0x92, bit=0, name="Nest: HFP: Lava Side: Cliff (4)", type="Nest"},
	{byte=0x92, bit=1, name="Nest: HFP: Lava Side: Cliff (5)", type="Nest"},
	{byte=0x92, bit=2, name="Nest: HFP: Lava Side: Cliff (6)", type="Nest"},
	{byte=0x92, bit=3, name="Nest: HFP: Lava Side: Near Ladder (1)", type="Nest"},
	{byte=0x92, bit=4, name="Nest: HFP: Lava Side: Near Ladder (2)", type="Nest"},
	{byte=0x92, bit=5, name="Nest: HFP: Ice Cube (Oil Drill) (1)", type="Nest"},
	{byte=0x92, bit=6, name="Nest: HFP: Ice Cube (Oil Drill) (2)", type="Nest"},
	{byte=0x92, bit=7, name="Nest: HFP: Ice Cube (Upper Area Warp Pad) (1)", type="Nest"},
	{byte=0x93, bit=0, name="Nest: HFP: Ice Cube (Upper Area Warp Pad) (2)", type="Nest"},
	{byte=0x93, bit=1, name="Nest: HFP: Ice Cube (Boggy's Igloo) (1)", type="Nest"},
	{byte=0x93, bit=2, name="Nest: HFP: Ice Cube (Boggy's Igloo) (2)", type="Nest"},
	{byte=0x93, bit=3, name="Nest: HFP: Ice Cube (Lower Area Warp Pad) (1)", type="Nest"},
	{byte=0x93, bit=4, name="Nest: HFP: Ice Cube (Lower Area Warp Pad) (2)", type="Nest"},
	{byte=0x93, bit=5, name="Treble Clef: HFP", type="Treble Clef"},
	{byte=0x93, bit=6, name="Nest: CCL: Central Cavern (1)", map=0x13A, type="Nest"},
	{byte=0x93, bit=7, name="Nest: CCL: Central Cavern (2)", map=0x13A, type="Nest"},
	{byte=0x94, bit=0, name="Nest: CCL: Central Cavern (3)", map=0x13A, type="Nest"},
	{byte=0x94, bit=1, name="Nest: CCL: Central Cavern (4)", map=0x13A, type="Nest"},
	{byte=0x94, bit=2, name="Nest: CCL: Central Cavern (5)", map=0x13A, type="Nest"},
	{byte=0x94, bit=3, name="Nest: CCL: Central Cavern (6)", map=0x13A, type="Nest"},
	{byte=0x94, bit=4, name="Nest: CCL: Central Cavern (7)", map=0x13A, type="Nest"},
	{byte=0x94, bit=5, name="Nest: CCL: Central Cavern (8)", map=0x13A, type="Nest"},
	{byte=0x94, bit=6, name="Nest: CCL: Central Cavern (9)", map=0x13A, type="Nest"},
	{byte=0x94, bit=7, name="Nest: CCL: Central Cavern (10)", map=0x13A, type="Nest"},
	{byte=0x95, bit=0, name="Nest: CCL: Central Cavern (11)", map=0x13A, type="Nest"},
	{byte=0x95, bit=1, name="Nest: CCL: Central Cavern (12)", map=0x13A, type="Nest"},
	{byte=0x95, bit=2, name="Nest: CCL: Central Cavern (13)", map=0x13A, type="Nest"},
	{byte=0x95, bit=3, name="Nest: CCL: Central Cavern (14)", map=0x13A, type="Nest"},
	{byte=0x95, bit=4, name="Nest: CCL: Central Cavern (15)", map=0x13A, type="Nest"},
	{byte=0x95, bit=5, name="Nest: CCL: Central Cavern (16)", map=0x13A, type="Nest"},
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
	-- 0x98 > 1
	-- 0x98 > 2
	-- 0x98 > 3
	-- 0x98 > 4
	{byte=0x98, bit=5, name="GGM: Levitate Chuffy (2)", type="Mumbo's Magic"},
	-- 0x98 > 6
	-- 0x98 > 7
	-- 0x99 > 0
	-- 0x99 > 1
	-- 0x99 > 2
	-- 0x99 > 3
	{byte=0x99, bit=4, name="First Time Split Up Pad Text", nomap=true, type="FTT"},
	{byte=0x99, bit=5, name="First Time Split Up Text", nomap=true, type="FTT"},
	-- 0x99 > 6
	-- 0x99 > 7
	-- 0x9A > 0
	-- 0x9A > 1
	-- 0x9A > 2
	{byte=0x9A, bit=3, name="GGM: Crushing Shed Active? (1)"},
	{byte=0x9A, bit=4, name="Mumbo's Magic: Levitate: Jiggy Boulder (Levitated?)", type="Mumbo's Magic"},
	{byte=0x9A, bit=5, name="Mumbo's Magic: Levitate: Jiggy Boulder (Placed?)", type="Mumbo's Magic"},
	-- 0x9A > 6
	{byte=0x9A, bit=7, name="GGM: Crushing Shed Active? (2)"},
	{byte=0x9B, bit=0, name="GGM: Jiggy Boulder Crushed?"},
	-- 0x9B > 1
	-- 0x9B > 2
	{byte=0x9B, bit=3, name="FT Enter Waterfall Cavern?"},
	-- 0x9B > 4
	{byte=0x9B, bit=5, name="First Time Mumbo in Wumba's Wigwam", type="FTT"},
	{byte=0x9B, bit=6, name="First Time Jamjars Cutscene", type="FTT"},
	{byte=0x9B, bit=7, name="GGM: Canary Mary Freed (2)", type="Progress"},
	{byte=0x9C, bit=0, name="GGM: Canary Mary Race Intro FTT", type="FTT"},
	{byte=0x9C, bit=1, name="JRL: Underground Doubloon Spawned (1)", type="Physical"},
	{byte=0x9C, bit=2, name="JRL: Underground Doubloon Spawned (2)", type="Physical"},
	{byte=0x9C, bit=3, name="JRL: Underground Doubloon Spawned (3)", type="Physical"},
	{byte=0x9C, bit=4, name="WW: Big Top Ticket Collected (1)"},
	{byte=0x9C, bit=5, name="WW: Big Top Ticket Collected (2)"},
	{byte=0x9C, bit=6, name="WW: Big Top Ticket Collected (3)"},
	{byte=0x9C, bit=7, name="WW: Big Top Ticket Collected (4)"},
	{byte=0x9D, bit=0, name="WW: Big Top Ticket Spawned (1)", type="Physical"},
	{byte=0x9D, bit=1, name="WW: Big Top Ticket Spawned (2)", type="Physical"},
	{byte=0x9D, bit=2, name="WW: Big Top Ticket Spawned (3)", type="Physical"},
	{byte=0x9D, bit=3, name="WW: Big Top Ticket Spawned (4)", type="Physical"},
	{byte=0x9D, bit=4, name="MT: Dilberta Boulder Drilled", type="Physical"},
	-- 0x9D > 5
	{byte=0x9D, bit=6, name="MT: Fly Pad Boulder Drilled", type="Physical"},
	{byte=0x9D, bit=7, name="GGM: Ordnance Storage Boulder Drilled", type="Physical"},
	{byte=0x9E, bit=0, name="GGM: Boulder Drilled Near Prospector's Hut"},
	{byte=0x9E, bit=1, name="GGM: Gloomy Caverns Entrance Boulder Drilled", type="Physical"},
	{byte=0x9E, bit=2, name="GGM: Gloomy Caverns Boulder Drilled (1)", type="Physical"},
	{byte=0x9E, bit=3, name="GGM: Gloomy Caverns Boulder Drilled (2)", type="Physical"},
	{byte=0x9E, bit=4, name="GGM: Toxic Gas Cave Boulder Drilled (Health)", type="Physical"},
	{byte=0x9E, bit=5, name="GGM: Toxic Gas Cave Boulder Drilled (Eggs)", type="Physical"},
	-- 0x9E > 6
	-- 0x9E > 7
	{byte=0x9F, bit=0, name="GGM: Jinjo Boulder Drilled", type="Physical"},
	-- 0x9F > 1
	-- 0x9F > 2
	-- 0x9F > 3
	-- 0x9F > 4
	-- 0x9F > 5
	{byte=0x9F, bit=6, name="IoH: Pleteau: Jinjo Boulder Drilled", type="Physical"},
	-- 0x9F > 7
	-- 0xA0 > 0
	{byte=0xA0, bit=1, name="GGM: Toxic Gas Cave Boulder Drilled (Feathers)", type="Physical"},
	-- 0xA0 > 2
	-- 0xA0 > 3
	-- 0xA0 > 4
	-- 0xA0 > 5
	-- 0xA0 > 6
	-- 0xA0 > 7
	-- 0xA1 > 0
	-- 0xA1 > 1
	{byte=0xA1, bit=2, name="IoH: Jiggywiggy's Temple FT Open?", type="FTT"},
	{byte=0xA1, bit=3, name="IoH: Jiggywiggy's Temple Podium Instructions", type="FTT"},
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
	{byte=0xA3, bit=0, name="FT Fight Klungo?"},
	{byte=0xA3, bit=1, name="FT Enter MT"},
	{byte=0xA3, bit=2, name="FT Fight Targitzan?"},
	{byte=0xA3, bit=3, name="FT Enter GGM"},
	{byte=0xA3, bit=4, name="GGM: FT Enter Canary Race"},
	{byte=0xA3, bit=5, name="GGM: FT Fight Old King Coal?"},
	{byte=0xA3, bit=6, name="FT Enter WW"},
	{byte=0xA3, bit=7, name="CCL: FT Attempt Pot o' Gold??"},
	-- 0xA4 > 0
	-- 0xA4 > 1
	{byte=0xA4, bit=2, name="FT Enter JRL"},
	-- 0xA4 > 3
	{byte=0xA4, bit=4, name="JRL: FT Enter UFO"},
	{byte=0xA4, bit=5, name="JRL: UFO Refuelled", type="Progress"},
	-- 0xA4 > 6
	-- 0xA4 > 7
	{byte=0xA5, bit=0, name="FT Enter TDL"},
	{byte=0xA5, bit=1, name="TDL: FT Terry Fight?"},
	{byte=0xA5, bit=2, name="FT Enter GI"},
	{byte=0xA5, bit=3, name="GI: FT Fight Weldar?"},
	{byte=0xA5, bit=4, name="FT Enter HFP"},
	-- 0xA5 > 5
	{byte=0xA5, bit=6, name="FT Enter CCL"},
	-- 0xA5 > 7 Something in the Mingy Jongo fight
	-- 0xA6 > 0
	{byte=0xA6, bit=1, name="FT Enter CK"},
	{byte=0xA6, bit=2, name="FT Enter ToT"},
	{byte=0xA6, bit=3, name="FT Watch Fake Credits"},
	{byte=0xA6, bit=4, name="FT Fight Hag 1?"},
	{byte=0xA6, bit=5, name="FT Enter IoH"},
	{byte=0xA6, bit=6, name="FT Enter Jinjo Village??"},
	-- 0xA6 > 7
	-- 0xA7 > 0
	{byte=0xA7, bit=1, name="FT Enter King Jingaling's Palace?"},
	{byte=0xA7, bit=3, name="FT Enter Bottles' House?"},
	{byte=0xA7, bit=4, name="FT Enter Heggy's Shed?"},
	-- 0xA7 > 5
	{byte=0xA7, bit=6, name="Honey B. FTT", type="FTT"},
	{byte=0xA7, bit=7, name="First Time Turbo Trainers"},
	{byte=0xA8, bit=0, name="First Time Wading Boots"},
	{byte=0xA8, bit=1, name="First Time Springy Step Shoes"},
	{byte=0xA8, bit=2, name="First Time Claw Clamber Boots"},
	{byte=0xA8, bit=3, name="First Time CWK Shot"},
	{byte=0xA8, bit=4, name="First Boss Fight?"},
	{byte=0xA7, bit=5, name="IoH: First Time Enter Jiggywiggy's Temple"},
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
	{byte=0xAA, bit=0, name="Bottles' Energy Restored", type="Progress"},
	-- 0xAA > 1
	{byte=0xAA, bit=2, name="GGM: Canary Mary Freed (3)", type="Progress"},
	-- 0xAA > 3
	{byte=0xAA, bit=4, name="Mumbo's Magic: Summon: Golden Goliath", type="Mumbo's Magic"},
	{byte=0xAA, bit=5, name="Mumbo's Magic: Enlarge: Wumba's Wigwam", type="Mumbo's Magic"}, -- FT only, this doesn't actually enlarge the Wigwam
	-- 0xAA > 6
	-- 0xAA > 7
	{byte=0xAB, bit=0, name="Mumbo's Magic: Rain Dance", type="Mumbo's Magic"}, -- FT Only
	{byte=0xAB, bit=1, name="IoH: Heggy Split Up Cover Drilled", type="Physical"},
	{byte=0xAB, bit=2, name="ToT: Set After Round 1?"},
	{byte=0xAB, bit=3, name="ToT: Set After Round 2?"},
	{byte=0xAB, bit=4, name="ToT: Round 1 Intro Seen?", type="FTT"},
	{byte=0xAB, bit=5, name="ToT: Round 2 Intro Seen?", type="FTT"},
	{byte=0xAB, bit=6, name="ToT: Round 3 Intro Seen?", type="FTT"},
	-- 0xAB > 7
	-- 0xAC > 0
	-- 0xAC > 1
	-- 0xAC > 2
	-- 0xAC > 3
	-- 0xAC > 4
	-- 0xAC > 5
	{byte=0xAC, bit=6, name="CK: Laser Grid Deactivated", type="Physical"},
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
	{byte=0xAE, bit=4, name="MT: Treasure Chamber Open (Top)", type="Physical"},
	{byte=0xAE, bit=5, name="WW: Boggy Children? (1)"},
	{byte=0xAE, bit=6, name="WW: Boggy Children? (2)"},
	{byte=0xAE, bit=7, name="WW: Boggy Children? (3)"},
	{byte=0xAF, bit=1, name="WW: Boggy Children? (4)"},
	{byte=0xAF, bit=0, name="WW: Boggy Children? (5)"},
	{byte=0xAF, bit=2, name="WW: Boggy Children? (6)"},
	{byte=0xAF, bit=3, name="Cheat Active: Enable Homing Eggs", type="Cheat"},
	-- 0xAF > 4
	-- 0xAF > 5
	-- 0xAF > 6
	-- 0xAF > 7
};

local global_flag_names = {};
local flags_by_address = {};
local flag_names = {};

for i = 1, #flag_array do
	if not flag_array[i].ignore then
		flag_names[i] = flag_array[i].name;
	end
	if flags_by_address[flag_array[i].byte] == nil then
		flags_by_address[flag_array[i].byte] = {};
	end
	flags_by_address[flag_array[i].byte][flag_array[i].bit] = flag_array[i];
end

for i = 0, flag_block_size - 1 do
	if type(flags_by_address[i]) ~= "table" then
		flags_by_address[i] = {};
	end
end

for i = 1, #global_flag_array do
	if not global_flag_array[i].ignore then
		global_flag_names[i] = global_flag_array[i].name;
	end
end

function isKnown(byte, bit)
	return flags_by_address[byte][bit] ~= nil;
end

function getFlagName(byte, bit)
	local flag = flags_by_address[byte][bit];
	if type(flag) == "table" then
		if not flag.ignore then
			return flag.name;
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

function checkFlagByName(name, suppressPrint)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		return checkFlag(flag.byte, flag.bit, suppressPrint);
	end
	return false;
end

function toggleFlagByName(name)
	if checkFlagByName(name, true) then
		clearFlagByName(name);
	else
		setFlagByName(name);
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
			local currentValue = mainmemory.readbyte(flags + byte);
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
			local currentValue = mainmemory.readbyte(flags + byte);
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
	local flags = dereferencePointer(Game.Memory.flag_block_pointer[version]);
	if isRDRAM(flags) then
		local flagBlock = mainmemory.readbyterange(flags, flag_block_size);

		if #flag_block_cache == flag_block_size - 1 then
			local currentValue, previousValue, isSet, wasSet;
			for byte = 0, flag_block_size - 1 do
				currentValue = flagBlock[byte];
				previousValue = flag_block_cache[byte];
				for _bit = 0, 7 do
					isSet = bit.check(currentValue, _bit);
					wasSet = bit.check(previousValue, _bit);
					if isSet and not wasSet then
						if isKnown(byte, _bit) then
							dprint("Flag "..toHexString(byte, 2)..">".._bit..": \""..getFlagName(byte, _bit).."\" was set on frame "..emu.framecount());
						else
							dprint("{byte="..toHexString(byte, 2)..", bit=".._bit..", name=\"Name\"},");
						end
					elseif not isSet and wasSet then
						dprint("Flag "..toHexString(byte, 2)..">".._bit..": \""..getFlagName(byte, _bit).."\" was cleared on frame "..emu.framecount());
					end
				end
			end
			flag_block_cache = flagBlock;
			print_deferred();
		else
			flag_block_cache = flagBlock;
			print("Populated flag block cache");
		end
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
			elseif flagType == "Cutscene" then
				validType = true;
			elseif flagType == "Doubloon" then
				validType = true;
			elseif flagType == "FTT" then
				validType = true;
			elseif flagType == "Glowbo Paid" then
				validType = true;
			elseif flagType == "Mumbo's Magic" then
				validType = true;
			elseif flagType == "Physical" then
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
			--dprint("Warning: Flag without map tag at "..toHexString(flag.byte, 2)..">"..flag["bit"].." with name: \""..name.."\"");
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

------------------
-- Global Flags --
------------------

function isKnownGlobal(byte, bit)
	for i = 1, #global_flag_array do
		if global_flag_array[i].byte == byte and global_flag_array[i].bit == bit then
			return true;
		end
	end
	return false;
end

function getGlobalFlag(byte, bit)
	for i = 1, #global_flag_array do
		if byte == global_flag_array[i].byte and bit == global_flag_array[i].bit then
			return global_flag_array[i];
		end
	end
end

function setGlobalFlag(byte, bit)
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit < 8 then
		local flags = Game.Memory.global_flag_base[version];
		if isRDRAM(flags) then
			local currentValue = mainmemory.readbyte(flags + byte);
			mainmemory.writebyte(flags + byte, set_bit(currentValue, bit));
		end
	end
end

function clearGlobalFlag(byte, bit)
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit < 8 then
		local flags = Game.Memory.global_flag_base[version];
		if isRDRAM(flags) then
			local currentValue = mainmemory.readbyte(flags + byte);
			mainmemory.writebyte(flags + byte, clear_bit(currentValue, bit));
		end
	end
end

function getGlobalFlagName(byte, bit)
	for i = 1, #global_flag_array do
		if byte == global_flag_array[i].byte and bit == global_flag_array[i].bit and not global_flag_array[i].ignore then
			return global_flag_array[i].name;
		end
	end
	return "Unknown at "..toHexString(byte)..">"..bit;
end

function checkGlobalFlags()
	local flags = Game.Memory.global_flag_base[version];
	local flagBlock = mainmemory.readbyterange(flags, global_flag_block_size);
	local currentValue, previousValue, isSet, wasSet, flag, ignore;
	for byte = 0, global_flag_block_size - 1 do
		currentValue = flagBlock[byte];
		previousValue = global_flag_block_cache[byte];
		if previousValue == nil then
			previousValue = currentValue;
		end
		for bit = 0, 7 do
			isSet = check_bit(currentValue, bit);
			wasSet = check_bit(previousValue, bit);
			flag = getGlobalFlag(byte, bit);
			ignore = type(flag) == "table" and flag.ignore;
			if not ignore then
				if isSet and not wasSet then
					if isKnownGlobal(byte, bit) then
						dprint("Global Flag "..toHexString(byte, 2)..">"..bit..": \""..flag.name.."\" was set on frame "..emu.framecount());
					else
						dprint("{byte="..toHexString(byte, 2)..", bit="..bit..", name=\"Name\"}, (GLOBAL)");
					end
				elseif not isSet and wasSet then
					dprint("Global Flag "..toHexString(byte, 2)..">"..bit..": \""..getGlobalFlagName(byte, bit).."\" was cleared on frame "..emu.framecount());
				end
			end
		end
	end
	global_flag_block_cache = flagBlock;
	print_deferred();
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
	["transparency"] = 0x5B, --Byte
	["models"] = {
		--TODO: Import list from
			-- http://thumbsupmaster.blogspot.com.au/p/banjo-tooie-image-modifications.html
			-- http://bsfree.shadowflareindustries.com/index.php?s=39&d=6&g=15729&c=72210
			-- https://www.youtube.com/watch?v=9DDV52RXyiM
			-- Wumba's Wigwam https://banjosbackpack.com/forums/showthread.php?8165-Wumba-s-Wigwam-BT-Setup-Viewer
			-- Possibly other sources
		[0x5DD] = "Sign", -- Pay Here

		[0x5E1] = "Lantern", -- GGM
		[0x5E7] = "1st Floor Sign",
		[0x5E8] = "2nd Floor Sign",
		[0x5E9] = "3rd Floor Sign",
		[0x5EA] = "4th Floor Sign",
		[0x5EB] = "5th Floor Sign",
		[0x5EC] = "Floating Barrel",
		[0x5EE] = "Boggy's Sled",

		[0x5F9] = "Bed", -- Opening CS
		[0x5FD] = "Door", -- Opening CS

		[0x610] = "Jiggy",
		[0x612] = "Empty Honeycomb",
		[0x615] = "Beehive",
		[0x616] = "Wading Boots",
		[0x617] = "Turbo Trainers",
		[0x61C] = "Kazooie", -- Character Parade

		[0x627] = "Missiles", -- Submarine Projectile
		[0x629] = "Molehill",
		[0x62A] = "Banjo-Kazooie", -- ToT
		[0x62B] = "Banjo-Kazooie", -- ToT Multiplayer
		[0x62C] = "Cheese Wedge",
		[0x62D] = "Jelly", -- Heart

		[0x635] = "Shock Spring Pad",
		[0x636] = "Fly Pad",
		[0x637] = "Shadow",
		[0x63B] = "Ice Key",
		[0x63E] = "Loggo",

		[0x641] = "Warp Pad",
		[0x643] = "Jinjo",
		[0x644] = "Star Pad", -- Prison Compound
		[0x645] = "Moon Pad", -- Prison Compound
		[0x646] = "Sun Pad", -- Prison Compound
		[0x647] = "Door", -- MT Prison Compound
		[0x648] = "Mumbo's Skull", -- GGM
		[0x649] = "Column", -- MT Prison Compound
		[0x64A] = "Column", -- MT Column Chamber
		[0x64C] = "Right Arm", -- Old King Coal
		[0x64D] = "Left Arm", -- Old King Coal
		[0x64F] = "Torso", -- Old King Coal

		[0x650] = "Old King Coal",
		[0x651] = "Breakable Door", -- MT Code Chamber
		[0x653] = "Door", -- Bottles after Credits
		[0x654] = "Mayan Door (Left)",
		[0x655] = "Mayan Door (Right",
		[0x656] = "Breakable Stone", -- Entrance to Prison Compound
		[0x657] = "Door", -- Relic Temple
		[0x658] = "Snake Head", -- MT
		[0x65D] = "Door", -- MT Kickball
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
		[0x66A] = "Enemy Kickball Player",
		[0x66B] = "Chief Bloatazin",
		[0x66C] = "Generator",
		[0x66D] = "Dilberta",
		[0x66E] = "Dragunda",
		[0x66F] = "Diggit",

		[0x670] = "Yellow Ball", -- Kickball
		[0x671] = "Ugger",
		[0x672] = "Red Ball", -- Kickball
		[0x673] = "Golden Goliath",
		[0x675] = "Humba Wumba",
		[0x676] = "Stony", -- NPC
		[0x677] = "Bomb Ball", -- Kickball
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
		[0x683] = "Crusher", -- Crushing Shed
		[0x684] = "Conveyor", -- Crushing Shed
		[0x685] = "Button (Wall)", -- GGM Crushing Shed
		[0x686] = "Grinder", -- GGM Crushing Shed
		[0x687] = "Jiggy Rock",
		[0x68B] = "Minecart", -- Broken
		[0x68C] = "Gas", -- Eg. Cheese Wedge
		[0x68F] = "Bang Box",

		[0x691] = "Saucer of Peril", -- In Box
		[0x692] = "Pile of Rocks", -- GGM
		[0x693] = "Conga",
		[0x697] = "Remains", -- Mingy Jongo
		[0x690] = "Saucer of Peril", -- Stationary/Kick about
		[0x698] = "Fish", -- Multiple
		[0x69D] = "Spell", -- Projectile, Mingy Jongo

		[0x6A1] = "TNT",
		[0x6A2] = "Rareware Box", -- SM
		[0x6A5] = "Jiggy Chunk", -- Crushed Jiggy Rock
		[0x6A6] = "Invisibility Honey",
		[0x6A7] = "Button (Floor)", -- Power Hut
		[0x6A8] = "Wooden Hut", -- GGM
		[0x6A9] = "Chuffy", -- Train
		[0x6AA] = "Gun Powder", -- JRL
		[0x6AB] = "Breakable Door", -- GGM Gloomy Caverns
		[0x6AC] = "Shadow", -- Crusher, Crushing Shed
		[0x6AD] = "Salty Joe",
		[0x6AE] = "Big Al",
		[0x6AF] = "Burger",

		[0x6B0] = "Fries",
		[0x6B1] = "Jippo Jim", -- Ringmaster
		[0x6B2] = "Jippo Jim", -- Frankenstein
		[0x6B3] = "Jippo Jim", -- Cowboy
		[0x6B4] = "Jippo Jim", -- Alien
		[0x6B6] = "Particles", -- Mumbo's Wand
		[0x6B7] = "Mrs. Boggy",
		[0x6B8] = "Hothead",
		[0x6B9] = "Pole Electricity",
		[0x6BA] = "Enemy Dodgem Car",
		[0x6BD] = "Bouncy Castle",
		[0x6BE] = "Ghost", -- WW Haunted Cavern

		[0x6C3] = "Pawno",
		[0x6C4] = "Cash Register", -- Pawno's Emporium
		[0x6C5] = "Big Fish",
		[0x6C6] = "Egg", -- Tiptup
		[0x6C7] = "Tiptup Jr.",
		[0x6C8] = "Tiptup",
		[0x6C9] = "Fruity",
		[0x6CA] = "Coin", -- Projectile, Fruity
		[0x6CB] = "Frazzle",
		[0x6CC] = "Scrut",
		[0x6CD] = "Alien",
		[0x6CE] = "Whirlweed",
		[0x6CF] = "Plant",

		[0x6D0] = "Inky",
		[0x6D1] = "Chris P. Bacon",
		[0x6D2] = "Blubbul",
		[0x6D3] = "Stomponadon",
		[0x6D4] = "Captain Blackeye",
		[0x6D5] = "Chompasaurus",
		[0x6D6] = "Jolly Roger",
		[0x6D7] = "Soarasaurs",
		[0x6D8] = "Merry Maggie Malpass",
		[0x6D9] = "Seemee Fish",
		[0x6DA] = "Terry",
		[0x6DC] = "Mucoid", -- Terry, Projectile
		[0x6DD] = "Mucoid", -- Terry
		[0x6DB] = "Captain Blubber",
		[0x6DE] = "Fish",

		[0x6E6] = "Swellbelly",
		[0x6E8] = "Stepping Stone",
		[0x6E9] = "Code Statues",
		[0x6EA] = "Nest (Eggs)",
		[0x6EC] = "Nest (Note)",
		[0x6ED] = "Nest (Treble Clef)",
		[0x6EF] = "Nest (Feathers)",

		[0x6F1] = "Fan", -- Water Supply
		[0x6F2] = "Wumba's Wigwam", -- TDL
		[0x6F3] = "Cage", -- Chris P. Bacon
		[0x6FA] = "Roysten",
		[0x6FB] = "Interactive Object", -- Inc. Warp Clouds, Fire places, UFO Ice Hole
		[0x6FC] = "UFO", -- Cutscene
		[0x6FE] = "Rareware Box",
		[0x6FF] = "Door", -- Chris P. Bacon entrance

		[0x700] = "Rareware Box",
		[0x701] = "Door", -- Madame Grunty's
		[0x702] = "Terry's Egg",
		[0x703] = "Small Pterodactyl",
		[0x704] = "Honeycomb",
		[0x705] = "Honeycomb (Skill/Random)",
		[0x706] = "Stegosaurus", -- Small
		[0x707] = "Klungo",
		[0x708] = "Potion", -- Yellow
		[0x709] = "Toxi-Gag",
		[0x70A] = "Electomagnet",
		[0x70B] = "Door", -- Electromagnet
		[0x70C] = "Door", -- Restricted Access
		[0x70D] = "Door", -- Exterior Jinjo Door GI
		[0x70E] = "Breakable Window", -- GI

		[0x710] = "Breakable Plate", -- GI

		[0x73F] = "Fish", -- Multiple, JRL

		[0x743] = "Spinning Light", -- GI
		[0x744] = "Industrial Fan", -- GI
		[0x745] = "Spinning Pipe", -- GI
		[0x746] = "Crusher", -- GI Trash Compactor
		[0x747] = "Crusher Arm", -- GI Trash Compactor
		[0x748] = "Door", -- Elevator GI
		[0x749] = "Button (Wall)", -- GI
		[0x74A] = "Crusher",
		[0x74B] = "Bridge", -- TDL Inside the Mountain

		[0x752] = "Button (Floor)", -- Shock Spring Spawn
		[0x753] = "Breakable Dirt", -- Terry
		[0x754] = "Button (Floor)", -- Cactus of Strength
		[0x755] = "Stadium Light", -- Mr. Patch
		[0x756] = "Shattered Shock Spring Pad",
		[0x757] = "Glass Box", -- Pawno's
		[0x759] = "Moggy", -- Boggy
		[0x75A] = "Soggy", -- Boggy
		[0x75B] = "Groggy", -- Boggy
		[0x75D] = "Ice", -- Ice Eggs on Enemies
		[0x75F] = "Breakable Gate", -- Talon Torpedo

		[0x760] = "Button (Floor)", -- Al's Burger
		[0x761] = "Breakable Gate", -- Talon Torpedo
		[0x762] = "Breakable Plate", -- JRL
		[0x763] = "Door", -- Jolly's
		[0x764] = "Pile of Dirt", -- JRL
		[0x765] = "Breakable Chest", -- JRL
		[0x766] = "Glowbo",
		[0x767] = "Door", -- Dodgem, 1
		[0x768] = "Door", -- Dodgem, 2
		[0x769] = "Door", -- Dodgem, 3
		[0x76A] = "Door", -- Saucer of Peril
		[0x76B] = "Zubba (Red)",
		[0x76C] = "Zubba (Green)",
		[0x76D] = "Zubba (Blue)",
		[0x76E] = "Red Mine",
		[0x76F] = "Green Mine",

		[0x770] = "Blue Mine",
		[0x774] = "Big Al's (Top)",
		[0x775] = "Salty Joe's (Top)",
		[0x776] = "Boxing Glove", -- Mr. Patch Fight
		[0x777] = "Planet", -- Star Spinner
		[0x778] = "Ring", -- Star Spinner
		[0x779] = "Spinning Star",
		[0x77A] = "Breakable Circuit", -- Star Spinner
		[0x77B] = "Door", -- GGM Old King Coal
		[0x77C] = "Bell", -- Cactus of Strength
		[0x77D] = "Cable Car",
		[0x77E] = "Inferno Door",
		[0x77F] = "Cable Car Button",

		[0x780] = "Electric Gates",
		[0x781] = "Gate", -- Bottle's House
		[0x782] = "Doors", -- WW Train Station
		[0x783] = "Doors", -- WW Train Station
		[0x784] = "Button (Giant T-Rex)", -- Caged Jinjo
		[0x786] = "Breakable Box", -- JRL
		[0x787] = "Cheato",
		[0x788] = "Gobi",
		[0x789] = "Billy Bob",
		[0x78A] = "Billy Bob (Inactive)",
		[0x78B] = "Breakable Door", -- WW Cave of Horrors
		[0x78C] = "Blue Balloon",
		[0x78D] = "Green Balloon",
		[0x78E] = "Cactus of Strength Bar",

		[0x790] = "Prospector",
		[0x791] = "Box", -- GGM Prospector's Hut
		[0x793] = "Breakable Rock", -- MT
		[0x794] = "Mr. Patch",
		[0x795] = "Feet", -- Old King Coal
		[0x796] = "Red Balloon", -- Balloon Burst
		[0x79D] = "Electric Field",
		[0x79F] = "Screw",

		[0x7A0] = "Door", -- Crazy Castle
		[0x7A1] = "Red Hoop", -- Hoop Hurry
		[0x7A2] = "Signpost",
		[0x7A3] = "Door", -- GI Trash Compactor
		[0x7A4] = "Fries", -- Giving to Soggy/Caveman
		[0x7A5] = "Van Door",
		[0x7A6] = "Burger", -- Giving to Groggy/Caveman
		[0x7A7] = "Dingpot",
		[0x7A8] = "Falling Box",
		[0x7A9] = "Falling Platform",
		[0x7AA] = "Springy Step Shoes",
		[0x7AB] = "Service Elevator",
		[0x7AC] = "Ice Cube",
		[0x7AD] = "Screw Seal",
		[0x7AE] = "Gate", -- Metal
		[0x7AF] = "Breakable Door", -- GI Worker's Quarters

		[0x7B1] = "Icicle",
		[0x7B2] = "Icicle",
		[0x7B3] = "Icicle",
		[0x7B4] = "Icicle",
		[0x7B5] = "Icicle",
		[0x7B6] = "Icicle",
		[0x7B7] = "Icicle",
		[0x7B8] = "Button (Floor)", -- Solo Banjo
		[0x7B9] = "Button (Floor)", -- Solo Kazooie
		[0x7BA] = "Button (Floor)", -- Flight Pad
		[0X7BB] = "Fireball", -- HFP Volcano
		[0x7BF] = "Ticket", -- Big Top

		[0x7C0] = "Doubloon",
		[0x7C1] = "Button (Floor)", -- Toxic Waste
		[0x7C2] = "Barrier", -- Targitzan
		[0x7C3] = "Targitzan Base",
		[0x7C4] = "Gate", -- Crossed
		[0x7C5] = "Twinkly (Blue)",
		[0x7C6] = "Twinkly (Green)",
		[0x7C7] = "Twinkly (Red)",
		[0x7C8] = "Targitzan (part)",
		[0x7C9] = "Targitzan (part)",
		[0x7CA] = "Targitzan (part)",
		[0x7CB] = "Targitzan (part)",
		[0x7CC] = "Targitzan (top)",
		[0x7CD] = "Button (Floor)", -- Opens crossed gate
		[0x7CE] = "Button (Wall)", -- Opens crossed gate
		[0x7CF] = "Toxi-Klang", -- GI

		[0x7D0] = "Klang",
		[0x7D1] = "Tintup",
		[0x7D2] = "Silver Coin", -- Van
		[0x7D3] = "Toll Box", -- WW
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
		[0x7E3] = "Spy-I-Cam",
		[0x7E4] = "Bazza",
		[0x7E5] = "Oogle Boogle",
		[0x7E9] = "Dippy",
		[0x7EA] = "Nutta",
		[0x7EB] = "Washup",
		[0x7EC] = "Boltoid",
		[0x7ED] = "Ice", -- Sabreman
		[0x7EE] = "Unga Bunga",
		[0x7EF] = "Sabreman",

		[0x7F3] = "Cheato Page",
		[0x7F4] = "Targitzan",
		[0x7F5] = "Alien Child (Pink)",
		[0x7F6] = "Alien Child (Blue)",
		[0x7F7] = "Alien Child (Yellow)",
		[0x7F8] = "Ice", -- HFP
		[0x7F9] = "Lord Woo Fak Fak",
		[0x7FA] = "Baby T. Rex",
		[0x7FB] = "Glowing Light", -- Lord Woo Projectile
		[0x7FC] = "Chilli Billi",
		[0x7FD] = "Chilly Willy",
		[0x7FE] = "Keelhaul",
		[0x7FF] = "Guvnor", -- GI Worker Enemy

		[0x800] = "Washing Machine",
		[0x801] = "Cannon", -- Dragon Fights
		[0x802] = "Skivvy", -- GI Worker
		[0x803] = "Skivvy", -- GI Worker
		[0x804] = "Germ", -- Green
		[0x805] = "Germ", -- Red
		[0x806] = "Germ", -- Blue
		[0x807] = "Alien Dad",
		[0x808] = "Guffo",
		[0x809] = "Big T. Rex",
		[0x80A] = "Clockwork Kazooie",
		[0x80C] = "File Select (1)",
		[0x80D] = "File Select (2)",
		[0x80E] = "File Select (3)",
		[0x80F] = "Camera",

		[0x810] = "Video Player", -- Main Menu
		[0x811] = "Honeycomb Television",
		[0x812] = "N64 Console",
		[0x813] = "Dustbin", -- Main Menu
		[0x814] = "Ice Ball", -- Chilly Willy
		[0x815] = "Fire Ball", -- Chilli Billi
		[0x816] = "Mingy Jongo",
		[0x817] = "Weldar",
		[0x818] = "Flatso", -- Green
		[0x819] = "Flatso", -- Blue
		[0x81A] = "Flatso", -- Pink
		[0x81B] = "Energy Beam", -- Jiggywiggy's Temple
		[0x81C] = "Bigfoot",
		[0x81E] = "Biggafoot",

		[0x822] = "Klungo Shield",
		[0x823] = "Floor", -- Mingy Jongo cover to exit
		[0x824] = "Invisible Wall", -- Most Wumba's to cover secret passage
		[0x825] = "Red Target", -- Saucer of Peril
		[0x826] = "Green Target", -- Saucer of Peril
		[0x827] = "Blue Target", -- Saucer of Peril
		[0x828] = "Blue Dodgem Car",
		[0x82C] = "Dirt", -- CCL
		[0x82D] = "Pot O' Gold Button", -- CCL
		[0x82E] = "Door", -- Pot O' Gold
		[0x82F] = "Platform", -- Pot O'Gold

		[0x830] = "Protection Screen", -- Quality Control
		[0x832] = "Claw Clamber Boots",
		[0x837] = "Dart", -- Bee
		[0x83B] = "Skivvy", -- Embarrassed
		[0x83C] = "Overalls", -- Clean
		[0x83D] = "Overalls", -- GI Worker
		[0x83E] = "Golden Goliath", -- In Ground
		[0x83F] = "Door", -- Targitzan's Temple, Sacred

		[0x840] = "Door", -- Targitzan's Temple, Entrance
		[0x841] = "Door", -- Targitzan's Temple, Octagonal
		[0x842] = "Door", -- Targitzan's Temple, Green
		[0x843] = "Door", -- Targitzan's Temple, Brown
		[0x844] = "Door", -- Targitzan's Temple, Grey
		[0x845] = "Door", -- Targitzan's Temple, Blue
		[0x846] = "Door", -- Targitzan's Temple, Brown
		[0x847] = "Door", -- Targitzan's Temple, Red/Grey
		[0x848] = "Door", -- Targitzan's Temple, Golden
		[0x849] = "Door", -- Targitzan's Lobby
		[0x84B] = "Dynamite Ticker", -- Ordnance Storage
		[0x84C] = "Dynamite Remains", -- Ordnance Storage
		[0x84D] = "Clinker",
		[0x84F] = "Door", -- Entrance to Clinker's

		[0x850] = "Door", -- Ordnance Storage
		[0x854] = "Mumbo Jumbo",
		[0x85A] = "Press Start", -- Title Demos
		[0x85D] = "Big Tent",
		[0x85F] = "Zubba",

		[0x862] = "Banjo's Hand", -- File Select
		[0x863] = "Puzzle", -- Jiggywiggy
		[0x864]	= "Empty Puzzle", -- Jiggywiggy
		[0x867] = "Red Skull",
		[0x869] = "Door (Left)",
		[0x86A] = "Door (Right)",
		[0x86B] = "Weldar Head",
		[0x86C] = "Electricity Box",
		[0x86D] = "Train Station Switch", -- TDL
		[0x86E] = "Weldar Part",
		[0x86F] = "Weldar",

		[0x870] = "Weldar Head",
		[0x871] = "Electrical Component", -- Weldar
		[0x872] = "Doors", -- HFP Ice Train Station
		[0x873] = "Doors", -- HFP Ice Train Station
		[0x874] = "Tintups Spawner",
		[0x876] = "Goop", -- Terry
		[0x877] = "Green Hoop", -- Hoop Hurry
		[0x878] = "Blue Hoop", -- Hoop Hurry
		[0x87B] = "Door", -- Electric Caution, GI
		[0x87C] = "Metal Door", -- GI
		[0x87D] = "Travelator", -- GI Trash Compactor
		[0x87E] = "Button (Floor)", -- EM Room
		[0x87F] = "Toxic Waste Hatch",

		[0x880] = "Door", -- Fire Hazard, Weldar
		[0x881] = "Breakable Grate", -- GI/ww
		[0x883] = "Button (Floor)", -- Cable Room
		[0x884] = "Toxic Barrel", -- Quality Control
		[0x885] = "Rareware Barrel", -- Quality Control
		[0x886] = "Fan", -- Quality Control
		[0x887] = "Door", -- GI Floor 2
		[0x888] = "Roar Door",
		[0x889] = "Button (Floor)", -- GI
		[0x88F] = "S'Hard",

		[0x892] = "Cannon Flower", -- CCL
		[0x893] = "Eyeballus Jiggium Plant",
		[0x895] = "Pansie",
		[0x896] = "King Jingaling",
		[0x897] = "King Jingaling", -- Zombie
		[0x898] = "Throne", -- King Jingaling
		[0x899] = "Scrotty",
		[0x89A] = "Scrit",
		[0x89B] = "Scrat",
		[0x89C] = "Weldar Fireball",
		[0x89E] = "Mr. Fit",
		[0x89F] = "Onion",

		[0x8A0] = "Mouse", -- CCL, Fixed
		[0x8A1] = "Mouse", -- CCL, Broken
		[0x8A5] = "Sky", -- Opening Cutscene
		[0x8A8] = "Logo", -- Title Demos
		[0x8A9] = "Rock", -- Grunty's Rock
		[0x8AE] = "Mumbo Jumbo", -- Kick About
		[0x8AF] = "Playing Cards", -- Opening CS

		[0x8B0] = "Banjo-Kazooie", -- BK at Controls CS
		[0x8B1] = "Curtains", -- Opening CS
		[0x8B3] = "Rocks", -- Opening CS
		[0x8B4] = "Drill (Hag 1)", -- Opening CS
		[0x8B5] = "Bottles", -- Bottles eating burnt food CS
		[0x8B7] = "Clock", -- Opening CS
		[0x8BA] = "Hag 1", -- Opening CS
		[0x8BB] = "Mingella",
		[0x8BD] = "Blobbelda",
		[0x8BE] = "Gruntilda", -- Jingaling Zapped CS7
		[0x8BF] = "Partcle Spawner",

		[0x8C3] = "Bottles (Burnt)",
		[0x8C5] = "Pile of Money", -- Opening CS
		[0x8C6] = "Power Beam", -- BoB Cutscenes, Green
		[0x8C7] = "Power Beam", -- Jingaling Zapped, Green
		[0x8C8] = "BOB Control Panel",
		[0x8C9] = "Power Beam", -- BoB Cutscenes, Blue
		[0x8CA] = "Power Beam", -- Jingaling/Bottles Restored, Blue
		[0x8CC] = "Door", -- Inside Trash Can
		[0x8CD] = "Door", -- Rear Door GI
		[0x8CE] = "Rainbow", -- CCL
		[0x8CF] = "Bean", -- CCL

		[0x8D0] = "Zubba's Target",
		[0x8D1] = "Door", -- Zubba's
		[0x8D2] = "Glass Bottle", -- Trash Can
		[0x8D4] = "Panel", -- HFP
		[0x8D5] = "Button (Floor)", -- HFP
		[0x8D6] = "Button (Floor)", -- HFP Kickball Lobby
		[0x8D8] = "Gate", -- HFP
		[0x8DA] = "Door", -- Superstash
		[0x8DB] = "Button (Floor)", -- Superstash
		[0x8DC] = "No Food Sign",
		[0x8DD] = "Beanstalk", -- CCL

		[0x8E0] = "Mumbo's Skull", -- TDL
		[0x8E1] = "Blue Skull",
		[0x8E2] = "Breakable Stone", -- JRL/HFP Mumbo's
		[0x8E3] = "Panel", -- Most Mumbo's to hide secret passage
		[0x8E4] = "Locker Door",
		[0x8E5] = "Locker Door",
		[0x8E6] = "Locker Door",
		[0x8E7] = "Locker Door",
		[0x8E8] = "Locker Door",
		[0x8E9] = "Locker Door",
		[0x8EA] = "Locker Door",
		[0x8EB] = "Locker Door",
		[0x8EC] = "Locker Door",
		[0x8ED] = "Electricity", -- CK
		[0x8EE] = "Drawbridge", -- CK
		[0x8EF] = "Breakable Stone", -- JRL

		[0x8F0] = "Breakable Temple", -- HFP
		[0x8F1] = "Boggy",
		[0x8F2] = "Glass Box", -- Toxic Waste
		[0x8F6] = "Door", -- HFP Lava Side Train Station
		[0x8F9] = "Breakable Wall", -- GFP
		[0x8FA] = "Fish", -- Boggy's
		[0x8FC] = "Stick of Dynamite",
		[0x8FE] = "HAG 1",
		[0x8FF] = "Rocknut",

		[0x900] = "Gobgoyle",
		[0x901] = "HAG 1",
		[0x902] = "Gobgoyle",
		[0x903] = "Chuffy Pad",
		[0x904] = "Mortar", -- Hag 1
		[0x905] = "Mortar Fragment", -- Hag 1
		[0x906] = "Mortar Fragment", -- Hag 1
		[0x907] = "Mortar Fragment", -- Hag 1
		[0x908] = "Mortar Fragment", -- Hag 1
		[0x909] = "Bigga-Bazza",
		[0x90A] = "Bigga-Bazza",
		[0x90B] = "Mrs. Bottles",
		[0x90C] = "Klungo", -- Hurt
		[0x90D] = "Klungo", -- Very Hurt
		[0x90E] = "Bottles (Angel)",
		[0x90F] = "Bottles (Devil)",

		[0x910] = "B-K Cartridge",
		[0x911] = "Gold Idol",
		[0x912] = "Water", -- HFP Gobi
		[0x913] = "Jade Idol", -- Targitzan's Temple
		[0x914] = "Heggy",
		[0x915] = "George", -- Ice Cube
		[0x916] = "Mildred", -- Ice Cube
		[0x917] = "Warp Silo",
		[0x918] = "Honey B.",
		[0x919] = "Speccy", -- Bottles' Child
		[0x91A] = "Goggles", -- Bottles' Child
		[0x91B] = "Buzzer", -- ToT
		[0x91C] = "Pieces of HAG 1", -- CK
		[0x91D] = "Buzzer", -- ToT
		[0x91E] = "Buzzer", -- Jamjars ToT Multiplayer
		[0x91F] = "Drill",

		[0x923] = "Floatus Floatsum Egg",
		[0x924] = "Floatus Floatsum", -- CCL
		[0x925] = "Hothand", -- HFP Lava Side
		[0x926] = "Flame", -- HFP Lava Side
		[0x927] = "Flame", -- HFP Lava Side
		[0x92A] = "Breakable Rock", -- Talon Torpedo
		[0x92B] = "Jelly", -- CCL
		[0x92C] = "Hothand", -- HFP Lava Side
		[0x92D] = "Jelly Castle", -- CCL
		[0x92E] = "Jelly", -- Landing pads in CCL

		[0x930] = "Superstash",
		[0x931] = "Chuffy Sign",
		[0x932] = "Button (Floor)",  -- HFP Drill
		[0x933] = "Buzzer", -- Mumbo ToT Multiplayer
		[0x934] = "Buzzer", -- Humba ToT Multiplayer
		[0x935] = "Master Jiggywiggy",
		[0x936] = "Gruntilda", -- ToT
		[0x937] = "Disciple of Jiggywiggy",
		[0x939] = "Particle Spawner",
		[0x93B] = "Burnt Food", -- Bottles eating burnt food CS
		[0x93C] = "Breakable Door", -- Talon Torpedo, UFO
		[0x93D] = "Fries Button",
		[0x93E] = "Beach Ball", -- Projectile, Mr. Patch

		[0x942] = "Button (Floor)", -- Banjo-Kazooie
		[0x943] = "Door", -- Mr. Patch
		[0x944] = "Gate", -- Lord Woo
		[0x945] = "Button (Floor)", -- HFP Volcano
		[0x946] = "Hot Waterfall", -- HFP Lava Side
		[0x947] = "Door", -- HFP to JRL
		[0x948] = "Button (Talon Torpedo)", -- TDL
		[0x949] = "Doors", -- TDL Train Station
		[0x94A] = "Doors", -- TDL Train Station
		[0x94B] = "Button (Wall)", -- Chompa
		[0x94C] = "Electricity", -- Gatehouse
		[0x94D] = "Electricity", -- Gatehouse
		[0x94E] = "Electricity", -- ToT
		[0x94F] = "Doors", -- IoH Train Station

		[0x950] = "Doors", -- IoH Train Station
		[0x951] = "Breakable Door", -- SM Talon Torpedo
		[0x952] = "Breakable Grate", -- Rusted
		[0x956] = "Red Hoop", -- Hoop Hurry
		[0x957] = "Green Hoop", -- Hoop Hurry
		[0x958] = "Blue Hoop", -- Hoop Hurry
		[0x95A] = "Gate", -- HFP Kickball
		[0x95B] = "Button (Floor)", -- HFP Bridge
		[0x96E] = "Gate", -- IoH to JRL
		[0x96F] = "Gate", -- IoH to HFP

		[0x965] = "Door", -- Ice Key
		[0x966] = "Energy Beam", -- Jiggywiggy's Temple
		[0x967] = "Door", -- IoH to MT
		[0x968] = "Door", -- To Jiggywiggy's Temple
		[0x969] = "Grate", -- IoH to GGM
		[0x96A] = "Gate", -- Plateau to Pine Grove
		[0x96B] = "Gate", -- Plateau to Cliff Top
		[0x96C] = "Gate (Left)", -- IoH to WW
		[0x96D] = "Gate (Right)", -- IoH to WW

		[0x970] = "Rock Teeth", -- IoH to TDL
		[0x971] = "Gate (Left)", -- IoH to GI
		[0x972] = "Gate (Right)", -- IoH to GI
		[0x973] = "No Entry Sign", -- GI
		[0x974] = "Purple Mystery Egg",
		[0x975] = "Blue Mystery Egg",
		[0x976] = "Yellow Egg", -- Heggy
		[0x977] = "Jiggywiggy's Altar of Knowledge",
		[0x978] = "Electricty", -- IoH to CK/CK to Hag 1

		[0x999] = "Cracked Ice", -- Heggy
		[0x99A] = "1 Ton Weight", -- ToT
		[0x99B] = "Button (Wall)", -- Fire Switch
		[0x99C] = "Jukebox",
		[0x99D] = "Red Germ", -- Chompa's Belly
		[0x99E] = "Green Germ", -- Chompa's Belly
		[0x99F] = "Blue Germ", -- Chompa's Belly

		[0x9A0] = "Overlay", -- Credits/Character Parade
		[0x9A2] = "Applause Sign",
		[0x9A3] = "Bed", -- Jolly's
		[0x9AF] = "Pointer", -- Grunty Life-Force Machine

		[0x9B4] = "Klungo", -- Sad Party CS
		[0x9BE] = "Red Feather Particles", -- Beak Bomb
		[0x9BF] = "Gold Feath Particles", -- Wonderwing

		[0x9C0] = "Ice Egg", -- Projectile
		[0x9C1] = "Fire Egg", -- Projectile
		[0x9C2] = "Grenade Egg", -- Projectile
		[0x9C3] = "Golden Egg", -- Projectile
		[0x9C4] = "Clockwork Kazooie Egg", -- Projectile
		[0x9C5] = "Proximity Egg", -- Projectile/Wall
		[0x9C7] = "Light (Wall)",

		[0x9D1] = "Underwear", -- Washing Machine
		[0x9D7] = "Blue Egg", -- Projectile

		[0xFFFF] = "Player Model",
	},
};

local function getNumSlots()
	local objectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
	if isRDRAM(objectArray) then
		local firstObject = dereferencePointer(objectArray + 0x04);
		local lastObject = dereferencePointer(objectArray + 0x08);
		if isRDRAM(firstObject) and isRDRAM(lastObject) then
			return math.floor((lastObject - firstObject) / slot_size) + 1;
		end
	end
	return 0;
end

local function getSlotBase(index)
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

local function getObjectModel1Pointers()
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

local function setObjectModel1Position(pointer, x, y, z)
	if isRDRAM(pointer) then
		mainmemory.writefloat(pointer + object_model1.x_position, x, true);
		mainmemory.writefloat(pointer + object_model1.y_position, y, true);
		mainmemory.writefloat(pointer + object_model1.z_position, z, true);
	end
end

local function zipTo(index)
	local objectArray = dereferencePointer(Game.Memory.object_array_pointer[version]);
	if isRDRAM(objectArray) then
		local objectPointer = objectArray + getSlotBase(index);
		local xPos = mainmemory.readfloat(objectPointer + object_model1.x_position, true);
		local yPos = mainmemory.readfloat(objectPointer + object_model1.y_position, true);
		local zPos = mainmemory.readfloat(objectPointer + object_model1.z_position, true);
		Game.setPosition(xPos, yPos, zPos);
	end
end

local function zipToSelectedObject()
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

local function getAnimationType(model1Base)
	local objectIDPointer = dereferencePointer(model1Base + object_model1.id_struct);
	if isRDRAM(objectIDPointer) then
		local modelIndex = mainmemory.read_u16_be(objectIDPointer + 0x14);
		if type(object_model1.models[modelIndex]) == "string" then
			return object_model1.models[modelIndex];
		else
			return toHexString(modelIndex);
		end
	end
	return "Unknown";
end

local green_highlight = 0xFF00FF00;
local yellow_highlight = 0xFFFFFF00;
local max_page_size = 40;

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
		local page_total = math.ceil(getNumSlots() / max_page_size);
		local page_pos = math.floor((object_index - 1) / max_page_size) + 1;
		local page_index = max_page_size + object_index - (page_pos * max_page_size);

		if page_pos < page_total
			then page_size = max_page_size;
		else
			page_size = numSlots - ((page_total - 1) * max_page_size);
		end

		gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, "Page: "..(page_pos).."/"..(page_total), nil, 'bottomright');
		row = row + 1;

		for i = page_size, 1, -1 do
			local currentSlotBase = objectArray + getSlotBase(i + ((page_pos - 1) * max_page_size) - 1);

			local color = nil;
			if page_index == i then
				color = yellow_highlight;
			end

			local xPos = mainmemory.readfloat(currentSlotBase + object_model1.x_position, true);
			local yPos = mainmemory.readfloat(currentSlotBase + object_model1.y_position, true);
			local zPos = mainmemory.readfloat(currentSlotBase + object_model1.z_position, true);

			local animationType = getAnimationType(currentSlotBase);
			if type(object_filter) == "string" and not string.contains(animationType, object_filter) then
				-- Skip
			else
				gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, round(xPos, precision)..", "..round(yPos, precision)..", "..round(zPos, precision).." - "..animationType.." "..i..": "..toHexString(currentSlotBase or 0), color, 'bottomright');
				row = row + 1;
			end
		end
	end
end

-- Keybinds
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm
ScriptHawk.bindKeyRealtime("Z", zipToSelectedObject, true);
ScriptHawk.bindKeyRealtime("C", toggleObjectAnalysisToolsMode, true);
ScriptHawk.bindKeyRealtime("N", decrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("M", incrementObjectIndex, true);
ScriptHawk.bindMouse("mousewheelup", decrementObjectIndex);
ScriptHawk.bindMouse("mousewheeldown", incrementObjectIndex);

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

function Game.getDCWLocation()
	local DCW_locationMap = mainmemory.read_u16_be(Game.Memory.DCW_location[version]);
	local DCW_locationMapName = "Unknown";
	if Game.maps[DCW_locationMap] ~= nil then
		DCW_locationMapName = Game.maps[DCW_locationMap];
	end
	return DCW_locationMapName.." ("..toHexString(DCW_locationMap)..")";
end

function Game.getMaxAir()
	if checkFlagByName("Roysten Rescued", true) then
		return 100;
	end
	return 60;
end

function Game.getCharacterState()
	local characterStateValue = mainmemory.readbyte(Game.Memory.character_state[version]);
	if Game.character_states[characterStateValue] ~= nil then
		return Game.character_states[characterStateValue];
	end
	return characterStateValue;
end

local obfuscatedConsumables = { -- TODO: Extract keys directly from the game
	[0] = {key=0x27BD, name="Blue Eggs"},
	[1] = {key=0x0C03, name="Fire Eggs"},
	[2] = {key=0x0002, name="Ice Eggs"},
	[3] = {key=0x01EE, name="Grenade Eggs"},
	[4] = {key=0x2401, name="CWK Eggs"},
	[5] = {key=0x15E0, name="Jiggies?"},
	[6] = {key=0x1000, name="Red Feathers"},
	[7] = {key=0x3C18, name="Gold Feathers"},
	[8] = {key=0x0003, name="Glowbos"},
	[9] = {key=0x3C0C, name="Empty Honeycombs"},
	[10] = {key=0x0319, name="Cheato Pages"},
	[11] = {key=0x858C, name="Burgers"},
	[12] = {key=0x03E0, name="Fries"},
	[13] = {key=0x27BD, name="Tickets"},
	[14] = {key=0x0C03, name="Doubloons"},
	[15] = {key=0x3C05, name="Gold Idols"},
	[16] = {key=0xFFFD, name="Beans"}, -- CCL
	[17] = {key=0x7A1C, name="Fish"}, -- HFP
	[18] = {key=0xFFBF, name="Eggs"}, -- Stop'n'Swop
	[19] = {key=0x7040, name="Ice Keys"}, -- Stop'n'Swop
	[20] = {key=0xEB9E, name="Mega Glowbos"},
	[21] = {key=0xB363, name="???"},
	[22] = {key=0x0900, name="???"},
	[23] = {key=0xFAFF, name="???"},
};

function Game.setConsumable(index, value)
	if type(obfuscatedConsumables[index]) == "table" then
		local consumablesBlock = dereferencePointer(Game.Memory.consumable_pointer[version]);
		if isRDRAM(consumablesBlock) then
			mainmemory.write_u16_be(consumablesBlock + index * 2, bit.bxor(value, obfuscatedConsumables[index].key));
		end
	end
end

function Game.getConsumable(index)
	local consumablesBlock = dereferencePointer(Game.Memory.consumable_pointer[version]);
	if isRDRAM(consumablesBlock) then
		local normalValue = mainmemory.read_u16_be(Game.Memory.consumable_base[version] + index * 0x0C);
		local obfuscatedValue = mainmemory.read_u16_be(consumablesBlock + index * 2);
		local key = bit.bxor(obfuscatedValue, normalValue);
		return toHexString(obfuscatedValue, 4, "").." XOR "..toHexString(key, 4, "").." = "..normalValue;
	end
	return "Unknown";
end

function Game.applyInfinites()
	Game.setConsumable(0, 999); -- Blue Eggs
	Game.setConsumable(1, 999); -- Fire Eggs
	Game.setConsumable(2, 999); -- Ice Eggs
	Game.setConsumable(3, 999); -- Grenade Eggs
	Game.setConsumable(4, 999); -- CWK Eggs
	Game.setConsumable(6, 999); -- Red Feathers
	Game.setConsumable(7, 999); -- Gold Feathers
	Game.setConsumable(8, 999); -- Glowbos
	Game.setConsumable(9, 999); -- Empty Honeycombs
	Game.setConsumable(10, 999); -- Cheato Pages
	Game.setConsumable(11, 999); -- Burgers
	Game.setConsumable(12, 999); -- Fries
	Game.setConsumable(13, 999); -- Tickets
	Game.setConsumable(14, 999); -- Doubloons
	Game.setConsumable(15, 999); -- Gold Idols
	mainmemory.writefloat(Game.Memory.air[version], Game.getMaxAir(), true);
	Game.setCurrentHealth(Game.getMaxHealth());
end

local move_levels = {
	["1. All"]  = {0xFFFFFFFF, 0xFFFFFFFF},
	["2. None"] = {0xE0FFFF01, 0x00004000},
};

local function unlock_moves()
	local level = forms.gettext(ScriptHawk.UI.form_controls.moves_dropdown);
	local flagBlock = dereferencePointer(Game.Memory.flag_block_pointer[version]);
	if isRDRAM(flagBlock) then
		mainmemory.write_u32_be(flagBlock + 0x18, move_levels[level][1]);
		mainmemory.write_u32_be(flagBlock + 0x1C, move_levels[level][2]);
	end
end

function Game.toggleDragonKazooie()
	toggleFlagByName("Ability: Dragon Kazooie");
end

function Game.initUI()
	-- Flag stuff
	ScriptHawk.UI.form_controls["Flag Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, flag_names, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Set Flag Button"] = forms.button(ScriptHawk.UI.options_form, "Set", flagSetButtonHandler, ScriptHawk.UI.col(10), ScriptHawk.UI.row(7), 46, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Check Flag Button"] = forms.button(ScriptHawk.UI.options_form, "Check", flagCheckButtonHandler, ScriptHawk.UI.col(12), ScriptHawk.UI.row(7), 46, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Clear Flag Button"] = forms.button(ScriptHawk.UI.options_form, "Clear", flagClearButtonHandler, ScriptHawk.UI.col(14), ScriptHawk.UI.row(7), 46, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["realtime_flags"] = forms.checkbox(ScriptHawk.UI.options_form, "Realtime Flags", ScriptHawk.UI.col(10) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);
	--forms.setproperty(ScriptHawk.UI.form_controls.realtime_flags, "Checked", true);

	ScriptHawk.UI.form_controls.toggle_neverslip = forms.checkbox(ScriptHawk.UI.options_form, "Never Slip", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);

	-- Moves
	ScriptHawk.UI.form_controls.moves_dropdown = forms.dropdown(ScriptHawk.UI.options_form, { "1. All", "2. None" }, ScriptHawk.UI.col(5) - ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(4) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls.moves_button = forms.button(ScriptHawk.UI.options_form, "Unlock Moves", unlock_moves, ScriptHawk.UI.col(10), ScriptHawk.UI.row(4), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls.dragon_button = forms.button(ScriptHawk.UI.options_form, "Toggle Dragon Kazooie", Game.toggleDragonKazooie, ScriptHawk.UI.col(10), ScriptHawk.UI.row(5), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);

	-- Character Dropdown
	ScriptHawk.UI.form_controls["Character Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, { "BK", "Snowball", "Cutscene", "Bee", "W. Machine", "Stony", "Breegull B.", "Solo Banjo", "Solo Kazooie", "Submarine", "Mumbo", "G. Goliath", "Detonator", "Van", "Cwk Kazooie", "Small T-Rex", "Big T-Rex" }, ScriptHawk.UI.col(5) - ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(5) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(3) + 10, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Character Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "", ScriptHawk.UI.col(9) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(5) + ScriptHawk.UI.dropdown_offset);

	flagStats();
end

function Game.eachFrame()
	if forms.ischecked(ScriptHawk.UI.form_controls.toggle_neverslip) then
		neverSlip();
	end
	if type(ScriptHawk.UI.form_controls["realtime_flags"]) ~= "nil" and forms.ischecked(ScriptHawk.UI.form_controls["realtime_flags"]) then
		checkFlags();
		checkGlobalFlags();
	end
	if encircle_enabled then
		encircle_banjo();
	end

	-- Check EEPROM checksums
	local checksum_value;
	for i = 1, #eep_checksum do
		checksum_value = readChecksum(eep_checksum[i].address);
		if not checksumsMatch(checksum_value, eep_checksum[i].value) then
			if i > 2 then
				print("Slot "..(i - 2).." Checksum: "..checksumToString(eep_checksum[i].value).." -> "..checksumToString(checksum_value));
			else
				print("Global Flags "..i.." Checksum: "..checksumToString(eep_checksum[i].value).." -> "..checksumToString(checksum_value));
			end
			eep_checksum[i].value = checksum_value;
		end
	end

	if camera_lock.enabled then
		Game.setCameraXPosition(camera_lock.x);
		Game.setCameraYPosition(camera_lock.y);
		Game.setCameraZPosition(camera_lock.z);
	end

	if forms.ischecked(ScriptHawk.UI.form_controls["Character Checkbox"]) then
		local characterString = forms.getproperty(ScriptHawk.UI.form_controls["Character Dropdown"], "SelectedItem");
		if type(Game.character_change_lookup[characterString]) == "number" then
			mainmemory.write_u8(Game.Memory.character_change[version], Game.character_change_lookup[characterString]);
		end
	end
end

Game.OSDPosition = {2, 70};
Game.OSD = {
	{"Map", Game.getMapOSD},
	{"DCW", Game.getDCWLocation},
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
	{"Character", Game.getCharacterState},
	{"Movement", Game.getCurrentMovementState},
	{"Slope Timer", Game.getSlopeTimer, Game.colorSlopeTimer},
	{"Separator", 1},
	{"Camera", function() return toHexString(Game.getCameraObject()) end},
	{"Camera X", Game.getCameraXPosition},
	{"Camera Y", Game.getCameraYPosition},
	{"Camera Z", Game.getCameraZPosition},
};

return Game;