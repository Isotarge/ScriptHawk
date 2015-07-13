-- DK64 C-Upless ledge clip angle/position finder
-- Written by Isotarge, 2015

kong_model_pointer = 0x7fbb4d;

-- Relative to kong model
x_pos = 0x7c;
y_pos = 0x80;
z_pos = 0x84;
angle = 0xe4;

x = 0.0;
y = 0.0;
z = 0.0;

ledgegrab_angles = {{140, 1910}, {2180, 3950}};

start_x = 179.999;
x_increments = -0.002;
-- > this means success, < this means failure
end_x = 176.5;
current_x = start_x;

currentAngle = 0x0000;
maxAngle = 0x0fff;
angle_increments = 1;

running = true;

ground = 20.0;

frames_since_set = 0;
max_frames_since_set = 150;

function round (num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num));
end

function rotate (axis, amount)
	local kong_model = mainmemory.read_u24_be(kong_model_pointer);
	local current_value = mainmemory.read_u16_be(kong_model + angle + axis * 2);
	mainmemory.write_u16_be(kong_model + angle + axis * 2, current_value + amount);
end

function plot_pos ()
	if running then
		local kong_model = mainmemory.read_u24_be(kong_model_pointer);

		x = mainmemory.readfloat(kong_model + x_pos, true);
		y = mainmemory.readfloat(kong_model + y_pos, true);
		z = mainmemory.readfloat(kong_model + z_pos, true);

		if frames_since_set == 0 then
			savestate.loadslot(0);

			if currentAngle % 10 == 0 then
				console.log('testing angle='..currentAngle);
			end

			-- Set angle and position
			rotate(1 , currentAngle);
			memory.writefloat(kong_model + x_pos, current_x, true);

			-- Update angle and position for next test
			currentAngle = currentAngle + angle_increments;

			if currentAngle >= maxAngle then
				currentAngle = 0;
				current_x = current_x + x_increments;
				console.log('testing new: x='..current_x);
			end
			
			for i=1,table.getn(ledgegrab_angles) do
				if currentAngle >= ledgegrab_angles[i][1] and currentAngle < ledgegrab_angles[i][2] then
					currentAngle = ledgegrab_angles[i][2];
				end
			end
		end

		if y <= ground then
			if x >= end_x then
				running = false;
				console.log('found solution: angle='..currentAngle..' x='..current_x);
			else
				frames_since_set = 0;
			end
		elseif frames_since_set > max_frames_since_set then
			if x >= end_x then
				running = false;
				console.log('found solution: angle='..currentAngle..' x='..current_x);
			else
				console.log('probably grabbed ledge...');
				frames_since_set = 0;
			end
		else
			frames_since_set = frames_since_set + 1;
		end
	end
end

event.onframestart(plot_pos, "Ledge Clip");