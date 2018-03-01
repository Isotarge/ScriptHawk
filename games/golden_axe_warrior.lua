if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		current_hp = 0x318,
		max_hp = 0xDA,
		current_magic = 0xDB,
		max_magic = 0xDC,
		horns = 0xDD,
		keys = 0xDE,
	},
};

--[[
RNG Solver Design:
Path points A -> B -> C pass through all points and all enemies
Collision maps: 160 tile array
Spawn maps: 160 tile array
Start index
Middle index
End index
Coordinate you're supposed to reach on a certain frame
Run path and make sure coordinate reached on that frame
Number of positions required
For example minimum 3/6 positions
Enemies can take a variable number of hits
Condition to check for the lower number of hits
If there's a vertical gap in the middle of you and an enemy you can hit it from the bottom but not the top
2 checks, spawn inside area and spawn by frame x
Trace out movement into room, on frame they should spawn by check that they're vulnerable and check their position
Always the up button that manipulates RNG
Other directions don't affect it?
Can start moving on any frame
Button press then Next 4 frames are free to do w/e
Figure out damage boosts, keep manipulating RNG until you're further along than is possible with normal movement
map data in ram roughly 0x1600
]]

-- Configuration
drawCursor = false;

-- Game state
local object_array_base = 0x300;
local object_size = 0x30;
local object_array_capacity = 31;

local tileWidth = 16;
local tileHeight = 16;

