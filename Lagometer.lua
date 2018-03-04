require "lib.LibScriptHawk";

local Lagometer = {
	UI = {},
	Settings = {
		resolution = {
			value = 60,
			min = 1,
			max = 250,
		},
		ignore = {
			value = 30,
			min = 0,
			max = 60,
		},
		redzone = {
			value = 5,
			min = 1,
			max = 100,
		},
		height = {
			value = 60,
			min = 16,
			max = 128,
		},
		width = {
			value = 16,
			min = 16,
			max = 128,
		},
		trackedPeriods = {
			value = 10,
			min = 1,
			max = 50,
		},
	},
};

local function getSetting(value)
	return Lagometer.Settings[value].value;
end

local frameCount = 0;
local lagCount = 0;
local previous = {};

local function shufflePrevious()
	table.remove(previous, 1);
end

local function getHighestLagCount()
	local highest = 0;
	for i = 1, #previous do
		highest = math.max(highest, previous[i].lag);
	end
	return highest;
end

local function getAverageLag()
	local sum = 0;
	for i = 1, #previous do
		sum = sum + previous[i].lag;
	end
	return sum / #previous;
end

local function recalculateRatios()
	for i = 1, #previous do
		if previous[i].mode == "vframe" then
			previous[i].ratio = math.min(1, math.max(0, previous[i].lag - 1) / math.max(1, getSetting("redzone")));
		end
	end
end

Lagometer.UI.update = function()
	forms.settext(Lagometer.UI.resolution_value_label, getSetting("resolution"));
	forms.settext(Lagometer.UI.ignore_value_label, getSetting("ignore"));
	forms.settext(Lagometer.UI.redzone_value_label, getSetting("redzone"));
	forms.settext(Lagometer.UI.width_value_label, getSetting("width"));
	forms.settext(Lagometer.UI.height_value_label, getSetting("height"));
	forms.settext(Lagometer.UI.tracked_periods_value_label, getSetting("trackedPeriods"));
	forms.settext(Lagometer.UI.average_lag_label, getAverageLag());
end

-------------------
-- GUI Callbacks --
-------------------

local function increaseSetting(value)
	Lagometer.Settings[value].value = math.min(Lagometer.Settings[value].max, getSetting(value) + 1);
	Lagometer.UI.update();
end

local function decreaseSetting(value)
	Lagometer.Settings[value].value = math.max(Lagometer.Settings[value].min, getSetting(value) - 1);
	Lagometer.UI.update();
end

local function decreaseResolution()
	Lagometer.Settings.resolution.value = math.max(1, getSetting("resolution") - 1);
	Lagometer.Settings.ignore.value = math.min(getSetting("resolution"), getSetting("ignore"));
	Lagometer.UI.update();
end

local function increaseIgnore()
	Lagometer.Settings.ignore.value = math.min(getSetting("resolution"), getSetting("ignore") + 1);
	Lagometer.UI.update();
end

local function decreaseTrackedPeriods()
	decreaseSetting("trackedPeriods");
	while #previous > getSetting("trackedPeriods") do
		shufflePrevious();
	end
end

--------------
-- GUI Code --
--------------

local form_padding = 8;
local label_offset = 4;
local button_height = 24;
local label_width = 64;

local function row(row_num)
	return round(form_padding + button_height * row_num, 0);
end

local function col(col_num)
	return row(col_num);
end

Lagometer.UI.form = forms.newform(col(10), row(11), "Lagometer");

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--           Handle                                  Type                     Caption             Callback                X position   Y position             Width             Height --
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Lagometer.UI.resolution_label =                forms.label(Lagometer.UI.form, "Resolution:",                              col(0),      row(0) + label_offset, label_width,      14);
Lagometer.UI.decrease_resolution_button =      forms.button(Lagometer.UI.form,"-",                decreaseResolution,     col(4) - 32, row(0),                button_height,    button_height);
Lagometer.UI.increase_resolution_button =      forms.button(Lagometer.UI.form,"+",     function() increaseSetting("resolution") end, col(5) - 32, row(0),     button_height,    button_height);
Lagometer.UI.resolution_value_label =          forms.label(Lagometer.UI.form, getSetting("resolution"),                   col(5),      row(0) + label_offset, label_width,      14);

Lagometer.UI.ignore_label =                    forms.label(Lagometer.UI.form, "Ignore:",                                  col(0),      row(1) + label_offset, label_width,      14);
Lagometer.UI.decrease_ignore_button =          forms.button(Lagometer.UI.form,"-",     function() decreaseSetting("ignore") end, col(4) - 32, row(1),         button_height,    button_height);
Lagometer.UI.increase_ignore_button =          forms.button(Lagometer.UI.form,"+",                increaseIgnore,         col(5) - 32, row(1),                button_height,    button_height);
Lagometer.UI.ignore_value_label =              forms.label(Lagometer.UI.form, getSetting("ignore"),                       col(5),      row(1) + label_offset, label_width,      14);

Lagometer.UI.tracked_periods_label =           forms.label(Lagometer.UI.form, "Tracked Periods:",                         col(0),      row(2) + label_offset, label_width,      14);
Lagometer.UI.decrease_tracked_periods_button = forms.button(Lagometer.UI.form,"-",                decreaseTrackedPeriods, col(4) - 32, row(2),                button_height,    button_height);
Lagometer.UI.increase_tracked_periods_button = forms.button(Lagometer.UI.form,"+",     function() increaseSetting("trackedPeriods") end, col(5) - 32, row(2), button_height,    button_height);
Lagometer.UI.tracked_periods_value_label =     forms.label(Lagometer.UI.form, getSetting("trackedPeriods"),               col(5),      row(2) + label_offset, label_width,      14);

