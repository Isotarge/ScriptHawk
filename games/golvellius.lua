if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		map = 0x80D,
		health_orbs = 0x836, -- BCD
		gold_hundred_thousands = 0x83F, -- BCD
		gold_thousands = 0x840, -- BCD
		gold_tens = 0x841, -- BCD
		max_gold_hundred_thousands = 0x842, -- BCD
		max_gold_thousands = 0x843, -- BCD
		max_gold_tens = 0x844, -- BCD
		item_bitfield = 0x846,
		crystal_bitfield = 0x847,
		sword_damage = 0x848,
		bible_bitfield = 0x84F, -- 2 bytes
		hole_tile = 0xAD2,
	},
};

-- Configuration
alwaysHP = true;
enableDamageTimer = true;

colors.gold = 0xFFFFD700;
colors.green = 0xFF00AA00; -- Hair Color

-- Map stuff
local hole_contents = {
	[0] = "Crawky Crystal 30000G", -- Dungeon 5?
	[1] = "Rio", -- Fairy
	[2] = "Sword 50000G",
	[3] = "Rio", -- Fairy
	[4] = "Bible 5000G",
	[5] = "Boots 70000G",
	[6] = "Dina", -- Trade HP for Gold
	[7] = "Haidee Crystal 40000G", -- Dungeon 6?
	[8] = "Rio", -- Fairy
	[9] = "Bible 5000G",
	[10] = "Bachular's Dungeon", -- Dungeon 3
	[11] = "Bible 2000G",
	[12] = "Rio", -- Fairy
	[13] = "Rio", -- Fairy
	[14] = "Potion",
	[15] = "Rio", -- Fairy
	[16] = "Golvellius' Dungeon",
	[17] = "Rio", -- Fairy
	[18] = "Rio", -- Fairy
	[19] = "Rio", -- Fairy
	[20] = "Rio", -- Fairy
	[21] = "Potion",
	[22] = "Dina", -- Trade HP for Gold
	[23] = "Rio", -- Fairy
	[24] = "Pendant 25000G",
	[25] = "Winkle", -- Password
	[26] = "Wise Woman",
	[27] = "Rio", -- Fairy
	[28] = "Dina", -- Trade HP for Gold
	[29] = "Rio", -- Fairy
	[30] = "Randar",
	[31] = "Wise Woman", -- Golvellius Directions
	[32] = "Randar",
	[33] = "Rio", -- Fairy
	[34] = "Sword 12000G",
	[35] = "Rio", -- Fairy
	[36] = "Mea 6000G",
	[37] = "Rio", -- Fairy
	[38] = "Potion",
	[39] = "Bible 7000G",
	[40] = "Ring",
	[41] = "Rio", -- Fairy
	[42] = "Potion",
	[43] = "Winkle", -- Password
	[44] = "Rio", -- Fairy
	[45] = "Rio", -- Fairy
	[46] = "Wise Woman",
	[47] = "Bible 4000G",
	[48] = "Bachular's Crystal 8000G", -- Dungeon 3
	[49] = "Bible 1000G",
	[50] = "Annie", -- HP Restore
	[51] = "Rolick's Crystal 3000G", -- Dungeon 2
	[52] = "Wise Woman",
	[53] = "Annie", -- HP Restore
	[54] = "Bible 10000G",
	[55] = "Jasba's Dungeon", -- Crawky?
	[56] = "Rio", -- Fairy
	[57] = "Mirror 25000G",
	[58] = "Rio", -- Fairy
	[59] = "Rio", -- Fairy
	[60] = "Rio", -- Fairy
	[61] = "Randar",
	[62] = "Rio", -- Fairy
	[63] = "Rio", -- Fairy
	[64] = "Potion",
	[65] = "Rio", -- Fairy
	[66] = "Potion",
	[67] = "Wise Woman",
	[68] = "Rio", -- Fairy
	[69] = "Wise Woman",
	[70] = "Potion",
	[71] = "Rio", -- Fairy
	[72] = "Bible 8000G",
	[73] = "Potion",
	[74] = "Rio", -- Fairy
	[75] = "Rio", -- Fairy
	[76] = "Mea 1000G",
	[77] = "Rio", -- Fairy
	[78] = "Winkle", -- Password
	[79] = "Rio", -- Fairy
	[80] = "Shield 40000G",
	[81] = "Bible 2000G",
	[82] = "Rio", -- Fairy
	[83] = "Rio", -- Fairy
	[84] = "Haidee's Dungeon", -- Dungeon 6?
	[85] = "Rio", -- Fairy
	[86] = "Pendant 10000G",
	[87] = "Rio", -- Fairy
	[88] = "Rio", -- Fairy
	[89] = "Rio", -- Fairy
	[90] = "Randar",
	[91] = "Dina", -- Trade HP for Gold
	[92] = "Rio", -- Fairy
	[93] = "Boots 20000G",
	[94] = "Rio", -- Fairy
	[95] = "Rio", -- Fairy
	[96] = "Bible 10000G",
	[97] = "Rio", -- Fairy
	[98] = "Potion",
	[99] = "Rio", -- Fairy
	[100] = "Rio", -- Fairy
	[101] = "Annie", -- HP Restore
	[102] = "Bible 2000G",
	[103] = "Rio", -- Fairy
	[104] = "Rio", -- Fairy
	[105] = "Bible 5000G",
	[106] = "Rio", -- Fairy
	[107] = "Randar",
	[108] = "Potion",
	[109] = "Rio", -- Fairy
	[110] = "Rio?", -- Rio pretending to be Wise Woman?
	[111] = "Rio", -- Fairy
	[112] = "Potion",
	[113] = "Winkle", -- Password
	[114] = "Rio", -- Fairy
	[115] = "Winkle", -- Password
	[116] = "Shield 8000G",
	[117] = "Mea 15000G",
	[118] = "Rio", -- Fairy
	[119] = "Rio", -- Fairy
	[120] = "Rio", -- Fairy
	[121] = "Bible 4000G",
	[122] = "Winkle", -- Password
	[123] = "Rio", -- Fairy
	[124] = "Bible 3000G",
	[125] = "Randar",
	[126] = "Rolick's Dungeon", -- Dungeon 2
	[127] = "Bible 800G",
	[128] = "Potion",
	[129] = "Rio", -- Fairy
	[130] = "Rio", -- Fairy
	[131] = "Warlic's Dungeon", -- Dungeon 5
	[132] = "Potion",
	[133] = "Rio", -- Fairy
	[134] = "Rio", -- Fairy
	[135] = "Wise Woman",
	[136] = "Rio", -- Fairy
	[137] = "Rio", -- Fairy
	[138] = "Rio", -- Fairy
	[139] = "Rio", -- Fairy
	[140] = "Wise Woman",
	[141] = "Rio", -- Fairy
	[142] = "Potion",
	[143] = "Bible 3000G",
	[144] = "Rio", -- Fairy
	[145] = "Rio", -- Fairy
	[146] = "Wise Woman",
	[147] = "Potion",
	[148] = "Rio", -- Fairy
	[149] = "Annie", -- HP Restore
	[150] = "Potion",
	[151] = "Fosbus' Crystal 8000G", -- Dungeon 4
	[152] = "Potion",
	[153] = "Bible 500G",
	[154] = "Rio", -- Fairy
	[155] = "Potion",
	[156] = "Rio", -- Fairy
	[157] = "Warlic's Crystal 20000G",
	[158] = "Fairy?", -- Fairy pretending to be Wise Woman?
	[159] = "Rio", -- Fairy
	[160] = "Annie", -- HP Restore
	[161] = "Mea 8000G",
	[162] = "Bible 6000G",
	[163] = "Rio", -- Fairy
	[164] = "Fosbus' Dungeon", -- Dungeon 4
	[165] = "Rio", -- Fairy
	[166] = "Despa's Dungeon", -- Dungeon 1
	[167] = "Despa's Crystal 1000G", -- Dungeon 1
	[168] = "Rio", -- Fairy
	[169] = "Wise Woman", -- NPC Text
	[170] = "Rio", -- Fairy
	[171] = "Rio", -- Fairy
	[172] = "Bible 7000G",
	[173] = "Rio", -- Fairy
	[174] = "Ring 10000G",
	[175] = "Rio", -- Fairy
	[176] = "Dina", -- Trade HP for Gold
	[177] = "Rio", -- Fairy
	[178] = "Bible 4000G",
	[179] = "Randar",
	[180] = "None",
	[181] = "Rio", -- Fairy
	[182] = "None", -- Intro Cutscene Screen
};

