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
	},
};
object_size = 0x16;
row_height = 16;

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	if string.contains(romHash, "5E423DFAB8221B69A641D2E535EBFE1E3759A2E4") then
		version = 1;
		return true;
	end
	return false;
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.read_u16_le(Game.Memory.x_position);
end

function Game.getYPosition()
	return mainmemory.read_u16_le(Game.Memory.y_position);
end

function Game.getXVelocity()
	return mainmemory.read_s16_le(Game.Memory.x_velocity);
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(Game.Memory.y_velocity);
end

function Game.setXPosition(value)
	mainmemory.write_u16_le(Game.Memory.x_position, value);
end

function Game.setYPosition(value)
	mainmemory.write_u16_le(Game.Memory.y_position, value);
end

------------
-- Events --
------------

function Game.drawUI()
	for i = 0, 24 do
		local objectBase = Game.Memory.object_base + i * object_size;
		local xPos = mainmemory.read_u16_le(objectBase + 0x02);
		local yPos = mainmemory.read_u16_le(objectBase + 0x08);
		local xVel = mainmemory.read_s16_le(objectBase + 0x06);
		local yVel = mainmemory.read_s16_le(objectBase + 0x0C);

		gui.text(2, i * row_height, "X:"..xPos..", Y:"..yPos..", X Velocity:"..xVel..", Y Velocity:"..yVel, colors.white, "bottomright");
	end
end

Game.OSD = {
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