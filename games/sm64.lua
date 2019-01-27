if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	squish_memory_table = true,
	Memory = { -- Version order: USA, Europe, Japan Shindou, Japan
		x_rot = {0x33B19C, 0x30945C, 0x31D9EC, 0x339E2C}, -- u16_be -- TODO: Find
		y_rot = {0x33B19C, 0x30945C, 0x31D9EC, 0x339E2C}, -- u16_be
		z_rot = {0x33B19C, 0x30945C, 0x31D9EC, 0x339E2C}, -- u16_be -- TODO: Find
		x_pos = {0x33B1AC, 0x30946C, 0x31D9FC, 0x339E3C}, -- Float
		y_pos = {0x33B1B0, 0x309470, 0x31DA00, 0x339E40}, -- Float
		z_pos = {0x33B1B4, 0x309474, 0x31DA04, 0x339E44}, -- Float
		velocity = {0x33B1C4, 0x309484, 0x31DA14, 0x339E54}, -- Float
		y_velocity = {0x33B1B8, 0x30947C, 0x31DA0C, 0x339E48}, -- Float
		map = {0x32DDF8, 0x2F9FC8, 0x30D528, 0x32CE98}, -- u16_be
		object_list = {0x33D488, 0x30B0B8, 0x31F648, 0x33C118},
		global_object_data = {0x38BD88, 0x386A20, 0x388980, 0x38BD88},
	},
	maps = {
		"Unknown 1",
		"Unknown 2",
		"Unknown 3",
		"Big Boo's Haunt",
		"Cool, Cool Mountain",
		"Inside Peach's Castle",
		"Hazy Maze Cave",
		"Shifting Sand Land",
		"Bob-omb Battlefield",
		"Snowman's Land",
		"Wet-Dry World",
		"Jolly Roger Bay",
		"Tiny-Huge Island",
		"Tick Tock Clock",
		"Rainbow Ride",
		"Outside the Castle",
		"Bowser in the Dark World",
		"Vanish Cap Under the Moat",
		"Bowser in the Fire Sea",
		"The Secret Aquarium",
		"Bowser in the Sky",
		"Lethal Lava Land",
		"Dire, Dire Docks",
		"Whomp's Fortress",
		"'The End' Picture",
		"Castle Courtyard",
		"The Princess's Secret Slide",
		"Cavern of the Metal Cap",
		"Tower of the Wing Cap",
		"Bowser in the Dark World Boss",
		"Wing Mario Over the Rainbow",
		"Unknown 32",
		"Bowser in the Fire Sea Boss",
		"Bowser in the Sky Boss",
		"Unknown 35",
		"Tall Tall Mountain",
		"Unknown 37",
		"Unknown 38",
	},
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 },
	speedy_index = 7,
	rot_speed = 100,
	max_rot_units = 65536,
};

---------------------
-- Object Analysis --
---------------------

local objectIndex = 0;
local numObjects = 240;
local objectSize = 0x260; -- Double check

