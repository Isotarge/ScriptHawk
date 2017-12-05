if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		object_array_base = 0xE80,
		player_x = 0xEB2, -- s16_le
		player_y = 0xEAF, -- s16_le
		level_x = 0xD72, -- u16_le
		level_y = 0xD2B, -- u16_le
		hits = 0xDC4, -- u16_le
		shots = 0xDC6, -- u16_le
	},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

local object_size = 0x21;
local object_array_capacity = 27;

local max_player_projectiles = 3;
local max_enemies = 7;

local object_fields = {
	object_type = 0x00, -- Byte
	object_types = {
		[0x01] = {name = "Player", color = colors.yellow},
		[0x02] = {name = "Player Projectile", color = colors.yellow, hitbox_height = 8, hitbox_width = 8},
		[0x03] = {name = "Player Projectile", color = colors.yellow, hitbox_height = 8, hitbox_width = 8},
		[0x04] = {name = "Boss", color = colors.pink}, -- Early levels
		[0x05] = {name = "Boss", color = colors.pink}, -- Later levels
		[0x06] = {name = "Boss Projectile", color = colors.red},
		[0x07] = {name = "Boss Projectile", color = colors.red}, -- Level 5
		[0x08] = {name = "Boss Projectile", color = colors.red},
		[0x09] = {name = "Enemy Projectile", color = colors.red, hitbox_height = 8, hitbox_width = 8}, -- Small projectile
		[0x0A] = {name = "Boss Projectile", color = colors.red, hitbox_height = 8, hitbox_width = 8},
		[0x0B] = {name = "Red Scroll", color = colors.pink},
		[0x0C] = {name = "Blue Scroll", color = colors.pink},
		[0x0D] = {name = "Green Scroll", color = colors.pink},
		[0x0E] = {name = "Splash"},
		[0x0F] = {name = "Enemy Dying", isEnemy = true},
		[0x10] = {name = "Grey Enemy", isEnemy = true},
		[0x11] = {name = "Blue Enemy", isEnemy = true},
		[0x12] = {name = "Grey Enemy", isEnemy = true},
		[0x13] = {name = "Grey Enemy", isEnemy = true},
		[0x14] = {name = "Grey Enemy", isEnemy = true}, -- Level 6
		[0x15] = {name = "Grey Enemy", isEnemy = true},
		[0x16] = {name = "Grey Enemy", isEnemy = true}, -- Scythe
		[0x17] = {name = "Boulder Enemy", isEnemy = true},
		[0x18] = {name = "Popup Enemy", isEnemy = true}, -- Level 2
		[0x19] = {name = "Bouncing Boulder", color = colors.red}, -- Level 2
		[0x1A] = {name = "Bouncing Boulder Shadow"}, -- Level 2
		[0x1B] = {name = "Horse", color = colors.red}, -- Level 7
		[0x1C] = {name = "Wolf", isEnemy = true},
		[0x1D] = {name = "Light Blue Enemy", isEnemy = true}, -- Level 11
		[0x1E] = {name = "Green Enemy", isEnemy = true}, -- Level 8
		[0x1F] = {name = "Enemy Projectile", color = colors.red}, -- Scythe
		[0x20] = {name = "Grey Enemy", isEnemy = true}, -- From boulder, can contain green scroll
		[0x21] = {name = "Boulder Enemy", isEnemy = true},
		[0x22] = {name = "Grey Enemy", isEnemy = true}, -- Circling
		[0x23] = {name = "Fire Enemy", isEnemy = true}, -- Level 7
		[0x24] = {name = "Red Jumping Enemy", isEnemy = true}, -- Level 4
		[0x25] = {name = "Red Enemy", isEnemy = true}, -- Level 4
		[0x26] = {name = "Red Enemy", isEnemy = true}, -- Level 4, after jumping
		[0x27] = {name = "Grey Enemy", isEnemy = true}, -- Cliff
		[0x28] = {name = "Blue Enemy", isEnemy = true}, -- Cliff
		[0x29] = {name = "Grey Enemy", isEnemy = true}, -- Cliff, moving up
		[0x2A] = {name = "Ball Spawner"}, -- Cliff -- TODO: Does this count as an enemy?
		[0x2B] = {name = "Ball", color = colors.red, hitbox_height = 8, hitbox_width = 8}, -- Cliff
		[0x2C] = {name = "Green Scroll Trigger", color = colors.pink},
		[0x2D] = {name = "Boulder Enemy", color = colors.pink}, -- Contains green scroll, does not count towards enemy cap
		[0x2E] = {name = "Arrow", color = colors.pink}, -- Map Screen
		[0x2F] = {name = "Red Scroll", color = colors.pink}, -- Map Screen
		[0x30] = {name = "Blue Scroll", color = colors.pink}, -- Map Screen
		[0x31] = {name = "Green Scrolls", color = colors.pink}, -- Map Screen
		[0x32] = {name = "Staircase Trigger", color = colors.pink}, -- Level 10
		[0x33] = {name = "Player", color = colors.pink}, -- End screen
		[0x34] = {name = "Princess", color = colors.pink}, -- End screen
		[0x35] = {name = "Boulder Enemy", isEnemy = true},
		[0x36] = {name = "Blue Enemy", isEnemy = true, color = colors.pink}, -- Contains red scroll
		[0x37] = {name = "Blue Enemy", isEnemy = true, color = colors.pink}, -- Contains blue scroll
		[0x38] = {name = "Wolf", isEnemy = true, color = colors.pink}, -- Contains red scroll
		[0x39] = {name = "Grey Enemy", isEnemy = true, color = colors.pink}, -- Contains blue scroll
		[0x3A] = {name = "Red Enemy", isEnemy = true, color = colors.pink}, -- Level 6, Contains red scroll
		[0x3B] = {name = "Grey Enemy", isEnemy = true}, -- Circles, Contains red scroll

		[0x3D] = {name = "Grey Enemy", isEnemy = true}, -- Level 10, Contains red scroll
		[0x3E] = {name = "Light Blue Enemy", isEnemy = true, color = colors.pink}, -- Level 11, Contains red scroll
		[0x3F] = {name = "Light Blue Enemy", isEnemy = true, color = colors.pink}, -- Level 11, Contains blue scroll
		[0x40] = {name = "Grey Enemy", isEnemy = true}, -- Level 5
		[0x41] = {name = "Grey Enemy", isEnemy = true, color = colors.pink}, -- Level 5, Contains red scroll
		[0x42] = {name = "Fire Enemy", isEnemy = true, color = colors.pink}, -- Level 7, Contains red scroll
		[0x43] = {name = "Grey Enemy", isEnemy = true, color = colors.pink}, -- Cliff, Contains red scroll
		[0x44] = {name = "Fire Enemy", isEnemy = true, color = colors.pink}, -- Contains blue scroll
		[0x45] = {name = "Easter Egg Trigger", color = colors.yellow}, -- Only in Japanese version
	},
	animation_index = 0x03, -- Byte
	animation_current_frame = 0x04, -- Byte
	animation_length = 0x05, -- Byte
	segment_current_frame = 0x06, -- Byte
	segment_length_frames = 0x07,
	x_position = 0x11, -- s16_le
	y_position = 0x0E, -- s16_le
	boss_health = 0x1E, -- byte
};

