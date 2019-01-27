----------------------
-- Memory addresses --
----------------------

local p_meter = 0x106;
local max_p = 32;

local velocity_aerial = 0x110;
local velocity_ground = 0x111;

local viewport_x_position = 0x120;

---------
-- Bot --
---------

local startFrame = 0;
local endFrame = 16;
local checkFrame = 32;
local numFrames = 16;

-- State for current attempt
local inputs = {};

-- State for best attempt
local bestInputs;
local bestNumPressed;
local bestXPosition;
local bestVelocityGround;
local bestVelocityAerial;
local bestP;
local bestHealth;

function generateInputsTable()
	numFrames = endFrame - startFrame;
	inputs = {};
	for i = 1, numFrames do
		inputs[i] = false;
	end
end

function iterateInputsTable()
	local success = false;
	for i = numFrames, 1, -1 do
		if inputs[i] == false then
			inputs[i] = true;
			success = true;
			break;
		else
			inputs[i] = false;
		end
	end
	return success;
end

function printInputsTable(input_table)
	local inputString = "";
	for i = 1, #input_table do
		if input_table[i] == true then
			inputString = inputString.."1";
		else
			inputString = inputString.."0";
		end
	end
	print(inputString);
end

function countNumPressed(input_table)
	local numPressed = 0;
	for i = 1, #input_table do
		if input_table[i] == true then
			numPressed = numPressed + 1;
		end
	end
	return numPressed;
end

function checkBestAttempt()
	-- First attempt will be the baseline
	if bestInputs == nil then
		return true;
	end

	local currentP = mainmemory.readbyte(p_meter);
	local currentVelocityAerial = mainmemory.read_s8(velocity_aerial);
	local currentVelocityGround = mainmemory.read_s8(velocity_ground);
	local currentXPosition = mainmemory.read_u16_le(viewport_x_position);
	local currentNumPressed = countNumPressed(inputs);

	if currentXPosition > bestXPosition then
		print("Best input beaten with new X position: "..currentXPosition);
		return true;
	elseif currentXPosition == bestXPosition then
		if currentVelocityGround > bestVelocityGround then
			print("Best input beaten with new ground velocity: "..currentVelocityGround);
			return true;
		elseif currentVelocityGround == bestVelocityGround then
			if currentP > bestP then
				print("Best input beaten with new P meter: "..currentP);
				return true;
			elseif currentP == bestP then
				if currentNumPressed < bestNumPressed then
					print("Best input beaten with fewer button presses!");
					return true;
				elseif currentNumPressed == bestNumPressed then
					print("Attempt tied previous best in every way... Not sure what to do here...");
					return true; -- This attempt completely tied the previous best, I have no idea what to do with it
				end
			end
		end
	end
	return false;
end

function updateBestAttempt()
	bestP = mainmemory.readbyte(p_meter);
	bestVelocityAerial = mainmemory.read_s8(velocity_aerial);
	bestVelocityGround = mainmemory.read_s8(velocity_ground);
	bestXPosition = mainmemory.read_u16_le(viewport_x_position);

	-- Clone the inputs table to bestInputs
	bestInputs = {};
	for i = 1, #inputs do
		bestInputs[i] = inputs[i];
	end

	-- Count how many frames B1 is pressed in the best inputs
	bestNumPressed = countNumPressed(bestInputs);
end

function clearBestAttempt()
	bestP = nil;
	bestVelocityAerial = nil;
	bestVelocityGround = nil;
	bestXPosition = nil;
	bestInputs = nil;
end

function botLoop()
	if bot_is_running then
		if inputs == nil then
			generateInputsTable();
			clearBestAttempt();
		end
		local currentFrame = emu.framecount();
		if currentFrame == checkFrame then
			if checkBestAttempt() == true then
				updateBestAttempt();
				--print("Best input beaten with new X Position: "..bestXPosition);
			end
			tastudio.setplayback(startFrame);
			if iterateInputsTable() == false then
				bot_is_running = false;
				bot_is_outputting_best_input = true;
				print("Finished!");
				print();
				printInputsTable(bestInputs);
				print("Best X Position: "..bestXPosition);
				print("Best Aerial Vel: "..bestVelocityAerial);
				print("Best Ground Vel: "..bestVelocityGround);
				print("Best P Meter: "..bestP);
			end
			--printInputsTable(inputs);
		elseif currentFrame < endFrame then
			local relativeFrame = currentFrame - startFrame;
			joypad.set({B1 = inputs[relativeFrame]}, 1);
		end
	elseif bot_is_outputting_best_input then
		local currentFrame = emu.framecount();
		if currentFrame == checkFrame then
			bot_is_outputting_best_input = false;
			client.pause();
		elseif currentFrame < endFrame then
			local relativeFrame = currentFrame - startFrame;
			joypad.set({B1 = bestInputs[relativeFrame]}, 1);
		end
	end
end

event.onframestart(botLoop);

local UIControls = {};

function startBot()
	startFrame = emu.framecount();
	endFrame = tonumber(forms.gettext(UIControls.endFrameBox));
	checkFrame = tonumber(forms.gettext(UIControls.checkFrameBox));
	bot_is_running = true;
	bot_is_outputting_best_input = false;
	inputs = nil;
end

local form_padding = 8;
local label_offset = 5;
local dropdown_offset = 1;
local long_label_width = 140;
local button_height = 23;

local function row(row_num)
	return form_padding + button_height * row_num;
end

local function col(col_num)
	return row(col_num);
end

UIControls.botForm = forms.newform(col(17), row(10), "TazBot Options");
UIControls.endFrameBox = forms.textbox(UIControls.botForm, "End Frame", 100, 20, "UNSIGNED", col(0), row(0), false, true, "None");
UIControls.checkFrameBox = forms.textbox(UIControls.botForm, "Check Frame", 100, 20, "UNSIGNED", col(0), row(1), false, true, "None");
UIControls.startBotButton = forms.button(UIControls.botForm, "Start TazBot", startBot, col(0), row(2), col(3), button_height);
-- TODO: Label for N Combinations
-- TODO: Label for ETA?