local pointer_list;
local kong_pointer;
local camera_pointer;
safeMode = true;

local romName = gameinfo.getromname();

if bizstring.contains(romName, "Donkey Kong 64") then
	if bizstring.contains(romName, "USA") and not bizstring.contains(romName, "Kiosk") then
		pointer_list = 0x7fbff0;
		camera_pointer = 0x7fb968;
		kong_pointer = 0x7fbb4d;
	elseif bizstring.contains(romName, "Europe") then
		pointer_list = 0x7fbf10;
		camera_pointer = 0x7fb888;
		kong_pointer = 0x7fba6d;
	elseif bizstring.contains(romName, "Japan") then
		pointer_list = 0x7fc460;
		camera_pointer = 0x7fbdd8;
		kong_pointer = 0x7fbfbd;
	elseif bizstring.contains(romName, "Kiosk") then
		pointer_list = 0x7b5e58;
		camera_pointer = 0x7b5918; -- TODO: Does this work?
		kong_pointer = 0x7b5afd;
		grab_pointer = 0x2F4;
	end
else
	print("This game is not supported.");
	return;
end

local function isPointer(value)
	return value >= 0x80000000 and value <= 0x807FFFFF;
end

function get_bit(field, index)
	if index < 32 then
		local bitmask = math.pow(2, index);
		return bit.band(bitmask, field) == bitmask;
	end
	return false;
end

local object_pointers = {};
local object_index = 1;
local max_objects = 0xFF;
local radius = 100;

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
	[59] = "Fireball (Mad Jack)", -- TODO: where else is this used?
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
	[181] = "Book (Castle Library)",
	[182] = "Barrel Enemy (Normal)",
	[183] = "Zinger",
	[184] = "Snide",
	[185] = "Armydillo",
	[186] = "Kremling (Kremling Kosh)",
	[187] = "Klump",
	[188] = "Camera",
	[189] = "Cranky",
	[190] = "Funky",
	[191] = "Candy",
	[192] = "Beetle (Race)",
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
	[208] = "Klaptrap (Purple)",
	[212] = "Beaver (Gold)",
	[216] = "Pufftoss",
	[224] = "Mushroom Enemy",
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
	[252] = "Rabbit (Fungi)",
	[254] = "Static Object", -- Fake DK, wheel in Helm, something in DK Rap
	[255] = "Shockwave",
	[258] = "Shockwave (Boss)",
	[259] = "Guard (Stealthy Snoop)",
	[261] = "Robo-Zinger",
	[262] = "Krossbones",
	[263] = "Fire Shockwave (Dogadon)",
	[264] = "Squawks",
	[265] = "Yellow Ray (Dogadon)", -- TODO: Used anywhere else?
	[267] = "Starfish Enemy",
	[268] = "Gimpfish Enemy",
	[270] = "Sir Domino",
	[271] = "Mr. Dice",
	[275] = "K. Lumsy",
	[281] = "K. Rool (DK Phase)",
	[285] = "Bat",
	[286] = "Giant Clam",
	[289] = "Spoopy ghost thing", -- TODO: proper name
	[290] = "Pufferfish Enemy",
	[291] = "Kosha",
	[292] = "K. Rool (Diddy Phase)",
	[293] = "K. Rool (Lanky Phase)",
	[294] = "K. Rool (Tiny Phase)",
	[295] = "K. Rool (Chunky Phase)",
	[299] = "Textbox",
	[305] = "Missile (Car Race)",
	[310] = "Spotlight", -- Tag barrel, instrument etc.
	[311] = "Checkpoint (Seal Race)",
	[313] = "Particle (Idle Anim.)",
	--[315] = "Sim Slam Shockwave", TODO: uhhhhh idk
	[316] = "Kong (Tag Barrel)",
	[317] = "Locked Kong (Tag Barrel)",
	[325] = "Sim Slam Shockwave",
	[328] = "Klaptrap (Peril Path Panic)",
	[329] = "Fairy (Peril Path Panic)",
	[330] = "Bug (Big Bug Bash)",
	[332] = "Big Bug Bash Controller?", -- TODO: Verify
	[333] = "Unknown on main menu",
	[334] = "Padlock (K. Lumsy)",
	[336] = "Training Barrel Controller",
	[337] = "Multiplayer Model (Main Menu)",
	[339] = "Arena Controller", -- Rambi/Enguarde
	[340] = "Bug Enemy (Castle Trash Can)",
	[342] = "Try Again Dialog",
}

-- Relative to objects found in the pointer list
local model_pointer = 0x00;
local rendering_parameters_pointer = 0x04;
local current_bone_array_pointer = 0x08;

