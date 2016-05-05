ScriptHawk = {};

if emu.getsystemid() == "N64" then
	RDRAMBase = 0x80000000;
	RDRAMSize = 0x800000; -- Halved with no expansion pak

	-- Dereferences a N64 RDRAM pointer
	-- Returns the RDRAM address pointed to if it's a valid pointer
	-- Returns nil if invalid
	function dereferencePointer(address)
		if type(address) == "number" and address >= 0 and address < (RDRAMSize - 4) then
			address = mainmemory.read_u32_be(address);
			if address >= RDRAMBase and address < RDRAMBase + RDRAMSize then
				return address - RDRAMBase;
			end
		end
	end

	-- Checks whether a value falls within N64 RDRAM
	function isRDRAM(value)
		return type(value) == "number" and value >= 0 and value < RDRAMSize;
	end

	-- Checks whether a value is a N64 RDRAM pointer
	function isPointer(value)
		return type(value) == "number" and value >= RDRAMBase and value < RDRAMBase + RDRAMSize;
	end
end

--------------------
-- UI State Table --
--------------------

ScriptHawk.UI = {
	["form_controls"] = {}, -- TODO: Detect UI position problems using this array
	["form_padding"] = 8,
	["label_offset"] = 5,
	["dropdown_offset"] = 1,
	["long_label_width"] = 140,
	["button_height"] = 23,
};

----------------------
-- Helper functions --
----------------------

image_directory_root = ".\\Images\\";
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

function stringContains(haystack, needle)
	return type(string.find(haystack, esc(needle))) == "number";
end

function toHexString(value, desiredLength, prefix)
	value = string.format("%X", value or 0);
	prefix = prefix or "0x";
	desiredLength = desiredLength or string.len(value);
	while string.len(value) < desiredLength do
		value = "0"..value;
	end
	return prefix..value;
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
	while object > 0 do
		dprint(count..": "..toHexString(object + 0x10, 6, "").." Size: "..toHexString(object - prevObject));
		prevObject = object;
		object = mainmemory.read_u24_be(object + 4 + 1);
		count = count + 1;
	end
	print_deferred();
end

function replace_u32_be(find, replace)
	for i = 0, RDRAMSize - 4, 4 do
		if mainmemory.read_u32_be(i) == find then
			dprint("Replaced "..toHexString(i, 6));
			mainmemory.write_u32_be(i, replace);
		end
	end
	print_deferred();
end

max_string_length = 25;
function readNullTerminatedString(base)
	local builtString = "";
	local length = 0;
	local nextByte = mainmemory.readbyte(base + length);
	repeat
		builtString = builtString..string.char(nextByte);
		length = length + 1;
		nextByte = mainmemory.readbyte(base + length);
	until nextByte == 0 or length > max_string_length;
	return builtString;
end

--------------------
-- Load libraries --
--------------------

JSON = require "lib.JSON";
Stats = require "lib.Stats";
lips = require "lips.init";
require "lib.pngLua.png";
require "lib.DPrint";

-----------------------
-- Keybind framework --
-----------------------

ScriptHawk.keybindsFrame = {};
ScriptHawk.keybindsRealtime = {};

ScriptHawk.joypadBindsFrame = {};
ScriptHawk.joypadBindsRealtime = {};

function ScriptHawk.bind(keybindArray, key, callback, preventHold)
	if type(keybindArray) == "table" and type(key) == "string" and type(callback) == "function" then
		if type(preventHold) ~= 'boolean' then
			preventHold = true;
		end
		table.insert(keybindArray, {['key'] = key, ['callback'] = callback, ['pressed'] = false, ['preventHold'] = preventHold});
	end
end

function ScriptHawk.bindKeyRealtime(key, callback, preventHold)
	ScriptHawk.bind(ScriptHawk.keybindsRealtime, key, callback, preventHold);
end

function ScriptHawk.bindKeyFrame(key, callback, preventHold)
	ScriptHawk.bind(ScriptHawk.keybindsFrame, key, callback, preventHold);
end

function ScriptHawk.bindJoypadFrame(key, callback, preventHold)
	ScriptHawk.bind(ScriptHawk.joypadBindsFrame, key, callback, preventHold);
end

function ScriptHawk.bindJoypadRealtime(key, callback, preventHold)
	ScriptHawk.bind(ScriptHawk.joypadBindsRealtime, key, callback, preventHold);
end

function ScriptHawk.unbind(keybinds, key)
	if type(key) == "string" then
		for i, keybind in ipairs(keybinds) do
			if key == keybind.key then
				table.remove(keybinds, i);
			end
		end
	end
end

function ScriptHawk.processKeybinds(keybinds)
	local input_table = input.get();

	for i, keybind in ipairs(keybinds) do
		if not input_table[keybind.key] then
			keybind.pressed = false;
		end
		if input_table[keybind.key] and (not keybind.preventHold or not keybind.pressed) then
			keybind.callback();
			keybind.pressed = true;
		end
	end
end

function ScriptHawk.processJoypadBinds(joypadBinds)
	local input_table = joypad.getimmediate();

	for i, joypadBind in ipairs(joypadBinds) do
		if not input_table[joypadBind.key] then
			joypadBind.pressed = false;
		end
		if input_table[joypadBind.key] and (not joypadBind.preventHold or not joypadBind.pressed) then
			joypadBind.callback();
			joypadBind.pressed = true;
		end
	end
end

-----------------
-- Game checks --
-----------------

