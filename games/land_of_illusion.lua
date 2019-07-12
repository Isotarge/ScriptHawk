if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		screen_x_position = 0x70, -- Fixed u16.8 LE
		tilemap_pointer = 0x79,
		level_width = 0x7C, -- Single byte, measured in tiles
		max_health = 0x98,
		health = 0x99,
		lives = 0x9F,
		time_paused = 0xA0,
		time_frames = 0xA1, -- u8, maxes at 0x19 and counts down
		time_seconds = 0xA2, -- BCD
		time_hundred_seconds = 0xA3, -- BCD - Anything with 0xA-F in the upper digit is instakill, weird
		air_timer = 0xAC,
		air = 0xAD,
		grabbed_object_pointer = 0x11A, -- 2 byte pointer onto system bus
		time_ticking_down = 0x12D, -- 0x04 ticking, possibly a bitfield?
		x_position_level = 0x214, -- Fixed u16.8 LE
		x_position = 0x20C, -- Fixed u8.8 LE
		y_position = 0x20A, -- Fixed u8.8 LE
		x_velocity = 0x210, -- Fixed s8.8 LE
		y_velocity = 0x20E, -- Fixed s8.8 LE
		level_index = 0x9FF, -- Single byte
		--[[
		Tornados RNG (Level 2)	0x04BA
		Boss Health	0x041F
		Boss Cycle and RNG	0x041A
		--]]
	},
	maps = {
		"Intro",
		"Forest",
		"Lake",
		"Blacksmith's Castle",
		"Castle Ruins",
		"Tiny Cavern",
		"Flower Field",
		"Toy Workshop",
		"Palace Ruins",
		"Craggy Cliff",
		"Desert",
		"Good Princess's Castle",
		"Sand Castle",
		"Island",
		"Phantom's Castle",
	},
};

local enemy_array = 0x200;
local enemy_array_capacity = 32;
local enemy_size = 0x20;
local enemy = {
	x_screen = 0x0C,
	y_screen = 0x12, -- Single byte?
	x = 0x14,
	y = 0x0A,
	health = 0x1F, -- Boss Only?
};

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

function Game.read_hitbox_y(base)
	local major = mainmemory.read_s8(base + enemy.y_screen) * 256;
	local minor = mainmemory.read_u16_le(base + enemy.y) / 256;
	return major + minor;
end

function Game.write_hitbox_y(base, value)
	local major = math.floor(value / 256);
	local minor = (value * 256) % 0xFFFF;
	mainmemory.write_s8(base + enemy.y_screen, major);
	mainmemory.write_u16_le(base + enemy.y, minor);
end

function Game.write_u16_8(base, value)
	local major = math.floor(value);
	local sub = value - major;
	mainmemory.writebyte(base, sub * 256);
	mainmemory.write_u16_le(base + 1, major);
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.smooth_moving_angle = false;
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultMode = ScriptHawk.hitboxModeWHCentered;
	return true;
end

function Game.getXPosition()
	return Game.read_u16_8(Game.Memory.x_position_level);
end

function Game.getYPosition()
	return Game.read_hitbox_y(0x200);
end

function Game.getScreenXPosition()
	return Game.read_u16_8(Game.Memory.screen_x_position);
end

function Game.getXVelocity()
	return mainmemory.read_s16_le(Game.Memory.x_velocity) / 256;
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(Game.Memory.y_velocity) / 256;
end

function Game.blueWhenInfinites()
	if ScriptHawk.UI.ischecked("Toggle Infinites Checkbox") then
		return colors.blue;
	end
end

function Game.applyInfinites()
	-- Set lives to max
	mainmemory.writebyte(Game.Memory.lives, 0x10);

	-- Set health to max
	mainmemory.writebyte(Game.Memory.health, mainmemory.readbyte(Game.Memory.max_health));

	-- Set air to max
	mainmemory.writebyte(Game.Memory.air, 8);

	-- Set time to max if it's not counting down
	if not bit.check(mainmemory.readbyte(Game.Memory.time_ticking_down), 2) then
		mainmemory.writebyte(Game.Memory.time_seconds, 0x00);
		mainmemory.writebyte(Game.Memory.time_hundred_seconds, 0x10);
	end
end

