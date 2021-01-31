-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InventoryGUI.lua
-- *  PURPOSE:     InventoryGUI - Class
-- *
-- **************************************************************************

InventoryGUI = inherit(GUIForm)
InventoryGUI.Map = {}
InventoryGUI.Sizes = {
	big = {width = 15, height = 10},
	medium = {width = 12, height = 8},
	small = {width = 10, height = 7},
	tiny = {width = 8, height = 6}
}
-- inherit(Singleton, InventoryGUI)

addRemoteEvents{"syncInventory"}

function InventoryGUI.create(title, elementType, elementId, size)
	if not InventoryGUI.Map[elementType] then
		InventoryGUI.Map[elementType] = {}
	end

	if not InventoryGUI.Map[elementType][elementId] or DEBUG then
		InventoryGUI.Map[elementType][elementId] = InventoryGUI:new(title, elementType, elementId, size)

		return InventoryGUI.Map[elementType][elementId]
	end

	return false
end

function InventoryGUI:constructor(title, elementType, elementId, size)
	if not InventoryGUI.Sizes[size] then
		size = "big"
	end
	local width = InventoryGUI.Sizes[size].width
	local height = InventoryGUI.Sizes[size].height

	GUIWindow.updateGrid()
	self.m_Width = grid("x", width)
	self.m_Height = grid("y", height)
	self.m_ElementType = elementType
	self.m_ElementId = elementId

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)

	self.m_ItemList = GUIGridItemSlotList:new(1, 1, width-1, height-1, self.m_Window)
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
	InventoryGUI.Map[self.m_ElementType][self.m_ElementId] = nil
	triggerServerEvent("unsubscribeFromInventory", localPlayer, self.m_ElementType, self.m_ElementId)
	GUIForm.destructor(self)
end