function Game.countPlayerProjectiles()
	local num = 0;
	for i = 0, object_array_capacity do
		local objectBase = Game.Memory.object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType == 0x02 or objectType == 0x03 then
			num = num + 1;
		end
	end
	return num.."/"..max_player_projectiles;
end

function Game.countEnemies()
	local num = 0;
	for i = 0, object_array_capacity do
		local objectBase = Game.Memory.object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if object_fields.object_types[objectType] ~= nil then
			if object_fields.object_types[objectType].isEnemy == true then
				num = num + 1;
			end
		end
	end
	return num.."/"..max_enemies;
end

function Game.countObjects()
	local num = 0;
	for i = 0, object_array_capacity do
		local objectBase = Game.Memory.object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType ~= 0x00 then
			num = num + 1;
		end
	end
	return num.."/"..object_array_capacity;
end

function Game.getPlayerXPosition()
	return mainmemory.read_s16_le(Game.Memory.player_x);
end

function Game.getPlayerYPosition()
	return mainmemory.read_s16_le(Game.Memory.player_y);
end

function Game.getLevelXPosition()
	return mainmemory.read_u16_le(Game.Memory.level_x);
end

function Game.getLevelYPosition()
	return mainmemory.read_u16_le(Game.Memory.level_y);
end

function Game.getXPosition()
	return Game.getPlayerXPosition() + Game.getLevelXPosition();
end

function Game.getYPosition()
	return -Game.getPlayerYPosition() + Game.getLevelYPosition();
end

function Game.getHits()
	return mainmemory.read_u16_le(Game.Memory.hits);
end

function Game.getShots()
	return mainmemory.read_u16_le(Game.Memory.shots);
end

function Game.getOptimalShots()
	return Game.getHits() * 100 / 2 + 1;
end

function Game.getHitsOSD()
	return Game.getHits().."/"..Game.getShots().." ("..Game.getOptimalShots()..")";
end

function Game.getHitRatio()
	local hits = Game.getHits();
	local shots = Game.getShots();
	if hits >= shots or (hits == 0 and shots == 0) then
		return "100%";
	end
	return round(hits / shots * 100, 2).."%";
end

function Game.isBossLoaded()
	for i = 0, object_array_capacity do
		local objectBase = Game.Memory.object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType == 0x04 or objectType == 0x05 then
			return true;
		end
	end
	return false;
