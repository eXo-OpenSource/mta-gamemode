-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu/VehicleMouseMenuAdmin.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
VehicleMouseMenuAdmin = inherit(GUIMouseMenu)

function VehicleMouseMenuAdmin:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	local owner = getElementData(element, "OwnerName")
	if owner then
		self:addItem(_("Besitzer: %s (Admin)", owner)):setTextColor(Color.Red)
	end

	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenu:new(posX, posY, element), element)
			end
		end
	)
	if getElementData(element, "OwnerType") ~= "faction" and getElementData(element, "OwnerType") ~= "company" then
		self:addItem(_"Respawnen / Parken >>>",
			function()
				if self:getElement() then
					delete(self)
					ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenuRespawn:new(posX, posY, element), element)
				end
			end
		)
	else
		if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["respawnVehicle"] then
			self:addItem(_"Respawnen",
				function()
					if self:getElement() then
						triggerServerEvent("vehicleRespawn", self:getElement())
					end
				end
			)
		end
		if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["parkVehicle"] then
			self:addItem(_"Parken",
				function()
					if self:getElement() then
						triggerServerEvent("vehiclePark", self:getElement())
					end
				end
			)
		end
	end

	--[[if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["editVehicleHandling"] then
		self:addItem(_"Handling",
			function()
				if self:getElement() then
					if VehiclePerformanceGUI.Map[self:getElement()]  then
						VehiclePerformanceGUI.Map[self:getElement()]:delete()
					end
					VehiclePerformanceGUI.Map[self:getElement()] = VehiclePerformanceGUI:new(self:getElement(), true)
				end
			end
		)
	end]]

	if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["repairVehicle"] then
		self:addItem(_"Reparieren",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleRepair", self:getElement())
				end
			end
		)
	end

	if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["despawnVehicle"] then
		self:addItem(_"Despawnen",
			function()
				if not self:getElement() then return end
				InputBox:new(_"Fahrzeug despawnen", _"Aus welchem Grund möchtest du das Fahrzeug despawnen?",
					function(reason)
						if self:getElement() then
							triggerServerEvent("adminVehicleDespawn", self:getElement(), reason)
						end
					end
				)
			end
		)
	end

	if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["looseVehicleHandbrake"] then
		self:addItem(_"Handbremse lösen",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleToggleHandbrake", self:getElement())
				end
			end
		)
	end

	if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["editVehicleGeneral"] then
		self:addItem(_"Editieren",
			function()
				if not self:getElement() then return end
				AdminVehicleEditGUI:new(self:getElement())
			end
		)
	end

	if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["deleteVehicle"] then
		self:addItem(_"Löschen",
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

	self:adjustWidth()
end
