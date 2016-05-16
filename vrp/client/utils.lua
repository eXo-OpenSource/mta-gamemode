-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/utils.lua
-- *  PURPOSE:     Clientside utility functions
-- *
-- ****************************************************************************
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