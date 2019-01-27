if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		score_table_start = 0x10,
		score_size = 0x06,
		num_scores = 15,
		score = {
			digits = 0x00, -- 3 Bytes, Binary Coded Decimal
			initials = 0x03, -- 3 Bytes, ASCII
		},
		current_map = 0x97,
		horizontal_map_position = 0x98,
		memory_selected = 0xA5,
		lift_resets = 0xB5,
		snoozes = 0xB6,
		snooze_timer = 0xB7,
		x_position = 0x180,
		y_position = 0x181,
		gametime = {
			hours = 0x00CA,
			minutes = 0x00CB,
			seconds = 0x00CC,
			centiseconds = 0x00CD,
		},
		puzzle_rotation = 0x1B12,
		puzzle_pieces = 0x1B36,
		map_addresses = {
			0x1B5A, 0x1B5C, 0x1B5E, 0x1B60, 0x1B62, 0x1B64, 0x1B66, 0x1B68, 0x1B6A,
			0x1B6B, 0x1B6D, 0x1B6F, 0x1B71, 0x1B73, 0x1B75, 0x1B77, 0x1B79, 0x1B7B,
			0x1B7C, 0x1B7E, 0x1B80, 0x1B82, 0x1B84, 0x1B86, 0x1B88, 0x1B8A, 0x1B8C,
			0x1B8D, 0x1B8F, 0x1B91, 0x1B93, 0x1B95, 0x1B97, 0x1B99, 0x1B9B, 0x1B9D,
			0x1B9E, 0x1BA0, 0x1BA2, 0x1BA4, 0x1BA6, 0x1BA8, 0x1BAA, 0x1BAC, 0x1BAE,
			0x1BAF, 0x1BB1, 0x1BB3, 0x1BB5, 0x1BB7, 0x1BB9, 0x1BBB, 0x1BBD, 0x1BBF,
		},
	},
	bestPieceDistribution = 100,
	bestFlipsRequired = 100,
	bestColorChangesRequired = 100,
	bestSearchLength = 1000,
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.dumpScores()
	for i = 1, Game.Memory.num_scores do
		local scoreBase = Game.Memory.score_table_start + (i - 1) * Game.Memory.score_size;
		local score = toHexString(bit.band(mainmemory.readbyte(scoreBase + 0), 0x0F), 1, "")..toHexString(mainmemory.readbyte(scoreBase + 1), 2, "")..toHexString(mainmemory.readbyte(scoreBase + 2), 2, "");
		local initials = readNullTerminatedString(scoreBase + Game.Memory.score.initials, 3);
		dprint(i..": "..score.." "..initials);
	end
	print_deferred();
end

