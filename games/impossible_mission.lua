if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		current_map = 0x97,
		horizontal_map_position = 0x98,
		x_position = 0x180,
		y_position = 0x181,
		gametime = {
			hours = 0x00CA,
			minutes = 0x00CB,
			seconds = 0x00CC,
			centiseconds = 0x00CD,
		},
		map_addresses = {
			0x1B5A, 0x1B5C, 0x1B5E, 0x1B60, 0x1B62, 0x1B64, 0x1B66, 0x1B68, 0x1B6A,
			0x1B6B, 0x1B6D, 0x1B6F, 0x1B71, 0x1B73, 0x1B75, 0x1B77, 0x1B79, 0x1B7B,
			0x1B7C, 0x1B7E, 0x1B80, 0x1B82, 0x1B84, 0x1B86, 0x1B88, 0x1B8A, 0x1B8C,
			0x1B8D, 0x1B8F, 0x1B91, 0x1B93, 0x1B95, 0x1B97, 0x1B99, 0x1B9B, 0x1B9D,
			0x1B9E, 0x1BA0, 0x1BA2, 0x1BA4, 0x1BA6, 0x1BA8, 0x1BAA, 0x1BAC, 0x1BAE,
			0x1BAF, 0x1BB1, 0x1BB3, 0x1BB5, 0x1BB7, 0x1BB9, 0x1BBB, 0x1BBD, 0x1BBF,
		},
		maps = {
			[0x05] = "Good Room (9)",
			[0x0F] = "Ending",
			[0x1E] = "Puzzle", -- Light green
			[0x1F] = "Puzzle", -- Dark Grey
			[0x20] = "Glitchy Puzzle", -- Light Grey
			[0x21] = "Glitchy Puzzle", -- Yellow
			[0x22] = "Glitchy Puzzle", -- Green
			[0x23] = "Glitchy Puzzle", -- Cyan
			[0x7F] = "Empty",
		},
	},
	speedy_speeds = {},
	max_rot_units = 0,
	bestPieceDistribution = 100,
};

function Game.detectVersion(romName, romHash)
	return true;
end

object_arrays = { -- Use indexes from maps array
	[0x00] = {start=0x11D7, objects=4, exits="ur"},
	[0x01] = {start=0x11EC, objects=3, exits="dr"},
	[0x02] = {start=0x1201, objects=5, exits="dr"},
	[0x03] = {start=0x121A, objects=2, exits="dl,ur"},
	[0x04] = {start=0x1227, objects=6, exits="dl,ur"},
	[0x05] = {start=0x1244, objects=9, exits="ul"},
	[0x06] = {start=0x126D, objects=5, exits="dl,ur"},
	[0x07] = {start=0x1286, objects=5, exits="dr"},
	[0x08] = {start=0x12A3, objects=3, exits="ul,dr"},
	[0x09] = {start=0x12B4, objects=6, exits="ul"},
	[0x0A] = {start=0x12D1, objects=3, exits="dl,dr"},
	[0x0B] = {start=0x12E6, objects=2, exits="dl,ur"},
	[0x0C] = {start=0x12F7, objects=3, exits="ul"},
	[0x0D] = {start=0x130C, objects=4, exits="ul,dr"},
	[0x0E] = {start=0x1321, objects=4, exits="ur"},
	[0x0F] = {start=0x1336, objects=3, exits="ul,ur"},
	[0x10] = {start=0x134B, objects=5, exits="ul,ur"},
	[0x11] = {start=0x136C, objects=5, exits="ur"},
	[0x12] = {start=0x1389, objects=5, exits="ul,dr"},
	[0x13] = {start=0x13A6, objects=5, exits="ul,ur"},
	[0x14] = {start=0x0000, objects=0, exits="ul,ur"},
	[0x15] = {start=0x13C4, objects=3, exits="ul,dr"},
	[0x16] = {start=0x13D5, objects=4, exits="dl"},
	[0x17] = {start=0x13EA, objects=3, exits="dl"},
	[0x18] = {start=0x13FB, objects=7, exits="dl,dr"},
	[0x19] = {start=0x1420, objects=2, exits="dl,ur"},
	[0x1A] = {start=0x1431, objects=7, exits="dl"},
	[0x1B] = {start=0x1456, objects=6, exits="ul"},
	[0x1C] = {start=0x1473, objects=3, exits="dr"},
	[0x1D] = {start=0x1484, objects=4, exits="ur"},
};

object = {
	obj_type = 0x00,
	obj_types = {
		--[0x00] = "??",
		[0x01] = "Blue Computer",
		[0x02] = "Printer",
		[0x03] = "Oven",
		[0x04] = "Desk",
		[0x05] = "Bed",
		[0x06] = "Drawers",
		[0x07] = "Fireplace ",
		[0x08] = "Sideways blue monitor",
		[0x09] = "Pink Chair",
		[0x0A] = "Flashing brown and blue rectangle",
		[0x0B] = "Brown and blue box",
		[0x0C] = "Bookshelf",
		[0x0D] = "Roll on deodorant",
		[0x0E] = "Lamp",
		[0x0F] = "Lounge",
		[0x10] = "Sink",
		[0x11] = "Small Pink thing",
		[0x12] = "Bathtub",
		[0x13] = "Toilet",
		[0x14] = "Candy",
		[0x15] = "End of Game Object",
		[0x16] = "Microwave",
		[0x17] = "Desk 2",
		[0x18] = "Fridge",
		[0x19] = "*Crash",
		--
		[0x1D] = "A2600 mode crash",
	},
	x_position = 0x01,
	y_position = 0x02,
	contents = 0x03,
	content_types = {
		[0x00] = "Nothing",
		[0x40] = "Lift Init",
		[0x80] = "Snooze",
		[0xC0] = "Puzzle Piece",
	},
};

