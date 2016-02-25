local pointer_list;
local player_pointer;
local camera_pointer;
local obj_model2_array_pointer;
local obj_model2_array_count;

hide_non_scripted = false;
encircle_enabled = false;
rat_enabled = false;
local object_pointers = {};
local object_index = 1;
local max_objects = 0xFF;
local radius = 100;

local grab_script_modes = {
	"List (Object Model 1)",
	"Examine (Object Model 1)",
	"List (Object Model 2)",
	"Examine (Object Model 2)",
};

local grab_script_mode_index = 1;
grab_script_mode = grab_script_modes[grab_script_mode_index];

local function switch_grab_script_mode()
	grab_script_mode_index = grab_script_mode_index + 1;
	if grab_script_mode_index > #grab_script_modes then
		grab_script_mode_index = 1;
	end
	grab_script_mode = grab_script_modes[grab_script_mode_index];
end

-- Kong index
local DK     = 0;
local Diddy  = 1;
local Lanky  = 2;
local Tiny   = 3;
local Chunky = 4;
local Krusha = 5;

-- These are different on Kiosk so we declare before version detection to allow overwriting
local actor_types = {
	[2] = "DK",
	[3] = "Diddy",
	[4] = "Lanky",
	[5] = "Tiny",
	[6] = "Chunky",
	[7] = "Krusha",
	[8] = "Rambi",
	[9] = "Enguarde",
	[12] = "Loading Zone Controller",
	[17] = "Cannon Barrel",
	[19] = "Barrel (Diddy 5DI)",
	[18] = "Rambi Box",
	[23] = "Cannon",
	[25] = "Hunky Chunky Barrel",
	[26] = "TNT Barrel",
	[27] = "TNT Barrel Spawner (Armydillo)",
	[28] = "Bonus Barrel",
	[30] = "Fireball", -- Boss fights TODO: where else is this used?
	[31] = "Bridge (Castle)",
	[32] = "Swinging Light",
	[33] = "Vine (Brown)",
	[34] = "Kremling Kosh Controller",
	[35] = "Melon (Projectile)",
	[36] = "Peanut",
	[38] = "Pineapple",
	[40] = "Mini Monkey barrel",
	[41] = "Orange",
	[42] = "Grape",
	[43] = "Feather",
	[44] = "Lazer (Projectile)",
	[47] = "Watermelon Slice",
	[48] = "Coconut",
	[49] = "Rocketbarrel",
	[50] = "Lime",
	[52] = "Orange Pickup", -- Dropped by Klump & Purple Klaptrap
	[56] = "Orangstand Sprint Barrel",
	[57] = "Strong Kong Barrel",
	[58] = "Swinging Light",
	[59] = "Fireball", -- Mad Jack -- TODO: where else is this used?
	[61] = "Boulder",
	[63] = "Vase (O)",
	[64] = "Vase (:)",
	[65] = "Vase (Triangle)",
	[66] = "Vase (+)",
	[67] = "Cannon Ball",
	[69] = "Vine (Green)",
	[71] = "Red Kremling (Lanky's Keyboard Game in R&D)",
	[72] = "Boss Key",
	[75] = "Blueprint (Diddy)",
	[76] = "Blueprint (Chunky)",
	[77] = "Blueprint (Lanky)",
	[78] = "Blueprint (DK)",
	[79] = "Blueprint (Tiny)",
	[81] = "Fire Spawner? (Dogadon)", -- TODO: Verify
	[85] = "Steel Keg",
	[86] = "Crown",
	[91] = "Balloon (Diddy)",
	[92] = "Stalactite",
	[95] = "Pause Menu",
	[96] = "Hunky Chunky Barrel (Dogadon)",
	[98] = "Tag Barrel",
	[97] = "TNT Barrel Spawner (Dogadon)",
	[100] = "1 Pad (Diddy 5DI)",
	[101] = "2 Pad (Diddy 5DI)",
	[102] = "3 Pad (Diddy 5DI)",
	[103] = "4 Pad (Diddy 5DI)",
	[104] = "5 Pad (Diddy 5DI)",
	[105] = "6 Pad (Diddy 5DI)",
	[106] = "5DI Controller?", -- TODO: Investigate
	[107] = "Bonus Barrel (Hideout Helm)",
	[111] = "Balloon (Chunky)",
	[112] = "Balloon (Tiny)",
	[113] = "Balloon (Lanky)",
	[114] = "Balloon (DK)",
	[115] = "K. Lumsy's Cage", -- TODO: Also rabbit race finish line?
	[116] = "Chain",
	[124] = "Peril Path Panic Controller?", -- TODO: Verify, used anywhere else?
	[126] = "Fly Swatter",
	[128] = "Headphones",
	[129] = "Enguarde Box",
	[130] = "Apple (Fungi)",
	[133] = "Barrel",
	[134] = "Training Barrel",
	[135] = "Boombox (Treehouse)",
	[136] = "Tag Barrel",
	[137] = "Tag Barrel", -- Troff'n'Scoff
	[138] = "B. Locker",
	[139] = "Rainbow Coin Patch",
	[140] = "Rainbow Coin (Spawner?)",
	[148] = "Rope (K. Rool ring)",
	[156] = "Wrinkly",
	[163] = "Banana Fairy (BFI)",
	[164] = "Ice Tomato",
	[165] = "Tag Barrel (King Kutout)",
	[166] = "King Kutout Part",
	[167] = "Cannon",
	[173] = "Cutscene Controller",
	[176] = "Timer",
	[178] = "Beaver (Blue)",
	[179] = "Shockwave (Mad Jack)",
	[181] = "Book", -- Castle Library
	[182] = "Barrel Enemy (Normal)",
	[183] = "Zinger",
	[184] = "Snide",
	[185] = "Armydillo",
	[186] = "Kremling", -- Kremling Kosh
	[187] = "Klump",
	[188] = "Camera",
	[189] = "Cranky",
	[190] = "Funky",
	[191] = "Candy",
	[192] = "Beetle", -- Race
	[193] = "Mermaid",
	[195] = "Squawks",
	[197] = "Trapped Diddy",
	[198] = "Trapped Lanky",
	[199] = "Trapped Tiny",
	[200] = "Trapped Chunky",
	[201] = "Llama",
	[203] = "Padlock (T&S)",
	[204] = "Mad Jack",
	[205] = "Klaptrap (Green)",
	[206] = "Zinger",
	[207] = "Vulture (Race)",
	[208] = "Klaptrap (Purple)",
	[212] = "Beaver (Gold)",
	[216] = "Pufftoss",
	[224] = "Mushroom Man",
	[226] = "Troff",
	[228] = "Bad Hit Detection Man",
	[230] = "Ruler Enemy",
	[231] = "Toy Box",
	[232] = "Text Overlay",
	[234] = "Scoff",
	[235] = "Robo-Kremling",
	[236] = "Dogadon",
	[238] = "Kremling",
	[240] = "Fish with headlamp",
	[241] = "Kasplat (DK)",
	[242] = "Kasplat (Diddy)",
	[243] = "Kasplat (Lanky)",
	[244] = "Kasplat (Tiny)",
	[245] = "Kasplat (Chunky)",
	[247] = "Seal",
	[248] = "Banana Fairy",
	[249] = "Squawks w/spotlight",
	[252] = "Rabbit", -- Fungi
	[254] = "Static Object", -- Used in TONS of places, mainly for objects animated by cutscenes
	[255] = "Shockwave",
	[258] = "Shockwave", -- Boss
	[259] = "Guard", -- Stealthy Snoop
	[260] = "Text Overlay", -- K. Rool fight
	[261] = "Robo-Zinger",
	[262] = "Krossbones",
	[263] = "Fire Shockwave (Dogadon)",
	[264] = "Squawks",
	[265] = "Light beam", -- Boss fights etc
	[267] = "Starfish Enemy",
	[268] = "Gimpfish Enemy",
	[270] = "Sir Domino",
	[271] = "Mr. Dice",
	[275] = "K. Lumsy",
	[281] = "K. Rool (DK Phase)",
	[285] = "Bat",
	[286] = "Giant Clam",
	[289] = "Kritter-in-a-Sheet",
	[290] = "Pufferfish Enemy",
	[291] = "Kosha",
	[292] = "K. Rool (Diddy Phase)",
	[293] = "K. Rool (Lanky Phase)",
	[294] = "K. Rool (Tiny Phase)",
	[295] = "K. Rool (Chunky Phase)",
	[299] = "Textbox",
	[305] = "Missile (Car Race)",
	[309] = "DK Logo (Instrument)",
	[310] = "Spotlight", -- Tag barrel, instrument etc.
	[311] = "Checkpoint (Race)", -- Seal race & Castle car race
	[313] = "Particle (Idle Anim.)",
	[316] = "Kong (Tag Barrel)",
	[317] = "Locked Kong (Tag Barrel)",
	[325] = "Sim Slam Shockwave",
	[326] = "Main Menu Controller",
	[328] = "Klaptrap", -- Peril Path Panic
	[329] = "Fairy", -- Peril Path Panic
	[330] = "Bug", -- Big Bug Bash
	[331] = "Klaptrap", -- Searchlight Seek
	[332] = "Big Bug Bash Controller?", -- TODO: Verify -- TODO: Fly swatter?
	[333] = "Barrel (Main Menu)",
	[334] = "Padlock (K. Lumsy)",
	[335] = "Snide's Menu",
	[336] = "Training Barrel Controller",
	[337] = "Multiplayer Model (Main Menu)",
	[339] = "Arena Controller", -- Rambi/Enguarde
	[340] = "Bug", -- Trash Can
	[342] = "Try Again Dialog",
};

