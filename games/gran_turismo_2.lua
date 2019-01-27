if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

function mainmemory.read_s1616_le(address) -- Signed fixed point 16.16 little endian
	return mainmemory.read_s32_le(address) / 0x10000;
end

function mainmemory.write_s1616_le(address, value) -- Signed fixed point 16.16 little endian
	return mainmemory.write_u32_le(address, value * 0x10000);
end

function mainmemory.read_s2012_le(address) -- Signed fixed point 20.12 little endian
	return mainmemory.read_s32_le(address) / 0x1000;
end

function mainmemory.write_s2012_le(address, value) -- Signed fixed point 20.12 little endian
	return mainmemory.write_u32_le(address, value * 0x1000);
end

--[[
Testing procedure:

Infinite cash
Buy 3 Cars
Game.buyAllParts()
Game.dumpCars()
Enter a circuit you don't have a licence for and take me there to super speedway
expect no opponents
Win via autopilot
Game.goldAllLicenceTests()
Check licence screen

Tests:
- circuit_restriction_check
- autopilot
- map
- num_racers
- licence tests
- num_cars_garaged
- garage_base
- car_size
- cash

--]]

local Game = {
	squish_memory_table = true,
	Memory = { --     Version order: USA v1.0, USA v1.1, USA v1.2, Japan1.0, Japan1.1, Europe1.0
		--                           PASS      FAIL MAP  UNKNOWN   UNKNOWN   UNKNOWN   UNKNOWN
		circuit_restriction_check = {0x0148E0, 0x0148E0, 0x0148E0, 0x0148E0, 0x0148E0, 0x014908},
		x_position =                {0x0A9A00, 0x0A9AB0, 0x0A9D10, 0x0AA510, 0x0A9B70, 0x0A9D40}, -- autopilot - 0x12A
		y_position =                {0x0A9A08, 0x0A9AB8, 0x0A9D18, 0x0AA518, 0x0A9B78, 0x0A9D48}, -- TODO: I think this is part of a massive array of active cars in the race, figure out size of structs and number of them etc etc
		z_position =                {0x0A9A04, 0x0A9AB4, 0x0A9D14, 0x0AA514, 0x0A9B74, 0x0A9D44}, -- active cars seem to be 0xB40 big
		autopilot =                 {0x0A9B2A, 0x0A9BDA, 0x0A9E3A, 0x0AA63A, 0x0A9C9A, 0x0A9E6A}, -- TODO: Had 0xAA310 for J 1.0 and 0xA9970 for J 1.1 and 0xA9B40 for E, doublecheck
		map =                       {0x0AEF20, 0x0AEFD0, 0x0AF230, 0x0AFA30, 0x0AF090, 0x0AF260},
		num_racers =                {0x0AEF21, 0x0AEFD1, 0x0AF231, 0x0AFA31, 0x0AF091, 0x0AF261},
		licence_tests =             {0x1CA758, 0x1CAAC8, 0x1CACF8, 0x1CB158, 0x1CAB58, 0x1CAD28},
		num_cars_garaged =          {0x1CCFB4, 0x1CD324, 0x1CD554, 0x1CD9B4, 0x1CD3B4, 0x1CD584},
		garage_base =               {0x1CCFB8, 0x1CD328, 0x1CD558, 0x1CD9B8, 0x1CD3B8, 0x1CD588},
		car_size =                  {0xA4,     0xA4,     0xA4,     0xA4,     0xA4,     0xA4}, -- garaged
		active_car_array =          {nil,      nil,      nil,      nil,      nil,      nil}, -- TODO
		active_car_size =           {0xB40,    0xB40,    0xB40,    0xB40,    0xB40,    0xB40}, -- in race
		--color_names =             {nil,      nil,      0x0C6748, nil,      nil,      nil},
		--car_names =               {nil,      nil,      0x0D2B08, nil,      nil,      nil},
		cash =                      {0x1D0FC8, 0x1D1338, 0x1D1568, 0x1D19C8, 0x1D13C8, 0x1D1598}, -- Note: Japanese values are multiplied by 100 for display
		current_car =               {0x1D0FCC, 0x1D133C, 0x1D156C, 0x1D19CC, 0x1D13CC, 0x1D159C},
	},
	speedy_speeds = { 0.1 },
};

