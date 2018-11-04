if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		x_pos = 0xB7A, -- u16_le
		y_pos = 0xB7C, -- u16_le
		time_minor = 0x1091,
		time_major = 0x1092,
		gun_type = 0x10A2,
		bombs = 0x139C,
		health = 0x13B2,
		screen_x = 0xDD9,
		screen_y = 0xDDB,
		mission = 0xF9C,
	},
	guns = {
		["Machine Gun 1"] = 0,
		["Machine Gun 2"] = 1,
		["Machine Gun 3"] = 2,
		["Machine Gun 4"] = 3,
		["Flamethrower"] = 4,
		["Rocket Launcher 1"] = 5,
		["Rocket Launcher 2"] = 6,
		["Shotgun"] = 7,
	},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

-- TODO: Make this more accurate
function Game.isPhysicsFrame()
	ScriptHawk.override_lag_detection = false;
	return true;
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.bombs, 9);
	mainmemory.writebyte(Game.Memory.health, 31);
	mainmemory.writebyte(Game.Memory.time_minor, 0x99);
	mainmemory.writebyte(Game.Memory.time_major, 0x99);
end

function Game.getHealth()
	return mainmemory.readbyte(Game.Memory.health);
end

function Game.getTime()
	local major = mainmemory.readbyte(Game.Memory.time_major);
	local minor = mainmemory.readbyte(Game.Memory.time_minor);
	return toHexString(major, 2, "")..toHexString(math.floor(minor / 16), 1, "").."."..toHexString(minor % 16, 1, "");
end

function Game.getGun()
	local value = mainmemory.readbyte(Game.Memory.gun_type);
	for k, v in pairs(Game.guns) do
		if value == v then
			return k;
		end
	end
	return "Unknown "..value;
end

function Game.setGun(index)
	mainmemory.writebyte(Game.Memory.gun_type, index);
end

function Game.setGunFromDropdown()
	local index = forms.gettext(ScriptHawk.UI.form_controls.gun_dropdown);
	Game.setGun(Game.guns[index] or 0);
end

function Game.getXPosition()
	return mainmemory.read_u16_le(Game.Memory.x_pos);
end

function Game.getYPosition()
	return mainmemory.read_u16_le(Game.Memory.y_pos);
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.form_controls.gun_dropdown = forms.dropdown(ScriptHawk.UI.options_form, { "Machine Gun 1", "Machine Gun 2", "Machine Gun 3", "Machine Gun 4", "Flamethrower", "Rocket Launcher 1", "Rocket Launcher 2", "Shotgun" }, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 8, ScriptHawk.UI.button_height);
		ScriptHawk.UI.button(5, 7, {4, 8}, nil, nil, "Set Gun", Game.setGunFromDropdown);
	end
end

local object = {
	array_start = 0xA00,
	array_end = 0xC31,
	size = 0x21,
	active = 0x09, -- byte?
	x_position = 0x0F, -- u16_le
	y_position = 0x11, -- u16_le
};

function Game.getHitboxes()
	-- Transform level space to framebuffer space
	ScriptHawk.hitboxDefaultXOffset = -mainmemory.read_u16_le(Game.Memory.screen_x);
	ScriptHawk.hitboxDefaultYOffset = -mainmemory.read_u16_le(Game.Memory.screen_y);

	local hitboxes = {};
	for i = object.array_start, object.array_end, object.size do
		local hitbox = {
			dragTag = i,
			x = mainmemory.read_u16_le(i + object.x_position),
			y = mainmemory.read_u16_le(i + object.y_position),
			width = 16,
			height = 16;
		};
		if mainmemory.readbyte(i + object.active) > 0 then
			table.insert(hitboxes, hitbox);
		end
	end
	return hitboxes;
end

function Game.setHitboxPosition(hitbox, x, y)
	mainmemory.write_u16_le(hitbox.dragTag + object.x_position, x);
	mainmemory.write_u16_le(hitbox.dragTag + object.y_position, y);
end

----[[
function Game.getHitboxListText(hitbox)
	return hitbox.x..", "..hitbox.y.." - "..toHexString(hitbox.dragTag);
end
--]]

--[[
function Game.getHitboxListText(hitbox)
	local byteString = "";
	for i = 0, object.size - 1 do
		if i < 0x0F or i > 0x12 then
			byteString = byteString..toHexString(mainmemory.readbyte(hitbox.dragTag + i), 2, "");
		end
	end
	return hitbox.x..", "..hitbox.y.." - "..byteString.." - "..toHexString(hitbox.dragTag);
end
--]]

local lagFrameLog = {};
local lagCountEvery1000 = {};
local lagCount = 0;

function Game.eachFrame()
	local currentFrame = emu.framecount();
	local consecutiveLag = 0;
	lagFrameLog[currentFrame] = emu.islagged();
	lagCount = 0;
	local firstFrame = 0;
	for i = math.floor(currentFrame / 1000) * 1000, 0, -1000 do
		if lagCountEvery1000[i] then
			lagCount = lagCountEvery1000[i].lagCount;
			consecutiveLag = lagCountEvery1000[i].consecutiveLag;
			firstFrame = i;
			break;
		end
	end
	for i = firstFrame, currentFrame do
		if lagFrameLog[i] then
			consecutiveLag = consecutiveLag + 1;
			if consecutiveLag > 3 then
				lagCount = lagCount + 1;
			end
		else
			consecutiveLag = 0;
		end
	end
	if currentFrame % 1000 == 0 then
		lagCountEvery1000[currentFrame] = {
			lagCount = lagCount,
			consecutiveLag = consecutiveLag,
		};
	end
end

function Game.getLagCount()
	return lagCount;
end

Game.OSD = {
	{"Lag", Game.getLagCount, category="lag"},
	{"Gun", Game.getGun, category="gun"},
	{"Time", Game.getTime, category="time"},
	{"Health", Game.getHealth, category="health"},
	{"X", category="position"},
	{"Y", category="position"},
	{"dX", category="positionStats"},
	{"dY", category="positionStats"},
	{"D. Health", function() return mainmemory.readbyte(0x1240); end, "health"},
	{"D. Health", function() return mainmemory.readbyte(0x1241); end, "health"},
	{"D. Health", function() return mainmemory.readbyte(0x138D); end, "health"},
};

return Game;