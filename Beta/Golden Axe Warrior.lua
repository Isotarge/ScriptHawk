--[[
RNG Solver Design:
Path points A -> B -> C pass through all points and all enemies
Collision maps: 160 tile array
Spawn maps: 160 tile array
Start index
Middle index
End index
Coordinate you're supposed to reach on a certain frame
Run path and make sure coordinate reached on that frame
Number of positions required
For example minimum 3/6 positions
Enemies can take a variable number of hits
Condition to check for the lower number of hits
If there's a vertical gap in the middle of you and an enemy you can hit it from the bottom but not the top
2 checks, spawn inside area and spawn by frame x
Trace out movement into room, on frame they should spawn by check that they're vulnerable and check their position
Always the up button that manipulates RNG
Other directions don't affect it?
Can start moving on any frame
Button press then Next 4 frames are free to do w/e
Figure out damage boosts, keep manipulating RNG until you're further along than is possible with normal movement
]]

-- Configuration
showList = false;
showHitbox = true;
drawCursor = true;

local red = 0xFFFF0000;
local yellow = 0xFFFFFF00;
local green = 0xFF00FF00;
local pink = 0xFFFF00FF;
local black = 0xFF000000;

-- Game state
local object_array_base = 0x300;
local object_size = 0x30;
local object_array_capacity = 31;

local tileWidth = 16;
local tileHeight = 16;

local textWidth = 8; -- Text column width
local textHeight = 16; -- Text row height

local object_fields = {
	["object_type"] = 0x00, -- Byte
	["object_types"] = {
		[0x02] = {["name"] = "Player", ["color"] = yellow},
		[0x10] = {["name"] = "Spear", ["color"] = yellow}, -- Projectile
		[0x20] = {["name"] = "Pig Guy", ["color"] = red},
		[0x26] = {["name"] = "Slime Guy", ["color"] = red},
	},
	["vulnerable"] = 0x0C, -- Dying = 0x05, Spawning = 0x04, Vulnerable = 0x02,
	["y_position"] = 0x10, -- u16_le
	["x_position"] = 0x12, -- u16_le
};

function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	prefix = prefix or "0x";
	desiredLength = desiredLength or string.len(value);
	while string.len(value) < desiredLength do
		value = "0"..value;
	end
	return prefix..value;
end

function round(num, idp)
	return tonumber(string.format("%."..(idp or 0).."f", num));
end

local mouseLastFrame = {
	Left = false,
	Middle = false,
	Right = false,
};
local startDragPosition = {0,0};
local draggedObjects = {};

RNGSolver = {
	collisionArray = {}, -- 160 tile array
	spawnArray = {
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	}, -- 160 tile array
	positionRequired = 6, -- Minimum number of positions required
	mode = "SetSpawn", -- SetSpawn || SetCollision || Solve
	enabled = false,
};

function isVulnerable(object)
	return mainmemory.readbyte(object + object_fields.vulnerable) == 0x02;
end

function getTileIndex(object)
	local xPos = math.floor(mainmemory.read_u16_le(objectBase + object_fields.x_position) / 256 / tileWidth);
	local yPos = math.floor(mainmemory.read_u16_le(objectBase + object_fields.y_position) / 256 / tileHeight);
	return 1 + (yPos * 16 + xPos);
end

function toggle01(value)
	if value ~= 0 then
		return 0;
	else
		return 1;
	end
end

