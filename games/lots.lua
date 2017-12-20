if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		map = 0x98,
		map_status = 0xA0,
		building_status = 0xA1,
		demo_timer = 0x104, -- 2 bytes
		screen_x_tile = 0x10A,
		screen_x_pixel = 0x10F,
		health = 0x129,
		recovery_status = 0x12B,
		recovery_timer = 0x12C, -- 2 bytes
		continue_map = 0xCAE,
		continues_used = 0xCAF,
		movement_state = 0x401,
		x_position = 0x40A, -- 1 byte (screen)
		y_position = 0x407, -- 1 byte (screen)
		x_velocity = 0x413, -- 3 byte
		y_velocity = 0x410, -- 2 byte
		facing_direction = 0x421,
		in_air = 0x422,
		sword_damage = 0xCA8,
		bow_damage = 0xCA9,
	},
	maps = {
		"01 - Swamp (Shagart +1L) (Left)",
		"02 - Swamp (Shagart +1L) (Right)",
		"03 - Swamp (Dwarle +1DR) (Lindon +1L) (Left)",
		"04 - Swamp (Dwarle +1DR) (Lindon +1L) (Right)",
		"05 - Swamp (Pharazon +1R) (Left)",
		"06 - Swamp (Pharazon +1R) (Right)",
		"07 - Swamp (Harfoot +1R) (Amon +2L) (Left) (Demo)",
		"08 - Swamp (Harfoot +1R) (Amon +2L) (Right)",
		"09 - Swamp (Ithile +3R) (Left)",
		"0A - Swamp (Ithile +3R) (Right)",
		"0B - Swamp (Dwarle +1UR) (Left)",
		"0C - Swamp (Dwarle +1UR) (Left)",
		"0D - Swamp (Varlin +1L) (Left)",
		"0E - Swamp (Varlin +1L) (Right)",
		"0F - Swamp (Pharazon +1DL) (Left)",
		"10 - Swamp (Pharazon +1DL) (Right)",
		"11 - Swamp (Ithile +1R) (Left)",
		"12 - Swamp (Ithile +1R) (Right)",
		"13 - Swamp (Harfoot +1L) (Medusa +3R) (Left)",
		"14 - Swamp (Harfoot +1L) (Medusa +3R) (Right)",
		"15 - Swamp (Pharazon +1UR) (Right)",
		"16 - Swamp (Pharazon +1UR) (Right)",
		"17 - Swamp (Shagart +1R) (Left)",
		"18 - Swamp (Shagart +1R) (Right)",
		"19 - Swamp (Lindon +1R) (Pirate +2L) (Left)",
		"1A - Swamp (Lindon +1R) (Pirate +2L) (Right)",
		"1B - Swamp (Pharazon +1UL) (Left)",
		"1C - Swamp (Pharazon +1UL) (Right)",
		"1D - Swamp (Castle Elder +1L) (Left)",
		"1E - Swamp (Castle Elder +1L) (Right)",
		"1F - Swamp (Ithile +1L) (Goblin +3R) (Left)",
		"20 - Swamp (Ithile +1L) (Goblin +3R) (Right)",
		"21 - Swamp (Varlin +1UL) (Left)",
		"22 - Swamp (Varlin +1UL) (Right)",
		"23 - Forest (Amon +1L) (Harfoot +2R) (Left)",
		"24 - Forest (Amon +1L) (Harfoot +2R) (Right)",
		"25 - Forest (Amon +1UL) (Left)",
		"26 - Forest (Amon +1UL) (Right)",
		"27 - Forest (Namo +1R) (Pharazon +2DL) (Left)",
		"28 - Forest (Namo +1R) (Pharazon +2DL) (Right)",
		"29 - Forest (Ulmo +1R) (Left)",
		"2A - Forest (Ulmo +1R) (Right)",
		"2B - Forest (Medusa +2R) (Harfoot +2L) (Left)",
		"2C - Forest (Medusa +2R) (Harfoot +2L) (Right)",
		"2D - Forest (Amon +1R) (Left)",
		"2E - Forest (Amon +1R) (Right)",
		"2F - Forest (???) (Left)",
		"30 - Forest (???) (Right)",
		"31 - Forest (???) (Bottom Left)",
		"32 - Forest (???) (Right)",
		"33 - Forest (???) (Top Left)",
		"34 - Forest (Shagart +2L) (Bottom Left)",
		"35 - Forest (Shagart +2L) (Right)",
		"36 - Forest (Shagart +2L) (Top Left, Stairs)",
		"37 - Forest (Varlin +2UL) (Dwarle +2L) (Bottom Left)",
		"38 - Forest (Varlin +2UL) (Dwarle +2L) (Right)",
		"39 - Forest (Varlin +2UL) (Dwarle +2L) (Top Left, Stairs)",
		"3A - Coast (Dwarle +1L) (Left)",
		"3B - Coast (Dwarle +1L) (Right)",
		"3C - Coast (Ithile +2R) (Left)",
		"3D - Coast (Ithile +2R) (Right)",
		"3E - Coast (???) (Left)",
		"3F - Coast (???) (Right)",
		"40 - Cave (Dark Suma +1R) (Left)",
		"41 - Cave (Dark Suma +1R) (Right)",
		"42 - Cave (Swamp Spirit +1R) (Ithile +3L) (Left)",
		"43 - Cave (Swamp Spirit +1R) (Ithile +3L) (Right)",
		"44 - Mountains (Amon +2UL) (Pharazon +2R) (Left)",
		"45 - Mountains (Amon +2UL) (Pharazon +2R) (Right)",
		"46 - Mountains (???) (Left)",
		"47 - Mountains (???) (Right)",
		"48 - Mountains (???) (Left)",
		"49 - Mountains (???) (Right)",
		"4A - Mountains (???) (Left)",
		"4B - Mountains (???) (Right)",
		"4C - Mountains (???) (Bottom Left)",
		"4D - Mountains (???) (Right)",
		"4E - Mountains (???) (Top Left)",
		"4F - Mountains (Pharazon +2UR) (Bottom Left)",
		"50 - Mountains (Pharazon +2UR) (Right)",
		"51 - Mountains (Pharazon +2UR) (Top Left Stairs)",
		"52 - Mountains (???) (Left)",
		"53 - Mountains (???) (Right)",
		"54 - Mountains (Medusa +1R) (Harfoot +3L) (Left)",
		"55 - Mountains (Medusa +1R) (Harfoot +3L) (Right)",
		"56 - Mountains (Pharazon +1UL+3L+Stairs) (Left)",
		"57 - Mountains (Pharazon +1UL+3L+Stairs) (Right)",
		"58 - Mountains (Dark Suma +2R) (Left)",
		"59 - Mountains (Dark Suma +2R) (Right)",
		"5A - Dark Forest (Ithile +2L) (Swamp Spirit +2R) (Left)",
		"5B - Dark Forest (Ithile +2L) (Swamp Spirit +2R) (Right)",
		"5C - Dark Forest (Pirate +1L) (Lindon +2R) (Left)",
		"5D - Dark Forest (Pirate +1L) (Lindon +2R) (Right)",
		"5E - Harfoot (Left)",
		"5F - Harfoot (Right)",
		"60 - Ithile (Left)",
		"61 - Ithile (Right)",
		"62 - Amon (Left)",
		"63 - Amon (Right)",
		"64 - Amon (Left Stairs)",
		"65 - Amon (Left)", -- Unused?
		"66 - Amon (Right)", -- Unused?
		"67 - Amon (Left Stairs)", -- Unused?
		"68 - Dwarle (Left)",
		"69 - Dwarle (Right)",
		"6A - Dwarle (Right Stairs)",
		"6B - Pharazon (Left)",
		"6C - Pharazon (Right)",
		"6D - Pharazon (Left Stairs)",
		"6E - Pharazon (Bottom Left, Stairs Spawned)",
		"6F - Pharazon (Bottom Right, Stairs Spawned)",
		"70 - Pharazon (Left Stairs, Stairs Spawned)",
		"71 - Pharazon (Top Right, Stairs Spawned)",
		"72 - Shagart (Left)",
		"73 - Shagart (Door)",
		"74 - Shagart (Open) (Left)",
		"75 - Shagart (Open) (Door)",
		"76 - Lindon (Left)",
		"77 - Lindon (Right)",
		"78 - Castle Elder",
		"79 - Glitched version of Varlin [UNTESTED, HASN'T BEEN TESTED WITH CORRECT FLAGS SET]",
		"7A - Varlin (Bottom Left, Closed)",
		"7B - Varlin (Top Left, Closed)",
		"7C - Varlin (Bottom Left, Open)",
		"7D - Varlin (Top Left, Open)",
		"7E - Dark Suma's Dungeon 1F (Bottom Left)",
		"7F - Dark Suma's Dungeon 1F (Top Left)",
		"80 - Dark Suma's Dungeon 2F",
		"81 - Dark Suma's Dungeon 3F",
		"82 - Ra Goan's Dungeon Entrance",
		"83 - Ra Goan's Dungeon Boss Room",
		"84 - Ra Goan's Dungeon B1F",
		"85 - Ra Goan's Dungeon B2F",
		"86 - Ra Goan's Dungeon B3F",
	},
	map_states = {
		[0x00] = "Reset",
		[0x01] = "Map",
		[0x02] = "Sega logo",
		[0x03] = "Title Screen",
		[0x04] = "Demo",
		[0x05] = "Start Game",
		[0x06] = "Story",
	},
	building_states = {
		[0x00] = "Map",
		[0x01] = "Load Map",
		[0x02] = "Building",
		[0x03] = "Boss Fight",
		[0x04] = "Map Screen",
		[0x05] = "Ending",
		[0x06] = "Death",
	},
	movement_states = {
		[0x00] = "Walking (L)",
		[0x01] = "Walking (R)",
		[0x02] = "Jumping (L)",
		[0x03] = "Jumping (R)",
		[0x04] = "Falling (L)",
		[0x05] = "Falling (R)",
		[0x06] = "Crouching (L)",
		[0x07] = "Crouching (R)",
		[0x08] = "Sword (L)",
		[0x09] = "Sword (R)",
		[0x0A] = "Bow (L)",
		[0x0B] = "Bow (R)",
		[0x0C] = "Crouching Bow (L)",
		[0x0D] = "Crouching Bow (R)",
		[0x0E] = "Death",
		[0x10] = "Damaged",
		[0x12] = "Crouching Sword (L)",
		[0x13] = "Crouching Sword (R)",
	},
	takeMeThereType = "Button",
};

