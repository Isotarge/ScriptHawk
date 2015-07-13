-- DK64 - ISG Timer
-- Written by Isotarge, 2015
-- Based on research by Exchord

local map;
local romName = gameinfo.getromname();

if bizstring.contains(romName, "Donkey Kong 64") then
	if bizstring.contains(romName, "USA") then
		map = 0x7444E7;
	elseif bizstring.contains(romName, "Europe") then
		map = 0x73EC37;
	elseif bizstring.contains(romName, "Japan") then
		map = 0x743DA7;
	elseif bizstring.contains(romName, "Kiosk") then
		console.log("The kiosk version is not supported.");
		return;
	end
else
	console.log("This game is not supported.");
	return;
end

local prev_map = 0;
local timer_value = 0;
local timer_start_frame = 0;
local timer_started = false;

local function timer ()
	local map_value = mainmemory.readbyte(map);
	if map_value == 153 and prev_map ~= 153 then
		timer_value = 0;
		timer_start_frame = emu.framecount();
		timer_started = true;
	end
	prev_map = map_value;

	if timer_started then
		timer_value = emu.framecount() - timer_start_frame;
	end

	if timer_value / 60 > 270 or timer_value < 0 then
		timer_value = 0;
		timer_start_frame = 0;
		timer_started = false;
	end

	if timer_started then
		local s = timer_value / 60;
		local timer_string = string.format("%.2d:%05.2f", s / 60 % 60, s % 60);
		gui.text(16, 16, "ISG Timer: "..timer_string, null, null, 'topright');
	else
		gui.text(16, 16, "Waiting for ISG", null, null, 'topright');
	end
end

event.onframestart(timer, "ISG Timer");