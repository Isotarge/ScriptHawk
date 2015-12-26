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

	"Crash 0x00B0", "Crash 0x00B1", "Unknown 0x00B2", "Crash 0x00B3", "Unknown 0x00B4", "Crash 0x00B5", 

	"MT - Humba's Wigwam",
	"MT - Mumbo's Skull",
	"MT - Mayahem Temple",
	"MT - Prison Compound",

	"Unknown 0x00BA", "Unknown 0x00BB",

	"MT - Code chamber",

	"Crash 0x00BD", "Crash 0x00BE", "Unknown 0x00BF",
	"Crash 0x00C0", "Crash 0x00C1", "Crash 0x00C2", "Crash 0x00C3",

	"MT - Jade snake grove",
	"MT - Treasure chamber",
	"MT - Kickball arena",
	"GGM",
	"MT - Kickball arena",
	"MT - Kickball arena",

	"GGM - Fuel depot",
	"GGM - Crushing shed",
	"GGM - Flooded caves",
	"GGM - Water storage",
	"GGM - Waterfall cavern",
	"GGM - Power hut basement",
	"GGM - Chuffy's cab",
	"GGM - Inside Chuffy's boiler",
	"GGM - Gloomy caverns",
	"GGM - Generator caverns",
	"GGM - Power hut",
	"GGM - Humba's Wigwam",

	"WW - Witchy World",

	"GGM - Train station",
	"GGM - Prospectors hut",
	"GGM - Mumbo's Skull",
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

	"GGM - Humba's Wigwam",
	"WW - cave of horrors",
	"WW - haunted cavern",
	"WW - Train station",
	"JRL - Jolly's",
	"JRL - Pawno's emporium",
	"JRL - Mumbo's Skull",

	"Crash 0x00F0",

	"HP - Inside the UFO",

	"Unknown 0x00F2", "Crash 0x00F3",

	"JRL - Ancient Swimming Baths",

	"Crash 0x00F5",

	"JRL - Electric Eel's lair",
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

	"TDL - Overworld",
	"TDL - Terry's nest",
	"TDL - Train station",
	"TDL - Oogle Boogles cave",
	"TDL - Inside the mountain",
	"TDL - River passage",
	"TDL - Styracosaurus family cave",
	"TDL - Unga Bunga's cave",
	"TDL - Stomping plains",
	"TDL - Bonfire cavern",

	"Crash 0x011C", "Crash 0x011D",

	"TDL - Humba's Wigwam",
	"GI - Wide angle Humba's Wigwam",
	"JRL - Wide angle Humba's Wigwam",
	"GGM - Inside Chuffy's wagon",
	"TDL - Wide angle Humba's Wigwam",
	"TDL - Inside Chompa's belly",
	"WW - Saucer of Peril",
	"GI - Water supply pipe",
	"GGM - Water supply pipe",

	"HP - Lava side",
	"HP - Icy side",
	"HP - Lava train station",
	"HP - Ice train station",
	"HP - Chilli Billi",
	"HP - Chilly Willy",
	"HP - Colosseum kickball stadium lobby",
	"HP - Colosseum kickball stadium - wide angle",
	"HP - Colosseum kickball stadium - wide angle",
	"HP - Colosseum kickball stadium - wide angle",
	"HP - Boggy's igloo",
	"HP - Icicle grotto",
	"HP - Inside the volcano",
	"HP - Mumbo's Skull",
	"HP - Humba's Wigwam",

	"CCL - Cloud Cuckoo Land",
	"CCL - Inside the trashcan",
	"CCL - Inside the cheesewedge",
	"CCL - Zubba's nest",
	"CCL - Central cavern",

	"WW - Crazy castle stockade (Saucer)",
	"WW - Star spinner (Saucer)",

	"CCL - Inside the pot'o'gold",
	"CCL - Mumbo's Skull",
	"CCL - Mingy Jongo's Skull",
	"CCL - Humba's Wigwam",

	"SM - Inside the digger tunnel",

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

	"IoH - Plateau",
	"IoH - Plateau - Honey B's Hive",
	"IoH - Pine Grove",
	"IoH - Cliff top",
	"IoH - Cliff top - Mumbo's Skull",
	"IoH - Pine Grove - Humba's Wigwam",

	"Game select screen",
	"Opening cutscene",

	"IoH - Wasteland",
	"IoH - Inside another digger tunnel",
	"IoH - Quagmire",

	"CK - Cauldron Keep",
	"CK - The gatehouse",
	"CK - Tower of Tragedy",
	"CK - Gun chamber",

	"CCL",

	"GI - Floor 4 - Clinker's cavern",

	"GGM - Ordnance Storage entrance",
	"GGM - Ordnance Storage ",
	"GGM - Ordnance Storage (multiplayer)",

	"MT - Targitzan's temple (multiplayer)",
	"MT - (still)",
	"HP - Icy side (still)",
	"JV - Bottles' house (still)",
	"CK - Gun room (still)",

	"Crash 0x016B", "Crash 0x016C", "Crash 0x016D", "Crash 0x016E",

	"GGM - Testing",
	"GGM - Testing",
	"GGM - Mumbo's Skull",

	"GI - Mumbo's Skull",

	"SM - Banjo's house",

	"Crash 0x0174", "Crash 0x0175",

	"WW - Mumbo's Skull",

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
	"TDL - Chompa's belly (multiplayer)",

	"Crash 0x0184",

	"CCL - Trash can mini",
	"WW - Dodgems",
	"GI - Sewer entrance",
	"CCL - Zubba's nest (multiplayer)",

	"Crash 0x0189",

	"CK - Inside HAG1",
	"0x018B - Intro screen",

	"Crash 0x018C",

	"Cutscene - Jingaling zapped",
	"Cutscene - Meanwhile....Jingaling zapping",
	"Cutscene - B.O.B preparing to fire",
	"Cutscene - Jingaling getting zapped",
	"Cutscene - Sad Party at Bottles",
	"Cutscene - Bottles eating burnt food",
	"Cutscene - Bottle's energy restoring",
	"Cutscene - Banjo and Kazooie running into Gun Chamber",
	"Cutscene - Banjo and Kazooie at B.O.B's controls",
	"Cutscene - Kick about",
	"Cutscene - `I wonder what we'll hit...` Kazooie",
	"Cutscene - Jingaling restoring",
	"Cutscene - All Jinjos happy again",

	"CK - HAG1",
	"JV - Jingaling's Zombified Palace",

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

