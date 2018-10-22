if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	squish_memory_table = true,
	Memory = { -- Version order: France, Europe, USA, German 1.1, German 1.0
		global_timer = {0x0A3A00, 0x0A3360, 0x0A3040, 0x0A3A20, 0x0A3A00}, -- u32_be
		x_position = {0x0BBB40, 0x0BB460, 0x0BB070, 0x0BBB60, 0x0BBB40}, -- s32_be
		y_position = {0x0BBB44, 0x0BB464, 0x0BB074, 0x0BBB64, 0x0BBB44}, -- s32_be
		z_position = {0x0BBB48, 0x0BB468, 0x0BB078, 0x0BBB68, 0x0BBB48}, -- s32_be
		facing_angle = {0x0BBB88, 0x0BB4A8, 0x0BB0B8, 0x0BBBA8, 0x0BBB88}, -- u16_be
	},
	speedy_speeds = { 100, 1000, 2000, 5000, 7500, 10000, 20000, 50000, 100000 },
	speedy_index = 4,
	speedy_invert_LR = true,
	speedy_invert_Y = true,
	rot_speed = 10,
	max_rot_units = 4096,
};

-------------------
-- Physics/Scale --
-------------------

local global_timer = {
	previous = -1,
	current = -1,
};

function Game.isPhysicsFrame()
	return global_timer.current ~= global_timer.previous;
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.read_s32_be(Game.Memory.x_position);
end

function Game.getYPosition()
	return mainmemory.read_s32_be(Game.Memory.y_position);
end

function Game.getZPosition()
	return mainmemory.read_s32_be(Game.Memory.z_position);
end

function Game.setXPosition(value)
	mainmemory.write_s32_be(Game.Memory.x_position, value);
end

function Game.setYPosition(value)
	mainmemory.write_s32_be(Game.Memory.y_position, value);
end

function Game.setZPosition(value)
	mainmemory.write_s32_be(Game.Memory.z_position, value);
end

--------------
-- Rotation --
--------------

function Game.getYRotation()
	return mainmemory.read_u16_be(Game.Memory.facing_angle);
end

function Game.setYRotation(value)
	mainmemory.write_u16_be(Game.Memory.facing_angle, value);
end

function Game.eachFrame()
	global_timer.previous = global_timer.current;
	global_timer.current = mainmemory.read_u32_be(Game.Memory.global_timer);
end

Game.OSD = {
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"},
	{"Facing", Game.getYRotation, category="angle"},
};

return Game;