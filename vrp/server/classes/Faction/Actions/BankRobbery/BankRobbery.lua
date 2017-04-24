-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************
BankRobbery = inherit(Object)
--Info 68 Tresors
local MONEY_PER_SAFE_MIN = 500
local MONEY_PER_SAFE_MAX = 750
local MAX_MONEY_PER_BAG = 3000
local BANKROB_TIME = 60*1000*12


function BankRobbery:constructor()
	self.m_IsBankrobRunning = false
	self.m_RobPlayer = nil
	self.m_RobFaction = nil

end

function BankRobbery:spawnPed(skin, pos, rot)
	if isElement(self.m_Ped) then
		destroyElement(self.m_Ped)
	end
	self.m_Ped = ShopNPC:new(skin, pos, rot)
	self.m_Ped.onTargetted = bind(self.Ped_Targetted, self)

	addEventHandler("onPedWasted", self.m_Ped,
		function()
			setTimer(function() self:spawnPed() end, 5*60*1000, 1)
		end
	)
end

function BankRobbery:destructor()

end

function BankRobbery:destroyRob()
	BankManager:getSingleton():stopRob()

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

	if self.m_Blip then
		for index, blip in pairs(self.m_Blip) do delete(blip) end
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

	removeEventHandler("onColShapeHit", self.m_HelpColShape, self.m_ColFunc)
	removeEventHandler("onColShapeLeave", self.m_HelpColShape, self.m_HelpCol)

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

function BankRobbery:startRob(player)
	ActionsCheck:getSingleton():setAction("Banküberfall")
	local faction = player:getFaction()
	local pos = self.m_BankDoor:getPosition()
	self.m_RobPlayer = player
	self.m_RobFaction = faction
	self.m_IsBankrobRunning = true
	self.m_RobFaction:giveKarmaToOnlineMembers(-5, "Banküberfall gestartet!")

	StatisticsLogger:getSingleton():addActionLog("BankRobbery", "start", self.m_RobPlayer, self.m_RobFaction, "faction")

	faction:sendMessage(_("Euer Spieler %s startet einen Banküberfall! Der Truck wurde gespawnt!", player, player.name), 0, 255, 0)

	self.m_Timer = setTimer(bind(self.timeUp, self), BANKROB_TIME, 1)
	self.m_UpdateBreakingNewsTimer = setTimer(bind(self.updateBreakingNews, self), 20000, 0)

	for index, playeritem in pairs(faction:getOnlinePlayers()) do
		playeritem:triggerEvent("Countdown", math.floor(BANKROB_TIME/1000), "Bank-Überfall")
	end

	addRemoteEvents{"bankRobberyLoadBag", "bankRobberyDeloadBag"} --// TODO CONTINUE FIXING THIS PART


	addEventHandler("onVehicleStartEnter", self.m_Truck, bind(self.Event_OnTruckStartEnter, self))
end

function BankRobbery:Ped_Targetted(ped, attacker)
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
	PlayerManager:getSingleton():breakingNews("Der Banküberfall ist beendet! Die Täter haben sich zuviel Zeit gelassen!")
	self:destroyRob()
end

function BankRobbery:updateBreakingNews()
	local msg = ""
	local rnd = math.random(1,4)
	if rnd == 1 then
		msg =  _("Der Banküberfall ist immer noch im Gange!", self.m_RobPlayer)
	elseif rnd == 2 then
		if not self.m_BrNe_EvilPeople then self.m_BrNe_EvilPeople = 0 end
		local nowEvilPeople = self:countEvilPeople()
		if self.m_BrNe_EvilPeople > nowEvilPeople then
			msg = _("Den neuesten Informationen zufolge befinden sich nur noch %d Räuber am Gelände!", self.m_RobPlayer, nowEvilPeople)
			self.m_BrNe_EvilPeople = nowEvilPeople
		elseif self.m_BrNe_EvilPeople < nowEvilPeople then
			msg = _("Das SAPD geht nun von %d beteiligten Räubern aus!", self.m_RobPlayer, nowEvilPeople)
			self.m_BrNe_EvilPeople = nowEvilPeople
		elseif self.m_BrNe_EvilPeople == nowEvilPeople then
			msg = _("Die Lage an der Palomino Creek-Bank ist unverändert. %d Räuber befinden sich am Gelände!", self.m_RobPlayer, nowEvilPeople)
			self.m_BrNe_EvilPeople = nowEvilPeople
		end
	elseif rnd == 3 then
		if not self.m_BrNe_StatePeople then self.m_BrNe_StatePeople = 0 end
		local nowStatePeople = self:countStatePeople()
		if self.m_BrNe_StatePeople > nowStatePeople then
			msg = _("Das SAPD ist nur noch mit %d Beamten am Gelände!", self.m_RobPlayer, nowStatePeople)
			self.m_BrNe_StatePeople = nowStatePeople
		elseif self.m_BrNe_StatePeople < nowStatePeople then
			msg = _("Das SAPD hat zusätzliche Einheiten hinzugezogen. Es befinden sich %d Beamten vor Ort!", self.m_RobPlayer, nowStatePeople)
			self.m_BrNe_StatePeople = nowStatePeople
		elseif self.m_BrNe_StatePeople == nowStatePeople then
			msg = _("Die Lage an der Palomino-Creek Bank ist unverändert. %d Beamte befinden sich am Gelände!", self.m_RobPlayer, nowStatePeople)
			self.m_BrNe_StatePeople = nowStatePeople
		end
	elseif rnd == 4 then
		msg = _("Neuesten Informationen zur Folge handelt es sich bei den Tätern um Mitglieder der %s!", self.m_RobPlayer, self.m_RobFaction:getName())
	end
	PlayerManager:getSingleton():breakingNews(msg)
