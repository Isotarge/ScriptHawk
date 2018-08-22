if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

encircle_enabled = false;

object_index = 1;
object_pointers = {}; -- TODO: I'd love to get rid of this eventually, replace with some kind of getObjectPointers() system
grab_script_modes = {
	"Disabled",
	"List",
	"Examine",
};
grab_script_mode_index = 1;
grab_script_mode = grab_script_modes[grab_script_mode_index];

local Game = {
	Memory = { -- 1 USA, 2 EU
		jim_pointer = {0x0C6810, 0x0C8670},
		floor_value = {0x0D6EDC, 0x0D8D3C},
		boss_camlock_pointer = {0x0E9F08, 0x0EBD68},
		current_map = {0x0E9EF9, 0x0EBD59},
		destination_map = {0x0E03E7, 0x0E2247},
		destination_exit = {0x0E03E9, 0x0E2249},
		subhub_entrance_cs = {0x0C624A, nil},
		--controller_input = {0x0D4134, 0x0D5F94},
		reload_map = {0x0E03E2, 0x0E2242},
		marble_pointer = {0x0C61E2, 0x0C8042},
		object_count = {0x0A6F02, nil},
		pointer_list = {0x0E9E98, nil}, -- 0x273870
	},
};

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	if romHash == "EAB14F23640CD6148D4888902CDCC00DD6111BF9" then -- US
		version = 1;
	elseif romHash == "F02C1AFD18C1CBE309472CBE5B3B3F04B22DB7EE" then -- Europe
		version = 2;
	else
		return false;
	end

	-- Squish Game.Memory tables down to a single address for the relevant version
	for k, v in pairs(Game.Memory) do
		Game.Memory[k] = v[version];
	end

	return true;
end

--------------------
-- Jim Parameters --
--------------------

jim = {
	y_rotation_1 = 0x000, -- Float
	y_rotation_2 = 0x008, -- Float
	x_position = 0x030, -- Float
	y_position = 0x034, -- Float
	z_position = 0x038, -- Float
	bagpipe_lock = 0x0C0, -- Byte
	animation_timer = 0x0CA, -- 2 Byte
	control_type = 0x0F4, -- 4 Byte (0 = Normal, 2 = Boss Fights, 4 = Void Process)
	Health = 0x0FC, -- 4 Byte
	animation = 0x0C9, -- Byte
	Lives = 0x100, -- 4 Byte
	gun_pointer = 0x104,
	movement = 0x2F3, -- Byte
	cutscene_lock = 0x2A3, -- Byte
	--speed = 0x2C8, -- Float (Not too sure on this)
	y_last_action = 0x338, -- Float
	crouch_available = 0x454, -- Byte
	oob_timer = 0x455, -- Byte
	boss_pointer = 0x48C, -- Byte
	first_person_angle_delta = 0x4D8, -- Float, Radians?
	character_mode = 0x5B0, -- Byte (0 = Jim, 1+ = Kim)
};

--------------------
-- Gun Parameters --
--------------------

gun = {
	red_gun = 0x000,
	bubble_gun = 0x018,
	rockets = 0x030,
	flamethrower = 0x048,
	bananamyte = 0x060,
	laser = 0x078,
	pea = 0x090,
	egg	= 0x0A8,
	fakegun = 0x0C0,
	magnum = 0x0D8,
	disco = 0x0F0,
	knife = 0x108,
	leprechaun = 0x120,
};

---------------------
-- Boss Parameters --
---------------------

boss = {
	player_marbles = 0xDFC,
	player_egoboosts = 0xDFD,
	player_missiles = 0xDFE,
	boss_marbles = 0xE48,
	boss_egoboosts = 0xE49,
	boss_missiles = 0xE4A,
};

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = {.001, .01, .1, .5, 1, 2, 5, 10, 20 };
Game.speedy_index = 7;
Game.speedy_invert_LR = 1;

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.jim_pointer + jim.x_position, true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.jim_pointer + jim.y_position, true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.jim_pointer + jim.z_position, true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(Game.Memory.jim_pointer + jim.x_position, value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.jim_pointer + jim.y_position, value, true);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.jim_pointer + jim.z_position, value, true);
end

function Game.getFloor()
	return mainmemory.readfloat(Game.Memory.floor_value, true);
end

--------------
-- Rotation --
--------------

Game.rot_speed = 10;
Game.max_rot_units = 360;

