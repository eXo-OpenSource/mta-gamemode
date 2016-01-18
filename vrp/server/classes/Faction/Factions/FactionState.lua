-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionManager.lua
-- *  PURPOSE:     Factionmanager Class
-- *
-- ****************************************************************************

FactionState = inherit(Singleton)
  -- implement by children

function FactionState:constructor()
	outputDebugString("Faction State loaded")
	self:createDutyPickup(252.6, 69.4, 1003.64,6)
	self:createArrestZone(1564.92, -1693.55, 5.89)
	addCommandHandler("suspect",bind(self.Command_suspect, self))
	addCommandHandler("su",bind(self.Command_suspect, self))
end

function FactionState:destructor()
end

function FactionState:createDutyPickup(x,y,z,int)
	self.m_DutyPickup = createPickup(x,y,z, 3, 1275) --PD
	setElementInterior(self.m_DutyPickup, int)
	addEventHandler("onPickupHit", self.m_DutyPickup,
		function(hitElement)
			if getElementType(hitElement) == "player" then
				local faction = hitElement:getFaction()
				if faction:isStateFaction() == true then
					hitElement:triggerEvent("showStateFactionDutyGUI")
					hitElement:getFaction():updateStateFactionDutyGUI(hitElement)
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
					hitElement:triggerEvent("showStateFactionArrestGUI",self.m_ArrestZoneCol)
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

function FactionState:suspect(player,target,reason)
	if getPlayerWantedLevel(target) <= 5 then
		setPlayerWantedLevel ( target, getPlayerWantedLevel(target)+1 )
	end
	outputChatBox ( "Du hast ein Verbrechen begangen: "..reason..", Gemeldet von: "..getPlayerName(player), target, 255, 255, 0 )
	local msg = getPlayerName(player).." hat "..getPlayerName(target).." ein Wanted wegen "..reason.." gegeben!"
	player:getFaction():sendMessage(msg, 255,0,0)

end

function FactionState:Command_suspect(player,cmd,target,anzahl,...)
	local anzahl = tonumber(anzahl)
	if anzahl > 0 and anzahl < 7 then
		if not r2 then r2 = "" end
		if not r3 then r3 = "" end
		if not r4 then r4 = "" end
		local reason = table.concat({...}, " ")
		local reason = self:getFullReasonFromShortcut(reason)
		local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
		if isElement(target) then
			if not isPedDead(target) then
				if string.len(reason) < 50 then
					local targetname = getPlayerName ( target )
						for i=1,tonumber(anzahl),1 do
							self:suspect (player,target,reason)
						end
				else
					player:sendError(_("Der Grund ist zu lang!"))
				end
			else
				player:sendError(_("Der Spieler ist tot!"))
			end
		end
	else
		player:sendError(_("Die Anzahl muss zwischen 1 und 6 liegen!"))
	end
end
