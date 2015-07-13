pointer_list = 0x7fbff0;
object_pointers = {};
kong_pointer = 0x7fbb4c;

x_pos = 0x7c;
y_pos = 0x80;
z_pos = 0x84;
shade_byte = 0x16D;

radius = 100.0;

function pull_objects ()
	object_pointers = {};
	object_found = true;
	object_no = 0;
	object_count = 0;
	kong_object = mainmemory.read_u24_be(kong_pointer + 1);

	while object_found do
		pointer = mainmemory.read_u24_be(pointer_list + (object_no * 4) + 1);
		object_found = pointer ~= 0xffffff;

		if object_found then
			if pointer ~= kong_object then
				--mainmemory.writebyte(pointer + shade_byte, 0x00);
				object_pointers[object_count] = pointer;
				object_count = object_count + 1;
			end
			object_no = object_no + 1;
		end
	end

	-- Get kong position
	kong_x = mainmemory.readfloat(kong_object + x_pos, true);
	kong_y = mainmemory.readfloat(kong_object + y_pos, true);
	kong_z = mainmemory.readfloat(kong_object + z_pos, true);

	i = 0;
	--console.log("kong("..kong_x..","..kong_z..")\n");
	while i < object_count do
		x = kong_x + radius;
		z = kong_z + radius;

		x = kong_x + math.cos(math.pi * 2 * i / object_count) * radius;
		z = kong_z + math.sin(math.pi * 2 * i / object_count) * radius;

		mainmemory.writefloat(object_pointers[i] + x_pos, x, true);
		mainmemory.writefloat(object_pointers[i] + y_pos, kong_y, true);
		mainmemory.writefloat(object_pointers[i] + z_pos, z, true);

		i = i + 1;
	end
end

event.onframestart(pull_objects, "pull_objects");