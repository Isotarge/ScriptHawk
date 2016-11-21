Game = { -- Versions: Japan, Australia, Europe, USA
	speedy_speeds = { .1, 1, 5, 10, 20, 35, 50, 75, 100 };
	speedy_index = 6;
	max_rot_units = 4,
	Memory = {
		["player_list_pointer"] = {0x12E914, 0x131594, 0x139A74, 0x130D84},
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

local characters = {
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
};

local playerColors = {
	[1] = 0xFFFF0000, -- Red
	[2] = 0xFF00FFFF, -- Blue
	[3] = 0xFFFFFF00, -- Yellow
	[4] = 0xFF00FF00, -- Green
};

local playerFields = {
	["NextPlayerPointer"] = 0x00, -- Pointer
	["Character"] = 0x0B, -- Byte?
	["Costume"] = 0x10, -- Byte?
	["FacingDirection"] = 0x44, -- s32_be -- -1 = left, 1 = right
	["YVelocity"] = 0x4C, -- Float
	["PositionDataPointer"] = 0x78, -- Pointer
	["PositionData"] = {
		["XPosition"] = 0x00, -- Float
		["YPosition"] = 0x04, -- Float
	},
	["JumpCounter"] = 0x148, -- Byte
	["InvinvibilityState"] = 0x5AC, -- u16_be
};

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
		return mainmemory.readbyte(playerActor + playerFields.Character);
	end
	return 0x1C; -- Default to none selected
end

function Game.getPlayerOSD(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		local character = Game.getCharacter(player);
		if type(characters[character]) == "string" then
			character = characters[character];
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
		local positionData = dereferencePointer(playerActor + playerFields.PositionDataPointer);
		if isRDRAM(positionData) then
			return mainmemory.readfloat(positionData + playerFields.PositionData.XPosition, true);
		end
	end
	return 0;
end

function Game.getYPosition(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		local positionData = dereferencePointer(playerActor + playerFields.PositionDataPointer);
		if isRDRAM(positionData) then
			return mainmemory.readfloat(positionData + playerFields.PositionData.YPosition, true);
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
		local positionData = dereferencePointer(playerActor + playerFields.PositionDataPointer);
		if isRDRAM(positionData) then
			mainmemory.writefloat(positionData + playerFields.PositionData.XPosition, value, true);
		end
	end
end

function Game.setYPosition(value, player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		Game.setYVelocity(0, player);
		local positionData = dereferencePointer(playerActor + playerFields.PositionDataPointer);
		if isRDRAM(positionData) then
			mainmemory.writefloat(positionData + playerFields.PositionData.YPosition, value, true);
		end
	end
end

function Game.setZPosition(value, player)
	return;
end

function Game.getYRotation(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		return mainmemory.read_s32_be(playerActor + playerFields.FacingDirection) + 1; -- Plus 1 here to make ScriptHawk display 0 and 180 degrees
	end
	return 0;
end

function Game.getYVelocity(player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		return mainmemory.readfloat(playerActor + playerFields.YVelocity, true);
	end
	return 0;
end

function Game.setYVelocity(value, player)
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		mainmemory.writefloat(playerActor + playerFields.YVelocity, value, true);
	end
end

Game.OSD = {
	{"P1", Game.getPlayerOSD, playerColors[1]},
	--{"Separator", 1},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Y Velocity", Game.getYVelocity},
	{"Facing", Game.getYRotation},
	{"Separator", 1},
	{"P2", function() return Game.getPlayerOSD(2) end, playerColors[2]},
	--{"Separator", 1},
	{"X", function() return Game.getXPosition(2) end},
	{"Y", function() return Game.getYPosition(2) end},
	{"Y Velocity", function() return Game.getYVelocity(2) end},
	{"Facing", function() return Game.getYRotation(2) end},
	{"Separator", 1},
	{"P3", function() return Game.getPlayerOSD(3) end, playerColors[3]},
	--{"Separator", 1},
	{"X", function() return Game.getXPosition(3) end},
	{"Y", function() return Game.getYPosition(3) end},
	{"Y Velocity", function() return Game.getYVelocity(3) end},
	{"Facing", function() return Game.getYRotation(3) end},
	{"Separator", 1},
	{"P4", function() return Game.getPlayerOSD(4) end, playerColors[4]},
	--{"Separator", 1},
	{"X", function() return Game.getXPosition(4) end},
	{"Y", function() return Game.getYPosition(4) end},
	{"Y Velocity", function() return Game.getYVelocity(4) end},
	{"Facing", function() return Game.getYRotation(4) end},
};

return Game;