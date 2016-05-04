local floor = math.floor
local open = io.open

local function readfile(fn, binary)
    local mode = binary and 'rb' or 'r'
    local f = open(fn, mode)
    if not f then
        local kind = binary and 'binary' or 'assembly'
        error('could not open '..kind..' file for reading: '..tostring(fn), 2)
    end
    local data = f:read('*a')
    f:close()
    return data
end

local function bitrange(x, lower, upper)
    return floor(x/2^lower) % 2^(upper - lower + 1)
end

return {
    readfile = readfile,
    bitrange = bitrange,
}
