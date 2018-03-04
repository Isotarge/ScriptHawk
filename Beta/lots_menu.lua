-- Plays around on the Lord of the Sword (UE) (SMS) menu
-- Written by Isotarge, 2015

local titleScreenLength = mainmemory.read_u16_le(0x104);
local mapStatus = mainmemory.readbyte(0xA0);

local frame = 0;
local distance = 1;

local input = true;

local function isOnTitleScreen()
	titleScreenLength = mainmemory.read_u16_le(0x104);
	mapStatus = mainmemory.readbyte(0xA0);
	return mapStatus == 0x03 and titleScreenLength > 0 and not emu.islagged();
end

local function do_menu()
	if isOnTitleScreen() then
		frame = frame + 1;
		if frame == distance then
			joypad.set({Up = input, Down = (not input)}, 1);
			input = not input;
			distance = distance + 1;
			frame = 0;
		else
			joypad.set({Up = false, Down = false}, 1);
		end
	else
		frame = 0;
		distance = 1;
	end
end

event.onframeend(do_menu, "ScriptHawk - LOTS menu");