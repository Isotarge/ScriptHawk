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
	speedy_speeds = {0},
	speedy_index = 1,
	max_rot_units = 0,
	bestPieceDistribution = 100,
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
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
		[0x01] = {hitbox_width=24, hitbox_height=32, name="Blue Computer"},
		[0x02] = {hitbox_width=24, hitbox_height=24, name="Printer"},
		[0x03] = {hitbox_width=40, hitbox_height=32, name="Oven"},
		[0x04] = {hitbox_width=40, hitbox_height=24, name="Desk"},
		[0x05] = {hitbox_width=40, hitbox_height=16, name="Bed"},
		[0x06] = {hitbox_width=16, hitbox_height=24, name="Drawers"},
		[0x07] = {hitbox_width=56, hitbox_height=24, name="Fireplace"},
		[0x08] = {hitbox_width=16, hitbox_height=24, name="Sideways blue monitor"},
		[0x09] = {hitbox_width=16, hitbox_height=24, name="Pink Chair"},
		[0x0A] = {hitbox_width=16, hitbox_height=24, name="Flashing brown and blue rectangle"},
		[0x0B] = {hitbox_width=16, hitbox_height=16, name="Brown and blue box"},
		[0x0C] = {hitbox_width=24, hitbox_height=32, name="Bookshelf"},
		[0x0D] = {hitbox_width=16, hitbox_height=24, name="Roll on deodorant"},
		[0x0E] = {hitbox_width=16, hitbox_height=24, name="Lamp"},
		[0x0F] = {hitbox_width=40, hitbox_height=16, name="Lounge"},
		[0x10] = {hitbox_width=16, hitbox_height=32, name="Sink"},
		[0x11] = {hitbox_width=8, hitbox_height=8, name="Small Pink thing"},
		[0x12] = {hitbox_width=40, hitbox_height=24, name="Bathtub"},
		[0x13] = {hitbox_width=16, hitbox_height=16, name="Toilet"},
		[0x14] = {hitbox_width=32, hitbox_height=32, name="Candy"},
		[0x15] = {hitbox_width=40, hitbox_height=32, name="End of Game Object"},
		[0x16] = {hitbox_width=24, hitbox_height=24, name="Microwave"},
		[0x17] = {hitbox_width=32, hitbox_height=24, name="Desk 2"},
		[0x18] = {hitbox_width=24, hitbox_height=32, name="Fridge"},
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
	return toHexString(mainmemory.readbyte(Game.Memory.current_map));
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

local function draw_map()
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
		value = Game.countPuzzlePieces(value);
		if value == 0 then
			mapColor = mapColor - 0x80000000; -- Halve alpha
			gui.drawText(draw_x + ((i - 1) % 9) * column_width, draw_y + row * row_height - 3, ".", mapColor, 0x00000000);
		else
			gui.drawText(draw_x + ((i - 1) % 9) * column_width, draw_y + row * row_height, value, mapColor, 0x00000000);
		end
	end
end

local tile_width = 8;
local tile_height = 8;
local default_hitbox_width = 16;
local default_hitbox_height = 16;

local function draw_objects()
	local currentMap = mainmemory.readbyte(Game.Memory.current_map);
	if type(object_arrays[currentMap]) == "table" then
		local x_offset = 4;
		local y_offset = 0;
		if client.bufferheight() == 243 then -- Compensate for overscan
			x_offset = 17;
			y_offset = 27;
		end
		for i = 1, object_arrays[currentMap].objects do
			local objectBase = object_arrays[currentMap].start + (i - 1) * 4;
			local id = mainmemory.readbyte(objectBase + object.obj_type);
			if id < 0x80 then
				local xPos = mainmemory.readbyte(objectBase + object.x_position);
				local yPos = mainmemory.readbyte(objectBase + object.y_position);
				local contents = bit.band(mainmemory.readbyte(objectBase + object.contents), 0xF0);
				if type(object.content_types[contents]) == "string" then
					contents = object.content_types[contents];
				else
					contents = "U "..toHexString(contents);
				end
				local hitbox_width = default_hitbox_width;
				local hitbox_height = default_hitbox_height;
				if type(object.obj_types[id]) == "table" then
					hitbox_width = object.obj_types[id].hitbox_width;
					hitbox_height = object.obj_types[id].hitbox_height;
				end
				gui.drawRectangle(x_offset + xPos * tile_width, y_offset + yPos * tile_height, hitbox_width, hitbox_height);
				gui.drawText(x_offset + xPos * tile_width, y_offset + yPos * tile_height, contents);
			end
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
				local contents = bit.band(mainmemory.readbyte(object_arrays[index].start + (i - 1) * 4 + 3), 0xF0);
				if (contents == 0xC0 or contents == 0xD0) and not foundThisRoom then
					foundThisRoom = true;
					count = count + 1;
				end
			end
		end
	end
	if count > 0 and count < Game.bestPieceDistribution then
		if Game.getTotalPieces() == 36 then
			print("New best puzzle distribution: "..count);
			Game.bestPieceDistribution = count;
		end
	end
	return count;