function Game.getIGT()
	local frames = mainmemory.readbyte(Game.Memory.time_frames);
	local seconds = toHexString(mainmemory.readbyte(Game.Memory.time_seconds), 2, "");
	local hundredSeconds = toHexString(mainmemory.readbyte(Game.Memory.time_hundred_seconds), 2, "");
	return hundredSeconds..seconds.."."..frames;
end

function Game.getHealth()
	return mainmemory.readbyte(Game.Memory.health);
end

function Game.getMaxHealth()
	return mainmemory.readbyte(Game.Memory.max_health);
end

function Game.getHealthOSD()
	return Game.getHealth().."/"..Game.getMaxHealth();
end

function Game.getBossHealth()
	return 0; -- TODO
end

function Game.getHitboxes()
	local hitboxes = {};

	local screenX = Game.getScreenXPosition();
	ScriptHawk.hitboxDefaultXOffset = -screenX;

	for base = enemy_array, enemy_array + enemy_array_capacity * enemy_size, enemy_size do
		local enemyType = mainmemory.readbyte(base);
		if enemyType ~= 0 then
			local hitbox = {
				base = base,
				dragTag = base,
				enemyType = enemyType,
				x = Game.read_u16_8(base + enemy.x),
				y = Game.read_hitbox_y(base),
				width = 16,
				height = 16,
				health = mainmemory.readbyte(base + enemy.health),
			};
			table.insert(hitboxes, hitbox);
		end
	end
	return hitboxes;
end

function Game.getHitboxListText(hitbox)
	return round(hitbox.x)..", "..round(hitbox.y).." "..hitbox.health.."HP - "..toHexString(hitbox.base);
end

function Game.getHitboxStaticText(hitbox)
	return toHexString(hitbox.base);
end

function Game.setHitboxPosition(hitbox, x, y)
	Game.write_u16_8(hitbox.base + enemy.x, x);
	Game.write_hitbox_y(hitbox.base, y);
end

function Game.getGrabbedObject()
	return mainmemory.read_u16_le(Game.Memory.grabbed_object_pointer);
end

function Game.getAirOSD()
	return mainmemory.readbyte(Game.Memory.air).."."..mainmemory.readbyte(Game.Memory.air_timer);
end

function Game.getMapOSD()
	local currentMap = Game.getLevel();
	local currentMapName = "Unknown";
	if Game.maps[currentMap + 1] ~= nil then
		currentMapName = Game.maps[currentMap + 1];
	end
	return currentMapName.." ("..toHexString(currentMap)..")";
end

function Game.getTilemapPointer()
	return mainmemory.read_u16_le(Game.Memory.tilemap_pointer);
end

function Game.getLevel()
	return mainmemory.readbyte(Game.Memory.level_index);
end

function Game.setMap(value)
	mainmemory.writebyte(Game.Memory.level_index, value - 1);
end

-- Map Data
local tilemap_start = 0x1600;
local screen_height = 0x0A; -- tiles
local tile_size = 16;

local SOLID = 0xFFFF0000; -- Red
local SOLID_ABOVE_ONLY = 0xFFFF7F00; -- Orange
local EMPTY = 0x2FFFFFFF; -- White
local BLOCK = 0xFFFFFF00; -- Yellow
local VINE = 0xFF00FF00; -- Green
local SECRET = 0xFF00FF00; -- Green
local CHECKPOINT = 0xFF0000FF; -- Blue
local DOOR = 0xFF0000FF; -- Blue
local DAMAGE = 0xFFFF00FF; -- Pink
local SLOPE = 0xFFFF00FF; -- Pink, for now
local UNKNOWN = 0xFFFF00FF; -- Pink

