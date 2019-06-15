temporary_flags = {
	{byte=0xB7, bit=3, flagName="Helm: Roman Numeral Doors Open"},
	{byte=0xB7, bit=4, flagName="Helm: DK BBlast Barrel complete"},
	{byte=0xB7, bit=4, flagName="Helm: Chunky PPunch Barrel complete"},
	{byte=0xB7, bit=5, flagName="Helm: Diddy Kremling Barrel complete"},
	{byte=0xB7, bit=6, flagName="Helm: Tiny PTT Barrel complete"},

	{byte=0xB8, bit=0, flagName="Helm: Lanky Maze Barrel complete"},
	{byte=0xB8, bit=1, flagName="Helm: DK Rambi Barrel complete"},
	{byte=0xB8, bit=2, flagName="Helm: Diddy Cage Barrel complete"},
	{byte=0xB8, bit=3, flagName="Helm: Tiny Mushroom Barrel complete"},
	{byte=0xB8, bit=4, flagName="Helm: Chunky Gun Barrel complete"},
	{byte=0xB8, bit=5, flagName="Helm: Lanky Gun Barrel complete"},
	{byte=0xB8, bit=6, flagName="Helm: DK Grate Punched"},
	{byte=0xB8, bit=7, flagName="Helm: Chunky Grate Punched"},

	{byte=0xB9, bit=0, flagName="Helm: Lanky Grate Punched"},
	{byte=0xB9, bit=1, flagName="Helm: Tiny Grate Punched"},
	{byte=0xB9, bit=3, flagName="Helm: DK Room Shut Down"},
	{byte=0xB9, bit=4, flagName="Helm: Chunky Room Shut Down"},
	{byte=0xB9, bit=5, flagName="Helm: Tiny Room Shut Down"},
	{byte=0xB9, bit=6, flagName="Helm: Lanky Room Shut Down"},
	{byte=0xB9, bit=7, flagName="Helm: Diddy Room Shut Down"},

	-- 0xBA, 0 set on Helm Completion, cleared when trying to exit Diddy Room
	-- 0xBA, 5 set on entering any K Rool Phase

	{byte=0xBB, bit=0, flagName="K. Rool: Tiny Phase Intro"},
	{byte=0xBB, bit=5, flagName="K. Rool: DK Phase Intro"},

	{byte=0xBC, bit=7, flagName="Aztec: Dogadon Long Intro"},

	{byte=0xBD, bit=0, flagName="Japes: Army Dillo Long Intro"},
	{byte=0xBD, bit=1, flagName="Fungi: Dogadon Long Intro"},
	{byte=0xBD, bit=2, flagName="Factory: Mad Jack Long Intro"},
	{byte=0xBD, bit=3, flagName="Galleon: Puftoss Long Intro"},
	{byte=0xBD, bit=4, flagName="Castle: Kut Out Long Intro"},
	{byte=0xBD, bit=5, flagName="Caves: Army Dillo Long Intro"},
};

-- 0xB8, 2

start = 0x7FDCE0;
finish = 0x7FDD9F;
previous = {};

string.lpad = function(str, len, char)
	if type(str) ~= "str" then
		str = tostring(str);
	end
	if char == nil then char = ' ' end
	return string.rep(char, len - #str)..str;
end

function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	value = string.lpad(value, desiredLength or string.len(value), '0');
	return (prefix or "0x")..value;
end

function updateValues()
	for i = start, finish do
		previous[i - start] = mainmemory.readbyte(i);
	end
end

function setTempFlag(byte, bit)
	local temp_flag_value = mainmemory.readbyte(start + byte);
	temp_flag_value = bit.set(temp_flag_value, bit);
	mainmemory.writebyte(start + byte, temp_flag_value);
end

function clearTempFlag(byte, bit)
	local temp_flag_value = mainmemory.readbyte(start + byte);
	temp_flag_value = bit.clear(temp_flag_value, bit);
	mainmemory.writebyte(start + byte, temp_flag_value);
end

function checkTempFlag(byte, bit)
	local temp_flag_value = mainmemory.readbyte(start + byte);
	local return_value = bit.check(temp_flag_value, bit);
	return return_value;
end

function checkDifference()
	for i = start, finish do
		local current_value = mainmemory.readbyte(i);
		local previous_value = previous[i - start];
		if current_value ~= previous_value then
			local byteVal = i - start;
			local bitArray = getBitfieldDifferences(previous_value, current_value);
			for j = 0, 7 do
				if math.abs(bitArray[j]) == 1 then
					local flagName = "Unknown";
					for k = 1, #temporary_flags do
						if temporary_flags[k].byte == byteVal then
							if temporary_flags[k].bit == j then
								flagName = temporary_flags[k].flagName;
							end
						end
					end
					if bitArray[j] == -1 then
						print("Temporary Flag '"..flagName.."' ("..toHexString(byteVal)..","..j..") cleared on frame "..emu.framecount());
					elseif bitArray[j] == 1 then
						print("Temporary Flag '"..flagName.."' ("..toHexString(byteVal)..","..j..") set on frame "..emu.framecount());
					end
				end
			end
		end
	end
end

function getBitfieldDifferences(before, after)
	local bitfieldDifference = {};
	for i = 0, 7 do
		local bitBefore = bit.check(before, i);
		local bitAfter = bit.check(after, i);
		if bitBefore and not bitAfter then
			bitfieldDifference[i] = -1; -- Clear
		elseif not bitBefore and bitAfter then
			bitfieldDifference[i] = 1; -- Set
		else
			bitfieldDifference[i] = 0; -- No Difference
		end
	end
	return bitfieldDifference;
end

updateValues();

function eventLoop()
	checkDifference();
	updateValues();
end

event.onframestart(eventLoop, "Event Loop for a frame");