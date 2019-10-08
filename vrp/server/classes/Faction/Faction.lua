-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Faction.lua
-- *  PURPOSE:     Base Faction Super Class
-- *
-- ****************************************************************************

Faction = inherit(Object)

-- implement by children

function Faction:constructor(Id, name_short, name_shorter, name, bankAccountId, players, rankLoans, rankSkins, rankWeapons, depotId, factionType, diplomacy)
	self.m_Id = Id
	self.m_Name_Short = name_short
	self.m_ShorterName = name_shorter
	self.m_Name = name
	self.m_Players = players[1]
	self.m_PlayerLoans = players[2]
	self.m_PlayerActivity = {}
	self.m_LastActivityUpdate = 0
	self.m_BankAccount = BankAccount.load(bankAccountId) or BankAccount.create(BankAccountTypes.Faction, self:getId())
	self.m_Settings = UserGroupSettings:new(USER_GROUP_TYPES.Faction, Id)
	self.m_Invitations = {}
	self.m_RankNames = factionRankNames[Id]
	self.m_Skins = factionSkins[Id]
	self.m_SpecialSkin = false
	for i, v in pairs(self.m_Skins) do if tonumber(self:getSetting("Skin", i, 0)) == -1 then self.m_SpecialSkin = i end end
	self.m_ValidWeapons = factionWeapons[Id]
	self.m_Color = factionColors[Id]
	self.m_WeaponDepotInfo = factionType == "State" and factionWeaponDepotInfoState or factionWeaponDepotInfo
	self.m_Countdowns = {}

	self.m_Vehicles = {}

	if rankLoans == "" then	rankLoans = {} for i=0,6 do rankLoans[i] = 0 end rankLoans = toJSON(rankLoans) outputDebug("Created RankLoans for faction "..Id) end
	if rankSkins == "" then	rankSkins = {} for i=0,6 do rankSkins[i] = self:getRandomSkin() end rankSkins = toJSON(rankSkins) outputDebug("Created RankSkins for faction "..Id) end
	if rankWeapons == "" then rankWeapons = {} for i=0,6 do rankWeapons[i] = {} for wi=0,46 do rankWeapons[i][wi] = 0 end end rankWeapons = toJSON(rankWeapons) outputDebug("Created RankWeapons for faction "..Id) end

	self.m_RankWeapons = fromJSON(rankWeapons)
	self.m_RankLoans = fromJSON(rankLoans)
	self.m_RankSkins = fromJSON(rankSkins)
	self.m_Type = factionType

	self.m_Depot = Depot.load(depotId, self, "faction")

	self.m_PhoneNumber = (PhoneNumber.load(2, self.m_Id) or PhoneNumber.generateNumber(2, self.m_Id))
	self.m_PhoneTakeOff = bind(self.phoneTakeOff, self)

	self.m_VehicleTexture = false

	self.m_DiplomacyJSON = diplomacy

	if not DEBUG then
		Async.create(
			function(self)
				self:getActivity()
			end
		)(self)
	end
	self:checkEquipmentPermissions()
end

function Faction:destructor()
	if self.m_BankAccount then
		delete(self.m_BankAccount)
	end
	self.m_Depot:save()
	self:save()
end

function Faction:getRequiredForumPermissionsChanges(playerId)
	local forumId = Account.getBoardIdFromId(playerId)

	Forum:getSingleton():userGet(forumId, Async.waitFor(self))
	local result = Async.wait()
	local data = fromJSON(result)

	if data["status"] == 200 then
		local groups = data["data"]["groups"]
		local currentGroups = {}

		for _, v in pairs(groups) do
			if not table.find(currentGroups, v["groupID"]) then
				table.insert(currentGroups, v["groupID"])
			end
		end

		local rank = self:getPlayerRank(playerId)
		local modifications = {
			add = {},
			remove = {}
		}

		if rank and self.m_Permissions["forum"] and self.m_Permissions["forum"]["ranks"] then
			local newGroups = self.m_Permissions["forum"]["ranks"][tostring(rank)]

			if type(newGroups) == "table" then
				newGroups = table.copy(newGroups)
			else
				newGroups = {newGroups}
			end

			for _, groupId in pairs(currentGroups) do
				local isFactionGroup = table.find(self.m_ForumGroups, groupId) and true or false
				local isNewGroup = table.find(newGroups, groupId) and true or false

				if isFactionGroup and not isNewGroup then
					table.insert(modifications.remove, groupId)
				elseif isNewGroup then
					table.removevalue(newGroups, groupId)
				end
			end

			for _, groupId in pairs(newGroups) do
				table.insert(modifications.add, groupId)
			end
		else
			for _, groupId in pairs(currentGroups) do
				local isFactionGroup = table.find(self.m_ForumGroups, groupId) and true or false

				if isFactionGroup then
					table.insert(modifications.remove, groupId)
				end
			end
		end

		return modifications
	else
		outputDebugString("[Faction@getRequiredForumPermissionsChanges]Can't determinant changes for the user " .. tostring(playerId))
	end
	return false
