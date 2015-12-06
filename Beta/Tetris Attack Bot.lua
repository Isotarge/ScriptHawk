local cursor_left_x = 0x3A4;
local cursor_left_y = 0x3A8;
local cursor_right_x = 0x3AC
local cursor_right_y = 0x3B0;

local grid_base = 0xFB0;

local grid_height = 12;
local grid_width = 6;

colors = {
	[0] = "Empty",
	"Red",
	"Green",
	"Light Blue",
	"Yellow",
	"Purple",
	"Dark Blue",
	"!"
};

-- Status
-- 0x00 Normal
-- 0x01 Stopped?
-- 0x02 Shaking
-- 0x03 Stopped?
-- 0x04 Red Block (can't move)
-- 0x08 Grey Block (can't move)
-- 0x40 Popping

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
		local currentMove = moveQueue[#moveQueue];
		drawGridText(UI_HUD_LEFT_X_OFFSET, 4, currentMove["x"]..","..currentMove["y"]);
		drawGridText(UI_HUD_LEFT_X_OFFSET, 5, currentMove["type"]);
	else
		drawGridText(UI_HUD_LEFT_X_OFFSET, 4, "None");
	end
end

--------------------
-- The good stuff --
--------------------

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

function getColumnHeight(x)
	local y;
	for y=1,grid_height do
		if getColor(x, y) ~= 0x00 then
			return grid_height - y + 1;
		end
	end
	return 0;
end

local previousFrameA = false;
function moveAt(x, y)
	local cursorLeftX = mainmemory.readbyte(cursor_left_x);
	local cursorLeftY = mainmemory.readbyte(cursor_left_y) - 2;
	local cursorRightX = mainmemory.readbyte(cursor_right_x);
	local cursorRightY = mainmemory.readbyte(cursor_right_y) - 2;

	if cursorLeftX < x then
		joypad.set({["Right"]=true},1);
		previousFrameA = false;
	elseif cursorLeftX > x then
		joypad.set({["Left"]=true},1);
		previousFrameA = false;
	end

	if cursorLeftY < y then
		joypad.set({["Down"]=true},1);
		previousFrameA = false;
	elseif cursorLeftY > y then
		joypad.set({["Up"]=true},1);
		previousFrameA = false;
	end

	if cursorLeftX == x and cursorLeftY == y then
		previousFrameA = not previousFrameA;
		joypad.set({["A"]=previousFrameA},1);
		return true;
	end

	return false;
end

verbose = false;
moveQueue = {};

function getColorAtCursor()
	local cursorLeftX = mainmemory.readbyte(cursor_left_x);
	local cursorLeftY = mainmemory.readbyte(cursor_left_y) - 2;
	local cursorRightX = mainmemory.readbyte(cursor_right_x);
	local cursorRightY = mainmemory.readbyte(cursor_right_y) - 2;

	local leftColor = getColor(cursorLeftX, cursorLeftY);
	local rightColor = getColor(cursorRightX, cursorRightY);
	return {colors[leftColor], colors[rightColor]};
end

function checkVertical3(x,y)
	if verbose then
		print("checking vertical 3 at "..x..","..y);
	end

	local tls = getStatus(x,     y);
	local trs = getStatus(x + 1, y);
	local mls = getStatus(x,     y + 1);
	local mrs = getStatus(x + 1, y + 1);
	local bls = getStatus(x    , y + 2);
	local brs = getStatus(x + 1, y + 2);

	local redBlock = 0x04;
	local greyBlock = 0x08;
	local popping = 0x40;
	local statusArray = {tls, trs, mls, mrs, bls, brs};
	local i;
	for i=1,#statusArray do
		if statusArray[i] == popping or statusArray[i] == redBlock or statusArray[i] == greyBlock then
			if verbose then
				print("a block was unmovable, skipping check at "..x..","..y);
			end
			return;
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
		end
	end

	-- Check middle row
	if (tl == bl and mr == tl) or (tr == br and ml == tr) then
		if ml ~= 0 and mr ~= 0 and ml ~= mr then
			if verbose then
				print("found middle row");
			end
			table.insert(moveQueue, {["x"]=x,["y"]=y+1,["type"]="middle"});
		end
	end

	-- Check bottom row
	if (tl == ml and br == ml) or (tr == mr and bl == mr) then
		if bl ~= 0 and br ~= 0 and bl ~= br then
			if verbose then
				print("found bottom row");
			end
			table.insert(moveQueue, {["x"]=x,["y"]=y+2,["type"]="bottom"});
		end
	end
end

function findMoveGreedy()
	moveQueue = {};
	local x, y;
	for y = 1, grid_height - 2 do
		for x = 1, grid_width - 1 do
			checkVertical3(x,y);
		end
	end
end

function mainLoop()
	drawUI();
	if #moveQueue > 0 then
		local currentMove = moveQueue[#moveQueue];
		local cL = getColor(currentMove["x"], currentMove["y"]);
		local cR = getColor(currentMove["x"] + 1, currentMove["y"]);
		if cL ~= 0 or cR ~= 0 then
			local result = moveAt(currentMove["x"], currentMove["y"]);
			if result == true then
				findMoveGreedy();
			end
		else
			if verbose then
				print("both squares were empty, finding new move");
			end
			findMoveGreedy();
		end
	else
		if verbose then
			print("no moves in queue, finding new move");
		end
		findMoveGreedy();
	end
end

event.onframestart(mainLoop, "Bot");