function Game.calculateAngle(angle1,angle2)
	angle_1 = 90 * (angle1 + 1);
	
	if angle2 < 0 then
		angle = (angle_1 * (0 - 1)) - 90;
	else
		angle = (angle_1 - 90);
	end
	return angle;
end


function Game.getXRotation()
	return mainmemory.readfloat(Game.Memory.x_rotation, true);
end

function Game.getYRotation()
	local angle1 = mainmemory.readfloat(Game.Memory.jim_pointer + jim.y_rotation_1, true);
	local angle2 = mainmemory.readfloat(Game.Memory.jim_pointer + jim.y_rotation_2, true);
	return Game.calculateAngle(angle1,angle2);
end

function Game.getZRotation()
	return mainmemory.readfloat(Game.Memory.z_rotation, true);
end

function Game.setXRotation(value)
	mainmemory.writefloat(Game.Memory.x_rotation, value, true);
end

function Game.setYRotation(value)
	mainmemory.writefloat(Game.Memory.y_rotation, value / 180, true);
end

function Game.setZRotation(value)
	mainmemory.writefloat(Game.Memory.z_rotation, value, true);
end

------------
-- Events --
------------

Game.maps = {
	"The Brain",
	"Memory Hub",
	"Coop D'Etat",
	"Barn to be Wild",
	"Psycrow",
	"Happiness Hub",
	"Lord to the Fries",
	"Are you Hungry Tonite?",
	"Fatty Roswell",
	"Fear Hub",
	"Mansion Lobby",
	"Poultrygeist",
	"Poultrygeist Too",
	"Death Wormed Up",
	"Boogie Nights of the Living Dead",
	"Professor Monkey for a Head",
	"Fantasy Hub",
	"Violent Death Valley",
	"The Good, The Bad and The Elderly",
	"Bob and Number Four",
	"Earthworm Kim",
	"Main Menu",
};

Game.animations = {
	[0] = "Walking",
	[1] = "Running",
	[2] = "Preparing to Run",
	[3] = "Idle",
	[4] = "Creeping",
	[5] = "Stopping",
	[6] = "Jumping",
	[7] = "Holding Gun",
	[8] = "Firing",
	[9] = "Grabbing Gun",
	-- [10] = "Wielding Gun", -- Not used?
	[11] = "Idle", -- Rope
	[12] = "Moving", -- Rope
	[13] = "Holding Gun", -- Rope
	[14] = "Firing", -- Rope
	[15] = "Grabbing Gun", -- Rope
	[16] = "Retracting Gun", -- Rope
	[17] = "Surfing", -- Pork Boarding, No Earthworm Turning
	[18] = "Surfing", -- Pork Boarding, Earthworm Turning
	[19] = "Grabbing Ledge",
	[20] = "Damage", -- Laser Guns, Fall Damage
	[21] = "Damage", -- Knockback
	[22] = "Death",
	[23] = "Idle", -- Pulling Head
	[24] = "Breaking Wind", -- Pp Can, Also acid sea damage
	[25] = "Crouching/Rolling",
	[26] = "Udder Dance",
	[27] = "Whipping",
	[28] = "Whipping", -- Jumping
	[29] = "Floating", -- Spin Move in Air
	[30] = "Damage", -- Acid Bats
	[31] = "Dodging", -- Rope
	[32] = "Damage", -- Rope
	[33] = "Drowning",
	[34] = "Inflating", -- Balloon
	[35] = "Floating", -- Balloon
	[36] = "Ego Boost", -- Pork Boarding
	[37] = "Damage", -- Pork Boarding
	[38] = "Jumping", -- Pork Boarding
	[39] = "Bagpipes", -- Opening new hub
	[40] = "Prancing", -- Main Menu Pre/Post-Accordion
	[41] = "Playing", -- Main Menu Accordion
	[42] = "Falling", -- Main Menu Post Cows
	[43] = "Locked", -- Textbox
};

Game.movements = {
	[0] = "Normal", -- A lot of things
	[1] = "Jumping", -- Moving
	[2] = "Jumping (Stationary)",
	[4] = "Stopping",
	[9] = "On Rope",
	[12] = "Grabbing Ledge", -- End of Grabbing Up
	[13] = "Grabbing Ledge", -- Grabbing Up
	[14] = "Breaking Wind",
	[16] = "Rolling",
	[17] = "Crouching",
	[18] = "Whipping (Grounded)",
	[19] = "Whipping", -- Airbourne
	[20] = "Floating",
	[21] = "Knockback", -- Damage
	[22] = "Damaged", -- Damage plane (Acid sea/bean sea etc.)
	[23] = "Acid Burn", -- Acid Bats
	[24] = "First Person",
	[25] = "Blue Balloon",
};