function Game.getMapStatus()
	local status = mainmemory.readbyte(Game.Memory.map_status);
	if type(Game.map_states[status]) == "string" then
		return Game.map_states[status];
	end
	return "Unknown "..toHexString(status);
end

function Game.getBuildingStatus()
	local status = mainmemory.readbyte(Game.Memory.building_status);
	if type(Game.building_states[status]) == "string" then
		return Game.building_states[status];
	end
	return "Unknown "..toHexString(status);
end

function Game.getMap()
	local map = mainmemory.readbyte(Game.Memory.map);
	if type(Game.maps[map]) == "string" then
		return Game.maps[map];
	end
	return "Unknown "..toHexString(map);
end

function Game.getContinue()
	local map = mainmemory.readbyte(Game.Memory.continue_map);
	if type(Game.maps[map]) == "string" then
		return Game.maps[map];
	end
	return "Unknown "..toHexString(map);
end

function Game.setMap(value)
	mainmemory.writebyte(Game.Memory.map, value);
	mainmemory.writebyte(Game.Memory.building_status, 1);
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.health, 0x30);
	--mainmemory.writebyte(Game.Memory.continues_used, 1);
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

function Game.isGrounded()
	return mainmemory.readbyte(Game.Memory.in_air) == 0x00;
end

function Game.isRecovering()
	return mainmemory.readbyte(Game.Memory.recovery_status) ~= 0x00;
