if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

local Game = {
	Memory = {
		x_position = 0x242, -- 3 bytes, sub.pixel.major
		y_position = 0x245, -- 3 bytes?, sub.pixel.major?
		x_velocity = 0x248, -- Signed Fixed 8.8
		y_velocity = 0x24A, -- Signed Fixed 8.8?
		current_transformation = 0x24F, -- Byte
		max_transformation_unlocked = 0xF5B, -- Byte
		door_timer = 0x26F, -- Byte
		-- Swords
		sword_legendary = 0xF20,
		sword_ivory = 0xF21,
		sword_mithril = 0xF22,
		sword_shogun = 0xF23,
		sword_crystal = 0xF24,
		sword_thunder = 0xF25,
		sword_magical = 0xF26,
		sword_lucky = 0xF27,
		sword_muramasa = 0xF28,
		sword_tasmanian = 0xF29,
		-- Shields
		shield_legendary = 0xF2A,
		shield_ivory = 0xF2B,
		shield_mithril = 0xF2C,
		shield_shogun = 0xF2D,
		shield_crystal = 0xF2E,
		shield_knight = 0xF2F,
		shield_dancing = 0xF30,
		shield_aqua = 0xF31,
		shield_master = 0xF32,
		shield_heavenly = 0xF33,
		-- Armor
		armor_legendary = 0xF34,
		armor_ivory = 0xF35,
		armor_mithril = 0xF36,
		armor_shogun = 0xF37,
		armor_crystal = 0xF38,
		armor_goblin = 0xF39,
		armor_samurai = 0xF3A,
		armor_dragon = 0xF3B,
		armor_prince = 0xF3C,
		armor_hades = 0xF3D,
		--
		fire_ball = 0xF3E,
		tornado = 0xF3F,
		arrow = 0xF40,
		boomerang = 0xF41,
		thunder = 0xF42,
		stone = 0xF48,
		key = 0xF49,
		lives = 0xF4A,
		health = 0xF52, -- 2 byte
		max_health = 0xF54, -- byte
		gold_ones = 0xF55,
		gold_tens = 0xF56,
		gold_hundreds = 0xF57,
		gold_thousands = 0xF58,
		gold_ten_thousands = 0xF59,
		gold_hundred_thousands = 0xF5A,
		rng_pointer = 0x10DC,
		rng_base = 0x10A5,
		boss_x_position = 0x1150,
		boss_y_position = 0x1153,
		boss_health = 0x116A,
	},
	transformations = {
		[0] = "Hu-Man",
		[1] = "Lizard-Man",
		[2] = "Mouse-Man",
		[3] = "Piranha-Man",
		[4] = "Lion-Man",
		[5] = "Bird-Man",
	},
};

function Game.getCurrentTransformation()
	local value = mainmemory.readbyte(Game.Memory.current_transformation);
	if Game.transformations[value] ~= nil then
		return Game.transformations[value];
	end
	return value;
end

function Game.setCurrentTransformation(value)
	mainmemory.writebyte(Game.Memory.current_transformation, value);
end

function Game.setCurrentTransformationFromDropdown()
	local selectedTransformation = forms.getproperty(ScriptHawk.UI.form_controls["Character Dropdown"], "SelectedItem");
	for k, v in pairs(Game.transformations) do
		if selectedTransformation == v then
			Game.setCurrentTransformation(k);
			return;
		end
	end
end

function Game.detectVersion(romName, romHash)
	ScriptHawk.dpad.joypad.enabled = false;
	ScriptHawk.dpad.key.enabled = false;
	return true;
end

function Game.getConsumableValue(address)
	return bit.clear(mainmemory.readbyte(address), 7);
end

function Game.setConsumableValue(address, value)
	if value > 99 then
		value = 99;
	end
	if value < 0 then
		value = 0;
	end
	local currentValue = mainmemory.readbyte(address);
	local isEquipped = bit.check(currentValue, 7);
	if isEquipped then
		mainmemory.writebyte(address, bit.set(value, 7));
	else
		mainmemory.writebyte(address, value);
	end
end

function Game.applyInfinites()
	Game.setConsumableValue(Game.Memory.fire_ball, 99);
	Game.setConsumableValue(Game.Memory.tornado, 99);
	Game.setConsumableValue(Game.Memory.arrow, 99);
	Game.setConsumableValue(Game.Memory.boomerang, 99);
	Game.setConsumableValue(Game.Memory.thunder, 99);
	Game.setConsumableValue(Game.Memory.key, 99);
	local maxHealth = Game.getMaxHealth();
	mainmemory.write_u16_le(Game.Memory.health, maxHealth * 0xD0);
end

function Game.giveStone()
	local currentValue = Game.getConsumableValue(Game.Memory.stone);
	Game.setConsumableValue(Game.Memory.stone, currentValue + 1);
end

function Game.removeStone()
	local currentValue = Game.getConsumableValue(Game.Memory.stone);
	Game.setConsumableValue(Game.Memory.stone, currentValue - 1);
end

function Game.giveMaxStones()
	Game.setConsumableValue(Game.Memory.stone, 99);
end

