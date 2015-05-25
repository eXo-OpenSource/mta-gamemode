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

    -- TODO: Don't count line breaks, but calculate it correctly using dxGetTextWidth + linebreaks (might be useful to add a new parameter to dxGetFontHeight)
    local lineBreaks = countLineBreaks(text)
    local height = (dxGetFontHeight(self.m_Label:getFontSize(), self.m_Label:getFont()) + 20) * (lineBreaks + 1) -- Tempfix: Use 20px to get a sufficient height
    self:resize(self.m_Width, height)
end

function GUIScrollableText:getText()
    return self.m_Label:getText()
end
