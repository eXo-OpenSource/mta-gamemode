-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionEvil.lua
-- *  PURPOSE:     Evil Faction Class
-- *
-- ****************************************************************************

FactionEvil = inherit(Singleton)
  -- implement by children

function FactionEvil:constructor()
	self.InteriorEnterExit = {}
	self.m_WeaponPed = {}
	self.m_ItemDepot = {}

	self.m_Raids = {}

	nextframe(function()
		self:loadYakGates(6)
	end)

	for Id, faction in pairs(FactionManager:getAllFactions()) do
		if faction:isEvilFaction() then
			self:createInterior(Id, faction)
		end
	end
	nextframe(function()
		self:loadDiplomacy()
	end)


	addRemoteEvents{"factionEvilStartRaid", "factionEvilSuccessRaid", "factionEvilFailedRaid"}
	addEventHandler("factionEvilStartRaid", root, bind(self.Event_StartRaid, self))
	addEventHandler("factionEvilSuccessRaid", root, bind(self.Event_SuccessRaid, self))
	addEventHandler("factionEvilFailedRaid", root, bind(self.Event_FailedRaid, self))
end

function FactionEvil:destructor()
end

function FactionEvil:createInterior(Id, faction)
	self.InteriorEnterExit[Id] = InteriorEnterExit:new(evilFactionInteriorEnter[Id], Vector3(2807.32, -1173.92, 1025.57), 0, 0, 8, Id)
	self.m_WeaponPed[Id] = NPC:new(FactionManager:getFromId(Id):getRandomSkin(), 2819.20, -1166.77, 1025.58, 133.63)
	setElementDimension(self.m_WeaponPed[Id], Id)
	setElementInterior(self.m_WeaponPed[Id], 8)
	self.m_WeaponPed[Id]:setImmortal(true)
	self.m_WeaponPed[Id]:setData("clickable",true,true) -- Makes Ped clickable
	self.m_WeaponPed[Id].Faction = faction
	addEventHandler("onElementClicked", self.m_WeaponPed[Id], bind(self.onWeaponPedClicked, self))

	self.m_ItemDepot[Id] = createObject(2972, 2816.8, -1173.5, 1024.4, 0, 0, 0)
	self.m_ItemDepot[Id]:setDimension(Id)
	self.m_ItemDepot[Id]:setInterior(8)
	self.m_ItemDepot[Id].Faction = faction
	self.m_ItemDepot[Id]:setData("clickable",true,true) -- Makes Ped clickable
	addEventHandler("onElementClicked", self.m_ItemDepot[Id], bind(self.onDepotClicked, self))

	local int = {
		createObject(351, 2818, -1173.6, 1025.6, 80, 340, 0),
		createObject(348, 2813.6001, -1166.8, 1025.64, 90, 0, 332),
		createObject(3016, 2820.3999, -1167.7, 1025.7, 0, 0, 18),
		createObject(1271, 2818.69995, -1167.30005, 1025.40002, 0, 0, 314),
		createObject(1271, 2818.19995, -1166.80005, 1024.69995, 0, 0, 314),
		createObject(1271, 2818.2, -1166.8, 1025.4, 0, 0, 312),
		createObject(1271, 2818.7, -1167.3, 1024.7, 0, 0, 313.995),
		createObject(1271, 2819.2, -1167.8, 1024.7, 0, 0, 314.495),
		createObject(1271, 2819.2, -1167.8, 1025.4, 0, 0, 315.25),
		createObject(2041, 2819.1001, -1165.2, 1025.9, 0, 0, 10),
		createObject(2042, 2818.3, -1166.8, 1025.8),
		createObject(2359, 2817.7, -1165.1, 1025.9, 0, 0, 348),
		createObject(2358, 2820.2, -1165.1, 1024.7 ),
		createObject(2358, 2820.19995, -1165.09998, 1024.90002, 0, 0, 354),
		createObject(2358, 2820.2, -1165.1, 1025.1, 0, 0, 10),
		createObject(2358, 2820.2, -1165.1, 1025.3),
		createObject(2358, 2820.2, -1165.1, 1025.5, 0, 0, 348),
		createObject(349, 2818.8999, -1167.7, 1025.8, 90, 0, 0),
		createObject(2977, 2819.3, -1170.6, 1024.4, 0, 0, 30.5),
		createObject(2332, 2814.6001, -1173.8, 1026.6, 0, 0, 180)
	}
	for k,v in pairs(int) do
		setElementDimension(v, Id)
		setElementInterior(v, 8)
		if v:getModel() == 2332 then
			faction:setSafe(v)
		end
	end
end

function FactionEvil:getFactions()
	local factions = FactionManager:getSingleton():getAllFactions()
	local returnFactions = {}
	for i, faction in pairs(factions) do
		if faction:isEvilFaction() then
			table.insert(returnFactions, faction)
		end
	end
	return returnFactions
end

function FactionEvil:getOnlinePlayers()
	local factions = FactionManager:getSingleton():getAllFactions()
	local players = {}
	for index,faction in pairs(factions) do
		if faction:isEvilFaction() then
			for index, value in pairs(faction:getOnlinePlayers()) do
				table.insert(players, value)
			end
		end
	end
	return players
end

function FactionEvil:countPlayers()
	local count = #self:getOnlinePlayers()
	return count
end

function FactionEvil:giveKarmaToOnlineMembers(karma, reason)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:giveKarma(karma)
		player:sendShortMessage(_("%s\nDu hast %d Karma erhalten!", player, reason, karma), "Karma")
	end
