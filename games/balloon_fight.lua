if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	OSD = {}, -- TODO
};

-- Game state
local object_array_capacity = 6;
local object_fields = {
	object_type = 0x7F, -- Byte
	object_types = {
		-- TODO
	},
	x_position = 0x91, -- u8
	y_position = 0x9A, -- u8
};

local projectile_array_capacity = 4;
local projectile_fields = {
	x_position = 0x490, -- u8
	y_position = 0x4A4, -- u8
};

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	ScriptHawk.hitboxDefaultColor = colors.white;
	ScriptHawk.hitboxDefaultXOffset = 0;
	ScriptHawk.hitboxDefaultYOffset = 0;
	ScriptHawk.hitboxDefaultWidth = 16;
	ScriptHawk.hitboxDefaultHeight = 16;
	return true;
end

function Game.getHitboxes()
	local hitboxes = {};

	for i = 0, object_array_capacity do
		table.insert(hitboxes, {
			xPosAddress = object_fields.x_position + i,
			yPosAddress = object_fields.y_position + i,
			typeValue = mainmemory.readbyte(object_fields.object_type + i),
		});
	end

	for i = 0, projectile_array_capacity do
		table.insert(hitboxes, {
			xPosAddress = projectile_fields.x_position + i,
			yPosAddress = projectile_fields.y_position + i,
			typeValue = 1, -- TODO: need to find this
		});
	end

	for i = 1, #hitboxes do
		local hitbox = hitboxes[i];
		hitbox.type = "Unknown ("..toHexString(hitbox.typeValue)..")";
		hitbox.x = mainmemory.read_u8(hitbox.xPosAddress);
		hitbox.y = mainmemory.read_u8(hitbox.yPosAddress);
		hitbox.index = i;
		hitbox.dragTag = i;

		if type(object_fields.object_types[hitbox.typeValue]) == "table" then
			local objectTypeTable = object_fields.object_types[hitbox.typeValue];
			hitbox.color = objectTypeTable.color;
			hitbox.xOffset = objectTypeTable.hitbox_x_offset;
			hitbox.yOffset = objectTypeTable.hitbox_y_offset;
			hitbox.width = objectTypeTable.hitbox_width;
			hitbox.height = objectTypeTable.hitbox_height;

			if type(objectTypeTable.name) == "string" then
				hitbox.type = object_fields.object_types[hitbox.typeValue].name.." "..toHexString(hitbox.typeValue);
			end
		end
	end
	return hitboxes;
end

function Game.getHitboxMouseOverText(hitbox)
	return {
		hitbox.type,
		hitbox.index..": "..hitbox.x..","..hitbox.y,
	};
end

function Game.setHitboxPosition(hitbox, x, y)
	mainmemory.write_u8(hitbox.xPosAddress, x);
	mainmemory.write_u8(hitbox.yPosAddress, y);
end

return Game;