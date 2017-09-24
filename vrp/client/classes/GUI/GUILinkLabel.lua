-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUILinkLabel.lua
-- *  PURPOSE:     GUI label subclass which provides a native click event
-- *
-- ****************************************************************************
GUILinkLabel = inherit(GUILabel)

function GUILinkLabel:constructor(posX, posY, width, height, text, parent)
	checkArgs("GUILabel:constructor", "number", "number", "number")
	posX, posY = math.floor(posX), math.floor(posY)
	width, height = math.floor(width), math.floor(height)

	GUILabel.constructor(self, posX, posY, width, height, text, parent)
    self:setColor(Color.Accent)

	self.m_AlignX = "left"
	self.m_AlignY = "top"

    self.onInternalHover = function()
        self:setColor(Color.White)
    end 
    self.onInternalUnhover = function()
        self:setColor(Color.Accent)
    end 
    self.onInternalLeftClick = function()
        if self.onClick then
            self.onClick()
        end
    end 
	self:setFont(VRPFont(height))
end

function GUILinkLabel:drawThis(incache)
	dxSetBlendMode("modulate_add")
		if GUI_DEBUG then
			dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
		end

		dxDrawText(self.m_Text, self.m_AbsoluteX, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_Height, self.m_Color, self:getFontSize(), self:getFont(), self.m_AlignX, self.m_AlignY, false, true, incache ~= true, false, false)
	dxSetBlendMode("blend")
end

function GUILinkLabel:setAlignX(alignX)
	self.m_AlignX = alignX
	return self
end

function GUILinkLabel:setAlignY(alignY)
	self.m_AlignY = alignY
	return self
end

function GUILinkLabel:setAlign(x, y)
	self.m_AlignX = x or self.m_AlignX
	self.m_AlignY = y or self.m_AlignY
	return self
end

function GUILinkLabel:setClickCallback(c)
	self.onClick = c
	return self
end
