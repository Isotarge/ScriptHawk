if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		round = 0x20,
		screen_x = 0x22,
		screen_y = 0x24,
		lives = 0x16,
		straw_effigies = 0x18,
		money_bags = 0x19,
		psycho_sticks = 0x1A,
		magic_medicine = 0x1B,
		x_position = 0x30, -- 3 byte sub.minor.major
		y_position = 0x33, -- 3 byte sub.minor.major
		x_velocity = 0x204, -- signed fixed point 8.8 little endian
		y_velocity = 0x206, -- signed fixed point 8.8 little endian
		jump_x_velocity = 0x208, -- signed fixed point 8.8 little endian
	},
	max_velocity = 2.5,
	maps = {
		"1-1", -- 0x00
		"1-2",
		"1-3",
		"2-1",
		"2-2",
		"2-3",
		"3-1",
		"3-2",
		"3-3",
		"4-1",
		"4-2",
		"4-3",
		"5-1",
		"5-2",
		"5-3",
		"6-1",
		"6-2", -- 0x10
		"6-3",
		"7-1",
		"7-2",
		"7-3",
		"Warp Entry",
	},
};

function Game.setMap(value)
	mainmemory.writebyte(Game.Memory.round, value - 1);
end

function Game.readPosition(base)
	local sub = mainmemory.readbyte(base + 0);
	local minor = mainmemory.readbyte(base + 1);
	local major = mainmemory.readbyte(base + 2);
	return (major * 256) + minor + (sub / 256);
end

function Game.writePosition(base, value)
	local flooredValue = math.floor(value);
	local remainder = value - flooredValue;

	local sub = remainder * 256;
	local minor = flooredValue % 256;
	local major = math.floor(flooredValue / 256);

	mainmemory.writebyte(base + 0, sub);
	mainmemory.writebyte(base + 1, minor);
	mainmemory.writebyte(base + 2, major);
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.lives, 9);
	mainmemory.writebyte(Game.Memory.straw_effigies, 9);
	mainmemory.writebyte(Game.Memory.money_bags, 9);
	mainmemory.writebyte(Game.Memory.psycho_sticks, 9);
	mainmemory.writebyte(Game.Memory.magic_medicine, 9);
end

function Game.fixAcceleration()
	local inputs = joypad.get();
	if inputs['P1 Left'] or inputs['P1 Right'] then
		Game.setXVelocity(Game.max_velocity);
		Game.setJumpXVelocity(Game.max_velocity);
	else
		Game.setXVelocity(0);
		Game.setJumpXVelocity(0);
	end
end

function Game.getLives()
	return mainmemory.readbyte(Game.Memory.lives);
end

function Game.getRound()
	local round = mainmemory.readbyte(Game.Memory.round);
	return Game.maps[round + 1] or "Unknown "..toHexString(round);
end

function Game.getScreenXPosition()
	return mainmemory.read_u16_le(Game.Memory.screen_x);
end

function Game.getScreenYPosition()
	return mainmemory.read_u16_le(Game.Memory.screen_y);
end

function Game.getXPosition()
	return Game.readPosition(Game.Memory.x_position);
end

function Game.getYPosition()
	return Game.readPosition(Game.Memory.y_position);
end

function Game.setXPosition(value)
	return Game.writePosition(Game.Memory.x_position, value);
end

function Game.setYPosition(value)
	return Game.writePosition(Game.Memory.y_position, value);
end

function Game.getXVelocity()
	return mainmemory.read_s16_le(Game.Memory.x_velocity) / 256;
end

function Game.setXVelocity(value)
	mainmemory.write_s16_le(Game.Memory.x_velocity, value * 256);
end

function Game.getJumpXVelocity()
	return mainmemory.read_s16_le(Game.Memory.jump_x_velocity) / 256;
end

function Game.setJumpXVelocity(value)
	mainmemory.write_s16_le(Game.Memory.jump_x_velocity, value * 256);
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(Game.Memory.y_velocity) / 256;
end

function Game.eachFrame()
	if ScriptHawk.UI.ischecked("Fix Acceleration Checkbox") then
		Game.fixAcceleration();
	end
end

function Game.initUI()
	ScriptHawk.UI.checkbox(0, 6, "Fix Acceleration Checkbox", "Fix Acceleration");
end

-------------
-- Enemies --
-------------

local enemy_array = 0xB00;
local enemy_array_capacity = 10;
local enemy_size = 0x20;

local enemy = {
	x = 0x02,
	y = 0x04,
};

function Game.getHitboxes()
	local screenX = mainmemory.read_u16_le(Game.Memory.screen_x);
	local screenY = mainmemory.read_u16_le(Game.Memory.screen_y);
	ScriptHawk.hitboxDefaultXOffset = -screenX;
	ScriptHawk.hitboxDefaultYOffset = -screenY;

	local hitboxes = {};
	for base = enemy_array, enemy_array + enemy_array_capacity * enemy_size, enemy_size do
		local enemyType = mainmemory.readbyte(base);
		if enemyType ~= 0 then
			local hitbox = {
				base = base,
				dragTag = base,
				enemyType = enemyType,
				x = mainmemory.read_u16_le(base + enemy.x),
				y = mainmemory.read_u16_le(base + enemy.y),
				width = 16,
				height = 16,
				isPlayer = false,
			};
			table.insert(hitboxes, hitbox);
		end
	end

	local playerHitbox = {
		dragTag = "Player",
		x = Game.getXPosition(),
		y = Game.getYPosition(),
		width = 16,
		height = 16,
		isPlayer = true,
	};
	table.insert(hitboxes, playerHitbox);

	return hitboxes;
end

function Game.setHitboxPosition(hitbox, x, y)
	if hitbox.isPlayer then
		Game.setXPosition(x);
		Game.setYPosition(y);
	else
		mainmemory.write_u16_le(hitbox.base + enemy.x, x);
		mainmemory.write_u16_le(hitbox.base + enemy.y, y);
	end
end

function Game.getHitboxStaticText(hitbox)
	if not hitbox.isPlayer then
		return hitbox.enemyType;
	end
end

function Game.getHitboxMouseOverText(hitbox)
	if not hitbox.isPlayer then
		return hitbox.enemyType;
	end
end

Game.OSD = {
	{"Round", Game.getRound, category="round"},
	{"Lives", Game.getLives, category="lives"},
	{"Separator"},
	{"Screen X", Game.getScreenXPosition, category="screenPosition"},
	{"Screen Y", Game.getScreenYPosition, category="screenPosition"},
	{"X", category="position"},
	{"Y", category="position"},
	{"X Velocity", Game.getXVelocity, category="speed"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"dX", category="positionStats"},
	{"dY", category="positionStats"},
};

return Game;