MechanicTow = inherit(Singleton)
addRemoteEvents{"mechanicFuelTankStart", "mechanicFuelTankStop"}

function MechanicTow:constructor()
	self.m_Ped = createPed(50, 913.83, -1234.65, 16.98)
	setElementData(self.m_Ped, "clickable", true)
	self.m_Ped:setData("NPC:Immortal", true)
	self.m_Ped:setFrozen(true)
	self.m_Ped:setData("onClickEvent",
		function()
			self.ms_SelectionGUI = GUIButtonMenu:new("Fahrzeug Art")
			self.ms_SelectionGUI:addItem(_"Privat Fahrzeug", Color.LightBlue,
				function()
					triggerServerEvent("mechanicOpenTakeGUI", localPlayer, "permanentVehicle")
				end
			)
			self.ms_SelectionGUI:addItem(_"Firma/Gruppen Fahrzeug", Color.LightBlue,
				function()
					triggerServerEvent("mechanicOpenTakeGUI", localPlayer, "groupVehicle")
				end
			)
		end
	)

	SpeakBubble3D:new(self.m_Ped, _"Fahrzeug freikaufen", _"Klicke mich an!")

	NonCollidingArea:new(894.25, -1188.40, 16.98, 10)
	NonCollidingArea:new(915.76, -1192.84, 16.72, 10)
	NonCollidingArea:new(908.032, -1259.658, 15, 15)
	-- NonCollidingArea:new(864.61, -1272.77, 15, 15)

	self.m_BugPed = createPed(50, 850.305, -1226.058, 17.269, 290)
	setElementData(self.m_BugPed, "clickable", true)
	self.m_BugPed:setData("BugChecker", true)
	self.m_BugPed:setData("NPC:Immortal", true)
	self.m_BugPed:setFrozen(true)

	SpeakBubble3D:new(self.m_BugPed, _"Ich kann Wanzen aufspüren", _"Klicke mich an!")

	self.m_RenderFuelHoles = {}
	self.m_RequestFill = bind(MechanicTow.requestFill, self)

	addEventHandler("onClientElementStreamIn", root, bind(MechanicTow.onObjectStreamIn, self))
	addEventHandler("onClientRender", root, bind(MechanicTow.renderFuelHose, self))
	addEventHandler("mechanicFuelTankStart", root, bind(MechanicTow.fuelTankStart, self))
	addEventHandler("mechanicFuelTankStop", root, bind(MechanicTow.fuelTankStop, self))
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
			if vehicle then
				dxDrawLine3D(vehicle.position, element.matrix:transformPosition(Vector3(0.07, 0, -0.11)), Color.Black, 5)

				if localPlayer:getPrivateSync("hasFuelNozzle") then
					local worldVehicle = localPlayer:getWorldVehicle()
					if worldVehicle and worldVehicle:getModel() ~= 611 and worldVehicle ~= localPlayer.lastWorldVehicle then
						localPlayer.lastWorldVehicle = worldVehicle

						if not VehicleFuel:isInstantiated() then
							VehicleFuel:new(localPlayer.lastWorldVehicle, self.m_RequestFill)
						end
					elseif not worldVehicle then
						localPlayer.lastWorldVehicle = nil

						if VehicleFuel:isInstantiated() then
							delete(VehicleFuel:getSingleton())
						end
					end

					if (vehicle.position - element.position).length > 10 then
						self.m_RenderFuelHoles[element] = nil
						triggerServerEvent("mechanicRejectFuelNozzle", localPlayer)
					end
				end
			end
		else
			self.m_RenderFuelHoles[element] = nil
		end
	end
end

function MechanicTow:requestFill(vehicle, fuel)
	if VehicleFuel:isInstantiated() then
		delete(VehicleFuel:getSingleton())
	end

	if not vehicle.controller then
		ErrorBox:new("In dem Fahrzeug sitzt kein Spieler")
	--	return
	end

	InfoBox:new("Dem Spieler wurde dein Service angeboten..")
	triggerServerEvent("mechanicVehicleRequestFill", localPlayer, vehicle, fuel)
end

function MechanicTow:fuelTankStart(vehicle)
	FuelTankGUI:new(vehicle)

	--bindKey("mouse1", "down", self.m_RequestFill)
end

function MechanicTow:fuelTankStop()
	if FuelTankGUI:isInstantiated() then
		delete(FuelTankGUI:getSingleton())
	end

	unbindKey("mouse1", "down", self.m_RequestFill)
end