local object_fields = {
	object_type = 0x00, -- Byte
	object_types = {
		[0x01] = {name="Dying Enemy", color=colors.white},
		[0x02] = {name="Player", color=colors.yellow},
		--
		[0x07] = {name="Explosion Spawner", color=colors.yellow}, -- Post boss
		[0x08] = {name="Yellow Horn", color=colors.pink}, -- Collectable
		[0x09] = {name="Blue Horn", color=colors.pink}, -- Collectable
		[0x0A] = {name="Bread", color=colors.pink}, -- Collectable
		[0x0B] = {name="Meat", color=colors.pink}, -- Collectable
		[0x0C] = {name="Magic Pot", color=colors.pink}, -- Collectable
		[0x0D] = {name="Hourglass", color=colors.pink}, -- Collectable
		[0x0E] = {name="Key", color=colors.pink}, -- Collectable
		[0x0F] = {name="Crystal", color=colors.pink}, -- Collectable
		[0x10] = {name="Spear", color=colors.yellow}, -- Projectile
		[0x11] = {name="Axe", color=colors.yellow}, -- Projectile
		[0x12] = {name="Spell", color=colors.yellow}, -- Projectile, Snoutman
		[0x13] = {name="Fireball", color=colors.yellow}, -- Projectile, Sea Dragon
		[0x14] = {name="Fireball", color=colors.yellow}, -- Projectile, Sea Dragon
		[0x15] = {name="Fireball", color=colors.yellow}, -- Projectile, Sea Dragon
		[0x16] = {name="Projectile", color=colors.yellow}, -- Projectile
		[0x17] = {name="Projectile", color=colors.yellow}, -- Projectile
		[0x18] = {name="Projectile", color=colors.yellow}, -- Projectile
		[0x19] = {name="Projectile", color=colors.yellow}, -- Projectile, Boulder
		[0x1A] = {name="Sword", color=colors.yellow}, -- Projectile, Dark Soldier
		[0x1B] = {name="Snowball", color=colors.yellow}, -- Projectile, Dweepie
		[0x1C] = {name="Fire", color=colors.yellow}, -- Projectile, Fire Goblin
		[0x1D] = {name="Fire", color=colors.yellow}, -- Projectile, Lava Spawner
		[0x1E] = {name="Fire", color=colors.yellow}, -- Projectile
		[0x1F] = {name="Rock", color=colors.yellow}, -- Projectile, Rockhead
		[0x20] = {name="Snoutman", color=colors.red}, -- Green
		[0x21] = {name="Snoutman", color=colors.red}, -- Blue
		[0x22] = {name="Snoutman", color=colors.red}, -- Red
		[0x23] = {name="Hornet", color=colors.red}, -- Green
		[0x24] = {name="Hornet", color=colors.red}, -- Blue
		--
		[0x26] = {name="Globus", color=colors.red}, -- Green
		[0x27] = {name="Globus", color=colors.red}, -- Blue
		[0x28] = {name="Globus", color=colors.red}, -- Red
		[0x29] = {name="Scorpion", color=colors.red}, -- Green
		[0x2A] = {name="Scorpion", color=colors.red}, -- Red
		[0x2B] = {name="Desert Cap", color=colors.red},
		[0x2C] = {name="Twister", color=colors.red}, -- Blue
		[0x2D] = {name="Skull", color=colors.yellow}, -- Projectile Spawner
		[0x2E] = {name="Sea Dragon", color=colors.red}, -- Green
		[0x2F] = {name="Sea Dragon", color=colors.red}, -- Red
		[0x30] = {name="Shadow", color=colors.yellow}, -- Bounder
		[0x31] = {name="Bounder", color=colors.red}, -- Blue
		[0x32] = {name="Bounder", color=colors.red}, -- Red
		[0x33] = {name="Flying Fish", color=colors.red}, -- Green
		[0x34] = {name="Flying Fish", color=colors.red}, -- Red
		[0x35] = {name="Bushbeast", color=colors.red}, -- Green
		[0x36] = {name="Bushbeast", color=colors.red}, -- Blue
		[0x37] = {name="Bushbeast", color=colors.red}, -- Red
		[0x38] = {name="Rockhead", color=colors.red}, -- Blue
		[0x39] = {name="Rockhead", color=colors.red}, -- Red
		[0x3A] = {name="Sandworm", color=colors.red}, -- Green
		[0x3B] = {name="Sandworm", color=colors.red}, -- Blue
		[0x3C] = {name="Flying Mirror", color=colors.red}, -- Blue
		[0x3D] = {name="Dark Soldier", color=colors.red}, -- Blue
		[0x3E] = {name="Dark Soldier", color=colors.red}, -- Red
		[0x3F] = {name="Snowball", color=colors.red},
		[0x40] = {name="Dweepie", color=colors.red},
		[0x41] = {name="Lava Spawner", color=colors.yellow},
		[0x42] = {name="Fire Goblin", color=colors.red},
		[0x43] = {name="Skeleton", color=colors.red}, -- Green
		[0x44] = {name="Skeleton", color=colors.red}, -- Blue
		[0x45] = {name="Skeleton", color=colors.red}, -- Red
		[0x46] = {name="Chest Monster", color=colors.red},
		[0x47] = {name="Bat", color=colors.red}, -- Green
		[0x48] = {name="Bat", color=colors.red}, -- Blue
		[0x49] = {name="Bat", color=colors.red}, -- Red
		[0x4A] = {name="Googlybear", color=colors.red}, -- Green
		[0x4B] = {name="Googlybear", color=colors.red}, -- Blue
		[0x4C] = {name="Googlybear", color=colors.red}, -- Red
		[0x4D] = {name="Ghost", color=colors.red}, -- Blue, Drains Magic
		[0x4E] = {name="Ghost", color=colors.red}, -- Red, Drains Magic
		[0x4F] = {name="Demon", color=colors.red}, -- Green
		[0x50] = {name="Demon", color=colors.red}, -- Blue
		[0x51] = {name="Demon", color=colors.red}, -- Red
		[0x52] = {name="Ghost", color=colors.red}, -- Drains Magic
		[0x53] = {name="Cancer", color=colors.red}, -- Rusts Armour
		[0x54] = {name="Eye", color=colors.red}, -- Green
		[0x55] = {name="Eye", color=colors.red}, -- Blue
		[0x56] = {name="Eye", color=colors.red}, -- Red
		[0x57] = {name="Block Monster", color=colors.red}, -- Blue
		[0x58] = {name="Block Monster", color=colors.red}, -- Red
		[0x59] = {name="Mage", color=colors.red}, -- Blue
		[0x5A] = {name="Mage", color=colors.red}, -- Red
		[0x5B] = {name="Tub", color=colors.red},
		[0x5C] = {name="Shell Monster", color=colors.red}, -- Blue
		[0x5D] = {name="Shell Monster", color=colors.red}, -- Gold
		[0x5E] = {name="Spear Spawner", color=colors.yellow}, -- On walls usually
		[0x5F] = {name="Chicken Leg", color=colors.red}, -- Blue
		[0x60] = {name="Chicken Leg", color=colors.red}, -- Red
		[0x61] = {name="Spikeball", color=colors.red}, -- LR
		[0x62] = {name="Spikeball", color=colors.red}, -- UD
		[0x63] = {name="Dragon", color=colors.red}, -- Dungeon 2
		[0x64] = {name="Dragon", color=colors.red}, -- Dungeon 6
		[0x65] = {name="Big Skull Boss", color=colors.red}, -- Dungeon ??? -- TODO: Proper Name
		[0x66] = {name="Magic", color=colors.yellow}, -- Projecitle, Big Skull Boss -- TODO: Proper Name
		[0x67] = {name="Boss - Fake Fire Thingy", color=colors.red}, -- TODO: Proper Name
		[0x68] = {name="Boss 1", color=colors.red}, -- Dungeon 1
		--
		[0x6A] = {name="Boss Cloaky Magey Deathy Guy", color=colors.red}, -- Dungeon ??? -- TODO: Proper Name
		--
		[0x6D] = {name="Knight", color=colors.red}, -- Dungeon ???
		--
		[0x70] = {name="Sword", color=colors.yellow}, -- Projectile
		[0x71] = {name="Beam", color=colors.yellow}, -- Projectile, Blue Eye
		[0x72] = {name="Fireball", color=colors.yellow}, -- Projecitle, Boss Rush Dragon
		[0x73] = {name="Fireball", color=colors.yellow}, -- Projecitle, Dungeon 6 Dragon
		[0x74] = {name="Magic", color=colors.yellow}, -- Projecitle, Boss Cloaky Magey Deathy Guy -- TODO: Proper Name
		--
		[0x77] = {name="Spear", color=colors.yellow}, -- Projectile
		[0x78] = {name="Dragon", color=colors.red}, -- Boss Rush Version
		[0x79] = {name="Dragon", color=colors.red}, -- Boss Rush Version
		[0x7A] = {name="Knight", color=colors.red}, -- Boss Rush Version
		[0x7B] = {name="Red Knight", color=colors.red}, -- Boss Rush Version
		[0x7C] = {name="Boss Cloaky Magey Deathy Guy", color=colors.red}, -- Boss Rush Version -- TODO: Proper Name
	},
	vulnerable = 0x0C, -- Dying = 0x05, Spawning = 0x04, Vulnerable = 0x02,
	y_position = 0x10, -- u16_le
	x_position = 0x12, -- u16_le
	health = 0x18, -- Byte?
};

