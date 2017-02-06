if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 },
	speedy_index = 7,
	rot_speed = 100,
	max_rot_units = 65535,
	Memory = { -- Version order: N64 USA, N64 PAL
		["cheat_base"] = {0x11648C, 0x118E84},
		["number_of_cheats"] = {22, 24},
		["velocity"] = {0x14A298, 0x170D70},
		["x_position"] = {0x14A47C, 0x170F54},
		["y_position"] = {0x14A480, 0x170F58},
		["z_position"] = {0x14A484, 0x170F5C},
	},
};

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	if romHash == "3F99351D7BB61656614BDB2AA1A90CFE55D1922C" then -- N64 USA
		version = 1;
	elseif romHash == "61373D4758ECA3FA831BEAC27B4D4C250845F80C" then -- N64 PAL
		version = 2;
	else
		return false;
	end

	return true;
end

function Game.unlockCheats()
	for i = 1, Game.Memory.number_of_cheats[version] do
		mainmemory.writebyte(Game.Memory.cheat_base[version] + i - 1, 0x01);
	end
end

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
	return mainmemory.writefloat(Game.Memory.x_position[version], value, true);
end

function Game.setYPosition(value)
	return mainmemory.writefloat(Game.Memory.y_position[version], value, true);
end

function Game.setZPosition(value)
	return mainmemory.writefloat(Game.Memory.z_position[version], value, true);
end

function Game.getVelocity()
	return mainmemory.readfloat(Game.Memory.velocity[version], true);
end

function Game.setVelocity(value)
	return mainmemory.writefloat(Game.Memory.velocity[version], value, true);
end

function Game.initUI()
	ScriptHawk.UI.form_controls["Unlock Cheats Button"] = forms.button(ScriptHawk.UI.options_form, "Unlock Cheats", Game.unlockCheats, ScriptHawk.UI.col(10), ScriptHawk.UI.row(0), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
end

Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"Velocity", Game.getVelocity},
	{"dY"},
	{"dXZ"},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
	{"Rot. X", Game.getXRotation},
	{"Facing", Game.getYRotation},
	{"Rot. Z", Game.getZRotation},
};

return Game;