local object_vars = {
	--[0x00] = {Type="u16_be", Display="hex", Name="Header", Description="Always 0x18"},
	[0x02] = {Type="u16_be", Display="binary", Name="Camera Bitfield", Description="Affects how the object behaves according to the camera (billboarding, hide object, etc)"},
	[0x04] = {Type="pointer", Name="Previous Object", Description="Pointer to next object (if last object, pointer to first object)"},
	[0x08] = {Type="pointer", Name="Next Object", Description="Pointer to previous object (if first object, pointer to last object)"},
	--[0x0C] = {Type="pointer", Name="Global Object Variables", Description="Pointer to variables that affect all objects"},

	[0x14] = {Type="pointer", Name="Graphics Data", Description="Pointer to the object's graphics data. If zero, object has no graphics"},
	[0x18] = {Type="u16_be", Display="binary", Name="Graphics Enabled", Description="Use graphics flag"},

	--[0x20] = {Type="float", Name="Unknown Float 0x20"}, -- TODO: Unknown
	--[0x24] = {Type="float", Name="Unknown Float 0x24"}, -- TODO: Unknown
	--[0x28] = {Type="float", Name="Unknown Float 0x28"}, -- TODO: Unknown

	[0x2C] = {Type="float", Name="X Scale"},
	[0x30] = {Type="float", Name="Y Scale"},
	[0x34] = {Type="float", Name="Z Scale"},

	[0x38] = {Type="u16_be", Name="Current Action", Description="Object's current action (Mario only?)"},
	[0x3A] = {Type="u16_be", Name="Vertical Offset", Description="Higher object above or lower below ground (Mario only?)"},
	[0x3C] = {Type="pointer", Name="Animation Data", Description="Pointer to the object's animation data. If zero, object is not animated"},
	[0x40] = {Type="u16_be", Name="Animation Frame", Description="For animated objects, current animation frame"},

	--[0x54] = {Type="float", Name="Unknown Float 0x54"}, -- TODO: Unknown
	--[0x58] = {Type="float", Name="Unknown Float 0x58"}, -- TODO: Unknown
	--[0x5C] = {Type="float", Name="Unknown Float 0x5C"}, -- TODO: Unknown

	--[0x60] = {Type="pointer", Name="Unknown Object Pointer 0x60", Description="Points to an object, use is currently unknown"},
	--[0x64] = {Type="pointer", Name="Unknown Object Pointer 0x64", Description="Points to an object, use is currently unknown"},
	[0x68] = {Type="pointer", Name="Target Object", Description="For objects that follow another this is a pointer to the object to follow"},

	[0x74] = {Type="u16_be", Display="binary", Name="Is Active", Description="Determines if the object is being used"},
	[0x76] = {Type="u16_be", Display="binary", Name="Collision", Description="Collision flag?"},
	[0x78] = {Type="pointer", Name="Collision Object", Description="Pointer to object this object collided with"},

	[0x8E] = {Type="u16_be", Display="binary", Name="Reaction", Description="How much object reacts to Mario (use depends on behaviour)"},

	[0xA0] = {Type="float", Name="X Position"},
	[0xA4] = {Type="float", Name="Y Position"},
	[0xA8] = {Type="float", Name="Z Position"},

	[0xC4] = {Type="u32_be", Name="X Collision Rotation"}, -- TODO: Hitbox rotation?
	[0xC8] = {Type="u32_be", Name="Y Collision Rotation"}, -- TODO: Hitbox rotation?
	[0xCC] = {Type="u32_be", Name="Z Collision Rotation"}, -- TODO: Hitbox rotation?

	[0xD0] = {Type="float", Name="X Rotation"},
	[0xD4] = {Type="float", Name="Y Rotation"}, -- TODO: Getting bogus values here, are these u16_be?
	[0xD8] = {Type="float", Name="Z Rotation"},

	--[0xE8] = {Type="float", Name="Unknown Float 0xE8"}, -- TODO: Unknown

	[0xF0] = {Type="u32_be", Name="Appearance", Description="Changes the appearance of the object (used by some object graphics)"},
	[0xF4] = {Type="u32_be", Name="Object Type", Description="Type of object (used by some behaviours to allow for behaviour variations)"},
	[0xF8] = {Type="float", Name="Scale", Description="Used by some behaviors to scale all 3 axes"},
	[0xFC] = {Type="u32_be", Name="Fuse Timer", Description="Fuse timer used by Bob-omb behavior"}, -- TODO: Used for anything else?

	--[0x100] = {Type="float", Name="Unknown Float 0x100"}, -- TODO: Unknown
	--[0x104] = {Type="float", Name="Unknown Float 0x104"}, -- TODO: Unknown
	[0x108] = {Type="float", Name="Scale", Description="Used for file select buttons to scale all 3 axes"},

	[0x120] = {Type="u32_be", Name="Animation Start Offset", Description="Segment/offset value indicating start of animation data"},
	[0x124] = {Type="u32_be", Name="Current Action (0x124)", Description="What the object is doing, exact use depends on behavior"},
	[0x130] = {Type="u32_be", Name="Current Action (0x130)", Description="Simple behaviour select such as climbing it like a tree or to act like a door"},
	[0x134] = {Type="u32_be", Name="Special Action (0x134)", Description="Certain actions performed only by Mario? For other behaviors, to do with collisions"},

	[0x144] = {Type="u32_be", Name="Current Action (0x144)", Description="Used by some behaviors to remember what it's doing, other behaviours have different use"},
	[0x14C] = {Type="u32_be", Name="Current Action (0x14C)", Description="Used by most behaviors to remember what it's doing"},
	[0x150] = {Type="u32_be", Name="Current Action (0x150)", Description="Used by some behaviors to remember what it's doing"},
	[0x154] = {Type="u32_be", Name="Timer", Description="Timer used by and updated by some behaviors"},
	--[0x15C] = {Type="float", Name="Unknown Float 0x15C"}, -- TODO: Unknown

	[0x17C] = {Type="u32_be", Name="Transparancy", Description="Level of transparency for object's graphics"},
	[0x180] = {Type="u32_be", Name="Damage", Description="How many segments of damage to do to Mario for objects that cause him harm"},
	[0x184] = {Type="u32_be", Name="Health", Description="Used by some behaviours to remember its health. Other behaviours have similar use"},

	--[0x194] = {Type="float", Name="Unknown Float 0x194"}, -- TODO: Unknown
	[0x198] = {Type="u32_be", Name="Coin Payout", Description="How many coins to give, how you get the coins depends on the behaviour"},
	[0x19C] = {Type="float", Name="Activation Radius", Description="Controls what distance from the camera the object becomes active?"},

	[0x1AC] = {Type="pointer", Name="External Behavior Data (0x1AC)", Description="Pointer to external data used by some behaviors"},
	[0x1B0] = {Type="u32_be", Name="External Behavior Data Index", Description="Used by some behaviors as an index into the external data"},
	[0x1B8] = {Type="u16_be", Name="External Behavior Data Value", Description="For some behaviors, this is the value copied from the External Behavior Data object (0x1C0)"},
	[0x1C0] = {Type="pointer", Name="External Behavior Data (0x1C0)", Description="Pointer to external data used by some behaviors"},

	[0x1CC] = {Type="pointer", Name="Behavior Script Offset 1", Description="Pointer to part of behaviour script to be executed"}, -- TODO: On kill? On hit? What are these?
	[0x1D4] = {Type="pointer", Name="Behavior Script Offset 2", Description="Pointer to part of behaviour script to be executed"}, -- TODO: On kill? On hit? What are these?
	[0x1DC] = {Type="pointer", Name="Behavior Script Offset 3", Description="Pointer to part of behaviour script to be executed"}, -- TODO: On kill? On hit? What are these?

	[0x1F8] = {Type="float", Name="Tree Bottom", Description="Determines start of tree where Mario can grab before climbing"}, -- TODO: Better description
	[0x1FC] = {Type="float", Name="Tree Top", Description="Determines height of tree and thus, when Mario can handstand"}, -- TODO: Better description

	--[0x200] = {Type="float", Name="Unknown Float 0x200"}, -- TODO: Unknown
	--[0x204] = {Type="float", Name="Unknown Float 0x204"}, -- TODO: Unknown
	[0x20C] = {Type="pointer", Name="Behavior Script", Description="Pointer to start of the object's behaviour script"},

	[0x214] = {Type="pointer", Name="Standing On", Description="Pointer to the object this object is standing on (used only by Mario?)"},
	[0x218] = {Type="pointer", Name="Collision Data", Description="Pointer to collision data (as set by behaviour script command 0x2A)"},
	--[0x21C] = {Type="float", Name="Unknown Float 0x21C"}, -- TODO: Unknown

	--[0x230] = {Type="float", Name="Unknown Float 0x230"}, -- TODO: Unknown

	--[0x244] = {Type="float", Name="Unknown Float 0x244"}, -- TODO: Unknown

	--[0x258] = {Type="float", Name="Unknown Float 0x258"}, -- TODO: Unknown
	--[0x25C] = {Type="pointer", Name="Unknown Pointer 0x25C"},
};

