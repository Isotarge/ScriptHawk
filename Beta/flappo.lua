-- Original minified bot
-- Written by Isotarge, 2014
--c=37 h={c,53,c,69,c} m=memory.read_u8 event.oninputpoll(function()x=h[m(92)+1] joypad.set({Button=m(112)==4 or m(5)-x>=m(94)},1)end)

local game_mode = 0x70;
local y_velocity = 0x5E;
local screen_type = 0x5C;

local y_position = {
	0x05,
	0x1D,
};

ideal_height = { 39, 55, 37, 69, 37 };

function do_flappo()
	x = ideal_height[mainmemory.read_u8(screen_type) + 1];
	--joypad.set({["P1 Button"]= mainmemory.read_u8(game_mode) == 4 or mainmemory.read_u8(y_position[1]) - x >= mainmemory.read_u8(y_velocity)});
	for i = 1, #y_position do
		mainmemory.writebyte(y_position[i], x);
	end
end

event.oninputpoll(do_flappo, "ScriptHawk - Flappo Bot");