-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/utils.lua
-- *  PURPOSE:     Clientside utility functions
-- *
-- ****************************************************************************



local _addEventHandler = addEventHandler
local _removeEventHandler = removeEventHandler

addedEventHandlers = {
	["onClientRender"] 		= {},
	["onClientPreRender"] 	= {},
	["onClientHUDRender"] 	= {},
}
addedEventFuncUID = {}

function addEventHandler(eventName, attached, func, prop, priority)
	if addedEventHandlers[eventName] then
		local info = debug.getinfo(2, "Sl")
		local UID = getTickCount()+math.random(100, 200)
		addedEventHandlers[eventName][func] = {UID, info.short_src, info.currentline}
		addedEventFuncUID[UID] = func
	end
	return _addEventHandler(eventName, attached, func, prop, priority)
end

function removeEventHandler(eventName, attached, func)
	if addedEventHandlers[eventName] then
		if addedEventHandlers[eventName][func] then addedEventHandlers[eventName][func] = nil end
	end
	return _removeEventHandler(eventName, attached, func)
end


function updateCameraMatrix(x, y, z, lx, ly, lz, r, fov)
	local _x, _y, _z, _lx, _ly, _lz, _r, _fov = getCameraMatrix()
	setCameraMatrix(x or _x, y or _y, z or _z, lx or _lx, ly or _ly, lz or _lz, r or _r, fov or _fov)
end

function fontHeight(font, size)
	return dxGetFontHeight(size, font) * 1.75
end
function fontWidth(text, font, size)
	return dxGetTextWidth(text, size or 1, font or "default")
end

function textHeight(text, lineWidth, font, size)
	--[[
	Breaks words. Lines are automatically broken between words if a word would
	extend past the edge of the rectangle specified by the pRect parameter.
	A carriage return/line feed sequence also breaks the line.
	]]
	local start = 1
	local height = dxGetFontHeight(size, font)
	for pos = 1, text:len() do
		if dxGetTextWidth(text:sub(start, pos), size, font) > lineWidth or text:sub(pos, pos) == "\n" then
			local fh = dxGetFontHeight(size, font)
			height = height + fh
			start = pos - 1
		end
	end
	return height
end

local offset = 0
local outMargin = 0
function grid(type, pos)
	if not pos then pos = 1 end
	if type == "offset" then
		offset = pos
		return true
	elseif type == "outMargin" then
		outMargin = pos
		return true
	elseif type == "reset" then -- reset all previous settings
		offset = 0
		outMargin = 0
		return true
	elseif type == "x" then
		return 30*(pos - 1) + 10*pos + outMargin
	elseif type == "y" then
		return offset + 30*(pos - 1) + 10*pos + outMargin
	end
	return 30*pos + 10*(pos - 1)
end

--[[local text = "BlaBlaBlaBla\nfffasdfasdfasdf\nasdf"
local lineWidth = 200
local h = textHeight(text, lineWidth, "arial", 3)
outputDebug("h:"..h)
addEventHandler("onClientRender", root,
	function()

		dxDrawRectangle(300, 300, lineWidth, 100, tocolor(255, 255, 0, 255))
		dxDrawRectangle(300, 300, lineWidth, h, tocolor(0, 0, 255, 255))
		dxDrawText(text, 300, 300, 300+lineWidth, 500, tocolor(255, 0, 0), 3, "arial", "left", "top", false, true)

	end
)]]

_guiCreateScrollBar = guiCreateScrollBar
function guiCreateScrollBar(...) return GUIScrollbarHorizontaloooooooo(...) or _guiCreateScrollBar(...) end

function getElementBehindCursor(worldX, worldY, worldZ)
    local x, y, z = getCameraMatrix()
    local hit, hitX, hitY, hitZ, element = processLineOfSight(x, y, z, worldX, worldY, worldZ, false, true, true, true, false)

    return element
end

-- For easy use with: https://atom.io/packages/color-picker
function rgb(r, g, b)
	return tocolor(r, g, b)
end

function rgba(r, g, b, a)
	return tocolor(r, g, b, a*255)
end

function dxDrawImage3D(x,y,z,w,h,m,c,r,...)
	local lx, ly, lz = x+w, y+h, (z+tonumber(r or 0)) or z
	return dxDrawMaterialLine3D(x,y,z, lx, ly, lz, m, h, c or tocolor(255,255,255,255), ...)
end

function dxDrawText3D(text, x, y, z)
	local x, y, z = x, y, z
	if x and type(x) == "table" then -- Vector conversion
		x, y, z = x.x, x.y, x.z
	end
	local scx,scy = getScreenFromWorldPosition(x, y, z)
	if scx and scy then
		dxDrawText("[Debug] "..text, scx, scy, nil, nil, Color.White, 1, "default-bold", "center", "center")
	end
end

