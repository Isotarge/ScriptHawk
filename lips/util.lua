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

local function parent(t)
    local mt = getmetatable(t)
    if mt == nil then
        return nil
    end
    return mt.__index
end

-- http://stackoverflow.com/a/9279009
local loadcode
if setfenv and loadstring then -- 5.1, JIT
    loadcode = function(code, environment)
        local f = assert(loadstring(code))
        setfenv(f, environment)
        return f
    end
else -- 5.2, 5.3
    loadcode = function(code, environment)
        return assert(load(code, nil, 't', environment))
    end
end

local data_sizes = {
    BYTE = 1,
    HALFWORD = 2,
    WORD = 4,
}

local function measure_data(s)
    assert(s and s.type == '!DATA', 'Internal Error: expected !DATA statement')
    local n = 0
    for i, t in ipairs(s) do
        if t.tt == 'LABELSYM' then
            n = n + 4
        elseif t.tt == 'NUM' then
            if t.size == nil then
                error('Internal Error: unspecified data size in NUM')
            end
            local size = data_sizes[t.size]
            if size == nil then
                error('Internal Error: unknown data size in NUM, got '..tostring(t.size))
            end
            n = n + size
        elseif t.tt == 'WORDS' then
            n = n + #t.tok * 4
        elseif t.tt == 'HALFWORDS' then
            n = n + #t.tok * 2
        elseif t.tt == 'BYTES' then
            n = n + #t.tok * 1
        else
            error('Internal Error: unknown data type in !DATA, got '..tostring(t.tt))
        end
    end
    return n
end

return {
    readfile = readfile,
    bitrange = bitrange,
    parent = parent,
    loadcode = loadcode,
    measure_data = measure_data,
}
