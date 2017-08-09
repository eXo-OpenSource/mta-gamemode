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

	self.m_Items = {}
	self.m_CurrentItem = 1

	--self.m_BackButton = GUIButton:new(self.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.LightBlue):setHoverColor(Color.White):setFontSize(1)
	self.m_LeftButton = GUIButton:new(0, 0, self.m_Height, self.m_Height, FontAwesomeSymbols.Left, self):setFont(FontAwesome(15))
	:setBackgroundColor(Color.Accent)
	:setFontSize(1)
	self.m_LeftButton.onLeftClick = function()
		self.m_CurrentItem = self.m_CurrentItem - 1
		if self.m_CurrentItem <= 0 then
			self.m_CurrentItem = #self.m_Items
		end
		self:setIndex(self.m_CurrentItem)
	end
	self.m_RightButton = GUIButton:new(self.m_Width - self.m_Height, 0, self.m_Height, self.m_Height, FontAwesomeSymbols.Right, self):setFont(FontAwesome(15))
	:setBackgroundColor(Color.Accent)
	:setFontSize(1)
	self.m_RightButton.onLeftClick = function()
		self.m_CurrentItem = self.m_CurrentItem + 1
		if self.m_CurrentItem > #self.m_Items then
			self.m_CurrentItem = 1
		end
		self:setIndex(self.m_CurrentItem)
	end
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

function GUIChanger:getSelectedItem(item)
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