end

function Faction:save()
	local diplomacy = ""
	if self.m_Diplomacy then
		diplomacy = toJSON({["Status"] = self.m_Diplomacy, ["Requests"] = self.m_DiplomacyRequests, ["Permissions"] = self.m_DiplomacyPermissions or {}})
	end
	if self.m_Settings then
		self.m_Settings:save()
	end
	if sql:queryExec("UPDATE ??_factions SET RankLoans = ?, RankSkins = ?, RankWeapons = ?, BankAccount = ?, Diplomacy = ? WHERE Id = ?", sql:getPrefix(), toJSON(self.m_RankLoans), toJSON(self.m_RankSkins), toJSON(self.m_RankWeapons), self.m_BankAccount:getId(), diplomacy, self.m_Id) then
	else
		outputDebug(("Failed to save Faction '%s' (Id: %d)"):format(self:getName(), self:getId()))
	end
end

function Faction:isStateFaction()
	if self.m_Type == "State" then
		return true
	end
	return false
end

function Faction:setDepotId(Id)
	self.m_Depot = Depot.load(Id, self, "faction")
end

function Faction:isRescueFaction()
	if self.m_Type == "Rescue" then
		return true
	end
	return false
end

function Faction:isEvilFaction()
	if self.m_Type == "Evil" then
		return true
	end
	return false
end

function Faction:setSetting(category, key, value, responsiblePlayer)
	local allowed = true
	if responsiblePlayer and isElement(responsiblePlayer) and getElementType(responsiblePlayer) == "player" then
		if not responsiblePlayer:getFaction() then allowed = false end
		if responsiblePlayer:getFaction() ~= self then allowed = false end
		if self:getPlayerRank(responsiblePlayer) ~= FactionRank.Leader then allowed = false end
	end
	if allowed then
		self.m_Settings:setSetting(category, key, value)
	else
		responsiblePlayer:sendError(_("Nur Leader (Rang %s) der Fraktion %s können deren Einstellungen ändern!", responsiblePlayer, FactionRank.Leader, self:getShortName()))
	end
end

function Faction:getSetting(category, key, defaultValue)
	return self.m_Settings:getSetting(category, key, defaultValue)
end

function Faction:giveKarmaToOnlineMembers(karma, reason)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:giveKarma(karma)
		player:sendShortMessage(_("%s\nDu hast %d Karma erhalten!", player, reason, karma), "Karma")
	end
end

function Faction:getType()
	return self.m_Type
end

function Faction:getColor()
	return self.m_Color
end

function Faction:getId()
	return self.m_Id
end

function Faction:getName()
	return self.m_Name
end

function Faction:getShortName()
	return self.m_Name_Short
end

function Faction:getRankName(rank)
	return self.m_RankNames[rank]
end

function Faction:getRankNames()
	return self.m_RankNames
end

function Faction:getDepot()
	return self.m_Depot
end

function Faction:getPhoneNumber()
	return self.m_PhoneNumber:getNumber()
end