function Game.getMap()
	return mainmemory.readbyte(Game.Memory.map);
end

function Game.getHoleContents()
	local map = Game.getMap();
	return hole_contents[map] or "Unknown";
end

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
		[0x8F] = {name="Fly", color=colors.red, max_hp=1},
		[0x90] = {name="Fly", gold=80, color=colors.red, max_hp=1},
		[0x91] = {name="Tick", gold=60, color=colors.red, max_hp=1},
		[0x92] = {name="Bat", gold=30, color=colors.red, max_hp=1}, -- Dark Blue
		[0x93] = {name="Little Big Bat", gold=0, color=colors.red, max_hp=0},
		[0x94] = {name="Big Bat", gold=0, color=colors.red, max_hp=16},
		[0x95] = {name="Spawning Enemy"},
		[0x96] = {name="Vortex", gold=220, color=colors.red, max_hp=6},
		[0x97] = {name="Vortex", gold=400, color=colors.red, max_hp=10}, -- TODO: Was listed as 9HP?
		[0x98] = {name="Death Lord", gold=500, color=colors.red, max_hp=15}, -- TODO: Figure out which bit of the item bitfield shows them properly
		[0x99] = {name="Crow", gold=40, color=colors.red, max_hp=1}, -- Black
		[0x9A] = {name="Crow", gold=90, color=colors.red, max_hp=2}, -- Blue
		[0x9B] = {name="Crow", gold=210, color=colors.red, max_hp=3}, -- Red
		[0x9C] = {name="Koranda", gold=350, color=colors.red, max_hp=14},
		[0x9D] = {name="Bat", gold=30, color=colors.red, max_hp=1}, -- Dark Blue
		[0x9E] = {name="Bat", gold=50, color=colors.red, max_hp=2}, -- Light Blue
		[0x9F] = {name="Bat", gold=200, color=colors.red, max_hp=2}, -- Red
		[0xA0] = {name="Bat", gold=300, color=colors.red, max_hp=6}, -- White
		[0xA1] = {name="Bat", gold=200, color=colors.red, max_hp=6}, -- Red
		[0xA2] = {name="Bee", gold=100, color=colors.red, max_hp=1}, -- Yellow
		[0xA3] = {name="Bee", gold=200, color=colors.red, max_hp=2}, -- Red
		[0xA4] = {name="Spider", gold=80, color=colors.red, max_hp=2}, -- Light Blue
		[0xA5] = {name="Spider", gold=180, color=colors.red, max_hp=5}, -- Dark Blue
		[0xA6] = {name="Spider", gold=280, color=colors.red, max_hp=5}, -- Red
		[0xA7] = {name="Health", color=colors.pink, particle=true},
		[0xA8] = {name="Frog", gold=40, color=colors.red, max_hp=2}, -- Green
		[0xA9] = {name="Frog", gold=200, color=colors.red, max_hp=3}, -- Red
		[0xAA] = {name="Snake", gold=10, color=colors.red, max_hp=1}, -- Red
		[0xAB] = {name="Snake", gold=40, color=colors.red, max_hp=2}, -- Blue
		[0xAC] = {name="Snake", gold=180, color=colors.red, max_hp=3}, -- Green
		[0xAD] = {name="Snake", gold=220, color=colors.red, max_hp=6}, -- White
		[0xAE] = {name="Jellyfish", gold=300, color=colors.red, max_hp=9}, -- Red
		[0xAF] = {name="Jellyfish", gold=400, color=colors.red, max_hp=15},
		[0xB0] = {name="Potato Bug", gold=100, color=colors.red, max_hp=4}, -- Green
		[0xB1] = {name="Potato Bug", gold=240, color=colors.red, max_hp=9}, -- White
		[0xB2] = {name="Porcupig", gold=30, color=colors.red, max_hp=2}, -- Red
		[0xB3] = {name="Porcupig", gold=100, color=colors.red, max_hp=4}, -- Blue
		[0xB4] = {name="Porcupig", gold=180, color=colors.red, max_hp=6},
		[0xB5] = {name="Troll", gold=120, color=colors.red, max_hp=6}, -- Red
		[0xB6] = {name="Troll", gold=330, color=colors.red, max_hp=6}, -- Blue
		[0xB7] = {name="Troll", gold=440, color=colors.red, max_hp=9},
		[0xB8] = {name="Knight", gold=100, color=colors.red, max_hp=6}, -- Blue
		[0xB9] = {name="Knight", gold=200, color=colors.red, max_hp=9}, -- Red
		[0xBA] = {name="Knight", gold=300, color=colors.red, max_hp=12},
		[0xBB] = {name="Skeleton", gold=120, color=colors.red, max_hp=4},
		[0xBC] = {name="Skeleton", gold=330, color=colors.red, max_hp=9}, -- Black
		[0xBD] = {name="Mouse", gold=200, color=colors.red, max_hp=6}, -- Blue
		[0xBE] = {name="Mouse", gold=400, color=colors.red, max_hp=9},
		[0xBF] = {name="Mole", gold=60, color=colors.red, max_hp=2}, -- Red
		[0xC0] = {name="Mole", gold=120, color=colors.red, max_hp=5}, -- Blue
		[0xC1] = {name="Mole", gold=200, color=colors.red, max_hp=6},
		[0xC2] = {name="Shark", gold=150, color=colors.red, max_hp=4},
		[0xC3] = {name="Shark", gold=150, color=colors.red, max_hp=4},
		--
		[0xD0] = {name="Despa", color=colors.red, max_hp=20},
		[0xD1] = {name="Rolick", color=colors.red, max_hp=36},
		[0xD2] = {name="Bachular", color=colors.red, max_hp=40},
		[0xD3] = {name="Fosbus", color=colors.red, max_hp=66},
		[0xD4] = {name="Warlic", color=colors.red, max_hp=56},
		[0xD5] = {name="Jasba", color=colors.red, max_hp=48}, -- Crawky?
		[0xD6] = {name="Haidee", color=colors.red, max_hp=127},
		[0xD7] = {name="Golvellius", color=colors.red, max_hp=120},
		[0xD8] = {name="Dying Boss?", particle=true},
		--
		[0xDB] = {name="Projectile", color=colors.yellow, particle=true},
		[0xDC] = {name="Dying Boss?", particle=true},
		[0xDD] = {name="Sword", color=colors.yellow, particle=true},
		--
		[0xDF] = {name="Axe", color=colors.yellow, particle=true},
		[0xE0] = {name="Despa Projectile", color=colors.yellow, particle=true},
		[0xE1] = {name="Bachular Projectile", color=colors.yellow, particle=true},
		[0xE2] = {name="Projectile", color=colors.yellow, particle=true}, -- Fosbus & Jasba/Crawky?
		[0xE3] = {name="Haidee Projectile", color=colors.yellow, particle=true},
		[0xE4] = {name="Golvellius' Projectile", color=colors.yellow, particle=true},
		[0xE5] = {name="Giant Snake", gold=0, color=colors.red, max_hp=5},
		--
		[0xE7] = {name="Giant Snake", gold=0, color=colors.red, max_hp=18},
		--
		[0xE9] = {name="Giant Snake", gold=0, color=colors.red, max_hp=36},
		[0xEA] = {name="Giant Snake", gold=0, color=colors.red, max_hp=6},
		--
		[0xEC] = {name="Giant Snake", gold=0, color=colors.red, max_hp=30},
		--
		[0xED] = {name="Snakelet Projectile", gold=10, color=colors.red, max_hp=1},
		--
		[0xEF] = {name="Projectile", color=colors.yellow, particle=true},
		--
		[0xF1] = {name="Snakelet Projectile", color=colors.red, max_hp=3},
		[0xF2] = {name="Snakelet Projectile", gold=10, color=colors.red, max_hp=1},
		--
		[0xF4] = {name="Snakelet Projectile", color=colors.red, max_hp=1},
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

