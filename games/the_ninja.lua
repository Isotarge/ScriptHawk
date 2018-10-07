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
	ScriptHawk.hitboxDefaultMode = ScriptHawk.hitboxModeWHCentered;
	ScriptHawk.hitboxDefaultWidth = 16;
	ScriptHawk.hitboxDefaultHeight = 16;
	ScriptHawk.hitboxDefaultColor = colors.black;
	return true;
end

local object_size = 0x21;
local object_array_capacity = 27;

local max_player_projectiles = 3;
local max_enemies = 7;

local object_fields = {
	object_type = 0x00, -- Byte
	object_types = {
		[0x01] = {name="Player", color=colors.yellow},
		[0x02] = {name="Player Projectile", color=colors.yellow, hitbox_height=8, hitbox_width=8},
		[0x03] = {name="Player Projectile", color=colors.yellow, hitbox_height=8, hitbox_width=8},
		[0x04] = {name="Boss", color=colors.pink}, -- Early levels
		[0x05] = {name="Boss", color=colors.pink}, -- Later levels
		[0x06] = {name="Boss Projectile", color=colors.red},
		[0x07] = {name="Boss Projectile", color=colors.red}, -- Level 5
		[0x08] = {name="Boss Projectile", color=colors.red},
		[0x09] = {name="Enemy Projectile", color=colors.red, hitbox_height=8, hitbox_width=8}, -- Small projectile
		[0x0A] = {name="Boss Projectile", color=colors.red, hitbox_height=8, hitbox_width=8},
		[0x0B] = {name="Red Scroll", color=colors.pink},
		[0x0C] = {name="Blue Scroll", color=colors.pink},
		[0x0D] = {name="Green Scroll", color=colors.pink},
		[0x0E] = {name="Splash"},
		[0x0F] = {name="Enemy Dying", isEnemy=true},
		[0x10] = {name="Grey Enemy", isEnemy=true},
		[0x11] = {name="Blue Enemy", isEnemy=true},
		[0x12] = {name="Grey Enemy", isEnemy=true},
		[0x13] = {name="Grey Enemy", isEnemy=true},
		[0x14] = {name="Grey Enemy", isEnemy=true}, -- Level 6
		[0x15] = {name="Grey Enemy", isEnemy=true},
		[0x16] = {name="Grey Enemy", isEnemy=true}, -- Scythe
		[0x17] = {name="Boulder Enemy", isEnemy=true},
		[0x18] = {name="Popup Enemy", isEnemy=true}, -- Level 2
		[0x19] = {name="Bouncing Boulder", color=colors.red}, -- Level 2
		[0x1A] = {name="Bouncing Boulder Shadow"}, -- Level 2
		[0x1B] = {name="Horse", color=colors.red}, -- Level 7
		[0x1C] = {name="Wolf", isEnemy=true},
		[0x1D] = {name="Light Blue Enemy", isEnemy=true}, -- Level 11
		[0x1E] = {name="Green Enemy", isEnemy=true}, -- Level 8
		[0x1F] = {name="Enemy Projectile", color=colors.red}, -- Scythe
		[0x20] = {name="Grey Enemy", isEnemy=true}, -- From boulder, can contain green scroll
		[0x21] = {name="Boulder Enemy", isEnemy=true},
		[0x22] = {name="Grey Enemy", isEnemy=true}, -- Circling
		[0x23] = {name="Fire Enemy", isEnemy=true}, -- Level 7
		[0x24] = {name="Red Jumping Enemy", isEnemy=true}, -- Level 4
		[0x25] = {name="Red Enemy", isEnemy=true}, -- Level 4
		[0x26] = {name="Red Enemy", isEnemy=true}, -- Level 4, after jumping
		[0x27] = {name="Grey Enemy", isEnemy=true}, -- Cliff
		[0x28] = {name="Blue Enemy", isEnemy=true}, -- Cliff
		[0x29] = {name="Grey Enemy", isEnemy=true}, -- Cliff, moving up
		[0x2A] = {name="Ball Spawner"}, -- Cliff -- TODO: Does this count as an enemy?
		[0x2B] = {name="Ball", color=colors.red, hitbox_height=8, hitbox_width=8}, -- Cliff
		[0x2C] = {name="Green Scroll Trigger", color=colors.pink},
		[0x2D] = {name="Boulder Enemy", color=colors.pink}, -- Contains green scroll, does not count towards enemy cap
		[0x2E] = {name="Arrow", color=colors.pink}, -- Map Screen
		[0x2F] = {name="Red Scroll", color=colors.pink}, -- Map Screen
		[0x30] = {name="Blue Scroll", color=colors.pink}, -- Map Screen
		[0x31] = {name="Green Scrolls", color=colors.pink}, -- Map Screen
		[0x32] = {name="Staircase Trigger", color=colors.pink}, -- Level 10
		[0x33] = {name="Player", color=colors.pink}, -- End screen
		[0x34] = {name="Princess", color=colors.pink}, -- End screen
		[0x35] = {name="Boulder Enemy", isEnemy=true},
		[0x36] = {name="Blue Enemy", isEnemy=true, color=colors.pink}, -- Contains red scroll
		[0x37] = {name="Blue Enemy", isEnemy=true, color=colors.pink}, -- Contains blue scroll
		[0x38] = {name="Wolf", isEnemy=true, color=colors.pink}, -- Contains red scroll
		[0x39] = {name="Grey Enemy", isEnemy=true, color=colors.pink}, -- Contains blue scroll
		[0x3A] = {name="Red Enemy", isEnemy=true, color=colors.pink}, -- Level 6, Contains red scroll
		[0x3B] = {name="Grey Enemy", isEnemy=true}, -- Circles, Contains red scroll

		[0x3D] = {name="Grey Enemy", isEnemy=true}, -- Level 10, Contains red scroll
		[0x3E] = {name="Light Blue Enemy", isEnemy=true, color=colors.pink}, -- Level 11, Contains red scroll
		[0x3F] = {name="Light Blue Enemy", isEnemy=true, color=colors.pink}, -- Level 11, Contains blue scroll
		[0x40] = {name="Grey Enemy", isEnemy=true}, -- Level 5
		[0x41] = {name="Grey Enemy", isEnemy=true, color=colors.pink}, -- Level 5, Contains red scroll
		[0x42] = {name="Fire Enemy", isEnemy=true, color=colors.pink}, -- Level 7, Contains red scroll
		[0x43] = {name="Grey Enemy", isEnemy=true, color=colors.pink}, -- Cliff, Contains red scroll
		[0x44] = {name="Fire Enemy", isEnemy=true, color=colors.pink}, -- Contains blue scroll
		[0x45] = {name="Easter Egg Trigger", color=colors.yellow}, -- Only in Japanese version
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
		if object_fields.object_types[objectType] ~= nil and object_fields.object_types[objectType].isEnemy == true then
			num = num + 1;
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

-- Hacky method to hide OSD row
-- TODO: Figure out a way to do this without hacks in the OSD API
function Game.colorBossHealth()
	if Game.isBossLoaded() then
		return colors.white;
	end
	return colors.transparent;
end

function Game.getDColor()
	if math.abs(ScriptHawk.getDX()) > 0 or math.abs(ScriptHawk.getDY()) > 0 then
		return colors.white;
	end
	return colors.red;
end

Game.OSD = {
	{"X", Game.getPlayerXPosition, category="position"},
	{"Y", Game.getPlayerYPosition, category="position"},
	{"Level X", Game.getLevelXPosition, category="mapData"},
	{"Level Y", Game.getLevelYPosition, category="mapData"},
	{"dX", nil, Game.getDColor, category="positionStats"},
	{"dY", nil, Game.getDColor, category="positionStats"},
	{"Separator"},
	{"Player Proj", Game.countPlayerProjectiles, category="projectiles"},
	{"Hits", Game.getHitsOSD, category="hits"},
	{"Ratio", Game.getHitRatio, category="hits"},
	{"Separator"},
	{"Objects", Game.countObjects, category="objects"},
	{"Enemies", Game.countEnemies, category="enemies"},
	{"Separator"},
	{"Boss Health", Game.getBossHealth, Game.colorBossHealth, category="boss"},
};

function Game.getHitboxes()
	local hitboxes = {};
	for i = 0, object_array_capacity do
		local hitbox = {
			objectBase = Game.Memory.object_array_base + (i * object_size),
		};
		local objectType = mainmemory.readbyte(hitbox.objectBase + object_fields.object_type);
		if objectType ~= 0 then
			hitbox.dragTag = hitbox.objectBase;
			hitbox.objectType = "Unknown ("..toHexString(objectType)..")";
			hitbox.x = mainmemory.read_s16_le(hitbox.objectBase + object_fields.x_position);
			hitbox.y = mainmemory.read_s16_le(hitbox.objectBase + object_fields.y_position);

			if type(object_fields.object_types[objectType]) == "table" then
				local objectTypeTable = object_fields.object_types[objectType];
				hitbox.color = objectTypeTable.color or colors.white;
				hitbox.xOffset = objectTypeTable.hitbox_x_offset;
				hitbox.yOffset = objectTypeTable.hitbox_y_offset;
				hitbox.width = objectTypeTable.hitbox_width;
				hitbox.height = objectTypeTable.hitbox_height;

				if type(objectTypeTable.name) == "string" then
					hitbox.objectType = objectTypeTable.name.." "..toHexString(objectType);
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
	};
end

function Game.getHitboxListText(hitbox)
	return hitbox.x..", "..hitbox.y.." - "..hitbox.objectType.." "..toHexString(hitbox.objectBase);
end

return Game;