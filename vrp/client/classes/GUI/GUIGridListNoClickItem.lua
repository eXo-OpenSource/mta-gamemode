-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIGridListNoClickItem.lua
-- *  PURPOSE:     GUI gridlist item class that retrieves no clicks by default
-- *
-- ****************************************************************************
GUIGridListNoClickItem = inherit(GUIGridListItem)
inherit(GUIColorable, GUIGridListNoClickItem)

function GUIGridListNoClickItem:constructor(...)
	GUIGridListItem.constructor(self, ...)
end

function GUIGridListNoClickItem:drawThis()
	dxSetBlendMode("modulate_add")
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Color)

	local currentXPos = 0
	for columnIndex, columnValue in ipairs(self.m_Columns) do
		local columnWidth = self:getGridList():getColumnWidth(columnIndex)
		-- Todo: Find a better color
		dxDrawText(self.m_Columns[columnIndex].text, self.m_AbsoluteX + currentXPos + 4, self.m_AbsoluteY + 1, self.m_AbsoluteX + currentXPos + columnWidth*self.m_Width - 4, self.m_Height, Color.Red, 1, VRPFont(28), self.m_Columns[columnIndex].alignX)
		currentXPos = currentXPos + columnWidth*self.m_Width + 5
	end
	dxSetBlendMode("blend")
end

-- Disable clicks
GUIGridListNoClickItem.onInternalLeftClick = nil
