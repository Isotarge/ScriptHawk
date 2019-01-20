if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	squish_memory_table = true,
	Memory = { -- Order: SMS/GG (Proto), GG
		in_score_screen = {0x1207, 0x0000}, -- TODO: GG
		level = {0x123E, 0x1238},
		rings = {0x12AA, 0x12A9}, -- byte, BCD
		lives = {0x1246, 0x1240},
		level_width = {0x1238, 0x0000}, -- TODO: GG -- width of the floor layout in blocks
		level_height = {0x123A, 0x0000}, -- TODO: GG -- height of the floor layout in blocks
		viewport_x = {0x125A, 0x1254},
		viewport_x2 = {0x126F, 0x0000}, -- TODO: GG
		viewport_y = {0x125D, 0x1257},
		viewport_y2 = {0x1271, 0x0000}, -- TODO: GG
		x_position = {0x13FD, 0x13FE}, -- 3 bytes sub.min.maj
		y_position = {0x1400, 0x1401}, -- 3 bytes sub.min.maj
		x_velocity = {0x1403, 0x1404}, -- 3 bytes sub.min.maj
		y_velocity = {0x1406, 0x1407}, -- 3 bytes sub.min.maj
		igt = {0x12CE, 0x12CF}, -- 3 bytes: min(BCD):sec(BCD).frame
		invuln_timer = {0x128D, 0x1287},
		speed_shoes_timer = {0x1411, 0x1412},
		object_array_base = {0x13FC, 0x13FD},
		ring_mod_10_timer = {0x1298, 0x0000}, -- TODO: GG
		cycle_pallete_speed = {0x12A4, 0x0000}, -- TODO: GG
	},
	maps = {
		"Green Hill 1", -- 0x00
		"Green Hill 2",
		"Green Hill 3",
		"Bridge 1",
		"Bridge 2",
		"Bridge 3",
		"Jungle 1",
		"Jungle 2",
		"Jungle 3",
		"Labyrinth 1",
		"Labyrinth 2",
		"Labyrinth 3",
		"Scrap Brain 1",
		"Scrap Brain 2",
		"Scrap Brain 3",
		"Sky Base 1",
		"Sky Base 2", -- 0x10
		"Sky Base 3",
		"Ending",
		"Ending (Part 2)",
		"Scrap Brain (Room 1)",
		"Scrap Brian (Room 2)",
		"Scrap Brain (Room 3)",
		"Scrap Brain (Room 4)",
		"Scrap Brain (Room 5)",
		"Scrap Brain (Room 6)",
		"Sky Base 2 (Interior)",
		"Sky Base 2 (Interior)",
		"Special Stage 1",
		"Special Stage 2",
		"Special Stage 3",
		"Special Stage 4",
		"Special Stage 5", -- 0x20
		"Special Stage 6",
		"Special Stage 7",
		"Special Stage 8",
		"Credits",
	},
	solidityBankSwitchCycles = 0,
	solidityDataReadCycles = 0,
	IRQStartCycles = 0,
	minimumGlitchCycleOffset = math.huge,
};

function Game.setMap(value)
	mainmemory.writebyte(Game.Memory.level, value - 1);
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

function Game.write_u16_8(base, value)
	local major = math.floor(value);
	local sub = value - major;
	mainmemory.writebyte(base, sub * 256);
	mainmemory.write_u16_le(base + 1, major);
end

function Game.getIGT()
	local mins = mainmemory.readbyte(Game.Memory.igt + 0);
	local secs = mainmemory.readbyte(Game.Memory.igt + 1);
	local frames = mainmemory.readbyte(Game.Memory.igt + 2);
	return toHexString(mins, 1, "")..":"..toHexString(secs, 2, "").."."..string.lpad(frames, 2, '0');
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxListShowCount = true;
	ScriptHawk.hitboxDefaultColor = colors.white;
	return true;
end

function Game.applyInfinites()
	if bit.band(mainmemory.readbyte(Game.Memory.in_score_screen), 0x01) == 0 then
		mainmemory.writebyte(Game.Memory.lives, 99);
		mainmemory.writebyte(Game.Memory.rings, 0x1);
	end
end

function Game.getLives()
	return mainmemory.readbyte(Game.Memory.lives);
end

function Game.getRings()
	return mainmemory.readbyte(Game.Memory.rings);
end

function Game.getRingMod10Timer()
	return mainmemory.readbyte(Game.Memory.ring_mod_10_timer);
end

