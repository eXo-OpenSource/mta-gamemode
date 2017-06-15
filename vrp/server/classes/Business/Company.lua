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

function Company:constructor(Id, Name, ShortName, Creator, players, lastNameChange, bankAccountId, Settings, rankLoans, rankSkins )
  self.m_Id = Id
  self.m_Name = Name
  self.m_ShortName = ShortName
  self.m_Creator = Creator
  self.m_Players = players
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

  sql:queryExec("UPDATE ??_companies SET BankAccount = ? WHERE Id = ?;", sql:getPrefix(), self.m_BankAccount:getId(), self.m_Id)

  self:createDutyMarker()
  self.m_PhoneNumber = (PhoneNumber.load(3, self.m_Id) or PhoneNumber.generateNumber(3, self.m_Id))
  self.m_PhoneTakeOff = bind(self.phoneTakeOff, self)

  self.m_VehicleTexture = companyVehicleShaders[Id] or false

	self:getActivity()
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

function Company:giveMoney(amount, reason)
    StatisticsLogger:getSingleton():addMoneyLog("company", self, amount, reason or "Unbekannt")
    return self.m_BankAccount:addMoney(amount, reason)
end

function Company:takeMoney(amount, reason)
    StatisticsLogger:getSingleton():addMoneyLog("company", self, -amount, reason or "Unbekannt")
    return self.m_BankAccount:takeMoney(amount, reason)
end

function Company:addPlayer(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	rank = rank or 0
	self.m_Players[playerId] = rank
	local player = Player.getFromId(playerId)
	if player then
		player:setCompany(self)
	end

	sql:queryExec("UPDATE ??_character SET CompanyId = ?, CompanyRank = ? WHERE Id = ?", sql:getPrefix(), self.m_Id, rank, playerId)

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
	local player = Player.getFromId(playerId)
	if player then
		player:setCompany(nil)
		player:sendShortMessage(_("Du wurdest aus deinem Unternehmen entlassen!", player))
		self:sendShortMessage(_("%s hat dein Unternehmen verlassen!", player, player:getName()))
	end

	sql:queryExec("UPDATE ??_character SET CompanyId = 0, CompanyRank = 0 WHERE Id = ?", sql:getPrefix(), playerId)

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

function Company:sendChatMessage(sourcePlayer,message)
	local playerId = sourcePlayer:getId()
	local rank = self.m_Players[playerId]
	local rankName = self.m_RankNames[rank]
    local receivedPlayers = {}
	local text = ("%s %s: %s"):format(rankName, sourcePlayer:getName(), message)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, 100, 150, 250)
        if player ~= sourcePlayer then
            receivedPlayers[#receivedPlayers+1] = player:getName()
        end
	end
    StatisticsLogger:getSingleton():addChatLog(sourcePlayer, "company:"..self.m_Id, message, toJSON(receivedPlayers))
end

function Company:invitePlayer(player)
    client:sendShortMessage(("Du hast %s erfolgreich in dein Unternehmen eingeladen."):format(getPlayerName(player)))
	player:triggerEvent("companyInvitationRetrieve", self:getId(), self:getName())

	self.m_Invitations[player] = true
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

function Company:getActivity(force)
	if self.m_LastActivityUpdate > getRealTime().timestamp - 30 * 60 and not force then
		return
	end
	self.m_LastActivityUpdate = getRealTime().timestamp

	for playerId, rank in pairs(self.m_Players) do
		local row = sql:queryFetchSingle("SELECT FLOOR(SUM(Duration) / 60) AS Activity FROM ??_accountActivity WHERE UserID = ? AND Date BETWEEN DATE(NOW()) - 7 AND DATE(NOW());", sql:getPrefix(), playerId)
	
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
		local activity = self.m_PlayerActivity[playerId]
		if not activity then activity = 0 end

		temp[playerId] = {name = Account.getNameFromId(playerId), rank = rank, activity = activity}
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

function Company:setRankLoan(rank,amount)
	self.m_RankLoans[tostring(rank)] = amount
end

function Company:setRankSkin(rank,skinId)
	self.m_RankSkins[tostring(rank)] = skinId
end

function Company:updateCompanyDutyGUI(player)
	player:triggerEvent("updateCompanyDutyGUI", player:isCompanyDuty())
end

function Company:changeSkin(player)
	local rank = self:getPlayerRank(player)
	player:setModel(self.m_RankSkins[tostring(rank)])
end

function Company:paydayPlayer(player)
	local rank = self.m_Players[player:getId()]
	local loan = tonumber(self.m_RankLoans[tostring(rank)])
	if self:getMoney() < loan then loan = self:getMoney() end
	if loan < 0 then loan = 0 end
	self:takeMoney(loan, "Lohn von "..player:getName())
	return loan
end

function Company:createDutyMarker()
    	self.m_DutyPickup = createPickup(companyDutyMarker[self.m_Id], 3, 1275)
        if companyDutyMarkerInterior[self.m_Id] then self.m_DutyPickup:setInterior(companyDutyMarkerInterior[self.m_Id]) end
    	addEventHandler("onPickupHit", self.m_DutyPickup,
    		function(hitElement)
    			if getElementType(hitElement) == "player" and not hitElement.vehicle then
    				local company = hitElement:getCompany()
    				if company and company == self then
    					hitElement:triggerEvent("showCompanyDutyGUI")
    					hitElement:getCompany():updateCompanyDutyGUI(hitElement)
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
				player:sendShortMessage(_("Der Spieler %s ruft euer Unternehmen (%s) an!\nDrücke 'F5' um abzuheben.", player, caller:getName(), self:getName()))
				bindKey(player, "F5", "down", self.m_PhoneTakeOff, caller)
			end
		end
	end
end

function Company:phoneCallAbbort(caller)
	for k, player in ipairs(self:getOnlinePlayers()) do
		if not player:getPhonePartner() then
			player:sendShortMessage(_("Der Spieler %s hat den Anruf abgebrochen.", player, caller:getName()))
			unbindKey(player, "F5", "down", self.m_PhoneTakeOff, caller)
		end
	end
end

function Company:phoneTakeOff(player, key, state, caller)
	if player.m_PhoneOn == false then
		player:sendError(_("Dein Telefon ist ausgeschaltet!", player))
		return
	end
	if player:getPhonePartner() then
		player:sendError(_("Du telefonierst bereits!", player))
		return
	end
	self:sendShortMessage(_("%s hat das Telefonat von %s angenommen!", player, player:getName(), caller:getName()))
	self:addLog(player, "Telefonate", ("hat das Telefonat von %s angenommen!"):format(caller:getName()))
	caller:triggerEvent("callAnswer", player, voiceCall)
	player:triggerEvent("callAnswer", caller, voiceCall)
	caller:setPhonePartner(player)
	player:setPhonePartner(caller)
	for k, player in ipairs(self:getOnlinePlayers()) do
        if isKeyBound(player, "F5", "down", self.m_PhoneTakeOff) then
			unbindKey(player, "F5", "down", self.m_PhoneTakeOff)
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
