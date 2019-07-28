if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		player_ptr = {Domain="EWRAM", Address=0x47EC},
		object_array_size = {Domain="IWRAM", Address=0x16F8},
		object_list_ptr = {Domain="IWRAM", Address=0x14A0},
		rangCount = {Domain="IWRAM", Address=0xB06},
		--player_ptr = {Domain="EWRAM", Address={0x5B08}}, -- May be better?
	},
};

local script_modes = {
	"Disabled",
	"List",
	"Examine",
};

local script_mode_index = 1;
local script_mode = script_modes[script_mode_index];

--------------------
-- Region/Version --
--------------------

local player_struct = {
	[0xC] = {type="s32_le", name="XPosition"},
	[0x10] = {type="s32_le", name="YPosition"},
	[0x18] = {type="s32_le", name="XVelocity"},
	[0x1C] = {type="s32_le", name="YVelocity"},
	[0x74] = {type="u32_le", name="1st Glide"},
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

-------------------
-- Physics/Scale --
-------------------

function Game.getPlayer()
	return dereferencePointer(Game.Memory.player_ptr);
end

local movementStates = {
	[0x00] = "Idle",
	[0x01] = "Run",
	[0x02] = "Jump",
	[0x03] = "Fall",
	[0x04] = "Glide",
	[0x05] = "Rang Throw",
	[0x06] = "Damaged",
	[0x07] = "Run Skid",
	[0x09] = "Run Start",
	[0x0A] = "Landing",
	[0x0C] = "Bite",
	[0x0D] = "Interacting",
	[0x10] = "Fast Falling",
	[0x11] = "Fall Damage",
	[0x15] = "Platform Drop Through",
	[0x17] = "Looking",
	[0X19] = "Arial Bite",
};

function Game.getState()
	local player = Game.getPlayer();
	if player ~= nil then
		local currentMovementState = memory.read_u8(player.Address + 0x5D, player.Domain);
		--local direction = memory.read_u8_le(player.Address + 0x16, player.Domain);
		return movementStates[currentMovementState] or "Unknown ("..currentMovementState..")";
	end
end

function Game.getRangCount()
	return (2 - memory.read_u16_le(Game.Memory.rangCount.Address, Game.Memory.rangCount.Domain));
end

function Game.colorRangCount()
	local rangs = Game.getRangCount();
	if rangs == 0 then
		return colors.red;
	elseif rangs == 2 then
		return colors.green;
	end
end

function Game.getGlideFlag()
	local player = Game.getPlayer();
	if player ~= nil then
		local glideFlag = memory.read_u32_le(player.Address + 0x74, player.Domain);
		return glideFlag ~= 0;
	end
end

function Game.colorGlideFlag()
	local glideFlag = Game.getGlideFlag();
	if glideFlag == true and Game.getRangCount() == 2 then
		return colors.green;
	end
end

--------------
-- Position --
--------------

function Game.getXPosition()
	local player = Game.getPlayer();
	if player ~= nil then
		return memory.read_s32_le(player.Address + 0x0C, player.Domain);
	end
	return 0
end

function Game.getYPosition()
	local player = Game.getPlayer();
	if player ~= nil then
		return -memory.read_s32_le(player.Address + 0x10, player.Domain);
	end
	return 0;
end

function Game.colorYVelocity()
	local yVelocity = Game.getYVelocity();
	if yVelocity < 0 then
		return colors.red;
	end
end

function Game.setXPosition(value)
	local player = Game.getPlayer();
	if player ~= nil then
		memory.write_s32_le(player.Address + 0x0C, value, player.Domain);
	end
end

function Game.setYPosition(value)
	local player = Game.getPlayer();
	if player ~= nil then
		memory.write_s32_le(player.Address + 0x10, value, player.Domain);
	end
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	local player = Game.getPlayer();
	if player ~= nil then
		return memory.read_s32_le(player.Address + 0x18, player.Domain);
	end
	return 0;
end

function Game.getYVelocity()
	local player = Game.getPlayer();
	if player ~= nil then
		return memory.read_s32_le(player.Address + 0x1C, player.Domain);
	end
	return 0;
end

-------------
-- Objects --
-------------

local object_index = 2;
local object_top_index = 1;
object_max_slots = 25;
local object_struct_size = 0xF8;

local object_indexes = {
	[0x0B] = "Moving Platform",

	[0x36] = "Crab Tank Enemy",
	[0x37] = "Cricket Bat Enemy",
	[0x38] = "Bird Enemy",
	[0x39] = "Spider Enemy",

	[0x3D] = "Checkpoint",
	[0x3E] = "Health Refill",

	[0x49] = "Robot Enemy",

	[0x4B] = "Opal Sack",

	[0x53] = "Secret Box",
	[0x54] = "Ninja Enemy",

	[0x59] = "Breakable Crystals",

	[0x5B] = "Warp Mushrooms",
	[0x5C] = "Bilby",

	[0x5E] = "Firebreathing Enemy",

	[0x60] = "Fish Enemy",

	[0x62] = "Tilting Platform",

	[0x65] = "Mech Suit Enemy",

	[0x69] = "Ranger Ken",

	[0x6D] = "Air Bubbles",
	[0x6E] = "Wood Gate",
	[0x6F] = "White Croc",
	[0x70] = "Button",

	[0x72] = "Moving Platform",

	[0x7D] = "Breakable Rock Wall",

	[0x81] = "Liftable Rock",

	[0x92] = "Fire",
	[0x93] = "Leech",
};

-- Object Structure
local slot_variables = {
	[0x0C] = {type="s32_le", name={"X", "X Pos", "X Position"}},
	[0x10] = {type="s32_le", name={"Y", "Y Pos", "Y Position"}},
	[0x18] = {type="s32_le", name={"dX", "X Vel", "X Velocity"}},
	[0x1C] = {type="s32_le", name={"dY", "Y Vel", "Y Velocity"}},
};

local function getObjectSlotBase(index, addressPtr)
	if addressPtr == nil then
		addressPtr = Game.Memory.object_list_ptr;
		index = index - 1;
	end

	if index > 0 then
		local nextPtr = memory.read_u32_le(addressPtr.Address + 0x0C, addressPtr.Domain);
		nextPtr = parsePointer(nextPtr);
		if nextPtr ~= nil then
			return getObjectSlotBase(index - 1, nextPtr);
		end
	else
		local objectPtr = memory.read_u32_le(addressPtr.Address + 0x04, addressPtr.Domain);
		return parsePointer(objectPtr);
	end
end

local function incrementObjectIndex()
	local tempObject = getObjectSlotBase(object_index + 1);
	if tempObject ~= nil then
		object_index = object_index + 1;
		if object_index > object_top_index - 1 + object_max_slots then
			object_top_index = object_index + 1 - object_max_slots;
		end
	end
end

local function decrementObjectIndex()
	if object_index - 1 > 0 then
		object_index = object_index - 1;
		if object_index < object_top_index then
			object_top_index = object_index;
		end
	end
end

function zipToSelectedObject()
	local objAddress = getObjectSlotBase(object_index);
	if objAddress ~= nil then
		local x = memory.read_u32_le(objAddress.Address + 0x0C, objAddress.Domain);
		local y = memory.read_u32_le(objAddress.Address + 0x10, objAddress.Domain);

		Game.setXPosition(x);
		Game.setYPosition(y);
	end
end

local function getVariableName(address)
	local variable = slot_variables[address];
	local nameType = type(variable.Name);

	if nameType == "string" then
		return variable.Name;
	elseif nameType == "table" then
		return variable.Name[1];
	end

	return variable.type.." "..toHexString(address);
end

local function isBinary(var_type)
	return var_type == "Binary" or var_type == "Bitfield" or var_type == "Byte" or var_type == "Flag" or var_type == "Boolean";
end

local function isHex(var_type)
	return var_type == "Hex" or var_type == "Pointer" or var_type == "Z4_Unknown";
end

local function formatForOutput(var_type, value)
	if isBinary(var_type) then
		local binstring = toBinaryString(value);
		if binstring ~= "" then
			return binstring;
		end
		return "0";
	elseif isHex(var_type) then
		return toHexString(value);
	end
	return ""..value;
end

function getExamineData(slotBase) -- TODO: Improve this based on SM64 module implementation
	local current_slot_variables = {};
	-- Get slot size
	local objectType = memory.read_u32_le((slotBase.Address) + 0x04, slotBase.Domain);
	local slot_size = 0xF8;

	-- Generate table
	for relative_address = 0, slot_size do
		local variable_data = slot_variables[relative_address];
		if type(variable_data) == "table" then
			local variableName = getVariableName(relative_address);
			if variable_data.type == "s32_le" then
				table.insert(current_slot_variables, {variableName, formatForOutput(variable_data.type, memory.read_s32_le((slotBase.Address) + relative_address, slotBase.Domain))});
				--table.insert(current_slot_variables, {variableName, "Test"});
			end
		end
	end
	return current_slot_variables;
end

------------
-- Events --
------------

local function toggleObjectAnalysisToolsMode()
	script_mode_index = script_mode_index + 1;
	if script_mode_index > #script_modes then
		script_mode_index = 1;
	end
	script_mode = script_modes[script_mode_index];
end

function Game.drawUI()
	local row = 0;
	if script_mode == "Disabled" then
		return;
	elseif script_mode == "Examine" then
		gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, "Mode: "..script_mode, nil, 'bottomright');
		row = row + 1;

		local currentSlotBase = getObjectSlotBase(object_index);
		if currentSlotBase ~= nil then
			local examine_data = getExamineData(currentSlotBase);

			for i = #examine_data, 1, -1 do
				if examine_data[i][1] ~= "Separator" then
					gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, examine_data[i][2].." - "..examine_data[i][1], nil, 'bottomright');
					row = row + 1;
				else
					row = row + examine_data[i][2];
				end
			end

			if memory.read_u32_le(currentSlotBase.Address, currentSlotBase.Domain) ~= 0 then
				local objectType = memory.read_u32_le(currentSlotBase.Address + 0x04, currentSlotBase.Domain);
				local actorType = object_indexes[objectType] or "Unknown("..toHexString(objectType)..")";
				gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, actorType.." "..object_index..": "..toHexString(currentSlotBase.Address or 0), nil, 'bottomright');
				row = row + 1;
			end
		end
	elseif script_mode == "List" then
		gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, "Mode: "..script_mode, nil, 'bottomright');
		row = row + 1;

		local objectcount = object_max_slots;
		local printlist = {};
		for i = object_top_index - 1 + objectcount, object_top_index, -1 do
			local currentSlotBase = getObjectSlotBase(i);
			if currentSlotBase ~= nil then
				local objectType = memory.read_u32_le(currentSlotBase.Address + 0x04, currentSlotBase.Domain);
				local actorType = object_indexes[objectType] or "Unknown("..toHexString(objectType)..")";
				printlist[i] = actorType.." "..i..": "..toHexString(currentSlotBase.Address or 0);
			end
		end
		for i = object_top_index - 1 + objectcount, object_top_index, -1 do
			local color = nil;
			if object_index == i then
				color = colors.yellow;
			end
			if printlist[i] ~= nil then
				gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, printlist[i], color, 'bottomright');
				row = row + 1;
			end
		end
	end
end

Game.OSD = {
	{"State", Game.getState, category="state"},
	{"Rang #", Game.getRangCount, Game.colorRangCount, category="boomerang"},
	{"SuperJump", Game.getGlideFlag, Game.colorGlideFlag, category="superjump"},
	{"X", category="position"},
	{"Y", category="position"},
	{"Separator"},
	{"X Vel", Game.getXVelocity, category="speed"},
	{"Y Vel", Game.getYVelocity, Game.colorYVelocity, category="speed"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"},
};

ScriptHawk.bindKeyRealtime("Z", zipToSelectedObject, true);
ScriptHawk.bindKeyRealtime("C", toggleObjectAnalysisToolsMode, true);
ScriptHawk.bindMouse("mousewheelup", decrementObjectIndex);
ScriptHawk.bindMouse("mousewheeldown", incrementObjectIndex);

return Game;