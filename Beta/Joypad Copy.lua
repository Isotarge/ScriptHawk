-- Copies joypad inputs from player 1 to player 2, 3, and 4
local function copyJoypad()
	local buttons = joypad.get(1);
	for i = 2, 4 do
		joypad.set(buttons, i);
		joypad.setanalog(buttons, i);
	end
end
event.onframestart(copyJoypad, "ScriptHawk - Copy Joypad Inputs");