local tile_colors = {
	[0x8DD9] = { -- Forest Start
		[0x00] = EMPTY,
		[0x01] = EMPTY,
		[0x02] = BLOCK,
		[0x03] = SOLID,
		[0x04] = SOLID,
		[0x05] = SOLID,
		[0x06] = SOLID,
		[0x07] = SOLID,
		[0x08] = DAMAGE,
		[0x09] = SOLID,
		[0x0A] = SOLID,
		[0x0B] = SOLID,
		[0x0C] = SOLID,
		[0x0D] = DOOR,
		[0x0E] = DOOR,
		[0x0F] = DOOR,
		[0x10] = DOOR,
		[0x11] = SOLID,
		[0x12] = SOLID,
		[0x13] = SOLID,
		[0x14] = VINE,
		[0x15] = VINE,
		[0x16] = VINE,
		[0x17] = VINE,
		[0x18] = SOLID,
		[0x19] = SOLID,
		[0x1A] = SOLID,
		[0x1B] = SOLID,
		[0x1C] = SOLID,
		[0x1D] = SOLID,
		[0x1E] = EMPTY,
		[0x1F] = EMPTY, -- Unused?
		[0x20] = EMPTY,
		[0x21] = EMPTY,
		[0x22] = EMPTY,
		[0x23] = EMPTY,
		[0x24] = SOLID,
		[0x25] = SOLID,
		[0x26] = SOLID,
		[0x27] = SOLID,
		[0x28] = EMPTY,
		[0x29] = EMPTY,
		[0x2A] = EMPTY, -- Unused?
		[0x2B] = SOLID_ABOVE_ONLY, -- Tree branch
		[0x2D] = SOLID_ABOVE_ONLY, -- Tree branch
		[0x2E] = SOLID_ABOVE_ONLY, -- Tree branch
		[0x2F] = SOLID_ABOVE_ONLY, -- Tree branch
		[0x30] = EMPTY, -- Unused?
		[0x31] = EMPTY,
		[0x32] = EMPTY,
		[0x33] = EMPTY,
		[0x34] = EMPTY,
		[0x35] = EMPTY,
		[0x36] = EMPTY,
		[0x37] = EMPTY,
		[0x38] = EMPTY,
		[0x39] = EMPTY,
		[0x3A] = EMPTY,
		[0x3B] = EMPTY,
		[0x3C] = EMPTY,
		[0x3D] = EMPTY,
		[0x3E] = EMPTY,
		[0x3F] = EMPTY,
		[0x40] = EMPTY,
		[0x41] = EMPTY, -- Unused?
		[0x42] = EMPTY,
		[0x43] = EMPTY,
		[0x44] = EMPTY,
		[0x45] = EMPTY,
		[0x46] = EMPTY,
		[0x47] = EMPTY,
		[0x48] = EMPTY,
		[0x49] = EMPTY,
		[0x4A] = EMPTY,
		[0x4C] = EMPTY,
		[0x4D] = EMPTY,
		[0x4E] = EMPTY,
		[0x4F] = EMPTY,
		[0x50] = EMPTY,
		[0x51] = EMPTY,
		[0x52] = EMPTY,
		[0x53] = EMPTY,
		[0x54] = EMPTY,
		[0x55] = EMPTY,
		[0x56] = EMPTY,
		[0x57] = EMPTY,
		[0x58] = EMPTY,
		[0x59] = EMPTY,
		[0x5A] = EMPTY,
		[0x5B] = EMPTY,
		[0x5C] = EMPTY,
		[0x5D] = EMPTY,
		[0x5E] = EMPTY,
		[0x5F] = EMPTY,
		[0x60] = EMPTY, -- Web
		[0x61] = EMPTY, -- Web
		[0x62] = EMPTY, -- Web
		[0x63] = EMPTY, -- Web
		[0x64] = EMPTY, -- Web
		[0x65] = EMPTY, -- Web
		[0x66] = EMPTY, -- Web
		[0x67] = EMPTY, -- Web
		[0x68] = EMPTY, -- Web
		[0x69] = EMPTY, -- Web
		[0x6A] = EMPTY, -- Web
		[0x6B] = EMPTY, -- Web
		[0x6C] = EMPTY, -- Web
		[0x6D] = EMPTY,
		[0x6E] = EMPTY,
		[0x6F] = EMPTY,
		[0x70] = EMPTY,
		[0x71] = EMPTY,
		[0x72] = EMPTY,
		[0x73] = EMPTY,
		[0x74] = EMPTY,
		[0x75] = EMPTY,
		[0x76] = EMPTY,
		[0x77] = EMPTY,
		[0x78] = EMPTY,
		[0x79] = EMPTY,
		[0x7A] = SOLID_ABOVE_ONLY,
		[0x7B] = SECRET,
		[0x7C] = SECRET,
		[0x7D] = SECRET,
		[0x7E] = SECRET,
		[0x7F] = SECRET,
	},
	[0xA361] = {
		[0x01] = EMPTY,
		[0x02] = EMPTY,
		[0x03] = SOLID,
		[0x04] = EMPTY,
		[0x05] = SOLID,
		[0x06] = SOLID,
		[0x07] = SOLID,
		[0x08] = SOLID,
		[0x09] = CHECKPOINT,
		[0x0A] = CHECKPOINT,
		[0x0B] = CHECKPOINT,
		[0x0C] = CHECKPOINT,
		[0x0D] = DOOR,
		[0x0E] = DOOR,
		[0x0F] = DOOR,
		[0x10] = DOOR,
		[0x11] = SOLID,
		[0x12] = SOLID,

		[0x14] = VINE,
		[0x15] = VINE,
		[0x16] = VINE,
		[0x17] = VINE,
		[0x18] = SOLID,
		[0x19] = SOLID,
		[0x1A] = SOLID,
		[0x1B] = SOLID,
		[0x1C] = EMPTY,
		[0x1D] = EMPTY,
		[0x1E] = EMPTY,
		[0x1F] = EMPTY,
		[0x20] = DOOR,
		[0x21] = DOOR,
		[0x22] = DOOR,
		[0x23] = DOOR,
		[0x24] = SOLID,
		[0x25] = EMPTY,

		[0x28] = DOOR,
		[0x29] = DOOR,
		[0x2A] = DOOR,
		[0x2B] = DOOR,
		[0x2C] = EMPTY,
		[0x2D] = EMPTY,
		[0x2E] = EMPTY,
		[0x2F] = EMPTY,
		[0x30] = EMPTY,
		[0x31] = EMPTY,
		[0x32] = EMPTY,
		[0x33] = EMPTY,
		[0x34] = EMPTY,
		[0x35] = EMPTY,
		[0x36] = EMPTY,
		[0x37] = EMPTY,
		[0x38] = EMPTY,
		[0x39] = EMPTY,
		[0x3A] = EMPTY,
		[0x3B] = EMPTY,
		[0x3C] = EMPTY,
		[0x3D] = EMPTY,
		[0x3E] = EMPTY,
		[0x3F] = EMPTY,
		[0x40] = EMPTY,
		[0x41] = EMPTY,
		[0x42] = EMPTY,
		[0x43] = EMPTY,
		[0x44] = EMPTY,
		[0x45] = EMPTY,
		[0x46] = EMPTY,
		[0x47] = EMPTY,

		[0x49] = EMPTY,
		[0x4A] = EMPTY,
		[0x4B] = EMPTY,
		[0x4C] = EMPTY,
		[0x4D] = EMPTY,
		[0x4E] = EMPTY,
		[0x4F] = EMPTY,
		[0x50] = SOLID_ABOVE_ONLY,
		[0x51] = EMPTY,
		[0x52] = EMPTY,
		[0x53] = EMPTY,
		[0x54] = SOLID_ABOVE_ONLY,
		[0x55] = EMPTY,
		[0x56] = SOLID_ABOVE_ONLY,
		[0x57] = SOLID_ABOVE_ONLY,
		[0x58] = SOLID_ABOVE_ONLY,
		[0x59] = EMPTY,
		[0x5A] = EMPTY,
		[0x5B] = EMPTY,
		[0x5C] = SOLID_ABOVE_ONLY,
		[0x5D] = EMPTY,
		[0x5E] = EMPTY,
		[0x5F] = SOLID_ABOVE_ONLY,
		[0x60] = SOLID,
		[0x61] = SOLID,

		[0x68] = SOLID,

		[0x6A] = SOLID_ABOVE_ONLY,
		[0x6B] = SOLID_ABOVE_ONLY,
		[0x6C] = SOLID_ABOVE_ONLY,

		[0x6F] = EMPTY,

		[0x71] = EMPTY,

		[0x78] = EMPTY,

		[0x80] = SOLID,

		[0x82] = SOLID,

		[0x88] = EMPTY,
		[0x89] = EMPTY,
		[0x8A] = EMPTY,
		[0x8B] = EMPTY,
		[0x8C] = EMPTY,
		[0x8D] = EMPTY,
	},
	[0xBAE8] = {
		[0x00] = EMPTY,
		[0x10] = SOLID, -- Log Left
		[0x11] = SOLID, -- Log Section
		[0x13] = EMPTY, -- Green Background
		[0x15] = SOLID,
		[0x16] = VINE, -- Log Top
		[0x17] = VINE, -- Middle, Green Background
		[0x18] = EMPTY,
		[0x19] = EMPTY,
		[0x1A] = EMPTY,
		[0x1B] = EMPTY,
		[0x1C] = EMPTY,
		[0x1D] = EMPTY,
		[0x1E] = EMPTY,
		[0x1F] = EMPTY,

		[0x26] = SOLID,

		[0x30] = EMPTY,
		[0x31] = EMPTY,
		[0x32] = EMPTY,
		[0x33] = EMPTY,
		[0x34] = EMPTY,
		[0x35] = EMPTY,

		[0x40] = EMPTY,
		[0x41] = SOLID,

		[0x5C] = EMPTY,
		[0x5D] = EMPTY,
		[0x5E] = EMPTY,
		[0x5F] = EMPTY,
		[0x60] = EMPTY,
		[0x61] = EMPTY,
		[0x62] = EMPTY,
		[0x63] = EMPTY,
		[0x64] = EMPTY,
		[0x65] = EMPTY,
	},
	[0x8C92] = { -- Lake Start
		[0x02] = BLOCK,
		[0x09] = CHECKPOINT,
		[0x0A] = CHECKPOINT,
		[0x0B] = DOOR,
		[0x0C] = DOOR,
		[0x0D] = DOOR,
		[0x0E] = DOOR,
		[0x0F] = VINE,
		[0x10] = VINE,
		[0x17] = SOLID,
		[0x18] = SOLID,
		[0x19] = SOLID,
		[0x1A] = SOLID,
		[0x1B] = SOLID,
		[0x1D] = SOLID,
		[0x1E] = SOLID,
		[0x1F] = SOLID,
		[0x20] = SOLID,
		[0x22] = SOLID,
		[0x23] = SOLID,
		[0x26] = EMPTY,
		[0x27] = EMPTY,
		[0x28] = EMPTY,
		[0x29] = EMPTY,
		[0x2A] = EMPTY,
		[0x2B] = EMPTY,
		[0x2C] = EMPTY,
		[0x2D] = EMPTY,
		[0x2E] = EMPTY,
		[0x2F] = EMPTY,
		[0x30] = EMPTY,
		[0x31] = EMPTY,
		[0x32] = EMPTY,
		[0x33] = EMPTY,
		[0x34] = EMPTY,
		[0x35] = EMPTY,
		[0x37] = EMPTY,
		[0x38] = EMPTY,
		[0x3D] = EMPTY,
		[0x3E] = EMPTY,
		[0x3F] = EMPTY,
		[0x41] = SOLID,
		[0x47] = EMPTY,
		[0x4F] = EMPTY,
		[0x54] = SOLID,
		[0x55] = SOLID,
		[0x56] = SOLID,
		[0x57] = SOLID,
	},
};

