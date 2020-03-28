-- In num physics frames
function Game.getPredictedYPosition(num)
	local frameRate = Game.getFrameRate();
	local gravity = Game.getGravity();
	local terminalVelocity = Game.getTerminalVelocity();

	if num == nil then
		num = 0;
	end

	local yPos = Game.getYPosition();
	local yVel = Game.getYVelocity();
	for i = 0, num do
		yVel = math.max(yVel + gravity, terminalVelocity);
		yPos = yPos + (yVel / frameRate);
	end
	return math.max(yPos, Game.getFloor());
end

function Game.getVertDist()
	local verts = {
		[0] = Game.getFloorTriangleVertPositionRaw(0),
		[1] = Game.getFloorTriangleVertPositionRaw(1),
		[2] = Game.getFloorTriangleVertPositionRaw(2),
	};
	if verts[0] == nil or verts[1] == nil or verts[2] == nil then
		return "Unknown";
	end

	local px = Game.getXPosition();
	local py = Game.getZPosition();
	local minDistSq = math.huge;
	for i = 1, 3 do -- All 3 pairs of vertices
		local x1 = verts[(i - 1) % 3].x;
		local y1 = verts[(i - 1) % 3].z;

		local x2 = verts[i % 3].x;
		local y2 = verts[i % 3].z;

		local T = ((px - x1) * (x2 - x1) + (py - y1) * (y2 - y1)) / ((x2 - x1) ^ 2 + (y2 - y1) ^ 2);
		local distSq = (x1 - px + T * (x2 - x1)) ^ 2 + (y1 - py + T * (y2 - y1)) ^ 2;
		minDistSq = math.min(distSq, minDistSq);
	end

	return math.sqrt(minDistSq);
end

function Game.getFloorTriangleVertPosition(index)
	local vert = Game.getFloorTriangleVertPositionRaw(index);
	if vert ~= nil then
		return vert.x.." "..vert.y.." "..vert.z;
	end
	return "Unknown";
end

function Game.getFloorTriangleVertPositionRaw(index)
	if type(index) ~= 'number' then
		return;
	end
	if index < 0 or index > 2 then
		return;
	end
	local floorObject = Game.getFloorObject();
	if isRDRAM(floorObject) then
		local vertIndex = mainmemory.read_u16_be(floorObject + 0x04 + index * 0x02);
		local vertBase = Game.getVertBase();
		if isRDRAM(vertBase) then
			return {
				x = mainmemory.read_s16_be(vertBase + (vertIndex * 0x10) + 0x00),
				y = mainmemory.read_s16_be(vertBase + (vertIndex * 0x10) + 0x02),
				z = mainmemory.read_s16_be(vertBase + (vertIndex * 0x10) + 0x04),
			};
		end
	end
end

function Game.zipToFloorVert(index)
	if type(index) ~= 'number' then
		return;
	end
	if index < 0 or index > 2 then
		return;
	end
	local floorObject = dereferencePointer(Game.Memory.floor_object_pointer);
	if isRDRAM(floorObject) then
		local vertIndex = mainmemory.read_u16_be(floorObject + 0x04 + index * 0x02);
		local vertBase = Game.getVertBase();
		if isRDRAM(vertBase) then
			local xPos = mainmemory.read_s16_be(vertBase + (vertIndex * 0x10) + 0x00);
			local yPos = mainmemory.read_s16_be(vertBase + (vertIndex * 0x10) + 0x02);
			local zPos = mainmemory.read_s16_be(vertBase + (vertIndex * 0x10) + 0x04);
			Game.setPosition(xPos, yPos, zPos);
		end
	end
end

-----------------------------------
-- Seam Clip Tester              --
-- By The8bitbeast & ThatCowGuy  --
-----------------------------------

seamTester = {
	gran = 0.000001,
	bounds = 0.0002,
	offset = 0, -- offset from the first vertex (in case the vertex is inside a wall etc); offset = 0.5 means start in the center of the seam eg.
	lowestY = -math.huge,
	highestY = math.huge,
	x1 = 0,
	z1 = 0,
	x2 = 0,
	z2 = 0,
	t = 0,-- t factor that goes from 0 -> 1 f(x) = p1(x) * (1 - t) + p2(x) * t
	xt = 0, -- t is position along the seam; used as an anchor
	zt = 0,
	xq = 0, -- q is test position
	zq = 0,
	x_align = 0, -- 0 = no, 1 = yes. Used to deduplicate
	z_align = 0,
	oldFloor = -math.huge,
	testing = false,
	positionHistory = {},
	positionHistoryLength = 10,
};

