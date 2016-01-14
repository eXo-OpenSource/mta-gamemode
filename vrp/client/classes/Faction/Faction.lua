-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Faction.lua
-- *  PURPOSE:     Base Faction Super Class
-- *
-- ****************************************************************************

Faction = inherit(Object)

-- implement by children
Faction.constructor = pure_virtual
Faction.destructor = pure_virtual
Faction.start = pure_virtual -- Todo: don't know for what, ask Jusonex :P
Faction.stop = pure_virtual -- Same here.

function Faction:virtual_constructor()
  outputDebug("Faction.virtual_constructor")
end

function Faction:virtual_destructor()
  FactionManager:getSingleton():removeRef(self)
end

function Faction:receiveSyncInfo(players, money)
  self.m_Players = players
  self.m_Money = money
end

function Faction:setId(Id)
  self.m_Id = Id
end

function Faction:getId()
  return self.m_Id
end

function Faction:getName()
  return self.m_Name
end

function Faction:getMoney()
	return self.m_Money
end

function Faction:getDescription ()
  return self.m_Description
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

function Faction:onInfoHit(p)
  --FactionInfoGUI:new(self.m_Id) -- Todo: Information GUI

  p:sendMessage("-- Testing the availability of the important data --")
  p:sendMessage("Faction Id: "..self:getId())
  p:sendMessage("Faction Name: "..self:getName())
  p:sendMessage("Faction Description: "..self:getDescription())
  p:sendMessage("Faction Bank: $"..self:getMoney())
  p:sendMessage("Faction Position: "..tostring(self.m_Position))
  p:sendMessage("Faction Membercount: "..table.size(self.m_Players))
end
