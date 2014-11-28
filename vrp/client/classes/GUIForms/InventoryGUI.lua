-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InventoryGUI.lua
-- *  PURPOSE:     Inventory GUI class
-- *
-- ****************************************************************************
InventoryGUI = inherit(GUIForm)
inherit(Singleton, InventoryGUI)
InventoryGUI.Map = {}

function InventoryGUI:constructor()
	self.m_Inventory = false
	self.m_GUIItems = {}
	self.m_SelectedItem = false
	self.m_CurrentCategory = ItemCategory.All
	InventoryGUI.Map[inventoryId] = self

	local w, h = screenWidth/5*3, screenHeight/5*3
	GUIForm.constructor(self, screenWidth/5*1, screenHeight/5*1, w, h)
	self.m_Background = GUIRectangle:new(0, 0, w, h, tocolor(0, 0, 0, 150), self)
	
	-- todo: make dependand on h instead
	local ENTRYHEIGHT = screenHeight/100*7
	local ENTRYWIDTH = w/3*2-50
	local ENTRYSPACE = screenHeight/100
	
	self.m_Scrollable = GUIScrollableArea:new(w/3, 50, ENTRYWIDTH, screenHeight, ENTRYWIDTH, screenHeight, false, false, self)
	
	self.m_CategoryRects = {}
	for categoryId, categoryName in ipairs(ItemItemCategoryNames) do
		local rect = GUIRectangle:new(w*0.05, 50 + (ENTRYHEIGHT+ENTRYSPACE)*(categoryId-1), w*0.25, ENTRYHEIGHT, Color.Grey, self)
		local iw, ih = rect:getSize()
		GUILabel:new(iw*0.05, ih*0.05, iw*0.9, ih*0.9, categoryName, rect)
		rect.onLeftClick = bind(self.Category_Click, self, categoryId, rect)
		table.insert(self.m_CategoryRects, rect)
	end
	self.m_CategoryRects[1]:setColor(Color.LightBlue)
	
	-- Error Box
	self.m_ErrorBox = GUIRectangle:new(50, h/100*80, w/4, h/100*15, tocolor(173, 14, 22, 255), self)
	self.m_ErrorText = GUILabel:new(0, 0, w/4, h/100*15, "", self.m_ErrorBox) -- 1.5
	self.m_ErrorText:setAlign("center", "center")
	self.m_ErrorBox:hide()
	
	-- Buttons
	local useText = _"Verwenden"
	local fwUse = fontWidth(useText, "default", 1.75)
	self.m_ButtonUse = VRPButton:new(w/3+w/3*2-50-fwUse*1.3, h-h/100*9, fwUse*1.3, h/100*6, useText, true, self):setBarColor(tocolor(28, 101, 28))
	
	local removeText = _"Wegwerfen"
	local fwRemove = fontWidth(removeText, "default", 1.75)
	self.m_ButtonDiscard = VRPButton:new(w/3+w/3*2-50-fwUse*1.3-fwRemove*1.3-20, h-h/100*9, fwRemove*1.3, h/100*6, removeText, true, self):setBarColor(tocolor(143, 0, 0))
	
	self.m_ButtonUse.onLeftClick = bind(self.ButtonUse_Click, self)
	self.m_ButtonDiscard.onLeftClick = bind(self.ButtonDiscard_Click, self)
end

function InventoryGUI:setInventory(inv, loadContent)
	self.m_Inventory = inv
	
	if loadContent then
		for k, item in ipairs(inv:getItems()) do
			item:addItem(item)
		end
	end
end

function InventoryGUI:getInventory()
	return self.m_Inventory
end

function InventoryGUI:clear()
	-- TODO: Call destructors
	self.m_Items = {}
	self.m_GUIItems = {}
end

function InventoryGUI:ButtonUse_Click()
	if not self.m_SelectedItem then
		self.m_ErrorBox:show()
		self.m_ErrorText:setText(_"Fehler: \nKein Item ausgewählt!")
		return
	end
	
	local item = self.m_GUIItems[self.m_SelectedItem]
	assert(item)
	if item.use then
		--item:use()
		triggerServerEvent("inventoryUseItem", root, self.m_InventoryId, item:getItemId(), item:getSlot())
		self.m_SelectedItem:updateFromItem()
	else
		self.m_ErrorText:setText(_"Fehler: \nDieses Item ist nicht verwendbar!")
		self.m_ErrorBox:show()
	end
