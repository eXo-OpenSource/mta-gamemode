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
	
	self:addItem("Lock/Unlock", function() localPlayer:sendMessage("No content yet", 255, 0, 0) end)
	self:addItem("Keys", function() localPlayer:sendMessage("No content yet", 255, 0, 0) end)
end