end

function Game.getRecoveryTimer()
	return mainmemory.read_u16_le(Game.Memory.recovery_timer);
end

function Game.colorRecoveryTimer()
	if Game.isRecovering() then
		return colors.red;
	end
	return 0; -- Transparent, cheeky hack to hide the OSD entry without switching OSD tables
end

function Game.getHealth()
	return mainmemory.readbyte(Game.Memory.health);
end

function Game.getContinuesUsed()
	return mainmemory.readbyte(Game.Memory.continues_used);
end

function Game.getMapX()
	return mainmemory.readbyte(Game.Memory.screen_x_tile) * 8 + (7 - mainmemory.readbyte(Game.Memory.screen_x_pixel));
end

function Game.getXPosition()
	return Game.getMapX() + mainmemory.readbyte(Game.Memory.x_position);
end

function Game.getYPosition()
	return mainmemory.readbyte(Game.Memory.y_position);
end

function Game.getXVelocity()
	return Game.read_s16_8(Game.Memory.x_velocity);
end

function Game.colorXVelocity()
	local xVel = math.abs(Game.getXVelocity());
	if xVel >= 2 then
		return colors.green;
	end
	if xVel > 0 and xVel < 1 then
		return getColor(1 - xVel);
	end
	return colors.white;
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(Game.Memory.y_velocity) / 256;
end

