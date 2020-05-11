-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/VehicleImportManager.lua
-- *  PURPOSE:     manager for vehicle importing missions (delivery to vehicle shops) 
-- *
-- ****************************************************************************


VehicleImportManager = inherit(Singleton)
VehicleImportManager.ImportLocation = Vector3(-1706.71, 12.56, 3.55)
VehicleImportManager.ImportRotation = 315
VehicleImportManager.TransportMissionEndCountdown = 10 -- 10 sec
VehicleImportManager.VehiclePriceToPaymentFactor = 0.025 -- 2.5% of vehicle price -> total payment for both EPT and driver
VehicleImportManager.PaymentForDriverFactor = 0.25 -- driver of vehicle (the one who ended the mission) gets 25% of the total payment  

addRemoteEvents {"requestVehicleImportList", "startVehicleTransport"}

function VehicleImportManager:constructor()
	self.m_ActiveVehicles = {}
	self.m_ActiveVehiclesByShop = {}
	self.m_VehicleTransporters = {}

    self.m_SendVehicleListFunc = bind(self.sendVehicleListToClient, self)
	self.m_StartTransportFunc = bind(self.startTransport, self)
	self.m_VehicleDeliveryHitFunc = bind(self.internalVehicleDeliveryColHit, self)
	self.m_VehicleDamageFunc = bind(self.internalOnVehicleDamage, self)
	self.m_VehicleEnterFunc = bind(self.internalOnVehicleEnter, self, veh)
	self.m_VehicleExitFunc = bind(self.internalOnVehicleExit, self, veh)
	self.m_VehicleTransporterRespawnFunc = bind(self.internalOnVehicleTransporterRespawn, self)
	self.m_VehicleTransporterDamageFunc = bind(self.internalOnVehicleTransporterDamage, self)
	self.m_VehicleTransporterEnterFunc = bind(self.internalVehicleTransporterOnEnter, self)
	self.m_VehicleTransporterExitFunc = bind(self.internalVehicleTransporterOnExit, self)

    addEventHandler("requestVehicleImportList", root, self.m_SendVehicleListFunc)
	addEventHandler("startVehicleTransport", root, self.m_StartTransportFunc)
	
	self.m_VehicleLoadingColHitFunc = bind(self.internalOnVehicleColHit, self)
	self.m_VehicleLoadingColLeaveFunc = bind(self.internalOnVehicleColLeave, self)

	self.m_LoadingCols = {}
	self.m_ImportWarehouseCol = createColSphere(VehicleImportManager.ImportLocation, 20)
	self.m_ImportWarehouseCol:setData("NonCollisionArea", {players = true}, true)
	self:addLoadingCol(self.m_ImportWarehouseCol) -- add warehouse col permanently

	self.m_BankAccountServer = BankServer.get("action.vehicle_import")
end

function VehicleImportManager:addVehicleTransporter(veh)
	if self.m_VehicleTransporters[veh] then return end
	self.m_VehicleTransporters[veh] = true
	addEventHandler("onVehicleEnter", veh, self.m_VehicleTransporterEnterFunc)
	addEventHandler("onVehicleExit", veh, self.m_VehicleTransporterExitFunc)
	veh:getRespawnHook():register(self.m_VehicleTransporterRespawnFunc)
	veh:getDamageHook():register(self.m_VehicleTransporterDamageFunc)
end

function VehicleImportManager:removeVehicleTransporter(veh)
	assert(self.m_VehicleTransporters[veh], "vehicle is not a transport vehicle")
	self.m_VehicleTransporters[veh] = nil
	removeEventHandler("onVehicleEnter", veh, self.m_VehicleTransporterEnterFunc)
	removeEventHandler("onVehicleExit", veh, self.m_VehicleTransporterExitFunc)
	veh:getRespawnHook():unregister(self.m_VehicleTransporterRespawnFunc)
	veh:getDamageHook():unregister(self.m_VehicleTransporterDamageFunc)
end

