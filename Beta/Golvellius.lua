-- Configuration
alwaysHP = true;
enableDamageTimer = true;
enableDragAndDrop = false;
enableLagDetection = false;
showList = false;
showHitbox = true;

print("Settings:");
print();
print("alwaysHP = "..tostring(alwaysHP));
print("enableDamageTimer = "..tostring(enableDamageTimer));
print("enableDragAndDrop = "..tostring(enableDragAndDrop));
print("enableLagDetection = "..tostring(enableLagDetection));
print("showHitbox = "..tostring(showHitbox));
print("showList = "..tostring(showList));

local red = 0xFFFF0000;
local yellow = 0xFFFFFF00;
local gold = 0xFFFFD700;
local green = 0xFF00AA00; -- Hair Color
local pink = 0xFFFF00FF;
local black = 0xFF000000;
local white = 0xFFFFFFFF;

-- Game state
local object_array_base = 0x100;
local object_size = 0x20;
local object_array_capacity = 16;

local object_fields = {
	["object_type"] = 0x00, -- Byte
	["object_types"] = {
		[0x4C] = {name = "Player"}, -- Damaged, Vertical Dungeon
		--
		[0x59] = {name = "Player"}, -- Damaged, Side Scroller
		--
		[0x5E] = {name = "Player"}, -- Damaged, Overworld
		--
		[0x81] = {name = "Player"}, -- Overworld
		[0x82] = {name = "Player"}, -- Dungeon, Side Scroller
		[0x83] = {name = "Player"}, -- Dungeon, Vertical
		[0x84] = {name = "Sword", color = yellow}, -- Player Sword
		--
		[0x87] = {name = "Snakelet", gold = 10, color = red, max_hp = 1},
		[0x88] = {name = "Fire Spirit", gold = 40, color = red, max_hp = 2},
		[0x89] = {name = "Flea", gold = 30, color = red, max_hp = 2},
		[0x8A] = {name = "Basketworm", gold = 20, color = red, max_hp = 2},
		[0x8B] = {name = "Spider", gold = 100, color = red, max_hp = 3},
		[0x8C] = {name = "Health", color = pink},
		--
		[0x90] = {name = "Fly", gold = 80, color = red, max_hp = 1},
		[0x91] = {name = "Tick", gold = 60, color = red, max_hp = 1},
		[0x92] = {name = "Dark Blue Bat", gold = 30, color = red, max_hp = 1},
		[0x93] = {name = "Little Big Bat", gold = 0, color = red, max_hp = 0},
		[0x94] = {name = "Big Bat", gold = 0, color = red, max_hp = 16},
		[0x95] = {name = "Spawning Enemy"},
		--
		[0x99] = {name = "Black Crow", gold = 40, color = red, max_hp = 1},
		[0x9A] = {name = "Blue Crow", gold = 90, color = red, max_hp = 2},
		[0x9B] = {name = "Red Crow", gold = 210, color = red, max_hp = 3},
		--
		[0x9D] = {name = "Dark Blue Bat", gold = 30, color = red, max_hp = 1},
		[0x9E] = {name = "Light Blue Bat", gold = 50, color = red, max_hp = 2},
		[0x9F] = {name = "Red Bat", gold = 200, color = red, max_hp = 2},
		[0xA0] = {name = "White Bat", gold = 300, color = red, max_hp = 6},
		[0xA1] = {name = "Red Bat", gold = 200, color = red, max_hp = 6},
		[0xA2] = {name = "Yellow Bee", gold = 100, color = red, max_hp = 1},
		[0xA3] = {name = "Red Bee", gold = 200, color = red, max_hp = 2},
		[0xA4] = {name = "Light Blue Spider", gold = 80, color = red, max_hp = 2},
		[0xA5] = {name = "Dark Blue Spider", gold = 180, color = red, max_hp = 5},
		[0xA6] = {name = "Red Spider", gold = 280, color = red, max_hp = 5},
		--
		[0xA8] = {name = "Green Frog", gold = 40, color = red, max_hp = 2},
		[0xA9] = {name = "Red Frog", gold = 200, color = red, max_hp = 3},
		[0xAA] = {name = "Red Snake", gold = 10, color = red, max_hp = 1},
		[0xAB] = {name = "Blue Snake", gold = 40, color = red, max_hp = 2},
		[0xAC] = {name = "Green Snake", gold = 180, color = red, max_hp = 3},
		[0xAD] = {name = "White Snake", gold = 220, color = red, max_hp = 6},
		[0xAE] = {name = "Red Jellyfish", gold = 300, color = red, max_hp = 9},
		--
		[0xB0] = {name = "Green Potato Bug", gold = 100, color = red, max_hp = 4},
		[0xB1] = {name = "White Potato Bug", gold = 240, color = red, max_hp = 9},
		[0xB2] = {name = "Red Porcupig", gold = 30, color = red, max_hp = 2},
		[0xB3] = {name = "Blue Porcupig", gold = 100, color = red, max_hp = 4},
		--
		[0xB5] = {name = "Red Troll", gold = 120, color = red, max_hp = 6},
		[0xB6] = {name = "Blue Troll", gold = 330, color = red, max_hp = 6},
		--
		[0xB8] = {name = "Blue Knight", gold = 100, color = red, max_hp = 6},
		[0xB9] = {name = "Red Knight", gold = 200, color = red, max_hp = 9},
		--
		[0xBB] = {name = "Skeleton", gold = 120, color = red, max_hp = 4},
		[0xBC] = {name = "Black Skeleton", gold = 330, color = red, max_hp = 9},
		[0xBD] = {name = "Blue Mouse", gold = 200, color = red, max_hp = 6},
		--
		[0xBF] = {name = "Red Mole", gold = 60, color = red, max_hp = 2},
		[0xC0] = {name = "Blue Mole", gold = 120, color = red, max_hp = 5},
		--
		[0xD0] = {name = "Boss 1", color = red, max_hp = 20},
		[0xD1] = {name = "Boss 2", color = red, max_hp = 36},
		[0xD2] = {name = "Boss 3", color = red, max_hp = 40},
		[0xD3] = {name = "Boss 4", color = red, max_hp = 66},
		[0xD4] = {name = "Boss 5", color = red, max_hp = 56},
		--
		[0xDB] = {name = "Projectile", color = yellow},
		--
		[0xE0] = {name = "Boss 1 Projectile", color = yellow},
		[0xE1] = {name = "Boss 3 Projectile", color = yellow},
		[0xE2] = {name = "Boss 4 Projectile", color = yellow},
		--
		[0xE5] = {name = "Giant Snake", gold = 0, color = red, max_hp = 5},
		--
		[0xEF] = {name = "Projectile", color = yellow},
	},
	["y_position"] = 0x01, -- u8
	["x_position"] = 0x02, -- u8
	["spawn_timer"] = 0x08, -- u8
	["sword_timer"] = 0x0D, -- u8
	["health"] = 0x15, -- u8
	["damage_timer"] = 0x1F, -- u8
};

