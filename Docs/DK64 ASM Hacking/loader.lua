local hookBase = 0x7494;
local codeBase = 0x7FF500;
local maxCodeSize = 0xAFF;

local hook = {
	0x3C, 0x08, 0x80, 0x7F, 0x35, 0x08, 0xF5, 0x00,
	0x01, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00
};

local code_filename = forms.openfile(nil, nil, "Assembled R4300i Code|*.bin|All Files (*.*)|*.*");
if code_filename == "" then
	return;
end

-- Open the file and read the code
local input_file = assert(io.open(code_filename, "rb"));

local codeByte = 0x00;
local codeFound = true;
local i = 0;

while codeFound and i <= maxCodeSize do
	codeFound = false;
	codeByte = input_file:read(1);
	if codeByte then
		codeFound = true;
		mainmemory.writebyte(codeBase + i, string.byte(codeByte));
		i = i + 1;
	end
end
input_file:close();

-- Patch the hook
for i=1,#hook do
	mainmemory.writebyte(hookBase + (i - 1), hook[i]);
end

console.log("Done!");