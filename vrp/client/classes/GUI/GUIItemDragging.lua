-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIImage.lua
-- *  PURPOSE:     GUI image class
-- *
-- ****************************************************************************
GUIItemDragging = inherit(Singleton)

function GUIItemDragging:constructor()
	self.m_Item = nil
	self.m_PositionX = 0
	self.m_PositionY = 0
end

function GUIItemDragging:render()
	if self.m_Item then
		dxDrawImage(self.m_PositionX, self.m_PositionY, 40, 40, "files/images/Inventory/items/" .. self.m_Item.Icon)
	end
end

function GUIItemDragging:prerender()
	local cx, cy = getCursorPosition()
	if not cx then
		return
	end

	cx = cx*screenWidth
	cy = cy*screenHeight

	self.m_PositionX = cx
	self.m_PositionY = cy
end

function GUIItemDragging:setItem(item)
	self.m_Item = item
end

function GUIItemDragging:isDragging()
	return self.m_Item ~= nil
end
