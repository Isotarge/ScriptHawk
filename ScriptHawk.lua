-------------------
-- Version Check --
-------------------

if emu.setislagged == nil then -- 1.11.5 (Feb 2016)
	print("This version of BizHawk is not supported by ScriptHawk");
	print("Please upgrade to a newer version of BizHawk");
	print("http://tasvideos.org/Bizhawk.html");
	return false;
end

if emu.getluacore == nil then -- 2.2.2 (March 2018)
	function emu.getluacore()
		return "NLua";
	end
end

ScriptHawk = {
	warnings = false, -- Useful for debugging but annoying for end users, so default to false
	ui_test = false, -- Open all possible module options forms, useful for testing global UI changes
	force_module = {
		enabled = false,
		name = "games.lots", -- The name of the module to load for all opened ROMs
		version = 1, -- The Game.version value to force
		selfContained = false, -- Whether the forced module is self contained
	},
	mode = "Position",
	update_delta_on_lag = false,
	smooth_moving_angle = true,
	UI = {
		form_controls = {},
		form_padding = 8,
		form_width = 17,
		form_height = 10,
		label_offset = 5,
		dropdown_offset = 1,
		long_label_width = 140,
		button_height = 23,
	},
	modifyOSDUI = {
		isOpen = false,
		form_controls = {},
		form_padding = 8,
		form_width = 10,
		form_height = 10,
		label_offset = 5,
		dropdown_offset = 1,
		long_label_width = 140,
		button_height = 23,
	},
	hitboxModeWH = 0,
	hitboxModeWHCentered = 1,
	hitboxModeX2Y2 = 2,
	hitboxDefaultColor = 0xFFFFFFFF, -- White
	hitboxDefaultBGColor = 0x33000000, -- Translucent black
	hitboxListPosition = {
		x = 2,
		y = 2,
	},
	hitboxListAnchor = "bottomright",
	hitboxListShowCount = false,
	overscan_compensation = {
		x = 0,
		y = 0,
	},
	isSMS = emu.getsystemid() == "SMS",
	isNES = emu.getsystemid() == "NES",
	bufferWidth = client.bufferwidth(),
	bufferHeight = client.bufferheight(),
	isFileIOSafe = emu.getluacore() == "LuaInterface",
};

ScriptHawk.hitboxDefaultMode = ScriptHawk.hitboxModeWH;
ScriptHawk.hitboxDefaultShowList = true;
ScriptHawk.hitboxDefaultShowHitboxes = true;

function ScriptHawk.biz222Notice()
	print("Due to a bug between BizHawk release 1.13.0 and 2.2.1");
	print("The save & clear preferenes function cannot run on any");
	print("pre-2.2.2 release of BizHawk. Sorry");
	print("--------");
end

function ScriptHawk.UI.controlsOverlap(control1, control2)
	local x1 = tonumber(forms.getproperty(control1, "Left"));
	local y1 = tonumber(forms.getproperty(control1, "Top"));
	local w1 = tonumber(forms.getproperty(control1, "Width"));
	local h1 = tonumber(forms.getproperty(control1, "Height"));

	local x2 = tonumber(forms.getproperty(control2, "Left"));
	local y2 = tonumber(forms.getproperty(control2, "Top"));
	local w2 = tonumber(forms.getproperty(control2, "Width"));
	local h2 = tonumber(forms.getproperty(control2, "Height"));

	--gui.drawRectangle(x1, y1, w1, h1);
	--gui.drawRectangle(x2, y2, w2, h2);

	return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1;
end

function ScriptHawk.UI.checkControls()
	for k, v in pairs(ScriptHawk.UI.form_controls) do
		--local x = forms.getproperty(v, "Left");
		--local y = forms.getproperty(v, "Top");
		--local w = forms.getproperty(v, "Width")
		--local h = forms.getproperty(v, "Height");
		--dprint(k.." ("..v.."): Position: "..x..", "..y.." Size: "..w..", "..h);
		for l, u in pairs(ScriptHawk.UI.form_controls) do
			if v ~= u and ScriptHawk.UI.controlsOverlap(v, u) then
				dprint('Warning: Controls "'..k..'" and "'..l..'" may be overlapping!');
			end
		end
	end
	print_deferred();
end

---------------
-- Libraries --
---------------

require "lib.pngLua.png";
require "lib.LibScriptHawk";
Stats = require "lib.Stats";
lips = require "lips.init";

-----------------------
-- Keybind framework --
-----------------------

local mouse_state = {
	previous = {},
	current = {},
};
local input_pressed = {};
local joypad_pressed = {};
local lbutton_pressed = false;
local dpad_pressed = {
	up = false,
	down = false,
	left = false,
	right = false,
};

ScriptHawk.keybindsFrame = {};
ScriptHawk.keybindsRealtime = {};

ScriptHawk.joypadBindsFrame = {};
ScriptHawk.joypadBindsRealtime = {};

ScriptHawk.mouseBinds = {};

function ScriptHawk.bind(keybindArray, key, callback, preventHold)
	if type(keybindArray) == "table" and type(key) == "string" and type(callback) == "function" then
		if type(preventHold) ~= 'boolean' then
			preventHold = true;
		end
		table.insert(keybindArray, {key = key, callback = callback, pressed = false, preventHold = preventHold});
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

function ScriptHawk.bindMouse(key, callback)
	ScriptHawk.bind(ScriptHawk.mouseBinds, key, callback);
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

function ScriptHawk.processMouseBinds(mouseBinds)
	mouse_state.current = input.getmouse();
	if type(mouse_state.current.Wheel) == "number" and type(mouse_state.previous.Wheel) == "number" then
		if mouse_state.current.Wheel > mouse_state.previous.Wheel then
			mouse_state.current.mousewheelup = true;
			mouse_state.current.mousewheeldown = false;
		elseif mouse_state.current.Wheel < mouse_state.previous.Wheel then
			mouse_state.current.mousewheelup = false;
			mouse_state.current.mousewheeldown = true;
		end
	else
		mouse_state.current.mousewheelup = false;
		mouse_state.current.mousewheeldown = false;
	end
	for i = 1, #mouseBinds do
		if mouse_state.current[mouseBinds[i].key] then
			mouseBinds[i].callback();
		end
	end
	mouse_state.previous = mouse_state.current;
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
	local skippedZeroes = 0;
	if type(bytes) == "table" and #bytes > 0 then
		local nextByteHandled = false;
		for i = 1, #bytes do
			if not nextByteHandled then
				if i < #bytes and bytes[i][1] == (bytes[i + 1][1] - 1) then
					if not (skipZeroes and bytes[i][2] == 0x00 and bytes[i + 1] == 0x00) then
						dprint(toHexString(bytes[i][1], 6, "  - 81")..toHexString(bytes[i][2], 2, " ")..toHexString(bytes[i + 1][2], 2, ""));
					else
						skippedZeroes = skippedZeroes + 2;
					end
					nextByteHandled = true;
				else
					if not (skipZeroes and bytes[i][2] == 0x00) then
						dprint(toHexString(bytes[i][1], 6, "  - 80")..toHexString(bytes[i][2], 2, " 00"));
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

