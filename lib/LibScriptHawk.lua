-------------------
-- LibScriptHawk --
-------------------

-- For developers who want access to ScriptHawk's helper functions without the commitment of a full fat game module

-------------
-- Texture --
-------------

image_directory_root = ".\\Images\\";

-- Pixel format: 16bit RGBA 5551
-- RRRR RGGG GGBB BBBA
local rgba5551_color_constants = {
	["Red"] = 0x0800,
	["Green"] = 0x0040,
	["Blue"] = 0x0002,
};

function replaceTextureRGBA5551(filename, base, width, height)
	if not fileExists(filename) then
		filename = forms.openfile(nil, nil, "PNG Image (*.png)|*.png");
		if not fileExists(filename) then
			print("No image selected. Exiting.");
			return;
		end
	end

	local img = pngImage(filename);

	for y = 1, math.min(img.height, height) do
		for x = 1, math.min(img.width, width) do
			local pixel = img:getPixel(x, y);
			local r = math.floor(pixel.R / img.depth) * rgba5551_color_constants["Red"];
			local g = math.floor(pixel.G / img.depth) * rgba5551_color_constants["Green"];
			local b = math.floor(pixel.B / img.depth) * rgba5551_color_constants["Blue"];
			local a = 0;
			if pixel.A > 0 then
				a = 1;
			end

			mainmemory.write_u16_be(base + ((y - 1) * width * 2) + ((x - 1) * 2), r + g + b + a);
		end
	end
end

--------------------
-- Deferred print --
-- Thanks, Notwa  --
--------------------

local __dprinted = {};

function dprint(...) -- defer print
	-- helps with lag from printing directly to Bizhawk's console
	table.insert(__dprinted, {...});
end

function dprintf(fmt, ...)
	table.insert(__dprinted, fmt:format(...));
end

function print_deferred()
	local buff = '';
	for i, t in ipairs(__dprinted) do
		if type(t) == 'string' then
			buff = buff..t..'\n';
		elseif type(t) == 'table' then
			local s = '';
			for j, v in ipairs(t) do
				s = s..tostring(v);
				if j ~= #t then s = s..'\t' end
			end
			buff = buff..s..'\n';
		end
	end
	if #buff > 0 then
		print(buff:sub(1, #buff - 1));
	end
	__dprinted = {};
end

if emu.getsystemid() == "N64" then
	RDRAMBase = 0x80000000;
	RDRAMSize = 0x800000; -- Halved with no expansion pak, can be read from 0x80000318

	-- Checks whether a value falls within N64 RDRAM
	function isRDRAM(value)
		return type(value) == "number" and value >= 0 and value < RDRAMSize;
	end

	-- Checks whether a value is a pointer in to N64 RDRAM on the system bus
	function isPointer(value)
		return type(value) == "number" and value >= RDRAMBase and value < RDRAMBase + RDRAMSize;
	end

	-- Dereferences a N64 RDRAM pointer
	-- Returns the RDRAM address pointed to if it's a valid pointer
	-- Returns nil if invalid
	function dereferencePointer(address)
		if type(address) == "number" and address >= 0 and address < (RDRAMSize - 4) then
			address = mainmemory.read_u32_be(address);
			if isPointer(address) then
				return address - RDRAMBase;
			end
		end
	end
end

if emu.getsystemid() == "PSX" then
	RAMBase = 0x80000000;
	RAMSize = 0x200000;

	function isPointer(addr)
		if type(addr) ~= "number" then
			return false;
		end
		return addr >= RAMBase and addr < RAMBase + RAMSize;
	end

	function isRAM(addr)
		if type(addr) ~= "number" then
			return false;
		end
		return addr >= 0 and addr < RAMSize;
	end

	function dereferencePointer(addr)
		if isRAM(addr) then
			addr = mainmemory.read_u32_le(addr);
			if isPointer(addr) then
				return addr - RAMBase;
			end
		end
	end
end

function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num));
end

function isnan(x) return x ~= x end

function divisibleBy(number, divisor)
	if type(number) == "number" and (not isnan(number)) and number ~= 0 and type(divisor) == "number" and (not isnan(divisor)) and divisor ~= 0 then
		local divValue = number / divisor;
		return math.floor(divValue) == divValue;
	end
	return false;
