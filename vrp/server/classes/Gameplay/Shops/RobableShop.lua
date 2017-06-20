-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/Gameplay/RobableShop.lua
-- * PURPOSE: Robable shop class
-- *
-- ****************************************************************************
RobableShop = inherit(Object)

addRemoteEvents{"robableShopGiveBagFromCrash"}

local ROBSHOP_TIME = 15*60*1000
local ROBSHOP_PAUSE = 30*60 --in Sec

function RobableShop:constructor(shop, pedPosition, pedRotation, pedSkin, interiorId, dimension)
	-- Create NPC(s)
	self.m_Shop = shop
	self.m_LastRob = 0
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
	if attacker:getGroup() then
		if attacker:getGroup():getType() == "Gang" then
			if not attacker:isFactionDuty() then
				if not timestampCoolDown(self.m_LastRob, ROBSHOP_PAUSE) then
					attacker:sendError(_("Der nächste Shop-Überfall ist am/um möglich: %s!", attacker, getOpticalTimestamp(self.m_LastRob+ROBSHOP_PAUSE)))
					return false
				end

				if FactionState:getSingleton():countPlayers() < SHOPROB_MIN_MEMBERS then
					attacker:sendError(_("Es müssen mindestens %d Staatsfraktionisten online sein!",attacker, SHOPROB_MIN_MEMBERS))
					return false
				end
				self.m_LastRob = getRealTime().timestamp
				local shop = ped.Shop
				self.m_Shop = shop
				if shop:getMoney() >= 250 then
					self:startRob(shop, attacker, ped)
				else
					attacker:sendError(_("Es ist nicht genug Geld zum ausrauben in der Shopkasse!", attacker))
				end
			else
				attacker:sendError(_("Du bist im Dienst, du darfst keinen Überfall machen!", attacker))
			end
		else
			attacker:sendError(_("Du bist Mitglied einer privaten Firma! Nur Gangs können überfallen!", attacker))
		end
	else
		attacker:sendError(_("Du bist kein Mitglied einer privaten Gang!", attacker))
	end
end

