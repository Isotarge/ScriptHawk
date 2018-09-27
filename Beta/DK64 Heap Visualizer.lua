-- DK64 Heap Visualizer
-- Originally written by MrCheeze
-- Cleanups & Optimizations by Isotarge

UPDATE_EVERY_N_FRAMES = 1;
dump_block_list = false;
free_only = false;

local dynamic_memory_start = 0x075200; -- TODO: Port to other versions
local dynamic_memory_end   = 0x539F10; -- TODO: Port to other versions
local dynamic_memory_len = dynamic_memory_end - dynamic_memory_start;

--------------------
-- Deferred print --
-- Thanks, Notwa  --
--------------------

local __dprinted = {};

function dprint(...) -- defer print
	-- helps with lag from printing directly to Bizhawk's console
	table.insert(__dprinted, {...});
end

function print_deferred()
	local buff = '';
	for i, t in ipairs(__dprinted) do
		if type(t) == 'string' then
			buff = buff..t..'\n';
		elseif type(t) == 'table' then
			local s = '';
			for j, v in ipairs(t) do
				s = s..tostring(v);
				if j ~= #t then s = s..'\t' end
			end
			buff = buff..s..'\n';
		end
	end
	if #buff > 0 then
		print(buff:sub(1, #buff - 1));
	end
	__dprinted = {};
end

event.onexit(function()
	gui.DrawNew("native");
end);

while true do
	if emu.framecount() % UPDATE_EVERY_N_FRAMES == 0 or client.ispaused() then
		gui.DrawNew("native"); -- Coordinates are now based on screen pixels rather than game pixels, and stuff is not erased automatically each frame.

		addr = dynamic_memory_start;
		screenwidth = client.screenwidth();

		gui.drawBox(0, 0, screenwidth, 50, 0x40000000, 0xFF00FF00);

		used_memory = 0;
		free_memory = 0;
		used_count = 0;
		free_count = 0;

		while addr >= dynamic_memory_start and addr < dynamic_memory_end do
			--prev_addr = mainmemory.read_u32_be(addr);
			blocksize = mainmemory.read_u32_be(addr + 0x04) + 0x10; -- Extra 0x10 bytes for the header
			next_free = mainmemory.read_u32_be(addr + 0x08);
			prev_free = mainmemory.read_u32_be(addr + 0x0C);
			next_addr = addr + blocksize;
			in_use = next_free == 0 and prev_free == 0;

			if in_use then
				used_memory = used_memory + blocksize;
				used_count = used_count + 1;
				bgcolor = 0xFF00FF00;
			else
				free_memory = free_memory + blocksize;
				free_count = free_count + 1;
				bgcolor = 0xFFFF0000;
			end

			gui.drawBox((addr - dynamic_memory_start) * screenwidth / dynamic_memory_len - 1, 0, (next_addr - dynamic_memory_start) * screenwidth / dynamic_memory_len + 1, 50, 0x40000000, bgcolor);

			if dump_block_list then
				dprint(string.format("addr:%X next_addr:%X  prev_free:%X next_free:%X  used:%s blocksize:%X", addr, next_addr, prev_free, next_free, tostring(in_use), blocksize - 0x10));
				--print(string.format("addr:%X  prev_addr:%X next_addr:%X  prev_free:%X next_free:%X  used:%s blocksize:%X", addr, prev_addr, next_addr, prev_free, next_free, tostring(in_use), blocksize - 0x10));
			end

			if free_only then
				addr = next_free - 0x80000000;
			else
				addr = next_addr;
			end
		end

		gui.drawText(24, 50, string.format("Used Memory: %X (%d blocks)", used_memory, used_count));
		gui.drawText(24, 65, string.format("Free Memory: %X (%d blocks)", free_memory, free_count));

		if dump_block_list then
			print_deferred();
		end
	end

	emu.frameadvance();
end