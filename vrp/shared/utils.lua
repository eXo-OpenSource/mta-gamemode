-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/utils.lua
-- *  PURPOSE:     Useful stuff
-- *
-- *****************************************************************************

local __enums = {}
function enum(targetVar, name)
	if __enums[name] then
		__enums[name].maxNum = __enums[name].maxNum+1
	else
		__enums[name] = {maxNum = 1}
	end
	
	-- Register in global namespace
	_G[targetVar] = __enums[name].maxNum
	
	-- Register mainly for addons
	__enums[name][__enums[name].maxNum] = targetVar
	
	return __enums[name]
end

function getEnums()
	return __enums
end

function enumFields(name)
	local i = 0
	local maxNum = __enums[name].maxNum
	return (
		function()
			i = i + 1
			if i ~= maxNum then
				return i, __enums[name][i]
			end
		end
	)
end

function table.size(tab)
	local i = 0
	for _ in pairs(tab) do
		i = i + 1
	end
	return i
end

function table.find(tab, value)
	for k, v in pairs(tab) do
		if v == value then
			return k
		end
	end
	return nil
end

function table.findAll(tab, value)
	local result = {}
	for k, v in pairs(tab) do
		if v == value then
			table.insert(result, k)
		end
	end
	return result
end

_coroutine_resume = coroutine.resume
function coroutine.resume(...)
	local state,result = _coroutine_resume(...)
	if not state then
		outputDebugString( tostring(result), 1 )	-- Output error message
	end
	return state,result
end

-- key-sorted pairs
function kspairs(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
 
	local i = 0 
	local iter = function ()
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
 
	return iter
end

function chance(chance)
	assert(chance >= 0 and chance <= 100, "Bad Chance (Range 0-100)")
	return math.random(0, 100) <= chance 
end

function table.append(table1, table2)
	for k, v in pairs(table2) do
		table1[#table1+1] = v
	end
	return table1
end

function getPositionFromElementOffset(element, offX, offY, offZ)
	local m = getElementMatrix(element)
	
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z
end

function getPositionFromCoordinatesOffset(x, y, z, rx, ry, rz, offX, offY, offZ)
	local m = getMatrix(x, y, z, rx, ry, rz)
	
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z
end

function rotationMatrix(x, y, z, alpha)
	alpha = math.rad(alpha)
	local m = matrix{
		{math.cos(alpha), -math.sin(alpha), 0},
		{math.sin(alpha), math.cos(alpha), 0},
		{0, 0, 1}
	}
	
	local vec = m*matrix{x, y, z}
	return vec[1][1], vec[2][1], vec[3][1]
end

function getMatrix(x, y, z, rrx, rry, rrz)
	local rx, ry, rz = rrx, rry, rrz
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
	matrix[4][1], matrix[4][2], matrix[4][3] = x, y, z
	matrix[4][4] = 1
 
	return matrix
end

function findRotation(x1, y1, x2, y2)
	--[[local x, y = math.abs(x2-x1), math.abs(y2-y1)
	local rot = math.deg(math.atan2(y, x))
	if x1 <= x2 and y1 < y2 then
		rot = 90 - rot
	elseif x2 <= x1 and y1 < y2 then
		rot = 270 + rot
	elseif x1 <= x2 and y2 <= y1 then
		rot = 90 + rot
	elseif x2 < x1 and y2 < y1 then
		rot = 270 - rot
	end
	return 630 - rot]]
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	if t < 0 then t = t + 360 end
	return t
end

function string.duration(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor(seconds / 60)
	
	if hours > 0 then
		return string.format("%02dh:%02dm", hours)
	elseif minutes > 0 then
		return string.format("%dmin", minutes)
	else
		return string.format("%dsec", seconds)
	end
end

function setBytesInInt32(byte1, byte2, byte3, byte4)
	assert(byte1 >= 0 and byte1 <= 255)
	assert(byte2 >= 0 and byte2 <= 255)
	assert(byte3 >= 0 and byte3 <= 255)
	assert(byte4 >= 0 and byte4 <= 255)
	
	local var = byte1
	var = bitOr(bitLShift(var, 8), byte2)
	var = bitOr(bitLShift(var, 8), byte3)
	var = bitOr(bitLShift(var, 8), byte4)
	return var
end

function getBytesInInt32(int32)
	local byte1 = bitRShift(int32, 24)
	local byte2 = bitAnd(bitRShift(int32, 16), 0x000000FF)
	local byte3 = bitAnd(bitRShift(int32, 8), 0x000000FF)
	local byte4 = bitAnd(int32, 0x000000FF)
	return byte1, byte2, byte3, byte4
end

function nextframe(fn)
	setTimer(fn, 50, 1)
end

function toboolean(num)
	return num ~= 0 and num ~= "0"
end

function addRemoteEvents(eventList)
	for k, v in ipairs(eventList) do
		addEvent(v, true)
	end
end

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function getPointFromDistanceRotation3D(x,y,z,rx,ry,rz,distance)
	rx = math.rad(rx)
	ry = math.rad(ry)
	rz = math.rad(rz)
	
	local sin = math.sin
	local cos = math.cos
	
	local dx,dy,dz =1,0,0
	
	local function rotateZY(x,y,z,r)
		return 
		( cos(r) * x - sin(r) * y + 0   * z),
		( sin(r) * x + cos(r) * y + 0   * z),
		( 0		 * x - 0 	  * y + 1 	* z )
	end
	
	local function rotateX(x,y,z,r)
		return
		( 1		 * x - 0 	  * y + 0 		* z),
		( 0		 * x + cos(r) * y - sin(r)	* z),
		( 0		 * x + sin(r) * y + cos(r)	* z)
	end

	dx,dy,dz=rotateZY(dx,dy,dz,rz)
	dx,dy,dz=rotateX(dx,dy,dz,rx)
	dx,dy,dz=rotateZY(dx,dy,dz,ry)
	return x+dx*distance,y+dy*distance,z+dz*distance
end

-- returns 4 integers from a value created by tocolor (aka. inverse tocolor)
function fromcolor(color)
	local str = string.format("%x", color)
	local value = {}
	for word in str:gmatch("%x%x") do
		value[#value+1] = tonumber("0x"..word)
	end
	value[5] = value[1]
	table.remove(value, 1)
	return unpack(value)
end
