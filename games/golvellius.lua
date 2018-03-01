if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	OSD = {}, -- TODO
};

-- Configuration
alwaysHP = true;
enableDamageTimer = true;

colors.gold = 0xFFFFD700;
colors.green = 0xFF00AA00; -- Hair Color

local object_array_base = 0x100;
local object_size = 0x20;
local object_array_capacity = 16;

local object_fields = {
	object_type = 0x00, -- Byte
	object_types = {
		[0x4C] = {name="Player", color=colors.red}, -- Damaged, Vertical Dungeon
		--
		[0x59] = {name="Player", color=colors.red}, -- Damaged, Side Scroller
		--
		[0x5C] = {name="Dying Boss?", particle=true},
		--
		[0x5E] = {name="Player", color=colors.red}, -- Damaged, Overworld
		--
		[0x60] = {name="Despa Particle Spawning", particle=true},
		--
		[0x81] = {name="Player"}, -- Overworld
		[0x82] = {name="Player"}, -- Dungeon, Side Scroller
		[0x83] = {name="Player"}, -- Dungeon, Vertical
		[0x84] = {name="Sword", color=colors.yellow}, -- Player Sword
		--
		[0x86] = {name="Dying Enemy", particle=true},
		[0x87] = {name="Snakelet", gold=10, color=colors.red, max_hp=1},
		[0x88] = {name="Fire Spirit", gold=40, color=colors.red, max_hp=2},
		[0x89] = {name="Flea", gold=30, color=colors.red, max_hp=2},
		[0x8A] = {name="Basketworm", gold=20, color=colors.red, max_hp=2},
		[0x8B] = {name="Spider", gold=100, color=colors.red, max_hp=3},
		[0x8C] = {name="Health", color=colors.pink, particle=true},
		--
		[0x90] = {name="Fly", gold=80, color=colors.red, max_hp=1},
		[0x91] = {name="Tick", gold=60, color=colors.red, max_hp=1},
		[0x92] = {name="Dark Blue Bat", gold=30, color=colors.red, max_hp=1},
		[0x93] = {name="Little Big Bat", gold=0, color=colors.red, max_hp=0},
		[0x94] = {name="Big Bat", gold=0, color=colors.red, max_hp=16},
		[0x95] = {name="Spawning Enemy"},
		--
		[0x99] = {name="Black Crow", gold=40, color=colors.red, max_hp=1},
		[0x9A] = {name="Blue Crow", gold=90, color=colors.red, max_hp=2},
		[0x9B] = {name="Red Crow", gold=210, color=colors.red, max_hp=3},
		--
		[0x9D] = {name="Dark Blue Bat", gold=30, color=colors.red, max_hp=1},
		[0x9E] = {name="Light Blue Bat", gold=50, color=colors.red, max_hp=2},
		[0x9F] = {name="Red Bat", gold=200, color=colors.red, max_hp=2},
		[0xA0] = {name="White Bat", gold=300, color=colors.red, max_hp=6},
		[0xA1] = {name="Red Bat", gold=200, color=colors.red, max_hp=6},
		[0xA2] = {name="Yellow Bee", gold=100, color=colors.red, max_hp=1},
		[0xA3] = {name="Red Bee", gold=200, color=colors.red, max_hp=2},
		[0xA4] = {name="Light Blue Spider", gold=80, color=colors.red, max_hp=2},
		[0xA5] = {name="Dark Blue Spider", gold=180, color=colors.red, max_hp=5},
		[0xA6] = {name="Red Spider", gold=280, color=colors.red, max_hp=5},
		[0xA7] = {name="Health", color=colors.pink, particle=true},
		[0xA8] = {name="Green Frog", gold=40, color=colors.red, max_hp=2},
		[0xA9] = {name="Red Frog", gold=200, color=colors.red, max_hp=3},
		[0xAA] = {name="Red Snake", gold=10, color=colors.red, max_hp=1},
		[0xAB] = {name="Blue Snake", gold=40, color=colors.red, max_hp=2},
		[0xAC] = {name="Green Snake", gold=180, color=colors.red, max_hp=3},
		[0xAD] = {name="White Snake", gold=220, color=colors.red, max_hp=6},
		[0xAE] = {name="Red Jellyfish", gold=300, color=colors.red, max_hp=9},
		--
		[0xB0] = {name="Green Potato Bug", gold=100, color=colors.red, max_hp=4},
		[0xB1] = {name="White Potato Bug", gold=240, color=colors.red, max_hp=9},
		[0xB2] = {name="Red Porcupig", gold=30, color=colors.red, max_hp=2},
		[0xB3] = {name="Blue Porcupig", gold=100, color=colors.red, max_hp=4},
		--
		[0xB5] = {name="Red Troll", gold=120, color=colors.red, max_hp=6},
		[0xB6] = {name="Blue Troll", gold=330, color=colors.red, max_hp=6},
		--
		[0xB8] = {name="Blue Knight", gold=100, color=colors.red, max_hp=6},
		[0xB9] = {name="Red Knight", gold=200, color=colors.red, max_hp=9},
		--
		[0xBB] = {name="Skeleton", gold=120, color=colors.red, max_hp=4},
		[0xBC] = {name="Black Skeleton", gold=330, color=colors.red, max_hp=9},
		[0xBD] = {name="Blue Mouse", gold=200, color=colors.red, max_hp=6},
		--
		[0xBF] = {name="Red Mole", gold=60, color=colors.red, max_hp=2},
		[0xC0] = {name="Blue Mole", gold=120, color=colors.red, max_hp=5},
		--
		[0xD0] = {name="Despa", color=colors.red, max_hp=20},
		[0xD1] = {name="Rolick", color=colors.red, max_hp=36},
		[0xD2] = {name="Bachular", color=colors.red, max_hp=40},
		[0xD3] = {name="Fosbus", color=colors.red, max_hp=66},
		[0xD4] = {name="Warlic", color=colors.red, max_hp=56},
		-- 0xD5 Crawky
		-- 0xD6 Haidee
		-- 0xD7 Golvellius
		[0xD8] = {name="Dying Boss?", particle=true},
		--
		[0xDB] = {name="Projectile", color=colors.yellow, particle=true},
		[0xDC] = {name="Dying Boss?", particle=true},
		--
		[0xE0] = {name="Despa Projectile", color=colors.yellow, particle=true},
		[0xE1] = {name="Bachular Projectile", color=colors.yellow, particle=true},
		[0xE2] = {name="Fosbus Projectile", color=colors.yellow, particle=true},
		--
		[0xE5] = {name="Giant Snake", gold=0, color=colors.red, max_hp=5},
		--
		[0xEF] = {name="Projectile", color=colors.yellow, particle=true},
	},
	y_position = 0x01, -- u8
	x_position = 0x02, -- u8
	spawn_timer = 0x08, -- u8
	sword_timer = 0x0D, -- u8
	health = 0x15, -- u8
	damage_timer = 0x1F, -- u8
};

