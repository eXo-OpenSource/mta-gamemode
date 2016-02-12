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
	outputDebug("Faction State loaded")
	self:createDutyPickup(252.6, 69.4, 1003.64,6) -- PD Interior
	self:createArrestZone(1564.92, -1693.55, 5.89) -- PD Garage

	VehicleBarrier:new(Vector3(1544.70, -1630.90, 13.10), Vector3(0, 90, 90)).onBarrierHit = bind(self.onBarrierGateHit, self) -- PD Barrier
	Gate:new(980, Vector3(1588, -1637.90, 14.90), Vector3(0, 0, 0), Vector3(1598, -1637.90, 14.90)).onGateHit = bind(self.onBarrierGateHit, self) -- PD Garage Gate

	local pdGarageEnter = InteriorEnterExit:new(Vector3(1525.16, -1678.17, 5.89), Vector3(259.22, 73.73, 1003.64), 0, 0, 6, 0)
	--local pdGarageExit = InteriorEnterExit:new(Vector3(259.22, 73.73, 1003.64), Vector3(1527.16, -1678.17, 5.89), 0, 0, 0, 0)

	addRemoteEvents{"FactionStateArrestPlayer","factionStateChangeSkin", "factionStateRearm", "factionStateSwat","factionStateToggleDuty"}

	addCommandHandler("suspect",bind(self.Command_suspect, self))
	addCommandHandler("su",bind(self.Command_suspect, self))
	addEventHandler("factionStateArrestPlayer", root, bind(self.Event_JailPlayer, self))
	addEventHandler("factionStateChangeSkin", root, bind(self.Event_FactionChangeSkin, self))
	addEventHandler("factionStateRearm", root, bind(self.Event_FactionRearm, self))
	addEventHandler("factionStateSwat", root, bind(self.Event_toggleSwat, self))
	addEventHandler("factionStateToggleDuty", root, bind(self.Event_toggleDuty, self))

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

function FactionState:onBarrierGateHit(player)
    if not player:getFaction():isStateFaction() then
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

function FactionState:Command_suspect(player,cmd,target,anzahl,...)
	if player:isFactionDuty() then
		local anzahl = tonumber(anzahl)
		if anzahl >= 1 and anzahl <= 6 then
			local reason = self:getFullReasonFromShortcut(table.concat({...}, " "))
			local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
			if isElement(target) then
				if not isPedDead(target) then
					if string.len(reason) > 2 and string.len(reason) < 50 then
						local targetname = getPlayerName ( target )
						target:giveWantedLevel(anzahl)
						outputChatBox(("Verbrechen begangen: %s, %s Wanteds, Gemeldet von: %s"):format(reason,anzahl,player:getName()), target, 255, 255, 0 )
						local msg = ("%s hat %s %d Wanteds wegen %s gegeben!"):format(player:getName(),target:getName(),anzahl, reason)
						player:getFaction():sendMessage(msg, 255,0,0)
					else
						player:sendError(_("Der Grund ist ungültig!"))
					end
				else
					player:sendError(_("Der Spieler ist tot!"))
				end
			end
		else
			player:sendError(_("Die Anzahl muss zwischen 1 und 6 liegen!"))
		end
	else
		player:sendError(_("Du bist nicht im Dienst!"))
	end
end

function FactionState:Event_JailPlayer(player)
	local policeman = client
	if policeman:isFactionDuty() then
		if player:getWantedLevel() > 0 then
			-- Teleport to jail
			player:setPosition(Vector3(2673.37, -2112.44, 19.05) + Vector3(math.random(-2, 2), math.random(-2, 2), 0))
			player:setRotation(0, 0, 90)
			player:toggleControl("fire", false)
			player:toggleControl("jump", false)
			player:toggleControl("aim_weapon ", false)

			-- Pay some money, karma and xp to the policeman
			policeman:giveMoney(player:getWantedLevel() * 100)
			policeman:giveKarma(player:getWantedLevel() * 0.05)
			policeman:givePoints(3)

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

			-- Clear crimes
			player:clearCrimes()

			-- Tell the other policemen that we jailed someone
			policeman:getFaction():sendMessage("%s wurde soeben von %s eingesperrt!", getPlayerName(player), getPlayerName(policeman))

			-- Tell the client that we were jailed
			player:triggerEvent("playerJailed", jailTime)
		else
			policeman:sendError("Der Spieler wird nicht gesucht!")
		end
	else
		policeman:sendError(_("Du bist nicht im Dienst!"))
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
			faction:updateStateFactionDutyGUI(client)
			client:sendInfo(_("Du bist nicht mehr im Dienst!", client))
			client:setPublicSync("Faction:Duty",false)
			client:getInventory():removeAllItem("Barrikade")
		else
			faction:changeSkin(client)
			client.m_FactionDuty = true
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