local car = {
	-- TODO: Fill in fields
	car_type = 0x00, -- u32_le -- TODO: Catalog these values and figure out how to read car name as string from game
	color = 0x04, -- u32_le
	rims = 0x08, -- u32_le
	brakes = 0x0C, -- u16_le -- TODO: Verify
	brake_controller = 0x0E, -- u16_le -- TODO: Verify
	-- ??? = 0x10, -- u16_le -- TODO: Verify
	base_weight = 0x12, -- u16_le -- TODO: Verify
	engine = 0x14, -- byte?
	gear_1 = 0x46, -- u16_le -- TODO: Verify
	gear_2 = 0x48, -- u16_le -- TODO: Verify
	gear_3 = 0x4A, -- u16_le -- TODO: Verify
	gear_4 = 0x4C, -- u16_le -- TODO: Verify
	gear_5 = 0x50, -- u16_le -- TODO: Verify
	gear_6 = 0x52, -- u16_le -- TODO: Verify
	gear_7 = 0x54, -- u16_le -- TODO: Verify
	gear_final = 0x56, -- u16_le -- TODO: Verify
	--gear_auto = 0x58, -- u16_le -- TODO: Verify
	brake_setting_front = 0x58, -- u8
	brake_setting_rear = 0x59, -- u8
	downforce_front = 0x60, -- u8 -- TODO: Verify
	downforce_rear = 0x61, -- u8 -- TODO: Verify
	-- Turbo blow off sound in this gap somewhere?
	-- Turbo boost gauge in this gap somewhere?
	ride_height_front = 0x64, -- u8
	ride_height_rear = 0x65, -- u8
	spring_rate_front = 0x68, -- u8 / 10
	spring_rate_rear = 0x69, -- u8 / 10
	damper_bound_front = 0x6C, -- u8 -- TODO: Left?
	damper_bound_front_2 = 0x6D, -- u8 -- TODO: Right?
	damper_rebound_front = 0x6E, -- u8 -- TODO: Left?
	damper_rebound_front_2 = 0x6F, -- u8 -- TODO: Right?
	damper_bound_rear = 0x70, -- u8 -- TODO: Left?
	damper_bound_rear_2 = 0x71, -- u8 -- TODO: Right?
	damper_rebound_rear = 0x72, -- u8 -- TODO: Left?
	damper_rebound_rear_2 = 0x73, -- u8 -- TODO: Right?
	stabilizer_front = 0x74, -- u8
	stabilizer_rear = 0x75, -- u8
	ascc_setting = 0x7C, -- u8 + 1
	tcsc_setting = 0x7D, -- u8 + 1
	price = 0x90, -- u32_le
	parts_purchased_bitfield = 0x9A, -- Array of bytes
	cleanliness = 0xA2, -- u16_le
};

local active_car = { -- TODO: Find velocity, angles, etc
	x_position = 0x00, -- signed fixed point 20.12 little endian
	y_position = 0x08, -- signed fixed point 20.12 little endian
	z_position = 0x04, -- signed fixed point 20.12 little endian
	autopilot = 0x12A, -- byte
};

function Game.getActiveCar(index)
	local numRacers = Game.getNumRacers();
	if numRacers >= 1 and numRacers <= 6 then
		return Game.Memory.active_car_array + index * Game.Memory.active_car_size;
	end
end

