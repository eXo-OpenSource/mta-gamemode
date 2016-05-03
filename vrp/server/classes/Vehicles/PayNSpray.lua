PayNSpray = inherit(Object)

function PayNSpray:constructor(x, y, z, garageId)
	self.m_FixShape = createColSphere(x, y, z, 4)
	self.m_Blip = Blip:new("PayNSpray.png", x, y)
	if garageId then
		setGarageOpen(garageId, true)
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
				end
				setElementFrozen(vehicle, true)

				-- Give money to the Owner (TODO: Improve this -> complete Repair ~4.58$ (310% Vehicle Health) -> is it okay?)
				self.m_Company.m_BankAccount:addMoney(costs*0.01)

				setTimer(
					function()
						fixVehicle(vehicle)
						setElementFrozen(vehicle, false)
						if garageId then
							setGarageOpen(garageId, true)
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

function PayNSpray:destructor()
	destroyElement(self.m_FixShape)
	delete(self.m_Blip)
end

function PayNSpray.initializeAll()
	-- Todo
	PayNSpray:new(2063.2, -1831.3, 13.5, 8)
	PayNSpray:new(487.4, -1742.8, 11.1, 12)
	PayNSpray:new(1025.1, -1022, 32.1, 11)
	PayNSpray:new(1444.860, -1785.127, 13.250)
end