Game.takeMeThereType = "Checkbox";

function Game.setMap(index)
	mainmemory.writebyte(Game.Memory.destination_map, index - 1);
end

function Game.checkMapSoftlock()
	local dest_exit = mainmemory.readbyte(Game.Memory.destination_exit);
	local dest_map = mainmemory.readbyte(Game.Memory.destination_map);

	if dest_map == 1 or dest_map == 5 or dest_map == 9 or dest_map == 16 then -- Sub Hubs (Central Column Fix)
		if dest_exit > 0 and dest_exit < 4 then -- Coming from Boss/Level
			mainmemory.writebyte(Game.Memory.subhub_entrance_cs, 0);
		else -- Coming from 'The Brain'
			mainmemory.writebyte(Game.Memory.subhub_entrance_cs, 1);
		end
	end
end

function Game.reloadMap()
	mainmemory.writebyte(Game.Memory.reload_map, 1);
	Game.checkMapSoftlock()
end

function Game.reloadMapHard()
	mainmemory.writebyte(Game.Memory.current_map, 255);
	Game.reloadMap()
end

function Game.getMapOSD()
	local currentMap = mainmemory.readbyte(Game.Memory.current_map);
	local currentMapName = "Unknown";
	if Game.maps[currentMap + 1] ~= nil then
		currentMapName = Game.maps[currentMap + 1];
	end
	return currentMapName.." ("..currentMap..")";
end

function Game.setExit(index)
	mainmemory.writebyte(Game.Memory.destination_exit);
end

function Game.getExitOSD()
	local currentExit = mainmemory.readbyte(Game.Memory.destination_exit);
	return currentExit;
end

function Game.getAnimationOSD()
	local currentAnimation = mainmemory.readbyte(Game.Memory.jim_pointer + jim.animation);
	local currentAnimationName = "Unknown ("..currentAnimation..")";
	return Game.animations[currentAnimation] or currentAnimationName;
end

function Game.getMovementOSD()
	local currentMovement = mainmemory.readbyte(Game.Memory.jim_pointer + jim.movement);
	local currentMovementName = "Unknown ("..currentMovement..")";
	return Game.movements[currentMovement] or currentMovementName;
end

function Game.getAnimationTimerOSD()
	local anim_timer = mainmemory.read_u16_be(Game.Memory.jim_pointer + jim.animation_timer);
	return anim_timer;
end

function Game.FreezeOoBTimer()
	mainmemory.writebyte(Game.Memory.jim_pointer + jim.oob_timer, 0);
end

--------------------
-- FREE ROAM MODE --
--------------------

function Game.freeroamEnabled()
	if IsYStored ~= 1 then
		YStored = Game.getYPosition();
		IsYStored = 1;
	end
	
	-- detect if L to Levitate
	joypad_pressed = {};
	input_pressed = {};
	joypad_pressed = joypad.getimmediate();
	input_pressed = input.get();
	lbutton_pressed = joypad_pressed[ScriptHawk.lbutton.joypad] or input_pressed[ScriptHawk.lbutton.key];
	if lbutton_pressed then
		YStored = Game.getYPosition() + Game.speedy_speeds[Game.speedy_index];
	end
	
	Game.setYPosition(YStored);
	
	-- Cancel falling
	if mainmemory.readbyte(Game.Memory.jim_pointer + jim.movement) == 2 then
		mainmemory.writebyte(Game.Memory.jim_pointer + jim.movement, 21);
	end
end

function Game.freeroamDisabled()
	IsYStored = 0;
end

------------------
-- CONSOLE MODE --
------------------

function Game.toggleConsoleMode()
	if console_mode == 0 or console_mode == nil then
		console_mode = 1;
	elseif console_mode == 1 then
		console_mode = 2;
	else
		console_mode = 0;
	end
end

function Game.getConsoleMode()
	if console_mode == 1 then
		forms.settext(ScriptHawk.UI.form_controls["Console Mode Switch"], "N64 Mode");
		twirl_yFreeze = 1;
		roll_cap = 1;
		walljump_hack = 1;
	elseif console_mode == 2 then
		forms.settext(ScriptHawk.UI.form_controls["Console Mode Switch"], "PC Mode");
		twirl_yFreeze = 0;
		roll_cap = 1;
		walljump_hack = 0;
	else
		forms.settext(ScriptHawk.UI.form_controls["Console Mode Switch"], "Emulator Mode");
		twirl_yFreeze = 0;
		roll_cap = 0;
		walljump_hack = 0;
	end
