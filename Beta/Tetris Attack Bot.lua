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
-- 0x01 Stopped?
-- 0x02 Shaking
-- 0x03 Stopped?
-- 0x04 Red Block (can't move)
-- 0x08 Grey Block (can't move)
-- 0x40 Popping
local unmoveableStates = {
	0x04, 0x08, 0x40
}

speedUp = false;
verbose = false;
moveQueue = {{},{}};

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
	local x,y;
	for x=1,grid_width do
		drawGridText(x,0,x);
		if verbose then
			drawGridText(x,1,getColumnHeight(x));
		end
	end
	for y=1,grid_height do
		drawGridText(0,y,y);
	end

	-- Output current move to the screen
	drawGridText(UI_HUD_LEFT_X_OFFSET,3,"Move");
	if #moveQueue[player] > 0 then
		local currentMove = moveQueue[player][1];
		drawGridText(UI_HUD_LEFT_X_OFFSET, 4, currentMove["x"]..","..currentMove["y"]);
		drawGridText(UI_HUD_LEFT_X_OFFSET, 5, currentMove["type"]);
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
	return {["x"]=cursorLeftX, ["y"]=cursorLeftY};
end

function getGridAddress(x, y, player)
	x = x - 1;
	y = (y - 1) * 0x10;
	return grid_base[player] + y + (x * 2);
end

function getColor(x, y, player)
	return mainmemory.readbyte(getGridAddress(x, y, player));
end

function getStatus(x, y, player)
	return mainmemory.readbyte(getGridAddress(x, y, player) + 1);
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
	-- TODO
	return 10;
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

function isEmpty(y, player)
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
			local current = -1;
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
					table.insert(moveQueue[player], {["x"]=x,["y"]=y,["type"]="sort"});
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
			local current = -1;
			for x = 1, grid_width - 1 do
				local left = getColor(x, y, player);
				local right = getColor(x + 1, y, player);
				local dxl = math.abs(x - left);
				local dxr = math.abs(x - right)
				if dxr > dxl then
					moveQueue[player] = {};
					table.insert(moveQueue[player], {["x"]=x,["y"]=y,["type"]="sort2"});
					return true;
				end
			end
		end
	end
	return false;
end

function pickRandomMove(player)
	local timeout = 0;
	local x,y;
	repeat
		x = math.random(1, grid_width -1);
		y = math.random(1, grid_height);
		local left = getColor(x, y, player);
		local right = getColor(x + 1, y, player);
		local leftMoveable = isMoveable(x, y, player);
		local rightMoveable = isMoveable(x + 1, y, player);
		timeout = timeout + 1;
	until (leftMoveable and rightMoveable and (left ~= 0x00 or right ~= 0x00) and left ~= right) or timeout > 100;

	if timeout <= 100 then
		moveQueue[player] = {};
		table.insert(moveQueue[player], {["x"]=x,["y"]=y,["type"]="random"});
		return true;
	else
		return false;
	end
end

----------------------------------------------------------
-- Hilariously complicated method to find the next move --
----------------------------------------------------------

function checkVertical3(x, y, player)
	if verbose then
		print("Checking vertical 3 at "..x..","..y);
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
				print("A block was unmovable, skipping check at "..x..","..y);
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

	if verbose then
		local colorArray = {tl, tr, ml, mr, bl, br};
		local colorArrayFriendly = {colors[tl], colors[tr], colors[ml], colors[mr], colors[bl], colors[br]};
		print(colorArrayFriendly);
	end

	-- Check top row
	if (tl == mr and mr == br and tl ~= 0) or (tr == ml and ml == bl and tr ~= 0) then
		if tl ~= tr then
			if verbose then
				print("Found top row");
			end
			moveQueue[player] = {};
			table.insert(moveQueue[player], {["x"]=x,["y"]=y,["type"]="top"});
			return true;
		end
	end

	-- Check middle row
	if (tl == bl and mr == tl) or (tr == br and ml == tr) then
		if ml ~= 0 and mr ~= 0 and ml ~= mr then
			if verbose then
				print("Found middle row");
			end
			moveQueue[player] = {};
			table.insert(moveQueue[player], {["x"]=x,["y"]=y+1,["type"]="middle"});
			return true;
		end
	end

	-- Check bottom row
	if (tl == ml and br == ml) or (tr == mr and bl == mr) then
		if bl ~= 0 and br ~= 0 and bl ~= br then
			if verbose then
				print("Found bottom row");
			end
			moveQueue[player] = {};
			table.insert(moveQueue[player], {["x"]=x,["y"]=y+2,["type"]="bottom"});
			return true;
		end
	end

	-- No move found =(
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
		if not isEmpty(y, player) then
			-- Work from left to right
			for x = 1, grid_width - 1 do
				if checkVertical3(x, y, player) then
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

numMoves = {0, 0};
frameSum = {0, 0};

local previousFrameA = {false, false};
local previousFrameDirection = {false, false};

function getAverageMoveLength()
	print("avg: "..frameSum[1]/numMoves[1]);
	print("avg: "..frameSum[2]/numMoves[2]);
end

function moveAt(x, y, player)
	local cursorPosition = getCursorPosition(player);

	if cursorPosition["x"] == x and cursorPosition["y"] == y then
		previousFrameA[player] = not previousFrameA[player];
		joypad.set({["A"]=previousFrameA[player]}, player);
		return true;
	end

	if not previousFrameDirection[player] then
		if cursorPosition["x"] < x then
			joypad.set({["Right"]=true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
		elseif cursorPosition["x"] > x then
			joypad.set({["Left"]=true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
		end

		if cursorPosition["y"] < y then
			joypad.set({["Down"]=true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
		elseif cursorPosition["y"] > y then
			joypad.set({["Up"]=true}, player);
			previousFrameA[player] = false;
			previousFrameDirection[player] = true;
		end
	else
		previousFrameDirection[player] = false;
	end

	return false;
end

local movePickFunctions = {findMoveSimpleSort, findMoveGreedy, pickRandomMove};
--local movePickFunctions = {findMoveSimpleSort, findMoveGreedy, pickRandomMove};
--local movePickFunctions = {findMoveSimpleSort};
--local movePickFunctions = {findMoveDeltaSort};
--local movePickFunctions = {pickRandomMove};

function movePickFunction(player)
	local i;
	for i=1,#movePickFunctions do
		if movePickFunctions[i](player) then
			return true;
		end
	end
	return false;
end

function mainLoop()
	if emu.islagged() then
		return;
	end

	local player;
	for player = 1, 2 do
		--drawUI(player);
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
				movePickFunction(player);
			end
		else
			if verbose then
				print("No moves in queue, finding new move");
			end
			movePickFunction(player);

			-- Make things more exciting
			-- TODO: Restrict this so that it doesn't fire for too long
			if #moveQueue[player] == 0 and speedUp and not verbose then
				joypad.set({["L"]=true},player);
			end
		end
	end
end

event.onframestart(mainLoop, "Bot");