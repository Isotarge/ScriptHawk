if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = { -- 1 USA, 2 EU
		jim_pointer = {0x0C6810, 0x0C8670},
		boss_camlock_pointer = {0x0E9F08, 0x0EBD68},
		current_map = {0x0E9EF9, 0x0EBD59},
		destination_map = {0x0E03E7, 0x0E2247},
		destination_exit = {0x0E03E9, 0x0E2249},
		subhub_entrance_cs = {0x0C624A, nil},
		--controller_input = {0x0D4134, 0x0D5F94},
		reload_map = {0x0E03E2,0x0E2242},
		marble_pointer = {0x0C61E2,0x0C8042},
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
	[24] = "Breaking Wind",
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
	[23] = "Acid Burn", -- Acid Bats
	[24] = "First Person",
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

local labelValue = 0;
function Game.initUI()
	ScriptHawk.UI.form_controls["Reload Map (Soft)"] = forms.button(ScriptHawk.UI.options_form, "Reload Map", Game.reloadMap, ScriptHawk.UI.col(5), ScriptHawk.UI.row(4), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Reload Map (Hard)"] = forms.button(ScriptHawk.UI.options_form, "Hard Reload", Game.reloadMapHard, ScriptHawk.UI.col(10), ScriptHawk.UI.row(0), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Kill Boss"] = forms.button(ScriptHawk.UI.options_form, "Kill Boss", Game.killBoss, ScriptHawk.UI.col(10), ScriptHawk.UI.row(1), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
end

function Game.realTime()
--	if forms.ischecked(ScriptHawk.UI.form_controls["Fix Input Bug"]) then
--		Game.fixInputBug();
--	end
end

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
	{"Animation", Game.getAnimationOSD},
	{"Animation Timer", Game.getAnimationTimerOSD},
	{"Movement", Game.getMovementOSD},
	{"Facing", Game.getYRotation},
	--{"Rot. Z", Game.getZRotation},
};

return Game;