PayNSpray = inherit(Object)

function PayNSpray:constructor(x, y, z, garageId)
	self.m_FixShape = createColSphere(x, y, z, 4)
	self.m_Blip = Blip:new("PayNSpray.png", x, y, root, 600)
	self.m_Blip:setDisplayText("Pay'N'Spray Autoreparatur", BLIP_CATEGORY.VehicleMaintenance)
	self.m_Blip:setOptionalColor({67, 121, 98})
	self.m_BankAccountServer = BankServer.get("vehicle.paynspray")
	if garageId then
		setGarageOpen(garageId, true)
	elseif isElement(self.m_CustomDoor) then
		self:setCustomGarageOpen(true)
	end

	self.m_Company = CompanyManager:getSingleton():getFromId(CompanyStaticId.MECHANIC) -- Mechanic and Tow Id

	addEventHandler("onColShapeHit", self.m_FixShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				local vehicle = getPedOccupiedVehicle(hitElement)
				if not vehicle or getPedOccupiedVehicleSeat(hitElement) ~= 0 then
					return
				end
				if vehicle.m_IsAutoLesson then
					return hitElement:sendError(_("Du kannst dieses Fahrzeug nicht reparieren!", hitElement))
				end
				local costs = (100 - vehicle:getHealthInPercent()) * 5 -- max. 500$, maybe improve this later to get higher costs based on maxHealth (armor)
				if not hitElement:isFactionDuty() and not hitElement:isCompanyDuty() and hitElement:getBankMoney() < costs then
					hitElement:sendError(_("Du benötigst %d$ auf deinem Bankkonto um dein Fahrzeug zu reparieren", hitElement, costs))
					return
				end
				if hitElement:getFaction() and hitElement:isFactionDuty() and vehicle:getFaction() == hitElement:getFaction() and hitElement:getFaction():getMoney() < costs then
					hitElement:sendError(_("Deine Fraktion benötigt %d$ in der Kasse, um dein Fahrzeug zu reparieren", hitElement, costs))
					return
				elseif hitElement:getCompany() and hitElement:isCompanyDuty() and instanceof(vehicle, CompanyVehicle) and vehicle:getCompany() == hitElement:getCompany() and hitElement:getCompany():getMoney() < costs then
						hitElement:sendError(_("Dein Unternehmen benötigt %d$ in der Kasse, um dein Fahrzeug zu reparieren", hitElement, costs))
					return
				end

				if garageId then
					setGarageOpen(garageId, false)
				elseif isElement(self.m_CustomDoor) then
					self:setCustomGarageOpen(false)
				end
				setElementFrozen(vehicle, true)

				-- Give money to the Owner (TODO: Improve this -> complete Repair ~4.58$ (310% Vehicle Health) -> is it okay?)
				if math.floor(costs*0.5) > 0 then
					self.m_BankAccountServer:transferMoney({self.m_Company, nil, true}, math.floor(costs*0.5), "Pay N Spray", "Vehicle", "Repair")
				end
				vehicle.m_DisableToggleHandbrake = true
				setTimer(
					function()
						if garageId then
							setGarageOpen(garageId, true)
						elseif isElement(self.m_CustomDoor) then
							self:setCustomGarageOpen(true)
						end

						setElementFrozen(vehicle, false)
						vehicle.m_DisableToggleHandbrake = nil

						if not isElement(hitElement) then return end
						if hitElement:getFaction() and hitElement:isFactionDuty() and vehicle:getFaction() == hitElement:getFaction() then
							if hitElement:getFaction():getMoney() >= costs then
								if costs > 0 then
									hitElement:getFaction():transferMoney(self.m_BankAccountServer, costs, "Pay'N'Spray", "Vehicle", "Repair")
								end
							else
								return hitElement:sendError(_("Deine Fraktion benötigt %d$ in der Kasse, um dein Fahrzeug zu reparieren", hitElement, costs))
							end
						elseif hitElement:getCompany() and hitElement:isCompanyDuty() and instanceof(vehicle, CompanyVehicle) and vehicle:getCompany() == hitElement:getCompany() then
							if hitElement:getCompany():getMoney() >= costs then
								if costs > 0 then
									hitElement:getCompany():transferMoney(self.m_BankAccountServer, costs, "Pay'N'Spray", "Vehicle", "Repair")
								end
							else
								return hitElement:sendError(_("Dein Unternehmen benötigt %d$ in der Kasse, um dein Fahrzeug zu reparieren", hitElement, costs))
							end
						else
							if hitElement:getBankMoney() >= costs then
								if costs > 0 then
									hitElement:transferBankMoney(self.m_BankAccountServer, costs, "Pay'N'Spray", "Vehicle", "Repair")
								end
							else
								return hitElement:sendError(_("Du benötigst %d$ auf deinem Bankkonto um dein Fahrzeug zu reparieren", hitElement, costs))
							end
						end
						vehicle:fix()
						vehicle:setWheelStates(0, 0, 0, 0)
					end,
					3000, 1
				)
			end
		end
	)
end

function PayNSpray:createCustomDoor(model, pos, rot)
	self.m_CustomDoor = createObject(model, pos, rot)
	self.m_CustomDoor.open = true
end

function PayNSpray:setCustomGarageOpen(state)
	if not self.m_CustomDoor.moving then
		local pos = self.m_CustomDoor:getPosition()
		if state == true then
			if not self.m_CustomDoor.open then
				pos.z = pos.z+1.7
				self.m_CustomDoor:move(2000, pos, Vector3(0, 90, 0))
				setTimer(function()
					self.m_CustomDoor.open = true
				end, 2500, 1)
			end
		else
			if self.m_CustomDoor.open then
				pos.z = pos.z-1.7
				self.m_CustomDoor:move(2000, pos, Vector3(0, -90, 0))
				setTimer(function()
					self.m_CustomDoor.open = false
				end, 2500, 1)
			end
		end
	end
end

function PayNSpray:destructor()
	destroyElement(self.m_FixShape)
	delete(self.m_Blip)
end

function PayNSpray.initializeAll()
	-- Todo
	PayNSpray:new(2063.2, -1831.3, 13.5, 8) -- LS Idlewood
	PayNSpray:new(487.4, -1742.8, 11.1, 12) -- LS Santa Maria Beach
	PayNSpray:new(1025.1, -1022, 32.1, 11) -- LS Temple
	PayNSpray:new(1976.60, 2162.41, 9.57, 36) -- LV City
	PayNSpray:new(-99.77, 1118.37, 18.29, 41) -- Fort Carson
	PayNSpray:new(-1904.47, 289.47, 40, 19) -- SF Wang Cars{ x = -1904.900, y = 286.494, z = 40.456 }
	PayNSpray:new(-2425.84, 1020.08, 50.4, 27) -- SF Juniper Hill
	PayNSpray:new(-1420.49, 2582.37, 55.41, 40) -- El Quebrados
	PayNSpray:new(720.26, -455.14, 16.34, 47) -- Dillimore

	--local noobSpawn = PayNSpray:new(1444.860, -1790.127, 13.250)
	--noobSpawn:createCustomDoor(13028, Vector3(1445.6, -1781.39, 16.1), Vector3(180, -90, 90))
end
