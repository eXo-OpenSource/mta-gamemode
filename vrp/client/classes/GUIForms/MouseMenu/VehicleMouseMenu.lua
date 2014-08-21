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
	
	if getElementData(element, "OwnerName") then
		self:addItem("Besitzer: "..getElementData(element, "OwnerName")):setTextColor(Color.Red)
	end
	
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
	
	if localPlayer:getJob() == JobMechanic:getSingleton() then
		self:addItem(_"Reparieren",
			function()
				if self:getElement() then
					triggerServerEvent("mechanicRepair", self:getElement())
				end
			end
		)
	end
	
	if localPlayer:getRank() >= RANK.Moderator then
		self:addItem(_"Admin: Reparieren",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleRepair", self:getElement())
				end
			end
		)
		self:addItem(_"Admin: Löschen",
			function()
				if self:getElement() then
					QuestionBox:new(_"Möchtest du dieses Auto wirklich löschen?",
						function()
							triggerServerEvent("vehicleDelete", self:getElement())
						end
					)
				end
			end
		)
	end
end