--[[
NTSC 1.0 NTSC 1.1 NTSC 1.2 Japanese PAL      Description
801ccfb8 801cd328 801cd558 801cd9b8 801cd588 Car code 1
801ccfba 801cd32a 801cd55a 801cd9ba 801cd58a Car Code 2
801ccfc4 801cd334 801cd564 801cd9c4 801cd594 Brakes
801ccfc6 801cd336 801cd566 801cd9c6 801cd596 Brake controller
801ccfc8 801cd338 801cd568 801cd9c8 801cd598 ?? ??
801ccfca 801cd33a 801cd56a 801cd9ca 801cd59a Base weight
801ccfcc 801cd33c 801cd56c 801cd9cc 801cd59c Engine
801ccfce 801cd33e 801cd56e 801cd9ce 801cd59e Drivetrain
801ccfd0 801cd340 801cd570 801cd9d0 801cd5a0 Transmission
801ccfd2 801cd342 801cd572 801cd9d2 801cd5a2 Suspension
801ccfd4 801cd344 801cd574 801cd9d4 801cd5a4 Differential
801ccfd6 801cd346 801cd576 801cd9d6 801cd5a6 Front Tires
801ccfd8 801cd348 801cd578 801cd9d8 801cd5a8 Rear Tires
801ccfda 801cd34a 801cd57a 801cd9da 801cd5aa Weight Reduction
801ccfdc 801cd34c 801cd57c 801cd9dc 801cd5ac (weight distribution)
801ccfde 801cd34e 801cd57e 801cd9de 801cd5ae Port/Polish
801ccfe0 801cd350 801cd580 801cd9e0 801cd5b0 Engine Balance
801ccfe2 801cd352 801cd582 801cd9e2 801cd5b2 Displacement
801ccfe4 801cd354 801cd584 801cd9e4 801cd5b4 Engine Rom Chip
801ccfe6 801cd356 801cd586 801cd9e6 801cd5b6 N/A Tuning
801ccfe8 801cd358 801cd588 801cd9e8 801cd5b8 Turbo
801ccfea 801cd35a 801cd58a 801cd9ea 801cd5ba Flywheel
801ccfec 801cd35c 801cd58c 801cd9ec 801cd5bc Clutch
801ccfee 801cd35e 801cd58e 801cd9ee 801cd5be Driveshaft
801ccff0 801cd360 801cd590 801cd9f0 801cd5c0 Exhaust
801ccff2 801cd362 801cd592 801cd9f2 801cd5c2 Intercooler
801ccff4 801cd364 801cd594 801cd9f4 801cd5c4 ASC
801ccff6 801cd366 801cd596 801cd9f6 801cd5c6 TCS
801ccff8 801cd368 801cd598 801cd9f8 801cd5c8 Rims code (part 3)
801ccffa 801cd36a 801cd59a 801cd9fa 801cd5ca Power multiplier
801ccffc 801cd36c 801cd59c 801cd9fc 801cd5cc Reverse gear
801ccffe 801cd36e 801cd59e 801cd9fe 801cd5ce 1st Gear
801cd000 801cd370 801cd5a0 801cda00 801cd5d0 2nd gear
801cd002 801cd372 801cd5a2 801cda02 801cd5d2 3rd gear
801cd004 801cd374 801cd5a4 801cda04 801cd5d4 4th gear
801cd006 801cd376 801cd5a6 801cda06 801cd5d6 5th gear
801cd008 801cd378 801cd5a8 801cda08 801cd5d8 6th gear
801cd00a 801cd37a 801cd5aa 801cda0a 801cd5da 7th gear
801cd00c 801cd37c 801cd5ac 801cda0c 801cd5dc Final gear
801cd00e 801cd37e 801cd5ae 801cda0e 801cd5de Auto gearing
801cd010 801cd380 801cd5b0 801cda10 801cd5e0 Brake control settings
801cd012 801cd382 801cd5b2 801cda12 801cd5e2 Downforce front/rear
801cd014 801cd384 801cd5b4 801cda14 801cd5e4 Turbo blow off sound
801cd016 801cd386 801cd5b6 801cda16 801cd5e6 Turbo boost gauge
801cd018 801cd388 801cd5b8 801cda18 801cd5e8 ?? ??
801cd022 801cd392 801cd5c2 801cda22 801cd5f2 Traction/suspension
801cd02e 801cd39e 801cd5ce 801cda2e 801cd5fe LSD/YAW settings
801cd030 801cd3a0 801cd5d0 801cda30 801cd600 LSD accel settings
801cd032 801cd3a2 801cd5d2 801cda32 801cd602 LSD decel settings
801cd036 801cd3a6 801cd5d6 801cda36 801cd606 ?? ??
801cd038 801cd3a8 801cd5d8 801cda38 801cd608 ?? ??
801cd03a 801cd3aa 801cd5da 801cda3a 801cd60a ?? ??
801cd03c 801cd3ac 801cd5dc 801cda3c 801cd60c ?? ??
801cd03e 801cd3ae 801cd5de 801cda3e 801cd60e ?? ??
801cd040 801cd3b0 801cd5e0 801cda40 801cd610 ?? ??
801cd042 801cd3b2 801cd5e2 801cda42 801cd612 ?? ??
801cd044 801cd3b4 801cd5e4 801cda44 801cd614 Body code 1
801cd046 801cd3b6 801cd5e6 801cda46 801cd616 Body code 2
801cd04c 801cd3bc 801cd5ec 801cda4c 801cd61c Weight - Drivetrain
801cd04e 801cd3be 801cd5ee 801cda4e 801cd61e Torque
801cd050 801cd3c0 801cd5f0 801cda50 801cd620 HP - [R] - auto
--]]