function Game.getCyclePalleteSpeed()
	return mainmemory.readbyte(Game.Memory.cycle_pallete_speed);
end

function Game.getSpeedShoesTimer()
	return mainmemory.readbyte(Game.Memory.speed_shoes_timer);
end

function Game.getInvulnerabilityTimer()
	return mainmemory.readbyte(Game.Memory.invuln_timer);
end

function Game.getLevel()
	local level = mainmemory.readbyte(Game.Memory.level);
	return Game.maps[level + 1] or "Unknown "..toHexString(level);
end

function Game.getViewportX()
	return mainmemory.read_u16_le(Game.Memory.viewport_x);
end

function Game.getViewportY()
	return mainmemory.read_u16_le(Game.Memory.viewport_y);
end

function Game.getXPosition()
	return Game.read_u16_8(Game.Memory.x_position);
end

function Game.getYPosition()
	return Game.read_u16_8(Game.Memory.y_position);
end

function Game.getXVelocity()
	return Game.read_s16_8(Game.Memory.x_velocity);
end

function Game.getYVelocity()
	return Game.read_s16_8(Game.Memory.y_velocity);
end

function Game.getXVelocityHex()
	return toHexString(mainmemory.read_u16_le(Game.Memory.x_velocity + 1), 4, "").."."..toHexString(mainmemory.readbyte(Game.Memory.x_velocity), 2, "");
end

function Game.getYVelocityHex()
	return toHexString(mainmemory.read_u16_le(Game.Memory.y_velocity + 1), 4, "").."."..toHexString(mainmemory.readbyte(Game.Memory.y_velocity), 2, "");
end

function Game.read_s16_8(base)
	local major = mainmemory.read_s16_le(base + 1);
	local sub = mainmemory.readbyte(base) / 256;
	return major + sub;
end

function Game.camHack()
	local playerX = Game.getXPosition();
	local playerY = Game.getYPosition();
	local adjustedXPosition = math.max(0, playerX + -128);
	local adjustedYPosition = math.max(0, playerY + -75);
	mainmemory.write_u16_le(Game.Memory.viewport_x, adjustedXPosition);
	--mainmemory.write_u16_le(Game.Memory.viewport_x2, adjustedXPosition);
	mainmemory.write_u16_le(Game.Memory.viewport_y, adjustedYPosition);
	--mainmemory.write_u16_le(Game.Memory.viewport_y2, adjustedYPosition);
end

function Game.eachFrame()
	if ScriptHawk.UI.ischecked("CamHack Checkbox") then
		Game.camHack();
	end
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.checkbox(0, 6, "CamHack Checkbox", "CamHack (Beta)");
	end
end