local air;
local game_time_base;
local linked_list_root;
local map;
local map_trigger;

function Game.detectVersion(romName)
	if bizstring.contains(romName, "Australia") then
		air = 0x12B050; -- TODO
		game_time_base = 0x131520;
		linked_list_root = 0x13C380;
		map = 0x127640; -- TODO
		map_trigger = 0x127642; -- TODO
	elseif bizstring.contains(romName, "Europe") then
		air = 0x12B050; -- TODO
		game_time_base = 0x1317B0;
		linked_list_root = 0x13C680;
		map = 0x127640; -- TODO
		map_trigger = 0x127642; -- TODO
	elseif bizstring.contains(romName, "Japan") then
		air = 0x12B050; -- TODO
		game_time_base = 0x126970;
		linked_list_root = 0x131850;
		map = 0x127640; -- TODO
		map_trigger = 0x127642; -- TODO
	elseif bizstring.contains(romName, "USA") then
		air = 0x12B050;
		game_time_base = 0x12C7A0;
		linked_list_root = 0x137800;
		map = 0x127640;
		map_trigger = 0x127642;
	else
		return false;
	end

	return true;
end

local function isPointer(number)
	return number >= 0x000000 and number <= 0x3FFFFF;
end

function resolvePointer(base, index)
	if isPointer(base) then
		return mainmemory.read_u32_be(base + index) - 0x80000000;
	end
end

local function find_root(object)
	while object > 0 do
		print(toHexString(object));
		object = mainmemory.read_u24_be(object + 1);
	end
end

---------------------
-- Game time stuff --
---------------------

previousGameTime = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
gameTime = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

local function checkGameTime()
	previousGameTime = gameTime;	
	gameTime = {};

	local i;
	for i=1,15 do
		table.insert(gameTime, mainmemory.readfloat(game_time_base + (i * 4), true))
	end
end

function gameTimeHasChanged()
	return deepcompare(previousGameTime, gameTime, true);
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_index = 7;

Game.rot_speed = 10;
Game.max_rot_units = 360;

function Game.isPhysicsFrame()
	return gameTimeHasChanged() and not emu.islagged();
end

------------------------
-- Player object shit --
------------------------

-- Update this each frame
playerObject = nil;

-- Relative to objects in linked list, including player
local previous_item = 0x00;
local next_item = 0x04;

local slope_pointer_index = 44 * 4;
local velocity_pointer_index = 54 * 4;
local rot_x_pointer_index = 59 * 4;
local position_pointer_index = 61 * 4;
local rot_z_pointer_index = 65 * 4;
local rot_y_pointer_index = 66 * 4;

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
local y_velocity = 0x14;

