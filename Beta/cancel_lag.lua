local frames_real = 0x7F0560;
local frames_lag = 0x76AF10;

local function fix_lag()
	local frames_real_value = mainmemory.read_u32_be(frames_real);
	local frames_lag_value = mainmemory.read_u32_be(frames_lag);
	mainmemory.write_u32_be(frames_lag, frames_real_value - 1);
end

event.onframestart(fix_lag, "Fix Lag");