-- Map data
local map_base = 0xA00;
local map_width = 0x0F;
local map_height = 0x0C;

local function getHoleTile()
	return mainmemory.readbyte(0xAD2);
end

local function getHolePosition()
	local holeTile = getHoleTile();
	local xTile = holeTile % map_width;
	local yTile = math.floor(holeTile / map_width);
	return {xTile * 16 + 8, yTile * 16};
end

-- Lag Detection
local prevLag = -1;
function Game.isPhysicsFrame()
	local currentLag = mainmemory.readbyte(0x808);
	if Game.getGameMode() == "vertical" then -- Only detect lag for vertical dungeons
		if currentLag == prevLag then
			return false;
		end
	end
	prevLag = currentLag;
	return not emu.islagged();
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultWidth = 16;
	ScriptHawk.hitboxDefaultHeight = 16;
	ScriptHawk.hitboxDefaultcolor = colors.white;
	ScriptHawk.hitboxDefaultMode = ScriptHawk.hitboxModeWHCentered;
	return true;
end

function Game.getHitboxes()
	local hitboxes = {};
	for i = object_array_capacity, 0, -1 do
		local hitbox = {
			objectBase = object_array_base + (i * object_size),
		};
		local objectType = mainmemory.readbyte(hitbox.objectBase + object_fields.object_type);
		if objectType ~= 0 then
			hitbox.dragTag = hitbox.objectBase;
			hitbox.x = mainmemory.readbyte(hitbox.objectBase + object_fields.x_position);
			hitbox.y = mainmemory.readbyte(hitbox.objectBase + object_fields.y_position);
			hitbox.hp = mainmemory.readbyte(hitbox.objectBase + object_fields.health);
			hitbox.maxHP = "?";
			hitbox.goldOnKill = -1;
			hitbox.isParticle = false;
			hitbox.objectTypeNumeric = objectType;
			hitbox.objectType = "Unknown ("..toHexString(objectType)..")";

			if type(object_fields.object_types[objectType]) == "table" then
				local objectTypeTable = object_fields.object_types[objectType];
				hitbox.color = objectTypeTable.color;
				hitbox.xOffset = objectTypeTable.hitbox_x_offset;
				hitbox.yOffset = objectTypeTable.hitbox_y_offset;
				hitbox.width = objectTypeTable.hitbox_width;
				hitbox.height = objectTypeTable.hitbox_height;
				hitbox.goldOnKill = objectTypeTable.gold;
				hitbox.maxHP = objectTypeTable.max_hp or "?";
				hitbox.isParticle = type(objectTypeTable.particle) ~= "nil" and objectTypeTable.particle;

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
	mainmemory.writebyte(hitbox.objectBase + object_fields.x_position, x);
	mainmemory.writebyte(hitbox.objectBase + object_fields.y_position, y);