end

function Game.getPieceDistributionOSD()
	return Game.getPieceDistribution().." Rooms";
end

function Game.getBestPieceDistribution()
	return Game.bestPieceDistribution.." Rooms";
end

function Game.resetBestDistribution()
	Game.bestPieceDistribution = 100;
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

local startFrame = 492;
local start2Frame = 512;
--local resetFrame = 544;
local resetFrame = 580;
local checkFrame = resetFrame + 13;
local numFrames = 52;

-- State for current attempt
local lastPauseFrame;
local last2Frame;

-- State for best attempt
local bestLastPauseFrame;
local bestLast2Frame;
local bestNumPresed;
local bestDistribution;

function initBotInput()
	numFrames = checkFrame - startFrame;
	lastPauseFrame = startFrame - 2;
	last2Frame = start2Frame - 2;
end

function iterateBotInput()
	last2Frame = last2Frame + 2;
	if last2Frame > resetFrame then
		last2Frame = start2Frame - 2;
		lastPauseFrame = lastPauseFrame + 2;
	end
	return not (lastPauseFrame > checkFrame);
end

function getSeekFrame(lastPauseFrame, last2Frame)
	return math.min(lastPauseFrame, last2Frame) - 1;
end

function countNumPressed(lastPauseFrame, last2Frame)
	return ((lastPauseFrame - startFrame) / 2) + ((last2Frame - startFrame) / 2);
end

function checkBestAttempt()
	-- First attempt will be the baseline
	if bestLastPauseFrame == nil then
		return true;
	end

	local currentDistribution = Game.getPieceDistribution();
	local currentNumPressed = countNumPressed(lastPauseFrame, last2Frame);

	if currentDistribution > 0 and currentDistribution < bestDistribution then
		print("Best input beaten with new distribution: "..currentDistribution);
		return true;
	end
	return false;
end

function updateBestAttempt()
	bestDistribution = Game.getPieceDistribution();

	-- Copy state for best attempt
	bestLastPauseFrame = lastPauseFrame + 0;
	bestLast2Frame = last2Frame + 0;

	print("bestLastPauseFrame"..bestLastPauseFrame);
	print("bestLast2Frame"..bestLast2Frame);
	
	-- Count how many inputs were made during the best attempt
	bestNumPressed = countNumPressed(bestLastPauseFrame, bestLast2Frame);
end

function clearBestAttempt()
	bestLastPauseFrame = nil;
	bestLast2Frame = nil;
	bestDistribution = 100;
end

