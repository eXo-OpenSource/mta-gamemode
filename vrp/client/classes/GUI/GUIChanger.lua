-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIChanger.lua
-- *  PURPOSE:     Changer GUI element class
-- *
-- ****************************************************************************
GUIChanger = inherit(GUIElement)
inherit(GUIFontContainer, GUIChanger)
inherit(GUIColorable, GUIChanger)

function GUIChanger:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, "", 1, VRPFont(height*.9))
	GUIColorable.constructor(self, Color.White)

	self.m_BackgroundColor = Color.LightBlue

	self.m_Items = {}
	self.m_CurrentItem = 1

	self.m_LeftButton = GUIRectangle:new(2, 2, self.m_Height - 4, self.m_Height - 4, Color.Accent, self)
	self.m_LeftButton.onHover =
		function()
			self.m_LeftLabel:setColor(Color.Black)
			self.m_LeftButton:setColor(Color.White)
			Animation.Move:new(self.m_LeftButton, 150, 0, 0, "OutQuad")
			Animation.Size:new(self.m_LeftButton, 150, self.m_Height, self.m_Height, "OutQuad")
		end
	self.m_LeftButton.onUnhover =
		function()
			self.m_LeftLabel:setColor(Color.White)
			self.m_LeftButton:setColor(Color.Accent)
			Animation.Move:new(self.m_LeftButton, 150, 2, 2, "OutQuad")
			Animation.Size:new(self.m_LeftButton, 150, self.m_Height - 4, self.m_Height - 4, "OutQuad")
		end
	self.m_LeftButton.onLeftClick =
		function()
			self.m_CurrentItem = self.m_CurrentItem - 1
			if self.m_CurrentItem <= 0 then
				self.m_CurrentItem = #self.m_Items
			end
			self:setIndex(self.m_CurrentItem)
		end

	self.m_RightButton = GUIRectangle:new(self.m_Width - self.m_Height + 2, 2, self.m_Height - 4, self.m_Height - 4, Color.Accent, self)
	self.m_RightButton.onHover =
		function()
			self.m_RightLabel:setColor(Color.Black)
			self.m_RightButton:setColor(Color.White)
			Animation.Move:new(self.m_RightButton, 150, self.m_Width - self.m_Height, 0, "OutQuad")
			Animation.Size:new(self.m_RightButton, 150, self.m_Height, self.m_Height, "OutQuad")
		end
	self.m_RightButton.onUnhover =
		function()
			self.m_RightLabel:setColor(Color.White)
			self.m_RightButton:setColor(Color.Accent)
			Animation.Move:new(self.m_RightButton, 150, self.m_Width - self.m_Height + 2, 2, "OutQuad")
			Animation.Size:new(self.m_RightButton, 150, self.m_Height - 4, self.m_Height - 4, "OutQuad")
		end
	self.m_RightButton.onLeftClick =
		function()
			self.m_CurrentItem = self.m_CurrentItem + 1
			if self.m_CurrentItem > #self.m_Items then
				self.m_CurrentItem = 1
			end
			self:setIndex(self.m_CurrentItem)
		end

	self.m_LeftLabel = GUILabel:new(0, 0, self.m_Height, self.m_Height, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setFontSize(1):setAlign("center", "center")
	self.m_RightLabel = GUILabel:new(self.m_Width - self.m_Height, 0, self.m_Height, self.m_Height, FontAwesomeSymbols.Right, self):setFont(FontAwesome(20)):setFontSize(1):setAlign("center", "center")
end

function GUIChanger:drawThis()
	dxSetBlendMode("modulate_add")
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, Color.PrimaryNoClick)
	dxDrawText(self.m_Items[self.m_CurrentItem] or "", self.m_AbsoluteX + self.m_Height, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width - self.m_Height, self.m_AbsoluteY + self.m_Height, self:getColor(), self:getFontSize(), self:getFont(), "center", "center")
	dxSetBlendMode("blend")
end

function GUIChanger:addItem(text)
	local itemId = #self.m_Items + 1
	self.m_Items[itemId] = text
	self:anyChange()
	return itemId
end

function GUIChanger:setIndex(index, dontTriggerChangeEvent)
	if index <= 0 or index > #self.m_Items then
		return false
	end

	self.m_CurrentItem = index
	if not dontTriggerChangeEvent and self.onChange then
		self.onChange(self.m_Items[index], index)
	end
	self:anyChange()
end

function GUIChanger:setSelectedItem(item)
	for k,v in ipairs(self.m_Items) do
		if item == v then
			self:setIndex(k)
		end
	end
end

function GUIChanger:setBackgroundColor(color)
	self.m_BackgroundColor = color
	self:anyChange()
	return self
end

function GUIChanger:getSelectedItem()
	return self.m_Items[self.m_CurrentItem], self.m_CurrentItem
end

function GUIChanger:getIndex()
	return self.m_Items[self.m_CurrentItem], self.m_CurrentItem
end

function GUIChanger:clear()
	self.m_Items = {}
	self.m_CurrentItem = 1
	self:anyChange()
end
