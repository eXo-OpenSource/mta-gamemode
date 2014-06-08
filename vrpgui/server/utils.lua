function critical_error(errmsg)
	outputDebugString("[CRITICAL ERROR] "..tostring(errmsg))
	outputDebugString("[CRITICAL ERROR] vRoleplay Script will now halt")
	outputDebugString("[CRITICAL ERROR] If you cannot solve this issue please report at fixme: forumurl ")
	stopResource(getThisResource())
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

function tocolor(r, g, b, a)
	return setBytesInInt32(r, g, b, a or 255)
end
