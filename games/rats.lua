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
	-- Lua has a maximum of 200 local variables per function, we use a table to store memory addresses to get around this
	-- It's a 2 dimensional table, the first dimension is the name of the address
	-- the second dimension is an index for which version of the game was detected, set below by Game.detectVersion()
	-- Examples of how to access the memory address for X Position:
		-- Game.Memory.x_position[version] -- Preferred
		-- Game.Memory["x_position"][version]
		-- Game["Memory"]["x_position"][version]
	["x_position"] = {0x01EE, 0x200000}, -- Example addresses
	["y_position"] = {0x01F4, 0x200004},
	["x_velocity"] = {0x01F2, 0x200010},
    ["y_velocity"] = {0x01F8, 0x200004},
    ["object_base"] = {0x01EC, 0x200004},
	["map_index"] = {0x10000C, 0x20000C},
};

function Game.detectVersion(romName, romHash) -- Modules should ideally use ROM hash rather than name, but both are passed in by ScriptHawk
	if string.contains(romHash, "5E423DFAB8221B69A641D2E535EBFE1E3759A2E4") then -- string.contains is a pure Lua global function provided by ScriptHawk, intended to replace calls to bizstring.contains() for portability reasons
		version = 1; -- We use the version variable as an index for the Game.Memory table
	elseif string.contains(romHash, "Europe") then
		version = 2;
	else
		return false; -- Return false if this version of the game is not supported
	end

	return true; -- Return true if version detection is successful
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 }; -- D-Pad speeds, scale these appropriately with your game's coordinate system
Game.speedy_index = 7;

function Game.isPhysicsFrame() -- Optional: If lag in your game is more complicated than a simple emu.islagged() call you should add the logic to detect it here
	-- Implementing this logic will result in smooth dY/dXZ calculation (no more flickering between 0 and the correct value)
	return not emu.islagged();
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.read_u16_le(Game.Memory.x_position[version]);
end

function Game.getYPosition()
	return mainmemory.read_u16_le(Game.Memory.y_position[version]);
end

function Game.getZPosition()
	return 69;
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

-- Checkbox:
	-- Will be called each frame while the checkbox is checked
	-- Should not reload the map instantly
	-- Should take effect after walking through a door
-- Button:
	-- Will be called exacty once when the button is pressed
	-- Should load the selected map as soon as possible after the button is pressed

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

function Game.realTime() -- Optional: This function will be executed as fast as possible
	-- TODO
end

Game.OSDPosition = {2, 70}; -- Optional: OSD position in pixels from the top left corner of the screen, defaults to 2, 70 if not set by a game module
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