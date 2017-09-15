if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		["level"] = 0xF00, --u8?
		["level_time"] = 0x1A4, -- u16_le
		["lives"] = 0x100, -- s8
		["l_meter"] = 0x103, -- u8?
		["p_meter"] = 0x106, -- u8?
		["viewport_x_position"] = 0x120, -- u16_le
		["viewport_y_position"] = 0x122, -- u16_le
		["player_has_control"] = 0xF9, -- u8?
		["taz_x_position"] = 0x150, -- s16_le
		["taz_y_position"] = 0x152, -- s16_le
		["velocity_aerial"] = 0x110, -- s8
		["velocity_ground"] = 0x111, -- s8
		["jump_height"] = 0x141, -- u8
		["object_position_base"] = 0xC00,
		["object_status_base"] = 0x1100,
	},
	speedy_speeds = {0},
	speedy_index = 1,
	rot_speed = 0,
	max_rot_units = 0,
};

Game.cache = {};

function Game.detectVersion(romName, romHash)
	return true;
end

function Game.getXPosition()
	local viewportX = mainmemory.read_u16_le(Game.Memory.viewport_x_position);
	return viewportX;
	--local tazX = mainmemory.read_s16_le(Game.Memory.taz_x_position);
	--return viewportX + tazX;
end

function Game.getXPositionOSD()
	local frameCount = emu.framecount();
	if type(Game.cache[frameCount]) == "table" then
		return Game.getXPosition().." ("..Game.cache[frameCount].x..")";
	end
	return Game.getXPosition();
end

function Game.getYPosition()
	local viewportY = mainmemory.read_u16_le(Game.Memory.viewport_y_position);
	return viewportY;
	--local tazY = mainmemory.read_s16_le(Game.Memory.taz_y_position);
	--return viewportY + tazY;
end

function Game.getYPositionOSD()
	local frameCount = emu.framecount();
	if type(Game.cache[frameCount]) == "table" then
		return Game.getYPosition().." ("..Game.cache[frameCount].y..")";
	end
	return Game.getYPosition();
end

function Game.getJumpHeight()
	return mainmemory.read_u8(Game.Memory.jump_height);
end

function Game.colorJumpHeight()
	if forms.ischecked(ScriptHawk.UI.form_controls["Toggle Super Jump Checkbox"]) then
		return 0xFF00FFFF; -- Light Blue
	end
	if Game.getJumpHeight() ~= 0 then
		return 0xFF00FF00; -- Green
	end
end

function Game.getPMeter()
	return mainmemory.read_u8(Game.Memory.p_meter);
end

function Game.getPMeterOSD()
	local frameCount = emu.framecount();
	if type(Game.cache[frameCount]) == "table" then
		return Game.getPMeter().." ("..Game.cache[frameCount].p..")";
	end
	return Game.getPMeter();
end

function Game.getGroundVelocity()
	return mainmemory.read_s8(Game.Memory.velocity_ground);
end

function Game.getGroundVelocityOSD()
	local frameCount = emu.framecount();
	if type(Game.cache[frameCount]) == "table" then
		return Game.getGroundVelocity().." ("..Game.cache[frameCount].vg..")";
	end
	return Game.getGroundVelocity();
end

function Game.getAerialVelocity()
	return mainmemory.read_s8(Game.Memory.velocity_aerial);
end

function Game.getAerialVelocityOSD()
	local frameCount = emu.framecount();
	if type(Game.cache[frameCount]) == "table" then
		return Game.getAerialVelocity().." ("..Game.cache[frameCount].va..")";
	end
	return Game.getAerialVelocity();
end

function Game.colorDX()
	local dX = ScriptHawk.getDX();
	if dX == 0 then
		return 0xFFFF0000; -- Red
	end
	if dX == 1 or dX == 5 or dX == 7 then
		return 0xFFFFFF00; -- Yellow
	end
end

function Game.getLevel()
	return mainmemory.readbyte(Game.Memory.level);
end

function Game.getLevelTime()
	return mainmemory.read_u16_le(Game.Memory.level_time);
end

function Game.getLevelOSD()
	return Game.getLevel().." ("..Game.getLevelTime()..")";
end

function Game.applyInfinites()
	if mainmemory.readbyte(Game.Memory.player_has_control) > 0 then
		mainmemory.writebyte(Game.Memory.p_meter, 32);
		mainmemory.writebyte(Game.Memory.l_meter, 32);
	end
end

function Game.initUI()
	ScriptHawk.UI.form_controls["Toggle Super Jump Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Super Jump", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(4) + ScriptHawk.UI.dropdown_offset);
	ScriptHawk.UI.form_controls["Record Stats"] = forms.checkbox(ScriptHawk.UI.options_form, "Record Stats", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(3) + ScriptHawk.UI.dropdown_offset);
end

function Game.eachFrame()
	if forms.ischecked(ScriptHawk.UI.form_controls["Toggle Super Jump Checkbox"]) then
		mainmemory.write_u8(Game.Memory.jump_height, 0);
	end
	if forms.ischecked(ScriptHawk.UI.form_controls["Record Stats"]) then
		Game.cache[emu.framecount()] = {
			x = Game.getXPosition(),
			y = Game.getYPosition(),
			p = Game.getPMeter(),
			vg = Game.getGroundVelocity(),
			va = Game.getAerialVelocity(),
			igt = Game.getLevelTime()
		};
	end
end

Game.OSD = {
	{"X", Game.getXPositionOSD},
	{"Y", Game.getYPositionOSD},
	{"dX", nil, Game.colorDX},
	{"dY"},
	{"Separator", 1},
	{"P Meter", Game.getPMeterOSD},
	{"Velocity (Gnd)", Game.getGroundVelocityOSD},
	{"Velocity (Air)", Game.getAerialVelocityOSD},
	{"Jump", Game.getJumpHeight, Game.colorJumpHeight},
	{"Separator", 1},
	{"Level", Game.getLevelOSD},
	--{"IGT", Game.getLevelTime},
};

Game.OSDPosition = {114, 208};

-- Default to 16 width/height for hitbox
local hitboxWidth = 16;
local hitboxHeight = 16;

function Game.drawUI()
	local color = 0xFFFF0000; -- White

	local hitboxXOffset = 0;
	local hitboxYOffset = 0;
	if client.bufferheight() == 243 then -- Compensate for overscan
		hitboxXOffset = 13;
		hitboxYOffset = 27;
	end

	local row = 0;
	for i = 0, 31 do
		local statusBase = Game.Memory.object_status_base + i;
		local status = mainmemory.read_s8(statusBase);
		if status ~= -1 then
			local positionBase = Game.Memory.object_position_base + i * 0x04;
			local xPos = mainmemory.read_s16_le(positionBase + 0x00);
			local yPos = mainmemory.read_s16_le(positionBase + 0x02);
			--gui.text(2, 2 + row * Game.OSDRowHeight, toHexString(positionBase)..": ".."X: "..xPos..", Y:"..yPos, nil, "bottomright");
			--row = row + 1;
			gui.drawRectangle(xPos + hitboxXOffset, yPos + hitboxYOffset, hitboxWidth, hitboxHeight, color, 0x33000000); -- Draw the object's hitbox
			gui.drawText(xPos + hitboxXOffset, yPos + hitboxYOffset, status, color, 0x00000000);
		end
	end
end

return Game;