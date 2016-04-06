-- DK64 C-Upless ledge clip angle/position finder
-- Written by Isotarge, 2015-2016

local player_pointer;

-- Relative to Objects in Model 1, some offsets are different on Kiosk
local x_pos = 0x7C; -- Float 32 bit Big Endian
local y_pos = x_pos + 4; -- Float 32 bit Big Endian
local z_pos = y_pos + 4; -- Float 32 bit Big Endian
local angle = 0xE6; -- u16_be

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

local x_increments = -0.002;

local maxAngle = 0x0FFF;
local angle_increments = 1;

running = true;

local initialFloor
local currentX = 0;
local currentAngle = 0;

local frames_since_set = 0;
local max_frames_since_set = 150;

local function plot_pos()
	if running then
		local playerObject = mainmemory.read_u24_be(player_pointer + 1);

		x = mainmemory.readfloat(playerObject + x_pos, true);
		y = mainmemory.readfloat(playerObject + y_pos, true);
		z = mainmemory.readfloat(playerObject + z_pos, true);

		if frames_since_set == 0 then
			savestate.loadslot(0);

			initialFloor = mainmemory.readfloat(playerObject + 0xA4, true);

			if currentAngle % 10 == 0 then
				print('testing angle='..currentAngle);
			end

			-- Set Angle
			local current_yrot = mainmemory.read_u16_be(playerObject + angle);
			mainmemory.write_u16_be(playerObject + angle, current_yrot + currentAngle);

			-- Set Position
			memory.writefloat(playerObject + x_pos, currentX, true);

			-- Update angle and position for next test
			currentAngle = currentAngle + angle_increments;

			if currentAngle >= maxAngle then
				currentAngle = 0;
				currentX = currentX + x_increments;
				print('testing new: x='..currentX);
			end
		end

		local currentFloor = mainmemory.readfloat(playerObject + 0xA4, true)
		local distanceToFloor = mainmemory.readfloat(playerObject + 0xB4, true);
		local controlState = mainmemory.readbyte(playerObject + 0x154);

		if controlState == 0x5B then
			frames_since_set = 0; -- Reset: Ledge grabbed
		elseif distanceToFloor == 0 and currentFloor < initialFloor then
			if x == currentX and z == currentZ then
				running = false;
				print('found solution: angle='..currentAngle..' x='..currentX);
			else
				frames_since_set = 0;
			end
		elseif frames_since_set > max_frames_since_set then
			frames_since_set = 0; -- Reset: Unknown failure
		else
			frames_since_set = frames_since_set + 1;
		end
	end
end

event.onframestart(plot_pos, "ScriptHawk - Ledge clip finder");