local supportedGames = {
	-- Banjo
	["90726D7E7CD5BF6CDFD38F45C9ACBF4D45BD9FD8"] = {["moduleName"] = "games.bk", ["friendlyName"] = "Banjo to Kazooie no Daibouken (Japan)"},
	["5A5172383037D171F121790959962703BE1F373C"] = {["moduleName"] = "games.bt", ["friendlyName"] = "Banjo to Kazooie no Daibouken 2 (Japan)"},
	["BB359A75941DF74BF7290212C89FBC6E2C5601FE"] = {["moduleName"] = "games.bk", ["friendlyName"] = "Banjo-Kazooie (Europe) (En,Fr,De)"},
	["DED6EE166E740AD1BC810FD678A84B48E245AB80"] = {["moduleName"] = "games.bk", ["friendlyName"] = "Banjo-Kazooie (USA) (Rev A)"},
	["1FE1632098865F639E22C11B9A81EE8F29C75D7A"] = {["moduleName"] = "games.bk", ["friendlyName"] = "Banjo-Kazooie (USA)"},
	["4CA2D332F6E6B018777AFC6A8B7880B38B6DFB79"] = {["moduleName"] = "games.bt", ["friendlyName"] = "Banjo-Tooie (Australia)"},
	["93BF2FAC1387320AD07251CB4B64FD36BAC1D7A6"] = {["moduleName"] = "games.bt", ["friendlyName"] = "Banjo-Tooie (Europe) (En,Fr,De,Es)"},
	["AF1A89E12B638B8D82CC4C085C8E01D4CBA03FB3"] = {["moduleName"] = "games.bt", ["friendlyName"] = "Banjo-Tooie (USA)"},

	-- Conker's Bad Fur Day
	["EE7BC6656FD1E1D9FFB3D19ADD759F28B88DF710"] = {["moduleName"] = "games.cbfd", ["friendlyName"] = "Conker's Bad Fur Day (Europe)"},
	["4CBADD3C4E0729DEC46AF64AD018050EADA4F47A"] = {["moduleName"] = "games.cbfd", ["friendlyName"] = "Conker's Bad Fur Day (USA)"},

	-- Diddy Kong Racing
	["B7F628073237B3D211D40406AA0884FF8FDD70D5"] = {["moduleName"] = "games.dkr", ["friendlyName"] = "Diddy Kong Racing (Europe) (En,Fr,De) (Rev A)"},
	["DD5D64DD140CB7AA28404FA35ABDCABA33C29260"] = {["moduleName"] = "games.dkr", ["friendlyName"] = "Diddy Kong Racing (Europe) (En,Fr,De)"},
	["23BA3D302025153D111416E751027CEF11213A19"] = {["moduleName"] = "games.dkr", ["friendlyName"] = "Diddy Kong Racing (Japan)"},
	["6D96743D46F8C0CD0EDB0EC5600B003C89B93755"] = {["moduleName"] = "games.dkr", ["friendlyName"] = "Diddy Kong Racing (USA) (En,Fr) (Rev A)"},
	["0CB115D8716DBBC2922FDA38E533B9FE63BB9670"] = {["moduleName"] = "games.dkr", ["friendlyName"] = "Diddy Kong Racing (USA) (En,Fr)"},

	-- Donkey Kong 64
	["F96AF883845308106600D84E0618C1A066DC6676"] = {["moduleName"] = "games.dk64", ["friendlyName"] = "Donkey Kong 64 (Europe) (En,Fr,De,Es)"},
	["F0AD2B2BBF04D574ED7AFBB1BB6A4F0511DCD87D"] = {["moduleName"] = "games.dk64", ["friendlyName"] = "Donkey Kong 64 (Japan)"},
	["B4717E602F07CA9BE0D4822813C658CD8B99F993"] = {["moduleName"] = "games.dk64", ["friendlyName"] = "Donkey Kong 64 (USA) (Demo) (Kiosk)"},
	["CF806FF2603640A748FCA5026DED28802F1F4A50"] = {["moduleName"] = "games.dk64", ["friendlyName"] = "Donkey Kong 64 (USA)"},

	-- Elmo
	["97777CA06F4E8AFF8F1E95033CC8D3833BE40F76"] = {["moduleName"] = "games.elmo", ["friendlyName"] = "Elmo's Letter Adventure (USA)"},
	["7195EA96D9FE5DE065AF61F70D55C92C8EE905E6"] = {["moduleName"] = "games.elmo", ["friendlyName"] = "Elmo's Number Journey (USA)"},

	-- Galahad
	["536E5A1FFB50D33632A9978B35DB5DF6"] = {["moduleName"] = "beta.Galahad", ["selfContained"] = true, ["friendlyName"] = "Legend of Galahad, The (UE) [!]"},
	["FA7A34B92D06013625C2FE155A9DB5A8"] = {["moduleName"] = "beta.Galahad", ["selfContained"] = true, ["friendlyName"] = "Legend of Galahad, The (UE) [t1+C]"},
	["3F183BD8A7360E3BE3CF65AE8FF9810C"] = {["moduleName"] = "beta.Galahad", ["selfContained"] = true, ["friendlyName"] = "Legend of Galahad, The (UE) [t1]"},

	-- MM
	["B38B71D2961DFFB523020A67F4807A4B704E347A"] = {["moduleName"] = "games.mm", ["friendlyName"] = "Legend of Zelda, The - Majora's Mask (Europe) (En,Fr,De,Es) (Beta)"},
	["BB4E4757D10727C7584C59C1F2E5F44196E9C293"] = {["moduleName"] = "games.mm", ["friendlyName"] = "Legend of Zelda, The - Majora's Mask (Europe) (En,Fr,De,Es) (Rev A)"},
	["C04599CDAFEE1C84A7AF9A71DF68F139179ADA84"] = {["moduleName"] = "games.mm", ["friendlyName"] = "Legend of Zelda, The - Majora's Mask (Europe) (En,Fr,De,Es)"},
	["2F0744F2422B0421697A74B305CB1EF27041AB11"] = {["moduleName"] = "games.mm", ["friendlyName"] = "Legend of Zelda, The - Majora's Mask (USA) (Demo)"},
	["D6133ACE5AFAA0882CF214CF88DABA39E266C078"] = {["moduleName"] = "games.mm", ["friendlyName"] = "Legend of Zelda, The - Majora's Mask (USA)"},
	["41FDB879AB422EC158B4EAFEA69087F255EA8589"] = {["moduleName"] = "games.mm", ["friendlyName"] = "Zelda no Densetsu - Mujura no Kamen (Japan) (Rev A)"},
	["5FB2301AACBF85278AF30DCA3E4194AD48599E36"] = {["moduleName"] = "games.mm", ["friendlyName"] = "Zelda no Densetsu - Mujura no Kamen (Japan)"},

	-- Mr. Driller
	["E7009DD8418303343C4AAC2558538B8CAA28B694"] = {["moduleName"] = "beta.Drillbot", ["selfContained"] = true, ["friendlyName"] = "Mr. Driller 2 (USA)"},

	-- OoT
	["CFBB98D392E4A9D39DA8285D10CBEF3974C2F012"] = {["moduleName"] = "games.oot", ["friendlyName"] = "Legend of Zelda, The - Ocarina of Time (Europe) (En,Fr,De) (Rev A)"},
	["328A1F1BEBA30CE5E178F031662019EB32C5F3B5"] = {["moduleName"] = "games.oot", ["friendlyName"] = "Legend of Zelda, The - Ocarina of Time (Europe) (En,Fr,De)"},
	["D3ECB253776CD847A5AA63D859D8C89A2F37B364"] = {["moduleName"] = "games.oot", ["friendlyName"] = "Legend of Zelda, The - Ocarina of Time (USA) (Rev A)"},
	["41B3BDC48D98C48529219919015A1AF22F5057C2"] = {["moduleName"] = "games.oot", ["friendlyName"] = "Legend of Zelda, The - Ocarina of Time (USA) (Rev B)"},
	["AD69C91157F6705E8AB06C79FE08AAD47BB57BA7"] = {["moduleName"] = "games.oot", ["friendlyName"] = "Legend of Zelda, The - Ocarina of Time (USA)"},
	["50BEBEDAD9E0F10746A52B07239E47FA6C284D03"] = {["moduleName"] = "games.oot", ["friendlyName"] = "Legend of Zelda, The - Ocarina of Time - Master Quest (USA) (Debug Edition)"},
	["8B5D13AAC69BFBF989861CFDC50B1D840945FC1D"] = {["moduleName"] = "games.oot", ["friendlyName"] = "Legend of Zelda, The - Ocarina of Time - Master Quest (USA) (GC)"},
	["DBFC81F655187DC6FEFD93FA6798FACE770D579D"] = {["moduleName"] = "games.oot", ["friendlyName"] = "Zelda no Densetsu - Toki no Ocarina (Japan) (Rev A)"},
	["FA5F5942B27480D60243C2D52C0E93E26B9E6B86"] = {["moduleName"] = "games.oot", ["friendlyName"] = "Zelda no Densetsu - Toki no Ocarina (Japan) (Rev B)"},
	["C892BBDA3993E66BD0D56A10ECD30B1EE612210F"] = {["moduleName"] = "games.oot", ["friendlyName"] = "Zelda no Densetsu - Toki no Ocarina (Japan)"},
	["DD14E143C4275861FE93EA79D0C02E36AE8C6C2F"] = {["moduleName"] = "games.oot", ["friendlyName"] = "Zelda no Densetsu - Toki no Ocarina (Japan) (GC)"},

	-- Rayman 2
	["619AB27EA1645399439AD324566361D3E7FF020E"] = {["moduleName"] = "games.rayman_2", ["friendlyName"] = "Rayman 2 - The Great Escape (Europe) (En,Fr,De,Es,It)"},
	["50558356B059AD3FBAF5FE95380512B9DCEAAF52"] = {["moduleName"] = "games.rayman_2", ["friendlyName"] = "Rayman 2 - The Great Escape (USA) (En,Fr,De,Es,It)"},

	-- SM64
	["4AC5721683D0E0B6BBB561B58A71740845DCEEA9"] = {["moduleName"] = "games.sm64", ["friendlyName"] = "Super Mario 64 (Europe) (En,Fr,De)"},
	["3F319AE697533A255A1003D09202379D78D5A2E0"] = {["moduleName"] = "games.sm64", ["friendlyName"] = "Super Mario 64 (Japan) (Rev A) (Shindou Edition)"},
	["8A20A5C83D6CEB0F0506CFC9FA20D8F438CAFE51"] = {["moduleName"] = "games.sm64", ["friendlyName"] = "Super Mario 64 (Japan)"},
	["9BEF1128717F958171A4AFAC3ED78EE2BB4E86CE"] = {["moduleName"] = "games.sm64", ["friendlyName"] = "Super Mario 64 (USA)"},

	-- Tetris Attack
	-- TODO: Support more versions of this game
	["EAD855D774C9943F7FFB5B4F429B2DD07FB6F606"] = {["moduleName"] = "Tetris Attack Bot", ["selfContained"] = true, ["friendlyName"] = "Panel de Pon (Japan)"}, -- SNES
	["B59061561A3AEAC13E46735582F29826E7310141"] = {["moduleName"] = "Tetris Attack Bot", ["selfContained"] = true, ["friendlyName"] = "Panel de Pon - Event '98 (Japan) (BS)"}, -- SNES
	["08E01F9AD5B6148E1A4355C80E2B23D8B2463443"] = {["moduleName"] = "Tetris Attack Bot", ["selfContained"] = true, ["friendlyName"] = "Tetris Attack (Europe) (En,Ja)"}, -- SNES
	["2DC56EAB3E70C0910AE47119D8B69F494E6000DF"] = {["moduleName"] = "Tetris Attack Bot", ["selfContained"] = true, ["friendlyName"] = "Tetris Attack (USA) (En,Ja)"}, -- SNES

	-- Toy Story 2
	["A9F97E22391313095D2C2FBAF81FB33BFA2BA7C6"] = {["moduleName"] = "games.ts2", ["friendlyName"] = "Toy Story 2 - Buzz l'Eclair a la Rescousse! (France)"},
	["92015E5254CBBAD1BC668ECB13A4B568E5F55052"] = {["moduleName"] = "games.ts2", ["friendlyName"] = "Toy Story 2 - Buzz Lightyear to the Rescue! (Europe)"},
	["982AD2E1E44C6662C88A77367BC5DF91C51531BF"] = {["moduleName"] = "games.ts2", ["friendlyName"] = "Toy Story 2 - Buzz Lightyear to the Rescue! (USA)"},
	["EAE83C07E2E777D8E71A5BE6120AED03D7E67782"] = {["moduleName"] = "games.ts2", ["friendlyName"] = "Toy Story 2 - Captain Buzz Lightyear auf Rettungsmission! (Germany) (Rev A)"},
	["F8FBB100227015BE8629243F53D70F29A2A14315"] = {["moduleName"] = "games.ts2", ["friendlyName"] = "Toy Story 2 - Captain Buzz Lightyear auf Rettungsmission! (Germany)"},

	-- Wonder Boy III
	["E7F86C049E4BD8B26844FF62BD067D57"] = {["moduleName"] = "beta.Wonder Boy III RNG Watch", ["selfContained"] = true, ["friendlyName"] = "Wonder Boy III - The Dragon's Trap (UE)"},
};

