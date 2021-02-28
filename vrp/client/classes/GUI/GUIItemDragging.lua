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
				--triggerServerEvent("onItemMove", localPlayer, self.m_Slot.m_InventoryId, self.m_Slot.m_ItemData.Id, self.m_CurrentSlot.m_InventoryId, self.m_CurrentSlot.m_Slot)
				InventoryManager:getSingleton():onItemDrop(self.m_Slot.m_InventoryId, self.m_Slot.m_ItemData, self.m_CurrentSlot.m_InventoryId, self.m_CurrentSlot.m_Slot, self.m_MoveType)
				playSound("files/audio/Inventory/move-drop.mp3")
			elseif not hoveredInventory then
				--self.m_Slot:setItem(nil, nil)
				InventoryActionGUI:new(_"Löschen")
			end
			self.m_Slot:setMoving(false)
			self:clearItem()
			return
		end

		local icon = self.m_Item.Icon
		if self.m_Item.Metadata and self.m_Item.Metadata.Icon then
			icon = self.m_Item.Metadata.Icon
		end

		if not fileExists(icon) then
			icon = "files/images/Inventory/items/missing.png"
		end
		local xOffset, yOffset, width, height = GUIImage.fitImageSizeToCenter(icon, 40, 40)
		dxDrawImage(self.m_PositionX, self.m_PositionY, width, height, icon)

		local amount = self.m_MoveType == "half" and math.floor(self.m_Slot.m_ItemData.Amount/2) or self.m_MoveType == "single" and 1 or self.m_Slot.m_ItemData.Amount
		if amount > 1 then
			local textWidth = dxGetTextWidth(amount, 1, getVRPFont(VRPFont(20)))
			local textHeight = dxGetFontHeight(1, getVRPFont(VRPFont(20))) / 1.5
			dxDrawRectangle(self.m_PositionX + width - textWidth - 4, self.m_PositionY + height - textHeight + 1, textWidth + 4, textHeight - 1, Color.Background)
			dxDrawText(amount, self.m_PositionX + width - textWidth - 2, self.m_PositionY + height - textHeight - 2, self.m_PositionX + width, self.m_PositionY + height, Color.white, 1, getVRPFont(VRPFont(20)))
		end
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

function GUIItemDragging:setItem(item, slot, moveType)
	self.m_Item = item
	self.m_Slot = slot
	self.m_MoveType = moveType
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
