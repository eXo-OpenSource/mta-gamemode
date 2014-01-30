-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Group.lua
-- *  PURPOSE:     Group class
-- *
-- ****************************************************************************
Group = inherit(Object)

function Group:constructor(Id, name, money)
	self.m_Id = Id
	
	self.m_Players = {}
	self.m_Name = name
	self.m_Money = money
end

function Group:destructor()
end

function Group.create(name)
	if sql:queryExec("INSERT INTO ??_groups (Name) VALUES(?)", sql:getPrefix(), name) then
		local group = Group:new(sql:lastInsertId(), name, 0)
		
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
		
		return true
	end
	return false
end

function Group:getId()
	return self.m_Id
end

function Group:getName()
	return self.m_Name
end

function Group:getKarma()
	local karmaSum = 0
	
	for playerId in pairs(self.m_Players) do
		local player = Player.getFromId(playerId)
		if player then
			karmaSum = karmaSum + player:getKarma()
		end
	end
	
	return karmaSum / #self:getOnlinePlayers()
end

function Group:addPlayer(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end
	
	self.m_Players[playerId] = rank or 0
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
end

function Group:getMoney()
	return self.m_Money
end

function Group:addMoney(amount)
	self.m_Money = self.m_Money + amount
end

function Group:takeMoney(amount)
	self.m_Money = self.m_Money - amount
end

function Group:getPlayers()
	return self.m_Players
end

function Group:getOnlinePlayers()
	local players = {}
	for playerId in pairs(self.m_Players) do
		local player = Player.getFromId(playerId)
		if player then
			table.insert(players, player)
		end
	end
	return players
end

function Group:sendMessage(text, r, g, b, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end
