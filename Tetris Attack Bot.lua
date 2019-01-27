local romHash = gameinfo.getromhash();

local cursor_left_x;
local cursor_left_y;
local cursor_right_x;
local cursor_right_y;
local row_height_tickers;
local grid_base;

-- TODO: Support more versions of this game
if romHash == "EAD855D774C9943F7FFB5B4F429B2DD07FB6F606" then -- Panel de Pon (Japan) (SNES)
	cursor_left_x = {0x3A6, 0x3A8};
	cursor_left_y = {0x3AA, 0x3AC};
	cursor_right_x = {0x3AE, 0x3B0};
	cursor_right_y = {0x3B2, 0x3B4};
	row_height_tickers = {0x406, 0x408};
	grid_base = {0x17B0, 0x18B0};
--elseif romHash == "B59061561A3AEAC13E46735582F29826E7310141" then -- Panel de Pon - Event '98 (Japan) (BS) (SNES) -- TODO: Support this
elseif romHash == "2DC56EAB3E70C0910AE47119D8B69F494E6000DF" then -- Tetris Attack (USA) (En,Ja) (SNES)
	cursor_left_x = {0x3A4, 0x3A6};
	cursor_left_y = {0x3A8, 0x3AA};
	cursor_right_x = {0x3AC, 0x3AE};
	cursor_right_y = {0x3B0, 0x3B2};
	row_height_tickers = {0x404, 0x406};
	grid_base = {0xFAE, 0x10AE};
elseif romHash == "08E01F9AD5B6148E1A4355C80E2B23D8B2463443" then -- Tetris Attack (Europe) (En,Ja) (SNES)
	cursor_left_x = {0x3A6, 0x3A8};
	cursor_left_y = {0x3AA, 0x3AC};
	cursor_right_x = {0x3AE, 0x3B0};
	cursor_right_y = {0x3B2, 0x3B4};
	row_height_tickers = {0x406, 0x408};
	grid_base = {0xFB0, 0x10B0};
else
	print("This game is not currently supported.");
	return false;
end

local grid_height = 12;
local grid_width = 6;

local colors = {
	[0] = "Empty",
	[1] = "Red",
	[2] = "Green",
	[3] = "Light Blue",
	[4] = "Yellow",
	[5] = "Purple",
	[6] = "Dark Blue",
	[7] = "!",
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
};

num_players = 2;
panic_threshold = grid_height - 3;
speed_threshold = grid_height - 4;
draw_grid = false;
speedUp = true;
verbose = false;
warnings = false;
moveQueue = {};
local previousHeightTickerValues = {};

--------------------
-- The good stuff --
--------------------

local function getCursorPosition(player)
	local cursorLeftX = mainmemory.readbyte(cursor_left_x[player]);
	local cursorLeftY = mainmemory.readbyte(cursor_left_y[player]) - 2;
	return {x = cursorLeftX, y = cursorLeftY};
end

local function getGridAddress(x, y, player)
	if (warnings or verbose) and (x <= 0 or x > grid_width or y <= 0 or y > grid_height) then
		print("Warning: getGridAddress("..x..","..y..","..player..") was called with out of bounds X or Y.");
	end
	x = x - 1;
	y = (y - 1) * 0x10;
	return grid_base[player] + y + (x * 2);
end

local colorCache = {};
local function getColor(x, y, player)
	if type(colorCache[player][x][y]) ~= "nil" then
		return colorCache[player][x][y];
	end
	colorCache[player][x][y] = mainmemory.readbyte(getGridAddress(x, y, player));
	return colorCache[player][x][y];
end

local statusCache = {};
local function getStatus(x, y, player)
	if type(statusCache[player][x][y]) ~= "nil" then
		return statusCache[player][x][y];
	end
	statusCache[player][x][y] = mainmemory.readbyte(getGridAddress(x, y, player) + 1);
	return statusCache[player][x][y];
end

local function invalidateGridCache(player)
	-- Invalidate state caches
	colorCache[player] = {};
	statusCache[player] = {};

	for x = 1, grid_width do
		colorCache[player][x] = {};
		statusCache[player][x] = {};
	end
end

local function isMoveable(x, y, player)
	local status = getStatus(x, y, player);
	for i = 1, #unmoveableStates do
		if status == unmoveableStates[i] then
			return false;
		end
	end
	return true;
end

local function getColumnHeight(x, player, includeUnmoveable)
	local height = 0;
	for y = 1, grid_height do
		if includeUnmoveable then
			if getColor(x, y, player) ~= 0x00 then
				height = height + 1;
			end
		else
			if getColor(x, y, player) ~= 0x00 and isMoveable(x, y, player) then
				height = height + 1;
			end
		end
	end
	return height;