local function getHolePosition()
	local holeTile = mainmemory.readbyte(Game.Memory.hole_tile);
	local xTile = holeTile % map_width;
	local yTile = math.floor(holeTile / map_width);
	return {xTile * 16 + 8, yTile * 16};
end

function Game.digHole()
	mainmemory.writebyte(map_base + mainmemory.readbyte(Game.Memory.hole_tile), 0x2B);
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
				hitbox.listcolor = hitbox.color;
				hitbox.textcolor = colors.gold;
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

	local HPString = "";
	if hitbox.hp > 0 then
		if hitbox.maxHP ~= "?" then
			HPString = " "..hitbox.hp.."/"..hitbox.maxHP.."HP";
		else
			HPString = " "..hitbox.hp.."HP";
		end
	end

	return {
		hitbox.objectType..HPString,
		toHexString(hitbox.objectBase).." "..hitbox.x..","..hitbox.y..goldString,
	};
end

function Game.getHitboxStaticText(hitbox)
	if hitbox.objectTypeNumeric == 0x95 then -- Spawning enemy should show countdown to spawn
		return mainmemory.readbyte(hitbox.objectBase + object_fields.spawn_timer);
	elseif hitbox.objectTypeNumeric == 0x84 then -- Sword should show Sword Timer
		return mainmemory.readbyte(hitbox.objectBase + object_fields.sword_timer);
	elseif (not alwaysHP) and hitbox.goldOnKill > 0 then
		return hitbox.goldOnKill;
	elseif hitbox.objectBase ~= 0x100 and not hitbox.isParticle then -- Everyone without a gold value should show their current/max HP (except the player)
		local damageTimerString = "";
		if enableDamageTimer then
			local damageTimer = mainmemory.readbyte(hitbox.objectBase + object_fields.damage_timer);
			if damageTimer > 0 then
				damageTimerString = " "..damageTimer;
			end
		end
		if hitbox.maxHP ~= "?" then
			return hitbox.hp.."/"..hitbox.maxHP..damageTimerString;
		else
			return hitbox.hp..damageTimerString;
		end
	end
