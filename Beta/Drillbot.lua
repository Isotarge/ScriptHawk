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
	["Left"] = 0x00,
	["Right"] = 0x01,
	["Down"] = 0x02,
	["Up"] = 0x03,
};

local gridBase = 0x1320;
local gridWidth = 9;
local gridHeight = 32;
local blockSize = 0x20;
local rowSize = (gridWidth + 3) * blockSize;

function getColor(x, y)
	return mainmemory.readbyte(gridBase + ((y - 1) * rowSize) + (x * blockSize) + 0x0E);
end

function getState(x, y)
	return mainmemory.readbyte(gridBase + ((y - 1) * rowSize) + (x * blockSize));
end

function getXPosition()
	return mainmemory.read_u16_le(0x1136);
end

-- y<=20 is above player
-- y=21 is player level
-- y>=22 is under the player
function getYPosition()
	return 21;
end

function getAir()
	return mainmemory.readbyte(0x114E);
end

function isBlockSafe(x, y)
	local color = colors[getColor(x, y)] or 'unknown';
	local state = states[getState(x, y)] or 'unknown';
	if state == "Empty" or state == "Drilled" or state == "Active" then
		return true;
	end
	if state == "Falling" and color ~= "Air" then
		return false;
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
function isSafe(x)
	if x < 1 or x > gridWidth then
		if verbose then
			print("Warning: OOB call to isSafe() with x of "..x);
		end
		return false;
	end
	for y = 18, 21 do
		if not isBlockSafe(x, y) then
			return false;
		end
	end
	return true;
end

function columnContainsReachableAir(x)
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

function getColumnScore(x) -- TODO: Needs tons of work & weighting
	if not isSafe(x) then
		return -math.huge; -- If the column is not safe then we never want to go there
	end

	local score = 0;

	if getAir() < 50 and columnContainsReachableAir(x) then -- Check for air
		score = score + 3;
	end
	if colors[getColor(x, 22)] == "Brown" then -- Check for brown block
		score = score - 10;
	end

	score = score - math.abs(getXPosition() - x); -- Delta between the player and the column

	return score;
end

function getMaxScoredColumn()
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

function getOSDXPos(x)
	return 10 + (x - 1) * 16;
end

function drawUI()
	gui.cleartext();
	for x = 1, gridWidth do
		if isSafe(x) then
			gui.drawText(getOSDXPos(x), 72, "Y", 0xFF00FF00); -- Green
		else
			gui.drawText(getOSDXPos(x), 72, "N", 0xFFFF0000); -- Red
		end
		local columnScore = getColumnScore(x);
		if columnScore ~= -math.huge then -- Only draw if it's actually possible to move there
			gui.drawText(getOSDXPos(x), 88, columnScore);
		end
	end
end

local prevFrameA = false;
function eachFrame()
	local maxScored = getMaxScoredColumn();
	local xPos = getXPosition();
	if maxScored < xPos then
		joypad.set({["Left"] = true});
	elseif maxScored > xPos then
		joypad.set({["Right"] = true});
	else
		joypad.set({["Down"] = true});
	end
	prevFrameA = not prevFrameA;
	joypad.set({["A"] = prevFrameA}); -- Mash A like there's no tomorrow
	drawUI();
end

event.onframestart(eachFrame, "ScriptHawk - Drillbot Each Frame");
event.onloadstate(eachFrame, "ScriptHawk - Drillbot On Load State");