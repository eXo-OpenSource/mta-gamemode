-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Business/Company.lua
-- *  PURPOSE:     Base Company Super Class
-- *
-- ****************************************************************************

Company = inherit(Object)

-- implement by children
Company.constructor = pure_virtual
Company.destructor = pure_virtual
Company.start = pure_virtual -- Todo: don't know for what, ask Jusonex :P
Company.stop = pure_virtual -- Same here.

function Company:virtual_constructor(name, desc, position, players, money)
  outputDebug("Company.virtual_constructor")

  self.m_Name = name
  self.m_Description = desc
  self.m_Position = position
  self.m_Players = players
  self.m_Money = money
end

function Company:virtual_destructor()
  CompanyManager:getSingleton():removeRef(self)
end

function Company:setId(Id)
  self.m_Id = Id
end

function Company:getId()
  return self.m_Id
end

function Company:getName()
  return self.m_Name
end

function Company:getMoney()
	return self.m_Money
end

function Company:getPlayers()
  return self.m_Players
end

function Company:getOnlinePlayers()
	local players = {}
	for playerId in pairs(self:getPlayers()) do
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

function Company:getSyncInfo()
  return self:getId(), self:getPlayers(), self:getMoney()
end

function Company:sendSync()
  triggerClientEvent("receiveSync", root, self:getSyncInfo())
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

  for i, v in pairs(self.m_Players) do
    print(i, v)
  end

  self:sendSync()
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

  self:sendSync()
end
