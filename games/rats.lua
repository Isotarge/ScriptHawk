if type(ScriptHawk) ~= "table" then -- An error message to inform the user that this is a game module, not a standalone script
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {}; -- This table stores the module's API function implementations and game state, it's returned to ScriptHawk at the end of the module code
object_size = 0x16;
row_height = 16;

--------------------
-- Region/Version --
--------------------

Game.Memory = {
	["x_position"] = {0x01EE},
	["y_position"] = {0x01F4},
	["x_velocity"] = {0x01F2},
	["y_velocity"] = {0x01F8},
	["object_base"] = {0x01EC},
};

function Game.detectVersion(romName, romHash) -- Modules should ideally use ROM hash rather than name, but both are passed in by ScriptHawk
	if string.contains(romHash, "5E423DFAB8221B69A641D2E535EBFE1E3759A2E4") then
		version = 1;
		return true;
	end
	return false; -- Return false if this version of the game is not supported
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 }; -- D-Pad speeds, scale these appropriately with your game's coordinate system
Game.speedy_index = 7;

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.read_u16_le(Game.Memory.x_position[version]);
end

function Game.getYPosition()
	return mainmemory.read_u16_le(Game.Memory.y_position[version]);
end

function Game.getXVelocity()
	return mainmemory.read_s16_le(Game.Memory.x_velocity[version]);
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(Game.Memory.y_velocity[version]);
end

function Game.setXPosition(value)
	mainmemory.write_u16_le(Game.Memory.x_position[version], value);
end

function Game.setYPosition(value)
	mainmemory.write_u16_le(Game.Memory.y_position[version], value);
end

------------
-- Events --
------------

function Game.drawUI() -- Optional: This function will be executed once per frame
	for i = 0, 24 do
		local objectBase = Game.Memory.object_base[version] + i * object_size;
		local xPos = mainmemory.read_u16_le(objectBase + 0x02);
		local yPos = mainmemory.read_u16_le(objectBase + 0x08);
		local xVel = mainmemory.read_s16_le(objectBase + 0x06);
		local yVel = mainmemory.read_s16_le(objectBase + 0x0C);

		gui.text(2, i * row_height, "X:"..xPos..", Y:"..yPos..", X Velocity:"..xVel..", Y Velocity:"..yVel, 0xFFFFFFFF, "bottomright");
	end
end

Game.OSDPosition = {2, 70};
Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Separator", 1},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"dX"},
	{"dY"},
	{"Separator", 1},
	{"Max dX"},
	{"Max dY"},
	{"Odometer"},
};

return Game; -- Return your Game table to ScriptHawk