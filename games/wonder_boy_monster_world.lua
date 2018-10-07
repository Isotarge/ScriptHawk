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
	return Game.maps[map + 1] or "Unknown "..toHexString(map);
end

function Game.setMap(value)
	if mainmemory.readbyte(0xC6) == 0 then
		mainmemory.writebyte(Game.Memory.map, value - 1);
	end
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultWidth = 16;
	ScriptHawk.hitboxDefaultHeight = 16;
	ScriptHawk.hitboxDefaultColor = colors.red;
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

function Game.getHitboxes()
	local hitboxes = {};
	local mapX = Game.getMapX();
	local mapY = Game.getMapY();

	for i = 0, object_array_capacity do
		local hitbox = {
			objectBase = object_array_base + (i * object_size),
		};
		local objectType = mainmemory.readbyte(hitbox.objectBase + object_fields.object_type);
		if objectType > 0 then
			hitbox.dragTag = hitbox.objectBase;
			hitbox.objectType = "Unknown "..toHexString(objectType);
			hitbox.xOffset = -mapX;
			hitbox.yOffset = -mapY - 105;
			hitbox.x = mainmemory.read_s16_le(hitbox.objectBase + object_fields.x_position);
			hitbox.y = mainmemory.read_s16_le(hitbox.objectBase + object_fields.y_position);
			hitbox.currentHP = mainmemory.readbyte(hitbox.objectBase + object_fields.currentHP);

			if type(object_fields.object_types[objectType]) == "table" then
				local objectTypeTable = object_fields.object_types[objectType];
				hitbox.color = objectTypeTable.color or colors.white;
				hitbox.width = objectTypeTable.hitbox_width;
				hitbox.height = objectTypeTable.hitbox_height;

				if type(objectTypeTable.name) == "string" then
					hitbox.objectType = objectTypeTable.name;
				end
			end

			table.insert(hitboxes, hitbox);
		end
	end
	return hitboxes;
end

function Game.setHitboxPosition(hitbox, x, y)
	mainmemory.write_s16_le(hitbox.objectBase + object_fields.x_position, x);
	mainmemory.write_s16_le(hitbox.objectBase + object_fields.y_position, y);
end

function Game.getHitboxMouseOverText(hitbox)
	return {
		hitbox.objectType,
		toHexString(hitbox.objectBase).." "..hitbox.x..","..hitbox.y,
		hitbox.currentHP.."HP",
	};
end

function Game.getHitboxStaticText(hitbox)
	if hitbox.currentHP > 0 then
		return hitbox.currentHP;
	end
end

function Game.getHitboxListText(hitbox)
	return hitbox.x..", "..hitbox.y.." - "..hitbox.objectType.." "..hitbox.currentHP.."HP "..toHexString(hitbox.objectBase);
end

Game.OSD = {
	{"Map", Game.getMap, category="mapData"},
	{"Map X", Game.getMapX, category="mapData"},
	{"Map Y", Game.getMapY, category="mapData"},
	{"Separator"},
	{"Health", function() return Game.getHealth().."/"..Game.getMaxHealth(); end, category="health"},
	{"HP Timer", Game.getHPTimer, category="health"},
	{"X", category="position"},
	{"Y", category="position"},
	{"X Velocity", Game.getXVelocity, category="speed"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"dX", category="positionStats"},
	{"dY", category="positionStats"},
};

return Game;