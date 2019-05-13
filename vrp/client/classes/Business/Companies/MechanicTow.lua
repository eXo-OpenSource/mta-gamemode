MechanicTow = inherit(Singleton)

function MechanicTow:constructor()
	self.m_Ped = createPed(50, 2466.00, -2096.02, 13.55)
	setElementData(self.m_Ped, "clickable", true)
	self.m_Ped:setData("NPC:Immortal", true)
	self.m_Ped:setFrozen(true)
	self.m_Ped:setData("onClickEvent",
		function()
			self.ms_SelectionGUI = GUIButtonMenu:new("Fahrzeug Art")
			self.ms_SelectionGUI:addItem(_"Privat Fahrzeug", Color.Accent,
				function()
					triggerServerEvent("mechanicOpenTakeGUI", localPlayer, "permanentVehicle")
				end
			)
			self.ms_SelectionGUI:addItem(_"Firma/Gruppen Fahrzeug", Color.Accent,
				function()
					triggerServerEvent("mechanicOpenTakeGUI", localPlayer, "groupVehicle")
				end
			)
		end
	)

	SpeakBubble3D:new(self.m_Ped, _"Fahrzeug freikaufen", _"Klicke mich an!")
	NonCollisionArea:new("Cuboid", {Vector3(2425.22, -2143.81, 12), 23, 18, 5})

	self.m_BugPed = createPed(50, 2446.57, -2110.89, 13.55, 109.26)
	setElementData(self.m_BugPed, "clickable", true)
	self.m_BugPed:setData("BugChecker", true)
	self.m_BugPed:setData("NPC:Immortal", true)
	self.m_BugPed:setFrozen(true)

	SpeakBubble3D:new(self.m_BugPed, _"Ich kann Wanzen aufspüren", _"Klicke mich an!")

	self.m_RenderFuelHoles = {}
	self.m_RequestFill = bind(MechanicTow.requestFill, self)

	addEventHandler("onClientElementStreamIn", root, bind(MechanicTow.onObjectStreamIn, self))
	addEventHandler("onClientRender", root, bind(MechanicTow.renderFuelHose, self))
end

function MechanicTow:onObjectStreamIn()
	if source:getModel() == 1909 then
		self.m_RenderFuelHoles[source] = true
	end
end

function MechanicTow:renderFuelHose()
	for element in pairs(self.m_RenderFuelHoles) do
		if isElement(element) then
			local vehicle = element:getData("attachedToVehicle")
			if isElement(vehicle) and vehicle.towingVehicle then
				local x, y, z = getElementPosition(vehicle)
				local endX, endY, endZ = x+0.07, y, z-0.11
				dxDrawLine3D(x, y, z, element.matrix:transformPosition(Vector3(0.07, 0, -0.11)), Color.Black, 5)

				if localPlayer:getPrivateSync("hasMechanicFuelNozzle") then
					local worldVehicle = localPlayer:getWorldVehicle()
					if worldVehicle and worldVehicle:getModel() ~= 611 and worldVehicle:getModel() ~= 584 and worldVehicle ~= localPlayer.lastWorldVehicle and worldVehicle:getFuelType() ~= "nofuel" then
						localPlayer.lastWorldVehicle = worldVehicle

						VehicleFuel.forceClose()
						VehicleFuel:new(localPlayer.lastWorldVehicle, self.m_RequestFill, true)
					end

					if localPlayer.vehicle or getDistanceBetweenPoints3D(x, y, z, getElementPosition(element)) > 10 then
						self.m_RenderFuelHoles[element] = nil
						triggerServerEvent("mechanicRejectFuelNozzle", localPlayer)
					end
				end
			else
				self.m_RenderFuelHoles[element] = nil
				if localPlayer:getPrivateSync("hasMechanicFuelNozzle") then
					triggerServerEvent("mechanicRejectFuelNozzle", localPlayer)
				end
			end
		else
			self.m_RenderFuelHoles[element] = nil
		end
	end
end

function MechanicTow:requestFill(vehicle, fuel)
	if not vehicle.controller then
		ErrorBox:new("In dem Fahrzeug sitzt kein Spieler")
		return
	end

	triggerServerEvent("mechanicVehicleRequestFill", localPlayer, vehicle, fuel)
end
