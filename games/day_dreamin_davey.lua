if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		screen_x_major = 0x13,
		screen_y_major = 0x14,
		screen_x = 0x15,
		screen_y = 0x16,
		player_screen_x = 0x63,
		player_screen_y = 0x64,
		health = 0x67,
	},
};

function Game.getScreenX()
	return mainmemory.read_s8(Game.Memory.screen_x_major) * 256 + mainmemory.readbyte(Game.Memory.screen_x);
end

function Game.getScreenY()
	return mainmemory.read_s8(Game.Memory.screen_y_major) * 256 + mainmemory.readbyte(Game.Memory.screen_y);
end

function Game.getXPosition()
	return mainmemory.readbyte(Game.Memory.player_screen_x);
end

function Game.getYPosition()
	return mainmemory.readbyte(Game.Memory.player_screen_y);
end

function Game.getHealth()
	return mainmemory.readbyte(Game.Memory.health);
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.health, 0xFF);
end

Game.OSD = {
	{"Health", Game.getHealth},
	{"Separator"},
	{"Screen X", Game.getScreenX},
	{"Screen Y", Game.getScreenY},
	{"Separator"},
	{"X"},
	{"Y"},
	{"Separator"},
	{"dY"},
	{"dXZ"},
};

return Game;