local object_fields = {
	type = 0x00,
	types = {
		[0x00] = {color=colors.white, name="Sonic"},
		[0x01] = {color=colors.pink, name="Monitor (Ring)"},
		[0x02] = {color=colors.pink, name="Monitor (Speed Shoes)"},
		[0x03] = {color=colors.pink, name="Monitor (Life)"},
		[0x04] = {color=colors.pink, name="Monitor (Shield)"},
		[0x05] = {color=colors.pink, name="Monitor (Invincibility)"},
		[0x06] = {color=colors.pink, name="Chaos Emerald"},
		[0x07] = {color=colors.white, name="End Sign"},
		[0x08] = {color=colors.red, name="Crabmeat"}, -- Badnick
		[0x09] = {color=colors.white, name="Wooden Platform (Swinging)"}, -- Green Hill
		[0x0A] = {color=colors.yellow, name="Explosion"},
		[0x0B] = {color=colors.white, name="Wooden Platform"}, -- Green Hill
		[0x0C] = {color=colors.white, name="Wooden Platform (Falling)"}, -- Green Hill
		--[0x0D] = {color=colors.white, name="UNKNOWN"},
		[0x0E] = {color=colors.red, name="Buzz Bomber"}, -- Badnick
		[0x0F] = {color=colors.white, name="Wooden Platform (Moving)"}, -- Green Hill
		[0x10] = {color=colors.red, name="Motobug"}, -- Badnick
		[0x11] = {color=colors.red, name="Newtron"}, -- Badnick
		[0x12] = {color=colors.red, name="Robotnik"}, -- Green Hill
		--[0x13] = {color=colors.yellow, name="UNKNOWN - Bullet?"},
		--[0x14] = {color=colors.yellow, name="UNKNOWN - Fireball Right?"},
		--[0x15] = {color=colors.yellow, name="UNKNOWN - Fireball Left?"},
		[0x16] = {color=colors.white, name="Flamethrower"}, -- Scrap Brain
		[0x17] = {color=colors.white, name="Door (Left)"}, -- Scrap Brain
		[0x18] = {color=colors.white, name="Door (Right)"}, -- Scrap Brain
		[0x19] = {color=colors.white, name="Door "}, -- Scrap Brain
		[0x1A] = {color=colors.red, name="Electric Sphere"}, -- Scrap Brain
		[0x1B] = {color=colors.red, name="Ball Hog"}, -- Badnick, Scrap Brain
		--[0x1C] = {color=colors.yellow, name="UNKNOWN - Ball From Ball Hog?"},
		[0x1D] = {color=colors.white, name="Switch"},
		[0x1E] = {color=colors.white, name="Switch door"},
		[0x1F] = {color=colors.red, name="Caterkiller"}, -- Badnick
		--[0x20] = {color=colors.white, name="UNKNOWN"},
		[0x21] = {color=colors.white, name="Moving Bumper"}, -- Special Stage
		[0x22] = {color=colors.white, name="Robotnik"}, -- Scrap Brain
		[0x23] = {color=colors.green, name="Rabbit"}, -- Freed Critter
		[0x24] = {color=colors.green, name="Bird"}, -- Freed Critter
		[0x25] = {color=colors.white, name="Capsule"},
		[0x26] = {color=colors.white, name="Chopper"},  -- Badnick
		[0x27] = {color=colors.white, name="Log (Vertical)"}, -- Jungle
		[0x28] = {color=colors.white, name="Log (Horizontal)"}, -- Jungle
		[0x29] = {color=colors.white, name="Log (Floating)"}, -- Jungle
		--[0x2A] = {color=colors.white, name="UNKNOWN"},
		--[0x2B] = {color=colors.white, name="UNKNOWN"},
		[0x2C] = {color=colors.red, name="Robotnik"}, -- Jungle
		[0x2D] = {color=colors.red, name="Yadrin"}, -- Badnick, Bridge
		[0x2E] = {color=colors.yellow, name="Falling Bridge"}, -- Bridge
		--[0x2F] = {color=colors.white, name="UNKNOWN - Wave Moving Projectile?"},
		[0x30] = {color=colors.white, name="Clouds"}, -- Meta, Sky Base
		[0x31] = {color=colors.white, name="Propeller"}, -- Sky Base
		[0x32] = {color=colors.red, name="Bomb"}, -- Badnick, Sky Base
		[0x33] = {color=colors.yellow, name="Cannon"}, -- Sky Base
		[0x34] = {color=colors.red, name="Cannon Ball"}, -- Sky Base
		[0x35] = {color=colors.red, name="Unidos"}, -- Badnick, Sky Base
		--[0x36] = {color=colors.red, name="UNKNOWN - Stationary, Lethal"},
		[0x37] = {color=colors.white, name="Rotating Turret"}, -- Sky Base
		[0x38] = {color=colors.white, name="Flying Platform"}, -- Sky Base
		[0x39] = {color=colors.white, name="Moving Spiked Wall"}, -- Sky Base
		[0x3A] = {color=colors.white, name="Fixed Turret"}, -- Sky Base
		[0x3B] = {color=colors.white, name="Flying Platform (Up/Down)"}, -- Sky Base
		[0x3C] = {color=colors.red, name="Jaws"}, -- Badnick, Labyrinth
		[0x3D] = {color=colors.red, name="Spike Ball"}, -- Labyrinth
		[0x3E] = {color=colors.red, name="Spear"}, -- Labyrinth
		[0x3F] = {color=colors.red, name="Fire Ball Head"}, -- Labyrinth
		[0x40] = {color=colors.white, name="Water Line Position"}, -- Meta
		[0x41] = {color=colors.white, name="Bubbles"}, -- Labyrinth
		--[0x42] = {color=colors.white, name="UNKNOWN"},
		[0x43] = {color=colors.white, name="Null"}, -- No code
		[0x44] = {color=colors.red, name="Burrobot"}, -- Badnick
		[0x45] = {color=colors.white, name="Platform (Float Up)"}, -- Labyrinth
		[0x46] = {color=colors.red, name="Boss - Electric Beam"}, -- Sky Base
		--[0x47] = {color=colors.white, name="UNKNOWN"},
		[0x48] = {color=colors.red, name="Robotnik"}, -- Bridge
		[0x49] = {color=colors.red, name="Robotnik"}, -- Labyrinth
		[0x4A] = {color=colors.red, name="Robotnik"}, -- Sky Base
		[0x4B] = {color=colors.yellow, name="Trip Zone"}, -- Green Hill
		[0x4C] = {color=colors.white, name="Flipper"}, -- Special Stage
		[0x4D] = {color=colors.white, name="RESET!"},
		[0x4E] = {color=colors.white, name="Balance"}, -- Bridge
		[0x4F] = {color=colors.white, name="RESET!"},
		[0x50] = {color=colors.white, name="Flower"}, -- Green Hill
		[0x51] = {color=colors.pink, name="Monitor (Checkpoint)"},
		[0x52] = {color=colors.pink, name="Monitor (Continue)"},
		[0x53] = {color=colors.white, name="Final Animation"},
		[0x54] = {color=colors.white, name="All Emeralds Animation"},
		[0x55] = {color=colors.white, name="Make Sonic Blink"},
	},
	x_position = 0x01, -- 3 bytes, use Game.read_u16_8
	y_position = 0x04, -- 3 bytes, use Game.read_u16_8
	x_velocity = 0x07, -- 3 bytes, use Game.read_s16_8
	y_velocity = 0x0A, -- 3 bytes, use Game.read_s16_8
	width = 0x0D, -- 1 byte, in pixels
	height = 0x0E, -- 1 byte, in pixels
	sprite_layout = 0x0F, -- 2 bytes, pointer
};

