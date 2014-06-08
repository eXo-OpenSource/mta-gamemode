-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VendingMouseMenu.lua
-- *  PURPOSE:     Vending machine mouse menu class
-- *
-- ****************************************************************************
VendingMouseMenu = inherit(GUIMouseMenu)

function VendingMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	
	self:addItem(_"Snack kaufen",
		function()
			if self:getElement() then
				outputChatBox("Nicht implementiert!")
			end
		end
	)
	self:addItem(_"Ausrauben",
		function()
			if self:getElement() then
				triggerServerEvent("vendingRob", self:getElement())
			end
		end
	)
end