local object_arrays = { -- Use indexes from maps array
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

local object = {
	obj_type = 0x00,
	obj_types = {
		--[0x00] = "??",
		[0x01] = {hitbox_width=24, hitbox_height=32, search_length=0x08, name="Blue Computer"},
		[0x02] = {hitbox_width=24, hitbox_height=24, search_length=0x08, name="Printer"},
		[0x03] = {hitbox_width=40, hitbox_height=32, search_length=0x0F, name="Oven"},
		[0x04] = {hitbox_width=40, hitbox_height=24, search_length=0x18, name="Desk"},
		[0x05] = {hitbox_width=40, hitbox_height=16, search_length=0x0C, name="Bed"},
		[0x06] = {hitbox_width=16, hitbox_height=24, search_length=0x1E, name="Drawers"},
		[0x07] = {hitbox_width=56, hitbox_height=24, search_length=0x0C, name="Fireplace"},
		[0x08] = {hitbox_width=16, hitbox_height=24, search_length=0x08, name="Sideways blue monitor"},
		[0x09] = {hitbox_width=16, hitbox_height=24, search_length=0x0C, name="Pink Chair"},
		[0x0A] = {hitbox_width=16, hitbox_height=24, search_length=0x00, name="Flashing brown and blue rectangle"},
		[0x0B] = {hitbox_width=16, hitbox_height=16, search_length=0x08, name="Brown and blue box"},
		[0x0C] = {hitbox_width=24, hitbox_height=32, search_length=0x1E, name="Bookshelf"},
		[0x0D] = {hitbox_width=16, hitbox_height=24, search_length=0x14, name="Roll on deodorant"},
		[0x0E] = {hitbox_width=16, hitbox_height=24, search_length=0x0C, name="Lamp"},
		[0x0F] = {hitbox_width=40, hitbox_height=16, search_length=0x18, name="Lounge"},
		[0x10] = {hitbox_width=16, hitbox_height=32, search_length=0x10, name="Sink"},
		[0x11] = {hitbox_width=8, hitbox_height=8, search_length=0x14, name="Small Pink thing"},
		[0x12] = {hitbox_width=40, hitbox_height=24, search_length=0x0C, name="Bathtub"},
		[0x13] = {hitbox_width=16, hitbox_height=16, search_length=0x0C, name="Toilet"},
		[0x14] = {hitbox_width=32, hitbox_height=32, search_length=0x1E, name="Candy"},
		[0x15] = {hitbox_width=40, hitbox_height=32, search_length=0x00, name="End of Game Object"},
		[0x16] = {hitbox_width=24, hitbox_height=24, search_length=0x13, name="Microwave"},
		[0x17] = {hitbox_width=32, hitbox_height=24, search_length=0x1C, name="Desk 2"},
		[0x18] = {hitbox_width=24, hitbox_height=32, search_length=0x1E, name="Fridge"},
	},
	x_position = 0x01,
	y_position = 0x02,
	contents = 0x03,
	content_types = {
		[0x00] = "E", -- Empty
		[0x10] = "E", -- Empty, Search Started
		[0x40] = "L", -- Lift Reset
		[0x50] = "L", -- Lift Reset, Search Started
		[0x80] = "Z", -- Snooze
		[0x90] = "Z", -- Snooze, Search Started
		[0xC0] = "P", -- Puzzle Piece
		[0xD0] = "P", -- Puzzle Piece, Search Started
	},
};

function Game.getXPosition()
	return mainmemory.readbyte(Game.Memory.x_position);
end

function Game.getYPosition()
	return mainmemory.readbyte(Game.Memory.y_position);
end

function Game.getCurrentMap()
	return mainmemory.readbyte(Game.Memory.current_map);
end

function Game.getIGT()
	local hours = mainmemory.readbyte(Game.Memory.gametime.hours);
	local minutes = mainmemory.readbyte(Game.Memory.gametime.minutes);
	local seconds = mainmemory.readbyte(Game.Memory.gametime.seconds);
	local centiseconds = mainmemory.readbyte(Game.Memory.gametime.centiseconds);
	return toHexString(hours, 1, "")..":"..toHexString(minutes, 2, "")..":"..toHexString(seconds, 2, "").."."..(51 - centiseconds);
end

function Game.getSnoozeTimer()
	return mainmemory.readbyte(Game.Memory.snooze_timer);
end

function Game.countPuzzlePieces(index)
	local count = 0;
	if type(object_arrays[index]) == "table" then
		for i = 1, object_arrays[index].objects do
			local id = mainmemory.readbyte(object_arrays[index].start + (i - 1) * 4);
			if id < 0x80 then
				local contents = bit.band(mainmemory.readbyte(object_arrays[index].start + (i - 1) * 4 + 3), 0xF0);
				if contents == 0xC0 or contents == 0xD0 then
					count = count + 1;
				end
			end
		end
	end
	return count;
end

function Game.getTotalPieces()
	local pieceCount = 0;
	for i = 0x00, 0x1D do
		pieceCount = pieceCount + Game.countPuzzlePieces(i);
	end
	return pieceCount;
end

function Game.getPuzzleFlipsRequired()
	local flipsRequired = 0;
	for i = 0, 8 do
		local hSpotted = false;
		local vSpotted = false;
		local hvSpotted = false;
		for j = 0, 3 do
			local rotationValue = mainmemory.readbyte(Game.Memory.puzzle_rotation + (i * 4) + j);
			local pieceVFlipped = bit.band(0x40, rotationValue) > 0;
			local pieceHFlipped = bit.band(0x80, rotationValue) > 0;
			if pieceVFlipped then
				vSpotted = true;
			end
			if pieceHFlipped then
				hSpotted = true;
			end
			if pieceHFlipped and pieceVFlipped then
				hvSpotted = true;
			end
		end
		if not hSpotted and not vSpotted and not hvSpotted then -- 0 0 0
			-- No flips required
		elseif hSpotted and not vSpotted and not hvSpotted then -- 1 0 0
			flipsRequired = flipsRequired + 1;
		elseif not hSpotted and vSpotted and not hvSpotted then -- 0 1 0
			flipsRequired = flipsRequired + 1;
		elseif not hSpotted and not vSpotted and hvSpotted then -- 0 0 1
			flipsRequired = flipsRequired + 2;
		elseif hSpotted and not vSpotted and hvSpotted then -- 1 0 1
			flipsRequired = flipsRequired + 2;
		elseif not hSpotted and vSpotted and hvSpotted then -- 0 1 1
			flipsRequired = flipsRequired + 2;
		elseif hSpotted and vSpotted and not hvSpotted then -- 1 1 0
			flipsRequired = flipsRequired + 2;
		elseif hSpotted and vSpotted and hvSpotted then -- 1 1 1
			flipsRequired = flipsRequired + 3;
		end
	end
	if flipsRequired > 0 and flipsRequired < Game.bestFlipsRequired and Game.getTotalPieces() == 36 then
		print("New best puzzle flips required: "..flipsRequired);
		Game.bestFlipsRequired = flipsRequired;
	end
	return flipsRequired;
end

function Game.getPuzzleColorChangesRequired()
	local changesRequired = 0;
	for i = 0, 8 do
		local redSpotted = false;
		local greenSpotted = false;
		local blueSpotted = false;
		for j = 0, 3 do
			local colorValue = bit.band(mainmemory.readbyte(Game.Memory.puzzle_rotation + (i * 4) + j), 0x0F);
			if colorValue == 0x01 then
				blueSpotted = true;
			elseif colorValue == 0x02 then
				greenSpotted = true;
			elseif colorValue == 0x03 then
				redSpotted = true;
			end
		end
		local uniqueColors = 0;
		if redSpotted then
			uniqueColors = uniqueColors + 1;
		end
		if greenSpotted then
			uniqueColors = uniqueColors + 1;
		end
		if blueSpotted then
			uniqueColors = uniqueColors + 1;
		end
		changesRequired = changesRequired + (uniqueColors - 1);
	end
	if changesRequired > 0 and changesRequired < Game.bestColorChangesRequired and Game.getTotalPieces() == 36 then
		print("New best puzzle color changes required: "..changesRequired);
		Game.bestColorChangesRequired = changesRequired;
	end
	return changesRequired;
end

local function draw_map()
	local value;
	local row_height = 8;
	local column_width = 16;
	for i = 1, #Game.Memory.map_addresses do
		local draw_x = 51 + ScriptHawk.overscan_compensation.x;
		local draw_y = 124 + ScriptHawk.overscan_compensation.y;
		local row = math.floor((i - 1) / 9);
		value = mainmemory.readbyte(Game.Memory.map_addresses[i]);
		if value > 0x80 then
			value = value - 0x80;
		end
		local mapColor = colors.white;
		if value == 0x0F then
			mapColor = colors.pink;
		end
		value = Game.countPuzzlePieces(value);
		if value == 0 then
			mapColor = mapColor - 0x80000000; -- Halve alpha
			gui.drawText(draw_x + ((i - 1) % 9) * column_width, draw_y + row * row_height - 3, ".", mapColor, colors.transparent);
		else
			gui.drawText(draw_x + ((i - 1) % 9) * column_width, draw_y + row * row_height, value, mapColor, colors.transparent);
		end
	end
end

local function draw_puzzle()
	local memorySelected = mainmemory.readbyte(Game.Memory.memory_selected);

	local piece0 = mainmemory.readbyte(Game.Memory.puzzle_pieces + memorySelected);
	local piece0Major = math.floor(piece0 / 4);
	local piece0Minor = piece0 % 4;
	local piece0Rotation = mainmemory.readbyte(Game.Memory.puzzle_rotation + piece0);
	local piece0VFlipped = bit.band(0x40, piece0Rotation) > 0;
	local piece0HFlipped = bit.band(0x80, piece0Rotation) > 0;
	if piece0VFlipped then
		piece0VFlipped = "V";
	else
		piece0VFlipped = "";
	end
	if piece0HFlipped then
		piece0HFlipped = "H";
	else
		piece0HFlipped = "";
	end

	local piece1 = mainmemory.readbyte(Game.Memory.puzzle_pieces + memorySelected + 1);
	local piece1Major = math.floor(piece1 / 4);
	local piece1Minor = piece1 % 4;
	local piece1Rotation = mainmemory.readbyte(Game.Memory.puzzle_rotation + piece1);
	local piece1VFlipped = bit.band(0x40, piece1Rotation) > 0;
	local piece1HFlipped = bit.band(0x80, piece1Rotation) > 0;
	if piece1VFlipped then
		piece1VFlipped = "V";
	else
		piece1VFlipped = "";
	end
	if piece1HFlipped then
		piece1HFlipped = "H";
	else
		piece1HFlipped = "";
	end

	local puzzleX = 44 + ScriptHawk.overscan_compensation.x;
	local puzzleY = 123 + ScriptHawk.overscan_compensation.y;

	gui.drawText(puzzleX, puzzleY, piece0Major.."-"..piece0Minor.." "..piece0HFlipped..piece0VFlipped, colors.white, colors.transparent);
	gui.drawText(puzzleX, puzzleY + 24, piece1Major.."-"..piece1Minor.." "..piece1HFlipped..piece1VFlipped, colors.white, colors.transparent);
end

function Game.dumpPuzzleInventory()
	for i = 0, 35 do
		local piece = mainmemory.readbyte(Game.Memory.puzzle_pieces + i);
		if piece < 0xFF then
			local pieceMajor = math.floor(piece / 4);
			local pieceMinor = piece % 4;
			local pieceRotation = mainmemory.readbyte(Game.Memory.puzzle_rotation + piece);
			local pieceVFlipped = bit.band(0x40, pieceRotation) > 0;
			local pieceHFlipped = bit.band(0x80, pieceRotation) > 0;
			if pieceVFlipped then
				pieceVFlipped = "V";
			else
				pieceVFlipped = "";
			end
			if pieceHFlipped then
				pieceHFlipped = "H";
			else
				pieceHFlipped = "";
			end

			local pieceColor = bit.band(pieceRotation, 0x0F);
			if pieceColor == 0x01 then
				pieceColor = "B";
			elseif pieceColor == 0x02 then
				pieceColor = "G";
			elseif pieceColor == 0x03 then
				pieceColor = "R";
			else
				pieceColor = "U";
			end

			dprint(pieceMajor.."-"..pieceMinor.." "..pieceColor.." "..pieceHFlipped..pieceVFlipped);
		end
	end
	print_deferred();
end

local tile_width = 8;
local tile_height = 8;
local default_hitbox_width = 16;
local default_hitbox_height = 16;

local function draw_objects()
	local currentMap = mainmemory.readbyte(Game.Memory.current_map);
	if type(object_arrays[currentMap]) == "table" then
		local x_offset = 4 + ScriptHawk.overscan_compensation.x;
		local y_offset = 0 + ScriptHawk.overscan_compensation.y;
		for i = 1, object_arrays[currentMap].objects do
			local objectBase = object_arrays[currentMap].start + (i - 1) * 4;
			local id = mainmemory.readbyte(objectBase + object.obj_type);
			if id < 0x80 then
				local xPos = mainmemory.readbyte(objectBase + object.x_position);
				local yPos = mainmemory.readbyte(objectBase + object.y_position);
				local contentsRaw = mainmemory.readbyte(objectBase + object.contents);
				local contents = bit.band(contentsRaw, 0xF0);
				contents = object.content_types[contents] or "U "..toHexString(contents);
				local hitbox_width = default_hitbox_width;
				local hitbox_height = default_hitbox_height;
				if type(object.obj_types[id]) == "table" then
					hitbox_width = object.obj_types[id].hitbox_width;
					hitbox_height = object.obj_types[id].hitbox_height;
				end
				gui.drawText(x_offset + xPos * tile_width, y_offset + yPos * tile_height, contents);
				--gui.drawText(x_offset + xPos * tile_width, y_offset + yPos * tile_height + 16, toHexString(contentsRaw));
				--gui.drawText(x_offset + xPos * tile_width, y_offset + yPos * tile_height + 32, toHexString(id));
				gui.drawRectangle(x_offset + xPos * tile_width, y_offset + yPos * tile_height, hitbox_width, hitbox_height);
			end
		end
	end
end

function Game.getTotalSearchBarLength()
	local count = 0;
	for index = 0x00, 0x1D do
		if type(object_arrays[index]) == "table" then
			for i = 1, object_arrays[index].objects do
				local id = bit.band(mainmemory.readbyte(object_arrays[index].start + (i - 1) * 4), 0x7F);
				local contents = bit.band(mainmemory.readbyte(object_arrays[index].start + (i - 1) * 4 + 3), 0xF0);
				if (contents == 0xC0 or contents == 0xD0) then
					if type(object.obj_types[id]) == "table" then
						count = count + object.obj_types[id].search_length;
					end
				end
			end
		end
	end
	if count > 0 and count < Game.bestSearchLength and Game.getTotalPieces() == 36 then
		print("New best puzzle search length: "..count);
		Game.bestSearchLength = count;
	end
	return count;
end

function Game.getPieceDistribution()
	local count = 0;
	for index = 0x00, 0x1D do
		local foundThisRoom = false;
		if type(object_arrays[index]) == "table" then
			for i = 1, object_arrays[index].objects do
				local id = mainmemory.readbyte(object_arrays[index].start + (i - 1) * 4);
				local contents = bit.band(mainmemory.readbyte(object_arrays[index].start + (i - 1) * 4 + 3), 0xF0);
				if (contents == 0xC0 or contents == 0xD0) and not foundThisRoom then
					foundThisRoom = true;
					count = count + 1;
				end
			end
		end
	end
	if count > 0 and count < Game.bestPieceDistribution and Game.getTotalPieces() == 36 then
		print("New best puzzle distribution: "..count);
		Game.bestPieceDistribution = count;
	end
	return count;
end

function Game.getPieceDistributionOSD()
	return Game.getPieceDistribution().." Rooms";
end

function Game.getBestPieceDistribution()
	return Game.bestPieceDistribution.." Rooms";
end

function Game.getBestPuzzleFlipsRequired()
	return Game.bestFlipsRequired;
end

function Game.getBestPuzzleColorChangesRequired()
	return Game.bestColorChangesRequired;
end

function Game.getBestSearchLength()
	return Game.bestSearchLength;
end

function Game.resetBestDistribution()
	Game.bestPieceDistribution = 100;
	Game.bestFlipsRequired = 100;
	Game.bestColorChangesRequired = 100;
	Game.bestSearchLength = 1000;
end

function Game.completeMinimap()
	for i = 0x1B5A, 0x1BBF do
		local value = mainmemory.readbyte(i);
		if value < 0x80 then
			value = value + 0x80;
			mainmemory.writebyte(i, value);
		end
	end
end

---------
-- Bot --
---------

local bot_is_running = false;
local bot_is_outputting_best_input = false;
local screenshot_next_frame = false;

local startFrame = 1;
local start2Frame = 580;
local resetFrame = 580;
local checkFrame = resetFrame + 13;

-- State for current attempt
local lastPauseFrame;
local last2Frame;

-- State for best attempt
local bestLastPauseFrame;
local bestLast2Frame;
local bestNumPressed;
local bestDistribution;

local function initBotInput()
	lastPauseFrame = startFrame - 2;
	last2Frame = start2Frame - 1;
end

local function iterateBotInput()
	last2Frame = last2Frame + 1;
	if last2Frame > resetFrame then
		last2Frame = start2Frame - 1;
		lastPauseFrame = lastPauseFrame + 2;
	end
	return not (lastPauseFrame > checkFrame);
end

local function countNumPressed(lastPauseFrame, last2Frame)
	return ((lastPauseFrame - startFrame) / 2) + ((last2Frame - startFrame) / 2);
end

local function checkBestAttempt()
	-- First attempt will be the baseline
	if bestLastPauseFrame == nil then
		return true;
	end

	local currentDistribution = Game.getPieceDistribution();
	--local currentNumPressed = countNumPressed(lastPauseFrame, last2Frame);

	if currentDistribution > 0 and currentDistribution < bestDistribution then
		print("Best input beaten with new distribution: "..currentDistribution);
		return true;
	end
	return false;
end

local function updateBestAttempt()
	bestDistribution = Game.getPieceDistribution();

	-- Copy state for best attempt
	bestLastPauseFrame = lastPauseFrame;
	bestLast2Frame = last2Frame;

	print("bestLastPauseFrame: "..bestLastPauseFrame);
	print("bestLast2Frame: "..bestLast2Frame);

	-- Count how many inputs were made during the best attempt
	bestNumPressed = countNumPressed(bestLastPauseFrame, bestLast2Frame);
end

local function clearBestAttempt()
	bestLastPauseFrame = nil;
	bestLast2Frame = nil;
	bestDistribution = 100;
end

local function startBot()
	--resetFrame = tonumber(forms.gettext(ScriptHawk.UI.form_controls.resetFrameBox));
	forms.setproperty(ScriptHawk.UI.form_controls["Toggle Overlay Checkbox"], "Checked", false);
	checkFrame = resetFrame + 13;
	bot_is_running = true;
	bot_is_outputting_best_input = false;
	lastPauseFrame = nil;
	last2Frame = nil;
	tastudio.setrecording(true);
	tastudio.setplayback(startFrame - 1);
	client.unpause();
	Game.OSD = Game.botOSD;
end

local function botLoop()
	if screenshot_next_frame then
		return;
	end
	if bot_is_running then
		if lastPauseFrame == nil then
			initBotInput();
			clearBestAttempt();
		end
		local currentFrame = emu.framecount();
		if currentFrame == checkFrame then
			if Game.getPieceDistribution() <= 16 then
				screenshot_next_frame = true;
				return;
			end
		end
		if currentFrame >= checkFrame then
			if checkBestAttempt() == true then
				updateBestAttempt();
			end
			if iterateBotInput() == false then
				bot_is_running = false;
				bot_is_outputting_best_input = true;
				print("Finished! Best Distribution: "..bestDistribution);
				print("bestLastPauseFrame: "..bestLastPauseFrame);
				print("bestLast2Frame: "..bestLast2Frame);
				tastudio.setplayback(startFrame);
				forms.setproperty(ScriptHawk.UI.form_controls["Toggle Overlay Checkbox"], "Checked", true);
				botLoop();
				return;
			end
			tastudio.setplayback(math.min(lastPauseFrame - 1, last2Frame));
			forms.setproperty(ScriptHawk.UI.form_controls["Toggle Overlay Checkbox"], "Checked", false);
			botLoop();
		elseif currentFrame < checkFrame then
			local relativeFrame = currentFrame - startFrame;
			joypad.set({Pause = (currentFrame <= lastPauseFrame) and (relativeFrame >= 0) and (relativeFrame % 2 == 0)});
			joypad.set({B2 = (relativeFrame >= 0) and (currentFrame <= last2Frame)}, 1);
			if currentFrame == resetFrame then
				joypad.set({Reset = true});
				forms.setproperty(ScriptHawk.UI.form_controls["Toggle Overlay Checkbox"], "Checked", true);
			end
		end
	elseif bot_is_outputting_best_input then
		local currentFrame = emu.framecount();
		if currentFrame == checkFrame then
			if Game.getPieceDistribution() <= 16 then
				screenshot_next_frame = true;
				return;
			end
		end
		if currentFrame >= checkFrame then
			bot_is_outputting_best_input = false;
			tastudio.setrecording(false);
			client.pause();
			if Game.bestPieceDistribution > 15 then
				resetFrame = resetFrame + 1;
				print("Didn't meet goal, restarting bot with reset frame "..resetFrame);
				startBot();
			else
				print("Met goal, stopping bot!");
			end
		elseif currentFrame < checkFrame then
			local relativeFrame = currentFrame - startFrame;
			joypad.set({Pause = (currentFrame <= bestLastPauseFrame) and (relativeFrame >= 0) and (relativeFrame % 2 == 0)});
			joypad.set({B2 = (relativeFrame >= 0) and (currentFrame <= bestLast2Frame)}, 1);
			if currentFrame == resetFrame then
				joypad.set({Reset = true});
			end
		end
	else
		Game.OSD = Game.standardOSD;
	end
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.button(10, 4, {4, 10}, nil, nil, "Complete Minimap", Game.completeMinimap);
		ScriptHawk.UI.button(10, 5, {4, 10}, nil, nil, "Reset Best", Game.resetBestDistribution);
	end

	ScriptHawk.UI.checkbox(0, 6, "Toggle Overlay Checkbox", "Overlay", true);

	-- Bot
	--ScriptHawk.UI.form_controls.resetFrameBox = forms.textbox(ScriptHawk.UI.options_form, "Reset Frame", 100, 21, "UNSIGNED", ScriptHawk.UI.col(10) + 1, ScriptHawk.UI.row(0) + 1, false, true, "None");
	ScriptHawk.UI.button(10, 1, 3, nil, nil, "Start Bot", startBot);
end

function Game.drawUI()
	if ScriptHawk.UI.ischecked("Toggle Overlay Checkbox") then
		if mainmemory.readbyte(Game.Memory.horizontal_map_position) % 2 == 1 then
			if mainmemory.readbyte(0x93) ~= 137 then
				draw_map();
			else
				draw_puzzle();
			end
		else
			draw_objects();
		end
	end
	if screenshot_next_frame then
		local last2FrameSS = last2Frame;
		local lastPauseFrameSS = lastPauseFrame;
		if bot_is_outputting_best_input then
			last2FrameSS = bestLast2Frame;
			lastPauseFrameSS = bestLastPauseFrame;
		end
		client.screenshot(Game.getPieceDistribution().."rooms_"..resetFrame.."reset_"..last2FrameSS.."last2_"..lastPauseFrameSS.."lastPause_"..Game.getPuzzleFlipsRequired().."flips_"..Game.getPuzzleColorChangesRequired().."colors_"..Game.getTotalSearchBarLength().."search.png");
		screenshot_next_frame = false;
	end
end

function Game.eachFrame()
	--[[
	if Game.getPieceDistribution() == 15 and Game.getTotalPieces() == 36 then
		print("15 piece on frame "..emu.framecount());
	end
	--]]
	botLoop();
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.snoozes, 0xFF);
	mainmemory.writebyte(Game.Memory.lift_resets, 0xFF);
