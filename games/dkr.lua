local Game = {};

local player_object_pointer = 0x3FFFC0; -- TODO: Does this work for all versions?

local x_pos = 0x0C;
local y_pos = 0x10;
local z_pos = 0x14;

local y_velocity = 0xC0;
local velocity = 0xC4;

local camera_zoom = 0x12C;

local x_rot = 0x238; -- TODO
local facing_angle = 0x238;
local y_rot = facing_angle;
local z_rot = 0x238; -- TODO

Game.maps = { "Not Implemented" };

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if bizstring.contains(romName, "Europe") then
		-- TODO
	elseif bizstring.contains(romName, "Japan") then
		player_object_pointer = 0x3FFFC0;
	elseif bizstring.contains(romName, "USA") then
		-- TODO
	else
		return false;
	end

	return true;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { -.001, -.01, -.1, -1, -5, -10, -20, -50, -100 };
Game.speedy_index = 7;

Game.rot_speed = 100;
Game.max_rot_units = 65535;

function Game.isPhysicsFrame()
	return not emu.islagged();
end

function Game.getVelocity()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.readfloat(player_object + velocity, true);
end

--------------
-- Position --
--------------

function Game.getXPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.readfloat(player_object + x_pos, true);
end

function Game.getYPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.readfloat(player_object + y_pos, true);
end

function Game.getZPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.readfloat(player_object + z_pos, true);
end

function Game.setXPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	mainmemory.writefloat(player_object + x_pos, value, true);
end

function Game.setYPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	mainmemory.writefloat(player_object + y_velocity, 0, true);
	mainmemory.writefloat(player_object + y_pos, value, true);
end

function Game.setZPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	mainmemory.writefloat(player_object + z_pos, value, true);
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.read_u16_be(player_object + facing_angle); -- TODO
end

function Game.getYRotation()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.read_u16_be(player_object + facing_angle);
end

function Game.getZRotation()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.read_u16_be(player_object + facing_angle); -- TODO
end

function Game.setXRotation(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.write_u16_be(player_object + facing_angle, value);
end

function Game.setYRotation(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.write_u16_be(player_object + facing_angle, value);
end

function Game.setZRotation(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.write_u16_be(player_object + facing_angle, value);
end

-----------------------------
-- Optimal tapping script  --
-- Written by Faschz, 2015 --
-----------------------------

local otap_checkbox;
local otap_enabled = false;

local otap_startFrame = emu.framecount();
local otap_startLag = emu.lagcount();

-- Numbers optimized for TT with 0 bananas
local velocity_min = -9.212730408;
local velocity_med = -12.34942532;
local velocity_max = -14.22209072;

local function enableOptimalTap()
	local otap_startFrame = emu.framecount();
	local otap_startLag = emu.lagcount();
	otap_enabled = true;
	console.log("Auto tapper (by Faschz) enabled.");
end

local function disableOptimalTap()
	otap_enabled = false;
	console.log("Auto tapper disabled.");
end

local function optimalTap()
	local _velocity = Game.getVelocity();
	local frame = emu.framecount();

	if _velocity >= velocity_min then
		joypad.set({["A"] = true}, 1);
	elseif _velocity >= velocity_med and _velocity < velocity_min then
		if (frame - (otap_startFrame + (emu.lagcount() - otap_startLag))) % 2 == 0 then
			joypad.set({["A"] = true}, 1);
		else
			joypad.set({["A"] = false}, 1);
		end
	elseif _velocity >= velocity_max and _velocity < velocity_med then
		if (frame - (otap_startFrame + (emu.lagcount() - otap_startLag))) % 3 == 0 then
			joypad.set({["A"] = true}, 1);
		else
			joypad.set({["A"] = false}, 1);
		end
	elseif _velocity < velocity_max then
		if (frame - (otap_startFrame + (emu.lagcount() - otap_startLag))) % 4 == 0 then
			joypad.set({["A"] = true}, 1);
		else
			joypad.set({["A"] = false}, 1);
		end
	end
end

------------
-- Events --
------------

function Game.setMap(value)
	-- TODO
end

function Game.applyInfinites()
	-- TODO
end

function Game.initUI(form_handle, col, row, button_height, label_offset, dropdown_offset)
	otap_checkbox = forms.checkbox(form_handle, "Auto tapper", col(0) + dropdown_offset, row(6) + dropdown_offset);
end

function Game.eachFrame()
	if not otap_enabled and forms.ischecked(otap_checkbox) then
		enableOptimalTap();
	end

	if otap_enabled and not forms.ischecked(otap_checkbox) then
		disableOptimalTap();
	end

	if otap_enabled then
		optimalTap();
	end
end

return Game;