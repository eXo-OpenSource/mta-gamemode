-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/Inventory.lua
-- *  PURPOSE:     Inventory class
-- *
-- ****************************************************************************

InventoryNew = inherit(GUIForm)
inherit(Singleton, InventoryNew)
InventoryNew.Color = {
	TabHover  = rgb(77, 103, 110);
	TabNormal = rgb(38, 158, 200);
	ItemsBackground = rgb(50, 200, 255);
	ItemBackground  = rgb(97, 129, 140);
}

function InventoryNew:constructor()
	GUIForm.constructor(self, screenWidth/2 - 330/2, screenHeight/2 - (106+100)/2, 330, (50+106))
	self.m_Tabs = {}
	self.m_CurrentTab = 1

	-- Upper Area (Tabs)
	local tabArea = GUIElement:new(0, 0, self.m_Width, self.m_Height*(50/self.m_Height), self)
	local tabX, tabY = tabArea:getSize()
	GUIRectangle:new(0, 0, tabX, tabY, InventoryNew.Color.TabHover, tabArea)

	-- Tabs
	local tabItems = self:addTab("files/images/Inventory/items.png", tabArea)
	self:addItemSlots(13, tabItems)
	local tabObjects = self:addTab("files/images/Inventory/items/Objekte.png", tabArea)
	self:addItemSlots(3, tabObjects)
	local tabFood = self:addTab("files/images/Inventory/food.png", tabArea)
	self:addItemSlots(5, tabFood)
	local tabDrugs = self:addTab("files/images/Inventory/drogen.png", tabArea)
	self:addItemSlots(7, tabDrugs)

	--[[
	-- Lower Area (Items)
	local itemArea = GUIElement:new(0, self.m_Height*(50/self.m_Height), self.m_Width, self.m_Height - self.m_Height*(50/self.m_Height), self)
	local itemX, itemY = itemArea:getSize()
	self.m_ItemArea = itemArea
	GUIRectangle:new(0, 0, itemX, itemY, Color.LightBlue, itemArea)
	GUIEmptyRectangle:new(0, 0, itemX, itemY, 2, Color.White, itemArea)
	--]]
end

function InventoryNew:addTab(img, parent)
	local Id = #self.m_Tabs + 1
	local tabX, tabY = parent:getSize()
	local tabButton = GUIElement:new(0 + math.floor(self.m_Width/4)*(Id-1), 0, math.floor(self.m_Width/4), tabY, parent)
	local tabBackground = GUIRectangle:new(0, 0, tabButton.m_Width, tabButton.m_Height, InventoryNew.Color.TabNormal, tabButton)
	GUIImage:new(tabButton.m_Width*0.225, tabButton.m_Height*0.025, tabButton.m_Width*0.55, tabButton.m_Height*0.95, img, tabButton)
	GUIEmptyRectangle:new(0, 0, tabButton.m_Width+2, tabButton.m_Height+2, 2, Color.White, tabButton)

	tabButton.isTab = true
	tabButton.m_Background = tabBackground
	tabButton.onHover = function ()
		if self.m_CurrentTab ~= Id then
			tabBackground:setColor(InventoryNew.Color.TabHover)
		end
	end
	tabButton.onUnhover = function ()
		if self.m_CurrentTab ~= Id then
			tabBackground:setColor(InventoryNew.Color.TabNormal)
		end
	end
	tabButton.onLeftClick = function()
		self:setTab(Id)

		for k, v in ipairs(parent.m_Children) do
			if v.isTab == true then
				v.m_Background:setColor(InventoryNew.Color.TabNormal)
			end
		end

		tabButton.m_Background:setColor(InventoryNew.Color.TabHover)
	end

	local itemArea = GUIElement:new(0, self.m_Height*(50/self.m_Height), self.m_Width, self.m_Height - self.m_Height*(50/self.m_Height), self)
	local itemX, itemY = itemArea:getSize()
	itemArea.m_Background = GUIRectangle:new(0, 0, itemX, itemY, InventoryNew.Color.ItemsBackground, itemArea)
	itemArea.m_BackgroundRound = GUIEmptyRectangle:new(0, 0, itemX, itemY, 2, Color.White, itemArea)

	if Id ~= 1 then
		itemArea:setVisible(false)
	else
		self.m_CurrentTab = 1
		tabBackground:setColor(InventoryNew.Color.TabHover)
	end

	self.m_Tabs[Id] = itemArea
	return itemArea
end

function InventoryNew:setTab(Id)
	if self.m_CurrentTab then
		self.m_Tabs[self.m_CurrentTab]:setVisible(false)
	end

	self.m_Tabs[Id]:setVisible(true)
	self.m_CurrentTab = Id
	if self.onTabChanged then
		self.onTabChanged(Id)
	end
end

function InventoryNew:addItemSlots(count, parent)
	parent.m_ItemSlots = {}
	local x, y = parent:getSize()
	local row = 0
	for i = 1, count, 1 do
		local i = i - 7*row                                                  -- y
		parent.m_ItemSlots[#parent.m_ItemSlots+1] = GUIRectangle:new(x*0.025 + math.floor(x*0.125)*(i-1) + (x*0.014)*(i-1), x*0.03 + math.floor(x*0.125)*(row) + (x*0.014)*(row), x*0.125, x*0.125, InventoryNew.Color.ItemBackground, parent)

		if i == count then break; end
		if i%7 == 0 then row = row + 1 end
	end

	-- Calculate new parent size
	parent:setSize(x, y + (y*0.455)*(row-1))
	parent.m_Background:setSize(x, y + (y*0.455)*(row-1))
	parent.m_BackgroundRound:setSize(x, y + (y*0.455)*(row-1))
end

function InventoryNew:addItemToSlot(tabId, item)
	if not self.m_Tabs[tabId] then return false end
	local tab = self.m_Tabs[tabId]
	if not tab.m_ItemSlots then return false end
	local slot = tab.m_ItemSlots
end

function InventoryNew:onShow()

end

function InventoryNew:onHide()

end