end

function Game.applyConsoleSettings()
	-- List of edits to make more accurate to N64 or PC release
		
	if twirl_yFreeze == 1 then	-- NO TWIRL HEIGHT GAIN
		animation_value = mainmemory.readbyte(Game.Memory.jim_pointer + jim.animation);
		animation_frame = mainmemory.read_u16_be(Game.Memory.jim_pointer + jim.animation_timer);
		movement_value = mainmemory.readbyte(Game.Memory.jim_pointer + jim.movement);
		
		if animation_value == 29 and movement_value == 20 then
			if twirlStoredY == nil then
				if version == 1 then -- US
					twirlStoredY = Game.getYPosition() - 0.0498;
				else -- version = 2 (EU)
					twirlStoredY = Game.getYPosition() - 0.042;
				end
			end
			
			Game.setYPosition(twirlStoredY);
			
			if animation_frame == 9 then
				twirlStoredY = nil;
			end
		else
			twirlStoredY = nil;
		end
	end
	
	if roll_cap == 1 then	-- NO HYPEREXTENDED ROLL (NOT EVEN ON PC, JUST AN EMU BUG)
		if animation_value == 25 and movement_value == 16 then
			if roll_count == nil then
				roll_count = 0;
			end
			
			if animation_frame == 21 then
				roll_count = roll_count + 1;
				if roll_count == 8 then
					mainmemory.write_u16_be(Game.Memory.jim_pointer + jim.animation_timer, 23);
					roll_count = 0;
				end
			end
		end
	end

	if walljump_hack == 1 then	-- WALLJUMP
		if animation_value == 6 and movement_value == 12 then
			mainmemory.writebyte(Game.Memory.jim_pointer + jim.crouch_available, 1);
		end
	end
end

---------------
-- INFINITES --
---------------

function Game.applyInfinites()
	max_ammo_red_gun = 250;
	max_ammo_bubble_gun = 50;
	max_ammo_rockets = 25;
	max_ammo_flamethrower = 50;
	max_ammo_bananamyte = 1;
	max_ammo_laser = 6;
	max_ammo_pea = 50;
	max_ammo_egg = 25;
	max_ammo_fakegun = 0;
	max_ammo_magnum = 50;
	max_ammo_disco = 6;
	max_ammo_knife = 1;
	max_ammo_leprechaun = 5;
	max_lives = 3;
	max_health = 100;
	max_missiles = 2;
	max_egoboosts = 2;

	-------------------
	-- Set Infinites --
	-------------------

	-- Lives
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.Lives, max_lives);
	-- Health
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.Health, max_health);
	-- Red Gun
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.red_gun, max_ammo_red_gun);
	-- Bubble Gun
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.bubble_gun, max_ammo_bubble_gun);
	-- Rocket Launcher
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.rockets, max_ammo_rockets);
	-- Flamethrower
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.flamethrower, max_ammo_flamethrower);
	-- Bananamyte
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.bananamyte, max_ammo_bananamyte);
	-- Laser Gun
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.laser, max_ammo_laser);
	-- Pea Shooter
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.pea, max_ammo_pea);
	-- Egg Shooter
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.egg, max_ammo_egg);
	-- Fake unused gun
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.fakegun, max_ammo_fakegun);
	-- Magnum Gun
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.magnum, max_ammo_magnum);
	-- Disco Gun
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.disco, max_ammo_disco);
	-- Knife Boomerang
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.knife, max_ammo_knife);
	-- Leprechaun Launcher
	mainmemory.write_u32_be(Game.Memory.jim_pointer + jim.gun_pointer + gun.leprechaun, max_ammo_leprechaun);
	local bossPointer = dereferencePointer(Game.Memory.jim_pointer + jim.boss_pointer);
	if isRDRAM(bossPointer) then
		-- Missiles
		mainmemory.writebyte(bossPointer + boss.player_missiles, max_missiles);
		-- Ego Boosts
		mainmemory.writebyte(bossPointer + boss.player_egoboosts, max_egoboosts);
	end
end

