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
	self:addItem(_"Respawn",
		function()
			if self:getElement() then
				triggerServerEvent("vehicleRespawn", self:getElement())
			end
		end
	)
	if getElementData(element, "OwnerName") == localPlayer.name then
		self:addItem(_"Schlüssel",
			function()
				if self:getElement() then
					VehicleKeyGUI:new(self:getElement())
				end
			end
		)
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
	
	if owner == localPlayer.name then
		self:addItem(_"Verkaufen",
			function()
				if self:getElement() then
					outputChatBox("[I]Begebe dich zur Stadthalle und besorge dir einen Vertrag zum Verkaufen!",200,200,0,true)
				end
			end
		)
	end
	if localPlayer:isInVehicle() then
		self:addItem(_"Kurzschließen",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleHotwire", self:getElement())
				end
			end
		)
	end

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


	if localPlayer:getPublicSync("CompanyId") == 2 then
		self:addItem(_"Mechaniker: Reparieren",
			function()
				if self:getElement() then
					triggerServerEvent("mechanicRepair", self:getElement())
				end
			end
		)
	end

	if localPlayer:getFactionId() == 4 and localPlayer:getPublicSync("Rescue:Type") == "medic" then
		if element:getModel() == 416 then
			self:addItem(_"Medic: Krankentrage ausladen",
				function()
					if self:getElement() then
						outputDebug("TRUE")
						triggerServerEvent("factionRescueGetStretcher", self:getElement())
					end
				end
			)
			self:addItem(_"Medic: Krankentrage einladen",
				function()
					if self:getElement() then
						triggerServerEvent("factionRescueRemoveStretcher", self:getElement())
					end
				end
			)
		elseif element:getModel() == 599 then
			self:addItem(_"Medic: Defibrillator ausladen",
				function()
					if self:getElement() then
						triggerServerEvent("factionRescueGetStretcher", self:getElement())
					end
				end
			)
		end
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
				if not self:getElement() then return end
				QuestionBox:new(_"Möchtest du dieses Auto wirklich löschen?",
					function()
						if self:getElement() then
							triggerServerEvent("vehicleDelete", self:getElement())
						end
					end
				)
			end
		)
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
