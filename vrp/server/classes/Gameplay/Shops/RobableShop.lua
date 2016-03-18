-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/RobableShop.lua
-- *  PURPOSE:     Robable shop class
-- *
-- ****************************************************************************
RobableShop = inherit(Object)

addRemoteEvents{"robableShopGiveBagFromCrash"}

function RobableShop:constructor(shop, pedPosition, pedRotation, pedSkin, interiorId, dimension)
	-- Create NPC(s)
	self:spawnPed(shop, pedPosition, pedRotation, pedSkin, interiorId, dimension)

	-- Respawn ped after a while (if necessary)
	addEventHandler("onPedWasted", self.m_Ped,
		function()
			setTimer(function() self:spawnPed(shop, pedPosition, pedRotation, pedSkin, interiorId, dimension) end, 5*60*1000, 1)
		end
	)


end

function RobableShop:spawnPed(shop, pedPosition, pedRotation, pedSkin, interiorId, dimension)
	if self.m_Ped and isElement(self.m_Ped) then
		self.m_Ped:destroy()
	end

	self.m_Ped = ShopNPC:new(pedSkin, pedPosition.x, pedPosition.y, pedPosition.z, pedRotation)
	self.m_Ped:setInterior(interiorId)
	self.m_Ped:setDimension(dimension)
	self.m_Ped.Shop = shop
	self.m_Ped.onTargetted = bind(self.Ped_Targetted, self)
end

function RobableShop:Ped_Targetted(ped, attacker)
	if attacker:getGroup() and attacker:getGroup():getType() == "Gang" then
		if not ActionsCheck:getSingleton():isActionAllowed(attacker) then
			return false
		end
		local shop = ped.Shop
		self.m_Shop = shop
		if shop:getMoney() >= 250 then
			self:startRob(shop, attacker, ped)
		else
			attacker:sendError("Es ist nicht genug Geld zum ausrauben in der Shopkasse!", attacker)
		end
	else
		attacker:sendError("Nur Mitglieder privater Gangs können Shops überfallen!", attacker)
	end
end

