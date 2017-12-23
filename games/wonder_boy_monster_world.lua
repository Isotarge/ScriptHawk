if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		hp_timer = 0xC4,
		heart_containers = 0x58B,
		health = 0x58D,
		map = 0x600,
		map_x = 0x610,
		map_y = 0x612,
		gold = 0x67D, -- u16_le
	},
	maps = {
		"00 Starting Area",
		"01 Unknown",
		"02 Unknown",
		"03 Unknown",
		"04 Unknown",
		"05 Unknown",
		"06 Unknown",
		"07 Unknown",
		"08 Unknown",
		"09 Unknown",
		"0A Unknown",
		"0B Unknown",
		"0C Unknown",
		"0D Village Alsedo", -- The Fairy Village
		"0E Unknown",
		"0F Unknown",
		"10 Unknown",
		"11 Unknown",
		"12 Unknown",
		"13 Unknown",
		"14 Unknown",
		"15 Unknown",
		"16 Unknown",
		"17 Unknown",
		"18 Unknown",
		"19 Unknown",
		"1A Unknown",
		"1B Unknown",
		"1C Unknown",
		"1D Unknown",
		"1E Unknown",
		"1F Unknown",
		"20 Unknown",
		"21 Unknown",
		"22 Unknown",
		"23 Unknown",
		"24 Unknown",
		"25 Unknown",
		"26 Unknown",
		"27 Unknown",
		"28 Unknown",
		"29 Unknown",
		"2A Unknown",
		"2B Unknown",
		"2C Unknown",
		"2D Unknown",
		"2E Unknown",
		"2F Unknown",
		"30 Unknown",
		"31 Unknown",
		"32 Unknown",
		"33 Unknown",
		"34 Unknown",
		"35 Unknown",
		"36 Unknown",
		"37 Unknown",
		"38 Unknown",
		"39 Unknown",
		"3A Unknown",
		"3B Unknown",
		"3C Unknown",
		"3D Unknown",
		"3E Elder Dragon",
		"3F Blacksmith",
		"40 Pyramid",
		"41 Pyramid",
		"42 Pyramid",
		"43 Pyramid",
		"44 Neptune",
	},
};

local object_size = 0x20;
local object_array_base = 0x300;
local object_array_capacity = 23;
local object_fields = {
	object_type = 0x00,
	x_position = 0x06, -- 2 bytes
	x_sub_position = 0x09, -- 1 byte
	y_position = 0x04, -- 2 bytes
	y_sub_position = 0x08, -- 1 byte
	y_velocity = 0x0A, -- 2 byte s8.8
	x_velocity = 0x0D, -- 2 byte s8.8
	currentHP = 0x1B,
	object_types = {
		--[0x00] = "Null",
		[0x01] = {name="Player"},
		[0x03] = {name="Player"}, -- Crouching
		[0x05] = {name="Player"}, -- Sword Left
		[0x06] = {name="Player"}, -- Sword Left (Crouching)
		[0x07] = {name="Snake"}, -- Blue
		[0x08] = {name="Player"}, -- Damaged
		[0x09] = {name="Coin"},
		[0x0A] = {name="Snake"}, -- Green
		[0x0B] = {name="Spawning Object"},
		[0x0D] = {name="Platform"},
		[0x12] = {name="Little Blue Beach Enemy Guy"},
		[0x13] = {name="Crab"},
		[0x14] = {name="Mushroom"},
		[0x15] = {name="Bat"},
		[0x1A] = {name="NPC"},
		[0x1D] = {name="Treasure Chest"},
		[0x1E] = {name="Treasure Chest Reward"}, -- Heart?
		[0x21] = {name="Player"}, -- Swimming
		[0x22] = {name="Door"},
		[0x28] = {name="Player"}, -- Swimming, Attacking
		[0x33] = {name="Mushroom Spirit"},
		[0x38] = {name="Bat"},
		[0x3E] = {name="Player"}, -- Dying
		[0x41] = {name="Item"}, -- Shop?
		[0x42] = {name="Shopkeeper"}, -- NPC
		[0x43] = {name="Sonia"},
		[0x4A] = {name="Mushroom"}, -- Big
	},
};

function Game.getMap()
	local map = mainmemory.readbyte(Game.Memory.map);
	if type(Game.maps[map + 1]) == "string" then
		return Game.maps[map + 1];
	end
	return "Unknown "..toHexString(map);
end

function Game.setMap(value)
	if mainmemory.readbyte(0xC6) == 0 then
		mainmemory.writebyte(Game.Memory.map, value - 1);
	end
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.read_u16_8(base)
	local major = mainmemory.read_u16_le(base + 1);
	local sub = mainmemory.readbyte(base) / 256;
	return major + sub;
end

function Game.read_s16_8(base)
	local major = mainmemory.read_s16_le(base + 1);
	local sub = mainmemory.readbyte(base) / 256;
	return major + sub;
end

function Game.getHealth()
	return mainmemory.readbyte(Game.Memory.health);
end

function Game.getMaxHealth()
	return mainmemory.readbyte(Game.Memory.heart_containers) * 4;
end

function Game.getHPTimer()
	return mainmemory.readbyte(Game.Memory.hp_timer);
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.health, Game.getMaxHealth());
	mainmemory.write_u16_le(Game.Memory.gold, 9999);
end

function Game.getMapX()
	return mainmemory.read_s16_be(Game.Memory.map_x);
end

function Game.getMapY()
	return mainmemory.read_s16_be(Game.Memory.map_y);
end

function Game.getXPosition()
	local major = mainmemory.read_s16_le(object_array_base + object_fields.x_position);
	local minor = mainmemory.readbyte(object_array_base + object_fields.x_sub_position) / 256;
	return major + minor;
