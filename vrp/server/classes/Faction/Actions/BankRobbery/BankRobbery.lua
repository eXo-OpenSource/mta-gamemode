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
	if isElement(self.m_StateDestinationMarker) then destroyElement(self.m_StateDestinationMarker) end
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
	for truck in pairs(self.m_Trucks) do
		if isElement(truck) then destroyElement(truck) end
	end
	if isElement(self.m_BackDoor) then destroyElement(self.m_BackDoor) end
	if isElement(self.m_HackMarker) then destroyElement(self.m_HackMarker) end
	if self.m_VehicleTeleporter then self.m_VehicleTeleporter:delete() self.m_VehicleTeleporter = nil end
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
	self.m_MoneyInSafes = 0

	killTimer(self.m_Timer)
	if isTimer(self.m_UpdateBreakingNewsTimer) then
	killTimer(self.m_UpdateBreakingNewsTimer)
	end

	local onlinePlayers = self:getEvilPeople()
	if onlinePlayers then
		for index, playeritem in pairs(onlinePlayers) do
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
	self.m_Blip = {}

	if self.m_HelpColShape then
		removeEventHandler("onColShapeHit", self.m_HelpColShape, self.m_HelpColFunc)
		removeEventHandler("onColShapeLeave", self.m_HelpColShape, self.m_HelpColFunc)
	end

	self.m_AlarmTriggered = false
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

function BankRobbery:startRobGeneral(player) --ped got targeted
	BankRobberyManager:getSingleton():startRob(self)
	ActionsCheck:getSingleton():setAction("Banküberfall")

	local faction = player:getFaction()
	local pos = self.m_BankDoor:getPosition()
	self.m_RobPlayer = player
	self.m_RobFaction = faction
	self.m_IsBankrobRunning = true
	self.m_MoneyInSafes = 0
	self.m_RobFaction:giveKarmaToOnlineMembers(-5, "Banküberfall gestartet!")
	self.m_CircuitBreakerPlayers = {}
	self.m_MoneyBags = {}
	self:setAllTrucksActive(true)

	StatisticsLogger:getSingleton():addActionLog("BankRobbery", "start", self.m_RobPlayer, self.m_RobFaction, "faction")

	--if we dont want to inform the cops just yet
	if not self.startAlarm then -- this is a function ;)
		self:loadDestinationsAndInformState()
		faction:sendShortMessage(_("%s hat einen Raubüberfall gestartet!", player, player.name))
		if faction:getAllianceFaction() then
			faction:getAllianceFaction():sendWarning(_("Euer Bündnispartner %s hat einen Raubüberfall gestartet! Schaut nach, wie ihr sie unterstützen könnt!", player, faction:getShortName()), "neue Aktion", true, self.m_MarkedPosition)
		end
	else --add a timer to stop the bank rob if the players didn't hack it in time
		self.m_Timer = setTimer(bind(self.timeUp, self), 5*60*1000, 1)
		for index, playeritem in pairs(self:getEvilPeople()) do
			playeritem:triggerEvent("Countdown", 5*60, "Hack-Zeitfenster")
		end
		faction:sendShortMessage(_("%s hat einen Raubüberfall gestartet! Ihr habt 5 Minuten Zeit, bevor das SAPD alarmiert wird!", player, player.name))
		if faction:getAllianceFaction() then
			faction:getAllianceFaction():sendWarning(_("Euer Bündnispartner %s hat einen Raubüberfall gestartet! Schaut nach, wie ihr sie unterstützen könnt!", player, faction:getShortName()), "neue Aktion", true, self.m_MarkedPosition)
		end
	end
end

