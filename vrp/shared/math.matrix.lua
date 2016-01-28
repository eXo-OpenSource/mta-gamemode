-- ****************************************************************************
-- *
-- *  PROJECT:     	vRoleplay
-- *  FILE:        	shared/math.lua
-- *  PURPOSE:     	Math library for building special matrices
-- *
-- ****************************************************************************
math.matrix = {}
math.matrix.two = {}
math.matrix.three = {}

-- "Local-ize" global variables for faster access
local sin, cos = math.sin, math.cos
local matrix = matrix

--
-- Builds a homogeneous 3D translation matrix
-- that represents a translation
-- @param x, y, z The position you want to move the coordinate system by
-- @return A 4x4 homogenous translation matrix
--
function math.matrix.three.translate(x, y, z)
	return matrix:new({
		{1, 0, 0, x},
		{0, 1, 0, y},
		{0, 0, 1, z},
		{0, 0, 0, 1}
	})
end

--
-- Builds a homogeneous 3D scaling matrix
-- that can be used to scale the system
-- @param x, y, z The scale for each axis
-- @return A 4x4 homogenous scaling matrix
--
function math.matrix.three.scale(x, y, z)
	return matrix:new({
		{x, 0, 0, 0},
		{0, y, 0, 0},
		{0, 0, z, 0},
		{0, 0, 0, 1}
	})
end

--
-- Builds a homogeneous 3D rotation matrix
-- that represents a rotation around the X axis
-- @param The angle you want to rotate the system by
-- @return A 4x4 homogenous rotation matrix
--
function math.matrix.three.rotate_x(angle)
	return matrix:new({
		{1,          0,           0, 0},
		{0, cos(angle), -sin(angle), 0},
		{0, sin(angle),  cos(angle), 0},
		{0,          0,           0, 1}
	})
end

--
-- Builds a homogeneous 3D rotation matrix
-- that represents a rotation around the Y axis
-- @param The angle you want to rotate the system by
-- @return A 4x4 homogenous rotation matrix
--
function math.matrix.three.rotate_y(angle)
	return matrix:new({
		{cos(angle), 0,  sin(angle), 0},
		{0,          1,           0, 0},
		{-sin(angle),0,  cos(angle), 0},
		{0,          0,           0, 1}
	})
end

--
-- Builds a homogeneous 3D rotation matrix
-- that represents a rotation around the Z axis
-- @param The angle you want to rotate the system by
-- @return A 4x4 homogenous rotation matrix
--
function math.matrix.three.rotate_z(angle)
	return matrix:new({
		{cos(angle), -sin(angle), 0, 0},
		{sin(angle),  cos(angle), 0, 0},
		{0,          0,           1, 0},
		{0,          0,           0, 1}
	})
end

--
-- Builds a homogeneous 4D vector
-- @param x, y, z 3D coordinates
-- @param w homogeneous component (1 if translation is included, 0 otherwise)
-- @return A homogeneous 4D vector
--
function math.matrix.three.hvector(x, y, z, w)
	return matrix:new({{x}, {y}, {z}, {w}})
end
