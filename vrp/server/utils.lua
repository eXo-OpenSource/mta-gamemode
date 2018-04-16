function critical_error(errmsg)
	outputDebugString("[CRITICAL ERROR] "..tostring(errmsg))
	outputDebugString("[CRITICAL ERROR] vRoleplay Script will now halt")
	outputDebugString("[CRITICAL ERROR] If you cannot solve this issue please report at fixme: forumurl ") -- Todo: Fixme URL
	stopResource(getThisResource())
	core.m_Failed = true
	error("Critical Error")
end

function getElementMatrix(element)
	local rx, ry, rz = getElementRotation(element, "ZXY")
	rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
	local matrix = {}
	matrix[1] = {}
	matrix[1][1] = math.cos(rz)*math.cos(ry) - math.sin(rz)*math.sin(rx)*math.sin(ry)
	matrix[1][2] = math.cos(ry)*math.sin(rz) + math.cos(rz)*math.sin(rx)*math.sin(ry)
	matrix[1][3] = -math.cos(rx)*math.sin(ry)
	matrix[1][4] = 1

	matrix[2] = {}
	matrix[2][1] = -math.cos(rx)*math.sin(rz)
	matrix[2][2] = math.cos(rz)*math.cos(rx)
	matrix[2][3] = math.sin(rx)
	matrix[2][4] = 1

	matrix[3] = {}
	matrix[3][1] = math.cos(rz)*math.sin(ry) + math.cos(ry)*math.sin(rz)*math.sin(rx)
	matrix[3][2] = math.sin(rz)*math.sin(ry) - math.cos(rz)*math.cos(ry)*math.sin(rx)
	matrix[3][3] = math.cos(rx)*math.cos(ry)
	matrix[3][4] = 1

	matrix[4] = {}
	matrix[4][1], matrix[4][2], matrix[4][3] = getElementPosition(element)
	matrix[4][4] = 1

	return matrix
end

addEvent("onElementInteriorChange", true )
_setElementInterior = setElementInterior
function setElementInterior(element, interior, x, y, z)
	if isElement(element) then
		_setElementInterior(element, interior, x, y, z)
		triggerEvent("onElementInteriorChange", element, interior)
		if getElementType(element) == "player" then
			triggerClientEvent(element, "onClientPlayerDebugInteriorChange", element)
		end
	end
end

addEvent("onElementDimensionChange", true )
_setElementDimension = setElementDimension
function setElementDimension(element, dimension)
	if isElement(element) then
		_setElementDimension(element, dimension)
		triggerEvent("onElementDimensionChange", element, dimension)
	end
end
