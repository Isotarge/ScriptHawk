local men = 0xE264; -- u16be
local breed_ticker = 0xE262; -- fixed 12.4 be
logging = true;
data = {};
local fixed_scaling_factor = 0.0125;

local prev_breed_ticker = 0;

function log()
	if not emu.islagged() then
		if logging then
			local _men = mainmemory.read_u16_be(men);
			local _breed_ticker = mainmemory.read_u16_be(breed_ticker) * fixed_scaling_factor;
			if _breed_ticker ~= prev_breed_ticker then
				table.insert(data, {emu.framecount(), _men, _breed_ticker});
				prev_breed_ticker = _breed_ticker;
			end
			if _men >= 100 then
				logging = false;
			end
		end
		if not logging then
			print("Frames,Men,Counter");
			for k, v in pairs(data) do
				print(k..","..v[2]..","..v[3]..",");
			end
			data = {};
		end
	end
end

event.onframestart(log);