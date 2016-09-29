local HEADER = 0x60A90;
local pScale = 3000;
local vScale = 100000;

function drawOSD()
	local row = 0;
	local xOffset = 2;
	local yOffset = 70;
	local height = 16;

	local addr = mainmemory.read_u32_le(HEADER);
	if addr >= 0x80000000 and addr <= 0x80200000 then
		addr = addr - 0x80000000;
	else
		gui.text(xOffset, yOffset + row * height, "Crash not found...");
		return;
	end

	local X  = mainmemory.read_s32_le(addr + 0x60) / pScale;
	local Y  = mainmemory.read_s32_le(addr + 0x68) / pScale;
	local Z  = mainmemory.read_s32_le(addr + 0x64) / pScale;
	local XV = mainmemory.read_s32_le(addr + 0x84) / vScale;
	local YV = mainmemory.read_s32_le(addr + 0x8C) / vScale;
	local ZV = mainmemory.read_s32_le(addr + 0x88) / vScale;
	local V  = mainmemory.read_s32_le(addr + 0x104) / vScale;
	local XY = math.sqrt(XV*XV+YV*YV);
	local D  = mainmemory.read_s32_le(addr + 0x94) / 4096*360;
	local J  = mainmemory.read_u32_le(addr + 0x1B5);
	local BOXi = mainmemory.read_u32_le(0x6CC69);
	local BOXs = mainmemory.read_u32_le(0x6CDC1);
	local Level = mainmemory.read_u32_le(0x618DC);

	gui.text(xOffset, yOffset + row * height, string.format("%8x : Header", addr));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8d : Level", Level));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%4d/%3d : Box", BOXi, BOXs));
	row = row + 2;

	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Z  Pos", Z));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Z  Vel", ZV));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : X  Pos", X));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : X  Vel", XV));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Y  Pos", Y));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Y  Vel", YV));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : XY Vel", XY));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Velocity", V));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Jumps", J));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Degrees", D));
end

event.onframestart(drawOSD);
--[[
function key_input()
	local t = joypad.getdown(1);
	local a = {xleft = 128, yleft = 128, xright = 128, yright = 128};
	if t.right == true then
		a.xleft = 255;
	elseif t.left == true then
		a.xleft = 0;
	end
	if t.down == true then
		a.yleft = 255;
	elseif t.up == true then
		a.yleft = 0;
	end
	joypad.set(1,t)
	joypad.setanalog(1,a)
	joypad.setanalog(2,{xleft=128,yleft=128,xright=128,yright=128})
	--   joypad.setanalog(1,{xleft=132,yleft=0})
end

--emu.registerbefore(key_input)
]]--