end

function Game.getHitboxMouseOverText(hitbox)
	local goldString = "";
	if hitbox.goldOnKill ~= nil and hitbox.goldOnKill > 0 then
		goldString = " "..hitbox.goldOnKill.."G";
	end

	return {
		hitbox.objectType.." "..hitbox.hp.."/"..hitbox.maxHP.." HP",
		toHexString(hitbox.objectBase).." "..hitbox.x..","..hitbox.y..goldString,
	};
end

function Game.getHitboxStaticText(hitbox)
	if hitbox.objectTypeNumeric == 0x95 then -- Spawning enemy should show countdown to spawn
		return mainmemory.readbyte(hitbox.objectBase + object_fields.spawn_timer);
	elseif hitbox.objectTypeNumeric == 0x84 then -- Sword should show Sword Timer
		return mainmemory.readbyte(hitbox.objectBase + object_fields.sword_timer); -- TODO: Color: gold
	elseif (not alwaysHP) and hitbox.goldOnKill > 0 then
		return hitbox.goldOnKill; -- TODO: Color: gold
	elseif hitbox.objectBase ~= 0x100 and not hitbox.isParticle then -- Everyone without a gold value should show their current/max HP (except the player)
		local damageTimerString = "";
		if enableDamageTimer then
			local damageTimer = mainmemory.readbyte(hitbox.objectBase + object_fields.damage_timer);
			if damageTimer > 0 then
				damageTimerString = " "..damageTimer;
			end
		end
		return hitbox.hp.."/"..hitbox.maxHP..damageTimerString; -- TODO: Color: gold
	end
end

function Game.getHitboxListText(hitbox)
	local goldString = " ";
	if hitbox.goldOnKill ~= nil and hitbox.goldOnKill > 0 then
		goldString = " - "..hitbox.goldOnKill.."G - ";
	end
	return hitbox.x..", "..hitbox.y.." - "..hitbox.hp.."/"..hitbox.maxHP.." HP - "..hitbox.objectType..goldString..toHexString(hitbox.objectBase);
end

local function getGold()
	local hundred_thousands = toHexString(mainmemory.readbyte(0x83F), 2, ""); -- 100000s
	local thousands = toHexString(mainmemory.readbyte(0x840), 2, ""); -- 1000s
	local tens = toHexString(mainmemory.readbyte(0x841), 2, ""); -- 10s
	return hundred_thousands..thousands..tens.."0";
end

local function getScreen()
	if Game.getGameMode() == "vertical" then
		return toHexString(mainmemory.readbyte(0x808), 2, "");
	end
	return toHexString(mainmemory.readbyte(0x809), 2, "");
end

function Game.getGameMode()
	local playerType = mainmemory.readbyte(0x100);
	local gameMode = "overworld";
	if playerType == 0x5E or playerType == 0x81 then
		gameMode = "overworld";
	elseif playerType == 0x4C or playerType == 0x83 then
		gameMode = "vertical";
	elseif playerType == 0x59 or playerType == 0x82 then
		gameMode = "horizontal";
	end
	return gameMode;
end

function Game.drawUI()
	local gameMode = Game.getGameMode();

	if gameMode == "vertical" then
		gui.drawText(197 + ScriptHawk.overscan_compensation.x, 1 + ScriptHawk.overscan_compensation.y, getScreen().." ScrY", 0xFF000000, 0);
	else
		if gameMode == "horizontal" then
			gui.drawRectangle(156 + ScriptHawk.overscan_compensation.x, 15 + ScriptHawk.overscan_compensation.y, 92, 13, 0, 0x7F000000);
			gui.drawText(156 + ScriptHawk.overscan_compensation.x, 14 + ScriptHawk.overscan_compensation.y, getScreen().." Screen X", colors.gold, 0);
		end
		gui.drawRectangle(156 + ScriptHawk.overscan_compensation.x, 2 + ScriptHawk.overscan_compensation.y, 92, 13, 0, 0x7F000000);
		gui.drawText(156 + ScriptHawk.overscan_compensation.x, 1 + ScriptHawk.overscan_compensation.y, getGold().." Gold", colors.gold, 0);
	end

	if gameMode == "overworld" then -- Don't render hole position in dungeons
		local holePosition = getHolePosition();
		gui.drawRectangle(holePosition[1] + ScriptHawk.overscan_compensation.x, holePosition[2] + ScriptHawk.overscan_compensation.y, 16, 16, colors.green, 0x7F000000);
		gui.drawText(holePosition[1] + 3 + ScriptHawk.overscan_compensation.x, holePosition[2] + ScriptHawk.overscan_compensation.y, "H", colors.white, 0x00000000);
	end
end

return Game;