local mouseLastFrame = {
	Left = false,
	Middle = false,
	Right = false,
};

RNGSolver = {
	collisionArray = {}, -- 160 tile array
	spawnArray = {
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	}, -- 160 tile array
	positionRequired = 6, -- Minimum number of positions required
	mode = "SetSpawn", -- SetSpawn || SetCollision || Solve
	enabled = false,
};

function isVulnerable(object)
	return mainmemory.readbyte(object + object_fields.vulnerable) == 0x02;
end

function getTileIndex(object)
	local xPos = math.floor(mainmemory.read_u16_le(object + object_fields.x_position) / 256 / tileWidth);
	local yPos = math.floor(mainmemory.read_u16_le(object + object_fields.y_position) / 256 / tileHeight) - 8;
	return 1 + (yPos * 16 + xPos);
end

function toggle01(value)
	if value ~= 0 then
		return 0;
	else
		return 1;
	end
end

function killAllEnemies()
	for i = 0, object_array_capacity do
		local objectBase = object_array_base + (i * object_size);
		local objectType = mainmemory.readbyte(objectBase + object_fields.object_type);
		if objectType ~= 0 and objectType ~= 2 then
			--print("Killing enemy at "..objectBase);
			mainmemory.writebyte(objectBase + object_fields.health, 0);
			--mainmemory.writebyte(objectBase + object_fields.object_type, 1);
		end
	end
end

