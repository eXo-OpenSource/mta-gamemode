-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIScrollableText.lua
-- *  PURPOSE:     GUI sscrollable text; Use it only if you have to
-- *               It's necessary to manually add line breaks (atm)
-- *
-- ****************************************************************************
GUIScrollableText = inherit(GUIScrollableArea)

function GUIScrollableText:constructor(posX, posY, width, height, text, textSize, parent)
    GUIScrollableArea.constructor(self, posX, posY, width, height, 1, 1, true, false, parent, 40)

    self.m_Label = GUILabel:new(0, 0, width, textSize, text, self)
    self.m_Label:setFont(VRPFont(textSize))
    self:setText(text)
end

function GUIScrollableText:setText(text)
    self.m_Label:setText(text)
    self:setScrollPosition(0, 0)
    self:resize(self.m_Width, textHeight(text, self.m_Width, self.m_Label:getFont(), self.m_Label:getFontSize()))
end

function GUIScrollableText:getText()
    return self.m_Label:getText()
end