function VehicleImportManager:openVehicleListForPlayer(player)
    triggerClientEvent(player, "openVehicleImportListGUI", player, self:getVehicleShopMissingStock())
end

function VehicleImportManager:sendVehicleListToClient(player)
    self:openVehicleListForPlayer(client)
end

function VehicleImportManager:startTransport(shopId, model, variant, reloadListForClient)
	if not client or not client:getCompany() or not client:isCompanyDuty() or client:getCompany():getId() ~= CompanyStaticId.EPT then 
		if client then client:sendError("Du darfst den Transport nicht starten.") end
		return 
	end
	-- check if vehicle is valid shop vehicle
	if not ShopManager.VehicleShopsMap[shopId] or not ShopManager.VehicleShopsMap[shopId].m_VehicleList[model] or not ShopManager.VehicleShopsMap[shopId].m_VehicleList[model][variant] then
		client:sendError("Ungültiges Shop-Fahrzeug. Bitte öffne die Fahrzeugliste erneut.")
		return
	end

	--check if stock is missing
	local currentlyTransported = self:getCurrentlyTransportedVehiclesByShop(shopId, model, variant)
	
	local max = ShopManager.VehicleShopsMap[shopId].m_VehicleList[model][variant].maxStock
	local current = ShopManager.VehicleShopsMap[shopId].m_VehicleList[model][variant].currentStock + currentlyTransported
	if current >= max then
		client:sendError("Der Shop benötigt keine weiteren Fahrzeuge.")
		return
	end

	CompanyManager:getSingleton():getFromId(CompanyStaticId.EPT)
			:sendShortMessage(("%s hat den Transport für das Fahrzeug '%s' gestartet."):format(getPlayerName(client), VehicleCategory:getSingleton():getModelName(model)))
	CompanyManager:getSingleton():getFromId(CompanyStaticId.EPT):addLog(client, "Import", ("hat den Fahrzeugtransport für das Fahrzeug '%s' gestartet!"):format(VehicleCategory:getSingleton():getModelName(model)))
	
	local payment = math.round((ShopManager.VehicleShopsMap[shopId].m_VehicleList[model][variant].price * VehicleImportManager.VehiclePriceToPaymentFactor))

	self:internalCreateVehicle(shopId, model, variant, payment)
	
	if reloadListForClient then
		self:openVehicleListForPlayer(client)
	end
end

function VehicleImportManager:getVehicleShopMissingStock()
	local stock = {}
	for id, shop in pairs(ShopManager.VehicleShopsMap) do
		for vehicleModel, vehicleVariants in pairs(shop.m_VehicleList) do
			for index, vehicleData in pairs(vehicleVariants) do 
				if vehicleData.maxStock ~= -1 and vehicleData.currentStock < vehicleData.maxStock then
					table.insert(stock, {
                        shopId 					= id,
                        shopName        		= shop.m_Name,
						model 					= vehicleModel,
						variant 				= index,
						currentStock 			= vehicleData.currentStock,
						currentlyTransported 	= self:getCurrentlyTransportedVehiclesByShop(id, vehicleModel, index),
                        maxStock 				= vehicleData.maxStock,
                        price           		= math.round((vehicleData.price * VehicleImportManager.VehiclePriceToPaymentFactor)),
					})
				end
			end
		end
	end
	return stock
end

function VehicleImportManager:getCurrentlyTransportedVehiclesByShop(shopId, vehicleModel, variant)
	return (self.m_ActiveVehiclesByShop[shopId] and self.m_ActiveVehiclesByShop[shopId][vehicleModel] and self.m_ActiveVehiclesByShop[shopId][vehicleModel][variant]) and self.m_ActiveVehiclesByShop[shopId][vehicleModel][variant] or 0
end

function VehicleImportManager:increaseShopStockByVehicle(shopId, model, variant)
	if not (ShopManager.VehicleShopsMap[shopId]) then return end
	ShopManager.VehicleShopsMap[shopId]:increaseVehicleStock(model, variant)
end

-- vehicle transporter functions

