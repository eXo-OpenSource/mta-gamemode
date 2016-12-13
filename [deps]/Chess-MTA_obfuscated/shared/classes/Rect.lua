-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Rect.lua
-- *  PURPOSE:     Rectangle class
-- *
-- ****************************************************************************
Rect = inherit(Object)

function Rect:constructor(x, y, width, height)
	self.X, self.Y = x, y
	self.Width, self.Height = width, height
end
