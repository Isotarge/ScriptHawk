Game = {
	speedy_speeds = { .1, 1, 5, 10, 20, 35, 50, 75, 100 };
	speedy_index = 6;
	max_rot_units = 4,
	Memory = { -- Versions: Japan, Australia, Europe, USA
		["match_settings_pointer"] = {0x0A30A8, 0x0A5828, 0x0AD948, 0x0A50E8},
		["hurtbox_color_RG"] = {nil, nil, nil, 0x0F2786},
		["hurtbox_color_BA"] = {nil, nil, nil, 0x0F279E},
		["hitbox_patch"] = {nil, nil, nil, 0x0F2C04}, -- 2400
		["red_hitbox_patch"] = {nil, nil, nil, 0x0F33BC}, -- 2400
		["purple_hurtbox_patch"] = {nil, nil, nil, 0x0F2FD0}, -- 2400
		["player_list_pointer"] = {0x12E914, 0x131594, 0x139A74, 0x130D84},
		["red_projectile_hurtbox_patch"] = {nil, nil, nil, 0x166F34},
		["projectile_hitbox_patch"] = {nil, nil, nil, 0x167578}, -- 2400
	},
	characters = {
		[0x00] = "Mario",
		[0x01] = "Fox",
		[0x02] = "DK",
		[0x03] = "Samus",
		[0x04] = "Luigi",
		[0x05] = "Link",
		[0x06] = "Yoshi",
		[0x07] = "Falcon",
		[0x08] = "Kirby",
		[0x09] = "Pikachu",
		[0x0A] = "Jigglypuff",
		[0x0B] = "Ness",
		[0x0C] = "Master Hand",
		[0x0D] = "Metal Mario",
		[0x0E] = "Polygon Mario",
		[0x0F] = "Polygon Fox",
		[0x10] = "Polygon DK",
		[0x11] = "Polygon Samus",
		[0x12] = "Polygon Luigi",
		[0x13] = "Polygon Link",
		[0x14] = "Polygon Yoshi",
		[0x15] = "Polygon Falcon",
		[0x16] = "Polygon Kirby",
		[0x17] = "Polygon Pikachu",
		[0x18] = "Polygon Jigglypuff",
		[0x19] = "Polygon Ness",
		[0x1A] = "Giant DK",
		--[0x1B] = "Crash",
		[0x1C] = "None", -- No character selected
	},
	maps = {
		"Peach's Castle", -- 0x00
		"Sector Z",
		"Congo Jungle",
		"Planet Zebes",
		"Hyrule Castle",
		"Yoshi's Island",
		"Dream Land",
		"Saffron City",
		"Mushroom Kingdom",
		"Dream Land Beta 1",
		"Dream Land Beta 2",
		"Demo Stage",
		"Yoshi's Island no clouds",
		"Metal Mario",
		"Polygon Team",
		"Race to the Finish!",
		"Final Destination", -- 0x10
		"Targets - Mario",
		"Targets - Fox",
		"Targets - DK",
		"Targets - Samus",
		"Targets - Luigi",
		"Targets - Link",
		"Targets - Yoshi",
		"Targets - Falcon",
		"Targets - Kirby",
		"Targets - Pikachu",
		"Targets - Jigglypuff",
		"Targets - Ness",
		"Platforms - Mario",
		"Platforms - Fox",
		"Platforms - DK",
		"Platforms - Samus", -- 0x20
		"Platforms - Luigi",
		"Platforms - Link",
		"Platforms - Yoshi",
		"Platforms - Falcon",
		"Platforms - Kirby",
		"Platforms - Pikachu",
		"Platforms - Jigglypuff",
		"Platforms - Ness", -- 0x28
	},
};

local playerColors = {
	[1] = 0xFFFF0000, -- Red
	[2] = 0xFF00FFFF, -- Blue
	[3] = 0xFFFFFF00, -- Yellow
	[4] = 0xFF00FF00, -- Green
};

