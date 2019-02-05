TASSafe = true;
local function writeblock(...)
	--print("Memory write blocked! Your TAS is safe!");
end

emu.setregister = writeblock;
nes.addgamegenie = writeblock;

mainmemory.writebyte = writeblock;
mainmemory.writebyterange = writeblock;
mainmemory.write_u8 = writeblock;
mainmemory.writefloat = writeblock;
mainmemory.write_s8 = writeblock;
mainmemory.write_u8 = writeblock;
mainmemory.write_s16_le = writeblock;
mainmemory.write_s16_be = writeblock;
mainmemory.write_u16_le = writeblock;
mainmemory.write_u16_be = writeblock;
mainmemory.write_s24_le = writeblock;
mainmemory.write_s24_be = writeblock;
mainmemory.write_u24_le = writeblock;
mainmemory.write_u24_be = writeblock;
mainmemory.write_s32_le = writeblock;
mainmemory.write_s32_be = writeblock;
mainmemory.write_u32_le = writeblock;
mainmemory.write_u32_be = writeblock;

memory.writebyte = writeblock;
memory.writebyterange = writeblock;
memory.write_u8 = writeblock;
memory.writefloat = writeblock;
memory.write_s8 = writeblock;
memory.write_u8 = writeblock;
memory.write_s16_le = writeblock;
memory.write_s16_be = writeblock;
memory.write_u16_le = writeblock;
memory.write_u16_be = writeblock;
memory.write_s24_le = writeblock;
memory.write_s24_be = writeblock;
memory.write_u24_le = writeblock;
memory.write_u24_be = writeblock;
memory.write_s32_le = writeblock;
memory.write_s32_be = writeblock;
memory.write_u32_le = writeblock;
memory.write_u32_be = writeblock;

local result = require("ScriptHawk");

if result == true then
	print("This is a special version of ScriptHawk designed to be used while TASing");
	print("All memory writes are blocked");
	print("Some features may be unavailable in this mode");
	ScriptHawk.mode = "TAS";
	while true do
		if client.ispaused() then
			gui.cleartext();
			--gui.clearGraphics();
			ScriptHawk.UI.updateReadouts();
			ScriptHawk.modifyOSDUI.updateReadouts();
			ScriptHawk.drawHitboxes();
			Game.drawUI();
		end
		ScriptHawk.processKeybinds(ScriptHawk.keybindsRealtime);
		ScriptHawk.processJoypadBinds(ScriptHawk.joypadBindsRealtime);
		ScriptHawk.processMouseBinds(ScriptHawk.mouseBinds);
		Game.realTime();
		emu.yield();
	end
end