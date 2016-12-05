local Game = {};

--------------------
-- Region/Version --
--------------------

Game.Memory = { -- Version order: Europe, USA
	["x_position"] = {0x0CC704, 0x0CC2E4}, -- Float
	["y_position"] = {0x0CC708, 0x0CC2E8}, -- Float
	["z_position"] = {0x0CC70C, 0x0CC2EC}, -- Float
	["y_velocity"] = {0x0CC710, 0x0CC2F0}, -- Float
	["velocity"] = {0x0CC72C, 0x0CC30C}, -- Float
	["moving_angle"] = {0x0CC766, 0x0CC346}, -- u16_be
	["facing_angle"] = {0x0CC76A, 0x0CC34A}, -- u16_be
	["map"] = {0x0BE7FE, 0x0BE3DE}, -- u16_be
	["exit"] = {0x0BE800, 0x0BE3E0}, -- byte
};

Game.takeMeThereStyle = "Checkbox";
Game.maps = {
	"Barn",
	"Rock Solid - bar. Outside.",
	"FREEZE 0x03",
	"Beach",
	"Black - but intro",
	"nasty/nice spot",
	"leading to ship?",
	"weird texture ?",
	"weird texture ?",
	"Boiler. At spot when you piss on guys.",
	"Water near cogs.",
	"Barn Boys level",
	"FREEZE",
	"War - Area with tank",
	"Raptor arena (with raptor, but with gun shots) no background",
	"Electrical room at top of Haybot Second Battle Spot",
	"FREEZE 0x11",
	"Inside water of safe",
	"Beginning spot of War",
	"Raptor arena",
	"FREEZE 0x15",
	"FREEZE 0x16",
	"Water in safe",
	"Intro",
	"Prehistoric (dinosaurs parolling fort)",
	"Heist (multi)",
	"War lasers",
	"War part w/ Rodent",
	"Inside Pub (Cock and Plucker)",
	"War - lasers",
	"beta area ??? Berri's house?",
	"beta area (no bg)",
	"Ncube Massacre intro",
	"Greggs room",
	"War - Fighting tedi boss and subs",
	"Tank (multi)",
	"Audio info",
	"Room with conveyor belt (master plan)",
	"Bee hive",
	"Escaping Tedi Boss",
	"Starting level",
	"FREEZE 0x2A",
	"Beach (Multi)",
	"Beetles house",
	"War arena (Multi)",
	"Inside Cave with key (first level)",
	"War - Operating room",
	"Multi-area",
	"Rock Solid bar",
	"Beginning spot of race",
	"Race (multi)",
	"Multi-area",
	"The Poo Boss",
	"Inside Feral Reserve - beginning",
	"Poo Slicers",
	"Meeting place of Weasels? You can't play here normally.",
	"Outside Feral Reserve - Signs",
	"Inside Feral Reserve - in safe",
	"Nasty/Nice area - night",
	"Haunted Castle",
	"Path leading to Haunted Castle",
	"FREEZE 0x3E",
	"Raptor (multi)",
	"Inside Feral Reserve - Final Boss",
	"Spooky - flooded mineshafts",
	"Slimy passage - Phlegm",
	"Inside Prehistoric --> 44",
	"Inside Prehistoric --> 32",
};

function Game.setMap(value)
	mainmemory.write_u16_be(Game.Memory.map[version], value);
end

function Game.detectVersion(romName, romHash)
	if romHash == "EE7BC6656FD1E1D9FFB3D19ADD759F28B88DF710" then -- Europe
		version = 1;
		return true;
	elseif romHash == "4CBADD3C4E0729DEC46AF64AD018050EADA4F47A" then -- USA
		version = 2;
		return true;
	end

	return false;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100, 200 };
Game.speedy_index = 8;

function Game.isPhysicsFrame()
	return not emu.islagged(); -- TODO: Research lag in this game
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.x_position[version], true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_position[version], true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_position[version], true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(Game.Memory.x_position[version], value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.y_position[version], value, true);
	Game.setYVelocity(0);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_position[version], value, true);
end

function Game.getVelocity()
	return mainmemory.readfloat(Game.Memory.velocity[version], true);
end

function Game.setVelocity(value)
	return mainmemory.writefloat(Game.Memory.velocity[version], value, true);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity[version], true);
end

function Game.setYVelocity(value)
	return mainmemory.writefloat(Game.Memory.y_velocity[version], value, true);
end

--------------
-- Rotation --
--------------

Game.rot_speed = 16;
Game.max_rot_units = 0xFFFF;

function Game.getYRotation()
	return (mainmemory.read_u16_be(Game.Memory.moving_angle[version]) + Game.max_rot_units / 4) % Game.max_rot_units; -- TODO: Fix this for all modules with a dpad angle offset
end

function Game.setYRotation(value)
	mainmemory.write_u16_be(Game.Memory.moving_angle[version], (value - Game.max_rot_units / 4) % Game.max_rot_units);
end

------------
-- Events --
------------

Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"dY"},
	{"dXZ"},
	{"Velocity", Game.getVelocity};
	{"Y Velocity", Game.getYVelocity},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
	--{"Rot. X", Game.getXRotation},
	{"Moving", Game.getYRotation},
	--{"Rot. Z", Game.getZRotation},
};

return Game;