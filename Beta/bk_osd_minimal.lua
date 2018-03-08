-- Written by Isotarge
-- Angle calculator by The8bitbeast

-- For calculated moving angle
local x = 0.0;
local z = 0.0;
local dx = 0.0;
local dz = 0.0;
local prev_x = 0.0;
local prev_z = 0.0;

local Game = {
	Memory = {
		-- Version order: Europe, Japan, US 1.1, US 1.0
		frame_timer = {0x280700, 0x27F718, 0x27F718, 0x2808D8},
		slope_timer = {0x37CCB4, 0x37CDE4, 0x37B4E4, 0x37C2E4},
		player_grounded = {0x37C930, 0x37CA60, 0x37B160, 0x37BF60},
		wall_collisions = {0x37CC4D, 0x37CD7D, 0x37B47D, 0x37C27D},
		floor_object_pointer = {0x37CBD0, 0x37CD00, 0x37B400, 0x37C200},
		x_velocity = {0x37CE88, 0x37CFB8, 0x37B6B8, 0x37C4B8},
		y_velocity = {0x37CE8C, 0x37CFBC, 0x37B6BC, 0x37C4BC},
		z_velocity = {0x37CE90, 0x37CFC0, 0x37B6C0, 0x37C4C0},
		x_position = {0x37CF70, 0x37D0A0, 0x37B7A0, 0x37C5A0},
		y_position = {0x37CF74, 0x37D0A4, 0x37B7A4, 0x37C5A4},
		z_position = {0x37CF78, 0x37D0A8, 0x37B7A8, 0x37C5A8},
		x_rotation = {0x37CF10, 0x37D040, 0x37B740, 0x37C540},
		y_rotation = {0x37D060, 0x37D190, 0x37B890, 0x37C690},
		facing_angle = {0x37D060, 0x37D190, 0x37B890, 0x37C690},
		moving_angle = {0x37D064, 0x37D194, 0x37B894, 0x37C694},
		z_rotation = {0x37D050, 0x37D180, 0x37B880, 0x37C680},
		current_movement_state = {0x37DB34, 0x37DC64, 0x37C364, 0x37D164},
		object_array_pointer = {0x36EAE0, 0x36F260, 0x36D760, 0x36E560},
	},
};

local ROMHash = gameinfo.getromhash();
if ROMHash == "BB359A75941DF74BF7290212C89FBC6E2C5601FE" then -- Europe
	Game.version = 1;
elseif ROMHash == "90726D7E7CD5BF6CDFD38F45C9ACBF4D45BD9FD8" then -- Japan
	Game.version = 2;
elseif ROMHash == "DED6EE166E740AD1BC810FD678A84B48E245AB80" then -- US 1.1
	Game.version = 3;
elseif ROMHash == "1FE1632098865F639E22C11B9A81EE8F29C75D7A" then -- US 1.0
	Game.version = 4;
else
	print("This game is not supported.");
	return false;
end

RDRAMBase = 0x80000000;
RDRAMSize = 0x800000; -- Halved with no expansion pak

-- Dereferences a N64 RDRAM pointer
-- Returns the RDRAM address pointed to if it's a valid pointer
-- Returns nil if invalid
function dereferencePointer(address)
	if type(address) == "number" and address >= 0 and address < (RDRAMSize - 4) then
		address = mainmemory.read_u32_be(address);
		if address >= RDRAMBase and address < RDRAMBase + RDRAMSize then
			return address - RDRAMBase;
		end
	end
end

-- Checks whether a value falls within N64 RDRAM
function isRDRAM(value)
	return type(value) == "number" and value >= 0 and value < RDRAMSize;
end

local precision = 3;
function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num));
end

function angleBetweenPoints(x1, y1, x2, y2)
	local angle = 180 * (math.atan2(x2 - x1, y2 - y1)) / math.pi;
	return (angle + 360) % 360;
end

function Game.getFloor()
	local floorObject = dereferencePointer(Game.Memory.floor_object_pointer[Game.version]);
	if isRDRAM(floorObject) then
		return mainmemory.readfloat(floorObject + 0x40, true);
	end
	return 0;
end

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.x_position[Game.version], true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_position[Game.version], true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_position[Game.version], true);
end

