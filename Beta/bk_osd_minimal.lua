precision = 3;
function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num));
end

function getXPosition()
	return mainmemory.readfloat(0x37C5A0, true);
end

function getYPosition()
	return mainmemory.readfloat(0x37C5A4, true);
end

function getZPosition()
	return mainmemory.readfloat(0x37C5A8, true);
end

function getVelocity()
	local vX = mainmemory.readfloat(0x37C4B8, true);
	local vZ = mainmemory.readfloat(0x37C4C0, true);
	return math.sqrt(vX*vX + vZ*vZ);
end

function getYVelocity()
	return mainmemory.readfloat(0x37C4BC, true);
end

OSD = {
	{"X", getXPosition},
	{"Y", getYPosition},
	{"Z", getZPosition},
	{"Separator", 1},
	{"Velocity", getVelocity};
	{"Y Velocity", getYVelocity},
	{"Separator", 1},
};

function drawOSD()
	local row = 0;
	local OSDX = 2;
	local OSDY = 70;

	for i = 1, #OSD do
		local label = OSD[i][1];
		local value = OSD[i][2];

		if label ~= "Separator" then
			-- Get the value
			if type(value) == "function" then
				value = value();
			end

			-- Round the value
			if type(value) == "number" then
				value = round(value, precision);
			end

			gui.text(OSDX, OSDY + 16 * row, label..": "..value);
		else
			if type(value) == "number" and value > 1 then
				row = row + value - 1;
			end
		end
		row = row + 1;
	end
end

while true do
	drawOSD();
	emu.yield();
end