-- Kiosk specific Object Model 1 offsets
local velocity = 0xB8; -- 32 bit float big endian
local y_velocity = 0xC0; -- 32 bit float big endian
local y_acceleration = 0xC4; -- 32 bit float big endian
local x_rot = 0xE4; -- u16_be
local y_rot = x_rot + 2; -- u16_be
local z_rot = y_rot + 2; -- u16_be
local hand_state = 0x147; -- Bitfield

local camera_focus_pointer = 0x178;
local grab_pointer = 0x32C;

----------------------------
-- Version specific stuff --
----------------------------

local romName = gameinfo.getromname();

if bizstring.contains(romName, "Donkey Kong 64") then
	if bizstring.contains(romName, "USA") and not bizstring.contains(romName, "Kiosk") then
		pointer_list = 0x7FBFF0;
		camera_pointer = 0x7FB968;
		player_pointer = 0x7FBB4D;
		obj_model2_array_pointer = 0x7F6000;
	elseif bizstring.contains(romName, "Europe") then
		pointer_list = 0x7FBF10;
		camera_pointer = 0x7FB888;
		player_pointer = 0x7FBA6D;
		obj_model2_array_pointer = 0x7F5F20;
	elseif bizstring.contains(romName, "Japan") then
		pointer_list = 0x7FC460;
		camera_pointer = 0x7FBDD8;
		player_pointer = 0x7FBFBD;
		obj_model2_array_pointer = 0x7F6470;
	elseif bizstring.contains(romName, "Kiosk") then
		pointer_list = 0x7B5E58;
		camera_pointer = 0x7B5918;
		player_pointer = 0x7B5AFD;
		obj_model2_array_pointer = 0x7F6000; -- TODO

		actor_types = {
			[2] = "DK",
			[3] = "Diddy",
			[4] = "Lanky",
			[5] = "Tiny",
			[6] = "Chunky",
			[25] = "TNT Barrel",
			[26] = "TNT Barrel Spawner (Armydillo)",
			[29] = "Fireball", -- Armydillo, Dogadon
			[71] = "Boss Key",
			[96] = "TNT Barrel Spawner (Dogadon)",
			[145] = "Armydillo",
			[149] = "Camera",
			[201] = "Dogadon",
			[221] = "Static Object", -- Fake Chunky in Dogadon 2 opening cutscene
			[230] = "Fireball Shockwave", -- Dogadon
			[232] = "Light Beam", -- Boss fights etc
		};

		-- Kiosk specific Object Model 1 offsets
		velocity = 0xB0;
		y_velocity = 0xB8;
		y_acceleration = 0xBC;
		x_rot = 0xD8;
		y_rot = x_rot + 2;
		z_rot = y_rot + 2;
		hand_state = 0x137;
		camera_focus_pointer = 0x168;
		grab_pointer = 0x2F4;
	end
	obj_model2_array_count = obj_model2_array_pointer + 4; -- u32_be
