-- Original script by pirohiko, http://tasvideos.org/forum/viewtopic.php?p=315430#315430
-- Ported to BizHawk and ScriptHawk API by Isotarge

-- TODO: Uh yeah this script needs a lot of cleanup and fixes
	-- vScale and pScale are annoying hacks :(
	-- Scale Game.speedy_speeds
	-- Game.Memory table please
	-- Support more versions
	-- Box counts don't work?
	-- Take me there implementation
	-- Move player + x constants to an object model table
	-- D-Pad binds are annoying to use, this needs to be fixed in ScriptHawk.lua

Game = {};

local playerPointer = 0x60A90;
local pScale = 1000;
local vScale = 100000;

local boxI = 0x6CC69;
local boxS = 0x6CDC1;
local level = 0x618DC;

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_index = 7;

function Game.detectVersion(romName, romHash)
	return true; -- TODO
end

---------------------
-- General Getters --
---------------------

function Game.getBoxI()
	return mainmemory.read_u32_le(boxI);
end

function Game.getBoxS()
	return mainmemory.read_u32_le(boxS)
end

function Game.getBoxString() -- TODO: This doesn't work lol
	return Game.getBoxI().." / "..Game.getBoxS();
end

function Game.getLevel()
	return mainmemory.read_u32_le(level);
end

--------------------
-- Player Getters --
--------------------

function Game.getPlayerActor()
	return dereferencePointer(playerPointer);
end

function playerPointerOSD()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return toHexString(player);
	end
	return "Crash not found...";
end

function Game.getJumps()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_u32_le(player + 0x1B5);
	end
	return 0;
end

function Game.getXPosition()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + 0x60) / pScale;
	end
	return 0;
end

function Game.getYPosition()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + 0x64) / pScale;
	end
	return 0;
end

function Game.getZPosition()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + 0x68) / pScale;
	end
	return 0;
end

function Game.setXPosition(value)
	local player = Game.getPlayerActor();
	if isRAM(player) then
		mainmemory.write_s32_le(player + 0x60, value * pScale);
	end
end

function Game.setYPosition(value)
	local player = Game.getPlayerActor();
	if isRAM(player) then
		mainmemory.write_s32_le(player + 0x64, value * pScale);
	end
end

function Game.setZPosition(value)
	local player = Game.getPlayerActor();
	if isRAM(player) then
		mainmemory.write_s32_le(player + 0x68, value * pScale);
	end
end

Game.max_rot_units = 4096;
function Game.getYRotation()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + 0x94);
	end
	return 0;
end

function Game.getXVelocity()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + 0x84) / vScale;
	end
	return 0;
end

function Game.getYVelocity()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + 0x88) / vScale;
	end
	return 0;
end

function Game.getZVelocity()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + 0x8C) / vScale;
	end
	return 0;
end

function Game.getXZVelocity()
	local xV = Game.getXVelocity();
	local zV = Game.getZVelocity();
	return math.sqrt(xV*xV + zV*zV);
end

function Game.getVelocity()
	local player = Game.getPlayerActor();
	if isRAM(player) then
		return mainmemory.read_s32_le(player + 0x104) / vScale;
	end
	return 0;
end

Game.OSD = {
	{"Crash", playerPointerOSD},
	{"Level", Game.getLevel},
	{"Box", Game.getBoxString},
	{"Separator", 1},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Facing", Game.getYRotation},
	{"Moving Angle"},
	{"Separator", 1},
	--{"X Vel", Game.getXVelocity},
	{"Y Vel", Game.getYVelocity},
	--{"Z Vel", Game.getZVelocity},
	{"XZ Vel", Game.getXZVelocity},
	{"Velocity", Game.getVelocity},
	{"Jumps", Game.getJumps},
};

return Game;