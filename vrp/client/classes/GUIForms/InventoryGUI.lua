-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InventoryGUI.lua
-- *  PURPOSE:     InventoryGUI - Class
-- *
-- **************************************************************************

InventoryGUI = inherit(GUIForm)
-- inherit(Singleton, InventoryGUI)

addRemoteEvents{"syncInventory"}

function InventoryGUI:constructor(title, elementType, elementId)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 15)
	self.m_Height = grid("y", 10)
	self.m_ElementType = elementType
	self.m_ElementId = elementId

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, false, self) -- temporarly disable close button as it breaks the closing of the gui

	self.m_ItemList = GUIGridItemSlotList:new(1, 1, 14, 9, self.m_Window)
	self.m_InventorySync = bind(self.Event_syncInventory, self)
	InventoryManager:getSingleton():getHook():register(self.m_InventorySync)

	triggerServerEvent("subscribeToInventory", localPlayer, elementType, elementId)
end

function InventoryGUI:Event_syncInventory(data, items)
	if data.ElementType ~= self.m_ElementType or data.ElementId ~= self.m_ElementId  then
		return
	end

	self.m_ItemList:setSlots(data.Slots, data.Id)
	for i = 1, data.Slots, 1 do
		self.m_ItemList:setItem(i, nil)
	end
	for k, v in pairs(items) do
		self.m_ItemList:setItem(v.Slot, v)
	end
end

function InventoryGUI:destructor()
	triggerServerEvent("unsubscribeFromInventory", localPlayer, elementType, elementId)
	GUIForm.destructor(self)
end
