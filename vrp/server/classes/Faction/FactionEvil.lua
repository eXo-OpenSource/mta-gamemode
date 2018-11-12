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
		self:loadLCNGates(5)
		self:loadTriadGates(11)
	end)

	for Id, faction in pairs(FactionManager:getAllFactions()) do
		if faction:isEvilFaction() then
			self:createInterior(Id, faction)
			local blip = Blip:new("Evil.png", evilFactionInteriorEnter[Id].x, evilFactionInteriorEnter[Id].y, {faction = Id}, 400, {factionColors[Id].r, factionColors[Id].g, factionColors[Id].b})
				blip:setDisplayText(faction:getName(), BLIP_CATEGORY.Faction)
		end
	end
	nextframe(function()
		self:loadDiplomacy()
	end)


	addRemoteEvents{"factionEvilStartRaid", "factionEvilSuccessRaid", "factionEvilFailedRaid", "factionEvilToggleDuty", "factionEvilRearm", "factionEvilStorageWeapons"}
	addEventHandler("factionEvilStartRaid", root, bind(self.Event_StartRaid, self))
	addEventHandler("factionEvilSuccessRaid", root, bind(self.Event_SuccessRaid, self))
	addEventHandler("factionEvilFailedRaid", root, bind(self.Event_FailedRaid, self))
	addEventHandler("factionEvilToggleDuty", root, bind(self.Event_toggleDuty, self))
	addEventHandler("factionEvilRearm", root, bind(self.Event_FactionRearm, self))
	addEventHandler("factionEvilStorageWeapons", root, bind(self.Event_storageWeapons, self))
end

function FactionEvil:destructor()
end

function FactionEvil:createInterior(Id, faction)
	self.InteriorEnterExit[Id] = InteriorEnterExit:new(evilFactionInteriorEnter[Id], Vector3(2807.32, -1173.92, 1025.57), 0, 0, 8, Id)
	self.m_WeaponPed[Id] = NPC:new(FactionManager:getFromId(Id):getRandomSkin(), 2819.20, -1166.77, 1025.58, 133.63)
	self.m_WeaponPed[Id]:setDimension(Id)
	self.m_WeaponPed[Id]:setInterior(8)
	self.m_WeaponPed[Id]:setFrozen(true)
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

function FactionEvil:getOnlinePlayers(afkCheck, dutyCheck)
	local factions = FactionManager:getSingleton():getAllFactions()
	local players = {}
	for index,faction in pairs(factions) do
		if faction:isEvilFaction() then
			for index, value in pairs(faction:getOnlinePlayers(afkCheck, dutyCheck)) do
				table.insert(players, value)
			end
		end
	end
	return players
end

function FactionEvil:countPlayers(afkCheck, dutyCheck)
	local count = #self:getOnlinePlayers(afkCheck, dutyCheck)
	return count
end

function FactionEvil:giveKarmaToOnlineMembers(karma, reason)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:giveKarma(karma)
	end
end

function FactionEvil:sendWarning(text, header, withOffDuty, pos, ...)
	for k, player in pairs(self:getOnlinePlayers(false, not withOffDuty)) do
		player:sendWarning(_(text, player, ...), 30000, header)
	end
	if pos and pos.x then pos = {pos.x, pos.y, pos.z} end -- serialiseVector conversion
	if pos and pos[1] and pos[2] then
		local blip = Blip:new("Gangwar.png", pos[1], pos[2], {factionType = "Evil", duty = (not withOffDuty)}, 4000, BLIP_COLOR_CONSTANTS.Orange)
			blip:setDisplayText(header)
		if pos[3] then
			blip:setZ(pos[3])
		end
		setTimer(function()
			blip:delete()
		end, 30000, 1)
	end
end

function FactionEvil:onWeaponPedClicked(button, state, player)
	if button == "left" and state == "down" then
		if player:getFaction() and (player:getFaction() == source.Faction or source.Faction:checkAlliancePermission(player:getFaction(), "weapons")) then
			player.m_CurrentDutyPickup = source
			player:getFaction():updateDutyGUI(player)
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
	lcnGates[1] = Gate:new(2933, Vector3(907.40002, -1712.5, 14.5), Vector3(0, 0, 90), Vector3(907.40002, -1701.8812255859, 14.5))
	setObjectScale(lcnGates[1].m_Gates[1], 1.1)
	-- setObjectBreakable(lcnGates[1].m_Gates[1], false) <- works only clientside
	for index, gate in pairs(lcnGates) do
		gate:setOwner(FactionManager:getSingleton():getFromId(factionId))
		gate.onGateHit = bind(self.onBarrierGateHit, self)
	end
	--// remove some objects for the new base that totally looks like a bullshit-fortress for some unauthentic factions called "weaboo-yakuza"
	--// ps: have I told you that I hate this new faction-base?
	--// removed removeModel ;)
end

