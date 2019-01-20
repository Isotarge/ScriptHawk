if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		RNG = 0x8B,
		x_position = 0x91, x_position_sub = 0x92,
		y_position = 0x95, y_position_sub = 0x94,
		x_velocity = 0x98, x_velocity_sub = 0x99,
		y_velocity = 0x9C, y_velocity_sub = 0x9D,
		current_boost = 0xA9,
		current_boost_sub = 0xAA,
		buttons_this_frame = 0xC7,
		buttons_last_frame = 0xC8,
		screen_x_position_super = 0xCD, screen_x_position = 0xCC,
		screen_y_position_super = 0xCF, screen_y_position = 0xCE,
		timer = 0xEA,
		--0x01 = Title screen
		--0x02 = Title screen idle animation
		--0x03 = Title screen -> First level
		--0x04 = Filler/between screens
		--0x05 = Playable level
		screen_mode = 0xEC,
		bomb_timer1 = 0x4D7,
		bomb_timer2 = 0x4D8,
		tile_value = 0x615,
		frames = 0x61A,
		money = 0x61E,
		hp = 0x62C,
		lives = 0x62D,
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

function Game.read_u16_8(super, major, sub)
	super = mainmemory.read_u8(super) * 256;
	major = mainmemory.read_u8(major);
	sub = mainmemory.read_u8(sub) / 256;
	return super + major + sub;
end

function Game.read_s16_8(super, major, sub)
	super = mainmemory.read_s8(super) * 256;
	major = mainmemory.read_u8(major);
	sub = mainmemory.read_u8(sub) / 256;
	return super + major + sub;
end

function Game.write_u16_8(super, major, sub, value)
	local majorValue = math.floor(value);
	local superValue = math.floor(majorValue / 256);
	local subValue = (value - majorValue) * 256;

	mainmemory.write_u8(super, superValue);
	mainmemory.write_u8(major, majorValue % 256);
	mainmemory.write_u8(sub, subValue);
end

function Game.write_s16_8(super, major, sub, value)
	local majorValue = math.floor(value);
	local superValue = math.floor(majorValue / 256);
	local subValue = (value - majorValue) * 256;

	mainmemory.write_s8(super, superValue);
	mainmemory.write_u8(major, majorValue % 256);
	mainmemory.write_u8(sub, subValue);
end

function Game.read_s88(major, sub)
	major = mainmemory.read_s8(major);
	sub = mainmemory.read_u8(sub) / 256;
	return major + sub;
end

function Game.write_s88(major, sub, value)
	local majorValue = math.floor(value);
	local subValue = (value - majorValue) * 256;
	mainmemory.write_s8(major, majorValue);
	mainmemory.write_u8(sub, subValue);
end

function Game.getIGT()
	local superSecs = mainmemory.read_u8(Game.Memory.timer + 1) * 256;
	local secs = mainmemory.read_u8(Game.Memory.timer);
	local frames = mainmemory.read_u8(Game.Memory.frames);
	return (superSecs + secs).."."..frames;
end

function Game.getHP()
	return mainmemory.read_u8(Game.Memory.hp);
end

function Game.getScreenXPosition()
	local super = mainmemory.read_u8(Game.Memory.screen_x_position_super) * 256;
	local major = mainmemory.read_u8(Game.Memory.screen_x_position);
	return super + major;
end

function Game.getScreenYPosition()
	local super = mainmemory.read_u8(Game.Memory.screen_y_position_super) * 256;
	local major = mainmemory.read_u8(Game.Memory.screen_y_position);
	return super + major;
end

function Game.getPlayerXPosition()
	return Game.read_s88(Game.Memory.x_position, Game.Memory.x_position_sub);
end

function Game.getPlayerYPosition()
	return Game.read_s88(Game.Memory.y_position, Game.Memory.y_position_sub);
end

function Game.getXPosition()
	local screenPos = Game.getScreenXPosition();
	local playerPos = Game.getPlayerXPosition();
	return screenPos + playerPos;
end

function Game.getYPosition()
	local screenPos = Game.getScreenYPosition();
	local playerPos = Game.getPlayerYPosition();
	return screenPos + playerPos;
end

function Game.getXVelocity()
	return Game.read_s88(Game.Memory.x_velocity, Game.Memory.x_velocity_sub);
end

function Game.getYVelocity()
	return Game.read_s88(Game.Memory.y_velocity, Game.Memory.x_velocity_sub);
end

