local cursor_left_x = 0x3A4;
local cursor_left_y = 0x3A8;
local cursor_right_x = 0x3AC
local cursor_right_y = 0x3B0;

local grid_base = 0xFB0;

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

function drawUI()
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
	if #moveQueue > 0 then
		local currentMove = moveQueue[1];
		drawGridText(UI_HUD_LEFT_X_OFFSET, 4, currentMove["x"]..","..currentMove["y"]);
		drawGridText(UI_HUD_LEFT_X_OFFSET, 5, currentMove["type"]);
	else
		drawGridText(UI_HUD_LEFT_X_OFFSET, 4, "None");
	end
end

--------------------
-- The good stuff --
--------------------

function getCursorPosition()
	local cursorLeftX = mainmemory.readbyte(cursor_left_x);
	local cursorLeftY = mainmemory.readbyte(cursor_left_y) - 2;
	--local cursorRightX = mainmemory.readbyte(cursor_right_x);
	--local cursorRightY = mainmemory.readbyte(cursor_right_y) - 2;
	return {["x"]=cursorLeftX, ["y"]=cursorLeftY};
end

function getGridAddress(x, y)
	x = x - 2;
	if x == -1 then
		x = 7;
		y = y - 1;
	end;
	y = (y - 1) * 0x10;
	return grid_base + y + (x * 2);
end

function getColor(x, y)
	return mainmemory.readbyte(getGridAddress(x, y));
end

function getStatus(x, y)
	return mainmemory.readbyte(getGridAddress(x, y) + 1);
end

function isMoveable(x, y)
	local status = getStatus(x, y);
	local i;
	for i=1,#unmoveableStates do
		if status == unmoveableStates[i] then
			return false;
		end
	end
	return true;
end

function getColumnHeight(x)
	local y;
	for y=1,grid_height do
		if getColor(x, y) ~= 0x00 then
			return grid_height - y + 1;
		end
	end
	return 0;
end

function isEmpty(y)
	local x;
	for x=1,grid_width do
		if getColor(x,y) > 0x00 and isMoveable(x, y) then
			return false;
		end
	end
	return true;
end

function rowContains(y, color)
	local x;
	for x=1,grid_width do
		if getColor(x,y) == color then
			return true;
		end
	end
	return false;
end

local previousFrameA = false;
function moveAt(x, y)
	local cursorPosition = getCursorPosition();

	if cursorPosition["x"] < x then
		joypad.set({["Right"]=true},1);
		previousFrameA = false;
	elseif cursorPosition["x"] > x then
		joypad.set({["Left"]=true},1);
		previousFrameA = false;
	end

	if cursorPosition["y"] < y then
		joypad.set({["Down"]=true},1);
		previousFrameA = false;
	elseif cursorPosition["y"] > y then
		joypad.set({["Up"]=true},1);
		previousFrameA = false;
	end

	if cursorPosition["x"] == x and cursorPosition["y"] == y then
		previousFrameA = not previousFrameA;
		joypad.set({["A"]=previousFrameA},1);
		return true;
	end

	return false;
end

speedUp = true;
verbose = false;
moveQueue = {};

function getColorAtCursor()
	local cursorPosition = getCursorPosition();
	local leftColor = getColor(cursorPosition["x"], cursorPosition["y"]);
	local rightColor = getColor(cursorPosition["x"] + 1, cursorPosition["y"]);
	return {leftColor, rightColor};
end

function checkVertical3(x,y)
	if verbose then
		print("Checking vertical 3 at "..x..","..y);
	end

	local tlm = isMoveable(x,     y);
	local trm = isMoveable(x + 1, y);
	local mlm = isMoveable(x,     y + 1);
	local mrm = isMoveable(x + 1, y + 1);
	local blm = isMoveable(x    , y + 2);
	local brm = isMoveable(x + 1, y + 2);

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

	local tl = getColor(x,     y);
	local tr = getColor(x + 1, y);
	local ml = getColor(x,     y + 1);
	local mr = getColor(x + 1, y + 1);
	local bl = getColor(x    , y + 2);
	local br = getColor(x + 1, y + 2);

	if verbose then
		local colorArray = {tl, tr, ml, mr, bl, br};
		local colorArrayFriendly = {colors[tl], colors[tr], colors[ml], colors[mr], colors[bl], colors[br]};
		print(colorArrayFriendly);
	end

	-- Check top row
	if (tl == mr and mr == br) or (tr == ml and ml == bl) then
		if tl ~= 0 and tr ~= 0 and tl ~= tr then
			if verbose then
				print("found top row");
			end
			table.insert(moveQueue, {["x"]=x,["y"]=y,["type"]="top"});
			return true;
		end
	end

	-- Check middle row
	if (tl == bl and mr == tl) or (tr == br and ml == tr) then
		if ml ~= 0 and mr ~= 0 and ml ~= mr then
			if verbose then
				print("found middle row");
			end
			table.insert(moveQueue, {["x"]=x,["y"]=y+1,["type"]="middle"});
			return true;
		end
	end

	-- Check bottom row
	if (tl == ml and br == ml) or (tr == mr and bl == mr) then
		if bl ~= 0 and br ~= 0 and bl ~= br then
			if verbose then
				print("found bottom row");
			end
			table.insert(moveQueue, {["x"]=x,["y"]=y+2,["type"]="bottom"});
			return true;
		end
	end

	-- No move found =(
	return false;
end

function findMoveGreedy()
	moveQueue = {};
	local x, y;
	-- Work from the bottom up
	for y = grid_height - 2, 1, -1 do
		-- TODO: Allow moveable blocks on top of unmoveable rows to be processed
		if not isEmpty(y) then
			-- Work from left to right
			for x = 1, grid_width - 1 do
				if checkVertical3(x,y) then
					return;
				end
			end
		else
			break;
		end
	end
end

function mainLoop()
	drawUI();
	if #moveQueue > 0 then
		local currentMove = moveQueue[1];
		local cL = getColor(currentMove["x"], currentMove["y"]);
		local cR = getColor(currentMove["x"] + 1, currentMove["y"]);
		if cL ~= 0 or cR ~= 0 then
			if moveAt(currentMove["x"], currentMove["y"]) then
				if verbose then
					print("Move completed!");
				end
				table.remove(moveQueue);
			end
		else
			if verbose then
				print("Both squares were empty, finding new move");
			end
			findMoveGreedy();
		end
	else
		if verbose then
			print("No moves in queue, finding new move");
		end
		findMoveGreedy();

		-- Make things more exciting
		if #moveQueue == 0 and speedUp and not verbose then
			joypad.set({["L"]=true},1);
		end
	end
end

event.onframestart(mainLoop, "Bot");