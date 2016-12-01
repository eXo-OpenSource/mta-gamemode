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
	local owner = getElementData(element, "OwnerName")
	if owner then
		self:addItem(_("Besitzer: %s", owner)):setTextColor(Color.Red)
	end

	if element:getVehicleType() ~= VehicleType.Bike and element:getVehicleType() ~= VehicleType.Trailer then
		self:addItem(_"Auf-/Zuschließen",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleLock", self:getElement())
				end
			end
		)
	end
	if getElementData(element, "OwnerName") == localPlayer.name or localPlayer:getRank() >= RANK.Ticketsupporter then
		if getElementData(element, "OwnerType") ~= "faction" and getElementData(element, "OwnerType") ~= "company" and getElementData(element, "OwnerType") ~= "group" then
			self:addItem(_"Respawn in Garage",
				function()
					if self:getElement() then
						triggerServerEvent("vehicleRespawn", self:getElement(), true)
					end
				end
			)
			self:addItem(_"Respawn an Parkposition",
				function()
					if self:getElement() then
						triggerServerEvent("vehicleRespawnWorld", self:getElement())
					end
				end
			)

			self:addItem(_"hier Parken",
				function()
					if self:getElement() then
						triggerServerEvent("vehiclePark", self:getElement())
					end
				end
			)
		else
			self:addItem(_"Respawn",
				function()
					if self:getElement() then
						triggerServerEvent("vehicleRespawn", self:getElement())
					end
				end
			)
		end
	end
	if getElementData(element, "OwnerName") == localPlayer.name then
		self:addItem(_"Schlüssel",
			function()
				if self:getElement() then
					VehicleKeyGUI:new(self:getElement())
				end
			end
		)

		if getElementData(element, "Special") == VehicleSpecial.Soundvan then
			self:addItem(_"Musik abspielen",
				function()
					if self:getElement() then
						StreamGUI:new("Soundvan Musik ändern", function(url) triggerServerEvent("soundvanChangeURL", self:getElement(), url) end, function() triggerServerEvent("soundvanStopSound", self:getElement()) end)
					end
				end
			)
		end
		self:addItem(_"Verkaufen",
			function()
				if self:getElement() then
					outputChatBox("[I]Begebe dich zur Stadthalle und besorge dir einen Vertrag zum Verkaufen!",200,200,0,true)
				end
			end
		)
	end

	if element:getModel() == 427 or element:getModel() == 598 or element:getModel() == 596 then
		if localPlayer:getFaction() and localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") == true then
			self:addItem(_"Blitzer nehmen",
					function()
						if self:getElement() then
							triggerServerEvent("factionStateTakeSpeedCam", localPlayer)
						end
					end
				)
		end
	end
	
	
	if element:getModel() == 427 or element:getModel() == 598 or element:getModel() == 596 then
		if localPlayer:getFaction() and localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") == true then
			self:addItem(_"Blitzer reinlegen",
					function()
						if self:getElement() then
							triggerServerEvent("factionStatePutSpeedCam", localPlayer)
						end
					end
				)
		end
	end

	if element:getVehicleType() ~= VehicleType.Trailer then
		self:addItem(_"Fahrzeug leeren",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleEmpty", self:getElement())
				end
			end
		)
	end
	--[[if localPlayer:isInVehicle() then
		self:addItem(_"Kurzschließen",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleHotwire", self:getElement())
				end
			end
		)
	end
	]]
	if getElementData(element,"WeaponTruck") or VEHICLE_BOX_LOAD[element.model] then
		if #self:getAttachedElement(2912, element) > 0 then
			self:addItem(_"Kiste abladen",
				function()
					triggerServerEvent("weaponTruckDeloadBox", self:getElement(), element)
				end
			)
		end
		if #self:getAttachedElement(2912, localPlayer) > 0 then
			self:addItem(_"Kiste aufladen",
				function()
					triggerServerEvent("weaponTruckLoadBox", self:getElement(), element)
				end
			)
		end
	end

	if VEHICLE_BAG_LOAD[element.model] then
		if #self:getAttachedElement(1550, element) > 0 then
			self:addItem(_"Geldsack abladen",
				function()
					triggerServerEvent("bankRobberyDeloadBag", self:getElement(), element)
				end
			)
		end
		if #self:getAttachedElement(1550, localPlayer) > 0 then
			self:addItem(_"Geldsack aufladen",
				function()
					triggerServerEvent("bankRobberyLoadBag", self:getElement(), element)
				end
			)
		end
	end


	if localPlayer:getPublicSync("CompanyId") == 2 and localPlayer:getPublicSync("Company:Duty") == true then
		self:addItem(_"Mechaniker: Reparieren",
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
		self:addItem(_"Admin: despawnen",
			function()
				if not self:getElement() then return end
				triggerServerEvent("adminVehicleDespawn", self:getElement())
			end
		)
		self:addItem(_"Admin: Löschen",
			function()
				if not self:getElement() then return end
				InputBox:new(_"Fahrzeug löschen", _"Aus welchem Grund möchtest du das Fahrzeug löschen?",
					function(reason)
						if self:getElement() then
							triggerServerEvent("vehicleDelete", self:getElement(), reason)
						end
					end
				)
			end
		)
	end
	if VehicleSellGUI then
		if VehicleSellGUI:isInstantiated() then
			delete( self )
		end
	end
end

function VehicleMouseMenu:getAttachedElement(model, element)
	local boxes = {}
	for key,value in pairs(element:getAttachedElements()) do
		if value.model == model then
			table.insert(boxes, value)
		end
	end
	return boxes
end