function drawObjects()

	local mouse = input.getmouse();

	if showHitbox then
		gui.clearGraphics();
	end

	local startDrag = false;
	local dragging = false;
	local dragTransform = {0, 0};
	if mouse.Left then
		if not mouseLastFrame.Left then
			startDrag = true;
			startDragPosition = {mouse.X, mouse.Y};
		end
		dragging = true;
		dragTransform = {mouse.X - startDragPosition[1], mouse.Y - startDragPosition[2]};
	else
		draggedObjects = {};
		dragging = false;
	end

	local row = 0;
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		local objectTypeTable = nil;
		local color = nil;
		if objectType ~= 0 then
			-- Default to 16 width/height for hitbox
			local hitboxXOffset = -8;
			local hitboxYOffset = -16;
			local hitboxWidth = 16;
			local hitboxHeight = 16;

			-- Get the X and Y position of the object
			local xPosition = mainmemory.read_u16_le(objectBase + object_fields.x_position) / 256;
			local yPosition = mainmemory.read_u16_le(objectBase + object_fields.y_position) / 256;

			if type(object_fields.object_types[objectType]) == "table" then
				objectTypeTable = object_fields.object_types[objectType];

				if type(objectTypeTable.name) == "string" then
					objectType = object_fields.object_types[objectType].name.." "..toHexString(objectType);
				else
					objectType = "Unknown ("..toHexString(objectType)..")";
				end

				if type(objectTypeTable["color"]) == "number" then
					color = objectTypeTable["color"];
				end

				if type(objectTypeTable.hitbox_x_offset) == "number" then
					hitboxXOffset = objectTypeTable.hitbox_x_offset;
				end
				if type(objectTypeTable.hitbox_y_offset) == "number" then
					hitboxYOffset = objectTypeTable.hitbox_y_offset;
				end

				if type(objectTypeTable.hitbox_width) == "number" then
					hitboxWidth = objectTypeTable.hitbox_width;
				end
				if type(objectTypeTable.hitbox_height) == "number" then
					hitboxHeight = objectTypeTable.hitbox_height;
				end
			else
				color = pink;
				objectType = "Unknown ("..toHexString(objectType)..")";
			end

			if showHitbox then
				if dragging then
					for d = 1, #draggedObjects do
						if draggedObjects[d][1] == objectBase then
							xPosition = draggedObjects[d][2] + dragTransform[1];
							yPosition = draggedObjects[d][3] + dragTransform[2];
							mainmemory.write_s16_le(objectBase + object_fields.x_position, xPosition * 256);
							mainmemory.write_s16_le(objectBase + object_fields.y_position, yPosition * 256);
							break;
						end
					end
				end

				if (mouse.X >= xPosition + hitboxXOffset and mouse.X <= xPosition + hitboxXOffset + hitboxWidth) and (mouse.Y >= yPosition + hitboxYOffset and mouse.Y <= yPosition + hitboxYOffset + hitboxHeight) then
					if startDrag then
						table.insert(draggedObjects, {objectBase, xPosition, yPosition});
					end

					local mouseOverText = {
						objectType,
						toHexString(objectBase).." "..round(xPosition)..","..round(yPosition),
					};

					local maxLength = -math.huge;
					for t = 1, #mouseOverText do
						maxLength = math.max(maxLength, string.len(mouseOverText[t]));
					end
					local safeX = math.min(xPosition + hitboxXOffset, 256 - (maxLength * textWidth));
					local safeY = math.min(yPosition + hitboxYOffset, 192 - (#mouseOverText * textHeight));

					for t = 1, #mouseOverText do
						gui.drawText(safeX, safeY + ((t - 1) * textHeight), mouseOverText[t], color);
					end
				end
				gui.drawRectangle(xPosition + hitboxXOffset, yPosition + hitboxYOffset, hitboxWidth, hitboxHeight, color); -- Draw the object's hitbox
			end

			if showList then
				gui.text(2, 2 + textHeight * row, round(xPosition)..", "..round(yPosition).." - "..objectType.." "..toHexString(objectBase), color, 'bottomright');
				row = row + 1;
			end
		end
	end

	if RNGSolver.enabled then
		if RNGSolver.mode == "SetSpawn" then
			if mouse.Left then
				if not mouseLastFrame.Left then
					togglePosition.x = math.floor(mouse.X / tileWidth);
					togglePosition.y = math.floor(mouse.Y / tileHeight);
					RNGSolver.spawnArray[1 + (togglePosition.y * 16 + togglePosition.x)] = toggle01(RNGSolver.spawnArray[1 + (togglePosition.y * 16 + togglePosition.x)]);
				end
			end
			for x = 0, 16 do
				for y = 0, 9 do
					local color = 0x7FFF0000;
					if RNGSolver.spawnArray[1 + (y * 16 + x)] == 1 then
						color = 0x7F00FF00;
					end
					gui.drawRectangle(x * tileWidth, y * tileHeight, tileWidth, tileHeight, color, color);
				end
			end
		end
	end

	if mouse.Middle and not mouseLastFrame.Middle then
		drawCursor = not drawCursor;
	end

	-- Draw Mouse Cursor
	if drawCursor then
		gui.drawImage("cursor.png", mouse.X, mouse.Y - 4);
	end

	mouseLastFrame.Left = mouse.Left;
	mouseLastFrame.Middle = mouse.Middle;
	mouseLastFrame.Right = mouse.Right;
end

event.onframestart(drawObjects);