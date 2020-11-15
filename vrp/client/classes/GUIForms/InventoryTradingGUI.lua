-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InventoryTradingGUI.lua
-- *  PURPOSE:     InventoryTradingGUI - Class
-- *
-- **************************************************************************

InventoryTradingGUI = inherit(GUIForm)
inherit(Singleton, InventoryTradingGUI)

InventoryTradingGUI.TradePlaces = 12

function InventoryTradingGUI:constructor(tradingPartner)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
	self.m_Height = grid("y", 12)
	self.m_ElementId = localPlayer:getPublicSync("Id")
	self.m_TradingPartner = tradingPartner:getName()

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Handel", true, true, self)
	
	self.m_InventoryItemList = GUIGridItemSlotList:new(1, 1, 7, 11, self.m_Window)
	self.m_InventoryItemList.onItemRightClick = function(list, slot) self:onInventoryItemRightClick(slot) end
	self.m_InventoryItemList.onItemLeftClickDown = function() end
	self.m_InventorySync = bind(self.Event_syncInventory, self)
	InventoryManager:getSingleton():getHook():register(self.m_InventorySync)
	
	self.m_LocalItemList = GUIGridItemSlotList:new(9, 1, 7, 2.6, self.m_Window)
	self.m_LocalItemList:setSlots(InventoryTradingGUI.TradePlaces, "trading")
	self.m_LocalItemList.onItemRightClick = function(list, slot) self:onTradingItemRightClick(slot) end
	self.m_LocalItemList.onItemLeftClickDown = function() end
	self.m_LocalMoneyLabel = GUIGridLabel:new(9, 3.6, 2, 1, "Geld:", self.m_Window):setAlignX("center"):setHeader("sub")
	self.m_LocalMoneyEdit = GUIGridEdit:new(11, 3.6, 5, 1, self.m_Window):setNumeric(true, true)
	self.m_LocalMoneyEdit.onChange = function() self:onMoneyChange() end
	self.m_LocalMoneyEdit:setText("0")
	
	self.m_RemoteHeader = GUIGridLabel:new(9, 5, 7, 1, self.m_TradingPartner, self.m_Window):setAlignX("center"):setHeader()
	self.m_RemoteItemList = GUIGridItemSlotList:new(9, 6, 7, 2.6, self.m_Window)
	self.m_RemoteItemList.onItemLeftClickDown = function() end
	self.m_RemoteItemList:setSlots(InventoryTradingGUI.TradePlaces, "trading")
	self.m_RemoteMoneyLabel = GUIGridLabel:new(9, 8.6, 7, 1, "", self.m_Window):setAlignX("center"):setHeader("sub")
	
	self.m_AcceptButton = GUIGridButton:new(9, 10, 7, 1, "Bereit", self.m_Window):setBackgroundColor(Color.Green)
	self.m_AcceptButton.onLeftClick = function() self:onAccept() end
	self.m_AbortButton = GUIGridButton:new(9, 11, 7, 1, "Abbrechen", self.m_Window):setBackgroundColor(Color.Red)
	self.m_AbortButton.onLeftClick = function() delete(self) end

	triggerServerEvent("subscribeToInventory", localPlayer, DbElementType.Player, elementId)
end

function InventoryTradingGUI:destructor()
	GUIForm.destructor(self)
	triggerServerEvent("unsubscribeFromInventory", localPlayer, DbElementType.Player, self.m_ElementId)
	InventoryTradingManager:getSingleton():stopTrade()
end

function InventoryTradingGUI:Event_syncInventory(data, items)
	if data.ElementType ~= DbElementType.Player or data.ElementId ~= self.m_ElementId  then
		return
	end

	self.m_InventoryItemList:setSlots(data.Slots, data.Id)
	for i = 1, data.Slots, 1 do
		self.m_InventoryItemList:setItem(i, nil)
	end
	for k, v in pairs(items) do
		self.m_InventoryItemList:setItem(v.Slot, v)
	end

	for key, localSlot in pairs(self.m_LocalItemList:getSlots()) do
		if localSlot.m_ItemData ~= nil then
			local itemFound = false
			for k, inventorySlot in pairs(self.m_InventoryItemList:getSlots()) do
				if localSlot.m_ItemData.Id == inventorySlot.m_ItemData.Id then
					itemFound = true
					break
				end
			end
			if not itemFound then
				InventoryTradingManager:getSingleton():removeItemFromTrade(self.m_ElementId, localSlot.m_ItemData)
				localSlot:setItem(nil)
			end
		end
	end
end

function InventoryTradingGUI:onInventoryItemRightClick(slot)
	if slot:isEnabled() then
		local item = slot.m_ItemData
		local indexToMove
		for key, slot in pairs(self.m_LocalItemList:getSlots()) do
			if slot.m_ItemData == nil then
				indexToMove = key
				break
			end
		end

		if indexToMove then
			slot:setEnabled(false)
			self.m_LocalItemList:setItem(indexToMove, item)

			InventoryTradingManager:getSingleton():addItemToTrade(self.m_ElementId, item)
		end
	end
end

function InventoryTradingGUI:onTradingItemRightClick(slot)
	local item = slot.m_ItemData
	local index = slot.m_Slot

	if item ~= nil then
		slot:setItem(nil)
		for key, inventorySlot in pairs(self.m_InventoryItemList:getSlots()) do
			if inventorySlot.m_ItemData == item then
				inventorySlot:setEnabled(true)
			end
		end
		InventoryTradingManager:getSingleton():removeItemFromTrade(self.m_ElementId, item)
	end
end

function InventoryTradingGUI:onMoneyChange()
	local money = tonumber(self.m_LocalMoneyEdit:getText())
	if money then
		InventoryTradingManager:getSingleton():addMoneyToTrade(money)
	end
end

function InventoryTradingGUI:setRemoteData(tradingInfo)
	self.m_RemoteHeader:setText(self.m_TradingPartner)
	self.m_RemoteMoneyLabel:setText(toMoneyString(tradingInfo["money"]))

	for i = 1, InventoryTradingGUI.TradePlaces do
		self.m_RemoteItemList:setItem(i, nil)
	end

	local i = 1
	for key, item in pairs(tradingInfo) do
		self.m_RemoteItemList:setItem(i, item)
		i = i + 1
	end
end

function InventoryTradingGUI:onReady()
	InventoryTradingManager:getSingleton():setTradeReady()
end

function InventoryTradingGUI:onPartnerReady()
	self.m_RemoteHeader:setText(_("%s [Bereit]", self.m_TradingPartner))
end