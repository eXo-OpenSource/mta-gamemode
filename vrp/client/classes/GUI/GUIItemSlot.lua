-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIItemSlot.lua
-- *  PURPOSE:     GUI label class
-- *
-- ****************************************************************************
GUIItemSlot = inherit(GUIElement)
inherit(GUIFontContainer, GUIItemSlot)
inherit(GUIColorable, GUIItemSlot)

function GUIItemSlot:constructor(posX, posY, width, height, slotList, slot, inventoryId, parent)
	checkArgs("GUIItemSlot:constructor", "number", "number", "number")
	posX, posY = math.floor(posX), math.floor(posY)
	width, height = math.floor(width), math.floor(height)

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, "99", 0.5, VRPFont(height))
	GUIColorable.constructor(self, Color.white, rgb(97, 129, 140))

	self.m_Multiline = false
	self.m_AlignX = "left"
	self.m_AlignY = "top"
	self.m_Rotation = 0
	self.m_InventoryId = inventoryId
	self.m_ItemData = nil
	self.m_IsMoving = false
	self.m_SlotList = slotList
	self.m_Slot = slot
	self.m_Enabled = true
	self.m_KeyChangeBind = bind(self.onKeyChange, self)
end

function GUIItemSlot:setItem(item)
	self.m_ItemData = item

	if item then
		self.m_Text = item.Amount
	end
	self:updateTooltipText()

	self:anyChange()
end

function GUIItemSlot:drawThis(incache)
	dxSetBlendMode("modulate_add")

	if GUI_DEBUG then
		dxDrawRectangle(self.m_AbsoluteX - 4, self.m_AbsoluteY - 4, self.m_Width + 8, self.m_Height + 8, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
	end

	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_BackgroundColor)

	if self.m_ItemData ~= nil then
		local alpha = self.m_IsMoving and 100 or 255

		local icon = "files/images/Inventory/items/" .. self.m_ItemData.Icon
		if string.sub(self.m_ItemData.Icon, 1, 1) == "/" then -- if the icon is laying outside files/images/Inventory/items folder
			icon = self.m_ItemData.Icon
		end

		if not fileExists(icon) then
			icon = "files/images/Inventory/items/missing.png"
		end

		local xOffset, yOffset, width, height = GUIImage.fitImageSizeToCenter(icon, self.m_Width, self.m_Height)
		dxDrawImage(self.m_AbsoluteX + xOffset, self.m_AbsoluteY + yOffset, width, height, icon, 0, 0, 0, tocolor(255, 255, 255, 255))

		if self.m_ItemData.MaxDurability > 0 then
			local progress = self.m_ItemData.Durability / self.m_ItemData.MaxDurability
			local durabilityLevelColor = tocolor(255*(1-progress), 255*progress, 0)

			dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height - 4, self.m_Width, 4, Color.Background)
			dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height - 4, self.m_Width * progress, 4, durabilityLevelColor)
		end

		if not self.m_ItemData.IsUnique and not self.m_ItemData.IsStackable and self.m_ItemData.Amount > 1 then
			local width = dxGetTextWidth(self.m_Text, self:getFontSize(), self:getFont())
			local height = dxGetFontHeight(self:getFontSize(), self:getFont()) / 1.5
			local itemAmountOffset = self.m_ItemData.MaxDurability > 0 and 4 or 0

			dxDrawRectangle(self.m_AbsoluteX + self.m_Width - width - 4, self.m_AbsoluteY + self.m_Height - height + 1 - itemAmountOffset, width + 4, height - 1, Color.Background, incache ~= true)
			dxDrawText(self.m_Text, self.m_AbsoluteX + self.m_Width - width - 2, self.m_AbsoluteY + self.m_Height - height - 2 - itemAmountOffset, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_Height - itemAmountOffset, Color.white, self:getFontSize(), self:getFont(), self.m_AlignX, self.m_AlignY, false, true, incache ~= true, false, false, 0)
		end

		if self.m_IsMoving or not self.m_Enabled then
			dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, 150))
		end
	end

	dxSetBlendMode("blend")