local function getPlayerObject()
	local playerFound = false;
	local i;

	-- Get first object in linked list
	local objectBase = resolvePointer(linked_list_root, next_item);

	-- Iterate through linked list looking for pointer list that matches a known template
	while not playerFound and isPointer(objectBase) do
		-- Check if current linked list object has pointers in the correct spots
		local slopeObjectPointer = resolvePointer(objectBase, slope_pointer_index);
		local positionObjectPointer = resolvePointer(objectBase, position_pointer_index);
		local rotXObjectPointer = resolvePointer(objectBase, rot_x_pointer_index);
		local rotYObjectPointer = resolvePointer(objectBase, rot_y_pointer_index);
		local rotZObjectPointer = resolvePointer(objectBase, rot_z_pointer_index);
		local velocityObjectPointer = resolvePointer(objectBase, velocity_pointer_index);

		if isPointer(positionObjectPointer) and isPointer(rotXObjectPointer) and isPointer(rotYObjectPointer) and isPointer(rotZObjectPointer) and isPointer(velocityObjectPointer) and isPointer(slopeObjectPointer) then
			playerFound = true;

			-- Check for pointers near player pointer to make sure
			for i=4,89 do
				if not isPointer(resolvePointer(objectBase, i * 4)) then
					playerFound = false;
				end
			end
		end

		-- Get next object in linked list
		if not playerFound then
			objectBase = resolvePointer(objectBase, next_item);
		end
	end

	if playerFound then
		return objectBase;
	end
end

function output_objects()
	if type(playerObject) ~= "nil" then
		print("Player: "..toHexString(playerObject, nil, ""));
		print("Position: "..toHexString(resolvePointer(playerObject, position_pointer_index), nil, ""));
		print("Rot X: "..toHexString(resolvePointer(playerObject, rot_x_pointer_index), nil, ""));
		print("Rot Y: "..toHexString(resolvePointer(playerObject, rot_y_pointer_index), nil, ""));
		print("Rot Z: "..toHexString(resolvePointer(playerObject, rot_z_pointer_index), nil, ""));
		print("Slope: "..toHexString(resolvePointer(playerObject, slope_pointer_index), nil, ""));
		print("Velocity: "..toHexString(resolvePointer(playerObject, velocity_pointer_index), nil, ""));
	else
		print("Can't get a read...");
	end
end

--------------
-- Position --
--------------

function Game.getXPosition()
	if type(playerObject) ~= "nil" then
		return mainmemory.readfloat(resolvePointer(playerObject, position_pointer_index) + x_pos, true);
	end
	return 0;
end

function Game.getYPosition()
	if type(playerObject) ~= "nil" then
		return mainmemory.readfloat(resolvePointer(playerObject, position_pointer_index) + y_pos, true);
	end
	return 0;
end

function Game.getZPosition()
	if type(playerObject) ~= "nil" then
		return mainmemory.readfloat(resolvePointer(playerObject, position_pointer_index) + z_pos, true);
	end
	return 0;
end

function Game.setXPosition(value)
	if type(playerObject) ~= "nil" then
		local playerPositionObject = resolvePointer(playerObject, position_pointer_index);
		mainmemory.writefloat(playerPositionObject + x_pos, value, true);
		mainmemory.writefloat(playerPositionObject + x_pos + 12, value, true);
		mainmemory.writefloat(playerPositionObject + x_pos + 24, value, true);
	end
end

function Game.setYPosition(value)
	if type(playerObject) ~= "nil" then
		local playerPositionObject = resolvePointer(playerObject, position_pointer_index);

		mainmemory.writefloat(playerPositionObject + y_pos, value, true);
		mainmemory.writefloat(playerPositionObject + y_pos + 12, value, true);
		mainmemory.writefloat(playerPositionObject + y_pos + 24, value, true);

		-- Nullify Y velocity
		mainmemory.writefloat(resolvePointer(playerObject, velocity_pointer_index) + y_velocity, 0, true);
	end
end

function Game.setZPosition(value)
	if type(playerObject) ~= "nil" then
		local playerPositionObject = resolvePointer(playerObject, position_pointer_index);
		mainmemory.writefloat(playerPositionObject + z_pos, value, true);
		mainmemory.writefloat(playerPositionObject + z_pos + 12, value, true);
		mainmemory.writefloat(playerPositionObject + z_pos + 24, value, true);
	end
end

--------------
-- Velocity --
--------------

function Game.getYVelocity()
	if type(playerObject) ~= "nil" then
		local playerVelocityObject = resolvePointer(playerObject, velocity_pointer_index);
		return mainmemory.readfloat(playerVelocityObject + y_velocity, true);
	end
	return 0;
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	if type(playerObject) ~= "nil" and isPointer(playerObject) then
		return mainmemory.readfloat(resolvePointer(playerObject, rot_x_pointer_index) + x_rot_current, true);
	end
	return 0;
end

function Game.getYRotation()
	if type(playerObject) ~= "nil" and isPointer(playerObject) then
		return mainmemory.readfloat(resolvePointer(playerObject, rot_y_pointer_index) + facing_angle, true);
	end
	return 0;
end

