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

function Company:constructor(Id, Name, Creator, players, lastNameChange, bankAccountId, Settings, rankLoans, rankSkins )
  self.m_Id = Id
  self.m_Name = Name
  self.m_Creator = Creator
  self.m_Players = players
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
  self.m_PhoneNumber = PhoneNumbers:getSingleton():loadOrGenerateNumber("company", self)

end

function Company:destructor()
  if self.m_BankAccount then
    delete(self.m_BankAccount)
  end

  self:save()
end

function Company:save()
	outputDebug(("Saved Company '%s' (Id: %d)"):format(self:getName(), self:getId()))

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

function Company:setMoney(...)
  return self.m_BankAccount:setMoney(...)
end

function Company:getMoney(...)
  return self.m_BankAccount:getMoney(...)
end

function Company:giveMoney(amount)
    return self.m_BankAccount:setMoney(self.m_BankAccount:getMoney() + amount)
end

function Company:takeMoney(amount)
    return self.m_BankAccount:setMoney(self.m_BankAccount:getMoney() - amount)
end

function Company:addPlayer(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	rank = rank or 1
	self.m_Players[playerId] = rank
	local player = Player.getFromId(playerId)
	if player then
		player:setCompany(self)
	end

	sql:queryExec("UPDATE ??_character SET CompanyId = ?, CompanyRank = ? WHERE Id = ?", sql:getPrefix(), self.m_Id, rank, playerId)

  if self.onPlayerJoin then -- Only for Companies with own class
    self:onPlayerJoin(playerId, rank)
  end
end
function Company:removePlayer(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = nil
	local player = Player.getFromId(playerId)
	if player then
		player:setCompany(nil)
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
		if player then
			players[#players + 1] = player
		end
	end
	return players
end

function Company:sendMessage(text, r, g, b, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function Company:invitePlayer(player)
  client:sendShortMessage(("Du hast %s erfolgreich in deine Firma eingeladen."):format(getPlayerName(player)))
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

function Company:getPlayers(getIDsOnly)
	if getIDsOnly then
		return self.m_Players
	end

	local temp = {}
	for playerId, rank in pairs(self.m_Players) do
		temp[playerId] = {name = Account.getNameFromId(playerId), rank = rank}
	end
	return temp
end

function Company:canVehiclesBeModified()
  return self.m_VehiclesCanBeModified
end

function Company:getCreator()
    return self.m_Creator
end

function Company:sendMessage(msg)
    for i, v in pairs(Element.getAllByType("player")) do
        if v:getCompany() == self then
            v:sendShortMessage(("%s:\n%s"):format(self:getName(), msg))
        end
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
	if self.m_BankAccount:getMoney() < loan then loan = self.m_BankAccount:getMoney() end
	self.m_BankAccount:takeMoney(loan)
	return loan
end

function Company:createDutyMarker()
    	self.m_DutyPickup = createPickup(companyDutyMarker[self.m_Id], 3, 1275)
        if companyDutyMarkerInterior[self.m_Id] then self.m_DutyPickup:setInterior(companyDutyMarkerInterior[self.m_Id]) end
    	addEventHandler("onPickupHit", self.m_DutyPickup,
    		function(hitElement)
    			if getElementType(hitElement) == "player" then
    				local company = hitElement:getCompany()
    				if company then
    					hitElement:triggerEvent("showCompanyDutyGUI")
    					hitElement:getCompany():updateCompanyDutyGUI(hitElement)
    				end
    			end
    			cancelEvent()
    		end
    	)
end
