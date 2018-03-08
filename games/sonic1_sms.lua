if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		in_score_screen = 0x1207,
		level = 0x123E,
		rings = 0x12AA, -- byte, BCD
		lives = 0x1246,
		viewport_x = 0x125A,
		viewport_x2 = 0x126F,
		viewport_y = 0x125D,
		viewport_y2 = 0x1271,
		x_position = 0x13FD, -- 3 bytes sub.min.maj
		y_position = 0x1400, -- 3 bytes sub.min.maj
		x_velocity = 0x1403, -- 3 bytes sub.min.maj
		y_velocity = 0x1406, -- 3 bytes sub.min.maj
		igt = 0x12CE, -- 3 bytes: min(BCD):sec(BCD).frame
		invuln_timer = 0x128D,
		speed_shoes_timer = 0x1411,
	},
	maps = {
		"Green Hill 1", -- 0x00
		"Green Hill 2",
		"Green Hill 3",
		"Bridge 1",
		"Bridge 2",
		"Bridge 3",
		"Jungle 1",
		"Jungle 2",
		"Jungle 3",
		"Labyrinth 1",
		"Labyrinth 2",
		"Labyrinth 3",
		"Scrap Brain 1",
		"Scrap Brain 2",
		"Scrap Brain 3",
		"Sky Base 1",
		"Sky Base 2", -- 0x10
		"Sky Base 3",
		"Ending",
		"Ending (Part 2)",
		"Scrap Brain (Room 1)",
		"Scrap Brian (Room 2)",
		"Scrap Brain (Room 3)",
		"Scrap Brain (Room 4)",
		"Scrap Brain (Room 5)",
		"Scrap Brain (Room 6)",
		"Sky Base 2 (Interior)",
		"Sky Base 2 (Interior)",
		"Special Stage 1",
		"Special Stage 2",
		"Special Stage 3",
		"Special Stage 4",
		"Special Stage 5", -- 0x20
		"Special Stage 6",
		"Special Stage 7",
		"Special Stage 8",
		"Credits",
	},
};

function Game.setMap(value)
	mainmemory.writebyte(Game.Memory.level, value - 1);
end

function Game.read_u16_8(base)
	local major = mainmemory.read_u16_le(base + 1);
	local sub = mainmemory.readbyte(base) / 256;
	return major + sub;
end

function Game.read_s16_8(base)
	local major = mainmemory.read_s16_le(base + 1);
	local sub = mainmemory.readbyte(base) / 256;
	return major + sub;
end

function Game.getIGT()
	local mins = mainmemory.readbyte(Game.Memory.igt + 0);
	local secs = mainmemory.readbyte(Game.Memory.igt + 1);
	local frames = mainmemory.readbyte(Game.Memory.igt + 2);
	return toHexString(mins, 1, "")..":"..toHexString(secs, 2, "").."."..string.lpad(frames, 2, '0');
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.applyInfinites()
	if bit.band(mainmemory.readbyte(Game.Memory.in_score_screen), 0x01) == 0 then
		mainmemory.writebyte(Game.Memory.lives, 99);
		mainmemory.writebyte(Game.Memory.rings, 0x1);
	end
end

function Game.getLives()
	return mainmemory.readbyte(Game.Memory.lives);
end

function Game.getRings()
	return mainmemory.readbyte(Game.Memory.rings);
end

function Game.getLevel()
	local level = mainmemory.readbyte(Game.Memory.level);
	return Game.maps[level + 1] or "Unknown "..toHexString(level);
end

function Game.getViewportX()
	return mainmemory.read_u16_le(Game.Memory.viewport_x);
end

function Game.getViewportY()
	return mainmemory.read_u16_le(Game.Memory.viewport_y);
end

function Game.getXPosition()
	return Game.read_u16_8(Game.Memory.x_position);
end

function Game.getYPosition()
	return Game.read_u16_8(Game.Memory.y_position);
end

function Game.getXVelocity()
	return Game.read_s16_8(Game.Memory.x_velocity);
end

function Game.getYVelocity()
	return Game.read_s16_8(Game.Memory.y_velocity);
end

function Game.camHack()
	local playerX = Game.getXPosition();
	local playerY = Game.getYPosition();
	local adjustedXPosition = math.max(0, playerX + -128);
	local adjustedYPosition = math.max(0, playerY + -75);
	mainmemory.write_u16_le(Game.Memory.viewport_x, adjustedXPosition);
	--mainmemory.write_u16_le(Game.Memory.viewport_x2, adjustedXPosition);
	mainmemory.write_u16_le(Game.Memory.viewport_y, adjustedYPosition);
	--mainmemory.write_u16_le(Game.Memory.viewport_y2, adjustedYPosition);
end

function Game.eachFrame()
	if forms.ischecked(ScriptHawk.UI.form_controls["CamHack Checkbox"]) then
		Game.camHack();
	end
end

function Game.initUI()
	ScriptHawk.UI.checkbox(0, 6, "CamHack Checkbox", "CamHack (Beta)");
end

Game.OSDPosition = {2, 70};
Game.OSD = {
	{"Level", Game.getLevel},
	{"IGT", Game.getIGT},
	{"Lives", Game.getLives},
	{"Rings", hexifyOSD(Game.getRings, nil, "")},
	{"Viewport X", Game.getViewportX},
	{"Viewport Y", Game.getViewportY},
	{"Separator"},
	{"X"},
	{"Y"},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"dX"},
	{"dY"},
};

return Game;