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
	if not tab or not type(tab) == "table" then
		outputDebugString("Bad Argument #1 in function table.size. See Console for more details")
		outputConsole(debug.traceback())
		return false
	end

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

function table.insertUnique(tab, value)
	if not table.find(tab, value) then
		table.insert(tab, value)
	end
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

function table.map(tab, func)
	local result = {}

	for k, v in pairs(tab) do
		result[k] = func(v)
	end

	return result
end

function table.compare(tab1, tab2) -- This method is for debugging purposes only
	-- Check if tab2 is subset of tab1
	for k, v in pairs(tab1) do
		if type(v) == "table" and type(tab2[k]) == "table" then
			if not table.compare(v, tab2[k]) then
				return false
			end
		elseif type(v) == "number" and type(tab2[k]) == "number" then
			if not floatEqual(v, tab2[k]) then
				return false
			end
		elseif v ~= tab2[k] then
			return false
		end
	end

	-- Check if tab1 is subset of tab2
	for k, v in pairs(tab2) do
		if type(v) == "table" and type(tab1[k]) == "table" then
			if not table.compare(v, tab1[k]) then
				return false
			end
		elseif type(v) == "number" and type(tab1[k]) == "number" then
			if not floatEqual(v, tab1[k]) then
				return false
			end
		elseif v ~= tab1[k] then
			return false
		end
	end

	return true
end

function table.removevalue(tab, value)
	local idx = table.find(tab, value)
	if idx then
		table.remove(tab, idx)
		return true
	end
end

function table.copy(tab)
	local temp = {}
	for k, v in pairs(tab) do
		temp[k] = type(v) == "table" and table.copy(tab) or v
	end
	return temp
end

function table.reverse(tab)
    local reversedTable = {}
    local itemCount = #tab
    for k, v in ipairs(tab) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.copyobject(tab) -- Does not detect circular/infinite loops
	local temp = {}
	for k, v in pairs(tab) do
		temp[k] = type(v) == "table" and table.copyobject(v) or v
	end
	return setmetatable(temp, getmetatable(tab))
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

-- value-sorted pairs
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
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
	local hrest = 0
	local minutes = math.floor(seconds / 60)
	if hours > 0 then
		hrest = ((seconds / 3600)%1)*60
		return string.format("%02dh:%02dm", hours, hrest)
	elseif minutes > 0 then
		return string.format("%dmin", minutes)
	else
		return string.format("%dsec", seconds)
	end
end

function string.count(str, search)
	local _, count = string.gsub(str, search, "")
	return count
end


function string.short(str, i)
	return #str > i and str:sub(0, i).."..." or str
end

function table.setIndexToInteger(tab)
	local newTab = {}
	for index, value in pairs(tab) do
		if tonumber(index) then
			newTab[tonumber(index)] = value
		else
			newTab[index] = value
		end
	end
	return newTab
end

-- Override with UTF-8 versions (but keep a backup for binary operations)
string.binary_sub = string.sub
string.binary_len = string.len
string.sub = utfSub
string.len = utfLen

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

function nextframe(fn, ...)
	setTimer(fn, 50, 1, ...)
end

function toboolean(num)
	return num and num ~= 0 and num ~= "0" and num ~= "false"
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
-- https://gist.github.com/StiviiK/b7efbfb34122c44ce60db53f10a7197d
function fromcolor(color)
  return bitExtract(color, 16, 8), bitExtract(color, 8, 8), bitExtract(color, 0, 8), bitExtract(color, 24, 8)
end

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
	if
		type( sEventName ) == 'string' and
		isElement( pElementAttachedTo ) and
		type( func ) == 'function'
	then
		local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
		if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
			for i, v in ipairs( aAttachedFunctions ) do
				if v == func then
					return true
				end
			end
		end
	end

	return false
end

function hasPedThisWeaponInSlots(ped, id)
	local occupied = false
	for i = 1, 8 do
		local weapon = getPedWeapon ( ped, i )
		if weapon then
			if weapon == id then
				occupied = true
				break
			end
		end
	end
	return occupied
end

function calculatePlayerLevel(xp)
	-- XP(level) = 0.5*x^2 --> level(XP) = sqrt(2*xp)
	return (2 * math.floor(math.abs(xp)))^0.5
end

function calculatePointsToNextLevel(currentLevel)
	return (currentLevel+2)^3 * 10
end

function getRandomUniqueNick()
	local randomNick
	repeat
		randomNick = "Gast_"..math.random(1, 99999)
	until (not getPlayerFromName(randomNick))

	return randomNick
end

function getCrimeById(crimeId)
	for k, crime in pairs(Crime) do
		if crime.id == crimeId then
			return crime
		end
	end
	return false
end

function string.countChar(str, char)
	return math.floor((str:len() - str:gsub(char, ""):len())/char:len())
