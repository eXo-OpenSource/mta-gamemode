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

function Company:constructor(Id, Name, Creator, players, lastNameChange, bankAccountId, Settings)
  self.m_Id = Id
  self.m_Name = Name
  self.m_Creator = Creator
  self.m_Players = players or {}
  self.m_LastNameChange = lastNameChange or 0
  self.m_Invitations = {}
  self.m_Vehicles = {}
  self.m_Level = 0

  -- Settings
  self.m_VehiclesCanBeModified = Settings.VehiclesCanBeModified or false

  self.m_BankAccount = BankAccount.load(bankAccountId) or BankAccount.create(BankAccountTypes.Company, self.m_Id)
  sql:queryExec("UPDATE ??_companies SET BankAccount = ? WHERE Id = ?;", sql:getPrefix(), self.m_BankAccount:getId(), self.m_Id)
end

function Company:destructor()
  if self.m_BankAccount then
    delete(self.m_BankAccount)
  end

  local Settings = {
    VehiclesCanBeModified = self.m_VehiclesCanBeModified
  }
  sql:queryExec("UPDATE ??_companies SET Settings = ? WHERE Id = ?;", sql:getPrefix(), toJSON(Settings), self.m_Id)
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

function Company:getPlayers()
  return self.m_Players
end

function Company:canVehiclesBeModified()
  return self.m_VehiclesCanBeModified
end

function Company:getCreator()
    return self.m_Creator
end
