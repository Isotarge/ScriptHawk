local maxResolution = 250;
local resolution = 60;
local ignore = 30;
local maxRedzone = 100;
local redzone = 5;

local minHeight = 16;
local maxHeight = 128;
local height = 60;

local minWidth = 16;
local maxWidth = 128;
local width = 16;

local frameCount = 0;
local lagCount = 0;

local maxTrackedPeriods = 50;
local trackedPeriods = 10;
local previous = {};

function null_check (value)
	return value ~= nil and (value > 0) ~= (value <= 0);
end

function shufflePrevious()
	temp = {};
	for i=2,#previous do
		temp[i - 1] = previous[i];
	end
	previous = temp;
end

function getHighestLagCount()
	highest = 0;
	for i=1,#previous do
		highest = math.max(highest, previous[i].lag);
	end
	return highest;
end

function recalculateRatios()
	for i=1,#previous do
		if previous[i].mode == "vframe" then
			previous[i].ratio = math.min(1, math.max(0, previous[i].lag - 1) / math.max(1, redzone));
		end
	end
end

function round (num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", (num or 0)));
end

--       a  r  g  b
-- 0.0 = 7F 00 FF 00 = Green
-- 0.5 = 7F FF FF 00 = Yellow
-- 1.0 = 7F FF 00 00 = Red

function getColour(ratio)
	if ratio > 0.5 then
		green = 255 - round(((ratio - 0.5) * 2) * 255);
		red = 255;
	elseif ratio < 0.5 then
		red = round((ratio * 2) * 255);
		green = 255;
	else
		red = 255;
		green = 255;
	end

	return 0x7f000000 + (red * 0x00010000) + (green * 0x00000100);
end

-------------------
-- GUI Callbacks --
-------------------

function increaseResolution()
	resolution = math.min(maxResolution, resolution + 1);
	updateUIReadouts_lagometer();
end

function decreaseResolution()
	resolution = math.max(1, resolution - 1);
	ignore = math.min(resolution, ignore);
	updateUIReadouts_lagometer();
end

function increaseIgnore()
	ignore = math.min(resolution, ignore + 1);
	updateUIReadouts_lagometer();
end

function decreaseIgnore()
	ignore = math.max(0, ignore - 1);
	updateUIReadouts_lagometer();
end

function increaseRedzone()
	redzone = math.min(maxRedzone, redzone + 1);
	updateUIReadouts_lagometer();
end

function decreaseRedzone()
	redzone = math.max(1, redzone - 1);
	updateUIReadouts_lagometer();
end

function increaseWidth()
	width = math.min(maxWidth, width + 1);
	updateUIReadouts_lagometer();
end

function decreaseWidth()
	width = math.max(minWidth, width - 1);
	updateUIReadouts_lagometer();
end

function increaseHeight()
	height = math.min(maxHeight, height + 1);
	updateUIReadouts_lagometer();
end

function decreaseHeight()
	height = math.max(minHeight, height - 1);
	updateUIReadouts_lagometer();
end

function increaseTrackedPeriods()
	trackedPeriods = math.min(maxTrackedPeriods, trackedPeriods + 1);
	updateUIReadouts_lagometer();
end

function decreaseTrackedPeriods()
	trackedPeriods = math.max(0, trackedPeriods - 1);
	while #previous > trackedPeriods do
		shufflePrevious();
	end
	updateUIReadouts_lagometer();
end

--------------
-- GUI Code --
--------------

local form_padding = 8;
local label_offset = 4;
local long_label_width = 140;
local button_height = 24;
local label_width = 64;

function row (row_num)
	return round(form_padding + button_height * row_num, 0);
end

function col (col_num)
	return row(col_num);
end

local options_form = forms.newform(col(10), row(11), "Lagometer");

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--    Handle                                    Type                       Caption             Callback                X position   Y position             Width             Height --
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local options_resolution_label =                forms.label(options_form,  "Resolution:",                              col(0),      row(0) + label_offset, label_width,      14);
local options_decrease_resolution_button =      forms.button(options_form, "-",                decreaseResolution,     col(4) - 32, row(0),                button_height,    button_height);
local options_increase_resolution_button =      forms.button(options_form, "+",                increaseResolution,     col(5) - 32, row(0),                button_height,    button_height);
local options_resolution_value_label =          forms.label(options_form,  resolution,                                 col(5),      row(0) + label_offset, label_width,      14);

local options_ignore_label =                    forms.label(options_form,  "Ignore:",                                  col(0),      row(1) + label_offset, label_width,      14);
local options_decrease_ignore_button =          forms.button(options_form, "-",                decreaseIgnore,         col(4) - 32, row(1),                button_height,    button_height);
local options_increase_ignore_button =          forms.button(options_form, "+",                increaseIgnore,         col(5) - 32, row(1),                button_height,    button_height);
local options_ignore_value_label =              forms.label(options_form,  ignore,                                     col(5),      row(1) + label_offset, label_width,      14);

local options_tracked_periods_label =           forms.label(options_form,  "Tracked Periods:",                         col(0),      row(2) + label_offset, label_width,      14);
local options_decrease_tracked_periods_button = forms.button(options_form, "-",                decreaseTrackedPeriods, col(4) - 32, row(2),                button_height,    button_height);
local options_increase_tracked_periods_button = forms.button(options_form, "+",                increaseTrackedPeriods, col(5) - 32, row(2),                button_height,    button_height);
local options_tracked_periods_value_label =     forms.label(options_form,  trackedPeriods,                             col(5),      row(2) + label_offset, label_width,      14);

local options_redzone_label =                   forms.label(options_form,  "Redzone:",                                 col(0),      row(3) + label_offset, label_width,      14);
local options_decrease_redzone_button =         forms.button(options_form, "-",                decreaseRedzone,        col(4) - 32, row(3),                button_height,    button_height);
local options_increase_redzone_button =         forms.button(options_form, "+",                increaseRedzone,        col(5) - 32, row(3),                button_height,    button_height);
local options_redzone_value_label =             forms.label(options_form,  redzone,                                    col(5),      row(3) + label_offset, label_width,      14);

local options_width_label =                     forms.label(options_form,  "Width:",                                   col(0),      row(4) + label_offset, label_width,      14);
local options_decrease_width_button =           forms.button(options_form, "-",                decreaseWidth,          col(4) - 32, row(4),                button_height,    button_height);
local options_increase_width_button =           forms.button(options_form, "+",                increaseWidth,          col(5) - 32, row(4),                button_height,    button_height);
local options_width_value_label =               forms.label(options_form,  width,                                      col(5),      row(4) + label_offset, label_width,      14);

local options_height_label =                    forms.label(options_form,  "Height:",                                  col(0),      row(5) + label_offset, label_width,      14);
local options_decrease_height_button =          forms.button(options_form, "-",                decreaseHeight,         col(4) - 32, row(5),                button_height,    button_height);
local options_increase_height_button =          forms.button(options_form, "+",                increaseHeight,         col(5) - 32, row(5),                button_height,    button_height);
local options_height_value_label =              forms.label(options_form,  height,                                     col(5),      row(5) + label_offset, label_width,      14);

local options_toggle_vframe_mode =              forms.checkbox(options_form, "VFrame mode",                            col(0),      row(6));

function updateUIReadouts_lagometer()
	forms.settext(options_resolution_value_label, resolution);
	forms.settext(options_ignore_value_label, ignore);
	forms.settext(options_redzone_value_label, redzone);
	forms.settext(options_width_value_label, width);
	forms.settext(options_height_value_label, height);
	forms.settext(options_tracked_periods_value_label, trackedPeriods);
end

local function drawGraphicalRepresentation()
	gui_x = 8;
	gui_y = 8;
	column = 0;

	for i=#previous,1,-1 do
		if previous[i].mode == "vframe" then
			gui.drawText(gui_x + width * column, gui_y, previous[i].lag - 1);
		else
			gui.drawText(gui_x + width * column, gui_y, previous[i].lag - ignore);
		end
		if null_check(previous[i].dxz) then
			if null_check(precision) then
				gui.drawText(gui_x + width * column, gui_y + 16, round(previous[i].dxz, precision));
			else
				gui.drawText(gui_x + width * column, gui_y + 16, round(previous[i].dxz));
			end
		end
		gui.drawRectangle(gui_x + width * column, gui_y + height - (height * previous[i].ratio) + 32, width, height * previous[i].ratio, 0, getColour(previous[i].ratio));
		column = column + 1;
	end

	updateUIReadouts_lagometer();
end

local function mainloop()
	if forms.ischecked(options_toggle_vframe_mode) then
		if emu.islagged() then
			lagCount = lagCount + 1;
		else
			ratio = math.min(1, math.max(0, lagCount - 1) / math.max(1, redzone));
			table.insert(previous, {['lag']=lagCount, ['ratio']=ratio, ['mode']="vframe"});
			if null_check(d) then
				previous[#previous].dxz = d;
			end
			if #previous > trackedPeriods then
				shufflePrevious();
				recalculateRatios();
			end
			lagCount = 0;
			frameCount = 0;
		end
	else
		if emu.islagged() then
			lagCount = lagCount + 1;
		end
		frameCount = frameCount + 1;

		if frameCount >= resolution then
			ratio = (lagCount - ignore) / (frameCount - ignore);
			table.insert(previous, {['lag']=lagCount, ['frames']=frameCount, ['ratio']=ratio, ['mode']="normal"});
			if null_check(d) then
				previous[#previous].dxz = d;
			end
			if #previous > trackedPeriods then
				shufflePrevious();
			end
			lagCount = 0;
			frameCount = 0;
		end
	end

	drawGraphicalRepresentation();
end

event.onframestart(mainloop, "Lagometer");