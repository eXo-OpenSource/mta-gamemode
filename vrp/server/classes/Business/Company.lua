-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/Company.lua
-- *  PURPOSE:     Company class
-- *
-- ****************************************************************************
Company = inherit(Object)
Company.DerivedClasses = {}

function Company.onInherit(derivedClass)
  Company.DerivedClasses[#Company.DerivedClasses+1] = derivedClass
end

function Company:constructor(Id, Name, ShortName, ShorterName, Creator, players, lastNameChange, bankAccountId, Settings, rankLoans, rankSkins)
	self.m_Id = Id
	self.m_Name = Name
	self.m_ShortName = ShortName
	self.m_ShorterName = ShorterName
	self.m_Creator = Creator
	self.m_Players = players[1]
	self.m_PlayerLoans = players[2]
	self.m_PlayerActivity = {}
	self.m_LastActivityUpdate = 0
	self.m_LastNameChange = lastNameChange or 0
	self.m_Invitations = {}
	self.m_Vehicles = {}
	self.m_Level = 0
	self.m_RankNames = companyRankNames[Id]
	self.m_Skins = companySkins[Id]
	-- Settings
	self.m_VehiclesCanBeModified = Settings.VehiclesCanBeModified or false

	if rankLoans == "" then rankLoans = {} for i=0,5 do rankLoans[i] = 0 end rankLoans = toJSON(rankLoans) outputDebug("Created RankLoans for company "..Id) end
	if rankSkins == "" then rankSkins = {} for i=0,5 do rankSkins[i] = self:getRandomSkin() end rankSkins = toJSON(rankSkins) outputDebug("Created RankSkins for company "..Id) end

	self.m_RankLoans = fromJSON(rankLoans)
	self.m_RankSkins = fromJSON(rankSkins)

	self.m_BankAccount = BankAccount.load(bankAccountId) or BankAccount.create(BankAccountTypes.Company, self.m_Id)
	self.m_Settings = UserGroupSettings:new(USER_GROUP_TYPES.Company, Id)

	sql:queryExec("UPDATE ??_companies SET BankAccount = ? WHERE Id = ?;", sql:getPrefix(), self.m_BankAccount:getId(), self.m_Id)

	self:createDutyMarker()
	self.m_PhoneNumber = (PhoneNumber.load(3, self.m_Id) or PhoneNumber.generateNumber(3, self.m_Id))
	self.m_PhoneTakeOff = bind(self.phoneTakeOff, self)

	self.m_VehicleTexture = companyVehicleShaders[Id] or false

	if not DEBUG then
		self:getActivity()
	end
end

function Company:destructor()
  if self.m_BankAccount then
    delete(self.m_BankAccount)
  end

  self:save()
end

function Company:save()
    local Settings = {
      VehiclesCanBeModified = self.m_VehiclesCanBeModified
    }
	if self.m_Settings then
		self.m_Settings:save()
	end
    sql:queryExec("UPDATE ??_companies SET RankLoans = ?, RankSkins = ?, Settings = ? WHERE Id = ?",sql:getPrefix(),toJSON(self.m_RankLoans),toJSON(self.m_RankSkins),toJSON(Settings),self.m_Id)
end

function Company:virtual_constructor(...)
  Company.constructor(self, ...)
end

function Company:virtual_destructor(...)
  Company.destructor(self, ...)
end

function Company.create(Name, Creator)
  if sql:queryExec("INSERT INTO ??_companies(Name, Creator) VALUES(?, ?);", sql:getPrefix(), Name, Creator:getName()) then
    local company = Company:new(sql:lastInsertId(), Name)

    -- Add refernece
    CompanyManager:getSingleton():addRef(company)

    return company
  end
  return false
end

function Company:purge()
  if sql:queryExec("DELETE FROM ??_groups WHERE Id = ?", sql:getPrefix(), self.m_Id) then
    -- Remove all players
    for playerId in pairs(self.m_Players) do
      self:removePlayer(playerId)
    end

    -- Remove reference
    CompanyManager:getSingleton():removeRef(self)

    return true
	end
	return false
end

function Company:getId()
  return self.m_Id
end

function Company:setName(Name)
  local timestamp = getRealTime().timestamp
  if not sql:queryExec("UPDATE ??_companies SET Name = ?, lastNameChange = ? WHERE Id = ?", sql:getPrefix(), Name, timestamp, self:getId()) then
    return false
  end

  self.m_Name = Name
  self.m_LastNameChange = timestamp
end

function Company:getName()
  return self.m_Name
end

function Company:getShortName()
  return self.m_ShortName
end

function Company:setMoney(...)
  return self.m_BankAccount:setMoney(...)
end

function Company:getMoney(...)
  return self.m_BankAccount:getMoney(...)
end

function Company:__giveMoney(amount, reason, silent)
    StatisticsLogger:getSingleton():addMoneyLog("company", self, amount, reason or "Unbekannt")
    return self.m_BankAccount:__giveMoney(amount, reason, silent)
end

function Company:__takeMoney(amount, reason, silent)
    StatisticsLogger:getSingleton():addMoneyLog("company", self, -amount, reason or "Unbekannt")
    return self.m_BankAccount:__takeMoney(amount, reason, silent)
end

function Company:transferMoney(...)
	return self.m_BankAccount:transferMoney(...)
end

function Company:setSetting(category, key, value, responsiblePlayer)
	local allowed = true
	if responsiblePlayer and isElement(responsiblePlayer) and getElementType(responsiblePlayer) == "player" then
		if not responsiblePlayer:getCompany() then allowed = false end 
		if responsiblePlayer:getCompany() ~= self then allowed = false end 
		if self:getPlayerRank(responsiblePlayer) ~= CompanyRank.Leader then allowed = false end 
	end
	if allowed then
		self.m_Settings:setSetting(category, key, value)
	else
		responsiblePlayer:sendError(_("Nur Leader (Rang %s) des Unternehmens %s können deren Einstellungen ändern!", responsiblePlayer, CompanyRank.Leader, self:getShortName()))
	end
end

function Company:getSetting(category, key, defaultValue)
	return self.m_Settings:getSetting(category, key, defaultValue)
end

function Company:getPhoneNumber()
	return self.m_PhoneNumber:getNumber()
end

function Company:addPlayer(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	rank = rank or 0
	self.m_Players[playerId] = rank
	self.m_PlayerLoans[playerId] = 1
	local player = Player.getFromId(playerId)
	if player then
		player:setCompany(self)
		player:reloadBlips()
	end

	sql:queryExec("UPDATE ??_character SET CompanyId = ?, CompanyRank = ?, CompanyLoanEnabled = 1 WHERE Id = ?", sql:getPrefix(), self.m_Id, rank, playerId)

  if self.onPlayerJoin then -- Only for Companies with own class
    self:onPlayerJoin(playerId, rank)
  end

  self:getActivity(true)
end

function Company:removePlayer(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = nil
	self.m_PlayerLoans[playerId] = nil
	local player = Player.getFromId(playerId)
	if player then
		player:setCompany(nil)
		player:reloadBlips()
		player:sendShortMessage(_("Du wurdest aus deinem Unternehmen entlassen!", player))
		self:sendShortMessage(_("%s hat dein Unternehmen verlassen!", player, player:getName()))
	end

	sql:queryExec("UPDATE ??_character SET CompanyId = 0, CompanyRank = 0, CompanyLoanEnabled = 0 WHERE Id = ?", sql:getPrefix(), playerId)

	if self.onPlayerLeft then -- Only for Companies with own class
		self:onPlayerLeft(playerId)
	end
end

function Company:getOnlinePlayers()
	local players = {}
	for playerId in pairs(self.m_Players) do
		local player = Player.getFromId(playerId)
		if player and isElement(player) and player:isLoggedIn() then
			players[#players + 1] = player
		end
	end
	return players
end

function Company:getRankName(rank)
	return self.m_RankNames[rank]
end


function Company:sendChatMessage(sourcePlayer,message)
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
	message = message:gsub("%%", "%%%%")
	local text = ("%s %s: %s"):format(rankName, sourcePlayer:getName(), message)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, 100, 150, 250)
        if player ~= sourcePlayer then
            receivedPlayers[#receivedPlayers+1] = player
        end
	end
    StatisticsLogger:getSingleton():addChatLog(sourcePlayer, "company:"..self.m_Id, message, receivedPlayers)
end

function Company:invitePlayer(player)
    client:sendShortMessage(("Du hast %s erfolgreich in dein Unternehmen eingeladen."):format(getPlayerName(player)))
	player:triggerEvent("companyInvitationRetrieve", self:getId(), self:getName())

	self.m_Invitations[player] = client.m_Id
end

function Company:removeInvitation(player)
	self.m_Invitations[player] = nil
end

function Company:hasInvitation(player)
	return self.m_Invitations[player]
end

function Company:isPlayerMember(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	return self.m_Players[playerId] ~= nil
end

function Company:getPlayerRank(playerId)
  if type(playerId) == "userdata" then
    playerId = playerId:getId()
  end

  return self.m_Players[playerId]
end

function Company:setPlayerRank(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = rank
	sql:queryExec("UPDATE ??_character SET CompanyRank = ? WHERE Id = ?", sql:getPrefix(), rank, playerId)
end

function Company:isPlayerLoanEnabled(playerId)
	return self.m_PlayerLoans[playerId] == 1
end

function Company:setPlayerLoanEnabled(playerId, state)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_PlayerLoans[playerId] = state
	sql:queryExec("UPDATE ??_character SET CompanyLoanEnabled = ? WHERE Id = ?", sql:getPrefix(), state, playerId)
end

function Company:getActivity(force)
	if self.m_LastActivityUpdate > getRealTime().timestamp - 30 * 60 and not force then
		return
	end
	self.m_LastActivityUpdate = getRealTime().timestamp

	for playerId, rank in pairs(self.m_Players) do
		local row = sql:queryFetchSingle("SELECT FLOOR(SUM(Duration) / 60) AS Activity FROM ??_accountActivity WHERE UserID = ? AND Date BETWEEN DATE(DATE_SUB(NOW(), INTERVAL 1 WEEK)) AND DATE(NOW());", sql:getPrefix(), playerId)

		local activity = 0

		if row and row.Activity then
			activity = row.Activity
		end

		self.m_PlayerActivity[playerId] = activity
	end
end

function Company:getPlayers(getIDsOnly)
	if getIDsOnly then
		return self.m_Players
	end

	self:getActivity()

	local temp = {}
	for playerId, rank in pairs(self.m_Players) do
		local loanEnabled = self.m_PlayerLoans[playerId]
		local activity = self.m_PlayerActivity[playerId] or 0

		temp[playerId] = {name = Account.getNameFromId(playerId), rank = rank, loanEnabled = loanEnabled, activity = activity}
	end
	return temp
end

function Company:canVehiclesBeModified()
  return self.m_VehiclesCanBeModified
end

function Company:getCreator()
    return self.m_Creator
end

function Company:sendMessage(text, r, g, b, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function Company:sendShortMessage(text, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendShortMessage(_(text, player), self:getName(), {0, 32, 63}, ...)
	end
end

function Company:getRandomSkin()
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

function Company:getAllSkins()
	local tab = {}
	for skinId in pairs(self.m_Skins) do
		tab[skinId] = self:getSetting("Skin", skinId, 0)
	end
	return tab
end


function Company:getSkinsForRank(rank)
	local tab = {}
	for skinId in pairs(self.m_Skins) do
		if tonumber(self:getSetting("Skin", skinId, 0)) <= rank then
			table.insert(tab, skinId)
		end
	end
	return tab
end

function Company:setRankLoan(rank,amount)
	self.m_RankLoans[tostring(rank)] = amount
end

function Company:setRankSkin(rank,skinId)
	self.m_RankSkins[tostring(rank)] = skinId
end

function Company:updateCompanyDutyGUI(player)
	player:triggerEvent("showDutyGUI", false, self:getId(), player:isCompanyDuty())
end

function Company:changeSkin(player, skinId)
	local playerRank = self:getPlayerRank(player)
	if not skinId then skinId = self:getSkinsForRank(playerRank)[1] end
	if self.m_Skins[skinId] then
		local minRank = tonumber(self:getSetting("Skin", skinId, 0))
		if minRank <= playerRank then
			player:setModel(skinId)
		else
			player:sendWarning(_("Deine ausgewählte Kleidung ist erst ab Rang %s verfügbar, dir wurde eine andere gegeben.", player, minRank))
			player:setModel(self:getSkinsForRank(playerRank)[1])
		end
	else
		--player:sendWarning(_("Deine ausgewählte Kleidung ist nicht mehr verfügbar, dir wurde eine andere gegeben.", player, minRank))
		-- ^useless if player switches faction
		player:setModel(self:getSkinsForRank(playerRank)[1])
	end
end

function Company:paydayPlayer(player)
	local rank = self.m_Players[player:getId()]
	local loanEnabled = self:isPlayerLoanEnabled(player:getId())
	local loan = loanEnabled and tonumber(self.m_RankLoans[tostring(rank)]) or 0

	if self:getMoney() < loan then loan = self:getMoney() end
	if loan < 0 then loan = 0 end
	return loan
end

function Company:createDutyMarker()
    	self.m_DutyPickup = createPickup(companyDutyMarker[self.m_Id], 3, 1275)
        if companyDutyMarkerInterior[self.m_Id] then self.m_DutyPickup:setInterior(companyDutyMarkerInterior[self.m_Id]) end
        if companyDutyMarkerDimension[self.m_Id] then self.m_DutyPickup:setDimension(companyDutyMarkerDimension[self.m_Id]) end
    	addEventHandler("onPickupHit", self.m_DutyPickup,
    		function(hitElement)
    			if getElementType(hitElement) == "player" and not hitElement.vehicle then
    				local company = hitElement:getCompany()
    				if company and company == self then
    					hitElement:triggerEvent("showDutyGUI", false, self:getId(), hitElement:isCompanyDuty())
                    else
                        hitElement:sendError(_("Du bist nicht in diesem Unternehmen!", hitElement))
                    end
    			end
    			cancelEvent()
    		end
    	)
end

function Company:respawnVehicles()
	local companyVehicles = VehicleManager:getSingleton():getCompanyVehicles(self.m_Id)
	local fails = 0
	local vehicles = 0
	if companyVehicles then
		for companyId, vehicle in pairs(companyVehicles) do
			if vehicle:getCompany() == self then
				vehicles = vehicles + 1
				if not vehicle:respawn() then
					fails = fails + 1
				else
					vehicle:setInterior(0)
					vehicle:setDimension(0)
				end
			end
		end
	end
	self:sendShortMessage(("%s/%s Fahrzeuge wurden respawned!"):format(vehicles-fails, vehicles))
end

function Company:phoneCall(caller)
	for k, player in ipairs(self:getOnlinePlayers()) do
		if not player:getPhonePartner() then
			if player ~= caller then
				local color = {companyColors[self.m_Id].r, companyColors[self.m_Id].g, companyColors[self.m_Id].b}
				triggerClientEvent(player, "callIncomingSM", resourceRoot, caller, false, ("%s ruft euch an."):format(caller:getName()), ("eingehender Anruf - %s"):format(self:getShortName()), color)
			end
		end
	end
end

function Company:phoneCallAbbort(caller)
	for k, player in ipairs(self:getOnlinePlayers()) do
		triggerClientEvent(player, "callRemoveSM", resourceRoot, caller, false)
	end
end

function Company:phoneTakeOff(player, caller, voiceCall)
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
			caller:setPhonePartner(player)
			player:setPhonePartner(caller)
			for k, companyPlayer in ipairs(self:getOnlinePlayers()) do
				triggerClientEvent(companyPlayer, "callRemoveSM", resourceRoot, caller, player)
			end
		end
	end
end

function Company:addLog(player, category, text)
	StatisticsLogger:getSingleton():addGroupLog(player, "company", self, category, text)
end

function Company:getLog()
	return StatisticsLogger:getSingleton():getGroupLogs("company", self.m_Id)
end

function Company:setSafe(obj)
	self.m_Safe = obj
	self.m_Safe:setData("clickable",true,true)
	addEventHandler("onElementClicked", self.m_Safe, function(button, state, player)
		if button == "left" and state == "down" then
			if player:getCompany() and player:getCompany() == self then
				player:triggerEvent("bankAccountGUIShow", self:getName(), "companyDeposit", "companyWithdraw")
				self:refreshBankAccountGUI(player)
			else
				player:sendError(_("Du bist nicht im richtigen Unternehmen!", player))
			end
		end
	end)
end

function Company:refreshBankAccountGUI(player)
	player:triggerEvent("bankAccountGUIRefresh", self:getMoney())
end
