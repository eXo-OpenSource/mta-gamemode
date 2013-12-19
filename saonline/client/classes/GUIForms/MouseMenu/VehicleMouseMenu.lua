-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu.lua
-- *  PURPOSE:     Vehicle mouse menu class
-- *
-- ****************************************************************************
VehicleMouseMenu = inherit(GUIMouseMenu)

function VehicleMouseMenu:constructor(posX, posY)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	
	self:addItem("Owner: Jusonex"):setTextColor(Color.Red)
	self:addItem("Lock/Unlock",
		function()
			if self:getElement() then
				triggerServerEvent("vehicleLock", self:getElement())
			end
		end
	)
	self:addItem("Keys",
		function()
			if self:getElement() then
				VehicleKeyGUI:new(self:getElement())
			end
		end
	)
end