local match_settings = {
	map = 0x01, -- Byte
	match_type = 0x03, -- Byte (bitfield?) Values: 0x01 = time, 0x02 = stock, 0x03 = timed stock match
	time = 0x06, -- Byte
	stock = 0x07, -- Byte
	p1_damage = 0x6C, -- u32_be -- Only applies to the UI, real damage is stored in the player object
	p2_damage = 0xE0, -- u32_be -- Only applies to the UI, real damage is stored in the player object
	p3_damage = 0x154, -- u32_be -- Only applies to the UI, real damage is stored in the player object
	p4_damage = 0x1C8, -- u32_be -- Only applies to the UI, real damage is stored in the player object
};

local player_fields = {
	["NextPlayerPointer"] = 0x00, -- Pointer
	["Character"] = 0x0B, -- Byte?
	["Costume"] = 0x10, -- Byte?
	["ShieldSize"] = 0x34, -- s32_be
	["FacingDirection"] = 0x44, -- s32_be -- -1 = left, 1 = right
	["XVelocity"] = 0x48, -- Float
	["YVelocity"] = 0x4C, -- Float
	["PositionDataPointer"] = 0x78, -- Pointer
	["PositionData"] = {
		["XPosition"] = 0x00, -- Float
		["YPosition"] = 0x04, -- Float
	},
	["JumpCounter"] = 0x148, -- Byte
	["ShieldBreakerRecoveryTimer"] = 0x26C, -- s32_be
	["InvinvibilityState"] = 0x5AC, -- u16_be
	["CharacterConstantsPointer"] = 0x9C8,
	["CharacterConstants"] = {
		["NumberOfJumps"] = 0x64,
	},
};

function Game.detectVersion(romName, romHash)
	if romHash == "4B71F0E01878696733EEFA9C80D11C147ECB4984" then -- Japan
		version = 1;
		return true;
	elseif romHash == "A9BF83FE73361E8D042C33ED48B3851D7D46712C" then -- Australia
		version = 2;
		return true;
	elseif romHash == "6EE8A41FEF66280CE3E3F0984D00B96079442FB9" then -- Europe
		version = 3;
		return true;
	elseif romHash == "E2929E10FCCC0AA84E5776227E798ABC07CEDABF" then -- USA -- TODO: 19XXTE?
		version = 4;
		return true;
	end
	return false;
end

function Game.setMap(index)
	local matchSettings = dereferencePointer(Game.Memory.match_settings_pointer[version]);
	if isRDRAM(matchSettings) then
		mainmemory.writebyte(matchSettings + match_settings.map, index - 1);
	end
end

function Game.getPlayer(player)
	if type(player) ~= "number" or player == 1 then
		return dereferencePointer(Game.Memory.player_list_pointer[version]);
	elseif player == 2 then
		local playerList = dereferencePointer(Game.Memory.player_list_pointer[version]);
		if isRDRAM(playerList) then
			return dereferencePointer(playerList);
		end
	elseif player == 3 then
		local playerList = dereferencePointer(Game.Memory.player_list_pointer[version]);
		if isRDRAM(playerList) then
			playerList = dereferencePointer(playerList);
			if isRDRAM(playerList) then
				return dereferencePointer(playerList);
			end
		end
	elseif player == 4 then
		local playerList = dereferencePointer(Game.Memory.player_list_pointer[version]);
		if isRDRAM(playerList) then
			playerList = dereferencePointer(playerList);
			if isRDRAM(playerList) then
				playerList = dereferencePointer(playerList);
				if isRDRAM(playerList) then
					return dereferencePointer(playerList);
				end
			end
		end
	end
end

