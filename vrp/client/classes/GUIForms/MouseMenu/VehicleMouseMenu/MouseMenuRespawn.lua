-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu/VehicleMouseMenuRespawn.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
VehicleMouseMenuRespawn = inherit(GUIMouseMenu)

function VehicleMouseMenuRespawn:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	local owner = getElementData(element, "OwnerName")
	if owner then
		self:addItem(_("Besitzer: %s", owner)):setTextColor(Color.Red)
	end

	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenu:new(posX, posY, element), element)
			end
		end
	)
	if getElementData(element, "OwnerType") == "group" then
		self:addItem(_"Respawn",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleRespawn", self:getElement(), true)
				end
			end
		)
	else
		self:addItem(_"Respawn @ Garage",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleRespawn", self:getElement(), true)
				end
			end
		)
		self:addItem(_"Respawn @ Parkposition",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleRespawnWorld", self:getElement())
				end
			end
	)
	end

	self:addItem(_"Fahrzeug parken",
		function()
			if self:getElement() then
				if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["parkVehicle"] or not localPlayer.m_DisallowParking then 
					triggerServerEvent("vehiclePark", self:getElement())
				else 
					ErrorBox:new(_("Du kannst dein Auto hier nicht parken!"))
				end
			end
		end
	)

	self:adjustWidth()
end