local code = {};

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
	["6E8E702E1D8A893EE698B93F5807972A"] = {moduleName="games.miracle_world", friendlyName="Alex Kidd in Miracle World (J)"},
	["3D9A8D5C2D6D3F8FF63A8F7C77FFA983"] = {moduleName="games.miracle_world", friendlyName="Alex Kidd in Miracle World (UE)"},
	["F43E74FFEC58DDF62F0B8667D31F22C0"] = {moduleName="games.miracle_world", friendlyName="Alex Kidd in Miracle World (UE) (Rev 1)"},

	-- Alex Kidd in Shinobi World
	["D62B631506913712A2103F54912458A5"] = {moduleName="games.shinobi_world", friendlyName="Alex Kidd in Shinobi World (UE)"},

	-- Balloon Fight
	["3F597CE54843187CCA85ADAA7E26F46FAE4992B5"] = {moduleName="games.balloon_fight", friendlyName="Balloon Fight"},
	["BE2C30D69B1EBA76EAF1CC259DFA41F0F29B0FB2"] = {moduleName="games.balloon_fight", friendlyName="Balloon Fight"},
	["F7E96381736E679C1E996283C2BE718025A02C0D"] = {moduleName="games.balloon_fight", friendlyName="Balloon Fight (PC10)"},

	-- Banjo-Kazooie
	["90726D7E7CD5BF6CDFD38F45C9ACBF4D45BD9FD8"] = {moduleName="games.bk", friendlyName="Banjo to Kazooie no Daibouken (Japan)", version=2},
	["BB359A75941DF74BF7290212C89FBC6E2C5601FE"] = {moduleName="games.bk", friendlyName="Banjo-Kazooie (Europe) (En,Fr,De)", version=1},
	["DED6EE166E740AD1BC810FD678A84B48E245AB80"] = {moduleName="games.bk", friendlyName="Banjo-Kazooie (USA) (Rev A)", version=3},
	["1FE1632098865F639E22C11B9A81EE8F29C75D7A"] = {moduleName="games.bk", friendlyName="Banjo-Kazooie (USA)", version=4},

	-- Banjo-Tooie
	["5A5172383037D171F121790959962703BE1F373C"] = {moduleName="games.bt", friendlyName="Banjo to Kazooie no Daibouken 2 (Japan)", version=3},
	["4CA2D332F6E6B018777AFC6A8B7880B38B6DFB79"] = {moduleName="games.bt", friendlyName="Banjo-Tooie (Australia)", version=1},
	["93BF2FAC1387320AD07251CB4B64FD36BAC1D7A6"] = {moduleName="games.bt", friendlyName="Banjo-Tooie (Europe) (En,Fr,De,Es)", version=2},
	["AF1A89E12B638B8D82CC4C085C8E01D4CBA03FB3"] = {moduleName="games.bt", friendlyName="Banjo-Tooie (USA)", version=4},

	-- Brother Bear (GBA)
	["89E6903500F62E11483402B76C1454AF788646C0"] = {moduleName="games.GBA_brother_bear", friendlyName="Brother Bear (USA)", version=1},

	-- Conker's Bad Fur Day
	["EE7BC6656FD1E1D9FFB3D19ADD759F28B88DF710"] = {moduleName="games.cbfd", friendlyName="Conker's Bad Fur Day (Europe)", version=1},
	["4CBADD3C4E0729DEC46AF64AD018050EADA4F47A"] = {moduleName="games.cbfd", friendlyName="Conker's Bad Fur Day (USA)", version=2},

	-- Crash Bandicoot
	["41B5F211"] = {moduleName="games.crash1", friendlyName="Crash Bandicoot (USA)", version=1},
	["249FC147"] = {moduleName="games.crash1", friendlyName="Crash Bandicoot (USA)", version=1},
	["D6172125"] = {moduleName="games.crash1", friendlyName="Crash Bandicoot (Europe) (EDC)", version=2},
	["2033243A"] = {moduleName="games.crash1", friendlyName="Crash Bandicoot (Europe) (EDC)", version=2},
	["FD11EB1E"] = {moduleName="games.crash1", friendlyName="Crash Bandicoot (Europe) (No EDC)", version=2},
	["0B9EB02B"] = {moduleName="games.crash1", friendlyName="Crash Bandicoot (Europe) (No EDC)", version=2},
	["D9BA797E"] = {moduleName="games.crash1", friendlyName="Crash Bandicoot (Japan)", version=3},
	["F5B95131"] = {moduleName="games.crash1", friendlyName="Crash Bandicoot (Japan)", version=3},

	-- Crash Bandicoot 2: Cortex Strikes Back
	["149A203B"] = {moduleName="games.crash2", friendlyName="Crash Bandicoot 2 - Cortex Strikes Back (USA)", version=1},
	["395C0916"] = {moduleName="games.crash2", friendlyName="Crash Bandicoot 2 - Cortex Strikes Back (USA)", version=1},
	["5F65CF0F"] = {moduleName="games.crash2", friendlyName="Crash Bandicoot 2 - Cortex Strikes Back (Europe) (En,Fr,De,Es,It) (No EDC)", version=2},
	["F5E2EC49"] = {moduleName="games.crash2", friendlyName="Crash Bandicoot 2 - Cortex Strikes Back (Europe) (En,Fr,De,Es,It) (No EDC)", version=2},
	["97395614"] = {moduleName="games.crash2", friendlyName="Crash Bandicoot 2 - Cortex Strikes Back (Europe) (En,Fr,De,Es,It) (EDC)", version=2},
	["74C85B1E"] = {moduleName="games.crash2", friendlyName="Crash Bandicoot 2 - Cortex Strikes Back (Europe) (En,Fr,De,Es,It) (EDC)", version=2},
	["B0A92BAF"] = {moduleName="games.crash2", friendlyName="Crash Bandicoot 2 - Cortex no Gyakushuu! (Japan)", version=3},
	["14591AE9"] = {moduleName="games.crash2", friendlyName="Crash Bandicoot 2 - Cortex no Gyakushuu! (Japan)", version=3},

	-- Crash Bandicoot 3: Warped
	["05E3012B"] = {moduleName="games.crash3", friendlyName="Crash Bandicoot - Warped (USA)", version=1},
	["9BF37B2C"] = {moduleName="games.crash3", friendlyName="Crash Bandicoot - Warped (USA)", version=1},
	["39B868A1"] = {moduleName="games.crash3", friendlyName="Crash Bandicoot 3 - Warped (Europe) (En,Fr,De,Es,It)", version=2},
	["A91BEA0E"] = {moduleName="games.crash3", friendlyName="Crash Bandicoot 3 - Warped (Europe) (En,Fr,De,Es,It)", version=2},
	["7E59A4CE"] = {moduleName="games.crash3", friendlyName="Crash Bandicoot 3 - Buttobi! Sekai Isshuu (Japan)", version=3},
	["A2E93AEC"] = {moduleName="games.crash3", friendlyName="Crash Bandicoot 3 - Buttobi! Sekai Isshuu (Japan)", version=3},

	-- Day Dreamin' Davey
	["4C88391318E3BD79C14BFF6724A377688E47261B"] = {moduleName="games.day_dreamin_davey", friendlyName="Day Dreamin' Davey"},

	-- Diddy Kong Racing
	["B7F628073237B3D211D40406AA0884FF8FDD70D5"] = {moduleName="games.dkr", friendlyName="Diddy Kong Racing (Europe) (En,Fr,De) (Rev A)", version=1},
	["DD5D64DD140CB7AA28404FA35ABDCABA33C29260"] = {moduleName="games.dkr", friendlyName="Diddy Kong Racing (Europe) (En,Fr,De)", version=2},
	["23BA3D302025153D111416E751027CEF11213A19"] = {moduleName="games.dkr", friendlyName="Diddy Kong Racing (Japan)", version=3},
	["6D96743D46F8C0CD0EDB0EC5600B003C89B93755"] = {moduleName="games.dkr", friendlyName="Diddy Kong Racing (USA) (En,Fr) (Rev A)", version=4},
	["0CB115D8716DBBC2922FDA38E533B9FE63BB9670"] = {moduleName="games.dkr", friendlyName="Diddy Kong Racing (USA) (En,Fr)", version=5},

	-- Donald Land
	["C5BBA353871E438C387FD13891580A2A139694AD"] = {moduleName="games.donald_land", friendlyName="Donald Land"},

	-- Donkey Kong 64
	["F96AF883845308106600D84E0618C1A066DC6676"] = {moduleName="games.dk64", friendlyName="Donkey Kong 64 (Europe) (En,Fr,De,Es)", version=2},
	["F0AD2B2BBF04D574ED7AFBB1BB6A4F0511DCD87D"] = {moduleName="games.dk64", friendlyName="Donkey Kong 64 (Japan)", version=3},
	["B4717E602F07CA9BE0D4822813C658CD8B99F993"] = {moduleName="games.dk64", friendlyName="Donkey Kong 64 (USA) (Demo) (Kiosk)", version=4},
	["CF806FF2603640A748FCA5026DED28802F1F4A50"] = {moduleName="games.dk64", friendlyName="Donkey Kong 64 (USA)", version=1},

	-- Donkey Kong Country 2 (GBA)
	["B0A4D59447C8D7C321BEA4DC7253B0F581129EDE"] = {moduleName="games.GBA_dkc2", friendlyName="Donkey Kong Country 2 (USA)", version=1},

	-- Drill Dozer
	["C1058CC2482B91204100CC8515DA99AEB06773F5"] = {moduleName="games.GBA_DrillDozer", friendlyName="Drill Dozer (USA)", version=1},
	["84AFA7108E4D604E7B1A6D105DF5760869A247FA"] = {moduleName="games.GBA_DrillDozer", friendlyName="Screw Breaker Goushin Dorirurero (Japan)", version=2},

	-- Duck Dodgers
	["2C840E2991D6A2AF63C4EFE830240FC49D93FC9A"] = {moduleName="games.duck_dodgers", friendlyName="Duck Dodgers Starring Daffy Duck (USA) (En,Fr,Es)"},

	-- Earthworm Jim 3D
	["EAB14F23640CD6148D4888902CDCC00DD6111BF9"] = {moduleName="games.ej3d", friendlyName="Earthworm Jim 3D (USA)", version=1},
	["F02C1AFD18C1CBE309472CBE5B3B3F04B22DB7EE"] = {moduleName="games.ej3d", friendlyName="Earthworm Jim 3D (Europe) (En,Fr,De,Es,It)", version=2},

	-- Elmo
	["97777CA06F4E8AFF8F1E95033CC8D3833BE40F76"] = {moduleName="games.elmo", friendlyName="Elmo's Letter Adventure (USA)", verison=2},
	["7195EA96D9FE5DE065AF61F70D55C92C8EE905E6"] = {moduleName="games.elmo", friendlyName="Elmo's Number Journey (USA)", verison=1},

	-- Galahad
	["536E5A1FFB50D33632A9978B35DB5DF6"] = {moduleName="games.galahad", friendlyName="Legend of Galahad, The (UE) [!]"},
	["FA7A34B92D06013625C2FE155A9DB5A8"] = {moduleName="games.galahad", friendlyName="Legend of Galahad, The (UE) [t1+C]"},
	["3F183BD8A7360E3BE3CF65AE8FF9810C"] = {moduleName="games.galahad", friendlyName="Legend of Galahad, The (UE) [t1]"},

	-- Golden Axe Warrior
	["D46E40BBB729BA233F171AD7BF6169F5"] = {moduleName="games.golden_axe_warrior", friendlyName="Golden Axe Warrior (UE)"},

	-- Golvellius
	["2101295C258CB6B845BDB72BE617691D"] = {moduleName="games.golvellius", friendlyName="Golvellius (UE)"},
	["6BD9879AF39E248D149761014EBF5639"] = {moduleName="games.golvellius", friendlyName="Golvellius (J)"},

	-- Gran Turismo 2
	["D2C9B4EE"] = {moduleName="games.gran_turismo_2", friendlyName="Gran Turismo 2 (USA 1.0)", version=1},
	["B5A363A3"] = {moduleName="games.gran_turismo_2", friendlyName="Gran Turismo 2 (USA 1.1)", version=2},
	["E3672E95"] = {moduleName="games.gran_turismo_2", friendlyName="Gran Turismo 2 (USA 1.2)", version=3},
	["20FB91D3"] = {moduleName="games.gran_turismo_2", friendlyName="Gran Turismo 2 (Japan 1.0)", version=4},
	["7E74A4F0"] = {moduleName="games.gran_turismo_2", friendlyName="Gran Turismo 2 (Japan 1.1)", version=5},
	["AFCCF4DC"] = {moduleName="games.gran_turismo_2", friendlyName="Gran Turismo 2 (Europe)", version=6},

	-- Impossible Mission
	["AF51AB03A173DEC28C9241532227CD64"] = {moduleName="games.impossible_mission", friendlyName="Impossible Mission (E)"},
	["A26D40B6B7646C22D1F2DB7F746F0391"] = {moduleName="games.impossible_mission", friendlyName="Impossible Mission (E) (Beta)"},

	--Klonoa: Empire of Dreams
	["A0A298D9DBA1BA15D04A42FC2EB35893D1A9569B"] = {moduleName="games.GBA_klonoa", friendlyName="Klonoa - Empire of Dreams (USA)"},
	
	-- Land of Illusion
	["07FAC1D61BC20CF6EB298F66EC2FFE49"] = {moduleName="games.land_of_illusion", friendlyName="Land of Illusion Starring Mickey Mouse (E)"},

	-- Lord of the Sword
	["6A08D913FD92A213B1ECF5AA7C5630362CCCC6B4"] = {moduleName="games.lots", friendlyName="Lord of the Sword (J)"},
	["A5736126ED7E8569A189065EC20ADF72"] = {moduleName="games.lots", friendlyName="Lord of the Sword (J)"},
	["A5326A0029F7C3101ADD3335A599A01CCD7634C5"] = {moduleName="games.lots", friendlyName="Lord of the Sword (UE)"},
	["B80F87887881343E5705FF3CCE93C5F1"] = {moduleName="games.lots", friendlyName="Lord of the Sword (UE)"},

	-- Majora's Mask
	["B38B71D2961DFFB523020A67F4807A4B704E347A"] = {moduleName="games.mm", friendlyName="Legend of Zelda, The - Majora's Mask (Europe) (En,Fr,De,Es) (Beta)"},
	["BB4E4757D10727C7584C59C1F2E5F44196E9C293"] = {moduleName="games.mm", friendlyName="Legend of Zelda, The - Majora's Mask (Europe) (En,Fr,De,Es) (Rev A)"},
	["C04599CDAFEE1C84A7AF9A71DF68F139179ADA84"] = {moduleName="games.mm", friendlyName="Legend of Zelda, The - Majora's Mask (Europe) (En,Fr,De,Es)"},
	["2F0744F2422B0421697A74B305CB1EF27041AB11"] = {moduleName="games.mm", friendlyName="Legend of Zelda, The - Majora's Mask (USA) (Demo)"},
	["D6133ACE5AFAA0882CF214CF88DABA39E266C078"] = {moduleName="games.mm", friendlyName="Legend of Zelda, The - Majora's Mask (USA)"},
	["41FDB879AB422EC158B4EAFEA69087F255EA8589"] = {moduleName="games.mm", friendlyName="Zelda no Densetsu - Mujura no Kamen (Japan) (Rev A)"},
	["5FB2301AACBF85278AF30DCA3E4194AD48599E36"] = {moduleName="games.mm", friendlyName="Zelda no Densetsu - Mujura no Kamen (Japan)"},

	-- Mercs
	["7D5696C3DA0DBED04B35543F7BDBEF40"] = {moduleName="games.mercs_sms", friendlyName="Mercs (E)"},

	-- Metroid
	["166A5B1344B17F98B6B18794094F745F8A7435B8"] = {moduleName="games.metroid", friendlyName="Metroid (U)"},
	["FDBFC7871962F72A1EF57E5A7E456164FB93430B"] = {moduleName="games.metroid", friendlyName="Metroid (U)"},
	["B2D2D9ED68B3E5E0D29053EA525BD37C"] = {moduleName="games.metroid", friendlyName="Metroid (U)"},

	-- Mr. Driller
	["E7009DD8418303343C4AAC2558538B8CAA28B694"] = {moduleName="beta.Drillbot", selfContained=true, friendlyName="Mr. Driller 2 (USA)"},

	-- Ocarina of Time
	["CFBB98D392E4A9D39DA8285D10CBEF3974C2F012"] = {moduleName="games.oot", friendlyName="Legend of Zelda, The - Ocarina of Time (Europe) (En,Fr,De) (Rev A)"},
	["328A1F1BEBA30CE5E178F031662019EB32C5F3B5"] = {moduleName="games.oot", friendlyName="Legend of Zelda, The - Ocarina of Time (Europe) (En,Fr,De)"},
	["D3ECB253776CD847A5AA63D859D8C89A2F37B364"] = {moduleName="games.oot", friendlyName="Legend of Zelda, The - Ocarina of Time (USA) (Rev A)"},
	["41B3BDC48D98C48529219919015A1AF22F5057C2"] = {moduleName="games.oot", friendlyName="Legend of Zelda, The - Ocarina of Time (USA) (Rev B)"},
	["AD69C91157F6705E8AB06C79FE08AAD47BB57BA7"] = {moduleName="games.oot", friendlyName="Legend of Zelda, The - Ocarina of Time (USA)"},
	["50BEBEDAD9E0F10746A52B07239E47FA6C284D03"] = {moduleName="games.oot", friendlyName="Legend of Zelda, The - Ocarina of Time - Master Quest (USA) (Debug Edition)"},
	["8B5D13AAC69BFBF989861CFDC50B1D840945FC1D"] = {moduleName="games.oot", friendlyName="Legend of Zelda, The - Ocarina of Time - Master Quest (USA) (GC)"},
	["DBFC81F655187DC6FEFD93FA6798FACE770D579D"] = {moduleName="games.oot", friendlyName="Zelda no Densetsu - Toki no Ocarina (Japan) (Rev A)"},
	["FA5F5942B27480D60243C2D52C0E93E26B9E6B86"] = {moduleName="games.oot", friendlyName="Zelda no Densetsu - Toki no Ocarina (Japan) (Rev B)"},
	["C892BBDA3993E66BD0D56A10ECD30B1EE612210F"] = {moduleName="games.oot", friendlyName="Zelda no Densetsu - Toki no Ocarina (Japan)"},
	["DD14E143C4275861FE93EA79D0C02E36AE8C6C2F"] = {moduleName="games.oot", friendlyName="Zelda no Densetsu - Toki no Ocarina (Japan) (GC)"},

	-- Penguin Land
	["8762239C339A084DFB8443CC38515301476BDE28"] = {moduleName="games.penguin_land", friendlyName="Penguin Land (UE)"},
	["8DDEC589F72CDCF2CD4CAAFB075EC8E4"] = {moduleName="games.penguin_land", friendlyName="Penguin Land (UE)"},
	["C01CF44EEE335D509DC20A165ADD8514E7FBB7C4"] = {moduleName="games.penguin_land", friendlyName="Doki Doki Penguin Land - Uchuu Daibouken (J)"},
	["FF7502DD8A717DB5ADB42C711DDBC9F5"] = {moduleName="games.penguin_land", friendlyName="Doki Doki Penguin Land - Uchuu Daibouken (J)"},

	-- Phantasy Star (SMS)
	["DFEBC48DFE8165202B7F002D8BAC477B"] = {moduleName="games.phantasy_star_1", friendlyName="Phantasy Star (J)"},
	["14C59604768B33175362CC592CB75EAD"] = {moduleName="games.phantasy_star_1", friendlyName="Phantasy Star (J)"}, -- From Saturn Collection CD
	["1B69716F9F4053E1533F654C091AE410"] = {moduleName="games.phantasy_star_1", friendlyName="Phantasy Star (B)"},
	["F853B7DDCA63864735C03001C9AC477B"] = {moduleName="games.phantasy_star_1", friendlyName="Phantasy Star (K)"},
	["5BA9114EDEA5DEB5282FD9AD7D4B2D62"] = {moduleName="games.phantasy_star_1", friendlyName="Phantasy Star (UE) (Rev 2)"},
	["1110938DF80F4E44C8213D7F85CFB5E6"] = {moduleName="games.phantasy_star_1", friendlyName="Phantasy Star (UE) (Rev 3)"},

	-- Psycho Fox
	["278CC3853905626138E83B6CFA39C26BA8E4F632"] = {moduleName="games.psycho_fox", friendlyName="Psycho Fox (UE)"},
	["A9C2FACF9EF536D095414CE2E7CE2F4F"] = {moduleName="games.psycho_fox", friendlyName="Psycho Fox (UE)"},

	-- Rats!
	["5E423DFAB8221B69A641D2E535EBFE1E3759A2E4"] = {moduleName="games.rats", friendlyName="Rats! (USA) (En,Es)"},

	-- Rayman 2
	["619AB27EA1645399439AD324566361D3E7FF020E"] = {moduleName="games.rayman_2", friendlyName="Rayman 2 - The Great Escape (Europe) (En,Fr,De,Es,It)", version=1},
	["50558356B059AD3FBAF5FE95380512B9DCEAAF52"] = {moduleName="games.rayman_2", friendlyName="Rayman 2 - The Great Escape (USA) (En,Fr,De,Es,It)", version=2},

	-- San Francisco Rush 2049
	["3F99351D7BB61656614BDB2AA1A90CFE55D1922C"] = {moduleName="games.rush_2049", friendlyName="San Francisco Rush 2049 (USA)", version=1},
	["61373D4758ECA3FA831BEAC27B4D4C250845F80C"] = {moduleName="games.rush_2049", friendlyName="San Francisco Rush 2049 (Europe) (En,Fr,De,Es,It,Nl)", version=2},

	-- Super Mario 64
	["4AC5721683D0E0B6BBB561B58A71740845DCEEA9"] = {moduleName="games.sm64", friendlyName="Super Mario 64 (Europe) (En,Fr,De)", version=2},
	["3F319AE697533A255A1003D09202379D78D5A2E0"] = {moduleName="games.sm64", friendlyName="Super Mario 64 (Japan) (Rev A) (Shindou Edition)", version=3},
	["8A20A5C83D6CEB0F0506CFC9FA20D8F438CAFE51"] = {moduleName="games.sm64", friendlyName="Super Mario 64 (Japan)", version=4},
	["9BEF1128717F958171A4AFAC3ED78EE2BB4E86CE"] = {moduleName="games.sm64", friendlyName="Super Mario 64 (USA)", version=1},

	-- Smash 64
	["4B71F0E01878696733EEFA9C80D11C147ECB4984"] = {moduleName="games.smash64", friendlyName="Nintendo All-Star! Dairantou Smash Brothers (Japan)", version=1},
	["A9BF83FE73361E8D042C33ED48B3851D7D46712C"] = {moduleName="games.smash64", friendlyName="Super Smash Bros. (Australia)", version=2},
	["6EE8A41FEF66280CE3E3F0984D00B96079442FB9"] = {moduleName="games.smash64", friendlyName="Super Smash Bros. (Europe) (En,Fr,De)", version=3},
	["E2929E10FCCC0AA84E5776227E798ABC07CEDABF"] = {moduleName="games.smash64", friendlyName="Super Smash Bros. (USA)", version=4},
	["88C8FED5ECD5ED901CB5FC4B5BBEFFA3EA022DF7"] = {moduleName="games.smash64", friendlyName="19XXTE 0.11", version=4}, -- Based on US ROM
	["1095F94D70216AC916A9DD8A9FD65DB13E7F9F17"] = {moduleName="games.smash64", friendlyName="19XXGE", version=4}, -- Based on US ROM
	["926DFAD9DAEDE0DDD088D3006BBD1D02CA6222A4"] = {moduleName="games.smash64", friendlyName="Super Smash Bros. (iQue)", version=5},

	-- Sonic The Hedgehog (GG)
	["8A95B36139206A5BA13A38BB626AEE25"] = {moduleName="games.sonic1_sms", friendlyName="Sonic The Hedgehog (J)", version=2},
	["05D0E3897CB2B6E08C2952730D2C80C1"] = {moduleName="games.sonic1_sms", friendlyName="Sonic The Hedgehog (W) (Proto)", version=1}, -- Same addresses as SMS version, interestingly
	["B1DE7027824C434CE8DE59782705F5C9"] = {moduleName="games.sonic1_sms", friendlyName="Sonic The Hedgehog (W) (Rev 1)", version=3},

	-- Sonic The Hedgehog (SMS)
	["6B9677E4A9ABB37765D6DB4658F4324251807E07"] = {moduleName="games.sonic1_sms", friendlyName="Sonic The Hedgehog (UE)", version=1},
	["6ACA0E3DFFE461BA1CB11A86CD4CAF5B97E1B8DF"] = {moduleName="games.sonic1_sms", friendlyName="Sonic The Hedgehog (E) (BIOS)", version=1},
	["DC13A61EAFE75C13C15B5ECE419AC57B"] = {moduleName="games.sonic1_sms", friendlyName="Sonic The Hedgehog (UE)", version=1},
	["4187D96BEAF36385E681A3CF3BD1663D"] = {moduleName="games.sonic1_sms", friendlyName="Sonic The Hedgehog (E) (BIOS)", version=1},

	-- Sonic The Hedgehog 2 (SMS)
	["BF3B7A41E7DA9DE23416473A33C6AC2B"] = {moduleName="games.sonic2_sms", friendlyName="Sonic The Hedgehog 2 (E)"},
	["0AC157B6B7E839953FC8EBA7538FB74A"] = {moduleName="games.sonic2_sms", friendlyName="Sonic The Hedgehog 2 (E) (Rev 1)"},

	-- Space Station Silicon Valley
	["E5E09205AA743A9E5043A42DF72ADC379C746B0B"] = {moduleName="games.sssv", friendlyName="Space Station Silicon Valley (USA)", version=1},
	["23710541BB3394072740B0F0236A7CB1A7D41531"] = {moduleName="games.sssv", friendlyName="Space Station Silicon Valley (Europe) (En,Fr,De)", version=2},

	-- Taz-Mania (SMS)
	["AC98F23DDC24609CB77BB13102E0386F8C2A4A76"] = {moduleName="games.taz", friendlyName="Taz-Mania (E)"},
	["CFC878F0163933FCFCC89E134FBEB31F"] = {moduleName="games.taz", friendlyName="Taz-Mania (E)"},

	-- Tetris Attack
	-- TODO: Support more versions of this game
	["EAD855D774C9943F7FFB5B4F429B2DD07FB6F606"] = {moduleName="Tetris Attack Bot", selfContained=true, friendlyName="Panel de Pon (Japan)"}, -- SNES
	["B59061561A3AEAC13E46735582F29826E7310141"] = {moduleName="Tetris Attack Bot", selfContained=true, friendlyName="Panel de Pon - Event '98 (Japan) (BS)"}, -- SNES
	["08E01F9AD5B6148E1A4355C80E2B23D8B2463443"] = {moduleName="Tetris Attack Bot", selfContained=true, friendlyName="Tetris Attack (Europe) (En,Ja)"}, -- SNES
	["2DC56EAB3E70C0910AE47119D8B69F494E6000DF"] = {moduleName="Tetris Attack Bot", selfContained=true, friendlyName="Tetris Attack (USA) (En,Ja)"}, -- SNES

	-- The Ninja (SMS)
	["76396A25902700E18ADF6BC5C8668E2A8BDF03A9"] = {moduleName="games.the_ninja", friendlyName="The Ninja (UE)"},
	["E9ACDAE112A898F7DB090FC0B8F1CE9B86637234"] = {moduleName="games.the_ninja", friendlyName="The Ninja (J)"},
	["2C620BA64FCAAC940B4B1566733037B3"] = {moduleName="games.the_ninja", friendlyName="The Ninja (UE)"},
	["41E20AFE05C2FBE45AC5F3A9C8111047"] = {moduleName="games.the_ninja", friendlyName="The Ninja (J)"},

	-- Toy Story 2
	["A9F97E22391313095D2C2FBAF81FB33BFA2BA7C6"] = {moduleName="games.ts2", friendlyName="Toy Story 2 - Buzz l'Eclair a la Rescousse! (France)", version=1},
	["92015E5254CBBAD1BC668ECB13A4B568E5F55052"] = {moduleName="games.ts2", friendlyName="Toy Story 2 - Buzz Lightyear to the Rescue! (Europe)", version=2},
	["982AD2E1E44C6662C88A77367BC5DF91C51531BF"] = {moduleName="games.ts2", friendlyName="Toy Story 2 - Buzz Lightyear to the Rescue! (USA)", version=3},
	["EAE83C07E2E777D8E71A5BE6120AED03D7E67782"] = {moduleName="games.ts2", friendlyName="Toy Story 2 - Captain Buzz Lightyear auf Rettungsmission! (Germany) (Rev A)", version=4},
	["F8FBB100227015BE8629243F53D70F29A2A14315"] = {moduleName="games.ts2", friendlyName="Toy Story 2 - Captain Buzz Lightyear auf Rettungsmission! (Germany)", version=5},

	-- Ty the Tasmanian Tiger 2: Bush Rescue(GBA)
	["84267CE3D86100688048A8D4F166FA1B2D50E6D5"] = {moduleName="games.GBA_Ty2", friendlyName="Ty the Tasmanian Tiger 2 - Bush Rescue (USA,Europe) (En,Fr,De)"},

	-- Tyrants - Fight Through Time (Mega Lo Mania)
	["B090D74241CD56820B568C319799412B"] = {moduleName="games.tftt", friendlyName="Tyrants - Fight Through Time (U) [!]"},
	["1F7DD4DCB076E7AF7E43F01795504C4A"] = {moduleName="games.tftt", friendlyName="Tyrants - Fight Through Time (U) [!]"}, -- Bad dump?
	["8EBE079DB90BEC1AE3E5CBBBDDF0EC4F3164B191"] = {moduleName="games.tftt", friendlyName="Tyrants - Fight Through Time (U) [!]"}, -- Bad dump?
	["692F7BF5446415B1B64AAA32E4F652E6"] = {moduleName="games.tftt", friendlyName="Tyrants - Fight Through Time (U) [b1]"},
	["C98AD9D36B1A43B7C6E687C197487C05"] = {moduleName="games.tftt", friendlyName="Tyrants - Fight Through Time (U) [b2]"},
	["11AA8E16CB988BFE63A18E81976DDD3E"] = {moduleName="games.tftt", friendlyName="Tyrants - Fight Through Time (U) [b3]"},
	["2E132458425BB780A3563611811E33E4"] = {moduleName="games.tftt", friendlyName="Tyrants - Fight Through Time (U) [f1]"},
	["080686B870B124F89E47AC9C83A94A73"] = {moduleName="games.tftt", friendlyName="Tyrants - Fight Through Time (U) [hI+1C]"},
	["21901EE9D49825953454DF458230D673"] = {moduleName="games.tftt", friendlyName="Tyrants - Fight Through Time (U) [hI+2C]"},
	["A5D23A84E3320CB5A0DDA78B1A435083"] = {moduleName="games.tftt", friendlyName="Tyrants - Fight Through Time (U) [hI]"},
	["E622BC3C4A61AACC2EFC1FE4C580987F"] = {moduleName="games.tftt", friendlyName="Mega Lo Mania (E) (REV00) [c][!]"},
	["B26A3CE67638A9A02E0CFEA97A31A2DE"] = {moduleName="games.tftt", friendlyName="Mega Lo Mania (E) (REV01) [hI+C]"},
	["EFF87FFE2421EF0F5A5965F3B9D3F573"] = {moduleName="games.tftt", friendlyName="Mega Lo Mania (E) (REV01) [hI]"},
	["A4561B736011C91E43C18AA8971CDEAD"] = {moduleName="games.tftt", friendlyName="Mega Lo Mania (E) (REV01)"},
	["6D294B1A2C901AE61774754F6F533A34"] = {moduleName="games.tftt", friendlyName="Mega Lo Mania (J) [!]"},
	["1FCFC9EE3BFFC25388735782B0CDB829A7E40507"] = {moduleName="games.tftt", friendlyName="Mega Lo Mania (F) [!]"},

	-- Wonder Boy
	["917C3E4F4C50D6506E64E2F05B945D9C"] = {moduleName="games.wonder_boy_sms", friendlyName="Wonder Boy (J)", version=2}, -- Game Gear
	["03ADBEA26158137DE3F18D82E119C520"] = {moduleName="games.wonder_boy_sms", friendlyName="Wonder Boy (E)", version=2}, -- Game Gear
	["A4E48850BF8799CFAC74B1D33F5900B5"] = {moduleName="games.wonder_boy_sms", friendlyName="Wonder Boy (JE)", version=1},
	["7E805AA51BFB5F206C950A32EBCDAB7C"] = {moduleName="games.wonder_boy_sms", friendlyName="Wonder Boy (UE)", version=1},

	-- Wonder Boy III
	["E7F86C049E4BD8B26844FF62BD067D57"] = {moduleName="games.wonder_boy_iii", friendlyName="Wonder Boy III - The Dragon's Trap (UE)"},

	-- Wonder Boy in Monster World (SMS)
	["DA0ACDB1B9E806AA67A0216A675CB02ED24ABF8B"] = {moduleName="games.wonder_boy_monster_world", friendlyName="Wonder Boy in Monster World (E)"},
	["5837764C172C8C43C8C7B21F2144CF27"] = {moduleName="games.wonder_boy_monster_world", friendlyName="Wonder Boy in Monster World (E)"},
};

