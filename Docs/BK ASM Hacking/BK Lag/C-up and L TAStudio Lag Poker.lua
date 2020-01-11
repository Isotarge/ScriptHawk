function pokeLag()
	local inputs = joypad.getimmediate();
	local inputsTS = movie.getinput(emu.framecount());
	if inputs["P1 C Up"] or inputs["P1 L"] then
		mainmemory.writebyte(0x400000, 1);
	end
	if inputsTS["P1 C Up"] or inputsTS["P1 L"] then
		mainmemory.writebyte(0x400000, 1);
	end
end

event.onframestart(pokeLag);