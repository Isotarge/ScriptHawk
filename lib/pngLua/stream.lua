class = require 'lib.pngLua.30log'
Stream = class()
Stream.data = ""
Stream.position = 1
Stream.__name = "Stream"

function Stream:bsRight(num, pow)
    return math.floor(num / 2^pow)
end

function Stream:bsLeft(num, pow)
    return math.floor(num * 2^pow)
end

function Stream:bytesToNum(bytes)
	local n = 0
	for k,v in ipairs(bytes) do
		n = self:bsLeft(n, 8) + v
	end
	n = (n > 2147483647) and (n - 4294967296) or n
	return n
end

function Stream:__init(param)
	if (param.inputF ~= nil) then
		self.data = io.open(param.inputF, "rb"):read("*all")
	end
	if (param.input ~= nil) then
		self.data = param.input
	end
end

function Stream:seek(amount)
	self.position = self.position + amount
end

function Stream:readChar()
	if self.position <= 0 then self:seek(1) return nil end
	local byte = self.data:sub(self.position, self.position)
	self:seek(1)
	return byte
end

function Stream:readChars(num)
	if self.position <= 0 then self:seek(1) return nil end
	local str = ""
	local i = 1
	while i <= num do
		str = str .. self:readChar()
		i = i + 1
	end
	return str, i-1
end

function Stream:readByte()
	if self.position <= 0 then self:seek(1) return nil end
	return self:readChar():byte(1)
end

function Stream:readBytes(num)
	if self.position <= 0 then self:seek(1) return nil end
	local tabl = {}
	local i = 1
	while i <= num do
		local curByte = self:readByte()
		if curByte == nil then break end
		tabl[i] = curByte
		i = i + 1
	end
	return tabl, i-1
end

function Stream:readInt(num)
	if self.position <= 0 then self:seek(1) return nil end
	num = num or 4
	local bytes, count = self:readBytes(num)
	return self:bytesToNum(bytes), count
end

function Stream:writeChar(char)
	if self.position <= 0 then self:seek(1) return end
	self.data = table.concat{self.data:sub(1,self.position-1), char, self.data:sub(self.position+1)}
	self:seek(1)
end

function writeChars(buffer)
	if self.position <= 0 then self:seek(1) return end
	local lenString = buffer:len()
	self.data = ("%s%s%s"):format(self.data:sub(1,self.position-1), char, self.data:sub(self.position+lenString))
	self.seek(lenString)
end

function Stream:writeByte(byte)
	if self.position <= 0 then self:seek(1) return end
	self:writeChar(string.char(byte))
end

function Stream:writeBytes(buffer)
	if self.position <= 0 then self:seek(1) return end
	local str = ""
	for k,v in pairs(buffer) do
		str = str .. string.char(v)
	end
	writeChars(str)
end