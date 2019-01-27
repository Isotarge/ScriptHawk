-------------------------------------------------------
-- A simple debug mode for Sonic the Hedgehog on SMS --
-- Written by The8bitbeast, 2016                     --
-------------------------------------------------------

local speed = 0x02;
local max_speed = 0x20;

local horizontal_velocity = 0x1404; -- signed integer 16 bit little endian -- TODO: It's actually s16.8 fixed point
local vertical_velocity = 0x1407; -- signed integer 16 bit little endian -- TODO: It's actually s16.8 fixed point

local function increment_speed()
	speed = math.min(max_speed, speed + 1);
end

local function decrement_speed()
	speed = math.max(1, speed - 1);
end

local formhandle = forms.newform(500, 250, "Debug");
local debugCheck = forms.checkbox(formhandle, "Debug On", 50, 50);
forms.button(formhandle, "+", increment_speed, 50, 70, 20, 20);
forms.button(formhandle, "-", decrement_speed, 150, 70, 20, 20);

local function debug()
	if forms.ischecked(debugCheck) then
		local bT = joypad.get();

		local up = bT["P1 Up"];
		local down = bT["P1 Down"];
		local left = bT["P1 Left"];
		local right = bT["P1 Right"];

		mainmemory.write_s8(0x1403, 0x00); -- TODO: All versions
		mainmemory.write_s16_le(horizontal_velocity, 0);
		mainmemory.write_s8(0x1406, 0x00); -- TODO: All versions
		mainmemory.write_s16_le(vertical_velocity, 0);

		if up and not down then
			mainmemory.write_s16_le(vertical_velocity, -speed);
		end

		if down and not up then
			mainmemory.write_s16_le(vertical_velocity, speed);
		end

		if left and not right then
			mainmemory.write_s16_le(horizontal_velocity, -speed);
		end

		if right and not left then
			mainmemory.write_s16_le(horizontal_velocity, speed);
		end
	end
end

event.onframestart(debug, "ScriptHawk - Debug Mode");