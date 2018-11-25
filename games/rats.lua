if type(ScriptHawk) ~= "table" then -- An error message to inform the user that this is a game module, not a standalone script
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		x_position = 0x01EE,
		y_position = 0x01F4,
		x_velocity = 0x01F2,
		y_velocity = 0x01F8,
		object_base = 0x01EC,
		igt_major = 0x19EB,
		igt_minor = 0x19E9,
	},
	object_size = 0x16,
	position_scale = 0x10,
};

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.read_u16_le(Game.Memory.x_position) / Game.position_scale;
end

function Game.getYPosition()
	return mainmemory.read_u16_le(Game.Memory.y_position) / Game.position_scale;
end

function Game.getXVelocity()
	return mainmemory.read_s16_le(Game.Memory.x_velocity) / Game.position_scale;
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(Game.Memory.y_velocity) / Game.position_scale;
end

function Game.setXPosition(value)
	mainmemory.write_u16_le(Game.Memory.x_position, value * Game.position_scale);
end

function Game.setYPosition(value)
	mainmemory.write_u16_le(Game.Memory.y_position, value * Game.position_scale);
end

function Game.getIGT()
	return mainmemory.readbyte(Game.Memory.igt_major) + mainmemory.readbyte(Game.Memory.igt_minor) / 256;
end

function Game.setIGT(value)
	mainmemory.writebyte(Game.Memory.igt_major, math.floor(value));
	mainmemory.writebyte(Game.Memory.igt_minor, (value * 256) % 256);
end

function Game.applyInfinites()
	Game.setIGT(20.01); -- 20 freezes the timer
end

------------
-- Events --
------------

function Game.drawUI()
	local row = 0;
	for i = 0, 23 do
		local objectBase = Game.Memory.object_base + i * Game.object_size;
		local objectEnabled = bit.check(mainmemory.readbyte(objectBase), 0); -- Possibly object type
		if objectEnabled then
			local xPos = mainmemory.read_u16_le(objectBase + 0x02) / Game.position_scale;
			local yPos = mainmemory.read_u16_le(objectBase + 0x08) / Game.position_scale;
			local xVel = mainmemory.read_s16_le(objectBase + 0x06) / Game.position_scale;
			local yVel = mainmemory.read_s16_le(objectBase + 0x0C) / Game.position_scale;

			gui.text(2, row * Game.OSDRowHeight, "X:"..round(xPos, precision)..", Y:"..round(yPos, precision)..", XVel:"..round(xVel, precision)..", YVel:"..round(yVel, precision).." - "..toHexString(objectBase), colors.white, "bottomright");
			row = row + 1;
		end
	end
end

Game.OSD = {
	{"IGT", Game.getIGT, category="IGT"},
	{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"Separator"},
	{"X Velocity", Game.getXVelocity, category="speed"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"dX", category="positionStats"},
	{"dY", category="positionStats"},
	{"Separator"},
	{"Max dX", category="positionStatsMore"},
	{"Max dY", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
};

return Game;