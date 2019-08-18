if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

encircle_enabled = false;

local object_index = 1;
local object_pointers = {}; -- TODO: I'd love to get rid of this eventually, replace with some kind of getObjectPointers() system
local grab_script_modes = {
	"Disabled",
	"List (Model 1)",
	"Examine (Model 1)",
	"List (Model 2)",
	"Examine (Model 2)",
};
local grab_script_mode_index = 1;
local grab_script_mode = grab_script_modes[grab_script_mode_index];

local Game = {
	squish_memory_table = true,
	Memory = { -- 1 USA, 2 EU
		jim_pointer = {0x0C6810, 0x0C8670},
		floor_value = {0x0D6EDC, 0x0D8D3C},
		current_map = {0x0E9EF9, 0x0EBD59},
		destination_map = {0x0E03E7, 0x0E2247},
		destination_exit = {0x0E03E9, 0x0E2249},
		subhub_entrance_cs = {0x0C624A, nil},
		--controller_input = {0x0D4134, 0x0D5F94},
		reload_map = {0x0E03E2, 0x0E2242},
		marble_pointer = {0x0C61E2, 0x0C8042},
		object_count = {0x0E9E97, nil},
		obj1_pointer_list = {0x0E9E98, nil},
		object_m2_count = {0x0E9EFE, nil},
		obj2_pointer_list = {0x0E9F00, nil},
		flag_pointer = {0x0E9F08, 0x0EBD68},
		marble_count = {0x0E9FF3, nil},
	},
	speedy_speeds = {.001, .01, .1, .5, 1, 2, 5, 10, 20},
	speedy_index = 7,
	speedy_invert_LR = true,
	rot_speed = 10,
	max_rot_units = 360,
	form_height = 10,
};

--------------------
-- Jim Parameters --
--------------------

