if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

solidityTestEnabled = false;
solidityTestValue = 0x00;

local Game = {
	squish_memory_table = true,
	Memory = { -- Order: SMS/GG (Proto), GG 1.0, GG 1.1
		in_score_screen = {0x1207, 0x1207, 0x1207}, -- These are actually part of a big game state bitfield, might be worth going through the disassembly and documenting all of them
		level = {0x123E, 0x1238, 0x1238},
		rings = {0x12AA, 0x12A9, 0x12A9}, -- byte, BCD
		lives = {0x1246, 0x1240, 0x1240},
		level_width = {0x1238, 0x1232, 0x1232}, -- u16_le: Width of the floor layout in blocks
		level_height = {0x123A, 0x1234, 0x1234}, -- u16_le: Height of the floor layout in blocks
		viewport_x = {0x125A, 0x1254, 0x1254},
		viewport_x2 = {0x126F, 0x0000, 0x0000}, -- TODO: GG 1.0, GG 1.1
		viewport_y = {0x125D, 0x1257, 0x1257},
		viewport_y2 = {0x1271, 0x0000, 0x0000}, -- TODO: GG 1.0, GG 1.1
		x_position = {0x13FD, 0x13FE, 0x13FE}, -- 3 bytes: sub.min.maj
		y_position = {0x1400, 0x1401, 0x1401}, -- 3 bytes: sub.min.maj
		x_velocity = {0x1403, 0x1404, 0x1404}, -- 3 bytes: sub.min.maj
		y_velocity = {0x1406, 0x1407, 0x1407}, -- 3 bytes: sub.min.maj
		igt = {0x12CE, 0x12CF, 0x12CF}, -- 3 bytes: min(BCD):sec(BCD).frame
		invuln_timer = {0x128D, 0x1287, 0x1287},
		speed_shoes_timer = {0x1411, 0x1412, 0x1412},
		object_array_base = {0x13FC, 0x13FD, 0x13FD},
		ring_mod_10_timer = {0x1298, 0x1293, 0x1293},
		cycle_pallete_speed = {0x12A4, 0x129F, 0x129F},
		solidity_data_index = {0x12D4, 0x12D5, 0x12D5},
		standard_solidity_bank = {0x0F, 0x05, 0x05},
		glitched_solidity_bank = {0x02, 0x02, 0x02},
		solidity_data_start_system_bus = {0xB9ED, 0xA200, 0xA200},
		-- Code hooks
		solidity_bank_switch = {0x49E9, 0x4BF1, 0x4BFB},
		solidity_data_first_read = {0x4A05, 0x4C17, 0x4C21},
		solidity_data_second_read = {0x4A07, 0x4C19, 0x4C23},
		solidity_data_final_read = {0x4A0B, 0x4C1D, 0x4C27},
		solidity_test = {0x4A0C, 0x4C1E, 0x4C28},
		irq_address = {0x0038, 0x0038, 0x0038},
		irq_bank_switch_address = {0x01AF, 0x0000, 0x0000}, -- TODO: GG 1.0, GG 1.1
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
	solidityDataFinalReadCycles = 0,
	IRQStartCycles = 0,
	IRQBankSwitchThisFrame = false,
	tileIndex = 0,
	solidityValue = 0,
	solidityAddress = 0x0000,
	possibleSolidityValues = {
		[1] = {address=0x0000, value=0x00},
		[2] = {address=0x0000, value=0x00},
		[3] = {address=0x0000, value=0x00},
	},
	minimumGlitchCycleOffset = math.huge,
	glitchedThisFrame = false,
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

function Game.read_u16_8_hex(base)
	return toHexString(mainmemory.read_u16_le(base + 1), 4, "").."."..toHexString(mainmemory.readbyte(base), 2, "");
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
	ScriptHawk.hitboxDefaultShowList = false;
	ScriptHawk.hitboxDefaultShowHitboxes = false;
	ScriptHawk.hitboxListShowCount = true;
	ScriptHawk.hitboxDefaultColor = colors.white;

	-- Gotta put these here so that we can use the squished memory tables
	event.onmemoryexecute(solidityBankSwitchCallback, Game.Memory.solidity_bank_switch);
	event.onmemoryexecute(solidityDataFirstReadCallback, Game.Memory.solidity_data_first_read);
	event.onmemoryexecute(solidityDataSecondReadCallback, Game.Memory.solidity_data_second_read);
	event.onmemoryexecute(solidityDataFinalReadCallback, Game.Memory.solidity_data_final_read);
	event.onmemoryexecute(solidityTestCallback, Game.Memory.solidity_test);
	event.onmemoryexecute(IRQCallback, Game.Memory.irq_address);
	--event.onmemoryexecute(IRQBankSwitchCallback, Game.Memory.irq_bank_switch_address);

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
	return Game.read_s16_8(Game.Memory.x_velocity);
end

function Game.getYVelocity()
	return Game.read_s16_8(Game.Memory.y_velocity);
end

function Game.getXVelocityHex()
	return Game.read_u16_8_hex(Game.Memory.x_velocity);
end

function Game.getYVelocityHex()
	return Game.read_u16_8_hex(Game.Memory.y_velocity);
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

function Game.getHitboxes()
	local screenX = Game.getViewportX();
	local screenY = Game.getViewportY();
	ScriptHawk.hitboxDefaultXOffset = -screenX;
	ScriptHawk.hitboxDefaultYOffset = -screenY;

	if Game.version ~= 1 then -- Game Gear is weird
		ScriptHawk.hitboxDefaultXOffset = ScriptHawk.hitboxDefaultXOffset - 50;
		ScriptHawk.hitboxDefaultYOffset = ScriptHawk.hitboxDefaultYOffset - 24;
	end

	local hitboxes = {};
	for i = 1, 32 do
		local objectBase = Game.Memory.object_array_base + 0x1A * (i - 1);
		local hitbox = {
			index = i - 1,
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
	return hitbox.name.." - x: "..round(hitbox.x)..", y:"..round(hitbox.y).." - "..toHexString(hitbox.dragTag).." - "..hitbox.index;
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

local function systemBusToROM(bank, address)
	local bankSize = 0x4000;
	return bank * bankSize + address - 0x8000;
end

local function glitchyBusRead(bank, address)
	-- Clamp address to system bus
	address = bit.band(address, 0xFFFF);

	-- If address is outside the range of the glitchy bank read from system bus as normal
	if address < 0x8000 or address > 0xBFFF then
		return memory.readbyte(address, "System Bus");
	end

	-- Pretend the glitched bank (probably bank 2) is loaded and read from that bank in ROM
	return memory.readbyte(systemBusToROM(bank, address), "ROM");
end

local function computeSolidityValue(tileIndex, bank, startOffset)
	local solidityDataIndex = mainmemory.readbyte(Game.Memory.solidity_data_index);

	local hl = Game.Memory.solidity_data_start_system_bus + 2 * solidityDataIndex;

	local currentBank = Game.Memory.standard_solidity_bank; -- Non glitched

	if startOffset == 1 then
		currentBank = bank; -- Glitch the bank!
	end

	local a = glitchyBusRead(currentBank, hl);

	if startOffset == 2 then
		currentBank = bank; -- Glitch the bank!
	end

	local h = glitchyBusRead(currentBank, hl + 1);

	local realSolidityAddress = bit.band(Game.Memory.solidity_data_start_system_bus + 0x0100 * h + a + tileIndex, 0xFFFF);

	if startOffset == 3 then
		currentBank = bank; -- Glitch the bank!
	end

	local returnValue = {value=glitchyBusRead(currentBank, realSolidityAddress), address=realSolidityAddress};
	return returnValue;
end

function solidityBankSwitchCallback()
	Game.solidityBankSwitchCycles = emu.totalexecutedcycles();
end

function solidityTestCallback()
	if solidityTestEnabled then
		-- Set the solidity value in the register itself
		emu.setregister("A", solidityTestValue);

		-- Read back what the value has been set to
		local registers = emu.getregisters();
		Game.solidityValue = registers.A;
	end
end

function solidityDataFirstReadCallback()
	Game.solidityDataFirstReadCycles = emu.totalexecutedcycles();

	-- Compute possible tile solidity values for a glitchy bank 2 read at certain points in the solidity function
	local registers = emu.getregisters();
	local tileIndex = registers.E;
	Game.tileIndex = tileIndex;
	for i = 1, 3 do
		Game.possibleSolidityValues[i] = computeSolidityValue(tileIndex, Game.Memory.glitched_solidity_bank, i);
	end
end

function solidityDataSecondReadCallback()
	Game.solidityDataSecondReadCycles = emu.totalexecutedcycles();
end

function solidityDataFinalReadCallback()
	local registers = emu.getregisters();
	local solidityDataAddress = registers.HL;
	Game.solidityAddress = solidityDataAddress;
	Game.solidityValue = memory.readbyte(solidityDataAddress, "System Bus");
	Game.glitchedThisFrame = memory.readbyte(0xFFFF, "System Bus") ~= Game.Memory.standard_solidity_bank; -- True if the incorrect bank (probably 2) is loaded in the system bus at the time the solidity value is read
	Game.solidityDataFinalReadCycles = emu.totalexecutedcycles();
end

function IRQCallback()
	Game.IRQStartCycles = emu.totalexecutedcycles();
	Game.IRQBankSwitchThisFrame = false; -- Will be set to true later in interrupt handler if the bank is switched
end

function IRQBankSwitchCallback()
	Game.IRQBankSwitchThisFrame = true;
end

function Game.IRQCausedBankSwitchThisFrame()
	return Game.IRQBankSwitchThisFrame;
end

function Game.getSolidityBankSwitchCycles()
	return Game.solidityBankSwitchCycles;
end

function Game.getSolidityDataReadCycles()
	return Game.solidityDataFirstReadCycles;
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
	if Game.IRQStartCycles >= Game.solidityBankSwitchCycles and Game.IRQStartCycles <= Game.solidityDataFinalReadCycles then
		return colors.green;
	end
end

function Game.getGlitchWindowSize()
	return Game.solidityDataFinalReadCycles - Game.solidityBankSwitchCycles;
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

function Game.getTileIndex()
	return toHexString(Game.tileIndex, 2, "");
end

function Game.getSolidityValue()
	return toHexString(Game.solidityValue, 2, "").." ("..toHexString(Game.solidityAddress, 4, "")..")";
end

function Game.getPossibleSolidityValues()
	return toHexString(Game.possibleSolidityValues[1].value, 2, "")..",   "..toHexString(Game.possibleSolidityValues[2].value, 2, "")..",   "..toHexString(Game.possibleSolidityValues[3].value, 2, "");
end

function Game.colorPossibleValues()
	local greenFound = false;
	local yellowFound = false;
	for i = 1, 3 do
		if Game.possibleSolidityValues[i].value == 0x0B then
			greenFound = true;
		end
		if Game.possibleSolidityValues[i].value <= 0x1C then
			yellowFound = true;
		end
	end
	if greenFound then
		return colors.green;
	end
	if yellowFound then
		return colors.yellow;
	end
end

function Game.getPossibleSolidityAddresses()
	return toHexString(Game.possibleSolidityValues[1].address, 4, "")..", "..toHexString(Game.possibleSolidityValues[2].address, 4, "")..", "..toHexString(Game.possibleSolidityValues[3].address, 4, "");
end

function Game.getPossibleSolidityOffsets()
	return "TODO, TODO, TODO";
end

function Game.isGlitchedThisFrame()
	return Game.glitchedThisFrame;
end

function Game.colorIsGlitched()
	if Game.glitchedThisFrame then
		return colors.green;
	end
end

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
	{"dX", category="positionStats"},
	{"dY", category="positionStats"},
	{"Separator"},
	{"X (Hex)", Game.getXPositionHex, category="position"},
	{"Y (Hex)", Game.getYPositionHex, category="position"},
	{"X Velocity (Hex)", Game.getXVelocityHex, category="speed"},
	{"Y Velocity (Hex)", Game.getYVelocityHex, category="speed"},
	{"Separator"},
	{"Speed Shoes", Game.getSpeedShoesTimer},
	{"Invuln.", Game.getInvulnerabilityTimer},
	{"Separator"},
	{"Ring Timer", Game.getRingMod10Timer, Game.colorGlitchTimers},
	{"Pallete Timer", Game.getCyclePalleteSpeed, Game.colorGlitchTimers},
	{"Separator"},
	{"Sol. Bank Switch", Game.getSolidityBankSwitchCycles, Game.colorGlitchCycleOffset},
	{"IRQ Start       ", Game.getIRQStartCycles, Game.colorGlitchCycleOffset},
	{"Sol. Data Read  ", Game.getSolidityDataReadCycles, Game.colorGlitchCycleOffset},
	{"Offset          ", Game.getGlitchCycleOffset, Game.colorGlitchCycleOffset},
	{"Glitched Frame  ", Game.isGlitchedThisFrame, Game.colorIsGlitched},
	--{"IRQ Bank Switch?", Game.IRQCausedBankSwitchThisFrame},
	{"Min Offset      ", Game.getMinimumGlitchCycleOffset},
	{"Glitch Window   ", Game.getGlitchWindowSize},
	{"Tile Index      ", Game.getTileIndex},
	{"Solidity Value  ", Game.getSolidityValue},
	{"Poss. Sol. Val. ", Game.getPossibleSolidityValues, Game.colorPossibleValues},
	{"Poss. Sol. Addr.", Game.getPossibleSolidityAddresses, Game.colorPossibleValues},
	--{"Poss. Offsets   ", Game.getPossibleSolidityOffsets, Game.colorPossibleValues},
};

return Game;