else
	print("This game is not supported.");
	return;
end

----------------------
-- Helper functions --
----------------------

max_string_length = 25;
function readNullTerminatedString(base)
	local builtString = "";
	local length = 0;
	local nextByte = mainmemory.readbyte(base + length);
	repeat
		builtString = builtString..string.char(nextByte);
		length = length + 1;
		nextByte = mainmemory.readbyte(base + length);
	until nextByte == 0 or length > max_string_length;
	return builtString;
end

function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	prefix = prefix or "0x";
	desiredLength = desiredLength or string.len(value);
	while string.len(value) < desiredLength do
		value = "0"..value;
	end
	return prefix..value;
end

local function isRDRAM(value)
	return value >= 0x000000 and value < 0x800000;
end

local function isPointer(value)
	return value >= 0x80000000 and value < 0x80800000;
end

function get_bit(field, index)
	if index < 32 then
		local bitmask = math.pow(2, index);
		return bit.band(bitmask, field) == bitmask;
	end
	return false;
end

----------------------------------
-- Object Model 1 documentation --
----------------------------------

-- Relative to objects found in the model 1 pointer list
local previous_object = -0x10; -- u32_be
local object_size = -0x0C; -- u32_be

local model_pointer = 0x00; -- u32_be
local rendering_parameters_pointer = 0x04; -- u32_be
local current_bone_array_pointer = 0x08; -- u32_be

local actor_type = 0x58; -- u32_be
function isKong(actorType)
	return actorType >= 2 and actorType <= 6;
end

-- 0001 0000 = collides with terrain
-- 0000 0100 = visible
-- 0000 0001 = in water
local visibility = 0x63; -- Bitfield -- TODO: Fully document

local specular_highlight = 0x6D;

local shadow_width = 0x6E; -- u8
local shadow_height = 0x6F; -- u8

local x_pos = 0x7C; -- 32 bit float big endian
local y_pos = x_pos + 4; -- 32 bit float big endian
local z_pos = y_pos + 4; -- 32 bit float big endian

local floor = 0xA4; -- 32 bit float big endian
local distance_from_floor = 0xB4; -- 32 bit float big endian

--local acceleration = 0xBC; -- Seems wrong
local gravity_strength = 0xC8; -- 32 bit float big endian

local light_thing = 0xCC; -- Values 0x00->0x14

local health = 0x134; -- s16_be
local takes_enemy_damage = 0x13B;

local lock_method_1_pointer = 0x13C;

local shade_byte = 0x16D;

-- Relative to tag barrel
local tb_scroll_timer = 0x17D;
local tb_current_index = 0x17E;
local tb_previous_index = 0x17F;
local tb_kickout_timer = 0x1B4;

-- Relative to camera
-- TODO: Verify for all versions
local camera_viewport_x_position = 0x1FC;
local camera_viewport_y_position = camera_viewport_x_position + 4;
local camera_viewport_z_position = camera_viewport_y_position + 4;

local camera_tracking_distance = 0x21C;
local camera_viewport_y_rotation = 0x22A;
local camera_tracking_angle = 0x230;

local camera_zoom_level_c_down = 0x266;
local camera_zoom_level_current = 0x267;
local camera_zoom_level_after_c_up = 0x268;

local camera_state_switch_timer_1 = 0x269;
local camera_state_switch_timer_2 = 0x26E;

local camera_state_type = 0x26B;

-- Relative to text overlay
local text_shown = 0x1EE; -- 16 bit uint -- TODO: This needs to be in a separate object, text overlays are only 0x190 big

-- Relative to player
local grabbed_vine_pointer = 0x2B0;

local fairy_active = 0x36C;

-- Relative to rendering params
local scale_x = 0x34; -- 32 bit float big endian
local scale_y = scale_x + 4; -- 32 bit float big endian
local scale_z = scale_y + 4; -- 32 bit float big endian

local anim_timer1 = 0x94; -- 32 bit float big endian
local anim_timer2 = 0x98; -- 32 bit float big endian

local anim_timer3 = 0x104; -- 32 bit float big endian
local anim_timer4 = 0x108; -- 32 bit float big endian

local function isValidObject(pointer, playerObject, cameraObject)
	local modelPointer = mainmemory.read_u32_be(pointer + model_pointer);
	local hasModel = isPointer(modelPointer);

	if encircle_enabled then
		return hasModel and pointer ~= playerObject;
	end

	return true;
end