-- TODO: Put unknowns in object_vars table somehow, probably autopopulate and have checkbox to display unknown fields
-- u16_be: Unknown Use:
	-- 0x1A, 0x42, 0x8C, 0x1F4, 0x1F6
-- u16_be(?): Unknown Type, Unknown Use:
	-- 0x94, 0x96, 0x1BA, 0x1BC
-- u32_be(?): Unknown Type, Unknown Use:
	-- 0x10, 0x1C, 0x44, 0x48, 0x4C, 0x50, 0x6C, 0x70, 0x7C, 0x80, 0x84, 0x88, 0x90, 0x98, 0x9C, 0xAC, 0xB0,
	-- 0xB4, 0xB8, 0xBC, 0xC0, 0xDC, 0xE0, 0xE4, 0xEC, 0x10C, 0x110, 0x114, 0x118, 0x11C, 0x128, 0x12C, 0x138, 0x13C, 0x140, 0x148,
	-- 0x158, 0x160, 0x164, 0x168, 0x16C, 0x170, 0x174, 0x178, 0x188, 0x18C, 0x190, 0x1A0, 0x1A4, 0x1A8, 0x1B4, 0x1C4,
	-- 0x1C8, 0x1D0, 0x1D8, 0x1E0, 0x1E4, 0x1E8, 0x1EC, 0x1F0, 0x208, 0x210, 0x220, 0x224, 0x228, 0x22C, 0x234,
	-- 0x238, 0x23C, 0x240, 0x248, 0x24C, 0x250, 0x254