end

function Game.getHitboxListText(hitbox)
	local goldString = " ";
	if hitbox.goldOnKill ~= nil and hitbox.goldOnKill > 0 then
		goldString = " - "..hitbox.goldOnKill.."G - ";
	end
	local HPString = "";
	if hitbox.hp > 0 then
		if hitbox.maxHP ~= "?" then
			HPString = hitbox.hp.."/"..hitbox.maxHP.."HP - ";
		else
			HPString = hitbox.hp.."HP - ";
		end
	end

	return hitbox.x..", "..hitbox.y.." - "..HPString..hitbox.objectType..goldString..toHexString(hitbox.objectBase);
end

function Game.unlockItems()
	mainmemory.writebyte(Game.Memory.item_bitfield, 0xFF);
	mainmemory.writebyte(Game.Memory.crystal_bitfield, 0xFF);
	mainmemory.write_u16_le(Game.Memory.bible_bitfield, 0xFFFF);
end

local function getGold()
	local tens = toHexString(mainmemory.readbyte(Game.Memory.gold_tens), 2, ""); -- 100000s
	local thousands = toHexString(mainmemory.readbyte(Game.Memory.gold_thousands), 2, ""); -- 1000s
	local hundred_thousands = toHexString(mainmemory.readbyte(Game.Memory.gold_hundred_thousands), 2, ""); -- 10s
	return hundred_thousands..thousands..tens.."0";