--[[
bridgePieceIndex = 1;
bridgePieces = {
--   type xsub xmin xmaj ysub ymin ymaj xvel xvel xvel yvel yvel yvel wdth hght spr  spr  unk  unk  unk  unk  unk  unk  unk  unk  unk
--   0    1    2    3    4    5    6    7    8    9    a    b    c    d    e    f    10   11   12   13   14   15   16   17   18   19
	{0x2E,0x00,0xA0,0x06,0xA0,0x5F,0x01,0x00,0x00,0x00,0xC0,0x02,0x00,0x0E,0x08,0x81,0x84,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x23,0x00},
	{0x2E,0x00,0xB0,0x06,0xE0,0x6B,0x01,0x00,0x00,0x00,0x40,0x03,0x00,0x0E,0x08,0x81,0x84,0x01,0xD4,0x01,0x00,0xAA,0x06,0x04,0x23,0x00},
	{0x2E,0x00,0xC0,0x06,0x60,0x55,0x01,0x00,0x00,0x00,0x40,0x02,0x00,0x0E,0x08,0x81,0x84,0x01,0xD4,0x01,0x00,0xAA,0x06,0x04,0x23,0x00},
	{0x2E,0x00,0xD0,0x06,0xE0,0x5C,0x01,0x00,0x00,0x00,0xA0,0x02,0x00,0x0E,0x08,0x81,0x84,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x23,0x00},
	{0x2E,0x00,0xE0,0x06,0xA0,0x68,0x01,0x00,0x00,0x00,0x20,0x03,0x00,0x0E,0x08,0x81,0x84,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x23,0x00},
	{0x2E,0x00,0xF0,0x06,0x80,0x65,0x01,0x00,0x00,0x00,0x00,0x03,0x00,0x0E,0x08,0x81,0x84,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x23,0x00},
	{0x2E,0x00,0x00,0x07,0xC0,0x57,0x01,0x00,0x00,0x00,0x60,0x02,0x00,0x0E,0x08,0x81,0x84,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x23,0x00},
	{0x2E,0x00,0x10,0x07,0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x0E,0x08,0x00,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x22,0x00},
	{0x2E,0x00,0x20,0x07,0xC0,0x40,0x01,0x00,0x00,0x00,0x60,0x00,0x00,0x0E,0x08,0x81,0x84,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x23,0x00},
	{0x2E,0x00,0x30,0x07,0xA0,0x42,0x01,0x00,0x00,0x00,0xC0,0x00,0x00,0x0E,0x08,0x81,0x84,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x23,0x00},
	{0x2E,0x00,0x40,0x07,0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x0E,0x08,0x00,0x00,0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x22,0x00},
};

bridgePieces = {
--   type xsub xmin xmaj ysub ymin ymaj xvel xvel xvel yvel yvel yvel wdth hght spr  spr  unk  unk  unk  unk  unk  unk  unk  unk  unk
--   0    1    2    3    4    5    6    7    8    9    a    b    c    d    e    f    10   11   12   13   14   15   16   17   18   19
	{    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,0x81,0x84,0x01,0x00,0x00,    ,0x00,0x00,0x00,0x23,    },
	{    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,0x81,0x84,0x01,0xD4,0x01,    ,0xAA,0x06,0x04,0x23,    },
	{    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,0x81,0x84,0x01,0xD4,0x01,    ,0xAA,0x06,0x04,0x23,    },
	{    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,0x81,0x84,0x01,0x00,0x00,    ,0x00,0x00,0x00,0x23,    },
	{    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,0x81,0x84,0x01,0x00,0x00,    ,0x00,0x00,0x00,0x23,    },
	{    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,0x81,0x84,0x01,0x00,0x00,    ,0x00,0x00,0x00,0x23,    },
	{    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,0x81,0x84,0x01,0x00,0x00,    ,0x00,0x00,0x00,0x23,    },
	{    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,0x00,0x00,0x06,0x00,0x00,    ,0x00,0x00,0x00,0x22,    },
	{    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,0x81,0x84,0x01,0x00,0x00,    ,0x00,0x00,0x00,0x23,    },
	{    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,0x81,0x84,0x01,0x00,0x00,    ,0x00,0x00,0x00,0x23,    },
	{    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,    ,0x00,0x00,0x07,0x00,0x00,    ,0x00,0x00,0x00,0x22,    },
};
--]]

