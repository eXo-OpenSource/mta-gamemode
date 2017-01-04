PayNSpray = inherit(Object)

function PayNSpray:constructor(x, y, z, garageId)
	self.m_FixShape = createColSphere(x, y, z, 4)
	self.m_Blip = Blip:new("PayNSpray.png", x, y, root, 600)
	if garageId then
		setGarageOpen(garageId, true)
	elseif isElement(self.m_CustomDoor) then
		self:setCustomGarageOpen(true)
	end

	self.m_Company = CompanyManager:getSingleton():getFromId(2) -- Mechanic and Tow Id

	addEventHandler("onColShapeHit", self.m_FixShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				local vehicle = getPedOccupiedVehicle(hitElement)
				if not vehicle or getPedOccupiedVehicleSeat(hitElement) ~= 0 then
					return
				end

				if getElementHealth(vehicle) > 950 then
					hitElement:sendError(_("Dein Fahrzeug hat keinen erheblichen Schaden!", hitElement))
					return
				end

				local costs = math.floor((1000-getElementHealth(vehicle))*0.5) + math.floor((1000-getElementHealth(vehicle))*0.5*0.33)
				if hitElement:getMoney() < costs then
					hitElement:sendError(_("Du hast nicht genügend Geld!", hitElement))
					return
				end

				if garageId then
					setGarageOpen(garageId, false)
				elseif isElement(self.m_CustomDoor) then
					self:setCustomGarageOpen(false)
				end
				setElementFrozen(vehicle, true)

				-- Give money to the Owner (TODO: Improve this -> complete Repair ~4.58$ (310% Vehicle Health) -> is it okay?)
				self.m_Company.m_BankAccount:addMoney(costs*0.01)

				setTimer(
					function()
						vehicle:fix()
						vehicle:setWheelStates(1, 1, 1, 1)
						setElementFrozen(vehicle, false)
						if garageId then
							setGarageOpen(garageId, true)
						elseif isElement(self.m_CustomDoor) then
							self:setCustomGarageOpen(true)
						end

						hitElement:takeMoney(costs, "Pay'N'Spray")
						hitElement:sendShortMessage(_("Die Reperatur kostete %d$", hitElement, costs))
					end,
					3000,
					1
				)
			end
		end
	)
end

function PayNSpray:createCustomDoor(model, pos, rot)
	self.m_CustomDoor = createObject(model, pos, rot)
	self.m_CustomDoor.open = true
	self.m_CustomDoor.moving = false
end

function PayNSpray:setCustomGarageOpen(state)
	if not self.m_CustomDoor.moving then
		local pos = self.m_CustomDoor:getPosition()
		if state == true then
			if not self.m_CustomDoor.open then
				pos.z = pos.z+1.7
				self.m_CustomDoor:move(2000, pos, Vector3(0, 90, 0))
				self.m_CustomDoor.moving = true
				setTimer(function()
					self.m_CustomDoor.open = true
					self.m_CustomDoor.moving = false
				end, 2500, 1)
			end
		else
			if self.m_CustomDoor.open then
				pos.z = pos.z-1.7
				self.m_CustomDoor:move(2000, pos, Vector3(0, -90, 0))
				self.m_CustomDoor.moving = true
				setTimer(function()
					self.m_CustomDoor.open = false
					self.m_CustomDoor.moving = false
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
	PayNSpray:new(-1904.47, 289.47, 4, 19) -- SF Wang Cars
	PayNSpray:new(-2425.84, 1020.08, 4, 27) -- SF Juniper Hill
	PayNSpray:new(720.26, -455.14, 16.34, 47) -- Dillimore

	local noobSpawn = PayNSpray:new(1444.860, -1790.127, 13.250)
	noobSpawn:createCustomDoor(13028, Vector3(1445.5998,-1781.0005,16.1), Vector3(180,-90,90))
end