local parts_purchased = {
	{byte=0x00, bit=0, name="ASM Controller"},
	{byte=0x00, bit=1, name="Brakes: Sports"},
	{byte=0x00, bit=2, name="Brakes: Balance Controller"},
	{byte=0x00, bit=3, name="Clutch: Single"},
	{byte=0x00, bit=4, name="Clutch: Twin"},
	{byte=0x00, bit=5, name="Clutch: Triple"},
	{byte=0x00, bit=6, name="Engine: Computer", donotbuy=true},
	{byte=0x00, bit=7, name="Engine: Displacement Increase", donotbuy=true},

	-- 0x01 > 0 Unknown
	{byte=0x01, bit=1, name="Engine: Balancing", donotbuy=true},
	{byte=0x01, bit=2, name="Flywheel: Sports"},
	{byte=0x01, bit=3, name="Flywheel: Semi-Racing"},
	{byte=0x01, bit=4, name="Flywheel: Racing"},
	{byte=0x01, bit=5, name="Transmission: Sports"},
	{byte=0x01, bit=6, name="Transmission: Semi-Racing"},
	{byte=0x01, bit=7, name="Transmission: Racing"},

	{byte=0x02, bit=0, name="Intercooler: Sports"},
	{byte=0x02, bit=1, name="Intercooler: Racing"},
	{byte=0x02, bit=2, name="Weight Reduction: Stage 1", donotbuy=true},
	{byte=0x02, bit=3, name="Weight Reduction: Stage 2", donotbuy=true},
	{byte=0x02, bit=4, name="Weight Reduction: Stage 3", donotbuy=true},
	{byte=0x02, bit=5, name="LSD: 1 Way"},
	{byte=0x02, bit=6, name="LSD: 2 Way"},
	{byte=0x02, bit=7, name="LSD: 1.5 Way"},

	{byte=0x03, bit=0, name="LSD: Full"},
	{byte=0x03, bit=1, name="Yaw Controller"},
	{byte=0x03, bit=2, name="Exhaust: Sports"},
	{byte=0x03, bit=3, name="Exhaust: Semi-Racing"},
	{byte=0x03, bit=4, name="Exhaust: Racing"},
	{byte=0x03, bit=5, name="Engine: NA Stage 1"},
	{byte=0x03, bit=6, name="Engine: NA Stage 2"},
	{byte=0x03, bit=7, name="Engine: NA Stage 3"},

	{byte=0x04, bit=0, name="Engine: Port & Polish", donotbuy=true},
	{byte=0x04, bit=1, name="Driveshaft: Carbon"},
	{byte=0x04, bit=2, name="Racing Modification", donotbuy=true},
	{byte=0x04, bit=3, name="Suspension: Sports"},
	{byte=0x04, bit=4, name="Suspension: Semi-Racing"},
	{byte=0x04, bit=5, name="Suspension: Racing"},
	{byte=0x04, bit=6, name="TCS Controller"},
	{byte=0x04, bit=7, name="Tires: Sports"},

	{byte=0x05, bit=0, name="Tires: Racing Hard"},
	{byte=0x05, bit=1, name="Tires: Medium"},
	{byte=0x05, bit=2, name="Tires: Soft"},
	{byte=0x05, bit=3, name="Tires: Racing Super Soft"},
	{byte=0x05, bit=4, name="Tires: Simulation"},
	{byte=0x05, bit=5, name="Tires: Dirt"},
	{byte=0x05, bit=6, name="Turbo: Stage 1"},
	{byte=0x05, bit=7, name="Turbo: Stage 2"},

	{byte=0x06, bit=0, name="Turbo: Stage 3"},
	{byte=0x06, bit=1, name="Turbo: Stage 4"},
};

function isKnownPart(byte, bit)
	for k, v in pairs(parts_purchased) do
		if byte == v.byte and bit == v.bit then
			return true;
		end
	end
	return false;
end

function Game.buyPart(byte, bit, carIndex)
	if carIndex == nil then
		carIndex = Game.getCurrentCar();
	end
	local carBase = Game.getGaragedCar(carIndex);
	if not isRAM(carBase) then
		print("Error finding car in RAM.");
		return;
	end
	local partsArray = carBase + car.parts_purchased_bitfield;
	local currentValue = mainmemory.readbyte(partsArray + byte);
	mainmemory.writebyte(partsArray + byte, set_bit(currentValue, bit));
	print("Bought part at "..toHexString(byte).." > "..bit);
end

function Game.buyPartByName(name, carIndex)
	if carIndex == nil then
		carIndex = Game.getCurrentCar();
	end
	for k, v in pairs(parts_purchased) do
		if name == v.name then
			Game.buyPart(v.byte, v.bit, carIndex);
		end
	end
	return false;
end

function Game.buyAllParts(carIndex)
	if carIndex == nil then
		carIndex = Game.getCurrentCar();
	end
	local carBase = Game.getGaragedCar(carIndex);
	if not isRAM(carBase) then
		print("Error finding car in RAM.");
		return;
	end
	for k, v in pairs(parts_purchased) do
		if not v.donotbuy then
			Game.buyPart(v.byte, v.bit, carIndex);
		end
	end
end

function Game.sellPart(byte, bit, carIndex)
	if carIndex == nil then
		carIndex = Game.getCurrentCar();
	end
	local carBase = Game.getGaragedCar(carIndex);
	if not isRAM(carBase) then
		print("Error finding car in RAM.");
		return;
	end
	local partsArray = carBase + car.parts_purchased_bitfield;
	local currentValue = mainmemory.readbyte(partsArray + byte);
	mainmemory.writebyte(partsArray + byte, clear_bit(currentValue, bit));
	print("Sold part at "..toHexString(byte).." > "..bit);
end

function Game.sellPartByName(name, carIndex)
	if carIndex == nil then
		carIndex = Game.getCurrentCar();
	end
	for k, v in pairs(parts_purchased) do
		if name == v.name then
			Game.sellPart(v.byte, v.bit, carIndex);
		end
	end
	return false;
end

function Game.sellAllParts(carIndex)
	if carIndex == nil then
		carIndex = Game.getCurrentCar();
	end
	for k, v in pairs(parts_purchased) do
		Game.sellPart(v.byte, v.bit, carIndex);
	end
end

