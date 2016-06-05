local object_array_base = 0x300;
local object_size = 0x20;
local object_array_capacity = 30;

local object_fields = {
	["object_type"] = 0x00, -- Byte
	["object_types"] = {
		[0x01] = "Player",
		[0x02] = "Bullet",
		[0x03] = "Explosion", -- Vehicle dying
		[0x04] = "Bullet", -- Dying
		[0x0B] = "Janken Choice Display", -- Player
		[0x0C] = "Janken Score Display",
		[0x0D] = "Stone Head's Head",
		[0x0E] = "Scissors Head's Head",
		[0x0F] = "Paper Head's Head",
		[0x10] = "Spike", -- Will fall when room loads
		[0x12] = "Falling Block", -- Loading
		[0x13] = "Spike", -- Loading
		[0x14] = "Spike", -- Falling
		[0x15] = "Waterfall", -- Falling
		[0x16] = "Trapdoor", -- Opens when stepped on
		[0x17] = "Trigger", -- For falling blocks
		--[0x18] = "Unknown 0x18", -- Title Screen
		[0x19] = "Projectile", -- Janken Ninja Star
		[0x1B] = "Projectile", -- Ring
		[0x1A] = "Projectile", -- Scissors Head Ninja Star
		[0x1C] = "Janken",
		[0x1D] = "Stone Head",
		[0x1E] = "Scissors Head",
		[0x1F] = "Paper Head",
		[0x20] = "Bat", -- Left
		[0x22] = "Bubble", -- Big Frog
		[0x23] = "Big Frog",
		[0x24] = "Octopus", -- Arm segment
		[0x2B] = "Dying", -- Small enemy
		[0x2C] = "Plant Enemy", -- Moves up and down
		[0x2D] = "Bird", -- Left
		[0x2E] = "Fish", -- Big Left
		[0x2F] = "Frog", -- Small, Grounded
		[0x30] = "Fish", -- Small Left
		[0x31] = "Seahorse", -- Left
		[0x32] = "Seahorse", -- Right
		[0x34] = "Fish", -- Small Right
		[0x35] = "Fish", -- Big Right
		[0x36] = "Bat", -- Right
		[0x33] = "Bird", -- Right
		[0x37] = "Frog", -- Small, Jumping
		[0x38] = "Box Particle",
		[0x39] = "Box Particle",
		[0x3A] = "Box Particle",
		[0x3B] = "Box Particle",
		[0x3C] = "Money",
		[0x3D] = "Flame",
		[0x3E] = "Scorpion", -- Left
		[0x3F] = "Scorpion", -- Right
		[0x40] = "Cloud",
		[0x41] = "Cloud", -- Shooting Lightning
		[0x42] = "Fish", -- Jumping Piranha
		[0x43] = "Dying", -- Boss, turns into Rice Cake
		[0x44] = "Rice Cake",
		[0x45] = "Saint Nurari", -- Level 4
		[0x46] = "OX", -- Left
		[0x47] = "OX", -- Left, Hurt
		[0x48] = "OX", -- Right
		[0x49] = "OX", -- Right, Hurt
		[0x4B] = "Hidden Block",
		[0x4D] = "Extra Life",
		[0x4E] = "Ring",
		[0x4F] = "Ghost",
		[0x50] = "Saint Nurari", -- Level 6
		[0x51] = "Patricia", -- Level 16
		[0x52] = "Item", -- Helecopter, Crown, Blue circle with star
		[0x54] = "Rolling Rock",
		[0x55] = "Hopper",
		[0x57] = "Flame", -- Stationary
		[0x61] = "Crown Code Controller",
	},
	["state"] = 0x01, -- Byte
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

	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		local color = nil;
		if objectType ~= 0 then
			if objectType == 0x52 then
				if mainmemory.readbyte(objectBase + 0x07) == 0xD3 and mainmemory.readbyte(objectBase + 0x08) == 0x80 then -- Detect crown and make it flash Red & Yellow
					if emu.framecount() % 10 > 4 then
						color = 0xFFFF0000; -- Red
					else
						color = 0xFFFFFF00; -- Yellow
					end
				end
			end
			if objectType == 0x44 then -- Detect Rice Cake and color it green
				color = 0xFF00FF00; -- Green
			end
			if type(object_fields.object_types[objectType]) ~= "nil" then
				objectType = object_fields.object_types[objectType];
			else
				objectType = "Unknown ("..toHexString(objectType)..")";
			end
			local xPosition = mainmemory.readbyte(objectBase + object_fields.x_position);
			local yPosition = mainmemory.readbyte(objectBase + object_fields.y_position);
			gui.text(gui_x, gui_y + height * row, xPosition..", "..yPosition.." - "..objectType.." "..toHexString(objectBase), color, nil, 'bottomright');
			row = row + 1;
		end
	end
end

while true do
	draw_ui();
	emu.yield();
end