function Game.getXPosition()
	return mainmemory.readbyte(Game.Memory.x_position);
end

function Game.getYPosition()
	return mainmemory.readbyte(Game.Memory.y_position);
end

function Game.getCurrentMap()
	return toHexString(mainmemory.readbyte(Game.Memory.current_map));
end

function Game.getIGT()
	local hours = mainmemory.readbyte(Game.Memory.gametime.hours);
	local minutes = mainmemory.readbyte(Game.Memory.gametime.minutes);
	local seconds = mainmemory.readbyte(Game.Memory.gametime.seconds);
	local centiseconds = mainmemory.readbyte(Game.Memory.gametime.centiseconds);
	return toHexString(hours, 1, "")..":"..toHexString(minutes, 2, "")..":"..toHexString(seconds, 2, "").."."..(51 - centiseconds);
end

function countPuzzlePieces(index)
	local count = 0;
	if type(object_arrays[index]) == "table" then
		for i = 1, object_arrays[index].objects do
			local id = mainmemory.readbyte(object_arrays[index].start + (i - 1) * 4);
			if id < 0x80 then
				local contents = mainmemory.readbyte(object_arrays[index].start + (i - 1) * 4 + 3);
				if contents >= 0xC0 and contents < 0xD0 then
					count = count + 1;
				end
			end
		end
	end
	return count;
end

function draw_map()
	local value;
	local row_height = 8;
	local column_width = 16;
	for i = 1, #Game.Memory.map_addresses do
		local draw_x = 51;
		local draw_y = 124;
		if client.bufferheight() == 243 then -- Compensate for overscan
			draw_x = 64;
			draw_y = 151;
		end
		local row = math.floor((i - 1) / 9);
		value = mainmemory.readbyte(Game.Memory.map_addresses[i]);
		if value > 0x80 then
			value = value - 0x80;
		end
		local mapColor = 0xFFFFFFFF;
		if value == 0x0F then -- Color end map purple
			mapColor = 0xFFFF00FF;
		end
		value = countPuzzlePieces(value);
		if value == 0 then
			mapColor = mapColor - 0x80000000; -- Halve alpha
			gui.drawText(draw_x + ((i - 1) % 9) * column_width, draw_y + row * row_height - 3, ".", mapColor, 0x00000000);
		else
			gui.drawText(draw_x + ((i - 1) % 9) * column_width, draw_y + row * row_height, value, mapColor, 0x00000000);
		end
	end
end

function Game.getPieceDistribution()
	local count = 0;
	for index = 0x00, 0x1D do
		local foundThisRoom = false;
		if type(object_arrays[index]) == "table" then
			for i = 1, object_arrays[index].objects do
				local id = mainmemory.readbyte(object_arrays[index].start + (i - 1) * 4);
				local contents = mainmemory.readbyte(object_arrays[index].start + (i - 1) * 4 + 3);
				if contents >= 0xC0 and contents < 0xD0 and not foundThisRoom then
					foundThisRoom = true;
					count = count + 1;
				end
			end
		end
	end
	if count > 0 and count < Game.bestPieceDistribution then
		local pieceCount = 0;
		for i = 0x00, 0x1D do
			pieceCount = pieceCount + countPuzzlePieces(i);
		end
		if pieceCount == 36 then
			print("New best puzzle distribution: "..count);
			Game.bestPieceDistribution = count;
		end
	end
	return count.." Rooms";
end

function Game.getBestPieceDistribution()
	return Game.bestPieceDistribution;
end

local function resetBestDistribution()
	Game.bestPieceDistribution = 100;
end

function completeMinimap()
	for i = 0x1B5A, 0x1BBF do
		local value = mainmemory.readbyte(i);
		if value < 0x80 then
			value = value + 0x80;
			mainmemory.writebyte(i, value);
		end
	end
end

function Game.initUI()
	ScriptHawk.UI.form_controls["Complete Minimap Button"] = forms.button(ScriptHawk.UI.options_form, "Complete Minimap", completeMinimap, ScriptHawk.UI.col(10), ScriptHawk.UI.row(4), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Reset Best Distribution"] = forms.button(ScriptHawk.UI.options_form, "Reset Best Dist.", resetBestDistribution, ScriptHawk.UI.col(10), ScriptHawk.UI.row(5), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
end

function Game.drawUI()
	if mainmemory.readbyte(Game.Memory.horizontal_map_position) % 2 == 1 then
		draw_map();
	end
end

Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Map", Game.getCurrentMap},
	{"IGT", Game.getIGT},
	{"Piece Dist", Game.getPieceDistribution},
	{"Best Dist", Game.getBestPieceDistribution},
};

return Game;