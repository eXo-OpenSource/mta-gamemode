-- ****************************************************************************
-- *
-- *  PROJECT:     	Open MTA:DayZ
-- *  FILE:        	shared/Vector.lua
-- *  PURPOSE:     	Vector class
-- *
-- ****************************************************************************
Vector = inherit(Object)
Vector.__index = Vector
setmetatable(Vector, {__call = function(tab, ...) local t = setmetatable({}, Vector) t:constructor(...) return t end})
 
function Vector:constructor(x, y, z)
		if tonumber(x) and tonumber(y) and tonumber(z) then
				self.X, self.Y, self.Z = tonumber(x), tonumber(y), tonumber(z)
		else
				self.X, self.Y, self.Z = 0, 0, 0
		end
end
 
function Vector:add(vec)
		return Vector(self.X + vec.X, self.Y + vec.Y, self.Z + vec.Z)
end
 
function Vector:sub(vec)
		return Vector(self.X - vec.X, self.Y - vec.Y, self.Z - vec.Z)
end
 
function Vector:mul(vecOrScalar)
		if type(vecOrScalar) == "table" then
				local vec = vecOrScalar
				return Vector(self.X * vec.X, self.Y * vec.Y, self.Z * vec.Z)
		elseif type(vecOrScalar) == "number" then
				local scalar = vecOrScalar
				return Vector(self.X * scalar, self.Y * scalar, self.Z * scalar)
		else
				error("Invalid type @ Vector.mul")
		end
end
 
function Vector:div(vecOrScalar)
		if type(vecOrScalar) == "table" then
				local vec = vecOrScalar
				return Vector(self.X / vec.X, self.Y / vec.Y, self.Z / vec.Z)
		elseif type(vecOrScalar) == "number" then
				local scalar = vecOrScalar
				return Vector(self.X / scalar, self.Y / scalar, self.Z / scalar)
		else
				error("Invalid type @ Vector.div")
		end
end
 
function Vector:invert()
		return Vector(-self.X, -self.Y, -self.Z)
end
 
function Vector:equalTo(vec)
		return (self.X == vec.X and self.Y == vec.Y and self.Z == vec.Z)
end
 
function Vector:lt(vec) -- is there an operation like this?
		return (self.X < vec.X and self.Y < vec.Y and self.Z < vec.Z)
end
 
function Vector:le(vec)
		return (self.X <= vec.X and self.Y <= vec.Y and self.Z <= vec.Z)
end
 
function Vector:norm()
		return math.sqrt(self.X^2 + self.Y^2 + self.Z^2)
end
 
function Vector:dotP(vec) -- scalar product
		return (self.X * vec.X + self.Y * vec.Y + self.Z * vec.Z)
end
 
function Vector:crossP(vec) -- cross product
		return Vector(self.Y * vec.Z - self.Z * vec.Y, self.Z * vec.X - self.X * vec.Z, self.X * vec.Y - self.Y * vec.X)
end
 
function Vector:isColinear(vec)
		local factor = vec.X / self.X
		return (self.Y * factor == vec.Y and self.Z * factor == vec.Z)
end
 
function Vector:isOrthogonal(vec)
		return (self:dotP(vec) == 0)
end
 
function Vector:getAngle(vec)
		return math.deg(math.acos(self:dotP(vec) / ( self:norm() * vec:norm() )))
end
 
function Vector:tostring()
		return ("X = %f, Y = %f; Z = %f"):format(self.X, self.Y, self.Z)
end
 
 
-- Operators
function Vector.__add(vec1, vec2)
		return vec1:add(vec2)
end
 
function Vector.__sub(vec1, vec2)
		return vec1:sub(vec2)
end
 
function Vector.__mul(vec1, vecOrScalar)
		return vec1:mul(vecOrScalar)
end
 
function Vector.__div(vec1, vecOrScalar)
		return vec1:div(vecOrScalar)
end
 
function Vector.__unm(vec)
		return vec:invert()
end
 
function Vector.__eq(vec1, vec2)
		return vec1:equalTo(vec2)
end
 
function Vector.__lt(vec1, vec2)
		return vec1:lt(vec2)
end
 
function Vector.__le(vec1, vec2)
		return vec2:le(vec2)
end
 
function Vector.__tostring(vec)
		return vec:tostring()
end

