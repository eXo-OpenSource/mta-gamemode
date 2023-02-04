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
	local templateName = getElementData(element, "TemplateName") or ""
	local hasLocalPlayerKey = table.find(getElementData(element, "VehicleKeys") or {}, localPlayer:getId()) ~= nil
	if owner then
		self:addItem(_("Besitzer: %s", owner, element:getName())):setTextColor(Color.Red)
	end

	if element:getData("Burned") then
		self:addItem(_"Fahrzeug-Wrack"):setTextColor(Color.Red)
	else
		self:addItem(_("Marke: %s", element:getName())):setTextColor(Color.LightBlue)
	end
	--[[if templateName ~= "" then
		self:addItem(_("Fabrikat: %s ", templateName)):setTextColor(Color.LightBlue)
	else
		self:addItem(_("Fabrikat: Standard")):setTextColor(Color.LightBlue)
	end]]
	--self:addItem(_("Klasse: %s", element:getCategoryName())):setTextColor(Color.LightBlue)
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
		if getElementData(element, "lastDrivers") then
			local lastDriver = getElementData(element, "lastDrivers")[#getElementData(element, "lastDrivers")]
			self:addItem(_("Letzter Fahrer: %s", lastDriver),
				function()
						if self:getElement() then
							delete(self)
							ClickHandler:getSingleton():addMouseMenu(LastDriverMouseMenu:new(posX, posY, element), element)
						end
				end
			):setIcon(FontAwesomeSymbols.Player)
		end
		if getElementData(element, "OwnerName") == localPlayer.name or (getElementData(element, "GroupType") and localPlayer:getGroupName() == getElementData(element, "OwnerName")) or hasLocalPlayerKey then
			if (getElementData(element, "GroupType") and getElementData(element, "GroupType") == "Firma") then
				if getElementData(element, "isRented") ~= true then
					if getElementData(element, "forRent") ~= true then
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
											if amount and #amount > 0 and tonumber(amount) > 0 and tonumber(amount) <= 15000000 then
												triggerServerEvent("groupSetVehicleForSale", self:getElement(), tonumber(amount))
											else
												ErrorBox:new(_("Der Betrag muss zwischen 1$ und 10.000.000$ liegen!"))
											end
										end, true)
									end
								end
							):setIcon(FontAwesomeSymbols.Cart_Plus)
						end
					end

					if getElementData(element, "forSale") ~= true then
						if getElementData(element, "forRent") == true then
							self:addItem(_"Firma: Vermieten beenden",
								function()
									if self:getElement() then
										delete(self)
										QuestionBox:new("Möchtest du die Vermietung des Fahrzeuges beenden?",
										function ()
											triggerServerEvent("groupStopVehicleForRent", self:getElement())
										end)
									end
								end
							):setIcon(FontAwesomeSymbols.HandHoldingUSD)
						else
							self:addItem(_"Firma: zum Mieten anbieten",
								function()
									if self:getElement() then
										delete(self)
										InputBox:new("Fahrzeug zum Mieten anbieten", "Für welchen Betrag pro Stunde möchtest du das Fahrzeug anbieten?",
										function (amount)
											if amount and #amount > 0 and tonumber(amount) > 0 and tonumber(amount) <= 25000 then
												triggerServerEvent("groupSetVehicleForRent", self:getElement(), tonumber(amount))
											else
												ErrorBox:new(_("Der Betrag muss zwischen 1$ und 25.000$ pro Stunde liegen!"))
											end
										end, true)
									end
								end
							):setIcon(FontAwesomeSymbols.HandHoldingUSD)
						end
					end
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
			if getElementData(element, "OwnerType") ~= "faction" and getElementData(element, "OwnerType") ~= "company" and not hasLocalPlayerKey then
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
							triggerServerEvent("vehicleRespawnWorld", self:getElement())
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
		if (element:getModel() == 544 or element:getModel() == 407 or element:getModel() == 563) and 
		localPlayer:getFaction() and localPlayer:getFaction():isRescueFaction() and 
		localPlayer:getPublicSync("Faction:Duty") and localPlayer:getPublicSync("Rescue:Type") == "fire" then
			self:addItem(_"Feuerlöscher auffüllen",
				function()
					if self:getElement() then 
						if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
							if localPlayer:getWeapon(9) == 42 then
								if getPedTotalAmmo(localPlayer, 9)  < 10000 then
									triggerServerEvent("factionRescueFillFireExtinguisher", self:getElement())
									SuccessBox:new(_"Feuerlöscher aufgefüllt.")
								end
							else
								ErrorBox:new(_"Du hast kein Feuerlöscher dabei.")
							end
						end
					end
				end
			):setIcon(FontAwesomeSymbols.Fire_Extinguisher)
		end
		if element:getData("EPT_Taxi") and element:getModel() == 420 or element:getModel() == 438 then -- Taxis
			if localPlayer:getCompany() and localPlayer:getCompany():getId() == 4 and localPlayer:getPublicSync("Company:Duty") == true then
				if localPlayer.vehicle == element and localPlayer.vehicleSeat == 0 then
					self:addItem(_"Taxileuchte bedienen",
						function()
							if self:getElement() then
								triggerServerEvent("publicTransportSwitchTaxiLight", self:getElement())
							end
						end
					):setIcon(FontAwesomeSymbols.Lightbulb)
				end
			end
		end
		if element:getData("VehicleTransporterWithRamp") then
			if localPlayer:getCompany() and localPlayer:getCompany():getId() == 4 and localPlayer:getPublicSync("Company:Duty") == true then
				self:addItem(_"Laderampe bedienen",
				function()
					if self:getElement() then
						triggerServerEvent("vehicleToggleLoadingRamp", self:getElement())
					end
				end
			):setIcon(FontAwesomeSymbols.Car)
			end
		end
		if element:getData("EPT_Bus") then -- Coach
			if localPlayer:getCompany() and localPlayer:getCompany():getId() == 4 and localPlayer:getPublicSync("Company:Duty") == true then
				if PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "startBusTour") then
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
				):setIcon(FontAwesomeSymbols.Table)
			end
		end
		if element:getVehicleType() == VehicleType.Automobile or element:getVehicleType() == VehicleType.Bike then
			if element:getData("ShopVehicle") then
				if not element:getData("Vehicle:Stolen") then
					if localPlayer:getGroupType() == "Gang" then
						self:addItem(_"Fahrzeug stehlen",
							function()
								if localPlayer.vehicle then return ErrorBox:new(_"Steige aus, um das Schloss zu knacken.") end
								if localPlayer:getPrivateSync("isAttachedToVehicle") then return ErrorBox:new(_"Steige vom Fahrzeug ab, um das Schloss zu knacken.") end
								if Damage:getSingleton().m_InTreatment then return ErrorBox:new(_"Du kannst während einer Behandlung kein Schloss knacken.") end
								if not localPlayer.m_IsPickingLockand then
									if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 2 then
										triggerServerEvent("ShopVehicleRob:onTryingSteal", self:getElement())
									else
										ErrorBox:new(_"Du bist zuweit von der Tür entfernt.")
									end
								else 
									ErrorBox:new(_"Du knackst bereits ein Schloss")
								end
							end
						):setIcon(FontAwesomeSymbols.Lock_Open)
					end
				else
					if localPlayer:getFaction() and localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") and not localPlayer.vehicle then
						self:addItem(_"Fahrzeug entsperren",
							function()
								if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 2 then
									triggerServerEvent("ShopVehicleRob:onPoliceUnlockVehicle", self:getElement())
								else
									ErrorBox:new(_"Du bist zuweit von der Tür entfernt.")
								end
							end
						):setIcon(FontAwesomeSymbols.Lock_Open)
					else
						if not element:getData("Vehicle:LockIsPicked") then
							self:addItem(_"Schloss knacken",
								function()
									if localPlayer.vehicle then return ErrorBox:new(_"Steige aus, um das Schloss zu knacken.") end
									if localPlayer:getPrivateSync("isAttachedToVehicle") then return ErrorBox:new(_"Steige vom Fahrzeug ab, um das Schloss zu knacken.") end
									if Damage:getSingleton().m_InTreatment then return ErrorBox:new(_"Du kannst während einer Behandlung kein Schloss knacken.") end
									if not localPlayer.m_IsPickingLock then
										if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 2 then
											triggerServerEvent("ShopVehicleRob:continuePickingLock", self:getElement())
										else
											ErrorBox:new(_"Du bist zuweit von der Tür entfernt.")
										end
									else 
										ErrorBox:new(_"Du knackst bereits ein Schloss")
									end
								end
							):setIcon(FontAwesomeSymbols.Lock_Open)
						end
					end
				end
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
			
			self:addItem(_("Fraktion >>>"),
				function()
					if self:getElement() then
						delete(self)
						ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenuFaction:new(posX, posY, element), element)
					end
				end
			):setIcon(FontAwesomeSymbols.List)
		end
		if getElementData(element, "OwnerName") == localPlayer.name and getElementData(element, "OwnerType") == "player" then
			self:addItem(_"Schlüssel",
				function()
					if self:getElement() then
						VehicleKeyGUI:new(self:getElement())
					end
				end
			):setIcon(FontAwesomeSymbols.Key)
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
		if element:getModel() == 459 then
			if 	(element:getData("OwnerType") == "player" and element:getData("OwnerName") == localPlayer.name) or (element:getData("OwnerType") == "group" and element:getData("OwnerName") == localPlayer:getGroupName()) or
				(element:getData("OwnerType") == "faction" and (localPlayer:getFaction() and element:getData("OwnerName") == localPlayer:getFaction():getName()) and localPlayer:getPublicSync("Faction:Duty")) then 
				if not localPlayer:getData("RcVehicle") then
					if localPlayer.vehicle == element and (localPlayer.vehicleSeat == 2 or localPlayer.vehicleSeat == 3) then
						self:addItem(_"RC Fahrzeug benutzen >>>",
							function()
								if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
									if localPlayer.vehicle then
										ClickHandler:getSingleton():addMouseMenu(MouseMenuRcVehicle:new(posX, posY, element), element)
									else
										ErrorBox:new(_"Du musst im RC Van sitzen.")
									end
								end
							end
						):setIcon(FontAwesomeSymbols.Plane)
					end
				else
					self:addItem(_("%s nicht mehr benutzen", localPlayer.vehicle:getName()),
					function()
						if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
							if self:getElement() then
								triggerServerEvent("vehicleToggleRC", self:getElement(), localPlayer:getData("RcVehicle"), false)
							end
						end
					end
					):setIcon(FontAwesomeSymbols.Plane_Slash)
				end
			end
		end

		if getElementData(element,"WeaponTruck") or VEHICLE_BOX_LOAD[element.model] then
			if #self:getAttachedElement(2912, element) > 0 then
				self:addItem(_"Kiste abladen",
					function()
						--triggerServerEvent("weaponTruckDeloadBox", self:getElement(), element)
						triggerServerEvent("vehicleDeloadObject", self:getElement(), element, "weaponBox")
					end
				):setIcon(FontAwesomeSymbols.Double_Down)
			end
			if #self:getAttachedElement(2912, localPlayer) > 0 then
				self:addItem(_"Kiste aufladen",
					function()
						--triggerServerEvent("weaponTruckLoadBox", self:getElement(), element)
						triggerServerEvent("vehicleLoadObject", self:getElement(), element, "weaponBox")
					end
				):setIcon(FontAwesomeSymbols.Double_Up)
			end
		end

		if VEHICLE_BAG_LOAD[element.model] then
			if #self:getAttachedElement(1550, element) > 0 then
				self:addItem(_"Geldsack abladen",
					function()
						triggerServerEvent("vehicleDeloadObject", self:getElement(), element, "moneyBag")
					end
				):setIcon(FontAwesomeSymbols.Double_Down)
			end
			if #self:getAttachedElement(1550, localPlayer) > 0 then
				self:addItem(_"Geldsack aufladen",
					function()
						triggerServerEvent("vehicleLoadObject", self:getElement(), element, "moneyBag")
					end
				):setIcon(FontAwesomeSymbols.Double_Up)
			end
		end

		if getElementData(element,"WeedTruck") or VEHICLE_PACKAGE_LOAD[element.model] then
			if #self:getAttachedElement(1575, element) > 0 then
				self:addItem(_"Drogenpaket abladen",
					function()
						triggerServerEvent("vehicleDeloadObject", self:getElement(), element, "drugPackage")
					end
				):setIcon(FontAwesomeSymbols.Double_Down)
			end
			if #self:getAttachedElement(1575, localPlayer) > 0 then
				self:addItem(_"Drogenpaket aufladen",
					function()
						triggerServerEvent("vehicleLoadObject", self:getElement(), element, "drugPackage")
					end
				):setIcon(FontAwesomeSymbols.Double_Up)
			end
		end

		if getElementData(element,"ChristmasTruck:Truck") then
			if #self:getAttachedElement(2912, element) > 0 then
				self:addItem(_"Geschenk vom Truck nehmen",
					function()
						triggerServerEvent("vehicleDeloadObject", self:getElement(), element, "christmasPresent")
					end
				):setIcon(FontAwesomeSymbols.Double_Down)
			end
			if #self:getAttachedElement(2912, localPlayer) > 0 then
				self:addItem(_"Geschenk auf den Truck laden",
					function()
						triggerServerEvent("vehicleLoadObject", self:getElement(), element, "christmasPresent")
					end
				):setIcon(FontAwesomeSymbols.Double_Up)
			end
		end

		if localPlayer:getCompany() and localPlayer:getCompany():getId() == CompanyStaticId.MECHANIC and localPlayer:getPublicSync("Company:Duty") then
			if element:getHealth() < 950 then
				self:addItem(_"Mechaniker: Reparieren",
					function()
						if self:getElement() then
							triggerServerEvent("mechanicRepair", self:getElement())
						end
					end
				):setIcon(FontAwesomeSymbols.Wrench)
			end
			if getElementData(element, "Handbrake") == true and (element:getModel() ~= 611 or element:getModel() ~= 584) then
				self:addItem(_"Mechaniker: Handbremse lösen",
					function()
						if self:getElement() then
							triggerServerEvent("vehicleToggleHandbrake", self:getElement())
							delete(self)
						end
					end
				):setIcon(FontAwesomeSymbols.Cogs)
			end

			if localPlayer.vehicle and localPlayer.vehicle:getData("OwnerName") == localPlayer:getCompany():getName() then
				if (element:getVehicleType() == VehicleType.Bike or VEHICLE_BIKES[element:getModel()]) and element:isEmpty() and not localPlayer.vehicle:getData("towingBike") then
					self:addItem(_("Mechaniker: %s aufladen", element:getVehicleType() == VehicleType.Bike and "Motorrad" or "Fahrrad"),
						function()
							if self:getElement() then
								triggerServerEvent("mechanicAttachBike", localPlayer, self:getElement())
								delete(self)
							end
						end
					):setIcon(FontAwesomeSymbols.Cogs)
				end
				if element == localPlayer.vehicle and localPlayer.vehicle:getData("towingBike") then
					self:addItem(_("Mechaniker: %s abladen", localPlayer.vehicle:getData("towingBike"):getVehicleType() == VehicleType.Bike and "Motorrad" or "Fahrrad"),
						function()
							if self:getElement() then
								triggerServerEvent("mechanicDetachBike", localPlayer, self:getElement())
								delete(self)
							end
						end
					):setIcon(FontAwesomeSymbols.Cogs)
				end
			end

			if not localPlayer.vehicle and element.towingVehicle and not element.towingVehicle.controller ~= localPlayer and (element:getModel() == 611 or element:getModel() == 584) and not localPlayer:getPrivateSync("hasGasStationFuelNozzle") then -- fuel tank
				self:addItem(_("Mechaniker: Zapfpistole %s", localPlayer:getPrivateSync("hasMechanicFuelNozzle") and "einhängen" or "nehmen"),
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
			end
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
	if (element.occupants and table.size(element.occupants) > 0) or (element:getData("VSE:Passengers") and table.size(element:getData("VSE:Passengers")) > 0) then
		self:addItem(_"Insassen >>>",
			function()
				if self:getElement() then
					delete(self)
					ClickHandler:getSingleton():addMouseMenu(PassengerMouseMenu:new(posX, posY, element), element)
				end
			end
		):setIcon(FontAwesomeSymbols.Group)
	end

	self:addItem(_"Details >>>",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenuDetails:new(posX, posY, element), element)
			end
		end
	):setIcon(FontAwesomeSymbols.Search)


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

	if getElementData(element, "OwnerType") == "group" and getElementData(element, "forRent") == true then
		self:addItem(_"Fahrzeug mieten",
			function()
				if self:getElement() then
					delete(self)

					InputBox:new(_("Möchtest du das Fahrzeug für %d$ pro Stunde mieten?", getElementData(element, "forRentRate")), "Für wie viele Stunden möchtest du es mieten? Zusätzlich kommt noch eine Kaution von 2000$ dazu, welche zum Begleichen von Kosten vom Tanken, Schäden und/oder Abschleppen verwendet wird.",
					function (duration)
						if duration and #duration > 0 and tonumber(duration) > 0 and tonumber(duration) <= 24 then
							triggerServerEvent("groupRentVehicle", self:getElement(), tonumber(duration))
						else
							ErrorBox:new(_("Es muss länger als 1 Stunde sein und maximal 24 Stunden!"))
						end
					end, true, 1)
				end
			end
		):setIcon(FontAwesomeSymbols.HandHoldingUSD)
	end

	if getElementData(element, "OwnerType") == "group" and getElementData(element, "isRented") == true then
		local rentedUntil = (getElementData(element, "rentedUntil") - getRealTime().timestamp) / 60
		local minutes = math.floor(rentedUntil % 60)
		local hours = math.floor(rentedUntil / 60)
		if minutes < 10 then minutes = "0" .. minutes end

		self:addItem(_("Gemietet von: %s", getElementData(element, "rentedByName"))):setTextColor(Color.White)
		self:addItem(_("Noch %s:%s vermietet", hours, minutes)):setTextColor(Color.White)
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
	if getElementType(element) == "player" then
		return (localPlayer:getPrivateSync("attachedObject") and localPlayer:getPrivateSync("attachedObject"):getModel() == model and {localPlayer:getPrivateSync("attachedObject")}) or {}
	end
	local boxes = {}
	for key,value in pairs(element:getAttachedElements()) do
		if value.model == model then
			table.insert(boxes, value)
		end
	end
	return boxes
end
