-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionState.lua
-- *  PURPOSE:     Faction State Class
-- *
-- ****************************************************************************

FactionState = inherit(Singleton)
  -- implement by children

function FactionState:constructor()
	self:createArrestZone(1564.92, -1693.55, 5.89) -- PD Garage
	self:createArrestZone(255.19, 84.75, 1002.45, 6)-- PD Zellen
	self:createArrestZone(163.05, 1904.10, 18.67) -- Area

	self.m_Items = {
		["Barrikade"] = 0,
		["Nagel-Band"] = 0,
		["Blitzer"] = 0
	}

	nextframe( -- Todo workaround
		function ()
			self:loadLSPD(1)
			self:loadFBI(2)
			self:loadArmy(3)
		end
	)

	addRemoteEvents{"factionStateArrestPlayer","factionStateChangeSkin", "factionStateRearm", "factionStateSwat","factionStateToggleDuty", "factionStateGiveWanteds", "factionStateClearWanteds",
	"factionStateGrabPlayer", "factionStateFriskPlayer", "factionStateShowLicenses", "factionStateTakeDrugs", "factionStateTakeWeapons", "factionStateAcceptShowLicense", "factionStateDeclineShowLicense",
	"factionStateGivePANote", "factionStatePutItemInVehicle", "factionStateTakeItemFromVehicle", "factionStateLoadJailPlayers", "factionStateFreePlayer"}

	addCommandHandler("suspect",bind(self.Command_suspect, self))
	addCommandHandler("su",bind(self.Command_suspect, self))
	addCommandHandler("m",bind(self.Command_megaphone, self))
	addCommandHandler("tie",bind(self.Command_tie, self))
	addCommandHandler("needhelp",bind(self.Command_needhelp, self))
	addCommandHandler("bail",bind(self.Command_bail, self))

	addEventHandler("factionStateArrestPlayer", root, bind(self.Event_JailPlayer, self))
	addEventHandler("factionStateChangeSkin", root, bind(self.Event_FactionChangeSkin, self))
	addEventHandler("factionStateRearm", root, bind(self.Event_FactionRearm, self))
	addEventHandler("factionStateSwat", root, bind(self.Event_toggleSwat, self))
	addEventHandler("factionStateToggleDuty", root, bind(self.Event_toggleDuty, self))
	addEventHandler("factionStateGiveWanteds", root, bind(self.Event_giveWanteds, self))
	addEventHandler("factionStateClearWanteds", root, bind(self.Event_clearWanteds, self))
	addEventHandler("factionStateGrabPlayer", root, bind(self.Event_grabPlayer, self))
	addEventHandler("factionStateFriskPlayer", root, bind(self.Event_friskPlayer, self))
	addEventHandler("factionStateShowLicenses", root, bind(self.Event_showLicenses, self))
	addEventHandler("factionStateTakeDrugs", root, bind(self.Event_takeDrugs, self))
	addEventHandler("factionStateTakeWeapons", root, bind(self.Event_takeWeapons, self))
	addEventHandler("factionStateAcceptShowLicense", root, bind(self.Event_acceptShowLicense, self))
	addEventHandler("factionStateDeclineShowLicense", root, bind(self.Event_declineShowLicense, self))
	addEventHandler("factionStateGivePANote", root, bind(self.Event_givePANote, self))
	addEventHandler("factionStatePutItemInVehicle", root, bind(self.Event_putItemInVehicle, self))
	addEventHandler("factionStateTakeItemFromVehicle", root, bind(self.Event_takeItemFromVehicle, self))
	addEventHandler("factionStateLoadJailPlayers", root, bind(self.Event_loadJailPlayers, self))
	addEventHandler("factionStateFreePlayer", root, bind(self.Event_freePlayer, self))




	-- Prepare the Area51
	self:createDefendActors(
		{
			{Vector3(128.396, 1954.551, 19.428), Vector3(0, 0, 354.965), 287, 31, 30};
			{Vector3(340.742, 1793.668, 18.140), Vector3(0, 0, 216.25), 287, 31, 30};
			{Vector3(350.257, 1800.481, 18.577), Vector3(0, 0, 227.407), 287, 31, 30};
			{Vector3(281.812, 1816.380, 17.970), Vector3(0, 0, 359.113), 287, 31, 30};
			{Vector3(97.468, 1942.034, 34.378), Vector3(0, 0, 19.822), 287, 34, 90};
			{Vector3(161.950, 1935.313, 33.898), Vector3(0, 0, 0.349), 287, 34, 90};
			{Vector3(111.469, 1812.475, 33.898), Vector3(0, 0, 135.428), 287, 34, 90};
			{Vector3(262.044, 1805.083, 33.898), Vector3(0, 0, 173.677), 287, 34, 90};
			{Vector3(384.456, 1961.135, 33.278), Vector3(0, 0, 266.788), 287, 34, 90};
			{Vector3(277.512, 2061.715, 33.678), Vector3(0, 0, 358.1), 287, 34, 90};
		}
	)
