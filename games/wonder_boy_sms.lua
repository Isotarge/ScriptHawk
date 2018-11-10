if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		-- Values:
		-- 0: In level
		-- 1: Score Screen
		mode = 0x11E,
		has_axe = 0x127, -- Byte
		level = 0x128, -- Byte
		screen_x_tile_major = 0x129, -- Byte
		screen_x_tile = 0x12A, -- Byte
		screen_x_pixel = 0x12B, -- Byte
		screen_x_pixel_major = 0x12C, -- Byte
		boss_hp = 0x1AC, -- Byte
		player_x_position = 0x226, -- fixed 8.8 le relative to screen
		player_y_position = 0x223, -- fixed 8.8 le relative to screen
		player_x_velocity = 0x232, -- signed fixed 8.8 le
		player_y_velocity = 0x230, -- signed fixed 8.8 le
		vitality = 0xC35, -- 2 bytes, minor.major
	},
	maps = {
		"1-1", "1-2", "1-3", "1-4",
		"2-1", "2-2", "2-3", "2-4",
		"3-1", "3-2", "3-3", "3-4",
		"4-1", "4-2", "4-3", "4-4",
		"5-1", "5-2", "5-3", "5-4",
		"6-1", "6-2", "6-3", "6-4",
		"7-1", "7-2", "7-3", "7-4",
		"8-1", "8-2", "8-3", "8-4",
		"9-1", "9-2", "9-3", "9-4",
		"10-1", "10-2", "10-3", "10-4",
		"Bonus",
	},
	-- To transform object positions/velocities into screen space
	-- Add the X offset (or Y offset)
	-- Then multiply by coordinate scale
	screenHeight = 192,
	coordinateScale = 2,
	coordinateXOffset = -65,
	coordinateYOffset = -80,
};

function Game.detectVersion(romName, romHash)
	if Game.version == 2 then -- Game Gear
		Game.screenHeight = 144;
		Game.coordinateXOffset = -88;
		Game.coordinateYOffset = -44;
	end
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultMode = ScriptHawk.hitboxModeWHCentered;
	ScriptHawk.hitboxDefaultWidth = 16;
	ScriptHawk.hitboxDefaultHeight = 16;
	return true;
end

function Game.inScoreScreen()
	return mainmemory.readbyte(Game.Memory.mode) == 1;
end

function Game.getLevel()
	local value = mainmemory.readbyte(Game.Memory.level);
	return Game.maps[value + 1] or value;
end

function Game.setMap(index)
	mainmemory.writebyte(Game.Memory.level, index - 1);
end

function Game.scaleCoord(coord)
	return coord * Game.coordinateScale;
end

function Game.xCoordToScreenSpace(coord)
	return Game.scaleCoord(coord + Game.coordinateXOffset);
end

function Game.yCoordToScreenSpace(coord)
	return Game.scaleCoord(Game.screenHeight - coord + Game.coordinateYOffset);
end

function Game.scaleCoordDown(coord)
	return coord / Game.coordinateScale;
end

function Game.xCoordToObjectSpace(coord)
	return Game.scaleCoordDown(coord) - Game.coordinateXOffset;
end

function Game.yCoordToObjectSpace(coord)
	return Game.screenHeight - Game.scaleCoordDown(coord) + Game.coordinateYOffset;
end

local object_fields = {
	object_type = 0x00, -- TODO: Find this
	object_types = {
		-- TODO: Start filling in this table
	},
	x_position = 0x06, -- fixed 8.8 le relative to screen
	y_position = 0x03, -- fixed 8.8 le relative to screen
	x_velocity = 0x12, -- signed fixed 8.8 le
	y_velocity = 0x10, -- signed fixed 8.8 le
};

-- minor.major
function Game.read_s88(address)
	return mainmemory.read_s16_le(address) / 256;
end

-- minor.major
function Game.read_u88(address)
	return mainmemory.read_u16_le(address) / 256;
end

function Game.getScreenXPosition()
	--local tileMajor = mainmemory.readbyte(Game.Memory.screen_x_tile_major);
	--local tile = mainmemory.readbyte(Game.Memory.screen_x_tile);
	local pixelMajor = mainmemory.readbyte(Game.Memory.screen_x_pixel_major);
	local pixel = mainmemory.readbyte(Game.Memory.screen_x_pixel);
	return pixelMajor * 256 + pixel;
end

function Game.getPlayerXPosition()
	return Game.xCoordToScreenSpace(Game.read_u88(Game.Memory.player_x_position));
end

function Game.getPlayerYPosition()
	return Game.yCoordToScreenSpace(Game.read_u88(Game.Memory.player_y_position));
end