function dxDrawToolTip(x, y, text)
	local f = getVRPFont(VRPFont(30))
	local h = fontHeight(f, 1)/2
	local w = fontWidth(text, f, 1)+30
	dxDrawRectangle(x-w/2, y-h, w, h, tocolor(0, 0, 0, 150))
	dxDrawText(text, x, y-h/2, nil, nil, Color.White, 1, f, "center", "center")
end

function getFreeSkinDimension()
	local dim = math.random(1, 60000)
	for key, player in ipairs( getElementsByType("player") ) do
		if getElementDimension( player ) == dim then
			return getFreeSkinDimension()
		end
	end
	return dim
end

function rectangleCollision2D(rax, ray, raw, rah, rbx, rby, rbw, rbh)
	local RectA = {X1 = rax, X2 = rax + raw, Y1 = ray, Y2 = ray + rah}
	local RectB = {X1 = rbx, X2 = rbx + rbw, Y1 = rby, Y2 = rby + rbh}

	if RectA.X1 <= RectB.X2 and RectA.X2 >= RectB.X1 and RectA.Y1 <= RectB.Y2 and RectA.Y2 >= RectB.Y1 then
		return true
	end
end

function calcDxFontSize(text, width, font, max)
	for i = max, 0.1, -0.1 do
		if dxGetTextWidth(text, i, font) <= width then
			return i
		end
	end
	return max
end

function timeMsToTimeText(timeMs, hideMinutes)
	local minutes	= math.floor( timeMs / 60000 )
	timeMs			= timeMs - minutes * 60000;

	local seconds	= math.floor( timeMs / 1000 )
	local ms		= timeMs - seconds * 1000;

	if hideMinutes and minutes < 1 then
		return ("%02d.%03d"):format(seconds, ms)
	end

	return ("%02d:%02d.%03d"):format(minutes, seconds, ms)
end

function sortPlayerTable(theTable, keyIndex, sortFunction)
	local cache = {}

	for k, v in pairs(theTable) do
		local insertCache = {}
		insertCache[keyIndex] = k

		for insertKey, insertValue in pairs(v) do
			insertCache[insertKey] = insertValue
		end

		table.insert(cache, insertCache)
	end

	table.sort(cache, sortFunction)

	return cache
end

--[[
 * Converts an RGB color value to HSV. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and v in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSV representation
]]
function rgbToHsv(r, g, b, a)
	r, g, b, a = r / 255, g / 255, b / 255, a / 255
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, v
	v = max

	local d = max - min
	if max == 0 then s = 0 else s = d / max end

	if max == min then
		h = 0 -- achromatic
	else
		if max == r then
			h = (g - b) / d
			if g < b then h = h + 6 end
		elseif max == g then h = (b - r) / d + 2
		elseif max == b then h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h, s, v, a
end

--[[
 * Converts an HSV color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes h, s, and v are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  v       The value
 * @return  Array           The RGB representation
]]
function hsvToRgb(h, s, v, a)
	local r, g, b

	local i = math.floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	i = i % 6

	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end

	return r * 255, g * 255, b * 255, a * 255
end

function RGBToHex(red, green, blue, alpha)
	if((red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) or (alpha and (alpha < 0 or alpha > 255))) then
		return nil
	end
	if(alpha) then
		return string.format("%.2X%.2X%.2X%.2X", red,green,blue,alpha)
	else
		return string.format("%.2X%.2X%.2X", red,green,blue)
	end
end

function isPedAiming ( thePedToCheck )
	if isElement(thePedToCheck) then
		if getElementType(thePedToCheck) == "player" or getElementType(thePedToCheck) == "ped" then
			if getPedTask(thePedToCheck, "secondary", 0) == "TASK_SIMPLE_USE_GUN" then
				return true
			end
		end
	end
	return false
end

function dxDrawBoxShape( x, y, w, h , ...)
	dxDrawLine( x, y, x+w,y,...)
	dxDrawLine( x, y+h , x +w , y+h,...)
	dxDrawLine( x , y ,x , y+h , ... )
	dxDrawLine( x+w , y ,x+w , y+h , ...)
end

function dxDrawBoxText( text , x, y , w , h , ... )
	dxDrawText( text , x , y , x + w , y + h , ... )
end

function getLineAngle( cx, cy, r, t)
	local x = r*math.cos(math.rad(t)) + cx;
	local y = r*math.sin(math.rad(t)) + cy;
	return x,y
end

addEvent("onClientElementInteriorChange", true )
_setElementInterior = setElementInterior
function setElementInterior(element, interior, x, y, z)
	_setElementInterior(element, interior, x, y, z)
	triggerEvent("onClientElementInteriorChange", element, interior)
end

addEvent("onClientElementDimensionChange", true )
_setElementDimension = setElementDimension
function setElementDimension(element, dimension)
	_setElementDimension(element, dimension)
	triggerEvent("onClientElementDimensionChange", element, dimension)
end
