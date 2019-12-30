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

local Game = {
	max_rot_units = 4096,
	rot_speed = 16,
	speedy_index = 7,
	speedy_speeds = {
		0.001, 0.01, 0.1, 1, 5, 10, 20, 50, 100
	},
	squish_memory_table = true,
	Memory = { -- Version order: USA, Europe, Japan
		akuaku_mask_pointer = {0x6CBB0, 0x6CE48, 0x6D9AC},
		global_timer = {0x60944, 0x60BDC, 0x62D98},
		level = {nil, nil, nil}, -- TODO
		player_pointer = {0x5F38C, 0x5F624, 0x614F0},
		total_boxes = {0x6CDC0, 0x6D058, 0x6DBBC}, -- Signed 24.8 fixed point
		level_progress = {0x608E0, 0x60B78, 0x62D34}, -- 24.8 fixed point
	},
};

local player_data = {
	x_position = 0x60,
	y_position = 0x64,
	z_position = 0x68,
	x_velocity = 0x84,
	y_velocity = 0x88,
	z_velocity = 0x8C,
	y_rotation = 0x94,
	velocity = 0x104,
	lives = 0x144, -- Signed 24.8 fixed point
	boxes_smashed = 0x164,
	jumps = 0x18D,
};

local pScale = 1000;
local vScale = 100000;

local global_timer = {
	current = 0,
	previous = 0,
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.smooth_moving_angle = false;
	ScriptHawk.update_delta_on_lag = true;
	return true;
end

function Game.isPhysicsFrame()
	return global_timer.current ~= global_timer.previous;
end

function Game.getLevel()
	return mainmemory.read_u32_le(Game.Memory.level);
end

function Game.getPlayerActor()
	return dereferencePointer(Game.Memory.player_pointer);
end

local function playerPointerOSD()
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
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return math.floor(mainmemory.read_u32_le(player + player_data.boxes_smashed) / 256);
	end
	return 0;
end

function Game.getTotalBoxes()
	return math.floor(mainmemory.read_s32_le(Game.Memory.total_boxes) / 256);
end

function Game.getBoxString()
	return Game.getBoxesSmashed().." / "..Game.getTotalBoxes();
end

function Game.getJumps()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_u32_le(player + player_data.jumps);
	end
	return 0;
end

function Game.getLevelProgress()
	return mainmemory.read_u32_le(Game.Memory.level_progress) / 256;
end

function Game.getMaxLevelProgress()
	return mainmemory.read_u32_le(Game.Memory.level_progress + 4) / 256;
end

function Game.getLevelProgressOSD()
	return round(Game.getLevelProgress(), precision).." / "..round(Game.getMaxLevelProgress(), precision);
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
	local maskObject = dereferencePointer(Game.Memory.akuaku_mask_pointer);
	if isRAM(maskObject) then
		mainmemory.writebyte(maskObject + 0x175, 0x02);
	end
end

function Game.eachFrame()
	global_timer.previous = global_timer.current;
	global_timer.current = mainmemory.read_u32_le(Game.Memory.global_timer);
end

Game.OSD = {
	{"Player", playerPointerOSD, category="player"},
	--{"Level", Game.getLevel, category="mapData"},
	{"Box", Game.getBoxString, category="boxData"},
	{"Progress", Game.getLevelProgressOSD, category="progress"},
	--{"Progress Vel", Game.getProgressVel, category="progressMore"}, -- TODO: Progress velocity
	{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"dY", category="positionStats"},
	{"dX", category="positionStats"},
	{"dZ", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"},
	{"Facing", Game.getYRotation, category="angle"},
	{"Moving Angle", category="angle"},
	{"Separator"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"XZ Velocity", Game.getXZVelocity, category="speed"},
	{"Velocity", Game.getVelocity, category="speed"},
	{"Separator"},
	{"Jumps", Game.getJumps, category="jumps"},
};

return Game;