function Game.checkPart(byte, bit, carIndex)
	if carIndex == nil then
		carIndex = Game.getCurrentCar();
	end
	local carBase = Game.getGaragedCar(carIndex);
	if not isRAM(carBase) then
		return false;
	end
	local partsArray = carBase + car.parts_purchased_bitfield;
	local currentValue = mainmemory.readbyte(partsArray + byte);
	return check_bit(currentValue, bit);
end

local cachedParts = nil;
function checkParts(carIndex)
	if carIndex == nil then
		carIndex = Game.getCurrentCar();
	end
	local carBase = Game.getGaragedCar(carIndex);
	if not isRAM(carBase) then
		print("Error finding car in RAM.");
		return;
	end
	local partsArray = carBase + car.parts_purchased_bitfield;
	local arrayLength = 9;
	local currentParts = mainmemory.readbyterange(partsArray, arrayLength);
	if cachedParts == nil then
		cachedParts = currentParts;
		print("Parts cached, run again after buying a part.");
		return;
	end
	for i = 0, arrayLength do
		if currentParts[i] ~= cachedParts[i] then
			print("Byte "..i.." has changed from "..toHexString(cachedParts[i]).." to "..toHexString(currentParts[i]));
			for bit = 0, 7 do
				isSet = check_bit(currentParts[i], bit);
				wasSet = check_bit(cachedParts[i], bit);
				--print(bit.." isSet "..tostring(isSet).." wasSet "..tostring(wasSet));
				if isSet and (not wasSet) then
					if not isKnownPart(i, bit) then
						print("{byte="..toHexString(i, 2)..", bit="..bit..', name="Name"},');
					end
				end
			end
		end
	end
	cachedParts = currentParts;
end

local cachedCar = nil;
function checkCar()
	local currentCar = Game.getCurrentCar();
	local carBase = Game.getGaragedCar(currentCar);
	if not isRAM(carBase) then
		print("Error finding car in RAM.");
		return;
	end
	currentCar = mainmemory.readbyterange(carBase, Game.Memory.car_size);
	if cachedCar == nil then
		cachedCar = currentCar;
		print("Car cached, run again after buying a part.");
		return;
	end
	for i = 0, Game.Memory.car_size - 1 do
		if currentCar[i] ~= cachedCar[i] and i < 0x9A then
			print("Byte "..toHexString(carBase + i).." (car + "..toHexString(i)..") changed from "..toHexString(cachedCar[i]).." to "..toHexString(currentCar[i]));
		end
	end
	cachedCar = currentCar;
end

function Game.exportCar(carIndex)
	if carIndex == nil then
		carIndex = Game.getCurrentCar();
	end
	local carBase = Game.getGaragedCar(carIndex);
	local exportString = "";
	for i = 0, Game.Memory.car_size - 1 do
		local value = toHexString(mainmemory.readbyte(carBase + i), 2, "");
		exportString = exportString..value;
	end
	print("Export complete:");
	print('Game.importCar("'..exportString..'")');
end

function Game.importCar(importString, carIndex)
	if carIndex == nil then
		carIndex = Game.getCurrentCar();
	end
	local carBase = Game.getGaragedCar(carIndex, true);
	for i = 0, Game.Memory.car_size - 1 do
		local value = tonumber(string.sub(importString, i * 2 + 1, i * 2 + 2), 16);
		print("Writing "..toHexString(value).." to "..toHexString(carBase + i));
		mainmemory.writebyte(carBase + i, value);
	end
	local numCars = mainmemory.readbyte(Game.Memory.num_cars_garaged);
	if carIndex > numCars then
		print("Changing number of cars in garage from "..numCars.." to "..carIndex);
		mainmemory.writebyte(Game.Memory.num_cars_garaged, carIndex);
	end
	print("Import complete!");
end

function Game.getNumRacers()
	return mainmemory.readbyte(Game.Memory.num_racers);
end

function Game.setNumRacers(num)
	local numRacers = Game.getNumRacers();
	if numRacers >= 1 and numRacers <= 6 then
		mainmemory.writebyte(Game.Memory.num_racers, num);
	end
end

function Game.getCash()
	local value = mainmemory.read_u32_le(Game.Memory.cash);
	if Game.version == 4 or Game.version == 5 then  -- Note: Japanese values are multiplied by 100 for display
		return value * 100;
	end
	return value;
end

function Game.applyInfinites()
	mainmemory.write_u32_le(Game.Memory.cash, 99999999);
	-- TODO: Make sure tires are at optimal wear all the time
end

function Game.goldAllLicenceTests()
	-- Ordered S, IA, IB, IC, A, B
	-- Stride 0xA4 for some reason
	for i = 0, 59 do
		mainmemory.write_u16_le(Game.Memory.licence_tests + i * 0xA4, 0x0400);
	end
end

-- TODO: Units seem weird on these, could be 20.12 instead of 16.16
function Game.getXPosition()
	return mainmemory.read_s2012_le(Game.Memory.x_position);
end

function Game.getYPosition()
	return mainmemory.read_s2012_le(Game.Memory.y_position);