function Game.getVelocity()
	local vX = mainmemory.readfloat(Game.Memory.x_velocity[Game.version], true);
	local vZ = mainmemory.readfloat(Game.Memory.z_velocity[Game.version], true);
	return math.sqrt(vX*vX + vZ*vZ);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity[Game.version], true);
end

function Game.getXRotation()
	return mainmemory.readfloat(Game.Memory.x_rotation[Game.version], true);
end

function Game.getMovingAngle()
	return mainmemory.readfloat(Game.Memory.moving_angle[Game.version], true);
end

function Game.getGroundState()
	return tostring(mainmemory.read_u32_be(Game.Memory.player_grounded[Game.version]) > 0);
end

function Game.getWallCollisions()
	return mainmemory.readbyte(Game.Memory.wall_collisions[Game.version]);
end

function Game.getSlopeTimer()
	return mainmemory.readfloat(Game.Memory.slope_timer[Game.version], true);
end

function Game.isPhysicsFrame()
	local frameTimerValue = mainmemory.read_s32_be(Game.Memory.frame_timer[Game.version]);
	return frameTimerValue <= 0 and not emu.islagged();
end

function Game.getCalculatedMovingAngle()
	if dx == 0 and dz == 0 then
		return 0;
	end
	return angleBetweenPoints(prev_x, prev_z, x, z);
end

