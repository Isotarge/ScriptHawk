local Game = {};

local player_object_pointer = 0x3FFFC0; -- TODO: Does this work for all versions?

local x_pos = 0x0C;
local y_pos = 0x10;
local z_pos = 0x14;

local y_velocity = 0xC0;
local velocity = 0xC4;

local camera_zoom = 0x12C;

local x_rot = 0x238; -- TODO
local facing_angle = 0x238;
local y_rot = facing_angle;
local z_rot = 0x238; -- TODO

local map_freeze_values = {};

Game.maps = { 
	"0x00 - Overworld",
	"0x01 - Bluey 1",
	"0x02 - Dragon Forest (Hub)",
	"0x03 - Fossil Canyon",
	"0x04 - Pirate Lagoon",
	"0x05 - Ancient lake",
	"0x06 - Walrus Cove",
	"0x07 - Hot Top Volcano",
	"0x08 - Whale Bay",
	"0x09 - Snowball Valley",
	"0x0A - Crescent Island",
	"0x0B - Fire Mountain",
	"0x0C - Dino Domain (Hub)",
	"0x0D - Everfrost Peak",
	"0x0E - Sherbert Island (Hub)",
	"0x0F - Spaceport Alpha",
	
	"0x10 - Horseshoe Gulch (Unused)",
	"0x11 - Spacedust Alley",
	"0x12 - Greenwood Village",
	"0x13 - Boulder Canyon",
	"0x14 - Windmill Plains",
	"0x15 - Intro",
	"0x16 - Character Select",
	"0x17 - Title Screen",
	"0x18 - Snowflake Mountain",
	"0x19 - Smokey Castle",
	"0x1A - Darkwater Beach",
	"0x1B - Icicle Pyramid",
	"0x1C - Frosty Village",
	"0x1D - Jungle Falls",
	"0x1E - Treasure Caves",
	"0x1F - Haunted Woods",
	
	"0x20 - Darkmoon Caverns",
	"0x21 - Star City",
	"0x22 - Trophy Race Results Screen",
	"0x23 - Future Fun Land (Hub)",
	"0x24 - Overworld (Opening Cutscene)",
	"0x25 - Wizpig 1",
	"0x26 - Dino 1",
	"0x27 - Menu Screen",
	"0x28 - Bubbler 1",
	"0x29 - Smokey 1",
	"0x2A - Overworld (Wizpig 1 opening cutscene)",
	"0x2B - Wizpig amulet cutscene",
	"0x2C - TT amulet cutscene",
	"0x2D - Overworld (FFL opening cutscene)",
	"0x2E - Dino 2",
	"0x2F - Toufool",
	
	"0x30 - Snoufool",
	"0x31 - Toufool again",
	"0x32 - Toufool again again",
	"0x33 - Toufool in space",
	"0x34 - Bluey 2",
	"0x35 - Bubbler 2",
	"0x36 - Smokey 2",
	"0x37 - Wizpig 2",
	"0x38 - Overworld (Fake credits)",
	"0x39 - Tricky's map (cutscene version)",
	"0x3A - Smokey's map (cutscene version)",
	"0x3B - Bluey's map (cutscene version)",
	"0x3C - Wizpig 1 cutscene",
	"0x3D - Bubbler's map (cutscene version)",
	"0x3E - Wizpig 2 cutscene",
	"0x3F - Overworld (Credits 1)",
	
	"0x40 - Overworld (Credits 2)",
	"0x41 - Overworld (misc cutscene 1)",
	"0x42 - Overworld (misc cutscene 2)",
	"0x43 - Overworld (misc cutscene 3)",
	"0x44 - Overworld (misc cutscene 4)",
	"0x45 - Overworld (misc cutscene 5)",
	"0x46 - ...",
	"0x47 - ...",
	"0x48 - ...",
	"0x49 - ...",
	"0x4A - ...",
	"0x4B - ...",
	"0x4C - ...",
	"0x4D - ",
	"0x4E - ",
	"0x4F - ",
	
	"0x50 - ",
	"0x51 - ",
	"0x52 - ",
	"0x53 - ",
	"0x54 - ",
	"0x55 - ",
	"0x56 - ",
	"0x57 - ",
	"0x58 - ",
	"0x59 - ",
	"0x5A - ",
	"0x5B - ",
	"0x5C - ",
	"0x5D - ",
	"0x5E - ",
	"0x5F - ",
};

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if bizstring.contains(romName, "Europe") then
		-- TODO
	elseif bizstring.contains(romName, "Japan") then
		player_object_pointer = 0x3FFFC0;
		map_freeze_values = {
			0x11C91B, 0x122BD7, 0x122CC2, 0x124F67, 0x1FD4A5, 0x1FD52B, 0x1FE729
		};
	elseif bizstring.contains(romName, "USA") then
		-- TODO
	else
		return false;
	end

	return true;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { -.001, -.01, -.1, -1, -5, -10, -20, -50, -100 };
