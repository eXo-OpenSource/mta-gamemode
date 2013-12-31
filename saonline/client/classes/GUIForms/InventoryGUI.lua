InventoryGUI = inherit(GUIForm)

function InventoryGUI:constructor()
	local sw, sh = guiGetScreenSize()
	local w, h = sw/5*3, sh/5*3

	GUIForm.constructor(self, sw/5*1, sh/5*1, w, h)
	self.m_Background = GUIRectangle:new(0, 0, w, h, tocolor(2, 17, 39, 255), self)
	self.m_Items = { Item:new(ITEM_CRACK); Item:new(ITEM_LSD); }
	self.m_GUIItems = {}
	self.m_SelectedItem = false;
	-- todo: make dependand on h instead
	local ENTRYHEIGHT = sh/100*7
	local ENTRYWIDTH = w/3*2-50
	local ENTRYSPACE = sh/100
	
	self.m_Scrollable = GUIScrollableArea:new(w/3, 50, ENTRYWIDTH, sh, ENTRYWIDTH, sh, false, false, self)
	for i, item in ipairs(self.m_Items) do
		local vrp = VRPItem:new(0, (ENTRYHEIGHT+ENTRYSPACE)*(i-1), ENTRYWIDTH, ENTRYHEIGHT, item, self.m_Scrollable)
		self.m_GUIItems[vrp] = item
		vrp.onLeftClick = bind(InventoryGUI.onItemClick, self, vrp, item)
	end
	
	-- Error Box
	self.m_ErrorBox = GUIRectangle:new(50, h/100*80, w/4, h/100*15, tocolor(173, 14, 22, 255), self)
	self.m_ErrorText = GUILabel:new(0, 0, w/4, h/100*15, "", 1.5, self.m_ErrorBox)
	self.m_ErrorText:setAlign("center", "center")
	self.m_ErrorBox:hide()
	
	-- Buttons
	local useText = _"Verwenden"
	local fwUse = fontWidth(useText, "default", 1.75)
	self.m_ButtonUse = GUIRectangle:new(w/3+w/3*2-50-fwUse*1.3, h-h/100*9, fwUse*1.3, h/100*6, tocolor(28, 101, 28), self)
	GUILabel:new(0, 0, fwUse*1.3, h/100*5, useText, 2, self.m_ButtonUse):setAlign("center", "center")	-- Buttons
	
	local sortText = _"Sortieren"
	local fwSort = fontWidth(sortText, "default", 1.75)
	self.m_ButtonSort = GUIRectangle:new(w/3+w/3*2-50-fwSort*1.3-fwUse*1.3-20, h-h/100*9, fwSort*1.3, h/100*6, tocolor(26, 85, 163), self)
	GUILabel:new(0, 0, fwSort*1.3, h/100*5, sortText, 2, self.m_ButtonSort):setAlign("center", "center")	
	
	local removeText = _"Wegwerfen"
	local fwRemove = fontWidth(removeText, "default", 1.75)
	self.m_ButtonDiscard = GUIRectangle:new(w/3+w/3*2-50-fwSort*1.3-fwUse*1.3-20-fwRemove*1.3-20, h-h/100*9, fwRemove*1.3, h/100*6, tocolor(143, 0, 0), self)
	GUILabel:new(0, 0, fwRemove*1.3, h/100*5, removeText, 2, self.m_ButtonSort):setAlign("center", "center")
	
	self.m_ButtonUse.onLeftClick = bind(function(self)
		if not self.m_SelectedItem then
			self.m_ErrorBox:show()
			self.m_ErrorText:setText(_"Fehler: \nKein Item ausgewählt!")
			return
		end
		
		local item = self.m_GUIItems[self.m_SelectedItem]
		assert(item)
		if item.use then
			item:use()
			self.m_SelectedItem:updateFromItem()
		else
			self.m_ErrorText:setText(_"Fehler: \nDieses Item ist nicht verwendbar!")
			self.m_ErrorBox:show()
		end
	end, self)
	
	-- ToDo: Send to server
	self.m_ButtonDiscard.onLeftClick = bind(function(self)
		if not self.m_SelectedItem then
			self.m_ErrorBox:show()
			self.m_ErrorText:setText(_"Fehler: \nKein Item ausgewählt!")
			return
		end
		
		local item = self.m_GUIItems[self.m_SelectedItem]
		assert(item)
		if item.m_Count > 1 then
			item.m_Count = item.m_Count -1
			self.m_SelectedItem:updateFromItem()
		else
			delete(item)
			self.m_SelectedItem:destroy(bind(
				function(self)
					self:resort()
				end, self))
			self.m_SelectedItem = false
		end
	end, self)
	
	
end

function InventoryGUI:onItemClick(vrpitem, item)
	if self.m_SelectedItem then
		self.m_SelectedItem:deselect()
	end
	
	self.m_SelectedItem = vrpitem
	self.m_SelectedItem:select()
end

function InventoryGUI:open()

end