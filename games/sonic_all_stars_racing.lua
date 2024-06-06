if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

function mainmemory.read_s1616_le(address) -- Signed fixed point 16.16 little endian
	return mainmemory.read_s32_le(address) / 0x10000;
end

function mainmemory.write_s1616_le(address, value) -- Signed fixed point 16.16 little endian
	return mainmemory.write_u32_le(address, value * 0x10000);
end

local Game = {
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 },
	speedy_index = 7,
	rot_speed = 128,
	max_rot_units = 4096,
	squish_memory_table = true,
	Memory = { -- Version order: US, Europe
		player_pointer = {0x236238, 0},
		rng = {0x1293B0, 0},
		igf = {0xAB4, 0},
		boost_flame_size = {0x798, 0},
		boost = {0x938, 0}, -- unsigned 32 bit
		y_rotation = {0x10C, 0}, -- signed 32 bit, but unknown units, relative to player
		base_velocity = {0x8E0, 0}, -- s16.16le, relative to player
		x_velocity = {0xA7C, 0}, -- s16.16le, relative to player
		y_velocity = {0xA80, 0}, -- s16.16le, relative to player
		z_velocity = {0xA84, 0}, -- s16.16le, relative to player
		side_velocity = {0x8E4, 0}, -- s16.16le, relative to player
		x_position = {0x6C, 0}, -- s16.16le, relative to player
		y_position = {0x70, 0}, -- s16.16le, relative to player
		z_position = {0x74, 0}, -- s16.16le, relative to player
		wheelie = {0xA78, 0}, -- signed 32 bit
		airtime = {0x680, 0}, -- signed 32 bit
		death = {0x99C, 0}, -- signed 32 bit
		wrong_way = {0xAE4, 0}, -- signed 32 bit
		checkpoint = {0xB6C, 0}, -- signed 32 bit
		tilt = {0x10A, 0}, -- signed 16 bit
		item = {0x954, 0}, -- signed 32 bit
		full_time = {0xAC4, 0},
		lap_time = {0xAB4, 0},
		loaded_track = {0x19B97C, 0}, -- signed 16 bit
		map = {0xC, 0},
		tester = {0x16A38, 0},
	},
	-- maps = {
	-- 	"Test Track",
	-- 	"Whale Lagoon",
	-- 	"Icicle Valley",
	-- 	"Roulette Road",
	-- 	"Studio Amigo",
	-- 	"Shibuya Downtown",
	-- 	"Outer Forest",
	-- 	"Turbine Loop",
	-- 	"Treetops",
	-- 	"Rampart Road",
	-- 	"Dark Arsenal",
	-- 	"Jump Parade",
	-- 	"Pinball Highway",
	-- 	"Sewer Scrapes",
	-- 	"Lost Palace",
	-- 	"Sandy Drifts",
	-- 	"Rokkaku Hill",
	-- 	"Sun Fair",
	-- 	"Highway Zero",
	-- 	"Deadly Route",
	-- 	"Ocean Ruin",
	-- 	"Bingo Party",
	-- 	"Lava Lair",
	-- 	"Monkey Target",
	-- 	"Thunder Deck",
	-- }
};

function Game.getPlayer()
	return dereferencePointer(Game.Memory.player_pointer);
end

function Game.getRNG()
	return mainmemory.read_s32_le(Game.Memory.rng);
end

-- function Game.setMap(value)
-- 	if value >= 1 and value <= #Game.maps then
-- 		mainmemory.write_u16_be(Game.Memory.map, value);
-- 	end
-- end

function Game.getFrames()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + Game.Memory.igf);
	end
	return 0;
end

function Game.getItem()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + Game.Memory.item);
	end
	return "???";
end

function Game.getXPosition()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.x_position);
	end
	return 0;
end

function Game.getYPosition()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.y_position);
	end
	return 0;
end

function Game.getZPosition()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.z_position);
	end
	return 0;
end

