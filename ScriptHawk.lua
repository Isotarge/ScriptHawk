ScriptHawk = {};

ScriptHawk.UI = {
	["form_controls"] = {}, -- TODO: Detect UI position problems using this array
	["form_padding"] = 8,
	["label_offset"] = 5,
	["dropdown_offset"] = 1,
	["long_label_width"] = 140,
	["button_height"] = 23,
};

---------------
-- Libraries --
---------------

require "lib.LibScriptHawk";
Stats = require "lib.Stats";
lips = require "lips.init";
require "lib.pngLua.png";

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

	img = pngImage(filename);

	for y = 1, math.min(img.height, height) do
		for x = 1, math.min(img.width, width) do
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

-- Default to N64 binds
ScriptHawk.dpad = {
	joypad = {
		up = "P1 DPad U",
		down = "P1 DPad D",
		left = "P1 DPad L",
		right = "P1 DPad R",
		enabled = true,
	},
	key = {
		up = "W",
		down = "S",
		left = "A",
		right = "D",
		enabled = true,
	},
};

ScriptHawk.lbutton = {
	joypad = "P1 L",
	key = "E",
};

-- PSX Joypad binds
if emu.getsystemid() == "PSX" then
	ScriptHawk.dpad.joypad = {
		up = "P1 Up",
		down = "P1 Down",
		left = "P1 Left",
		right = "P1 Right",
		enabled = false,
	};
	ScriptHawk.lbutton.joypad = "P1 L1";
end

----------------
-- ASM Loader --
----------------

function outputGamesharkCode(bytes, skipZeroes)
	skipZeroes = skipZeroes or false;
	skippedZeroes = 0;
	if type(bytes) == "table" and #bytes > 0 then
		nextByteHandled = false;
		for i = 1, #bytes do
			if not nextByteHandled then
				if i < #bytes and bytes[i][1] == (bytes[i + 1][1] - 1) then
					if not (skipZeroes and bytes[i][2] == 0x00 and bytes[i + 1] == 0x00) then
						dprint(toHexString(bytes[i][1], 6, "81")..toHexString(bytes[i][2], 2, " ")..toHexString(bytes[i + 1][2], 2, ""));
					else
						skippedZeroes = skippedZeroes + 2;
					end
					nextByteHandled = true;
				else
					if not (skipZeroes and bytes[i][2] == 0x00) then
						dprint(toHexString(bytes[i][1], 6, "80")..toHexString(bytes[i][2], 2, " 00"));
					else
						skippedZeroes = skippedZeroes + 1;
					end
				end
			else
				nextByteHandled = false;
			end
		end
	end
	return skippedZeroes;
end

code = {};

function codeWriter(...)
	if isPointer(arg[1]) then
		table.insert(code, {arg[1] - RDRAMBase, arg[2]});
	else
		print("Warning: "..toHexString(arg[1]).." isn't a pointer to RDRAM on the System Bus. Writing outside RDRAM isn't currently supported.");
	end
end

