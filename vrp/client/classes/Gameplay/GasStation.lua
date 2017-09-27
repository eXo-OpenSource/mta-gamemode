-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/GasStation.lua
-- *  PURPOSE:     Gas stations
-- *
-- ****************************************************************************
GasStation = inherit(Singleton)
addRemoteEvents{"gasStationReset", "gasStationNonInteriorRequest"}

function GasStation:constructor()
	self.m_RenderFuelHoles = {}
	self.m_RenderGasStations = {}

	self.m_RenderTarget = dxCreateRenderTarget(512, 512)
	self.m_Shaders = {
		StaticRenderTargetTextureReplacer:new(self.m_RenderTarget, "petrolpumpbase_256", {}),
		StaticRenderTargetTextureReplacer:new(self.m_RenderTarget, "vgnptrpump1_256", {})
	}

	self.m_Amount = "-"
	self.m_Price = "-"

	self.m_Font = dxCreateFont("files/fonts/fuelstation.ttf", 25)
	self.m_Size = 1

	self.m_FilledDone =
		function(vehicle, fuel, station, price, opticalFuel)
			GasStation.PendingTransaction = {station = station, vehicle = vehicle, fuel = fuel, price = price, opticalFuel = opticalFuel}
			InfoBox:new("Gehe in die Tankstelle um zu bezahlen!")
			--triggerServerEvent("gasStationStartTransaction", localPlayer, vehicle, fuel, station)
		end

	self.m_Reset =
		function()
			GasStation.PendingTransaction = nil
			if GasStationShopGUI:isInstantiated() then
				local gasStationGUI = GasStationShopGUI:getSingleton()
				gasStationGUI.m_Fuel:setText("-")
				gasStationGUI.m_Price:setText("-")
				gasStationGUI.m_Confirm:setVisible(false)
				gasStationGUI.m_Cancel:setVisible(false)
			end
		end

	addEventHandler("gasStationReset", root, self.m_Reset)
	addEventHandler("gasStationNonInteriorRequest", root, bind(GasStation.nonInteriorRequest, self))
	addEventHandler("onClientElementStreamIn", root, bind(GasStation.onObjectStreamIn, self))
	addEventHandler("onClientElementStreamOut",root ,bind(GasStation.onObjectStreamOut, self))
	addEventHandler("onClientRender", root, bind(GasStation.renderGasStation, self))
end

function GasStation:onObjectStreamIn()
	if source:getModel() == 1909 then
		self.m_RenderFuelHoles[source] = true
		return
	end

	if source:getModel() == 1676 then
		self.m_RenderGasStations[source] = true
		source:setBreakable(false)
		return
	end
end

function GasStation:onObjectStreamOut()
	if source:getModel() == 1676 then
		self.m_RenderGasStations[source] = nil
		return
	end
end

function GasStation:nonInteriorRequest()
	if not GasStation.PendingTransaction then return end

	local vehicle = GasStation.PendingTransaction.vehicle
	local fuel = GasStation.PendingTransaction.fuel
	local station = GasStation.PendingTransaction.station
	local price = math.floor(fuel * (station:getData("isServiceStation") and SERVICE_FUEL_PRICE_MULTIPLICATOR or FUEL_PRICE_MULTIPLICATOR))

	QuestionBox:new(("Möchtest du %s Liter für %s$ auftanken?"):format(fuel, price),
		function()
			triggerServerEvent("gasStationConfirmTransaction", localPlayer, vehicle, fuel, station)
		end,
		function()
			GasStation.PendingTransaction = nil
		end
	)
end

function GasStation:renderGasStation()
	for element in pairs(self.m_RenderFuelHoles) do
		if isElement(element) then
			local station = element:getData("attachedGasStation")
			if isElement(station) then
				dxDrawLine3D(station.matrix:transformPosition(Vector3(0, 0, 1.2)), element.matrix:transformPosition(Vector3(0.07, 0, -0.11)), Color.Black, 5)

				if element:getData("attachedPlayer") == localPlayer then
					localPlayer.usingGasStation = station

					local worldVehicle = localPlayer:getWorldVehicle()
					if worldVehicle and worldVehicle ~= localPlayer.lastWorldVehicle then
						localPlayer.lastWorldVehicle = worldVehicle

						VehicleFuel.forceClose()
						VehicleFuel:new(localPlayer.lastWorldVehicle, self.m_FilledDone, false, station)
					end

					if localPlayer.vehicle or (station.position - element.position).length > 10 then
						localPlayer.lastWorldVehicle = nil
						localPlayer.usingGasStation = nil
						self.m_RenderFuelHoles[element] = nil
						triggerServerEvent("gasStationRejectFuelNozzle", localPlayer)
					end
				end
			end
		else
			self.m_RenderFuelHoles[element] = nil
			localPlayer.lastWorldVehicle = nil
			localPlayer.usingGasStation = nil
		end
	end

	dxSetRenderTarget(self.m_RenderTarget)
		self:renderBackground()
		self:renderDisplay()
	dxSetRenderTarget()
	--self.m_Shaders[1]:update()
	--self.m_Shaders[2]:update()
end

function GasStation:renderBackground()
	dxDrawImage(0, 0, 512, 512, "files/images/Textures/GasStation.png")
	dxDrawRectangle(50, 80, 412, 60, Color.DarkBlue)
	dxDrawRectangle(55, 85, 200, 50, Color.Black)
	dxDrawRectangle(50, 180, 412, 60, Color.DarkBlue)
	dxDrawRectangle(55, 185, 200, 50, Color.Black)
end

function GasStation:renderDisplay()
	if localPlayer:getPrivateSync("hasGasStationFuelNozzle") and localPlayer.usingGasStation then
		self.m_Amount = VehicleFuel:isInstantiated() and VehicleFuel:getSingleton():getOpticalFuelAmount() or 0
		self.m_Price = VehicleFuel:isInstantiated() and VehicleFuel:getSingleton():getFuelPrice() or 0
	else
		self.m_Amount = "-"
		self.m_Price = "-"
	end

	local px, py, width, height = 55, 85, 200, 50


	dxDrawText("Liter" , px + width, py, px + width*2, py + height, Color.White, 3, "default-bold", "center", "center")
	dxDrawText(self.m_Amount , px, py, px + width, py + height, Color.White, self.m_Size, self.m_Font, "center", "center")

	local px, py, width, height = 55, 185, 200, 50
	dxDrawText("Dollar", px + width, py, px + width*2, py + height, Color.White, 3, "default-bold", "center", "center")
	dxDrawText(self.m_Price, px, py, px + width, py + height, Color.White, self.m_Size, self.m_Font, "center", "center")
end
