if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		is_map_rendering = 0xB73,
		player_x_position = 0xA0A,
		player_y_position = 0xA0B,
		player_movement_cooldown = 0xA0D,
		exit_x_position = 0xA70,
		exit_y_position = 0xA71,
	},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultMode = ScriptHawk.hitboxModeWH;
	ScriptHawk.hitboxDefaultWidth = 8;
	ScriptHawk.hitboxDefaultHeight = 8;
	ScriptHawk.hitboxDefaultColor = colors.red;
	return true;
end

function Game.getXPosition()
	return mainmemory.readbyte(Game.Memory.player_x_position);
end

function Game.getYPosition()
	return mainmemory.readbyte(Game.Memory.player_y_position);
end

function Game.getExitXPosition()
	return mainmemory.readbyte(Game.Memory.exit_x_position);
end

function Game.getExitYPosition()
	return mainmemory.readbyte(Game.Memory.exit_y_position);
end

function Game.getDXExit()
	return math.abs(Game.getXPosition() - Game.getExitXPosition());
end

function Game.getDYExit()
	return math.abs(Game.getYPosition() - Game.getExitYPosition());
end

function Game.getDExit()
	return Game.getDXExit() + Game.getDYExit();
end

function Game.getMovementCooldown()
	return mainmemory.readbyte(Game.Memory.player_movement_cooldown);
end

function Game.isMapRendering()
	return mainmemory.readbyte(Game.Memory.is_map_rendering) ~= 0;
end

function Game.isPhysicsFrame()
	return (not emu.islagged()) and (not (Game.isMapRendering() or Game.getMovementCooldown() > 0));
end

Game.OSD = {
	{"X", category="position", tastudio_column=true, tastudio_column_width=40},
	{"Y", category="position", tastudio_column=true, tastudio_column_width=40},
	{"Separator"},
	{"dXExit", Game.getDXExit, category="position"},
	{"dYExit", Game.getDYExit, category="position"},
	{"dExit", Game.getDExit, category="position", tastudio_column=true, tastudio_column_width=40},
	{"Separator"},
	{"Movement Cooldown", Game.getMovementCooldown, category="position", tastudio_column=true, tastudio_column_width=40},
	{"isMapRendering", Game.isMapRendering, tastudio_column=true, tastudio_column_width=40},
};

function Game.getHitboxes()
	local hitboxes = {
		{
			name = "Player",
			index = 0,
			x = Game.getXPosition() * 8,
			y = Game.getYPosition() * 8,
		},
		{
			name = "Exit",
			index = 1,
			x = Game.getExitXPosition() * 8,
			y = Game.getExitYPosition() * 8,
		},
	};
	-- TODO: Shovel
	-- TODO: Sword
	-- TODO: Enemies
	-- TODO: Exploders
	return hitboxes;
end

function Game.getHitboxMouseOverText(hitbox)
	return {hitbox.name};
end

return Game;