local movementStates = {
	[0] = "Null",
	[1] = "Idle",
	[2] = "Walking", -- Slow
	[3] = "Walking",
	[4] = "Walking", -- Fast
	[5] = "Jumping",
	[6] = "Bear punch",
	[7] = "Crouching",
	[8] = "Jumping", -- Talon Trot
	[9] = "Shooting Egg",
	[10] = "Pooping Egg",

	[12] = "Skidding",

	[14] = "Damaged",
	[15] = "Beak Buster",
	[16] = "Feathery Flap",
	[17] = "Rat-a-tat rap",
	[18] = "Backflip", -- Flap Flip
	[19] = "Beak Barge",
	[20] = "Entering Talon Trot",
	[21] = "Idle", -- Talon Trot
	[22] = "Walking", -- Talon Trot
	[23] = "Leaving Talon Trot",
	[24] = "Knockback", -- Flying

	[26] = "Entering Wonderwing",
	[27] = "Idle", -- Wonderwing
	[28] = "Walking", -- Wonderwing
	[29] = "Jumping", -- Wonderwing
	[30] = "Leaving Wonderwing",
	[31] = "Creeping",
	[32] = "Landing", -- After Jump
	[33] = "Charging Shock Spring Jump",
	[34] = "Shock Spring Jump",
	[35] = "Taking Flight",
	[36] = "Flying",
	[37] = "Entering Wading Boots",
	[38] = "Idle", -- Wading Boots
	[39] = "Walking", -- Wading Boots
	[40] = "Jumping", -- Wading Boots
	[41] = "Leaving Wading Boots",
	[42] = "Beak Bomb",
	[43] = "Idle", -- Underwater
	[44] = "Swimming (B)",
	[45] = "Idle", -- Treading water
	[46] = "Paddling",
	[47] = "Falling", -- After pecking
	[48] = "Diving",
	[49] = "Rolling",
	[50] = "Slipping",

	[52] = "Jig", -- Note door
	[53] = "Idle", -- Termite
	[54] = "Walking", -- Termite
	[55] = "Jumping", -- Termite
	[56] = "Falling", -- Termite
	[57] = "Swimming (A)",
	[58] = "Idle", -- Carrying object (eg. Orange)
	[59] = "Walking", -- Carrying object (eg. Orange)

	[61] = "Falling", -- Tumbling, will take damage
	[62] = "Damaged", -- Termite

	[64] = "Locked", -- Pumpkin: Pipe
	[65] = "Death",
	[66] = "Dingpot",
	[67] = "Death", -- Termite
	[68] = "Jig", -- Jiggy
	[69] = "Slipping", -- Talon Trot

	[72] = "Idle", -- Pumpkin
	[73] = "Walking", -- Pumpkin
	[74] = "Jumping", -- Pumpkin
	[75] = "Falling", -- Pumpkin
	[76] = "Landing", -- In water
	[77] = "Damaged", -- Pumpkin
	[78] = "Death", -- Pumpkin
	[79] = "Idle", -- Holding tree, pole, etc.
	[80] = "Climbing", -- Tree, pole, etc.
	[81] = "Leaving Climb",
	[82] = "Tumblar", -- Standing on Tumblar
	[83] = "Tumblar", -- Standing on Tumblar
	[84] = "Death", -- Drowning
	[85] = "Slipping", -- Wading Boots
	[86] = "Knockback", -- Successful enemy damage
	[87] = "Beak Bomb", -- Ending
	[88] = "Damaged", -- Beak Bomb
	[89] = "Damaged", -- Beak Bomb
	[90] = "Loading Zone",
	[91] = "Throwing", -- Throwing object (eg. Orange)

	[94] = "Idle", -- Croc
	[95] = "Walking", -- Croc
	[96] = "Jumping", -- Croc
	[97] = "Falling", -- Croc
	[99] = "Damaged", -- Croc
	[100] = "Death", -- Croc

	[103] = "Idle", -- Walrus
	[104] = "Walking", -- Walrus
	[105] = "Jumping", -- Walrus
	[106] = "Falling", -- Walrus
	[107] = "Locked", -- Bee, Mumbo Transform Cutscene
	[108] = "Knockback", -- Walrus
	[109] = "Death", -- Walrus
	[110] = "Biting", -- Croc
	[111] = "EatingWrongThing", -- Croc
	[112] = "EatingCorrectThing", -- Croc
	[113] = "Falling", -- Talon Trot
	[114] = "Recovering", -- Getting up after taking damage, eg. fall famage
	[115] = "Locked", -- Cutscene
	[116] = "Locked", -- Jiggy pad, Mumbo transformation, Bottles
	[117] = "Locked", -- Bottles
	[118] = "Locked", -- Flying
	[119] = "Locked", -- Water Surface
	[120] = "Locked", -- Underwater
	[121] = "Locked", -- Holding Jiggy, Talon Trot
	[122] = "Creeping", -- In damaging water etc
	[123] = "Damaged", -- Talon Trot
	[124] = "Locked", -- Sled in FP sliding down scarf
	[125] = "Idle", -- Walrus Sled
	[126] = "Jumping", -- Walrus Sled
	[127] = "Damaged", -- Swimming
	[128] = "Locked", -- Walrus Sled losing race
	[129] = "Locked", -- Walrus Sled
	[130] = "Locked", -- Walrus Sled In Air when losing race

	[133] = "Idle", -- Bee
	[134] = "Walking", -- Bee
	[135] = "Jumping", -- Bee
	[136] = "Falling", -- Bee
	[137] = "Damaged", -- Bee
	[138] = "Death", -- Bee

	[140] = "Flying", -- Bee
	[141] = "Locked", -- Mumbo transformation, Mr. Vile
	[142] = "Locked", -- Jiggy podium, Bottles' text outside Mumbo's
	[143] = "Locked", -- Pumpkin
	[145] = "Damaged", -- Flying
	[147] = "Locked", -- Pumpkin?
	[148] = "Locked", -- Mumbo transformation
	[149] = "Locked", -- Walrus?
	[150] = "Locked", -- Paddling
	[151] = "Locked", -- Swimming
	[152] = "Locked", -- Loading zone, Mumbo transformation
	[153] = "Locked", -- Flying
	[154] = "Locked", -- Talon Trot
	--[155] = "Locked??", -- In WadingBoots Set
	--[156] = "Locked??", -- In WalrusSled Set
	[157] = "Locked", -- Bee?
	[158] = "Locked", -- Climbing
	[159] = "Knockback", -- Termite, not damaged
	[160] = "Knockback", -- Pumpkin, not damaged
	[161] = "Knockback", -- Croc, not damaged
	[162] = "Knockback", -- Walrus, not damaged
	[163] = "Knockback", -- Bee, not damaged
	--[164] = "???", -- Wonderwing
	[165] = "Locked", -- Wonderwing
};

function Game.getCurrentMovementState()
	local currentMovementState = mainmemory.read_u32_be(Game.Memory.current_movement_state[Game.version]);
	return movementStates[currentMovementState] or "Unknown ("..currentMovementState..")";
end

