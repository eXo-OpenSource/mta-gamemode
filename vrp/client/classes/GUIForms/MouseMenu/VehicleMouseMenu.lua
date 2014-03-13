-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu.lua
-- *  PURPOSE:     Vehicle mouse menu class
-- *
-- ****************************************************************************
VehicleMouseMenu = inherit(GUIMouseMenu)

function VehicleMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	
	self:addItem("Besitzer: "..getElementData(element, "OwnerName")):setTextColor(Color.Red)
	
	self:addItem(_"Auf-/Zuschließen",
		function()
			if self:getElement() then
				triggerServerEvent("vehicleLock", self:getElement())
			end
		end
	)
	self:addItem(_"Respawn",
		function()
			if self:getElement() then
				triggerServerEvent("vehicleRespawn", self:getElement())
			end
		end
	)
	self:addItem(_"Schlüssel",
		function()
			if self:getElement() then
				VehicleKeyGUI:new(self:getElement())
			end
		end
	)
	
	if localPlayer:getRank() >= RANK.Moderator then
		self:addItem(_"Reparieren",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleRepair", self:getElement())
				end
			end
		)
		self:addItem(_"Löschen",
			function()
				outputChatBox("Not implemented yet")
			end
		)
	end
end