local romName = gameinfo.getromname();
local romHash = gameinfo.getromhash();
Game = nil;
for k, v in pairs(supportedGames) do
	if romHash == k then
		Game = require (v.moduleName);
		if v.selfContained then -- Self contained modules that do not require ScriptHawk's functionality and merely use ScriptHawk.lua as a convenient loader
			return true;
		end
	end
end

if Game == nil then
	print("This game is not currently supported.");
	return false;
end

if type(Game.detectVersion) ~= "function" or not Game.detectVersion(romName, romHash) then
	print("This version of the game is not currently supported.");
	return false;
end

----------------
-- ASM Loader --
----------------

-- Output gameshark code
function outputGamesharkCode(bytes, base, skipZeroes)
	skipZeroes = skipZeroes or false;
	skippedZeroes = 0;
	if type(bytes) == "table" and #bytes > 0 and #bytes % 2 == 0 then
		for i = 1, #bytes, 2 do
			if not (skipZeroes and bytes[i] == 0x00 and bytes[i + 1] == 0x00) then
				dprint("81"..toHexString(base + i - 1, 6, "").." "..toHexString(bytes[i], 2, "")..toHexString(bytes[i + 1], 2, ""));
			else
				skippedZeroes = skippedZeroes + 1;
			end
		end
	end
	return skippedZeroes;
