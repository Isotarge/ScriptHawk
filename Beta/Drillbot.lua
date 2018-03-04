local colors = {
	[0x00] = "Empty",
	[0x06] = "Empty",
	[0x07] = "Empty",
	[0x08] = "Air",
	[0x09] = "Checkpoint",
	[0x0A] = "Brown",
	[0x0B] = "Star",
	[0x0C] = "Blue",
	[0x0D] = "Green",
	[0x0E] = "Red",
	[0x0F] = "Yellow",
};

local states = {
	[0x00] = "Empty",
	[0x03] = "Falling",
	[0x04] = "Active",
	[0x08] = "Drilled",
	[0x09] = "Drilled",
	[0x0A] = "Drilled",
	[0x0C] = "Drilled", -- Checkpoint reached
};

local facingDirection = {
	Left = 0x00,
	Right = 0x01,
	Down = 0x02,
	Up = 0x03,
};

local gridBase = 0x1320;
local gridWidth = 9;
local gridHeight = 32;
local blockSize = 0x20;
local rowSize = (gridWidth + 3) * blockSize;

local function getOSDXPos(x)
	return 10 + (x - 1) * 16;
end

local function getOSDYPos(y)
	return -264 + (y * 16);
end

local function getBlockAddress(x, y)
	return gridBase + ((y - 1) * rowSize) + (x * blockSize);
end

local function getColor(x, y)
	return mainmemory.readbyte(getBlockAddress(x, y) + 0x0E);
end

local function getTimer(x, y)
	return mainmemory.readbyte(getBlockAddress(x, y) + 0x16);
end

local function setTimer(x, y, value)
	mainmemory.writebyte(getBlockAddress(x, y) + 0x16, value);
end

local function getState(x, y)
	return mainmemory.readbyte(getBlockAddress(x, y));
end

local function getXPosition()
	return mainmemory.read_u16_le(0x1136);
end

-- y<=20 is above player
-- y=21 is player level
-- y>=22 is under the player
local function getYPosition()
	return 21;
end

local function getAir()
	return mainmemory.readbyte(0x114E);
end

local function isBlockSafe(x, y)
	local color = colors[getColor(x, y)] or 'unknown';
	local state = states[getState(x, y)] or 'unknown';
	if state == "Empty" or state == "Drilled" or state == "Active" then
		return true;
	end
	if state == "Falling" and color ~= "Air" then
		return not (getTimer(x, y) == 0);
	end
	if color == "Empty" or color == "Air" or color == "Star" then
		return true;
	end
	if color == 'unknown' or state == 'unknown' then
		--print("Unknown block detected at "..x..","..y..": Color: "..getColor(x, y).." State: "..getState(x, y));
	end
	return false;
end

-- TODO: Pretty reliable but needs some work
local function isSafe(x)
	if x < 1 or x > gridWidth then
		if verbose then
			print("Warning: OOB call to isSafe() with x of "..x);
		end
		return false;
	end
	for y = 19, 21 do
		if not isBlockSafe(x, y) then
			return false;
		end
	end
	return true;
end

local function columnContainsReachableAir(x)
	for y = 1, 20 do
		if colors[getColor(x, y)] == "Air" and states[getState(x, y)] == "Falling" then
			return true;
		end
	end
	for y = 21, 32 do
		if colors[getColor(x, y)] == "Air" then
			return true;
		end
	end
	return false;
end

weight = {
	Air = 5,
	Safe = -50,
	Brown = -5,
	Distance = -2,
};

local function getColumnScore(x) -- TODO: Needs tons of work & weighting
	local score = 0;
	if not isSafe(x) then
		score = score + weight.Safe;
	end

	if getAir() <= 50 and columnContainsReachableAir(x) then -- Check for air
		score = score + weight.Air;
	end
	if colors[getColor(x, 22)] == "Brown" then -- Check for brown block underneath
		score = score + weight.Brown;
	end
	for test = 1, x - 1 do
		if colors[getColor(test, 21)] == "Brown" then -- Check for brown blocks to the left
			score = score + weight.Brown;
		end
	end
	for test = x + 1, gridWidth do
		if colors[getColor(test, 21)] == "Brown" then -- Check for brown blocks to the right
			score = score + weight.Brown;
		end
	end

	score = score + math.abs(getXPosition() - x) * weight.Distance; -- Delta between the player and the column

	return score;
end

local function getMaxScoredColumn()
	local maxScored = -math.huge;
	local maxScore = -math.huge;
	for x = 1, gridWidth do
		local columnScore = getColumnScore(x);
		if columnScore > maxScore then
			maxScore = columnScore;
			maxScored = x;
		end
	end
	return maxScored;
end

local function drawUI()
	gui.cleartext();
	for x = 1, gridWidth do
		if isSafe(x) then
			gui.drawText(getOSDXPos(x), getOSDYPos(21), "Y", 0xFF00FF00); -- Green
		else
			gui.drawText(getOSDXPos(x), getOSDYPos(21), "N", 0xFFFF0000); -- Red
		end
		--[[
		local columnScore = getColumnScore(x);
		if columnScore ~= -math.huge then -- Only draw if it's actually possible to move there
			gui.drawText(getOSDXPos(x), getOSDYPos(22), columnScore);
		end
		--]]
		for y = 1, 32 do
			if states[getState(x, y)] == "Falling" then
				gui.drawText(getOSDXPos(x), getOSDYPos(y), getTimer(x, y));
			end
		end
	end
end

local function eachFrame()
	local maxScored = getMaxScoredColumn();
	local xPos = getXPosition();
	if maxScored < xPos then
		joypad.set({Left = true});
	elseif maxScored > xPos then
		joypad.set({Right = true});
	else
		joypad.set({Down = true});
	end
	joypad.set({A = (emu.framecount() % 2 == 0)}); -- Mash A like there's no tomorrow
	drawUI();
end

event.onframestart(eachFrame, "ScriptHawk - Drillbot Each Frame");
event.onloadstate(eachFrame, "ScriptHawk - Drillbot On Load State");