end

function GUIItemSlot:onHover(cursorX, cursorY)
	self:setBackgroundColor(rgb(50, 200, 255)):anyChange()
	GUIItemDragging:getSingleton():setCurrentSlot(self)
	self:updateTooltipText()
	addEventHandler("onClientKey", root, self.m_KeyChangeBind)
end

function GUIItemSlot:onUnhover(cursorX, cursorY)
	self:setBackgroundColor(rgb(97, 129, 140)):anyChange()
	if GUIItemDragging:getSingleton():getCurrentSlot() == self then
		GUIItemDragging:getSingleton():setCurrentSlot(nil)
	end
	self:updateTooltipText()
	removeEventHandler("onClientKey", root, self.m_KeyChangeBind)
end

function GUIItemSlot:onLeftClickDown()
	self.m_SlotList:onItemLeftClickDown(self)
end

function GUIItemSlot:onRightClick()
	self.m_SlotList:onItemRightClick(self)
end

function GUIItemSlot:setMoving(state)
	self.m_IsMoving = state
	self:anyChange()
	return self
end

function GUIItemSlot:setLineSpacing(lineSpacing)
	self.m_LineSpacing = lineSpacing
	return self
end

function GUIItemSlot:setMultiline(multilineEnabled)
	self.m_Multiline = multilineEnabled
	return self
end

function GUIItemSlot:setAlignX(alignX)
	self.m_AlignX = alignX
	return self
end

function GUIItemSlot:setAlignY(alignY)
	self.m_AlignY = alignY
	return self
end

function GUIItemSlot:setBackgroundColor(color)
	self.m_BackgroundColor = color
	return self
end

function GUIItemSlot:getRotation()
	return self.m_Rotation
end

function GUIItemSlot:setRotation(rot)
	self.m_Rotation = rot
	self:anyChange()
	return self
end

function GUIItemSlot:setAlign(x, y)
	self.m_AlignX = x or self.m_AlignX
	self.m_AlignY = y or self.m_AlignY
	return self
end

function GUIItemSlot:setClickable(state)
	if state then
		self:setColor(Color.Accent)
		self.onInternalHover = function()
			self:setColor(Color.White)
		end
		self.onInternalUnhover = function()
			self:setColor(Color.Accent)
		end
	else
		self:setColor(Color.White)
		self.onInternalHover = nil
		self.onInternalUnhover = nil
	end
	return self
end

function GUIItemSlot:setEnabled(state)
	self.m_Enabled = state
	return self
end

function GUIItemSlot:isEnabled()
	return self.m_Enabled
end

function GUIItemSlot:onKeyChange(button, state)
	self:updateTooltipText()
end

function GUIItemSlot:updateTooltipText()
	local item = self.m_ItemData
	local tooltipText
	local showDebug = getKeyState("lalt") and localPlayer:getRank() > 2

	if item then
		tooltipText = {}

		table.insert(tooltipText, {text = item.Name, size = 24, color = Color.White})

		if item.Tradeable == 0 then
			table.insert(tooltipText, {text = "Accountgebunden", size = 20, color = Color.Accent})
		end

		if item.IsUnique then
			table.insert(tooltipText, {text = "Einzigartig", size = 20, color = Color.White})
		end

		if item.Description and item.Description ~= "" then
			table.insert(tooltipText, {text = "", size = 20, color = Color.White})
			table.insert(tooltipText, {text = item.Description, size = 20, color = Color.White})
		end


		if showDebug then
			table.insert(tooltipText, {text = "", size = 20, color = Color.White})
			table.insert(tooltipText, {text = "DEBUG", size = 24, color = Color.White})
			for key, value in pairs(item) do
				table.insert(tooltipText, {text = ("%s: %s"):format(tostring(key), inspect(value)), size = 20, color = Color.White})
			end
		end
	end

	self:setTooltip(tooltipText)
end