end

function teleportPlayerNextToVehicle(player, vehicle, distance)
	player:removeFromVehicle()

	player:setPosition(vehicle.position + vehicle.matrix.right * (distance or 1))
end

function fromboolean(bool)
	return bool and 1 or 0
end

function getAnglePosition(x, y, z, rx, ry, rz, distance, angle, height)
	local nrx = math.rad(rx);
	local nry = math.rad(ry);
	local nrz = math.rad(angle - rz);

	local dx = math.sin(nrz) * distance;
	local dy = math.cos(nrz) * distance;
	local dz = math.sin(nrx) * distance;

	local newX = x + dx;
	local newY = y + dy;
	local newZ = z + height - dz;

	return newX, newY, newZ;
end

function getPlayersInRange(pos, range, inTable)
	local result = {}
	for k, player in pairs(inTable or getElementsByType("player")) do
		-- I guess calling getDistanceBetweenPoints3D is faster than using vector operations
		if getDistanceBetweenPoints3D(pos, player.position) <= range then
			result[#result + 1] = player
		end
	end
	return result
end

local FLOAT_EPSILON = 1e-5 --1e-9
function floatEqual(a, b)
	return math.abs(a - b) <= FLOAT_EPSILON
end

function getThisFunction()
	return debug.getinfo(2, "f").func
end

function getVehicleUpgradeNameFromID(upgradeId)
	return VEHICLE_UPGRADE_NAMES[upgradeId] or false
end

function getVehicleUpgradePrice(upgradeId)
	local price = VEHICLE_UPGRADE_PRICES[upgradeId]
	if price then
		if tonumber(price) then
			return math.floor(price)
		else
			return price
		end
	else
		return price
	end
end

function countLineBreaks(text)
	local count = 0
	for i = 0, #text do
		if text:sub(i, i) == "\n" then
			count = count + 1
		end
	end
	return count
end

function convertNumber ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
		if ( k==0 ) then
			break
		end
	end
	return formatted
end

function convertFrequency ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d)", '%2.%1')
		if ( k==0 ) then
			break
		end
	end
	return formatted
end

function toMoneyString(money)
	if tonumber(money) then
		return convertNumber(math.floor(money)).."$"
	end
	return tostring(money)
end

function getOpticalZoneName(x, y, z)
	local zone1 = getZoneName(x, y, z or 0)
	local zone2 = getZoneName(x, y, z or 0, true)
	return zone1 ~= zone2 and ("%s, %s"):format(zone1, zone2) or zone1
end

function linear(t, b, c, d)
  return c * t / d + b
end

function isLeapYear(year)
	if year then year = math.floor(year)
	else year = getRealTime().year + 1900 end
	return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

function getTimestamp(year, month, day, hour, minute, second)
	-- initiate variables
	local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
	local timestamp = 0
	local datetime = getRealTime()
	year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
	hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second

	-- calculate timestamp
	for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
	for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
	timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second

	timestamp = timestamp - 3600 --GMT+1 compensation
	if datetime.isdst then timestamp = timestamp - 3600 end

	return timestamp
end

function getWeekNumber()	--Maybe needs optimization
	local realtime = getRealTime()
	local firstDayOfTheYearTimestamp = getTimestamp(realtime.year + 1900, 0, 0)
	local firstYearDayTime = getRealTime(firstDayOfTheYearTimestamp)

	return math.floor((realtime.yearday + firstYearDayTime.weekday) / 7)
end

function getOpticalTimestamp(ts, seconds)
	local time = ts and getRealTime(ts) or getRealTime()
	time.month = time.month+1
	time.year = time.year-100
	for index, value in pairs(time) do
		value = tostring(value)
		if #value == 1 then time[index] = "0"..value end
	end
	return ("%s.%s.%s-%s:%s%s"):format(time.monthday, time.month, time.year, time.hour, time.minute, (seconds and (":%s"):format(time.second) or ""))
end

function timespanArray(seconds)
	local td = {}
    td["total"] = seconds
    td["sec"] = seconds % 60
    td["min"] = ((seconds - td["sec"]) / 60) % 60
    td["hour"] = ((((seconds - td["sec"]) /60)-td["min"]) / 60) % 24
    td["day"] = math.floor( (((((seconds - td["sec"]) /60)-td["min"]) / 60) / 24) )
    return td
end

-- Override it
local _getVehicleType = getVehicleType
function getVehicleType (...)
	local type = _getVehicleType(...)
	return (VehicleType[type] ~= nil and VehicleType[type] or VehicleType.Automobile)
end

function timestampCoolDown(last, seconds)
	if last + seconds < getRealTime().timestamp then
		return true
	end
	return false
end