end

function Game.clearGold()
	mainmemory.writebyte(Game.Memory.gold_tens, 0x00);
	mainmemory.writebyte(Game.Memory.gold_thousands, 0x00);
	mainmemory.writebyte(Game.Memory.gold_hundred_thousands, 0x00);
end

function Game.applyInfinites()
	-- Gold
	--mainmemory.writebyte(Game.Memory.gold_tens, mainmemory.readbyte(Game.Memory.max_gold_tens));
	--mainmemory.writebyte(Game.Memory.gold_thousands, mainmemory.readbyte(Game.Memory.max_gold_thousands));
	--mainmemory.writebyte(Game.Memory.gold_hundred_thousands, mainmemory.readbyte(Game.Memory.max_gold_hundred_thousands));
	mainmemory.writebyte(Game.Memory.gold_tens, 0x99);
	mainmemory.writebyte(Game.Memory.gold_thousands, 0x99);
	mainmemory.writebyte(Game.Memory.gold_hundred_thousands, 0x99);

	-- Health
	mainmemory.writebyte(Game.Memory.health_orbs, 0x99);
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.button(0, 2, {4, 10}, nil, nil, "Unlock Items", Game.unlockItems);
		ScriptHawk.UI.button(0, 3, {4, 10}, nil, nil, "Clear Gold", Game.clearGold);
		ScriptHawk.UI.button(0, 4, {4, 10}, nil, nil, "Dig Hole", Game.digHole);
	end
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

	if gameMode == "overworld" and Game.getHoleContents() ~= "None" then -- Don't render hole position in dungeons
		local holePosition = getHolePosition();
		gui.drawRectangle(holePosition[1] + ScriptHawk.overscan_compensation.x, holePosition[2] + ScriptHawk.overscan_compensation.y, 16, 16, colors.green, 0x7F000000);
		gui.drawText(holePosition[1] + 3 + ScriptHawk.overscan_compensation.x, holePosition[2] + ScriptHawk.overscan_compensation.y, "H", colors.white, 0x00000000);
	end
end

Game.OSD = {
	{"Map", Game.getMap, category="mapData"},
	{"Hole", Game.getHoleContents, category="holeContents"},
};

return Game;