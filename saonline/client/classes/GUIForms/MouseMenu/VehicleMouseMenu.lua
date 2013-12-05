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
	
	self:addItem("Lock/Unlock",
		function()
			if self:getElement() then
				localPlayer:sendMessage(_("Locking your %s"):format(getVehicleName(self:getElement())), 255, 0, 0)
				triggerServerEvent("vehicleLock", root, self:getElement())
			end
		end
	)
	self:addItem("Keys",
		function()
			VehicleKeyGUI:new()
		end
	)
end