function Game.setXPosition(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s1616_le(player + Game.Memory.x_position, value);
	end
end

function Game.setYPosition(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s1616_le(player + Game.Memory.y_position, value);
	end
end

function Game.setZPosition(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s1616_le(player + Game.Memory.z_position, value);
	end
end

function Game.getXVelocity()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.x_velocity);
	end
	return 0;
end

function Game.setXVelocity(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s1616_le(player + Game.Memory.x_velocity, value);
	end
end

function Game.getYVelocity()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.y_velocity);
	end
	return 0;
end

function Game.setYVelocity(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s1616_le(player + Game.Memory.y_velocity, value);
	end
end

function Game.getZVelocity()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.z_velocity);
	end
	return 0;
end

function Game.setZVelocity(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s1616_le(player + Game.Memory.z_velocity, value);
	end
end

function Game.getBaseVelocity()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.base_velocity);
	end
	return 0;
end

function Game.getSideVelocity()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.side_velocity);
	end
	return 0;
end

function Game.getYRotation()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + Game.Memory.y_rotation);
	end
	return "???";
end

function Game.setYRotation(value)
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.write_s32_le(player + Game.Memory.y_rotation, value);
	end
end

function Game.getBoostFlameSize()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + Game.Memory.boost_flame_size);
	end
	return "???";
end

function Game.getBoost()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + Game.Memory.boost);
	end
	return "???";
end

function Game.getAirtime()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + Game.Memory.airtime);
	end
	return "???";
end

function Game.getDeathTimer()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + Game.Memory.death);
	end
	return "???";
end

function Game.getWrongWayTimer()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + Game.Memory.wrong_way);
	end
	return "???";
end

function Game.getTilt()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s16_le(player + Game.Memory.tilt);
	end
	return "???";
end

function Game.getTrackSection()
	return mainmemory.read_s16_le(Game.Memory.loaded_track);
end

function Game.getVelocity()
	local vX = Game.getXVelocity();
	local vY = Game.getYVelocity();
	local vZ = Game.getZVelocity();
	return math.sqrt(vX*vX + vY*vY + vZ*vZ);
end

function Game.getXZVelocity()
	local vX = Game.getXVelocity();
	local vZ = Game.getZVelocity();
	return math.sqrt(vX*vX + vZ*vZ);
end

function Game.getCheckpoint()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_u32_le(player + Game.Memory.checkpoint);
	end
	return "???";
end

function Game.getWheelie()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + Game.Memory.wheelie);
	end
	return "???";
end

function Game.getTest()
	local player = Game.getPlayer();
	if isRAM(player) then
		return mainmemory.read_s1616_le(player + Game.Memory.tester);
	end
	return 0;
end

Game.OSD = {
	{"Player", hexifyOSD(Game.getPlayer, 6)},
	{"Frames", Game.getFrames},
	{"Item", Game.getItem},
	{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"Base Vel", Game.getVelocity},
	{"Forward Vel", Game.getBaseVelocity},
	{"X Vel", Game.getXVelocity}, {"Y Vel", Game.getYVelocity}, {"Z Vel", Game.getZVelocity},
	{"XZ Vel", Game.getXZVelocity},
	{"Side Vel", Game.getSideVelocity},
	{"Separator"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Separator"},
	{"Facing Angle", Game.getYRotation},
	{"Tilt", Game.getTilt},
	{"Wheelie", Game.getWheelie},
	{"Boost", Game.getBoost},
	{"Boost-Charge", Game.getBoostFlameSize},
	{"Separator"},
	{"Checkpoint", Game.getCheckpoint},
	{"Airtime", Game.getAirtime},
	{"Respawn-Timer", Game.getDeathTimer},
	{"Wrong Way", Game.getWrongWayTimer},
	{"Separator"},
	{"RNG", hexifyOSD(Game.getRNG, 7)},
	{"Track Section", Game.getTrackSection},
	-- {"Test", Game.getTest},
};

return Game;
