-- DK64 - Mad Jack Minimap
-- Written by Isotarge, 2014

-- Make some shorthand versions of BizHawk's memory functions
mrb = mainmemory.readbyte;
mwb = mainmemory.write_u8;
mru24 = mainmemory.read_u24_be;
mrf = mainmemory.readfloat;
mwf = mainmemory.writefloat;

MJ_state_pointer = 0x7fdc91;
script_root = "Lua/ScriptHawk";

-- Mad Jack state
MJ_time_until_next_action = 0x2d;
MJ_actions_remaining      = 0x58;
MJ_action_type            = 0x59;
MJ_current_pos            = 0x60;
MJ_next_pos               = 0x61;
MJ_white_switch_pos       = 0x64;
MJ_blue_switch_pos        = 0x65;

-- Colors
MJ_blue         = 0x7f00a2e8;
MJ_blue_switch  = 0xff00a2e8;
MJ_white        = 0x7fffffff;
MJ_white_switch = 0xffffffff;

-- Minimap ui
MJ_minimap_x_offset  = 19;
MJ_minimap_y_offset  = 19;
MJ_minimap_width     = 16;
MJ_minimap_height    = 16;

MJ_minimap_text_x = MJ_minimap_x_offset + 4.5 * MJ_minimap_width;
MJ_minimap_text_y = MJ_minimap_y_offset;

MJ_minimap_phase_number_y      = MJ_minimap_text_y;
MJ_minimap_actions_remaining_y = MJ_minimap_phase_number_y      + MJ_minimap_height;
MJ_time_until_next_action_y    = MJ_minimap_actions_remaining_y + MJ_minimap_height;

MJ_kong_row_y                  = MJ_time_until_next_action_y + MJ_minimap_height;
MJ_kong_col_y                  = MJ_kong_row_y + MJ_minimap_height;

function round (x)
	return x + 0.5 - (x + 0.5) % 1;
end

-- Position stuff
kong_model_pointer = 0x7fbb4d;

-- Relative to kong model
x_pos = 0x7c;
z_pos = 0x84;

function position_to_rowcol (pos)
	if pos < 450 then
		return 0;
	elseif pos < 570 then
		return 1;
	elseif pos < 690 then
		return 2;
	elseif pos < 810 then
		return 3;
	elseif pos < 930 then
		return 4;
	elseif pos < 1050 then
		return 5;
	elseif pos < 1170 then
		return 6;
	end
	return 7;
end

function get_kong_position ()
	kong_model = mainmemory.read_u24_be(kong_model_pointer);

	x = mainmemory.readfloat(kong_model + x_pos, true);
	z = mainmemory.readfloat(kong_model + z_pos, true);

	colseg = position_to_rowcol(z);
	rowseg = position_to_rowcol(x);

	col = math.floor(colseg / 2);
	row = math.floor(rowseg / 2);

	return {
		["x"] = x, ["z"] = z,
		["col"] = col, ["row"] = row,
		["col_seg"] = colseg, ["row_seg"] = rowseg
	};
end

function MJ_get_col_mask (position)
	return bit.band(position, 0x03);
end

function MJ_get_row_mask (position)
	return bit.rshift(bit.band(position, 0x0C), 2);
end

function MJ_get_switch_active_mask (position)
	return bit.rshift(bit.band(position, 0x10), 4) > 0;
end

function MJ_get_color (col, row)
	local color = 'blue';
	if row % 2 == col % 2 then
		color = 'white';
	end
	return color;
end

function MJ_get_action_type (phase_byte)
	if phase_byte == 0x08 or phase_byte == 0x0a or phase_byte == 0x0b or phase_byte == 0x0c or phase_byte == 0x0e then
		return "Jump";
	elseif phase_byte == 0x01 or phase_byte == 0x05 then
		return "Laser";
	elseif phase_byte == 0x28 or phase_byte == 0x2d or phase_byte == 0x32 then
		return "Fireball";
	end
	return "Jump";
end

function MJ_get_phase (phase_byte)
	if phase_byte == 0x08 or phase_byte == 0x32 then
		return 1;
	elseif phase_byte == 0x0a or phase_byte == 0x2d then
		return 2;
	elseif phase_byte == 0x0b or phase_byte == 0x28 then
		return 3;
	elseif phase_byte == 0x0c or phase_byte == 0x05 then
		return 4;
	elseif phase_byte == 0x0e or phase_byte == 0x01 then
		return 5;
	end
	return 0;
