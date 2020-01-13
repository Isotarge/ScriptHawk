function pokeLag()
	inputs = joypad.getimmediate();
	if inputs["P1 C Up"] or inputs["P1 L"] then
		mainmemory.writebyte(0x400000, 1);
	end
end

event.onframestart(pokeLag);
