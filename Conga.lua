local boggy_pointer = 0x36E560;

local slot_size = 0x80;
local throw_slot = 0x77;
local orange_timer = 0x1C;

local orange_timer_value = 0.5;

function set_orange_timer()
	joypad_pressed = joypad.getimmediate();
	if joypad_pressed["P1 L"] then
		local boggy_object = mainmemory.read_u24_be(boggy_pointer + 1);
		mainmemory.writefloat(boggy_object + throw_slot * slot_size + orange_timer, orange_timer_value, true);
		--console.log(bizstring.hex(boggy_object + throw_slot * slot_size + orange_timer));
	end
end

event.onframestart(set_orange_timer, "Conga");