end

local code = {};

function codeWriter(...)
	table.insert(code, arg[2]);
end

function loadASMPatch(code_filename, suppress_print)
	if Game.supportsASMHacks then
		if not fileExists(code_filename) then
			code_filename = forms.openfile(nil, nil, "R4300i Assembly Code|*.asm|All Files (*.*)|*.*");
			if not fileExists(code_filename) then
				if not suppress_print then
					print("No code loaded, aborting mission...");
				end
				return false;
			end
		end

		-- Open the file and assemble the code
		code = {};
		local result = lips(code_filename, codeWriter, {['unsafe'] = true, ['offset'] = Game.ASMCodeBase + RDRAMBase});

		if #code == 0 then
			if not suppress_print then
				print(result);
				print("The code did not compile correctly, check for errors in your source.");
			end
			return false;
		end

		if #code > Game.ASMMaxCodeSize then
			if not suppress_print then
				print("The compiled code was too large to safely inject into the game.");
			end
			return false;
		end

		-- Patch the code
		for i = 1, #code do
			mainmemory.writebyte(Game.ASMCodeBase + (i - 1), code[i]);
		end

		-- Patch the hook
		for i = 1, #Game.ASMHook do
			mainmemory.writebyte(Game.ASMHookBase + (i - 1), Game.ASMHook[i]);
		end

		-- Hacky, yes, but if we're using dynarec the patched code pages don't get marked as dirty
		-- Quickest and easiest way around this is to save and reload a state
		local ss_fn = 'lips/temp.state'
		savestate.save(ss_fn)
		savestate.load(ss_fn)

		if not suppress_print then
			outputGamesharkCode(Game.ASMHook, Game.ASMHookBase, false);
			outputGamesharkCode(code, Game.ASMCodeBase, false);

			dprint("Patched code ("..#code.." bytes)");
			dprint("Patched hook ("..#Game.ASMHook.." bytes)");
			dprint("Done!");
			print_deferred();
		end
		return true;
	else
		if not suppress_print then
			print("This game does not support ASM hacks.");
		end
		return false;
	end
end

-------------
-- Texture --
-------------

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

	img = pngImage(filename);

	for y = 1, height do
		for x = 1, width do
			if x <= img.width and y <= img.height then
				local pixel = img:getPixel(x, y);
				local r = math.floor(pixel.R / img.depth) * rgba5551_color_constants["Red"];
				local g = math.floor(pixel.G / img.depth) * rgba5551_color_constants["Green"];
				local b = math.floor(pixel.B / img.depth) * rgba5551_color_constants["Blue"];
				local a = 0;
				if pixel.A > 0 then
					a = 1
				end

				mainmemory.write_u16_be(base + ((y - 1) * width * 2) + ((x - 1) * 2), r + g + b + a);
			end
		end
	end
end

-----------
-- State --
-----------

local mode = "Position";
local rotation_units = "Degrees";

-- Stops garbage min/max dx/dy/dz values
local firstframe = true;
previous_frame = emu.framecount();
current_frame = emu.framecount();

previous_map = "";
previous_map_value = 0;

local dx = 0.0;
local dy = 0.0;
local dz = 0.0;
local d  = 0.0;
local odometer = 0.0;

local prev_x = 0.0;
local prev_y = 0.0;
local prev_z = 0.0;

local max_dx = 0.0;
local max_dy = 0.0;
local max_dz = 0.0;
local max_d  = 0.0;

-- Rounding precision
precision = 3;

local function decreasePrecision()
	precision = math.max(0, precision - 1);
end

local function increasePrecision()
	precision = math.min(5, precision + 1);
end

local function decreaseSpeed()
	Game.speedy_index = math.max(1, Game.speedy_index - 1);
end

local function increaseSpeed()
	Game.speedy_index = math.min(#Game.speedy_speeds, Game.speedy_index + 1);
end

-------------------------
-- Practice mode stuff --
-------------------------

local practice_save_slot = 0;

local function decreaseSaveSlot()
	if mode == "Practice" then
		practice_save_slot = math.max(0, practice_save_slot - 1);
		gui.addmessage("Switched to save slot "..practice_save_slot);
	end
end

local function increaseSaveSlot()
	if mode == "Practice" then
		practice_save_slot = math.min(9, practice_save_slot + 1);
		gui.addmessage("Switched to save slot "..practice_save_slot);
	end
end

local function loadPracticeSlot()
	if mode == "Practice" then
		savestate.loadslot(practice_save_slot);
	end
end

local function savePracticeSlot()
	if mode == "Practice" then
		savestate.saveslot(practice_save_slot);
	end
end

-- Practice mode JoypadBinds
ScriptHawk.bindJoypadRealtime("P1 DPad L", decreaseSaveSlot, true);
ScriptHawk.bindJoypadRealtime("P1 DPad R", increaseSaveSlot, true);
ScriptHawk.bindJoypadRealtime("P1 DPad U", savePracticeSlot, true);
ScriptHawk.bindJoypadRealtime("P1 DPad D", loadPracticeSlot, true);
ScriptHawk.bindJoypadRealtime("P1 L", loadPracticeSlot, true);

----------------------------
-- Other helper functions --
----------------------------

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

function rotation_to_degrees(num)
	return ((num % Game.max_rot_units) / Game.max_rot_units) * 360;
end

two_pi = math.pi * 2;
function rotation_to_radians(num)
	return ((num % Game.max_rot_units) / Game.max_rot_units) * two_pi;
end

function array_contains(array, value)
	if type(array) == "table" then
		-- TODO: Special check for index zero because ipairs doesn't support starting from 0?
		if type(array[0]) ~= "nil" then
			if array[0] == value then
				return true;
			end
		end

		-- Carry on
		for i, v in ipairs(array) do
			if v == value then
				return true;
			end
		end
	end
	return false;
end
arrayContains = array_contains;

local function toggleRotationUnits()
	if rotation_units == "Degrees" then
		rotation_units = "Radians";
	elseif rotation_units == "Radians" then
		rotation_units = "Units";
	else
		rotation_units = "Degrees";
	end
end

function ScriptHawk.UI.formatRotation(num)
	num = num or 0;
	if isnan(num) then
		num = 0;
	end
	if rotation_units == "Degrees" then
		return round(rotation_to_degrees(num), precision).."°";
	elseif rotation_units == "Radians" then
		return round(rotation_to_radians(num), precision);
	end
	return num;
end

local function toggleMode()
	if mode == 'Position' then
		mode = 'Rotation';
	elseif mode == 'Rotation' then
		mode = 'Practice';
	else
		mode = 'Position';
	end
end

---------------
-- Telemetry --
---------------

telemetryData = {};
local collecting_telemetry = false;

function getTelemetryHeaderString()
	local headerString = "Time (Frames),";
	for i, v in ipairs(Game.OSD) do
		if type(v) == "table" then
			if v[1] ~= "Separator" then
				headerString = headerString..v[1]..",";
			end
		end
	end
	return headerString;
end

-- Outputs telemetry data as CSV to the console
local function outputTelemetry()
	-- Print CSV header
	dprint(getTelemetryHeaderString());

	-- Print CSV values
	for i = 1, #telemetryData do
		local outputString = i..",";
		for k, v in ipairs(telemetryData[i]) do
			outputString = outputString..(v)..",";
		end
		dprint(outputString);
	end

	print_deferred();
end

local function startTelemetry()
	collecting_telemetry = true;
	forms.settext(ScriptHawk.UI.form_controls["Toggle Telemetry Button"], "Stop Telemetry");
	telemetryData = {};
end

local function stopTelemetry()
	collecting_telemetry = false;
	forms.settext(ScriptHawk.UI.form_controls["Toggle Telemetry Button"], "Start Telemetry");

	outputTelemetry();
	return;

	-- Output to file
	-- Output data to JSON
	--local json_data = JSON:encode_pretty(telemetryData);
	--local file = io.open("Lua/ScriptHawk/DK64_Y_Data.json", "w+");
	--if type(file) ~= "nil" then
		--io.output(file);
		--io.write(json_data);
		--io.close(file);
	--else
		--print("Error writing to file =(");
		--outputTelemetry();
	--end
end

local function toggleTelemetry()
	if collecting_telemetry then
		stopTelemetry();
	else
		startTelemetry();
	end
end

-------------
-- UI Code --
-------------

function ScriptHawk.UI.row(row_num)
	return round(ScriptHawk.UI.form_padding + ScriptHawk.UI.button_height * row_num, 0);
end

function ScriptHawk.UI.col(col_num)
	return ScriptHawk.UI.row(col_num);
end

ScriptHawk.UI.options_form = forms.newform(ScriptHawk.UI.col(17), ScriptHawk.UI.row(10), "ScriptHawk Options");

-- Handle, Type, Caption, Callback, X position, Y position, Width, Height
ScriptHawk.UI.form_controls["Mode Label"] = forms.label(ScriptHawk.UI.options_form, "Mode:", ScriptHawk.UI.col(0), ScriptHawk.UI.row(0) + ScriptHawk.UI.label_offset, 44, ScriptHawk.UI.button_height);
ScriptHawk.UI.form_controls["Mode Button"] = forms.button(ScriptHawk.UI.options_form, mode, toggleMode, ScriptHawk.UI.col(2), ScriptHawk.UI.row(0), 64, ScriptHawk.UI.button_height);

ScriptHawk.UI.form_controls["Precision Label"] = forms.label(ScriptHawk.UI.options_form, "Precision:", ScriptHawk.UI.col(0), ScriptHawk.UI.row(1) + ScriptHawk.UI.label_offset, 54, 14);
ScriptHawk.UI.form_controls["Decrease Precision Button"] = forms.button(ScriptHawk.UI.options_form, "-", decreasePrecision, ScriptHawk.UI.col(4) - 28, ScriptHawk.UI.row(1), ScriptHawk.UI.button_height, ScriptHawk.UI.button_height);
ScriptHawk.UI.form_controls["Increase Precision Button"] = forms.button(ScriptHawk.UI.options_form, "+", increasePrecision, ScriptHawk.UI.col(5) - 28, ScriptHawk.UI.row(1), ScriptHawk.UI.button_height, ScriptHawk.UI.button_height);
ScriptHawk.UI.form_controls["Precision Value Label"] = forms.label(ScriptHawk.UI.options_form, precision, ScriptHawk.UI.col(5), ScriptHawk.UI.row(1) + ScriptHawk.UI.label_offset, 44, 14);

ScriptHawk.UI.form_controls["Speed Label"] = forms.label(ScriptHawk.UI.options_form, "Speed:", ScriptHawk.UI.col(0), ScriptHawk.UI.row(2) + ScriptHawk.UI.label_offset, 54, 14);
ScriptHawk.UI.form_controls["Decrease Speed Button"] = forms.button(ScriptHawk.UI.options_form, "-", decreaseSpeed, ScriptHawk.UI.col(4) - 28, ScriptHawk.UI.row(2), ScriptHawk.UI.button_height, ScriptHawk.UI.button_height);
ScriptHawk.UI.form_controls["Increase Speed Button"] = forms.button(ScriptHawk.UI.options_form, "+", increaseSpeed, ScriptHawk.UI.col(5) - 28, ScriptHawk.UI.row(2), ScriptHawk.UI.button_height, ScriptHawk.UI.button_height);
ScriptHawk.UI.form_controls["Speed Value Label"] = forms.label(ScriptHawk.UI.options_form, "0", ScriptHawk.UI.col(5), ScriptHawk.UI.row(2) + ScriptHawk.UI.label_offset, 54, 14);

if type(Game.maps) == "table" then
	ScriptHawk.UI.form_controls["Map Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, Game.maps, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(3) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);
	if Game.takeMeThereType == nil or Game.takeMeThereType == "Checkbox" then
		Game.takeMeThereType = "Checkbox";
		ScriptHawk.UI.form_controls["Map Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Take me there", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(4) + ScriptHawk.UI.dropdown_offset);
	elseif Game.takeMeThereType == "Button" then
		ScriptHawk.UI.form_controls["Map Button"] = forms.button(ScriptHawk.UI.options_form, "Take me there", function() Game.setMap(previous_map_value); end, ScriptHawk.UI.col(0), ScriptHawk.UI.row(4), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);
	end
end

ScriptHawk.UI.form_controls["Toggle Telemetry Button"] = forms.button(ScriptHawk.UI.options_form, "Start Telemetry", toggleTelemetry, ScriptHawk.UI.col(10), ScriptHawk.UI.row(3), ScriptHawk.UI.col(4) + 10, ScriptHawk.UI.button_height);

if type(Game.applyInfinites) == "function" then
	ScriptHawk.UI.form_controls["Toggle Infinites Checkbox"] = forms.checkbox(ScriptHawk.UI.options_form, "Infinites", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(5) + ScriptHawk.UI.dropdown_offset);
end

ScriptHawk.UI.form_controls["Rotation Units Label"] = forms.label(ScriptHawk.UI.options_form, "Units:", ScriptHawk.UI.col(5), ScriptHawk.UI.row(0) + ScriptHawk.UI.label_offset, 44, 14);
ScriptHawk.UI.form_controls["Toggle Rotation Units Button"] = forms.button(ScriptHawk.UI.options_form, rotation_units, toggleRotationUnits, ScriptHawk.UI.col(7), ScriptHawk.UI.row(0), 64, ScriptHawk.UI.button_height);

-- Init any custom UI that the game module uses
if type(Game.initUI) == "function" then
	Game.initUI();
end

function ScriptHawk.UI.findMapValue()
	if type(Game.maps) == "table" then
		for i = 1, #Game.maps do
			if Game.maps[i] == previous_map then
				return i;
			end
		end
	end
	return 0;
end

-- Check for missing OSD definitions
if type(Game.OSD) ~= "table" then
	Game.OSD = {
		{"X", Game.getXPosition},
		{"Y", Game.getYPosition},
		{"Z", Game.getZPosition},
		{"Separator", 1},
		{"dY"},
		{"dXZ"},
		{"Separator", 1},
		{"Max dY"},
		{"Max dXZ"},
		{"Odometer"},
		{"Separator", 1},
		{"Rot. X", Game.getXRotation},
		{"Facing", Game.getYRotation},
		{"Rot. Z", Game.getZRotation},
	};
end

if type(Game.OSDPosition) ~= "table" then
	Game.OSDPosition = {2, 70};
end

if type(Game.OSDRowHeight) ~= "number" then
	Game.OSDRowHeight = 16;
end

local angleKeywords = {
	"Rot X", "Rot Y", "Rot Z", "Rot",
	"Rot. X", "Rot. Y", "Rot. Z", "Rot.",
	"Rotation X", "Rotation Y", "Rotation Z", "Rotation",
	"Facing", "Moving", "Angle"
};

function ScriptHawk.UI.updateReadouts()
	-- Update form buttons etc
	forms.settext(ScriptHawk.UI.form_controls["Speed Value Label"], Game.speedy_speeds[Game.speedy_index]);
	forms.settext(ScriptHawk.UI.form_controls["Precision Value Label"], precision);
	forms.settext(ScriptHawk.UI.form_controls["Mode Button"], mode);
	forms.settext(ScriptHawk.UI.form_controls["Toggle Rotation Units Button"], rotation_units);
	if type(Game.maps) == "table" and previous_map ~= forms.gettext(ScriptHawk.UI.form_controls["Map Dropdown"]) then
		previous_map = forms.gettext(ScriptHawk.UI.form_controls["Map Dropdown"]);
		previous_map_value = ScriptHawk.UI.findMapValue();
	end

	-- Draw OSD
	local row = 0;
	local OSDX = Game.OSDPosition[1];
	local OSDY = Game.OSDPosition[2];

	for i = 1, #Game.OSD do
		local label = Game.OSD[i][1];
		local value = Game.OSD[i][2];
		local color = Game.OSD[i][3];

		if label ~= "Separator" then
			-- Detect special keywords
			if label == "dY" or label == "DY" then
				value = dy or 0;
			end
			if label == "dXZ" or label == "DXZ" then
				value = d or 0;
			end

			if label == "Max dY" or label == "Max DY" then
				value = max_dy or 0;
			end
			if label == "Max dXZ" or label == "Max DXZ" then
				value = max_d or 0;
			end
			if label == "Odometer" then
				value = odometer or 0;
			end

			-- Get the value
			if type(value) == "function" then
				value = value();
			end

			-- Round the value
			if type(value) == "number" then
				value = round(value, precision);
			end

			-- Detect and format rotation based on a keyword search
			for j = 1, #angleKeywords do
				if label == angleKeywords[j] then
					value = ScriptHawk.UI.formatRotation(value);
				end
			end

			if type(color) == "function" then
				color = color();
			end

			gui.text(OSDX, OSDY + Game.OSDRowHeight * row, label..": "..value, color);
		else
			if type(value) == "number" and value > 1 then
				row = row + value - 1;
			end
		end
		row = row + 1;
	end
end

--------------------
-- Core functions --
--------------------

if type(Game.setPosition) ~= "function" then
	function Game.setPosition(x, y, z)
		Game.setXPosition(x);
		Game.setYPosition(y);
		Game.setZPosition(z);
	end
end

if type(Game.setRotation) ~= "function" then
	function Game.setRotation(x, y, z)
		Game.setXRotation(x);
		Game.setYRotation(y);
		Game.setZRotation(z);
	end
end

-- Default Game.isPhysicsFrame function
-- uses emu.islagged() as a fallback if the game module does not implement it
if type(Game.isPhysicsFrame) ~= "function" then
	function Game.isPhysicsFrame()
		return not emu.islagged();
	end
end

local function gofast(axis, speed)
	if axis == "x" then
		Game.setXPosition(Game.getXPosition() + speed);
	elseif axis == "y" then
		Game.setYPosition(Game.getYPosition() + speed);
	elseif axis == "z" then
		Game.setZPosition(Game.getZPosition() + speed);
	end
end

local function rotate(axis, amount)
	if axis == "x" then
		Game.setXRotation((Game.getXRotation() + amount) % Game.max_rot_units);
	elseif axis == "y" then
		Game.setYRotation((Game.getYRotation() + amount) % Game.max_rot_units);
	elseif axis == "z" then
		Game.setZRotation((Game.getZRotation() + amount) % Game.max_rot_units);
	end
end

local function mainloop()
	joypad_pressed = joypad.getimmediate();

	-- Calculate speed for D-Pad and L button
	local speedy_speed_XZ = Game.speedy_speeds[Game.speedy_index];
	local speedy_speed_Y = Game.speedy_speeds[Game.speedy_index];
	if Game.speedy_invert_XZ then
		speedy_speed_XZ = speedy_speed_XZ * -1;
	end

	if Game.speedy_invert_Y then
		speedy_speed_Y = speedy_speed_Y * -1;
	end

	if Game.isPhysicsFrame() then
		if mode == 'Position' then
			rot_rad = rotation_to_radians(Game.getYRotation());
			if Game.speedy_invert_UD then
				if joypad_pressed["P1 DPad U"] then
					gofast("x", -1.0 * (speedy_speed_XZ * math.sin(rot_rad)));
					gofast("z", -1.0 * (speedy_speed_XZ * math.cos(rot_rad)));
				end
				if joypad_pressed["P1 DPad D"] then
					gofast("x", speedy_speed_XZ * math.sin(rot_rad));
					gofast("z", speedy_speed_XZ * math.cos(rot_rad));
				end
			else
				if joypad_pressed["P1 DPad U"] then
					gofast("x", speedy_speed_XZ * math.sin(rot_rad));
					gofast("z", speedy_speed_XZ * math.cos(rot_rad));
				end
				if joypad_pressed["P1 DPad D"] then
					gofast("x", -1.0 * (speedy_speed_XZ * math.sin(rot_rad)));
					gofast("z", -1.0 * (speedy_speed_XZ * math.cos(rot_rad)));
				end
			end

			if Game.speedy_invert_LR then
				if joypad_pressed["P1 DPad L"] then
					gofast("x", -1.0 * (speedy_speed_XZ * math.cos(rot_rad)));
					gofast("z", speedy_speed_XZ * math.sin(rot_rad));
				end
				if joypad_pressed["P1 DPad R"] then
					gofast("x", speedy_speed_XZ * math.cos(rot_rad));
					gofast("z", -1.0 * (speedy_speed_XZ * math.sin(rot_rad)));
				end
			else
				if joypad_pressed["P1 DPad L"] then
					gofast("x", speedy_speed_XZ * math.cos(rot_rad));
					gofast("z", -1.0 * (speedy_speed_XZ * math.sin(rot_rad)));
				end
				if joypad_pressed["P1 DPad R"] then
					gofast("x", -1.0 * (speedy_speed_XZ * math.cos(rot_rad)));
					gofast("z", speedy_speed_XZ * math.sin(rot_rad));
				end
			end

			if joypad_pressed["P1 L"] then
				gofast("y", speedy_speed_Y);
			end
		end
		if mode == 'Rotation' then
			if joypad_pressed["P1 DPad U"] then
				rotate("x", Game.rot_speed);
			end
			if joypad_pressed["P1 DPad D"] then
				rotate("x", -Game.rot_speed);
			end
			if joypad_pressed["P1 DPad L"] then
				rotate("z", -Game.rot_speed);
			end
			if joypad_pressed["P1 DPad R"] then
				rotate("z", Game.rot_speed);
			end
			if joypad_pressed["P1 L"] then
				gofast("y", speedy_speed_Y);
			end
		end
	end

	if ScriptHawk.UI.form_controls["Toggle Infinites Checkbox"] ~= nil and forms.ischecked(ScriptHawk.UI.form_controls["Toggle Infinites Checkbox"]) then
		Game.applyInfinites();
	end

	if type(Game.maps) == "table" and Game.takeMeThereType == "Checkbox" and forms.ischecked(ScriptHawk.UI.form_controls["Map Checkbox"]) then
		Game.setMap(previous_map_value);
	end
end

local function plot_pos()
	ScriptHawk.processKeybinds(ScriptHawk.keybindsFrame);
	ScriptHawk.processKeybinds(ScriptHawk.joypadBindsFrame);
	if type(Game.eachFrame) == "function" then
		Game.eachFrame();
	end

	previous_frame = current_frame;
	current_frame = emu.framecount();

	local x = Game.getXPosition();
	local y = Game.getYPosition();
	local z = Game.getZPosition();

	if firstframe then
		prev_x = x;
		prev_y = y;
		prev_z = z;

		firstframe = false;
	end

	if lock_y then -- TODO: Checkbox
		if (not Game.speedy_invert_Y and y < prev_y) or (Game.speedy_invert_Y and y > prev_y) then
			Game.setYPosition(prev_y);
			y = prev_y;
		end
	end

	if Game.isPhysicsFrame() then
		if math.abs(current_frame - previous_frame) > 1 then
			dx = 0;
			dy = 0;
			dz = 0;
			max_dx = 0.0;
			max_dy = 0.0;
			max_dz = 0.0;
			max_d = 0.0;
		else
			dx = x - prev_x;
			dy = y - prev_y;
			dz = z - prev_z;
		end

		d = math.sqrt(dx*dx + dz*dz);
		odometer = odometer + d;

		if (max_dx ~= nil and max_dy ~= nil and max_dz ~= nil and max_d ~= nil) and (dx ~= nil and dy ~= nil and dz ~= nil and d ~= nil) then
			if math.abs(dx) > max_dx then max_dx = math.abs(dx) end
			if math.abs(dy) > max_dy then max_dy = math.abs(dy) end
			if math.abs(dz) > max_dz then max_dz = math.abs(dz) end
			if math.abs(current_frame - previous_frame) > 1 then
				max_dx = 0; max_dy = 0; max_dz = 0;
				max_d = 0;
			end
			if d > max_d then max_d = d end
		end

		prev_x = x;
		prev_y = y;
		prev_z = z;

		-- Telemetry
		if collecting_telemetry then
			local tempTelemetryData = {};
			for i = 1, #Game.OSD do
				local label = Game.OSD[i][1];
				local value = Game.OSD[i][2];

				if label ~= "Separator" then
					-- Detect special keywords
					if label == "dY" or label == "DY" then
						value = dy or 0;
					end
					if label == "dXZ" or label == "DXZ" then
						value = d or 0;
					end

					if label == "Max dY" or label == "Max DY" then
						value = max_dy or 0;
					end
					if label == "Max dXZ" or label == "Max DXZ" then
						value = max_d or 0;
					end
					if label == "Odometer" then
						value = odometer or 0;
					end

					-- Get the value
					if type(value) == "function" then
						value = value();
					end

					-- Round the value
					if type(value) == "number" then
						value = round(value, precision);
					end

					-- Detect and format rotation based on a keyword search
					for j = 1, #angleKeywords do
						if label == angleKeywords[j] then
							value = ScriptHawk.UI.formatRotation(value);
						end
					end

					table.insert(tempTelemetryData, value);
				end
			end
			table.insert(telemetryData, tempTelemetryData);
		end
	end
end

event.onframestart(mainloop, "ScriptHawk - Controller input handler");
event.onframestart(plot_pos, "ScriptHawk - Update position each frame");
event.onloadstate(plot_pos, "ScriptHawk - Update position on load state");

--------------
-- Keybinds --
--------------
-- For full list go here http://slimdx.org/docs/html/T_SlimDX_DirectInput_Key.htm

--ScriptHawk.bindKeyRealtime("Comma", decreasePrecision, true);
--ScriptHawk.bindKeyRealtime("Period", increasePrecision, true);

function ScriptHawk.resetMax()
	max_dx = 0.0;
	max_dy = 0.0;
	max_dz = 0.0;
	max_d = 0.0;
	odometer = 0.0;
	reset_max_pressed = true;
end
ScriptHawk.bindKeyRealtime("Slash", ScriptHawk.resetMax, true);
--ScriptHawk.bindKeyRealtime("M", toggleMode, true);

while true do
	gui.cleartext();
	ScriptHawk.UI.updateReadouts();
	ScriptHawk.processKeybinds(ScriptHawk.keybindsRealtime);
	ScriptHawk.processJoypadBinds(ScriptHawk.joypadBindsRealtime);
	if type(Game.realTime) == "function" then
		Game.realTime();
	end
	emu.yield();
end