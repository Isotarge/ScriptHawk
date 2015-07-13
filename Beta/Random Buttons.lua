max_boolean_inputs = 2;
booleanInputsReference = {
	"C Down",
	"C Left",
	"C Right",
	"C Up",
	"L",
	"R",
	"A",
	"B",
	"Z"
}

function pickRandomUniqueIndex(reference, alreadyChosen)
	indexFound = false;
	while not indexFound do
		index = math.random(#reference);
		indexFound = true;
		for i=0,#alreadyChosen do
			if index == alreadyChosen[i] then
				indexFound = false;
				break;
			end
		end
	end
	return index;
end

function generateBooleanInputs()
	numInputs = math.random(0, max_boolean_inputs);
	indexes = {};
	while #indexes < numInputs do
		table.insert(indexes, pickRandomUniqueIndex(booleanInputsReference, indexes));
	end

	chosenInputs = {};
	for i=0,#booleanInputsReference - 1 do
		chosenInputs[booleanInputsReference[i + 1]] = false;
		for j=0,#indexes do
			if indexes[j] == i then
				chosenInputs[booleanInputsReference[i + 1]] = true;
			end
		end
	end
	return chosenInputs;
end

function generateAnalogInputs()
	return {
		["X Axis"] = x,
		["Y Axis"] = y
	};
end

function getRandomAnalog()
	return math.random(-127, 128);
end

x = getRandomAnalog();
y = getRandomAnalog();

analogCounter = 0;
analogMaxMax = 200;
analogMax = math.random(1, analogMaxMax);

booleanInputs = generateBooleanInputs();
booleanCounter = 0;
booleanMaxMax = 59;
booleanMax = math.random(1, booleanMaxMax);

function randomPress()
	if not emu.islagged() then
		analogCounter = analogCounter + 1;
		if analogCounter >= analogMax then
			analogCounter = 0;
			analogMax = math.random(1, analogMaxMax);
			x = getRandomAnalog();
			y = getRandomAnalog();
		end

		booleanCounter = booleanCounter + 1;
		if booleanCounter >= booleanMax then
			booleanCounter = 0;
			booleanMax = math.random(1, booleanMaxMax);
			booleanInputs = generateBooleanInputs();
		end

		joypad.set(booleanInputs, 1);
		joypad.setanalog(generateAnalogInputs(), 1);
	end
end

event.onframestart(randomPress, "Random press");