function VehicleImportManager:internalVehicleTransporterOnEnter(player, seat)
	assert(self.m_VehicleTransporters[source], "vehicle is not a transport vehicle")
	assert(isElement(player) and getElementType(player) == "player", "not a valid player")
	if seat ~= 0 then return end
	local activeVehiclesOnTransporter = {}
	for veh, pos in pairs(self.m_ActiveVehicles) do
		if veh:getAttachedTo() == source then
			activeVehiclesOnTransporter[veh] = pos
		end
	end
	player:triggerEvent("createVehicleTransportDestinationBlips", activeVehiclesOnTransporter)
end

function VehicleImportManager:internalVehicleTransporterOnExit(player, seat)
	assert(self.m_VehicleTransporters[source], "vehicle is not a transport vehicle")
	assert(isElement(player) and getElementType(player) == "player", "not a valid player")
	
	if seat ~= 0 then return end
	player:triggerEvent("destroyVehicleTransportDestinationBlips")
end

function VehicleImportManager:internalOnVehicleTransporterRespawn(transporter)
	for i, veh in pairs(getAttachedElements(transporter)) do
		if self.m_ActiveVehicles[veh] then
			veh:detach()
			self:internalOnVehicleColLeave(veh, true)
		end
	end
end

function VehicleImportManager:internalOnVehicleTransporterDamage(transporter, loss)
	if loss < 50 then return end
	local vehiclesDetached = 0
	for i, veh in pairs(getAttachedElements(transporter)) do
		if self.m_ActiveVehicles[veh] then
			veh:detach()
			self:internalOnVehicleColLeave(veh, true)
			vehiclesDetached = vehiclesDetached + 1
		end
	end

	if transporter.controller and vehiclesDetached > 0 then
		transporter.controller:sendWarning("Der Aufprall des Transporters hat die Fahrzeuge weggeschleudert! Lade sie schnell wieder auf, oder der Transport schlägt fehl!")
	end
end

-- loading collision sphere logic

-- adds a colshape to the whitelist of places where transportable vehicles can drive without getting the destroy countdown 
function VehicleImportManager:addLoadingCol(col)
	if not isElement(col) or getElementType(col) ~= "colshape" then return end
	if not table.find(self.m_LoadingCols, col) then table.insert(self.m_LoadingCols, col) end
	if not isEventHandlerAdded("onColShapeHit", col, self.m_VehicleLoadingColHitFunc) then
		addEventHandler("onColShapeHit", col, self.m_VehicleLoadingColHitFunc)
	end
	if not isEventHandlerAdded("onColShapeLeave", col, self.m_VehicleLoadingColLeaveFunc) then
		addEventHandler("onColShapeLeave", col, self.m_VehicleLoadingColLeaveFunc)
	end
	-- trigger hit function for every element inside (as col itself is not created)
	for i,elem in pairs(getElementsWithinColShape(col)) do
		self.m_VehicleLoadingColHitFunc(elem, col:getDimension() == elem:getDimension())
	end
end

function VehicleImportManager:removeLoadingCol(col)
	table.removevalue(self.m_LoadingCols, col)
	if  isElement(col) and getElementType(col) ~= "colshape" then
		if isEventHandlerAdded("onColShapeHit", col, self.m_VehicleLoadingColHitFunc) then
			removeEventHandler("onColShapeHit", col, self.m_VehicleLoadingColHitFunc)
		end
		if isEventHandlerAdded("onColShapeLeave", col, self.m_VehicleLoadingColLeaveFunc) then
			removeEventHandler("onColShapeLeave", col, self.m_VehicleLoadingColLeaveFunc)
		end
	end
	-- trigger leave function for every element inside (as col itself is not destroyed)
	for i,elem in pairs(getElementsWithinColShape(col)) do
		self.m_VehicleLoadingColLeaveFunc(elem, col:getDimension() == elem:getDimension())
	end
end