seamTester.testSeamFromUI = function()
	if seamTester.testing then
		seamTester.cancel();
		return;
	end

	local level = forms.gettext(ScriptHawk.UI.form_controls.seam_dropdown);
	local vertLookup = {
		["1 -> 2"] = {0, 1},
		["1 -> 3"] = {0, 2},
		["2 -> 1"] = {1, 0},
		["2 -> 3"] = {1, 2},
		["3 -> 1"] = {2, 0},
		["3 -> 2"] = {2, 1},
	};
	if vertLookup[level] ~= nil then
		local vert1 = Game.getFloorTriangleVertPositionRaw(vertLookup[level][1]);
		local vert2 = Game.getFloorTriangleVertPositionRaw(vertLookup[level][2]);
		seamTester.testSeam(vert1.x, vert1.z, vert2.x, vert2.z, vert1.y, vert2.y);
	end
end

seamTester.testSeam = function(x1, z1, x2, z2, y1, y2)
	seamTester.bounds = tonumber(forms.gettext(ScriptHawk.UI.form_controls["bounds Textbox"]));
	seamTester.gran = tonumber(forms.gettext(ScriptHawk.UI.form_controls["gran Textbox"]));
	seamTester.offset = tonumber(forms.gettext(ScriptHawk.UI.form_controls["offset Textbox"]));
	if seamTester.bounds == nil then
		print("bounds wasn't a number! Aborting.");
		return;
	end
	if seamTester.gran == nil then
		print("gran wasn't a number! Aborting.");
		return;
	end
	if seamTester.offset == nil then
		print("offset wasn't a number! Aborting.");
		return;
	end

	if math.abs(z2 - z1) > math.abs(x2 - x1) then
		-- Seam is more Z Axis aligned => Crossers should be X Axis aligned
		seamTester.x_align = 1;
		seamTester.z_align = 0;
	else
		-- Seam is more X Axis aligned => Crossers should be Z Axis aligned
		seamTester.x_align = 0;
		seamTester.z_align = 1;
	end

	seamTester.x1 = x1;
	seamTester.z1 = z1;
	seamTester.x2 = x2;
	seamTester.z2 = z2;
	seamTester.lowestY = math.min(y1, y2);
	seamTester.highestY = math.max(y1, y2);

	seamTester.t = 0.0 + seamTester.offset; -- offset 0.5 means start in the center of the seam
	seamTester.xt = seamTester.x1 * (1.0 - seamTester.t) + seamTester.x2 * seamTester.t;
	seamTester.zt = seamTester.z1 * (1.0 - seamTester.t) + seamTester.z2 * seamTester.t;
	seamTester.xq = seamTester.xt - seamTester.bounds * seamTester.x_align;
	seamTester.zq = seamTester.zt - seamTester.bounds * seamTester.z_align;

	seamTester.oldFloor = -math.huge;
	seamTester.positionHistory = {};
	print("-------------------");
	print("Testing seam:");
	print("X1, Z1: "..seamTester.x1..", "..seamTester.z1);
	print("X2, Z2: "..seamTester.x2..", "..seamTester.z2);
	print("Y: "..seamTester.highestY);
	print("bounds: "..seamTester.bounds);
	print("gran: "..seamTester.gran);
	print("offset: "..seamTester.offset);
	print("-------------------");
	seamTester.testing = true;
	forms.settext(ScriptHawk.UI.form_controls["Test Seam Button"], "Cancel");
end

