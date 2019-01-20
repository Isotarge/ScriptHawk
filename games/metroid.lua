if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		frame_rule = 0x2C,
		frame_rule_2 = 0x29,
		frame_rule_3 = 0x2D,
		door_timer = 0x3BF,
		x_position = 0x30E, x_position_sub = 0x311,
		y_position = 0x30D, y_position_sub = 0x310,
		x_velocity = 0x309, x_velocity_sub = 0x313,
		y_velocity = 0x308, y_velocity_sub = 0x312,
		screen_y = 0xFC,
	},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.getXPosition()
	return mainmemory.readbyte(Game.Memory.x_position) + mainmemory.readbyte(Game.Memory.x_position_sub) / 256;
end

function Game.getYPosition()
	return mainmemory.readbyte(Game.Memory.y_position) + mainmemory.readbyte(Game.Memory.y_position_sub) / 256;
end

function Game.getXVelocity()
	return mainmemory.read_s8(Game.Memory.x_velocity) + mainmemory.readbyte(Game.Memory.x_velocity_sub) / 256;
end

function Game.getYVelocity()
	return mainmemory.read_s8(Game.Memory.y_velocity) + mainmemory.readbyte(Game.Memory.y_velocity_sub) / 256;
end

function Game.getScreenY()
	return mainmemory.readbyte(Game.Memory.screen_y);
end

function Game.getFrameRule()
	return mainmemory.readbyte(Game.Memory.frame_rule);
end

function Game.getFrameRule2()
	return mainmemory.readbyte(Game.Memory.frame_rule_2);
end

function Game.getFrameRule3()
	return mainmemory.readbyte(Game.Memory.frame_rule_3);
end

function Game.getDoorTimer()
	return mainmemory.readbyte(Game.Memory.door_timer);
end

Game.OSD = {
	{"Screen Y", Game.getScreenY, category="screenPosition"},
	{"X", category="position"},
	{"Y", category="position"},
	{"X Velocity", Game.getXVelocity, category="speed"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"dX", category="positionStats"},
	{"dY", category="positionStats"},
	{"Separator"},
	{"Frame Rule", Game.getFrameRule, category="frameRule"},
	{"Frame Rule", Game.getFrameRule2, category="frameRule"},
	{"Frame Rule", Game.getFrameRule3, category="frameRule"},
	{"Door Timer", Game.getDoorTimer, category="doorTimer"},
};

return Game;