local Game = {};

Game.maps = { "Not Implemented" };

--------------------
-- Region/Version --
--------------------

local linked_list_root;

function Game.detectVersion(romName)
	if bizstring.contains(romName, "Europe") then
		-- TODO
		return false;
	elseif bizstring.contains(romName, "Japan") then
		-- TODO
		return false;
	elseif bizstring.contains(romName, "USA") then
		linked_list_root = 0x137800;
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

--------------------------
-- Position object shit --
--------------------------

-- Update this each frame
local BK_Object_Base = 0x00;

local x_pos = 0x00;
local y_pos = 0x04;
local z_pos = 0x08;

local facing_angle = 0xd8;

----------------------
-- Linked List shit --
----------------------

local function is_pointer(number)
	return number >= 0x80000000 and number <= 0x803FFFFF;
end

-- Relative to object base
local previous_item = 0x00;
local next_item = 0x04;
local bk_pos_pointer = 61 * 4;

local function get_bk_address()
	local BK_Found = false;
	local bk_pointer, i;

	-- Get first object in linked list
	local object_base = mainmemory.read_u24_be(linked_list_root + next_item + 1);

	-- Iterate through linked list looking for pointer list, including pointer to BK Position
	while not BK_Found and object_base > 0 do
		-- Check if current linked list object has a pointer in the correct spot
		bk_pointer = mainmemory.read_u32_be(object_base + bk_pos_pointer);
		if is_pointer(bk_pointer) then
			BK_Found = true;

			-- Check for pointers near BK pointer to make sure
			for i=0,27 do
				if not is_pointer(mainmemory.read_u32_be(object_base + bk_pos_pointer + (i * 4))) then
					BK_Found = false;
				end
			end
		end

		-- Get next object in linked list
		object_base = mainmemory.read_u24_be(object_base + next_item + 1);
	end

	if BK_Found then
		return bk_pointer - 0x80000000;
	end
end

--------------
-- Position --
--------------

function Game.getXPosition()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + x_pos, true);
	end
	return 0;
end

function Game.getYPosition()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + y_pos, true);
	end
	return 0;
end

function Game.getZPosition()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + z_pos, true);
	end
	return 0;
end

function Game.setXPosition(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + x_pos, value, true);
	end
end

function Game.setYPosition(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + y_pos, value, true);
	end
end

function Game.setZPosition(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + z_pos, value, true);
	end
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + facing_angle, true);
	end
	return 0;
end

function Game.getYRotation()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + facing_angle, true);
	end
	return 0;
end

function Game.getZRotation()
	if type(BK_object_base) ~= "nil" then
		return mainmemory.readfloat(BK_object_base + facing_angle, true);
	end
	return 0;
end

function Game.setXRotation(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + facing_angle, value, true);
	end
end

function Game.setYRotation(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + facing_angle, value, true);
	end
end

function Game.setZRotation(value)
	if type(BK_object_base) ~= "nil" then
		mainmemory.writefloat(BK_object_base + facing_angle, value, true);
	end
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

function Game.initUI(form_handle, col, row, button_height, label_offset, dropdown_offset)
	-- TODO
end

function Game.eachFrame()
	BK_object_base = get_bk_address();
end

return Game;