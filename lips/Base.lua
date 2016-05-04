-- mostly just semantics over knife.base
-- https://github.com/airstruck/knife/blob/master/knife/base.lua
return {
    extend = function(self, subtype)
        subtype = subtype or {}
        local meta = { __index = subtype }
        return setmetatable(subtype, {
            __index = self,
            __call = function(self, ...)
                local obj = setmetatable({}, meta)
                return obj, obj:init(...)
            end
        })
    end,

    init = function() end,
}