function Game.giveMaxLives()
	mainmemory.writebyte(Game.Memory.lives, 99);
end

function Game.giveMaxGold()
	mainmemory.writebyte(Game.Memory.gold_ones, 9);
	mainmemory.writebyte(Game.Memory.gold_tens, 9);
	mainmemory.writebyte(Game.Memory.gold_hundreds, 9);
	mainmemory.writebyte(Game.Memory.gold_thousands, 9);
	mainmemory.writebyte(Game.Memory.gold_ten_thousands, 9);
	mainmemory.writebyte(Game.Memory.gold_hundred_thousands, 9);
end

function Game.buyAllItems()
	-- Swords
	mainmemory.writebyte(Game.Memory.sword_legendary, 0x81); -- Equipped
	mainmemory.writebyte(Game.Memory.sword_ivory, 1);
	mainmemory.writebyte(Game.Memory.sword_mithril, 1);
	mainmemory.writebyte(Game.Memory.sword_shogun, 1);
	mainmemory.writebyte(Game.Memory.sword_crystal, 1);
	mainmemory.writebyte(Game.Memory.sword_thunder, 1);
	mainmemory.writebyte(Game.Memory.sword_magical, 1);
	mainmemory.writebyte(Game.Memory.sword_lucky, 1);
	mainmemory.writebyte(Game.Memory.sword_muramasa, 1);
	mainmemory.writebyte(Game.Memory.sword_tasmanian, 1);
	-- Shields
	mainmemory.writebyte(Game.Memory.shield_legendary, 0x81); -- Equipped
	mainmemory.writebyte(Game.Memory.shield_ivory, 1);
	mainmemory.writebyte(Game.Memory.shield_mithril, 1);
	mainmemory.writebyte(Game.Memory.shield_shogun, 1);
	mainmemory.writebyte(Game.Memory.shield_crystal, 1);
	mainmemory.writebyte(Game.Memory.shield_knight, 1);
	mainmemory.writebyte(Game.Memory.shield_dancing, 1);
	mainmemory.writebyte(Game.Memory.shield_aqua, 1);
	mainmemory.writebyte(Game.Memory.shield_master, 1);
	mainmemory.writebyte(Game.Memory.shield_heavenly, 1);
	-- Armor
	mainmemory.writebyte(Game.Memory.armor_legendary, 0x81); -- Equipped
	mainmemory.writebyte(Game.Memory.armor_ivory, 1);
	mainmemory.writebyte(Game.Memory.armor_mithril, 1);
	mainmemory.writebyte(Game.Memory.armor_shogun, 1);
	mainmemory.writebyte(Game.Memory.armor_crystal, 1);
	mainmemory.writebyte(Game.Memory.armor_goblin, 1);
	mainmemory.writebyte(Game.Memory.armor_samurai, 1);
	mainmemory.writebyte(Game.Memory.armor_dragon, 1);
	mainmemory.writebyte(Game.Memory.armor_prince, 1);
	mainmemory.writebyte(Game.Memory.armor_hades, 1);
end

function Game.readPosition(base)
	local sub = mainmemory.readbyte(base + 0);
	local minor = mainmemory.readbyte(base + 1);
	local major = mainmemory.readbyte(base + 2);
	return (major * 256) + minor + (sub / 256);
end

function Game.writePosition(base, value)
	local flooredValue = math.floor(value);
	local remainder = value - flooredValue;

	local sub = remainder * 256;
	local minor = flooredValue % 256;
	local major = math.floor(flooredValue / 256);

	mainmemory.writebyte(base + 0, sub);
	mainmemory.writebyte(base + 1, minor);
	mainmemory.writebyte(base + 2, major);
end

function Game.getLives()
	return mainmemory.readbyte(Game.Memory.lives);
end

function Game.getHealth()
	return mainmemory.read_u16_le(Game.Memory.health) / 0xD0;
end

function Game.getMaxHealth()
	return mainmemory.readbyte(Game.Memory.max_health) / 0x0D;
end

function Game.getHealthOSD()
	return round(Game.getHealth(), precision).."/"..round(Game.getMaxHealth(), precision);
end

function Game.getBossHP()
	return mainmemory.read_u16_le(Game.Memory.boss_health) / 0x10;
end

function Game.getBossXPosition()
	return Game.readPosition(Game.Memory.boss_x_position);
end

function Game.getBossYPosition()
	return Game.readPosition(Game.Memory.boss_y_position);
end

function Game.getDoorTimer()
	return mainmemory.readbyte(Game.Memory.door_timer);
end

function Game.getXPosition()
	return Game.readPosition(Game.Memory.x_position);
end

function Game.getYPosition()
	return Game.readPosition(Game.Memory.y_position);
end

function Game.setXPosition(value)
	Game.writePosition(Game.Memory.x_position, value);
end

function Game.setYPosition(value)
	Game.writePosition(Game.Memory.y_position, value);
end

function Game.getXVelocity()
	return mainmemory.read_s16_le(Game.Memory.x_velocity) / 256;
end

function Game.setXVelocity(value)
	mainmemory.write_s16_le(Game.Memory.x_velocity, value * 256);
