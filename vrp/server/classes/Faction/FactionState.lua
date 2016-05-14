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
	self:createDutyPickup(252.6, 69.4, 1003.64, 6) -- PD Interior
	self:createDutyPickup(1530.21, -1671.66, 6.22, 0) -- PD Garage

	self:createArrestZone(1564.92, -1693.55, 5.89) -- PD Garage
	Blip:new("Police.png", 1552.278, -1675.725)

	VehicleBarrier:new(Vector3(1544.70, -1630.90, 13.10), Vector3(0, 90, 90)).onBarrierHit = bind(self.onBarrierGateHit, self) -- PD Barrier
	local gate = Gate:new(9093, Vector3(1588.80, -1638.30, 14.50), Vector3(0, 0, 270), Vector3(1598.80, -1638.30, 14.50))
	gate.onGateHit = bind(self.onBarrierGateHit, self) -- PD Garage Gate
	gate:setGateScale(1.25)
	local door = Door:new(1499, Vector3(1584.09, -1638.09, 12.30), Vector3(0, 0, 180))
	door.onDoorHit = bind(self.onBarrierGateHit, self) -- PD Garage Gate
	door:setDoorScale(1.1)

	local pdGarageEnter = InteriorEnterExit:new(Vector3(1525.16, -1678.17, 5.89), Vector3(259.22, 73.73, 1003.64), 0, 0, 6, 0)
	--local pdGarageExit = InteriorEnterExit:new(Vector3(259.22, 73.73, 1003.64), Vector3(1527.16, -1678.17, 5.89), 0, 0, 0, 0)

	addRemoteEvents{"factionStateArrestPlayer","factionStateChangeSkin", "factionStateRearm", "factionStateSwat","factionStateToggleDuty", "factionStateGiveWanteds", "factionStateClearWanteds", "factionStateGrabPlayer"}

	addCommandHandler("suspect",bind(self.Command_suspect, self))
	addCommandHandler("su",bind(self.Command_suspect, self))
	addCommandHandler("m",bind(self.Command_megaphone, self))
	addEventHandler("factionStateArrestPlayer", root, bind(self.Event_JailPlayer, self))
	addEventHandler("factionStateChangeSkin", root, bind(self.Event_FactionChangeSkin, self))
	addEventHandler("factionStateRearm", root, bind(self.Event_FactionRearm, self))
	addEventHandler("factionStateSwat", root, bind(self.Event_toggleSwat, self))
	addEventHandler("factionStateToggleDuty", root, bind(self.Event_toggleDuty, self))
	addEventHandler("factionStateGiveWanteds", root, bind(self.Event_giveWanteds, self))
	addEventHandler("factionStateClearWanteds", root, bind(self.Event_clearWanteds, self))
	addEventHandler("factionStateGrabPlayer", root, bind(self.Event_grabPlayer, self))


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

function FactionState:countPlayers()
	local factions = FactionManager:getSingleton():getAllFactions()
	local amount = 0
	for index,faction in pairs(factions) do
		if faction:isStateFaction() then
			amount = amount+faction:getOnlinePlayers()
		end
	end
	return amount
end

function FactionState:getOnlinePlayers()
	local factions = FactionManager:getSingleton():getAllFactions()
	local players = {}
	for index,faction in pairs(factions) do
		if faction:isStateFaction() then
			for index, value in pairs(faction:getOnlinePlayers()) do
				table.insert(players, value)
			end
		end
	end
	return players
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
    if not player:getFaction() or not player:getFaction():isStateFaction() then
        player:sendError(_("Zufahrt Verboten!", player))
        return false
    end
    return true
end

function FactionState:createDutyPickup(x,y,z,int)
	self.m_DutyPickup = createPickup(x,y,z, 3, 1275) --PD
	setElementInterior(self.m_DutyPickup, int)
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

