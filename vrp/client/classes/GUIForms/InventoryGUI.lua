-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InventoryGUI.lua
-- *  PURPOSE:     InventoryGUI - Class
-- *
-- **************************************************************************

InventoryGUI = inherit(GUIForm)
inherit(Singleton, InventoryGUI)

addRemoteEvents{"syncInventory"}

function InventoryGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 15)
	self.m_Height = grid("y", 10)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Inventar", true, false, self) -- temporarly disable close button as it breaks the closing of the gui

	self.m_ItemList = GUIGridItemSlotList:new(1, 1, 14, 9, self.m_Window)
	self:hide()

	addEventHandler("syncInventory", root, bind(self.Event_syncInventory, self))

	bindKey("k", "up", function()
		InventoryGUI:getSingleton():toggle()
	end)
end

function InventoryGUI:onShow()
	triggerServerEvent("syncInventory", localPlayer)
end

function InventoryGUI:Event_syncInventory(data, inventoryId)
	for k, v in pairs(data) do
		self.m_ItemList:setItem(v.Slot, inventoryId, v)
	end
end

function InventoryGUI:destructor()
	GUIForm.destructor(self)
end