end

function Game.getYVelocity()
	return mainmemory.read_s16_le(Game.Memory.y_velocity) / 256;
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.button(0, 6, {4, 10}, nil, nil, "Max Lives", Game.giveMaxLives);
		ScriptHawk.UI.button(0, 7, {4, 10}, nil, nil, "Max Gold", Game.giveMaxGold);

		ScriptHawk.UI.button(5, 5, {4, 10}, nil, nil, "Add Stone", Game.giveStone);
		ScriptHawk.UI.button(5, 6, {4, 10}, nil, nil, "Remove Stone", Game.removeStone);
		ScriptHawk.UI.button(5, 7, {4, 10}, nil, nil, "Max Stones", Game.giveMaxStones);

		ScriptHawk.UI.button(10, 5, {4, 10}, nil, nil, "Buy Items", Game.buyAllItems);

		-- Character Dropdown
		ScriptHawk.UI.form_controls["Character Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, { "Hu-Man", "Lizard-Man", "Mouse-Man", "Piranha-Man", "Lion-Man", "Bird-Man" }, ScriptHawk.UI.col(5) - ScriptHawk.UI.dropdown_offset + 2, ScriptHawk.UI.row(4) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 8, ScriptHawk.UI.button_height);
		ScriptHawk.UI.button(10, 4, {4, 10}, nil, nil, "Set Transformation", Game.setCurrentTransformationFromDropdown);
	end

	local RNGColBase = 10;
	ScriptHawk.UI.checkbox(RNGColBase, 6, "Toggle RNG Checkbox", "Show RNG", true);
	-- RNG Slots control
	ScriptHawk.UI.form_controls.rng_slots_label = forms.label(ScriptHawk.UI.options_form, "Slots:", ScriptHawk.UI.col(RNGColBase), ScriptHawk.UI.row(7) + ScriptHawk.UI.label_offset, 40, 14);
	ScriptHawk.UI.button({RNGColBase + 3, -28}, 7, {ScriptHawk.UI.button_height}, nil, "decrease_rng_button", "-", Game.decreaseRNGSlots);
	ScriptHawk.UI.button({RNGColBase + 4, -28}, 7, {ScriptHawk.UI.button_height}, nil, "increase_rng_button", "+", Game.increaseRNGSlots);
	ScriptHawk.UI.form_controls.rng_slots_value_label = forms.label(ScriptHawk.UI.options_form, get_ready_blue_min, ScriptHawk.UI.col(RNGColBase + 4), ScriptHawk.UI.row(7) + ScriptHawk.UI.label_offset, 32, 14);
end

-- RNG Stuff
-- Based on research by The8bitbeast, 2016

local RNGSlots = 6;
function Game.increaseRNGSlots()
	RNGSlots = RNGSlots + 1;
	RNGSlots = math.min(RNGSlots, 0x37);
end

function Game.decreaseRNGSlots()
	RNGSlots = RNGSlots - 1;
	RNGSlots = math.max(RNGSlots, 1);
end

function Game.getRNGSlot(index)
	local pointer = mainmemory.read_u8(Game.Memory.rng_pointer);
	local slot = {
		address = Game.Memory.rng_base + pointer + index,
	};
	while slot.address >= Game.Memory.rng_pointer do -- Could probably use mod for this?
		slot.address = slot.address - 0x37; -- Size of RNG table
	end
	slot.value = mainmemory.read_u8(slot.address);
	return slot;
end

function Game.isCrit(value)
	return value % 8 == 7 or (value % 8 == 6 and ((value < 0x80 and value > 0x3F) or (value > 0xBF)));
end

function Game.renderRNGSlot(slot)
	local crit = "";
	if Game.isCrit(slot.value) then
		crit = "(crit) ";
	end
	return crit..toHexString(slot.value, 2, "").." - "..toHexString(slot.address, 4, "");
end

function Game.drawUI()
	forms.settext(ScriptHawk.UI.form_controls.rng_slots_value_label, RNGSlots);

	local row = 0;

	if ScriptHawk.UI.ischecked("Toggle RNG Checkbox") then
		gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, "RNG: "..RNGSlots.." Slots", nil, 'bottomright');
		row = row + 1;

		for i = 1, RNGSlots do
			gui.text(Game.OSDPosition[1], 2 + Game.OSDRowHeight * row, Game.renderRNGSlot(Game.getRNGSlot(i)), nil, 'bottomright');
			row = row + 1;
		end
	end
end

Game.OSD = {
	{"Lives", Game.getLives, category="general"},
	{"Health", Game.getHealthOSD, category="general"},
	{"Transformation", Game.getCurrentTransformation, category="general"};
	{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"X Velocity", Game.getXVelocity, category="speed"},
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"dX", category="positionStats"},
	{"dY", category="positionStats"},
	{"Separator"},
	{"Door Timer", Game.getDoorTimer, category="general"},
	{"Separator"},
	{"Boss X", Game.getBossXPosition, category="general"},
	{"Boss Y", Game.getBossYPosition, category="general"},
	{"Boss HP", Game.getBossHP, category="general"},
};

return Game;