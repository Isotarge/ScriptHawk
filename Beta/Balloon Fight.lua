-- Configuration
showHitbox = true;

local red = 0xFFFF0000;
local yellow = 0xFFFFFF00;
local green = 0xFF00FF00;
local pink = 0xFFFF00FF;
local black = 0xFF000000;
local white = 0xFFFFFFFF;

-- Game state
local object_array_capacity = 6;
local object_fields = {
	["object_type"] = 0x7F, -- Byte
	["object_types"] = {
		-- TODO
	},
	["x_position"] = 0x91, -- u8
	["y_position"] = 0x9A, -- u8
};

local projectile_array_capacity = 4;
local projectile_fields = {
	["x_position"] = 0x490, -- u8
	["y_position"] = 0x4A4, -- u8
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

local function drawObjects()
	local height = 16; -- Text row height
	local width = 8; -- Text column width
	local mouse = input.getmouse();

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

	local objects = {};
	for i = 0, object_array_capacity do
		table.insert(objects, {
			["xPosAddress"] = object_fields.x_position + i,
			["yPosAddress"] = object_fields.y_position + i,
			["xPos"] = mainmemory.read_u8(object_fields.x_position + i),
			["yPos"] = mainmemory.read_u8(object_fields.y_position + i),
			["type"] = mainmemory.readbyte(object_fields.object_type + i),
		});
	end

	for i = 0, projectile_array_capacity do
		table.insert(objects, {
			["xPosAddress"] = projectile_fields.x_position + i,
			["yPosAddress"] = projectile_fields.y_position + i,
			["xPos"] = mainmemory.read_u8(projectile_fields.x_position + i),
			["yPos"] = mainmemory.read_u8(projectile_fields.y_position + i),
			["type"] = 1, -- TODO: need to find this
		});
	end

	for i = 1, #objects do
		local object = objects[i];
		local objectTypeTable = nil;
		local color = nil;

		-- Default to 16 width/height for hitbox
		local hitboxXOffset = 0;
		local hitboxYOffset = 0;
		local hitboxWidth = 16;
		local hitboxHeight = 16;

		if type(object_fields.object_types[object.type]) == "table" then
			objectTypeTable = object_fields.object_types[object.type];

			if type(objectTypeTable.name) == "string" then
				object.type = object_fields.object_types[object.type].name.." "..toHexString(object.type);
			else
				object.type = "Unknown ("..toHexString(object.type)..")";
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
			object.type = "Unknown ("..toHexString(object.type)..")";
		end

		if showHitbox then
			if dragging then
				for d = 1, #draggedObjects do
					if draggedObjects[d][1] == i then
						object.xPos = draggedObjects[d][2] + dragTransform[1];
						object.yPos = draggedObjects[d][3] + dragTransform[2];
						mainmemory.write_u8(object.xPosAddress, object.xPos);
						mainmemory.write_u8(object.yPosAddress, object.yPos);
						break;
					end
				end
			end

			if (mouse.X >= object.xPos + hitboxXOffset and mouse.X <= object.xPos + hitboxXOffset + hitboxWidth) and (mouse.Y >= object.yPos + hitboxYOffset and mouse.Y <= object.yPos + hitboxYOffset + hitboxHeight) then
				if startDrag then
					table.insert(draggedObjects, {i, object.xPos, object.yPos});
				end

				local mouseOverText = {
					object.type,
					i..": "..object.xPos..","..object.yPos,
				};

				local maxLength = -math.huge;
				for t = 1, #mouseOverText do
					maxLength = math.max(maxLength, string.len(mouseOverText[t]));
				end
				local safeX = math.min(object.xPos + hitboxXOffset, 256 - (maxLength * width)); -- TODO: Correct safe values for NES
				local safeY = math.min(object.yPos + hitboxYOffset, 192 - (#mouseOverText * height)); -- TODO: Correct safe values for NES

				for t = 1, #mouseOverText do
					gui.drawText(safeX, safeY + ((t - 1) * height), mouseOverText[t], color);
				end
			end
			gui.drawRectangle(object.xPos + hitboxXOffset, object.yPos + hitboxYOffset, hitboxWidth, hitboxHeight, color); -- Draw the object's hitbox
		end
	end
end

while true do
	drawObjects();
	emu.yield();
end