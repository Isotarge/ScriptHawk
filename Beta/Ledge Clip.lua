-- DK64 C-Upless ledge clip angle/position finder
-- Written by Isotarge, 2015

local kong_object_pointer = 0x7FBB4D; -- TODO: Port to other versions

-- Relative to kong object
local x_pos = 0x7C;
local y_pos = 0x80;
local z_pos = 0x84;
local angle = 0xe4;

local x = 0.0;
local y = 0.0;
local z = 0.0;

local ledgegrab_angles = {{140, 1910}, {2180, 3950}};

local start_x = 179.999;
local x_increments = -0.002;
-- > this means success, < this means failure
local end_x = 176.5;
local current_x = start_x;

local currentAngle = 0x0000;
local maxAngle = 0x0FFF;
local angle_increments = 1;

local running = true;

local ground = 20.0;

local frames_since_set = 0;
local max_frames_since_set = 150;

function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num));
end

local function rotate(axis, amount)
	local kong_object = mainmemory.read_u24_be(kong_object_pointer);
	local current_value = mainmemory.read_u16_be(kong_object + angle + axis * 2);
	mainmemory.write_u16_be(kong_object + angle + axis * 2, current_value + amount);
end

local function plot_pos()
	if running then
		local kong_object = mainmemory.read_u24_be(kong_object_pointer);

		x = mainmemory.readfloat(kong_object + x_pos, true);
		y = mainmemory.readfloat(kong_object + y_pos, true);
		z = mainmemory.readfloat(kong_object + z_pos, true);

		if frames_since_set == 0 then
			savestate.loadslot(0);

			if currentAngle % 10 == 0 then
				print('testing angle='..currentAngle);
			end

			-- Set angle and position
			rotate(1 , currentAngle);
			memory.writefloat(kong_object + x_pos, current_x, true);

			-- Update angle and position for next test
			currentAngle = currentAngle + angle_increments;

			if currentAngle >= maxAngle then
				currentAngle = 0;
				current_x = current_x + x_increments;
				print('testing new: x='..current_x);
			end

			-- Check to see if the ledge was grabbed
			for i = 1, #ledgegrab_angles do
				if currentAngle >= ledgegrab_angles[i][1] and currentAngle < ledgegrab_angles[i][2] then
					currentAngle = ledgegrab_angles[i][2];
				end
			end
		end

		if y <= ground then
			if x >= end_x then
				running = false;
				print('found solution: angle='..currentAngle..' x='..current_x);
			else
				frames_since_set = 0;
			end
		elseif frames_since_set > max_frames_since_set then
			if x >= end_x then
				running = false;
				print('found solution: angle='..currentAngle..' x='..current_x);
			else
				print('probably grabbed ledge...');
				frames_since_set = 0;
			end
		else
			frames_since_set = frames_since_set + 1;
		end
	end
end

event.onframestart(plot_pos, "ScriptHawk - Ledge clip finder");