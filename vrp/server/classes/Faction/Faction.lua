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
  FactionManager:getSingleton():removeRef(self)
end

function Faction:stop()
end

function Faction:start()
end

function Faction:setId(Id)
  self.m_Id = Id
end

function Faction:getId()
  return self.m_Id
end

function Faction:addPlayers()
  local result = sql:queryFetch("SELECT Id, FactionRank FROM ??_character WHERE FactionId = ?", sql:getPrefix(), self:getId())
  for i, row in ipairs(result) do
    self.m_Players[row.Id] = row.FactionRank
  end
end

function Faction:getName()
  return self.m_Name
end

function Faction:getMoney()
	return self.m_Money
end

function Faction:getPlayers()
  return self.m_Players
end

function Faction:getOnlinePlayers()
	local players = {}
	for playerId in pairs(self:getPlayers()) do
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

function Faction:getSyncInfo()
  return self:getId(), self:getPlayers(), self:getMoney()
end

function Faction:sendSync()
  triggerClientEvent("receiveSync", root, self:getSyncInfo())
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

  self:sendSync()
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

  self:sendSync()
end
