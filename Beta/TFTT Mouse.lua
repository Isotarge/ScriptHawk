local cursorX = 0xB410;
local cursorY = 0xB412;

function doMouse()
	-- Make game cursor follow real cursor
	local mousePos = input.getmouse();
	mainmemory.write_u16_be(cursorX, mousePos.X * 2);
	mainmemory.write_u16_be(cursorY, (mousePos.Y * 2) - 40); -- Minus 40 pixels to compensate for Overscan

	if mousePos.Left then
		joypad.set({["B"] = true}, 1);
	end
	if mousePos.Right then
		joypad.set({["C"] = true}, 1);
	end
end

event.onframestart(doMouse);