end

function FactionState:destructor()
end

function FactionState:loadLSPD(factionId)
	self:createDutyPickup(252.6, 69.4, 1003.64, 6) -- PD Interior
	self:createDutyPickup(1530.21, -1671.66, 6.22) -- PD Garage

	self:createTakeItemsPickup(Vector3(1543.96, -1707.26, 5.89))

	Blip:new("Police.png", 1552.278, -1675.725, root, 400)

	VehicleBarrier:new(Vector3(1544.70, -1630.90, 13.10), Vector3(0, 90, 90)).onBarrierHit = bind(self.onBarrierGateHit, self) -- PD Barrier
	VehicleBarrier:new(Vector3(283.900390625, 1817.7998046875, 17.400001525879), Vector3(0, 90, 90)).onBarrierHit = bind(self.onBarrierGateHit, self) -- Army Barrier

	local gate = Gate:new(9093, Vector3(1588.80, -1638.30, 14.50), Vector3(0, 0, 270), Vector3(1598.80, -1638.30, 14.50))
	gate.onGateHit = bind(self.onBarrierGateHit, self) -- PD Garage Gate
	gate:setGateScale(1.25)

	local door = Door:new(1499, Vector3(1584.09, -1638.09, 12.30), Vector3(0, 0, 180))
	door.onDoorHit = bind(self.onBarrierGateHit, self) -- PD Garage Gate
	door:setDoorScale(1.1)

	--InteriorEnterExit:new(Vector3(1525.16, -1678.17, 5.89), Vector3(259.22, 73.73, 1003.64), 0, 0, 6, 0) -- LSPD Garage
	--InteriorEnterExit:new(Vector3(1564.84, -1666.84, 28.40), Vector3(226.65, 75.95, 1005.04), 0, 0, 6, 0) -- LSPD Roof

	local elevator = Elevator:new()
	elevator:addStation("UG Garage", Vector3(1525.16, -1678.17, 5.89), 270)
	elevator:addStation("Erdgeschoss", Vector3(259.22, 73.73, 1003.64), 84, 6)
	elevator:addStation("Dach - Heliports", Vector3(1564.84, -1666.84, 28.40), 90)


	local safe = createObject(2332, 241, 77.70, 1004.50, 0, 0, 270)
	safe:setInterior(6)
	FactionManager:getSingleton():getFromId(1):setSafe(safe)

	self.m_ShootingRanchMarker = createMarker(249.78, 66.77, 1002.7, "cylinder", 1, 0, 255, 0, 200)
	self.m_ShootingRanchMarker:setInterior(6)
	addEventHandler("onMarkerHit", self.m_ShootingRanchMarker, function(hitElement, dim)
		if hitElement:getType() == "player" and dim then
			hitElement:triggerEvent("openWeaponLevelGUI")
		end
	end)

end

function FactionState:loadFBI(factionId)
	self:createDutyPickup(234.04456, 111.82722, 1003.22571, 10, 23) -- FBI Base
	self:createDutyPickup(1510.67871, -1479.12988, 9.50000)

	local safe = createObject(2332, 226.80, 128.50, 1010.20)
	safe:setInterior(10)
	FactionManager:getSingleton():getFromId(1):setSafe(safe)

	Gate:new(2938, Vector3(1534.6999511719,-1451.5,15), Vector3(0, 0, 270), Vector3(1534.6999511719,-1451.5,20)).onGateHit = bind(self.onBarrierGateHit, self)
	InteriorEnterExit:new(Vector3(1518.55298,-1452.88684,14.20313), Vector3(246.82773,108.65514,1003.21875), 0, 0, 10, 23)
	InteriorEnterExit:new( Vector3(1513.28772, -1461.14819, 9.50000),Vector3(214.93469,120.06063,1003.21875), -90, -180, 10, 23)
	InteriorEnterExit:new( Vector3(1536.08386,-1460.68518,63.8593),Vector3(228.63806,124.87337,1003.21875), 270, 90, 10, 23)
end