-- Map data
local map_base = 0xA00;
local map_width = 0x0F;
local map_height = 0x0C;

function getHoleTile()
	return mainmemory.readbyte(0xAD2);
end

function getHolePosition()
	local holeTile = getHoleTile();
	local xTile = holeTile % map_width;
	local yTile = math.floor(holeTile / map_width);
	return {xTile * 16 + 8, yTile * 16};
end

function renderHolePosition()
	local playerType = mainmemory.readbyte(0x100);
	if playerType == 0x5E or playerType == 0x81 then -- Don't render hole position in dungeons
		local holePosition = getHolePosition();
		gui.drawRectangle(holePosition[1], holePosition[2], 16, 16, green, 0x7F000000);
		gui.drawText(holePosition[1] + 3, holePosition[2], "H", white, 0x00000000);
	end
end
event.onframestart(renderHolePosition);

-- Lag Detection
local prevLag = -1;
function detectLag()
	local currentLag = mainmemory.readbyte(0x808);
	if enableLagDetection and mainmemory.readbyte(0x100) == 0x83 then -- Only detect lag for vertical dungeons
		if currentLag == prevLag then
			tastudio.setlag(emu.framecount(), true);
		else
			tastudio.setlag(emu.framecount(), false);
		end
	end
	prevLag = currentLag;