function VehicleImportManager:internalOnVehicleColHit(hitElem, dim)
	if not dim or not self.m_ActiveVehicles[hitElem] then return end

	if hitElem.destroyTimer and isTimer(hitElem.destroyTimer) then killTimer(hitElem.destroyTimer) end
	if hitElem.controller and isElement(hitElem.controller) then
		hitElem.controller:triggerEvent("CountdownStop", "Lieferung beendet")
	end
end

function VehicleImportManager:internalOnVehicleColLeave(hitElem, dim)
	if not dim or not self.m_ActiveVehicles[hitElem] then return end

	if hitElem:getAttachedTo() and isElement(hitElem:getAttachedTo()) and hitElem:getAttachedTo().vehicleTransportVehicle then return end -- vehicle is loaded
	for i = 1, #self.m_LoadingCols do -- do nothing if vehicle is inside another loading col
		if isElementWithinColShape(hitElem, self.m_LoadingCols[i]) then
			return
		end
	end
	hitElem.destroyTimer = setTimer(hitElem.destroyOnColLeaveFunc, VehicleImportManager.TransportMissionEndCountdown*1000, 1)
	if hitElem.controller and isElement(hitElem.controller) then
		hitElem.controller:triggerEvent("Countdown", VehicleImportManager.TransportMissionEndCountdown, "Lieferung beendet")
	end
end

-- vehicle management

function VehicleImportManager:internalCreateVehicle(shop, model, variant, payment)
	local veh = TemporaryVehicle.create(model, VehicleImportManager.ImportLocation.x, VehicleImportManager.ImportLocation.y, VehicleImportManager.ImportLocation.z, VehicleImportManager.ImportRotation)
	veh:setRepairAllowed(false)
	veh.destroyOnColLeaveFunc 	= bind(self.internalDestroyVehicle, self, veh)
	veh.transportShopId 		= shop
	veh.transportShopVariant 	= variant
	veh.transportPayment 		= payment
	
	veh.destinationCol = ShopManager.VehicleShopsMap[shop].m_NonCollissionCol
	self:addLoadingCol(veh.destinationCol)
	addEventHandler("onElementColShapeHit", veh, self.m_VehicleDeliveryHitFunc)
	addEventHandler("onVehicleEnter", veh, self.m_VehicleEnterFunc)
	addEventHandler("onVehicleExit", veh, self.m_VehicleExitFunc)
	veh:getDamageHook():register(self.m_VehicleDamageFunc)

	veh:toggleRespawn(false)
	veh:setAlwaysDamageable(true)
	veh:setRepairAllowed(false)

	local destinationPos = veh.destinationCol.position
	self.m_ActiveVehicles[veh] = {destinationPos.x, destinationPos.y, destinationPos.z}

	-- save amount of transported vehicles in separate table
	if not self.m_ActiveVehiclesByShop[shop] then self.m_ActiveVehiclesByShop[shop] = {} end
	if not self.m_ActiveVehiclesByShop[shop][model] then self.m_ActiveVehiclesByShop[shop][model] = {} end
	if not self.m_ActiveVehiclesByShop[shop][model][variant] then self.m_ActiveVehiclesByShop[shop][model][variant] = 0 end
	self.m_ActiveVehiclesByShop[shop][model][variant] = self.m_ActiveVehiclesByShop[shop][model][variant] + 1
end

function VehicleImportManager:internalDestroyVehicle(veh, missionSuccess)
	assert(self.m_ActiveVehicles[veh], "bad argument @internalDestroyVehicle: vehicle is not an import vehicle")
	if not missionSuccess then
		CompanyManager:getSingleton():getFromId(CompanyStaticId.EPT)
		:sendShortMessage(("Die Lieferung des Fahrzeuges '%s' wurde abgebrochen."):format(veh:getName()))
	end
	self.m_ActiveVehiclesByShop[veh.transportShopId][veh:getModel()][veh.transportShopVariant] = self.m_ActiveVehiclesByShop[veh.transportShopId][veh:getModel()][veh.transportShopVariant] - 1
	if isElement(veh) then
		local members = CompanyManager:getSingleton():getFromId(CompanyStaticId.EPT):getOnlinePlayers(true, true)
		triggerClientEvent(members, "destroyVehicleTransportDestinationBlips", resourceRoot, veh) -- send this with specific vehicle to all players to catch DFT driver
		if veh.controller then
			veh.controller:triggerEvent("destroyVehicleTransportDestinationBlips")
		end
		veh:destroy()
	end
	self.m_ActiveVehicles[veh] = nil