function FactionState:loadArmy(factionId)
	self:createDutyPickup(2743.75, -2453.81, 13.86) -- Army-LS
	self:createDutyPickup(247.05, 1859.38, 14.08) -- Army Area

	local safe = createObject(2332, 242.38, 1862.32, 14.08, 0, 0, 0 )
	FactionManager:getSingleton():getFromId(1):setSafe(safe)

	local areaGate = Gate:new(971, Vector3(130.3, 1934.8, 19.1), Vector3(0, 0, 180), Vector3(130.3, 1934.8, 13.7))
	areaGate:addGate(971, Vector3(139.2, 1934.8, 19.1), Vector3(0, 0, 180), Vector3(139.3, 1934.8, 13.7))
	areaGate:addCustomShapes(Vector3(134.93, 1927.58, 19.20), Vector3(135.27, 1941.85, 19.32))
	areaGate.onGateHit = bind(self.onBarrierGateHit, self)

	local areaGarage = Gate:new(7657, Vector3(208, 1875.90, 13.86), Vector3(0, 0, 180), Vector3(200, 1875.90, 13.86))
	areaGarage:addCustomShapes(Vector3(213.97, 1872.14, 13.14), Vector3(213.92, 1880.12, 13.14))
	areaGarage.onGateHit = bind(self.onBarrierGateHit, self)


	InteriorEnterExit:new(Vector3(1518.55298,-1452.88684,14.20313), Vector3(246.82773,108.65514,1003.21875), 0, 0, 10, 23)
	InteriorEnterExit:new( Vector3(1513.28772, -1461.14819, 9.50000),Vector3(214.93469,120.06063,1003.21875), -90, -180, 10, 23)
	InteriorEnterExit:new( Vector3(1536.08386,-1460.68518,63.8593),Vector3(228.63806,124.87337,1003.21875), 270, 90, 10, 23)
end

function FactionState:createTakeItemsPickup(pos)
	local pickup = createPickup(pos, 3, 1239, 0)
	addEventHandler("onPickupHit", pickup, function(hitElement)
		if hitElement:getType() == "player" then
			if hitElement.vehicle then
				if hitElement:isFactionDuty() and hitElement:getFaction() and hitElement:getFaction():isStateFaction() == true then
					local veh = hitElement.vehicle
					if veh:getFaction() and veh:getFaction():isStateFaction() then
						hitElement:triggerEvent("showStateItemGUI")
						triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, 0, self.m_Items)
					else
						hitElement:sendError(_("Ungültiges Fahrzeug!", hitElement))
					end
				else
					hitElement:sendError(_("Du bist nicht im Dienst!", hitElement))
				end
			else
				hitElement:sendError(_("Du brauchst ein Fahrzeug zum einladen!", hitElement))
			end
		end
	end)

end

function FactionState:countPlayers()
	local count = #self:getOnlinePlayers()
	return count
end

function FactionState:getOnlinePlayers()
	local factions = self:getFactions()
	local players = {}
	for index,faction in pairs(factions) do
		for index, value in pairs(faction:getOnlinePlayers()) do
			table.insert(players, value)
		end
	end
	return players
end

function FactionState:giveKarmaToOnlineMembers(karma, reason)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:giveKarma(karma)
		player:sendShortMessage(_("%s\nDu hast %d Karma erhalten!", player, reason, karma), "Karma")
	end
end

function FactionState:getFactions()
	local factions = FactionManager:getSingleton():getAllFactions()
	local returnFactions = {}
	for i, faction in pairs(factions) do
		if faction:isStateFaction() then
			table.insert(returnFactions, faction)
		end
	end
	return returnFactions
end

function FactionState:onBarrierGateHit(player)
    if player:getFaction() and player:getFaction():isStateFaction() then
		return true
	else
		return false
	end

end

function FactionState:createDutyPickup(x,y,z,int, dim)
	self.m_DutyPickup = createPickup(x,y,z, 3, 1275) --PD
	setElementInterior(self.m_DutyPickup, int or 0)
	setElementDimension ( self.m_DutyPickup, dim or 0)
	addEventHandler("onPickupHit", self.m_DutyPickup,
		function(hitElement)
			if getElementType(hitElement) == "player" then
				local faction = hitElement:getFaction()
				if faction then
					if faction:isStateFaction() == true then
						hitElement:triggerEvent("showStateFactionDutyGUI")
						hitElement:getFaction():updateStateFactionDutyGUI(hitElement)
					end
				end
			end
			cancelEvent()
		end
	)
end

function FactionState:createArrestZone(x, y, z, int, dim)
	local pickup = createPickup(x,y,z, 3, 1318)
	local col = createColSphere(x,y,z, 4)
	if int then
		pickup:setInterior(int)
		col:setInterior(int)
	end

	if dim then
		pickup:setDimension(dim)
		col:setDimension(dim)
	end
	addEventHandler("onPickupHit", pickup,
	function(hitElement)
		if getElementType(hitElement) == "player" then
			local faction = hitElement:getFaction()
			if faction then
				if faction:isStateFaction() == true then
					if hitElement:isFactionDuty() then
						hitElement:triggerEvent("showStateFactionArrestGUI", col)
					end
				end
			end
		end
		cancelEvent()
	end
	)
end

