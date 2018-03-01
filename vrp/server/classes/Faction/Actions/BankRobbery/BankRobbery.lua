-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************
BankRobbery = inherit(Object)
--Info 68 Tresors
local MONEY_PER_SAFE_MIN = 1000
local MONEY_PER_SAFE_MAX = 2000
local BANKROB_TIME = 60*1000*12

function BankRobbery:constructor()
	self.m_IsBankrobRunning = false
	self.m_RobPlayer = nil
	self.m_RobFaction = nil
	self.m_Trucks = {}
	self.m_Blip = {}
	self.m_DestinationMarker = {}
	self.m_MoneyBags = {}
	self.m_BankAccountServer = BankServer.get("action.bank_robbery")

	self.m_OnSafeClickFunction = bind(BankRobbery.Event_onSafeClicked, self)
	self.m_Event_onBagClickFunc = bind(BankRobbery.Event_onBagClick, self)
	self.m_Event_OnTruckStartEnterFunc = bind(BankRobbery.Event_OnTruckStartEnter, self)
end

function BankRobbery:virtual_constructor(...)
    BankRobbery.constructor(self, ...)
end

function BankRobbery:spawnPed(skin, pos, rot)
	if isElement(self.m_Ped) then
		destroyElement(self.m_Ped)
	end
	self.m_Ped = ShopNPC:new(skin, pos.x, pos.y, pos.z, rot)
	self.m_Ped.onTargetted = bind(self.Ped_Targetted, self)
	self.m_Ped:setData("NPC:Immortal",true)
	addEventHandler("onPedWasted", self.m_Ped,
		function()
			setTimer(function() self:spawnPed(skin, pos, rot) end, 30*60*1000, 1)
		end
	)
end

function BankRobbery:destructor()

end

function BankRobbery:destroyRob()
	BankRobberyManager:getSingleton():stopRob()

	local tooLatePlayers = getElementsWithinColShape(self.m_SecurityRoomShape, "player")
	if tooLatePlayers then
		for key, player in pairs( tooLatePlayers) do
			killPed(player)
			player:sendInfo("Du bist im abgeschlossenen Raum verendet!")
		end
	end
	triggerClientEvent("bankAlarmStop", root)
	if self.m_DestinationMarker then
		for index, marker in pairs(self.m_DestinationMarker) do
			if isElement(marker) then destroyElement(marker) end
		end
	end
	if self.m_Safes then
		for index, safe in pairs(self.m_Safes) do if isElement(safe) then destroyElement(safe) end	end
	end
	if self.m_BombableBricks then
		for index, brick in pairs(self.m_BombableBricks) do	if isElement(brick) then destroyElement(brick) end end
	end
	if self.m_MoneyBags then
		for index, bag in pairs(self.m_MoneyBags) do	if isElement(bag) then destroyElement(bag) end end
	end

	if isElement(self.m_BankDoor) then destroyElement(self.m_BankDoor) end
	if isElement(self.m_SafeDoor) then destroyElement(self.m_SafeDoor) end
	if isElement(self.m_ColShape) then destroyElement(self.m_ColShape) end
	if isElement(self.m_Ped) then destroyElement(self.m_Ped) end
	if isElement(self.m_Truck) then destroyElement(self.m_Truck) end
	if isElement(self.m_BackDoor) then destroyElement(self.m_BackDoor) end
	if isElement(self.m_HackMarker) then destroyElement(self.m_HackMarker) end
	if isElement(self.m_SecurityRoomShape) then destroyElement( self.m_SecurityRoomShape) end
	self.m_HackableComputer:setData("clickable", false, true)
	self.m_HackableComputer:setData("bankPC", false, true)
	if isElement(self.m_HackableComputer) then destroyElement(self.m_HackableComputer) end
	if self.m_GuardPed1 then destroyElement( self.m_GuardPed1 ) end

	if self.m_SafeGate then
		for index, object in pairs(self.m_SafeGate) do
			object:destroy()
		end
	end

	killTimer(self.m_Timer)
	killTimer(self.m_UpdateBreakingNewsTimer)

	local onlinePlayers = self.m_RobFaction:getOnlinePlayers()
	if onlinePlayers then
		for index, playeritem in pairs(self.m_RobFaction:getOnlinePlayers()) do
			playeritem:triggerEvent("CountdownStop", "Bank-Überfall")
			playeritem:triggerEvent("forceCircuitBreakerClose")
		end
	end
	if self.m_CircuitBreakerPlayers then
		for player, bool in pairs(self.m_CircuitBreakerPlayers) do
			if isElement(player) then
				player:triggerEvent("forceCircuitBreakerClose")
				self.m_CircuitBreakerPlayers[player] = nil
				player.m_InCircuitBreak = false
			end
		end
	end

	if self.m_Blip then
		for index, blip in pairs(self.m_Blip) do delete(blip) end
	end

	removeEventHandler("onColShapeHit", self.m_HelpColShape, self.m_HelpColFunc)
	removeEventHandler("onColShapeLeave", self.m_HelpColShape, self.m_HelpColFunc)

	ActionsCheck:getSingleton():endAction()
	StatisticsLogger:getSingleton():addActionLog("BankRobbery", "stop", self.m_RobPlayer, self.m_RobFaction, "faction")
	self:build()