function Game.getMovementState()
	local state = mainmemory.readbyte(Game.Memory.movement_state);
	if type(Game.movement_states[state]) == "string" then
		return Game.movement_states[state];
	end
	return "Unknown "..toHexString(state);
end

local object_size = 0x40;
local object_array_base = 0x400;
local object_array_capacity = 23;
local object_fields = {
	object_type = 0x00,
	x_position = 0x0A,
	y_position = 0x07,
	object_loaded = 0x0B,
	y_velocity = 0x11,
	currentHP = 0x3A,
	bossHP = 0x34,
	boss_defeated = 0x3E,
	boss_teleport_timer = 0x22,
	boss_flash_timer = 0x24,
	object_types = {
		--[0x00] = "Null",
		[0x01] = {name="Player"},
		[0x02] = {name="Arrow"},
		[0x03] = {name="Sword Upgrade"},
		[0x04] = {name="Arrow Upgrade"},
		[0x05] = {name="Sign"},
		[0x10] = {name="Slime"}, -- Dungeon
		[0x11] = {name="Eye Part"}, -- Forest
		[0x12] = {name="Bat"},
		[0x13] = {name="Bird"},
		[0x14] = {name="Fish"},
		[0x15] = {name="Clown"},
		[0x16] = {name="Knight"},
		[0x17] = {name="Scorpion"},
		[0x18] = {name="Spider"}, -- Mountain
		[0x19] = {name="Wolf"},
		[0x1A] = {name="Caterpillar"},
		[0x1B] = {name="Eye Part"}, -- Forest
		[0x1C] = {name="Skeleton"},
		[0x1D] = {name="Demon"}, -- Red Flying Thingy
		[0x1E] = {name="Snake"},
		[0x1F] = {name="Bat"},
		[0x20] = {name="Plant"}, -- Floating up and down and shooting (forest plant killymajig)
		[0x21] = {name="Goblin"}, -- Fall down from top, steal book
		[0x23] = {name="Kicky Guy"}, -- Mountain
		[0x24] = {name="Dinosaur"}, -- Red, forest, jumps
		[0x25] = {name="Dinosaur"}, -- Green, jumps from bottom of screen
		[0x26] = {name="Skeleton"}, -- Cave, shoots projectiles
		[0x27] = {name="Damaged"}, -- Killed Knight
		[0x28] = {name="Snake"}, -- Cave, shoots projectiles
		[0x29] = {name="Projectile"}, -- Plant
		[0x2A] = {name="Damaged"}, -- Killed or off edge of screen
		[0x2B] = {name="Tree Spirit", isBoss=true},
		[0x2C] = {name="Projectile"}, -- Tree Spirit
		[0x2D] = {name="Projectile"}, -- Tree Spirit
		[0x2E] = {name="Swamp Spirit", isBoss=true},
		[0x2F] = {name="Stone Hammer", isBoss=true}, -- Second Duel
		[0x30] = {name="Dark Suma", isBoss=true},
		[0x31] = {name="Clone", isBoss=true}, -- Swamp Spirit's Minion
		[0x32] = {name="Golden Guard", isBoss=true}, -- Third Duel
		[0x33] = {name="Paradin", isBoss=true}, -- Fifth Duel
		[0x34] = {name="Pirate", isBoss=true},
		[0x35] = {name="Projectile"}, -- Pirate Boss' Sword
		[0x36] = {name="Medusa", isBoss=true},
		[0x37] = {name="Demon Boss", isBoss=true},
		[0x39] = {name="Court Jester", isBoss=true}, -- Fourth Duel
		[0x3A] = {name="The Ripper", isBoss=true}, -- First Duel
		[0x3C] = {name="Projectile"}, -- Court Jester
		[0x3D] = {name="Skull"}, -- Dark Suma
		[0x3E] = {name="Projectile"}, -- Dark Suma
		[0x3F] = {name="Shield"}, -- Ra Goan
		[0x40] = {name="Projectile"}, -- Ra Goan
		[0x41] = {name="Projectile"}, -- Ra Goan
		[0x42] = {name="Ra Goan", isBoss=true},
	},
};