function loadASMPatch(code_filename, suppress_print)
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
	local result = lips(code_filename, codeWriter);

	if #code == 0 then
		if not suppress_print then
			print(result);
			print("The code did not compile correctly, check for errors in your source.");
		end
		return false;
	end

	-- Patch the code
	for i = 1, #code do
		mainmemory.writebyte(code[i][1], code[i][2]);
	end

	-- Hacky, yes, but if we're using dynarec the patched code pages don't get marked as dirty
	-- Quickest and easiest way around this is to save and reload a state
	local ss_fn = 'lips/temp.state';
	savestate.save(ss_fn);
	savestate.load(ss_fn);

	if not suppress_print then
		outputGamesharkCode(code, false);
		dprint("Patched code ("..#code.." bytes)");
		dprint("Done!");
		print_deferred();
	end
	return true;
end

-----------------
-- Game checks --
-----------------

local supportedGames = {
	-- Alex Kidd in Miracle World
	-- TODO: Somehow support self contained modules with while true loops...
	--["6E8E702E1D8A893EE698B93F5807972A"] = {["moduleName"] = "beta.Miracle World", ["selfContained"] = true, ["friendlyName"] = "Alex Kidd in Miracle World (J)"},
	--["3D9A8D5C2D6D3F8FF63A8F7C77FFA983"] = {["moduleName"] = "beta.Miracle World", ["selfContained"] = true, ["friendlyName"] = "Alex Kidd in Miracle World (UE)"},
	--["F43E74FFEC58DDF62F0B8667D31F22C0"] = {["moduleName"] = "beta.Miracle World", ["selfContained"] = true, ["friendlyName"] = "Alex Kidd in Miracle World (UE) (Rev 1)"},

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

	-- Crash Bandicoot 3: Warped
	["05E3012B"] = {["moduleName"] = "games.crash3", ["friendlyName"] = "Crash Bandicoot - Warped (USA)"},
	["9BF37B2C"] = {["moduleName"] = "games.crash3", ["friendlyName"] = "Crash Bandicoot - Warped (USA)"},
	["39B868A1"] = {["moduleName"] = "games.crash3", ["friendlyName"] = "Crash Bandicoot 3 - Warped (Europe) (En,Fr,De,Es,It)"},
	["A91BEA0E"] = {["moduleName"] = "games.crash3", ["friendlyName"] = "Crash Bandicoot 3 - Warped (Europe) (En,Fr,De,Es,It)"},
	["7E59A4CE"] = {["moduleName"] = "games.crash3", ["friendlyName"] = "Crash Bandicoot 3 - Buttobi! Sekai Isshuu (Japan)"},
	["A2E93AEC"] = {["moduleName"] = "games.crash3", ["friendlyName"] = "Crash Bandicoot 3 - Buttobi! Sekai Isshuu (Japan)"},

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

function ScriptHawk.getMovingAngle()
	if dx == 0 and dz == 0 then
		return 0;
	end
	return angleBetweenPoints(prev_x, prev_z, Game.getXPosition(), Game.getZPosition());
end

-------------------------
-- Practice mode stuff --
-------------------------

ScriptHawk.practice = {
	slot = 0,
	minSlot = 0,
	maxSlot = 9, -- Limited to 9 by savestate.loadslot and savestate.saveslot
};

function ScriptHawk.practice.decreaseSlot()
	if mode == "Practice" then
		ScriptHawk.practice.slot = math.max(ScriptHawk.practice.minSlot, ScriptHawk.practice.slot - 1);
		gui.addmessage("Switched to practice slot "..ScriptHawk.practice.slot);
	end
end

function ScriptHawk.practice.increaseSlot()
	if mode == "Practice" then
		ScriptHawk.practice.slot = math.min(ScriptHawk.practice.maxSlot, ScriptHawk.practice.slot + 1);
		gui.addmessage("Switched to practice slot "..ScriptHawk.practice.slot);
	end
end

function ScriptHawk.practice.load()
	if mode == "Practice" then
		savestate.loadslot(ScriptHawk.practice.slot);
	end
end

function ScriptHawk.practice.save()
	if mode == "Practice" then
		savestate.saveslot(ScriptHawk.practice.slot);
	end
end

-- Practice mode JoypadBinds
-- TODO: Move bind and unbind to togglemode?
if ScriptHawk.dpad.joypad.enabled then
	ScriptHawk.bindJoypadRealtime(ScriptHawk.dpad.joypad.left, ScriptHawk.practice.decreaseSlot, true);
	ScriptHawk.bindJoypadRealtime(ScriptHawk.dpad.joypad.right, ScriptHawk.practice.increaseSlot, true);
	ScriptHawk.bindJoypadRealtime(ScriptHawk.dpad.joypad.up, ScriptHawk.practice.save, true);
	ScriptHawk.bindJoypadRealtime(ScriptHawk.dpad.joypad.down, ScriptHawk.practice.load, true);
	ScriptHawk.bindJoypadRealtime(ScriptHawk.lbutton.joypad, ScriptHawk.practice.load, true);
end

if ScriptHawk.dpad.key.enabled then
	ScriptHawk.bindKeyRealtime(ScriptHawk.dpad.key.left, ScriptHawk.practice.decreaseSlot, true);
	ScriptHawk.bindKeyRealtime(ScriptHawk.dpad.key.right, ScriptHawk.practice.increaseSlot, true);
	ScriptHawk.bindKeyRealtime(ScriptHawk.dpad.key.up, ScriptHawk.practice.save, true);
	ScriptHawk.bindKeyRealtime(ScriptHawk.dpad.key.down, ScriptHawk.practice.load, true);
	ScriptHawk.bindKeyRealtime(ScriptHawk.lbutton.key, ScriptHawk.practice.load, true);
end

--------------
-- Rotation --
--------------

function rotation_to_degrees(num)
	return ((num % Game.max_rot_units) / Game.max_rot_units) * 360;
end

two_pi = math.pi * 2;
function rotation_to_radians(num)
	return ((num % Game.max_rot_units) / Game.max_rot_units) * two_pi;
end

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
		return round(rotation_to_degrees(num), precision)..string.char(0xB0);
	elseif rotation_units == "Radians" then
		return round(rotation_to_radians(num), precision);
	end
	return num;
end

local function toggleMode()
	if mode == 'Position' then
		mode = 'Rotation';
	elseif mode == 'Rotation' then
		mode = 'YRotation';
	elseif mode == 'YRotation' then
		mode = 'Practice';
		-- TODO: Bind and unbind the joypadbinds for practice mode here, saves some CPU for the mode checks and we can re-check ScriptHawk.dpad.*.enabled
	elseif mode == 'Practice' then
		mode = 'TAS';
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
-- TODO: Save as CSV file on disk
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
	local filteredMaps = {};
	for i = 1, #Game.maps do
		if string.sub(Game.maps[i],1,1) ~= "!" then
			table.insert(filteredMaps, Game.maps[i]);
		end
	end
	ScriptHawk.UI.form_controls["Map Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, filteredMaps, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(3) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);
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
	"rot x", "rot y", "rot z", "rot",
	"rot. x", "rot. y", "rot. z", "rot.",
	"rotation x", "rotation y", "rotation z", "rotation",
	"facing", "moving", "angle",
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
			local labelLower = string.lower(label);

			-- Detect special keywords
			if labelLower == "dx" then
				value = dx or 0;
			end
			if labelLower == "dy" then
				value = dy or 0;
			end
			if labelLower == "dz" then
				value = dz or 0;
			end
			if labelLower == "dxz" or labelLower == "d" then
				value = d or 0;
			end

			if labelLower == "max dx" then
				value = max_dx or 0;
			end
			if labelLower == "max dy" then
				value = max_dy or 0;
			end
			if labelLower == "max dz" then
				value = max_dz or 0;
			end
			if labelLower == "max dxz" or labelLower == "max d" then
				value = max_d or 0;
			end
			if labelLower == "odometer" then
				value = odometer or 0;
			end

			if labelLower == "moving angle" and value == nil then -- TODO: This has some name conflicts, "moving"
				value = round(ScriptHawk.getMovingAngle())..string.char(0xB0);
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
				if labelLower == angleKeywords[j] then
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

if type(Game.drawUI) ~= "function" then
	--print("Warning: This module does not implement Game.drawUI()");
	function Game.drawUI()
	end
end

if type(Game.eachFrame) ~= "function" then
	--print("Warning: This module does not implement Game.eachFrame()");
	function Game.eachFrame()
	end
end

if type(Game.realTime) ~= "function" then
	--print("Warning: This module does not implement Game.realTime());
	function Game.realTime()
	end
end

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

if type(Game.isPhysicsFrame) ~= "function" then
	--print("Warning: This module does not implement Game.isPhysicsFrame());
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

local lbutton_pressed = false;
local dpad_pressed = {
	up = false,
	down = false,
	left = false,
	right = false
};

local function mainloop()
	if ScriptHawk.UI.form_controls["Toggle Infinites Checkbox"] ~= nil and forms.ischecked(ScriptHawk.UI.form_controls["Toggle Infinites Checkbox"]) then
		Game.applyInfinites();
	end

	if type(Game.maps) == "table" and Game.takeMeThereType == "Checkbox" and forms.ischecked(ScriptHawk.UI.form_controls["Map Checkbox"]) then
		Game.setMap(previous_map_value);
	end

	if Game.isPhysicsFrame() then
		joypad_pressed = joypad.getimmediate();
		input_pressed = input.get();

		-- Check for D-Pad and L button pressed
		lbutton_pressed = joypad_pressed[ScriptHawk.lbutton.joypad] or input_pressed[ScriptHawk.lbutton.key];
		dpad_pressed.up = (ScriptHawk.dpad.joypad.enabled and joypad_pressed[ScriptHawk.dpad.joypad.up]) or (ScriptHawk.dpad.key.enabled and input_pressed[ScriptHawk.dpad.key.up]);
		dpad_pressed.down = (ScriptHawk.dpad.joypad.enabled and joypad_pressed[ScriptHawk.dpad.joypad.down]) or (ScriptHawk.dpad.key.enabled and input_pressed[ScriptHawk.dpad.key.down]);
		dpad_pressed.left = (ScriptHawk.dpad.joypad.enabled and joypad_pressed[ScriptHawk.dpad.joypad.left]) or (ScriptHawk.dpad.key.enabled and input_pressed[ScriptHawk.dpad.key.left]);
		dpad_pressed.right = (ScriptHawk.dpad.joypad.enabled and joypad_pressed[ScriptHawk.dpad.joypad.right]) or (ScriptHawk.dpad.key.enabled and input_pressed[ScriptHawk.dpad.key.right]);

		-- Speed things up by returning early if no inputs are pressed
		if not (lbutton_pressed or dpad_pressed.up or dpad_pressed.down or dpad_pressed.left or dpad_pressed.right) then
			return;
		end

		-- Calculate speed for D-Pad and L button
		local speedy_speed_XZ = Game.speedy_speeds[Game.speedy_index];
		local speedy_speed_Y = Game.speedy_speeds[Game.speedy_index];
		if Game.speedy_invert_XZ then
			speedy_speed_XZ = speedy_speed_XZ * -1;
		end
		if Game.speedy_invert_Y then
			speedy_speed_Y = speedy_speed_Y * -1;
		end

		local dpad_up_multiplier = 1.0;
		local dpad_down_multiplier = -1.0;
		if Game.speedy_invert_UD then
			dpad_up_multiplier = -1.0;
			dpad_down_multiplier = 1.0;
		end

		local dpad_left_multiplier = 1.0;
		local dpad_right_multiplier = -1.0;
		if Game.speedy_invert_LR then
			dpad_left_multiplier = -1.0;
			dpad_right_multiplier = 1.0;
		end

		if mode == 'Position' then
			local rot_rad = rotation_to_radians(Game.getYRotation());
			if dpad_pressed.up then
				gofast("x", dpad_up_multiplier * (speedy_speed_XZ * math.sin(rot_rad)));
				gofast("z", dpad_up_multiplier * (speedy_speed_XZ * math.cos(rot_rad)));
			end
			if dpad_pressed.down then
				gofast("x", dpad_down_multiplier * (speedy_speed_XZ * math.sin(rot_rad)));
				gofast("z", dpad_down_multiplier * (speedy_speed_XZ * math.cos(rot_rad)));
			end
			if dpad_pressed.left then
				gofast("x", dpad_left_multiplier * (speedy_speed_XZ * math.cos(rot_rad)));
				gofast("z", dpad_right_multiplier * (speedy_speed_XZ * math.sin(rot_rad)));
			end
			if dpad_pressed.right then
				gofast("x", dpad_right_multiplier * (speedy_speed_XZ * math.cos(rot_rad)));
				gofast("z", dpad_left_multiplier * (speedy_speed_XZ * math.sin(rot_rad)));
			end
			if lbutton_pressed then
				gofast("y", speedy_speed_Y);
			end
		elseif mode == 'Rotation' then
			if dpad_pressed.up then
				rotate("x", Game.rot_speed);
			end
			if dpad_pressed.down then
				rotate("x", -Game.rot_speed);
			end
			if dpad_pressed.left then
				rotate("z", -Game.rot_speed);
			end
			if dpad_pressed.right then
				rotate("z", Game.rot_speed);
			end
			if lbutton_pressed then
				gofast("y", speedy_speed_Y);
			end
		elseif mode == 'YRotation' then
			local rot_rad = rotation_to_radians(Game.getYRotation());
			if dpad_pressed.up then
				gofast("x", dpad_up_multiplier * (speedy_speed_XZ * math.sin(rot_rad)));
				gofast("z", dpad_up_multiplier * (speedy_speed_XZ * math.cos(rot_rad)));
			end
			if dpad_pressed.down then
				gofast("x", dpad_down_multiplier * (speedy_speed_XZ * math.sin(rot_rad)));
				gofast("z", dpad_down_multiplier * (speedy_speed_XZ * math.cos(rot_rad)));
			end
			if dpad_pressed.left then
				rotate("y", -Game.rot_speed);
			end
			if dpad_pressed.right then
				rotate("y", Game.rot_speed);
			end
			if lbutton_pressed then
				gofast("y", speedy_speed_Y);
			end
		end
	end
end

local function plot_pos()
	ScriptHawk.processKeybinds(ScriptHawk.keybindsFrame);
	ScriptHawk.processKeybinds(ScriptHawk.joypadBindsFrame);
	Game.eachFrame();

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
					local labelLower = string.lower(label);

					-- Detect special keywords
					if labelLower == "dx" then
						value = dx or 0;
					end
					if labelLower == "dy" then
						value = dy or 0;
					end
					if labelLower == "dz" then
						value = dz or 0;
					end
					if labelLower == "dxz" or labelLower == "d" then
						value = d or 0;
					end

					if labelLower == "max dx" then
						value = max_dx or 0;
					end
					if labelLower == "max dy" then
						value = max_dy or 0;
					end
					if labelLower == "max dz" then
						value = max_dz or 0;
					end
					if labelLower == "max dxz" or labelLower == "max d" then
						value = max_d or 0;
					end
					if labelLower == "odometer" then
						value = odometer or 0;
					end

					if labelLower == "moving angle" and value == nil then -- TODO: This has some name conflicts, "moving"
						value = round(ScriptHawk.getMovingAngle())..string.char(0xB0);
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

	if not client.ispaused() then
		--gui.cleartext();
		--gui.clearGraphics();
		ScriptHawk.UI.updateReadouts();
		Game.drawUI();
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

----------------------------------------
-- Angle Calculator                   --
-- Originally written by The8bitbeast --
-- Ported to ScriptHawk by Isotarge   --
----------------------------------------

angleCalc = {
	["buttonX"] = 220,
	["visible"] = false,
	["form"] = nil,
	["p1xbox"] = nil,
	["p1zbox"] = nil,
	["p2xbox"] = nil,
	["p2zbox"] = nil,
	["anglebox"] = nil,
};

angleCalc.setPoint1 = function()
	forms.settext(angleCalc.p1xbox, Game.getXPosition())
	forms.settext(angleCalc.p1zbox, Game.getZPosition())
	forms.settext(angleCalc.anglebox, "");
end

angleCalc.setPoint2 = function()
	forms.settext(angleCalc.p2xbox, Game.getXPosition());
	forms.settext(angleCalc.p2zbox, Game.getZPosition());
	forms.settext(angleCalc.anglebox, "");
end

angleCalc.calculateAngle = function()
	local p1x = forms.gettext(angleCalc.p1xbox);
	local p1z = forms.gettext(angleCalc.p1zbox);
	local p2x = forms.gettext(angleCalc.p2xbox);
	local p2z = forms.gettext(angleCalc.p2zbox);

	local angle = angleBetweenPoints(p1x, p1z, p2x, p2z);

	forms.settext(angleCalc.anglebox, angle);

	dprint('Point 1: '..round(p1x, 4)..", "..round(p1z, 4));
	dprint('Point 2: '..round(p2x, 4)..", "..round(p2z, 4));
	dprint('Angle: '..angle);
	dprint("");
	print_deferred();
end

angleCalc.clearAll = function()
	forms.settext(angleCalc.p1xbox, "");
	forms.settext(angleCalc.p1zbox, "");
	forms.settext(angleCalc.p2xbox, "");
	forms.settext(angleCalc.p2zbox, "");
	forms.settext(angleCalc.anglebox, "");
end

angleCalc.close = function()
	angleCalc.visible = false;
end

angleCalc.open = function()
	if not angleCalc.visible then
		angleCalc.visible = true;
		angleCalc.form = forms.newform(390, 190, "Angle Calculator", angleCalc.close);

		-- Buttons
		forms.button(angleCalc.form, "Use Current Coordinates", angleCalc.setPoint1, angleCalc.buttonX, 40, 150, 32);
		forms.button(angleCalc.form, "Use Current Coordinates", angleCalc.setPoint2, angleCalc.buttonX, 74, 150, 32);
		forms.button(angleCalc.form, "Calculate Angle", angleCalc.calculateAngle, angleCalc.buttonX, 108, 90, 32);
		forms.button(angleCalc.form, "Clear All", angleCalc.clearAll, angleCalc.buttonX + 95, 108, 55, 32);
		forms.label(angleCalc.form, "Calculates the angle of the straight line betwen 2 points", 0, 0, 500, 15);

		-- Labels
		forms.label(angleCalc.form, "Point 1:", 0, 50, 50, 15);
		forms.label(angleCalc.form, "Point 2:", 0, 84, 50, 15);
		forms.label(angleCalc.form, "Angle:", 0, 118, 50, 15);
		forms.label(angleCalc.form, "x", 85, 20, 20, 15);
		forms.label(angleCalc.form, "z", 170, 20, 20, 15);

		-- Textboxes
		angleCalc.p1xbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 50, 45);
		angleCalc.p1zbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 135, 45);
		angleCalc.p2xbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 50, 79);
		angleCalc.p2zbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 135, 79);
		angleCalc.anglebox = forms.textbox(angleCalc.form, "", 70, 20, 1, 50, 113);
	else
		--print("Please close the angle calculator before opening another one.");
	end
end

while true do
	if client.ispaused() then
		gui.cleartext();
		gui.clearGraphics();
		ScriptHawk.UI.updateReadouts();
		Game.drawUI();
	end
	ScriptHawk.processKeybinds(ScriptHawk.keybindsRealtime);
	ScriptHawk.processJoypadBinds(ScriptHawk.joypadBindsRealtime);
	Game.realTime();
	emu.yield();
end