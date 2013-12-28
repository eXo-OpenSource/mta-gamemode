function updateCameraMatrix(x, y, z, lx, ly, lz, r, fov)
	local _x, _y, _z, _lx, _ly, _lz, _r, _fov = getCameraMatrix()
	setCameraMatrix(x or _x, y or _y, z or _z, lx or _lx, ly or _ly, lz or _lz, r or _r, fov or _fov)
end