function FactionState:getFullReasonFromShortcut(reason)
	if string.lower(reason) == "bs" or string.lower(reason) == "wn" then
		reason = "Beschuss/Waffennutzung"
	elseif string.lower(reason) == "db" then
		reason = "Drogenbesitz"
	elseif string.lower(reason) == "br" then
		reason = "Banküberfall"
	elseif string.lower(reason) == "mt" then
		reason = "Mats-Truck"
	elseif string.lower(reason) == "wt" then
		reason = "Waffen-Truck"
	elseif string.lower(reason) == "dt" then
		reason = "Drogen-Truck"
	elseif string.lower(reason) == "gt" then
		reason = "Geldtruck-Überfall"
	elseif string.lower(reason) == "kh" then
		reason = "Knasthack/Knastausbruch"
	elseif string.lower(reason) == "swt" then
		reason = "Staatswaffentruck-Überfall"
	elseif string.lower(reason) == "illad" then
		reason = "Illegale Werbung"
	elseif string.lower(reason) == "kpv" then
		reason = "Körperverletzung"
	elseif string.lower(reason) == "garage" or string.lower(reason) == "pdgarage" then
		reason = "Einbruch-in-die-PD-Garage"
	elseif string.lower(reason) == "wd" then
		reason = "Waffen-Drohung"
	elseif string.lower(reason) == "bh" then
		reason = "Beihilfe einer Straftat"
	elseif string.lower(reason) == "vw" then
		reason = "Verweigerung-zur-Durchsuchung"
	elseif string.lower(reason) == "bb" or string.lower(reason) == "beleidigung" then
		reason = "Beamtenbeleidigung"
	elseif string.lower(reason) == "flucht" or string.lower(reason) == "fvvk" or string.lower(reason) == "vk" then
		reason = "Flucht aus Kontrolle"
	elseif string.lower(reason) == "kt" then
		reason = "Koks-Truck"
	elseif string.lower(reason) == "zt" then
		reason = "Überfall auf Zeugenschutz"
	elseif string.lower(reason) == "bv" then
		reason = "Befehlsverweigerung"
	elseif string.lower(reason) == "sb" then
		reason = "Sachbeschädigung"
	elseif string.lower(reason) == "rts" then
		reason = "Shop-Überfall"
	elseif string.lower(reason) == "eöä" then
		reason = "Erregung öffentlichen Ärgernisses"
	elseif string.lower(reason) == "vd" then
		reason = "versuchter Diebstahl"
	elseif string.lower(reason) == "fof" then
		reason = "Fahren ohne Führerschein"
	end
	return reason
end

function FactionState:sendShortMessage(text, ...)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:sendShortMessage(_(text, player), "Staat", {11, 102, 8}, ...)
	end
end

