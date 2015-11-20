--------------------
-- Deferred print --
-- HT Notwa       --
--------------------

local __dprinted = {};

function dprint(...) -- defer print
	-- helps with lag from printing directly to Bizhawk's console
	table.insert(__dprinted, {...});
end

function dprintf(fmt, ...)
	table.insert(__dprinted, fmt:format(...));
end

function print_deferred()
	local buff = '';
	for i, t in ipairs(__dprinted) do
		if type(t) == 'string' then
			buff = buff..t..'\n';
		elseif type(t) == 'table' then
			local s = '';
			for j, v in ipairs(t) do
				s = s..tostring(v);
				if j ~= #t then s = s..'\t' end
			end
			buff = buff..s..'\n';
		end
	end
	if #buff > 0 then
		print(buff:sub(1, #buff - 1));
	end
	__dprinted = {};
end

----------------------
-- Helper functions --
----------------------

-- TODO: Can I replace ScriptHawk's toHexString function with this without breaking anything?
-- Desired length is really fucking cool
function toHexString(value, desiredLength)
	value = string.format("%X", value or 0);
	desiredLength = desiredLength or string.len(value);
	while string.len(value) < desiredLength do
		value = "0"..value;
	end
	return value;
end

-- Output gameshark code
function outputGamesharkCode(bytes, base, skipZeroes)
	skipZeroes = skipZeroes or false;
	skippedZeroes = 0;
	if type(bytes) == "table" and #bytes > 0 and #bytes % 2 == 0 then
		for i=1,#bytes,2 do
			if not (skipZeroes and bytes[i] == 0x00 and bytes[i + 1] == 0x00) then
				dprint("81"..toHexString(base + i - 1, 6).." "..toHexString(bytes[i], 2)..toHexString(bytes[i + 1], 2));
			else
				skippedZeroes = skippedZeroes + 1;
			end
		end
	end
	print_deferred();
	return skippedZeroes;
end

--------------------
-- The main event --
--------------------

local hookBase = 0x7494;
local codeBase = 0x7FF500;
local maxCodeSize = 0xAFF;

local hook = {
	0x3C, 0x08, 0x80, 0x7F, 0x35, 0x08, 0xF5, 0x00,
	0x01, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00
};
local code = {};

local code_filename = forms.openfile(nil, nil, "Assembled R4300i Code|*.bin|All Files (*.*)|*.*");
if code_filename == "" then
	return;
end

-- Open the file and read the code
local input_file = assert(io.open(code_filename, "rb"));

local codeByte = 0x00;
local i = 0;

while codeByte and i <= maxCodeSize do
	codeByte = input_file:read(1);
	if codeByte then
		mainmemory.writebyte(codeBase + i, string.byte(codeByte));
		table.insert(code, string.byte(codeByte));
		i = i + 1;
	end
end
input_file:close();

-- Patch the hook
for i=1,#hook do
	mainmemory.writebyte(hookBase + (i - 1), hook[i]);
end

outputGamesharkCode(hook, hookBase);
print();
local skippedZeroes = outputGamesharkCode(code, codeBase, true);
dprint();
if skippedZeroes > 0 then
	dprint("Removed "..skippedZeroes.." unneeded lines from resulting GS code.");
end
dprint("Done!");
print_deferred();