function Game.getHitboxes()
	local hitboxes = {};
	for i = 0, object_array_capacity do
		local hitbox = {
			objectBase = object_array_base + (i * object_size),
		};
		local objectType = mainmemory.readbyte(hitbox.objectBase + object_fields.object_type);
		if objectType ~= 0 then
			hitbox.dragTag = hitbox.objectBase;
			hitbox.objectType = "Unknown ("..toHexString(objectType)..")";
			hitbox.x = mainmemory.read_u16_le(hitbox.objectBase + object_fields.x_position) / 256;
			hitbox.y = mainmemory.read_u16_le(hitbox.objectBase + object_fields.y_position) / 256;
			hitbox.currentHP = mainmemory.readbyte(hitbox.objectBase + object_fields.health);

			if type(object_fields.object_types[objectType]) == "table" then
				local objectTypeTable = object_fields.object_types[objectType];
				hitbox.color = objectTypeTable.color or colors.white;
				hitbox.xOffset = objectTypeTable.hitbox_x_offset;
				hitbox.yOffset = objectTypeTable.hitbox_y_offset;
				hitbox.width = objectTypeTable.hitbox_width;
				hitbox.height = objectTypeTable.hitbox_height;

				if type(objectTypeTable.name) == "string" then
					hitbox.objectType = objectTypeTable.name.." "..toHexString(objectType);
				end
			end
			table.insert(hitboxes, hitbox);
		end
	end
	return hitboxes;
end

function Game.setHitboxPosition(hitbox, x, y)
	mainmemory.write_s16_le(hitbox.objectBase + object_fields.x_position, hitbox.x * 256);
	mainmemory.write_s16_le(hitbox.objectBase + object_fields.y_position, hitbox.y * 256);
end

function Game.getHitboxMouseOverText(hitbox)
	return {
		hitbox.objectType.." "..hitbox.currentHP.."HP",
		toHexString(hitbox.objectBase).." "..round(hitbox.x)..","..round(hitbox.y),
	};
end

function Game.getHitboxStaticText(hitbox)
	if hitbox.currentHP > 0 then
		return hitbox.currentHP;
	end
end

function Game.getHitboxListText(hitbox)
	return round(hitbox.x)..", "..round(hitbox.y).." - "..hitbox.objectType.." - "..hitbox.currentHP.."HP "..toHexString(hitbox.objectBase);
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultXOffset = -8;
	ScriptHawk.hitboxDefaultYOffset = -16;
	ScriptHawk.hitboxDefaultWidth = 16;
	ScriptHawk.hitboxDefaultHeight = 16;
	ScriptHawk.hitboxDefaultColor = colors.pink;
	return true;
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.current_hp, mainmemory.readbyte(Game.Memory.max_hp));
	mainmemory.writebyte(Game.Memory.current_magic, mainmemory.readbyte(Game.Memory.max_magic));
	mainmemory.writebyte(Game.Memory.horns, 0xFF);
	mainmemory.writebyte(Game.Memory.keys, 0xFF);
end

function Game.drawUI()
	local mouse = input.getmouse();
	if RNGSolver.enabled then
		if RNGSolver.mode == "SetSpawn" then
			if mouse.Left and mouse.X >= 0 and mouse.X < 256 and mouse.Y >= 0 and mouse.Y < 192 then
				if not mouseLastFrame.Left then
					local togglePosition = {
						x = math.floor(mouse.X / tileWidth),
						y = math.floor(mouse.Y / tileHeight),
					};
					RNGSolver.spawnArray[1 + (togglePosition.y * 16 + togglePosition.x)] = toggle01(RNGSolver.spawnArray[1 + (togglePosition.y * 16 + togglePosition.x)]);
				end
			end
			for x = 0, 16 do
				for y = 0, 9 do
					local color = 0x7FFF0000;
					if RNGSolver.spawnArray[1 + (y * 16 + x)] == 1 then
						color = 0x7F00FF00;
					end
					gui.drawRectangle(x * tileWidth, y * tileHeight, tileWidth, tileHeight, color, color);
				end
			end
		end
	end

	if mouse.Middle and not mouseLastFrame.Middle then
		drawCursor = not drawCursor;
	end

	-- Draw Mouse Cursor
	if drawCursor then
		gui.drawImage("beta/cursor.png", mouse.X, mouse.Y - 4);
	end

	mouseLastFrame.Left = mouse.Left;
	mouseLastFrame.Middle = mouse.Middle;
	mouseLastFrame.Right = mouse.Right;
end

Game.OSD = {
	-- TODO
};

return Game;