end

function BankRobbery:onHelpColHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		if hitElement:getFaction() then
			hitElement:triggerEvent("setManualHelpBarText", "HelpTextTitles.Actions.Bankrob", "HelpTexts.Actions.Bankrob", true)
		end
	end
end

function BankRobbery:onHelpColLeave(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		hitElement:triggerEvent("resetManualHelpBarText")
	end
end

function BankRobbery:startRobGeneral(player)
	BankRobberyManager:getSingleton():startRob(self)
	ActionsCheck:getSingleton():setAction("Banküberfall")

	local faction = player:getFaction()
	local pos = self.m_BankDoor:getPosition()
	self.m_RobPlayer = player
	self.m_RobFaction = faction
	self.m_IsBankrobRunning = true
	self.m_RobFaction:giveKarmaToOnlineMembers(-5, "Banküberfall gestartet!")
	self.m_CircuitBreakerPlayers = {}
	self.m_MoneyBags = {}

	StatisticsLogger:getSingleton():addActionLog("BankRobbery", "start", self.m_RobPlayer, self.m_RobFaction, "faction")

	faction:sendMessage(_("Euer Spieler %s startet einen Banküberfall! Der Truck wurde gespawnt!", player, player.name), 0, 255, 0)
	FactionState:getSingleton():sendMoveRequest(TSConnect.Channel.STATE)

	self.m_Timer = setTimer(bind(self.timeUp, self), BANKROB_TIME, 1)
	self.m_UpdateBreakingNewsTimer = setTimer(bind(self.updateBreakingNews, self), 20000, 0)

	for index, playeritem in pairs(faction:getOnlinePlayers()) do
		playeritem:triggerEvent("Countdown", math.floor(BANKROB_TIME/1000), "Bank-Überfall")
	end

	for markerIndex, destination in pairs(self.ms_FinishMarker) do
		self.m_Blip[#self.m_Blip+1] = Blip:new("Marker.png", destination.x, destination.y, {faction = self.m_RobFaction:getId(), factionType = "State"}, 1000, BLIP_COLOR_CONSTANTS.Red)
		self.m_Blip[#self.m_Blip]:setDisplayText("Bankraub-Abgabe")
		self.m_Blip[#self.m_Blip]:setZ(destination.z)
		self.m_DestinationMarker[markerIndex] = createMarker(destination, "cylinder", 8)
		addEventHandler("onMarkerHit", self.m_DestinationMarker[markerIndex], bind(self.Event_onDestinationMarkerHit, self))
	end
end

function BankRobbery:Ped_Targetted(ped, attacker)
	if not attacker then return end
	local faction = attacker:getFaction()
	if faction and faction:isEvilFaction() then
		if not ActionsCheck:getSingleton():isActionAllowed(attacker) then
			return false
		end
		if FactionState:getSingleton():countPlayers() < BANKROB_MIN_MEMBERS then
			attacker:sendError(_("Es müssen mindestens %d Staatsfraktionisten online sein!",attacker, BANKROB_MIN_MEMBERS))
			return false
		end
		self:startRob(attacker)
		outputChatBox(_("Bankangestellter sagt: Hilfe! Ich öffne Ihnen die Tür zum Tresorraum!", attacker), attacker, 255, 255, 255)
		outputChatBox(_("Bankangestellter sagt: Bitte tun sie mir nichts!", attacker), attacker, 255, 255, 255)
	else
		attacker:sendError(_("Nur Mitglieder einer bösen Fraktion können die Bank ausrauben!", attacker))
	end
end

function BankRobbery:timeUp()
	FactionState:getSingleton():giveKarmaToOnlineMembers(10, "Banküberfall verhindert!")
	PlayerManager:getSingleton():breakingNews("Der Banküberfall ist beendet! Die Täter haben sich zu viel Zeit gelassen!")
	Discord:getSingleton():outputBreakingNews("Der Banküberfall ist beendet! Die Täter haben sich zu viel Zeit gelassen!")
	self:destroyRob()
end

function BankRobbery:updateBreakingNews()
	local msg = ""
	local rnd = math.random(1,4)
	if rnd == 1 then
		msg =  "Der Banküberfall ist immer noch im Gange!"
	elseif rnd == 2 then
		if not self.m_BrNe_EvilPeople then self.m_BrNe_EvilPeople = 0 end
		local nowEvilPeople = self:countEvilPeople()
		if self.m_BrNe_EvilPeople > nowEvilPeople then
			msg = ("Den neuesten Informationen zufolge befinden sich nur noch %d Räuber am Gelände!"):format(nowEvilPeople)
			self.m_BrNe_EvilPeople = nowEvilPeople
		elseif self.m_BrNe_EvilPeople < nowEvilPeople then
			msg = ("Das SAPD geht nun von %d beteiligten Räubern aus!"):format(nowEvilPeople)
			self.m_BrNe_EvilPeople = nowEvilPeople
		elseif self.m_BrNe_EvilPeople == nowEvilPeople then
			msg = ("Die Lage an der Bank ist unverändert. %d Räuber befinden sich am Gelände!"):format(nowEvilPeople)
			self.m_BrNe_EvilPeople = nowEvilPeople
		end
	elseif rnd == 3 then
		if not self.m_BrNe_StatePeople then self.m_BrNe_StatePeople = 0 end
		local nowStatePeople = self:countStatePeople()
		if self.m_BrNe_StatePeople > nowStatePeople then
			msg = ("Das SAPD ist nur noch mit %d Beamten am Gelände!"):format(nowStatePeople)
			self.m_BrNe_StatePeople = nowStatePeople
		elseif self.m_BrNe_StatePeople < nowStatePeople then
			msg = ("Das SAPD hat zusätzliche Einheiten hinzugezogen. Es befinden sich %d Beamten vor Ort!"):format(nowStatePeople)
			self.m_BrNe_StatePeople = nowStatePeople
		elseif self.m_BrNe_StatePeople == nowStatePeople then
			msg = ("Die Lage an der Bank ist unverändert. %d Beamte befinden sich am Gelände!"):format(nowStatePeople)
			self.m_BrNe_StatePeople = nowStatePeople
		end
	elseif rnd == 4 then
		msg = ("Neuesten Informationen zur Folge handelt es sich bei den Tätern um Mitglieder der %s!"):format(self.m_RobFaction:getName())
	end
	PlayerManager:getSingleton():breakingNews(msg)
end

function BankRobbery:countEvilPeople()
	local amount = 0
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		if player:getFaction() and player:getFaction():isEvilFaction() then
			amount = amount + 1
		end
	end
	return amount
end

function BankRobbery:countStatePeople()
	local amount = 0
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		if player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
			amount = amount + 1
		end
	end
	return amount
end

function BankRobbery:Event_onSafeClicked(button, state, player)
	if button == "left" and state == "down" then
		if player:getFaction() and player:getFaction():isEvilFaction() then
			if self.m_IsBankrobRunning then
				local position = source:getPosition()
				local rotation = source:getRotation()
				local interior = source:getInterior()
				local model = source:getModel()
				if model == 2332 then
					source:setModel(1829)
				elseif model == 1829 then	
					local money = math.random(MONEY_PER_SAFE_MIN, MONEY_PER_SAFE_MAX)
					if self:addMoneyToBag(player, money) then
						source:destroy()
						local obj = createObject(2003, position, rotation)
						obj:setInterior(interior)
						table.insert(self.m_Safes, obj)
					end
				end
			else
				player:sendError(_("Derzeit läuft kein Bankraub!", player))
			end
		end
	end
end

function BankRobbery:Event_onBagClick(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
			if player:getFaction() then
				if player:getFaction():isStateFaction() and player:isFactionDuty() then
					self:statePeopleClickBag(player, source)
				elseif player:getFaction():isEvilFaction() then
					player:attachPlayerObject(source)
				end
			else
				player:sendError(_("Nur Fraktionisten können den Geldsack aufheben!", player))
			end
		else
			player:sendError(_("Du bist zu weit von dem Geldsack entfernt!", player))
		end
	end
end

function BankRobbery:isPlayerParticipant(player)
	if not player or not isElement(player) then return false end
	if not player:getFaction() then return false end
	if player:getFaction() == self.m_RobFaction then return true end
	if player:getFaction() == self.m_RobFaction:getAllianceFaction() then return true end
	if player:getFaction():isStateFaction() and player:isFactionDuty() then return true end
	return false
end

function BankRobbery:statePeopleClickBag(player, bag)
	local amount = math.floor(bag:getData("Money")/2)
	PlayerManager:getSingleton():breakingNews("Das SAPD hat einen Geldsack sichergestellt!")
	player:sendInfo(_("Geldsack sichergestellt, es wurden %d$ in die Staatskasse gelegt!", player, amount))
	self.m_BankAccountServer:transferMoney(FactionManager:getSingleton():getFromId(1), amount, "Bankrob-Geldsack", "Action", "BankRobbery")
	player:giveKarma(5)
	table.remove(self.m_MoneyBags, table.find(self.m_MoneyBags, bag))
	bag:destroy()
end

function BankRobbery:addMoneyToBag(player, money)
	for i, bag in pairs(self.m_MoneyBags) do
		if bag:getData("Money") + money < self.ms_MoneyPerBag then
			bag:setData("Money", bag:getData("Money") + money, true)
			player:sendShortMessage(_("%d$ in den Geldsack %d gepackt!", player, money, i))
			return true
		end
	end
	if not self.ms_BagSpawns[#self.m_MoneyBags+1] then
		player:sendError(_("Ihr habt bereits die maximale Anzahl an Geldsäcken!", player))
		return false
	end
	local pos = self.ms_BagSpawns[#self.m_MoneyBags+1]
	local newBag = createObject(1550, pos)
	if self.ms_BagSpawnInterior then
		newBag:setInterior(self.ms_BagSpawnInterior)
	end
	newBag.DeloadHook = bind(self.deloadBag, self)
	table.insert(self.m_MoneyBags, newBag)
	newBag:setData("Money", money, true)
	newBag:setData("MoneyBag", true, true)
	addEventHandler("onElementClicked", newBag, self.m_Event_onBagClickFunc)
	player:sendShortMessage(_("%d$ in den Geldsack %d gepackt!", player, money, #self.m_MoneyBags))
	self.m_MoneyBagCount = #self.m_MoneyBags
	return true
end

function BankRobbery:createTruck(x, y, z, rz)
	local truck = TemporaryVehicle.create(428, x, y, z, rz)
	truck:setData("BankRobberyTruck", true, true)
	truck:toggleRespawn(false)
	truck:setMaxHealth(3000, true)
	truck:setBulletArmorLevel(2)
	truck:setRepairAllowed(false)
	truck:setVariant(0,0)
	truck:setAlwaysDamageable(true)
	self:setTruckActive(truck, false)
	self.m_Trucks[truck] = true
	addEventHandler("onVehicleStartEnter", truck, self.m_Event_OnTruckStartEnterFunc)
	addEventHandler("onElementDestroy", truck, function()
		if self.m_Trucks[truck] then
			self.m_Trucks[truck] = nil
			outputDebug(truck, "got destroyed")
		end
	end)
	return truck
end

function BankRobbery:setTruckActive(truck, active)
	if isElement(truck) then
		truck:setDamageProof(not active)
		truck:setLocked(not active)
		truck:setFrozen(not active)
	end
end

function BankRobbery:setAllTrucksActive(active)
	if active then
		for i,v in pairs(self.m_Trucks) do
			self:setTruckActive(v, active)
		end
	end
end


function BankRobbery:Event_OnTruckStartEnter(player, seat)
	if seat == 0 and player:getFaction() then
		player:sendError(_("Den Bank-Überfall Truck können nur Fraktionisten fahren!", player))
		cancelEvent()
	end
end

function BankRobbery:deloadBag(player, veh, bag)
	if player:getFaction():isStateFaction() and player:isFactionDuty() then
		player:detachPlayerObject(player:getPlayerAttachedObject())
		self:statePeopleClickBag(player, object)
	end
end

function BankRobbery:getRemainingBagAmount()
	local count = 0
	for i, k in pairs(self.m_MoneyBags) do
		if isElement(k) then
			count = count +1
		end
	end
	return count
end

function BankRobbery:Event_onDestinationMarkerHit(hitElement, matchingDimension)
	if isElement(hitElement) and matchingDimension then
		if hitElement.type == "player" then
			local faction = hitElement:getFaction()
			if faction then
				if faction:isEvilFaction() then
					local bags, amount = {}, 0
					local totalAmount = 0
					if hitElement:getPlayerAttachedObject() or hitElement.vehicle then

						if hitElement.vehicle and hitElement.vehicle == self.m_Truck then
							bags = getAttachedElements(self.m_Truck)
							hitElement:sendInfo(_("Du hast den Bank-Überfall Truck erfolgreich abgegeben! Das Geld ist nun in eurer Kasse!", hitElement))
						elseif hitElement:getPlayerAttachedObject() then
							bags = {hitElement:getPlayerAttachedObject()}
							hitElement:sendInfo(_("Du hast erfolgreich einen Geldsack abgegeben! Das Geld ist nun in eurer Kasse!", hitElement))
							hitElement:detachPlayerObject(hitElement:getPlayerAttachedObject())
						end
						for key, value in pairs (bags) do
							if value and isElement(value) and value:getModel() == 1550 then
								amount = value:getData("Money")
								totalAmount = totalAmount + amount
								value:destroy()
							end
						end

						if totalAmount > 0 then
							self.m_BankAccountServer:transferMoney(faction, totalAmount, "Bankrob-Geldsack", "Action", "BankRobbery")
						end

					end
					--outputChatBox(_("Es wurden %d$ in die Kasse gelegt!", hitElement, totalAmount), hitElement, 255, 255, 255)
					if self.m_SafeDoor.m_Open then
						if self:getRemainingBagAmount() == 0 then
							PlayerManager:getSingleton():breakingNews("Der Bankraub wurde erfolgreich abgeschlossen! Die Täter sind mit der Beute entkommen!")
							Discord:getSingleton():outputBreakingNews("Der Bankraub wurde erfolgreich abgeschlossen! Die Täter sind mit der Beute entkommen!")
							self.m_RobFaction:giveKarmaToOnlineMembers(-10, "Banküberfall erfolgreich!")
							source:destroy()
							self:destroyRob()
						end
					end
				end
			end
		end
	end
end
