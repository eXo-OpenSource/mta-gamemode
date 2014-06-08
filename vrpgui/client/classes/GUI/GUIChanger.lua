-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIChanger.lua
-- *  PURPOSE:     Changer GUI element class
-- *
-- ****************************************************************************
GUIChanger = inherit(GUIElement)
inherit(GUIColorable, GUIChanger)

function GUIChanger:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, Color.White)
	
	self.m_Items = {}
	self.m_CurrentItem = 1
	
	self.m_LeftButton = GUIButton:new(0, 0, self.m_Height, self.m_Height, "<", self)
	self.m_LeftButton.onLeftClick = function()
		self.m_CurrentItem = self.m_CurrentItem - 1
		if self.m_CurrentItem <= 0 then
			self.m_CurrentItem = #self.m_Items
		end
		self:setIndex(self.m_CurrentItem)
	end
	self.m_RightButton = GUIButton:new(self.m_Width - self.m_Height, 0, self.m_Height, self.m_Height, ">", self)
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
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, Color.DarkBlue)
	dxDrawText(self.m_Items[self.m_CurrentItem], self.m_AbsoluteX + self.m_Height, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width - self.m_Height, self.m_AbsoluteY + self.m_Height, self:getColor(), 1, VRPFont(self.m_Height-8), "center", "center")
	dxSetBlendMode("blend")
end

function GUIChanger:addItem(text)
	table.insert(self.m_Items, text)
end

function GUIChanger:setIndex(index)
	if index <= 0 or index > #self.m_Items then
		return false
	end
	
	self.m_CurrentItem = index
	if self.onChange then
		self.onChange(self.m_Items[index])
	end
	self:anyChange()
end

addCommandHandler("changer",
	function()
		local c = GUIChanger:new(500, 500, 250, 40)
		c:addItem("Item 1")
		c:addItem("Item 2")
		c:addItem("Item 3")
		c:addItem("Item 4")
	end
)