end

Game.standardOSD = {
	{"Map", hexifyOSD(Game.getCurrentMap), category="mapData"},
	{"IGT", Game.getIGT, category="igt"},
	{"Snooze Timer", Game.getSnoozeTimer, category="snoozeTimer"},
	{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"Separator"},
	{"dX", category="positionStats"},
	{"dY", category="positionStats"},
	{"Separator"},
	{"Piece Dist", Game.getPieceDistributionOSD, category="distribution"},
	{"Best Dist", Game.getBestPieceDistribution, category="distribution"},
	{"Separator"},
	{"Flips Requried", Game.getPuzzleFlipsRequired, category="flips"},
	{"Best Flips Req", Game.getBestPuzzleFlipsRequired, category="flips"},
	{"Separator"},
	{"Color Required", Game.getPuzzleColorChangesRequired, category="color"},
	{"Best Color Req", Game.getBestPuzzleColorChangesRequired, category="color"},
	{"Separator"},
	{"Total Search Length", Game.getTotalSearchBarLength, category="search"},
	{"Best Search Length", Game.getBestSearchLength, category="search"},
};

Game.botOSD = {
	{"Piece Dist", Game.getPieceDistributionOSD, category="distribution"},
	{"Best Dist", Game.getBestPieceDistribution, category="distribution"},
	--[[
	{"Separator"},
	{"Flips Requried", Game.getPuzzleFlipsRequired},
	{"Best Flips Req", Game.getBestPuzzleFlipsRequired},
	{"Separator"},
	{"Color Required", Game.getPuzzleColorChangesRequired},
	{"Best Color Req", Game.getBestPuzzleColorChangesRequired},
	{"Separator"},
	{"Total Search Length", Game.getTotalSearchBarLength},
	{"Best Search Length", Game.getBestSearchLength},
	--]]
};

Game.OSD = Game.standardOSD;

return Game;