if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	squish_memory_table = true,
	Memory = { -- Version order: Europe, USA
		exit = {0x0BE800, 0x0BE3E0}, -- byte
		current_map = {0x0BEE12, 0x0BE9F2}, -- u16_be
		destination_map = {0x0BEE16, 0x0BE9F6}, -- u16_be
		previous_map = {0x0BEE1A, 0x0BE9FA}, --u16_be
		health = {0x0CC8BA,0x0CC49A}, -- u8
		x_position = {0x0CC704, 0x0CC2E4}, -- Float
		y_position = {0x0CC708, 0x0CC2E8}, -- Float
		z_position = {0x0CC70C, 0x0CC2EC}, -- Float
		y_velocity = {0x0CC710, 0x0CC2F0}, -- Float
		velocity = {0x0CC72C, 0x0CC30C}, -- Float
		moving_angle = {0x0CC766, 0x0CC346}, -- u16_be
		facing_angle = {0x0CC76A, 0x0CC34A}, -- u16_be
		wealth = {nil, 0x0D2148}, -- u32_be
	},
	maps = {
		"Windy: Cow Field",
		"Barn Boys: Inside Barn",
		"Uga Buga: Outside Rock Solid",
		"!Unknown 0x03", -- Bulldog, B&W?
		"It's War: Beach",
		"Beta: Black Room",
		"Windy: Day",
		"Bat's Tower: River",
		"Beta: Unused Texture (0x8)",
		"!Unknown 0x9", -- B&W, similar to Map 3
		"Bat's Tower: Boiler Room",
		"Bat's Tower: Cog Room",
		"Barn Boys: Outside the Barn",
		"!Crash 0xD",
		"It's War: Tank Field",
		"Beta: Raptor Arena",
		"Barn Boys: Haybot Fight (Tower)",
		"!Unknown 0x11",
		"Bat's Tower: Safe",
		"It's War: Pier",
		"Uga Buga: Arena",
		"!Unknown 0x15", -- B&W, similar ot Map 3
		"Beta: Tank Room", -- Tank Room
		"Bat's Tower: Safe (Underwater)",
		"The Panther King's Lair",
		"Uga Buga: Lava Waterfall",
		"Multiplayer: Heist",
		"It's War: Laser Tunnels",
		"It's War: Pond",
		"The Cock and Plucker", -- Also Berri's House
		"It's War: Laser Tunnels II",
		"!Unknown 0x1F",
		"Beta: Unused Texture (0x20)",
		"Nintendo 64 Logo",
		"Gregg's Underworld",
		"It's War: The Experiment",
		"Multiplayer: Tank",
		"Nintendo Logo", -- Boot up
		"It's War: Gun Tunnels",
		"Windy: Beehive",
		"It's War: Escape Tunnels",
		"Hungover: Field",
		"!Unknown 0x2A",
		"Multiplayer: Beach",
		"Windy: The Beetle Tower",
		"Multiplayer: War",
		"Hungover: Key Chamber",
		"It's War: Operating Room",
		"Multiplayer: Colors",
		"Uga Buga: Rock Solid",
		"Uga Buga: Race",
		"Multiplayer: Race",
		"Multiplayer: Bunker",
		"Sloprano: The Great Mighty Poo",
		"Heist: Feral Reserve (Lobby)",
		"Sloprano: Water Caverns",
		"Heist: Boardroom",
		"Heist: Outside Feral Reserve",
		"Hiest: Feral Reserve (Safe)",
		"Windy: Night",
		"Spooky: Haunted Castle",
		"Spooky: Haunted Castle Exterior",
		"!Unknown 0x3E",
		"Multiplayer: Raptor",
		"Heist: Feral Reserve (Final Boss)",
		"Spooky: Flooded Mineshafts",
		"Uga Buga: Tribe Room (Fossil)",
		"Uga Buga: Tribe Room",
		"Uga Buga: Tribe Room (Lava)",
	},
	takeMeThereStyle = "Checkbox",
};

function Game.setMap(value)
	mainmemory.write_u16_be(Game.Memory.destination_map, value - 1);
end

function Game.getMap()
	local map_value = mainmemory.read_u16_be(Game.Memory.current_map);
	if Game.maps[map_value + 1] ~= nil then
		return Game.maps[map_value + 1];
	end
	return "Unknown (0x"..bizstring.hex(map_value)..")"
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
	return mainmemory.readfloat(Game.Memory.x_position, true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_position, true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_position, true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(Game.Memory.x_position, value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.y_position, value, true);
	Game.setYVelocity(0);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_position, value, true);
end

function Game.getVelocity()
	return mainmemory.readfloat(Game.Memory.velocity, true);
end

function Game.setVelocity(value)
	return mainmemory.writefloat(Game.Memory.velocity, value, true);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity, true);
end

function Game.setYVelocity(value)
	return mainmemory.writefloat(Game.Memory.y_velocity, value, true);
end

--------------
-- Rotation --
--------------

Game.rot_speed = 16;
Game.max_rot_units = 0xFFFF;

function Game.getYRotation()
	return (mainmemory.read_u16_be(Game.Memory.moving_angle) + Game.max_rot_units / 4) % Game.max_rot_units; -- TODO: Fix this for all modules with a dpad angle offset
end

function Game.setYRotation(value)
	mainmemory.write_u16_be(Game.Memory.moving_angle, (value - Game.max_rot_units / 4) % Game.max_rot_units);
end

------------
-- Events --
------------

Game.OSD = {
	{"Map", Game.getMap},
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Velocity", Game.getVelocity, category="speed"};
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"},
	--{"Rot. X", Game.getXRotation, category="angleMore"},
	{"Moving", Game.getYRotation, category="angle"},
	--{"Rot. Z", Game.getZRotation, category="angleMore"},
};

return Game;