local draggedObjects = {};
function Game.drawUI()
	local row = 0;
	local height = 16;

	local drawHitboxes = forms.ischecked(ScriptHawk.UI.form_controls["Object Hitboxes Checkbox"]);
	local drawList = forms.ischecked(ScriptHawk.UI.form_controls["Object List Checkbox"]);
	local draggableHitboxes = forms.ischecked(ScriptHawk.UI.form_controls["Draggable Hitboxes Checkbox"]);

	if drawHitboxes or drawList then
		-- Draw Objects
		local height = 16; -- Text row height
		local width = 8; -- Text column width
		local mouse = input.getmouse();

		-- Draw mouse pixel
		--gui.drawPixel(mouse.X, mouse.Y, colors.red);

		local startDrag = false;
		local dragging = false;
		local dragTransform = {0, 0};

		if draggableHitboxes then
			if mouse.Left then
				if not mouseClickedLastFrame then
					startDrag = true;
					startDragPosition = {mouse.X, mouse.Y};
				end
				mouseClickedLastFrame = true;
				dragging = true;
				dragTransform = {mouse.X - startDragPosition[1], mouse.Y - startDragPosition[2]};
			else
				draggedObjects = {};
				mouseClickedLastFrame = false;
				dragging = false;
			end
		end

		local row = 0;
		for i = 0, object_array_capacity do
			local objectBase = object_array_base + (i * object_size);
			local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
			local objectLoaded = mainmemory.readbyte(objectBase + object_fields.object_loaded);
			local objectTypeTable = nil;
			local color = nil;
			if objectType > 0 and objectLoaded == 0 then
				-- Default to 16 width/height for hitbox
				local hitboxWidth = 16;
				local hitboxHeight = 16;

				-- Get the X and Y position of the object
				local xPosition = mainmemory.readbyte(objectBase + object_fields.x_position);
				local yPosition = mainmemory.readbyte(objectBase + object_fields.y_position);

				local currentHP = mainmemory.readbyte(objectBase + object_fields.currentHP);

				if type(object_fields.object_types[objectType]) == "table" then
					objectTypeTable = object_fields.object_types[objectType];

					if type(objectTypeTable.name) == "string" then
						objectType = object_fields.object_types[objectType].name;
					else
						objectType = "Unknown "..toHexString(objectType);
					end

					if type(objectTypeTablecolor) == "number" then
						color = objectTypeTablecolor;
					end

					if objectTypeTable.isBoss then
						currentHP = mainmemory.readbyte(objectBase + object_fields.bossHP);
					elseif objectType == "Player" then
						currentHP = Game.getHealth();
					end

					if type(objectTypeTable.hitbox_x_offset) == "number" then
						hitboxXOffset = objectTypeTable.hitbox_x_offset;
					end
					if type(objectTypeTable.hitbox_y_offset) == "number" then
						hitboxYOffset = objectTypeTable.hitbox_y_offset;
					end

					if type(objectTypeTable.hitbox_width) == "number" then
						hitboxWidth = objectTypeTable.hitbox_width;
					end
					if type(objectTypeTable.hitbox_height) == "number" then
						hitboxHeight = objectTypeTable.hitbox_height;
					end
				else
					color = colors.red;
					objectType = "Unknown "..toHexString(objectType);
				end

				local hitboxXOffset = -8;
				local hitboxYOffset = -16;
				if client.bufferheight() == 243 then -- Compensate for overscan
					hitboxXOffset = hitboxXOffset + 13;
					hitboxYOffset = hitboxYOffset + 27;
				end

				if drawHitboxes then
					if dragging then
						for d = 1, #draggedObjects do
							if draggedObjects[d][1] == objectBase then
								xPosition = draggedObjects[d][2] + dragTransform[1];
								yPosition = draggedObjects[d][3] + dragTransform[2];
								mainmemory.writebyte(objectBase + object_fields.x_position, xPosition);
								mainmemory.writebyte(objectBase + object_fields.y_position, yPosition);
								break;
							end
						end
					end

					if drawHitboxes then
						if (mouse.X >= xPosition + hitboxXOffset and mouse.X <= xPosition + hitboxXOffset + hitboxWidth) and (mouse.Y >= yPosition + hitboxYOffset and mouse.Y <= yPosition + hitboxYOffset + hitboxHeight) then
							if startDrag then
								table.insert(draggedObjects, {objectBase, xPosition, yPosition});
							end

							local mouseOverText = {
								objectType,
								toHexString(objectBase).." "..xPosition..","..yPosition,
								currentHP.."HP",
							};

							for t = 1, #mouseOverText do
								gui.drawText(xPosition + hitboxXOffset, yPosition + hitboxYOffset + ((t - 1) * height), mouseOverText[t], color);
							end
						else
							if currentHP > 0 then
								gui.drawText(xPosition + hitboxXOffset, yPosition + hitboxYOffset, currentHP, color);
							end
						end
						gui.drawRectangle(xPosition + hitboxXOffset, yPosition + hitboxYOffset, hitboxWidth, hitboxHeight, color); -- Draw the object's hitbox
					end
				end

				if drawList then
					gui.text(2, 2 + height * row, xPosition..", "..yPosition.." - "..objectType.." "..currentHP.."HP "..toHexString(objectBase), color, 'bottomright');
					row = row + 1;
				end
			end
		end
	end