function RobableShop:startRob(shop, attacker, ped)
	shop.m_Marker.m_Disable = true
	setElementAlpha(shop.m_Marker,0)
	PlayerManager:getSingleton():breakingNews("%s meldet einen Überfall durch eine Straßengang!", shop:getName())
	local zone1, zone2 = getZoneName(shop.m_Position), getZoneName(shop.m_Position, true)
	if zone1 then
		FactionState:getSingleton():sendWarning("Die Alarmanlage von %s meldet einen Überfall\nPosition: %s/%s", "neuer Einsatz", true, shop:getName(), zone1, zone2)
	else
		FactionState:getSingleton():sendWarning("Die Alarmanlage von %s meldet einen Überfall", "neuer Einsatz", true, shop:getName())
	end
	shop.m_LastRob = getRealTime().timestamp

	-- Play an alarm
	local pos = ped:getPosition()
	triggerClientEvent("shopRobbed", attacker, pos.x, pos.y, pos.z, ped:getDimension())

	-- Report the crime
	--attacker:reportCrime(Crime.ShopRob)
	attacker:giveKarma(-5)
	attacker:giveWantedLevel(3)
	attacker:sendMessage("Verbrechen begangen: Shop-Überfall, 3 Wanteds", 255, 255, 0)

	self.m_Attacker = attacker

	self.m_Bag = createObject(1550, pos)
	self.m_Bag.Money = 0
	addEventHandler("onElementClicked", self.m_Bag, bind(self.onBagClick, self))

	self:giveBag(attacker)

	local evilPos = ROBABLE_SHOP_EVIL_TARGETS[math.random(1, #ROBABLE_SHOP_EVIL_TARGETS)]
	local statePos = ROBABLE_SHOP_STATE_TARGETS[math.random(1, #ROBABLE_SHOP_STATE_TARGETS)]

	self.m_Gang = attacker:getGroup()
	self.m_Gang:attachPlayerMarkers()
	self.m_EvilBlip = Blip:new("Waypoint.png", evilPos.x, evilPos.y, root, 2000)
	self.m_StateBlip = Blip:new("PoliceRob.png", statePos.x, statePos.y, root, 2000)
	self.m_EvilMarker = createMarker(evilPos, "cylinder", 2.5, 255, 0, 0, 100)
	self.m_StateMarker = createMarker(statePos, "cylinder", 2.5, 0, 255, 0, 100)
	self.m_onDeliveryMarkerHit = bind(self.onDeliveryMarkerHit, self)
	addEventHandler("onMarkerHit", self.m_EvilMarker, self.m_onDeliveryMarkerHit)
	addEventHandler("onMarkerHit", self.m_StateMarker, self.m_onDeliveryMarkerHit)
	self.m_onCrash = bind(self.onCrash, self)
	addEventHandler("robableShopGiveBagFromCrash", root, self.m_onCrash)
	self.m_characterInitializedFunc = bind(self.characterInitialized, self)
	addEventHandler("characterInitialized", root, self.m_characterInitializedFunc)

	StatisticsLogger:getSingleton():addActionLog("Shop-Rob", "start", attacker, self.m_Gang, "group")


	self.m_TargetTimer = setTimer(function()
		if isElement(attacker) then
			if attacker:getTarget() == ped then
				local rnd = math.random(5, 10)
				if shop:getMoney() >= rnd then
					shop:takeMoney(rnd, "Raub")
					self.m_Bag.Money = self.m_Bag.Money + rnd
					attacker:sendShortMessage(_("+%d$ - Tascheninhalt: %d$", attacker, rnd, self.m_Bag.Money))
				else
					if self.m_TargetTimer and isTimer(self.m_TargetTimer) then killTimer(self.m_TargetTimer) end
					attacker:sendInfo(_("Die Kasse ist nun leer! Du hast die maximale Beute!", attacker))
				end
			end
			return
		end
		if self.m_TargetTimer and isTimer(self.m_TargetTimer) then killTimer(self.m_TargetTimer) end
	end, 1000, 0)

	self.m_Func = bind(RobableShop.m_onExpire, self)
	self.m_ExpireTimer = setTimer(self.m_Func, ROBSHOP_TIME,1)

	attacker:triggerEvent("Countdown", ROBSHOP_TIME/1000, "Shop Überfall")

end

function RobableShop:m_onExpire()
	self.m_Shop.m_Marker.m_Disable = false
	setElementAlpha(self.m_Shop.m_Marker,255)
	if isElement( self.m_EvilMarker) then destroyElement(self.m_EvilMarker) end
	if isElement( self.m_StateMarker) then destroyElement(self.m_StateMarker) end
	for key, player in ipairs(getElementsByType("player")) do
		player:detachPlayerObject(self.m_Bag)
		removeEventHandler("onPlayerWasted", player, self.m_onWastedFunc)
		removeEventHandler("onPlayerDamage", player, self.m_onDamageFunc)
		removeEventHandler("onPlayerVehicleEnter", player, self.m_onVehicleEnterFunc)
		removeEventHandler("onPlayerVehicleExit", player, self.m_onVehicleExitFunc)
		removeEventHandler("onPlayerQuit", player, self.m_onPlayerQuitFunc)
	end

	local money = self.m_Bag.Money or 0
	local stateMoney = math.floor(money/3)
	FactionManager:getSingleton():getFromId(1):giveMoney(stateMoney, "Shop Raub Sicherstellung 1/3")
	self.m_Shop:giveMoney(stateMoney*2, "Shop Raub Sicherstellung 2/3")
	self.m_Bag:destroy()

	removeEventHandler("characterInitialized", root, self.m_characterInitializedFunc)

	delete(self.m_EvilBlip)
	delete(self.m_StateBlip)
	delete(self.m_BagBlip)
	if isTimer(self.m_TargetTimer) then killTimer(self.m_TargetTimer) end
	StatisticsLogger:getSingleton():addActionLog("Shop-Rob", "stop", nil, self.m_Gang, "group")

	self.m_Gang:removePlayerMarkers()
	removeEventHandler("robableShopGiveBagFromCrash", root, self.m_onCrash)
	self.m_Gang:sendMessage("[Shop-Rob] Die Zeit für den Rob ist ausgelaufen!",200,0,0,true)
	FactionManager:getSingleton():getFromId(1):sendMessage("[Shop-Rob] #EEEEEEDie Zeit für den Rob ist ausgelaufen!",200,200,0,true)

	if self.m_Attacker and isElement(self.m_Attacker) then
		self.m_Attacker:triggerEvent("CountdownStop", "Shop Überfall")
	end
end

function RobableShop:stopRob(player)
	if self.m_ExpireTimer and isTimer(self.m_ExpireTimer) then
		killTimer(self.m_ExpireTimer)
	end

	self.m_Shop.m_Marker.m_Disable = false
	setElementAlpha(self.m_Shop.m_Marker,255)
	if isElement( self.m_EvilMarker) then destroyElement(self.m_EvilMarker) end
	if isElement( self.m_StateMarker) then destroyElement(self.m_StateMarker) end

	player:detachPlayerObject(self.m_Bag)

	self.m_Bag:destroy()

	removeEventHandler("onPlayerWasted", player, self.m_onWastedFunc)
	removeEventHandler("onPlayerDamage", player, self.m_onDamageFunc)
	removeEventHandler("onPlayerVehicleEnter", player, self.m_onVehicleEnterFunc)
	removeEventHandler("onPlayerVehicleExit", player, self.m_onVehicleExitFunc)
	removeEventHandler("onPlayerQuit", player, self.m_onPlayerQuitFunc)
	removeEventHandler("characterInitialized", root, self.m_characterInitializedFunc)

	delete(self.m_EvilBlip)
	delete(self.m_StateBlip)
	delete(self.m_BagBlip)

	StatisticsLogger:getSingleton():addActionLog("Shop-Rob", "stop", nil, self.m_Gang, "group")

	self.m_Gang:removePlayerMarkers()
	removeEventHandler("robableShopGiveBagFromCrash", root, self.m_onCrash)

	if self.m_Attacker and isElement(self.m_Attacker) then
		self.m_Attacker:triggerEvent("CountdownStop", "Shop Überfall")
	end
end

function RobableShop:giveBag(player)
	self.m_Bag:setInterior(player:getInterior())
	self.m_Bag:setDimension(player:getDimension())
	player:attachPlayerObject(self.m_Bag, true)
	if self.m_BagBlip then delete(self.m_BagBlip) end
	self.m_BagBlip = Blip:new("MoneyBag.png", 0, 0)
	self.m_BagBlip:attach(self.m_Bag)

	self.m_onDamageFunc = bind(self.onDamage, self)
	self.m_onWastedFunc = bind(self.onWasted, self)
	self.m_onVehicleEnterFunc = bind(self.onVehicleEnter, self)
	self.m_onVehicleExitFunc = bind(self.onVehicleExit, self)
	self.m_onPlayerQuitFunc = bind(self.onPlayerQuit, self)

	addEventHandler("onPlayerDamage", player, self.m_onDamageFunc)
	addEventHandler("onPlayerWasted", player, self.m_onWastedFunc)
	addEventHandler("onPlayerVehicleEnter", player, self.m_onVehicleEnterFunc)
	addEventHandler("onPlayerVehicleExit", player, self.m_onVehicleExitFunc)
	addEventHandler("onPlayerQuit", player, self.m_onPlayerQuitFunc)

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
	removeEventHandler("onPlayerQuit", player, self.m_onPlayerQuitFunc)

	player:sendShortMessage(_("Du hast die Beute verloren!", player))
end

function RobableShop:checkBagAllowed(player)
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	if player:getGroup() == self.m_Gang or (player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty()) then
		return true
	end
	return false
end

function RobableShop:characterInitialized()
	if not self.m_Gang then
		return
	end
	if not source:getGroup() then
		return
	end
	if self.m_Gang.m_Id == source:getGroup().m_Id then
		Group:attachPlayerMarker(source)
	end
end

function RobableShop:onDamage(attacker, weapon)
	if not source.RobableShopDmgPause then
		if isElement(attacker) and self:checkBagAllowed(attacker) then
			if weapon == 0 then
				source.RobableShopDmgPause = true
				local source = source -- source in timer fix
				setTimer(function() source.RobableShopDmgPause = false end, 1500, 1)
				if source:getPlayerAttachedObject() and source:getPlayerAttachedObject() == self.m_Bag and self:checkBagAllowed(attacker) then
					self:removeBag(source)
					self:giveBag(attacker)
				else
					attacker:sendError(_("Du darfst die Beute nicht besitzen!", attacker))
				end
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

function RobableShop:onPlayerQuit()
	self:removeBag(source)
	self.m_Gang:removePlayerMarker(source)
end

function RobableShop:onCrash(player)
	if isElement(player) then
		if client:getPlayerAttachedObject() and client:getPlayerAttachedObject():getModel() == 1550 and self:checkBagAllowed(player) then
			if self:checkBagAllowed(player) then
				self:removeBag(client)
				self:giveBag(player)
			else
				player:sendError(_("Du darfst die Beute nicht besitzen!", player))
			end
		end
	end

end

function RobableShop:onDeliveryMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if hitElement:getPlayerAttachedObject() and hitElement:getPlayerAttachedObject() == self.m_Bag and self:checkBagAllowed(hitElement) then
			local money = self.m_Bag.Money
			if source == self.m_EvilMarker and hitElement:getGroup() == self.m_Gang then
				hitElement:giveMoney(money, "Shop-Raub")
				hitElement:sendInfo(_("Du hast durch den Raub %d$ erhalten!", hitElement, money))
				PlayerManager:getSingleton():breakingNews("%s Überfall: Die Täter sind mit der Beute entkommen!", self.m_Shop:getName())
			elseif source == self.m_StateMarker and hitElement:getFaction() and hitElement:getFaction():isStateFaction() and hitElement:isFactionDuty() then
				local stateMoney = math.floor(money/3)
				hitElement:giveMoney(stateMoney, "Shop Raub Sicherstellung 1/3")
				hitElement:getFaction():giveMoney(stateMoney, "Shop Raub Sicherstellung 1/3")
				self.m_Shop:giveMoney(stateMoney, "Shop Raub Sicherstellung 1/3")
				hitElement:sendInfo(_("Beute sichergestellt! Der Shop, du und die Staatskasse haben je %d$ erhalten!", hitElement, stateMoney))
				PlayerManager:getSingleton():breakingNews("Die Beute des %s Überfall wurde sichergestellt!", self.m_Shop:getName())
				FactionState:getSingleton():giveKarmaToOnlineMembers(5, "Shop Raub Beute sichergestellt!")
			else
				hitElement:sendError(_("Du darfst die Beute hier nicht abgeben!", hitElement))
				return
			end

			self.m_Bag.Money = 0
			self:stopRob(hitElement)
		else
			hitElement:sendError(_("Du darfst die Beute nicht besitzen!", hitElement))
		end
	end
end
