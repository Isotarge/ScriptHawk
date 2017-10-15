if type(ScriptHawk) ~= "table" then -- An error message to inform the user that this is a game module, not a standalone script
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {}; -- This table stores the module's API function implementations and game state, it's returned to ScriptHawk at the end of the module code

local script_modes = {
	"Disabled",
	"List",
--	"Examine",
};

local script_mode_index = 1;
script_mode = script_modes[script_mode_index];

--------------------
-- Region/Version --
--------------------

Game.Memory = {
	["x_position"] = {["Domain"] = "IWRAM", ["Address"] = {0x0E98}},
	["y_position"] = {["Domain"] = "IWRAM", ["Address"] = {0x0E9C}},
	["x_velocity"] = {["Domain"] = "IWRAM", ["Address"] = {0x0EA0}},
	["y_velocity"] = {["Domain"] = "IWRAM", ["Address"] = {0x0EA4}},
	["current_movement_state"] = {["Domain"] = "IWRAM", ["Address"] = {0x0F38}},
	["drill_gauge"] = {["Domain"] = "IWRAM", ["Address"] = {0x11A4}},

	["object_array_end_ptr"] = {["Domain"] = "EWRAM", ["Address"] = {0x0004}},
	["object_array"] = {["Domain"] = "EWRAM", ["Address"] = {0x0010}},
};

function Game.detectVersion(romName, romHash) -- Modules should ideally use ROM hash rather than name, but both are passed in by ScriptHawk
	if romHash == "C1058CC2482B91204100CC8515DA99AEB06773F5" then -- US
		version = 1; -- We use the version variable as an index for the Game.Memory table
	elseif romHash == "84AFA7108E4D604E7B1A6D105DF5760869A247FA" then --JP
		version = 2;
	else
		return false; -- Return false if this version of the game is not supported
	end

	return true; -- Return true if version detection is successful
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .001, .01, .1, 1, 5, 10, 20, 50, 100 }; -- D-Pad speeds, scale these appropriately with your game's coordinate system
Game.speedy_index = 7;

-----------------------------------------
-- 16.16 numbers and domains are weird --
-----------------------------------------

function Game.read_16_16(address, domain)
	local value =  memory.read_u16_le(address, domain) / 0x10000;
	value = value + memory.read_s16_le(address + 0x02, domain);
	return value;
end

function Game.write_16_16(address, value, domain)
	memory.write_s16_le(address + 0x02, value, domain);
	memory.write_u16_le(address, ((value * 0x10000) % 0x10000), domain);
	return value;
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return Game.read_16_16(Game.Memory.x_position["Address"][version], Game.Memory.x_position["Domain"]);
end

function Game.getYPosition()
	return Game.read_16_16(Game.Memory.y_position["Address"][version], Game.Memory.y_position["Domain"]);
end

function Game.setXPosition(value)
	Game.write_16_16(Game.Memory.x_position["Address"][version], value, Game.Memory.x_position["Domain"]);
end

function Game.setYPosition(value)
	Game.write_16_16(Game.Memory.x_position["Address"][version], value, Game.Memory.x_position["Domain"]);
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	return Game.read_16_16(Game.Memory.x_velocity["Address"][version], Game.Memory.x_velocity["Domain"]);
end

function Game.getYVelocity()
	return Game.read_16_16(Game.Memory.y_velocity["Address"][version], Game.Memory.y_velocity["Domain"]);
end

function Game.setXVelocity(value)
	Game.write_16_16(Game.Memory.x_velocity["Address"][version],value, Game.Memory.x_velocity["Domain"]);
end

function Game.setYVelocity(value)
	Game.write_16_16(Game.Memory.y_velocity["Address"][version],value, Game.Memory.y_velocity["Domain"]);
end

function Game.getDrillValue()
	return toHexString(memory.read_u32_le(Game.Memory.drill_gauge["Address"][version], Game.Memory.drill_gauge["Domain"]));
end

--------------------
-- Movement State --
--------------------

