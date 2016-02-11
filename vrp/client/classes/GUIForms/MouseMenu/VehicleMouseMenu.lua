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
		self:addItem(_("Besitzer: %s", getElementData(element, "OwnerName"))):setTextColor(Color.Red)
	end

	if element:getVehicleType() ~= "Bike" then
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

	self:addItem(_"Fahrzeug leeren",
		function()
			if self:getElement() then
				triggerServerEvent("vehicleEmpty", self:getElement())
			end
		end
	)

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
		if #self:getAttachedBoxes(element) > 0 then
			self:addItem(_"Kiste abladen",
				function()
					triggerServerEvent("weaponTruckDeloadBox", self:getElement(), element)
				end
			)
		end
		if #self:getAttachedBoxes(localPlayer) > 0 then
			self:addItem(_"Kiste aufladen",
				function()
					triggerServerEvent("weaponTruckLoadBox", self:getElement(), element)
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

function VehicleMouseMenu:getAttachedBoxes(element)
	local boxes = {}
	for key,value in pairs(element:getAttachedElements()) do
		if value.model == 2912 then
			table.insert(boxes, value)
		end
	end
	return boxes
end
