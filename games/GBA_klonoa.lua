if type(ScriptHawk) ~= "table" then -- An error message to inform the user that this is a game module, not a standalone script
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		obj_array_base = {Domain="IWRAM", Address=0x2920},
		obj_array_size = {Domain="IWRAM", Address=0x5428},
		grabbed_obj_index = {Domain="IWRAM", Address=0x5262}
	},
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 }, -- D-Pad speeds, scale these appropriately with your game's coordinate system
	speedy_index = 7, -- Default speed, index into the speedy_speeds table
};

--------------------
-- Region/Version --
--------------------
local obj_struct_size = 0x1C;
local obj_struct = {
	[0x00] = {type="s16_le", name="XPosition"},
	[0x02] = {type="s16_le", name="YPosition"},
	[0x04] = {type="s16_le", name="XScreenOffset"},
	[0x06] = {type="s16_le", name="YScreenOffset"},
	[0x10] = {type="u8", name="Visible"},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

-------------------
-- Physics/Scale --
-------------------

-- Optional: If lag in your game is more complicated than a simple emu.islagged() call you should add the logic to detect it here
function Game.isPhysicsFrame()
	-- Implementing this logic will result in smooth dY/dXZ calculation (no more flickering between 0 and the correct value)
	return not emu.islagged();
end

--------------
-- Objects --
--------------
function Game.getObjXPos(obj_index)
	local objArraySize = memory.read_u8(Game.Memory.obj_array_size.Address, Game.Memory.obj_array_size.Domain);
	if obj_index<objArraySize then
		local objAddr = {Address = Game.Memory.obj_array_base.Address,
			Domain = Game.Memory.obj_array_base.Domain
		};
		objAddr.Address = objAddr.Address + (obj_index * obj_struct_size);
		return memory.read_s16_le(objAddr.Address, objAddr.Domain);
	else
		return 0;
	end
end

function Game.getObjYPos(obj_index)
	local objArraySize = memory.read_u8(Game.Memory.obj_array_size.Address, Game.Memory.obj_array_size.Domain);
	if obj_index<objArraySize then
		local objAddr = {Address = Game.Memory.obj_array_base.Address,
			Domain = Game.Memory.obj_array_base.Domain
		};
		objAddr.Address = objAddr.Address + (obj_index * obj_struct_size);
		return memory.read_s16_le(objAddr.Address + 0x02, objAddr.Domain);
	else
		return 0;
	end
end

function Game.getObjVis(obj_index)
	local objArraySize = memory.read_u8(Game.Memory.obj_array_size.Address, Game.Memory.obj_array_size.Domain);
	if obj_index<objArraySize then
		local objAddr = {Address = Game.Memory.obj_array_base.Address,
			Domain = Game.Memory.obj_array_base.Domain
		};
		objAddr.Address = objAddr.Address + (obj_index * obj_struct_size);
		return memory.read_u8(objAddr.Address + 0x10, objAddr.Domain);
	else
		return 0;
	end
end

function Game.getObjXOffset(obj_index)
	local objArraySize = memory.read_u8(Game.Memory.obj_array_size.Address, Game.Memory.obj_array_size.Domain);
	if obj_index<objArraySize then
		local objAddr = {Address = Game.Memory.obj_array_base.Address,
			Domain = Game.Memory.obj_array_base.Domain
		};
		objAddr.Address = objAddr.Address + (obj_index * obj_struct_size);
		return memory.read_s16_le(objAddr.Address + 0x04, objAddr.Domain);
	else
		return 0;
	end
end

function Game.getObjYOffset(obj_index)
	local objArraySize = memory.read_u8(Game.Memory.obj_array_size.Address, Game.Memory.obj_array_size.Domain);
	if obj_index<objArraySize then
		local objAddr = {Address = Game.Memory.obj_array_base.Address,
			Domain = Game.Memory.obj_array_base.Domain
		};
		objAddr.Address = objAddr.Address + (obj_index * obj_struct_size);
		return memory.read_s16_le(objAddr.Address + 0x06, objAddr.Domain);
	else
		return 0;
	end
end

function Game.setObjXPos(obj_index, value)
	local objArraySize = memory.read_u8(Game.Memory.obj_array_size.Address, Game.Memory.obj_array_size.Domain);
	if obj_index<objArraySize then
		local objAddr = {Address = Game.Memory.obj_array_base.Address,
			Domain = Game.Memory.obj_array_base.Domain
		};
		objAddr.Address = objAddr.Address + (obj_index * obj_struct_size);
		return memory.write_s16_le(objAddr.Address, value, objAddr.Domain);
	else
		return 0;
	end
end

function Game.setObjYPos(obj_index, value)
	local objArraySize = memory.read_u8(Game.Memory.obj_array_size.Address, Game.Memory.obj_array_size.Domain);
	if obj_index<objArraySize then
		local objAddr = {Address = Game.Memory.obj_array_base.Address,
			Domain = Game.Memory.obj_array_base.Domain
		};
		objAddr.Address = objAddr.Address + (obj_index * obj_struct_size);
		return memory.read_s16_le(objAddr.Address + 0x04, value, objAddr.Domain);
	else
		return 0;
	end
end

--------------
-- Position --
--------------
function Game.getXPosition()
	return Game.getObjXPos(0);
end

function Game.getYPosition()
	return Game.getObjYPos(0);
end

function Game.setXPosition(value)
	Game.setObjXPos(0, value);
end

function Game.setYPosition(value)
	Game.setObjYPos(0, value);
end


function Game.drawObjectPositions()
	local objArraySize = memory.read_u8(Game.Memory.obj_array_size.Address, Game.Memory.obj_array_size.Domain);
	if objArraySize ~= 0 then 
		for i = 0, objArraySize-1 do
			local xOffset = Game.getObjXOffset(i);
			local yOffset = Game.getObjYOffset(i);
			
			if xOffset >= 0 and xOffset < 240 then
				if yOffset >= 0 and yOffset < 160 then
					local visible = Game.getObjVis(i)
					if visible ~= 0x00 then 
						gui.drawLine(xOffset, yOffset-2, xOffset, yOffset+2); 
						gui.drawLine(xOffset-2, yOffset, xOffset+2, yOffset); 
						gui.drawText(xOffset, yOffset, toHexString(i), null, null, 9);
					end
				end
			end
		end
	end
end

------------
-- Events --
------------

function Game.buttonHandler()
	print("Example button was pressed!");
end

local labelValue = 0;
function Game.initUI() -- Optional: Init any UI state here, mainly useful for setting up your form controls. Runs once at startup after successful version detection.
	-- Here are some examples for the most common UI control types
	ScriptHawk.UI.form_controls["Example Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, {"Option 1", "Option 2", "Option 3"}, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 7, ScriptHawk.UI.button_height);
	ScriptHawk.UI.button(10,                                    7, {59},                          nil, "Example Button",       "Label", Game.buttonHandler);
	ScriptHawk.UI.button({13, -7},                              6, {ScriptHawk.UI.button_height}, nil, "Example Plus Button",  "-",     function() labelValue = labelValue + 1 end);
	ScriptHawk.UI.button({13, ScriptHawk.UI.button_height - 7}, 6, {ScriptHawk.UI.button_height}, nil, "Example Minus Button", "+",     function() labelValue = labelValue - 1 end);
	ScriptHawk.UI.form_controls["Example Value Label"] = forms.label(ScriptHawk.UI.options_form, "0", ScriptHawk.UI.col(13) + ScriptHawk.UI.button_height + 21, ScriptHawk.UI.row(6) + ScriptHawk.UI.label_offset, 54, 14);
	ScriptHawk.UI.checkbox(10, 6, "Example Checkbox", "Label");
end

-- Optional: This function should be used to draw to the screen or update form controls
-- When emulation is running it will be called once per frame
-- When emulation is paused it will be called as fast as possible
--function Game.drawUI()
--	forms.settext(ScriptHawk.UI.form_controls["Example Value Label"], labelValue);
--end


function Game.eachFrame()
	Game.drawObjectPositions();
end

Game.OSD = {
	{"X", category="position"},
	{"Y", category="position"},
	{"Separator"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"}
};

return Game; -- Return your Game table to ScriptHawk