-- Configuration
showList = false;
showHitbox = true;

local red = 0xFFFF0000;
local yellow = 0xFFFFFF00;
local green = 0xFF00FF00;
local pink = 0xFFFF00FF;
local black = 0xFF000000;
local white = 0xFFFFFFFF

-- Game state
local object_array_capacity = 6;

local object_fields = {
	["object_type"] = 0x7F, -- Byte
	["object_types"] = {},
	["x_position"] = 0x91, -- u8
	["y_position"] = 0x9A, -- u8
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

local mouseClickedLastFrame = false;
local startDragPosition = {0,0};
local draggedObjects = {};

function drawObjects()
	local height = 16; -- Text row height
	local width = 8; -- Text column width
	local mouse = input.getmouse();

	if showHitbox then
		gui.clearGraphics();
	end

	-- Draw mouse pixel
	--gui.drawPixel(mouse.X, mouse.Y, red);

	local startDrag = false;
	local dragging = false;
	local dragTransform = {0, 0};
	if mouse.Left then
		if not mouseClickedLastFrame then
			startDrag = true;
			startDragPosition = {mouse.X, mouse.Y};
		end
		mouseClickedLastFrame = true;
		dragging = true;
		dragTransform = {mouse.X - startDragPosition[1], mouse.Y - startDragPosition[2]};
	else
		draggedObjects = {};
		mouseClickedLastFrame = false;
		dragging = false;
	end

	local row = 0;
	for i = 0, object_array_capacity do
		local objectType = mainmemory.readbyte(object_fields.object_type + i);
		local objectTypeTable = nil;
		local color = nil;

		-- Default to 16 width/height for hitbox
		local hitboxXOffset = 0;
		local hitboxYOffset = 0;
		local hitboxWidth = 16;
		local hitboxHeight = 16;

		-- Get the X and Y position of the object
		local xPosition = mainmemory.read_u8(object_fields.x_position + i);
		local yPosition = mainmemory.read_u8(object_fields.y_position + i);

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
			color = white;
			objectType = "Unknown ("..toHexString(objectType)..")";
		end

		if showHitbox then
			if dragging then
				for d = 1, #draggedObjects do
					if draggedObjects[d][1] == objectBase then
						xPosition = draggedObjects[d][2] + dragTransform[1];
						yPosition = draggedObjects[d][3] + dragTransform[2];
						mainmemory.write_u8(object_fields.x_position + i, xPosition);
						mainmemory.write_u8(object_fields.y_position + i, yPosition);
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
					toHexString(objectBase).." "..xPosition..","..yPosition,
				};

				local maxLength = -math.huge;
				for t = 1, #mouseOverText do
					maxLength = math.max(maxLength, string.len(mouseOverText[t]));
				end
				local safeX = math.min(xPosition + hitboxXOffset, 256 - (maxLength * width));
				local safeY = math.min(yPosition + hitboxYOffset, 192 - (#mouseOverText * height));

				for t = 1, #mouseOverText do
					gui.drawText(safeX, safeY + ((t - 1) * height), mouseOverText[t], color);
				end
			end
			gui.drawRectangle(xPosition + hitboxXOffset, yPosition + hitboxYOffset, hitboxWidth, hitboxHeight, color); -- Draw the object's hitbox
		end

		if showList then
			gui.text(2, 2 + height * row, xPosition..", "..yPosition.." - "..objectType.." "..toHexString(objectBase), color, 'bottomright');
			row = row + 1;
		end
	end
end

while true do
	drawObjects();
	emu.yield();
end