function Game.getCurrentBoost()
	return Game.read_s88(Game.Memory.current_boost, Game.Memory.current_boost_sub);
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

local object_array_capacity = 8;
local object_fields = {
	--0x00 = Slot empty
	--0x02 = Enemy is on screen
	--0x03 = Enemy is off screen
	on_screen = 0x4F3, -- u8
	x_position_super = 0x543, -- s8
	x_position = 0x54B, -- u8
	x_position_sub = 0x553, -- / 256
	y_position_super = 0x55B, -- s8
	y_position = 0x563, -- u8
	y_position_sub = 0x56B, -- / 256
	hitbox_h = 0x573, -- u8, add 0x07
	hitbox_w = 0x57B, -- u8, add 0x0F
	x_velocity = 0x583, -- s8
	x_velocity_sub = 0x58B, -- / 256
	y_velocity = 0x593, -- s8
	y_velocity_sub = 0x59B, -- / 256
};

function Game.getHitboxes()
	local hitboxes = {};

	-- Shift all hitboxes with the camera
	ScriptHawk.hitboxDefaultXOffset = -Game.getScreenXPosition();
	ScriptHawk.hitboxDefaultYOffset = -Game.getScreenYPosition();

	for i = 0, object_array_capacity do
		local onScreen = mainmemory.readbyte(object_fields.on_screen + i);
		if onScreen ~= 0 then
			table.insert(hitboxes, {
				index = i + 1,
				dragTag = i + 1,
				xPosAddressSuper = object_fields.x_position_super + i,
				xPosAddress = object_fields.x_position + i,
				xPosAddressSub = object_fields.x_position_sub + i,
				yPosAddressSuper = object_fields.y_position_super + i,
				yPosAddress = object_fields.y_position + i,
				yPosAddressSub = object_fields.y_position_sub + i,
				xVelAddress = object_fields.x_velocity + i,
				xVelAddressSub = object_fields.x_velocity_sub + i,
				yVelAddress = object_fields.y_velocity + i,
				yVelAddressSub = object_fields.y_velocity_sub + i,
				heightAddress = object_fields.hitbox_h + i,
				widthAddress = object_fields.hitbox_w + i,
				onScreen = onScreen,
			});
		end
	end

	for i = 1, #hitboxes do
		local hitbox = hitboxes[i];
		hitbox.type = "Unknown"; -- TODO: Identify enemies etc
		hitbox.x = Game.read_s16_8(hitbox.xPosAddressSuper, hitbox.xPosAddress, hitbox.xPosAddressSub);
		hitbox.y = Game.read_s16_8(hitbox.yPosAddressSuper, hitbox.yPosAddress, hitbox.yPosAddressSub);
		hitbox.xVelocity = Game.read_s88(hitbox.xVelAddress, hitbox.xVelAddressSub);
		hitbox.yVelocity = Game.read_s88(hitbox.xVelAddress, hitbox.yVelAddressSub);
		hitbox.height = mainmemory.readbyte(hitbox.heightAddress) + 0x07;
		hitbox.width = mainmemory.readbyte(hitbox.widthAddress) + 0x0F;
	end
	return hitboxes;
end

function Game.getHitboxMouseOverText(hitbox)
	return {
		hitbox.type,
		hitbox.index..": "..round(hitbox.x, precision)..","..round(hitbox.y, precision),
	};
end

function Game.getHitboxListText(hitbox)
	return hitbox.index..": "..round(hitbox.x, precision)..","..round(hitbox.y, precision);
end

function Game.setHitboxPosition(hitbox, x, y)
	Game.write_s16_8(hitbox.xPosAddressSuper, hitbox.xPosAddress, hitbox.xPosAddressSub, x);
	Game.write_s16_8(hitbox.yPosAddressSuper, hitbox.yPosAddress, hitbox.yPosAddressSub, y);
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
	{"Player Y", Game.getPlayerYPosition},
	{"Separator"},
	{"Screen X", Game.getScreenXPosition},
	{"Screen Y", Game.getScreenYPosition},
	{"Separator"},
	{"X"},
	{"Y"},
	{"Separator"},
	{"dX", nil, Game.colorDX},
	{"dY", nil, Game.colorDY},
	{"Separator"},
	{"Current Boost", Game.getCurrentBoost},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"Separator"},
	{"Bomb Timer 1", Game.getBombTimer1},
	{"Bomb Timer 2", Game.getBombTimer2},
	{"Separator"},
	{"Tile Value", hexifyOSD(Game.getTileValue)},
};

return Game;