end

function MJ_get_arrow_image (current, new)
	if new.row > current.row then
		if new.col > current.col then
			return script_root.."/Images/up_right.png";
		elseif new.col == current.col then
			return script_root.."/Images/up.png";
		elseif new.col < current.col then
			return script_root.."/Images/up_left.png";
		end
	elseif new.row == current.row then
		if new.col > current.col then
			return script_root.."/Images/right.png";
		elseif new.col < current.col then
			return script_root.."/Images/left.png";
		end
	elseif new.row < current.row then
		if new.col > current.col then
			return script_root.."/Images/down_right.png";
		elseif new.col == current.col then
			return script_root.."/Images/down.png";
		elseif new.col < current.col then
			return script_root.."/Images/down_left.png";
		end
	end
	return script_root.."/Images/question-mark.png";
end

function MJ_parse_position (position)
	return {
		["active"] = MJ_get_switch_active_mask(position),
		["col"] = MJ_get_col_mask(position),
		["row"] = MJ_get_row_mask(position),
	};
end

function draw_mj_minimap ()
	local MJ_state  = mru24(MJ_state_pointer);

	local cur_pos   = MJ_parse_position(mrb(MJ_state + MJ_current_pos));
	local next_pos  = MJ_parse_position(mrb(MJ_state + MJ_next_pos));

	local white_pos = MJ_parse_position(mrb(MJ_state + MJ_white_switch_pos));
	local blue_pos  = MJ_parse_position(mrb(MJ_state + MJ_blue_switch_pos));

	local switches_active = white_pos.active or blue_pos.active;

	local row, col, x, y, color;

	gui.clearGraphics();

	kong_position = get_kong_position();

	for row=0,3 do
		for	col=0,3 do
			x = MJ_minimap_x_offset + col * MJ_minimap_width;
			y = MJ_minimap_y_offset + (3 - row) * MJ_minimap_height;

			color = MJ_blue;
			if MJ_get_color(col, row) == 'white' then
				color = MJ_white;
			end

			if switches_active then
				if white_pos.row == row and white_pos.col == col and MJ_get_color(cur_pos.col, cur_pos.row) == 'white' then
					color = MJ_white_switch;
				elseif blue_pos.row == row and blue_pos.col == col and MJ_get_color(cur_pos.col, cur_pos.row) == 'blue' then
					color = MJ_blue_switch;
				end
			end

			gui.drawRectangle(x, y, MJ_minimap_width, MJ_minimap_height, 0, color);

			if switches_active then
				if (white_pos.row == row and white_pos.col == col) or (blue_pos.row == row and blue_pos.col == col) then
					gui.drawImage(script_root.."/Images/switch.png", x, y, MJ_minimap_width, MJ_minimap_height);
				end
			end

			if cur_pos.row == row and cur_pos.col == col then
				gui.drawImage(script_root.."/Images/jack_icon.png", x, y, MJ_minimap_width, MJ_minimap_height);
			elseif next_pos.row == row and next_pos.col == col then
				gui.drawImage(MJ_get_arrow_image(cur_pos, next_pos), x, y, MJ_minimap_width, MJ_minimap_height);
			end

			if kong_position.row == row and kong_position.col == col then
				--gui.drawText(x, y, "K");
				gui.drawImage(script_root.."/Images/TinyFaceEdited.png", x, y, MJ_minimap_width, MJ_minimap_height);
			end
		end
	end

	-- Text info
	local phase_byte = mrb(MJ_state + MJ_action_type);
	local actions_remaining = mrb(MJ_state + MJ_actions_remaining);
	local time_until_next_action = mrb(MJ_state + MJ_time_until_next_action);

	local phase = MJ_get_phase(phase_byte);
	local action_type = MJ_get_action_type(phase_byte);

	gui.drawText(MJ_minimap_text_x, MJ_minimap_actions_remaining_y, actions_remaining.." "..action_type.."s remaining");

	if action_type ~= "Jump" then
		gui.drawText(MJ_minimap_text_x, MJ_minimap_phase_number_y  , "Phase "..phase.." (switch)");
		gui.drawText(MJ_minimap_text_x, MJ_time_until_next_action_y, time_until_next_action.." ticks until next "..action_type);
	else
		gui.drawText(MJ_minimap_text_x, MJ_minimap_phase_number_y  , "Phase "..phase);
	end
end

event.onframeend(draw_mj_minimap, "Mad Jack Minimap");