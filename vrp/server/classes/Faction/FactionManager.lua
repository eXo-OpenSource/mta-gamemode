-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionManager.lua
-- *  PURPOSE:     Factionmanager Class
-- *
-- ****************************************************************************

FactionManager = inherit(Singleton)

function FactionManager:constructor()
  self.m_Companies = {
    PD:new("PD", "test", Vector3(2075, -1250, 24), 34508);
  }
  for k, v in ipairs(self.m_Companies) do
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
