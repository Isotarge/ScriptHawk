local Game = {};

local x_pos = 0;
local y_pos = 0;
local z_pos = 0;

local x_rot = 0;
local facing_angle = 0;
local z_rot = 0;

Game.maps = { "Not Implemented" };

--------------------
-- Region/Version --
--------------------

function Game.detectVersion(romName)
	if stringContains(romName, "Europe") then
		-- TODO
	elseif stringContains(romName, "Japan") then
		-- TODO
	elseif stringContains(romName, "USA") then
		-- TODO
	else
		return false;
	end

	return true;
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 };
Game.speedy_index = 7;

Game.rot_speed = 10;
Game.max_rot_units = 360;

function Game.isPhysicsFrame()
	return not emu.islagged();
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(x_pos, true);
end

function Game.getYPosition()
	return mainmemory.readfloat(y_pos, true);
end

function Game.getZPosition()
	return mainmemory.readfloat(z_pos, true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(x_pos, value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(y_pos, value, true);
end

function Game.setZPosition(value)
	mainmemory.writefloat(z_pos, value, true);
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	-- TODO
	return 0;
end

function Game.getYRotation()
	-- TODO
	return 0;
end

function Game.getZRotation()
	-- TODO
	return 0;
end

function Game.setXRotation(value)
	-- TODO
end

function Game.setYRotation(value)
	-- TODO
end

function Game.setZRotation(value)
	-- TODO
end

------------
-- Events --
------------

function Game.setMap(value)
	-- TODO
end

function Game.applyInfinites()
	-- TODO
end

local labelValue = 0;
function Game.initUI()
	-- TODO
	ScriptHawkUI.form_controls["Example Dropdown"] = forms.dropdown(ScriptHawkUI.options_form, {"Option 1", "Option 2", "Option 3"}, ScriptHawkUI.col(0) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(7) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.col(9) + 7, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Example Button"] = forms.button(ScriptHawkUI.options_form, "Label", flagSetButtonHandler, ScriptHawkUI.col(10), ScriptHawkUI.row(7), 59, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Example Plus Button"] = forms.button(ScriptHawkUI.options_form, "-", function() labelValue = labelValue + 1 end, ScriptHawkUI.col(13) - 7, ScriptHawkUI.row(6), ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Example Minus Button"] = forms.button(ScriptHawkUI.options_form, "+", function() labelValue = labelValue - 1 end, ScriptHawkUI.col(13) + ScriptHawkUI.button_height - 7, ScriptHawkUI.row(6),ScriptHawkUI.button_height, ScriptHawkUI.button_height);
	ScriptHawkUI.form_controls["Example Value Label"] = forms.label(ScriptHawkUI.options_form, "0", ScriptHawkUI.col(13) + ScriptHawkUI.button_height + 21, ScriptHawkUI.row(6) + ScriptHawkUI.label_offset, 54, 14);
	ScriptHawkUI.form_controls["Example Checkbox"] = forms.checkbox(ScriptHawkUI.options_form, "Label", ScriptHawkUI.col(10) + ScriptHawkUI.dropdown_offset, ScriptHawkUI.row(6) + ScriptHawkUI.dropdown_offset);
end

function Game.eachFrame()
	-- TODO
	forms.settext(ScriptHawkUI.form_controls["Example Value Label"], labelValue);
end

Game.OSDPosition = {2, 70}
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

return Game;