function botLoop()
	if bot_is_running then
		if lastPauseFrame == nil then
			initBotInput();
			clearBestAttempt();
		end
		local currentFrame = emu.framecount();
		if currentFrame == checkFrame then
			if checkBestAttempt() == true then
				updateBestAttempt();
			end
			tastudio.setplayback(getSeekFrame(lastPauseFrame, last2Frame));
			if iterateBotInput() == false then
				bot_is_running = false;
				bot_is_outputting_best_input = true;
				print("Finished! Best Distribution: "..bestDistribution);
				print("bestLastPauseFrame"..bestLastPauseFrame);
				print("bestLast2Frame"..bestLast2Frame);
				tastudio.setplayback(startFrame - 1);
			end
		elseif currentFrame < checkFrame then
			local relativeFrame = currentFrame - startFrame;
			joypad.set({["Pause"] = (relativeFrame >= 0) and (currentFrame < lastPauseFrame) and relativeFrame % 2 == 0});
			joypad.set({["B2"] = (relativeFrame >= 0) and (currentFrame < last2Frame) and relativeFrame % 2 == 0}, 1);
			if currentFrame == resetFrame then
				joypad.set({["Reset"] = true});
			end
		end
	elseif bot_is_outputting_best_input then
		local currentFrame = emu.framecount();
		if currentFrame == checkFrame then
			bot_is_outputting_best_input = false;
			tastudio.setrecording(false);
			client.pause();
			if Game.bestPieceDistribution > 15 then
				resetFrame = resetFrame + 1;
				print("15 didn't happen, restarting bot with reset frame "..resetFrame);
				startBot();
			end
		elseif currentFrame < checkFrame then
			local relativeFrame = currentFrame - startFrame;
			joypad.set({["Pause"] = (relativeFrame >= 0) and (currentFrame < bestLastPauseFrame) and relativeFrame % 2 == 0});
			joypad.set({["B2"] = (relativeFrame >= 0) and (currentFrame < bestLast2Frame) and relativeFrame % 2 == 0}, 1);
			if currentFrame == resetFrame then
				joypad.set({["Reset"] = true});
			end
		end
	end
end

function startBot()
	--resetFrame = tonumber(forms.gettext(ScriptHawk.UI.form_controls.resetFrameBox));
	checkFrame = resetFrame + 13;
	bot_is_running = true;
	bot_is_outputting_best_input = false;
	lastPauseFrame = nil;
	last2Frame = nil;
	tastudio.setrecording(true);
	tastudio.setplayback(startFrame - 1);
	client.unpause();
end

function Game.initUI()
	ScriptHawk.UI.form_controls["Complete Minimap Button"] = forms.button(ScriptHawk.UI.options_form, "Complete Minimap", Game.completeMinimap, ScriptHawk.UI.col(10), ScriptHawk.UI.row(4), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Reset Best Distribution"] = forms.button(ScriptHawk.UI.options_form, "Reset Best Dist.", Game.resetBestDistribution, ScriptHawk.UI.col(10), ScriptHawk.UI.row(5), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Toggle Overlay Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Overlay", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(6) + ScriptHawk.UI.dropdown_offset);
	forms.setproperty(ScriptHawk.UI.form_controls["Toggle Overlay Checkbox"], "Checked", true);

	-- Bot
	--ScriptHawk.UI.form_controls.resetFrameBox = forms.textbox(ScriptHawk.UI.options_form, "Reset Frame", 100, 21, "UNSIGNED", ScriptHawk.UI.col(10) + 1, ScriptHawk.UI.row(0) + 1, false, true, "None");
	ScriptHawk.UI.form_controls.startBotButton = forms.button(ScriptHawk.UI.options_form, "Start Bot", startBot, ScriptHawk.UI.col(10), ScriptHawk.UI.row(1), ScriptHawk.UI.col(3), ScriptHawk.UI.button_height);
end

function Game.drawUI()
	if forms.ischecked(ScriptHawk.UI.form_controls["Toggle Overlay Checkbox"]) then
		if mainmemory.readbyte(Game.Memory.horizontal_map_position) % 2 == 1 then
			draw_map();
		else
			draw_objects();
		end
	end
end

function Game.eachFrame()
	--[[
	if Game.getPieceDistribution() == 15 and Game.getTotalPieces() == 36 then
		print("15 piece on frame "..emu.framecount());
	end
	--]]--
	botLoop();
end

function Game.applyInfinites()
	mainmemory.writebyte(Game.Memory.snoozes, 0xFF);
	mainmemory.writebyte(Game.Memory.lift_resets, 0xFF);
end

Game.OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Separator", 1},
	{"dX"},
	{"dY"},
	{"Separator", 1},
	{"Map", Game.getCurrentMap},
	{"Snooze Timer", Game.getSnoozeTimer},
	{"IGT", Game.getIGT},
	{"Separator", 1},
	{"Piece Dist", Game.getPieceDistributionOSD},
	{"Best Dist", Game.getBestPieceDistribution},
};

return Game;