local romName = gameinfo.getromname();
local romHash = gameinfo.getromhash();
Game = nil;

if not ScriptHawk.ui_test then
	if not ScriptHawk.force_module.enabled then
		for k, v in pairs(supportedGames) do
			if romHash == k then
				Game = require (v.moduleName);
				ScriptHawk.moduleName = v.moduleName;
				ScriptHawk.gamePrefName = string.gsub(ScriptHawk.moduleName, "games.", "");
				if type(v.version) == "number" then
					Game.version = v.version;
				end
				if v.selfContained then -- Self contained modules that do not require ScriptHawk's functionality and merely use ScriptHawk.lua as a convenient loader
					return true;
				end
			end
		end
	else
		-- Force a particular module to load, see ScriptHawk.force_module for details
		print("ScriptHawk is forcing a particular module to load.");
		print("We cannot guarantee that this will work as desired, but we'll give it a shot anyways.");
		print("Good luck!");
		Game = require (ScriptHawk.force_module.name);
		ScriptHawk.moduleName = ScriptHawk.force_module.name;
		ScriptHawk.gamePrefName = string.gsub(ScriptHawk.moduleName, "games.", "");
		if type(ScriptHawk.force_module.version) == "number" then
			Game.version = ScriptHawk.force_module.version;
		end
		if ScriptHawk.force_module.selfContained then -- Self contained modules that do not require ScriptHawk's functionality and merely use ScriptHawk.lua as a convenient loader
			return true;
		end
	end

	if type(Game) ~= "table" then
		print("This game is not currently supported.");
		return false;
	end

	if Game.squish_memory_table and type(Game.version) == "number" then
		-- Squish Game.Memory tables down to a single address for the relevant version
		for k, v in pairs(Game.Memory) do
			Game.Memory[k] = v[Game.version];
		end
	end

	if type(Game.detectVersion) == "function" then
		if not Game.detectVersion(romName, romHash) then
			if not ScriptHawk.force_module.enabled then
				print("This version of the game is not currently supported.");
				return false;
			end
		end
	end