local jim = {
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
	max_xz_velocity = 0x2C0, -- Float
	xz_velocity = 0x2C8, -- Float
	y_velocity = 0x2D8, -- Float
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

local gun = {
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

local boss = {
	player_marbles = 0xDFC,
	player_egoboosts = 0xDFD,
	player_missiles = 0xDFE,
	boss_marbles = 0xE48,
	boss_egoboosts = 0xE49,
	boss_missiles = 0xE4A,
};

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

function Game.calculateAngle(angle1, angle2)
	angle1 = 90 * (angle1 + 1);

	if angle2 < 0 then
		return (angle1 * (0 - 1)) - 90;
	else
		return (angle1 - 90);
	end
end

function Game.getXRotation()
	return mainmemory.readfloat(Game.Memory.x_rotation, true);
end

function Game.getYRotation()
	local angle1 = mainmemory.readfloat(Game.Memory.jim_pointer + jim.y_rotation_1, true);
	local angle2 = mainmemory.readfloat(Game.Memory.jim_pointer + jim.y_rotation_2, true);
	return Game.calculateAngle(angle1, angle2);
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

-----------
-- Speed --
-----------

function Game.getVelocity()
	return mainmemory.readfloat(Game.Memory.jim_pointer + jim.xz_velocity, true);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.jim_pointer + jim.y_velocity, true);
end

function Game.getMaxXZVelocity()
	return mainmemory.readfloat(Game.Memory.jim_pointer + jim.max_xz_velocity, true);
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
	Game.checkMapSoftlock();
end

function Game.reloadMapHard()
	mainmemory.writebyte(Game.Memory.current_map, 255);
	Game.reloadMap();
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

function Game.getMarbleCount()
	return mainmemory.readbyte(Game.Memory.marble_count);
end

--------------------
-- FREE ROAM MODE --
--------------------

local YStored; -- TODO: Put these in the Game table
local isYStored = false;

function Game.freeroamEnabled()
	if not isYStored then
		YStored = Game.getYPosition();
		isYStored = true;
	end

	-- detect if L to Levitate
	-- TODO: ScriptHawk should probably expose whether it's d-padding or levitating to game modules actually, hmm...
	local joypad_pressed = joypad.getimmediate();
	local input_pressed = input.get();
	local lbutton_pressed = joypad_pressed[ScriptHawk.lbutton.joypad] or input_pressed[ScriptHawk.lbutton.key];
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
	isYStored = false;
end

------------------
-- CONSOLE MODE --
------------------

local console_mode = 0;
function Game.toggleConsoleMode()
	if console_mode == 0 then
		console_mode = 1;
	elseif console_mode == 1 then
		console_mode = 2;
	else
		console_mode = 0;
	end
end

local twirl_yFreeze = false;
local roll_cap = false;
local walljump_hack = false;

function Game.getConsoleMode()
	if not TASSafe then
		if console_mode == 1 then
			forms.settext(ScriptHawk.UI.form_controls["Console Mode Switch"], "N64 Mode");
			twirl_yFreeze = true;
			roll_cap = false; -- Currently desyncs like crazy
			walljump_hack = true;
		elseif console_mode == 2 then
			forms.settext(ScriptHawk.UI.form_controls["Console Mode Switch"], "PC Mode");
			twirl_yFreeze = false;
			roll_cap = true;
			walljump_hack = false;
		else
			forms.settext(ScriptHawk.UI.form_controls["Console Mode Switch"], "Emulator Mode");
			twirl_yFreeze = false;
			roll_cap = false;
			walljump_hack = false;
		end
	end
end

-- List of edits to make more accurate to N64 or PC release
local twirlStoredY;
local roll_count = 0;
function Game.applyConsoleSettings()
	local animation_value = mainmemory.readbyte(Game.Memory.jim_pointer + jim.animation);
	local animation_frame = mainmemory.read_u16_be(Game.Memory.jim_pointer + jim.animation_timer);
	local movement_value = mainmemory.readbyte(Game.Memory.jim_pointer + jim.movement);

	if twirl_yFreeze then -- NO TWIRL HEIGHT GAIN
		if animation_value == 29 and movement_value == 20 then
			if twirlStoredY == nil then
				if Game.version == 1 then -- US
					twirlStoredY = Game.getYPosition() - 0.0498;
				else -- Game.version == 2 (EU)
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

	if roll_cap then -- NO HYPEREXTENDED ROLL (NOT EVEN ON PC, JUST AN EMU BUG)
		if animation_value == 25 and movement_value == 16 then
			if animation_frame == 21 then
				roll_count = roll_count + 1;
				if roll_count == 8 then
					mainmemory.write_u16_be(Game.Memory.jim_pointer + jim.animation_timer, 23);
					roll_count = 0;
				end
			end
		end
	end

	if walljump_hack then -- WALLJUMP
		if animation_value == 6 and movement_value == 12 then
			mainmemory.writebyte(Game.Memory.jim_pointer + jim.crouch_available, 1);
		end
	end
end

---------------
-- INFINITES --
---------------

function Game.applyInfinites()
	local max_ammo_red_gun = 250;
	local max_ammo_bubble_gun = 50;
	local max_ammo_rockets = 25;
	local max_ammo_flamethrower = 50;
	local max_ammo_bananamyte = 1;
	local max_ammo_laser = 6;
	local max_ammo_pea = 50;
	local max_ammo_egg = 25;
	local max_ammo_fakegun = 0;
	local max_ammo_magnum = 50;
	local max_ammo_disco = 6;
	local max_ammo_knife = 1;
	local max_ammo_leprechaun = 5;
	local max_lives = 3;
	local max_health = 100;
	local max_missiles = 2;
	local max_egoboosts = 2;

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

function completeFile()
	local collectable_counts = { -- Udders, Marbles
		[0] = {1, 0}, -- Brain
		[1] = {0, 0}, -- Memory
		[2] = {3, 100}, -- CDE
		[3] = {7, 100}, -- BTBW
		[4] = {5, 0}, -- Psycrow
		[5] = {0, 0}, -- Happiness
		[6] = {5, 100}, -- LOTF
		[7] = {5, 100}, -- AYHT
		[8] = {5, 0}, -- Roswell
		[9] = {0, 0}, -- Fear
		[10] = {0,0}, -- Mansion Lobby
		[11] = {5, 100}, -- PG1
		[12] = {5, 100}, -- PG2
		[13] = {6, 100}, -- DWU
		[14] = {5, 100}, -- BNotLD
		[15] = {5, 0}, -- PMFAH
		[16] = {0, 0}, -- Fantasy
		[17] = {6, 100}, -- VDV
		[18] = {6, 100}, -- GBE
		[19] = {5, 0}, -- Bob
		[20] = {0, 0}, -- Kim
		[21] = {0, 0}, -- Main Menu
	};

	for i = 0, (#collectable_counts - 1) do
		mainmemory.writebyte(Game.Memory.marble_pointer + i + 0x14, collectable_counts[i][1]);
		mainmemory.writebyte(Game.Memory.marble_pointer + i - 0x02, collectable_counts[i][2]);
	end

	setFlagsByType("Udder");
	setFlag(0x150); -- Have all udders check
end

Game.BossCamLockOffset = {
	[4] = 0x4D8, -- Psycrow
	[8] = 0x4C8, -- Roswell
	[15] = 0x4B0, -- PMFAH
	[19] = 0x4C8, -- Bob
	[20] = 0x4C0, -- Kim
};

function Game.killBoss()
	local BossCamLockOffSet = Game.BossCamLockOffset[mainmemory.readbyte(Game.Memory.current_map)];
	if BossCamLockOffSet ~= nil then
		local camlock_address = dereferencePointer(Game.Memory.flag_pointer) + BossCamLockOffSet;
		local bossdeath_address = dereferencePointer(Game.Memory.jim_pointer + jim.boss_pointer) + 0xE73;
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

local function getObjectCount()
	return math.min(255, mainmemory.readbyte(Game.Memory.object_count) - 1);
end

local function incrementObjectIndex()
	object_index = object_index + 1;
	if object_index > #object_pointers then
		object_index = 1;
	end
end

local function decrementObjectIndex()
	object_index = object_index - 1;
	if object_index <= 0 then
		object_index = #object_pointers;
	end
end

local function switch_grab_script_mode()
	grab_script_mode_index = grab_script_mode_index + 1;
	if grab_script_mode_index > #grab_script_modes then
		grab_script_mode_index = 1;
	end
	grab_script_mode = grab_script_modes[grab_script_mode_index];
end

---------------
-- MODEL ONE --
---------------

local object_properties = {
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
		[0x0] = "Pan Roswell",
		[0x1] = "Mini Roswell",
		[0x2] = "Beaver", -- PG1
		[0x3] = "Billy the Kid",
		[0x4] = "Bob and Number Four",
		[0x5] = "Fatty Roswell",
		[0x6] = "Professor Monkey for a Head",
		[0x7] = "Psycrow",
		[0x8] = "Cow Enemy",
		[0x9] = "Acid Bat",
		[0xA] = "Dynamite Bunny",
		[0xB] = "Cactus",
		[0xC] = "Chick", -- CDE
		[0xD] = "Disco Body",
		[0xE] = "Disco Head",
		[0xF] = "Toilet gun guy", -- VDV
		[0x11] = "Pork Board (Earthworm Kim)",
		[0x12] = "Frog Enemies", -- PG2 Tree Room
		[0x13] = "Pickle",
		[0x14] = "Large Cow", -- Hubs, Boss Worlds
		[0x15] = "Elderly Mobster", -- GBE
		[0x16] = "Hamster", -- CDE
		[0x17] = "Hedgehog", -- CDE/BTBW
		[0x18] = "Vacuum",
		[0x1A] = "Cow", --Main Menu
		[0x1B] = "Robot", -- LOTF
		[0x1C] = "Granny",
		[0x1D] = "Peter the Dog",
		[0x1E] = "Pork Board",
		[0x1F] = "Green Piranha", -- LOTF
		[0x20] = "Orange Piranha", -- DWU
		[0x22] = "Pluckitt",
		[0x23] = "Moosilini",
		[0x24] = "Sheriff",
		[0x25] = "Speaker Enemy",
		[0x26] = "Particle Spawner",
		[0x27] = "Hot Sauce",
		[0x28] = "Agent Crow",
		[0x29] = "Wasps",
		[0x2A] = "Elvis", -- AYHT
	},
};

local function populateObjectM1Pointers()
	object_pointers = {};
	local obj1_pointers_start = dereferencePointer(Game.Memory.obj1_pointer_list);
	if isRDRAM (obj1_pointers_start) then
		for object_no = 0, getObjectCount() do
			local pointer = dereferencePointer(obj1_pointers_start + (object_no * 0xC0));
			if isRDRAM(pointer) then
				table.insert(object_pointers, pointer);
			end
		end
	end
	-- Clamp index
	object_index = math.min(object_index, math.max(1, #object_pointers));
end

function getObjectM1Value(pointer)
	local modelPtr = dereferencePointer(pointer + object_properties.object_model_pointer);
	local objectValue = 0;
	if isRDRAM(modelPtr) then
		objectValue = mainmemory.read_u16_be(modelPtr + 0x1122);
	end
	return objectValue;
end

function getObjectM1NameFromValue(value)
	return object_properties.object_types[value] or toHexString(value);
end

local function getExamineM1Data(pointer)
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
	local objectVal = getObjectM1Value(pointer);

	table.insert(examine_data, { "Address", toHexString(objectPointer) });
	table.insert(examine_data, { "Object Name", getObjectM1NameFromValue(objectVal) });
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

---------------
-- MODEL TWO --
---------------

object_model2_filter = nil;

local object_m2_properties = {
	object_texture_pointer = 0x8;
	object_model_pointer = 0x18;
	object_trait_pointer = 0x1C,
	traits_list = {
		obj_type = 0x0; -- 2 Byte
		opacity = 0xD;
	},
	object_x = 0xA0, -- (8x larger)
	object_y = 0xA4, -- (8x larger)
	object_z = 0xA8, -- (8x larger)
	object_types = {
		[0xB] = "Rocket Launcher/Marble/Pp Can", -- Pickup
		[0x15] = "Breakable Box", -- Psycrow
		[0x32] = "Udder",
		[0x34] = "Bunny Land mine", -- DWU
		[0x3E] = "Text Trigger", -- DWU Gravestones, BNotLD Grannies
		[0x40] = "Vending Machine", -- Rocket Launcher
		[0x41] = "Peter the Dog",
		[0x42] = "Statue", -- DWU
		[0x57] = "Laser", -- AYHT
		[0x5A] = "Snott",
	},
};

local function getObjectM2Count()
	return math.min(65535, mainmemory.read_u16_be(Game.Memory.object_m2_count) - 1);
end

local function populateObjectM2Pointers()
	object_pointers = {};
	local obj2_pointers_start = dereferencePointer(Game.Memory.obj2_pointer_list);
	if isRDRAM (obj2_pointers_start) then
		for object_no = 0, getObjectM2Count() do
			local pointer = dereferencePointer(obj2_pointers_start + (object_no * 0x4));
			m2_value = getObjectM2Value(pointer)
			m2_name = getObjectM2NameFromValue(m2_value)
			if isRDRAM(pointer) then
				if object_model2_filter == nil then
					table.insert(object_pointers, pointer);
				elseif object_model2_filter == m2_name then
					table.insert(object_pointers, pointer);
				end
			end
		end
	end
	-- Clamp index
	object_index = math.min(object_index, math.max(1, #object_pointers));
end

function getObjectM2Value(pointer)
	local traitPtr = dereferencePointer(pointer + object_m2_properties.object_trait_pointer);
	local objectM2Value = 0;
	if traitPtr ~= nil then
		objectM2Value = mainmemory.read_u16_be(traitPtr + object_m2_properties.traits_list.obj_type);
	end
	return objectM2Value;
end

function getObjectM2NameFromValue(value)
	return object_m2_properties.object_types[value] or toHexString(value);
end

local function getExamineM2Data(pointer)
	local examine_data = {};

	if not isRDRAM(pointer) then
		return examine_data;
	end

	local xPos = mainmemory.readfloat(pointer + object_m2_properties.object_x, true) / 8;
	local yPos = mainmemory.readfloat(pointer + object_m2_properties.object_y, true) / 8;
	local zPos = mainmemory.readfloat(pointer + object_m2_properties.object_z, true) / 8;

	local traitPointer = dereferencePointer(pointer + object_m2_properties.object_trait_pointer);
	local texturePointer = dereferencePointer(pointer + object_m2_properties.object_texture_pointer);
	local modelPointer = dereferencePointer(pointer + object_m2_properties.object_model_pointer);
	local hasTrait = traitPointer ~= nil;
	local objectM2Val = getObjectM2Value(pointer)

	table.insert(examine_data, { "Address", toHexString(pointer) });
	table.insert(examine_data, { "Object Name", getObjectM2NameFromValue(objectM2Val) });
	table.insert(examine_data, { "Object Value", toHexString(objectM2Val) });
	table.insert(examine_data, { "Separator", 1 });
	table.insert(examine_data, { "Trait Pointer", toHexString(traitPointer) });
	table.insert(examine_data, { "Texture Pointer", toHexString(texturePointer) });
	table.insert(examine_data, { "Model Pointer", toHexString(modelPointer) });
	table.insert(examine_data, { "Separator", 1 });
	table.insert(examine_data, { "X", xPos });
	table.insert(examine_data, { "Y", yPos });
	table.insert(examine_data, { "Z", zPos });
	table.insert(examine_data, { "Separator", 1 });

	if hasTrait then
		local objAnimTimer = mainmemory.readbyte(traitPointer + object_m2_properties.traits_list.opacity); -- Not entirely sure. Opacity for Snott, Anim Timer for Udder?
		table.insert(examine_data, { "Animation Timer", objAnimTimer });
	end
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

	if string.contains(grab_script_mode, "Model 1") then
		populateObjectM1Pointers();
	elseif string.contains(grab_script_mode, "Model 2") then
		populateObjectM2Pointers();
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
			if grab_script_mode == "Examine (Model 1)" then
				examine_data = getExamineM1Data(object_pointers[object_index]);
			elseif  grab_script_mode == "Examine (Model 2)" then
				examine_data = getExamineM2Data(object_pointers[object_index]);
			end

			pagifyThis(examine_data, 40);

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

		if string.contains(grab_script_mode, "List") then
			row = row + 1;
			pagifyThis(object_pointers, 40);
			for i = page_finish, page_start + 1, -1 do
				local color = nil;
				if object_index == i then
					color = colors.yellow;
				end

				if string.contains(grab_script_mode, "Model 1") then
					local objectVal = getObjectM1Value(object_pointers[i] or 0);
					gui.text(gui_x, gui_y + height * row, i..": "..toHexString(object_pointers[i] or 0, 6).." ("..getObjectM1NameFromValue(objectVal)..")", color, 'bottomright');
				elseif string.contains(grab_script_mode, "Model 2") then
					local objectVal = getObjectM2Value(object_pointers[i] or 0);
					gui.text(gui_x, gui_y + height * row, i..": "..toHexString(object_pointers[i] or 0, 6).." ("..getObjectM2NameFromValue(objectVal)..")", color, 'bottomright');
				end
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
		if string.contains(grab_script_mode, "Model 1") then
			desiredX = mainmemory.readfloat(selectedObject + object_properties.object_x, true);
			desiredY = mainmemory.readfloat(selectedObject + object_properties.object_y, true);
			desiredZ = mainmemory.readfloat(selectedObject + object_properties.object_z, true);
		elseif string.contains(grab_script_mode, "Model 2") then
			desiredX = mainmemory.readfloat(selectedObject + object_m2_properties.object_x, true) / 8;
			desiredY = mainmemory.readfloat(selectedObject + object_m2_properties.object_y, true) / 8;
			desiredZ = mainmemory.readfloat(selectedObject + object_m2_properties.object_z, true) / 8;
		end
	end

	-- Update player position
	if type(desiredX) == "number" and type(desiredY) == "number" and type(desiredZ) == "number" then
		Game.setPosition(desiredX, desiredY, desiredZ);
	end
end

----------------------------
-- Flag & Save File Stuff --
----------------------------

local flag_block_size = 0x438; -- D34 max
local flag_Array = {};

local flagBlock = {
	[0x018] = {name = "DWU: Stone Door Open", type = "Physical"},
	[0x040] = {name = "BTBW: Crow in final position", type = "Physical"},
	[0x070] = {name = "LOTF: Talked to King Gherkin", type = "Physical"},
	[0x078] = {name = "PG1: First Wall Cleared", type = "Physical"},
	[0x080] = {name = "PG1: Chicken Gauntlet Defeated", type = "Physical"},
	[0x098] = {name = "CDE: Barn Door Open", type = "Physical"},
	[0x0A8] = {name = "AYHT: Elevator Lasers Lowered", type = "Physical"},
	[0x130] = {name = "Brain: CDE Open", type = "Physical"},
	[0x138] = {name = "Brain: Happiness Hub Snott Spawned", type = "Physical"},
	[0x150] = {name = "Have all udders", type = "Check"},
	[0x160] = {name = "Brain: Snott FTT", type = "FTT"},
	[0x1B0] = {name = "Brain: Earthworm Kim Open", type = "Physical"},
	[0x1C0] = {name = "DWU: Rabbit Hole Udder", type = "Udder"},
	[0x1C8] = {name = "DWU: Gravestones Udder", type = "Udder"},
	[0x1D0] = {name = "DWU: Medallion Udder", type = "Udder"},
	[0x1D8] = {name = "DWU: Quicksand Udder", type = "Udder"},
	[0x1E0] = {name = "DWU: Statues Udder", type = "Udder"},
	[0x1F0] = {name = "DWU: Blue Balloon Udder", type = "Udder"},
	[0x1F8] = {name = "PG1: Beaver Head Udder", type = "Udder"},
	[0x200] = {name = "PG1: Painting Room Udder", type = "Udder"},
	[0x208] = {name = "PG1: Furniture Room Udder", type = "Udder"},
	[0x210] = {name = "PG1: Vacuum Udder", type = "Udder"},
	[0x218] = {name = "PG1: Chicken Gauntlet Udder", type = "Udder"},
	[0x220] = {name = "BNotLD: Boom Box Udder", type = "Udder"},
	[0x228] = {name = "BNotLD: Zombie Heads Udder", type = "Udder"},
	[0x230] = {name = "BNotLD: Manhole Udder", type = "Udder"},
	[0x238] = {name = "BNotLD: Speaker Towers Udder", type = "Udder"},
	[0x240] = {name = "BNotLD: Sewers Udder", type = "Udder"},
	[0x248] = {name = "GBE: Ice Block Udder", type = "Udder"},
	[0x250] = {name = "GBE: Bank Udder", type = "Udder"},
	[0x258] = {name = "GBE: Sheriff Udder", type = "Udder"},
	[0x260] = {name = "GBE: Bottle Udder", type = "Udder"},
	[0x268] = {name = "GBE: Granny Herding Udder", type = "Udder"},
	[0x270] = {name = "GBE: Bingo Udder", type = "Udder"},
	[0x278] = {name = "BTBW: Bootcamp Udder", type = "Udder"},
	[0x280] = {name = "BTBW: Camera Udder", type = "Udder"},
	[0x288] = {name = "BTBW: Barn Door Udder", type = "Udder"},
	[0x290] = {name = "BTBW: Crow Udder", type = "Udder"},
	[0x298] = {name = "BTBW: Kill Pluckitt Udder", type = "Udder"},
	-- 0x2A0 - Udder
	-- 0x2A8 - Udder
	[0x2B0] = {name = "BTBW: Blue Balloon Udder", type = "Udder"},
	-- 0x2B8
	[0x2C0] = {name = "CDE: Fridges Udder", type = "Udder"},
	[0x2C8] = {name = "CDE: Underpants Udder", type = "Udder"},
	[0x2D0] = {name = "CDE: Bomb Room Udder", type = "Udder"},
	-- 0x2D8
	[0x2E0] = {name = "AYHT: Elevator Udder", type = "Udder"},
	[0x2E8] = {name = "AYHT: Bean Room Udder", type = "Udder"},
	[0x2F0] = {name = "AYHT: Pan Room Udder", type = "Udder"},
	[0x2F8] = {name = "AYHT: Elvis Udder", type = "Udder"},
	[0x300] = {name = "VDV: Hidden Udder", type = "Udder"},
	[0x308] = {name = "VDV: Bean Room Udder", type = "Udder"},
	[0x310] = {name = "VDV: Ice Cream Udder", type = "Udder"},
	[0x318] = {name = "VDV: Kill Grannies Udder", type = "Udder"},
	[0x320] = {name = "VDV: Granny Herding Udder", type = "Udder"},
	[0x328] = {name = "BTBW: Swamp Udder", type = "Udder"},
	[0x330] = {name = "PG2: Vacuum Udder", type = "Udder"},
	[0x338] = {name = "PG2: Chicken Udder", type = "Udder"},
	[0x340] = {name = "PG2: Painting Room Udder", type = "Udder"},
	[0x348] = {name = "PG2: Library Udder", type = "Udder"},
	[0x350] = {name = "PG2: Blue Balloon Udder", type = "Udder"},
	[0x358] = {name = "LOTF: Blue Balloon Udder", type = "Udder"},
	[0x360] = {name = "LOTF: Central Tree Udder", type = "Udder"},
	[0x368] = {name = "LOTF: Tall Platform Udder", type = "Udder"},
	[0x370] = {name = "LOTF: King Gherkin Udder", type = "Udder"},
	[0x378] = {name = "LOTF: Potatoes Udder", type = "Udder"},
	-- 0x380
	[0x388] = {name = "AYHT: Blue Balloon Udder", type = "Udder"},
	[0x390] = {name = "Brain: Peter Udder", type = "Udder"},
	[0x398] = {name = "Psycrow: Udder (1)", type = "Udder"},
	[0x3A0] = {name = "Psycrow: Udder (2)", type = "Udder"},
	[0x3A8] = {name = "Psycrow: Udder (3)", type = "Udder"},
	[0x3B0] = {name = "Psycrow: Udder (4)", type = "Udder"},
	[0x3B8] = {name = "Psycrow: Udder (5)", type = "Udder"},
	[0x3C0] = {name = "Bob and No. 4: Udder (1)", type = "Udder"},
	[0x3C8] = {name = "Bob and No. 4: Udder (2)", type = "Udder"},
	[0x3D0] = {name = "Bob and No. 4: Udder (3)", type = "Udder"},
	[0x3D8] = {name = "Bob and No. 4: Udder (4)", type = "Udder"},
	[0x3E0] = {name = "Bob and No. 4: Udder (5)", type = "Udder"},
	[0x3E8] = {name = "PMFAH: Udder (1)", type = "Udder"},
	[0x3F0] = {name = "PMFAH: Udder (2)", type = "Udder"},
	[0x3F8] = {name = "PMFAH: Udder (3)", type = "Udder"},
	[0x400] = {name = "PMFAH: Udder (4)", type = "Udder"},
	[0x408] = {name = "PMFAH: Udder (5)", type = "Udder"},
	[0x410] = {name = "Fatty Roswell: Udder (1)", type = "Udder"},
	[0x418] = {name = "Fatty Roswell: Udder (2)", type = "Udder"},
	[0x420] = {name = "Fatty Roswell: Udder (3)", type = "Udder"},
	[0x428] = {name = "Fatty Roswell: Udder (4)", type = "Udder"},
	[0x430] = {name = "Fatty Roswell: Udder (5)", type = "Udder"},
	[0x438] = {name = "VDV: Blue Balloon Udder", type = "Udder"},
};

saveFile_start = 0x0C6200; -- Not sure on this
saveFile_size = 0xD0; -- Not sure on this

local saveFile_Block = {
	[0xC] = {name = 'Map: The Brain in Menu', type = 'Menu'},
	[0xD] = {name = 'Map: Memory Hub in Menu', type = 'Menu'},
	[0xE] = {name = 'Map: CDE in Menu', type = 'Menu'},
	[0xF] = {name = 'Map: BTBW in Menu', type = 'Menu'},
	[0x10] = {name = 'Map: Psycrow in Menu', type = 'Menu'},
	[0x11] = {name = 'Map: Happiness Hub in Menu', type = 'Menu'},
	[0x12] = {name = 'Map: LOTF in Menu', type = 'Menu'},
	[0x13] = {name = 'Map: AYHT in Menu', type = 'Menu'},
	[0x14] = {name = 'Map: Fatty Roswell in Menu', type = 'Menu'},
	[0x15] = {name = 'Map: Fear Hub in Menu', type = 'Menu'},
	[0x16] = {name = 'Map: Mansion Lobby in Menu', type = 'Menu'},
	[0x17] = {name = 'Map: PG1 in Menu', type = 'Menu'},
	[0x18] = {name = 'Map: PG2 in Menu', type = 'Menu'},
	[0x19] = {name = 'Map: DWU in Menu', type = 'Menu'},
	[0x1A] = {name = 'Map: BNotLD in Menu', type = 'Menu'},
	[0x1B] = {name = 'Map: PMFAH in Menu', type = 'Menu'},
	[0x1C] = {name = 'Map: Fantasy Hub in Menu', type = 'Menu'},
	[0x1D] = {name = 'Map: VDV in Menu', type = 'Menu'},
	[0x1E] = {name = 'Map: GBE in Menu', type = 'Menu'},
	[0x1F] = {name = 'Map: Bob in Menu', type = 'Menu'},
	[0x20] = {name = 'Map: Kim in Menu', type = 'Menu'},
	[0x21] = {name = 'Map: Main Menu in Menu', type = 'Menu'},
	-- 0x22 set when collecting peter udder
	[0x25] = {name = 'DWU: Stone Door Open', type = 'Physical', linkedFlag = 0x18},
	[0x2A] = {name = 'BTBW: Crow in final position', type = 'Physical', linkedFlag = 0x40},
	[0x30] = {name = 'LOTF: Talked to King Gherkin', type = 'Physical', linkedFlag = 0x70},
	[0x31] = {name = 'PG1: First Wall Cleared', type = 'Physical', linkedFlag = 0x78},
	[0x32] = {name = 'PG1: Chicken Gauntlet Defeated', type = 'Physical', linkedFlag = 0x80},
	[0x35] = {name = 'CDE: Barn Door Open', type = 'Physical', linkedFlag = 0x98},
	[0x37] = {name = 'AYHT: Elevator Lasers Lowered', type = 'Physical', linkedFlag = 0xA8},
	[0x48] = {name = 'Brain: CDE Open', type = 'Physical', linkedFlag = 0x130},
	[0x49] = {name = 'Brain: Happiness Hub Snott Spawned', type = 'Physical', linkedFlag = 0x138},
	--[0x4A] = {name = 'Brain: Entered Memory Hub', type = 'Physical'},
	--[0x4D] = {name = 'Brain: Entered Happiness Hub', type = 'Physical'},
	[0x4E] = {name = 'Brain: Snott FTT', type = 'FTT', linkedFlag = 0x160},
	[0x58] = {name = 'Brain: Earthworm Kim Open', type = 'Physical', linkedFlag = 0x1B0},
	[0x5A] = {name = 'DWU: Rabbit Hole Udder', type = 'Udder', linkedFlag = 0x1C0},
	[0x5B] = {name = 'DWU: Gravestones Udder', type = 'Udder', linkedFlag = 0x1C8},
	[0x5C] = {name = 'DWU: Medallion Udder', type = 'Udder', linkedFlag = 0x1D0},
	[0x5D] = {name = 'DWU: Quicksand Udder', type = 'Udder', linkedFlag = 0x1D8},
	[0x5E] = {name = 'DWU: Statues Udder', type = 'Udder', linkedFlag = 0x1E0},
	[0x60] = {name = 'DWU: Blue Balloon Udder', type = 'Udder', linkedFlag = 0x1F0},
	[0x61] = {name = 'PG1: Beaver Head Udder', type = 'Udder', linkedFlag = 0x1F8},
	[0x62] = {name = 'PG1: Painting Room Udder', type = 'Udder', linkedFlag = 0x200},
	[0x63] = {name = 'PG1: Furniture Room Udder', type = 'Udder', linkedFlag = 0x208},
	[0x64] = {name = 'PG1: Vacuum Udder', type = 'Udder', linkedFlag = 0x210},
	[0x65] = {name = 'PG1: Chicken Gauntlet Udder', type = 'Udder', linkedFlag = 0x218},
	[0x66] = {name = 'BNotLD: Boom Box Udder', type = 'Udder', linkedFlag = 0x220},
	[0x67] = {name = 'BNotLD: Zombie Heads Udder', type = 'Udder', linkedFlag = 0x228},
	[0x68] = {name = 'BNotLD: Manhole Udder', type = 'Udder', linkedFlag = 0x230},
	[0x69] = {name = 'BNotLD: Speaker Towers Udder', type = 'Udder', linkedFlag = 0x238},
	[0x6A] = {name = 'BNotLD: Sewers Udder', type = 'Udder', linkedFlag = 0x240},
	[0x6B] = {name = 'GBE: Ice Block Udder', type = 'Udder', linkedFlag = 0x248},
	[0x6C] = {name = 'GBE: Bank Udder', type = 'Udder', linkedFlag = 0x250},
	[0x6D] = {name = 'GBE: Sheriff Udder', type = 'Udder', linkedFlag = 0x258},
	[0x6E] = {name = 'GBE: Bottle Udder', type = 'Udder', linkedFlag = 0x260},
	[0x6F] = {name = 'GBE: Granny Herding Udder', type = 'Udder', linkedFlag = 0x268},
	[0x70] = {name = 'GBE: Bingo Udder', type = 'Udder', linkedFlag = 0x270},
	[0x71] = {name = 'BTBW: Bootcamp Udder', type = 'Udder', linkedFlag = 0x278},
	[0x72] = {name = 'BTBW: Camera Udder', type = 'Udder', linkedFlag = 0x280},
	[0x73] = {name = 'BTBW: Barn Door Udder', type = 'Udder', linkedFlag = 0x288},
	[0x74] = {name = 'BTBW: Crow Udder', type = 'Udder', linkedFlag = 0x290},
	[0x75] = {name = 'BTBW: Kill Pluckitt Udder', type = 'Udder', linkedFlag = 0x298},
	[0x78] = {name = 'BTBW: Blue Balloon Udder', type = 'Udder', linkedFlag = 0x2B0},
	[0x7A] = {name = 'CDE: Fridges Udder', type = 'Udder', linkedFlag = 0x2C0},
	[0x7B] = {name = 'CDE: Underpants Udder', type = 'Udder', linkedFlag = 0x2C8},
	[0x7C] = {name = 'CDE: Bomb Room Udder', type = 'Udder', linkedFlag = 0x2D0},
	[0x7E] = {name = 'AYHT: Elevator Udder', type = 'Udder', linkedFlag = 0x2E0},
	[0x7F] = {name = 'AYHT: Bean Room Udder', type = 'Udder', linkedFlag = 0x2E8},
	[0x80] = {name = 'AYHT: Pan Room Udder', type = 'Udder', linkedFlag = 0x2F0},
	[0x81] = {name = 'AYHT: Elvis Udder', type = 'Udder', linkedFlag = 0x2F8},
	[0x82] = {name = 'VDV: Hidden Udder', type = 'Udder', linkedFlag = 0x300},
	[0x83] = {name = 'VDV: Bean Room Udder', type = 'Udder', linkedFlag = 0x308},
	[0x84] = {name = 'VDV: Ice Cream Udder', type = 'Udder', linkedFlag = 0x310},
	[0x85] = {name = 'VDV: Kill Grannies Udder', type = 'Udder', linkedFlag = 0x318},
	[0x86] = {name = 'VDV: Granny Herding Udder', type = 'Udder', linkedFlag = 0x320},
	[0x87] = {name = 'BTBW: Swamp Udder', type = 'Udder', linkedFlag = 0x328},
	[0x88] = {name = 'PG2: Vacuum Udder', type = 'Udder', linkedFlag = 0x330},
	[0x89] = {name = 'PG2: Chicken Udder', type = 'Udder', linkedFlag = 0x338},
	[0x8A] = {name = 'PG2: Painting Room Udder', type = 'Udder', linkedFlag = 0x340},
	[0x8B] = {name = 'PG2: Library Udder', type = 'Udder', linkedFlag = 0x348},
	[0x8C] = {name = 'PG2: Blue Balloon Udder', type = 'Udder', linkedFlag = 0x350},
	[0x8D] = {name = 'LOTF: Blue Balloon Udder', type = 'Udder', linkedFlag = 0x358},
	[0x8E] = {name = 'LOTF: Central Tree Udder', type = 'Udder', linkedFlag = 0x360},
	[0x8F] = {name = 'LOTF: Tall Platform Udder', type = 'Udder', linkedFlag = 0x368},
	[0x90] = {name = 'LOTF: King Gherkin Udder', type = 'Udder', linkedFlag = 0x370},
	[0x91] = {name = 'LOTF: Potatoes Udder', type = 'Udder', linkedFlag = 0x378},
	[0x93] = {name = 'AYHT: Blue Balloon Udder', type = 'Udder', linkedFlag = 0x388},
	[0x94] = {name = 'Brain: Peter Udder', type = 'Udder', linkedFlag = 0x390},
	[0x95] = {name = 'Psycrow: Udder (1)', type = 'Udder', linkedFlag = 0x398},
	[0x96] = {name = 'Psycrow: Udder (2)', type = 'Udder', linkedFlag = 0x3A0},
	[0x97] = {name = 'Psycrow: Udder (3)', type = 'Udder', linkedFlag = 0x3A8},
	[0x98] = {name = 'Psycrow: Udder (4)', type = 'Udder', linkedFlag = 0x3B0},
	[0x99] = {name = 'Psycrow: Udder (5)', type = 'Udder', linkedFlag = 0x3B8},
	[0x9A] = {name = 'Bob and No. 4: Udder (1)', type = 'Udder', linkedFlag = 0x3C0},
	[0x9B] = {name = 'Bob and No. 4: Udder (2)', type = 'Udder', linkedFlag = 0x3C8},
	[0x9C] = {name = 'Bob and No. 4: Udder (3)', type = 'Udder', linkedFlag = 0x3D0},
	[0x9D] = {name = 'Bob and No. 4: Udder (4)', type = 'Udder', linkedFlag = 0x3D8},
	[0x9E] = {name = 'Bob and No. 4: Udder (5)', type = 'Udder', linkedFlag = 0x3E0},
	[0x9F] = {name = 'PMFAH: Udder (1)', type = 'Udder', linkedFlag = 0x3E8},
	[0xA0] = {name = 'PMFAH: Udder (2)', type = 'Udder', linkedFlag = 0x3F0},
	[0xA1] = {name = 'PMFAH: Udder (3)', type = 'Udder', linkedFlag = 0x3F8},
	[0xA2] = {name = 'PMFAH: Udder (4)', type = 'Udder', linkedFlag = 0x400},
	[0xA3] = {name = 'PMFAH: Udder (5)', type = 'Udder', linkedFlag = 0x408},
	[0xA4] = {name = 'Fatty Roswell: Udder (1)', type = 'Udder', linkedFlag = 0x410},
	[0xA5] = {name = 'Fatty Roswell: Udder (2)', type = 'Udder', linkedFlag = 0x418},
	[0xA6] = {name = 'Fatty Roswell: Udder (3)', type = 'Udder', linkedFlag = 0x420},
	[0xA7] = {name = 'Fatty Roswell: Udder (4)', type = 'Udder', linkedFlag = 0x428},
	[0xA8] = {name = 'Fatty Roswell: Udder (5)', type = 'Udder', linkedFlag = 0x430},
	[0xA9] = {name = 'VDV: Blue Balloon Udder', type = 'Udder', linkedFlag = 0x438},
	[0xAB] = {name = 'Brain: Memory Bagpipes Played', type = 'Physical'},
	[0xAF] = {name = 'Brain: Happiness Bagpipes Played', type = 'Physical'},
	[0xB3] = {name = 'Brain: Fear Bagpipes Played', type = 'Physical'},
	[0xBA] = {name = 'Brain: Fantasy Bagpipes Played', type = 'Physical'},
	-- Have all udders is not on this list?
	-- 0x1A3 set on file start
};

function checkSaveFlagLinkage()
	for i = 1, saveFile_size do
		if saveFile_Block[i] ~= nil then -- Save File Data discovered
			flag_linked = false;
			for j = 1, flag_block_size do
				if flagBlock[j] ~= nil then -- Flag discovered
					if saveFile_Block[i].name == flagBlock[j].name then
						print("["..toHexString(i).."] = {name = '"..saveFile_Block[i].name.."', type = '"..saveFile_Block[i].type.."', linkedFlag = "..toHexString(j).."},");
						flag_linked = true;
					end
				end
			end
			if not flag_linked then
				print("["..toHexString(i).."] = {name = '"..saveFile_Block[i].name.."', type = '"..saveFile_Block[i].type.."'},");
			end
		end
	end
end

function getFlagTypeCount(flagType)
	local flag_type_count = 0
	for i = 1, flag_block_size do
		if flagBlock[i] ~= nil then -- is a documented flag
			if flagBlock[i].type == flagType then
				flag_type_count = flag_type_count + 1;
			end
		end
	end
	return flag_type_count;
end

function getFlagsKnown()
	local flag_count = 0
	for i = 1, flag_block_size do
		if flagBlock[i] ~= nil then -- is a documented flag
			flag_count = flag_count + 1;
		end
	end
	return flag_count;
end

function getFlagsTotal()
	return flag_block_size / 8;
end

function getFlagArray()
	local flag_start = dereferencePointer(Game.Memory.flag_pointer);
	if isRDRAM(flag_start) then
		for i = 1, flag_block_size do
			flag_Array[i] = mainmemory.readbyte(flag_start + i);
		end
	end
end

function clearFlagCache()
	flagCache = {};
	new_FlagCache = {};
	dprint("Populated flag cache");
	print_deferred();
end

function clearSaveFileCache()
	saveFileCache = {};
	new_saveFileCache = {};
	--dprint("Populated additional flag cache");
	--print_deferred();
end

clearFlagCache();
clearSaveFileCache();

function populateFlagArray()
	local flag_start = dereferencePointer(Game.Memory.flag_pointer);
	if isRDRAM(flag_start) then
		local flag_counts = (flag_block_size / 8);
		for i = 1, flag_counts do
			local currentFlagState = mainmemory.readbyte(flag_start + (8 * i));
			flagCache[i] = currentFlagState;
		end
	end
end

function newFlagCache()
	local flag_start = dereferencePointer(Game.Memory.flag_pointer);
	if isRDRAM(flag_start) then
		local flag_counts = (flag_block_size / 8);
		for i = 1, flag_counts do
			local currentFlagState = mainmemory.readbyte(flag_start + (8 * i));
			new_FlagCache[i] = currentFlagState;
		end
	end
end

function populateSaveFileArray()
	for i = 1, saveFile_size do
		local currentSaveFileState = mainmemory.readbyte(saveFile_start + i);
		saveFileCache[i] = currentSaveFileState;
	end
end

function newSaveFileArray()
	for i = 1, saveFile_size do
		local currentSaveFileState = mainmemory.readbyte(saveFile_start + i);
		new_saveFileCache[i] = currentSaveFileState;
	end
end

function checkFlagArray()
	local flag_counts = (flag_block_size / 8);
	if #flagCache > 0 then
		for i = 1, flag_counts do
			local flag_difference = new_FlagCache[i] - flagCache[i];
			if flag_difference > 0 then
				local flag_name = "Unknown ("..toHexString(8 * i)..")";
				local currentFrame = emu.framecount();
				if flagBlock[8 * i] ~= nil then
					flag_name = flagBlock[8 * i].name;
				end
				print("'"..flag_name.."' has been SET on frame "..currentFrame);	
			elseif flag_difference < 0 then
				local flag_name = "Unknown ("..toHexString(8 * i)..")";
				local currentFrame = emu.framecount();
				if flagBlock[8 * i] ~= nil then
					flag_name = flagBlock[8 * i].name;
				end
				print("'"..flag_name.."' has been CLEARED on frame "..currentFrame);
			end
		end
	end
end

function checkSaveFileArray()
	if #saveFileCache > 0 then
		for i = 1, saveFile_size do
			local saveFile_difference = new_saveFileCache[i] - saveFileCache[i];
			if saveFile_difference > 0 then
				local saveFile_name = "Unknown ("..toHexString(i)..")";
				local currentFrame = emu.framecount();
				if saveFile_Block[i] ~= nil then
					saveFile_name = saveFile_Block[i].name;
				end
				print("'"..saveFile_name.."' has been SAVED on frame "..currentFrame);	
			elseif saveFile_difference < 0 then
				local saveFile_name = "Unknown ("..toHexString(i)..")";
				local currentFrame = emu.framecount();
				if saveFile_Block[i] ~= nil then
					saveFile_name = saveFile_Block[i].name;
				end
				print("'"..saveFile_name.."' has been UNSAVED on frame "..currentFrame);
			end
		end
	end
end

-- FLAGS

function checkFlag(offset)
	local flag_start = dereferencePointer(Game.Memory.flag_pointer);
	if isRDRAM(flag_start) then
		local flag_state = mainmemory.readbyte(flag_start + offset);
		if flag_state == 1 then
			print("Flag: '"..flagBlock[offset].name.."' is SET");
		else
			print("Flag: '"..flagBlock[offset].name.."' is NOT SET");
		end
	end
end

function setFlag(offset)
	local flag_start = dereferencePointer(Game.Memory.flag_pointer);
	if isRDRAM(flag_start) then
		mainmemory.writebyte(flag_start + offset, 1);
		local flag_name = "Unknown ("..toHexString(offset)..")";
		if flagBlock[offset] ~= nil then
			flag_name = flagBlock[offset].name;
		end
		print("Set flag '"..flag_name.."'");
	end
end

function clearFlag(offset)
	local flag_start = dereferencePointer(Game.Memory.flag_pointer);
	if isRDRAM(flag_start) then
		mainmemory.writebyte(flag_start + offset, 0);
		local flag_name = "Unknown ("..toHexString(offset)..")";
		if flagBlock[offset] ~= nil then
			flag_name = flagBlock[offset].name;
		end
		print("Cleared flag '"..flag_name.."'");
	end
end

function setFlagByName(name_string)
	for i = 1, flag_block_size do
		if flagBlock[i] ~= nil then
			if flagBlock[i].name == name_string then
				setFlag(i);
			end
		end
	end
end

function clearFlagByName(name_string)
	for i = 1, flag_block_size do
		if flagBlock[i] ~= nil then
			if flagBlock[i].name == name_string then
				clearFlag(i);
			end
		end
	end
end

function checkFlagByName(name_string)
	for i = 1, flag_block_size do
		if flagBlock[i] ~= nil then
			if flagBlock[i].name == name_string then
				checkFlag(i);
			end
		end
	end
end

function setFlagsByType(type_string)
	for i = 1, flag_block_size do
		if flagBlock[i] ~= nil then
			if flagBlock[i].type == type_string then
				setFlag(i);
			end
		end
	end
end

function clearFlagsByType(type_string)
	for i = 1, flag_block_size do
		if flagBlock[i] ~= nil then
			if flagBlock[i].type == type_string then
				checkFlag(i);
			end
		end
	end
end

-- SAVE FILE

function getSaveFileTypeCount(saveFileType)
	local saveFile_type_count = 0
	for i = 1, saveFile_size do
		if saveFile_Block[i] ~= nil then -- is a documented save
			if saveFile_Block[i].type == saveFileType then
				saveFile_type_count = saveFile_type_count + 1;
			end
		end
	end
	return saveFile_type_count;
end

function getSaveFileKnown()
	local saveFile_count = 0
	for i = 1, saveFile_size do
		if saveFile_Block[i] ~= nil then -- is a documented save
			saveFile_count = saveFile_count + 1;
		end
	end
	return saveFile_count;
end

function getSaveFileDataTotal()
	return saveFile_size;
end

function checkSaveFile(offset)
	local saveFile_state = mainmemory.readbyte(saveFile_start + offset);
	if saveFile_state == 1 then
		print("Save: '"..saveFile_Block[offset].name.."' is SET");
	else
		print("Save: '"..saveFile_Block[offset].name.."' is NOT SET");
	end
end

function setSaveFile(offset)
	mainmemory.writebyte(saveFile_start + offset, 1);
	if saveFile_Block[offset] ~= nil then
		if saveFile_Block[offset].linkedFlag ~= nil then
			setFlag(saveFile_Block[offset].linkedFlag);
		end
	end
	local saveFile_name = "Unknown ("..toHexString(offset)..")";
	if saveFile_Block[offset] ~= nil then
		saveFile_name = saveFile_Block[offset].name;
	end
	print("Set save file data '"..saveFile_name.."'");
end

function clearSaveFile(offset)
	mainmemory.writebyte(saveFile_start + offset, 0);
	if saveFile_Block[offset] ~= nil then
		if saveFile_Block[offset].linkedFlag ~= nil then
			clearFlag(saveFile_Block[offset].linkedFlag);
		end
	end
	local saveFile_name = "Unknown ("..toHexString(offset)..")";
	if saveFile_Block[offset] ~= nil then
		saveFile_name = saveFile_Block[offset].name;
	end
	print("Cleared save file data '"..saveFile_name.."'");
end

function setSaveFileByName(name_string)
	for i = 1, saveFile_size do
		if saveFile_Block[i] ~= nil then
			if saveFile_Block[i].name == name_string then
				setSaveFile(i);
			end
		end
	end
end

function clearSaveFileByName(name_string)
	for i = 1, saveFile_size do
		if saveFile_Block[i] ~= nil then
			if saveFile_Block[i].name == name_string then
				clearSaveFile(i);
			end
		end
	end
end

function checkSaveFileByName(name_string)
	for i = 1, saveFile_size do
		if saveFile_Block[i] ~= nil then
			if saveFile_Block[i].name == name_string then
				checkSaveFile(i);
			end
		end
	end
end

function setSaveFilesByType(type_string)
	for i = 1, saveFile_size do
		if saveFile_Block[i] ~= nil then
			if saveFile_Block[i].type == type_string then
				setSaveFile(i);
			end
		end
	end
end

function clearSaveFilesByType(type_string)
	for i = 1, saveFile_size do
		if saveFile_Block[i] ~= nil then
			if saveFile_Block[i].type == type_string then
				checkSaveFile(i);
			end
		end
	end
end

local function formatOutputString(caption, value, max)
	return caption..value.."/"..max.." or "..round(value / max * 100, 2).."%";
end

function flagStats()
	local udders_known = getFlagTypeCount("Udder");
	local udders_total = 74;
	local flags_known = getFlagsKnown();
	local flags_total = getFlagsTotal();

	dprint("Flag Block size: "..toHexString(flag_block_size));
	dprint(formatOutputString("Flags known: ", flags_known, flags_total));
	dprint(formatOutputString("Udders: ", udders_known, udders_total));
	dprint("");
	print_deferred();
end

function saveFileStats()
	local udders_known = getSaveFileTypeCount("Udder");
	local udders_total = 74;
	local saveFileData_known = getSaveFileKnown();
	local saveFileData_total = getSaveFileDataTotal();

	dprint("Save File Block size: "..toHexString(saveFile_size));
	dprint(formatOutputString("Save File data known: ", saveFileData_known, saveFileData_total));
	dprint(formatOutputString("Udders: ", udders_known, udders_total));
	dprint("");
	print_deferred();
end

function getFlagNameArray()
	local flagNameBlock = {}
	local j = 0;
	for i = 1, flag_block_size do
		if flagBlock[i] ~= nil then
			j = j + 1;
			flagNameBlock[j] = flagBlock[i].name;
		end
	end
	return flagNameBlock;
end

function getSaveFileNameArray()
	local saveFileNameBlock = {}
	local j = 0;
	for i = 1, saveFile_size do
		if saveFile_Block[i] ~= nil then
			j = j + 1;
			saveFileNameBlock[j] = saveFile_Block[i].name;
		end
	end
	return saveFileNameBlock;
end

local function flagSetButtonHandler()
	setFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagClearButtonHandler()
	clearFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagCheckButtonHandler()
	checkFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function saveFileSetButtonHandler()
	setSaveFileByName(forms.getproperty(ScriptHawk.UI.form_controls["Save File Dropdown"], "SelectedItem"));
end

local function saveFileClearButtonHandler()
	clearSaveFileByName(forms.getproperty(ScriptHawk.UI.form_controls["Save File Dropdown"], "SelectedItem"));
end

local function saveFileCheckButtonHandler()
	checkSaveFileByName(forms.getproperty(ScriptHawk.UI.form_controls["Save File Dropdown"], "SelectedItem"));
end

ScriptHawk.bindKeyRealtime("N", decrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("M", incrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("Z", zipToSelectedObject, true);
ScriptHawk.bindKeyRealtime("H", decrementPage, true);
ScriptHawk.bindKeyRealtime("J", incrementPage, true);
ScriptHawk.bindKeyRealtime("C", switch_grab_script_mode, true);

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.button(5, 4, {4, 10}, nil, "Reload Map (Soft)", "Reload Map", Game.reloadMap);
		ScriptHawk.UI.button(10, 0, {4, 10}, nil, "Reload Map (Hard)", "Hard Reload", Game.reloadMapHard);
		ScriptHawk.UI.button(10, 1, {4, 10}, nil, "Kill Boss", "Kill Boss", Game.killBoss);
		ScriptHawk.UI.checkbox(5, 5, "OoB Timer Checkbox", "OoB Timer Off");
		ScriptHawk.UI.checkbox(5, 6, "Free Roam Mode", "Free Roam Mode");
		ScriptHawk.UI.button(10, 4, {4, 10}, nil, "Console Mode Switch", "Emulator Mode", Game.toggleConsoleMode);

		--ScriptHawk.UI.button(10, 7, {46}, nil, "Set Flag Button", "Set", flagSetButtonHandler);
		--ScriptHawk.UI.button(12, 7, {46}, nil, "Check Flag Button", "Check", flagCheckButtonHandler);
		--ScriptHawk.UI.button(14, 7, {46}, nil, "Clear Flag Button", "Clear", flagClearButtonHandler);
		
		ScriptHawk.UI.button(10, 7, {46}, nil, "Set Save File Button", "Set", saveFileSetButtonHandler);
		ScriptHawk.UI.button(12, 7, {46}, nil, "Check Save File Button", "Check", saveFileCheckButtonHandler);
		ScriptHawk.UI.button(14, 7, {46}, nil, "Clear Save File Button", "Clear", saveFileClearButtonHandler);
	else
		-- Use a bigger check flags button if the others are hidden by TASSafe
		--ScriptHawk.UI.button(10, 7, {4, 10}, nil, "Check Flag Button", "Check Flag", flagCheckButtonHandler);
		ScriptHawk.UI.button(10, 7, {4, 10}, nil, "Check Save File Button", "Check Save File", saveFileCheckButtonHandler);
	end

	--ScriptHawk.UI.form_controls["Flag Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, getFlagNameArray(), ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Save File Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, getSaveFileNameArray(), ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI.checkbox(10, 6, "realtime_flags", "Realtime Flags", true);
	flagStats();
	saveFileStats();
end

function Game.drawUI()
	drawGrabScriptUI();
end

function Game.realTime()
--	if ScriptHawk.UI.ischecked("Fix Input Bug") then
--		Game.fixInputBug();
--	end
	Game.getConsoleMode();
end

function Game.eachFrame()
	if ScriptHawk.UI.ischecked("OoB Timer Checkbox") then
		Game.FreezeOoBTimer();
	end

	if ScriptHawk.UI.ischecked("Free Roam Mode") then
		Game.freeroamEnabled();
	else
		Game.freeroamDisabled();
	end

	Game.applyConsoleSettings();
	if ScriptHawk.UI.ischecked("realtime_flags") then
		newFlagCache();
		checkFlagArray();
		populateFlagArray();
		
		newSaveFileArray();
		checkSaveFileArray();
		populateSaveFileArray();
	end
end

function onLoadState()
	clearFlagCache();
	clearSaveFileCache();
end

Game.OSD = {
	{"Map", Game.getMapOSD, category="mapData"},
	{"Exit", Game.getExitOSD, category="mapData"},
	{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"Velocity", Game.getVelocity, category="positionStats"},
	{"Y Velocity", Game.getYVelocity, category="positionStats"},
	{"Max XZ Velocity", Game.getMaxXZVelocity, category="positionStats"},
	{"Separator"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"},
	--{"Rot. X", Game.getXRotation, category="angleMore"},
	{"Floor", Game.getFloor, category="position"},
	{"Animation", Game.getAnimationOSD, category="animation"},
	{"Animation Timer", Game.getAnimationTimerOSD, category="animation"},
	{"Movement", Game.getMovementOSD, category="movement"},
	{"Facing", Game.getYRotation, category="angle"},
	--{"Rot. Z", Game.getZRotation, category="angleMore"},
	{"Separator"},
	{"Marble Count", Game.getMarbleCount, category="marbleCount"},
};

event.onloadstate(onLoadState, "State loading function");

return Game;