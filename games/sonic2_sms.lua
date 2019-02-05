if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		x_position = 0x1510, -- sub, min, maj
		y_position = 0x1513, -- sub, min, maj
		x_velocity = 0x1516, -- 2 byte
		y_velocity = 0x1518, -- 2 byte
	},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
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

function Game.read_u16_8_hex(base)
	return toHexString(mainmemory.read_u16_le(base + 1), 4, "").."."..toHexString(mainmemory.readbyte(base), 2, "");
end

function Game.read_u8_8_hex(base)
	return toHexString(mainmemory.readbyte(base + 1), 2, "").."."..toHexString(mainmemory.readbyte(base), 2, "");
end

function Game.write_u16_8(base, value)
	local major = math.floor(value);
	local sub = value - major;
	mainmemory.writebyte(base, sub * 256);
	mainmemory.write_u16_le(base + 1, major);
end

function Game.getXPosition()
	return Game.read_u16_8(Game.Memory.x_position);
end

function Game.getYPosition()
	return Game.read_u16_8(Game.Memory.y_position);
end

function Game.getXPositionHex()
	return Game.read_u16_8_hex(Game.Memory.x_position);
end

function Game.getYPositionHex()
	return Game.read_u16_8_hex(Game.Memory.y_position);
end

function Game.setXPosition(value)
	return Game.write_u16_8(Game.Memory.x_position, value);
end

function Game.setYPosition(value)
	return Game.write_u16_8(Game.Memory.y_position, value);
end

function Game.getXVelocity()
	return mainmemory.read_s16_le(Game.Memory.x_velocity) / 256;
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(Game.Memory.y_velocity) / 256;
end

function Game.getXVelocityHex()
	return Game.read_u8_8_hex(Game.Memory.x_velocity);
end

function Game.getYVelocityHex()
	return Game.read_u8_8_hex(Game.Memory.y_velocity);
end

function Game.colorDX()
	local dX = ScriptHawk.getDX();
	local xVelocity = Game.getXVelocity();
	if dX == 0 and math.abs(xVelocity) > 0 then
		return colors.red;
	end
end

function Game.colorDY()
	local dY = ScriptHawk.getDY();
	local yVelocity = Game.getYVelocity();
	if dY == 0 and math.abs(yVelocity) > 0 then
		return colors.red;
	end
end

Game.OSD = {
	--{"Level", Game.getLevel, category="mapData"},
	--{"IGT", Game.getIGT, category="igt"},
	--{"Lives", Game.getLives, category="lives"},
	--{"Rings", hexifyOSD(Game.getRings, nil, ""), category="rings"},
	--{"Viewport X", Game.getViewportX, category="screenPosition"},
	--{"Viewport Y", Game.getViewportY, category="screenPosition"},
	--{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"X Velocity", Game.getXVelocity, category="speed"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"dX", nil, Game.colorDX, category="positionStats"},
	{"dY", nil, Game.colorDY, category="positionStats"},
	{"Separator"},
	{"X (Hex)", Game.getXPositionHex, category="position"},
	{"Y (Hex)", Game.getYPositionHex, category="position"},
	{"X Velocity (Hex)", Game.getXVelocityHex, category="speed"},
	{"Y Velocity (Hex)", Game.getYVelocityHex, category="speed"},
	{"Separator"},
	--{"Speed Shoes", Game.getSpeedShoesTimer},
	--{"Invuln.", Game.getInvulnerabilityTimer},
};

return Game;