function setEveryTile(value, height)
	if height == nil then
		height = 1
	end
	local levelWidth = mainmemory.readbyte(Game.Memory.level_width);
	for x = 0x00, levelWidth do
		for y = 0x00, screen_height - 1 do
			local tile = tilemap_start + y * levelWidth + x;
			mainmemory.writebyte(tile, value);
			if y == screen_height - height then
				mainmemory.writebyte(tile, 0x02); -- Block the bottom
			end
		end
	end
end

function Game.drawCollision()
	local mouse = input.getmouse(); -- TODO: Can we use mouse_state.current?
	local mouseIsOnScreen = (mouse.X >= 0 and mouse.X < ScriptHawk.bufferWidth) and (mouse.Y >= 0 and mouse.Y < ScriptHawk.bufferHeight);
	local screenXPos = Game.getScreenXPosition();
	for tileX = 0, 32 - 1 do
		local drawX = tileX * 8;
		drawX = drawX + 256 - screenXPos;
		drawX = drawX % 256;
		drawX = drawX + ScriptHawk.overscan_compensation.x;
		for tileY = 0, 20 - 1 do
			local drawY = tileY * 8 + ScriptHawk.overscan_compensation.y;
			local tileQuarterAddress = 0xA00 + (tileY * 64) + (tileX * 2) + 1;
			local collisionValue = mainmemory.readbyte(tileQuarterAddress);
			local collisionColor = nil;
			if collisionValue == 0x09 or collisionValue == 0x0B or collisionValue == 0x0D or collisionValue == 0x0F then
				collisionColor = DOOR;
			elseif collisionValue == 0x21 or collisionValue == 0x23 or collisionValue == 0x27 then
				collisionColor = SOLID_ABOVE_ONLY;
			elseif collisionValue == 0x41 or collisionValue == 0x43 or collisionValue == 0x45 or collisionValue == 0x47 then
				collisionColor = SOLID;
			elseif collisionValue == 0x49 or collisionValue == 0x4B then
				collisionColor = BLOCK; -- Toy, might just be solid, not sure
			elseif collisionValue == 0x51 or collisionValue == 0x53 then
				collisionColor = SOLID; -- Ceilings?
			elseif collisionValue == 0xA9 or collisionValue == 0xAB or collisionValue == 0xAF then
				collisionColor = BLOCK;
			elseif collisionValue == 0x61 or collisionValue == 0x63 or collisionValue == 0x81 or collisionValue == 0x83 then
				collisionColor = VINE; -- Also Spike? (Desert)
			elseif collisionValue == 0xC1 or collisionValue == 0xC3 then
				collisionColor = SLOPE; -- Slope down left, also fire right?
			elseif collisionValue == 0xE1 or collisionValue == 0xE3 then
				collisionColor = DAMAGE; -- Also right slope down?
			end
			if collisionColor ~= nil then
				gui.drawRectangle(drawX, drawY, 8, 8, collisionColor, nil);
			end
			if mouseIsOnScreen  then
				if mouse.X >= drawX and mouse.X <= drawX + 8 then
					if mouse.Y >= drawY and mouse.Y <= drawY + 8 then
						ScriptHawk.drawText(drawX, drawY, toHexString(collisionValue, 2, ""), collisionColor or colors.white, 0x7F000000, true);
					end
				end
			end
		end
	end
