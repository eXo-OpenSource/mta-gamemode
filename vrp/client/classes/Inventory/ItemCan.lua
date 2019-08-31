
addEvent("itemCanEnable", true)
addEventHandler("itemCanEnable", root,
	function(itemId)
		ItemCanGUI:new(itemId)
	end
)

addEvent("itemCanDisable", true)
addEventHandler("itemCanDisable", root,
	function()
		delete(ItemCanGUI:getSingleton())
	end
)

addEvent("itemCanRefresh", true)
addEventHandler("itemCanRefresh", root,
	function(state)
		-- ItemCanGUI:getSingleton():refresh(state)
	end
)

ItemCanGUI = inherit(GUIForm)
inherit(Singleton, ItemCanGUI)

function ItemCanGUI:constructor(itemId)
	self.m_ItemId = itemId

	GUIForm.constructor(self, screenWidth/2-200/2, 20, 200, 80, false)
	GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 125), self)
	GUILabel:new(0,0,self.m_Width, 30, _"Gießkannen-Füllstand:", self)
	self.m_Progress = GUIProgressBar:new(0,30,self.m_Width, 30,self)
	self.m_CanLabel = GUILabel:new(0, 30, self.m_Width, 30, "?/10", self):setAlignX("center"):setAlignY("center"):setColor(Color.Black)
	self.m_HelpLabel = GUILabel:new(0, 60, self.m_Width, 20, _"Im Wasser auffüllen! Taste X", self)
	self.m_Progress:setForegroundColor(tocolor(50,200,255))
	self.m_Progress:setBackgroundColor(tocolor(180,240,255))
	self.m_UpdateEvent = bind(self.refresh, self)

	InventoryManager:getSingleton():getPlayerHook():register(self.m_UpdateEvent)

	local inventory = InventoryManager:getSingleton():getPlayerInventory()
	self:refresh(inventory.inventoryId, inventory.elementId, inventory.elementType, inventory.size, inventory.items)
end

function ItemCanGUI:destructor()
	InventoryManager:getSingleton():getPlayerHook():unregister(self.m_UpdateEvent)
end

function ItemCanGUI:refresh(inventoryId, elementId, elementType, size, items)
	local durability = 0
	for k, v in pairs(items) do
		if v.Id == self.m_ItemId then
			durability = v.Durability
			break
		end
	end

	self.m_CanLabel:setText(durability.."/10")
	self.m_Progress:setProgress(durability*10)
	if tonumber(durability) < 1 then
		self.m_HelpLabel:setText(_"Im Wasser auffüllen! Taste X")
	else
		self.m_HelpLabel:setText(_"Benutze die Kanne mit Taste X")
	end
end