function getVariableName(address)
	local variable = object_vars[address];
	local nameType = type(variable.Name);

	if nameType == "string" then
		return variable.Name;
	elseif nameType == "table" then
		-- TODO: Decide how to pick shorter/longer names, maybe maximum length passed in?
		return variable.Name[1];
	end

	return variable.Type;
end

function getExamineData(objectBase)
	local examineData = {};
	local variable;
	for relativeAddress = 0, objectSize do
		variable = object_vars[relativeAddress];
		if type(variable) == "table" then
			local variableName = getVariableName(relativeAddress);
			local variableValue = 0;
			if variable.Type == "u8" or variable.Type == "byte" or variable.Type == "Byte" then
				variableValue = mainmemory.read_u8(objectBase + relativeAddress);
			elseif variable.Type == "s8" then
				variableValue = mainmemory.read_s8(objectBase + relativeAddress);
			elseif variable.Type == "u16_be" then
				variableValue = mainmemory.read_u16_be(objectBase + relativeAddress);
			elseif variable.Type == "s16_be" then
				variableValue = mainmemory.read_s16_be(objectBase + relativeAddress);
			elseif variable.Type == "u32_be" or variable.Type == "pointer" or variable.Type == "Pointer" then
				variableValue = mainmemory.read_u32_be(objectBase + relativeAddress);
			elseif variable.Type == "s32_be" then
				variableValue = mainmemory.read_s32_be(objectBase + relativeAddress);
			elseif variable.Type == "float" or variable.Type == "Float" then
				variableValue = mainmemory.readfloat(objectBase + relativeAddress, true);
			end
			if variable.Type == "pointer" or variable.Type == "Pointer" then
				if isPointer(variableValue) then
					table.insert(examineData, {variableName, toHexString(variableValue)});
				end
			else
				if variable.Display == "Hex" or variable.Display == "hex" then
					table.insert(examineData, {variableName, toHexString(variableValue)});
				elseif variable.Display == "Binary" or variable.Display == "binary" or variable.Display == "Bitfield" or variable.Display == "bitfield" then
					table.insert(examineData, {variableName, toBinaryString(variableValue)});
				else
					table.insert(examineData, {variableName, variableValue});
				end
			end
		end
	end
	return examineData;
end

function Game.drawUI()
	forms.settext(ScriptHawk.UI.form_controls["Object Index Label"], "Index: "..objectIndex);
	if ScriptHawk.UI.ischecked("Enable Object Analyzer") then
		local gui_x = 2;
		local gui_y = 2;
		local row = 0;
		local height = 16;

		local examine_data = getExamineData(Game.Memory.object_list + objectIndex * objectSize);
		for i = #examine_data, 1, -1 do
			if examine_data[i][1] ~= "Separator" then
				if type(examine_data[i][2]) == "number" then
					examine_data[i][2] = round(examine_data[i][2], precision);
				end
				gui.text(gui_x, gui_y + height * row, examine_data[i][2].." - "..examine_data[i][1], nil, 'bottomright');
				row = row + 1;
			else
				row = row + examine_data[i][2];
			end
		end
	end
