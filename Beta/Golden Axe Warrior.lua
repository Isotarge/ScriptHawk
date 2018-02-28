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
map data in ram roughly 0x1600
]]

-- Configuration
showList = false;
showHitbox = true;
drawCursor = true;

local white = 0xFFFFFFFF;
local red = 0xFFFF0000;
local yellow = 0xFFFFFF00;
local green = 0xFF00FF00;
local blue = 0xFF00FFFF;
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
		[0x01] = {name = "Dying Enemy", color = white},
		[0x02] = {name = "Player", color = yellow},
		--
		[0x07] = {name = "Explosion Spawner", color = yellow}, -- Post boss
		[0x08] = {name = "Yellow Horn", color = pink}, -- Collectable
		[0x09] = {name = "Blue Horn", color = pink}, -- Collectable
		[0x0A] = {name = "Bread", color = pink}, -- Collectable
		[0x0B] = {name = "Meat", color = pink}, -- Collectable
		[0x0C] = {name = "Magic Pot", color = pink}, -- Collectable
		[0x0D] = {name = "Hourglass", color = pink}, -- Collectable
		[0x0E] = {name = "Key", color = pink}, -- Collectable
		[0x0F] = {name = "Crystal", color = pink}, -- Collectable
		[0x10] = {name = "Spear", color = yellow}, -- Projectile
		[0x11] = {name = "Axe", color = yellow}, -- Projectile
		[0x12] = {name = "Spell", color = yellow}, -- Projectile, Snoutman
		[0x13] = {name = "Fireball", color = yellow}, -- Projectile, Sea Dragon
		[0x14] = {name = "Fireball", color = yellow}, -- Projectile, Sea Dragon
		[0x15] = {name = "Fireball", color = yellow}, -- Projectile, Sea Dragon
		[0x16] = {name = "Projectile", color = yellow}, -- Projectile
		[0x17] = {name = "Projectile", color = yellow}, -- Projectile
		[0x18] = {name = "Projectile", color = yellow}, -- Projectile
		[0x19] = {name = "Projectile", color = yellow}, -- Projectile, Boulder
		[0x1A] = {name = "Sword", color = yellow}, -- Projectile, Dark Soldier
		[0x1B] = {name = "Snowball", color = yellow}, -- Projectile, Dweepie
		[0x1C] = {name = "Fire", color = yellow}, -- Projectile, Fire Goblin
		[0x1D] = {name = "Fire", color = yellow}, -- Projectile, Lava Spawner
		[0x1E] = {name = "Fire", color = yellow}, -- Projectile
		[0x1F] = {name = "Rock", color = yellow}, -- Projectile, Rockhead
		[0x20] = {name = "Snoutman", color = red}, -- Green
		[0x21] = {name = "Snoutman", color = red}, -- Blue
		[0x22] = {name = "Snoutman", color = red}, -- Red
		[0x23] = {name = "Hornet", color = red}, -- Green
		[0x24] = {name = "Hornet", color = red}, -- Blue
		--
		[0x26] = {name = "Globus", color = red}, -- Green
		[0x27] = {name = "Globus", color = red}, -- Blue
		[0x28] = {name = "Globus", color = red}, -- Red
		[0x29] = {name = "Scorpion", color = red}, -- Green
		[0x2A] = {name = "Scorpion", color = red}, -- Red
		[0x2B] = {name = "Desert Cap", color = red},
		[0x2C] = {name = "Twister", color = red}, -- Blue
		[0x2D] = {name = "Skull", color = yellow}, -- Projectile Spawner
		[0x2E] = {name = "Sea Dragon", color = red}, -- Green
		[0x2F] = {name = "Sea Dragon", color = red}, -- Red
		[0x30] = {name = "Shadow", color = yellow}, -- Bounder
		[0x31] = {name = "Bounder", color = red}, -- Blue
		[0x32] = {name = "Bounder", color = red}, -- Red
		[0x33] = {name = "Flying Fish", color = red}, -- Green
		[0x34] = {name = "Flying Fish", color = red}, -- Red
		[0x35] = {name = "Bushbeast", color = red}, -- Green
		[0x36] = {name = "Bushbeast", color = red}, -- Blue
		[0x37] = {name = "Bushbeast", color = red}, -- Red
		[0x38] = {name = "Rockhead", color = red}, -- Blue
		[0x39] = {name = "Rockhead", color = red}, -- Red
		[0x3A] = {name = "Sandworm", color = red}, -- Green
		[0x3B] = {name = "Sandworm", color = red}, -- Blue
		[0x3C] = {name = "Flying Mirror", color = red}, -- Blue
		[0x3D] = {name = "Dark Soldier", color = red}, -- Blue
		[0x3E] = {name = "Dark Soldier", color = red}, -- Red
		[0x3F] = {name = "Snowball", color = red},
		[0x40] = {name = "Dweepie", color = red},
		[0x41] = {name = "Lava Spawner", color = yellow},
		[0x42] = {name = "Fire Goblin", color = red},
		[0x43] = {name = "Skeleton", color = red}, -- Green
		[0x44] = {name = "Skeleton", color = red}, -- Blue
		[0x45] = {name = "Skeleton", color = red}, -- Red
		[0x46] = {name = "Chest Monster", color = red},
		[0x47] = {name = "Bat", color = red}, -- Green
		[0x48] = {name = "Bat", color = red}, -- Blue
		[0x49] = {name = "Bat", color = red}, -- Red
		[0x4A] = {name = "Googlybear", color = red}, -- Green
		[0x4B] = {name = "Googlybear", color = red}, -- Blue
		[0x4C] = {name = "Googlybear", color = red}, -- Red
		[0x4D] = {name = "Ghost", color = red}, -- Blue, Drains Magic
		[0x4E] = {name = "Ghost", color = red}, -- Red, Drains Magic
		[0x4F] = {name = "Demon", color = red}, -- Green
		[0x50] = {name = "Demon", color = red}, -- Blue
		[0x51] = {name = "Demon", color = red}, -- Red
		[0x52] = {name = "Ghost", color = red}, -- Drains Magic
		[0x53] = {name = "Cancer", color = red}, -- Rusts Armour
		[0x54] = {name = "Eye", color = red}, -- Green
		[0x55] = {name = "Eye", color = red}, -- Blue
		[0x56] = {name = "Eye", color = red}, -- Red
		[0x57] = {name = "Block Monster", color = red}, -- Blue
		[0x58] = {name = "Block Monster", color = red}, -- Red
		[0x59] = {name = "Mage", color = red}, -- Blue
		[0x5A] = {name = "Mage", color = red}, -- Red
		[0x5B] = {name = "Tub", color = red},
		[0x5C] = {name = "Shell Monster", color = red}, -- Blue
		[0x5D] = {name = "Shell Monster", color = red}, -- Gold
		[0x5E] = {name = "Spear Spawner", color = yellow}, -- On walls usually
		[0x5F] = {name = "Chicken Leg", color = red}, -- Blue
		[0x60] = {name = "Chicken Leg", color = red}, -- Red
		[0x61] = {name = "Spikeball", color = red}, -- LR
		[0x62] = {name = "Spikeball", color = red}, -- UD
		[0x63] = {name = "Dragon", color = red}, -- Dungeon 2
		[0x64] = {name = "Dragon", color = red}, -- Dungeon 6
		[0x65] = {name = "Big Skull Boss", color = red}, -- Dungeon ??? -- TODO: Proper Name
		[0x66] = {name = "Magic", color = yellow}, -- Projecitle, Big Skull Boss -- TODO: Proper Name
		[0x67] = {name = "Boss - Fake Fire Thingy", color = red}, -- TODO: Proper Name
		[0x68] = {name = "Boss 1", color = red}, -- Dungeon 1
		--
		[0x6A] = {name = "Boss Cloaky Magey Deathy Guy", color = red}, -- Dungeon ??? -- TODO: Proper Name
		--
		[0x6D] = {name = "Knight", color = red}, -- Dungeon ???
		--
		[0x70] = {name = "Sword", color = yellow}, -- Projectile
		[0x71] = {name = "Beam", color = yellow}, -- Projectile, Blue Eye
		[0x72] = {name = "Fireball", color = yellow}, -- Projecitle, Boss Rush Dragon
		[0x73] = {name = "Fireball", color = yellow}, -- Projecitle, Dungeon 6 Dragon
		[0x74] = {name = "Magic", color = yellow}, -- Projecitle, Boss Cloaky Magey Deathy Guy -- TODO: Proper Name
		--
		[0x77] = {name = "Spear", color = yellow}, -- Projectile
		[0x78] = {name = "Dragon", color = red}, -- Boss Rush Version
		[0x79] = {name = "Dragon", color = red}, -- Boss Rush Version
		[0x7A] = {name = "Knight", color = red}, -- Boss Rush Version
		[0x7B] = {name = "Red Knight", color = red}, -- Boss Rush Version
		[0x7C] = {name = "Boss Cloaky Magey Deathy Guy", color = red}, -- Boss Rush Version -- TODO: Proper Name
	},
	["vulnerable"] = 0x0C, -- Dying = 0x05, Spawning = 0x04, Vulnerable = 0x02,
	["y_position"] = 0x10, -- u16_le
	["x_position"] = 0x12, -- u16_le
	["health"] = 0x18, -- Byte?
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
local startDragPosition = {
	x = 0,
	y = 0,
};
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
	local xPos = math.floor(mainmemory.read_u16_le(object + object_fields.x_position) / 256 / tileWidth);
	local yPos = math.floor(mainmemory.read_u16_le(object + object_fields.y_position) / 256 / tileHeight) - 8;
	return 1 + (yPos * 16 + xPos);
