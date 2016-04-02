-- DK64 C-Upless ledge clip angle/position finder
-- Written by Isotarge, 2015-2016
-- TODO: Base this method on floor value, if the floor is lower and your XZ doesn't change you probably clipped

local player_pointer;

-- Relative to Objects in Model 1, some offsets are different on Kiosk
local x_pos = 0x7C; -- Float 32 bit Big Endian
local y_pos = x_pos + 4; -- Float 32 bit Big Endian
local z_pos = y_pos + 4; -- Float 32 bit Big Endian
local angle = 0xE4; -- u16_be

local romName = gameinfo.getromname();
if bizstring.contains(romName, "Donkey Kong 64") then
	if bizstring.contains(romName, "USA") and not bizstring.contains(romName, "Kiosk") then
		player_pointer = 0x7FBB4C;
	elseif bizstring.contains(romName, "Europe") then
		player_pointer = 0x7FBA6C;
	elseif bizstring.contains(romName, "Japan") then
		player_pointer = 0x7FBFBC;
	elseif bizstring.contains(romName, "Kiosk") then
		player_pointer = 0x7B5AFC;
		angle = 0xD8;
	end
else
	print("This game is not supported.");
	return false;
end

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
	local playerObject = mainmemory.read_u24_be(player_pointer + 1);
	local current_value = mainmemory.read_u16_be(playerObject + angle + axis * 2);
	mainmemory.write_u16_be(playerObject + angle + axis * 2, current_value + amount);
end

local function plot_pos()
	if running then
		local playerObject = mainmemory.read_u24_be(player_pointer + 1);

		x = mainmemory.readfloat(playerObject + x_pos, true);
		y = mainmemory.readfloat(playerObject + y_pos, true);
		z = mainmemory.readfloat(playerObject + z_pos, true);

		if frames_since_set == 0 then
			savestate.loadslot(0);

			if currentAngle % 10 == 0 then
				print('testing angle='..currentAngle);
			end

			-- Set angle and position
			rotate(1, currentAngle);
			memory.writefloat(playerObject + x_pos, current_x, true);

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