function Game.completeFile()
	local udder_pointer = Game.Memory.marble_pointer + 0x14;

	-- UDDERS
	mainmemory.writebyte(udder_pointer + 0x00, 1); -- Brain
	mainmemory.writebyte(udder_pointer + 0x02, 3); -- Coop D'Etat
	mainmemory.writebyte(udder_pointer + 0x03, 7); -- Barn to be Wild
	mainmemory.writebyte(udder_pointer + 0x04, 5); -- Psycrow
	mainmemory.writebyte(udder_pointer + 0x06, 5); -- Lord of the Fries
	mainmemory.writebyte(udder_pointer + 0x07, 5); -- Hungry Tonite?
	mainmemory.writebyte(udder_pointer + 0x08, 5); -- Fatty Roswell
	mainmemory.writebyte(udder_pointer + 0x0B, 5); -- Poultrygeist
	mainmemory.writebyte(udder_pointer + 0x0C, 5); -- Poultrygeist Too
	mainmemory.writebyte(udder_pointer + 0x0D, 6); -- Death Wormed Up
	mainmemory.writebyte(udder_pointer + 0x0E, 5); -- Boogie Nights
	mainmemory.writebyte(udder_pointer + 0x0F, 5); -- Monkey for a Head
	mainmemory.writebyte(udder_pointer + 0x11, 6); -- Violent Death Valley
	mainmemory.writebyte(udder_pointer + 0x12, 6); -- Good Bad Elderly
	mainmemory.writebyte(udder_pointer + 0x13, 5); -- Bob & Number 4

	-- MARBLES
	mainmemory.writebyte(Game.Memory.marble_pointer + 0x00, 100); -- Coop D'Etat
	mainmemory.writebyte(Game.Memory.marble_pointer + 0x01, 100); -- Barn to be Wild
	mainmemory.writebyte(Game.Memory.marble_pointer + 0x04, 100); -- Lord of the Fries
	mainmemory.writebyte(Game.Memory.marble_pointer + 0x05, 100); -- Hungry Tonite
	mainmemory.writebyte(Game.Memory.marble_pointer + 0x09, 100); -- Poultrygeist
	mainmemory.writebyte(Game.Memory.marble_pointer + 0x0A, 100); -- Poultrygeist Too
	mainmemory.writebyte(Game.Memory.marble_pointer + 0x0B, 100); -- Death Wormed Up
	mainmemory.writebyte(Game.Memory.marble_pointer + 0x0C, 100); -- Boogie Nights
	mainmemory.writebyte(Game.Memory.marble_pointer + 0x0F, 100); -- Violent Death Valley
	mainmemory.writebyte(Game.Memory.marble_pointer + 0x10, 100); -- Good Bad Elderly
end

Game.BossCamLockOffset = {
	[4] = 0x4D8, -- Psycrow
	[8] = 0x4C8, -- Roswell
	[15] = 0x4B0, -- PMFAH
	[19] = 0x4C8, -- Bob
	[20] = 0x4C0, -- Kim
};

function Game.killBoss()
	BossCamLockOffSet = Game.BossCamLockOffset[mainmemory.readbyte(Game.Memory.current_map)];
	if BossCamLockOffSet ~= nil then
		camlock_address = dereferencePointer(Game.Memory.boss_camlock_pointer) + BossCamLockOffSet;
		bossdeath_address = dereferencePointer(Game.Memory.jim_pointer + jim.boss_pointer) + 0xE73;
		mainmemory.writebyte(camlock_address, 1);
		mainmemory.writebyte(bossdeath_address, 1);
	else
		print("This map does not have a programmed boss, and so this function will not run");
	end
end

------------------------------
-- Fix Controller Input Bug --
------------------------------

--[[
function Game.fixInputBug()
	local joystick_x_input = mainmemory.readbyte(Game.Memory.controller_input + 0x2);
	if joystick_x_input == 127 then
		mainmemory.writebyte(Game.Memory.controller_input + 0x2, 126);
	end

	joystick_x_input = mainmemory.readbyte(Game.Memory.controller_input + 0x2);
	if joystick_x_input == 127 then
		joypad.setanalog({["P1 X Axis"] = 126})
	end
end
--]]

------------------
-- Object Stuff --
------------------
-- 0x70 Position: X (Float)
-- 0x74 Position: Y (Float)
-- 0x78 Position: Z (Float)
-- 0x80 Angle (2-Byte)
-- 0x129 Health (1-Byte)
-- 0x12C Size (2-Byte)
-- 0x138 Opacity (1-Byte)
-- 0x13B Animation (1-Byte)
-- 0x13D Animation Timer (1-Byte)

-- 0x2740B0, 0x274170, 0x274230 (C0 difference)
-- 0x3206C8, 0x320820, 0x320978 (158 difference)
-- I think the start of the objects pointer list is at 0x273870

