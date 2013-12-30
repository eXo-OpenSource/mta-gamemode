InventoryGUI = inherit(GUIForm)

function InventoryGUI:constructor()
	local sw, sh = guiGetScreenSize()
	local w, h = sw/5*3, sh/5*3

	GUIForm.constructor(self, sw/5*1, sh/5*1, w, h)
	self.m_Background = GUIRectangle:new(0, 0, w, h, tocolor(2, 17, 39, 255), self)
	
	local items = { 
		{ id = 5; stack = math.random(1, 255) };
		{ id = 6; stack = math.random(1, 255) };
		{ id = 7; stack = math.random(1, 255) };
		{ id = 7; stack = math.random(1, 255) };
		{ id = 7; stack = math.random(1, 255) };
		{ id = 7; stack = math.random(1, 255) };
	}
	-- todo: make dependand on h instead
	local ENTRYHEIGHT = sh/100*7
	local ENTRYWIDTH = w/3*2-50
	local ENTRYSPACE = sh/100
	
	-- Scrollable Area is bugged
	self.m_Scrollable = GUIScrollableArea:new(w/3, 50, ENTRYWIDTH, sh, ENTRYWIDTH, sh, false, false, self)
	--self.m_Scrollable = GUIElement:new(w/3, 50, ENTRYWIDTH, sh, self)
	for i, item in ipairs(items) do
		local entry = GUIRectangle:new(0, (ENTRYHEIGHT+ENTRYSPACE)*(i-1), ENTRYWIDTH, ENTRYHEIGHT, tocolor(12, 26, 47, 255), self.m_Scrollable)
		-- Icon here
		entry.icon = GUIRectangle:new(5, 5, ENTRYHEIGHT-15, ENTRYHEIGHT-15, tocolor(255, 255, 0), entry)
		entry.name = GUILabel:new(ENTRYHEIGHT, 5, ENTRYWIDTH, ENTRYHEIGHT, "Gelbes Dreieck", 2.5, entry)
		entry.description = GUILabel:new(ENTRYHEIGHT+15, ENTRYHEIGHT-20, ENTRYWIDTH, ENTRYHEIGHT, "Ein pflegeleichtes gelbes Dreieck", 1, entry)
		entry.count = GUILabel:new(ENTRYWIDTH-fontWidth(tostring(item.stack), "default", 3)-10, 0, fontWidth(tostring(item.stack), "default", 3)+10, ENTRYHEIGHT, tostring(item.stack), 3, entry):setAlignY("center")
	end
	
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
	self.m_ButtonSort = GUIRectangle:new(w/3+w/3*2-50-fwSort*1.3-fwUse*1.3-20-fwRemove*1.3-20, h-h/100*9, fwRemove*1.3, h/100*6, tocolor(143, 0, 0), self)
	GUILabel:new(0, 0, fwRemove*1.3, h/100*5, removeText, 2, self.m_ButtonSort):setAlign("center", "center")
end

function InventoryGUI:open()

end