end

function Game.getYPosition()
	local major = mainmemory.read_s16_le(object_array_base + object_fields.y_position);
	local minor = mainmemory.readbyte(object_array_base + object_fields.y_sub_position) / 256;
	return major + minor;
end

function Game.getXVelocity()
	return mainmemory.read_s16_le(object_array_base + object_fields.x_velocity) / 256;
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(object_array_base + object_fields.y_velocity) / 256;
end

local draggedObjects = {};
function Game.drawUI()
	local row = 0;
	local height = 16;

	local drawHitboxes = forms.ischecked(ScriptHawk.UI.form_controls["Object Hitboxes Checkbox"]);
	local drawList = forms.ischecked(ScriptHawk.UI.form_controls["Object List Checkbox"]);
	local draggableHitboxes = forms.ischecked(ScriptHawk.UI.form_controls["Draggable Hitboxes Checkbox"]);

	if drawHitboxes or drawList then
		-- Draw Objects
		local height = 16; -- Text row height
		local width = 8; -- Text column width
		local mouse = input.getmouse();

		-- Draw mouse pixel
		--gui.drawPixel(mouse.X, mouse.Y, colors.red);

		local startDrag = false;
		local dragging = false;
		local dragTransform = {0, 0};

		if draggableHitboxes then
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
		local mapX = Game.getMapX();
		local mapY = Game.getMapY();
		for i = 0, object_array_capacity do
			local objectBase = object_array_base + (i * object_size);
			local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
			local objectTypeTable = nil;
			local color = nil;
			if objectType > 0 then
				-- Default to 16 width/height for hitbox
				local hitboxWidth = 16;
				local hitboxHeight = 16;

				-- Get the X and Y position of the object
				local xPosition = mainmemory.read_s16_le(objectBase + object_fields.x_position) - mapX;
				local yPosition = mainmemory.read_s16_le(objectBase + object_fields.y_position) - mapY;
				local currentHP = mainmemory.readbyte(objectBase + object_fields.currentHP);

				if type(object_fields.object_types[objectType]) == "table" then
					objectTypeTable = object_fields.object_types[objectType];

					if type(objectTypeTable.name) == "string" then
						objectType = object_fields.object_types[objectType].name;
					else
						objectType = "Unknown "..toHexString(objectType);
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
					color = colors.red;
					objectType = "Unknown "..toHexString(objectType);
				end

				local hitboxXOffset = 0;
				local hitboxYOffset = -105;
				if client.bufferheight() == 243 then -- Compensate for overscan
					hitboxXOffset = hitboxXOffset + 13;
					hitboxYOffset = hitboxYOffset + 27;
				end

				if drawHitboxes then
					if dragging then
						for d = 1, #draggedObjects do
							if draggedObjects[d][1] == objectBase then
								xPosition = draggedObjects[d][2] + dragTransform[1];
								yPosition = draggedObjects[d][3] + dragTransform[2];
								mainmemory.write_s16_le(objectBase + object_fields.x_position, mapX + xPosition);
								mainmemory.write_s16_le(objectBase + object_fields.y_position, mapY + yPosition);
								break;
							end
						end
					end

					if drawHitboxes then
						if (mouse.X >= xPosition + hitboxXOffset and mouse.X <= xPosition + hitboxXOffset + hitboxWidth) and (mouse.Y >= yPosition + hitboxYOffset and mouse.Y <= yPosition + hitboxYOffset + hitboxHeight) then
							if startDrag then
								table.insert(draggedObjects, {objectBase, xPosition, yPosition});
							end

							local mouseOverText = {
								objectType,
								toHexString(objectBase).." "..xPosition..","..yPosition,
								currentHP.."HP",
							};

							for t = 1, #mouseOverText do
								gui.drawText(xPosition + hitboxXOffset, yPosition + hitboxYOffset + ((t - 1) * height), mouseOverText[t], color);
							end
						else
							if currentHP > 0 then
								gui.drawText(xPosition + hitboxXOffset, yPosition + hitboxYOffset, currentHP, color);
							end
						end
						gui.drawRectangle(xPosition + hitboxXOffset, yPosition + hitboxYOffset, hitboxWidth, hitboxHeight, color); -- Draw the object's hitbox
					end
				end

				if drawList then
					gui.text(2, 2 + height * row, xPosition..", "..yPosition.." - "..objectType.." "..currentHP.."HP "..toHexString(objectBase), color, 'bottomright');
					row = row + 1;
				end
			end
		end
	end
end

function Game.initUI()
	ScriptHawk.UI.form_controls["Object List Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Object List", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);
	ScriptHawk.UI.form_controls["Object Hitboxes Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Hitboxes (Beta)", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset);
	ScriptHawk.UI.form_controls["Draggable Hitboxes Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Draggable", ScriptHawk.UI.col(5) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset);
	forms.setproperty(ScriptHawk.UI.form_controls["Object List Checkbox"], "Checked", true);
	forms.setproperty(ScriptHawk.UI.form_controls["Object Hitboxes Checkbox"], "Checked", true);
	--forms.setproperty(ScriptHawk.UI.form_controls["Draggable Hitboxes Checkbox"], "Checked", true);
end

Game.OSDPosition = {2, 70};
Game.OSD = {
	{"Map", Game.getMap},
	{"Map X", Game.getMapX},
	{"Map Y", Game.getMapY},
	{"Separator", 1},
	{"Health", function() return Game.getHealth().."/"..Game.getMaxHealth(); end},
	{"HP Timer", Game.getHPTimer},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"dX"},
	{"dY"},
};

return Game;