end

function BankRobbery:spawnGuards()
	self.m_GuardPed1 = GuardActor:new(Vector3(2315.25, 20.34, 26.53))
	self.m_GuardPed1:setRotation(270, 0, 270, "default", true)
	self.m_GuardPed1:setFrozen(true)
	self.m_GuardPed1.Colshape = createColCuboid(2314.4 ,1.15 ,25 ,2.5 ,21.45 , 4)
	addEventHandler("onColShapeHit", self.m_GuardPed1.Colshape, function(hitElement, dim)
		if dim and hitElement.type == "player" then
			if hitElement:getFaction() and hitElement:getFaction():isEvilFaction() then
				self.m_GuardPed1:startShooting(hitElement)
			end
		end

	end)
end

function BankRobbery:createSafes()
	self.m_Safes = {
		createObject(2332, 2305.5, 19.12012, 26.85, 0, 0, 90),
		createObject(2332, 2305.5, 18.29004, 26.85, 0, 0, 90),
		createObject(2332, 2305.5, 17.45898, 26.85, 0, 0, 90),
		createObject(2332, 2312.83984, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2312.0127, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2311.1836, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2310.3525, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2309.5215, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2308.6904, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2307.8604, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2307.0313, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2306.2002, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2305.5, 20.78027, 27.7085, 0, 0, 90),
		createObject(2332, 2305.5, 19.94922, 27.7085, 0, 0, 90),
		createObject(2332, 2305.5, 19.12012, 27.7085, 0, 0, 90),
		createObject(2332, 2305.5, 18.29004, 27.7085, 0, 0, 90),
		createObject(2332, 2305.5, 17.45898, 27.7085, 0, 0, 90),
		createObject(2332, 2310.3711, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2306.2002, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2309.5215, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2308.6904, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2307.8604, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2307.0313, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2306.2002, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2312.8398, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2312.0127, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2311.1836, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2307.0313, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2307.8604, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2308.6904, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2309.5215, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2310.3525, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2311.1836, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2312.0127, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2312.8398, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2306.2002, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2307.0313, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2307.8604, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2308.6904, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2309.5215, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2310.3525, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2311.1836, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2312.0127, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2312.8398, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2310.3525, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2311.1836, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2312.0127, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2312.8398, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2305.5, 20.78027, 26.85, 0, 0, 90),
		createObject(2332, 2306.2002, 21.5, 26, 0, 0, 0),
		createObject(2332, 2305.5, 20.78, 26, 0, 0, 90),
		createObject(2332, 2305.5, 19.94922, 26, 0, 0, 90),
		createObject(2332, 2305.5, 19.12, 26, 0, 0, 90),
		createObject(2332, 2305.5, 18.29004, 26, 0, 0, 90),
		createObject(2332, 2305.5, 17.45897, 26, 0, 0, 90),
		createObject(2332, 2305.5, 19.95, 26.85, 0, 0, 90),
		createObject(2332, 2307.0313, 21.5, 26, 0, 0, 0),
		createObject(2332, 2307.8601, 21.5, 26, 0, 0, 0),
		createObject(2332, 2308.6899, 21.5, 26, 0, 0, 0),
		createObject(2332, 2309.521, 21.5, 26, 0, 0, 0),
		createObject(2332, 2310.3525, 21.5, 26, 0, 0, 0),
		createObject(2332, 2311.1836, 21.5, 26, 0, 0, 0),
		createObject(2332, 2312.0127, 21.5, 26, 0, 0, 0),
		createObject(2332, 2312.8398, 21.5, 26, 0, 0, 0),
		createObject(2332, 2306.2002, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2307.0313, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2307.8604, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2308.6904, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2309.52, 21.5, 26.85, 0, 0, 0),
	}
	for index, safe in pairs(self.m_Safes) do
		safe:setData("clickable", true, true)
		addEventHandler( "onElementClicked", safe, self.m_OnSafeClickFunction)
	end
