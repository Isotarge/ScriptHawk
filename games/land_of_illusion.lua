if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		screen_x_position = 0x70, -- Fixed u16.8 LE
		level_width = 0x7C, -- Single byte, measured in tiles
		max_health = 0x98,
		health = 0x99,
		lives = 0x9F,
		time_paused = 0xA0,
		time_frames = 0xA1, -- u8, maxes at 0x19 and counts down
		time_seconds = 0xA2, -- BCD
		time_hundred_seconds = 0xA3, -- BCD - Anything with 0xA-F in the upper digit is instakill, weird
		grabbed_object_pointer = 0x11A, -- 2 byte pointer onto system bus
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
		"0x00",
		"0x01",
		"0x02",
		"0x03",
		"0x04",
		"0x05",
		"0x06",
		"0x07",
		"0x08",
		"0x09",
		"0x0A",
		"0x0B",
		"0x0C",
		"0x0D",
		"0x0E",
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

	-- Set time to max
	mainmemory.writebyte(Game.Memory.time_seconds, 0x00);
	mainmemory.writebyte(Game.Memory.time_hundred_seconds, 0x10);
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
			};
			table.insert(hitboxes, hitbox);
		end
	end
	return hitboxes;
end

function Game.getHitboxListText(hitbox)
	return round(hitbox.x)..", "..round(hitbox.y).." - "..toHexString(hitbox.base);
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

function Game.drawMap()
	local screenXPos = Game.getScreenXPosition();
	local startX = math.floor(screenXPos / tile_size);
	local endX = startX + 16;
	local levelWidth = mainmemory.readbyte(Game.Memory.level_width);
	local xOffset = ScriptHawk.overscan_compensation.x + (tile_size - screenXPos % tile_size) - tile_size;
	local yOffset = ScriptHawk.overscan_compensation.y;
	for x = startX, endX do
		for y = 0x00, screen_height - 1 do
			local tile = tilemap_start + y * levelWidth + x;
			local tileValue = mainmemory.readbyte(tile);
			ScriptHawk.drawText((x - startX) * tile_size + xOffset, y * tile_size + yOffset, toHexString(tileValue, 2, ""), nil, 0, true);
		end
	end
	--print_deferred();
end

function Game.drawUI()
	if (ScriptHawk.UI.isChecked("Draw Map Checkbox")) then
		Game.drawMap();
	end
end

function Game.initUI()
	ScriptHawk.UI.checkbox(10, 4, "Draw Map Checkbox", "Draw Map");
end

Game.OSD = {
	{"Level", Game.getLevel},
	{"IGT", Game.getIGT, Game.blueWhenInfinites},
	{"Health", Game.getHealthOSD, Game.blueWhenInfinites},
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