end

function Game.drawMap()
	local screenXPos = Game.getScreenXPosition();
	local startX = math.floor(screenXPos / tile_size);
	local endX = startX + 16;
	local levelWidth = mainmemory.readbyte(Game.Memory.level_width);
	local xOffset = ScriptHawk.overscan_compensation.x + (tile_size - screenXPos % tile_size) - tile_size;
	local yOffset = ScriptHawk.overscan_compensation.y;
	local levelIndex = Game.getTilemapPointer();
	for x = startX, endX do
		for y = 0x00, screen_height - 1 do
			local tile = tilemap_start + y * levelWidth + x;
			local tileValue = mainmemory.readbyte(tile);
			local tileColor = UNKNOWN;
			if tile_colors[levelIndex] ~= nil then
				if tile_colors[levelIndex][tileValue] ~= nil then
					tileColor = tile_colors[levelIndex][tileValue];
				end
			end
			ScriptHawk.drawText((x - startX) * tile_size + xOffset, y * tile_size + yOffset, toHexString(tileValue, 2, ""), tileColor, 0, true);
		end
	end
end

function Game.drawUI()
	if ScriptHawk.UI.isChecked("Draw Map Checkbox") then
		Game.drawMap();
	end
	if ScriptHawk.UI.isChecked("Draw Collision Checkbox") then
		Game.drawCollision();
	end
end

function Game.toggleMiniAbility()
	mainmemory.writebyte(0x86, bit.toggle(mainmemory.readbyte(0x86), 3));
end

function Game.initUI()
	ScriptHawk.UI.button(0, 6, {4, 10}, nil, "Toggle Mini Ability Button", "Toggle Mini Avail.", Game.toggleMiniAbility);
	ScriptHawk.UI.checkbox(10, 4, "Draw Map Checkbox", "Draw Map");
	ScriptHawk.UI.checkbox(10, 5, "Draw Collision Checkbox", "Draw Collision");
end

Game.OSD = {
	{"Level", Game.getMapOSD},
	{"Tile Map", hexifyOSD(Game.getTilemapPointer)},
	{"IGT", Game.getIGT, Game.blueWhenInfinites},
	{"Health", Game.getHealthOSD, Game.blueWhenInfinites},
	{"Air", Game.getAirOSD, Game.blueWhenInfinites},
	{"Separator"},
	{"X"},
	{"Y"},
	{"dX"},
	{"dY"},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"Separator"},
	{"Screen X", Game.getScreenXPosition},
	{"Grabbed", hexifyOSD(Game.getGrabbedObject)},
};

return Game;