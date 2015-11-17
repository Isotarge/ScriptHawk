local pointer_list = 0x7FBFF0;
local max_objects = 0xFF;
local precision = 5;

-- Relative to Object
local model_pointer = 0x00;
local rendering_parameters_pointer = 0x04;
local current_bone_array_pointer = 0x08;

local x_pos = 0x7C;
local y_pos = 0x80;
local z_pos = 0x84;

local floor = 0xA4;

local x_rot = 0xE4;
local y_rot = 0xE6;
local z_rot = 0xE8;

-- Relative to model object
local num_bones = 0x20;

local bone_size = 0x40;

-- Relative to objects in bone array
local bone_position_x = 0x18;
local bone_position_y = 0x1A;
local bone_position_z = 0x1C;

local bone_scale_x = 0x20;
local bone_scale_y = 0x2A;
local bone_scale_z = 0x34;

----------------------
-- Helper functions --
----------------------

function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num));
end

function toHexString(value)
	value = string.format("%X", value or 0);
	if string.len(value) % 2 ~= 0 then
		value = "0"..value;
	end
	return "0x"..value;
end

-- Checks whether a value falls within N64 RDRAM
local function isPointer(value)
	return value > 0x000000 and value < 0x7FFFFF;
end

-- Reads a signed, fixed point (16.16) big endian value from memory
function read_signed_fixed1616_be(address)
	local wholePart = mainmemory.read_s16_be(address);
	local fractionalPart = mainmemory.read_u16_be(address + 2) / 65536.0;
	return wholePart + fractionalPart;
end

-- Reads an unsigned, fixed point (16.16) big endian value from memory
function read_unsigned_fixed1616_be(address)
	local wholePart = mainmemory.read_u16_be(address);
	local fractionalPart = mainmemory.read_u16_be(address + 2) / 65536.0;
	return wholePart + fractionalPart;
end

--------------------
-- Deferred print --
--------------------

local __dprinted = {};

function dprint(...) -- defer print
	-- helps with lag from printing directly to Bizhawk's console
	table.insert(__dprinted, {...})
end

function dprintf(fmt, ...)
	table.insert(__dprinted, fmt:format(...))
end

