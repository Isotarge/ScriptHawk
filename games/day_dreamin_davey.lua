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

function Game.setXPosition(value)
	mainmemory.writebyte(Game.Memory.player_screen_x, value);
end

function Game.setYPosition(value)
	mainmemory.writebyte(Game.Memory.player_screen_y, value);
end

function Game.getHealth()
	return mainmemory.readbyte(Game.Memory.health);
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.health, 0xFF);
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

--------------------------------------
-- Tests for ScriptHawk.setInterval --
--------------------------------------

local function setIntervalCallback(calledCount)
	if calledCount % 2 == 0 then
		Game.setXPosition(Game.getXPosition() - 20);
	else
		Game.setXPosition(Game.getXPosition() + 20);
	end
end

local function clearIntervalTest()
	ScriptHawk.clearInterval("Wiggle");
	ScriptHawk.clearInterval("Wiggle (Offset 15)");
end

local function setIntervalTest()
	clearIntervalTest(); -- Make sure we don't add duplicate callbacks
	ScriptHawk.setInterval(setIntervalCallback, 30, "Wiggle");
	ScriptHawk.setInterval(setIntervalCallback, 30, "Wiggle (Offset 15)", 15);
end

-------------------------------------
-- Tests for ScriptHawk.setTimeout --
-------------------------------------

local function setTimeoutCallback() 
	Game.setXPosition(Game.getXPosition() - 20);
end

local function clearTimeoutTest()
	ScriptHawk.clearTimeout("Timeout Test");
end

local function setTimeoutTest()
	clearTimeoutTest(); -- Make sure we don't add duplicate callbacks
	ScriptHawk.setTimeout(setTimeoutCallback, 30, "Timeout Test");
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI:button(0, 2, 4, nil, nil, "Interval", setIntervalTest);
		ScriptHawk.UI:button(4.5, 2, 4, nil, nil, "Clear Interval", clearIntervalTest);
		ScriptHawk.UI:button(0, 3, 4, nil, nil, "Timeout", setTimeoutTest);
		ScriptHawk.UI:button(4.5, 3, 4, nil, nil, "Clear Timeout", clearTimeoutTest);
	end
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