local actor_type = 0x58; -- TODO: Document values for this
local visibility = 0x63; -- 127 = visible

local specular_highlight = 0x6D;

local shadow_width = 0x6E;
local shadow_height = 0x6F;

local x_pos = 0x7C;
local y_pos = x_pos + 4;
local z_pos = y_pos + 4;

local visibility = 0x63; -- 127 = visible

local floor = 0xA4;
local distance_from_floor = 0xB4;

local velocity = 0xB8;
--local acceleration = 0xBC; -- Seems wrong

local y_velocity = 0xC0;
local y_acceleration = 0xC4;

local gravity_strength = 0xC8;

local light_thing = 0xCC; -- Values 0x00->0x14

local x_rot = 0xE4;
local y_rot = x_rot + 2;
local z_rot = y_rot + 2;

local health = 0x134; -- Signed int 2 byte
local takes_enemy_damage = 0x13B;

local hand_state = 0x147; -- Bitfield

local shade_byte = 0x16D; -- TODO: Global?

-- Relative to tag barrel
local tb_scroll_timer = 0x17D;
local tb_current_index = 0x17E;
local tb_previous_index = 0x17F;
local tb_kickout_timer = 0x1B4;

-- Relative to camera
-- TODO: Verify for all versions
local camera_focus_pointer = 0x178;

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
local text_shown = 0x1EE; -- 16 bit uint

-- Relative to player
local grabbed_vine_pointer = 0x2B0;
local grab_pointer = 0x32c;
local fairy_active = 0x36c;

grab_script_mode = "Examine";

-- Relative to rendering params
local scale_x = 0x34;
local scale_y = scale_x + 4;
local scale_z = scale_y + 4;

local anim_timer1 = 0x94;
local anim_timer2 = 0x98;

local anim_timer3 = 0x104;
local anim_timer4 = 0x108;

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
	local i;
	for i=1,#object_pointers do
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
	local i;
	local melonCount = 0;
	for i=1,#object_pointers do
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
				print("Firing!");
			end
		end
	end
end

--event.onframestart(koshBotLoop, "Kremling Kosh Bot");

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

local function switch_grab_script_mode()
	if grab_script_mode == 'Examine' then
		grab_script_mode = 'List';
	else
		grab_script_mode = 'Examine';
	end
end

local function grab_object(pointer)
	local kongObject = mainmemory.read_u24_be(kong_pointer);
	if kongObject > 0x000000 and kongObject < 0x7FFFFF then
		mainmemory.writebyte(kongObject + grab_pointer, 0x80);
		mainmemory.write_u24_be(kongObject + grab_pointer + 1, pointer);
		mainmemory.writebyte(kongObject + grab_pointer + 4, 0x80);
		mainmemory.write_u24_be(kongObject + grab_pointer + 4 + 1, pointer);
	end
end

local function focus_object(pointer)
	local camera_object = mainmemory.read_u24_be(camera_pointer + 1);
	if camera_object > 0x000000 and camera_object < 0x7FFFFF then
		mainmemory.writebyte(camera_object + camera_focus_pointer, 0x80);
		mainmemory.write_u24_be(camera_object + camera_focus_pointer + 1, pointer);
	end
end

