-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIElements/VRPItem.lua
-- *  PURPOSE:     Inventory Item class
-- *
-- ****************************************************************************
VRPItem = inherit(GUIRectangle)

function VRPItem:constructor(posX, posY, width, height, item, parent)
	checkArgs("VRPItem:constructor", "number", "number", "number", "number")
	GUIRectangle.constructor(self, posX, posY, width, height, Color.Grey, parent)

	self.m_Item = item
	local id = item:getItemId()

	if Items[id].imagepath then
		self.m_Icon = GUIImage:new(5, 5, height-15, height-15, Items[id].imagepath, self)
	else
		self.m_Icon = GUIRectangle:new(5, 5, height-15, height-15, tocolor(255, 255, 0), self)
	end

	-- Name
	GUILabel:new(height, 0, width, height/5*3, Items[id].name, self):setFont(VRPFont(height/5*4))
	-- Description
	GUILabel:new(height+15, height-height/3-5, width, height/3, Items[id].description, self)
	local counttext = tostring(item:getCount())
	local fw = fontWidth(counttext, "default", 3)
	self.m_Count = GUILabel:new(width-fw-10, 0, fw+10, height, counttext, self):setAlignY("center") -- note: 3
end

function VRPItem:select()
	self:setColor(Color.Accent)
end

function VRPItem:deselect()
	self:setColor(Color.Grey)
end

function VRPItem:updateFromItem()
	-- If we are just removing the item we do not want to change it anymore
	if self.m_AnimRemove then return end

	-- Update Count
	local oldcount = tonumber(self.m_Count:getText())
	if oldcount ~= self.m_Item.m_Count then
		local count = self.m_Item:getCount()
		local counttext = tostring(count)
		local fw = fontWidth(counttext, "default", 3)
		self.m_Count:setText(counttext)
		self.m_Count.m_Width = fw+10
		self.m_Count:setPosition(self.m_Width-fw-10)
		self.m_Count:anyChange()
	end

	if self.m_Item.m_Count == 0 then
		self:playRemoveAnimation()
	end
end

function VRPItem:playRemoveAnimation()
	if self.m_AnimRemove then return end

	local tx = self.m_PosX + self.m_Width + 15
	self.m_AnimRemove = Animation.Move:new(self, 1500, tx, self.m_PosY)
	self.m_AnimRemove.onFinish = function()
		if self.onItemRemove then
			self:onItemRemove(self)
		end
		delete(self)
	end
end

function VRPItem:move(x, y)
	if self.m_AnimRemove then return end
	if self.m_AnimMove then
		delete(self.m_AnimMove)
	end
	self.m_AnimMove = Animation.Move:new(self, 500, x, y)
end
