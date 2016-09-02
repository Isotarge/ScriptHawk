-- Configuration
showList = false;
showHitbox = true;

local red = 0xFFFF0000;
local yellow = 0xFFFFFF00;
local green = 0xFF00FF00;
local pink = 0xFFFF00FF;
local black = 0xFF000000;
local white = 0xFFFFFFFF;

-- Game state
local object_array_base = 0xE80;
local object_size = 0x21;
local object_array_capacity = 27;

local max_player_projectiles = 3;
local max_enemies = 7;

local object_fields = {
	["object_type"] = 0x00, -- Byte
	["object_types"] = {
		[0x01] = {["name"] = "Player", ["color"] = yellow},
		[0x02] = {["name"] = "Player Projectile", ["color"] = yellow, ["hitbox_height"] = 8, ["hitbox_width"] = 8},
		[0x03] = {["name"] = "Player Projectile", ["color"] = yellow, ["hitbox_height"] = 8, ["hitbox_width"] = 8},
		[0x04] = {["name"] = "Boss", ["color"] = pink}, -- Early levels
		[0x05] = {["name"] = "Boss", ["color"] = pink}, -- Later levels
		[0x06] = {["name"] = "Boss Projectile", ["color"] = red},
		[0x07] = {["name"] = "Boss Projectile", ["color"] = red}, -- Level 5
		[0x08] = {["name"] = "Boss Projectile", ["color"] = red},
		[0x09] = {["name"] = "Enemy Projectile", ["color"] = red, ["hitbox_height"] = 8, ["hitbox_width"] = 8}, -- Small projectile
		[0x0A] = {["name"] = "Boss Projectile", ["color"] = red, ["hitbox_height"] = 8, ["hitbox_width"] = 8},
		[0x0B] = {["name"] = "Red Scroll", ["color"] = pink},
		[0x0C] = {["name"] = "Blue Scroll", ["color"] = pink},
		[0x0D] = {["name"] = "Green Scroll", ["color"] = pink},
		[0x0E] = {["name"] = "Splash"},
		[0x0F] = {["name"] = "Enemy Dying", ["isEnemy"] = true},
		[0x10] = {["name"] = "Grey Enemy", ["isEnemy"] = true},
		[0x11] = {["name"] = "Blue Enemy", ["isEnemy"] = true},
		[0x12] = {["name"] = "Grey Enemy", ["isEnemy"] = true},
		[0x13] = {["name"] = "Grey Enemy", ["isEnemy"] = true},
		[0x14] = {["name"] = "Grey Enemy", ["isEnemy"] = true}, -- Level 6
		[0x15] = {["name"] = "Grey Enemy", ["isEnemy"] = true},
		[0x16] = {["name"] = "Grey Enemy", ["isEnemy"] = true}, -- Scythe
		[0x17] = {["name"] = "Boulder Enemy", ["isEnemy"] = true},
		[0x18] = {["name"] = "Popup Enemy", ["isEnemy"] = true}, -- Level 2
		[0x19] = {["name"] = "Bouncing Boulder", ["color"] = red}, -- Level 2
		[0x1A] = {["name"] = "Bouncing Boulder Shadow"}, -- Level 2
		[0x1B] = {["name"] = "Horse", ["color"] = red}, -- Level 7
		[0x1C] = {["name"] = "Wolf", ["isEnemy"] = true},
		[0x1D] = {["name"] = "Light Blue Enemy", ["isEnemy"] = true}, -- Level 11
		[0x1E] = {["name"] = "Green Enemy", ["isEnemy"] = true}, -- Level 8
		[0x1F] = {["name"] = "Enemy Projectile", ["color"] = red}, -- Scythe
		[0x20] = {["name"] = "Grey Enemy", ["isEnemy"] = true}, -- From boulder, can contain green scroll
		[0x21] = {["name"] = "Boulder Enemy", ["isEnemy"] = true},
		[0x22] = {["name"] = "Grey Enemy", ["isEnemy"] = true}, -- Circling
		[0x23] = {["name"] = "Fire Enemy", ["isEnemy"] = true}, -- Level 7
		[0x24] = {["name"] = "Red Jumping Enemy", ["isEnemy"] = true}, -- Level 4
		[0x25] = {["name"] = "Red Enemy", ["isEnemy"] = true}, -- Level 4
		[0x26] = {["name"] = "Red Enemy", ["isEnemy"] = true}, -- Level 4, after jumping
		[0x27] = {["name"] = "Grey Enemy", ["isEnemy"] = true}, -- Cliff
		[0x28] = {["name"] = "Blue Enemy", ["isEnemy"] = true}, -- Cliff
		[0x29] = {["name"] = "Grey Enemy", ["isEnemy"] = true}, -- Cliff, moving up
		[0x2A] = {["name"] = "Ball Spawner"}, -- Cliff -- TODO: Does this count as an enemy?
		[0x2B] = {["name"] = "Ball", ["color"] = red, ["hitbox_height"] = 8, ["hitbox_width"] = 8}, -- Cliff
		[0x2C] = {["name"] = "Green Scroll Trigger", ["color"] = pink},
		[0x2D] = {["name"] = "Boulder Enemy", ["color"] = pink}, -- Contains green scroll, does not count towards enemy cap
		[0x2E] = {["name"] = "Arrow", ["color"] = pink}, -- Map Screen
		[0x2F] = {["name"] = "Red Scroll", ["color"] = pink}, -- Map Screen
		[0x30] = {["name"] = "Blue Scroll", ["color"] = pink}, -- Map Screen
		[0x31] = {["name"] = "Green Scrolls", ["color"] = pink}, -- Map Screen
		[0x32] = {["name"] = "Staircase Trigger", ["color"] = pink}, -- Level 10
		[0x33] = {["name"] = "Player", ["color"] = pink}, -- End screen
		[0x34] = {["name"] = "Princess", ["color"] = pink}, -- End screen
		[0x35] = {["name"] = "Boulder Enemy", ["isEnemy"] = true},
		[0x36] = {["name"] = "Blue Enemy", ["isEnemy"] = true, ["color"] = pink}, -- Contains red scroll
		[0x37] = {["name"] = "Blue Enemy", ["isEnemy"] = true, ["color"] = pink}, -- Contains blue scroll
		[0x38] = {["name"] = "Wolf", ["isEnemy"] = true, ["color"] = pink}, -- Contains red scroll
		[0x39] = {["name"] = "Grey Enemy", ["isEnemy"] = true, ["color"] = pink}, -- Contains blue scroll
		[0x3A] = {["name"] = "Red Enemy", ["isEnemy"] = true, ["color"] = pink}, -- Level 6, Contains red scroll
		[0x3B] = {["name"] = "Grey Enemy", ["isEnemy"] = true}, -- Circles, Contains red scroll

		[0x3D] = {["name"] = "Grey Enemy", ["isEnemy"] = true}, -- Level 10, Contains red scroll
		[0x3E] = {["name"] = "Light Blue Enemy", ["isEnemy"] = true, ["color"] = pink}, -- Level 11, Contains red scroll
		[0x3F] = {["name"] = "Light Blue Enemy", ["isEnemy"] = true, ["color"] = pink}, -- Level 11, Contains blue scroll
		[0x40] = {["name"] = "Grey Enemy", ["isEnemy"] = true}, -- Level 5
		[0x41] = {["name"] = "Grey Enemy", ["isEnemy"] = true, ["color"] = pink}, -- Level 5, Contains red scroll
		[0x42] = {["name"] = "Fire Enemy", ["isEnemy"] = true, ["color"] = pink}, -- Level 7, Contains red scroll
		[0x43] = {["name"] = "Grey Enemy", ["isEnemy"] = true, ["color"] = pink}, -- Cliff, Contains red scroll
		[0x44] = {["name"] = "Fire Enemy", ["isEnemy"] = true, ["color"] = pink}, -- Contains blue scroll
		[0x45] = {["name"] = "Easter Egg Trigger", ["color"] = yellow}, -- Only in Japanese version
	},
	["animation_index"] = 0x03, -- Byte
	["animation_current_frame"] = 0x04, -- Byte
	["animation_length"] = 0x05, -- Byte
	["segment_current_frame"] = 0x06, -- Byte
	["segment_length_frames"] = 0x07,
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

function countObjects()
	local num = 0;
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType ~= 0x00 then
			num = num + 1;
		end
	end
	return num;
end

function getX()
	return mainmemory.read_s16_le(0xEB2);
end

function getY()
	return mainmemory.read_s16_le(0xEAF);
end

function getLevelX()
	return mainmemory.read_u16_le(0xD72);
end

function getLevelY()
	return mainmemory.read_u16_le(0xD2B);
end

local prevPosition = {0,0};
local prevLevelPosition = {0,0};
local dx = 0;
local dy = 0;
local d = 0;
local dcolor = white;

function calculateDelta()
	local position = {getX(), getY()};
	local levelPosition = {getLevelX(), getLevelY()};
	dx = math.abs(prevLevelPosition[1] - levelPosition[1]) + math.abs(prevPosition[1] - position[1]);
	dy = math.abs(prevLevelPosition[2] - levelPosition[2]) + math.abs(prevPosition[2] - position[2]);
	if dx > 0 or dy > 0 then
		dcolor = white;
	else
		dcolor = red;
	end
	prevPosition = position;
	prevLevelPosition = levelPosition;
end
event.onframestart(calculateDelta, "ScriptHawk - Calculate Delta");

function getHits()
	return mainmemory.read_u16_le(0xDC4);
end

function getShots()
	return mainmemory.read_u16_le(0xDC6);
end

function getOptimalShots()
	return getHits() * 100 / 2 + 1;
end

function getHitRatio()
	local hits = getHits();
	local shots = getShots();
	if hits >= shots or (hits == 0 and shots == 0) then
		return "100%";
	end
	return round(hits / shots * 100, 2).."%";
end

function isBossLoaded()
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType == 0x04 or objectType == 0x05 then
			return true;
		end
	end
	return false;
end

function getBossHealth()
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType == 0x04 or objectType == 0x05 then
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

	local row = 0;
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
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
				color = black;
				objectType = "Unknown ("..toHexString(objectType)..")";
			end

			local hitboxXOffset = -(hitboxWidth / 2);
			local hitboxYOffset = -(hitboxHeight / 2);

			if showHitbox then
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
	row = row + 1;
	gui.text(OSDX, OSDY + height * row, "dX: "..dx, dcolor);
	row = row + 1;
	gui.text(OSDX, OSDY + height * row, "dY: "..dy, dcolor);
	row = row + 2;

	gui.text(OSDX, OSDY + height * row, "Player Proj: "..countPlayerProjectiles().."/"..max_player_projectiles);
	row = row + 1;
	gui.text(OSDX, OSDY + height * row, "Hits: "..getHits().."/"..getShots().." ("..getOptimalShots()..")");
	row = row + 1;
	gui.text(OSDX, OSDY + height * row, "Ratio: "..getHitRatio());
	row = row + 2;

	gui.text(OSDX, OSDY + height * row, "Objects: "..countObjects().."/"..object_array_capacity);
	row = row + 1;
	gui.text(OSDX, OSDY + height * row, "Enemies: "..countEnemies().."/"..max_enemies);
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