Game.speedy_index = 7;

Game.rot_speed = 100;
Game.max_rot_units = 65535;

function Game.isPhysicsFrame()
	return not emu.islagged();
end

function Game.getVelocity()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.readfloat(player_object + velocity, true);
end

--------------
-- Position --
--------------

function Game.getXPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.readfloat(player_object + x_pos, true);
end

function Game.getYPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.readfloat(player_object + y_pos, true);
end

function Game.getZPosition()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.readfloat(player_object + z_pos, true);
end

function Game.setXPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	mainmemory.writefloat(player_object + x_pos, value, true);
end

function Game.setYPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	mainmemory.writefloat(player_object + y_velocity, 0, true);
	mainmemory.writefloat(player_object + y_pos, value, true);
end

function Game.setZPosition(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	mainmemory.writefloat(player_object + z_pos, value, true);
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.read_u16_be(player_object + facing_angle); -- TODO
end

function Game.getYRotation()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.read_u16_be(player_object + facing_angle);
end

function Game.getZRotation()
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.read_u16_be(player_object + facing_angle); -- TODO
end

function Game.setXRotation(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.write_u16_be(player_object + facing_angle, value);
end

function Game.setYRotation(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.write_u16_be(player_object + facing_angle, value);
end

function Game.setZRotation(value)
	local player_object = mainmemory.read_u32_be(player_object_pointer) - 0x80000000;
	return mainmemory.write_u16_be(player_object + facing_angle, value);
end

-----------------------------
-- Optimal tapping script  --
-- Written by Faschz, 2015 --
-----------------------------

local otap_checkbox;
local otap_enabled = false;

local otap_startFrame = emu.framecount();
local otap_startLag = emu.lagcount();

-- Numbers optimized for TT with 0 bananas
local velocity_min = -9.212730408;
local velocity_med = -12.34942532;
local velocity_max = -14.22209072;

local function enableOptimalTap()
	local otap_startFrame = emu.framecount();
	local otap_startLag = emu.lagcount();
	otap_enabled = true;
	console.log("Auto tapper (by Faschz) enabled.");
end

local function disableOptimalTap()
	otap_enabled = false;
	console.log("Auto tapper disabled.");
end

local function optimalTap()
	local _velocity = Game.getVelocity();
	local frame = emu.framecount();

	if _velocity >= velocity_min then
		joypad.set({["A"] = true}, 1);
	elseif _velocity >= velocity_med and _velocity < velocity_min then
		if (frame - (otap_startFrame + (emu.lagcount() - otap_startLag))) % 2 == 0 then
			joypad.set({["A"] = true}, 1);
		else
			joypad.set({["A"] = false}, 1);
		end
	elseif _velocity >= velocity_max and _velocity < velocity_med then
		if (frame - (otap_startFrame + (emu.lagcount() - otap_startLag))) % 3 == 0 then
			joypad.set({["A"] = true}, 1);
		else
			joypad.set({["A"] = false}, 1);
		end
	elseif _velocity < velocity_max then
		if (frame - (otap_startFrame + (emu.lagcount() - otap_startLag))) % 4 == 0 then
			joypad.set({["A"] = true}, 1);
		else
			joypad.set({["A"] = false}, 1);
		end
	end
end

------------
-- Events --
------------

function Game.setMap(value)
	local i;
	value = value - 1;
	for i=1,#map_freeze_values do
		mainmemory.writebyte(map_freeze_values[i], value);
	end
end

function Game.applyInfinites()
	-- TODO
end

function Game.initUI(form_handle, col, row, button_height, label_offset, dropdown_offset)
	otap_checkbox = forms.checkbox(form_handle, "Auto tapper", col(0) + dropdown_offset, row(6) + dropdown_offset);
end

function Game.eachFrame()
	if not otap_enabled and forms.ischecked(otap_checkbox) then
		enableOptimalTap();
	end

	if otap_enabled and not forms.ischecked(otap_checkbox) then
		disableOptimalTap();
	end

	if otap_enabled then
		optimalTap();
	end
end

return Game;