local movementStates = {
	[0x00] = "Idle (L)",
	[0x01] = "Idle (R)",
	[0x02] = "Idle: Looking Up (L)",
	[0x03] = "Idle: Looking Up (R)",
	[0x04] = "Crouching (L)",
	[0x05] = "Crouching (R)",
	[0x06] = "Walking (L)",
	[0x07] = "Walking (R)",
	[0x08] = "Running (L)",
	[0x09] = "Running (R)",
	[0x0A] = "Jumping (L)",
	[0x0B] = "Jumping (R)",
	[0x0C] = "Freefall (L)",
	[0x0D] = "Freefall (R)",
	[0x0E] = "Falling (L)",
	[0x0F] = "Falling (R)",
	[0x10] = "Landing (L)",
	[0x11] = "Landing (R)",
	[0x12] = "Drilling: Up (L)",
	[0x13] = "Drilling: Up (R)",
	[0x14] = "Drilling: Down (L)",
	[0x15] = "Drilling: Down (R)",
	[0x16] = "Drilling (L)",
	[0x17] = "Drilling (R)",
	[0x18] = "Damaged (L)",
	[0x19] = "Damaged (R)",
	[0x1A] = "KickBack (L)",
	[0x1B] = "KickBack (R)",
	[0x1C] = "Drilling: Wall (L)",
	[0x1D] = "Drilling: Wall (R)",

	[0x20] = "Tunnel: Idle (L)",
	[0x21] = "Tunnel (L)",
	[0x22] = "Tunnel: Idle (R)",
	[0x23] = "Tunnel (R)",

	[0x24] = "Teetering (L)",
	[0x25] = "Teetering (R)",
	[0x26] = "Entering Door (L)",
	[0x27] = "Entering Door (R)",
	[0x28] = "Exiting Door (L)",
	[0x29] = "Exiting Door (R)",
	[0x2A] = "Drill Socket (L)",
	[0x2B] = "Drill Socket (R)",
	[0x2C] = "Looking (L)",
	[0x2D] = "Looking (R)",
	[0x2E] = "Looking: Up (L)",
	[0x2F] = "Looking: Up (R)",
	[0x30] = "Looking: Down (L)",
	[0x31] = "Looking: Down (R)",
	[0x32] = "Drilling: Walking (L)",
	[0x33] = "Drilling: Walking (R)",
	[0x34] = "Drilling: Back Walking (L)",
	[0x35] = "Drilling: Back Walking (R)",

	[0x3E] = "Drilling: Stuck in block (L)",
	[0x3F] = "Drilling: Stuck in block (R)",

	[0x42] = "Grabbing Gear (L)",
	[0x43] = "Grabbing Gear (R)",
	[0x45] = "Grabbing Gear Jig",

	[0x50] = "Drill Socket: Idle (L)",
	[0x51] = "Drill Socket: Idle (R)",

	[0x57] = "Swimming: Idle (L)",
	[0x58] = "Swimming: Idle (R)",
	[0x58] = "Swimming Up (R)",
	[0x59] = "Swimming Up (L)",
	[0x5A] = "Swimming Down (L)",
	[0x5B] = "Swimming Down (R)",
	[0x5C] = "Swimming (L)",
	[0x5D] = "Swimming (R)",
	[0x5F] = "Swimming: Up Idle (R)",
	[0x5F] = "Swimming: Up Idle (L)",
	[0x60] = "Swimming: Down Idle (L)",
	[0x61] = "Swimming: Down Idle (R)",
	[0x62] = "Swimming: Idle (L)",
	[0x63] = "Swimming: Idle (R)",
	[0x64] = "Swimming: Damaged (L)",
	[0x65] = "Swimming: Damaged (R)",

	[0x67] = "Wall Object: Grabbing (L)",
	[0x68] = "Wall Object: Grabbing (R)",
	[0x69] = "Wall Object: Idle (L)",
	[0x6A] = "Wall Object: Idle (R)",
	[0x6B] = "Wall Object: Falling (L)",
	[0x6C] = "Wall Object: Falling (R)",
	[0x6D] = "Wall Object: Walking (L)",
	[0x6E] = "Wall Object: Walking (R)",
	[0x6F] = "Wall Object: Placing (L)",
	[0x70] = "Wall Object: Placing (R)",

	[0x82] = "Slide Start (L)",
	[0x83] = "Slide Start (R)",
	[0x84] = "Slide (L)",
	[0x85] = "Slide (R)",
	[0x86] = "Slide End (L)",
	[0x87] = "Slide End (R)",

	[0x99] = "Looking: Backwards (L)",
	[0x9A] = "Looking: Backwards (R)",
	[0x9B] = "Looking: Forwards (L)",
	[0x9C] = "Looking: Forwards (R)",

	[0xBD] = "Loading Zone",
};

