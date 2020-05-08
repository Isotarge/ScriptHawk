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

function Game.getVertsFromModel(modelPointer)
	local vertOffset = mainmemory.read_u32_be(modelPointer + 0x10);
	local vertBase = modelPointer + vertOffset + 0x18;
	if isRDRAM(vertBase) then
		return vertBase;
	end
end

function Game.getVertBase()
	local mapModel = dereferencePointer(Game.Memory.map_model_pointer);
	if isRDRAM(mapModel) then
		return Game.getVertsFromModel(mapModel);
	end
end

function Game.getWaterVertBase()
	local mapModel = dereferencePointer(Game.Memory.water_model_pointer);
	if isRDRAM(mapModel) then
		return Game.getVertsFromModel(mapModel);
	end
end

function Game.getSeamDist()
	local verts = {};
	if Game.isInWater() and not ScriptHawk.UI.isChecked("never_test_water") then
		verts[0] = Game.getWaterTriangleVertPositionRaw(0);
		verts[1] = Game.getWaterTriangleVertPositionRaw(1);
		verts[2] = Game.getWaterTriangleVertPositionRaw(2);
	else
		verts[0] = Game.getFloorTriangleVertPositionRaw(0);
		verts[1] = Game.getFloorTriangleVertPositionRaw(1);
		verts[2] = Game.getFloorTriangleVertPositionRaw(2);
	end
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
	local vert = nil;
	if Game.isInWater() and not ScriptHawk.UI.isChecked("never_test_water") then
		vert = Game.getWaterTriangleVertPositionRaw(index);
	else
		vert = Game.getFloorTriangleVertPositionRaw(index);
	end
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

function Game.getWaterTriangleVertPositionRaw(index)
	if type(index) ~= 'number' then
		return;
	end
	if index < 0 or index > 2 then
		return;
	end
	local floorObject = Game.getFloorObject();
	if isRDRAM(floorObject) then
		local vertIndex = mainmemory.read_u16_be(floorObject + 0x10 + index * 0x02);
		local vertBase = Game.getWaterVertBase();
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
	local vert = nil;
	if Game.isInWater() and not ScriptHawk.UI.isChecked("never_test_water") then
		vert = Game.getWaterTriangleVertPositionRaw(index);
	else
		vert = Game.getFloorTriangleVertPositionRaw(index);
	end
	if vert ~= nil then
		Game.setPosition(vert.x, vert.y, vert.z);
	end
end

-----------------------------------
-- Seam Clip Tester              --
-- By The8bitbeast & ThatCowGuy  --
-----------------------------------

seamTester = {
	x_gran = 0.1,
	z_gran = 0.1,
	kx = 0,
	kz = 0,
	t_gran = 0.1,
	total_checks = 3,
	relat_checks = 0,
	projected_length = 1,
	offset = 0, -- Offset from the first vertex (in case the vertex is inside a wall etc); offset = 0.5 means start in the center of the seam
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
	testType = "floor", -- water
	positionHistory = {},
	positionHistoryLength = 10,
};