end

function BankRobbery:createBombableBricks()
	self.m_BombableBricks = {
		createObject(9131, 2317.334, 10.25, 28.87, 0, 0, 270),
		createObject(9131, 2317.334, 10.25, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 11, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 11, 28.87, 0, 0, 270),
		createObject(9131, 2317.334, 11.75, 28.87, 0, 0, 270),
		createObject(9131, 2317.334, 11.75, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 12.5, 28.87, 0, 0, 270),
		createObject(9131, 2317.334, 12.5, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 13.25, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 13.25, 28.87, 0, 0, 270),
		createObject(9131, 2317.334, 14, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 9.5, 26.6, 0, 0, 270),
	}
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
				local model = source:getModel()
				source:destroy()
				if model == 2332 then
					local obj = createObject(1829, position, rotation)
					addEventHandler( "onElementClicked", obj, self.m_OnSafeClickFunction)
					table.insert(self.m_Safes, obj)
					obj:setData("clickable", true, true)
				elseif model == 1829 then
					local obj = createObject(2003, position, rotation)
					local money = math.random(MONEY_PER_SAFE_MIN, MONEY_PER_SAFE_MAX)
					self:addMoneyToBag(player, money)
					table.insert(self.m_Safes, obj)
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
			player:sendError(_("Du bist zuweit von dem Geldsack entfernt!", player))
		end
	end
end

function BankRobbery:statePeopleClickBag(player, bag)
	local amount = math.floor(bag:getData("Money")/2)
	PlayerManager:getSingleton():breakingNews("Das SAPD hat einen Geldsack sichergestellt!")
	player:sendInfo(_("Geldsack sichergestellt, es wurden %d$ in die Staatskasse gelegt!", player, amount))
	FactionManager:getSingleton():getFromId(1):giveMoney(amount, "Bankrob-Geldsack")
	player:giveKarma(5)
	table.remove(self.m_MoneyBags, table.find(self.m_MoneyBags, bag))
	bag:destroy()
end

function BankRobbery:addMoneyToBag(player, money)
	for i, bag in pairs(self.m_MoneyBags) do
		if bag:getData("Money") + money < MAX_MONEY_PER_BAG then
			bag:setData("Money", bag:getData("Money") + money, true)
			player:sendShortMessage(_("%d$ in den Geldsack %d gepackt!", player, money, i))
			return
		end
	end
	local pos = self.ms_BagSpawns[#self.m_MoneyBags+1]
	local newBag = createObject(1550, pos)
	table.insert(self.m_MoneyBags, newBag)
	newBag:setData("Money", money, true)
	newBag:setData("MoneyBag", true, true)
	addEventHandler("onElementClicked", newBag, self.m_Event_onBagClickFunc)
	player:sendShortMessage(_("%d$ in eine Geldsack %d gepackt!", player, money, #self.m_MoneyBags))
	self.m_MoneyBagCount = #self.m_MoneyBags
end



function BankRobbery:Event_OnTruckStartEnter(player, seat)
	if seat == 0 and player:getFaction() ~= self.m_RobFaction then
		player:sendError(_("Den Bank-Überfall Truck können nur Fraktionisten fahren!", player))
		cancelEvent()
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
							hitElement:toggleControlsWhileObjectAttached(true)
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
							faction:giveMoney(totalAmount, "Bankraub")
						end

					end
					--outputChatBox(_("Es wurden %d$ in die Kasse gelegt!", hitElement, totalAmount), hitElement, 255, 255, 255)
					if self.m_SafeDoor.m_Open then
						if self:getRemainingBagAmount() == 0 then
							PlayerManager:getSingleton():breakingNews("Der Bankraub wurde erfolgreich abgeschlossen! Die Täter sind mit der Beute entkommen!")
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