else
	Game = {};
end

currentPreferences = {};
function loadPreferences()
	-- Load preferences from disk
	require "default_preferences";
	require "user_preferences";

	-- Copy defaultPreferences into currentPreferences
	currentPreferences = {};
	for moduleName, defaultPreference in pairs(defaultPreferences) do
		currentPreferences[moduleName] = {};
		if userPreferences[moduleName] == nil then
			userPreferences[moduleName] = {};
		end
		for OSDType, preference in pairs(defaultPreference) do
			currentPreferences[moduleName][OSDType] = preference;
		end
	end

	-- Override defaults with userPreferences in currentPreferences
	for moduleName, userPreference in pairs(userPreferences) do
		for OSDType, preference in pairs(userPreference) do
			if type(preference) == "boolean" then
				currentPreferences[moduleName][OSDType] = preference;
			end
		end
	end

	-- Update checkboxes if the modifyOSD() form is open
	if ScriptHawk.modifyOSDUI.isOpen then
		for OSDType, preference in pairs(currentPreferences[ScriptHawk.gamePrefName]) do
			local checkboxID = OSDType.."Checkbox";
			if preference then
				forms.setproperty(ScriptHawk.modifyOSDUI.form_controls[checkboxID], "Checked", true);
			else
				forms.setproperty(ScriptHawk.modifyOSDUI.form_controls[checkboxID], "Checked", false);
			end
		end
	end
end
loadPreferences();

-----------
-- State --
-----------

ScriptHawk.override_lag_detection = type(Game.isPhysicsFrame) == "function"; -- Default to true if the game implements custom lag detection
local rotation_units = "Degrees";

local current_frame = emu.framecount(); -- TODO: Move this to ScriptHawk table to give access for game modules?
local previous_frame = current_frame - 1; -- TODO: Move this to ScriptHawk table to give access for game modules?

local previous_map = "";
local previous_map_value = 0;

local x = 0.0;
local y = 0.0;
local z = 0.0;

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

function ScriptHawk.getDX()
	return dx;
end

function ScriptHawk.getDY()
	return dy;
end

function ScriptHawk.getDZ()
	return dz;
end

-- Rounding precision
precision = 3;

function ScriptHawk.decreasePrecision()
	precision = math.max(0, precision - 1);
end

function ScriptHawk.increasePrecision()
	precision = math.min(12, precision + 1);
end

function ScriptHawk.decreaseSpeed()
	Game.speedy_index = math.max(1, Game.speedy_index - 1);
