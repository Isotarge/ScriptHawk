local slot = {}
local slotAddress = {}
local slotCount = 3

function getSlots()
	pointer = mainmemory.read_u8(0x10DC)
	for i = 1,slotCount do
		slotAddress[i] = 0x10A5+pointer+i
		if slotAddress[i] > 0x10DB then
			slotAddress[i] = slotAddress[i] - 0x37
		end
		slot[i] = mainmemory.read_u8(slotAddress[i])
	end
	return slot
end

function draw_ui()
	slot = getSlots()
	local gui_x = 0;
	local gui_y = 32;
	local row = 3;
	local height = 16;
	
	for i  = 1,#slot do
		crit = "       "
		if slot[i]%8 == 7 or (slot[i]%8 == 6 and ((slot[i] < 0x80 and slot[i] > 0x3F) or (slot[i] > 0xBF)))then
			crit = " (crit)"
		end
		gui.text(gui_x, gui_y + height * row, bizstring.hex(slotAddress[i])..": "..bizstring.hex(slot[i])..crit, nil, nil, 'topleft');
		row = row+1
	end
end

event.onframestart(draw_ui);