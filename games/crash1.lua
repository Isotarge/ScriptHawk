if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

-- Original script by pirohiko, https://code.google.com/archive/p/pirohiko/
-- Ported to BizHawk and ScriptHawk API by Isotarge

-- TODO: Uh yeah this script needs a lot of cleanup and fixes
	-- vScale and pScale are annoying hacks :(
	-- Scale Game.speedy_speeds
	-- Take me there implementation

local oldP = {0, 0};
local P = {0, 0};
local oldPV = 0;

Game = {
	max_rot_units = 4096,
	rot_speed = 16,
	speedy_index = 7,
	speedy_speeds = {
		0.001, 0.01, 0.1, 1, 5, 10, 20, 50, 100
	},
	Memory = { -- Version order: USA, Europe, Japan
		akuaku_mask_pointer = {0x618CC, 0x615AC, 0x618B4},
		global_timer = {0x57960, 0x57640, 0x57948},
		level = {0x618DC, 0x615BC, 0x618C4},
		player_pointer = {0x566B4, 0x56390, 0x56698},
		boxes_smashed = {0x61984, 0x61664, 0x6196C}, -- Signed 24.8 fixed point
		level_progress = {0x57920, 0x57600, 0x57908}, -- 24.8 fixed point
	},
};

local player_data = {
	x_position = 0x80,
	y_position = 0x84,
	z_position = 0x88,
	x_velocity = 0xA4,
	y_velocity = 0xA8,
	z_velocity = 0xAC,
	y_rotation = 0xB4,
	velocity = 0x124,
	lives = 0x164,
	jumps = 0x1A1,
};

local pScale = 1000;
local vScale = 100000;

function Game.detectVersion(romName, romHash)
	if romHash == "41B5F211" or romHash == "249FC147" then -- USA
		version = 1;
		return true;
	elseif romHash == "D6172125" or romHash == "2033243A" then -- Europe (EDC)
		version = 2;
		return true;
	elseif romHash == "FD11EB1E" or romHash == "0B9EB02B" then -- Europe (No EDC)
		version = 2;
		return true;
	elseif romHash == "D9BA797E" or romHash == "F5B95131" then -- Japan
		version = 3;
		return true;
	end
	return false;
end

global_timer = {
	current = 0,
	previous = 0,
};

function Game.isPhysicsFrame()
	return global_timer.current ~= global_timer.previous;
end

function Game.getLevel()
	return mainmemory.read_u32_le(Game.Memory.level[version]);
end

function Game.getPlayerActor()
	return dereferencePointer(Game.Memory.player_pointer[version]);
end

function playerPointerOSD()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return toHexString(player);
	end
	return "Not Found";
end

function Game.getLives()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return math.floor(mainmemory.read_s32_le(player + player_data.lives) / 256);
	end
	return 0;
end

function Game.setLives(value)
	local player = Game.getPlayerActor();
	if isRAM(player) then
		mainmemory.write_s32_le(player + player_data.lives, value * 256);
	end
end

function Game.getBoxesSmashed()
	return math.floor(mainmemory.read_s32_le(Game.Memory.boxes_smashed[version]) / 256);
end

function Game.getSpinPower() -- TODO: Verify data
	local player = Game.getPlayerPointer();
	if isRAM(player) then
		local spin = math.min(300, mainmemory.u32_le(player + 0xFC) - mainmemory.read_u32_le(player + 0x194)) / 60;
		return spin;
	end
	return 0;
end

function Game.getJumps()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_u32_le(player + player_data.jumps);
	end
	return 0;
end

--------------
-- Progress --
--------------

function Game.getProgress()
	return mainmemory.read_s32_le(Game.Memory.level_progress[version]) / 256;
end

function Game.getProgressVel()
	P = {Game.getProgress(), emu.framecount()};
	if oldP[2] == P[2] then
		return oldPV;
	end
	local PV = P[1] - oldP[1];
	oldPV = PV;
	oldP = P;
	return PV;
end

--------------
-- Position --
--------------

function Game.getXPosition()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + player_data.x_position) / pScale;
	end
	return 0;
end

function Game.getYPosition()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + player_data.y_position) / pScale;
	end
	return 0;
end

function Game.getZPosition()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + player_data.z_position) / pScale;
	end
	return 0;
end

function Game.setXPosition(value)
	local player = Game.getPlayerActor();
	if isRAM(player) then
		mainmemory.write_s32_le(player + player_data.x_position, value * pScale);
	end
end

function Game.setYPosition(value)
	local player = Game.getPlayerActor();
	if isRAM(player) then
		mainmemory.write_s32_le(player + player_data.y_position, value * pScale);
	end
end

function Game.setZPosition(value)
	local player = Game.getPlayerActor();
	if isRAM(player) then
		mainmemory.write_s32_le(player + player_data.z_position, value * pScale);
	end
end

--------------
-- Rotation --
--------------

function Game.getYRotation()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + player_data.y_rotation);
	end
	return 0;
end

function Game.setYRotation(value)
	local player = Game.getPlayerActor();
	if isRAM(player) then
		mainmemory.write_s32_le(player + player_data.y_rotation, value);
	end
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + player_data.x_velocity) / vScale;
	end
	return 0;
end

function Game.getYVelocity()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + player_data.y_velocity) / vScale;
	end
	return 0;
end

function Game.getZVelocity()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + player_data.z_velocity) / vScale;
	end
	return 0;
end

function Game.getXZVelocity()
	local xV = Game.getXVelocity();
	local zV = Game.getZVelocity();
	return math.sqrt(xV*xV + zV*zV);
end

function Game.getVelocity()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + player_data.velocity) / vScale;
	end
	return 0;
end

function Game.applyInfinites()
	Game.setLives(99);
	local maskObject = dereferencePointer(Game.Memory.akuaku_mask_pointer[version]);
	if isRAM(maskObject) then
		mainmemory.writebyte(maskObject + 0x189, 0x02);
	end
end

function Game.eachFrame()
	global_timer.previous = global_timer.current;
	global_timer.current = mainmemory.read_u32_le(Game.Memory.global_timer[version]);
end

Game.OSD = {
	{"Player", playerPointerOSD},
	{"Level", Game.getLevel},
	{"Box", Game.getBoxesSmashed},
	{"Progress", Game.getProgress},
	{"Progress Vel", Game.getProgressVel},
	{"Separator"},
	{"X"},
	{"Y"},
	{"Z"},
	{"Separator"},
	{"dY"},
	{"dXZ"},
	--{"Max dY"},
	--{"Max dXZ"},
	--{"Odometer"},
	{"Separator"},
	{"Facing", Game.getYRotation},
	{"Moving Angle"},
	{"Separator"},
	{"Y Velocity", Game.getYVelocity},
	{"XZ Velocity", Game.getXZVelocity},
	{"Velocity", Game.getVelocity},
	{"Separator"},
	{"Jumps", Game.getJumps},
};

return Game;