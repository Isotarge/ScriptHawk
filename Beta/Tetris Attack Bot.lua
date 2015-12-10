local cursor_left_x = {0x3A4, 0x3A6};
local cursor_left_y = {0x3A8, 0x3AA};
local cursor_right_x = {0x3AC, 0x3AE};
local cursor_right_y = {0x3B0, 0x3B2};

local grid_base = {0xFAE, 0x10AE};

local grid_height = 12;
local grid_width = 6;

local colors = {
	[0x00] = "Empty",
	[0x01] = "Red",
	[0x02] = "Green",
	[0x03] = "Light Blue",
	[0x04] = "Yellow",
	[0x05] = "Purple",
	[0x06] = "Dark Blue",
	[0x07] = "!"
};

-- Status
-- 0x00 Normal
-- 0x01 Switching left or right
-- 0x02 Shaking
-- 0x03 Stopped?
-- 0x04 Red Block (can't move)
-- 0x08 Grey Block (can't move)
-- 0x40 Popping
local unmoveableStates = {
	0x01, 0x04, 0x08, 0x40
}

num_players = 2;
panic_threshold = grid_height - 3;
speed_threshold = grid_height - 4;
draw_grid = false;
speedUp = true;
verbose = false;
warnings = false;
moveQueue = {};

-----------------
-- UI Bollocks --
-----------------

UI_GRID_BASE_X = 72;
UI_GRID_BASE_Y = 8;
UI_ROW_HEIGHT = 16;
UI_ROW_WIDTH = 16;
UI_HUD_LEFT_X_OFFSET = -4;

function drawGridText(x, y, string)
	local drawX = UI_GRID_BASE_X + x * UI_ROW_WIDTH;
	local drawY = UI_GRID_BASE_Y + y * UI_ROW_HEIGHT;
	gui.drawText(drawX, drawY, string);
end

function drawUI(player)
	if verbose then
		print("Drawing grid UI for player "..player);
	end

	local x, y;
	for x = 1, grid_width do
		drawGridText(x, 0, x);
		if verbose then
			drawGridText(x, 1, getColumnHeight(x, player));
		end
	end
	for y = 1, grid_height do
		drawGridText(0, y, y);
	end

	-- Output current move to the screen
	drawGridText(UI_HUD_LEFT_X_OFFSET,3,"Move");
	if #moveQueue[player] > 0 then
		local currentMove = moveQueue[player][1];
		drawGridText(UI_HUD_LEFT_X_OFFSET, 4, currentMove["x"]..","..currentMove["y"]);
		drawGridText(UI_HUD_LEFT_X_OFFSET, 5, currentMove["type"]);

		if warnings or verbose then
			drawGridText(currentMove["x"], currentMove["y"], "L");
			drawGridText(currentMove["x"] + 1, currentMove["y"], "R");
		end
	else
		drawGridText(UI_HUD_LEFT_X_OFFSET, 4, "None");
	end
end

--------------------
-- The good stuff --
--------------------

function getCursorPosition(player)
	local cursorLeftX = mainmemory.readbyte(cursor_left_x[player]);
	local cursorLeftY = mainmemory.readbyte(cursor_left_y[player]) - 2;
	return {["x"] = cursorLeftX, ["y"] = cursorLeftY};
end

function getGridAddress(x, y, player)
	if (warnings or verbose) and (x <= 0 or x > grid_width or y <= 0 or y > grid_height) then
		print("Warning: getGridAddress("..x..","..y..","..player..") was called with out of bounds X or Y.");
	end
	x = x - 1;
	y = (y - 1) * 0x10;
	return grid_base[player] + y + (x * 2);
end

colorCache = {};
function getColor(x, y, player)
	if type(colorCache[player][x][y]) ~= "nil" then
		return colorCache[player][x][y];
	end
	colorCache[player][x][y] = mainmemory.readbyte(getGridAddress(x, y, player));
	return colorCache[player][x][y];
end

statusCache = {};
function getStatus(x, y, player)
	if type(statusCache[player][x][y]) ~= "nil" then
		return statusCache[player][x][y];
	end
	statusCache[player][x][y] = mainmemory.readbyte(getGridAddress(x, y, player) + 1);
	return statusCache[player][x][y];
end

function invalidateGridCache(player)
	-- Invalidate state caches
	colorCache[player] = {};
	statusCache[player] = {};

	local x;
	for x=1,grid_width do
		colorCache[player][x] = {};
		statusCache[player][x] = {};
	end
end

function isMoveable(x, y, player)
	local status = getStatus(x, y, player);
	local i;
	for i=1,#unmoveableStates do
		if status == unmoveableStates[i] then
			return false;
		end
	end
	return true;
end

function getMaxColumnHeight(player)
	local x;
	local maxHeight = 0;
	for x=1,grid_width do
		maxHeight = math.max(getColumnHeight(x, player), maxHeight);
	end
	return maxHeight;
end

function getColumnHeight(x, player)
	local y;
	for y=1,grid_height do
		if getColor(x, y, player) ~= 0x00 then
			return grid_height - y + 1;
		end
	end
	return 0;
end

function columnIsEmpty(x, player)
	return getColumnHeight(x, player) == 0;
end

function rowIsEmpty(y, player)
	local x;
	for x=1,grid_width do
		if getColor(x, y, player) > 0x00 and isMoveable(x, y, player) then
			return false;
		end
	end
	return true;
end

function rowContains(y, color, player)
	local x;
	for x=1,grid_width do
		if getColor(x, y, player) == color then
			return true;
		end
	end
	return false;
end

function getColorAtCursor(player)
	local cursorPosition = getCursorPosition(player);
	local leftColor = getColor(cursorPosition["x"], cursorPosition["y"], player);
	local rightColor = getColor(cursorPosition["x"] + 1, cursorPosition["y"], player);
	return {leftColor, rightColor};
end

-------------------------------------------------
-- Hilariously simple method to find next move --
-------------------------------------------------

function isSorted(y, player)
	local current = -1;
	for x = 1, grid_width do
		if getColor(x, y, player) >= current then
			current = getColor(x, y, player);
		else
			return false;
		end
	end
	return true;
end

function findMoveSimpleSort(player)
	local x, y;
	-- Work from the bottom up
	for y = grid_height, 1, -1 do
		if not isSorted(y, player) then
			-- Work from left to right
			for x = 1, grid_width - 1 do
				local left = getColor(x, y, player);
				local right = getColor(x + 1, y, player);

				-- Move <= to the left side of the screen
				if left > 0 and left < 4 then
					left = left * -1;
				end
				if right > 0 and right < 4 then
					right = right * -1;
				end

				if left > right and isMoveable(x, y, player) and isMoveable(x + 1, y, player) then
					moveQueue[player] = {};
					table.insert(moveQueue[player], {["x"] = x, ["y"] = y, ["type"] = "sort"});
					return true;
				end
			end
		end
	end
	return false;
end

function findMoveDeltaSort(player)
	local x, y;
	-- Work from the bottom up
	for y = grid_height, 1, -1 do
		if not isSorted(y, player) then
			-- Work from left to right
			for x = 1, grid_width - 1 do
				local left = getColor(x, y, player);
				local right = getColor(x + 1, y, player);
				local dxl = math.abs(x - left);
				local dxr = math.abs(x - right)
				if dxr > dxl then
					moveQueue[player] = {};
					table.insert(moveQueue[player], {["x"] = x, ["y"] = y, ["type"] = "deltasort"});
					return true;
				end
			end
		end
	end
	return false;
end

function pickRandomMove(player)
	local timeout = 0;
	local x,y, left, right, leftMoveable, rightMoveable;
	-- TODO: Make sure this doesn't take into account unmoveable blocks
	local maxColumnHeight = getMaxColumnHeight(player);
	local currentColumnHeight = -1;
	repeat
		x = math.random(1, grid_width);
		y = math.random(1, grid_height);

		currentColumnHeight = getColumnHeight(x, player);

		if x == grid_width then
			x = x - 1;
		end

		left = getColor(x, y, player);
		right = getColor(x + 1, y, player);
		leftMoveable = isMoveable(x, y, player);
		rightMoveable = isMoveable(x + 1, y, player);

		timeout = timeout + 1;
	until (currentColumnHeight == maxColumnHeight or math.random(1,2) == 1) and (leftMoveable and rightMoveable and (left ~= 0x00 or right ~= 0x00) and left ~= right) or timeout > 100;

	if timeout <= 100 then
		moveQueue[player] = {};
		table.insert(moveQueue[player], {["x"] = x, ["y"] = y, ["type"] = "random"});
		return true;
	else
		return false;
	end
end

----------------------------------------------------------
-- Hilariously complicated method to find the next move --
----------------------------------------------------------

function check2By3(x, y, player)
	-- Skip this check for the right of the screen
	if x == grid_width then
		return false;
	end

	local tlm = isMoveable(x,     y, player);
	local trm = isMoveable(x + 1, y, player);
	local mlm = isMoveable(x,     y + 1, player);
	local mrm = isMoveable(x + 1, y + 1, player);
	local blm = isMoveable(x    , y + 2, player);
	local brm = isMoveable(x + 1, y + 2, player);

	local moveableArray = {tlm, trm, mlm, mrm, blm, brm};
	local i;
	for i=1,#moveableArray do
		if moveableArray[i] == false then
			if verbose then
				print("A block was unmovable, skipping 2x3 check at "..x..","..y.." for player "..player);
			end
			return false;
		end
	end

	local tl = getColor(x,     y, player);
	local tr = getColor(x + 1, y, player);
	local ml = getColor(x,     y + 1, player);
	local mr = getColor(x + 1, y + 1, player);
	local bl = getColor(x    , y + 2, player);
	local br = getColor(x + 1, y + 2, player);

	if (tl == 0 and tr == 0) or (ml == 0 or mr == 0) and (bl == 0 or br == 0) then
		return false;
	end

	if verbose then
		print("Checking 2x3 at "..x..","..y.." for player "..player);
		--local colorArray = {tl, tr, ml, mr, bl, br};
		--local colorArrayFriendly = {colors[tl], colors[tr], colors[ml], colors[mr], colors[bl], colors[br]};
		--print(colorArrayFriendly);
	end

	-- Check top row
	if (tl == mr and mr == br and tl ~= 0) or (tr == ml and ml == bl and tr ~= 0) then
		if tl ~= tr then
			if verbose then
				print("Found top row");
			end
			moveQueue[player] = {};
			table.insert(moveQueue[player], {["x"] = x, ["y"] = y, ["type"] = "top"});
			return true;
		end
	end

	-- Check middle row
	if (tl == bl and mr == tl) or (tr == br and ml == tr) then
		if ml ~= mr then
			if verbose then
				print("Found middle row");
			end
			moveQueue[player] = {};
			table.insert(moveQueue[player], {["x"] = x, ["y"] = y + 1, ["type"] = "middle"});
			return true;
		end
	end

	-- Check bottom row
	if (tl == ml and br == ml) or (tr == mr and bl == mr) then
		if bl ~= br then
			if verbose then
				print("Found bottom row");
			end
			moveQueue[player] = {};
			table.insert(moveQueue[player], {["x"] = x, ["y"] = y + 2, ["type"] = "bottom"});
			return true;
		end
	end

	-- No move found =(
	return false;
end

function checkVertical3(x, y, player)
	-- Skip this check for the bottom of the screen
	if y > grid_height - 4 then
		return false;
	end

	local canMoveRight = x < grid_width;
	local canMoveLeft = x > 1;
	local columnColors = {};
	local currentColor, i, j;

	for i=1,4 do
		table.insert(columnColors, getColor(x, y + i, player));
		if not isMoveable(x, y + i, player) then
			return false;
		end
	end

	for currentColor=1,#colors do
		if currentColor ~= 0 then
			local currentColorCount = 0;
			for j=1,#columnColors do
				if columnColors[j] == currentColor then
					currentColorCount = currentColorCount + 1;
				end
			end
			if currentColorCount == 3 then
				for j=#columnColors,1,-1 do
					if columnColors[j] ~= currentColor then
						if canMoveRight and getColor(x + 1, y + j - 1, player) == 0 then
							if verbose then
								print("Moving block right to make vertical 3 of color "..colors[currentColor]);
								--print(columnColors);
							end
							table.insert(moveQueue[player], {["x"] = x, ["y"] = y + j - 1, ["type"] = "v3r"});
							return true;
						end
						if canMoveLeft and getColor(x - 1, y + j - 1, player) == 0 then
							if verbose then
								print("Moving block left to make vertical 3 of color "..colors[currentColor]);
								--print(columnColors);
							end
							table.insert(moveQueue[player], {["x"] = x - 1, ["y"] = y + j - 1, ["type"] = "v3l"});
							return true;
						end
					end
				end
			end
		end
	end

	return false;
end

function findMoveGreedy(player)
	if verbose then
		print("Running find move greedy for player "..player);
	end
	local x, y;
	-- Work from the bottom up
	for y = grid_height - 2, 1, -1 do
		-- TODO: Allow moveable blocks on top of unmoveable rows to be processed
		if not rowIsEmpty(y, player) then
			-- Work from left to right
			for x = 1, grid_width do
				if check2By3(x, y, player) or checkVertical3(x, y, player) then
					return true;
				end
			end
		else
			break;
		end
	end
	return false;
end

-------------
-- The bot --
-------------

local numMoves = {};
local frameSum = {};

local previousFrameA = {};
local previousFrameDirection = {};

function resetBotState()
	if verbose then
		print("Starting bot...");
	end

	moveQueue = {};
	numMoves = {};
	frameSum = {};
	previousFrameA = {};
	previousFrameDirection = {};

	local currentPlayer;
	for currentPlayer=1,num_players do
		table.insert(moveQueue, {});
		table.insert(numMoves, 0);
		table.insert(frameSum, 0);
		table.insert(previousFrameA, false);
		table.insert(previousFrameDirection, false);
		if verbose then
			print("Started bot for player "..currentPlayer.."!");
		end
	end
end
resetBotState();

function getAverageMoveLength()
	local currentPlayer;
	for currentPlayer=1,num_players do
		print("Avarage move length: "..(frameSum[currentPlayer] / numMoves[currentPlayer]));
	end
end

function moveAt(x, y, player)
	if x <= 0 or x >= grid_width or y <= 0 or y > grid_height then
		if warnings or verbose then
			print("Warning: moveAt("..x..","..y..","..player..","..moveQueue[player][1]["type"]..") was called with out of bounds X or Y.");
		end
		return true;
	end

	if not isMoveable(x, y, player) or not isMoveable(x + 1, y, player) then
		if warnings or verbose then
			print("Warning: moveAt("..x..","..y..","..player..","..moveQueue[player][1]["type"]..") was called with unmoveable blocks.");
		end
		return true;
	end

	if not getColor(x, y, player) == 0 and getColor(x + 1, y, player) == 0 then
		if warnings or verbose then
			print("Warning: moveAt("..x..","..y..","..player..","..moveQueue[player][1]["type"]..") was called with both L and R squares empty.");
		end
		return true;
	end

	local cursorPosition = getCursorPosition(player);

	if cursorPosition["x"] == x and cursorPosition["y"] == y then
		previousFrameA[player] = not previousFrameA[player];
		joypad.set({["A"] = previousFrameA[player]}, player);
		return true;
	end

	if not previousFrameDirection[player] then
		if cursorPosition["x"] < x then
			joypad.set({["Right"] = true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
			return false;
		elseif cursorPosition["x"] > x then
			joypad.set({["Left"] = true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
			return false;
		end

		if cursorPosition["y"] < y then
			joypad.set({["Down"] = true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
			return false;
		elseif cursorPosition["y"] > y then
			joypad.set({["Up"] = true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
			return false;
		end
	else
		previousFrameDirection[player] = false;
		return false;
	end

	if warnings or verbose then
		print("Warning: Made it to the end of moveAt("..x..","..y..","..player..","..moveQueue[player][1]["type"]..") this shouldn't happen.");
	end

	return false;
end

function movePickFunction(player)
	if getMaxColumnHeight(player) < panic_threshold then
		-- Calm and collected
		if findMoveSimpleSort(player) or findMoveGreedy(player) then
			return true;
		end
	else
		-- Panic mode
		if findMoveGreedy(player) or findMoveSimpleSort(player) then
			return true;
		end
	end

	-- Last resort
	return pickRandomMove(player);
end

function mainLoop()
	if emu.islagged() then
		return;
	end

	local player;
	for player = 1, num_players do
		invalidateGridCache(player)

		if draw_grid then
			drawUI(player);
		end

		if #moveQueue[player] > 0 then
			local currentMove = moveQueue[player][1];
			if currentMove["framesNeeded"] == nil then
				currentMove["framesNeeded"] = 0;
			end
			local cL = getColor(currentMove["x"], currentMove["y"], player);
			local cR = getColor(currentMove["x"] + 1, currentMove["y"], player);
			if cL ~= 0 or cR ~= 0 then
				if moveAt(currentMove["x"], currentMove["y"], player) then
					if verbose then
						print("Move completed in "..currentMove["framesNeeded"].." frames.");
					end
					if currentMove["framesNeeded"] > 1 then
						frameSum[player] = frameSum[player] + currentMove["framesNeeded"];
						numMoves[player] = numMoves[player] + 1;
					end
					table.remove(moveQueue[player]);
				else
					currentMove["framesNeeded"] = currentMove["framesNeeded"] + 1;
				end
			else
				if verbose then
					print("Both squares were empty, finding new move");
				end
				table.remove(moveQueue[player]);
				movePickFunction(player);
			end
		end

		if #moveQueue[player] == 0 then
			if verbose then
				print("No moves in queue, finding new move");
			end
			movePickFunction(player);
		end

		-- Make things more exciting
		local maxColumnHeight = getMaxColumnHeight(player);
		if speedUp and maxColumnHeight > 0 and maxColumnHeight < speed_threshold and not verbose then
			joypad.set({["L"] = true}, player);
		end
	end
end

event.onframestart(mainLoop, "Bot");

-- Invalidate bot state when a state is loaded
event.onloadstate(resetBotState, "Reset player state");