end

function Game.killEnemies()
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		local objectLoaded = mainmemory.readbyte(objectBase + object_fields.object_loaded);
		if objectType > 0 and objectLoaded == 0 then
			if type(object_fields.object_types[objectType]) == "table" then
				local objectTypeTable = object_fields.object_types[objectType];
				if objectTypeTable.isBoss then
					mainmemory.writebyte(objectBase + object_fields.bossHP, 0);
				else
					mainmemory.writebyte(objectBase + object_fields.currentHP, 0);
				end
			end
		end
	end
end

----------------
-- Flag stuff --
----------------

flag_block_base = 0xC00;
flag_array = {
	-- c00 tree spirit defeated?
	-- c03 swamp spirit defeated?
	{byte=0xC04, name="Duels Defeated"},
	{byte=0xC05, name="Pirate Defeated"},
	-- c06 suma defeated
	{byte=0xC11, name="Game Started"},
	{byte=0xC13, name="Tree Spirit Spawned"}, -- Namo NPC End
	-- c14 tree spirit defeated?
	-- c15 swamp spirit defeated?
	-- c17 duels defeated?
	-- c18 suma defeated?
	-- c1a Pharazon: daughter knows more details
	{byte=0xC21, name="Harfoot FTT"},
	{byte=0xC31, name="Amon FTT"},
	{byte=0xC32, name="Amon: Tree People Text"},
	{byte=0xC33, name="Amon: Namo Directions Text"},
	{byte=0xC34, name="Amon: First of Three Tests Text"},
	{byte=0xC35, name="Amon: Destroy Book Text"},
	{byte=0xC37, name="Amon: Pharazon Path"},
	{byte=0xC41, name="Dwarle FTT"},
	{byte=0xC51, name="Ithile FTT"},
	{byte=0xC52, name="Ithile: Brave Men Text"},
	{byte=0xC53, name="Ithile: Brave Men Text 2"},
	{byte=0xC54, name="Ithile: Swamp Spirit Text"},
	{byte=0xC61, name="Pharazon FTT"},
	{byte=0xC62, name="Pharazon: People of Ithile Text"},
	{byte=0xC63, name="Pharazon: Tree Spirits Text"},
	{byte=0xC64, name="Pharazon: Shagart Den of Thieves Text"},
	{byte=0xC65, name="Pharazon: Shagart Den of Thieves Text (2)"},
	{byte=0xC67, name="Pharazon: Path to Amon Text"},
	{byte=0xC68, name="Pharazon: Shagart Strange People Text"},
	{byte=0xC71, name="??? FTT"},
	{byte=0xC81, name="Lindon FTT"},
	{byte=0xC82, name="Lindon: Brave Men Text"},
	{byte=0xC83, name="Lindon: Brave Men Text 2"},
	{byte=0xC84, name="Lindon: Brave Men Text 3"},
	{byte=0xC85, name="Lindon: Kidnapping Text"},
	{byte=0xC87, name="Lindon: Rest Here Text"},
	{byte=0xC91, name="Ulmo FTT"},
	{byte=0xC92, name="Ulmo: Namo Directions Text"},
	-- ca0 Book is burnable
	{byte=0xCA1, name="Swamp Spirit Spawned"},
	{byte=0xCA2, name="Pirate Spawned"}, -- Also lindon/dwarle open?
	{byte=0xCA3, name="Path to Amon Open"}, -- Suma spawned?
	{byte=0xCA8, name="Sword Damage"},
	{byte=0xCA9, name="Bow Damage"},
	{byte=0xCAA, name="Inventory: Book"},
	{byte=0xCAB, name="Inventory: Tree Limb"},
	{byte=0xCAC, name="Inventory: Herb"},
};