-- +0x1123 on model ptr

local function getObjectCount()
	return math.min(255, mainmemory.read_u16_be(Game.Memory.object_count));
end

function incrementObjectIndex()
	object_index = object_index + 1;
	if object_index > #object_pointers then
		object_index = 1;
	end
end

function decrementObjectIndex()
	object_index = object_index - 1;
	if object_index <= 0 then
		object_index = #object_pointers;
	end
end

function switch_grab_script_mode()
	grab_script_mode_index = grab_script_mode_index + 1;
	if grab_script_mode_index > #grab_script_modes then
		grab_script_mode_index = 1;
	end
	grab_script_mode = grab_script_modes[grab_script_mode_index];
end

-- Relative to Model 1 Objects
object_properties = {
	object_x = 0x70,
	object_y = 0x74,
	object_z = 0x78,
	object_angle = 0x80,
	object_model_pointer = 0xD8;
	object_health = 0x129,
	object_size = 0x12C,
	object_pointer_to_pointer = 0x130,
	object_opacity = 0x138,
	object_anim = 0x13B,
	object_anim_timer = 0x13D,
	object_value = 0x1122,
	object_types = {
		[0x1] = "Mini Roswell (Gun)",
		[0x2] = "Beaver", -- PG1
		[0x4] = "Bob and Number Four",
		[0x5] = "Fatty Roswell",
		[0x6] = "Professor Monkey for a Head",
		[0x7] = "Psycrow",
		[0x8] = "Cow Enemy",
		[0x9] = "Acid Bat",
		[0xA] = "Dynamite Bunny",
		[0xB] = "Cactus",
		[0xD] = "Disco Body",
		[0xE] = "Disco Head",
		[0x11] = "Pork Board (Earthworm Kim)",
		[0x12] = "Frog Enemies", -- PG2 Tree Room
		[0x14] = "Large Cow", -- Hubs, Boss Worlds
		[0x1A] = "Cow", --Main Menu
		[0x1C] = "Granny",
		[0x1E] = "Pork Board",
		[0x23] = "Moosilini",
		[0x25] = "Speaker Enemy",
		[0x26] = "Speaker" -- Destructable
	},
};

