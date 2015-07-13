-- DK64 - ISG Timer
-- Written by Isotarge, 2015
-- Based on research by Exchord

prev_map = 0;

timer_value = 0;
timer_start_frame = 0;
timer_started = false;

-- TODO: Port to other regions/kiosk
map = 0x7444E7;

function timer ()
	map_value = mainmemory.readbyte(map);
	if (map_value == 153 and prev_map ~= 153) then
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
		s = timer_value / 60;
		timer_string = string.format("%.2d:%05.2f", s / 60 % 60, s % 60);
		gui.text(16, 16, "ISG Timer: "..timer_string, null, null, 'topright');
	else
		gui.text(16, 16, "Waiting for ISG", null, null, 'topright');
	end
end

event.onframestart(timer, "ISG Timer");