end

function toggle01(value)
	if value ~= 0 then
		return 0;
	else
		return 1;
	end
end

function killAllEnemies()
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType ~= 0 and objectType ~= 2 then
			--print("Killing enemy at "..objectBase);
			mainmemory.writebyte(objectBase + object_fields.health, 0);
			--mainmemory.writebyte(objectBase + object_fields.object_type, 1);
		end
	end
end

local function drawObjects()
	local mouse = input.getmouse();

	local startDrag = false;
	local dragging = false;
	local dragTransform = {0, 0};
	if mouse.Left then
		if not mouseLastFrame.Left then
			startDrag = true;
			startDragPosition = {
				x = mouse.X,
				y = mouse.Y
			};
		end
		dragging = true;
		dragTransform = {mouse.X - startDragPosition.x, mouse.Y - startDragPosition.y};
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
			-- Default hitbox
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
					objectType = objectTypeTable.name.." "..toHexString(objectType);
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
			if mouse.Left and mouse.X >= 0 and mouse.X < 256 and mouse.Y >= 0 and mouse.Y < 192 then
				if not mouseLastFrame.Left then
					local togglePosition = {
						x = math.floor(mouse.X / tileWidth),
						y = math.floor(mouse.Y / tileHeight),
					};
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
		if type(ScriptHawk) == "table" then
			gui.drawImage("beta/cursor.png", mouse.X, mouse.Y - 4);
		else
			gui.drawImage("cursor.png", mouse.X, mouse.Y - 4);
		end
	end

	mouseLastFrame.Left = mouse.Left;
	mouseLastFrame.Middle = mouse.Middle;
	mouseLastFrame.Right = mouse.Right;
end

event.onframestart(drawObjects);