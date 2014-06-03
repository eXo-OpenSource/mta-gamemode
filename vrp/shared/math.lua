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
	local n = planev1:crossP(planev2)
	if math.abs(n:dotP(linedir)) < 1.0e-3 then
		return false
	end
	
	local r = math.determinante(planev1, planev2, posoffset) / math.determinante(planev1, planev2, -linedir)
	return linepos + r * linedir
end


-- 3 Vectors only... no matrices please
function math.determinante(a, b, c)
	return a:crossP(b):dotP(c)
end