end

function Game.getZPosition()
	return mainmemory.read_s2012_le(Game.Memory.z_position);
end

--[[
function Game.setXPosition(value)
	return mainmemory.write_s2012_le(Game.Memory.x_position, value);
end

function Game.setYPosition(value)
	return mainmemory.write_s2012_le(Game.Memory.y_position, value);
end

function Game.setZPosition(value)
	return mainmemory.write_s2012_le(Game.Memory.z_position, value);
end
--]]

Game.maps = { -- This is correct for US V1.2, map indexes are different on different versions
	"000",
	"001 - Grand Valley Speedway TODO: Verify",
	"002 - Special Stage Route 5 Night TODO: Verify",
	"003 - Autumn Ring Mini TODO: Verify",
	"004 - Trial Mountain TODO: Verify",
	"005 - Rome Circuit TODO: Verify",
	"006 - Rome Night TODO: Verify",
	"007 - Rome Short TODO: Verify",
	"008 - Seattle Short TODO: Verify",
	"009",
	"010 - Grand Valley East TODO: Verify",
	"011",
	"012 - Red Rock Valley TODO: Verify",
	"013 - Deep Forest Raceway TODO: Verify",
	"014",
	"015 - Grindelwald TODO: Verify",
	"016 - Licence Test IA5",
	"017 - Licence Test IA6",
	"018 - Licence Test IB2",
	"019",
	"020",
	"021 - Licence Test IB1",
	"022 - Licence Test IA4",
	"023 - Licence Test B1/B2/B3/A1",
	"024 - Autumn Ring",
	"025",
	"026",
	"027",
	"028",
	"029 - Licence Test B4",
	"030 - Licence Test B5/IA1",
	"031 - Grand Valley Speedway",
	"032 - dart_test2 (beta)",
	"033 - Grindelwald", -- Licence Test S5
	"034 - Special Stage Route 5",
	"035 - l_20 (beta)",
	"036 - Licence Test IC7/IC8",
	"037 - Licence Test IA8",
	"038 - Licence Test IA3",
	"039 - Licence Test IB10/IA9",
	"040 - Leguna Seca", -- Licence Test S7
	"041 - Leguna Seca TODO: Verify",
	"042 - Leguna Seca TODO: Verify",
	"043 - Leguna Seca TODO: Verify",
	"044 - Licence Test IC10",
	"045 - Licence Test IC9/IA7",
	"046 - Test Course", -- Machine Test
	"047",
	"048 - Trial Mountain Circuit",
	"049 - Apricot Hill Speedway", -- Licence Test S10
	"050",
	"051",
	"052 - Smokey Mountain South",
	"053",
	"054",
	"055 - Green Forest Roadway",
	"056",
	"057 - Smokey Mountain North", -- Licence Test S3
	"058",
	"059 - Smokey Mountain North (Reverse)",
	"060 - Midfield Raceway", -- Licence Test S4
	"061",
	"062",
	"063 - Pikes Peak Hill Climb",
	"064 - Pikes Peak Hill Climb TODO: Verify",
	"065 - Pikes Peak Downhill TODO: Verify",
	"066 - Pikes Peak Downhill",
	"067",
	"068",
	"069",
	"070",
	"071",
	"072",
	"073",
	"074",
	"075",
	"076",
	"077",
	"078",
	"079",
	"080 - Rome Circuit", -- Licence Test S6
	"081 - Rome Night", -- Licence Test S9
	"082 - Rome Short Course",
	"083 - Super Speedway",
	"084 - Seattle Short Course",
	"085",
	"086 - Seattle Circuit Full Course", -- Licence Test S2
	"087",
	"088 - Grand Valley East Section",
	"089",
	"090 - Licence Test IC6",
	"091 - Licence Test IC5",
	"092 - Licence Test IB9",
	"093 - Test Course",
	"094",
	"095",
	"096 - Red Rock Valley",
	"097 - Tahiti Dirt Route 3",
	"098",
	"099 - Tahiti Dirt Route 3 (Reverse)",
	"100 - Tahiti Road", -- Licence Test S1
	"101",
	"102",
	"103 - Tahiti Maze", -- Licence Test S8
	"104 - Licence Test IB6",
	"105",
	"106",
	"107 - Licence Test IB8",
	"108",
	"109 - Licence Test A2",
	"110 - Licence Test IA2/IA10",
	"111",
	"112 - Deep Forest Raceway",
	"113 - Licence Test IC1/IC2",
	"114 - Licence Test IC3",
	"115 - Licence Test IC4",
	"116",
	"117 - Licence Test A5/A6",
	"118 - Licence Test B9/B10",
	"119 - License Test A7/A8/IB3/IB4",
	"120 - Licence Test B6/B7",
	"121 - Licence Test B8/A3/A4",
	"122 - Licence Test IB5",
	"123 - Licence Test IB7",
	"124 - Licence Test A9/A10",
	"125 - High Speed Ring",
};

