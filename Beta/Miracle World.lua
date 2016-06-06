mode = "Hitbox"; -- Standard
show_inactive = true;

local object_array_base = 0x300;
local object_size = 0x20;
local object_array_capacity = 30;

local red = 0xFFFF0000;
local yellow = 0xFFFFFF00;
local green = 0xFF00FF00;
local pink = 0xFFFF00FF;

local object_fields = {
	["object_type"] = 0x00, -- Byte
	["object_types"] = {
		[0x01] = {["name"] = "Player", ["color"] = yellow},
		[0x02] = {["name"] = "Bullet", ["hitbox_x"] = 8, ["hitbox_y"] = 8},
		[0x03] = {["name"] = "Explosion", ["color"] = yellow}, -- Vehicle dying
		[0x04] = {["name"] = "Bullet"}, -- Dying
		[0x0B] = {["name"] = "Janken Choice Display", ["hitbox_x"] = 32, ["hitbox_y"] = 32, ["color"] = pink}, -- Player
		[0x0C] = {["name"] = "Janken Score Display"},
		[0x0D] = {["name"] = "Stone Head's Head", ["color"] = red},
		[0x0E] = {["name"] = "Scissors Head's Head", ["color"] = red},
		[0x0F] = {["name"] = "Paper Head's Head", ["color"] = red},
		[0x10] = {["name"] = "Spike", ["color"] = red}, -- Will fall when room loads
		[0x12] = {["name"] = "Falling Block", ["color"] = red}, -- Loading
		[0x13] = {["name"] = "Spike", ["color"] = red}, -- Loading
		[0x14] = {["name"] = "Spike", ["color"] = red}, -- Falling
		[0x15] = {["name"] = "Waterfall", ["color"] = red}, -- Falling
		[0x16] = {["name"] = "Trapdoor", ["color"] = pink}, -- Opens when stepped on
		[0x17] = {["name"] = "Trigger", ["color"] = pink}, -- For falling blocks
		--[0x18] = {["name"] = "Unknown 0x18"}, -- Title Screen
		[0x19] = {["name"] = "Projectile", ["color"] = red}, -- Janken Ninja Star
		[0x1B] = {["name"] = "Projectile", ["hitbox_x"] = 8, ["hitbox_y"] = 8}, -- Ring
		[0x1A] = {["name"] = "Projectile", ["color"] = red}, -- Scissors Head Ninja Star
		[0x1C] = {["name"] = "Janken", ["color"] = pink},
		[0x1D] = {["name"] = "Stone Head", ["color"] = pink},
		[0x1E] = {["name"] = "Scissors Head", ["color"] = pink},
		[0x1F] = {["name"] = "Paper Head", ["color"] = pink},
		[0x20] = {["name"] = "Bat", ["direction"] = "Left", ["color"] = red}, -- Left
		[0x22] = {["name"] = "Bubble", ["color"] = red, ["hitbox_x"] = 8, ["hitbox_y"] = 8}, -- Big Frog
		[0x23] = {["name"] = "Big Frog", ["color"] = red},
		[0x24] = {["name"] = "Octopus", ["color"] = red, ["hitbox_x"] = 8, ["hitbox_y"] = 8}, -- Arm segment
		[0x27] = {["name"] = "Blue Bear", ["color"] = pink},
		[0x29] = {["name"] = "Projectile", ["color"] = red}, -- Monkey's projectile
		[0x2A] = {["name"] = "Monkey", ["color"] = red},
		[0x2B] = {["name"] = "Dying"}, -- Small enemy
		[0x2C] = {["name"] = "Plant", ["color"] = red}, -- Moves up and down
		[0x2D] = {["name"] = "Bird", ["direction"] = "Left", ["color"] = red, ["hitbox_x"] = 24, ["hitbox_y"] = 16},
		[0x2E] = {["name"] = "Fish", ["directoin"] = "Left", ["color"] = red}, -- Big
		[0x2F] = {["name"] = "Frog", ["color"] = red}, -- Small, Grounded
		[0x30] = {["name"] = "Fish", ["direction"] = "Left", ["color"] = red}, -- Small Left
		[0x31] = {["name"] = "Seahorse", ["direction"] = "Left", ["color"] = red},
		[0x32] = {["name"] = "Seahorse", ["direction"] = "Right", ["color"] = red},
		[0x34] = {["name"] = "Fish", ["direction"] = "Right", ["color"] = red}, -- Small
		[0x35] = {["name"] = "Fish", ["direction"] = "Right", ["color"] = red}, -- Big
		[0x36] = {["name"] = "Bat", ["direction"] = "Right", ["color"] = red},
		[0x33] = {["name"] = "Bird", ["direction"] = "Right", ["color"] = red, ["hitbox_x"] = 24, ["hitbox_y"] = 16},
		[0x37] = {["name"] = "Frog", ["color"] = red}, -- Small, Jumping
		[0x38] = {["name"] = "Box Particle", ["hitbox_x"] = 8, ["hitbox_y"] = 8},
		[0x39] = {["name"] = "Box Particle", ["hitbox_x"] = 8, ["hitbox_y"] = 8},
		[0x3A] = {["name"] = "Box Particle", ["hitbox_x"] = 8, ["hitbox_y"] = 8},
		[0x3B] = {["name"] = "Box Particle", ["hitbox_x"] = 8, ["hitbox_y"] = 8},
		[0x3C] = {["name"] = "Money", ["color"] = green},
		[0x3D] = {["name"] = "Flame", ["color"] = red},
		[0x3E] = {["name"] = "Scorpion", ["direction"] = "Left", ["color"] = red}, -- Also used for flames in later levels
		[0x3F] = {["name"] = "Scorpion", ["direction"] = "Right", ["color"] = red}, -- Also used for flames in later levels
		[0x40] = {["name"] = "Cloud", ["color"] = red},
		[0x41] = {["name"] = "Cloud", ["color"] = red}, -- Shooting Lightning
		[0x42] = {["name"] = "Flying Fish", ["color"] = red},
		[0x43] = {["name"] = "Dying", ["color"] = pink}, -- Boss, turns into Rice Cake
		[0x44] = {["name"] = "Rice Cake", ["color"] = green},
		[0x45] = {["name"] = "Saint Nurari", ["color"] = yellow}, -- Level 4
		[0x46] = {["name"] = "OX", ["direction"] = "Left", ["color"] = pink},
		[0x47] = {["name"] = "OX", ["direction"] = "Left", ["color"] = pink}, -- Hurt
		[0x48] = {["name"] = "OX", ["direction"] = "Right", ["color"] = pink},
		[0x49] = {["name"] = "OX", ["direction"] = "Right", ["color"] = pink}, -- Hurt
		[0x4B] = {["name"] = "Hidden Block", ["color"] = pink},
		[0x4D] = {["name"] = "Extra Life", ["color"] = pink},
		[0x4E] = {["name"] = "Ring", ["color"] = pink},
		[0x4F] = {["name"] = "Ghost", ["color"] = red},
		[0x50] = {["name"] = "Saint Nurari", ["color"] = yellow}, -- Level 6
		[0x51] = {["name"] = "Patricia", ["color"] = yelow}, -- Level 16
		[0x52] = {["name"] = "Item", ["color"] = pink}, -- Helecopter, Crown, Blue circle with star
		[0x54] = {["name"] = "Rolling Rock", ["color"] = red},
		[0x55] = {["name"] = "Hopper", ["color"] = red},
		[0x56] = {["name"] = "Arrow", ["hitbox_x"] = 8, ["hitbox_y"] = 8}, -- Map
		[0x57] = {["name"] = "Flame", ["color"] = red}, -- Stationary
		[0x61] = {["name"] = "Crown Code Controller", ["color"] = pink},
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

function draw_ui()
	local gui_x = 2;
	local gui_y = 2;
	local row = 0;
	local height = 16;
	local mouse = input.getmouse();
	if mode == "Hitbox" then
		gui.clearGraphics();
	end

	-- Draw mouse pixel
	--gui.drawPixel(mouse.X, mouse.Y, red);

	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		local objectActive = mainmemory.read_u16_be(objectBase + object_fields.active);
		local objectTypeTable = nil;
		local color = nil;
		if objectType ~= 0 then
			-- Default to 16 width/height for hitbox
			local hitboxX = 16;
			local hitboxY = 16;

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

				if type(objectTypeTable.hitbox_x) == "number" then
					hitboxX = objectTypeTable.hitbox_x;
				end
				if type(objectTypeTable.hitbox_y) == "number" then
					hitboxY = objectTypeTable.hitbox_y;
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

			if mode == "Standard" then
				gui.text(gui_x, gui_y + height * row, xPosition..", "..yPosition.." - "..objectType.." "..toHexString(objectBase), color, nil, 'bottomright');
				row = row + 1;
			end

			if mode == "Hitbox" then
				if showInactive or objectActive == 0x00 then
					if (mouse.X >= xPosition and mouse.X <= xPosition + hitboxX) and (mouse.Y >= yPosition and mouse.Y <= yPosition + hitboxY) then
						gui.drawText(xPosition, yPosition, objectType, color);
						gui.drawText(xPosition, yPosition + height, toHexString(objectBase).." "..xPosition..","..yPosition, color);
					end
					gui.drawRectangle(xPosition, yPosition, hitboxX, hitboxY, color); -- Draw the object's hitbox
				end
			end
		end
	end
end

while true do
	draw_ui();
	emu.yield();
end