local gruntyStates = {
	[0x1C4] = "Flying", -- Intro
	[0x1C5] = "Flying", -- Intro

	[0x257] = "Green Spell", -- Flying
	[0x258] = "Hurt",
	[0x259] = "Hurt",
	[0x25A] = "Fireball Spell", -- Flying

	[0x25C] = "Swooping",
	[0x25D] = "Recovering",
	[0x25E] = "Vulnerable",
	[0x25F] = "Standing",
	[0x260] = "Fireball Spell", -- Landed
	[0x261] = "Green Spell", -- Landed
	[0x263] = "Fall off Broom",
	-- [0x266] = "Grunty/Falling down tower", -- TODO: What is this?
	-- [0x267] = "Grunty?", -- TODO: What is this?
};

local slot_base = 0x08;
local slot_size = 0x180;
local max_slots = 0x100;

local function getSlotBase(index)
	return slot_base + index * slot_size;
end

local gruntyPosition = {
	x = 0,
	y = 0,
	z = 0,
	facing = 0,
};

function Game.getGruntyXPosition()
	return gruntyPosition.x;
end

function Game.getGruntyYPosition()
	return gruntyPosition.y;
end

function Game.getGruntyZPosition()
	return gruntyPosition.z;
end

function Game.getGruntyFacingAngle()
	return gruntyPosition.facing;
end

function Game.getGruntyState()
	local numSlots = 0;
	local levelObjectArray = dereferencePointer(Game.Memory.object_array_pointer[Game.version]);
	if isRDRAM(levelObjectArray) then
		numSlots = math.min(max_slots, mainmemory.read_u32_be(levelObjectArray));
	end
	for i = numSlots, 1, -1 do
		local currentSlotBase = levelObjectArray + getSlotBase(i);
		local animationObjectPointer = dereferencePointer(currentSlotBase + 0x14);
		if isRDRAM(animationObjectPointer) then
			local animationType = mainmemory.read_u32_be(animationObjectPointer + 0x38);
			if type(gruntyStates[animationType]) == "string" then
				gruntyPosition.x = mainmemory.readfloat(currentSlotBase + 0x04, true);
				gruntyPosition.y = mainmemory.readfloat(currentSlotBase + 0x08, true);
				gruntyPosition.z = mainmemory.readfloat(currentSlotBase + 0x0C, true);
				gruntyPosition.facing = mainmemory.readfloat(currentSlotBase + 0x50, true);
				return gruntyStates[animationType];
			end
		end
	end
	return "Unknown";
end

local OSDs = {
	WithGrunty = {
		{"X", Game.getXPosition},
		{"Y", Game.getYPosition},
		{"Z", Game.getZPosition},
		{"Separator"},
		{"Floor", Game.getFloor},
		{"Separator"},
		{"Velocity", Game.getVelocity};
		{"Y Velocity", Game.getYVelocity},
		{"Separator"},
		{"X Rotation", Game.getXRotation},
		{"Angle", Game.getMovingAngle},
		{"Moving Angle", Game.getCalculatedMovingAngle},
		{"Separator"},
		{"Movement", Game.getCurrentMovementState},
		{"Wall Collisions", Game.getWallCollisions},
		{"Grounded", Game.getGroundState},
		{"Slope Timer", Game.getSlopeTimer},
		{"Separator"},
		{"Grunty State", Game.getGruntyState},
		{"Separator"},
		{"Grunty X", Game.getGruntyXPosition},
		{"Grunty Y", Game.getGruntyYPosition},
		{"Grunty Z", Game.getGruntyZPosition},
		{"Grunty Facing", Game.getGruntyFacingAngle},
	},
	WithoutGrunty = {
		{"X", Game.getXPosition},
		{"Y", Game.getYPosition},
		{"Z", Game.getZPosition},
		{"Separator"},
		{"Floor", Game.getFloor},
		{"Separator"},
		{"Velocity", Game.getVelocity};
		{"Y Velocity", Game.getYVelocity},
		{"Separator"},
		{"X Rotation", Game.getXRotation},
		{"Angle", Game.getMovingAngle},
		{"Moving Angle", Game.getCalculatedMovingAngle},
		{"Separator"},
		{"Movement", Game.getCurrentMovementState},
		{"Wall Collisions", Game.getWallCollisions},
		{"Grounded", Game.getGroundState},
		{"Slope Timer", Game.getSlopeTimer},
	},
};

local OSD = OSDs.WithoutGrunty;

angleCalc = {
	buttonX = 220,
	visible = false,
	form = nil,
	p1xbox = nil,
	p1zbox = nil,
	p2xbox = nil,
	p2zbox = nil,
	anglebox = nil,
};