end

function ScriptHawk.increaseSpeed()
	Game.speedy_index = math.min(#Game.speedy_speeds, Game.speedy_index + 1);
end

ScriptHawk.movingAngle = 0.0;
function ScriptHawk.getMovingAngle()
	if ScriptHawk.smooth_moving_angle == true then
		if dx == 0 and dz == 0 then
			return 0;
		end
	end
	return angleBetweenPoints(prev_x, prev_z, Game.getXPosition(), Game.getZPosition());
end

if type(Game.speedy_speeds) ~= "table" then
	if ScriptHawk.warnings then
		print("Warning: This module does not have a Game.speedy_speeds table");
	end
	Game.speedy_speeds = {0};
end

if type(Game.speedy_index) ~= "number" then
	if ScriptHawk.warnings then
		print("Warning: This module does not have a Game.speedy_index value");
	end
	Game.speedy_index = 1;
end

if type(Game.max_rot_units) ~= "number" then
	if ScriptHawk.warnings then
		print("Warning: This module does not have a Game.max_rot_units value");
	end
	Game.max_rot_units = 0;
end

if type(Game.rot_speed) ~= "number" then
	if ScriptHawk.warnings then
		print("Warning: This module does not have a Game.rot_speed value");
	end
	Game.rot_speed = 0;
end

--------------
-- Position --
--------------

if type(Game.getXPosition) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.getXPosition()");
	end
	function Game.getXPosition()
		return 0;
	end
end

if type(Game.getYPosition) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.getYPosition()");
	end
	function Game.getYPosition()
		return 0;
	end
end

if type(Game.getZPosition) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.getZPosition()");
	end
	function Game.getZPosition()
		return 0;
	end
end

if type(Game.setXPosition) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.setXPosition()");
	end
	function Game.setXPosition()
		return;
	end
end

if type(Game.setYPosition) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.setYPosition()");
	end
	function Game.setYPosition()
		return;
	end
end

if type(Game.setZPosition) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.setZPosition()");
	end
	function Game.setZPosition()
		return;
	end
end

--------------
-- Rotation --
--------------

if type(Game.getXRotation) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.getXRotation()");
	end
	function Game.getXRotation()
		return 0;
	end
end

if type(Game.getYRotation) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.getYRotation()");
	end
	function Game.getYRotation()
		return 0;
	end
end

if type(Game.getZRotation) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.getZRotation()");
	end
	function Game.getZRotation()
		return 0;
	end
end

if type(Game.setXRotation) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.setXRotation()");
	end
	function Game.setXRotation(value)
	end
end

if type(Game.setYRotation) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.setYRotation()");
	end
	function Game.setYRotation(value)
	end
end

if type(Game.setZRotation) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.setZRotation()");
	end
	function Game.setZRotation(value)
	end
end

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
	elseif rotation_units == "Units" then
		rotation_units = "Hex";
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
	elseif rotation_units == "Hex" then
		return toHexString(num);
	end
	return num;
end

local function toggleMode()
	if ScriptHawk.mode == 'Position' then
		ScriptHawk.mode = 'Rotation';
	elseif ScriptHawk.mode == 'Rotation' then
		ScriptHawk.mode = 'YRotation';
	elseif ScriptHawk.mode == 'YRotation' then
		ScriptHawk.mode = 'TAS';
	else
		ScriptHawk.mode = 'Position';
	end
end

---------------
-- Telemetry --
---------------

ScriptHawk.telemetryData = {};
ScriptHawk.collecting_telemetry = false;

local function getTelemetryHeaderString()
	local headerString = "Frame,";
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
function ScriptHawk.outputTelemetry()
	-- Print CSV header
	dprint(getTelemetryHeaderString());

	-- Print CSV values
	for i = 0, emu.framecount() do -- I know this isn't optimal, but unfortunately ipairs() doesn't like tables with gaps in them, and pairs() doesn't iterate through keys in numerical order
		if type(ScriptHawk.telemetryData[i]) == "table" then
			local outputString = i..",";
			for k, v in ipairs(ScriptHawk.telemetryData[i]) do
				outputString = outputString..(v)..",";
			end
			dprint(outputString);
		end
	end

	print_deferred();
end

function ScriptHawk.startTelemetry()
	ScriptHawk.collecting_telemetry = true;
	ScriptHawk.clearTelemetry();
	forms.settext(ScriptHawk.UI.form_controls["Toggle Telemetry Button"], "Stop Telemetry");
end

function ScriptHawk.stopTelemetry()
	ScriptHawk.collecting_telemetry = false;
	forms.settext(ScriptHawk.UI.form_controls["Toggle Telemetry Button"], "Start Telemetry");

	ScriptHawk.outputTelemetry();
	return;
end

function ScriptHawk.toggleTelemetry()
	if ScriptHawk.collecting_telemetry then
		ScriptHawk.stopTelemetry();
	else
		ScriptHawk.startTelemetry();
	end
end

function ScriptHawk.clearTelemetry()
	ScriptHawk.telemetryData = {};
end

----------------------
-- TAStudio Columns --
----------------------

local TAStudio_column_data = {};
local TAStudio_color_data = {};

-- For older BizHawk versions
if tastudio.addcolumn == nil then
	function tastudio.addcolumn()
	end
else
	local function TAStudioTextUpdate(frameNumber, name)
		if TAStudio_column_data[frameNumber] ~= nil and TAStudio_column_data[frameNumber][name] ~= nil then
			return TAStudio_column_data[frameNumber][name];
		end
	end

	if tastudio.onqueryitemtext ~= nil then
		tastudio.onqueryitemtext(TAStudioTextUpdate);
	end

	--[[
	function TAStudioColorUpdate(frameNumber, name)
		if TAStudio_color_data[frameNumber] ~= nil and TAStudio_color_data[frameNumber][name] ~= nil then
			return TAStudio_color_data[frameNumber][name];
		end
	end

	if tastudio.onqueryitembg ~= nil then
		tastudio.onqueryitembg(TAStudioColorUpdate);
	end
	--]]
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

function ScriptHawk.UI.handleColInput(col)
	if col == nil then
		col = 0;
	end
	if type(col) == "number" then
		col = ScriptHawk.UI.col(col);
	end
	if type(col) == "table" then
		if #col == 2 then
			col = ScriptHawk.UI.col(col[1]) + col[2];
		elseif #col == 1 then
			col = col[1];
		end
	end
	return col;
end

function ScriptHawk.UI.handleRowInput(row)
	if row == nil then
		row = 0;
	end
	if type(row) == "number" then
		row = ScriptHawk.UI.row(row);
	end
	if type(row) == "table" then
		if #row == 2 then
			row = ScriptHawk.UI.row(row[1]) + row[2];
		elseif #row == 1 then
			row = row[1];
		end
	end
	return row;
end

if type(Game.form_width) == "number" then
	ScriptHawk.UI.form_height = Game.form_width;
end
if type(Game.form_height) == "number" then
	ScriptHawk.UI.form_height = Game.form_height;
end

function ScriptHawk.UI.checkbox(col, row, tag, caption, default)
	col = ScriptHawk.UI.handleColInput(col);
	row = ScriptHawk.UI.handleRowInput(row);
	if tag == nil then
		tag = caption.." Checkbox";
	end
	ScriptHawk.UI.form_controls[tag] = forms.checkbox(ScriptHawk.UI.options_form, caption, col + ScriptHawk.UI.dropdown_offset, row + ScriptHawk.UI.dropdown_offset);
	forms.setproperty(ScriptHawk.UI.form_controls[tag], "Height", 22);
	if default then
		forms.setproperty(ScriptHawk.UI.form_controls[tag], "Checked", true);
	end
end

function ScriptHawk.UI.ischecked(tag)
	return ScriptHawk.UI.form_controls[tag] ~= nil and forms.ischecked(ScriptHawk.UI.form_controls[tag]);
end
ScriptHawk.UI.isChecked = ScriptHawk.UI.ischecked;

function ScriptHawk.UI.button(col, row, width, height, tag, caption, callback)
	if height == nil then
		height = ScriptHawk.UI.button_height;
	else
		height = ScriptHawk.UI.handleRowInput(height);
	end

	width = ScriptHawk.UI.handleColInput(width);
	col = ScriptHawk.UI.handleColInput(col);
	row = ScriptHawk.UI.handleRowInput(row);

	if tag == nil then
		tag = caption.." Button";
	end
	--print("Creating button: "..col..","..row..","..width..","..height..","..tag..","..caption..","..tostring(callback == nil));
	ScriptHawk.UI.form_controls[tag] = forms.button(ScriptHawk.UI.options_form, caption, callback, col, row, width, height);
end

function ScriptHawk.initUI(formTitle)
	if type(formTitle) == "string" then
		ScriptHawk.UI.options_form = forms.newform(ScriptHawk.UI.col(ScriptHawk.UI.form_width), ScriptHawk.UI.row(ScriptHawk.UI.form_height), formTitle);
	else
		ScriptHawk.UI.options_form = forms.newform(ScriptHawk.UI.col(ScriptHawk.UI.form_width), ScriptHawk.UI.row(ScriptHawk.UI.form_height), "ScriptHawk Options");
	end

	if not TASSafe then
		ScriptHawk.UI.form_controls["Mode Label"] = forms.label(ScriptHawk.UI.options_form, "Mode:", ScriptHawk.UI.col(0), ScriptHawk.UI.row(0) + ScriptHawk.UI.label_offset, 44, ScriptHawk.UI.button_height);
		ScriptHawk.UI.button(2, 0, {64}, nil, "Mode Button", ScriptHawk.mode, toggleMode);
	else
		ScriptHawk.UI.checkbox(0, 2, "Override Lag Detection", "Override Lag Detection", ScriptHawk.override_lag_detection);
		forms.setproperty(ScriptHawk.UI.form_controls["Override Lag Detection"], "Width", 140);
	end

	ScriptHawk.UI.form_controls["Precision Label"] = forms.label(ScriptHawk.UI.options_form, "Precision:", ScriptHawk.UI.col(0), ScriptHawk.UI.row(1) + ScriptHawk.UI.label_offset, 54, 14);
	ScriptHawk.UI.button({4, -28}, 1, {ScriptHawk.UI.button_height}, nil, "Decrease Precision Button", "-", ScriptHawk.decreasePrecision);
	ScriptHawk.UI.button({5, -28}, 1, {ScriptHawk.UI.button_height}, nil, "Increase Precision Button", "+", ScriptHawk.increasePrecision);
	ScriptHawk.UI.form_controls["Precision Value Label"] = forms.label(ScriptHawk.UI.options_form, precision, ScriptHawk.UI.col(5), ScriptHawk.UI.row(1) + ScriptHawk.UI.label_offset, 44, 14);

	if not TASSafe then
		if ScriptHawk.dpad.joypad.enabled or ScriptHawk.dpad.key.enabled then
			ScriptHawk.UI.form_controls["Speed Label"] = forms.label(ScriptHawk.UI.options_form, "Speed:", ScriptHawk.UI.col(0), ScriptHawk.UI.row(2) + ScriptHawk.UI.label_offset, 54, 14);
			ScriptHawk.UI.button({4, -28}, 2, {ScriptHawk.UI.button_height}, nil, "Decrease Speed Button", "-", ScriptHawk.decreaseSpeed);
			ScriptHawk.UI.button({5, -28}, 2, {ScriptHawk.UI.button_height}, nil, "Increase Speed Button", "+", ScriptHawk.increaseSpeed);
			ScriptHawk.UI.form_controls["Speed Value Label"] = forms.label(ScriptHawk.UI.options_form, "0", ScriptHawk.UI.col(5), ScriptHawk.UI.row(2) + ScriptHawk.UI.label_offset, 47, 14);
		end

		if type(Game.maps) == "table" then
			local filteredMaps = {};
			for i = 1, #Game.maps do
				if string.sub(Game.maps[i], 1, 1) ~= "!" then
					table.insert(filteredMaps, Game.maps[i]);
				end
			end
			ScriptHawk.UI.form_controls["Map Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, filteredMaps, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(3) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);
			if Game.takeMeThereType == nil or Game.takeMeThereType == "Checkbox" then
				Game.takeMeThereType = "Checkbox";
				ScriptHawk.UI.checkbox(0, 4, "Map Checkbox", "Take me there");
			elseif Game.takeMeThereType == "Button" then
				ScriptHawk.UI.button(0, 4, {4, 10}, nil, "Map Button", "Take me there", function() Game.setMap(previous_map_value); end);
			end
		end

		if type(Game.applyInfinites) == "function" then
			ScriptHawk.UI.checkbox(0, 5, "Toggle Infinites Checkbox", "Infinites");
		end
	end

	if type(Game.getHitboxes) == "function" then
		ScriptHawk.UI.checkbox(10, 0, "Show Hitboxes Checkbox", "Hitboxes", ScriptHawk.hitboxDefaultShowHitboxes);
		local showListRow = 2;
		if type(Game.setHitboxPosition) == "function" and not TASSafe then
			ScriptHawk.UI.checkbox(10, 1, "Draggable Hitboxes Checkbox", "Draggable");
		else
			showListRow = 1; -- Move "Show List" checkbox up one row if Draggable checkbox is not drawn
		end
		if type(Game.getHitboxListText) == "function" then
			ScriptHawk.UI.checkbox(10, showListRow, "Show List Checkbox", "Show List", ScriptHawk.hitboxDefaultShowList);
		end
	end

	ScriptHawk.UI.button(10, 3, {4, 10}, nil, "Toggle Telemetry Button", "Start Telemetry", ScriptHawk.toggleTelemetry);

	ScriptHawk.UI.form_controls["Rotation Units Label"] = forms.label(ScriptHawk.UI.options_form, "Units:", ScriptHawk.UI.col(5), ScriptHawk.UI.row(0) + ScriptHawk.UI.label_offset, 44, 14);
	ScriptHawk.UI.button(7, 0, {64}, nil, "Toggle Rotation Units Button", rotation_units, toggleRotationUnits);
end

if ScriptHawk.ui_test == true then
	local loadedModules = {};
	for k, v in pairs(supportedGames) do
		if v.selfContained then
			-- Nothing needed here
		else
			-- Make sure we don't load the same module multiple times
			-- Doing so causes an exception when squishing Game.Memory tables in Game.detectVersion
			-- TODO: Figure out how to load all versions of a module without it breaking
			if loadedModules[v.moduleName] == nil then
				loadedModules[v.moduleName] = true;
				Game = require (v.moduleName);
				ScriptHawk.moduleName = v.moduleName;
				ScriptHawk.gamePrefName = string.gsub(ScriptHawk.moduleName, "games.", "");
				if type(v.version) == "number" then
					Game.version = v.version;
					if Game.squish_memory_table then
						-- Squish Game.Memory tables down to a single address for the relevant version
						for k, v in pairs(Game.Memory) do
							Game.Memory[k] = v[Game.version];
						end
					end
				end

				if type(Game.detectVersion) == "function" then
					Game.detectVersion(v.friendlyName, k);
				end
				ScriptHawk.initUI(v.friendlyName);
				if type(Game.initUI) == "function" then
					Game.initUI();
					if ScriptHawk.warnings then
						ScriptHawk.UI.checkControls();
					end
				end
			end
		end
	end
	return false;
end

ScriptHawk.initUI();

-- Init any custom UI that the game module uses
if type(Game.initUI) == "function" then
	Game.initUI();
	if ScriptHawk.warnings then
		ScriptHawk.UI.checkControls();
	end
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
	if ScriptHawk.warnings then
		print("Warning: This module does not define a custom Game.OSD");
	end
	Game.OSD = {
		{"X", category="position"},
		{"Y", category="position"},
		{"Z", category="position"},
		{"Separator"},
		{"dY", category="positionStats"},
		{"dXZ", category="positionStats"},
		{"Separator"},
		{"Max dY", category="positionStatsMore"},
		{"Max dXZ", category="positionStatsMore"},
		{"Odometer", category="positionStatsMore"},
		{"Separator"},
		{"Rot. X", Game.getXRotation, category="angle"},
		{"Facing", Game.getYRotation, category="angle"},
		{"Rot. Z", Game.getZRotation, category="angle"},
	};
end

if type(Game.OSDPosition) ~= "table" then
	Game.OSDPosition = {2, 76};
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
	forms.settext(ScriptHawk.UI.form_controls["Precision Value Label"], precision);
	forms.settext(ScriptHawk.UI.form_controls["Toggle Rotation Units Button"], rotation_units);

	if not TASSafe then
		if ScriptHawk.dpad.joypad.enabled or ScriptHawk.dpad.key.enabled then
			forms.settext(ScriptHawk.UI.form_controls["Speed Value Label"], Game.speedy_speeds[Game.speedy_index]);
		end
		forms.settext(ScriptHawk.UI.form_controls["Mode Button"], ScriptHawk.mode);

		if type(Game.maps) == "table" and previous_map ~= forms.gettext(ScriptHawk.UI.form_controls["Map Dropdown"]) then
			previous_map = forms.gettext(ScriptHawk.UI.form_controls["Map Dropdown"]);
			previous_map_value = ScriptHawk.UI.findMapValue();
		end
	end

	local frameCount = emu.framecount();
	local telemetryFound = false;
	local telemetryIndex = 0;
	local telemetryDataThisFrame = {};
	if ScriptHawk.collecting_telemetry == false and type(ScriptHawk.telemetryData[frameCount]) == "table" then
		telemetryFound = true;
		telemetryDataThisFrame = ScriptHawk.telemetryData[frameCount];
	end

	local TAStudioEngaged = tastudio.engaged();
	local TAStudioDataThisFrame = {};
	local TAStudioColorThisFrame = {};
	local atleastOneTAStudioColumn = false;

	-- Draw OSD
	local row = 0;
	local OSDX = Game.OSDPosition[1];
	local OSDY = Game.OSDPosition[2];

	local nothingDrawnSinceLastSeparator = true;
	local moduleHasOSDPreferences = currentPreferences[ScriptHawk.gamePrefName] ~= nil;

	for i, OSDRow in ipairs(Game.OSD) do
		local label = OSDRow[1];
		local value = OSDRow[2];
		local color = OSDRow[3];
		local variableType = OSDRow.category;
		local inTAStudio = OSDRow.tastudio_column == true;

		if label ~= "Separator" then
			-- Check if variable should be visible based on preferences, default to true
			local variableVisible = true;

			if moduleHasOSDPreferences and variableType ~= nil then
				variableVisible = false;
				if currentPreferences[ScriptHawk.gamePrefName][variableType] == true then
					variableVisible = true;
				end
			end

			local labelLower = string.lower(label);

			if value == nil then
				-- Detect special keywords
				if labelLower == "x" or labelLower == "x pos" or labelLower == "x position" then
					value = x;
				elseif labelLower == "y" or labelLower == "y pos" or labelLower == "y position" then
					value = y;
				elseif labelLower == "z" or labelLower == "z pos" or labelLower == "z position" then
					value = z;
				end

				if labelLower == "dx" then
					value = dx;
				elseif labelLower == "dy" then
					value = dy;
				elseif labelLower == "dz" then
					value = dz;
				elseif labelLower == "dxz" or labelLower == "d" then
					value = d;
				end

				if labelLower == "max dx" then
					value = max_dx;
				elseif labelLower == "max dy" then
					value = max_dy;
				elseif labelLower == "max dz" then
					value = max_dz;
				elseif labelLower == "max dxz" or labelLower == "max d" then
					value = max_d;
				elseif labelLower == "odometer" then
					value = odometer;
				end

				if labelLower == "moving angle" then -- TODO: This has some name conflicts, "moving"
					value = round(ScriptHawk.movingAngle, precision)..string.char(0xB0);
				end
			end

			-- Get the value
			if type(value) == "function" then
				value = value();
			end

			if value == nil then
				if ScriptHawk.warnings then
					print('Warning: When drawing the OSD, a value for label "'..label..'" was nil');
				end
				value = "nil";
			end

			if value ~= value then
				if ScriptHawk.warnings then
					print('Warning: When drawing the OSD, a value for label "'..label..'" was NaN');
				end
				value = "NaN";
			end

			-- Round the value
			if type(value) == "number" then
				value = round(value, precision);
			end

			-- Convert booleans to strings
			if type(value) == "boolean" then
				value = tostring(value);
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

			if TAStudioEngaged and inTAStudio then
				atleastOneTAStudioColumn = true;
				TAStudioDataThisFrame[label] = value;
				--TAStudioColorThisFrame[label] = color;
				tastudio.addcolumn(label, label, OSDRow.tastudio_column_width or 50);
			end

			-- Collect all OSD rows for telemetry, even if they're not visible
			-- TODO: Only run the value functions if the row is visible or if we're collecting telemetry
			if ScriptHawk.collecting_telemetry then
				table.insert(telemetryDataThisFrame, value);
			end
			telemetryIndex = telemetryIndex + 1;

			if variableVisible then
				if telemetryFound then
					local telemetryValue = telemetryDataThisFrame[telemetryIndex];
					if telemetryValue == nil then
						telemetryValue = "nil";
					end
					if labelLower == "x" then
						gui.text(OSDX, OSDY + Game.OSDRowHeight * row, label..": "..value.." ("..telemetryValue..") ("..(x - telemetryValue).." d)", color);
					elseif labelLower == "y" then
						gui.text(OSDX, OSDY + Game.OSDRowHeight * row, label..": "..value.." ("..telemetryValue..") ("..(y - telemetryValue).." d)", color);
					elseif labelLower == "z" then
						gui.text(OSDX, OSDY + Game.OSDRowHeight * row, label..": "..value.." ("..telemetryValue..") ("..(z - telemetryValue).." d)", color);
					else
						gui.text(OSDX, OSDY + Game.OSDRowHeight * row, label..": "..value.." ("..telemetryValue..")", color);
					end
				else
					gui.text(OSDX, OSDY + Game.OSDRowHeight * row, label..": "..value, color);
				end
				row = row + 1;
				nothingDrawnSinceLastSeparator = false;
			end
		else
			if not nothingDrawnSinceLastSeparator then
				if type(value) == "number" and value > 1 then
					row = row + value - 1;
				end
				row = row + 1;
				nothingDrawnSinceLastSeparator = true;
			end
		end
	end
	if atleastOneTAStudioColumn then
		TAStudio_column_data[frameCount] = TAStudioDataThisFrame;
		--TAStudio_color_data[frameCount] = TAStudioColorThisFrame;
	end
	if ScriptHawk.collecting_telemetry then
		ScriptHawk.telemetryData[frameCount] = telemetryDataThisFrame;
	end
end

---------------------
-- Modify OSD Form --
---------------------

function ScriptHawk.modifyOSDUI.checkbox(ui_col, ui_row, ui_tag, ui_caption, ui_default)
	ScriptHawk.modifyOSDUI.form_controls[ui_tag] = forms.checkbox(ScriptHawk.modifyOSDUI.options_form, ui_caption, ScriptHawk.UI.col(ui_col) + ScriptHawk.modifyOSDUI.dropdown_offset, ScriptHawk.UI.row(ui_row) + ScriptHawk.modifyOSDUI.dropdown_offset);
	forms.setproperty(ScriptHawk.modifyOSDUI.form_controls[ui_tag], "Height", 22);
	if ui_default then
		forms.setproperty(ScriptHawk.modifyOSDUI.form_controls[ui_tag], "Checked", true);
	end
end

function ScriptHawk.modifyOSDUI.ischecked(ui_tag)
	return ScriptHawk.modifyOSDUI.form_controls[ui_tag] ~= nil and forms.ischecked(ScriptHawk.modifyOSDUI.form_controls[ui_tag]);
end
ScriptHawk.modifyOSDUI.isChecked = ScriptHawk.modifyOSDUI.ischecked;

local function restoreModifyOSDDefaults()
	for k, v in pairs(defaultPreferences[ScriptHawk.gamePrefName]) do
		local checkboxID = k.."Checkbox";
		if v == true then
			forms.setproperty(ScriptHawk.modifyOSDUI.form_controls[checkboxID], "Checked", true);
		else
			forms.setproperty(ScriptHawk.modifyOSDUI.form_controls[checkboxID], "Checked", false);
		end
	end
end

local function saveUserPreferences()
	if ScriptHawk.isFileIOSafe then
		-- Open the file for writing
		local file = io.open('user_preferences.lua', "w");
		file:write("userPreferences={\n");
		for moduleName, userPreference in pairs(userPreferences) do
			local shouldWriteModule = false;
			local preferencesString = "\t"..moduleName.."={\n";
			for OSDType, preference in pairs(userPreference) do
				local valueToWrite = "true";
				if preference == nil then
					valueToWrite = "nil";
				elseif preference == false then
					valueToWrite = "false";
				end
				if userPreferences[moduleName][OSDType] ~= defaultPreferences[moduleName][OSDType] then
					shouldWriteModule = true;
					preferencesString = preferencesString.."\t\t"..OSDType.."="..valueToWrite..",\n";
				end
			end
			if shouldWriteModule then
				preferencesString = preferencesString.."\t},\n";
				file:write(preferencesString);
			end
		end
		file:write("};\n");
		file:close();
	else
		ScriptHawk.biz222Notice();
	end
end

local function clearPreferences()
	if ScriptHawk.isFileIOSafe then
		-- Open the file for writing
		local file = io.open('user_preferences.lua', "w");
		file:write("userPreferences={\n");
		for moduleName, userPreference in pairs(userPreferences) do
			file:write("\t"..moduleName.."={\n");
			file:write("\t},\n");
		end
		file:write("};\n");
		file:close();
		loadPreferences();
	else
		ScriptHawk.biz222Notice();
	end
end

function modifyOSD()
	if ScriptHawk.modifyOSDUI.isOpen then
		print("The modifyOSD() window is already open, please close it before opening another one.");
		return;
	end

	-- Update form height
	local preferenceCount = 0;
	for OSDType, preference in pairs(defaultPreferences[ScriptHawk.gamePrefName]) do
		preferenceCount = preferenceCount + 1;
	end
	ScriptHawk.modifyOSDUI.form_height = preferenceCount + 8.5;

	-- Carry on
	ScriptHawk.modifyOSDUI.options_form = forms.newform(ScriptHawk.UI.col(ScriptHawk.modifyOSDUI.form_width), ScriptHawk.UI.row(ScriptHawk.modifyOSDUI.form_height), "Modify OSD", function() ScriptHawk.modifyOSDUI.isOpen = false end);
	ScriptHawk.modifyOSDUI.isOpen = true;
	ScriptHawk.modifyOSDUI.form_controls["Title Label"] = forms.label(ScriptHawk.modifyOSDUI.options_form, "MODIFY SCRIPTHAWK OSD", ScriptHawk.UI.col(0), ScriptHawk.UI.row(0) + ScriptHawk.modifyOSDUI.label_offset, 300, 16);
	local OSDRow = 1;
	for OSDType, preference in pairs(defaultPreferences[ScriptHawk.gamePrefName]) do
		local labelID = OSDType.."Label";
		local labelText = OSDType..":";
		local checkboxID = OSDType.."Checkbox";
		ScriptHawk.modifyOSDUI.form_controls[labelID] = forms.label(ScriptHawk.modifyOSDUI.options_form, labelText, ScriptHawk.UI.col(0), ScriptHawk.UI.row(OSDRow) + ScriptHawk.modifyOSDUI.label_offset, 150, 16);
		ScriptHawk.modifyOSDUI.checkbox(8, OSDRow, checkboxID, "");
		if currentPreferences[ScriptHawk.gamePrefName][OSDType] == true then
			forms.setproperty(ScriptHawk.modifyOSDUI.form_controls[checkboxID], "Checked", true);
		end
		OSDRow = OSDRow + 1;
	end
	ScriptHawk.modifyOSDUI.form_controls["OSD Default Restore"] = forms.button(ScriptHawk.modifyOSDUI.options_form, "Restore to Default", restoreModifyOSDDefaults, ScriptHawk.UI.col(0), ScriptHawk.UI.row(preferenceCount + 2), 200, ScriptHawk.modifyOSDUI.button_height);
	ScriptHawk.modifyOSDUI.form_controls["OSD Load Preferences"] = forms.button(ScriptHawk.modifyOSDUI.options_form, "Load User Preferences", loadPreferences, ScriptHawk.UI.col(0), ScriptHawk.UI.row(preferenceCount + 3), 200, ScriptHawk.modifyOSDUI.button_height);
	if ScriptHawk.isFileIOSafe then
		ScriptHawk.modifyOSDUI.form_controls["OSD Save Preferences"] = forms.button(ScriptHawk.modifyOSDUI.options_form, "Save As User Preference", saveUserPreferences, ScriptHawk.UI.col(0), ScriptHawk.UI.row(preferenceCount + 4), 200, ScriptHawk.modifyOSDUI.button_height);
		ScriptHawk.modifyOSDUI.form_controls["OSD Clear Preferences"] = forms.button(ScriptHawk.modifyOSDUI.options_form, "Clear All User Preferences", clearPreferences, ScriptHawk.UI.col(0), ScriptHawk.UI.row(preferenceCount + 5), 200, ScriptHawk.modifyOSDUI.button_height);
	else
		ScriptHawk.modifyOSDUI.form_controls["OSD BizHawk Notice"] = forms.button(ScriptHawk.modifyOSDUI.options_form, "Notice", ScriptHawk.biz222Notice, ScriptHawk.UI.col(0), ScriptHawk.UI.row(preferenceCount + 5), 200, ScriptHawk.modifyOSDUI.button_height);
	end
end

function ScriptHawk.modifyOSDUI.updateReadouts()
	if ScriptHawk.modifyOSDUI.isOpen then
		for OSDType, preference in pairs(defaultPreferences[ScriptHawk.gamePrefName]) do
			local checkboxID = OSDType.."Checkbox";
			if ScriptHawk.modifyOSDUI.ischecked(checkboxID) then
				currentPreferences[ScriptHawk.gamePrefName][OSDType] = true;
				userPreferences[ScriptHawk.gamePrefName][OSDType] = true;
			else
				currentPreferences[ScriptHawk.gamePrefName][OSDType] = false;
				userPreferences[ScriptHawk.gamePrefName][OSDType] = false;
			end
		end
	end
end

--------------------
-- Core functions --
--------------------

if type(Game.drawUI) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.drawUI()");
	end
	function Game.drawUI()
	end
end

if type(Game.eachFrame) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.eachFrame()");
	end
	function Game.eachFrame()
	end
end

if type(Game.realTime) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.realTime()");
	end
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
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.isPhysicsFrame()");
	end
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
	if TASSafe then
		return; -- If we're in TAS mode, don't even bother checking DPad/L inputs
	end

	if ScriptHawk.UI.ischecked("Toggle Infinites Checkbox") then
		Game.applyInfinites();
	end

	if type(Game.maps) == "table" and Game.takeMeThereType == "Checkbox" and ScriptHawk.UI.ischecked("Map Checkbox") then
		Game.setMap(previous_map_value);
	end

	if Game.isPhysicsFrame() then
		joypad_pressed = joypad.getimmediate();
		input_pressed = input.get();

		-- Check for D-Pad and L button pressed
		lbutton_pressed = joypad_pressed[ScriptHawk.lbutton.joypad] or input_pressed[ScriptHawk.lbutton.key];

		dpad_pressed.up = false;
		dpad_pressed.down = false;
		dpad_pressed.left = false;
		dpad_pressed.right = false;

		if ScriptHawk.dpad.joypad.enabled then
			dpad_pressed.up = dpad_pressed.up or joypad_pressed[ScriptHawk.dpad.joypad.up];
			dpad_pressed.down = dpad_pressed.down or joypad_pressed[ScriptHawk.dpad.joypad.down];
			dpad_pressed.left = dpad_pressed.left or joypad_pressed[ScriptHawk.dpad.joypad.left];
			dpad_pressed.right = dpad_pressed.right or joypad_pressed[ScriptHawk.dpad.joypad.right];
		end
		if ScriptHawk.dpad.key.enabled then
			dpad_pressed.up = dpad_pressed.up or input_pressed[ScriptHawk.dpad.key.up];
			dpad_pressed.down = dpad_pressed.down or input_pressed[ScriptHawk.dpad.key.down];
			dpad_pressed.left = dpad_pressed.left or input_pressed[ScriptHawk.dpad.key.left];
			dpad_pressed.right = dpad_pressed.right or input_pressed[ScriptHawk.dpad.key.right];
		end

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

		if ScriptHawk.mode == 'Position' then
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
		elseif ScriptHawk.mode == 'Rotation' then
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
		elseif ScriptHawk.mode == 'YRotation' then
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
	if TASSafe then
		ScriptHawk.override_lag_detection = ScriptHawk.UI.ischecked("Override Lag Detection");
	end

	-- Compensate for overscan (SMS)
	if ScriptHawk.isSMS then
		ScriptHawk.bufferWidth = client.bufferwidth();
		ScriptHawk.bufferHeight = client.bufferheight();
		if ScriptHawk.bufferHeight == 243 then -- NTSC
			ScriptHawk.overscan_compensation.x = 13;
			ScriptHawk.overscan_compensation.y = 27;
		elseif ScriptHawk.bufferHeight == 288 then -- PAL
			ScriptHawk.overscan_compensation.x = 13;
			ScriptHawk.overscan_compensation.y = 48;
		else -- No Overscan
			ScriptHawk.overscan_compensation.x = 0;
			ScriptHawk.overscan_compensation.y = 0;
		end
	end

	ScriptHawk.processKeybinds(ScriptHawk.keybindsFrame);
	ScriptHawk.processJoypadBinds(ScriptHawk.joypadBindsFrame);
	Game.eachFrame();

	previous_frame = current_frame;
	current_frame = emu.framecount();
	local exactlyOneFrameHasPassed = current_frame - previous_frame == 1;

	x = Game.getXPosition();
	y = Game.getYPosition();
	z = Game.getZPosition();

	if not exactlyOneFrameHasPassed then
		prev_x = x;
		prev_y = y;
		prev_z = z;
	end

	if exactlyOneFrameHasPassed then -- TODO: Checkboxes
		if lock_x then
			if x ~= prev_x then
				Game.setXPosition(prev_x);
				x = prev_x;
			end
		end

		if lock_y then
			if (not Game.speedy_invert_Y and y < prev_y) or (Game.speedy_invert_Y and y > prev_y) then
				Game.setYPosition(prev_y);
				y = prev_y;
			end
		end

		if lock_z then
			if z ~= prev_z then
				Game.setZPosition(prev_z);
				z = prev_z;
			end
		end
	end

	local isLagged = not Game.isPhysicsFrame();
	if ScriptHawk.override_lag_detection then
		emu.setislagged(isLagged);
		if tastudio.engaged() then
			tastudio.setlag(current_frame - 1, isLagged);
		end
	end

	if not isLagged or ScriptHawk.update_delta_on_lag then
		if exactlyOneFrameHasPassed then
			dx = x - prev_x;
			dy = y - prev_y;
			dz = z - prev_z;
			d = math.sqrt(dx*dx + dz*dz);

			odometer = odometer + d;
			max_dx = math.max(max_dx, math.abs(dx));
			max_dy = math.max(max_dy, math.abs(dy));
			max_dz = math.max(max_dz, math.abs(dz));
			max_d = math.max(max_d, d);
		else
			dx = 0;
			dy = 0;
			dz = 0;
			max_dx = 0.0;
			max_dy = 0.0;
			max_dz = 0.0;
			max_d = 0.0;
		end

		if ScriptHawk.smooth_moving_angle == true then
			ScriptHawk.movingAngle = ScriptHawk.getMovingAngle();

			prev_x = x;
			prev_y = y;
			prev_z = z;
		end
	end

	if ScriptHawk.smooth_moving_angle == false then
		ScriptHawk.movingAngle = ScriptHawk.getMovingAngle();

		prev_x = x;
		prev_y = y;
		prev_z = z;
	end

	if not client.ispaused() then
		--gui.cleartext();
		--gui.clearGraphics();
		ScriptHawk.UI.updateReadouts();
		ScriptHawk.modifyOSDUI.updateReadouts();
		ScriptHawk.drawHitboxes();
		Game.drawUI();
	end
end

if type(Game.onLoadState) == "function" then
	event.onloadstate(Game.onLoadState, "ScriptHawk - Game.onLoadState");
end
event.onloadstate(plot_pos, "ScriptHawk - Update position on load state");
event.onframeend(mainloop, "ScriptHawk - Controller input handler");
event.onframeend(plot_pos, "ScriptHawk - Update position each frame");

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
	buttonX = 220,
	visible = false,
	form = nil,
	p1xbox = nil,
	p1zbox = nil,
	p2xbox = nil,
	p2zbox = nil,
	anglebox = nil,
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

--------------
-- Hitboxes --
--------------

ScriptHawk.hitboxDefaultDraggable = type(Game.setHitboxPosition) == "function" and not TASSafe;

if type(Game.setHitboxPosition) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.setHitboxPosition(hitbox, x, y)");
	end
	function Game.setHitboxPosition(hitbox, x, y)
		return;
	end
end

if type(Game.getHitboxMouseOverText) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.getHitboxMouseOverText(hitbox)");
	end
	function Game.getHitboxMouseOverText(hitbox)
		return;
	end
end

if type(Game.getHitboxStaticText) ~= "function" then
	if ScriptHawk.warnings then
		print("Warning: This module does not implement Game.getHitboxStaticText(hitbox)");
	end
	function Game.getHitboxStaticText(hitbox)
		return;
	end
end

local mouseClickedLastFrame = false;
local startDragPosition = {0, 0};
local draggedObjects = {};

-- Draw text in emu space, make sure it doesn't disappear off screen
function ScriptHawk.drawText(x, y, text, color, bgcolor, isStatic)
	if type(text) == "boolean" or type(text) == "number" then
		text = tostring(text);
	end
	if type(text) == "string" then
		text = {text};
	end
	if type(text) == "table" then
		local maxLength = -math.huge;
		for t = 1, #text do
			maxLength = math.max(maxLength, string.len(text[t]));
		end
		local safeX = math.max(0, math.min(x, ScriptHawk.bufferWidth - (maxLength * 8)));
		local safeY = math.max(0, math.min(y, ScriptHawk.bufferHeight - (#text * 16)));

		if isStaticText and (safeX ~= x or safeY ~= y) then
			-- Don't render static text that is offscreen
		else
			for t = 1, #text do
				gui.drawText(safeX, safeY + ((t - 1) * 16), text[t], color, bgcolor);
			end
		end
	end
end

function ScriptHawk.drawHitboxes()
	if type(Game.getHitboxes) ~= "function" then
		return;
	end

	local row = 0; -- Text row
	local mouse = input.getmouse(); -- TODO: Can we use mouse_state.current?
	local mouseIsOnScreen = (mouse.X >= 0 and mouse.X < ScriptHawk.bufferWidth) and (mouse.Y >= 0 and mouse.Y < ScriptHawk.bufferHeight);

	-- Compensate for bug causing mouse Y to be higher than it should be with certain scanline settings
	-- TODO: Make this solution general, or just report the bug to BizHawk devs
	-- TODO: Is this different on PAL?
	if ScriptHawk.isNES then
		mouse.Y = mouse.Y + nes.gettopscanline();
	end

	local showHitboxes = ScriptHawk.UI.ischecked("Show Hitboxes Checkbox");
	local enableDraggableHitboxes = ScriptHawk.UI.ischecked("Draggable Hitboxes Checkbox");
	local drawList = ScriptHawk.UI.ischecked("Show List Checkbox");

	-- Draw mouse pixel
	--gui.drawPixel(mouse.X, mouse.Y, colors.red);

	local startDrag = false;
	local dragging = false;
	local dragTransform = {0, 0};

	if enableDraggableHitboxes then
		if mouse.Left then
			if not mouseClickedLastFrame then
				startDrag = true;
				startDragPosition = {mouse.X, mouse.Y};
			end
			mouseClickedLastFrame = true;
			dragging = true;
			dragTransform = {mouse.X - startDragPosition[1], mouse.Y - startDragPosition[2]};
		else
			draggedObjects = {};
			mouseClickedLastFrame = false;
			dragging = false;
		end
	end

	local hitboxes = Game.getHitboxes();

	if ScriptHawk.hitboxListShowCount then
		gui.text(ScriptHawk.hitboxListPosition.x, ScriptHawk.hitboxListPosition.y + Game.OSDRowHeight * row, "Objects: "..#hitboxes, nil, ScriptHawk.hitboxListAnchor);
		row = row + 1;
	end

	for i = 1, #hitboxes do
		local hitbox = hitboxes[i];
		local color = hitbox.color or ScriptHawk.hitboxDefaultColor or colors.white;
		local bgcolor = hitbox.bgcolor or ScriptHawk.hitboxDefaultBGColor or 0x33000000;
		local textcolor = hitbox.textcolor or color;
		local listcolor = hitbox.listcolor or color;
		if type(hitbox.draggable) ~= "boolean" then
			hitbox.draggable = ScriptHawk.hitboxDefaultDraggable;
		end
		local x1 = hitbox.x;
		local y1 = hitbox.y;
		local x2 = x1;
		local y2 = y1;
		hitbox.mode = hitbox.mode or ScriptHawk.hitboxDefaultMode;
		hitbox.width = hitbox.width or ScriptHawk.hitboxDefaultWidth or 0;
		hitbox.height = hitbox.height or ScriptHawk.hitboxDefaultHeight or 0;
		if hitbox.mode == ScriptHawk.hitboxModeWH then
			x2 = x1 + hitbox.width;
			y2 = y1 + hitbox.height;
		elseif hitbox.mode == ScriptHawk.hitboxModeWHCentered then
			x1 = x1 - hitbox.width / 2;
			x2 = x1 + hitbox.width;
			y1 = y1 - hitbox.height / 2;
			y2 = y1 + hitbox.height;
		elseif hitbox.mode == ScriptHawk.hitboxModeX2Y2 then
			x2 = hitbox.x2;
			y2 = hitbox.y2;
			hitbox.width = x2 - x1;
			hitbox.height = y2 - y1;
		end

		local hitboxXOffset = hitbox.xOffset or ScriptHawk.hitboxDefaultXOffset or 0;
		local hitboxYOffset = hitbox.yOffset or ScriptHawk.hitboxDefaultYOffset or 0;
		hitboxXOffset = hitboxXOffset + ScriptHawk.overscan_compensation.x;
		hitboxYOffset = hitboxYOffset + ScriptHawk.overscan_compensation.y;

		x1 = x1 + hitboxXOffset;
		x2 = x2 + hitboxXOffset;
		y1 = y1 + hitboxYOffset;
		y2 = y2 + hitboxYOffset;

		if showHitboxes then
			if mouseIsOnScreen and hitbox.draggable and dragging then
				for dragIndex = 1, #draggedObjects do
					if draggedObjects[dragIndex][1] == hitbox.dragTag then
						hitbox.x = draggedObjects[dragIndex][2] + dragTransform[1];
						hitbox.y = draggedObjects[dragIndex][3] + dragTransform[2];
						Game.setHitboxPosition(hitbox, hitbox.x, hitbox.y);
						break;
					end
				end
			end

			local renderedText;
			local isStaticText = false;
			if mouseIsOnScreen and (mouse.X >= x1 and mouse.X <= x2) and (mouse.Y >= y1 and mouse.Y <= y2) then
				if hitbox.draggable and startDrag then
					table.insert(draggedObjects, {hitbox.dragTag, hitbox.x, hitbox.y});
				end
				renderedText = Game.getHitboxMouseOverText(hitbox);
			else
				renderedText = Game.getHitboxStaticText(hitbox);
				isStaticText = true;
			end

			ScriptHawk.drawText(x1, y1, renderedText, textcolor, bgcolor, isStaticText);
			gui.drawRectangle(x1, y1, hitbox.width, hitbox.height, color);
		end

		if drawList then
			local listString = Game.getHitboxListText(hitbox);
			if type(listString) == "boolean" or type(listString) == "number" then
				listString = tostring(listString);
			end
			if type(listString) == "string" then
				gui.text(ScriptHawk.hitboxListPosition.x, ScriptHawk.hitboxListPosition.y + Game.OSDRowHeight * row, listString, listcolor, ScriptHawk.hitboxListAnchor);
				row = row + 1;
			end
		end
	end
end

if not TASSafe then
	while true do
		if client.ispaused() then
			gui.cleartext();
			--gui.clearGraphics();
			ScriptHawk.UI.updateReadouts();
			ScriptHawk.modifyOSDUI.updateReadouts();
			ScriptHawk.drawHitboxes();
			Game.drawUI();
		end
		ScriptHawk.processKeybinds(ScriptHawk.keybindsRealtime);
		ScriptHawk.processJoypadBinds(ScriptHawk.joypadBindsRealtime);
		ScriptHawk.processMouseBinds(ScriptHawk.mouseBinds);
		Game.realTime();
		emu.yield();
	end
else
	return true;
end