end

local function incrementObjectIndex()
	if ScriptHawk.UI.ischecked("Enable Object Analyzer") then
		objectIndex = objectIndex + 1;
		if objectIndex >= numObjects then
			objectIndex = 0;
		end
	end
end

local function decrementObjectIndex()
	if ScriptHawk.UI.ischecked("Enable Object Analyzer") then
		objectIndex = objectIndex - 1;
		if objectIndex < 0 then
			objectIndex = numObjects;
		end
	end
end

function zipToSelectedObject()
	if ScriptHawk.UI.ischecked("Enable Object Analyzer") then
		local objectBase = Game.Memory.object_list + objectIndex * objectSize;

		local objectX = mainmemory.readfloat(objectBase + 0xA0, true);
		local objectY = mainmemory.readfloat(objectBase + 0xA4, true);
		local objectZ = mainmemory.readfloat(objectBase + 0xA8, true);

		Game.setPosition(objectX, objectY, objectZ);
	end
end

-------------------
-- Physics/Scale --
-------------------

function Game.getVelocity()
	return mainmemory.readfloat(Game.Memory.velocity, true);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity, true);
end

function Game.setYVelocity(value)
	mainmemory.writefloat(Game.Memory.y_velocity, value, true);
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.x_pos, true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_pos, true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_pos, true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(Game.Memory.x_pos, value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(Game.Memory.y_pos, value, true);
	Game.setYVelocity(0);
end

function Game.setZPosition(value)
	mainmemory.writefloat(Game.Memory.z_pos, value, true);
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	return mainmemory.read_u32_be(Game.Memory.x_rot);
end

function Game.getYRotation()
	return mainmemory.read_u32_be(Game.Memory.y_rot);
end

function Game.getZRotation()
	return mainmemory.read_u32_be(Game.Memory.z_rot);
end

function Game.setXRotation(value)
	return mainmemory.write_u32_be(Game.Memory.x_rot, value);
end

function Game.setYRotation(value)
	return mainmemory.write_u32_be(Game.Memory.y_rot, value);
end

function Game.setZRotation(value)
	return mainmemory.write_u32_be(Game.Memory.z_rot, value);
end

------------
-- Events --
------------

function Game.setMap(value)
	if value >= 1 and value <= #Game.maps then
		mainmemory.write_u16_be(Game.Memory.map, value);
	end
end

function Game.initUI()
	ScriptHawk.UI.checkbox(10, 6, "Enable Object Analyzer", "Object Analyzer");
	ScriptHawk.UI.button({13, -7}, 7, {ScriptHawk.UI.button_height}, nil, "Decrement Object Index", "-", decrementObjectIndex);
	ScriptHawk.UI.button({13, ScriptHawk.UI.button_height - 7}, 7, {ScriptHawk.UI.button_height}, nil, "Increment Object Index", "+", incrementObjectIndex);
	ScriptHawk.UI.form_controls["Object Index Label"] = forms.label(ScriptHawk.UI.options_form, "Index: 0", ScriptHawk.UI.col(8) + ScriptHawk.UI.button_height + 21, ScriptHawk.UI.row(7) + ScriptHawk.UI.label_offset, 64, 14);
end

ScriptHawk.bindKeyRealtime("Z", zipToSelectedObject, true);
ScriptHawk.bindKeyRealtime("N", decrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("M", incrementObjectIndex, true);
ScriptHawk.bindMouse("mousewheelup", decrementObjectIndex);
ScriptHawk.bindMouse("mousewheeldown", incrementObjectIndex);

Game.OSD = {
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Velocity", Game.getVelocity, category="speed"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"},
	--{"Rot. X", Game.getXRotation, category="angleMore"}, -- TODO
	{"Facing", Game.getYRotation, category="angle"},
	--{"Rot. Z", Game.getZRotation, category="angleMore"}, -- TODO
};

return Game;