local function populateObjectModel1Pointers()
	local object_no = 0;
	local playerObject = mainmemory.read_u24_be(player_pointer);
	local cameraObject = mainmemory.read_u24_be(camera_pointer + 1);

	object_pointers = {};
	for object_no = 0, max_objects do
		local pointer = mainmemory.read_u24_be(pointer_list + (object_no * 4) + 1);
		local object_found = isRDRAM(pointer);

		if object_found and isValidObject(pointer, playerObject, cameraObject) then
			table.insert(object_pointers, pointer);
		end
	end

	-- Clamp index
	object_index = math.min(object_index, math.max(1, #object_pointers));
end

local function encirclePlayerObjectModel1()
	if encircle_enabled then
		local x, z;

		local playerObject = mainmemory.read_u24_be(player_pointer);
		local xPos = mainmemory.readfloat(playerObject + x_pos, true);
		local yPos = mainmemory.readfloat(playerObject + y_pos, true);
		local zPos = mainmemory.readfloat(playerObject + z_pos, true);

		for i = 1, #object_pointers do
			x = xPos + math.cos(math.pi * 2 * i / #object_pointers) * radius;
			z = zPos + math.sin(math.pi * 2 * i / #object_pointers) * radius;

			mainmemory.writefloat(object_pointers[i] + x_pos, x, true);
			mainmemory.writefloat(object_pointers[i] + y_pos, yPos, true);
			mainmemory.writefloat(object_pointers[i] + z_pos, z, true);
		end
	end
end

local function getExamineDataModelOne(pointer)
	local examine_data = {};

	local actorSize = mainmemory.read_u32_be(pointer + object_size)
	local modelPointer = mainmemory.read_u32_be(pointer + model_pointer);
	local renderingParametersPointer = mainmemory.read_u32_be(pointer + rendering_parameters_pointer);
	local boneArrayPointer = mainmemory.read_u32_be(pointer + current_bone_array_pointer);
	local hasModel = isPointer(modelPointer) or isPointer(renderingParametersPointer) or isPointer(boneArrayPointer);

	local xPos = mainmemory.readfloat(pointer + x_pos, true);
	local yPos = mainmemory.readfloat(pointer + y_pos, true);
	local zPos = mainmemory.readfloat(pointer + z_pos, true);
	local hasPosition = xPos ~= 0 or yPos ~= 0 or zPos ~= 0 or hasModel;

	table.insert(examine_data, { "Actor base", string.format("0x%06x", pointer) });
	local currentActorTypeNumeric = mainmemory.read_u32_be(pointer + actor_type);
	local currentActorType = currentActorTypeNumeric;
	if type(actor_types[currentActorType]) ~= "nil" then
		currentActorType = actor_types[currentActorType];
	end
	table.insert(examine_data, { "Actor size", toHexString(actorSize) });
	table.insert(examine_data, { "Actor type", currentActorType });
	table.insert(examine_data, { "Separator", 1 });

	if hasModel then
		table.insert(examine_data, { "Model", string.format("0x%08x", modelPointer) });
		table.insert(examine_data, { "Rendering Params", string.format("0x%08x", renderingParametersPointer) });
		table.insert(examine_data, { "Bone Array", string.format("0x%08x", boneArrayPointer) });
		table.insert(examine_data, { "Separator", 1 });
	end

	if hasPosition then
		table.insert(examine_data, { "X", xPos });
		table.insert(examine_data, { "Y", yPos });
		table.insert(examine_data, { "Z", zPos });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Rot X", mainmemory.read_u16_be(pointer + x_rot) });
		table.insert(examine_data, { "Rot Y", mainmemory.read_u16_be(pointer + y_rot) });
		table.insert(examine_data, { "Rot Z", mainmemory.read_u16_be(pointer + z_rot) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Velocity", mainmemory.readfloat(pointer + velocity, true) });
		table.insert(examine_data, { "Y Velocity", mainmemory.readfloat(pointer + y_velocity, true) });
		table.insert(examine_data, { "Y Accel", mainmemory.readfloat(pointer + y_acceleration, true) });
		table.insert(examine_data, { "Separator", 1 });
	end

	table.insert(examine_data, { "Health", mainmemory.read_s16_be(pointer + health) });
	table.insert(examine_data, { "Hand state", mainmemory.readbyte(pointer + hand_state) });
	table.insert(examine_data, { "Specular highlight", mainmemory.readbyte(pointer + specular_highlight) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Shadow width", mainmemory.readbyte(pointer + shadow_width) });
	table.insert(examine_data, { "Shadow height", mainmemory.readbyte(pointer + shadow_height) });
	table.insert(examine_data, { "Brightness", mainmemory.readbyte(pointer + shade_byte) });
	table.insert(examine_data, { "Separator", 1 });

	local visibilityValue = mainmemory.readbyte(pointer + visibility);
	table.insert(examine_data, { "Visibility", bizstring.binary(visibilityValue) });
	table.insert(examine_data, { "In water", tostring(not get_bit(visibilityValue, 0)) });
	table.insert(examine_data, { "Visible", tostring(get_bit(visibilityValue, 2)) });
	table.insert(examine_data, { "Collides with terrain", tostring(get_bit(visibilityValue, 4)) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Lock Method 1 Pointer", string.format("0x%08x", mainmemory.read_u32_be(pointer + lock_method_1_pointer)) });
	table.insert(examine_data, { "Separator", 1 });

	if isKong(currentActorTypeNumeric) then
		table.insert(examine_data, { "Grabbed Vine Pointer", string.format("0x%08x", mainmemory.read_u32_be(pointer + grabbed_vine_pointer)) });
		table.insert(examine_data, { "Grab pointer", string.format("0x%08x", mainmemory.read_u32_be(pointer + grab_pointer)) });
		table.insert(examine_data, { "Fairy Active", mainmemory.readbyte(pointer + fairy_active) });
		table.insert(examine_data, { "Separator", 1 });
	end

	if currentActorType == "Camera" then
		local focusedActor = mainmemory.read_u24_be(pointer + camera_focus_pointer + 1);
		local focusedActorType;

		if isRDRAM(focusedActor) then
			focusedActorType = mainmemory.read_u32_be(focusedActor + actor_type);
			if type(actor_types[focusedActorType]) ~= "nil" then
				focusedActorType = actor_types[focusedActorType];
			end
		end

		table.insert(examine_data, { "Focused Actor", string.format("0x%06x", focusedActor) });
		if type(focusedActorType) ~= "nil" then
			table.insert(examine_data, { "Focused Actor Type", focusedActorType });
		end
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Viewport X Pos", mainmemory.readfloat(pointer + camera_viewport_x_position, true) });
		table.insert(examine_data, { "Viewport Y Pos", mainmemory.readfloat(pointer + camera_viewport_y_position, true) });
		table.insert(examine_data, { "Viewport Z Pos", mainmemory.readfloat(pointer + camera_viewport_z_position, true) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Viewport Y Rot", mainmemory.read_u16_be(pointer + camera_viewport_y_rotation) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Tracking Distance", mainmemory.readfloat(pointer + camera_tracking_distance, true) });
		table.insert(examine_data, { "Tracking Angle", mainmemory.readfloat(pointer + camera_tracking_angle, true) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Camera State Type", mainmemory.readbyte(pointer + camera_state_type) });
		table.insert(examine_data, { "C-Down Zoom Level", mainmemory.readbyte(pointer + camera_zoom_level_c_down) });
		table.insert(examine_data, { "Current Zoom Level", mainmemory.readbyte(pointer + camera_zoom_level_current) });
		table.insert(examine_data, { "Zoom Level After C-Up", mainmemory.readbyte(pointer + camera_zoom_level_after_c_up) });
		table.insert(examine_data, { "Zoom Level Timer 1", mainmemory.readbyte(pointer + camera_state_switch_timer_1) });
		table.insert(examine_data, { "Zoom Level Timer 2", mainmemory.readbyte(pointer + camera_state_switch_timer_2) });
		table.insert(examine_data, { "Separator", 1 });
	end

	if currentActorType == "Tag Barrel" then
		table.insert(examine_data, { "TB scroll timer", mainmemory.readbyte(pointer + tb_scroll_timer) });
		table.insert(examine_data, { "TB current index", mainmemory.readbyte(pointer + tb_current_index) });
		table.insert(examine_data, { "TB previous index", mainmemory.readbyte(pointer + tb_previous_index) });
		table.insert(examine_data, { "TB kickout timer", mainmemory.read_u32_be(pointer + tb_kickout_timer) });
		table.insert(examine_data, { "Separator", 1 });
	elseif currentActorType == "Kremling Kosh Controller" then
		table.insert(examine_data, { "Current Slot", mainmemory.readbyte(pointer + slot_location) });
		table.insert(examine_data, { "Melons Remaining", mainmemory.readbyte(pointer + melons_remaining) });
		for i = 1, 8 do
			table.insert(examine_data, { "Slot "..i.." pointer", string.format("0x%08x", mainmemory.read_u32_be(pointer + slot_pointer_base + (i - 1) * 4)) });
		end
		table.insert(examine_data, { "Separator", 1 });
	elseif currentActorTypeNumeric == 330 then -- Bug: Big Bug Bash
		table.insert(examine_data, { "Current AI direction", mainmemory.readfloat(pointer + 0x180) });
		table.insert(examine_data, { "Ticks til direction change", mainmemory.read_u32_be(pointer + 0x184) });
	end

	return examine_data;
end

----------------------------------
-- Object Model 2 Documentation --
----------------------------------

-- Things in object model 2
	-- GB's & CB's
	-- Doors in helm
	-- K. Rool's chair
	-- Gorilla Grab Levers
	-- Bananaporters
	-- DK portals
	-- Trees
	-- Instrument pads
	-- Wrinkly doors
	-- Shops (Snide's, Cranky's, Funky's, Candy's)

local obj_model2_slot_size = 0x90;

-- Relative to trigger slot
local obj_model2_x_pos = 0x00; -- Float
local obj_model2_y_pos = obj_model2_x_pos + 4; -- Float
local obj_model2_z_pos = obj_model2_y_pos + 4; -- Float

local obj_model2_hitbox_scale = 0x0C; -- Float

local obj_model2_model_pointer = 0x20;
local obj_model2_behavior_type_pointer = 0x24;

local obj_model2_unknown_counter = 0x3A; -- u16_be

local obj_model2_behavior_pointer = 0x7C;

-- 0x00 Unknown
-- 0x01 Unknown
-- 0x02 Unknown
-- 0x04 Unknown
-- 0x08 Unknown
-- 0x20 Unknown
-- 0x21 100001 GB - Chunky can collect
-- 0x22 100010 GB - Diddy can collect
-- 0x24 100100 GB - Tiny can collect
-- 0x28 101000 GB - DK can collect
-- 0x30 110000 GB - Lanky can collect
-- 0x3F 111111 GB - Anyone can collect?
local obj_model2_collectable_state = 0x8C; -- byte long bitfield

local GBStates = {
	[DK] = 0x28,
	[Diddy] = 0x22,
	[Lanky] = 0x30,
	[Tiny] = 0x24,
	[Chunky] = 0x21,
};

function isGB(collectableState) -- TODO: When rolling this into the DK64 module use array_contains
	for kong = DK, Chunky do
		if collectableState == GBStates[kong] then
			return true;
		end
	end
	return false;
end

-- Relative to model pointer
local obj_model2_model_x_pos = 0x00; -- Float
local obj_model2_model_y_pos = obj_model2_model_x_pos + 4; -- Float
local obj_model2_model_z_pos = obj_model2_model_y_pos + 4; -- Float
local obj_model2_model_scale = 0x0C;

local obj_model2_model_rot_x = 0x10; -- Float
local obj_model2_model_rot_y = obj_model2_model_rot_x + 4; -- Float
local obj_model2_model_rot_z = obj_model2_model_rot_y + 4; -- Float

function getObjectModel2ArraySize()
	local objModel2Array = mainmemory.read_u24_be(obj_model2_array_pointer + 1);
	if isRDRAM(objModel2Array) then
		return mainmemory.read_u32_be(objModel2Array - 0x0C) / obj_model2_slot_size;
	end
	return 0;
end

function getObjectModel2SlotBase(index)
	local objModel2Array = mainmemory.read_u24_be(obj_model2_array_pointer + 1);
	return objModel2Array + index * obj_model2_slot_size;
end

function getObjectModel2ModelBase(index)
	local objModel2Array = mainmemory.read_u24_be(obj_model2_array_pointer + 1);
	return mainmemory.read_u24_be(objModel2Array + index * obj_model2_slot_size + obj_model2_model_pointer + 1);
end

function populateObjectModel2Pointers()
	object_pointers = {};
	numSlots = mainmemory.read_u32_be(obj_model2_array_count);

	-- Fill and sort pointer list
	for i = 0, numSlots - 1 do
		table.insert(object_pointers, getObjectModel2SlotBase(i));
	end
	table.sort(object_pointers);
end

local function encirclePlayerObjectModel2()
	if encircle_enabled then
		local playerObject = mainmemory.read_u24_be(player_pointer);
		local xPos = mainmemory.readfloat(playerObject + x_pos, true);
		local yPos = mainmemory.readfloat(playerObject + y_pos, true);
		local zPos = mainmemory.readfloat(playerObject + z_pos, true);

		-- Iterate and set position
		local x, z, modelPointer;
		for i = 1, #object_pointers do
			x = xPos + math.cos(math.pi * 2 * i / #object_pointers) * radius;
			z = zPos + math.sin(math.pi * 2 * i / #object_pointers) * radius;

			-- Set hitbox X, Y, Z
			mainmemory.writefloat(object_pointers[i] + obj_model2_x_pos, x, true);
			mainmemory.writefloat(object_pointers[i] + obj_model2_y_pos, yPos, true);
			mainmemory.writefloat(object_pointers[i] + obj_model2_z_pos, z, true);

			-- Set model X, Y, Z
			modelPointer = mainmemory.read_u32_be(object_pointers[i] + obj_model2_model_pointer);
			if isPointer(modelPointer) then
				modelPointer = modelPointer - 0x80000000;
				mainmemory.writefloat(modelPointer + obj_model2_model_x_pos, x, true);
				mainmemory.writefloat(modelPointer + obj_model2_model_y_pos, yPos, true);
				mainmemory.writefloat(modelPointer + obj_model2_model_z_pos, z, true);
			end
		end
	end
end

local function getExamineDataModelTwo(pointer)
	local examine_data = {};

	local modelPointer = mainmemory.read_u32_be(pointer + obj_model2_model_pointer);
	local hasModel = isPointer(modelPointer);

	local xPos = mainmemory.readfloat(pointer + obj_model2_x_pos, true);
	local yPos = mainmemory.readfloat(pointer + obj_model2_y_pos, true);
	local zPos = mainmemory.readfloat(pointer + obj_model2_z_pos, true);
	local hasPosition = xPos ~= 0 or yPos ~= 0 or zPos ~= 0 or hasModel;

	table.insert(examine_data, { "Slot base", string.format("0x%06x", pointer) });
	table.insert(examine_data, { "Separator", 1 });

	if hasPosition then
		table.insert(examine_data, { "Hitbox X", xPos });
		table.insert(examine_data, { "Hitbox Y", yPos });
		table.insert(examine_data, { "Hitbox Z", zPos });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Hitbox Scale", mainmemory.readfloat(pointer + obj_model2_hitbox_scale, true) });
		table.insert(examine_data, { "Separator", 1 });
	end

	local behaviorTypePointer = mainmemory.read_u32_be(pointer + obj_model2_behavior_type_pointer);
	table.insert(examine_data, { "Behavior Type Pointer", string.format("0x%08x", behaviorTypePointer) });
	if isPointer(behaviorTypePointer) then
		table.insert(examine_data, { "Behavior Type", readNullTerminatedString(behaviorTypePointer - 0x80000000 + 0x0C) });
	end

	table.insert(examine_data, { "Unknown Counter", mainmemory.read_u16_be(pointer + obj_model2_unknown_counter) });

	local behaviorPointer = mainmemory.read_u32_be(pointer + obj_model2_behavior_pointer);
	if behaviorPointer ~= 0 then
		table.insert(examine_data, { "Behavior Pointer", string.format("0x%08x", behaviorPointer) });
	end

	table.insert(examine_data, { "Collectable", bizstring.binary(mainmemory.readbyte(pointer + obj_model2_collectable_state)) });

	if hasModel then
		modelPointer = modelPointer - 0x80000000;
		table.insert(examine_data, { "Model Base", string.format("0x%08x", modelPointer) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Model X", mainmemory.readfloat(modelPointer + obj_model2_model_x_pos, true) });
		table.insert(examine_data, { "Model Y", mainmemory.readfloat(modelPointer + obj_model2_model_y_pos, true) });
		table.insert(examine_data, { "Model Z", mainmemory.readfloat(modelPointer + obj_model2_model_z_pos, true) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Model Scale", mainmemory.readfloat(modelPointer + obj_model2_model_scale, true) });
		table.insert(examine_data, { "Separator", 1 });
	end

	return examine_data;
end

-----------------------
-- Kremling Kosh Bot --
-----------------------

-- Relative to Kremling Kosh controller
local slot_location = 0x1A2;
local melons_remaining = 0x1A3;
local slot_pointer_base = 0x1A8;

local kremling_kosh_joypad_angles = {
	[0] = {["X Axis"] = 0,    ["Y Axis"] = 0},
	[1] = {["X Axis"] = -128, ["Y Axis"] = 0},
	[2] = {["X Axis"] = -128, ["Y Axis"] = -128},
	[3] = {["X Axis"] = 0,    ["Y Axis"] = -128},
	[4] = {["X Axis"] = 127,  ["Y Axis"] = -128},
	[5] = {["X Axis"] = 127,  ["Y Axis"] = 0},
	[6] = {["X Axis"] = 127,  ["Y Axis"] = 127},
	[7] = {["X Axis"] = 0,    ["Y Axis"] = 127},
	[8] = {["X Axis"] = -128, ["Y Axis"] = 127},
};

function getKoshController()
	for i = 1, #object_pointers do
		local currentActorType = mainmemory.read_u32_be(object_pointers[i] + actor_type);
		if type(actor_types[currentActorType]) ~= "nil" then
			currentActorType = actor_types[currentActorType];
		end
		if currentActorType == "Kremling Kosh Controller" then
			return object_pointers[i];
		end
	end
end

function countMelonProjectiles()
	local melonCount = 0;
	for i = 1, #object_pointers do
		local currentActorType = mainmemory.read_u32_be(object_pointers[i] + actor_type);
		if type(actor_types[currentActorType]) ~= "nil" then
			currentActorType = actor_types[currentActorType];
		end
		if currentActorType == "Melon (Projectile)" then
			melonCount = melonCount + 1;
		end
	end
	return melonCount;
end

function getSlotPointer(koshController, slotIndex)
	return mainmemory.read_u32_be(koshController + slot_pointer_base + (slotIndex - 1) * 4);
end

function getCurrentSlot()
	local koshController = getKoshController();
	if type(koshController) ~= "nil" then
		return mainmemory.readbyte(koshController + slot_location);
	end
end

local shots_fired = {
	0, 0, 0, 0, 0, 0, 0, 0
};

function getDesiredSlot()
	local koshController = getKoshController();
	if type(koshController) ~= "nil" then
		local currentSlot = mainmemory.readbyte(koshController + slot_location);
		local melonsRemaining = mainmemory.readbyte(koshController + melons_remaining);
		if melonsRemaining == 0 then
			return 0;
		end

		-- Check for kremlings
		local slotIndex = 0;
		local desiredSlot = 0;
		for slotIndex = 1,8 do
			local slotPointer = getSlotPointer(koshController, slotIndex)
			if slotPointer > 0 and slotPointer ~= shots_fired[slotIndex] then
				desiredSlot = slotIndex;
			end
			if slotPointer == 0 then
				shots_fired[slotIndex] = 0;
			end
		end

		if desiredSlot > 0 then
			return desiredSlot;
		end
	end
end

local previousFrameB = false;
function koshBotLoop()
	if not emu.islagged() then
		local currentSlot = getCurrentSlot();
		local desiredSlot = getDesiredSlot();
		if type(desiredSlot) ~= "nil" then
			joypad.setanalog(kremling_kosh_joypad_angles[desiredSlot], 1);
			--print("Moving to slot "..desiredSlot);
			if currentSlot == desiredSlot then
				if desiredSlot > 0 then
					local koshController = getKoshController();
					shots_fired[desiredSlot] = getSlotPointer(koshController, desiredSlot);
				end
				previousFrameB = not previousFrameB;
				joypad.set({["B"] = true}, 1);
				--print("Firing!");
			end
		else
			joypad.setanalog({["X Axis"] = false, ["Y Axis"] = false}, 1);
		end
	end
end

event.onframestart(koshBotLoop, "ScriptHawk - Kremling Kosh Bot");

-- Keybinds
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm
local decrease_object_index_key = "N";
local increase_object_index_key = "M";
local grab_object_key = "V";
local focus_object_key = "B";
local switch_grab_script_mode_key = "C";

local decrease_object_index_pressed = false;
local increase_object_index_pressed = false;
local grab_object_pressed = false;
local focus_object_pressed = false;
local switch_mode_pressed = false;

local green_highlight = 0xFF00FF00;
local yellow_highlight = 0xFFFFFF00;

local function grab_object(pointer)
	local playerObject = mainmemory.read_u24_be(player_pointer);
	if isRDRAM(playerObject) then
		mainmemory.writebyte(playerObject + grab_pointer, 0x80);
		mainmemory.write_u24_be(playerObject + grab_pointer + 1, pointer);
		mainmemory.writebyte(playerObject + grab_pointer + 4, 0x80);
		mainmemory.write_u24_be(playerObject + grab_pointer + 4 + 1, pointer);
	end
end

local function focus_object(pointer)
	local cameraObject = mainmemory.read_u24_be(camera_pointer + 1);
	if isRDRAM(cameraObject) then
		mainmemory.writebyte(cameraObject + camera_focus_pointer, 0x80);
		mainmemory.write_u24_be(cameraObject + camera_focus_pointer + 1, pointer);
	end
end

local function process_input()
	input_table = input.get();

	-- Hold down key prevention
	if input_table[decrease_object_index_key] == nil then
		decrease_object_index_pressed = false;
	end

	if input_table[increase_object_index_key] == nil then
		increase_object_index_pressed = false;
	end

	if input_table[grab_object_key] == nil then
		grab_object_pressed = false;
	end

	if input_table[focus_object_key] == nil then
		focus_object_pressed = false;
	end

	if input_table[switch_grab_script_mode_key] == nil then
		switch_grab_script_mode_pressed = false;
	end

	-- Check for key presses
	if input_table[decrease_object_index_key] == true and decrease_object_index_pressed == false then
		object_index = object_index - 1;
		if object_index <= 0 then
			object_index = #object_pointers;
		end
		decrease_object_index_pressed = true;
	end

	if input_table[increase_object_index_key] == true and increase_object_index_pressed == false then
		object_index = object_index + 1;
		if object_index > #object_pointers then
			object_index = 1;
		end
		increase_object_index_pressed = true;
	end

	if bizstring.contains(grab_script_mode, "Model 1") then
		if input_table[grab_object_key] == true and grab_object_pressed == false then
			grab_object(object_pointers[object_index]);
			grab_object_pressed = true;
		end

		if input_table[focus_object_key] == true and focus_object_pressed == false then
			focus_object(object_pointers[object_index]);
			focus_object_pressed = true;
		end
	end

	if input_table[switch_grab_script_mode_key] == true and switch_grab_script_mode_pressed == false then
		switch_grab_script_mode();
		switch_grab_script_mode_pressed = true;
	end
end

local function draw_gui()
	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	local playerObject = mainmemory.read_u24_be(player_pointer);
	local cameraObject = mainmemory.read_u24_be(camera_pointer + 1);

	if bizstring.contains(grab_script_mode, "Model 1") then
		populateObjectModel1Pointers();
		encirclePlayerObjectModel1();
	end

	if bizstring.contains(grab_script_mode, "Model 2") then
		populateObjectModel2Pointers();
		encirclePlayerObjectModel2();
	end

	if rat_enabled then
		local renderingParams = mainmemory.read_u24_be(playerObject + rendering_parameters_pointer + 1);
		if isRDRAM(renderingParams) then
			if math.random() > 0.9 then
				local timerValue = math.random() * 50;
				mainmemory.writefloat(renderingParams + anim_timer1, timerValue, true);
				mainmemory.writefloat(renderingParams + anim_timer2, timerValue, true);
				mainmemory.writefloat(renderingParams + anim_timer3, timerValue, true);
				mainmemory.writefloat(renderingParams + anim_timer4, timerValue, true);
			end
		end
	end

	gui.text(gui_x, gui_y + height * row, "Mode: "..grab_script_mode, nil, nil, 'bottomright');
	row = row + 1;

	if grab_script_mode == "Examine (Object Model 2)" or grab_script_mode == "List (Object Model 2)" then
		gui.text(gui_x, gui_y + height * row, "Array Size: "..getObjectModel2ArraySize(), nil, nil, 'bottomright');
		row = row + 1;
	end

	gui.text(gui_x, gui_y + height * row, "Index: "..object_index.."/"..#object_pointers, nil, nil, 'bottomright');
	row = row + 1;

	if grab_script_mode == "Examine (Object Model 1)" or grab_script_mode == "List (Object Model 1)" then
		-- Display which object is grabbed
		gui.text(gui_x, gui_y + height * row, string.format("Grabbed object: 0x%06x", mainmemory.read_u24_be(playerObject + grab_pointer + 1)), nil, nil, 'bottomright');
		row = row + 1;

		-- Display which object the camera is currently focusing on
		gui.text(gui_x, gui_y + height * row, string.format("Focused object: 0x%06x", mainmemory.read_u24_be(cameraObject + camera_focus_pointer + 1)), nil, nil, 'bottomright');
		row = row + 1;
	end

	if #object_pointers > 0 and object_index <= #object_pointers then
		if bizstring.contains(grab_script_mode, "Examine") then
			local examine_data = {};
			if grab_script_mode == "Examine (Object Model 1)" then
				examine_data = getExamineDataModelOne(object_pointers[object_index]);
			elseif grab_script_mode == "Examine (Object Model 2)" then
				examine_data = getExamineDataModelTwo(object_pointers[object_index]);
			end

			for i = #examine_data, 1, -1 do
				if examine_data[i][1] ~= "Separator" then
					gui.text(gui_x, gui_y + height * row, examine_data[i][1]..": "..examine_data[i][2], nil, nil, 'bottomright');
					row = row + 1;
				else
					row = row + examine_data[i][2];
				end
			end
		end

		if grab_script_mode == "List (Object Model 1)" then
			row = row + 1;
			for i = #object_pointers, 1, -1 do
				local currentActorType = mainmemory.read_u32_be(object_pointers[i] + actor_type);
				local currentActorSize = mainmemory.read_u32_be(object_pointers[i] + object_size); -- TODO: Got an exception here while kiosk was booting
				if type(actor_types[currentActorType]) ~= "nil" then
					currentActorType = actor_types[currentActorType];
				end
				local color = nil;
				if object_index == i then
					color = yellow_highlight;
				end
				if object_pointers[i] == playerObject then
					color = green_highlight;
				end
				gui.text(gui_x, gui_y + height * row, i..": "..string.format("0x%06x: ", object_pointers[i] or 0)..currentActorType.." ("..toHexString(currentActorSize)..")", color, nil, 'bottomright');
				row = row + 1;
			end
		end

		if grab_script_mode == "List (Object Model 2)" then
			for i = #object_pointers, 1, -1 do
				local behaviorPointer = mainmemory.read_u32_be(object_pointers[i] + obj_model2_behavior_pointer);
				local collectableState = mainmemory.readbyte(object_pointers[i] + obj_model2_collectable_state);
				if behaviorPointer > 0 then
					behaviorPointer = " ("..string.format("0x%08x", behaviorPointer or 0)..")";
				else
					behaviorPointer = "";
				end
				local color = nil;
				if isGB(collectableState) then
					color = yellow_highlight;
				end
				if object_index == i then
					color = green_highlight
				end

				local behaviorType = "";
				local behaviorTypePointer = mainmemory.read_u32_be(object_pointers[i] + obj_model2_behavior_type_pointer);
				if isPointer(behaviorTypePointer) then
					behaviorType = " "..behaviorType..readNullTerminatedString(behaviorTypePointer - 0x80000000 + 0x0C);
				end

				if not (behaviorPointer == "" and hide_non_scripted) then
					gui.text(gui_x, gui_y + height * row, i..": "..string.format("0x%06x", object_pointers[i] or 0)..behaviorType..behaviorPointer, color, nil, 'bottomright');
					row = row + 1;
				end
			end
		end
	end
end

event.onframestart(draw_gui, "ScriptHawk - Object model analysis main loop");
event.onframestart(process_input, "ScriptHawk - Object model analysis keybinds");