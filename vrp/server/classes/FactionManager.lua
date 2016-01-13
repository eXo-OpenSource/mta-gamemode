-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionManager.lua
-- *  PURPOSE:     Factionmanager Class
-- *
-- ****************************************************************************

FactionManager = inherit(Singleton)

function FactionManager:constructor()
  outputServerLog("Loading factions...")
	local result = sql:queryFetch("SELECT ID, Name,Name_Short, Money FROM ??factions", sql:getPrefix())
	for k, row in ipairs(result) do
		local result2 = sql:queryFetch("SELECT Id, FactionRank FROM ??_character WHERE FactionID = ?", sql:getPrefix(), row.Id)
		local players = {}
		for i, factionRow in ipairs(result2) do
			players[factionRow.Id] = factionRow.FactionRank
		end
		self.m_Factions = {
			Faction:new(row.Id, row.Name_Short, row.Name, row.Money, players)
		}
	end
  
	for k, v in ipairs(self.m_Factions) do
		v:setId(k)
		v:addPlayers()
	end

  -- Todo: this sync method should be work fine -> test it.
  addEventHandler("playerReady", root, bind(FactionManager.sendFullSync, self))
end

function FactionManager:getFromId(Id)
  return self.m_Companies[Id]
end

function FactionManager:sendFullSync()
  for i, v in pairs(self.m_Companies) do
    v:sendSync()
  end
end

function FactionManager:addRef(ref)
  local id = #FactionManager.m_Companies + 1
	FactionManager.m_Companies[id] = ref
  ref:setId(id)
end

function FactionManager:removeRef(ref)
	FactionManager.m_Companies[ref:getId()] = nil
end
