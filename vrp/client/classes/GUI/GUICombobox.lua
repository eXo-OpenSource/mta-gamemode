-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUICombobox.lua
-- *  PURPOSE:     GUI combobox class
-- *
-- ****************************************************************************

GUICombobox = inherit(GUIElement)
local ITEM_HEIGHT = 30

function GUICombobox:constructor(posX, posY, width, height, displayText, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)

	self.m_TextMargin = height*0.05
	self.m_HeaderHeight = height
	self.m_Background = GUIRectangle:new(0, 0, width, height, Color.Primary, self)
	self.m_DisplayText = displayText
	self.m_Button = GUILabel:new(self.m_TextMargin*4, self.m_TextMargin, width, height-self.m_TextMargin, displayText, self.m_Background)
	self.m_Button.onLeftClick = function()
		local visible = not self.m_List:isVisible()
		self:internalShowItems(visible)
	end

	self.m_DropIconX = 0 + width - height - self.m_TextMargin
	self.m_DropIcon = GUILabel:new(self.m_DropIconX, 0, height, height, "", self.m_Button)
	self.m_DropIcon:setAlignX("center")
	self.m_DropIcon:setAlignY("center")
	self.m_DropIcon:setFont(FontAwesome(15)):setFontSize(1)
	self.m_DropIconMoveTime = 100 -- must be >= 50
	self.m_DropIconLastMove = 0

	self.m_Background.onHover = -- looking at this code is prohibited by federal law
		function()
			if getTickCount() - self.m_DropIconLastMove >= self.m_DropIconMoveTime*2 then
				self.m_DropIconMoving = true
				Animation.Move:new(self.m_DropIcon, self.m_DropIconMoveTime, self.m_DropIconX, self:areItemsVisible() and -4 or 4, "OutQuad")
				setTimer(function() --do not look at this code pls
					Animation.Move:new(self.m_DropIcon, self.m_DropIconMoveTime, self.m_DropIconX, 0, "InQuad")
				end, self.m_DropIconMoveTime, 1)
			end
		end

	self.m_List = GUIGridList:new(self.m_PosX, self.m_PosY, width, 200, self:getParent())
	self.m_List:setColumnBackgroundColor(Color.Clear)
	self.m_List.onSelectItem = function(item)
		self:internalShowItems(false)

		if self.onSelectItem then
			self.onSelectItem(item)
		end
	end
	self.m_List:addColumn("", 1)
	self.m_List:setVisible(false)
end

function GUICombobox:internalShowItems(visible)
	self.m_List:setVisible(visible)
	if visible then -- draw it at front of other child elements - very hacky lol
		table.removevalue(self.m_List:getParent().m_Children, self.m_List)
		table.insert(self.m_List:getParent().m_Children, self.m_List)
	end
	self.m_DropIcon:setText(visible and "" or "")
	if visible then
		self.m_Button:setText(self.m_DisplayText)
	elseif not visible and self:getSelectedItem() then
		self.m_Button:setText(self:getSelectedItem():getColumnText(1))
	end
end

function GUICombobox:areItemsVisible()
	return self.m_List:isVisible()
end

function GUICombobox:addItem(text)
	local item = self.m_List:addItem(text)
	self.m_List:setSize(nil, math.min(#self.m_List:getItems()*ITEM_HEIGHT + self.m_HeaderHeight, 6*ITEM_HEIGHT + self.m_HeaderHeight))
	return item
end

function GUICombobox:getSelectedItem(...)
	return self.m_List:getSelectedItem(...)
end

function GUICombobox:setSelectedItem(...)
	self.m_List:setSelectedItem(...)
	if not self:areItemsVisible() then
		self.m_Button:setText(self.m_List:getSelectedItem():getColumnText(1))
	end
end

function GUICombobox:clear()
	return self.m_List:clear()
end