end

local function getMaxColumnHeight(player, includeUnmoveable)
	local maxHeight = 0;
	for x = 1, grid_width do
		maxHeight = math.max(getColumnHeight(x, player, includeUnmoveable), maxHeight);
	end
	return maxHeight;
end

local function columnIsEmpty(x, player, includeUnmoveable)
	return getColumnHeight(x, player, includeUnmoveable) == 0;
end

local function rowIsEmpty(y, player)
	for x = 1, grid_width do
		if getColor(x, y, player) > 0x00 and isMoveable(x, y, player) then
			return false;
		end
	end
	return true;
end

local function rowContains(y, color, player)
	for x = 1, grid_width do
		if getColor(x, y, player) == color then
			return true;
		end
	end
	return false;
end

local function countColorInColumn(x, color, player)
	local count = 0;
	for y = 1, grid_height do
		if getColor(x, y, player) == color then
			count = count + 1;
		end
	end
	return count;
end

local function getMostCommonColumn(color, player)
	local mostCommonX = 0;
	local mostCommonAmount = -1;
	for x = 1, grid_width do
		local currentAmount = countColorInColumn(x, color, player);
		if currentAmount > mostCommonAmount then
			mostCommonX = x;
			mostCommonAmount = currentAmount;
		end
	end
	return mostCommonX;
end

local function getColorAtCursor(player)
	local cursorPosition = getCursorPosition(player);
	local leftColor = getColor(cursorPosition.x, cursorPosition.y, player);
	local rightColor = getColor(cursorPosition.x + 1, cursorPosition.y, player);
	return {leftColor, rightColor};
end

------------------------
-- Mode based sorting --
------------------------

local function isSortedMode(y, player)
	local mostCommonColumns = {
		[0] = getMostCommonColumn(0, player),
		getMostCommonColumn(1, player),
		getMostCommonColumn(2, player),
		getMostCommonColumn(3, player),
		getMostCommonColumn(4, player),
		getMostCommonColumn(5, player),
		getMostCommonColumn(6, player),
		getMostCommonColumn(7, player)
	};

	for x = 1, grid_width do
		local currentColor = getColor(x, y, player);

		-- TODO: improve this
		if not isMoveable(x, y, player) then
			return true;
		end

		if currentColor ~= 0 then
			if x ~= mostCommonColumns[currentColor] then
				return false;
			end
		end
	end
	return true;
end

local function findMoveModeSort(player)
	local mostCommonColumns = {
		[0] = getMostCommonColumn(0, player),
		getMostCommonColumn(1, player),
		getMostCommonColumn(2, player),
		getMostCommonColumn(3, player),
		getMostCommonColumn(4, player),
		getMostCommonColumn(5, player),
		getMostCommonColumn(6, player),
		getMostCommonColumn(7, player)
	};

	-- Work from the bottom up
	for y = grid_height, 1, -1 do
		if not isSortedMode(y, player) then
			-- Work from left to right
			for x = 1, grid_width - 1 do
				local left = getColor(x, y, player);
				local right = getColor(x + 1, y, player);

				if left ~= right and mostCommonColumns[left] > mostCommonColumns[right] and isMoveable(x, y, player) and isMoveable(x + 1, y, player) then
					moveQueue[player] = {};
					table.insert(moveQueue[player], {x = x, y = y, type = "sort"});
					return true;
				end
			end
		end
	end
	return false;
end

-------------------------------------------------
-- Hilariously simple method to find next move --
-------------------------------------------------

local function isSorted(y, player)
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

local function findMoveSimpleSort(player)
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
					-- TODO: Pick closest move to cursor
					moveQueue[player] = {};
					table.insert(moveQueue[player], {x = x, y = y, type = "sort"});
					return true;
				end
			end
		end
	end
	return false;
end

local function pickRandomMove(player)
	local timeout = 0;
	local x, y, left, right, leftMoveable, rightMoveable, currentColumnHeight;
	local maxColumnHeight = getMaxColumnHeight(player, false);
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
	until (currentColumnHeight == maxColumnHeight or math.random(1, 2) == 1) and (leftMoveable and rightMoveable and (left ~= 0x00 or right ~= 0x00) and left ~= right) or timeout > 100;

	if timeout <= 100 then
		moveQueue[player] = {};
		table.insert(moveQueue[player], {x = x, y = y, type = "random"});
		return true;
	else
		return false;
	end