Lagometer.UI.redzone_label =                   forms.label(Lagometer.UI.form, "Redzone:",                                 col(0),      row(3) + label_offset, label_width,      14);
Lagometer.UI.decrease_redzone_button =         forms.button(Lagometer.UI.form,"-",     function() decreaseSetting("redzone") end, col(4) - 32, row(3),        button_height,    button_height);
Lagometer.UI.increase_redzone_button =         forms.button(Lagometer.UI.form,"+",     function() increaseSetting("redzone") end, col(5) - 32, row(3),        button_height,    button_height);
Lagometer.UI.redzone_value_label =             forms.label(Lagometer.UI.form, getSetting("redzone"),                      col(5),      row(3) + label_offset, label_width,      14);

Lagometer.UI.width_label =                     forms.label(Lagometer.UI.form, "Width:",                                   col(0),      row(4) + label_offset, label_width,      14);
Lagometer.UI.decrease_width_button =           forms.button(Lagometer.UI.form,"-",     function() decreaseSetting("width") end, col(4) - 32, row(4),          button_height,    button_height);
Lagometer.UI.increase_width_button =           forms.button(Lagometer.UI.form,"+",     function() increaseSetting("width") end, col(5) - 32, row(4),          button_height,    button_height);
Lagometer.UI.width_value_label =               forms.label(Lagometer.UI.form, getSetting("width"),                        col(5),      row(4) + label_offset, label_width,      14);

Lagometer.UI.height_label =                    forms.label(Lagometer.UI.form, "Height:",                                  col(0),      row(5) + label_offset, label_width,      14);
Lagometer.UI.decrease_height_button =          forms.button(Lagometer.UI.form,"-",     function() decreaseSetting("height") end, col(4) - 32, row(5),         button_height,    button_height);
Lagometer.UI.increase_height_button =          forms.button(Lagometer.UI.form,"+",     function() increaseSetting("height") end, col(5) - 32, row(5),         button_height,    button_height);
Lagometer.UI.height_value_label =              forms.label(Lagometer.UI.form, getSetting("height"),                       col(5),      row(5) + label_offset, label_width,      14);

Lagometer.UI.toggle_vframe_mode =              forms.checkbox(Lagometer.UI.form,"VFrame mode",                            col(0),      row(6));

Lagometer.UI.average_lag_label =               forms.label(Lagometer.UI.form, getSetting("height"),                       col(0),      row(7) + label_offset, label_width,      14);

local function drawGraphicalRepresentation()
	local gui_x = 8;
	local gui_y = 8;
	local column = 0;

	for i = #previous, 1, -1 do
		if previous[i].mode == "vframe" then
			gui.drawText(gui_x + getSetting("width") * column, gui_y, previous[i].lag - 1);
		else
			gui.drawText(gui_x + getSetting("width") * column, gui_y, previous[i].lag - getSetting("ignore"));
		end
		if type(previous[i].dxz) ~= "nil" then
			if type(precision) ~= "nil" then
				gui.drawText(gui_x + getSetting("width") * column, gui_y + 16, round(previous[i].dxz, precision));
			else
				gui.drawText(gui_x + getSetting("width") * column, gui_y + 16, round(previous[i].dxz));
			end
		end
		gui.drawRectangle(gui_x + getSetting("width") * column, gui_y + getSetting("height") - (getSetting("height") * previous[i].ratio) + 32, getSetting("width"), getSetting("height") * previous[i].ratio, 0, getColour(previous[i].ratio, 0x7F));
		column = column + 1;
	end

	Lagometer.UI.update();
end

local function islagged()
	if type(Game) == "table" and type(Game.isPhysicsFrame) == "function" then
		return not Game.isPhysicsFrame();
	end
	return emu.islagged();
end

local function mainloop()
	if forms.ischecked(Lagometer.UI.toggle_vframe_mode) then
		if islagged() then
			lagCount = lagCount + 1;
		else
			local ratio = math.min(1, math.max(0, lagCount - 1) / math.max(1, getSetting("redzone")));
			table.insert(previous, {lag = lagCount, ratio = ratio, mode = "vframe"});
			if #previous > getSetting("trackedPeriods") then
				shufflePrevious();
				recalculateRatios();
			end
			lagCount = 0;
			frameCount = 0;
		end
	else
		if islagged() then
			lagCount = lagCount + 1;
		end
		frameCount = frameCount + 1;

		if frameCount >= getSetting("resolution") then
			local ratio = (lagCount - getSetting("ignore")) / (frameCount - getSetting("ignore"));
			table.insert(previous, {lag = lagCount, frames = frameCount, ratio = ratio, mode = "normal"});
			if #previous > getSetting("trackedPeriods") then
				shufflePrevious();
			end
			lagCount = 0;
			frameCount = 0;
		end
	end

	drawGraphicalRepresentation();
end

local function clearPrevious()
	lagCount = 0;
	frameCount = 0;
	previous = {};
end

event.onframestart(mainloop, "ScriptHawk - Lagometer");
event.onloadstate(clearPrevious, "ScriptHawk - Clear Lag History");