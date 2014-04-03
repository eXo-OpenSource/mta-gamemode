PayNSpray = inherit(Object)

function PayNSpray:constructor(x, y, z, garageId)
	self.m_FixShape = createColSphere(x, y, z, 4)
	self.m_Blip = Blip:new("files/images/Blips/PayNSpray.png", x, y)
	setGarageOpen(garageId, true)
	
	addEventHandler("onColShapeHit", self.m_FixShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				local vehicle = getPedOccupiedVehicle(hitElement)
				if not vehicle then
					return
				end
				
				local costs = math.floor((1000-getElementHealth(vehicle))*0.1)
				if hitElement:getMoney() < costs then
					hitElement:sendError(_("Du hast nicht genügend Geld!", hitElement))
					return
				end
				
				setGarageOpen(garageId, false)
				setElementFrozen(vehicle, true)
				hitElement:takeMoney(costs)
				hitElement:sendShortMessage(_("Die Reperatur kostete %d$", hitElement, costs))
				
				setTimer(
					function()
						fixVehicle(vehicle)
						setElementFrozen(vehicle, false)
						setGarageOpen(garageId, true)
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
end
