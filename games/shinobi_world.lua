if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		screen_x = 0x4F, -- fixed 8.8 le
		screen_x_major = 0x51,
		screen_y = 0x61, -- fixed 8.8 le
		screen_y_major = 0x63,
		health = 0x22E,
	},
};

local object_fields = {
	object_type = 0x00,
	object_types = { -- TODO: Finish filling in this table
		[0x01708C] = {name="Player"},
		[0x01DCA9] = {name="Dying Enemy", color=colors.red},
		[0x01DFA8] = {name="Dying Enemy", color=colors.red},
		[0x02708C] = {name="Player"}, -- Walking
		[0x03708C] = {name="Player"}, -- Uncrouching
		[0x0339A9] = {color=colors.red},
		[0x035DA9] = {color=colors.red},
		[0x04708C] = {name="Player"}, -- Jumping
		[0x05E48C] = {name="Player"}, -- Swinging Sword
		[0x05F7AB] = {name="Ninja Star", yOffset=0, width=8, height=8, color=colors.yellow},
		[0x06248D] = {name="Player"}, -- Jumping + Sword
		[0x07708C] = {name="Player"}, -- Crouching
		[0x08648D] = {name="Player"}, -- Crouching
		[0x09708C] = {name="Player"}, -- Crawling
		[0x0A708C] = {name="Player"}, -- Falling
		[0x0B1EAC] = {name="Sniper", color=colors.red},
		[0x0B5EAC] = {name="Sniper", color=colors.red}, -- Facing down
		[0x0C708C] = {name="Player"}, -- Damaged
		[0x0C82AC] = {name="Bullet", yOffset=0, width=8, height=8, color=colors.yellow},
		[0x11B88C] = {name="Player"}, -- Climbing
		[0x133C8E] = {name="Player"}, -- Charging Pole Fire Thing
		[0x135C8E] = {name="Player"}, -- Charging Pole Fire Thing
		[0x137C8E] = {name="Player"}, -- Charging Pole Fire Thing
		[0x19DC8C] = {name="Player"}, -- Dying
		[0x1C72A9] = {name="Sword", color=colors.yellow},
		[0x25B3B3] = {name="Heart", yOffset=0, color=colors.pink},
		[0x26BFB3] = {name="Extra Life", yOffset=0, color=colors.pink},
		[0x27CBB3] = {name="Power", yOffset=0, color=colors.pink},
		[0x338BB3] = {name="Helicopter", color=colors.red},
		[0x38DCA9] = {name="Ninja", color=colors.red},
		[0x4496A9] = {name="Ninja", color=colors.red},
		[0x44DCA9] = {name="Ninja", color=colors.red},
		[0x46DCA9] = {name="Ninja", color=colors.red},
		[0x47DCA9] = {name="Ninja", color=colors.red}, -- Red
		[0x48DCA9] = {name="Ninja", color=colors.red}, -- Red
	},
	x_position = 0x0C, -- fixed 8.8 le
	y_position = 0x0A, -- fixed 8.8 le
	x_velocity = 0x10, -- fixed 8.8 le
	y_velocity = 0x0E, -- fixed 8.8 le
};

function Game.getScreenXPosition()
	return mainmemory.readbyte(Game.Memory.screen_x_major) * 256 + mainmemory.read_u16_le(Game.Memory.screen_x) / 256;
end

function Game.getScreenYPosition()
	return mainmemory.readbyte(Game.Memory.screen_y_major) * 256 + mainmemory.read_u16_le(Game.Memory.screen_y) / 256;
end

function Game.getPlayerXPosition()
	return mainmemory.read_u16_le(0x200 + object_fields.x_position) / 256;
end

function Game.getPlayerYPosition()
	return mainmemory.read_u16_le(0x200 + object_fields.y_position) / 256;
end

function Game.getXPosition()
	return Game.getScreenXPosition() + Game.getPlayerXPosition();
end

function Game.getYPosition()
	return Game.getScreenYPosition() + Game.getPlayerYPosition();
end

function Game.getXVelocity()
	return mainmemory.read_s16_le(0x200 + object_fields.x_velocity) / 256;
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(0x200 + object_fields.y_velocity) / 256;
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultMode = ScriptHawk.hitboxModeWHCentered;
	ScriptHawk.hitboxDefaultWidth = 16;
	ScriptHawk.hitboxDefaultHeight = 16;
	ScriptHawk.hitboxDefaultYOffset = -8;
	return true;
end

function Game.getHitboxes()
	local hitboxes = {};
	for base = 0x200, 0x4A0, 0x20 do
		local objectType = mainmemory.readbyte(base);
		if base ~= 0x220 and objectType > 0 and mainmemory.read_u16_le(base + 0x12) == 0 then
			objectType = mainmemory.read_u16_be(base + 2) + objectType * 65536;
			local hitbox = {
				base = base,
				dragTag = base,
				x = mainmemory.read_u16_le(base + object_fields.x_position) / 256,
				y = mainmemory.read_u16_le(base + object_fields.y_position) / 256,
				objectType = "Unknown "..toHexString(objectType, 6, ""),
			};
			local objectTypeTable = object_fields.object_types[objectType];
			if objectTypeTable ~= nil then
				hitbox.objectType = objectTypeTable.name or hitbox.objectType;
				hitbox.width = objectTypeTable.width;
				hitbox.height = objectTypeTable.height;
				hitbox.xOffset = objectTypeTable.xOffset;
				hitbox.yOffset = objectTypeTable.yOffset;
				hitbox.color = objectTypeTable.color;
			end
			table.insert(hitboxes, hitbox);
		end
	end
	return hitboxes;
end

function Game.setHitboxPosition(hitbox, x, y)
	mainmemory.write_u16_le(hitbox.base + object_fields.x_position, x * 256);
	mainmemory.write_u16_le(hitbox.base + object_fields.y_position, y * 256);
end

function Game.getHitboxMouseOverText(hitbox)
	return {
		hitbox.objectType,
		toHexString(hitbox.base).." "..round(hitbox.x)..", "..round(hitbox.y),
	};
end

function Game.getHitboxStaticText(hitbox)
	return toHexString(hitbox.base, 3, "");
end

function Game.getHitboxListText(hitbox)
	return round(hitbox.x)..", "..round(hitbox.y).." "..hitbox.objectType.." "..toHexString(hitbox.base, 3, "");
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.health, 6);
end

Game.OSD = {
	{"X", category="position"},
	{"Y", category="position"},
	{"dX", category="positionStats"},
	{"dY", category="positionStats"},
	{"X Velocity", Game.getXVelocity, category="speed"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
};

return Game;