local function encircle_kong()
	local i, x, z;

	local kongObject = mainmemory.read_u24_be(kong_pointer);
	local kong_x = mainmemory.readfloat(kongObject + x_pos, true);
	local kong_y = mainmemory.readfloat(kongObject + y_pos, true);
	local kong_z = mainmemory.readfloat(kongObject + z_pos, true);

	for i=1,#object_pointers do
		x = kong_x + math.cos(math.pi * 2 * i / #object_pointers) * radius;
		z = kong_z + math.sin(math.pi * 2 * i / #object_pointers) * radius;

		mainmemory.writefloat(object_pointers[i] + x_pos, x, true);
		mainmemory.writefloat(object_pointers[i] + y_pos, kong_y, true);
		mainmemory.writefloat(object_pointers[i] + z_pos, z, true);
	end
end

local function getExamineData(pointer)
	local examine_data = {};

	local modelPointer = mainmemory.read_u32_be(pointer + model_pointer);
	local renderingParametersPointer = mainmemory.read_u32_be(pointer + rendering_parameters_pointer);
	local boneArrayPointer = mainmemory.read_u32_be(pointer + current_bone_array_pointer);
	local hasModel = isPointer(modelPointer) or isPointer(renderingParametersPointer) or isPointer(boneArrayPointer);

	local xPos = mainmemory.readfloat(pointer + x_pos, true);
	local yPos = mainmemory.readfloat(pointer + y_pos, true);
	local zPos = mainmemory.readfloat(pointer + z_pos, true);
	local hasPosition = xPos ~= 0 or yPos ~= 0 or zPos ~= 0 or hasModel;

	local currentActorType = mainmemory.read_u32_be(pointer + actor_type);
	if type(actor_types[currentActorType]) ~= "nil" then
		currentActorType = actor_types[currentActorType];
	end
	table.insert(examine_data, { "Actor type", currentActorType });
	table.insert(examine_data, { "Separator", 1 });

	if hasModel then
		table.insert(examine_data, { "Model", string.format("0x%08x", modelPointer) });
		table.insert(examine_data, { "Rendering Params", string.format("0x%08x", renderingParametersPointer) });
		table.insert(examine_data, { "Bone Array", string.format("0x%08x", boneArrayPointer) });
		table.insert(examine_data, { "Separator", 1 });
	end

	if hasPosition then
		table.insert(examine_data, { "X", mainmemory.readfloat(pointer + x_pos, true) });
		table.insert(examine_data, { "Y", mainmemory.readfloat(pointer + y_pos, true) });
		table.insert(examine_data, { "Z", mainmemory.readfloat(pointer + z_pos, true) });
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
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Fairy Active", mainmemory.readbyte(pointer + fairy_active) });
	table.insert(examine_data, { "Brightness", mainmemory.readbyte(pointer + shade_byte) });
	table.insert(examine_data, { "Separator", 1 });

	local visibilityValue = mainmemory.readbyte(pointer + visibility);
	table.insert(examine_data, { "Visibility", bizstring.binary(visibilityValue) });
	table.insert(examine_data, { "Visible", tostring(get_bit(visibilityValue, 2)) });
	table.insert(examine_data, { "Collides with terrain", tostring(get_bit(visibilityValue, 4)) });
	table.insert(examine_data, { "In water", tostring(not get_bit(visibilityValue, 0)) });
	table.insert(examine_data, { "Separator", 1 });

	if currentActorType ~= "Camera" then
		table.insert(examine_data, { "Grabbed Vine Pointer", string.format("0x%08x", mainmemory.read_u32_be(pointer + grabbed_vine_pointer)) });
		table.insert(examine_data, { "Grab pointer", string.format("0x%08x", mainmemory.read_u32_be(pointer + grab_pointer)) });
		table.insert(examine_data, { "Separator", 1 });
	end

	if currentActorType == "Camera" then
		local focusedActor = mainmemory.read_u24_be(pointer + camera_focus_pointer + 1);
		local focusedActorType;

		if focusedActor > 0x000000 and focusedActor < 0x7FFFFF then
			focusedActorType = mainmemory.read_u32_be(focusedActor + actor_type);
			if type(actor_types[focusedActorType]) ~= "nil" then
				focusedActorType = actor_types[focusedActorType];
			end
		end

		table.insert(examine_data, { "Focused Actor: ", string.format("0x%06x", focusedActor) });
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
	end

	if currentActorType == "Kremling Kosh Controller" then
		table.insert(examine_data, { "Current Slot", mainmemory.readbyte(pointer + slot_location) });
		table.insert(examine_data, { "Melons Remaining", mainmemory.readbyte(pointer + melons_remaining) });
		local i;
		for i=1,8 do
			table.insert(examine_data, { "Slot "..i.." pointer", string.format("0x%08x", mainmemory.read_u32_be(pointer + slot_pointer_base + (i - 1) * 4)) });
		end
		table.insert(examine_data, { "Separator", 1 });
	end

	return examine_data;
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
		object_index = math.max(1, object_index - 1);
		decrease_object_index_pressed = true;
	end

	if input_table[increase_object_index_key] == true and increase_object_index_pressed == false then
		object_index = math.min(#object_pointers, object_index + 1);
		object_index = math.max(1, object_index);
		increase_object_index_pressed = true;
	end

	if input_table[grab_object_key] == true and grab_object_pressed == false then
		grab_object(object_pointers[object_index]);
		grab_object_pressed = true;
	end

	if input_table[focus_object_key] == true and focus_object_pressed == false then
		focus_object(object_pointers[object_index]);
		focus_object_pressed = true;
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

	gui.text(gui_x, gui_y + height * row, "Mode: "..grab_script_mode, nil, nil, 'bottomright');
	row = row + 1;

	gui.text(gui_x, gui_y + height * row, "Index: "..object_index.."/"..#object_pointers, nil, nil, 'bottomright');
	row = row + 1;

	if #object_pointers > 0 and object_index <= #object_pointers then
		local currentActorType = mainmemory.read_u32_be((object_pointers[object_index] or 0) + actor_type);
		if type(actor_types[currentActorType]) ~= "nil" then
			currentActorType = actor_types[currentActorType];
		end
		gui.text(gui_x, gui_y + height * row, string.format("Selected object: 0x%06x: ", object_pointers[object_index] or 0)..currentActorType, nil, nil, 'bottomright');
		row = row + 1;
	end

	-- Display which object is grabbed
	local kongObject = mainmemory.read_u24_be(kong_pointer);
	gui.text(gui_x, gui_y + height * row, string.format("Grabbed object:  0x%06x", mainmemory.read_u24_be(kongObject + grab_pointer + 1)), nil, nil, 'bottomright');
	row = row + 1;

	-- Display which object the camera is currently focusing on
	local camera_object = mainmemory.read_u24_be(camera_pointer + 1);
	gui.text(gui_x, gui_y + height * row, string.format("Focused object:  0x%06x", mainmemory.read_u24_be(camera_object + camera_focus_pointer + 1)), nil, nil, 'bottomright');
	row = row + 1;
	row = row + 1;

	if #object_pointers > 0 and object_index <= #object_pointers then
		if grab_script_mode == "Examine" then
			local examine_data = getExamineData(object_pointers[object_index]);
			local i;
			for i=#examine_data,1,-1 do
				if examine_data[i][1] ~= "Separator" then
					gui.text(gui_x, gui_y + height * row, examine_data[i][1]..": "..examine_data[i][2], nil, nil, 'bottomright');
					row = row + 1;
				else
					row = row + examine_data[i][2];
				end
			end
		end

		if grab_script_mode == "List" then
			local i;
			for i=#object_pointers,1,-1 do
				local currentActorType = mainmemory.read_u32_be(object_pointers[i] + actor_type);
				if type(actor_types[currentActorType]) ~= "nil" then
					currentActorType = actor_types[currentActorType];
				end
				if object_index == i then
					gui.text(gui_x, gui_y + height * row, i..": "..string.format("0x%06x: ", object_pointers[i] or 0)..currentActorType, green_highlight, nil, 'bottomright');
				else
					if object_pointers[i] == kongObject then
						gui.text(gui_x, gui_y + height * row, i..": "..string.format("0x%06x: ", object_pointers[i] or 0)..currentActorType, yellow_highlight, nil, 'bottomright');
					else
						gui.text(gui_x, gui_y + height * row, i..": "..string.format("0x%06x: ", object_pointers[i] or 0)..currentActorType, nil, nil, 'bottomright');
					end
				end
				row = row + 1;
			end
		end
	end
end

local function isValidObject(pointer, kongObject, camera_object)
	if grab_script_mode == "Examine" or grab_script_mode == "List" or not safeMode then
		return true;
	end

	local modelPointer = mainmemory.read_u32_be(pointer + model_pointer);
	local hasModel = isPointer(modelPointer);

	if grab_script_mode == "Camera" and pointer ~= camera_object then
		return hasModel;
	end

	if grab_script_mode == "Grab" or grab_script_mode == "Encircle" then
		if pointer ~= kongObject then
			return hasModel;
		end
	end
end

local function pull_objects()
	local object_no = 0;
	local kongObject = mainmemory.read_u24_be(kong_pointer);
	local camera_object = mainmemory.read_u24_be(camera_pointer + 1);

	object_pointers = {};
	for object_no = 0, max_objects do
		local pointer = mainmemory.read_u24_be(pointer_list + (object_no * 4) + 1);
		local object_found = pointer > 0x000000 and pointer <= 0x7FFFFF;

		if object_found and isValidObject(pointer, kongObject, camera_object) then
			table.insert(object_pointers, pointer);
		end
	end

	-- Clamp index
	object_index = math.min(object_index, math.max(1, #object_pointers));

	if grab_script_mode == "Encircle" then
		--encircle_kong();
		local renderingParams = mainmemory.read_u24_be(kongObject + rendering_parameters_pointer + 1);
		if renderingParams > 0x000000 and renderingParams < 0x7FFFFF then
			if math.random() > 0.9 then
				local timerValue = math.random() * 50;
				mainmemory.writefloat(renderingParams + anim_timer1, timerValue, true);
				mainmemory.writefloat(renderingParams + anim_timer2, timerValue, true);
				mainmemory.writefloat(renderingParams + anim_timer3, timerValue, true);
				mainmemory.writefloat(renderingParams + anim_timer4, timerValue, true);
			end
		end
	end

	draw_gui();
end

event.onframestart(pull_objects, "Evaluate Object Pointer List");
event.onframestart(process_input, "Grab Object Keybinds");