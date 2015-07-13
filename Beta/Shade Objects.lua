local pointer_list = 0x7fbff0;
local object_pointers = {};
local kong_pointer = 0x7fbb4c;

local x_pos = 0x7c;
local y_pos = 0x80;
local z_pos = 0x84;
local shade_byte = 0x16D;

local max_objects = 0xff;
local radius = 100.0;

local function pull_objects ()
	object_pointers = {};
	local object_found = true;
	local object_no = 0;
	local kong_object = mainmemory.read_u24_be(kong_pointer + 1);

	while object_found do
		local pointer = mainmemory.read_u24_be(pointer_list + (object_no * 4) + 1);
		object_found = (pointer ~= 0xffffff) and (pointer ~= 0x000000) and (object_no <= max_objects);

		if object_found then
			if pointer ~= kong_object then
				--mainmemory.writebyte(pointer + shade_byte, 0x00);
				table.insert(object_pointers, pointer);
			end
			object_no = object_no + 1;
		end
	end

	-- Get kong position
	local kong_x = mainmemory.readfloat(kong_object + x_pos, true);
	local kong_y = mainmemory.readfloat(kong_object + y_pos, true);
	local kong_z = mainmemory.readfloat(kong_object + z_pos, true);

	local i;
	local x;
	local z;

	for i=1,#object_pointers do
		x = kong_x + radius;
		z = kong_z + radius;

		x = kong_x + math.cos(math.pi * 2 * i / #object_pointers) * radius;
		z = kong_z + math.sin(math.pi * 2 * i / #object_pointers) * radius;

		mainmemory.writefloat(object_pointers[i] + x_pos, x, true);
		mainmemory.writefloat(object_pointers[i] + y_pos, kong_y, true);
		mainmemory.writefloat(object_pointers[i] + z_pos, z, true);
	end
end

event.onframestart(pull_objects, "pull_objects");