end

function angleBetweenPoints(x1, y1, x2, y2)
	local angle = 180 * (math.atan2(x2 - x1, y2 - y1)) / math.pi;
	return (angle + 360) % 360;
end

function esc(str)
	return (str:gsub('%%', '%%%%')
		:gsub('%^', '%%%^')
		:gsub('%$', '%%%$')
		:gsub('%(', '%%%(')
		:gsub('%)', '%%%)')
		:gsub('%.', '%%%.')
		:gsub('%[', '%%%[')
		:gsub('%]', '%%%]')
		:gsub('%*', '%%%*')
		:gsub('%+', '%%%+')
		:gsub('%-', '%%%-')
		:gsub('%?', '%%%?'));
end

string.contains = function(haystack, needle)
	return type(string.find(haystack, esc(needle))) == "number";
end

string.lpad = function(str, len, char)
	if char == nil then char = ' ' end
	return string.rep(char, len - #str) .. str
end

string.rpad = function(str, len, char)
	if char == nil then char = ' ' end
	return str .. string.rep(char, len - #str)
end

function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	value = string.lpad(value, desiredLength or string.len(value), '0');
	return (prefix or "0x")..value;
end

function toBinaryString(num, bits) -- TODO: Properly define behavior for negative numbers
	if type(num) ~= "number" then
		return "0";
	end
	bits = bits or select(2, math.frexp(num));
	local t = {};
	for b = bits, 1, -1 do
		t[b] = math.fmod(num, 2);
		num = (num - t[b]) / 2;
	end
	return table.concat(t);
end

function get_bit(field, index)
	if index < 32 then
		local bitmask = math.pow(2, index);
		return bit.band(bitmask, field) == bitmask;
	end
	return false;
end
getBit = get_bit;
check_bit = get_bit;
checkBit = check_bit;

function set_bit(field, index)
	if index < 32 then
		local bitmask = math.pow(2, index);
		return bit.bor(bitmask, field);
	end
	return field;
end
setBit = set_bit;

function clear_bit(field, index)
	if index < 32 then
		local bitmask = math.pow(2, index);
		return bit.band(field, bit.bnot(bitmask));
	end
	return field;
end
clearBit = clear_bit;

function toggle_bit(field, index)
	if getBit(field, index) then
		return clearBit(field, index);
	end
	return setBit(field, index);
end
toggleBit = toggle_bit;

function deepcompare(t1, t2, ignore_mt)
	local ty1 = type(t1);
	local ty2 = type(t2);
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1);
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1, v1 in pairs(t1) do
		local v2 = t2[k1];
		if v2 == nil or not deepcompare(v1,v2) then return false end
	end
	for k2, v2 in pairs(t2) do
		local v1 = t1[k2];
		if v1 == nil or not deepcompare(v1,v2) then return false end
	end
	return true;
end

function table.contains(array, value)
	if type(array) == "table" then
		for k, v in pairs(array) do
			if v == value then
				return true;
			end
		end
	end
	return false;
end

function table.join(t1, t2)
	local t3 = {};
	if type(t1) == "table" then
		for k, v in ipairs(t1) do
			table.insert(t3, v);
		end
	end
	if type(t2) == "table" then
		for k, v in ipairs(t2) do
			table.insert(t3, v);
		end
	end
	return t3;
end

-- Recursive Print (structure, limit, indent)
function table.print(s, l, i)
	l = (l) or 100;
	i = i or "";
	if (l < 1) then
		print("ERROR: Item limit reached.");
		return l - 1;
	end
	local ts = type(s);
	if (ts ~= "table") then
		print(i, ts, s);
		return l - 1;
	end
	print(i, ts);
	for k,v in pairs(s) do
		l = table.print(v, l, i.."\t["..tostring(k).."]");
		if (l < 0) then
			break;
		end
	end
	return l;
end

function fileExists(name)
	if type(name) == 'string' then
		local f = io.open(name, "r");
		if f ~= nil then
			io.close(f);
			return true;
		end
	end
	return false;
end

--       a  r  g  b
-- 0.0 = 7F 00 FF 00 = Green
-- 0.5 = 7F FF FF 00 = Yellow
-- 1.0 = 7F FF 00 00 = Red
function getColour(ratio, alpha)
	local green = 255;
	local red = 255;
	alpha = alpha or 255;

	if ratio > 0.5 then
		green = 255 - round(((ratio - 0.5) * 2) * 255);
		red = 255;
	elseif ratio < 0.5 then
		red = round((ratio * 2) * 255);
		green = 255;
	end

	return (alpha * 0x01000000) + (red * 0x00010000) + (green * 0x00000100);
end
getColor = getColour; -- To speak Americano

-- Finds the root of a linked list
function find_root(object)
	local count = 0;
	local prevObject = object;
	while object > 0 do
		dprint(count..": "..toHexString(object + 0x10, 6, "").." Size: "..toHexString(prevObject - object));
		prevObject = object;
		object = mainmemory.read_u24_be(object + 1);
		count = count + 1;
	end
	print_deferred();
end
findRoot = find_root;

-- Finds the root of a linked list, outputting object size
function find_root_size(object)
	local count = 0;
	while object > 0 do
		dprint(count..": "..toHexString(object + 0x10, 6, "").." Size: "..toHexString(mainmemory.read_u32_be(object + 4)));
		object = mainmemory.read_u24_be(object + 1);
		count = count + 1;
	end
	print_deferred();
end
findRootSize = find_root_size;

-- Finds the end of a linked list, outputting object size
function traverse_size(object, minimumPrintSize, maximumPrintSize)
	minimumPrintSize = minimumPrintSize or -math.huge;
	maximumPrintSize = maximumPrintSize or math.huge;
	local count = 0;
	local size = 0;
	local prev = 0;
	repeat
		count = count + 1;
		size = mainmemory.read_u32_be(object + 4);
		if size >= minimumPrintSize and size <= maximumPrintSize then
			dprint(count..": "..toHexString(object + 0x10, 6, "").." "..(object + 0x10).." Size: "..toHexString(size));
		end
		object = object + 0x10 + size;
		prev = mainmemory.read_u32_be(object);
	until prev == 0 or not isRDRAM(object);
	print_deferred();
end
traverseSize = traverse_size;

-- Finds the end of a linked list
function traverse(object)
	local count = 0;
	local prevObject = object;
	while isRDRAM(object) do
		dprint(count..": "..toHexString(object + 0x10, 6, "").." Size: "..toHexString(object - prevObject));
		prevObject = object;
		object = dereferencePointer(object + 4);
		count = count + 1;
	end
	print_deferred();
end

function searchPointers(base, range, allowLater)
	local foundPointers = {};
	allowLater = allowLater or false;
	for address = 0, RDRAMSize - 4, 4 do
		local value = mainmemory.read_u32_be(address);
		if allowLater then
			if value >= base - range and value <= base + range then
				table.insert(foundPointers, {["Address"] = toHexString(address), ["Value"] = toHexString(value)});
				dprint(toHexString(address).." -> "..toHexString(value));
			end
		else
			if value >= base - range and value <= base then
				table.insert(foundPointers, {["Address"] = toHexString(address), ["Value"] = toHexString(value)});
				dprint(toHexString(address).." -> "..toHexString(value));
			end
		end
	end
	print_deferred();
	return foundPointers;
end

function searchPointersLE(base, range, allowLater) -- Little Endian Version (PSX etc) TODO: Endianness as a param? Or ifdef it out with same signature
	local foundPointers = {};
	allowLater = allowLater or false;
	for address = 0, RAMSize - 4, 4 do
		local value = mainmemory.read_u32_le(address);
		if allowLater then
			if value >= base - range and value <= base + range then
				table.insert(foundPointers, {["Address"] = toHexString(address), ["Value"] = toHexString(value)});
				dprint(toHexString(address).." -> "..toHexString(value));
			end
		else
			if value >= base - range and value <= base then
				table.insert(foundPointers, {["Address"] = toHexString(address), ["Value"] = toHexString(value)});
				dprint(toHexString(address).." -> "..toHexString(value));
			end
		end
	end
	print_deferred();
	return foundPointers;
end

function getMemoryStats(object)
	local size = 0;
	local prev = 0;
	local nextFree = 0;
	local prevFree = 0;
	local memoryStats = {
		["free"] = 0,
		["used"] = 0,
	};
	if isRDRAM(object) then
		repeat
			size = mainmemory.read_u32_be(object + 4); -- TODO: These offsets only apply to DK64's heap header
			nextFree = dereferencePointer(object + 8);
			prevFree = dereferencePointer(object + 12);
			if isRDRAM(nextFree) or isRDRAM(prevFree) then
				memoryStats.free = memoryStats.free + size;
			else
				memoryStats.used = memoryStats.used + size;
			end
			object = object + 0x10 + size;
			prev = dereferencePointer(object);
		until (not isRDRAM(prev)) or (not isRDRAM(object));
	end
	return memoryStats;
end

function mainmemory.readfloat_be(address)
	return mainmemory.readfloat(address, true);
end

function mainmemory.writefloat_be(address, value)
	mainmemory.writefloat(address, value, true);
end

function mainmemory.readfloat_le(address)
	return mainmemory.readfloat(address, false);
end

function mainmemory.writefloat_le(address, value)
	mainmemory.writefloat(address, value, false);
end

-- Replaces all instances of a given value in memory
-- This logic is reused in the wrappers below
function replace_memory(find, replace, read_function, write_function, stride)
	for i = 0, RDRAMSize - stride, stride do
		if read_function(i) == find then
			dprint("Replaced "..toHexString(i, 6));
			write_function(i, replace);
		end
	end
	print_deferred();
end

function replacebyte(find, replace)
	replace_memory(find, replace, mainmemory.readbyte, mainmemory.writebyte, 1);
end
replace_u8 = replacebyte;

function replace_s8(find, replace)
	replace_memory(find, replace, mainmemory.read_s8, mainmemory.write_s8, 1);
end

function replace_u16_be(find, replace)
	replace_memory(find, replace, mainmemory.read_u16_be, mainmemory.write_u16_be, 2);
end

function replace_s16_be(find, replace)
	replace_memory(find, replace, mainmemory.read_s16_be, mainmemory.write_s16_be, 2);
end

function replace_u16_le(find, replace)
	replace_memory(find, replace, mainmemory.read_u16_le, mainmemory.write_u16_le, 2);
end

function replace_s16_le(find, replace)
	replace_memory(find, replace, mainmemory.read_s16_le, mainmemory.write_s16_le, 2);
end

function replace_u32_be(find, replace)
	replace_memory(find, replace, mainmemory.read_u32_be, mainmemory.write_u32_be, 4);
end

function replace_s32_be(find, replace)
	replace_memory(find, replace, mainmemory.read_s32_be, mainmemory.write_s32_be, 4);
end

function replace_u32_le(find, replace)
	replace_memory(find, replace, mainmemory.read_u32_le, mainmemory.write_u32_le, 4);
end

function replace_s32_le(find, replace)
	replace_memory(find, replace, mainmemory.read_s32_le, mainmemory.write_s32_le, 4);
end

function replace_float_be(find, replace)
	replace_memory(find, replace, mainmemory.readfloat_be, mainmemory.writefloat_be, 4);
end

function replace_float_le(find, replace)
	replace_memory(find, replace, mainmemory.readfloat_le, mainmemory.writefloat_le, 4);
end

function readNullTerminatedString(base, max_length)
	max_length = max_length or 25;
	local builtString = "";
	for i = 0, max_length do
		local character = mainmemory.readbyte(base + i);
		if character == 0 then
			return builtString;
		end
		builtString = builtString..string.char(character);
	end
	return builtString;
end

function writeNullTerminatedString(pointer, message)
	for i = 1, string.len(message) do
		mainmemory.writebyte(pointer + i - 1, string.byte(message, i));
	end
	mainmemory.writebyte(pointer + string.len(message), 0x00);
end

function locals()
	local variables = {};
	local idx = 1;
	while true do
		local ln, lv = debug.getlocal(2, idx);
		if ln ~= nil then
			variables[ln] = lv;
		else
			break;
		end
		idx = idx + 1;
	end
	return variables;
end

function countLocals()
	local idx = 0;
	while true do
		local ln, lv = debug.getlocal(2, idx + 1);
		if ln == nil then
			break;
		end
		idx = idx + 1;
	end
	return idx;
end