end
event.onframestart(detectLag);

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
		local objectTypeNumeric = objectType;
		local objectTypeTable = nil;
		local color = nil;
		if objectType ~= 0 then
			-- Default to 16 width/height for hitbox
			local hitboxWidth = 16;
			local hitboxHeight = 16;

			-- Get the X and Y position of the object
			local xPosition = mainmemory.readbyte(objectBase + object_fields.x_position);
			local yPosition = mainmemory.readbyte(objectBase + object_fields.y_position);
			local hp = mainmemory.readbyte(objectBase + object_fields.health);
			local maxHP = "?";
			local goldOnKill = -1;

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

				if type(objectTypeTable.gold) == "number" then
					goldOnKill = objectTypeTable.gold;
				end
				if type(objectTypeTable.max_hp) == "number" then
					maxHP = objectTypeTable.max_hp;
				end
			else
				color = white;
				objectType = "Unknown ("..toHexString(objectType)..")";
			end

			local hitboxXOffset = -(hitboxWidth / 2);
			local hitboxYOffset = -(hitboxHeight / 2);

			if showHitbox then
				if enableDragAndDrop and dragging then
					for d = 1, #draggedObjects do
						if draggedObjects[d][1] == objectBase then
							xPosition = draggedObjects[d][2] + dragTransform[1];
							yPosition = draggedObjects[d][3] + dragTransform[2];
							mainmemory.writebyte(objectBase + object_fields.x_position, xPosition);
							mainmemory.writebyte(objectBase + object_fields.y_position, yPosition);
							break;
						end
					end
				end

				if (mouse.X >= xPosition + hitboxXOffset and mouse.X <= xPosition + hitboxXOffset + hitboxWidth) and (mouse.Y >= yPosition + hitboxYOffset and mouse.Y <= yPosition + hitboxYOffset + hitboxHeight) then
					if startDrag then
						table.insert(draggedObjects, {objectBase, xPosition, yPosition});
					end

					local mouseOverText = {
						objectType.." "..hp.."/"..maxHP.." HP",
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
				else
					if objectTypeNumeric == 0x95 then -- Spawning enemy should show countdown to spawn
						gui.drawText(xPosition + hitboxXOffset, yPosition + hitboxYOffset, mainmemory.readbyte(objectBase + object_fields.spawn_timer), gold);
					elseif objectTypeNumeric == 0x84 then -- Sword should show Sword Timer
						gui.drawText(xPosition + hitboxXOffset, yPosition + hitboxYOffset, mainmemory.readbyte(objectBase + object_fields.sword_timer), gold);
					elseif (not alwaysHP) and goldOnKill > 0 then
						gui.drawText(xPosition + hitboxXOffset, yPosition + hitboxYOffset, ""..goldOnKill, gold);
					elseif objectBase ~= 0x100 then -- Everyone without a gold value should show their current/max HP (except the player)
						local damageTimerString = "";
						if enableDamageTimer then
							local damageTimer = mainmemory.readbyte(objectBase + object_fields.damage_timer);
							if damageTimer > 0 then
								damageTimerString = " "..damageTimer;
							end
						end
						gui.drawText(xPosition + hitboxXOffset, yPosition + hitboxYOffset, hp.."/"..maxHP..damageTimerString, gold);
					end
				end
				gui.drawRectangle(xPosition + hitboxXOffset, yPosition + hitboxYOffset, hitboxWidth, hitboxHeight, color); -- Draw the object's hitbox
			end

			if showList then
				gui.text(2, 2 + height * row, xPosition..", "..yPosition.." - "..hp.."/"..maxHP.." HP - "..objectType.." "..toHexString(objectBase), color, 'bottomright');
				row = row + 1;
			end
		end
	end
end

function getGold()
	local hundred_thousands = toHexString(mainmemory.readbyte(0x83F), 2, ""); -- 100000s
	local thousands = toHexString(mainmemory.readbyte(0x840), 2, ""); -- 1000s
	local tens = toHexString(mainmemory.readbyte(0x841), 2, ""); -- 10s
	return hundred_thousands..thousands..tens.."0";
end

function drawOSD()
	gui.drawRectangle(156, 2, 92, 13, 0, 0x7F000000);
	gui.drawText(156, 1, getGold().." Gold", gold, 0);
	drawObjects();
end

event.onframestart(drawOSD);
event.onloadstate(drawOSD);