function Game.getHitboxes()
	local screenX = Game.getViewportX();
	local screenY = Game.getViewportY();
	ScriptHawk.hitboxDefaultXOffset = -screenX;
	ScriptHawk.hitboxDefaultYOffset = -screenY;

	if Game.version == 2 then -- Game Gear is weird
		ScriptHawk.hitboxDefaultXOffset = ScriptHawk.hitboxDefaultXOffset - 50;
		ScriptHawk.hitboxDefaultYOffset = ScriptHawk.hitboxDefaultYOffset - 24;
	end

	local hitboxes = {};
	for i = 1, 32 do
		local objectBase = Game.Memory.object_array_base + 0x1A * (i - 1);
		local hitbox = {
			dragTag = objectBase,
			type = mainmemory.readbyte(objectBase + object_fields.type),
			x = Game.read_u16_8(objectBase + object_fields.x_position),
			y = Game.read_u16_8(objectBase + object_fields.y_position),
			xVelocity = Game.read_s16_8(objectBase + object_fields.x_velocity),
			yVelocity = Game.read_s16_8(objectBase + object_fields.y_velocity),
			width = mainmemory.readbyte(objectBase + object_fields.width),
			height = mainmemory.readbyte(objectBase + object_fields.height),
		};
		if object_fields.types[hitbox.type] ~= nil then
			hitbox.name = object_fields.types[hitbox.type].name;
			hitbox.color = object_fields.types[hitbox.type].color;
		else
			hitbox.name = "Unknown "..toHexString(hitbox.type, 2);
		end
		if hitbox.type ~= 0xFF then
			table.insert(hitboxes, hitbox);
		end
	end
	return hitboxes;
end

function Game.getHitboxListText(hitbox)
	return hitbox.name.." - x: "..round(hitbox.x)..", y:"..round(hitbox.y).." - "..toHexString(hitbox.dragTag);
end

function Game.setHitboxPosition(hitbox, x, y)
	Game.write_u16_8(hitbox.dragTag + object_fields.x_position, x);
	Game.write_u16_8(hitbox.dragTag + object_fields.y_position, y);
	mainmemory.write_u16_le(hitbox.dragTag + object_fields.x_velocity, 0);
	mainmemory.write_u16_le(hitbox.dragTag + object_fields.y_velocity, 0);
end

--[[
-- TODO: Get tile data viewer working
function isAddressInLevelLayoutData(address)
	local levelWidth = mainmemory.read_u16_le(Game.Memory.level_width);
	local levelHeight = mainmemory.read_u16_le(Game.Memory.level_height);
	print("w "..levelWidth);
	print("h "..levelHeight);
	local levelDataStart = 0xC000;
	local levelDataEnd = levelDataStart + levelWidth * levelHeight;
	print("start "..toHexString(levelDataStart));
	print("end "..toHexString(levelDataEnd));
	return address >= levelDataStart and address < levelDataEnd;
end

function Game.drawUI()
	local tileSize = 32;
	local viewportXExact = Game.getViewportX();
	local viewportYExact = Game.getViewportY();
	local viewportXTile = math.floor(viewportXExact / tileSize);
	local viewportYTile = math.floor(viewportYExact / tileSize);
	for yTile = 0, 32 do
		for xTile = 0, 32 do
			ScriptHawk.drawText(xTile * tileSize, yTile * tileSize, xTile..", "..yTile, colors.white, colors.black, true);
		end
	end
end
--]]

