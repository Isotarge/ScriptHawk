Game = {
	speedy_speeds = { .1, 1, 5, 10, 20, 35, 50, 75, 100 };
	speedy_index = 6;
	max_rot_units = 4,
	Memory = { -- Versions: Japan, Australia, Europe, USA
		["music"] = {0x098BD3, 0x099833, 0x0A2E63, 0x099113},
		["unlocked_stuff"] = {0x0A28F4, 0x0A5074, 0x0AD194, 0x0A4934},
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
	music = {
		"Dream Land", -- 0x00
		"Planet Zebes",
		"Mushroom Kingdom",
		"Mushroom Kingdom (Fast)",
		"Sector Z",
		"Congo Jungle",
		"Peach's Castle",
		"Saffron City",
		"Yoshi's Island",
		"Hyrule Castle",
		"Character Select",
		"Beta Fanfare",
		"Mario/Luigi Wins",
		"Samus Wins",
		"DK Wins",
		"Kirby Wins",
		"Fox Wins", -- 0x10
		"Ness Wins",
		"Yoshi Wins",
		"Captain Falcon Wins",
		"Pikachu/Jigglypuff Wins",
		"Link Wins",
		"Results Screen",
		"Pre-Master Hand",
		"Pre-Master Hand #2",
		"Master Hand Battle",
		"Bonus Stage",
		"Stage Clear",
		"Bonus Stage Clear",
		"Master Hand Clear",
		"Bonus Stage Failure",
		"Continue?",
		"Game Over", -- 0x20
		"Intro",
		"How to Play",
		"Pre-1P Battle",
		"Fighting Polygon Team",
		"Metal Mario Stage",
		"Game Complete",
		"Credits",
		"Found a Secret!",
		"Hidden Character",
		"Training Mode",
		"VS Record",
		"Main Menu",
		"Hammer",
		"Invincibility", -- 0x2E
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
	["ZVelocity"] = 0x50, -- Float
	["XAcceleration"] = 0x60, -- Float
	["YAcceleration"] = 0x64, -- Float
	["ZAcceleration"] = 0x68, -- Float
	["PositionDataPointer"] = 0x78, -- Pointer
	["PositionData"] = {
		["XPosition"] = 0x00, -- Float
		["YPosition"] = 0x04, -- Float
		["ZPosition"] = 0x08, -- Float
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
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		local positionData = dereferencePointer(playerActor + player_fields.PositionDataPointer);
		if isRDRAM(positionData) then
			return mainmemory.readfloat(positionData + player_fields.PositionData.ZPosition, true);
		end
	end
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
	local playerActor = Game.getPlayer(player);
	if isRDRAM(playerActor) then
		Game.setYVelocity(0, player);
		local positionData = dereferencePointer(playerActor + player_fields.PositionDataPointer);
		if isRDRAM(positionData) then
			mainmemory.writefloat(positionData + player_fields.PositionData.ZPosition, value, true);
		end
	end
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

function Game.unlockEverything()
	local value = mainmemory.readbyte(Game.Memory.unlocked_stuff[version] + 3);
	value = set_bit(value, 0); -- Luigi Unlock Battle Completed
	value = set_bit(value, 1); -- Ness Unlock Battle Completed
	value = set_bit(value, 2); -- Captain Falcon Unlock Battle Completed
	value = set_bit(value, 3); -- Jigglypuff Unlock Battle Completed
	value = set_bit(value, 4); -- Mushroom Kingdom Available
	value = set_bit(value, 5); -- Sound Test Unlocked
	value = set_bit(value, 6); -- Item Switch Unlocked
	mainmemory.writebyte(Game.Memory.unlocked_stuff[version] + 3, value);

	value = mainmemory.readbyte(Game.Memory.unlocked_stuff[version] + 4);
	value = set_bit(value, 2); -- Jigglypuff Selectable
	value = set_bit(value, 3); -- Ness Selectable
	mainmemory.writebyte(Game.Memory.unlocked_stuff[version] + 4, value);

	value = mainmemory.readbyte(Game.Memory.unlocked_stuff[version] + 5);
	value = set_bit(value, 4); -- Luigi Selectable
	value = set_bit(value, 7); -- Captain Falcon Selectable
	mainmemory.writebyte(Game.Memory.unlocked_stuff[version] + 5, value);
end

function Game.setMusic(value)
	mainmemory.writebyte(Game.Memory.music[version], value);
end

function Game.initUI()
	-- Unlock Everything Button
	ScriptHawk.UI.form_controls.unlock_everything_button = forms.button(ScriptHawk.UI.options_form, "Unlock Everything", Game.unlockEverything, ScriptHawk.UI.col(10), ScriptHawk.UI.row(0), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);

	-- Music
	ScriptHawk.UI.form_controls["Music Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, Game.music, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Music Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Set Music", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset);
end

function Game.eachFrame()
	if forms.ischecked(ScriptHawk.UI.form_controls["Music Checkbox"]) then
		local musicString = forms.gettext(ScriptHawk.UI.form_controls["Music Dropdown"]);
		for i = 1, #Game.music do
			if Game.music[i] == musicString then
				Game.setMusic(i - 1);
			end
		end
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