function RobableShop:startRob(shop, attacker, ped)
	PlayerManager:getSingleton():breakingNews("%s meldet einen Überfall durch eine Straßengang!", shop:getName())
	ActionsCheck:getSingleton():setAction("Shop-Überfall")

	-- Play an alarm
	local pos = ped:getPosition()
	triggerClientEvent("shopRobbed", attacker, pos.x, pos.y, pos.z, ped:getDimension())

	-- Report the crime
	attacker:reportCrime(Crime.ShopRob)

	self.m_Bag = createObject(1550, pos)
	self.m_Bag.Money = 0
	addEventHandler("onElementClicked", self.m_Bag, bind(self.onBagClick, self))

	self:giveBag(attacker)

	local evilPos = ROBABLE_SHOP_EVIL_TARGETS[math.random(1, #ROBABLE_SHOP_EVIL_TARGETS)]
	local statePos = ROBABLE_SHOP_STATE_TARGETS[math.random(1, #ROBABLE_SHOP_STATE_TARGETS)]

	self.m_Gang = attacker:getGroup()
	self.m_Gang:attachPlayerMarkers()
	self.m_EvilBlip = Blip:new("Waypoint.png", evilPos.x, evilPos.y)
	self.m_StateBlip = Blip:new("PoliceRob.png", statePos.x, statePos.y)
	self.m_EvilMarker = createMarker(evilPos, "cylinder", 2.5, 255, 0, 0, 100)
	self.m_StateMarker = createMarker(statePos, "cylinder", 2.5, 0, 255, 0, 100)
	self.m_onDeliveryMarkerHit = bind(self.onDeliveryMarkerHit, self)
	addEventHandler("onMarkerHit", self.m_EvilMarker, self.m_onDeliveryMarkerHit)
	addEventHandler("onMarkerHit", self.m_StateMarker, self.m_onDeliveryMarkerHit)
	self.m_onCrash = bind(self.onCrash, self)
	addEventHandler("robableShopGiveBagFromCrash", root, self.m_onCrash)

	setTimer(
		function()
			if isElement(attacker) then
				if attacker:getTarget() == ped then
					local rnd = math.random(5, 10)
					if shop:getMoney() >= rnd then
						--shop:takeMoney(rnd)
						self.m_Bag.Money = self.m_Bag.Money + rnd
						attacker:sendShortMessage(_("+%d$ - Tascheninhalt: %d$", attacker, rnd, self.m_Bag.Money))
					else
						killTimer(sourceTimer)
						attacker:sendInfo(_("Die Kasse ist nun leer! Du hast die maximale Beute!", attacker))
					end
				end
				return
			end
			killTimer(sourceTimer)
		end,
		1000,
		60
	)
end

function RobableShop:stopRob()
	ActionsCheck:getSingleton():endAction()
	self.m_EvilMarker:destroy()
	self.m_StateMarker:destroy()
	self.m_Bag:destroy()
	delete(self.m_EvilBlip)
	delete(self.m_StateBlip)
	delete(self.m_BagBlip)
	self.m_Gang:removePlayerMarkers()
	removeEventHandler("robableShopGiveBagFromCrash", root, self.m_onCrash)

end

function RobableShop:giveBag(player)
	self.m_Bag:setInterior(player:getInterior())
	self.m_Bag:setDimension(player:getDimension())
	player:attachPlayerObject(self.m_Bag, true)
	if isElement(self.m_BagBlip) then self.m_BagBlip:destroy() end
	self.m_BagBlip = Blip:new("MoneyBag.png", 0, 0)
	self.m_BagBlip:attach(self.m_Bag)

	self.m_onDamageFunc = bind(self.onDamage, self)
	self.m_onWastedFunc = bind(self.onWasted, self)
	self.m_onVehicleEnterFunc = bind(self.onVehicleEnter, self)
	self.m_onVehicleExitFunc = bind(self.onVehicleExit, self)

	addEventHandler("onPlayerDamage", player, self.m_onDamageFunc)
	addEventHandler("onPlayerWasted", player, self.m_onWastedFunc)
	addEventHandler("onPlayerVehicleEnter", player, self.m_onVehicleEnterFunc)
	addEventHandler("onPlayerVehicleExit", source, self.m_onVehicleExitFunc)

	player:sendShortMessage(_("Du hast die Beute erhalten!", player))

	if player:getOccupiedVehicle() then
		triggerClientEvent(player, "robableShopEnableVehicleCollision", player, player:getOccupiedVehicle())
	end

end

function RobableShop:onBagClick(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
			if self:checkBagAllowed(player) then
				self:giveBag(player)
			else
				player:sendError(_("Du darfst die Beute nicht besitzen!", player))
			end
		else
			player:sendError(_("Du bist zuweit von dem Geldsack entfernt!", player))
		end
	end
end

function RobableShop:removeBag(player)
	player:detachPlayerObject(self.m_Bag)

	removeEventHandler("onPlayerWasted", player, self.m_onWastedFunc)
	removeEventHandler("onPlayerDamage", player, self.m_onDamageFunc)
	removeEventHandler("onPlayerVehicleEnter", player, self.m_onVehicleEnterFunc)
	removeEventHandler("onPlayerVehicleExit", player, self.m_onVehicleExitFunc)

	player:sendShortMessage(_("Du hast die Beute verloren!", player))
end

function RobableShop:checkBagAllowed(player)
	if player:getGroup() == self.m_Gang or player:getFaction():isStateFaction() then
		return true
	end
	return false
end

function RobableShop:onDamage(attacker, weapon)
	if isElement(attacker) and self:checkBagAllowed(attacker) then
		if weapon == 0 then
			if source:getPlayerAttachedObject() and source:getPlayerAttachedObject() == self.m_Bag then
				self:removeBag(source)
				self:giveBag(attacker)
			end
		end
	end
end

function RobableShop:onWasted()
	local pos = source:getPosition()
	pos.z = pos.z+1.5
	self:removeBag(source)
	self.m_Bag:setPosition(pos)
	self.m_Bag:setCollisionsEnabled(true)
end

function RobableShop:onVehicleEnter(veh)
	triggerClientEvent(source, "robableShopEnableVehicleCollision", source, veh)
end

function RobableShop:onVehicleExit(veh)
	triggerClientEvent(source, "robableShopDisableVehicleCollision", source, veh)
end

function RobableShop:onCrash(player)
	if isElement(player) then
		if client:getPlayerAttachedObject() and client:getPlayerAttachedObject():getModel() == 1550 then
			if self:checkBagAllowed(player) then
				self:removeBag(client)
				self:giveBag(player)
			else
				player:sendError(_("Du darfst die Beute nicht besitzen!", player))
			end
		else
			outputChatBox("Spieler "..client:getName().." hat keine Beute")
		end
	else
		outputChatBox("No Player")
	end

end

function RobableShop:onDeliveryMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if hitElement:getPlayerAttachedObject() and hitElement:getPlayerAttachedObject() == self.m_Bag then
			local money =  self.m_Bag.Money
			if source == self.m_EvilMarker then
				hitElement:giveMoney(money)
				hitElement:sendInfo(_("Du hast durch den Raub %d$ erhalten!", hitElement, money))
				PlayerManager:getSingleton():breakingNews("%s Überfall: Die Täter sind mit der Beute entkommen!", self.m_Shop:getName())
			elseif source == self.m_StateMarker then
				local stateMoney = math.floor(money/3)
				hitElement:giveMoney(stateMoney)
				hitElement:getFaction():giveMoney(stateMoney)
				self.m_Shop:giveMoney(stateMoney)
				hitElement:sendInfo(_("Beute sichergestellt! Der Shop, du und die Staatskasse haben je %d$ erhalten!", hitElement, stateMoney))
				PlayerManager:getSingleton():breakingNews("Die Beute des %s Überfall wurde sichergestellt!", self.m_Shop:getName())
			end
			self.m_Bag.Money = 0
			self:stopRob()
		end
	end
end

function RobableShop.initalizeAll()
	--RobableShop:new(Vector3(2104.8, -1806.5, 13.5), Vector3(372, -133.5, 1001.5), 0, 90, 5, Vector3(374.76, -117.26, 1001.5), 155)

	local positions = {
		--model, x,   y,      z,       rotation, interior, dimension
		{202, -23.94, -57.77, 1003.55, 357.8, 6, 0},
		{201, -30.84, -30.71, 1003.56, 0.7, 4, 0},
		{73, 295.45, -40.80, 1001.52, 358.4, 1, 0},
		{179, 295.59, -82.85, 1001.52, 1.3, 4, 0},
		{179, 290.30, -104.49, 1001.52, 180.5, 6, 0},
		{179, 312.32, -167.76, 999.59, 0.1, 6, 0},
		{179, 316.12, -133.91, 999.60, 90.7, 7, 0},
		{240, 501.72, -20.50, 1000.68, 93.6, 17, 0},
		{195, 498.10, -77.82, 998.77, 359.2, 11, 0},
		{192, 208.72, -98.30, 1005.26, 180.6, 15, 0},
		{168, 681.60, -455.82, -25.61, 358.9, 1, 0},
		{194, 204.27, -157.83, 1000.52, 180.1, 16, 0},
		{177, 420.58, -79.16, 1001.80, 176.6, 3, 0},
		{176, -201.12, -5.91, 1002.27, 132.5, 17, 0},
		{11, 820.18, 1.87, 1004.18, 273.3, 3, 0},
		{257, -2655.59, 1408.84, 906.27, 266.6, 3, 0},
		{176, 413.75, -51.22, 1001.90, 177.6, 12, 0},
		{156, 414.59, -16.30, 1001.80, 175.3, 2, 0},
		{75, -104.82, -8.91, 1000.72, 180.7, 3, 0},
		{13, 203.67, -41.67, 1001.80, 183.5, 1, 0},
		{252, 1214.98, -15.26, 1000.92, 358.0, 2, 0},
		{22, 207.23, -127.46, 1003.51, 182.3, 3, 0},
		{193, 204.85, -8.55, 1001.21, 272.5, 5, 0},
		{191, 161.27, -80.78, 1001.80, 181.5, 18, 0},
	}

	--[[addCommandHandler("int",
		function(player, cmd, id)
			outputChatBox(id)
			local info = positions[tonumber(id)]
			local model, x, y, z, rotation, interior, dimension = unpack(info)

			local i = 1
			setTimer(function()
				player:setInterior(i, x, y, z)
				i = i + 1
				outputChatBox(i)
			end, 500, 20)
		end
	)

	for k, info in pairs(positions) do
		local model, x, y, z, rotation, interior, dimension = unpack(info)
		-- Temporary HACK: Create in 6 dimensions
		for i = 0, 5 do
			RobableShop:new(Vector3(x, y, z), rotation, model, interior, i)
		end
	end
	]]
end