end

function InventoryGUI:ButtonDiscard_Click()
	-- ToDo: Send to server
	if not self.m_SelectedItem then
		self.m_ErrorBox:show()
		self.m_ErrorText:setText(_"Fehler: \nKein Item ausgewählt!")
		return
	end
	
	local item = self.m_GUIItems[self.m_SelectedItem]
	self.m_Inventory:removeItem(item, 1)
	if not item or item:getCount() == 0 then
		self.m_SelectedItem = false
	end
end

function InventoryGUI:Category_Click(categoryId, rect, cx, cy)
	for k, v in pairs(self.m_CategoryRects) do
		v:setColor(Color.Grey)
	end
	rect:setColor(Color.LightBlue)
	self.m_CurrentCategory = categoryId
	self:resort(false)
end


function InventoryGUI:Item_Click(vrpitem, item)
	if self.m_SelectedItem then
		self.m_SelectedItem:deselect()
	end
	
	self.m_SelectedItem = vrpitem
	self.m_SelectedItem:select()
end

function InventoryGUI:Item_Remove(item)
	self.m_GUIItems[item] = nil
	self:resort(false)
	if item == self.m_SelectedItem then
		self.m_SelectedItem = false
	end
end

function InventoryGUI:addItem(item)
	local w, h = screenWidth/5*3, screenHeight/5*3
	local ENTRYHEIGHT = screenHeight/100*7
	local ENTRYWIDTH = w/3*2-50
	local ENTRYSPACE = screenHeight/100

	local vrp = VRPItem:new(0, (ENTRYHEIGHT+ENTRYSPACE)*(table.size(self.m_GUIItems)-1), ENTRYWIDTH, ENTRYHEIGHT, item, self.m_Scrollable)
	self.m_GUIItems[vrp] = item
	vrp.onLeftClick = bind(InventoryGUI.Item_Click, self, vrp, item)
	self:resort(false)
end

function InventoryGUI:getGUIItemByItem(item)
	return table.find(self.m_GUIItems, item)
end

function InventoryGUI:resort(useanim)
	local w, h = screenWidth/5*3, screenHeight/5*3
	local ENTRYHEIGHT = screenHeight/100*7
	local ENTRYWIDTH = w/3*2-50
	local ENTRYSPACE = screenHeight/100
	useanim = false -- Force anim being off
	
	-- Todo: Add resort methods (table.sort GUIItems table)
	local i = 0
	for gui, item in pairs(self.m_GUIItems) do
		if self.m_CurrentCategory == ItemCategory.All or Items[item:getItemId()].category == self.m_CurrentCategory then
			if not useanim then
				gui:setPosition(0, (ENTRYHEIGHT+ENTRYSPACE)*i)
			else
				gui:move(0, (ENTRYHEIGHT+ENTRYSPACE)*i)
			end
			i = i+1
			gui:setVisible(true)
		else
			gui:setVisible(false)
		end
	end
end




--[[
Sort stuff (reintegrate later):

local sortText = _"Sortieren"
local fwSort = fontWidth(sortText, "default", 1.75)
self.m_ButtonSort = VRPButton:new(w/3+w/3*2-50-fwSort*1.3-fwUse*1.3-20, h-h/100*9, fwSort*1.3, h/100*6, sortText, true, self):setBarColor(tocolor(26, 85, 163))
	
self.m_ButtonSort.onLeftClick = bind(function(self)
	if not self.m_SelectedItem then
		self.m_ErrorBox:show()
		self.m_ErrorText:setText(_"Fehler: \nKein Item ausgewählt!")
		return
	end
	
	local item = self.m_GUIItems[self.m_SelectedItem]
	assert(item)
	item.m_Count = item.m_Count +1
	self.m_SelectedItem:updateFromItem()
	
end, self)


]]