function Game.getCurrentMovementState()
	local currentMovementState = memory.read_u32_le(Game.Memory.current_movement_state["Address"][version],Game.Memory.current_movement_state["Domain"]);
	if type(movementStates[currentMovementState]) ~= "nil" then
		return movementStates[currentMovementState];
	else
		return "Unknown ("..currentMovementState..")";
	end
end

function Game.colorCurrentMovementState()
	local stringMovementState = Game.getCurrentMovementState();
	--if stringMovementState == "Slipping" or stringMovementState == "Skidding" or stringMovementState == "Recovering" or stringMovementState == "Knockback" then
	--	return colors.yellow;
	--end
	if stringMovementState == "Damaged (L)" 
		or stringMovementState == "Damaged (R)" 
		or stringMovementState == "Swimming: Damaged (L)" 
		or stringMovementState == "Swimming: Damaged (R)" then
		return colors.red;
	end
end

-------------
-- Objects --
-------------
object_index = 1;

local object_struct_size = 0xFC;

local object_struct = {
	[0x16] = {["Type"] = "u16_le", ["Name"] = "Object Index"},

	[0x24] = {["Type"] = "u16_le", ["Name"] = "XPosition"},
	[0x26] = {["Type"] = "u16_le", ["Name"] = "YPosition"},

	[0x56] = {["Type"] = "u16_le", ["Name"] = "Health"},
	[0x58] = {["Type"] = "u16_le", ["Name"] = "Max Health"},
};

