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
	GUIRectangle.constructor(self, posX, posY, width, height, tocolor(12, 26, 47, 255), parent)
	
	local id = item:getItemId()
	
	if Items[id].icon then
		-- Icon here
	else
		self.m_Icon = GUIRectangle:new(5, 5, height-15, height-15, tocolor(255, 255, 0), self)
	end
	
	-- Name
	GUILabel:new(height, 5, width, height, Items[id].name, 2.5, self)
	-- Description
	GUILabel:new(height+15, height-20, width, height, Items[id].description, 1, self)
	local counttext = tostring(item:getCount())
	local fw = fontWidth(counttext, "default", 3)
	self.m_Count = GUILabel:new(width-fw-10, 0, fw+10, height, counttext, 3, self):setAlignY("center")
end

function VRPItem:select()
	self:setColor(tocolor(26, 62, 80, 255))
end

function VRPItem:deselect()
	self:setColor(tocolor(12, 26, 47, 255))
end