end

function Game.getBossHealth()
	for i = 0, object_array_capacity do
		local objectBase = Game.Memory.object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType == 0x04 or objectType == 0x05 then
			return mainmemory.readbyte(objectBase + object_fields.boss_health);
		end
	end
	return 0;
end

function Game.getDColor()
	if math.abs(ScriptHawk.getDX()) > 0 or math.abs(ScriptHawk.getDY()) > 0 then
		return colors.white;
	end
	return colors.red;
end

Game.standardOSD = {
	{"X", Game.getPlayerXPosition},
	{"Y", Game.getPlayerYPosition},
	{"Level X", Game.getLevelXPosition},
	{"Level Y", Game.getLevelYPosition},
	{"dX", ScriptHawk.getDX, Game.getDColor},
	{"dY", ScriptHawk.getDY, Game.getDColor},
	{"Separator", 1},
	{"Player Proj", Game.countPlayerProjectiles},
	{"Hits", Game.getHitsOSD},
	{"Ratio", Game.getHitRatio},
	{"Separator", 1},
	{"Objects", Game.countObjects},
	{"Enemies", Game.countEnemies},
};

Game.bossOSD = {
	{"X", Game.getPlayerXPosition},
	{"Y", Game.getPlayerYPosition},
	{"Level X", Game.getLevelXPosition},
	{"Level Y", Game.getLevelYPosition},
	{"dX", ScriptHawk.getDX, Game.getDColor},
	{"dY", ScriptHawk.getDY, Game.getDColor},
	{"Separator", 1},
	{"Player Proj", Game.countPlayerProjectiles},
	{"Hits", Game.getHitsOSD},
	{"Ratio", Game.getHitRatio},
	{"Separator", 1},
	{"Objects", Game.countObjects},
	{"Enemies", Game.countEnemies},
	{"Separator", 1},
	{"Boss Health", Game.getBossHealth},
};

Game.OSD = Game.standardOSD;

function Game.initUI()
	ScriptHawk.UI.form_controls["showList"] = forms.checkbox(ScriptHawk.UI.options_form, "Show List", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(4) + ScriptHawk.UI.dropdown_offset);
	ScriptHawk.UI.form_controls["showHitbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Show Hitbox", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(5) + ScriptHawk.UI.dropdown_offset);
	forms.setproperty(ScriptHawk.UI.form_controls.showHitbox, "Checked", true);
	ScriptHawk.UI.form_controls["draggableHitboxes"] = forms.checkbox(ScriptHawk.UI.options_form, "Draggable", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);
end

local mouseClickedLastFrame = false;
local startDragPosition = {0, 0};
local draggedObjects = {};

function Game.drawUI()
	if Game.isBossLoaded() then
		Game.OSD = Game.bossOSD;
	else
		Game.OSD = Game.standardOSD;
	end

	-- Draw Objects
	local height = 16; -- Text row height
	local width = 8; -- Text column width
	local mouse = input.getmouse();

	-- Draw mouse pixel
	--gui.drawPixel(mouse.X, mouse.Y, colors.red);

	local startDrag = false;
	local dragging = false;
	local dragTransform = {0, 0};

	if forms.ischecked(ScriptHawk.UI.form_controls.draggableHitboxes) then
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
	end

	local row = 0;
	for i = 0, object_array_capacity do
		local objectBase = Game.Memory.object_array_base + (i * object_size);
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

				if type(objectTypeTablecolor) == "number" then
					color = objectTypeTablecolor;
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
				color = colors.black;
				objectType = "Unknown ("..toHexString(objectType)..")";
			end

			local hitboxXOffset = -(hitboxWidth / 2);
			local hitboxYOffset = -(hitboxHeight / 2);
			if client.bufferheight() == 243 then -- Compensate for overscan
				hitboxXOffset = hitboxXOffset + 13;
				hitboxYOffset = hitboxYOffset + 27;
			end

			if forms.ischecked(ScriptHawk.UI.form_controls.showHitbox) then
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
					local safeX = math.max(0, math.min(xPosition + hitboxXOffset, 256 - (maxLength * width)));
					local safeY = math.max(0, math.min(yPosition + hitboxYOffset, 192 - (#mouseOverText * height)));

					for t = 1, #mouseOverText do
						gui.drawText(safeX, safeY + ((t - 1) * height), mouseOverText[t], color);
					end
				end
				gui.drawRectangle(xPosition + hitboxXOffset, yPosition + hitboxYOffset, hitboxWidth, hitboxHeight, color); -- Draw the object's hitbox
			end

			if forms.ischecked(ScriptHawk.UI.form_controls.showList) then
				gui.text(2, 2 + height * row, xPosition..", "..yPosition.." - "..objectType.." "..toHexString(objectBase), color, 'bottomright');
				row = row + 1;
			end
		end
	end
end

return Game;