angleCalc.setPoint1 = function()
	forms.settext(angleCalc.p1xbox, Game.getXPosition())
	forms.settext(angleCalc.p1zbox, Game.getZPosition())
	forms.settext(angleCalc.anglebox, "");
end

angleCalc.setPoint2 = function()
	forms.settext(angleCalc.p2xbox, Game.getXPosition());
	forms.settext(angleCalc.p2zbox, Game.getZPosition());
	forms.settext(angleCalc.anglebox, "");
end

angleCalc.calculateAngle = function()
	local p1x = forms.gettext(angleCalc.p1xbox);
	local p1z = forms.gettext(angleCalc.p1zbox);
	local p2x = forms.gettext(angleCalc.p2xbox);
	local p2z = forms.gettext(angleCalc.p2zbox);

	local angle = angleBetweenPoints(p1x, p1z, p2x, p2z);

	forms.settext(angleCalc.anglebox, angle);

	print('Point 1: '..round(p1x, 4)..", "..round(p1z, 4));
	print('Point 2: '..round(p2x, 4)..", "..round(p2z, 4));
	print('Angle: '..angle);
	print("");
end

angleCalc.clearAll = function()
	forms.settext(angleCalc.p1xbox, "");
	forms.settext(angleCalc.p1zbox, "");
	forms.settext(angleCalc.p2xbox, "");
	forms.settext(angleCalc.p2zbox, "");
	forms.settext(angleCalc.anglebox, "");
end

angleCalc.close = function()
	angleCalc.visible = false;
end

angleCalc.open = function()
	if not angleCalc.visible then
		angleCalc.visible = true;
		angleCalc.form = forms.newform(390, 190, "Angle Calculator", angleCalc.close);

		-- Buttons
		forms.button(angleCalc.form, "Use Current Coordinates", angleCalc.setPoint1, angleCalc.buttonX, 40, 150, 32);
		forms.button(angleCalc.form, "Use Current Coordinates", angleCalc.setPoint2, angleCalc.buttonX, 74, 150, 32);
		forms.button(angleCalc.form, "Calculate Angle", angleCalc.calculateAngle, angleCalc.buttonX, 108, 90, 32);
		forms.button(angleCalc.form, "Clear All", angleCalc.clearAll, angleCalc.buttonX + 95, 108, 55, 32);
		forms.label(angleCalc.form, "Calculates the angle of the straight line betwen 2 points", 0, 0, 500, 15);

		-- Labels
		forms.label(angleCalc.form, "Point 1:", 0, 50, 50, 15);
		forms.label(angleCalc.form, "Point 2:", 0, 84, 50, 15);
		forms.label(angleCalc.form, "Angle:", 0, 118, 50, 15);
		forms.label(angleCalc.form, "x", 85, 20, 20, 15);
		forms.label(angleCalc.form, "z", 170, 20, 20, 15);

		-- Textboxes
		angleCalc.p1xbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 50, 45);
		angleCalc.p1zbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 135, 45);
		angleCalc.p2xbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 50, 79);
		angleCalc.p2zbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 135, 79);
		angleCalc.anglebox = forms.textbox(angleCalc.form, "", 70, 20, 1, 50, 113);
	else
		--print("Please close the angle calculator before opening another one.");
	end
end
angleCalc.open();

local function drawOSD()
	if Game.getGruntyState() == "Unknown" then
		OSD = OSDs.WithoutGrunty;
	else
		OSD = OSDs.WithGrunty;
	end

	if Game.isPhysicsFrame() then
		prev_x = x;
		prev_z = z;
		x = Game.getXPosition();
		z = Game.getZPosition();
		dx = x - prev_x;
		dz = z - prev_z;
	end

	local row = 0;
	local OSDX = 2;
	local OSDY = 70;

	for i = 1, #OSD do
		local label = OSD[i][1];
		local value = OSD[i][2];

		if label ~= "Separator" then
			-- Get the value
			if type(value) == "function" then
				value = value();
			end

			-- Round the value
			if type(value) == "number" then
				value = round(value, precision);
			end

			gui.text(OSDX, OSDY + 16 * row, label..": "..value);
		else
			if type(value) == "number" and value > 1 then
				row = row + value - 1;
			end
		end
		row = row + 1;
	end
end

event.onframestart(drawOSD);
event.onloadstate(drawOSD);