local flag_block_size = 0xAC;
local flag_block_cache = {};

local function clearFlagCache()
	flag_block_cache = {};
end
event.onloadstate(clearFlagCache, "ScriptHawk - Clear Flag Cache");

local function getFlag(byte)
	for i = 1, #flag_array do
		if byte == flag_array[i].byte then
			return flag_array[i];
		end
	end
	return {byte=byte, name="Unknown at "..toHexString(byte)};
end

local function isFlagFound(byte)
	return getFlag(byte) ~= nil;
end

local function getFlagByName(flagName)
	for i = 1, #flag_array do
		if not flag_array[i].ignore and flagName == flag_array[i].name then
			return flag_array[i];
		end
	end
end

function Game.getFlagName(byte)
	for i = 1, #flag_array do
		if byte == flag_array[i].byte and not flag_array[i].ignore then
			return flag_array[i].name;
		end
	end
	return "Unknown at "..toHexString(byte);
end

function checkFlags(showKnown)
	local flagBlock = mainmemory.readbyterange(flag_block_base, flag_block_size + 1);

	if #flag_block_cache == flag_block_size then
		local flagFound = false;
		local knownFlagsFound = 0;
		local currentValue, previousValue;

		for i = 0, #flag_block_cache do
			currentValue = flagBlock[i];
			previousValue = flag_block_cache[i];
			if currentValue ~= previousValue then
				local currentFlag = getFlag(flag_block_base + i);
				if not currentFlag.ignore then
					if currentValue == 0 then
						dprint("Flag "..toHexString(currentFlag.byte, 2)..": \""..currentFlag.name.."\" was cleared on frame "..emu.framecount());
					elseif previousValue == 0 then
						dprint("Flag "..toHexString(currentFlag.byte, 2)..": \""..currentFlag.name.."\" was set with value "..toHexString(currentValue, 2).." on frame "..emu.framecount());
					elseif currentValue > previousValue then
						dprint("Flag "..toHexString(currentFlag.byte, 2)..": \""..currentFlag.name.."\" value increased from "..toHexString(previousValue, 2).." to "..toHexString(currentValue, 2).." on frame "..emu.framecount());
					elseif currentValue < previousValue then
						dprint("Flag "..toHexString(currentFlag.byte, 2)..": \""..currentFlag.name.."\" value decreased from "..toHexString(previousValue, 2).." to "..toHexString(currentValue, 2).." on frame "..emu.framecount());
					end
				end
			end
		end
		flag_block_cache = flagBlock;
		if not showKnown then
			if knownFlagsFound > 0 then
				dprint(knownFlagsFound.." Known flags skipped");
			end
			if not flagFound then
				dprint("No unknown flags were changed");
			end
		end
	else
		flag_block_cache = flagBlock;
		dprint("Populated flag block cache");
	end
	print_deferred();
end

function Game.eachFrame()
	checkFlags(true);
end

function Game.initUI()
	ScriptHawk.UI.form_controls["Object List Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Object List", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);
	ScriptHawk.UI.form_controls["Object Hitboxes Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Hitboxes (Beta)", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset);
	ScriptHawk.UI.form_controls["Draggable Hitboxes Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Draggable", ScriptHawk.UI.col(5) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset);
	forms.setproperty(ScriptHawk.UI.form_controls["Object List Checkbox"], "Checked", true);
	forms.setproperty(ScriptHawk.UI.form_controls["Object Hitboxes Checkbox"], "Checked", true);
	--forms.setproperty(ScriptHawk.UI.form_controls["Draggable Hitboxes Checkbox"], "Checked", true);
end

Game.OSDPosition = {2, 70};
Game.OSD = {
	{"Map", Game.getMap},
	{"Continue", Game.getContinue},
	{"Continues Used", function() return Game.getContinuesUsed().."/10"; end},
	{"Status", Game.getMapStatus},
	{"Status", Game.getBuildingStatus},
	{"Separator", 1},
	{"Health", function() return Game.getHealth().."/48"; end},
	{"Movement", Game.getMovementState},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"X Velocity", Game.getXVelocity, Game.colorXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"dX"},
	{"dY"},
	{"Grounded", Game.isGrounded},
	{"Recovery", Game.getRecoveryTimer, Game.colorRecoveryTimer},
};

return Game;