function Game.getZRotation()
	if type(playerObject) ~= "nil" and isPointer(playerObject) then
		return mainmemory.readfloat(resolvePointer(playerObject, rot_z_pointer_index) + z_rot_current, true);
	end
	return 0;
end

function Game.setXRotation(value)
	if type(playerObject) ~= "nil" then
		local rotXObject = resolvePointer(playerObject, rot_x_pointer_index);
		mainmemory.writefloat(rotXObject + x_rot_current, value, true);
		mainmemory.writefloat(rotXObject + x_rot_target, value, true);
	end
end

function Game.setYRotation(value)
	if type(playerObject) ~= "nil" then
		local rotYObject = resolvePointer(playerObject, rot_y_pointer_index);
		mainmemory.writefloat(rotYObject + facing_angle, value, true);
		mainmemory.writefloat(rotYObject + moving_angle, value, true);
	end
end

function Game.setZRotation(value)
	if type(playerObject) ~= "nil" then
		local rotZObject = resolvePointer(playerObject, rot_z_pointer_index);
		mainmemory.writefloat(rotZObject + z_rot_current, value, true);
		mainmemory.writefloat(rotZObject + z_rot_target, value, true);
	end
end

----------------
-- Never Slip --
----------------

local options_toggle_neverslip;

local function neverSlip()
	if type(playerObject) ~= "nil" then
		mainmemory.writefloat(resolvePointer(playerObject, slope_pointer_index) + slope_timer, 0.0, true);
	end
end

------------
-- Health --
------------

local iconAddress = 0x11B065;
local healthAddresses = {
	[0x01] = {0x11B644, 0x11B645}, -- BK
	[0x10] = {0x11B65F, 0x11B660}, -- Banjo (Solo)
	[0x11] = {0x11B668, 0x11B669}, -- Mumbo
	[0x2D] = {0x11B659, 0x11B65A}, -- Stony
	[0x2E] = {0x11B66E, 0x11B66F}, -- Detonator
	[0x2F] = {0x11B665, 0x11B666}, -- Submarine
	[0x30] = {0x11B677, 0x11B678}, -- Dinosaur
	[0x31] = {0x11B653, 0x11B654}, -- Bee
	[0x32] = {0x11B647, 0x11B648}, -- Snowball
	[0x36] = {0x11B656, 0x11B657}, -- Washing Machine
	[0x5F] = {0x11B662, 0x11B663} -- Kazooie (Solo)
}

function Game.getCurrentHealth()
	local currentTransformation = mainmemory.readbyte(iconAddress);
	if type(healthAddresses[currentTransformation]) == 'table' then
		return mainmemory.read_u8(healthAddresses[currentTransformation][1]);
	end
	return 1;
end

function Game.setCurrentHealth(value)
	local currentTransformation = mainmemory.readbyte(iconAddress);
	if type(healthAddresses[currentTransformation]) == 'table' then
		value = value or 0;
		value = math.max(0x00, value);
		value = math.min(0xFF, value);
		return mainmemory.write_u8(healthAddresses[currentTransformation][1], value);
	end
end

function Game.getMaxHealth()
	local currentTransformation = mainmemory.readbyte(iconAddress);
	if type(healthAddresses[currentTransformation]) == 'table' then
		return mainmemory.read_u8(healthAddresses[currentTransformation][2]);
	end
	return 1;
end

function Game.setMaxHealth(value)
	local currentTransformation = mainmemory.readbyte(iconAddress);
	if type(healthAddresses[currentTransformation]) == 'table' then
		value = value or 0;
		value = math.max(0x00, value);
		value = math.min(0xFF, value);
		return mainmemory.write_u8(healthAddresses[currentTransformation][2], value);
	end
end

function outputHealth()
	print("Health: "..Game.getCurrentHealth().."/"..Game.getMaxHealth());
end

------------
-- Events --
------------

function Game.setMap(value)
	local trigger_value = mainmemory.read_u16_be(map_trigger);
	if trigger_value == 0 then
		print("Travelling to "..value);
		mainmemory.write_u16_be(map, value);
		mainmemory.write_u16_be(map_trigger, 0x0101);
	end
end

local max_air = 60;

function Game.applyInfinites()
	-- TODO
	local maxHealth = Game.getMaxHealth();
	Game.setCurrentHealth(maxHealth);
	mainmemory.writefloat(air, max_air, true);
end

function Game.initUI(form_handle, col, row, button_height, label_offset, dropdown_offset)
	options_toggle_neverslip = forms.checkbox(form_handle, "Never Slip", col(0) + dropdown_offset, row(6) + dropdown_offset);
end

function Game.eachFrame()
	playerObject = getPlayerObject();
	checkGameTime();

	if forms.ischecked(options_toggle_neverslip) then
		neverSlip();
	end
end

return Game;