function traceback()
      local level = 1
      while true do
        local info = debug.getinfo(level, "Sl")
        if not info then break end
        if info.what == "C" then   -- is a C function?
          outputConsole("C function")
        else   -- a Lua function
          outputConsole(info.short_src.."-"..info.currentline)
        end
        level = level + 1
      end
    end

-- https://gist.github.com/StiviiK/9736d02a1163ea746e04
local function search (key, elements)
	for i, v in ipairs(elements) do
		if tostring(v.key) == tostring(key) then
			if type(v.value) ~= "function" then
				return v.value
			else
				return v.value()
			end
		end
	end

	return false
end

function case (name)
	return function(value)
		return {key = name, value = value}
	end
end

function switch (searchFor)
	return function(elements)
		local result = search(searchFor, elements)
		if not result then
			return search("default", elements)
		end

		return result
	end
end

function string.random(length)
	local char = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z","0","1","2","3","4","5","6","7","8","9"}
	local code = {}
	for z = 1, length do
		a = math.random(1, #char)
		x = string.lower(char[a])
		table.insert(code, x)
	end
	return table.concat(code)
end

function isNan(num)
	return num ~= num
end

function normaliseVector(serialisedVector)
	if serialisedVector.w then
		return Vector4(serialisedVector.x, serialisedVector.y, serialisedVector.z, serialisedVector.w)
	elseif serialisedVector.z then
		return Vector3(serialisedVector.x, serialisedVector.y, serialisedVector.z)
	elseif serialisedVector.y then
		return Vector2(serialisedVector.x, serialisedVector.y)
	elseif serialisedVector[3] then
		return Vector3(unpack(serialisedVector))
	end
end

function normaliseRange( min, max, value)
	return ( value-min ) / ( max-min )
end

function serialiseVector(vector)
	return {x = vector.x, y = vector.y, z = vector.z, w = vector.w}
end

-- GTA SA workaround, isVehicleOnGround return always false for some vehicles
local vehicles = {
	[573] = true, -- Dune
	[444] = true, -- Monster
	[556] = true, -- Monster 2
	[557] = true, -- Monster 3
}
local _isVehicleOnGround = isVehicleOnGround
function isVehicleOnGround(vehicle)
	if isElement(vehicle) then
		if (vehicle:getVehicleType() == VehicleType.Plane and not vehicle:getModel() == 460) or vehicles[vehicle:getModel()] then
			return vehicle:getSpeed() == 0
		elseif vehicle:getVehicleType() == VehicleType.Boat or vehicle:getModel() == 460 then
			return vehicle:getSpeed() < 3
		else
			return _isVehicleOnGround(vehicle)
		end
	end
end
function Vehicle.isOnGround(vehicle) return isVehicleOnGround(vehicle) end

function getColorNameFromVehicle(c1, c2)
	local color1 = CAR_COLORS_FROM_ID[c1] or "Unerkannt"
	local color2 = CAR_COLORS_FROM_ID[c2] or "Unerkannt"

	if color1 ~= color2 then
		return color1 .. " & " .. color2
	else
		return color1
	end
end

function attachRotationAdjusted ( from, to )
    -- Note: Objects being attached to ('to') should have at least two of their rotations set to zero
    --       Objects being attached ('from') should have at least one of their rotations set to zero
    -- Otherwise it will look all funny

    local frPosX, frPosY, frPosZ = getElementPosition( from )
    local frRotX, frRotY, frRotZ = getElementRotation( from )
    local toPosX, toPosY, toPosZ = getElementPosition( to )
	local toRotX, toRotY, toRotZ = getElementRotation( to )
	frRotX = frRotX or 0
	frRotY = frRotY or 0
	frRotZ = frRotZ or 0
    local offsetPosX = frPosX - toPosX
    local offsetPosY = frPosY - toPosY
    local offsetPosZ = frPosZ - toPosZ
    local offsetRotX = frRotX - toRotX
    local offsetRotY = frRotY - toRotY
    local offsetRotZ = frRotZ - toRotZ

    offsetPosX, offsetPosY, offsetPosZ = applyInverseRotation ( offsetPosX, offsetPosY, offsetPosZ, toRotX, toRotY, toRotZ )

    attachElements( from, to, offsetPosX, offsetPosY, offsetPosZ, offsetRotX, offsetRotY, offsetRotZ )
end

function applyInverseRotation ( x,y,z, rx,ry,rz )
    -- Degress to radians
    local DEG2RAD = (math.pi * 2) / 360
    rx = rx * DEG2RAD
    ry = ry * DEG2RAD
    rz = rz * DEG2RAD

    -- unrotate each axis
    local tempY = y
    y =  math.cos ( rx ) * tempY + math.sin ( rx ) * z
    z = -math.sin ( rx ) * tempY + math.cos ( rx ) * z

    local tempX = x
    x =  math.cos ( ry ) * tempX - math.sin ( ry ) * z
    z =  math.sin ( ry ) * tempX + math.cos ( ry ) * z

    tempX = x
    x =  math.cos ( rz ) * tempX + math.sin ( rz ) * y
    y = -math.sin ( rz ) * tempX + math.cos ( rz ) * y

    return x, y, z
end

function ripairs(t)
	local max = 1
	while t[max] ~= nil do
		max = max + 1
	end
	local function ripairs_it(t, i)
		i = i-1
		local v = t[i]
		if v ~= nil then
			return i,v
		else
			return nil
		end
	end
	return ripairs_it, t, max
end

function tableMerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

local seasons = {
	{season = 4, seasonStart = getRealTime(946684800).yearday, seasonEnd = getRealTime(953510400).yearday}, -- Winter
	{season = 1, seasonStart = getRealTime(953596800).yearday, seasonEnd = getRealTime(961459200).yearday}, -- Frühling
	{season = 2, seasonStart = getRealTime(961545600).yearday, seasonEnd = getRealTime(969580800).yearday}, -- Sommer
	{season = 3, seasonStart = getRealTime(969667200).yearday, seasonEnd = getRealTime(977270400).yearday}, -- Herbst
	{season = 4, seasonStart = getRealTime(977356800).yearday, seasonEnd = getRealTime(978220800).yearday}, -- Winter
}
function getCurrentSeason()
	local currentYearday = getRealTime().yearday

	for _, season in pairs(seasons) do
		if currentYearday >= season.seasonStart and currentYearday <= season.seasonEnd then
			return season.season
		end
	end
end

function checkRaySphere(origin, ray, sphere, radius)
	local offset = origin - sphere
	local b = offset:dot(ray)
	local c = offset:dot(offset) - radius * radius
	if c > 0 and b > 0 then
		return false
	end
	local discr = b * b - c
	if discr < 0 then
		return false
	end
	local t = -b - math.sqrt(discr)
	t = t < 0 and 0 or t
	return origin + ray * t, t
end

function getVectorByAngleDistance(vec, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return Vector3(vec.x+dx, vec.y+dy, vec.z);
end

function angle(vec1, vec2)
    return math.acos(vec1:dot(vec2)/(vec1.length*vec2.length))
end

function getPedWeapons(ped)
	local playerWeapons = {}
	if ped and isElement(ped) and getElementType(ped) == "ped" or getElementType(ped) == "player" then
		for i=1,11 do
			local wep = getPedWeapon(ped,i)
			if wep and wep ~= 0 then
				table.insert(playerWeapons,wep)
			end
		end
	else
		return false
	end
	return playerWeapons
end

function isValidElement(data, type)
    return isElement(data) and (not type or (getElementType(data) == type))
end

function normalize(x, y, z)
	local len = (x^2+y^2+z^2)^0.5
	x = x / len
	y = y / len
	z = z / len
	return x,y,z
end

function addComas(str)
	return #str % 3 == 0 and str:reverse():gsub("(%d%d%d)", "%1."):reverse():sub(2, -1) or str:reverse():gsub("(%d%d%d)", "%1."):reverse()
end

URLEncoder = {
    encode = function(str)
            if (not str) then
                return str
            end

            str = string.gsub (str, "\n", "\r\n")
            str = string.gsub (str, "[^%w.%-_~]",
                function (c) return string.format ("%%%02X", string.byte(c)) end)

            return str
        end,
    decode = function(str)
            str = string.gsub(str, "%%([0-9a-fA-F][0-9a-fA-F])",
                function (c) return string.char(tonumber("0x" .. c)) end)
            str = string.gsub (str, "\n", "\r\n")
            return str
        end,
}

function fisherYatesShuffle( input ) -- https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
    local output = {}
    for i = #input, 1, -1 do
        local j = math.random(i)
        input[i], input[j] = input[j], input[i]
        table.insert(output, input[i])
    end
    return output
end

function math.randomchoice(t) --Selects a random item from a table
    local keys = {}
    for key, value in pairs(t) do
        keys[#keys+1] = key --Store keys in another table
    end
    index = keys[math.random(1, #keys)]
    return t[index], index
end

function getBiggestUnitByBytes(value)
	if value < 1048576 then
		return "KB"
	end
	return "MB"
end

function convertBytesToUnit(value, unit)
	if unit == "MB" then
		return value / 1048576
	elseif unit == "KB" then
		return value / 1024
	end
end

function isValidPedModel(model)
	for i, skin in ipairs(getValidPedModels()) do
		if model == skin then
			return true
		end
	end
	return false
end

function lastIndexOf(haystack, needle)
    local i, j
    local k = 0
    repeat
        i = j
        j, k = string.find(haystack, needle, k + 1, true)
    until j == nil

    return i
end
