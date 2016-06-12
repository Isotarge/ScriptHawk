-- Configuration
showList = false;
showHitbox = true;
showInactive = false;

local red = 0xFFFF0000;
local yellow = 0xFFFFFF00;
local green = 0xFF00FF00;
local pink = 0xFFFF00FF;

-- Game state
local object_array_base = 0x300;
local object_size = 0x20;
local object_array_capacity = 30;

function isActiveEnemy(objectBase)
	return (mainmemory.readbyte(objectBase + 0x09) == 0) and (mainmemory.readbyte(objectBase + 0x0A) == 0);
end

function isActiveBoss(objectBase)
	return isActiveEnemy(objectBase) and (mainmemory.readbyte(objectBase + 0x1A) > 1);
end

local object_fields = {
	["object_type"] = 0x00, -- Byte
	["object_types"] = {
		[0x01] = {["name"] = "Player", ["color"] = yellow},
		[0x02] = {["name"] = "Bullet", ["hitbox_width"] = 8, ["hitbox_height"] = 8},
		[0x03] = {["name"] = "Explosion", ["color"] = yellow}, -- Vehicle dying
		[0x04] = {["name"] = "Bullet"}, -- Dying
		[0x05] = {["name"] = "miniAlex Turret", ["color"] = yellow}, -- Falling
		[0x06] = {["name"] = "miniAlex Turret", ["color"] = yellow}, -- Active
		[0x07] = {["name"] = "Shield Spawner", ["color"] = yellow},
		[0x08] = {["name"] = "Shield", ["color"] = yellow},
		[0x09] = {["name"] = "miniAlex", ["color"] = yellow},
		[0x0A] = {["name"] = "miniAlex", ["color"] = yellow}, -- Falling
		[0x0B] = {["name"] = "Janken Choice Display", ["hitbox_width"] = 32, ["hitbox_height"] = 32, ["color"] = yellow},
		[0x0C] = {["name"] = "Janken Score Display", ["hitbox_width"] = 24, ["hitbox_height"] = 8, ["color"] = yellow},
		[0x0D] = {["name"] = "Stone Head's Head", ["color"] = red},
		[0x0E] = {["name"] = "Scissors Head's Head", ["color"] = red},
		[0x0F] = {["name"] = "Paper Head's Head", ["color"] = red},
		[0x10] = {["name"] = "Spike", ["color"] = red}, -- Will fall when room loads
		[0x12] = {["name"] = "Falling Block", ["color"] = red}, -- Loading
		[0x13] = {["name"] = "Spike", ["color"] = red}, -- Loading
		[0x14] = {["name"] = "Spike", ["color"] = red}, -- Falling
		[0x15] = {["name"] = "Waterfall", ["color"] = red}, -- Falling
		[0x16] = {["name"] = "Trapdoor", ["color"] = pink, ["active"] = isActiveEnemy}, -- Opens when stepped on
		[0x17] = {["name"] = "Trigger", ["color"] = pink}, -- For falling blocks
		[0x18] = {["name"] = "Title Screen Sprite", ["color"] = yellow},
		[0x19] = {["name"] = "Projectile", ["hitbox_width"] = 8, ["hitbox_height"] = 8, ["color"] = red}, -- Janken Ninja Star
		[0x1B] = {["name"] = "Projectile", ["hitbox_width"] = 8, ["hitbox_height"] = 8}, -- Ring
		[0x1A] = {["name"] = "Projectile", ["hitbox_width"] = 8, ["hitbox_height"] = 8, ["color"] = red}, -- Scissors Head Ninja Star
		[0x1C] = {["name"] = "Janken", ["color"] = pink},
		[0x1D] = {["name"] = "Stone Head", ["color"] = pink, ["active"] = isActiveBoss},
		[0x1E] = {["name"] = "Scissors Head", ["color"] = pink, ["active"] = isActiveBoss},
		[0x1F] = {["name"] = "Paper Head", ["color"] = pink, ["active"] = isActiveBoss},
		[0x20] = {["name"] = "Bat", ["direction"] = "Left", ["hitbox_width"] = 16, ["hitbox_height"] = 8, ["color"] = red, ["active"] = isActiveEnemy},
		[0x22] = {["name"] = "Bubble", ["color"] = red, ["hitbox_width"] = 8, ["hitbox_height"] = 8}, -- Big Frog
		[0x23] = {["name"] = "Big Frog", ["color"] = red, ["active"] = isActiveEnemy},
		[0x24] = {["name"] = "Octopus", ["color"] = red, ["hitbox_width"] = 8, ["hitbox_height"] = 8, ["active"] = isActiveEnemy}, -- Arm segment
		[0x25] = {["name"] = "Blue Bear", ["direction"] = "Left", ["color"] = pink, ["active"] = isActiveEnemy}, -- Walking
		[0x26] = {["name"] = "Blue Bear", ["direction"] = "Right", ["color"] = pink, ["active"] = isActiveEnemy}, -- Walking
		[0x27] = {["name"] = "Blue Bear", ["direction"] = "Left", ["color"] = pink, ["active"] = isActiveEnemy}, -- Attacking
		[0x28] = {["name"] = "Blue Bear", ["direction"] = "Right", ["color"] = pink, ["active"] = isActiveEnemy}, -- Attacking
		[0x29] = {["name"] = "Projectile", ["color"] = red, ["hitbox_width"] = 8, ["hitbox_height"] = 8}, -- Monkey
		[0x2A] = {["name"] = "Monkey", ["color"] = red, ["active"] = isActiveEnemy},
		[0x2B] = {["name"] = "Dying"}, -- Small enemy
		[0x2C] = {["name"] = "Plant", ["color"] = red, ["hitbox_width"] = 16, ["hitbox_height"] = 40, ["active"] = isActiveEnemy}, -- Moves up and down
		[0x2D] = {["name"] = "Bird", ["direction"] = "Left", ["color"] = red, ["hitbox_width"] = 24, ["hitbox_height"] = 16, ["active"] = isActiveEnemy},
		[0x2E] = {["name"] = "Killer Fish", ["directoin"] = "Left", ["color"] = red, ["active"] = isActiveEnemy},
		[0x2F] = {["name"] = "Frog", ["color"] = red, ["active"] = isActiveEnemy}, -- Small, Grounded
		[0x30] = {["name"] = "Fish", ["direction"] = "Left", ["color"] = red, ["active"] = isActiveEnemy}, -- Small Left
		[0x31] = {["name"] = "Seahorse", ["direction"] = "Left", ["color"] = red, ["active"] = isActiveEnemy},
		[0x32] = {["name"] = "Seahorse", ["direction"] = "Right", ["color"] = red, ["active"] = isActiveEnemy},
		[0x34] = {["name"] = "Fish", ["direction"] = "Right", ["color"] = red, ["active"] = isActiveEnemy}, -- Small
		[0x35] = {["name"] = "Killer Fish", ["direction"] = "Right", ["color"] = red, ["active"] = isActiveEnemy},
		[0x36] = {["name"] = "Bat", ["direction"] = "Right", ["hitbox_width"] = 16, ["hitbox_height"] = 8, ["color"] = red, ["active"] = isActiveEnemy},
		[0x33] = {["name"] = "Bird", ["direction"] = "Right", ["color"] = red, ["hitbox_width"] = 24, ["hitbox_height"] = 16, ["active"] = isActiveEnemy},
		[0x37] = {["name"] = "Frog", ["color"] = red}, -- Small, Jumping
		[0x38] = {["name"] = "Box Particle", ["hitbox_width"] = 8, ["hitbox_height"] = 8},
		[0x39] = {["name"] = "Box Particle", ["hitbox_width"] = 8, ["hitbox_height"] = 8},
		[0x3A] = {["name"] = "Box Particle", ["hitbox_width"] = 8, ["hitbox_height"] = 8},
		[0x3B] = {["name"] = "Box Particle", ["hitbox_width"] = 8, ["hitbox_height"] = 8},
		[0x3C] = {["name"] = "Money", ["color"] = green},
		[0x3D] = {["name"] = "Flame", ["color"] = red, ["active"] = isActiveEnemy},
		[0x3E] = {["name"] = "Scorpion", ["direction"] = "Left", ["color"] = red, ["active"] = isActiveEnemy}, -- Also used for flames in later levels
		[0x3F] = {["name"] = "Scorpion", ["direction"] = "Right", ["color"] = red, ["active"] = isActiveEnemy}, -- Also used for flames in later levels
		[0x40] = {["name"] = "Cloud", ["color"] = red, ["active"] = isActiveEnemy},
		[0x41] = {["name"] = "Cloud", ["color"] = red, ["active"] = isActiveEnemy}, -- Shooting Lightning
		[0x42] = {["name"] = "Flying Fish", ["color"] = red, ["active"] = isActiveEnemy},
		[0x43] = {["name"] = "Dying", ["color"] = pink}, -- Boss, turns into Rice Cake
		[0x44] = {["name"] = "Rice Cake", ["color"] = green, ["active"] = isActiveEnemy},
		[0x45] = {["name"] = "Saint Nurari", ["color"] = yellow, ["active"] = isActiveEnemy}, -- Level 4
		[0x46] = {["name"] = "OX", ["direction"] = "Left", ["color"] = pink, ["active"] = isActiveEnemy},
		[0x47] = {["name"] = "OX", ["direction"] = "Left", ["color"] = pink, ["active"] = isActiveEnemy}, -- Hurt
		[0x48] = {["name"] = "OX", ["direction"] = "Right", ["color"] = pink, ["active"] = isActiveEnemy},
		[0x49] = {["name"] = "OX", ["direction"] = "Right", ["color"] = pink, ["active"] = isActiveEnemy}, -- Hurt
		[0x4A] = {["name"] = "Blue Bear", ["color"] = pink, ["active"] = isActiveEnemy}, -- Hurt
		[0x4B] = {["name"] = "Hidden Block", ["color"] = pink, ["active"] = isActiveEnemy},
		[0x4C] = {["name"] = "Warp", ["color"] = pink, ["active"] = isActiveEnemy},
		[0x4D] = {["name"] = "Extra Life", ["color"] = pink},
		[0x4E] = {["name"] = "Ring", ["color"] = pink},
		[0x4F] = {["name"] = "Ghost", ["color"] = red},
		[0x50] = {["name"] = "Saint Nurari", ["color"] = yellow, ["active"] = isActiveEnemy}, -- Level 6
		[0x51] = {["name"] = "Patricia", ["color"] = yellow, ["active"] = isActiveEnemy}, -- Level 16
		[0x52] = {["name"] = "Item", ["color"] = pink, ["active"] = isActiveEnemy}, -- Helecopter, Crown, Blue circle with star
		[0x54] = {["name"] = "Rolling Rock", ["color"] = red, ["active"] = isActiveEnemy},
		[0x55] = {["name"] = "Hopper", ["color"] = red, ["active"] = isActiveEnemy},
		[0x56] = {["name"] = "Arrow", ["hitbox_width"] = 8, ["hitbox_height"] = 8}, -- Map
		[0x57] = {["name"] = "Flame", ["color"] = red, ["active"] = isActiveEnemy}, -- Stationary
		[0x60] = {["name"] = "Crown Door Trigger", ["color"] = yellow, ["active"] = isActiveEnemy},
		[0x61] = {["name"] = "Crown Code Controller", ["color"] = pink},
		[0x63] = {["name"] = "Hidden Block", ["color"] = pink, ["active"] = isActiveEnemy},
	},
	["state"] = 0x01, -- Byte
	["active"] = 0x09, -- u16, 0x0000
	["x_position"] = 0x0C, -- Byte
	["y_position"] = 0x0E, -- Byte
	["x_velocity"] = 0x10, -- S8
	["y_velocity"] = 0x12, -- S8
	["janken_decision"] = 0x17, -- Byte
	["janken_decisions"] = {
		[0] = "Rock",
		[1] = "Scissors",
		[2] = "Paper",
	},
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

local mouseClickedLastFrame = false;
local startDragPosition = {0,0};
local draggedObjects = {};

function draw_ui()
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
			local xPosition = mainmemory.readbyte(objectBase + object_fields.x_position);
			local yPosition = mainmemory.readbyte(objectBase + object_fields.y_position);

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

			if objectType == "Item 0x52" then
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
								mainmemory.writebyte(objectBase + object_fields.x_position, xPosition);
								mainmemory.writebyte(objectBase + object_fields.y_position, yPosition);
								--mainmemory.write_s8(objectBase + object_fields.x_velocity, 0);
								--mainmemory.write_s8(objectBase + object_fields.y_velocity, 0);
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

while true do
	draw_ui();
	emu.yield();
end