function FactionEvil:loadTriadGates( factionId)

	local lcnGates = {}
	lcnGates[1] = Gate:new(10558, Vector3(1901.549, 967.301, 11.120 ), Vector3(0, 0, 270), Vector3(1901.549, 967.301, 11.120+4.04))
	for index, gate in pairs(lcnGates) do
		gate:setOwner(FactionManager:getSingleton():getFromId(factionId))
		gate.onGateHit = bind(self.onBarrierGateHit, self)
	end
	local pillar = createObject( 2774, 1906.836, 967.180+0.6, 10.820-7)
	local door = Door:new(6400, Vector3(1908.597, 967.407, 10.750), Vector3(0, 0, 90))
	setElementDoubleSided(door.m_Door, true)
	local crate = createObject(3576, 1909.020,965.252,11.320)
	setElementRotation(crate, 0, 0, 180)
	local box = createObject(18260, 1910.220, 969.863, 11.420)
	local elevator = Elevator:new()
	elevator:addStation("Garage", Vector3(1904.38, 1016.85, 11.3), 351-180)
	elevator:addStation("Casino", Vector3(1963.30, 973.03, 994.47), 204-180, 10, 0)
	elevator:addStation("Dach - Heliports", Vector3(1941.15, 988.92, 52.74), 0)
end


function FactionEvil:loadLCNGates(factionId)

	local lcnGates = {}
	lcnGates[1] = Gate:new(980, Vector3(784.56561, -1152.40520, 24.93374), Vector3(0, 0, 275), Vector3(784.56561, -1152.40520, 18.53374))
	lcnGates[2] = Gate:new(980, Vector3(659.12753, -1227.00923, 17.42981), Vector3(0, 0, 64), Vector3(659.12753, -1227.00923, 11.92981))
	lcnGates[3] = Gate:new(980, Vector3(664.99264, -1309.83203, 15.06094), Vector3(0, 0, 182), Vector3(664.99264, -1309.83203, 8.46094))

	--setObjectScale(lcnGates[1].m_Gates[1], 1.1)
	-- setObjectBreakable(lcnGates[1].m_Gates[1], false) <- works only clientside
	for index, gate in pairs(lcnGates) do
		gate:setOwner(FactionManager:getSingleton():getFromId(factionId))
		gate.onGateHit = bind(self.onBarrierGateHit, self)
	end
	--// remove some objects for the new base that totally looks like a bullshit-fortress for some unauthentic factions called "weaboo-yakuza"
	--// ps: have I told you that I hate this new faction-base?
	--// removed removeModel ;)
end

function FactionEvil:onBarrierGateHit(player, gate)
    if player:getFaction() == gate:getOwner() then
		return true
	else
		return false
	end
end

function FactionEvil:onBarrierDoorHit(player)
    if player:getFaction() == self.m_TriadDoor.m_FactionId then
		return true
	else
		return false
	end
end

function FactionEvil:Event_StartRaid(target)
	if client:getFaction() and client:getFaction():isEvilFaction() and client:isFactionDuty() then
		if target and isElement(target) and target:isLoggedIn() then
			if not target:isFactionDuty() and not target:isCompanyDuty() then
				if client.vehicle then
					client:sendError(_("Du kannst nicht aus einem Fahrzeug überfallen!", client))
					return
				end

				if target:getHealth() == 0 then return end

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
					client:meChat(true, _("überfällt %s!", client, targetName))

					target:triggerEvent("CountdownStop",  15, "Überfallen in")
					target:triggerEvent("Countdown", 15, "Überfallen in")
					client:triggerEvent("Countdown", 15, "Überfallen in")
					client:triggerEvent("factionEvilStartRaid", target)
					self.m_Raids[targetName] = getRealTime().timestamp
				else
					client:sendError(_("Der Spieler hat kein Geld dabei!", client))
				end
			else
				client:sendError(_("Du kannst keine Spieler im Dienst überfallen!", client))
			end
		end
	end
end

function FactionEvil:Event_SuccessRaid(target)
	local money = target:getMoney()
	if money > 750 then money = 750 end
	if money > 0 then
		client:meChat(true,"überfällt "..target:getName().." erfolgreich!")
		target:meChat(true, _("wurde erfolgreich von %s überfallen!", target, client:getName()))
		target:transferMoney(client, money, "Überfall", "Faction", "Robbery")
		client:triggerEvent("CountdownStop", "Überfallen in", 15)
		target:triggerEvent("CountdownStop", "Überfallen in", 15)
		StatisticsLogger:getSingleton():addRaidLog(client, target, 1, money)
	else
		client:sendError(_("Der Spieler hat kein Geld dabei!", client))
	end
end

function FactionEvil:Event_FailedRaid(target)
	target:sendSuccess(_("Du bist dem Überfall entkommen!", target))
	client:sendWarning(_("Der Spieler ist dem Überfall entkommen!", client))
	target:meChat(true, _("ist aus dem Überfall von %s entkommen!", target, client:getName()))
	StatisticsLogger:getSingleton():addRaidLog(client, target, 0, 0)
end

function FactionEvil:loadDiplomacy()
	local evilFactions = self:getFactions()
	for Id, faction in pairs(evilFactions) do
		if faction:isEvilFaction() then
			faction:loadDiplomacy()
		end
	end
end

