-- Original script by pirohiko, https://code.google.com/archive/p/pirohiko/
-- Ported to BizHawk and ScriptHawk API by Isotarge

-- TODO: Uh yeah this script needs a lot of cleanup and fixes
	-- vScale and pScale are annoying hacks :(
	-- Scale Game.speedy_speeds
	-- Take me there implementation

Game = {
	max_rot_units = 4096,
	rot_speed = 16,
	speedy_index = 7,
	speedy_speeds = {
		0.001, 0.01, 0.1, 1, 5, 10, 20, 50, 100
	},
	Memory = { -- Version order: USA, Europe, Japan
		akuaku_mask_pointer = {0x6CBB0, 0x6CE48, 0x6D9AC},
		global_timer = {0x60944, 0x60BDC, 0x62D98},
		level = {nil, nil, nil}, -- TODO
		player_pointer = {0x5F38C, 0x5F624, 0x614F0},
		total_boxes = {0x6CDC0, 0x6D058, 0x6DBBC}, -- Signed 24.8 fixed point
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

function Game.detectVersion(romName, romHash)
	if romHash == "149A203B" or romHash == "395C0916" then -- USA
		version = 1;
		return true;
	elseif romHash == "F5E2EC49" or romHash == "5F65CF0F" then -- Europe No EDC
		version = 2;
		return true;
	elseif romHash == "97395614" or romHash == "74C85B1E" then -- Europe EDC
		version = 2;
		return true;
	elseif romHash == "B0A92BAF" or romHash == "14591AE9" then -- Japan
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
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return math.floor(mainmemory.read_u32_le(player + player_data.boxes_smashed) / 256);
	end
	return 0;
end

function Game.getTotalBoxes()
	return math.floor(mainmemory.read_s32_le(Game.Memory.total_boxes[version]) / 256);
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

function Game.getXRotation()
	return 0; -- TODO: Get X Rotation
end

function Game.getYRotation()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + player_data.y_rotation);
	end
	return 0;
end

function Game.getZRotation()
	return 0; -- TODO: Get Z Rotation
end

function Game.setXRotation(value)
	return; -- TODO: Set X Rotation
end

function Game.setYRotation(value)
	local player = Game.getPlayerActor();
	if isRAM(player) then
		mainmemory.write_s32_le(player + player_data.y_rotation, value);
	end
end

function Game.setZRotation(value)
	return; -- TODO: Set Z Rotation
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
		mainmemory.writebyte(maskObject + 0x175, 0x02);
	end
end

function Game.eachFrame()
	global_timer.previous = global_timer.current;
	global_timer.current = mainmemory.read_u32_le(Game.Memory.global_timer[version]);
end

Game.OSD = {
	{"Player", playerPointerOSD},
	--{"Level", Game.getLevel},
	{"Box", Game.getBoxString},
	{"Separator", 1},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"dY"},
	{"dXZ"},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
	{"Facing", Game.getYRotation},
	{"Moving Angle"},
	{"Separator", 1},
	{"Y Velocity", Game.getYVelocity},
	{"XZ Velocity", Game.getXZVelocity},
	{"Velocity", Game.getVelocity},
	{"Separator", 1},
	{"Jumps", Game.getJumps},
};

return Game;