Game.seamTesterOSD = {
	{"X", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"t", function() return seamTester.t end, category="position"},
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
		if Game.isInWater() and not ScriptHawk.UI.isChecked("never_test_water") then
			seamTester.testType = "water";
			local vert1 = Game.getWaterTriangleVertPositionRaw(vertLookup[level][1]);
			local vert2 = Game.getWaterTriangleVertPositionRaw(vertLookup[level][2]);
			seamTester.testSeam(vert1.x, vert1.z, vert2.x, vert2.z, vert1.y, vert2.y);
		else
			seamTester.testType = "floor";
			local vert1 = Game.getFloorTriangleVertPositionRaw(vertLookup[level][1]);
			local vert2 = Game.getFloorTriangleVertPositionRaw(vertLookup[level][2]);
			seamTester.testSeam(vert1.x, vert1.z, vert2.x, vert2.z, vert1.y, vert2.y);
		end
	end
end

seamTester.testSeam = function(x1, z1, x2, z2, y1, y2)
	seamTester.offset = tonumber(forms.gettext(ScriptHawk.UI.form_controls["offset Textbox"]));
	seamTester.total_checks = tonumber(forms.gettext(ScriptHawk.UI.form_controls["total_checks Textbox"]));
	if seamTester.offset == nil then
		print("offset wasn't a number! Aborting.");
		return;
	end
	if seamTester.total_checks == nil then
		print("checks wasn't a number! Aborting.");
		return;
	end
	seamTester.relat_checks = (seamTester.total_checks - 1)/2.0;

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

	-- x/z_granularity are calculated exactly and then slightly altered to make sure we NEVER skip a float
	local smallest_x = math.min(math.abs(x1), math.abs(x2));
	seamTester.kx = floored_log2(smallest_x);
	seamTester.x_gran = pow(2.0, seamTester.kx - 23.0) * 0.99;
	local smallest_z = math.min(math.abs(z1), math.abs(z2));
	seamTester.kz = floored_log2(smallest_z);
	seamTester.z_gran = pow(2.0, seamTester.kz - 23.0) * 0.99;

	-- t_granularity is now equivalent to the granularity of the axis that the Crossers are NOT aligned to,
	-- it also needs to be adjusted by the axis-projected length of the seam
	seamTester.t_gran = seamTester.x_gran * seamTester.z_align + seamTester.z_gran * seamTester.x_align;
	seamTester.projected_length = (math.abs(x1 - x2) * seamTester.z_align + math.abs(z1 - z2) * seamTester.x_align);
	seamTester.t_gran = seamTester.t_gran / seamTester.projected_length;

	seamTester.lowestY = math.min(y1, y2);
	seamTester.highestY = math.max(y1, y2);

	seamTester.t = 0.0 + seamTester.offset - seamTester.relat_checks*seamTester.t_gran; -- offset 0.5 means start in the center of the seam
	seamTester.xt = seamTester.x1 * (1.0 - seamTester.t) + seamTester.x2 * seamTester.t;
	seamTester.zt = seamTester.z1 * (1.0 - seamTester.t) + seamTester.z2 * seamTester.t;
	seamTester.xq = seamTester.xt - (seamTester.relat_checks * seamTester.x_gran * seamTester.x_align);
	seamTester.zq = seamTester.zt - (seamTester.relat_checks * seamTester.z_gran * seamTester.z_align);

	seamTester.oldFloor = -math.huge;
	seamTester.positionHistory = {};
	dprint("-------------------");
	dprint("Testing seam:");
	dprint("Type: "..seamTester.testType);
	dprint("X1, Z1: "..seamTester.x1..", "..seamTester.z1);
	dprint("X2, Z2: "..seamTester.x2..", "..seamTester.z2);
	dprint("pLength: "..seamTester.projected_length);
	dprint("Y: "..seamTester.highestY);
	dprint("bounds: ".. (seamTester.relat_checks*seamTester.x_gran * seamTester.x_align) + (seamTester.relat_checks*seamTester.z_gran * seamTester.z_align));
	dprint("x_gran: "..seamTester.x_gran);
	dprint("z_gran: "..seamTester.z_gran);
	dprint("t_gran: "..seamTester.t_gran);
	dprint("offset: "..seamTester.offset);
	dprint("-------------------");
	print_deferred();
	seamTester.testing = true;
	forms.settext(ScriptHawk.UI.form_controls["Test Seam Button"], "Cancel");

	-- Change into performance oriented OSD
	Game.OSD = Game.seamTesterOSD;
end

seamTester.simulate = function()
	if seamTester.testing then
		Game.setXPosition(seamTester.xq);
		Game.setZPosition(seamTester.zq);

		-- Keep a log of the previous n positions to make sure we don't lose any magic numbers
		table.insert(seamTester.positionHistory, 1, {seamTester.xq, seamTester.zq});
		if #seamTester.positionHistory > seamTester.positionHistoryLength then
			seamTester.positionHistory[#seamTester.positionHistory] = nil;
		end

		local solutionFound = false;
		if seamTester.testType == "water" then
			local newYVelocity = Game.getYVelocity();
			solutionFound = newYVelocity < 1;
		else
			-- Make sure the player doesn't ever go under the floor while testing upward slopes
			Game.setYPosition(seamTester.highestY);

			-- Make sure the player doesn't slip down slopes while testing
			Game.neverSlip();

			local newFloor = Game.getFloor();
			local floorDifference = math.abs(newFloor - seamTester.oldFloor);

			-- If it's the first frame, ignore the huge difference in floor value
			if seamTester.oldFloor == -math.huge then
				floorDifference = 0;
			end

			seamTester.oldFloor = newFloor;

			solutionFound = floorDifference > 10 and newFloor < seamTester.lowestY;
		end

		if solutionFound then
			foundClip = true;
			dprint("Possible solution found!");
			dprint("Last "..seamTester.positionHistoryLength.." positions:");
			for i = #seamTester.positionHistory, 1, -1 do
				dprint("Game.setPosition("..seamTester.positionHistory[i][1]..", "..seamTester.highestY..", "..seamTester.positionHistory[i][2]..")");
			end
			dprint("Current position:");
			dprint("Game.setPosition("..seamTester.xq..", "..seamTester.highestY..", "..seamTester.zq..")");

			if seamTester.testType == "floor" then
				dprint("Floor: "..Game.getFloor());
			end

			dprint("t: "..seamTester.t);
			dprint("-------------------");
			print_deferred();
			if ScriptHawk.UI.isChecked("cancel_on_found_seam_clip") then
				client.pause();
				seamTester.cancel();
				return;
			end
		end

		-- update Cross-Searcher
		seamTester.xq = seamTester.xq + seamTester.x_gran * seamTester.x_align;
		seamTester.zq = seamTester.zq + seamTester.z_gran * seamTester.z_align;
		-- Test if we exceeded the boundarys for this crossing search
		if seamTester.xq > seamTester.xt + (seamTester.relat_checks * seamTester.x_gran) or seamTester.zq > seamTester.zt + (seamTester.relat_checks * seamTester.z_gran) then
			-- Increment t
			seamTester.t = seamTester.t + seamTester.t_gran;
			-- Stop when the end of the Seam is reached
			if seamTester.t > 1.0 + seamTester.relat_checks*seamTester.t_gran then
				seamTester.cancel();
				return;
			end
			-- Update T Position
			seamTester.xt = seamTester.x1 * (1.0 - seamTester.t) + seamTester.x2 * seamTester.t;
			seamTester.zt = seamTester.z1 * (1.0 - seamTester.t) + seamTester.z2 * seamTester.t;
			-- adapt X to local granularity
			if math.abs(seamTester.xt) - (seamTester.relat_checks * seamTester.x_gran * seamTester.x_align) > pow(2.0, seamTester.kx+1) then -- X coord reachead the next, less granular interval
				seamTester.kx = seamTester.kx + 1;
				seamTester.x_gran = pow(2.0, seamTester.kx-23.0) * 0.99;
			elseif math.abs(seamTester.xt) + (seamTester.relat_checks * seamTester.x_gran * seamTester.x_align) > pow(2.0, seamTester.kx) then -- X coord reachead the prior, MORE granular interval
				seamTester.kx = seamTester.kx - 1;
				seamTester.x_gran = pow(2.0, seamTester.kx-23.0) * 0.99;
			end
			-- adapt Z to local granularity
			if math.abs(seamTester.zt) - (seamTester.relat_checks * seamTester.z_gran * seamTester.z_align) > pow(2.0, seamTester.kz+1) then -- Z coord reachead the next, less granular interval
				seamTester.kz = seamTester.kz + 1;
				seamTester.z_gran = pow(2.0, seamTester.kz-23.0) * 0.99;
			elseif math.abs(seamTester.zt) + (seamTester.relat_checks * seamTester.z_gran * seamTester.z_align) > pow(2.0, seamTester.kx) then -- Z coord reachead the prior, MORE granular interval
				seamTester.kz = seamTester.kz - 1;
				seamTester.z_gran = pow(2.0, seamTester.kz-23.0) * 0.99;
			end
			-- adapt T Granularity
			seamTester.t_gran = seamTester.x_gran * seamTester.z_align + seamTester.z_gran * seamTester.x_align;
			seamTester.t_gran = seamTester.t_gran / seamTester.projected_length;
			-- Get Q into new position
			seamTester.xq = seamTester.xt - (seamTester.relat_checks * seamTester.x_gran * seamTester.x_align);
			seamTester.zq = seamTester.zt - (seamTester.relat_checks * seamTester.z_gran * seamTester.z_align);
		end
	end
end

seamTester.cancel = function()
	print("SEAM TEST ENDED");
	forms.settext(ScriptHawk.UI.form_controls["Test Seam Button"], "Test Seam");
	seamTester.testing = false;

	-- Change back into standard OSD
	Game.OSD = Game.standardOSD;
end

seamTester.initUI = function(baseRow)
	ScriptHawk.UI.form_controls.seam_dropdown = forms.dropdown(ScriptHawk.UI.options_form, { "1 -> 2", "1 -> 3", "2 -> 1", "2 -> 3", "3 -> 1", "3 -> 2" }, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(baseRow) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI.button(5, baseRow, {4, 8}, nil, nil, "Test Seam", seamTester.testSeamFromUI);
	ScriptHawk.UI.checkbox(10, baseRow, "cancel_on_found_seam_clip", "Auto Cancel");
	ScriptHawk.UI.checkbox(10, baseRow + 1, "never_test_water", "Never Water");

	ScriptHawk.UI.form_controls["total_checks Label"] = forms.label(ScriptHawk.UI.options_form, "Checks:", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(baseRow + 1) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(1) + 15, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["total_checks Textbox"] = forms.textbox(ScriptHawk.UI.options_form, seamTester.total_checks, ScriptHawk.UI.col(2) + 5, ScriptHawk.UI.button_height, nil, ScriptHawk.UI.col(2) + 4, ScriptHawk.UI.row(baseRow + 1));

	ScriptHawk.UI.form_controls["offset Label"] = forms.label(ScriptHawk.UI.options_form, "Offset:", ScriptHawk.UI.col(5) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(baseRow + 1) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(1) + 15, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["offset Textbox"] = forms.textbox(ScriptHawk.UI.options_form, seamTester.offset, ScriptHawk.UI.col(2) + 5, ScriptHawk.UI.button_height, nil, ScriptHawk.UI.col(7) + 4, ScriptHawk.UI.row(baseRow + 1));
end

function printTri()
	local vert1 = Game.getFloorTriangleVertPositionRaw(0);
	local vert2 = Game.getFloorTriangleVertPositionRaw(1);
	local vert3 = Game.getFloorTriangleVertPositionRaw(2);
	print(vert1.x .." ".. vert1.y .." ".. vert1.z .." ".. vert2.x .." ".. vert2.y .." ".. vert2.z .." "..vert3.x .." ".. vert3.y .." ".. vert3.z);
end
