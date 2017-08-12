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
		self:addItem(_("Besitzer: %s", owner, element:getName())):setTextColor(Color.Red)
	end
	self:addItem(_("Fahrzeug: %s", element:getName())):setTextColor(Color.LightBlue)
	if not element:isBlown() then
		if element:getVehicleType() ~= VehicleType.Bike and element:getVehicleType() ~= VehicleType.Trailer then
			self:addItem(_("%sschließen", element:isLocked() and "Auf" or "Zu"),
				function()
					if self:getElement() then
						triggerServerEvent("vehicleLock", self:getElement())
					end
				end
			):setIcon(element:isLocked() and FontAwesomeSymbols.Lock or FontAwesomeSymbols.Unlock)
		end
		if getElementData(element, "OwnerName") == localPlayer.name or localPlayer:getGroupName() == getElementData(element, "OwnerName") then
			if localPlayer:getGroupName() == getElementData(element, "OwnerName") and (getElementData(element, "GroupType") and getElementData(element, "GroupType") == "Firma") then
				if getElementData(element, "forSale") == true then
					self:addItem(_"Firma: Verkauf beenden",
						function()
							if self:getElement() then
								delete(self)
								QuestionBox:new("Möchtest du den Verkauf des Fahrzeuges beenden?",
								function ()
									triggerServerEvent("groupStopVehicleForSale", self:getElement())
								end)
							end
						end
					):setIcon(FontAwesomeSymbols.Cart_Down)
				else
					self:addItem(_"Firma: zum Verkauf anbieten",
						function()
							if self:getElement() then
								delete(self)
								InputBox:new("Fahrzeug zum Verkauf anbieten", "Für welchen Betrag möchtest du das Fahrzeug anbieten?",
								function (amount)
									if amount and #amount > 0 and tonumber(amount) > 0 and tonumber(amount) <= 5000000 then
										triggerServerEvent("groupSetVehicleForSale", self:getElement(), tonumber(amount))
									else
										ErrorBox:new(_("Der Betrag muss zwischen 1$ und 5.000.000$ liegen!"))
									end
								end, true)
							end
						end
					):setIcon(FontAwesomeSymbols.Cart_Plus)
				end
			end
			if getElementData(element, "Special") == VehicleSpecial.Soundvan then
				self:addItem(_"Musik abspielen",
					function()
						if self:getElement() then
							StreamGUI:new("Soundvan Musik ändern", function(url) triggerServerEvent("soundvanChangeURL", self:getElement(), url) end, function() triggerServerEvent("soundvanStopSound", self:getElement()) end)
						end
					end
				):setIcon(FontAwesomeSymbols.Music)
			end
			if getElementData(element, "OwnerType") ~= "faction" and getElementData(element, "OwnerType") ~= "company" then
				self:addItem(_"Respawnen / Parken >>>",
					function()
						if self:getElement() then
							delete(self)
							ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenuRespawn:new(posX, posY, element), element)
						end
					end
				):setIcon(FontAwesomeSymbols.Home)
			else
				self:addItem(_"Respawn",
					function()
						if self:getElement() then
							triggerServerEvent("vehicleRespawn", self:getElement())
						end
					end
				):setIcon(FontAwesomeSymbols.Home)
			end
		end

		if element:getModel() == 544 and localPlayer:getFaction() and localPlayer:getFaction():isRescueFaction() and localPlayer:getPublicSync("Faction:Duty") == true then
			if localPlayer.vehicle == element and localPlayer.vehicleSeat == 0 then
				self:addItem(_"Leiter Modus wechseln",
					function()
						if self:getElement() then
							triggerServerEvent("factionRescueToggleLadder", self:getElement())
						end
					end
				):setIcon(FontAwesomeSymbols.Arrows)
			end
		end
		if element:getData("EPT_Taxi") and element:getModel() == 420 or element:getModel() == 438 then -- Taxis
			if localPlayer:getCompany() and localPlayer:getCompany():getId() == 4 and localPlayer:getPublicSync("Company:Duty") == true then
				if localPlayer.vehicle == element and localPlayer.vehicleSeat == 0 then
					self:addItem(_"Taxileuchte bedienen",
						function()
							if self:getElement() then
								delete(self)
								triggerServerEvent("publicTransportSwitchTaxiLight", self:getElement())
							end
						end
					):setIcon(FontAwesomeSymbols.Lightbulb)
				end
			end
		end
		if element:getData("EPT_Bus") then -- Coach
			if localPlayer:getCompany() and localPlayer:getCompany():getId() == 4 and localPlayer:getPublicSync("Company:Duty") == true then
				if localPlayer.vehicle == element and localPlayer.vehicleSeat == 0 then
					self:addItem(_"Busfahrer >>>",
						function()
							if self:getElement() then
								delete(self)
								ClickHandler:getSingleton():addMouseMenu(BusLineMouseMenu:new(posX, posY, element), element)
							end
						end
					):setIcon(FontAwesomeSymbols.Arrows)
				end
			end -- don't use elseif as it will prevent the bus driver from seeing the UI
			if element:getData("EPT_bus_duty") then
				self:addItem(_"Fahrplan anzeigen",
					function()
						if self:getElement() then
							delete(self)
							BusRouteInformationGUI:new(element)
						end
					end
				):setIcon(FontAwesomeSymbols.Document)
			end
		end
		if localPlayer:getFaction() and localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") == true then
			if getElementData(element, "StateVehicle") then
				self:addItem(_("Items >>>"),
					function()
						if self:getElement() then
							delete(self)
							ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenuFactionItems:new(posX, posY, element), element)
						end
					end
				):setIcon(FontAwesomeSymbols.List)
			end
			if localPlayer:getFaction():getId() == 2 then
				self:addItem(_"Wanze anbringen",
						function()
							if self:getElement() then
								triggerServerEvent("factionStateAttachBug", self:getElement())
							end
						end
					):setIcon(FontAwesomeSymbols.Bug)
				end
			if localPlayer.vehicleSeat == 0 and getElementData(element, "StateVehicle") then
				self:addItem(_("Radar %s", getElementData(element, "speedCamEnabled") and "stoppen" or "starten"),
					function()
						if self:getElement() then
							triggerServerEvent("SpeedCam:onStartClick", self:getElement())
						end
					end
				):setIcon(FontAwesomeSymbols.Speedo)
			end
		end
		if getElementData(element, "OwnerName") == localPlayer.name and getElementData(element, "OwnerType") == "player" then
			self:addItem(_"Schlüssel",
				function()
					if self:getElement() then
						VehicleKeyGUI:new(self:getElement())
					end
				end
			):setIcon(FontAwesomeSymbols.Key)

			if getVehicleInteractType(element) == "Special" then
				self:addItem(_"Repairkit: reparieren",
					function()
						if self:getElement() then
							triggerServerEvent("onMouseMenuRepairkit", self:getElement())
						end
					end
				):setIcon(FontAwesomeSymbols.Wrench)
			end
		end

		if element:getVehicleType() ~= VehicleType.Trailer then
			self:addItem(_"Fahrzeug leeren",
				function()
					if self:getElement() then
						triggerServerEvent("vehicleEmpty", self:getElement())
					end
				end
			):setIcon(FontAwesomeSymbols.SignOut)
		end
		--[[if localPlayer:isInVehicle() then
			self:addItem(_"Kurzschließen",
				function()
					if self:getElement() then
						triggerServerEvent("vehicleHotwire", self:getElement())
					end
				end
			):setIcon(FontAwesomeSymbols.Random)
		end
		]]
		if getElementData(element,"WeaponTruck") or VEHICLE_BOX_LOAD[element.model] then
			if #self:getAttachedElement(2912, element) > 0 then
				self:addItem(_"Kiste abladen",
					function()
						triggerServerEvent("weaponTruckDeloadBox", self:getElement(), element)
					end
				):setIcon(FontAwesomeSymbols.Double_Down)
			end
			if #self:getAttachedElement(2912, localPlayer) > 0 then
				self:addItem(_"Kiste aufladen",
					function()
						triggerServerEvent("weaponTruckLoadBox", self:getElement(), element)
					end
				):setIcon(FontAwesomeSymbols.Double_Up)
			end
		end

		if VEHICLE_BAG_LOAD[element.model] then
			if #self:getAttachedElement(1550, element) > 0 then
				self:addItem(_"Geldsack abladen",
					function()
						triggerServerEvent("bankRobberyDeloadBag", self:getElement(), element)
					end
				):setIcon(FontAwesomeSymbols.Double_Down)
			end
			if #self:getAttachedElement(1550, localPlayer) > 0 then
				self:addItem(_"Geldsack aufladen",
					function()
						triggerServerEvent("bankRobberyLoadBag", self:getElement(), element)
					end
				):setIcon(FontAwesomeSymbols.Double_Up)
			end
		end

		if localPlayer:getPublicSync("CompanyId") == 2 and localPlayer:getPublicSync("Company:Duty") == true then
			if element:getHealth() < 950 then
				self:addItem(_"Mechaniker: Reparieren",
					function()
						if self:getElement() then
							triggerServerEvent("mechanicRepair", self:getElement())
						end
					end
				):setIcon(FontAwesomeSymbols.Wrench)
			end
			if getElementData(element, "Handbrake") == true and element:getModel() ~= 611 then
				self:addItem(_"Mechaniker: Handbremse lösen",
					function()
						if self:getElement() then
							triggerServerEvent("vehicleToggleHandbrake", self:getElement())
							delete(self)
						end
					end
				):setIcon(FontAwesomeSymbols.Cogs)
			end
			--if element.towingVehicle and not element.towingVehicle.controller ~= localPlayer and element:getModel() == 611 then -- fuel tankN
				local fuelMode = localPlayer:getPrivateSync("hasFuelNozzle")
				self:addItem(_("Mechaniker: Zapfpistole %s", fuelMode and "einhängen" or "nehmen"),
					function()
						if self:getElement() then
							triggerServerEvent("mechanicTakeFuelNozzle", localPlayer, element)
						end
					end
				):setIcon(FontAwesomeSymbols.Cogs)
				self:addItem(_"Mechaniker: Entkoppeln",
					function()
						if self:getElement() then
							triggerServerEvent("mechanicDetachFuelTank", localPlayer, element.towingVehicle)
						end
					end
				):setIcon(FontAwesomeSymbols.Cogs)
			--end
		end
	end
	if localPlayer:getRank() >= RANK.Supporter then
		self:addItem(_"Admin >>>",
			function()
				if self:getElement() then
					delete(self)
					ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenuAdmin:new(posX, posY, element), element)
				end
			end
		):setIcon(FontAwesomeSymbols.Star)
	end
	if element.occupants and table.size(element.occupants) > 0 then
		self:addItem(_"Insassen >>>",
			function()
				if self:getElement() then
					delete(self)
					ClickHandler:getSingleton():addMouseMenu(PassengerMouseMenu:new(posX, posY, element), element)
				end
			end
		):setIcon(FontAwesomeSymbols.Group)
	end

	if element:getVehicleType() == VehicleType.Helicopter and element == localPlayer.vehicle and localPlayer.vehicleSeat ~= 0 then
		self:addItem(_"Abseilen",
			function()
				if self:getElement() then
					delete(self)
					exports.helicopterrope:abseilBind()
				end
			end
		):setIcon(FontAwesomeSymbols.Long_Down)
	end

	if getElementData(element, "OwnerType") == "group" and getElementData(element, "forSale") == true then
		self:addItem(_"Tunings anzeigen",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleGetTuningList", self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Search)
		self:addItem(_"Fahrzeug kaufen",
			function()
				if self:getElement() then
					delete(self)
					QuestionBox:new(
						_("Möchtest du das Fahrzeug für %d$ kaufen?", getElementData(element, "forSalePrice")),
						function() 	triggerServerEvent("groupBuyVehicle", self:getElement()) end
					)
				end
			end
		):setIcon(FontAwesomeSymbols.Cart)
	end

	if VEHICLE_MODEL_SPAWNS[element:getModel()] and getElementData(element, "OwnerName") == localPlayer.name then
		self:addItem(_"Als Spawnpunkt festlegen",
			function()
				if self:getElement() then
					triggerServerEvent("onPlayerUpdateSpawnLocation", self:getElement(), SPAWN_LOCATIONS.VEHICLE)
				end
			end
		):setIcon(FontAwesomeSymbols.Waypoint)
	end

	if VehicleSellGUI then
		if VehicleSellGUI:isInstantiated() then
			delete(self)
		end
	end

	self:adjustWidth()
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