end

function VehicleImportManager:internalVehicleDeliveryColHit(col, dim)
	assert(self.m_ActiveVehicles[source], "bad argument @internalVehicleDeliveryColHit: vehicle is not an import vehicle")
	
	if col == source.destinationCol then
		if source.controller and isElement(source.controller) then
			source.controller:sendInfo("Steige aus dem Fahrzeug aus, um die Lieferung abzuschließen.")
		end
	end
end

function VehicleImportManager:internalOnVehicleEnter(player, seat)
	if seat ~= 0 then return end
	assert(self.m_ActiveVehicles[source], "bad argument @internalOnVehicleEnter: vehicle is not an import vehicle")
	assert(isElement(player) and getElementType(player) == "player", "bad argument @internalOnVehicleEnter: not a valid player")

	player:triggerEvent("createVehicleTransportDestinationBlips", {[source] = self.m_ActiveVehicles[source]}) --only trigger position of current vehicle
end

function VehicleImportManager:internalOnVehicleExit(player, seat)
	local veh = source
	if seat ~= 0 then return end
	assert(self.m_ActiveVehicles[veh], "bad argument @internalOnVehicleExit: vehicle is not an import vehicle")

	player:triggerEvent("destroyVehicleTransportDestinationBlips")
	if veh.destinationCol and isElement(veh.destinationCol) and isElementWithinColShape(veh, veh.destinationCol) then
		if veh:getVelocity().length > 0.001 then 
            player:sendWarning("Fahre langsamer um das Fahrzeug abzugeben.")
            return false 
		end
		if veh:getEngineState() then 
            player:sendWarning("Schalte den Motor aus um das Fahrzeug abzugeben.")
            return false 
		end
		local moneyTotal = veh.transportPayment * ((veh:getHealth()-900)/100)
		local moneyEarnedPlayer = math.round(veh.transportPayment * (VehicleImportManager.PaymentForDriverFactor))
		local moneyEarnedCompany = veh.transportPayment - moneyEarnedPlayer
		local eptInstance = CompanyManager:getSingleton():getFromId(CompanyStaticId.EPT)
		eptInstance:sendShortMessage(("%s hat das Fahrzeug '%s' abgeliefert."):format(getPlayerName(player), veh:getName()))
		eptInstance:addLog(player, "Import", ("hat das Fahrzeug '%s' abgeliefert (+%s)!"):format(veh:getName(), toMoneyString(moneyEarnedCompany)))
		self:increaseShopStockByVehicle(veh.transportShopId, veh:getModel(), veh.transportShopVariant)

		player:giveCombinedReward("Fahrzeug abgeliefert", {
			money = {
				mode = "give",
				bank = true,
				amount = moneyEarnedPlayer,
				toOrFrom = self.m_BankAccountServer,
				category = "Company",
				subcategory = "Vehicle Import"
			},
			points = 5,
		})
		self.m_BankAccountServer:transferMoney({eptInstance, true, true}, moneyEarnedCompany, "Fahrzeug abgeliefert", "Action", "Vehicle Import")
		self:internalDestroyVehicle(veh, true)
	end
end

function VehicleImportManager:internalOnVehicleDamage(vehicle, loss)
	if vehicle:getHealth()-loss >= 900 then return end
	
	local controller = vehicle.controller or  (vehicle:getAttachedTo() and vehicle:getAttachedTo().controller)
	if controller then
		controller:sendError(("Das Fahrzeug '%s' ist so kaputt, dass das Autohaus es nicht mehr annimmt!"):format(vehicle:getName()))
	end
	
	self:internalDestroyVehicle(vehicle)
	return true
end