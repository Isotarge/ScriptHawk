local Game = {
	["Memory"] = {
		-- Version order: Europe, Japan, US 1.1, US 1.0
		["slope_timer"] = {0x37CCB4, 0x37CDE4, 0x37B4E4, 0x37C2E4},
		["player_grounded"] = {0x37C930, 0x37CA60, 0x37B160, 0x37BF60},
		["x_velocity"] = {0x37CE88, 0x37CFB8, 0x37B6B8, 0x37C4B8},
		["y_velocity"] = {0x37CE8C, 0x37CFBC, 0x37B6BC, 0x37C4BC},
		["z_velocity"] = {0x37CE90, 0x37CFC0, 0x37B6C0, 0x37C4C0},
		["x_position"] = {0x37CF70, 0x37D0A0, 0x37B7A0, 0x37C5A0},
		["y_position"] = {0x37CF74, 0x37D0A4, 0x37B7A4, 0x37C5A4},
		["z_position"] = {0x37CF78, 0x37D0A8, 0x37B7A8, 0x37C5A8},
		["x_rotation"] = {0x37CF10, 0x37D040, 0x37B740, 0x37C540},
		["y_rotation"] = {0x37D060, 0x37D190, 0x37B890, 0x37C690},
		["facing_angle"] = {0x37D060, 0x37D190, 0x37B890, 0x37C690},
		["moving_angle"] = {0x37D064, 0x37D194, 0x37B894, 0x37C694},
		["z_rotation"] = {0x37D050, 0x37D180, 0x37B880, 0x37C680},
	},
};

local ROMHash = gameinfo.getromhash();
if ROMHash == "BB359A75941DF74BF7290212C89FBC6E2C5601FE" then -- Europe
	Game.version = 1;
elseif ROMHash == "90726D7E7CD5BF6CDFD38F45C9ACBF4D45BD9FD8" then -- Japan
	Game.version = 2;
elseif ROMHash == "DED6EE166E740AD1BC810FD678A84B48E245AB80" then -- US 1.1
	Game.version = 3;
elseif ROMHash == "1FE1632098865F639E22C11B9A81EE8F29C75D7A" then -- US 1.0
	Game.version = 4;
else
	print("This game is not supported.");
	return false;
end

local precision = 3;
function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num));
end

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.x_position[Game.version], true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_position[Game.version], true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_position[Game.version], true);
end

function Game.getVelocity()
	local vX = mainmemory.readfloat(Game.Memory.x_velocity[Game.version], true);
	local vZ = mainmemory.readfloat(Game.Memory.z_velocity[Game.version], true);
	return math.sqrt(vX*vX + vZ*vZ);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity[Game.version], true);
end

local OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"Velocity", Game.getVelocity};
	{"Y Velocity", Game.getYVelocity},
	{"Separator", 1},
};

local function drawOSD()
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