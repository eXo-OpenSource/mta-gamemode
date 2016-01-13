-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Faction.lua
-- *  PURPOSE:     Base Faction Super Class
-- *
-- ****************************************************************************

Faction = inherit(Object)

-- implement by children
Faction.constructor = pure_virtual
Faction.destructor = pure_virtual
Faction.start = pure_virtual -- Todo: don't know for what, ask Jusonex :P
Faction.stop = pure_virtual -- Same here.

function Faction:constructor(id,name_short, name, money,players)
  outputDebug("Faction.virtual_constructor")

  self.m_Id = id
  self.m_Name_Short = name_short
  self.m_Name = name
  self.m_Players = players
  self.m_Money = money
  
  outputDebugString("Faction "..self.m_Name.." loaded")
end

function Faction:destructor()
end

function Faction:stop()
end

function Faction:start()
end

function Faction:getId()
	return self.m_Id
end

function Faction:getName()
	return self.m_Name
end

function Faction:addPlayer(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	rank = rank or 0
	self.m_Players[playerId] = rank
	local player = Player.getFromId(playerId)
	if player then
		player:setFaction(self)
	end

	sql:queryExec("UPDATE ??_character SET FactionId = ?, FactionRank = ? WHERE Id = ?", sql:getPrefix(), self.m_Id, rank, playerId)
end

function Faction:removePlayer(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = nil
	local player = Player.getFromId(playerId)
	if player then
		player:setFaction(nil)
	end

	sql:queryExec("UPDATE ??_character SET FactionId = 0, FactionRank = 0 WHERE Id = ?", sql:getPrefix(), playerId)
end

function Faction:invitePlayer(player)
    client:sendShortMessage(("Du hast %s erfolgreich in die Fraktion eingeladen."):format(getPlayerName(player)))

	player:triggerEvent("factionInvitationRetrieve", self:getId(), self:getName())

	self.m_Invitations[player] = true
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

	self.m_Players[playerId] = rank
	sql:queryExec("UPDATE ??_character SET FactionRank = ? WHERE Id = ?", sql:getPrefix(), rank, playerId)
end

function Faction:getMoney()
	return self.m_Money
end

function Faction:giveMoney(amount)
	self:setMoney(self.m_Money + amount)
end

function Faction:takeMoney(amount)
	self:setMoney(self.m_Money - amount)
end

function Faction:setMoney(amount)
	self.m_Money = amount

	sql:queryExec("UPDATE ??_factions SET Money = ? WHERE Id = ?", sql:getPrefix(), self.m_Money, self.m_Id)
end

function Faction:getPlayers(getIDsOnly)
	if getIDsOnly then
		return self.m_Players
	end

	local temp = {}
	for playerId, rank in pairs(self.m_Players) do
		temp[playerId] = {name = Account.getNameFromId(playerId), rank = rank}
	end
	return temp
end

function Faction:getOnlinePlayers()
	local players = {}
	for playerId in pairs(self.m_Players) do
		local player = Player.getFromId(playerId)
		if player then
			players[#players + 1] = player
		end
	end
	return players
end

function Faction:sendMessage(text, r, g, b, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end
