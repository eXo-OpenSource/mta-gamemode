-- ****************************************************************************
-- *
-- *  PROJECT:     	vRoleplay
-- *  FILE:        	shared/math.lua
-- *  PURPOSE:     	Advanced mathematic operations
-- *
-- ****************************************************************************

-- Input should be the following:
--[[
Line:
(linepos.x)		  (linedir.x)
(linepos.y) + r * (linedir.y)
(linepos.z)		  (linedir.z)
Plane:
(planepos.x)	   (planev1.x)		 (planev2.x)
(planepos.y) + r * (planev1.y) + s * (planev1.y)
(planepos.z)	   (planev1.z)		 (planev1.z)
]]
-- Returns a Vector
function math.line_plane_intersection(linepos, linedir, planepos, planev1, planev2)
	local posoffset = linepos - planepos
	local n = planev1:cross(planev2)
	if math.abs(n:dot(linedir)) < 1.0e-3 then
		return false
	end
	
	local r = math.determinante(planev1, planev2, posoffset) / math.determinante(planev1, planev2, -linedir)
	return linepos + r * linedir
end


-- 3 Vectors only... no matrices please
function math.determinante(a, b, c)
	return a:cross(b):dot(c)
end

function math.getAngle(vec1, vec2)
	return math.acos(vec1:dot(vec2)/(vec1.length * vec2.length))
end

function math.getPlaneInfoFromEuler(position, rotation, size)
	-- Build entity matrix and calculate the normal
	local mat = Matrix(position, rotation)
	local normal = mat.forward
	
	local startpos = position
	local endpos = mat:transformPosition(Vector3(0, 0, -size.y))
	
	return startpos, endpos, normal
end

function math.lerp(min, max, pos)
	return max + pos * (max - min)
end

function math.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function math.clamp(low,value,high)
    return math.max(low,math.min(value,high))
end

function math.percent(value, max)
	if not max then max = 100 end
	return math.clamp(0, value/max*100, 100)
end