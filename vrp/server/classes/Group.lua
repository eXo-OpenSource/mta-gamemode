-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Group.lua
-- *  PURPOSE:     Group class
-- *
-- ****************************************************************************
Group = inherit(Object)

function Group:constructor(Id, name, money, players, karma, lastNameChange)
	self.m_Id = Id

	self.m_Players = players or {}
	self.m_Name = name
	self.m_Money = money or 0
	self.m_ProfitProportion = 0.5 -- Amount of money for the group fund
	self.m_Invitations = {}
	self.m_Karma = karma or 0
	self.m_LastNameChange = lastNameChange
end

function Group:destructor()
end

function Group.create(name)
	if sql:queryExec("INSERT INTO ??_groups (Name) VALUES(?)", sql:getPrefix(), name) then
		local group = Group:new(sql:lastInsertId(), name)

		-- Add refernece
		GroupManager:getSingleton():addRef(group)

		return group
	end
	return false
end

function Group:purge()
	if sql:queryExec("DELETE FROM ??_groups WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		-- Remove all players
		for playerId in pairs(self.m_Players) do
			self:removePlayer(playerId)
		end

		-- Remove reference
		GroupManager:getSingleton():removeRef(self)

		-- Free owned gangareas
		GangAreaManager:getSingleton():freeAreas()

		return true
	end
	return false
end

function Group:getId()
	return self.m_Id
end

function Group:setName(name)
	local timestamp = getRealTime().timestamp
	if not sql:queryExec("UPDATE ??_groups SET Name = ?, lastNameChange = ? WHERE Id = ?", sql:getPrefix(), name, timestamp, self.m_Id) then
		return false
	end
	triggerClientEvent("gangAreaOnGroupNameChange", root, self.m_Name, name)

	self.m_Name = name
	self.m_LastNameChange = timestamp

	for i, player in pairs(self:getOnlinePlayers()) do
		player:setPublicSync("GroupName", self:getName())
	end

	return true
end

function Group:getName()
	return self.m_Name
end

function Group:getKarma()
	return self.m_Karma
end

function Group:setKarma(karma)
	self.m_Karma = karma

	sql:queryExec("UPDATE ??_groups SET Karma = ? WHERE Id = ?", sql:getPrefix(), self.m_Karma, self.m_Id)
end

function Group:giveKarma(karma)
	self:setKarma(self:getKarma() + karma)
end

function Group:getKarma()
	return self.m_Karma
end

function Group:isEvil()
	return self:getKarma() < 0
end

function Group:addPlayer(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	rank = rank or 0
	self.m_Players[playerId] = rank
	local player = Player.getFromId(playerId)
	if player then
		player:setGroup(self)
	end

	sql:queryExec("UPDATE ??_character SET GroupId = ?, GroupRank = ? WHERE Id = ?", sql:getPrefix(), self.m_Id, rank, playerId)
end

function Group:removePlayer(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = nil
	local player = Player.getFromId(playerId)
	if player then
		player:setGroup(nil)
	end

	sql:queryExec("UPDATE ??_character SET GroupId = 0, GroupRank = 0 WHERE Id = ?", sql:getPrefix(), playerId)
end

function Group:invitePlayer(player)
    client:sendShortMessage(("Du hast %s erfolgreich in deine Gruppe eingeladen."):format(getPlayerName(player)))

	player:triggerEvent("groupInvitationRetrieve", self:getId(), self:getName())

	self.m_Invitations[player] = true
end

function Group:removeInvitation(player)
	self.m_Invitations[player] = nil
end

function Group:hasInvitation(player)
	return self.m_Invitations[player]
end

function Group:isPlayerMember(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	return self.m_Players[playerId] ~= nil
end


function Group:getPlayerRank(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	return self.m_Players[playerId]
end

function Group:setPlayerRank(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = rank
	sql:queryExec("UPDATE ??_character SET GroupRank = ? WHERE Id = ?", sql:getPrefix(), rank, playerId)
end

function Group:getMoney()
	return self.m_Money
end

function Group:giveMoney(amount)
	self:setMoney(self.m_Money + amount)
end

function Group:takeMoney(amount)
	self:setMoney(self.m_Money - amount)
end

function Group:setMoney(amount)
	self.m_Money = amount

	sql:queryExec("UPDATE ??_groups SET Money = ? WHERE Id = ?", sql:getPrefix(), self.m_Money, self.m_Id)
end

function Group:getPlayers(getIDsOnly)
	if getIDsOnly then
		return self.m_Players
	end

	local temp = {}
	for playerId, rank in pairs(self.m_Players) do
		temp[playerId] = {name = Account.getNameFromId(playerId), rank = rank}
	end
	return temp
end

function Group:getOnlinePlayers()
	local players = {}
	for playerId in pairs(self.m_Players) do
		local player = Player.getFromId(playerId)
		if player then
			players[#players + 1] = player
		end
	end
	return players
end

function Group:sendMessage(text, r, g, b, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function Group:distributeMoney(amount)
	local moneyForFund = amount * self.m_ProfitProportion
	self:giveMoney(moneyForFund)

	local moneyForPlayers = amount - moneyForFund
	local onlinePlayers = self:getOnlinePlayers()
	local amountPerPlayer = math.floor(moneyForPlayers / #onlinePlayers)

	for k, player in pairs(onlinePlayers) do
		player:giveMoney(amountPerPlayer)
	end
end
