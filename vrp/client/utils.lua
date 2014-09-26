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

_guiCreateScrollBar = guiCreateScrollBar
function guiCreateScrollBar(...) return GUIScrollbarHorizontaloooooooo(...) or _guiCreateScrollBar(...) end