function solidityBankSwitchCallback()
	Game.solidityBankSwitchCycles = emu.totalexecutedcycles();
end

function solidityDataReadCallback()
	Game.solidityDataReadCycles = emu.totalexecutedcycles();
end

function IRQCallback()
	Game.IRQStartCycles = emu.totalexecutedcycles();
end

function Game.getSolidityBankSwitchCycles()
	return Game.solidityBankSwitchCycles;
end

function Game.getSolidityDataReadCycles()
	return Game.solidityDataReadCycles;
end

function Game.getIRQStartCycles()
	return Game.IRQStartCycles;
end

function Game.getGlitchCycleOffset()
	return Game.IRQStartCycles - Game.solidityBankSwitchCycles;
end

function Game.getMinimumGlitchCycleOffset()
	local cycleOffset = math.abs(Game.getGlitchCycleOffset());
	Game.minimumGlitchCycleOffset = math.min(Game.minimumGlitchCycleOffset, cycleOffset);
	return Game.minimumGlitchCycleOffset;
end

function Game.resetMinimumGlitchCycleOffset()
	Game.minimumGlitchCycleOffset = math.huge;
end
ScriptHawk.bindKeyRealtime("Slash", Game.resetMinimumGlitchCycleOffset, true);

function Game.colorGlitchCycleOffset()
	if Game.IRQStartCycles >= Game.solidityBankSwitchCycles and Game.IRQStartCycles <= Game.solidityDataReadCycles then
		return colors.green;
	end
end

function Game.getGlitchWindowSize()
	return Game.solidityDataReadCycles - Game.solidityBankSwitchCycles;
end

function Game.colorGlitchTimers()
	local ringTimer = Game.getRingMod10Timer();
	local palleteTimer = Game.getCyclePalleteSpeed();
	if ringTimer == 0 and palleteTimer == 1 then
		return colors.green;
	end
	if ringTimer == 0 then
		return colors.yellow;
	end
	if palleteTimer == 1 then
		return colors.yellow;
	end
end

event.onmemoryexecute(solidityBankSwitchCallback, 0x49E9); -- TODO: Port to Game Gear
event.onmemoryexecute(solidityDataReadCallback, 0x4A0B); -- TODO: Port to Game Gear
event.onmemoryexecute(IRQCallback, 0x0038);

Game.OSD = {
	{"Level", Game.getLevel, category="mapData"},
	{"IGT", Game.getIGT, category="igt"},
	{"Lives", Game.getLives, category="lives"},
	{"Rings", hexifyOSD(Game.getRings, nil, ""), category="rings"},
	{"Viewport X", Game.getViewportX, category="screenPosition"},
	{"Viewport Y", Game.getViewportY, category="screenPosition"},
	{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"X Velocity", Game.getXVelocity, category="speed"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"X Velocity (Hex)", Game.getXVelocityHex, category="speed"},
	{"Y Velocity (Hex)", Game.getYVelocityHex, category="speed"},
	{"dX", category="positionStats"},
	{"dY", category="positionStats"},
	{"Separator"},
	{"Speed Shoes", Game.getSpeedShoesTimer},
	{"Invuln.", Game.getInvulnerabilityTimer},
	{"Separator"},
	{"Ring Timer", Game.getRingMod10Timer, Game.colorGlitchTimers},
	{"Pallete Timer", Game.getCyclePalleteSpeed, Game.colorGlitchTimers},
	{"Separator"},
	{"Solidity Bank Switch", Game.getSolidityBankSwitchCycles, Game.colorGlitchCycleOffset},
	{"IRQ Start           ", Game.getIRQStartCycles, Game.colorGlitchCycleOffset},
	{"Solidity Data Read  ", Game.getSolidityDataReadCycles, Game.colorGlitchCycleOffset},
	{"Offset              ", Game.getGlitchCycleOffset, Game.colorGlitchCycleOffset},
	{"Min Offset          ", Game.getMinimumGlitchCycleOffset},
	{"Glitch Window Size  ", Game.getGlitchWindowSize},
};

return Game;