end

function FactionEvil:sendWarning(text, header, ...)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:sendWarning(_(text, player, ...), 30000, header)
	end
end

function FactionEvil:onWeaponPedClicked(button, state, player)
	if button == "left" and state == "down" then
		if player:getFaction() and (player:getFaction() == source.Faction or source.Faction:checkAlliancePermission(player:getFaction(), "weapons")) then
			setPedArmor(player,100)
			player:sendInfo(_("Du hast dir eine neue Schutzweste geholt!",player))
			player.m_WeaponStoragePosition = player.position
			player:triggerEvent("showFactionWeaponShopGUI")
		else
			player:sendError(_("Dieser Waffenverkäufer liefert nicht an deine Fraktion!", player))
		end
	end
end

function FactionEvil:onDepotClicked(button, state, player)
	if button == "left" and state == "down" then
		if player:getFaction() and player:getFaction() == source.Faction then
			player:getFaction():getDepot():showItemDepot(player)
		else
			player:sendError(_("Dieses Depot gehört nicht deiner Fraktion!", player))
		end
	end
end

function FactionEvil:loadYakGates(factionId)

	local lcnGates = {}
	lcnGates[1] = Gate:new(10558, Vector3(1402.4599609375, -1450.0500488281, 9.6000003814697), Vector3(0, 0, 86), Vector3(1402.4599609375, -1450.0500488281, 5.6))
	for index, gate in pairs(lcnGates) do
		gate:setOwner(FactionManager:getSingleton():getFromId(factionId))
		gate.onGateHit = bind(self.onBarrierGateHit, self)
	end
	local elevator = Elevator:new()
	elevator:addStation("UG Garage", Vector3(1413.57, -1355.19, 8.93))
	elevator:addStation("Hinterhof", Vector3(1423.35, -1356.26, 13.57))
	elevator:addStation("Dach", Vector3(1418.78, -1329.92, 23.99))
end

function FactionEvil:onBarrierGateHit(player, gate)
    if player:getFaction() == gate:getOwner() then
		return true
	else
		return false
	end
end

function FactionEvil:Event_StartRaid(target)
	if client:getFaction() and client:getFaction():isEvilFaction() then
		if target and isElement(target) and target:isLoggedIn() then
			if not target:isFactionDuty() and not target:isCompanyDuty() then
				if client.vehicle then
					client:sendError(_("Du kannst nicht aus einem Fahrzeug überfallen!", client))
					return
				end
				if target:getPublicSync("supportMode") then
					client:sendError(_("Du kannst keine aktiven Supporter überfallen!", client))
					return
				end
				if target:getInterior() > 0 then
					client:sendError(_("Du kannst Leute nur im Freien überfallen!", client))
					return
				end
				if math.floor(target:getPlayTime()/60) < 10 then
					client:sendError(_("Spieler unter 10 Spielstunden dürfen nicht überfallen werden!", client))
					return
				end
				if target:getMoney() > 0 then

					local targetName = target:getName()
					if self.m_Raids[targetName] and not timestampCoolDown(self.m_Raids[targetName], 2*60*60) then
						client:sendError(_("Dieser Spieler wurde innerhalb der letzten 2 Stunden bereits überfallen!", client))
						return
					end
					target:sendMessage(_("Du wirst von %s (%s) überfallen!", target, client:getName(), client:getFaction():getShortName()), 255, 0, 0)
					target:sendMessage(_("Lauf weg oder bleibe bis der Überfall beendet ist!", target), 255, 0, 0)
					client:meChat(true, _("überfällt %s!", client, target:getName()))

					target:triggerEvent("CountdownStop",  15, "Überfallen in")
					target:triggerEvent("Countdown", 15, "Überfallen in")
					client:triggerEvent("Countdown", 15, "Überfallen in")
					client:triggerEvent("factionEvilStartRaid", target)
					self.m_Raids[targetName] = getRealTime().timestamp
				else
					client:sendError(_("Der Spieler hat kein Geld dabei!", client))
				end
			else
				client:sendError(_("Der Spieler ist nicht mehr online!", client))
			end
		else
			client:sendError(_("Du kannst keine Spieler im Dienst überfallen!", client))
		end
	else
		client:sendError(_("Nur Spieler böser Fraktionen können andere Spieler überfallen!", client))
	end
end

function FactionEvil:Event_SuccessRaid(target)
	local money = target:getMoney()
	if money > 750 then money = 750 end
	if money > 0 then
		client:meChat(true,"überfällt "..target:getName().." erfolgreich!")
		target:meChat(true, _("wurde erfolgreich von %s überfallen!", target, client:getName()))
		target:takeMoney(money, "Überfall")
		client:giveMoney(money, "Überfall")
		client:triggerEvent("CountdownStop", "Überfallen in", 15)
		target:triggerEvent("CountdownStop", "Überfallen in", 15)
	else
		client:sendError(_("Der Spieler hat kein Geld dabei!", client))
	end
end

function FactionEvil:Event_FailedRaid(target)
	target:sendSuccess(_("Du bist dem Überfall entkommen!", target))
	client:sendWarning(_("Der Spieler ist dem Überfall entkommen!", client))
	target:meChat(true, _("ist aus dem Überfall von %s entkommen!", target, client:getName()))
end

function FactionEvil:loadDiplomacy()
	local evilFactions = self:getFactions()
	for Id, faction in pairs(evilFactions) do
		if faction:isEvilFaction() then
			faction:loadDiplomacy()
		end
	end
end



