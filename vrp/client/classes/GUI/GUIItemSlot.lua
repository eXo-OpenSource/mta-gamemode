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

function GUIItemSlot:constructor(posX, posY, width, height, parent)
	checkArgs("GUIItemSlot:constructor", "number", "number", "number")
	posX, posY = math.floor(posX), math.floor(posY)
	width, height = math.floor(width), math.floor(height)

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, "99", 0.6, VRPFont(height))
	GUIColorable.constructor(self, Color.white, rgb(97, 129, 140))

	self.m_Multiline = false
	self.m_AlignX = "left"
	self.m_AlignY = "top"
	self.m_Rotation = 0
	self.m_InventoryId = nil
	self.m_ItemData = nil
end

function GUIItemSlot:setItem(inventoryId, item)
	self.m_InventoryId = inventoryId
	self.m_ItemData = item

	if item then
		self.m_Text = item.Amount

		local suffix = ""

		if DEBUG then
			suffix = "\n\nDEBUG\n"
			suffix = suffix .. "TechnicalName: " .. item.TechnicalName .. "\n"
			suffix = suffix .. "Class: " .. item.Class
		end

		self:setTooltip(item.Name .. "\n" .. item.Description .. suffix, nil, true)
	else
		self:setTooltip("")
	end

	self:anyChange()
end

function GUIItemSlot:drawThis(incache)
	dxSetBlendMode("modulate_add")

	if GUI_DEBUG then
		dxDrawRectangle(self.m_AbsoluteX - 4, self.m_AbsoluteY - 4, self.m_Width + 8, self.m_Height + 8, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
	end

	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_BackgroundColor)

	if self.m_ItemData ~= nil then
		dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/Inventory/items/" .. self.m_ItemData.Icon)

		if not self.m_ItemData.IsUnique and not self.m_ItemData.IsStackable and not (self.m_ItemData.MaxDurability > 0) then
			local width = dxGetTextWidth(self.m_Text, self:getFontSize(), self:getFont())
			local height = dxGetFontHeight(self:getFontSize(), self:getFont()) / 1.5
			dxDrawText(self.m_Text, self.m_AbsoluteX + self.m_Width - width - 2, self.m_AbsoluteY + self.m_Height - height - 2, width, height, Color.white, self:getFontSize(), self:getFont(), self.m_AlignX, self.m_AlignY, false, true, incache ~= true, false, false, 0)
		elseif self.m_ItemData.MaxDurability > 0 then
			local progress = self.m_ItemData.Durability / self.m_ItemData.MaxDurability
			local durabilityLevelColor = tocolor(255*(1-progress), 255*progress, 0)

			dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height - 4, self.m_Width, 4, Color.Background)
			dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height - 4, self.m_Width * progress, 4, durabilityLevelColor)
		end
	end

	dxSetBlendMode("blend")
end

function GUIItemSlot:onHover(cursorX, cursorY)
	self:setBackgroundColor(rgb(50, 200, 255)):anyChange()
end

function GUIItemSlot:onUnhover(cursorX, cursorY)
	self:setBackgroundColor(rgb(97, 129, 140)):anyChange()
end

function GUIItemSlot:onLeftClick()
	if self.m_ItemData ~= nil then
		triggerEvent("onInventoryItemLeft", localPlayer, self.m_InventoryId, self.m_ItemData)
	end
end

function GUIItemSlot:onRightClick()
	if self.m_ItemData ~= nil then
		triggerEvent("onInventoryItemRight", localPlayer, self.m_InventoryId, self.m_ItemData)
	end
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
