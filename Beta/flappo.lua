--c=37 h={c,53,c,69,c} m=memory.read_u8 event.oninputpoll(function()x=h[m(92)+1] joypad.set({["P1 Button"]=m(112)==4 or m(5)-x>=m(94)})end)

local game_mode = 0x70;
local y_velocity = 0x5e;

m = memory.read_u8;
ideal_height = { 37, 53, 37, 69, 37 };

function do_flappo()
	x = ideal_height[m(92)+1];
	joypad.set({["P1 Button"]= m(game_mode) == 4 or m(5) - x >= m(y_velocity)});
end

event.oninputpoll(do_flappo, "Flappo Bot");