seamTester.simulate = function()
	if seamTester.testing then
		Game.setXPosition(seamTester.xq);
		Game.setYPosition(seamTester.highestY); -- Make sure the player doesn't ever go under the floor while testing upward slopes
		Game.setZPosition(seamTester.zq);

		-- Make sure the player doesn't slip down slopes while testing
		Game.neverSlip();

		local newFloor = Game.getFloor();
		local floorDifference = math.abs(newFloor - seamTester.oldFloor);

		-- Keep a log of the previous n positions to make sure we don't lose any magic numbers
		table.insert(seamTester.positionHistory, 1, {seamTester.xq, seamTester.zq});
		if #seamTester.positionHistory > seamTester.positionHistoryLength then
			seamTester.positionHistory[#seamTester.positionHistory] = nil;
		end

		-- If it's the first frame, ignore the huge difference in floor value
		if seamTester.oldFloor == -math.huge then
			floorDifference = 0;
		end

		if floorDifference > 100 and newFloor < seamTester.lowestY then
			print("Possible solution found!");
			print("Last "..seamTester.positionHistoryLength.." positions:");
			for i = #seamTester.positionHistory, 1, -1 do
				print("Game.setPosition("..seamTester.positionHistory[i][1]..", "..seamTester.highestY..", "..seamTester.positionHistory[i][2]..")");
			end
			print("Current position:");
			print("Game.setPosition("..seamTester.xq..", "..seamTester.highestY..", "..seamTester.zq..")");
			print("Floor: "..newFloor);
			print("t: "..seamTester.t);
			print("-------------------");
			if ScriptHawk.UI.isChecked("cancel_on_found_seam_clip") then
				client.pause();
				seamTester.cancel();
				return;
			end
		end

		local oldX = Game.getXPosition();
		local oldZ = Game.getZPosition();
		local invalidPosition = true;

		while invalidPosition do
			-- Get Q into new position
			seamTester.xq = seamTester.xq + seamTester.gran * seamTester.x_align;
			seamTester.zq = seamTester.zq + seamTester.gran * seamTester.z_align;
			Game.setXPosition(seamTester.xq);
			Game.setZPosition(seamTester.zq);
			-- Test if new position is another float position or not
			if oldX ~= Game.getXPosition() or oldZ ~= Game.getZPosition() then -- Change in position
				invalidPosition = false;
			end
			-- Test if we exceeded the boundarys for this crossing search
			if seamTester.xq > seamTester.xt + seamTester.bounds or seamTester.zq > seamTester.zt + seamTester.bounds then
				-- Get in starting pos of current cross searcher
				seamTester.xq = seamTester.xt - seamTester.bounds * seamTester.x_align;
				seamTester.zq = seamTester.zt - seamTester.bounds * seamTester.z_align;
				Game.setXPosition(seamTester.xq);
				Game.setZPosition(seamTester.zq);
				-- Reset these
				local oldX = Game.getXPosition();
				local oldZ = Game.getZPosition();
				local invalidPosition = true;

				while invalidPosition do
					-- Increment t
					seamTester.t = seamTester.t + seamTester.gran;
					-- Stop when the end of the Seam is reached
					if seamTester.t > 1.0 then
						seamTester.cancel();
						return;
					end
					-- Update T Position
					seamTester.xt = seamTester.x1 * (1.0 - seamTester.t) + seamTester.x2 * seamTester.t;
					seamTester.zt = seamTester.z1 * (1.0 - seamTester.t) + seamTester.z2 * seamTester.t;
					-- Get Q into new position
					seamTester.xq = seamTester.xt - seamTester.bounds * seamTester.x_align;
					seamTester.zq = seamTester.zt - seamTester.bounds * seamTester.z_align;
					Game.setXPosition(seamTester.xq);
					Game.setZPosition(seamTester.zq);
					-- Test if new position is another float position or not
					-- Multiplying the X pos checks by z_align, because we only care for a change in X pos if the cross-searches are Z aligned and vice versa
					if oldX * seamTester.z_align ~= Game.getXPosition() * seamTester.z_align then
						invalidPosition = false;
					elseif oldZ * seamTester.x_align ~= Game.getZPosition() * seamTester.x_align then
						invalidPosition = false;
					end
				end
			end
		end
		seamTester.oldFloor = newFloor;
	end
end

seamTester.cancel = function()
	print("SEAM TEST ENDED");
	forms.settext(ScriptHawk.UI.form_controls["Test Seam Button"], "Test Seam");
	seamTester.testing = false;
end

seamTester.initUI = function(baseRow)
	ScriptHawk.UI.form_controls.seam_dropdown = forms.dropdown(ScriptHawk.UI.options_form, { "1 -> 2", "1 -> 3", "2 -> 1", "2 -> 3", "3 -> 1", "3 -> 2" }, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(baseRow) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI.button(5, baseRow, {4, 8}, nil, nil, "Test Seam", seamTester.testSeamFromUI);
	ScriptHawk.UI.checkbox(10, baseRow, "cancel_on_found_seam_clip", "Auto Cancel");

	ScriptHawk.UI.form_controls["bounds Label"] = forms.label(ScriptHawk.UI.options_form, "bounds:", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(baseRow + 1) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(1) + 15, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["bounds Textbox"] = forms.textbox(ScriptHawk.UI.options_form, seamTester.bounds, ScriptHawk.UI.col(2) + 5, ScriptHawk.UI.button_height, nil, ScriptHawk.UI.col(2) + 4, ScriptHawk.UI.row(baseRow + 1));

	ScriptHawk.UI.form_controls["gran Label"] = forms.label(ScriptHawk.UI.options_form, "granul:", ScriptHawk.UI.col(5) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(baseRow + 1) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(1) + 15, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["gran Textbox"] = forms.textbox(ScriptHawk.UI.options_form, seamTester.gran, ScriptHawk.UI.col(2) + 5, ScriptHawk.UI.button_height, nil, ScriptHawk.UI.col(7) + 4, ScriptHawk.UI.row(baseRow + 1));

	ScriptHawk.UI.form_controls["offset Label"] = forms.label(ScriptHawk.UI.options_form, "offset:", ScriptHawk.UI.col(10) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(baseRow + 1) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(1) + 15, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["offset Textbox"] = forms.textbox(ScriptHawk.UI.options_form, seamTester.offset, ScriptHawk.UI.col(2) + 5, ScriptHawk.UI.button_height, nil, ScriptHawk.UI.col(12) + 4, ScriptHawk.UI.row(baseRow + 1));
end