function Game.getMap()
	return mainmemory.readbyte(Game.Memory.map);
end

function Game.getMapOSD()
	local currentMap = Game.getMap();
	local currentMapName = "Unknown";
	if Game.maps[currentMap + 1] ~= nil then
		currentMapName = Game.maps[currentMap + 1];
	end
	return currentMapName.." ("..currentMap..")";
end

function Game.setMap(index)
	local map = Game.getMap();
	if map == 0 or map == 83 or map >= #Game.maps then
		return;
	end
	mainmemory.writebyte(Game.Memory.map, index - 1);
end

function Game.getCurrentCar()
	return mainmemory.read_u16_le(Game.Memory.current_car);
end

function Game.getCurrentCarOSD()
	local currentCar = Game.getCurrentCar();
	local numCars = mainmemory.readbyte(Game.Memory.num_cars_garaged) - 1;
	local carBase = Game.getGaragedCar(currentCar);
	if isRAM(carBase) then
		return currentCar.."/"..numCars.." - "..toHexString(carBase);
	end
	return currentCar.."/"..numCars.." - Unknown Address";
end

function Game.getGaragedCar(index, allowOOB)
	local numCars = mainmemory.readbyte(Game.Memory.num_cars_garaged);
	if not allowOOB and (numCars == 0 or index >= numCars) then
		return;
	end
	return Game.Memory.garage_base + index * Game.Memory.car_size;
end

function Game.dumpCars()
	local numCars = mainmemory.readbyte(Game.Memory.num_cars_garaged);
	if numCars == 0 then
		print("There are no cars in your garage.");
		return;
	end
	for i = 0, numCars - 1 do
		local carBase = Game.Memory.garage_base + i * Game.Memory.car_size;
		local color = mainmemory.read_u32_le(carBase + car.color);
		local engine = mainmemory.read_u32_le(carBase + car.engine);
		local rims = mainmemory.read_u32_le(carBase + car.rims);
		local price = mainmemory.read_u32_le(carBase + car.price);
		local cleanliness = mainmemory.read_u16_le(carBase + car.cleanliness);
		dprint("Car "..i.." at "..toHexString(carBase));
		dprint("Color: "..toHexString(color));
		dprint("Engine: "..toHexString(engine));
		dprint("Rims: "..toHexString(rims));
		dprint("Price: "..price);
		dprint("Cleanliness: "..toHexString(cleanliness));
		dprint("Bought parts:");
		local boughtParts = 0;
		local totalParts = 0;
		for k, v in pairs(parts_purchased) do
			if Game.checkPart(v.byte, v.bit, i) then
				dprint(toHexString(v.byte).." > "..v.bit.." - "..v.name);
				boughtParts = boughtParts + 1;
			end
			totalParts = totalParts + 1;
		end
		dprint("Parts "..boughtParts.."/"..totalParts);
		local springRateFront = mainmemory.read_u8(carBase + car.spring_rate_front) / 10;
		local springRateRear = mainmemory.read_u8(carBase + car.spring_rate_rear) / 10;
		local brakeSettingFront = mainmemory.read_u8(carBase + car.brake_setting_front);
		local brakeSettingRear = mainmemory.read_u8(carBase + car.brake_setting_rear);
		local rideHeightFront = mainmemory.read_u8(carBase + car.ride_height_front);
		local rideHeightRear = mainmemory.read_u8(carBase + car.ride_height_rear);
		local stabilizerFront = mainmemory.read_u8(carBase + car.stabilizer_front);
		local stabilizerRear = mainmemory.read_u8(carBase + car.stabilizer_rear);
		local damperBoundFront = mainmemory.read_u8(carBase + car.damper_bound_front);
		local damperBoundRear = mainmemory.read_u8(carBase + car.damper_bound_rear);
		local damperReboundFront = mainmemory.read_u8(carBase + car.damper_rebound_front);
		local damperReboundRear = mainmemory.read_u8(carBase + car.damper_rebound_rear);
		local ASCCSetting = mainmemory.read_u8(carBase + car.ascc_setting) + 1;
		local TCSCSetting = mainmemory.read_u8(carBase + car.tcsc_setting) + 1;
		dprint("Spring Rate: "..springRateFront.." front "..springRateRear.." rear");
		dprint("Brake Setting: "..brakeSettingFront.." front "..brakeSettingRear.." rear");
		dprint("Ride height front: "..rideHeightFront.." front "..rideHeightRear.." rear");
		dprint("Damper Bound: "..damperBoundFront.." front "..damperBoundRear.." rear");
		dprint("Damper Rebound: "..damperReboundFront.." front "..damperReboundRear.." rear");
		--dprint("Camber: TODO front TODO rear");
		--dprint("Toe: TODO front TODO rear");
		dprint("Stabilizer: "..stabilizerFront.." front "..stabilizerRear.." rear");
		dprint("ASCC Setting: "..ASCCSetting);
		dprint("TCSC Setting: "..TCSCSetting);
		--[[
		-- TODO: Verify these
		local gear1 = mainmemory.read_u16_le(carBase + car.gear_1);
		local gear2 = mainmemory.read_u16_le(carBase + car.gear_2);
		local gear3 = mainmemory.read_u16_le(carBase + car.gear_3);
		local gear4 = mainmemory.read_u16_le(carBase + car.gear_4);
		local gear5 = mainmemory.read_u16_le(carBase + car.gear_5);
		local gear6 = mainmemory.read_u16_le(carBase + car.gear_6);
		local gear7 = mainmemory.read_u16_le(carBase + car.gear_7);
		dprint("Gear 1 "..toHexString(gear1));
		dprint("Gear 2 "..toHexString(gear2));
		dprint("Gear 3 "..toHexString(gear3));
		dprint("Gear 4 "..toHexString(gear4));
		dprint("Gear 5 "..toHexString(gear5));
		dprint("Gear 6 "..toHexString(gear6));
		dprint("Gear 7 "..toHexString(gear7));
		--]]
		dprint();
	end
	print_deferred();