function Faction:getRandomSkin()
	local i = 1
	local skins = {}
	for skinId,bool in pairs(self.m_Skins) do
		if bool == true then
			skins[i] = skinId
			i = i+1
		end
	end
	return skins[math.random(1,#skins)]
end

function Faction:getAllSkins()
	local tab = {}
	for skinId in pairs(self.m_Skins) do
		tab[skinId] = tonumber(self:getSetting("Skin", skinId, 0))
	end
	return tab
end

function Faction:getSkinsForRank(rank)
	local tab = {}
	local rank = tonumber(rank)
	if rank then
		for skinId in pairs(self.m_Skins) do
			if tonumber(self:getSetting("Skin", skinId, 0)) <= rank then
				table.insert(tab, skinId)
			end
		end
	end
	return tab
end

function Faction:changeSkin(player, skinId)
	if not player or not isElement(player) or getElementType(player) ~= "player" then return false end
	local playerRank = self:getPlayerRank(player)
	if not skinId then skinId = self:getSkinsForRank(playerRank)[1] end
	if player:isFactionDuty() then
		if self.m_Skins[skinId] then
			local minRank = tonumber(self:getSetting("Skin", skinId, 0))
			if minRank <= playerRank then
				player:setModel(skinId)
				player.m_tblClientSettings["LastFactionSkin"] = skinId
			else
				player:sendWarning(_("Deine ausgewählte Kleidung ist erst ab Rang %s verfügbar, dir wurde eine andere gegeben.", player, minRank))
				player:setModel(self:getSkinsForRank(playerRank)[1])
			end
		else
			--player:sendWarning(_("Deine ausgewählte Kleidung ist nicht mehr verfügbar, dir wurde eine andere gegeben.", player, minRank))
			-- ^useless if player switches faction
			player:setModel(self:getSkinsForRank(playerRank)[1])
		end
	else
		player:sendError(_("Du bist nicht im Dienst deiner Fraktion aktiv!", player))
	end
end

function Faction:updateDutyGUI(player)
	if player:getFaction() and not player:isDead() then
		player:triggerEvent("showDutyGUI", true, player:getFaction():getId(), player:isFactionDuty(), self.m_SpecialSkin)
	end
end

function Faction:addPlayer(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	rank = rank or 0
	self.m_Players[playerId] = rank
	self.m_PlayerLoans[playerId] = 1
	local player = Player.getFromId(playerId)
	if player then
		player:setFaction(self)
		player:reloadBlips()
		player:giveAchievement(68) -- Parteiisch
		if self.m_Name_Short == "SAPD" then
			player:giveAchievement(9) -- Gutes blaues Männchen
		end
		bindKey(player, "y", "down", "chatbox", "Fraktion")
	end
	sql:queryExec("UPDATE ??_character SET FactionId = ?, FactionRank = ?, FactionLoanEnabled = 1 WHERE Id = ?", sql:getPrefix(), self.m_Id, rank, playerId)

	Async.create(
		function(self)
			self:getActivity(true)
		end
	)(self)
end

function Faction:removePlayer(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = nil
	self.m_PlayerLoans[playerId] = nil
	local player = Player.getFromId(playerId)
	if player then
		player:setFaction(nil)
		player:giveAchievement(67)
		player:setCorrectSkin()
		player:setFactionDuty(false)
		player:sendShortMessage(_("Du wurdest aus deiner Fraktion entlassen!", player))
		self:sendShortMessage(_("%s hat deine Fraktion verlassen!", player, player:getName()))
		if self:isStateFaction() and player:isFactionDuty() then
			takeAllWeapons(player)
			player:reloadBlips()
		end
		player:reloadBlips()
		unbindKey(player, "y", "down", "chatbox", "Fraktion")
	end
	sql:queryExec("UPDATE ??_character SET FactionId = 0, FactionRank = 0, FactionLoanEnabled = 0 WHERE Id = ?", sql:getPrefix(), playerId)
end

function Faction:invitePlayer(player)
  client:sendShortMessage(("Du hast %s erfolgreich in die Fraktion eingeladen."):format(getPlayerName(player)))
	player:triggerEvent("factionInvitationRetrieve", self:getId(), self:getName())

	self.m_Invitations[player] = client.m_Id
end

function Faction:removeInvitation(player)
	self.m_Invitations[player] = nil
end

function Faction:hasInvitation(player)
	return self.m_Invitations[player]
end

function Faction:isPlayerMember(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	return self.m_Players[playerId] ~= nil
end

function Faction:getPlayerRank(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	return self.m_Players[playerId]
end

function Faction:setPlayerRank(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end
	local player = Player.getFromId(playerId)
	if rank == 6 then
		player:giveAchievement(66)
	end

	self.m_Players[playerId] = rank
	if self:isEvilFaction() then
		if player and player.isFactionDuty and player:isFactionDuty() then
			self:changeSkin(player)
		end
	end
	--if isOffline then
	--	delete(player)
	--end
	sql:queryExec("UPDATE ??_character SET FactionRank = ? WHERE Id = ?", sql:getPrefix(), rank, playerId)
end

function Faction:isPlayerLoanEnabled(playerId)
	return self.m_PlayerLoans[playerId] == 1
end

function Faction:setPlayerLoanEnabled(playerId, state)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_PlayerLoans[playerId] = state
	sql:queryExec("UPDATE ??_character SET FactionLoanEnabled = ? WHERE Id = ?", sql:getPrefix(), state, playerId)
end

function Faction:getMoney()
	return self.m_BankAccount:getMoney()
end

function Faction:__giveMoney(amount, reason, silent)
	StatisticsLogger:getSingleton():addMoneyLog("faction", self, amount, reason or "Unbekannt")
	return self.m_BankAccount:__giveMoney(amount, reason, silent)
end

function Faction:__takeMoney(amount, reason, silent)
	StatisticsLogger:getSingleton():addMoneyLog("faction", self, -amount, reason or "Unbekannt")
	return self.m_BankAccount:__takeMoney(amount, reason, silent)
end

function Faction:transferMoney(...)
	return self.m_BankAccount:transferMoney(...)
end

function Faction:setRankLoan(rank,amount)
	self.m_RankLoans[tostring(rank)] = amount
end

function Faction:paydayPlayer(player)
	local rank = self.m_Players[player:getId()]
	local loanEnabled = self:isPlayerLoanEnabled(player:getId())
	local loan = loanEnabled and tonumber(self.m_RankLoans[tostring(rank)]) or 0

	if self.m_BankAccount:getMoney() < loan then loan = self.m_BankAccount:getMoney() end
	if loan < 0 then loan = 0 end
	return loan
end

function Faction:setRankSkin(rank,skinId)
	self.m_RankSkins[tostring(rank)] = skinId
end

function Faction:setRankWeapons(rank,weaponsTable)
	self.m_RankWeapons[tostring(rank)] = weaponsTable
end

function Faction:getRankWeapons(rank)
	return self.m_RankWeapons[tostring(rank)]
end

function Faction:getActivity(force)
	if self.m_LastActivityUpdate > getRealTime().timestamp - 30 * 60 and not force then
		return
	end

	self.m_LastActivityUpdate = getRealTime().timestamp
	local playerIds = {}

	for playerId, rank in pairs(self.m_Players) do
		table.insert(playerIds, playerId)
	end

	local query = "SELECT UserID, FLOOR(SUM(Duration) / 60) AS Activity FROM ??_accountActivity WHERE UserID IN (?" .. string.rep(", ?", #playerIds - 1) ..  ") AND Date BETWEEN DATE(DATE_SUB(NOW(), INTERVAL 1 WEEK)) AND DATE(NOW()) GROUP BY UserID"

	sql:queryFetch(Async.waitFor(), query, sql:getPrefix(), unpack(playerIds))

	local rows = Async.wait()

	self.m_PlayerActivity = {}
	for playerId, rank in pairs(self.m_Players) do
		self.m_PlayerActivity[playerId] = 0
	end

	for _, row in ipairs(rows) do
		local activity = 0

		if row and row.Activity then
			activity = row.Activity
		end

		self.m_PlayerActivity[row.UserID] = activity
	end
end

function Faction:getPlayers(getIDsOnly)
	if getIDsOnly then
		return self.m_Players
	end
	local temp = {}

	Async.create(
		function(self)
			self:getActivity()
		end
	)(self)

	for playerId, rank in pairs(self.m_Players) do
		local loanEnabled = self.m_PlayerLoans[playerId]
		local activity = self.m_PlayerActivity[playerId] or 0

		temp[playerId] = {name = Account.getNameFromId(playerId), rank = rank, loanEnabled = loanEnabled, activity = activity}
	end
	return temp
end

function Faction:getOnlinePlayers(afkCheck, dutyCheck)
	local players = {}
	for playerId in pairs(self.m_Players) do
		local player = Player.getFromId(playerId)
		if player and isElement(player) and player:isLoggedIn() then
			if (not afkCheck or not player.m_isAFK) and (not dutyCheck or player:isFactionDuty()) then
				players[#players + 1] = player
			end
		end
	end
	return players
end

function Faction:sendMessage(text, r, g, b, ...)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function Faction:sendShortMessage(text, ...)
	local color = {factionColors[self.m_Id].r, factionColors[self.m_Id].g, factionColors[self.m_Id].b}
	for k, player in pairs(self:getOnlinePlayers()) do
		player:sendShortMessage(_(text, player), self:getName(), color, ...)
	end
end

function Faction:sendWarning(text, header, withOffDuty, pos, ...)
	for k, player in pairs(self:getOnlinePlayers(false, not withOffDuty)) do
		player:sendWarning(_(text, player, ...), 30000, header)
	end
	if pos and pos[1] and pos[2] then
		local fType = self:getType()
		local blip = Blip:new(fType == "State" and "Alarm.png" or fType == "Evil" and "Gangwar.png" or fType == "Rescue" and "Fire.png",
			pos[1], pos[2], {faction = self:getId(), duty = (not withOffDuty)}, 4000, BLIP_COLOR_CONSTANTS.Orange)
			blip:setDisplayText(header)
		if pos[3] then
			blip:setZ(pos[3])
		end
		setTimer(function()
			blip:delete()
		end, 30000, 1)
	end
end

function Faction:sendSuccess(text)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:sendSuccess(text)
	end
end

function Faction:sendChatMessage(sourcePlayer, message)
	if not getElementData(sourcePlayer, "FactionChatEnabled") then return sourcePlayer:sendError(_("Du hast den Fraktionschat deaktiviert!", sourcePlayer)) end
	--if self:isEvilFaction() or (self:isStateFaction() or self:isRescueFaction() and sourcePlayer:isFactionDuty()) then
		local lastMsg, msgTimeSent = sourcePlayer:getLastChatMessage()
		if getTickCount()-msgTimeSent < (message == lastMsg and CHAT_SAME_MSG_REPEAT_COOLDOWN or CHAT_MSG_REPEAT_COOLDOWN) then -- prevent chat spam
			cancelEvent()
			return
		end
		sourcePlayer:setLastChatMessage(message)

		local playerId = sourcePlayer:getId()
		local rank = self.m_Players[playerId]
		local rankName = self.m_RankNames[rank]
		local receivedPlayers = {}
		local r,g,b = self.m_Color["r"],self.m_Color["g"],self.m_Color["b"]
		message = message:gsub("%%", "%%%%")
		local text = ("%s %s: %s"):format(rankName,getPlayerName(sourcePlayer), message)
		for k, player in ipairs(self:getOnlinePlayers()) do
			if getElementData(player, "FactionChatEnabled") then
				player:sendMessage(text, r, g, b)
			end
			if player ~= sourcePlayer then
	            receivedPlayers[#receivedPlayers+1] = player
	        end
		end
		StatisticsLogger:getSingleton():addChatLog(sourcePlayer, "faction:"..self.m_Id, message, receivedPlayers)
	--else
	--	sourcePlayer:sendError(_("Du bist nicht im Dienst!", sourcePlayer))
	--end
end

function Faction:sendBndChatMessage(sourcePlayer, message, alliance)
	if not getElementData(sourcePlayer, "AllianceChatEnabled") then return sourcePlayer:sendError(_("Du hast den Bündnischat deaktiviert!", sourcePlayer)) end
	local playerId = sourcePlayer:getId()
	local receivedPlayers = {}
	local r,g,b = 20, 140, 0
	local text = ("[Bündnis] %s: %s"):format(getPlayerName(sourcePlayer), message)
	for k, player in ipairs(self:getOnlinePlayers()) do
		if getElementData(player, "AllianceChatEnabled") then
			player:sendMessage(text, r, g, b)
		end
		if player ~= sourcePlayer then
			receivedPlayers[#receivedPlayers+1] = player
		end
	end
	StatisticsLogger:getSingleton():addChatLog(sourcePlayer, "factionBnd:"..self.m_Id, message, receivedPlayers)
end

function Faction:respawnVehicles(isAdmin)
	local time = getRealTime().timestamp
	if self.m_LastRespawn and not isAdmin then
		if time - self.m_LastRespawn <= 900 then --// 15min
			return self:sendShortMessage("Fahrzeuge können nur alle 15 Minuten respawned werden!")
		end
	end
	if isAdmin then
		self:sendShortMessage("Ein Admin hat eure Fraktionsfahrzeuge respawned!")
		isAdmin:sendShortMessage("Du hast die Fraktionsfahrzeuge respawned!")
	end
	local factionVehicles = VehicleManager:getSingleton():getFactionVehicles(self.m_Id)
	local fails = 0
	local vehicles = 0
	for factionId, vehicle in pairs(factionVehicles) do
		if vehicle:getFaction() == self then
			vehicles = vehicles + 1
			if not vehicle:respawn(true, isAdmin and true or false) then
				fails = fails + 1
			else
				vehicle:setInterior(vehicle.m_SpawnInt or 0)
				vehicle:setDimension(vehicle.m_SpawnDim or 0)
			end
			self.m_LastRespawn = getRealTime().timestamp
		end
	end

	self:sendShortMessage(("%s/%s Fahrzeuge wurden respawned!"):format(vehicles-fails, vehicles))
end

function Faction:phoneCall(caller)
	for k, player in ipairs(self:getOnlinePlayers()) do
		if not player:getPhonePartner() then
			if player ~= caller then
				local color = {factionColors[self.m_Id].r, factionColors[self.m_Id].g, factionColors[self.m_Id].b}
				triggerClientEvent(player, "callIncomingSM", resourceRoot, caller, false, ("%s ruft euch an."):format(caller:getName()), ("eingehender Anruf - %s"):format(self:getShortName()), color)
			end
		end
	end
end

function Faction:phoneCallAbbort(caller)
	for k, player in ipairs(self:getOnlinePlayers()) do
		triggerClientEvent(player, "callRemoveSM", resourceRoot, caller, false)
	end
end

function Faction:phoneTakeOff(player, caller, voiceCall)
	if player and caller then
		if instanceof(caller, Player) and instanceof(player, Player) then -- check if we can call methods from the Player-class
			if player.m_PhoneOn == false then
				player:sendError(_("Dein Telefon ist ausgeschaltet!", player))
				return
			end
			if player:getPhonePartner() then
				player:sendError(_("Du telefonierst bereits!", player))
				return
			end
			caller:triggerEvent("callAnswer", player, voiceCall)
			player:triggerEvent("callAnswer", caller, voiceCall)
			self:addLog(player, "Anrufe", ("hat ein Telefonat mit %s geführt!"):format(caller:getName()))
			caller:setPhonePartner(player)
			player:setPhonePartner(caller)
			for k, factionPlayer in ipairs(self:getOnlinePlayers()) do
				triggerClientEvent(factionPlayer, "callRemoveSM", resourceRoot, caller, player)
			end
		end
	end
end

function Faction:addLog(player, category, text)
	StatisticsLogger:getSingleton():addGroupLog(player, "faction", self, category, text)
end

function Faction:getLog()
	return StatisticsLogger:getSingleton():getGroupLogs("faction", self.m_Id)
end

function Faction:setSafe(obj)
	self.m_Safe = obj
	self.m_Safe:setData("clickable",true,true)
	addEventHandler("onElementClicked", self.m_Safe, function(button, state, player)
		if button == "left" and state == "down" then
			if player:getFaction() and player:getFaction() == self or (player:getFaction() and player:getFaction():isStateFaction() and self:isStateFaction()) then
				player:triggerEvent("bankAccountGUIShow", self:getName(), "factionDeposit", "factionWithdraw")
				self:refreshBankAccountGUI(player)
			else
				player:sendError(_("Du bist nicht in der richtigen Fraktion", player))
			end
		end
	end)
	ElementInfo:new(obj, "Fraktionskasse")
end


function Faction:refreshBankAccountGUI(player)
	player:triggerEvent("bankAccountGUIRefresh", self:getMoney())
end

function Faction:loadDiplomacy()
	if self.m_DiplomacyJSON and self.m_DiplomacyJSON ~= "" then
		local dbTable = fromJSON(self.m_DiplomacyJSON)
		if dbTable and dbTable["Status"] and dbTable["Requests"] and dbTable["Permissions"] then
			self.m_Diplomacy = dbTable["Status"]
			self.m_DiplomacyRequests = dbTable["Requests"]
			self.m_DiplomacyPermissions = dbTable["Permissions"]
		else
			self.m_DiplomacyJSON = nil
			self:loadDiplomacy()
		end
	else
		self.m_Diplomacy = {}
		self.m_DiplomacyRequests = {}
		self.m_DiplomacyPermissions = {}
		for Id, faction in pairs(FactionManager:getSingleton():getAllFactions()) do
			if faction:isEvilFaction() and faction ~= self then
				self:changeDiplomacy(faction, FACTION_DIPLOMACY.Waffenstillstand)
			end
		end
	end
end

function Faction:getDiplomacy(targetFaction)
	local factionId, status
	for index, data in pairs(self.m_Diplomacy) do
		factionId, status = unpack(data)
		if factionId == targetFaction:getId() then
			return status
		end
	end
end

function Faction:getAllianceFaction()
	local factionId, status
	if not self.m_Diplomacy then return false end
	for index, data in pairs(self.m_Diplomacy) do
		factionId, status = unpack(data)
		if status == FACTION_DIPLOMACY["Verbündet"] then
			if FactionManager:getSingleton():getFromId(factionId) then
				return FactionManager:getSingleton():getFromId(factionId)
			end
		end
	end
	return false
end

function Faction:checkAlliancePermission(targetFaction, permission)
	if not self.m_Diplomacy then return false end

	if self:getAllianceFaction() == targetFaction then
		if table.find(self.m_DiplomacyPermissions, permission) then
			return true
		end
	end
	return false
end

function Faction:changeDiplomacy(targetFaction, diplomacy, player)
	local factionId, status
	for index, data in pairs(self.m_Diplomacy) do
		factionId, status = unpack(data)
		if factionId == targetFaction:getId() then
			self.m_Diplomacy[index] = {factionId, diplomacy}
			if player then
				self:sendShortMessage(("%s hat den Diplomatiestatus mit den %s zu '%s' geändert!"):format(player:getName(), targetFaction:getName(), FACTION_DIPLOMACY[diplomacy]))
			end

			for index, player in pairs(self:getOnlinePlayers()) do
				player:reloadBlips()
			end
			for index, player in pairs(targetFaction:getOnlinePlayers()) do
				player:reloadBlips()
			end

			for index, data in pairs(self.m_DiplomacyRequests) do
				if (data["target"] == self and data["source"] == targetFaction) or (data["source"] == self and data["target"] == targetFaction) then
					self.m_DiplomacyRequests[index] = nil
				end
			end
			return
		end
	end
	table.insert(self.m_Diplomacy, {targetFaction:getId(), diplomacy})
	outputDebugString(("Created Diplomacy for %s and %s - Status: %s"):format(self:getShortName(), targetFaction:getShortName(), FACTION_DIPLOMACY[diplomacy] or "Unknown"))
end

function Faction:createDiplomacyRequest(sourceFaction, targetFaction, diplomacy, player)
	local request = {
		["source"] = sourceFaction:getId(),
		["target"] = targetFaction:getId(),
		["status"] = diplomacy,
		["player"] = player:getId(),
		["timestamp"] = getRealTime().timestamp
	}
	table.insert(self.m_DiplomacyRequests, request)
	if player and sourceFaction == self then
		self:sendShortMessage(("%s hat der Fraktion %s eine %s-Anfrage gesendet!"):format(player:getName(), targetFaction:getName(), FACTION_DIPLOMACY[diplomacy]))
	elseif player and targetFaction == self then
		targetFaction:sendShortMessage(("Die Fraktion %s hat euch eine %s-Anfrage gesendet!"):format(sourceFaction:getName(), FACTION_DIPLOMACY[diplomacy]))
	end
end

function Faction:sendMoveRequest(targetChannel, text)
	for k, player in pairs(self:getOnlinePlayers()) do
		TSConnect:getSingleton():sendMoveRequest(player, targetChannel, text)
	end
end

function Faction:onPlayerJoin(player) -- join means comming online (onPlayerJoin-Event)
	for text, data in pairs(self.m_Countdowns) do
		local time, origin = unpack(data)
		local now = getRealTime().timestamp
		local current = time - (now - origin)
		if current > 0 and current < time then
			player:triggerEvent("Countdown", current, text)
		end
	end
end

function Faction:setCountDown(time, text) -- this can be used to set a countdown for a faction (players that join after this have the right time displayed)
	local players = self:getOnlinePlayers()
	if self.m_Countdowns[text] then
		for index, player in pairs(players) do
			player:triggerEvent("CountdownStop", text)
		end
	end
	self.m_Countdowns[text] = {time, getRealTime().timestamp}
	for index, player in pairs(players) do
		player:triggerEvent("Countdown", time, text)
	end
end

function Faction:stopCountDown(text)
	if self.m_Countdowns[text] then
		local players = self:getOnlinePlayers()
		for index, player in pairs(players) do
			player:triggerEvent("CountdownStop", text)
		end
	end
end

function Faction:getEquipmentPermissions()
	local perms = {}
	for cat, data in pairs(ArmsDealer.Data) do
		if cat ~= "Waffen" then
			for product, subdata in pairs(data) do
				if not subdata[3] then
					perms[product] =  tonumber(self:getSetting("Equipment", product, ArmsDealer.ProhibitedRank[product] or 0))
				end
			end
		end
		perms["metadata"] = {self:getSetting("Equipment", "metadata_author", "-"), self:getSetting("Equipment", "metadata_time", getOpticalTimestamp(getRealTime().timestamp))}
	end
	return perms
end

function Faction:checkEquipmentPermissions()
	local perms = {}
	for cat, data in pairs(ArmsDealer.Data) do
		if cat ~= "Waffen" then
			for product, subdata in pairs(data) do
				if not subdata[3] then
					self:setSetting("Equipment", product, self:getSetting("Equipment", product, ArmsDealer.ProhibitedRank[product] or 0))
				end
			end
		end
		self:setSetting("Equipment", "metadata_author", self:getSetting("Equipment", "metadata_author", "-"))
		self:setSetting("Equipment", "metadata_time", self:getSetting("Equipment", "metadata_time", getOpticalTimestamp(getRealTime().timestamp)))
	end
end

function Faction:updateEquipmentPermissions(player, update)
	for item, rank in pairs(update) do
		self:setSetting("Equipment", item, rank-1, player)
	end
	self:setSetting("Equipment", "metadata_author", player:getName())
	self:setSetting("Equipment", "metadata_time", getOpticalTimestamp(getRealTime().timestamp))
	self:sendShortMessage(("Die Equipment-Ränge wurden von %s aktualisiert!"):format(player:getName()))
	self:addLog(player, "Equipment", "hat die Zugriffe aktualisiert!")
end

function Faction:takeEquipment(player)
	local item, amount, price, id
	local count = 0
	for category, data in pairs(ArmsDealer.Data) do
		if category ~= "Waffen" then
			for product, subdata in pairs(data) do
				amount, price, id = unpack(subdata)
				if not id then
					amount = player:getInventory():getItemAmount(product)
					if amount and amount > 0 then
						player:getInventory():removeAllItem(product)
						self:getDepot():addEquipment(player, product, amount, true)
						count = count + amount
					end
				end
			end
		end
	end
end


function Faction:storageWeapons(player)
	local depot = self:getDepot()
	local logData = {}
	for i= 1, 12 do
		if player:getWeapon(i) > 0 then
			local weaponId = player:getWeapon(i)
			local clipAmmo = getWeaponProperty(weaponId, "pro", "maximum_clip_ammo") or 0
			if WEAPON_CLIPS[weaponId] then
				clipAmmo = WEAPON_CLIPS[weaponId]
			end

			local magazines = clipAmmo > 0 and math.floor(player:getTotalAmmo(i)/clipAmmo) or 0
			if THROWABLE_WEAPONS[weaponId] then -- don't divide by magazine size
				magazines = player:getTotalAmmo(i)
			end

			local depotWeapons, depotMagazines = depot:getWeapon(weaponId)
			local depotMaxWeapons, depotMaxMagazines = self.m_WeaponDepotInfo[weaponId]["Waffe"], self.m_WeaponDepotInfo[weaponId]["Magazine"]

			if depotWeapons == -1 then
				takeWeapon(player, weaponId)
			else

				if THROWABLE_WEAPONS[weaponId] then -- grenade etc
					if depotWeapons+magazines <= depotMaxWeapons then --magazines = duplicates of weapon
						depot:addWeaponD(weaponId, magazines)
						takeWeapon(player, weaponId)
						logData[WEAPON_NAMES[weaponId]] = magazines
					elseif magazines > 0 then
						local weaponsToMax = depotMaxWeapons - depotWeapons
						depot:addWeaponD(weaponId, weaponsToMax)
						setWeaponAmmo(player, weaponId, getPedTotalAmmo(player, i) - weaponsToMax)
						if magsToMax > 0 then
							logData[WEAPON_NAMES[weaponId]] = weaponsToMax
							player:sendError(_("Im Depot ist nicht Platz für %s %s! Es wurden nur %s eingelagert.", player, magazines, WEAPON_NAMES[weaponId], weaponsToMax))
						end
					end
				else
					if depotWeapons+1 <= depotMaxWeapons then
						if depotMagazines + magazines <= depotMaxMagazines then
							depot:addWeaponD(weaponId, 1)
							depot:addMagazineD(weaponId, magazines)
							takeWeapon(player, weaponId)
							logData[WEAPON_NAMES[weaponId]] = magazines
						elseif magazines > 0 then
							local magsToMax = depotMaxMagazines - depotMagazines
							depot:addMagazineD(weaponId, magsToMax)
							setWeaponAmmo(player, weaponId, getPedTotalAmmo(player, i) - magsToMax*clipAmmo)
							if magsToMax > 0 then
								logData[WEAPON_NAMES[weaponId]] = magsToMax
								player:sendError(_("Im Depot ist nicht Platz für %s %s Magazin/e! Es wurden nur %s Magazine eingelagert.", player, magazines, WEAPON_NAMES[weaponId], magsToMax))
							end
						end

					else
						player:sendError(_("Im Depot ist nicht Platz für eine/n %s!", player, WEAPON_NAMES[weaponId]))
					end
				end
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
			self:addLog(player, "Waffenlager", ("hat ein/e(n) %s mit %s Magazin(en) in das Lager gelegt!"):format(i, v))
		else
			self:addLog(player, "Waffenlager", ("hat ein/e(n) %s in das Lager gelegt!"):format(i))
		end
	end
	if wepaponsPut then player:sendInfo(textForPlayer) end
end
