if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		timer = 0xEA,
		frames = 0x61A,
		screen_x_position = 0xCC,
		-- Screen does not move in Y direction
		x_position = 0x91, -- 0x92 is sub
		y_position = 0x95, -- 0x94 is sub
		x_velocity = 0x98, -- 0x99 is sub
		y_velocity = 0x9C, -- 0x9C is sub
		money = 0x61E,
		hp = 0x62C,
		lives = 0x62D,
		bomb_timer1 = 0x4D7,
		bomb_timer2 = 0x4D8,
        tile_value = 0x0615,
	},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultMode = ScriptHawk.hitboxModeWHCentered;
	ScriptHawk.hitboxDefaultColor = colors.white;
	ScriptHawk.hitboxDefaultXOffset = 0;
	ScriptHawk.hitboxDefaultYOffset = 0;
	ScriptHawk.hitboxDefaultWidth = 16;
	ScriptHawk.hitboxDefaultHeight = 16;
	return true;
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.money, 99);
	mainmemory.writebyte(Game.Memory.lives, 99);
	mainmemory.writebyte(Game.Memory.hp, 5);
	-- Don't set IGT if the level is finished
	if mainmemory.readbyte(Game.Memory.frames) ~= 0xFF then
		mainmemory.writebyte(Game.Memory.timer, 0xE7);
		mainmemory.writebyte(Game.Memory.timer + 1, 0x3);
	end
end

function Game.read_s88(address)
	local major = mainmemory.read_s8(address);
	local minor = mainmemory.readbyte(address + 1);
	return major + (minor / 256);
end

function Game.getIGT()
	local superSecs = mainmemory.readbyte(Game.Memory.timer + 1) * 256;
	local secs = mainmemory.readbyte(Game.Memory.timer);
	local frames = mainmemory.readbyte(Game.Memory.frames);
	return (superSecs + secs).."."..frames;
end

function Game.getHP()
	return mainmemory.readbyte(Game.Memory.hp);
end

function Game.getScreenXPosition()
	local superMajor = mainmemory.readbyte(Game.Memory.screen_x_position + 1);
	local major = mainmemory.readbyte(Game.Memory.screen_x_position);
	return (superMajor * 256) + major;
end

function Game.getPlayerXPosition()
	return Game.read_s88(Game.Memory.x_position);
end

function Game.getXPosition()
	local screenPos = Game.getScreenXPosition();
	local playerPos = Game.getPlayerXPosition();
	return screenPos + playerPos;
end

function Game.getYPosition()
	local major = mainmemory.readbyte(Game.Memory.y_position);
	local minor = mainmemory.readbyte(Game.Memory.y_position - 1);
	return major + (minor / 256);
end

function Game.getXVelocity()
	return Game.read_s88(Game.Memory.x_velocity);
end

function Game.getYVelocity()
	return Game.read_s88(Game.Memory.y_velocity);
end

function Game.getBombTimer1()
	return mainmemory.readbyte(Game.Memory.bomb_timer1);
end

function Game.getBombTimer2()
	return mainmemory.readbyte(Game.Memory.bomb_timer2);
end

function Game.getTileValue()
    return mainmemory.readbyte(Game.Memory.tile_value);
end

--[[
Definitely Object X Positions:
0x550
0x551 apple
0x552 apple 2

Definitely Object Y Positions:
0x568
0x569 apple
0x56A apple 2
--]]

object_array_capacity = 12;
object_fields = {
	x_position_super = 0x542, -- s8 - Super major
	x_position = 0x54A, -- u8 - Major
	y_position = 0x562,
	object_type = 0, -- TODO
	object_types = {
		-- TODO
	},
};

function Game.getHitboxes()
	local hitboxes = {};

	ScriptHawk.hitboxDefaultXOffset = -Game.getScreenXPosition();

	for i = 0, object_array_capacity do
		table.insert(hitboxes, {
			xPosAddressSuper = object_fields.x_position_super + i,
			xPosAddress = object_fields.x_position + i,
			yPosAddress = object_fields.y_position + i,
			typeValue = mainmemory.readbyte(object_fields.object_type + i),
		});
	end

	for i = 1, #hitboxes do
		local hitbox = hitboxes[i];
		hitbox.type = "Unknown ("..toHexString(hitbox.typeValue)..")";
		hitbox.x = mainmemory.read_s8(hitbox.xPosAddressSuper) * 256 + mainmemory.read_u8(hitbox.xPosAddress);
		hitbox.y = mainmemory.read_u8(hitbox.yPosAddress);
		hitbox.index = i;
		hitbox.dragTag = i;

		if type(object_fields.object_types[hitbox.typeValue]) == "table" then
			local objectTypeTable = object_fields.object_types[hitbox.typeValue];
			hitbox.color = objectTypeTable.color;
			hitbox.xOffset = objectTypeTable.hitbox_x_offset;
			hitbox.yOffset = objectTypeTable.hitbox_y_offset;
			hitbox.width = objectTypeTable.hitbox_width;
			hitbox.height = objectTypeTable.hitbox_height;

			if type(objectTypeTable.name) == "string" then
				hitbox.type = object_fields.object_types[hitbox.typeValue].name.." "..toHexString(hitbox.typeValue);
			end
		end
	end
	return hitboxes;
end

function Game.getHitboxMouseOverText(hitbox)
	return {
		hitbox.type,
		hitbox.index..": "..hitbox.x..","..hitbox.y,
	};
end

function Game.getHitboxListText(hitbox)
	return hitbox.index..": "..hitbox.x..","..hitbox.y;
end

function Game.setHitboxPosition(hitbox, x, y)
	mainmemory.write_u8(hitbox.xPosAddress, x);
	mainmemory.write_u8(hitbox.yPosAddress, y);
end

function Game.colorDX()
	local dX = math.abs(ScriptHawk.getDX());
	local xVelocity = math.abs(Game.getXVelocity());
	if dX == 0 then
		return colors.red;
	elseif dX > xVelocity then
		return colors.green;
	end
end

function Game.colorDY()
	local dY = math.abs(ScriptHawk.getDY());
	local yVelocity = math.abs(Game.getYVelocity());
	if dY == 0 then
		return colors.red;
	elseif dY > yVelocity then
		return colors.green;
	end
end

Game.OSD = {
	{"IGT", Game.getIGT},
	{"Separator"},
	{"Player X", Game.getPlayerXPosition},
	{"Screen X", Game.getScreenXPosition},
	--{"Separator"},
	{"X"},
	{"Y"},
	{"Separator"},
	{"dX", nil, Game.colorDX},
	{"dY", nil, Game.colorDY},
	{"Separator"},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"Separator"},
	{"Bomb Timer 1", Game.getBombTimer1},
	{"Bomb Timer 2", Game.getBombTimer2},
    {"Separator"},
    {"Tile Value", Game.getTileValue},
};

return Game;