end

function Game.fuckGears()
	local numCars = mainmemory.readbyte(Game.Memory.num_cars_garaged);
	if numCars == 0 then
		print("There are no cars in your garage.");
		return;
	end
	for i = 0, numCars - 1 do
		local carBase = Game.Memory.garage_base + i * Game.Memory.car_size;
		mainmemory.write_u16_le(carBase + car.gear_1, 0);
		mainmemory.write_u16_le(carBase + car.gear_2, 0);
		mainmemory.write_u16_le(carBase + car.gear_3, 0);
		mainmemory.write_u16_le(carBase + car.gear_4, 0);
		mainmemory.write_u16_le(carBase + car.gear_5, 0);
		mainmemory.write_u16_le(carBase + car.gear_6, 0);
		mainmemory.write_u16_le(carBase + car.gear_7, 0);
	end
end

function Game.enableAutopilot()
	if mainmemory.read_u16_le(Game.Memory.autopilot) == 0x0000 then
		mainmemory.write_u16_le(Game.Memory.autopilot, 0x0001);
	end
end

function Game.disableAutopilot()
	if mainmemory.read_u16_le(Game.Memory.autopilot) == 0x0001 then
		mainmemory.write_u16_le(Game.Memory.autopilot, 0x0000);
	end
end

function Game.toggleAutopilot()
	local currentValue = mainmemory.read_u16_le(Game.Memory.autopilot);
	if currentValue == 0x0001 then
		Game.disableAutopilot();
	elseif currentValue == 0x0000 then
		Game.enableAutopilot();
	end
end

function Game.getAutopilotState()
	if mainmemory.read_u16_le(Game.Memory.autopilot) == 0x0001 then
		return "On";
	end
	return "Off";
end

function Game.initUI()
	if not TASSafe then
		ScriptHawk.UI.checkbox(0, 6, "ignore_restrictions", "Ignore Restrictions");
		forms.setproperty(ScriptHawk.UI.form_controls.ignore_restrictions, "Width", ScriptHawk.UI.col(6));
		ScriptHawk.UI.form_controls.num_racers_dropdown = forms.dropdown(ScriptHawk.UI.options_form, { "1", "2", "3", "4", "5", "6" }, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(7) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(2) + 8, ScriptHawk.UI.button_height);
		ScriptHawk.UI.checkbox(3, 7, "set_num_racers", "Set Num Racers");
		ScriptHawk.UI.button(10, 0, {4, 10}, nil, nil, "Toggle Autopilot", Game.toggleAutopilot);
		ScriptHawk.UI.button(10, 2, {4, 10}, nil, nil, "Buy Parts", Game.buyAllParts);
	end
	ScriptHawk.UI.button(10, 1, {4, 10}, nil, nil, "Dump Cars", Game.dumpCars);
end

function Game.eachFrame()
	if mainmemory.read_u16_le(Game.Memory.circuit_restriction_check) == 0x000C then
		if ScriptHawk.UI.ischecked("ignore_restrictions") then
			mainmemory.write_u16_le(Game.Memory.circuit_restriction_check + 2, 0x1000);
		else
			mainmemory.write_u16_le(Game.Memory.circuit_restriction_check + 2, 0x4310);
		end
	end

	if ScriptHawk.UI.ischecked("set_num_racers") then
		local numRacers = tonumber(forms.getproperty(ScriptHawk.UI.form_controls.num_racers_dropdown, "SelectedItem"));
		if numRacers >= 1 and numRacers <= 6 then
			Game.setNumRacers(numRacers);
		end
	end
end

Game.OSD = {
	{"Autopilot", Game.getAutopilotState, category="general"},
	{"Car", Game.getCurrentCarOSD, category="general"},
	{"Map", Game.getMapOSD, category="general"},
	{"Cash", Game.getCash, category="general"},
	{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
};

return Game;