function FactionState:sendMessage(text, r, g, b, ...)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function FactionState:sendStateChatMessage(sourcePlayer, message)
	local faction = sourcePlayer:getFaction()
	if faction and faction:isStateFaction() == true then
	--	if sourcePlayer:isFactionDuty() then
			local playerId = sourcePlayer:getId()
			local rank = faction:getPlayerRank(playerId)
			local rankName = faction:getRankName(rank)
			local r,g,b = 200, 100, 100
			local receivedPlayers = {}
			local text = ("%s %s: %s"):format(rankName,getPlayerName(sourcePlayer), message)
			for k, player in pairs(self:getOnlinePlayers()) do
				player:sendMessage(text, r, g, b)
				if player ~= sourcePlayer then
					receivedPlayers[#receivedPlayers+1] = player:getName()
				end
			end
			StatisticsLogger:getSingleton():addChatLog(sourcePlayer, "state", message, toJSON(receivedPlayers))
	--	else
	--		sourcePlayer:sendError(_("Du bist nicht im Dienst!", sourcePlayer))
	--	end
	end
end

function FactionState:Command_megaphone(player, cmd, ...)
	local faction = player:getFaction()
	if faction and faction:isStateFaction() == true then
		if player:isFactionDuty() then
			if player:getOccupiedVehicle() and player:getOccupiedVehicle():getFaction() and player:getOccupiedVehicle():isStateVehicle() then
				local playerId = player:getId()
				local playersToSend = player:getPlayersInChatRange(2)
				local text = ("[[ %s %s: %s ]]"):format(faction:getShortName(), player:getName(), table.concat({...}, " "))
				for index = 1,#playersToSend do
					playersToSend[index]:sendMessage(text, 255, 255, 0)
				end
			else
				player:sendError(_("Du sitzt in keinem Fraktions-Fahrzeug!", player))
			end
		else
			player:sendError(_("Du bist nicht im Dienst!", player))
		end
	end
end

function FactionState:Command_suspect(player,cmd,target,amount,...)
	if player:isFactionDuty() and player:getFaction() and player:getFaction():isStateFaction() == true then
		local amount = tonumber(amount)
		if amount and amount >= 1 and amount <= 6 then
			local reason = self:getFullReasonFromShortcut(table.concat({...}, " "))
			local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
			if isElement(target) then
				if not isPedDead(target) then
					if string.len(reason) > 2 and string.len(reason) < 50 then
						target:giveWantedLevel(amount)
						outputChatBox(("Verbrechen begangen: %s, %s Wanteds, Gemeldet von: %s"):format(reason,amount,player:getName()), target, 255, 255, 0 )
						local msg = ("%s hat %s %d Wanteds wegen %s gegeben!"):format(player:getName(),target:getName(),amount, reason)
						StatisticsLogger:getSingleton():addTextLog("wanteds", msg)
						self:sendMessage(msg, 255,0,0)
					else
						player:sendError(_("Der Grund ist ungültig!", player))
					end
				else
					player:sendError(_("Der Spieler ist tot!", player))
				end
			end
		else
			player:sendError(_("Die Anzahl muss zwischen 1 und 6 liegen!", player))
		end
	else
		player:sendError(_("Du bist nicht im Dienst!", player))
	end
end

function FactionState:Command_tie(player, cmd, tname, bool)
	local faction = player:getFaction()
	if faction and faction:isStateFaction() then
		if player:isFactionDuty() then
			local vehicle = player:getOccupiedVehicle()
			if vehicle and vehicle:getFaction() and vehicle:isStateVehicle() then
				if tname then
					local target = PlayerManager:getSingleton():getPlayerFromPartOfName(tname, player)
					if isElement(target) then
						if target:getOccupiedVehicle() and target:getOccupiedVehicle() == vehicle then
							if isControlEnabled(target, "enter_exit") or bool == true then
								player:sendInfo(_("Du hast %s gefesselt", player, target:getName()))
								target:sendInfo(_("Du wurdest von %s gefesselt", target, player:getName()))
								toggleControl(target, "enter_exit", false)
							else
								player:sendInfo(_("Du hast %s entfesselt", player, target:getName()))
								target:sendInfo(_("Du wurdest von %s entfesselt", target, player:getName()))
								toggleControl(target, "enter_exit", true)
							end
						else
							player:sendError(_("Der Spieler ist nicht in deinem Fahrzeug!", player))
						end
					end
				else
					player:sendError(_("Kein Ziel angegeben! Befehl: /tie [NAME]!", player))
				end
			else
				player:sendError(_("Du sitzt in keinem Fraktions-Fahrzeug!", player))
			end
		else
			player:sendError(_("Du bist nicht im Dienst!", player))
		end
	end
end

function FactionState:Command_needhelp(player)
	local faction = player:getFaction()
	if faction and faction:isStateFaction() then
		if player:isFactionDuty() then
			if player:getInterior() == 0 and player:getDimension() == 0 then
				local rankName = faction:getRankName(faction:getPlayerRank(player))
				local zoneName = getZoneName(player:getPosition()).."/"..getZoneName(player:getPosition(), true)
				for k, onlineplayer in pairs(self:getOnlinePlayers()) do
					onlineplayer:sendMessage(_("%s %s benötigt Unterstützung! Ort: %s", onlineplayer, rankName, player:getName(), zoneName), 50, 200, 255)
					onlineplayer:sendMessage(_("Begib dich dort hin! Der Ort wird auf der Karte markiert!", onlineplayer), 50, 200, 255)
					onlineplayer:triggerEvent("stateFactionNeedHelp", player)
				end
			else
				player:sendError(_("Du kannst hier keine Hilfe anfordern!", player))
			end
		else
			player:sendError(_("Du bist nicht im Dienst!", player))
		end
	else
		player:sendError(_("Du bist in keiner Staatsfraktion!", player))
	end
end

function FactionState:Event_JailPlayer(player, bail, CUTSCENE, police)
	local policeman = police or client
	if policeman:getFaction() and policeman:getFaction():isStateFaction() then
		if policeman:isFactionDuty() then
			if player:getWantedLevel() > 0 then
				local bailcosts = 0
				local wantedLevel = player:getWantedLevel()
				local jailTime = wantedLevel * 8
				local factionBonus = JAIL_COSTS[wantedLevel]

				if bail then
					bailcosts = BAIL_PRICES[wantedLevel]
					player:setJailBail(bailcosts)
				end

				if player:getMoney() < JAIL_COSTS[wantedLevel] then
					factionBonus = player:getMoney()
				end

				player:takeMoney(factionBonus)
				player:giveKarma(-wantedLevel)
				player:setJailTime(jailTime)
				player:setWantedLevel(0)
				player:moveToJail(CUTSCENE)
				player:clearCrimes()

				-- Pay some money to faction and karma, xp to the policeman
				policeman:getFaction():giveMoney(factionBonus, "Arrest")
				policeman:giveKarma(wantedLevel)
				policeman:givePoints(wantedLevel)
				policeman:getFaction():sendShortMessage(_("%s wurde soeben von %s für %d Minuten eingesperrt! Strafe: %d$", player, player:getName(), policeman:getName(), jailTime, factionBonus))
				StatisticsLogger:getSingleton():addArrestLog(player, wantedLevel, jailTime, policeman, bailcosts)

				-- Give Achievements
				if wantedLevel > 4 then
					policeman:giveAchievement(48)
				else
					policeman:giveAchievement(47)
				end

				setTimer(function () -- (delayed)
					player:giveAchievement(31)
				end, 14000, 1)

			else
				policeman:sendError(_("Der Spieler wird nicht gesucht!", player))
			end
		else
			policeman:sendError(_("Du bist nicht im Dienst!", player))
		end
	end
end

function FactionState:Command_bail(player)
	if player.m_JailTimer then
		if player.m_Bail and player.m_JailTime then
			if player.m_Bail > 0 then
				local money = player:getBankMoney()
				if money >= player.m_Bail then

					player:takeBankMoney(player.m_Bail, "Kaution")
					FactionManager:getSingleton():getFromId(1):giveMoney(player.m_Bail, "Kaution")

					player:sendInfo(_("Sie haben sich mit der Kaution von %s$ freigekauft!", player, player.m_Bail))
					player.m_Bail = 0
					StatisticsLogger:getSingleton():addTextLog("jail", ("%s hat sich für %d Dollar freigekauft!"):format(player:getName(), player.m_Bail))
					self:freePlayer(player)
				else
					player:sendError("Sie haben nicht genügend Geld!")
				end
			end
		end
	end
end

function FactionState:freePlayer(player)
	player:setData("inJail",false, true)
	player:setDimension(0)
	player:setInterior(0)
	player:setPosition(1539.7, -1659.5 + math.random(-3, 3), 13.6)
	player:setRotation(0, 0, 90)
	player:setWantedLevel(0)
	player:toggleControl("fire", true)
	player:toggleControl("jump", true)
	player:toggleControl("aim_weapon ", true)
	if isTimer(player.m_JailTimer) then
		killTimer( player.m_JailTimer )
	end
	player.m_JailTimer = nil
	player:setJailTime(0)
	player.m_Bail = 0
	player:triggerEvent("playerLeftJail")
	player:triggerEvent("checkNoDm")
end


function FactionState:Event_toggleSwat()
	if client:isFactionDuty() then
		local swat = client:getPublicSync("Fraktion:Swat")
		if swat == true then
			client:setJobDutySkin(nil)
			client:setPublicSync("Fraktion:Swat",false)
			client:sendInfo(_("Du hast den Swat-Modus beendet Dienst!", client))
			client:getFaction():updateStateFactionDutyGUI(client)
		else
			client:setJobDutySkin(285)
			client:setPublicSync("Faction:Swat",true)
			client:sendInfo(_("Du hast bist in den Swat-Modus gewechselt!", client))
			client:getFaction():updateStateFactionDutyGUI(client)
		end
	end
end

function FactionState:Event_FactionChangeSkin()
	if client:isFactionDuty() then
		if client.m_SpawnWithFactionSkin then
			client:getFaction():changeSkin(client)
		else
			setElementModel( self, self.m_AltSkin or self.m_Skin)
		end
	end
end

function FactionState:Event_FactionRearm()
	if client:isFactionDuty() then
		client:getFaction():rearm(client)
	end
end

function FactionState:Event_FactionRearm()
	if client:isFactionDuty() then
		client:triggerEvent("showFactionWeaponShopGUI",client:getFaction().m_ValidWeapons)
	end
end

function FactionState:Event_toggleDuty()
	if getPedOccupiedVehicle(client) then
		return client:sendError("Steige erst aus dem Fahrzeug aus!")
	end
	local faction = client:getFaction()
	if faction:isStateFaction() then
		if client:isFactionDuty() then
			client:setDefaultSkin()
			client.m_FactionDuty = false
			takeAllWeapons(client)
			faction:updateStateFactionDutyGUI(client)
			client:sendInfo(_("Du bist nicht mehr im Dienst!", client))
			client:setPublicSync("Faction:Duty",false)
			client:getInventory():removeAllItem("Barrikade")
		else
			if client:getPublicSync("Company:Duty") and client:getCompany() then
				client:sendWarning(_("Bitte beende zuerst deinen Unternehmens-Dienst!", client))
				return false
			end

			faction:changeSkin(client)
			client.m_FactionDuty = true
			client:setHealth(100)
			client:setArmor(100)
			takeAllWeapons(client)
			faction:updateStateFactionDutyGUI(client)
			client:sendInfo(_("Du bist nun im Dienst!", client))
			client:setPublicSync("Faction:Duty",true)
			client:getInventory():removeAllItem("Barrikade")
			client:getInventory():giveItem("Barrikade", 10)
			client:triggerEvent("showFactionWeaponShopGUI")

		end
	else
		client:sendError(_("Du bist in keiner Staatsfraktion!", client))
		return false
	end
end

-- Area 51
function FactionState:createDefendActors(Actors)
	for i, v in pairs(Actors or {}) do
		local actor = DefendActor:new(v[1], v[3], v[4], v[5])
		actor:setRotation(v[2])
		actor:setFrozen(true)
		actor.onAttackRangeHit = function (actor, ele)
			if ele then
				local ele = ele
				if ele:getType() == "vehicle" or ele:getType() == "player" then
					if ele:getType() == "vehicle" then
						ele = ele:getOccupant()
						if not ele then -- Do not attack emtpy vehicles
							return true
						end
					end
					if ele:getType() == "player" then
						if ele:getFaction() and ele:getFaction():isStateFaction() then
							return true
						end
					end
				else
					return true -- Only attack Vehicles and Players
				end
			end

			return false
		end
	end
end


function FactionState:Event_giveWanteds(target, amount, reason)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			target:giveWantedLevel(amount)
			outputChatBox(("Verbrechen begangen: %s, %s Wanted/s, Gemeldet von: %s"):format(reason, amount, client:getName()), target, 255, 255, 0 )
			local msg = ("%s hat %s %d Wanted/s wegen %s gegeben!"):format(client:getName(), target:getName(), amount, reason)
			StatisticsLogger:getSingleton():addTextLog("wanteds", msg)
			self:sendMessage(msg, 255,0,0)
		end
	end
end

function FactionState:Event_clearWanteds(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			target:takeWantedLevel(6)
			outputChatBox(("Dir wurden alle Wanteds von %s erlassen"):format(client:getName()), target, 255, 255, 0 )
			local msg = ("%s hat %s alle Wanteds erlassen!"):format(client:getName(), target:getName())
			StatisticsLogger:getSingleton():addTextLog("wanteds", msg)
			self:sendMessage(msg, 255,0,0)
		end
	end
end

function FactionState:Event_grabPlayer(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			local vehicle = client:getOccupiedVehicle()
			if vehicle and vehicle:getFaction() and vehicle:isStateVehicle() then
				if target.isTasered == true then
					for seat = 1, getVehicleMaxPassengers(vehicle) do
						if not vehicle:getOccupant(seat) then
							warpPedIntoVehicle(target, vehicle, seat)
							client:sendInfo(_("%s wurde in dein Fahrzeug gezogen!", client, target:getName()))
							target:sendInfo(_("Du wurdest von %s in das Fahrzeug gezogen!", target, client:getName()))
							self:Command_tie(client, "tie", target:getName(), true)
							return
						end
					end
					client:sendError(_("Du hast keinen Platz in deinem Fahrzeug!", client))
				else
					client:sendError(_("Der Spieler ist nicht getazert!", client))
				end
			else
				client:sendError(_("Du sitzt in keinem Fraktions-Fahrzeug!", client))
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_friskPlayer(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			target:sendMessage(_("Der Staatsbeamte %s durchsucht dich!", target, client:getName()), 255, 255, 0)
			local DrugItems = {"Kokain", "Weed", "Heroin", "Shrooms"}
			local inv = target:getInventory()
			local targetDrugs = false
			for index, item in pairs(DrugItems) do
				if inv:getItemAmount(item) > 0 then
					if not targetDrugs then targetDrugs = {} end
					if not targetDrugs[item] then targetDrugs[item] = 0 end
					targetDrugs[item] = targetDrugs[item] + inv:getItemAmount(item)
				end
			end
			if targetDrugs then
				client:sendMessage(_("%s hat folgende Drogen dabei:", client, target:getName()), 255, 255, 0)
				target:sendMessage(_("Du hast folgende Drogen dabei:", target), 255, 255, 0)
				for drug, amount in pairs(targetDrugs) do
					client:sendMessage(_("%dg %s", client, amount, drug), 255, 125, 0)
					target:sendMessage(_("%dg %s", target, amount, drug), 255, 125, 0)
				end
			else
				client:sendMessage(_("%s hat keine Drogen dabei!", client, target:getName()), 0, 255, 0)
				target:sendMessage(_("Du hast keine Drogen dabei!", target), 0, 255, 0)
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_showLicenses(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			target:triggerEvent("questionBox", _("Staatsbeamter %s fordert dich auf deinen Führerschein zu zeigen! Zeigst du ihm deinen Führerschein?", client, getPlayerName(client)), "factionStateAcceptShowLicense", "factionStateDeclineShowLicense", client, target)
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_acceptShowLicense(player, target)
	player:triggerEvent("showIDCard", target)
	target:sendMessage(_("%s sieht sich deinen Führerschein an!", target, player:getName()), 255, 255, 0)
end

function FactionState:Event_declineShowLicense(player, target)
	player:sendMessage(_("%s will dir seinen Führerschein nicht zeigen!", player, target:getName()), 255, 255, 0)
end

function FactionState:Event_givePANote(target, note)
	local faction = client:getFaction()
	if faction and faction:getId() == 1 then
		if client:isFactionDuty() then
			if faction:getPlayerRank(client) < FactionRank.Manager then
				client:sendError(_("Du bist nicht berechtig PA-Noten auszuteilen!", client))
				return
			end
			if client == target then
				client:sendError(_("Du darfst dir nicht selber eine PA-Noten setzen!", client))
				return
			end
			if note > 0 and note <= 100 then
				target:sendInfo(_("%s hat dir eine PA-Note von %d gegeben!", target, client:getName(), note))
				client:sendInfo(_("Du hast %s eine PA-Note von %d gegeben!", client, target:getName(), note))
				target:setPaNote(note)
				StatisticsLogger:getSingleton():addTextLog("paNote", ("%s hat %s eine PA-Note von %d gegeben!"):format(client:getName(), target:getName(), note))
			else
				client:sendError(_("Ungültige PA-Note!", client))
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	else
		client:sendError(_("Du bist nicht im SAPD!", client))
	end
end

function FactionState:Event_takeDrugs(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			local DrugItems = {"Kokain", "Weed", "Heroin", "Shrooms"}
			client:sendMessage(_("Du hast %s folgende Drogen abgenommen:", client, target:getName()), 255, 255, 0)
			target:sendMessage(_("%s hat dir folgende Drogen abgenommen:", target, client:getName()), 255, 255, 0)
			local drugsTaken = false
			local amount = 0
			local inv = target:getInventory()
			for index, item in pairs(DrugItems) do
				if inv:getItemAmount(item) > 0 then
					amount = inv:getItemAmount(item)
					drugsTaken = true
					client:sendMessage(_("%dg %s", client, amount, item), 255, 125, 0)
					target:sendMessage(_("%dg %s", target, amount, item), 255, 125, 0)
					inv:removeAllItem(item)
				end
			end
			if not drugsTaken then
				client:sendMessage(_("Keine", client), 255, 125, 0)
				target:sendMessage(_("Keine", target), 255, 125, 0)
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_takeWeapons(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			client:sendMessage(_("Du hast %s entwaffnet!", client, target:getName()), 255, 255, 0)
			target:sendMessage(_("%s hat dich entwaffnet!", target, client:getName()), 255, 255, 0)
			takeAllWeapons(target)
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_putItemInVehicle(itemName, amount, inventory)
	if client.vehicle or inventory then
		if client:isFactionDuty() and client:getFaction() and client:getFaction():isStateFaction() == true then
			local veh = inventory and source or client.vehicle
			if veh:getFaction() and veh:getFaction():isStateFaction() then
				veh:loadFactionItem(client, itemName, amount, inventory)
			else
				client:sendError(_("Ungültiges Fahrzeug!", client))
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	else
		client:sendError(_("Du brauchst ein Fahrzeug zum einladen!", client))
	end
end


function FactionState:Event_takeItemFromVehicle(itemName)
	if client:isFactionDuty() and client:getFaction() and client:getFaction():isStateFaction() == true then
		local veh = source
		if veh:getFaction() and veh:getFaction():isStateFaction() then
			veh:takeFactionItem(client, itemName)
		else
			client:sendError(_("Ungültiges Fahrzeug!", client))
		end
	else
		client:sendError(_("Du bist nicht im Dienst!", client))
	end
end

function FactionState:Event_loadJailPlayers()
	local players = {}
	for index, playeritem in pairs(getElementsByType("player")) do
		if playeritem.m_JailTime and playeritem.m_JailTime > 0 then
			players[playeritem] = playeritem.m_JailTime
		end
	end
	client:triggerEvent("receiveJailPlayers", players)
end

function FactionState:Event_freePlayer(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			if target and isElement(target) then
				outputChatBox(("Du wurdest von %s aus dem Knast entlassen!"):format(client:getName()), target, 255, 255, 0 )
				local msg = ("%s hat %s aus dem Knast entlassen!"):format(client:getName(), target:getName())
				StatisticsLogger:getSingleton():addTextLog("jail", msg)
				self:sendMessage(msg, 255,0,0)
				self:freePlayer(target)
			else
				client:sendError(_("Spieler nicht gefunden!", client))
			end
		end
	end
end
