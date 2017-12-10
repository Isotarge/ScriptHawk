if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		round = 0x20,
		lives = 0x16,
		straw_effigies = 0x18,
		money_bags = 0x19,
		psycho_sticks = 0x1A,
		magic_medicine = 0x1B,
		x_position = 0x30, -- 3 byte sub.minor.major
		y_position = 0x33, -- 3 byte sub.minor.major
		x_velocity = 0x204, -- signed fixed point 8.8 little endian
		y_velocity = 0x206, -- signed fixed point 8.8 little endian
		jump_x_velocity = 0x208, -- signed fixed point 8.8 little endian
	},
	max_velocity = 2.5,
	maps = {
		"1-1", -- 0x00
		"1-2",
		"1-3",
		"2-1",
		"2-2",
		"2-3",
		"3-1",
		"3-2",
		"3-3",
		"4-1",
		"4-2",
		"4-3",
		"5-1",
		"5-2",
		"5-3",
		"6-1",
		"6-2", -- 0x10
		"6-3",
		"7-1",
		"7-2",
		"7-3",
		"Warp Entry",
	}
};

function Game.setMap(value)
	mainmemory.writebyte(Game.Memory.round, value - 1);
end

function Game.readPosition(base)
	local sub = mainmemory.readbyte(base + 0);
	local minor = mainmemory.readbyte(base + 1);
	local major = mainmemory.readbyte(base + 2);
	return (major * 256) + minor + (sub / 256);
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.lives, 9);
	mainmemory.writebyte(Game.Memory.straw_effigies, 9);
	mainmemory.writebyte(Game.Memory.money_bags, 9);
	mainmemory.writebyte(Game.Memory.psycho_sticks, 9);
	mainmemory.writebyte(Game.Memory.magic_medicine, 9);
end

function Game.fixAcceleration()
	local inputs = joypad.get();
	if inputs['P1 Left'] or inputs['P1 Right'] then
		Game.setXVelocity(Game.max_velocity);
		Game.setJumpXVelocity(Game.max_velocity);
	else
		Game.setXVelocity(0);
		Game.setJumpXVelocity(0);
	end
end

function Game.getLives()
	return mainmemory.readbyte(Game.Memory.lives);
end

function Game.getRound()
	local round = mainmemory.readbyte(Game.Memory.round);
	if type(Game.maps[round + 1]) == "string" then
		return Game.maps[round + 1];
	end
	return "Unknown "..toHexString(round);
end

function Game.getXPosition()
	return Game.readPosition(Game.Memory.x_position);
end

function Game.getYPosition()
	return Game.readPosition(Game.Memory.y_position);
end

function Game.getXVelocity()
	return mainmemory.read_s16_le(Game.Memory.x_velocity) / 256;
end

function Game.setXVelocity(value)
	mainmemory.write_s16_le(Game.Memory.x_velocity, value * 256);
end

function Game.getJumpXVelocity()
	return mainmemory.read_s16_le(Game.Memory.jump_x_velocity) / 256;
end

function Game.setJumpXVelocity(value)
	mainmemory.write_s16_le(Game.Memory.jump_x_velocity, value * 256);
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(Game.Memory.y_velocity) / 256;
end

function Game.eachFrame()
	if forms.ischecked(ScriptHawk.UI.form_controls["Fix Acceleration Checkbox"]) then
		Game.fixAcceleration();
	end
end

function Game.initUI()
	ScriptHawk.UI.form_controls["Fix Acceleration Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Fix Acceleration", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);
end

Game.OSDPosition = {2, 70};
Game.OSD = {
	{"Round", Game.getRound},
	{"Lives", Game.getLives},
	{"Separator", 1},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"dX"},
	{"dY"},
};

return Game;