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
	self.m_CurrentSlot = nil
end

function GUIItemDragging:render()
	if self.m_Item then
		if not getKeyState("mouse1") then
			local hoveredInventory = InventoryManager:getSingleton():isHovering()
			if self.m_CurrentSlot and hoveredInventory then
				triggerServerEvent("onItemMove", localPlayer, self.m_Slot.m_InventoryId, self.m_Slot.m_ItemData.Id, self.m_CurrentSlot.m_InventoryId, self.m_CurrentSlot.m_Slot)
				playSound("files/audio/Inventory/move-drop.mp3")
			elseif not hoveredInventory then
				--self.m_Slot:setItem(nil, nil)
				InventoryActionGUI:new(_"Löschen")
			end
			self.m_Slot:setMoving(false)
			self:clearItem()
			return
		end

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

function GUIItemDragging:setItem(item, slot)
	self.m_Item = item
	self.m_Slot = slot
	self.m_Slot:setMoving(true)
end

function GUIItemDragging:clearItem()
	self.m_Item = nil
	self.m_Slot = nil
end

function GUIItemDragging:isDragging()
	return self.m_Item ~= nil
end

function GUIItemDragging:setCurrentSlot(slot)
	self.m_CurrentSlot = slot
end

function GUIItemDragging:getCurrentSlot()
	return self.m_CurrentSlot
end

function GUIItemDragging:isDragging()
	return self.m_Item ~= nil
end