function Game.getCharacter(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		return mainmemory.readbyte(playerActor + player_fields.Character);
	end
	return 0x1C; -- Default to none selected
end

function Game.getShieldSize(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		return mainmemory.read_s32_be(playerActor + player_fields.ShieldSize);
	end
	return 0;
end

function Game.getPlayerOSD(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		local character = Game.getCharacter(player);
		if type(Game.characters[character]) == "string" then
			character = Game.characters[character];
		else
			character = "Unknown ("..toHexString(character)..")";
		end
		return ""..toHexString(playerActor)..": "..character;
	end
	return "Not Found";
end

function Game.getXPosition(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		local positionData = dereferencePointer(playerActor + player_fields.PositionDataPointer);
		if isRDRAM(positionData) then
			return mainmemory.readfloat(positionData + player_fields.PositionData.XPosition, true);
		end
	end
	return 0;
end

function Game.getYPosition(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		local positionData = dereferencePointer(playerActor + player_fields.PositionDataPointer);
		if isRDRAM(positionData) then
			return mainmemory.readfloat(positionData + player_fields.PositionData.YPosition, true);
		end
	end
	return 0;
end

function Game.getZPosition(player)
	return 0;
end

function Game.setXPosition(value, player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		local positionData = dereferencePointer(playerActor + player_fields.PositionDataPointer);
		if isRDRAM(positionData) then
			mainmemory.writefloat(positionData + player_fields.PositionData.XPosition, value, true);
		end
	end
end

function Game.setYPosition(value, player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		Game.setYVelocity(0, player);
		local positionData = dereferencePointer(playerActor + player_fields.PositionDataPointer);
		if isRDRAM(positionData) then
			mainmemory.writefloat(positionData + player_fields.PositionData.YPosition, value, true);
		end
	end
end

function Game.setZPosition(value, player)
	return;
end

function Game.getYRotation(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		return mainmemory.read_s32_be(playerActor + player_fields.FacingDirection) + 1; -- Plus 1 here to make ScriptHawk display 0 and 180 degrees
	end
	return 0;
end

function Game.getXVelocity(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		return mainmemory.readfloat(playerActor + player_fields.XVelocity, true);
	end
	return 0;
end

function Game.getYVelocity(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		return mainmemory.readfloat(playerActor + player_fields.YVelocity, true);
	end
	return 0;
end

function Game.setYVelocity(value, player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		mainmemory.writefloat(playerActor + player_fields.YVelocity, value, true);
	end
end

Game.OSD = {
	{"P1", Game.getPlayerOSD, playerColors[1]},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"Facing", Game.getYRotation},
	{"Shield", Game.getShieldSize},
	{"Separator", 1},
	{"P2", function() return Game.getPlayerOSD(2) end, playerColors[2]},
	{"X", function() return Game.getXPosition(2) end},
	{"Y", function() return Game.getYPosition(2) end},
	{"X Velocity", function() return Game.getXVelocity(2) end},
	{"Y Velocity", function() return Game.getYVelocity(2) end},
	{"Facing", function() return Game.getYRotation(2) end},
	{"Shield", function() return Game.getShieldSize(2) end},
	{"Separator", 1},
	{"P3", function() return Game.getPlayerOSD(3) end, playerColors[3]},
	{"X", function() return Game.getXPosition(3) end},
	{"Y", function() return Game.getYPosition(3) end},
	{"X Velocity", function() return Game.getXVelocity(3) end},
	{"Y Velocity", function() return Game.getYVelocity(3) end},
	{"Facing", function() return Game.getYRotation(3) end},
	{"Shield", function() return Game.getShieldSize(3) end},
	{"Separator", 1},
	{"P4", function() return Game.getPlayerOSD(4) end, playerColors[4]},
	{"X", function() return Game.getXPosition(4) end},
	{"Y", function() return Game.getYPosition(4) end},
	{"X Velocity", function() return Game.getXVelocity(4) end},
	{"Y Velocity", function() return Game.getYVelocity(4) end},
	{"Facing", function() return Game.getYRotation(4) end},
	{"Shield", function() return Game.getShieldSize(4) end},
};

return Game;