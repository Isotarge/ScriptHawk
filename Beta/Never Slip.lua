-- DK64 - NeverSlip
-- Written by Isotarge, 2014

--Pointers
slope_object_pointer = 0x7f94b9;
slope_object_pointer_2 = 0x7fd581;

--Relative to slope object
slope_timer = 0xc3;

function neverslip ()
	slope_object = mainmemory.read_u24_be(slope_object_pointer);
	mainmemory.write_u8(slope_object + slope_timer, 0);
end

event.onframestart(neverslip, "NeverSlip");