-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InventoryGUI.lua
-- *  PURPOSE:     Inventory GUI class
-- *
-- ****************************************************************************
InventoryGUI = inherit(GUIForm)
inherit(Singleton, InventoryGUI)

function InventoryGUI:constructor()
	self.m_Inventory = false
	self.m_GUIItems = {}
	self.m_SelectedItem = false
	self.m_CurrentCategory = ItemCategory.All

	local w, h = screenWidth*0.6, screenHeight*0.6
	GUIForm.constructor(self, screenWidth/2-w/2, screenHeight/2-h/2, w, h)
	self.m_Background = GUIWindow:new(0, 0, w, h, "", false, true, self)
	self.m_Background:deleteOnClose(false)

	-- todo: make dependand on h instead
	local ENTRYHEIGHT = screenHeight/100*7
	local ENTRYWIDTH = w/3*2-50
	local ENTRYSPACE = screenHeight/100

	self.m_Scrollable = GUIScrollableArea:new(w/3, 50, ENTRYWIDTH, self.m_Height*0.78, ENTRYWIDTH, screenHeight, false, false, self)

	self.m_CategoryRects = {}
	for categoryId, categoryName in ipairs(ItemItemCategoryNames) do
		local rect = GUIRectangle:new(w*0.05, 50 + (ENTRYHEIGHT+ENTRYSPACE)*(categoryId-1), w*0.25, ENTRYHEIGHT, Color.Grey, self)
		local iw, ih = rect:getSize()
		GUILabel:new(iw*0.05, ih*0.05, iw*0.9, ih*0.9, categoryName, rect)
		rect.onLeftClick = bind(self.Category_Click, self, categoryId, rect)
		table.insert(self.m_CategoryRects, rect)
	end
	self.m_CategoryRects[1]:setColor(Color.LightBlue)

	-- Error box
	self.m_ErrorBox = GUIRectangle:new(w/3, h-h/100*9, w/4, h*0.06, Color.Clear, self)
	self.m_ErrorText = GUILabel:new(0, 0, self.m_ErrorBox.m_Width, self.m_ErrorBox.m_Height, "", self.m_ErrorBox):setColor(Color.Red)
	self.m_ErrorText:setAlign("center", "center")
	self.m_ErrorBox:hide()

	-- Buttons
	local useText = _"Verwenden"
	local fwUse = fontWidth(useText, "default", 1.75)
	self.m_ButtonUse = GUIButton:new(w/3+w/3*2-50-fwUse*1.3, h-h/100*9, fwUse*1.3, h/100*6, useText, self):setBackgroundColor(tocolor(28, 101, 28)):setBarEnabled(true)

	local removeText = _"Wegwerfen"
	local fwRemove = fontWidth(removeText, "default", 1.75)
	self.m_ButtonDiscard = GUIButton:new(w/3+w/3*2-50-fwUse*1.3-fwRemove*1.3-20, h-h/100*9, fwRemove*1.3, h/100*6, removeText, self):setBackgroundColor(tocolor(143, 0, 0)):setBarEnabled(true)

	self.m_ButtonUse.onLeftClick = bind(self.ButtonUse_Click, self)
	self.m_ButtonDiscard.onLeftClick = bind(self.ButtonDiscard_Click, self)
end

function InventoryGUI:setInventory(inv, loadContent)
	self.m_Inventory = inv

	if loadContent then
		self:clear()
		for k, item in ipairs(inv:getItems()) do
			self:addItem(item)
		end
	end
end

function InventoryGUI:destructor()
	self:clear()
end

function InventoryGUI:getInventory()
	return self.m_Inventory
end

function InventoryGUI:clear()
	for guiItem, item in pairs(self.m_GUIItems) do
		delete(guiItem)
	end
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
		triggerServerEvent("inventoryUseItem", resourceRoot, self.m_InventoryId, item:getItemId(), item:getSlot())
		self.m_SelectedItem:updateFromItem()
	else
		self.m_ErrorText:setText(_"Fehler: \nDieses Item ist nicht verwendbar!")
		self.m_ErrorBox:show()
	end
end

function InventoryGUI:ButtonDiscard_Click()
	if not self.m_SelectedItem then
		self.m_ErrorBox:show()
		self.m_ErrorText:setText(_"Fehler: \nKein Item ausgewählt!")
		return
	end

	local item = self.m_GUIItems[self.m_SelectedItem]
	if not item then return end

	-- Tell the server that we want to remove the item
	triggerServerEvent("inventoryDropItem", resourceRoot, self.m_Id, item:getItemId(), item:getSlot(), 1)
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


function InventoryGUI:addItem(item)
	local w, h = screenWidth/5*3, screenHeight/5*3
	local ENTRYHEIGHT = screenHeight/100*7
	local ENTRYWIDTH = w/3*2-50
	local ENTRYSPACE = screenHeight/100

	local vrpitem = VRPItem:new(0, (ENTRYHEIGHT+ENTRYSPACE)*(table.size(self.m_GUIItems)-1), ENTRYWIDTH, ENTRYHEIGHT, item, self.m_Scrollable)
	self.m_GUIItems[vrpitem] = item
	vrpitem.onLeftClick = bind(InventoryGUI.Item_Click, self, vrpitem, item)
	self:resort(false)
end

function InventoryGUI:removeItem(item, amount)
	local guiItem = self:getGUIItemByItem(item)
	if guiItem then
		guiItem:updateFromItem()
		guiItem.onItemRemove = function() self:resort(false) end
	end

	if item:getCount() == 0 then
		self.m_GUIItems[guiItem] = nil

		if guiItem == self.m_SelectedItem then
			self.m_SelectedItem = false
		end
	end
end

function InventoryGUI:getGUIItemByItem(item)
	return table.find(self.m_GUIItems, item)
end

function InventoryGUI:resort(useanim)
	local w, h = screenWidth/5*3, screenHeight/5*3
	local ENTRYHEIGHT = screenHeight*0.07
	local ENTRYWIDTH = w/3*2-50
	local ENTRYSPACE = screenHeight*0.01
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
