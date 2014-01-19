Animation = setmetatable({}, { __call = function(self, ...) return self:new(...) end })
inherit(Object, Animation)