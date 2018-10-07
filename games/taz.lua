if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		level = 0xF00, --u8?
		level_time = 0x1A4, -- u16_le
		lives = 0x100, -- s8
		l_meter = 0x103, -- u8?
		p_meter = 0x106, -- u8?
		viewport_x_position = 0x120, -- u16_le
		viewport_y_position = 0x122, -- u16_le
		player_has_control = 0xF9, -- u8?
		taz_x_position = 0x150, -- s16_le
		taz_y_position = 0x152, -- s16_le
		velocity_aerial = 0x110, -- s8
		velocity_ground = 0x111, -- s8
		jump_height = 0x141, -- u8
		object_position_base = 0xC00,
		object_status_base = 0x1100,
	},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultMode = ScriptHawk.hitboxModeWH;
	ScriptHawk.hitboxDefaultWidth = 16;
	ScriptHawk.hitboxDefaultHeight = 16;
	ScriptHawk.hitboxDefaultColor = colors.red;
	return true;
end

function Game.getXPosition()
	local viewportX = mainmemory.read_u16_le(Game.Memory.viewport_x_position);
	return viewportX;
	--local tazX = mainmemory.read_s16_le(Game.Memory.taz_x_position);
	--return viewportX + tazX;
end

function Game.getYPosition()
	local viewportY = mainmemory.read_u16_le(Game.Memory.viewport_y_position);
	return viewportY;
	--local tazY = mainmemory.read_s16_le(Game.Memory.taz_y_position);
	--return viewportY + tazY;
end

function Game.getJumpHeight()
	return mainmemory.read_u8(Game.Memory.jump_height);
end

function Game.colorJumpHeight()
	if ScriptHawk.UI.ischecked("Toggle Super Jump Checkbox") then
		return colors.blue;
	end
	if Game.getJumpHeight() ~= 0 then
		return colors.green;
	end
end

function Game.getPMeter()
	return mainmemory.read_u8(Game.Memory.p_meter);
end

function Game.getGroundVelocity()
	return mainmemory.read_s8(Game.Memory.velocity_ground);
end

function Game.getAerialVelocity()
	return mainmemory.read_s8(Game.Memory.velocity_aerial);
end

function Game.colorDX()
	local dX = ScriptHawk.getDX();
	if dX == 0 then
		return colors.red;
	end
	if dX == 1 or dX == 5 or dX == 7 then
		return colors.yellow;
	end
end

function Game.getLevel()
	return mainmemory.readbyte(Game.Memory.level);
end

function Game.getLevelTime()
	return mainmemory.read_u16_le(Game.Memory.level_time);
end

function Game.applyInfinites()
	if mainmemory.readbyte(Game.Memory.player_has_control) > 0 then
		mainmemory.writebyte(Game.Memory.p_meter, 32);
		mainmemory.writebyte(Game.Memory.l_meter, 32);
	end
end

function Game.initUI()
	ScriptHawk.UI.checkbox(0, 4, "Toggle Super Jump Checkbox", "Super Jump");
end

function Game.eachFrame()
	if ScriptHawk.UI.ischecked("Toggle Super Jump Checkbox") then
		mainmemory.write_u8(Game.Memory.jump_height, 0);
	end
end

Game.OSD = {
	{"X", category="position", tastudio_column=true, tastudio_column_width=40},
	{"Y", category="position"},
	{"dX", nil, Game.colorDX, category="positionStats", tastudio_column=true, tastudio_column_width=40},
	{"dY", category="positionStats"},
	{"Separator"},
	{"P Meter", Game.getPMeter, category="pmeter", tastudio_column=true, tastudio_column_width=50},
	{"Velocity (Gnd)", Game.getGroundVelocity, category="speed", tastudio_column=true, tastudio_column_width=90},
	{"Velocity (Air)", Game.getAerialVelocity, category="speed", tastudio_column=true, tastudio_column_width=90},
	{"Jump", Game.getJumpHeight, Game.colorJumpHeight, category="jumps", tastudio_column=true, tastudio_column_width=40},
	{"Separator"},
	{"Level", Game.getLevel, category="mapData"},
	{"IGT", Game.getLevelTime, category="igt"},
};

Game.OSDPosition = {114, 208};

function Game.getHitboxes()
	local hitboxes = {};
	for i = 0, 31 do
		local status = mainmemory.read_s8(Game.Memory.object_status_base + i);
		if status ~= -1 then
			local hitbox = {
				index = i,
				status = status,
				dragTag = Game.Memory.object_position_base + i * 0x04,
			};
			hitbox.x = mainmemory.read_s16_le(hitbox.dragTag + 0x00);
			hitbox.y = mainmemory.read_s16_le(hitbox.dragTag + 0x02);
			table.insert(hitboxes, hitbox);
		end
	end
	return hitboxes;
end

function Game.setHitboxPosition(hitbox, x, y)
	mainmemory.write_s16_le(hitbox.dragTag + 0x00, x);
	mainmemory.write_s16_le(hitbox.dragTag + 0x02, y);
end

function Game.getHitboxMouseOverText(hitbox)
	return {hitbox.status};
end
Game.getHitboxStaticText = Game.getHitboxMouseOverText;

return Game;