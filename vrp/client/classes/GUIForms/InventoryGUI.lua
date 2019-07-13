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
	self.m_Width = grid("x", 8)
	self.m_Height = grid("y", 10)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Inventar", true, true, self)

	self.m_InventoryList = GUIGridGridList:new(1, 1, 7, 9, self.m_Window)
	self.m_InventoryList:addColumn(_"Name", 0.5)
	self.m_InventoryList:addColumn(_"Anzahl", 0.25)
	self.m_InventoryList:addColumn(_"IID", 0.25)

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
	self.m_InventoryList:clear()
	for k, v in pairs(data) do
		local item = self.m_InventoryList:addItem(v.Name, v.Amount, v.Id)
		item.m_Item = v
		item.onLeftClick = function()
			triggerServerEvent("onItemUse", localPlayer, inventoryId, v.Id)
		end

		item.onRightClick = function()
			for k, i in ipairs(self.m_InventoryList:getItems()) do
				if i == item then
					self.m_InventoryList:setSelectedItem(k)
					break
				end
			end
			triggerServerEvent("onItemUseSecondary", localPlayer, inventoryId, v.Id)
		end
	end
end

function InventoryGUI:destructor()
	GUIForm.destructor(self)
end