function Game.getXPosition()
	return Game.getScreenXPosition() + Game.getPlayerXPosition();
end

function Game.getYPosition()
	return Game.getPlayerYPosition();
end

function Game.getXVelocity()
	return Game.scaleCoord(Game.read_s88(Game.Memory.player_x_velocity));
end

function Game.getYVelocity()
	return Game.scaleCoord(Game.read_s88(Game.Memory.player_y_velocity));
end

function Game.getVitality()
	return Game.read_u88(Game.Memory.vitality);
end

function Game.getBossHP()
	return mainmemory.readbyte(Game.Memory.boss_hp);
end

function Game.getHitboxes()
	local hitboxes = {};
	for base = 0x220, 0xA00, 0x20 do
		local objectType = mainmemory.readbyte(base);
		if true then
			local hitbox = {
				base = base,
				dragTag = base,
				rawX = Game.read_u88(base + object_fields.x_position),
				rawY = Game.read_u88(base + object_fields.y_position),
				objectType = "Unknown",
			};
			-- Don't add null objects
			-- TODO: Better detection for this, it's possible that this is a valid position, so we'd need to detect with some kind of object type byte
			if hitbox.rawX > 0 and hitbox.rawY > 0 then
				-- Transform object position to screen space
				hitbox.x = Game.xCoordToScreenSpace(hitbox.rawX);
				hitbox.y = Game.yCoordToScreenSpace(hitbox.rawY);

				--[[
				local objectTypeTable = object_fields.object_types[objectType];
				if objectTypeTable ~= nil then
					hitbox.objectType = objectTypeTable.name or hitbox.objectType;
					hitbox.width = objectTypeTable.width;
					hitbox.height = objectTypeTable.height;
					hitbox.xOffset = objectTypeTable.xOffset;
					hitbox.yOffset = objectTypeTable.yOffset;
					hitbox.color = objectTypeTable.color;
				end
				--]]

				table.insert(hitboxes, hitbox);
			end
		end
	end
	return hitboxes;
end

function Game.setHitboxPosition(hitbox, x, y)
	-- Transform new X and Y coordinates back to object space
	x = Game.xCoordToObjectSpace(x);
	y = Game.yCoordToObjectSpace(y);
	-- Write position values
	mainmemory.write_u16_le(hitbox.base + object_fields.x_position, x * 256);
	mainmemory.write_u16_le(hitbox.base + object_fields.y_position, y * 256);
	-- Null velocity too
	mainmemory.write_s16_le(hitbox.base + object_fields.x_velocity, 0);
	mainmemory.write_s16_le(hitbox.base + object_fields.y_velocity, 0);
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
	if not Game.inScoreScreen() then
		-- 0xFF Causes death on picking up fruit
		-- 0x7F Causes annoyingly long score screens
		-- 0x10 Causes only 15 segments to show in UI
		mainmemory.writebyte(Game.Memory.vitality + 1, 0x11);
	end
end

function Game.hasAxe()
	return mainmemory.readbyte(Game.Memory.has_axe) > 0;
end

function Game.giveAxe()
	mainmemory.writebyte(Game.Memory.has_axe, 1);
end

local previousVitality = 0;
local currentVitality = 0;
function Game.eachFrame()
	previousVitality = currentVitality;
	currentVitality = Game.getVitality();
end

function Game.colorDX()
	if not Game.inScoreScreen() then
		if previousVitality == currentVitality then
			local dX = math.abs(ScriptHawk.getDX());
			local xVel = math.abs(Game.getXVelocity());

			if xVel > 0 and dX == 0 then
				return colors.red;
			end
		end
	end
end

function Game.colorDY()
	if not Game.inScoreScreen() then
		if previousVitality == currentVitality then
			local dY = math.abs(ScriptHawk.getDY());
			local yVel = math.abs(Game.getYVelocity());

			if yVel > 0.3 and dY == 0 then
				return colors.red;
			end
		end
	end
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.button(10, 4, {4, 10}, nil, nil, "Give Axe", Game.giveAxe);
	end
end

Game.OSD = {
	{"Level", Game.getLevel, category="general"},
	{"Vitality", Game.getVitality, category="general"},
	{"Has Axe", Game.hasAxe, category="general"},
	{"Screen X", Game.getScreenXPosition, category="position"},
	{"X", category="position"},
	{"Y", category="position"},
	{"dX", nil, Game.colorDX, category="positionStats"},
	{"dY", nil, Game.colorDY, category="positionStats"},
	{"X Velocity", Game.getXVelocity, Game.colorDX, category="speed"},
	{"Y Velocity", Game.getYVelocity, Game.colorDY, category="speed"},
	{"Boss HP", Game.getBossHP, category="general"},
};

return Game;