end

----------------------------------------------------------
-- Hilariously complicated method to find the next move --
----------------------------------------------------------

local function check2By3(x, y, player)
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

	for i = 1, #moveableArray do
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
			table.insert(moveQueue[player], {x = x, y = y, type = "top"});
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
			table.insert(moveQueue[player], {x = x, y = y + 1, type = "middle"});
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
			table.insert(moveQueue[player], {x = x, y = y + 2, type = "bottom"});
			return true;
		end
	end

	-- No move found =(
	return false;
end

local function checkVertical3(x, y, player)
	-- Skip this check for the bottom of the screen
	if y > grid_height - 4 then
		return false;
	end

	local canMoveRight = x < grid_width;
	local canMoveLeft = x > 1;
	local columnColors = {};

	for i = 1, 4 do
		table.insert(columnColors, getColor(x, y + i, player));
		if not isMoveable(x, y + i, player) then
			return false;
		end
	end

	for currentColor = 1, #colors do
		if currentColor ~= 0 then
			local currentColorCount = 0;
			for j = 1, #columnColors do
				if columnColors[j] == currentColor then
					currentColorCount = currentColorCount + 1;
				end
			end
			if currentColorCount == 3 then
				for j = #columnColors, 1, -1 do
					if columnColors[j] ~= currentColor then
						if canMoveRight and getColor(x + 1, y + j - 1, player) == 0 then
							if verbose then
								print("Moving block right to make vertical 3 of color "..colors[currentColor]);
								--print(columnColors);
							end
							table.insert(moveQueue[player], {x = x, y = y + j - 1, type = "v3r"});
							return true;
						end
						if canMoveLeft and getColor(x - 1, y + j - 1, player) == 0 then
							if verbose then
								print("Moving block left to make vertical 3 of color "..colors[currentColor]);
								--print(columnColors);
							end
							table.insert(moveQueue[player], {x = x - 1, y = y + j - 1, type = "v3l"});
							return true;
						end
					end
				end
			end
		end
	end

	return false;
end

local function findMoveGreedy(player)
	if verbose then
		print("Running find move greedy for player "..player);
	end
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

------------------
-- Ticker stuff --
------------------

local function gridHasChangedHeight(player)
	local currentHeightTickerValue = mainmemory.readbyte(row_height_tickers[player]);
	local hasChangedHeight = currentHeightTickerValue < previousHeightTickerValues[player];
	previousHeightTickerValues[player] = currentHeightTickerValue;
	return hasChangedHeight;
end

-----------------
-- UI Bollocks --
-----------------

UI_GRID_BASE_X = 72;
UI_GRID_BASE_Y = 8;
UI_ROW_HEIGHT = 16;
UI_ROW_WIDTH = 16;
UI_HUD_LEFT_X_OFFSET = -4;

local function drawGridText(x, y, string)
	local drawX = UI_GRID_BASE_X + x * UI_ROW_WIDTH;
	local drawY = UI_GRID_BASE_Y + y * UI_ROW_HEIGHT;
	gui.drawText(drawX, drawY, string);
end

local function drawUI(player)
	if verbose then
		print("Drawing grid UI for player "..player);
	end

	for x = 1, grid_width do
		drawGridText(x, 0, x);
		if verbose then
			drawGridText(x, 1, getColumnHeight(x, player, true));
		end
	end
	for y = 1, grid_height do
		drawGridText(0, y, y);
	end

	-- Output current move to the screen
	drawGridText(UI_HUD_LEFT_X_OFFSET, 3, "Move");
	if #moveQueue[player] > 0 then
		local currentMove = moveQueue[player][1];
		drawGridText(UI_HUD_LEFT_X_OFFSET, 4, currentMove.x..","..currentMove.y);
		drawGridText(UI_HUD_LEFT_X_OFFSET, 5, currentMove.type);

		if warnings or verbose then
			drawGridText(currentMove.x, currentMove.y, "L");
			drawGridText(currentMove.x + 1, currentMove.y, "R");
		end
	else
		drawGridText(UI_HUD_LEFT_X_OFFSET, 4, "None");
	end
end

-------------
-- The bot --
-------------

local numMoves = {};
local frameSum = {};

local previousFrameA = {};
local previousFrameDirection = {};

local function resetBotState()
	if verbose then
		print("Starting bot...");
	end

	moveQueue = {};
	numMoves = {};
	frameSum = {};
	previousFrameA = {};
	previousFrameDirection = {};
	previousHeightTickerValues = {};

	for currentPlayer = 1, num_players do
		table.insert(moveQueue, {});
		table.insert(numMoves, 0);
		table.insert(frameSum, 0);
		table.insert(previousFrameA, false);
		table.insert(previousFrameDirection, false);
		table.insert(previousHeightTickerValues, -1);
		if verbose then
			print("Started bot for player "..currentPlayer.."!");
		end
	end
end
resetBotState();

local function getAverageMoveLength()
	for currentPlayer = 1, num_players do
		print("Avarage move length: "..(frameSum[currentPlayer] / numMoves[currentPlayer]));
	end
end

local function moveAt(x, y, player)
	if x <= 0 or x >= grid_width or y <= 0 or y > grid_height then
		if warnings or verbose then
			print("Warning: moveAt("..x..","..y..","..player..","..moveQueue[player][1].type..") was called with out of bounds X or Y.");
		end
		return true;
	end

	if not isMoveable(x, y, player) or not isMoveable(x + 1, y, player) then
		if warnings or verbose then
			print("Warning: moveAt("..x..","..y..","..player..","..moveQueue[player][1].type..") was called with unmoveable blocks.");
		end
		return true;
	end

	if not getColor(x, y, player) == 0 and getColor(x + 1, y, player) == 0 then
		if warnings or verbose then
			print("Warning: moveAt("..x..","..y..","..player..","..moveQueue[player][1].type..") was called with both L and R squares empty.");
		end
		return true;
	end

	local cursorPosition = getCursorPosition(player);

	if cursorPosition.x == x and cursorPosition.y == y then
		previousFrameA[player] = not previousFrameA[player];
		joypad.set({A = previousFrameA[player]}, player);
		return true;
	end

	if not previousFrameDirection[player] then
		if cursorPosition.x < x then
			joypad.set({Right = true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
			return false;
		elseif cursorPosition.x > x then
			joypad.set({Left = true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
			return false;
		end

		if cursorPosition.y < y then
			joypad.set({Down = true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
			return false;
		elseif cursorPosition.y > y then
			joypad.set({Up = true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
			return false;
		end
	else
		previousFrameDirection[player] = false;
		return false;
	end

	if warnings or verbose then
		print("Warning: Made it to the end of moveAt("..x..","..y..","..player..","..moveQueue[player][1].type..") this shouldn't happen.");
	end

	return false;
end

local function movePickFunction(player)
	if getMaxColumnHeight(player, true) < panic_threshold then
		-- Calm and collected
		if findMoveSimpleSort(player) or findMoveGreedy(player) then
		--if findMoveModeSort(player) or findMoveGreedy(player) then
			return true;
		end
	else
		-- Panic mode
		if findMoveGreedy(player) or findMoveSimpleSort(player) then
		--if findMoveGreedy(player) or findMoveModeSort(player) then
			return true;
		end
	end

	-- Last resort
	return pickRandomMove(player);
end

local function mainLoop()
	if draw_grid then
		for player = 1, num_players do
			drawUI(player);
		end
	end

	if emu.islagged() then
		return;
	end

	for player = 1, num_players do
		invalidateGridCache(player);

		if #moveQueue[player] > 0 then
			local currentMove = moveQueue[player][1];
			if currentMove.framesNeeded == nil then
				currentMove.framesNeeded = 0;
			end

			if gridHasChangedHeight(player) then
				if verbose then
					print("Player "..player.." grid has changed height, adjusting current move accordingly.");
				end
				currentMove.y = math.max(1, currentMove.y - 1);
			end

			local cL = getColor(currentMove.x, currentMove.y, player);
			local cR = getColor(currentMove.x + 1, currentMove.y, player);
			if cL ~= 0 or cR ~= 0 then
				if moveAt(currentMove.x, currentMove.y, player) then
					if verbose then
						print("Move completed in "..currentMove.framesNeeded.." frames.");
					end
					if currentMove.framesNeeded > 1 then
						frameSum[player] = frameSum[player] + currentMove.framesNeeded;
						numMoves[player] = numMoves[player] + 1;
					end
					table.remove(moveQueue[player]);
				else
					currentMove.framesNeeded = currentMove.framesNeeded + 1;
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
		local maxColumnHeight = getMaxColumnHeight(player, true);
		if speedUp and maxColumnHeight > 0 and maxColumnHeight < speed_threshold and not verbose then
			joypad.set({L = true}, player);
		end
	end
end

event.onframestart(mainLoop, "ScriptHawk - Tetris Attack bot");
event.onloadstate(resetBotState, "ScriptHawk - Reset bot state"); -- Invalidate bot state when a state is loaded