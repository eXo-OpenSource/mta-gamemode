-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIRoundedRect.lua
-- *  PURPOSE:     GUI rounded rectangle class
-- *
-- ****************************************************************************
GUIRoundedRect = inherit(GUIElement)
inherit(GUIColorable, GUIRoundedRect)

function GUIRoundedRect:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	
	-- Set default color
	self:setColor(tocolor(0, 0, 0, 200))
end

function GUIRoundedRect:drawThis()
	-- Top-left corner
	dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, 32, 32, "files/images/GUI/RoundedCorner.png", 0, 0, 0, self.m_Color)
	
	-- Top rectangle
	dxDrawRectangle(self.m_AbsoluteX + 32, self.m_AbsoluteY, self.m_Width - 64, 32, self.m_Color)
	
	-- Top-right corner
	dxDrawImage(self.m_AbsoluteX + self.m_Width - 32, self.m_AbsoluteY, 32, 32, "files/images/GUI/RoundedCorner.png", 90, 0, 0, self.m_Color)
	
	-- Left rectangle
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + 32, 32, self.m_Height - 64, self.m_Color)
	
	-- Bottom-left corner
	dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height - 32, 32, 32, "files/images/GUI/RoundedCorner.png", 270, 0, 0, self.m_Color)
	
	-- Bottom rectangle
	dxDrawRectangle(self.m_AbsoluteX + 32, self.m_AbsoluteY + self.m_Height - 32, self.m_Width - 64, 32, self.m_Color)
	
	-- Bottom-right corner
	dxDrawImage(self.m_AbsoluteX + self.m_Width - 32, self.m_AbsoluteY + self.m_Height - 32, 32, 32, "files/images/GUI/RoundedCorner.png", 180, 0, 0, self.m_Color)
	
	-- Right rectangle
	dxDrawRectangle(self.m_AbsoluteX + self.m_Width - 32, self.m_AbsoluteY + 32, 32, self.m_Height - 64, self.m_Color)
	
	-- Main square
	dxDrawRectangle(self.m_AbsoluteX + 32, self.m_AbsoluteY + 32, self.m_Width - 64, self.m_Height - 64, self.m_Color)
end
