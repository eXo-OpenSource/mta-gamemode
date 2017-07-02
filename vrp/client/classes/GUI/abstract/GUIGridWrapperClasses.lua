-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIGridCheckbox.lua
-- *  PURPOSE:     GUI checkbox class
-- *
-- ****************************************************************************


GUIGridCheckbox = inherit(GUICheckbox)
function GUIGridCheckbox:constructor(posX, posY, width, height, text, parent)
	posX = grid("x", posX)
	posY = grid("y", posY) + 5 --adjust the positions so the actual checkbox isn't 30px wide
	width = grid("d", width)
	height = grid("d", height) - 10
	GUICheckbox.constructor(self, posX, posY, width, height, text, parent)
	self:setFont(VRPFont(25)):setFontSize(1)
	return self
end

GUIGridButton = inherit(GUIButton)
function GUIGridButton:constructor(posX, posY, width, height, text, parent)
	posX = grid("x", posX)
	posY = grid("y", posY)
	width = grid("d", width)
	height = grid("d", height)
	GUIButton.constructor(self, posX, posY, width, height, text, parent)
	self:setFont(VRPFont(25)):setFontSize(1)
	self:setBarEnabled(true)
	return self
end

GUIGridChanger = inherit(GUIChanger)
function GUIGridChanger:constructor(posX, posY, width, height, parent)
	posX = grid("x", posX)
	posY = grid("y", posY)
	width = grid("d", width)
	height = grid("d", height)
	GUIChanger.constructor(self, posX, posY, width, height, parent)
	self:setVRPFontSize(25)

	return self
end