local function populateObjectPointers()
	object_pointers = {};
	pointers_start = dereferencePointer(Game.Memory.pointer_list);
	if isRDRAM (pointers_start) then
		for object_no = 0, getObjectCount() do
			local pointer = dereferencePointer(pointers_start + (object_no * 0xC0));
			if isRDRAM(pointer) then
				table.insert(object_pointers, pointer);
			end
		end
	end
	-- Clamp index
	object_index = math.min(object_index, math.max(1, #object_pointers));
end

function getObjectValue(pointer)
	modelPtr = dereferencePointer(pointer + object_properties.object_model_pointer);
	if isRDRAM(modelPtr) then
		objectValue = mainmemory.read_u16_be(modelPtr + 0x1122);
	else
		objectValue = 0;
	end
	return objectValue;
end

function getObjectNameFromValue(value)
	if type(object_properties.object_types[value]) == 'string' then
		objname = object_properties.object_types[value];
	else
		objname = toHexString(value);
	end
	return objname;
end

local function getExamineData(pointer)
	local examine_data = {};

	if not isRDRAM(pointer) then
		return examine_data;
	end
	
	local objectPtrPtr = dereferencePointer(pointer + object_properties.object_pointer_to_pointer);
	local objectPointer = dereferencePointer(objectPtrPtr);
	local modelPointer = dereferencePointer(pointer + object_properties.object_model_pointer);
	local xPos = mainmemory.readfloat(pointer + object_properties.object_x, true);
	local yPos = mainmemory.readfloat(pointer + object_properties.object_y, true);
	local zPos = mainmemory.readfloat(pointer + object_properties.object_z, true);
	local hasPosition = hasModel or xPos ~= 0 or yPos ~= 0 or zPos ~= 0;
	local objectVal = getObjectValue(pointer)
	
	table.insert(examine_data, { "Address", toHexString(objectPointer) });
	table.insert(examine_data, { "Object Name", getObjectNameFromValue(objectVal) });
	table.insert(examine_data, { "Object Value", toHexString(objectVal) });
	table.insert(examine_data, { "Separator", 1 });
	table.insert(examine_data, { "X", xPos });
	table.insert(examine_data, { "Y", yPos });
	table.insert(examine_data, { "Z", zPos });
	table.insert(examine_data, { "Separator", 1 });
	table.insert(examine_data, { "Angle", mainmemory.read_u16_be(pointer + object_properties.object_angle) });
	table.insert(examine_data, { "Scale", mainmemory.read_u16_be(pointer + object_properties.object_size) });
	table.insert(examine_data, { "Health", mainmemory.readbyte(pointer + object_properties.object_health) });
	table.insert(examine_data, { "Opacity", mainmemory.readbyte(pointer + object_properties.object_opacity) });
	table.insert(examine_data, { "Separator", 1 });
	table.insert(examine_data, { "Model Address", toHexString(modelPointer) });
	table.insert(examine_data, { "Separator", 1 });
	table.insert(examine_data, { "Animation", mainmemory.readbyte(pointer + object_properties.object_anim) });
	table.insert(examine_data, { "Animation Timer", mainmemory.readbyte(pointer + object_properties.object_anim_timer) });

	return examine_data;
end

local function drawGrabScriptUI()
	if grab_script_mode == "Disabled" then
		return;
	end

	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	gui.text(gui_x, gui_y + height * row, "Mode: "..grab_script_mode, nil, 'bottomright');
	row = row + 1;

	if grab_script_mode == "List" or grab_script_mode == "Examine" then
		populateObjectPointers();
	end

	gui.text(gui_x, gui_y + height * row, "Index: "..object_index.."/"..#object_pointers, nil, 'bottomright');
	row = row + 1;
	gui.text(gui_x, gui_y + height * row, "Page: "..(page_pos).."/"..(page_total), nil, 'bottomright');
	row = row + 1;
	row = row + 1;

	-- Clamp index to number of objects
	if #object_pointers > 0 and object_index > #object_pointers then
		object_index = #object_pointers;
	end

	if #object_pointers > 0 and object_index <= #object_pointers then
		if string.contains(grab_script_mode, "Examine") then
			local examine_data = {};
			if grab_script_mode == "Examine" then
				examine_data = getExamineData(object_pointers[object_index]);
			end

			pagifyThis(examine_data,40);

			for i = page_finish, page_start + 1, -1 do
				if examine_data[i][1] ~= "Separator" then
					if type(examine_data[i][2]) == "number" then
						examine_data[i][2] = round(examine_data[i][2], precision);
					end
					gui.text(gui_x, gui_y + height * row, examine_data[i][1]..": "..examine_data[i][2], nil, 'bottomright');
					row = row + 1;
				else
					row = row + examine_data[i][2];
				end
			end
		end

		if grab_script_mode == "List" then
			row = row + 1;
			pagifyThis(object_pointers,40);
			for i = page_finish, page_start + 1, -1 do
				local color = nil;
				if object_index == i then
					color = colors.yellow;
				end
				if object_pointers[i] == playerObject then
					color = colors.green;
				end
				local objectVal = getObjectValue(object_pointers[i] or 0)
				gui.text(gui_x, gui_y + height * row, i..": "..toHexString(object_pointers[i] or 0, 6).." ("..getObjectNameFromValue(objectVal)..")", color, 'bottomright');
				--gui.text(gui_x, gui_y + height * row, i..": "..getActorName(object_pointers[i]).." "..toHexString(object_pointers[i] or 0, 6).." ("..toHexString(currentActorSize)..")".." ("..getActorCollisions(object_pointers[i]).." cols)", color, 'bottomright');
				row = row + 1;
			end
		end
	end
end

function zipToSelectedObject()
	local desiredX, desiredY, desiredZ;
	local selectedObject = object_pointers[object_index];
	if isRDRAM(selectedObject) then
		-- Get selected object X,Y,Z position
		if grab_script_mode == "List" or grab_script_mode == "Examine" then
			desiredX = mainmemory.readfloat(selectedObject + object_properties.object_x, true);
			desiredY = mainmemory.readfloat(selectedObject + object_properties.object_y, true);
			desiredZ = mainmemory.readfloat(selectedObject + object_properties.object_z, true);
		end
	end
	-- Update player position
	if type(desiredX) == "number" and type(desiredY) == "number" and type(desiredZ) == "number" then
		-- Write position
		Game.setPosition(desiredX, desiredY, desiredZ);
	end
end

----------------
-- Flag Stuff --
----------------
Game.flagBlock = {
--  BRAIN
	brain_udder_first = {0x0C6294, nil},
	brain_unlock_kim = {0x2772A0, nil},
--  COOP D'ETAT
	cde_udder_fridge = {0x0C627A, nil},
	cde_udder_pants = {0x0C627B, nil},
	cde_udder_chicken = {0x0C627C, nil},
--  BARN TO BE WILD
	btbw_udder_quicksand = {nil, nil},
	btbw_udder_barndoor = {nil, nil},
	btbw_udder_crow = {nil, nil},
	btbw_udder_jail = {nil, nil},
	btbw_udder_obstacle = {nil, nil},
	btbw_udder_balloon = {nil, nil},
	btbw_udder_camera = {nil, nil},
--  PSYCROW
	psy_udder_completion = {nil, nil},
--  LORD OF THE FRIES

--  ARE YOU HUNGRY TONITE?
	ayht_udder_bean = {0x37BAF8, nil},
--  FATTY Roswell

--  POULTRYGEIST
	poultone_udder_beaver = {0x310010, nil},
	poultone_udder_furniture = {0x310020, nil},
	poultone_udder_hoover = {0x310028, nil},
--  POULTRYGEIST TOO
	poulttwo_udder_fireplace = {0x321278, nil},
--  DEATH WORMED UP
	dwu_udder_graves = {0x0C625B, nil},
	dwu_udder_swamp = {0x0C625D, nil},
	dwu_udder_balloon = {0x0C6260, nil},
--  BOOGIE NIGHTS OF THE LIVING DEAD

--  PROFESSOR MONKEY FOR A HEAD

--  VIOLENT DEATH VALLEY

--  THE GOOD, THE BAD AND THE ELDERLY

--  BOB AND NUMBER Four

--  EARTHWORM KIM
};

ScriptHawk.bindKeyRealtime("N", decrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("M", incrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("Z", zipToSelectedObject, true);
ScriptHawk.bindKeyRealtime("H", decrementPage, true);
ScriptHawk.bindKeyRealtime("J", incrementPage, true);
ScriptHawk.bindKeyRealtime("C", switch_grab_script_mode, true);

local labelValue = 0;
function Game.initUI()
	ScriptHawk.UI.form_controls["Reload Map (Soft)"] = forms.button(ScriptHawk.UI.options_form, "Reload Map", Game.reloadMap, ScriptHawk.UI.col(5), ScriptHawk.UI.row(4), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Reload Map (Hard)"] = forms.button(ScriptHawk.UI.options_form, "Hard Reload", Game.reloadMapHard, ScriptHawk.UI.col(10), ScriptHawk.UI.row(0), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Kill Boss"] = forms.button(ScriptHawk.UI.options_form, "Kill Boss", Game.killBoss, ScriptHawk.UI.col(10), ScriptHawk.UI.row(1), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["OoB Timer Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "OoB Timer Off", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);
	ScriptHawk.UI.form_controls["Free Roam Mode"] = forms.checkbox(ScriptHawk.UI.options_form, "Free Roam Mode", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset);
	ScriptHawk.UI.form_controls["Console Mode Switch"] = forms.button(ScriptHawk.UI.options_form, "Emulator Mode", Game.toggleConsoleMode, ScriptHawk.UI.col(10), ScriptHawk.UI.row(4), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
end

function Game.realTime()
--	if ScriptHawk.UI.ischecked("Fix Input Bug") then
--		Game.fixInputBug();
--	end
	Game.getConsoleMode()
	drawGrabScriptUI()
end

function Game.eachFrame()
	if ScriptHawk.UI.ischecked("OoB Timer Checkbox") then
		Game.FreezeOoBTimer()
	end
	
	if ScriptHawk.UI.ischecked("Free Roam Mode") then
		Game.freeroamEnabled()
	else
		Game.freeroamDisabled()
	end
	
	drawGrabScriptUI()
	Game.applyConsoleSettings()
end

event.onframeend(Game.eachFrame, "Each Frame function")

Game.OSDPosition = {2, 70};
Game.OSD = {
	{"Map", Game.getMapOSD},
	{"Exit", Game.getExitOSD},
	{"Separator"},
	{"X"},
	{"Y"},
	{"Z"},
	{"Separator"},
	{"dY"},
	{"dXZ"},
	{"Separator"},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator"},
	--{"Rot. X", Game.getXRotation},
	{"Floor", Game.getFloor},
	{"Animation", Game.getAnimationOSD},
	{"Animation Timer", Game.getAnimationTimerOSD},
	{"Movement", Game.getMovementOSD},
	{"Facing", Game.getYRotation},
	--{"Rot. Z", Game.getZRotation},
};

return Game;