function BankRobbery:loadDestinationsAndInformState()
	if not self.m_AlarmTriggered then
		for markerIndex, destination in pairs(self.ms_FinishMarker) do
			if #self.m_Blip <= self:getDifficulty() then
				self.m_Blip[#self.m_Blip+1] = Blip:new("Marker.png", destination.x, destination.y, self:getBlipVisibleTo(), 9999, BLIP_COLOR_CONSTANTS.Red)
				self.m_Blip[#self.m_Blip]:setDisplayText("Bankraub-Abgabe")
				self.m_Blip[#self.m_Blip]:setZ(destination.z)
				self.m_DestinationMarker[markerIndex] = createMarker(destination, "cylinder", 8, 200, 0, 0, 100)
				addEventHandler("onMarkerHit", self.m_DestinationMarker[markerIndex], bind(self.Event_onDestinationMarkerHit, self))
			end
		end
		--state finish
		self.m_Blip[#self.m_Blip+1] = Blip:new("Marker.png", self.ms_StateFinishMarker.x, self.ms_StateFinishMarker.y, self:getBlipVisibleTo(), 9999, BLIP_COLOR_CONSTANTS.Blue)
		self.m_Blip[#self.m_Blip]:setDisplayText("Bankraub-Sicherstellung")
		self.m_Blip[#self.m_Blip]:setZ(self.ms_StateFinishMarker.z)
		self.m_StateDestinationMarker = createMarker(self.ms_StateFinishMarker, "cylinder", 8, 0, 50, 200, 100)
		addEventHandler("onMarkerHit", self.m_StateDestinationMarker, bind(self.Event_onStateDestinationMarkerHit, self))
		
		if isTimer(self.m_Timer) then killTimer(self.m_Timer) end
		self.m_Timer = setTimer(bind(self.timeUp, self), self.ms_BankRobGeneralTime, 1)
		for index, playeritem in pairs(self:getEvilPeople()) do
			playeritem:triggerEvent("CountdownStop", "Hack-Zeitfenster")
			playeritem:triggerEvent("Countdown", math.floor(self.ms_BankRobGeneralTime/1000), "Bank-Überfall")
		end
		self.m_UpdateBreakingNewsTimer = setTimer(bind(self.updateBreakingNews, self), 20000, 0)
		FactionState:getSingleton():sendMoveRequest(TSConnect.Channel.STATE)
		if self.startAlarm then self:startAlarm() end
		self.m_AlarmTriggered = true
	end
end

function BankRobbery:Ped_Targetted(ped, attacker)
	if not attacker then return end
	local faction = attacker:getFaction()
	if faction and faction:isEvilFaction() then
		if not ActionsCheck:getSingleton():isActionAllowed(attacker) then
			return false
		end
		if FactionState:getSingleton():countPlayers() < self.ms_MinBankrobStateMembers then
			attacker:sendError(_("Es müssen mindestens %d Staatsfraktionisten online sein!",attacker, self.ms_MinBankrobStateMembers))
			return false
		end
		if self:getDifficulty() < 1 then
			attacker:sendError(_("Es ist noch nicht genug Geld in den Tresoren!",attacker))
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
	local type = self.m_Name == "Casino" and "am Casino" or "an der Bank"
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
			msg = ("Die Lage %s ist unverändert. %d Räuber befinden sich am Gelände!"):format(type, nowEvilPeople)
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
			msg = ("Die Lage %s ist unverändert. %d Beamte befinden sich am Gelände!"):format(type, nowStatePeople)
			self.m_BrNe_StatePeople = nowStatePeople
		end
	elseif rnd == 4 then
		msg = ("Neuesten Informationen zur Folge handelt es sich bei den Tätern um Mitglieder der %s!"):format(self.m_RobFaction:getName())
	end
	PlayerManager:getSingleton():breakingNews(msg)
end

function BankRobbery:getEvilPeople()
	if not self.m_RobFaction:getAllianceFaction() then
		return self.m_RobFaction:getOnlinePlayers()
	else
		return table.append(table.copy(self.m_RobFaction:getOnlinePlayers()), self.m_RobFaction:getAllianceFaction():getOnlinePlayers())
	end
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

function BankRobbery:isPlayerParticipant(player)
	if not player or not isElement(player) then return false end
	if not player:getFaction() then return false end
	if player:getFaction() == self.m_RobFaction then return true end
	if player:getFaction() == self.m_RobFaction:getAllianceFaction() then return true end
	if player:getFaction():isStateFaction() and player:isFactionDuty() then return true end
	return false
end

function BankRobbery:getBlipVisibleTo()
	if self.m_RobFaction:getAllianceFaction() then
		return {faction = {self.m_RobFaction:getId(), self.m_RobFaction:getAllianceFaction():getId()}, factionType = "State"}
	else
		return {faction = self.m_RobFaction:getId(), factionType = "State"}
	end
end

function BankRobbery:getMoneyForNewSafe()
	local moneyLeft = self.m_CurrentMoney - self.m_MoneyInSafes
	local newMoney = math.random(math.min(MONEY_PER_SAFE_MIN, moneyLeft), math.min(MONEY_PER_SAFE_MAX, moneyLeft)) 
	self.m_MoneyInSafes = self.m_MoneyInSafes + newMoney
	return newMoney
end

function BankRobbery:Event_onSafeClicked(button, state, player)
	if button == "left" and state == "down" then
		if self:isPlayerParticipant(player) and player:getFaction():isEvilFaction() then
			if self.m_IsBankrobRunning then
				local position = source:getPosition()
				local rotation = source:getRotation()
				local interior = source:getInterior()
				local model = source:getModel()
				if model == 2332 then
					local newMoney = self:getMoneyForNewSafe()
					if newMoney == 0 then
						source:setModel(2003)
					else
						source:setModel(1829)
						source.m_Money = newMoney
						source:setPosition(source.position - source.matrix.forward *0.4)
					end
				elseif model == 1829 then
					if self:addMoneyToBag(player, source.m_Money) then
						source:setModel(2003)
						source:setPosition(source.position + source.matrix.forward *0.4)
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
			if self:isPlayerParticipant(player) then
				player:attachPlayerObject(source)
			else
				player:sendError(_("Du bist nicht an diesem Raub beteiligt!", player))
			end
		else
			player:sendError(_("Du bist zu weit von dem Geldsack entfernt!", player))
		end
	end
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
	truck:initObjectLoading()
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
			self:setTruckActive(i, active)
		end
	end
end


function BankRobbery:Event_OnTruckStartEnter(player, seat)
	if seat == 0 and not self:isPlayerParticipant(player) then
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
				if faction:isEvilFaction() and self:isPlayerParticipant(hitElement) then
					self:handleBagDelivery(faction, hitElement)
				end
			end
		end
	end
end

function BankRobbery:Event_onStateDestinationMarkerHit(hitElement, matchingDimension)
	if isElement(hitElement) and matchingDimension then
		if hitElement.type == "player" then
			local faction = hitElement:getFaction()
			if faction then
				if faction:isStateFaction() and self:isPlayerParticipant(hitElement) then
					self:handleBagDelivery(faction, hitElement)
				end
			end
		end
	end
end

function BankRobbery:handleBagDelivery(faction, player)
	local bag = player:getPlayerAttachedObject()
	if not bag then return end
	local money = bag:getData("Money")
	if bag:getModel() == 1550 and money and money > 0 then
		self.m_BankAccountServer:transferMoney({"faction", faction:getId(), true}, money, "Bankrob-Geldsack", "Action", "BankRobbery", {silent = true})
		if faction:isStateFaction() then
			FactionState:getSingleton():sendShortMessage(_("%s hat %s Beute sichergestellt!", player, player:getName(), toMoneyString(money)))
		else
			local text = _("%s hat %s in Sicherheit gebracht!", player, player:getName(), toMoneyString(money))
			faction:sendShortMessage(text)
			if faction:getAllianceFaction() then
				faction:getAllianceFaction():sendShortMessage(text)
			end
		end
		bag:destroy()
		table.removevalue(self.m_MoneyBags, bag)
	end

	if self.m_SafeDoor.m_Open then
		if self:getRemainingBagAmount() == 0 then
			local text = ("Der Raub wurde erfolgreich abgeschlossen! %s"):format(faction:isStateFaction() and "Das Geld konnte sichergestellt werden!" or "Die Täter sind mit der Beute entkommen!")

			PlayerManager:getSingleton():breakingNews(text)
			Discord:getSingleton():outputBreakingNews(text)
			--self.m_RobFaction:giveKarmaToOnlineMembers(-10, "Banküberfall erfolgreich!")
			source:destroy()
			self:destroyRob()
		end
	end
end