local object_indexes = {
	[0x00] = "2nd Gear Item",
	[0x01] = "3rd Gear Item",
	[0x02] = "Small Health",
	[0x03] = "Large Health",
	[0x04] = "Full Health",

	[0x0A] = "Moving Platfrom",

	[0x15] = "Moving Drill Socket",
	[0x16] = "Chandelier and Chain",
	[0x17] = "Chandelier",

	[0x31] = "Wheel Enemy",
	[0x32] = "Flying Spike Enemy",
	[0x33] = "Flying Upwards Spike Enemy",

	[0x4C] = "Doorway",

	[0x56] = "Spring Enemy",
	[0x57] = "Electric Spring Enemy",
	[0x58] = "Claw Miniboss Weakspot",
	[0x59] = "Claw",

	[0x5C] = "Squrpion Tank",
	[0x5D] = "Squrpion Tank Tail Piece",
	[0x5E] = "Bullet",

	[0x63] = "Breakable Box",
	[0x6B] = "Police MechSuit",

	[0x6D] = "Police Shield MechSuit",
	[0x6E] = "Lock-Camera Room",

	[0x75] = "Number Bomb",

	[0x77] = "Number Bomb Screw",

	[0x88] = "Skullker Minion",
	[0x89] = "Police Minion",
	[0x8A] = "Skeleton Minion",
	[0x8B] = "Prison Minion",

	[0x8C] = "Small Block",

	[0x8E] = "Tank Dozer",
	[0x8F] = "Tank Dozer Missile",

	[0x91] = "Control Drill Socket",

	[0xA0] = "Robo-Doggo",

	[0xAB] = "Giant Rolling Rock",
	[0xAC] = "Metal Box",

	[0xAE] = "Chip Item",

	[0xB6] = "Turret",
	[0xB7] = "Slime Ball",
	[0xB8] = "Treasure Chest",
	[0xB9] = "Ghost Enemy",
	[0xBA] = "Spirit Orb Boss",

	[0xCE] = "Punching MechSuit Enemy",

	[0xD0] = "Lock-on Enemy",

	[0xD2] = "Jill",

	[0xD4] = "Water Propeller Item",
	[0xD5] = "Fly Propeller Item",

	[0xE0] = "Regenerate Wall",
	[0xE1] = "Regenerate Wall Wiggle",
	[0xE2] = "Diamond",
	[0xE3] = "Gold Pile",

	[0x117] = "Tank Dozer Wheel",
	[0x118] = "Dust/Smoke",

	[0x11A] = "Crawling Bomb",
};

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
	if script_mode == "Disabled" then
		return;
	end

	local row = 0;

	local numSlots = 0x40;

	gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, "Mode: "..script_mode, nil, 'bottomright');
	row = row + 1;
	if script_mode == "List" then
		for i = numSlots, 1, -1 do
			local currentSlotBase = Game.Memory.object_array["Address"][version] + (i-1) * object_struct_size;
			if memory.read_u32_le(currentSlotBase, Game.Memory.object_array["Domain"]) ~= 0 then
				local actorType = "Unknown";
				local objectType = memory.read_u16_le(currentSlotBase + 0x16, Game.Memory.object_array["Domain"]);
				if type(object_indexes[objectType]) == "string" then
					actorType = object_indexes[objectType];
				else
					actorType = toHexString(objectType);
				end

				local color = nil;
				if object_index == i then
					color = yellow_highlight;
				end

				local object_health = memory.read_u16_le(currentSlotBase + 0x56, Game.Memory.object_array["Domain"]);

				if objectType == 0x77 then
					local object_health = memory.read_u16_le(currentSlotBase + 0x84, Game.Memory.object_array["Domain"]);
					gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, actorType.." "..i.." ("..object_health.."): "..toHexString(currentSlotBase or 0), color, 'bottomright');
					row = row + 1;
				elseif object_health ~= 0 then
					local object_total_health = memory.read_u16_le(currentSlotBase + 0x58, Game.Memory.object_array["Domain"]);
					if actorType == "Unknown" then
						--local xPos = memory.read_s16_le(currentSlotBase + 0x24, Game.Memory.objectArray["Domain"]);
						--local yPos = memory.read_s16_le(currentSlotBase + 0x26, Game.Memory.objectArray["Domain"]);
						gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, i.." ("..object_health.."/"..object_total_health.."): "..toHexString(currentSlotBase or 0), color, 'bottomright');
						row = row + 1;
					else
						gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, actorType.." "..i.." ("..object_health.."/"..object_total_health.."): "..toHexString(currentSlotBase or 0), color, 'bottomright');
						row = row + 1;
					end
				else
					if actorType == "Unknown" then
						--local xPos = memory.read_s16_le(currentSlotBase + 0x24, Game.Memory.objectArray["Domain"]);
						--local yPos = memory.read_s16_le(currentSlotBase + 0x26, Game.Memory.objectArray["Domain"]);
						gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, i..": "..toHexString(currentSlotBase or 0), color, 'bottomright');
						row = row + 1;
					else
						gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, actorType.." "..i..": "..toHexString(currentSlotBase or 0), color, 'bottomright');
						row = row + 1;
					end
				end
			end
		end
	end
end

Game.OSDPosition = {2, 70}; -- Optional: OSD position in pixels from the top left corner of the screen, defaults to 2, 70 if not set by a game module
Game.OSD = {
	{"Movement", Game.getCurrentMovementState, Game.colorCurrentMovementState},
	{"Drill", Game.getDrillValue},
	{"Separator", 1},
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"X Velocity", Game.getXVelocity},
	{"Y Velocity", Game.getYVelocity},
	{"Separator", 1},
	{"dX"},
	{"dY"},
	{"Separator", 1},
	{"Max dY"},
	{"Max dXZ"},
	{"Odometer"},
	{"Separator", 1},
};

ScriptHawk.bindKeyRealtime("C", toggleObjectAnalysisToolsMode, true);

return Game; -- Return your Game table to ScriptHawk