function FactionEvil:setPlayerDuty(player, state, wastedOrNotOnMarker, preferredSkin)
	local faction = player:getFaction()
	if not state and player:isFactionDuty() then
		player:setCorrectSkin(true)
		player:setFactionDuty(false)
		player:sendInfo(_("Du bist nun in zivil unterwegs!", player))
		if not wastedOrNotOnMarker then faction:updateDutyGUI(player) end
	elseif state and not player:isFactionDuty() then
		if player:getPublicSync("Company:Duty") and player:getCompany() then
			player:sendWarning(_("Bitte beende zuerst deinen Dienst im Unternehmen!", player))
			return false
		end
		player:setFactionDuty(true)
		faction:changeSkin(player, preferredSkin or (player.m_tblClientSettings and player.m_tblClientSettings["LastFactionSkin"]))
		player:setHealth(100)
		player:setArmor(100)
		player:sendInfo(_("Du bist nun als Gangmitglied gekennzeichnet!", player))
		if not wastedOrNotOnMarker then faction:updateDutyGUI(player) end
	end


end

function FactionEvil:Event_toggleDuty(wasted, preferredSkin)
	if wasted then client:removeFromVehicle() end

	if getPedOccupiedVehicle(client) then
		return client:sendError("Steige erst aus dem Fahrzeug aus!")
	end
	local faction = client:getFaction()
	if faction:isEvilFaction() then
		if wasted or (client.m_CurrentDutyPickup and getDistanceBetweenPoints3D(client.position, client.m_CurrentDutyPickup.position) <= 10) then
			self:setPlayerDuty(client, not client:isFactionDuty(), wasted, preferredSkin)
		else
			client:sendError(_("Du bist zu weit entfernt!", client))
		end
	else
		client:sendError(_("Du bist in keiner Gang / Mafia!", client))
		return false
	end
end

function FactionEvil:Event_FactionRearm()
	if client:isFactionDuty() then
		client.m_WeaponStoragePosition = client.position
		client:triggerEvent("showFactionWeaponShopGUI")
		client:setHealth(100)
		client:setArmor(100)
		local wStorage, aStorage
		for i = 1,12 do
			wStorage, aStorage = Guns:getSingleton():getWeaponInStorage( client, i)
			if wStorage then
				Guns:getSingleton():setWeaponInStorage(client, wStorage, false)
			end
		end
	end
end


function FactionEvil:Event_storageWeapons(player)
	local client = client
	if player and isElement(player) then
		client = player
	end
	local faction = client:getFaction()
	if faction and faction:isEvilFaction() then
		if client:isFactionDuty() then
			local depot = faction:getDepot()
			local logData = {}
			for i= 1, 12 do
				if client:getWeapon(i) > 0 then
					local weaponId = client:getWeapon(i)
					local clipAmmo = getWeaponProperty(weaponId, "pro", "maximum_clip_ammo") or 0
					if WEAPON_CLIPS[weaponId] then
						clipAmmo = WEAPON_CLIPS[weaponId]
					end

					local magazines = clipAmmo > 0 and math.floor(client:getTotalAmmo(i)/clipAmmo) or 0

					local depotWeapons, depotMagazines = faction:getDepot():getWeapon(weaponId)
					local depotMaxWeapons, depotMaxMagazines = faction.m_WeaponDepotInfo[weaponId]["Waffe"], faction.m_WeaponDepotInfo[weaponId]["Magazine"]
					if depotWeapons+1 <= depotMaxWeapons then
						if magazines > 0 and depotMagazines + magazines <= depotMaxMagazines or WEAPON_PROJECTILE[weaponId] then
							depot:addWeaponD(weaponId, 1)
							depot:addMagazineD(weaponId, magazines)
							takeWeapon(client, weaponId)
							logData[WEAPON_NAMES[weaponId]] = magazines
						elseif magazines > 0 then
							local magsToMax = depotMaxMagazines - depotMagazines
							depot:addMagazineD(weaponId, magsToMax)
							setWeaponAmmo(client, weaponId, getPedTotalAmmo(client, i) - magsToMax*clipAmmo)
							logData[WEAPON_NAMES[weaponId]] = magsToMax
							client:sendError(_("Im Depot ist nicht Platz für %s %s Magazin/e! Es wurden nur %s Magazine eingelagert.", client, magazines, WEAPON_NAMES[weaponId], magsToMax))
						end
					else
						client:sendError(_("Im Depot ist nicht Platz für eine/n %s!", client, WEAPON_NAMES[weaponId]))
					end
				end
			end
			local textForPlayer = "Du hast folgende Waffen in das Lager gelegt:"
			local wepaponsPut = false
			for i,v in pairs(logData) do
				wepaponsPut = true
				textForPlayer = textForPlayer.."\n"..i
				if v > 0 then
					textForPlayer = textForPlayer.. " mit ".. v .. " Magazin(en)"
					faction:addLog(client, "Waffenlager", ("hat ein/e(n) %s mit %s Magazin(en) in das Lager gelegt!"):format(i, v))
				else
					faction:addLog(client, "Waffenlager", ("hat ein/e(n) %s in das Lager gelegt!"):format(i))
				end
			end
			if wepaponsPut then client:sendInfo(textForPlayer) end
		end
	end
end