function FactionState:createArrestZone(x,y,z,int)
	self.m_ArrestZone = createPickup(x,y,z, 3, 1318) --PD
	self.m_ArrestZoneCol = createColSphere(x,y,z, 4) --PD
	addEventHandler("onPickupHit", self.m_ArrestZone,
		function(hitElement)
			if getElementType(hitElement) == "player" then
				local faction = hitElement:getFaction()
				if faction:isStateFaction() == true then
					if hitElement:isFactionDuty() then
						hitElement:triggerEvent("showStateFactionArrestGUI",self.m_ArrestZoneCol)
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


function FactionState:sendStateChatMessage(sourcePlayer,text)
	local faction = sourcePlayer:getFaction()
	if faction and faction:isStateFaction() == true then
		if sourcePlayer:isFactionDuty() then
			local playerId = sourcePlayer:getId()
			local rank = faction:getPlayerRank(playerId)
			local rankName = faction:getRankName(rank)
			local r,g,b = 200, 100, 100
			local text = ("%s %s: %s"):format(rankName,getPlayerName(sourcePlayer), text)
			for k, player in ipairs(self:getOnlinePlayers()) do
				player:sendMessage(text, r, g, b)
			end
		else
			sourcePlayer:sendError(_("Du bist nicht im Dienst!", sourcePlayer))
		end
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
	if player:isFactionDuty() then
		local amount = tonumber(amount)
		if amount >= 1 and amount <= 6 then
			local reason = self:getFullReasonFromShortcut(table.concat({...}, " "))
			local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
			if isElement(target) then
				if not isPedDead(target) then
					if string.len(reason) > 2 and string.len(reason) < 50 then
						target:giveWantedLevel(amount)
						outputChatBox(("Verbrechen begangen: %s, %s Wanteds, Gemeldet von: %s"):format(reason,amount,player:getName()), target, 255, 255, 0 )
						local msg = ("%s hat %s %d Wanteds wegen %s gegeben!"):format(player:getName(),target:getName(),amount, reason)
						player:getFaction():sendMessage(msg, 255,0,0)
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

function FactionState:Event_JailPlayer(player, bail)
	local policeman = client
	if policeman:isFactionDuty() then
		if player:getWantedLevel() > 0 then
			-- Teleport to jail
			local rnd = math.random(1, #Jail.Cells)
			player:setPosition(Jail.Cells[rnd])
			player:setInterior(0)
			player:setDimension(0)
			player:setRotation(0, 0, 90)
			player:toggleControl("fire", false)
			player:toggleControl("jump", false)
			player:toggleControl("aim_weapon ", false)

			-- Pay some money, karma and xp to the policeman
			policeman:giveMoney(player:getWantedLevel() * 100)
			policeman:giveKarma(player:getWantedLevel() * 0.05)
			policeman:givePoints(player:getWantedLevel())

			-- Give Achievements
			if player:getWantedLevel() > 4 then
				policeman:giveAchievement(48)
			else
				policeman:giveAchievement(47)
			end

			setTimer(function () -- (delayed)
				player:giveAchievement(31)
			end, 14000, 1)

			-- Start freeing timer
			local jailTime = player:getWantedLevel() * 360
			player.m_JailTimer = setTimer(
				function()
					if isElement(player) then
						player:setPosition(1539.7, -1659.5 + math.random(-3, 3), 13.6)
						player:setRotation(0, 0, 90)
						player:setWantedLevel(0)
						player:toggleControl("fire", true)
						player:toggleControl("jump", true)
						player:toggleControl("aim_weapon ", true)

						player.m_JailTimer = nil
					end
				end, jailTime * 1000, 1
			)

			player:clearCrimes()

			policeman:getFaction():sendMessage(_("%s wurde soeben von %s eingesperrt!", player, player:getName(), policeman:getName()), 255, 255, 0)

			player:triggerEvent("playerJailed", jailTime)
		else
			policeman:sendError(_("Der Spieler wird nicht gesucht!", player))
		end
	else
		policeman:sendError(_("Du bist nicht im Dienst!", player))
	end
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
		client:getFaction():changeSkin(client)
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
			faction:changeSkin(client)
			client.m_FactionDuty = true
			takeAllWeapons(client)
			faction:updateStateFactionDutyGUI(client)
			client:sendInfo(_("Du bist nun im Dienst!", client))
			client:setPublicSync("Faction:Duty",true)
			client:getInventory():removeAllItem("Barrikade")
			client:getInventory():giveItem("Barrikade", 10)
		end
	else
		client:sendError(_("Du bist in keiner Staatsfraktion!", client))
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
			outputChatBox(("Verbrechen begangen: %s, %s Wanteds, Gemeldet von: %s"):format(reason, amount, client:getName()), target, 255, 255, 0 )
			local msg = ("%s hat %s %d Wanteds wegen %s gegeben!"):format(client:getName(), target:getName(), amount, reason)
			client:getFaction():sendMessage(msg, 255,0,0)
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
			client:getFaction():sendMessage(msg, 255,0,0)
		end
	end
end

function FactionState:Event_grabPlayer(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			if client:getOccupiedVehicle() and client:getOccupiedVehicle():getFaction() and client:getOccupiedVehicle():isStateVehicle() then
				if target.isTasered == true then
					for seat, playerItem in pairs(client:getOccupiedVehicle():getOccupants()) do
						if seat > 0 then
							if not isElement(playerItem) then
								warpPedIntoVehicle(target, client:getOccupiedVehicle(), seat)
							end
						end
					end
				else
					client:sendError(_("Der Spieler ist nicht getazert!", client))
				end
			else
				client:sendError(_("Du sitzt in keinem Fraktions-Fahrzeug!", client))
			end
		end
	end
end