function print_deferred()
	local buff = ''
	for i, t in ipairs(__dprinted) do
		if type(t) == 'string' then
			buff = buff..t..'\n'
		elseif type(t) == 'table' then
			local s = ''
			for j, v in ipairs(t) do
				s = s..tostring(v)
				if j ~= #t then s = s..'\t' end
			end
			buff = buff..s..'\n'
		end
	end
	if #buff > 0 then
		print(buff:sub(1, #buff - 1))
	end
	__dprinted = {}
end

-----------------
-- Stupid shit --
-----------------

stupidShit = false;
local safeBoneNumbers = {};

local function setNumberOfBones(modelBasePointer)
	if isPointer(modelBasePointer) then
		if safeBoneNumbers[modelBasePointer] == nil then
			safeBoneNumbers[modelBasePointer] = mainmemory.readbyte(modelBasePointer + num_bones);
		end
		local currentNumBones = mainmemory.readbyte(modelBasePointer + num_bones);
		local newNumBones = currentNumBones - 1;
		if newNumBones <= 0 then
			newNumBones = safeBoneNumbers[modelBasePointer];
		end
		mainmemory.writebyte(modelBasePointer + num_bones, newNumBones);
	end
end

--------------------
-- The main event --
--------------------

local function getBoneInfo(baseAddress)
	local boneInfo = {};
	boneInfo["positionX"] = mainmemory.read_s16_be(baseAddress + bone_position_x);
	boneInfo["positionY"] = mainmemory.read_s16_be(baseAddress + bone_position_y);
	boneInfo["positionZ"] = mainmemory.read_s16_be(baseAddress + bone_position_z);
	boneInfo["scaleX"] = mainmemory.read_u16_be(baseAddress + bone_scale_x);
	boneInfo["scaleY"] = mainmemory.read_u16_be(baseAddress + bone_scale_y);
	boneInfo["scaleZ"] = mainmemory.read_u16_be(baseAddress + bone_scale_z);
	return boneInfo;
end

local function outputBones(boneArrayBase, numBones)
	dprint("X,Y,Z,ScaleX,ScaleY,ScaleZ,");
	local i;
	for i=0,numBones - 1 do
		local boneInfo = getBoneInfo(boneArrayBase + i * bone_size);
		dprint(boneInfo["positionX"]..","..boneInfo["positionY"]..","..boneInfo["positionZ"]..","..boneInfo["scaleX"]..","..boneInfo["scaleY"]..","..boneInfo["scaleZ"]..",");
	end
	print_deferred();
end

local function outputDifferences(oldBones, newBones)
	-- Check for and output differences
	local i, diff;
	local numberOfDifferences = 0;
	for i=1,#newBones do
		if oldBones[i] ~= newBones[i] then
			diff = math.abs(newBoneArray[i] - oldBones[i]);
			if diff > 1 then
				numberOfDifferences = numberOfDifferences + 1;
				print("Diff: "..toHexString(fake_dk_bone_block_start + i).." (i="..toHexString(i % bone_size)..")"..": "..toHexString(oldBones[i]).." -> "..toHexString(newBoneArray[i]));
			end
		end
	end
	if numberOfDifferences > 0 then
		print("Found "..numberOfDifferences.." differences.");
	end
	return numberOfDifferences;
end

local function calculateZeroRatio(boneArray, startBone, endBone)
	-- Handle parameters
	startBone = startBone or 0;
	endBone = endBone or math.floor(#boneArray / bone_size);

	-- The main event
	local numberOfZeroes = 0;
	local i;
	for i = startBone * bone_size + 1, endBone * bone_size + 1 do
		if boneArray[i] == 0x00 then
			numberOfZeroes = numberOfZeroes + 1;
		end
	end
	return numberOfZeroes / #boneArray;
end

local function calculateCompleteBones(boneArray, numberOfBones)
	local numberOfCompletedBones = 0;
	local epsilon = 2 / bone_size;
	local currentBone;
	for currentBone = 0, numberOfBones - 1 do
		local zeroRatio = calculateZeroRatio(boneArray, currentBone, currentBone + 1);
		if zeroRatio < epsilon then
			numberOfCompletedBones = numberOfCompletedBones + 1;
		end
	end
	return numberOfCompletedBones;
end

local function processObject(objectPointer)
	local currentModelBase = mainmemory.read_u24_be(objectPointer + model_pointer + 1);
	local currentBoneArrayBase = mainmemory.read_u24_be(objectPointer + current_bone_array_pointer + 1);

	if isPointer(currentModelBase) and isPointer(currentBoneArrayBase) then
		if stupidShit then
			setNumberOfBones(currentModelBase);
		end
		local numberOfBones = mainmemory.readbyte(currentModelBase + num_bones);
		local blockSize = numberOfBones * bone_size;

		-- Dump the bone array
		local currentBoneArray = mainmemory.readbyterange(currentBoneArrayBase, blockSize);
		local completedBones = calculateCompleteBones(currentBoneArray, numberOfBones);

		if completedBones < numberOfBones then
			print(toHexString(objectPointer).." updated "..completedBones.."/"..numberOfBones.." bones.");
			outputBones(currentBoneArrayBase, numberOfBones);
		end
	end
end

local function mainLoop()
	if not emu.islagged() then
		local objectPointer = 0x000000;
		local objectIndex = 0;
		repeat
			objectPointer = mainmemory.read_u24_be(pointer_list + (objectIndex * 4) + 1);
			objectIndex = objectIndex + 1;
			if isPointer(objectPointer) then
				processObject(objectPointer);
			end
		until not isPointer(objectPointer) or objectIndex >= max_objects;
	end
end

event.onframestart(mainLoop);