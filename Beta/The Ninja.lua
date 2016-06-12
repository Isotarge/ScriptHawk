-- Configuration
showList = false;
showHitbox = true;
showInactive = false;

local red = 0xFFFF0000;
local yellow = 0xFFFFFF00;
local green = 0xFF00FF00;
local pink = 0xFFFF00FF;

-- Game state
local object_array_base = 0xE80;
local object_size = 0x21;
local object_array_capacity = 26;

local maxPlayerProjectiles = 3;
local maxEnemies = 0; -- TODO: Figure out max enemies
local maxEnemyProjectiles = 0; -- TODO: Figure out max enemy projectiles

local object_fields = {
	["object_type"] = 0x00, -- Byte
	["object_types"] = {
		[0x01] = {["name"] = "Player", ["color"] = yellow},
		[0x02] = {["name"] = "Player Projectile", ["color"] = yellow},
		[0x03] = {["name"] = "Player Projectile", ["color"] = yellow},
		[0x04] = {["name"] = "Boss", ["color"] = red},
		[0x09] = {["name"] = "Enemy Projectile", ["isEnemyProjectile"] = true, ["color"] = red}, -- Small projectile
		[0x0B] = {["name"] = "Red Scroll", ["color"] = pink},
		[0x0C] = {["name"] = "Blue Scroll", ["color"] = pink}
		[0x0D] = {["name"] = "Green Scroll", ["color"] = pink},
		[0x10] = {["name"] = "Grey Enemy", ["isEnemy"] = true},
		[0x13] = {["name"] = "Grey Enemy", ["isEnemy"] = true},
		[0x16] = {["name"] = "Grey Enemy", ["isEnemy"] = true}, -- Scythe
		[0x17] = {["name"] = "Boulder Enemy", ["isEnemy"] = true},
		[0x1C] = {["name"] = "Wolf Enemy", ["isEnemy"] = true},
		[0x1F] = {["name"] = "Enemy Projectile", ["isEnemyProjectile"] = true, ["color"] = red}, -- Scythe
		[0x20] = {["name"] = "Grey Enemy"}, -- From boulder
		[0x2D] = {["name"] = "Boulder Enemy", ["isEnemy"] = true, ["color"] = pink}, -- Conrtains green scroll
		[0x2E] = {["name"] = "Arrow", ["color"] = pink}, -- Map Screen
		[0x36] = {["name"] = "Blue Enemy", ["isEnemy"] = true},
	},
	["x_position"] = 0x11, -- s16_le
	["y_position"] = 0x0E, -- s16_le
	["boss_health"] = 0x1E, -- byte
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

function countPlayerProjectiles()
	local num = 0;
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType == 0x02 or objectType == 0x03 then
			num = num + 1;
		end
	end
	return num;
end

function countEnemies()
	local num = 0;
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if object_fields.object_types[objectType] ~= nil then
			if object_fields.object_types[objectType].isEnemy == true then
				num = num + 1;
			end
		end
	end
	return num;
end

function countEnemyProjectiles()
	local num = 0;
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if object_fields.object_types[objectType] ~= nil then
			if object_fields.object_types[objectType].isEnemyProjectile == true then
				num = num + 1;
			end
		end
	end
	return num;
end

function getX()
	return mainmemory.readbyte(0xEB2); -- TODO: This is a s16_le
end

function getY()
	return mainmemory.readbyte(0xEAF); -- TODO: This is a s16_le
end

function getLevelX()
	return mainmemory.read_u16_le(0xD72);
end

function getLevelY()
	return mainmemory.read_u16_le(0xD2B);
end

function getHits()
	return mainmemory.read_u16_le(0xDC4);
end

function getShots()
	return mainmemory.read_u16_le(0xDC6);
end

function getHitRatio()
	local hits = getHits();
	local shots = getShots();
	if hits == 0 and shots == 0 then
		return "100%";
	end
	return round(hits / shots * 100, 2).."%";
end

function isBossLoaded()
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType == 0x04 then
			return true;
		end
	end
	return false;
end

function getBossHealth()
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType == 0x04 then
			return mainmemory.readbyte(objectBase + object_fields.boss_health);
		end
	end
	return 0;
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

	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		local objectActive = true;
		local objectTypeTable = nil;
		local color = nil;
		if objectType ~= 0 then
			-- Default to 16 width/height for hitbox
			local hitboxWidth = 16;
			local hitboxHeight = 16;

			-- Get the X and Y position of the object
			local xPosition = mainmemory.read_s16_le(objectBase + object_fields.x_position);
			local yPosition = mainmemory.read_s16_le(objectBase + object_fields.y_position);

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

				if type(objectTypeTable.hitbox_width) == "number" then
					hitboxWidth = objectTypeTable.hitbox_width;
				end
				if type(objectTypeTable.hitbox_height) == "number" then
					hitboxHeight = objectTypeTable.hitbox_height;
				end

				if type(objectTypeTable.active) == "function" then
					objectActive = objectTypeTable.active(objectBase); -- Call the function to check whether the object is active
				end
			else
				objectType = "Unknown ("..toHexString(objectType)..")";
			end

			if objectType == 0x52 then
				if mainmemory.readbyte(objectBase + 0x07) == 0xD3 and mainmemory.readbyte(objectBase + 0x08) == 0x80 then -- Detect crown and make it flash Red & Yellow
					if emu.framecount() % 10 > 4 then
						color = red;
					else
						color = yellow;
					end
				end
			end

			if showHitbox then
				if showInactive or objectActive then
					if dragging then
						for d = 1, #draggedObjects do
							if draggedObjects[d][1] == objectBase then
								xPosition = draggedObjects[d][2] + dragTransform[1];
								yPosition = draggedObjects[d][3] + dragTransform[2];
								mainmemory.write_s16_le(objectBase + object_fields.x_position, xPosition);
								mainmemory.write_s16_le(objectBase + object_fields.y_position, yPosition);
								break;
							end
						end
					end

					if (mouse.X >= xPosition and mouse.X <= xPosition + hitboxWidth) and (mouse.Y >= yPosition and mouse.Y <= yPosition + hitboxHeight) then
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
						local safeX = math.min(xPosition, 256 - (maxLength * width));
						local safeY = math.min(yPosition, 192 - (#mouseOverText * height));

						for t = 1, #mouseOverText do
							gui.drawText(safeX, safeY + ((t - 1) * height), mouseOverText[t], color);
						end
					end
					gui.drawRectangle(xPosition, yPosition, hitboxWidth, hitboxHeight, color); -- Draw the object's hitbox
				end
			end

			if showList then
				local list_x_offset = 2;
				local list_y_offset = 2;
				local row = 0;

				gui.text(list_x_offset, list_y_offset + height * row, xPosition..", "..yPosition.." - "..objectType.." "..toHexString(objectBase), color, nil, 'bottomright');
				row = row + 1;
			end
		end
	end
end

function drawOSD()
	gui.cleartext();

	local OSDX = 2;
	local OSDY = 70;
	local row = 0;
	local height = 16;

	gui.text(OSDX, OSDY + height * row, "Position: "..getX()..","..getY());
	row = row + 1;
	gui.text(OSDX, OSDY + height * row, "Level Pos: "..getLevelX()..","..getLevelY());
	row = row + 2;

	gui.text(OSDX, OSDY + height * row, "Player Proj: "..countPlayerProjectiles().."/"..maxPlayerProjectiles);
	row = row + 1;
	gui.text(OSDX, OSDY + height * row, "Hits: "..getHits().."/"..getShots());
	row = row + 1;
	gui.text(OSDX, OSDY + height * row, "Ratio: "..getHitRatio());
	row = row + 2;

	gui.text(OSDX, OSDY + height * row, "Enemies: "..countEnemies().."/"..maxEnemies);
	row = row + 1;
	gui.text(OSDX, OSDY + height * row, "Enemy Proj: "..countEnemyProjectiles().."/"..maxEnemyProjectiles);
	row = row + 2;

	if isBossLoaded() then
		gui.text(OSDX, OSDY + height * row, "Boss Health: "..getBossHealth());
		row = row + 1;
	end

	drawObjects();
end

while true do
	drawOSD();
	emu.yield();
end