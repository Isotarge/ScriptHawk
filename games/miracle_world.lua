if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {};

-- Game state
local object_array_base = 0x300;
local object_size = 0x20;
local object_array_capacity = 30;

local function isActiveEnemy(objectBase)
	return (mainmemory.readbyte(objectBase + 0x09) == 0) and (mainmemory.readbyte(objectBase + 0x0A) == 0);
end

local function isActiveBoss(objectBase)
	return isActiveEnemy(objectBase) and (mainmemory.readbyte(objectBase + 0x1A) > 1);
end

local object_fields = {
	object_type = 0x00, -- Byte
	object_types = {
		[0x01] = {name="Player", color=colors.yellow},
		[0x02] = {name="Bullet", hitbox_width=8, hitbox_height=8},
		[0x03] = {name="Explosion", color=colors.yellow}, -- Vehicle dying
		[0x04] = {name="Bullet"}, -- Dying
		[0x05] = {name="miniAlex Turret", color=colors.yellow}, -- Falling
		[0x06] = {name="miniAlex Turret", color=colors.yellow}, -- Active
		[0x07] = {name="Shield Spawner", color=colors.yellow},
		[0x08] = {name="Shield", color=colors.yellow},
		[0x09] = {name="miniAlex", color=colors.yellow},
		[0x0A] = {name="miniAlex", color=colors.yellow}, -- Falling
		[0x0B] = {name="Janken Choice Display", hitbox_width=32, hitbox_height=32, color=colors.yellow},
		[0x0C] = {name="Janken Score Display", hitbox_width=24, hitbox_height=8, color=colors.yellow},
		[0x0D] = {name="Stone Head's Head", color=colors.red},
		[0x0E] = {name="Scissors Head's Head", color=colors.red},
		[0x0F] = {name="Paper Head's Head", color=colors.red},
		[0x10] = {name="Spike", color=colors.red}, -- Will fall when room loads
		[0x12] = {name="Falling Block", color=colors.red}, -- Loading
		[0x13] = {name="Spike", color=colors.red}, -- Loading
		[0x14] = {name="Spike", color=colors.red}, -- Falling
		[0x15] = {name="Waterfall", color=colors.red}, -- Falling
		[0x16] = {name="Trapdoor", color=colors.pink, active=isActiveEnemy}, -- Opens when stepped on
		[0x17] = {name="Trigger", color=colors.pink}, -- For falling blocks
		[0x18] = {name="Title Screen Sprite", color=colors.yellow},
		[0x19] = {name="Projectile", hitbox_width=8, hitbox_height=8, color=colors.red}, -- Janken Ninja Star
		[0x1B] = {name="Projectile", hitbox_width=8, hitbox_height=8}, -- Ring
		[0x1A] = {name="Projectile", hitbox_width=8, hitbox_height=8, color=colors.red}, -- Scissors Head Ninja Star
		[0x1C] = {name="Janken", color=colors.pink},
		[0x1D] = {name="Stone Head", color=colors.pink, active=isActiveBoss},
		[0x1E] = {name="Scissors Head", color=colors.pink, active=isActiveBoss},
		[0x1F] = {name="Paper Head", color=colors.pink, active=isActiveBoss},
		[0x20] = {name="Bat", direction="Left", hitbox_width=16, hitbox_height=8, color=colors.red, active=isActiveEnemy},
		[0x22] = {name="Bubble", color=colors.red, hitbox_width=8, hitbox_height=8}, -- Big Frog
		[0x23] = {name="Big Frog", color=colors.red, hitbox_width=24, hitbox_height=32, active=isActiveEnemy},
		[0x24] = {name="Octopus", color=colors.red, hitbox_width=8, hitbox_height=8, active=isActiveEnemy}, -- Arm segment
		[0x25] = {name="Blue Bear", direction="Left", color=colors.pink, active=isActiveEnemy}, -- Walking
		[0x26] = {name="Blue Bear", direction="Right", color=colors.pink, active=isActiveEnemy}, -- Walking
		[0x27] = {name="Blue Bear", direction="Left", color=colors.pink, active=isActiveEnemy}, -- Attacking
		[0x28] = {name="Blue Bear", direction="Right", color=colors.pink, active=isActiveEnemy}, -- Attacking
		[0x29] = {name="Projectile", color=colors.red, hitbox_width=8, hitbox_height=8}, -- Monkey
		[0x2A] = {name="Monkey", color=colors.red, active=isActiveEnemy},
		[0x2B] = {name="Dying"}, -- Small enemy
		[0x2C] = {name="Plant", color=colors.red, hitbox_width=16, hitbox_height=40, active=isActiveEnemy}, -- Moves up and down
		[0x2D] = {name="Bird", direction="Left", color=colors.red, hitbox_width=24, hitbox_height=16, active=isActiveEnemy},
		[0x2E] = {name="Killer Fish", direction="Left", color=colors.red, hitbox_width=24, hitbox_height=16, active=isActiveEnemy},
		[0x2F] = {name="Frog", color=colors.red, active=isActiveEnemy}, -- Small, Grounded
		[0x30] = {name="Fish", direction="Left", color=colors.red, active=isActiveEnemy}, -- Small Left
		[0x31] = {name="Seahorse", direction="Left", color=colors.red, active=isActiveEnemy},
		[0x32] = {name="Seahorse", direction="Right", color=colors.red, active=isActiveEnemy},
		[0x34] = {name="Fish", direction="Right", color=colors.red, active=isActiveEnemy}, -- Small
		[0x35] = {name="Killer Fish", direction="Right", color=colors.red, hitbox_width=24, hitbox_height=16, active=isActiveEnemy},
		[0x36] = {name="Bat", direction="Right", hitbox_width=16, hitbox_height=8, color=colors.red, active=isActiveEnemy},
		[0x33] = {name="Bird", direction="Right", color=colors.red, hitbox_width=24, hitbox_height=16, active=isActiveEnemy},
		[0x37] = {name="Frog", color=colors.red}, -- Small, Jumping
		[0x38] = {name="Box Particle", hitbox_width=8, hitbox_height=8},
		[0x39] = {name="Box Particle", hitbox_width=8, hitbox_height=8},
		[0x3A] = {name="Box Particle", hitbox_width=8, hitbox_height=8},
		[0x3B] = {name="Box Particle", hitbox_width=8, hitbox_height=8},
		[0x3C] = {name="Money", color=colors.green},
		[0x3D] = {name="Flame", color=colors.red, active=isActiveEnemy},
		[0x3E] = {name="Scorpion", direction="Left", color=colors.red, active=isActiveEnemy}, -- Also used for flames in later levels
		[0x3F] = {name="Scorpion", direction="Right", color=colors.red, active=isActiveEnemy}, -- Also used for flames in later levels
		[0x40] = {name="Cloud", color=colors.red, active=isActiveEnemy},
		[0x41] = {name="Cloud", color=colors.red, active=isActiveEnemy}, -- Shooting Lightning
		[0x42] = {name="Flying Fish", color=colors.red, active=isActiveEnemy},
		[0x43] = {name="Dying", color=colors.pink}, -- Boss, turns into Rice Cake
		[0x44] = {name="Rice Cake", color=colors.green, active=isActiveEnemy},
		[0x45] = {name="Saint Nurari", color=colors.yellow, active=isActiveEnemy}, -- Level 4
		[0x46] = {name="OX", direction="Left", color=colors.pink, active=isActiveEnemy},
		[0x47] = {name="OX", direction="Left", color=colors.pink, active=isActiveEnemy}, -- Hurt
		[0x48] = {name="OX", direction="Right", color=colors.pink, active=isActiveEnemy},
		[0x49] = {name="OX", direction="Right", color=colors.pink, active=isActiveEnemy}, -- Hurt
		[0x4A] = {name="Blue Bear", color=colors.pink, active=isActiveEnemy}, -- Hurt
		[0x4B] = {name="Hidden Block", color=colors.pink, active=isActiveEnemy},
		[0x4C] = {name="Warp", color=colors.pink, active=isActiveEnemy},
		[0x4D] = {name="Extra Life", color=colors.pink},
		[0x4E] = {name="Ring", color=colors.pink},
		[0x4F] = {name="Ghost", color=colors.red},
		[0x50] = {name="Saint Nurari", color=colors.yellow, active=isActiveEnemy}, -- Level 6
		[0x51] = {name="Patricia", color=colors.yellow, active=isActiveEnemy}, -- Level 16
		[0x52] = {name="Item", color=colors.pink, active=isActiveEnemy}, -- Helecopter, Crown, Blue circle with star
		[0x54] = {name="Rolling Rock", color=colors.red, active=isActiveEnemy},
		[0x55] = {name="Hopper", color=colors.red, active=isActiveEnemy},
		[0x56] = {name="Arrow", hitbox_width=8, hitbox_height=8}, -- Map
		[0x57] = {name="Flame", color=colors.red, active=isActiveEnemy}, -- Stationary
		[0x60] = {name="Crown Door Trigger", color=colors.yellow, active=isActiveEnemy},
		[0x61] = {name="Crown Code Controller", color=colors.pink},
		[0x63] = {name="Hidden Block", color=colors.pink, active=isActiveEnemy},
	},
	state = 0x01, -- Byte
	active = 0x09, -- u16, 0x0000
	x_position = 0x0C, -- Byte -- TODO: Subpixel and screen wrap stuff, you know the drill
	y_position = 0x0E, -- Byte -- TODO: Subpixel and screen wrap stuff, you know the drill
	x_velocity = 0x10, -- S8
	y_velocity = 0x12, -- S8
	janken_decision = 0x17, -- Byte
	janken_decisions = {
		[0] = "Rock",
		[1] = "Scissors",
		[2] = "Paper",
	},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultMode = ScriptHawk.hitboxModeWH;
	ScriptHawk.hitboxDefaultWidth = 16;
	ScriptHawk.hitboxDefaultHeight = 16;
	ScriptHawk.hitboxDefaultColor = colors.white;
	return true;
end

function Game.getHitboxes()
	local hitboxes = {};
	for i = 0, object_array_capacity do
		local hitbox = {
			objectBase = object_array_base + (i * object_size),
		};
		local objectType = mainmemory.readbyte(hitbox.objectBase + object_fields.object_type);
		if objectType ~= 0 then
			hitbox.dragTag = hitbox.objectBase;
			hitbox.x = mainmemory.readbyte(hitbox.objectBase + object_fields.x_position);
			hitbox.y = mainmemory.readbyte(hitbox.objectBase + object_fields.y_position);
			hitbox.active = true;
			hitbox.objectType = "Unknown ("..toHexString(objectType)..")";

			if type(object_fields.object_types[objectType]) == "table" then
				local objectTypeTable = object_fields.object_types[objectType];
				hitbox.color = objectTypeTable.color;
				hitbox.width = objectTypeTable.hitbox_width;
				hitbox.height = objectTypeTable.hitbox_height;

				if type(objectTypeTable.name) == "string" then
					hitbox.objectType = objectTypeTable.name.." "..toHexString(objectType);
				end

				if type(objectTypeTable.active) == "function" then
					hitbox.active = objectTypeTable.active(hitbox.objectBase); -- Call the function to check whether the object is active
				end
			end

			if objectType == "Item 0x52" then
				if mainmemory.readbyte(hitbox.objectBase + 0x07) == 0xD3 and mainmemory.readbyte(hitbox.objectBase + 0x08) == 0x80 then -- Detect crown and make it flash Red & Yellow
					if emu.framecount() % 10 > 4 then
						hitbox.color = colors.red;
					else
						hitbox.color = colors.yellow;
					end
				end
			end

			if hitbox.active then
				table.insert(hitboxes, hitbox);
			end
		end
	end
	return hitboxes;
end

function Game.setHitboxPosition(hitbox, x, y)
	mainmemory.writebyte(hitbox.objectBase + object_fields.x_position, x);
	mainmemory.writebyte(hitbox.objectBase + object_fields.y_position, y);
	--mainmemory.write_s8(hitbox.objectBase + object_fields.x_velocity, 0);
	--mainmemory.write_s8(hitbox.objectBase + object_fields.y_velocity, 0);
end

function Game.getHitboxMouseOverText(hitbox)
	return {
		hitbox.objectType,
		toHexString(hitbox.objectBase).." "..hitbox.x..","..hitbox.y,
	};
end

function Game.getHitboxListText(hitbox)
	return hitbox.x..", "..hitbox.y.." - "..hitbox.objectType.." "..toHexString(hitbox.objectBase);
end

Game.OSD = {
	-- TODO
};

return Game;