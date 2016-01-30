-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/FactionManager.lua
-- *  PURPOSE:     Factionmanager Class
-- *
-- ****************************************************************************

FactionManager = inherit(Singleton)
FactionManager.Map = {}

function FactionManager:constructor()
  local Factions = { 
    TestFaction:new(Vector3(2075, -1250, 24));
  }
  for k, v in ipairs(Factions) do
		v:setId(k) 
    self:addRef(v)
	end

  addRemoteEvents{"receiveSync"}
  addEventHandler("receiveSync", root, bind(self.receiveSync, self))
end

function FactionManager:getFromId(Id)
  return FactionManager.Map[Id]
end


function FactionManager:receiveSync(Id, ...)
  if self:getFromId(Id) then
    self:getFromId(Id):receiveSyncInfo(...)
  end
end

function FactionManager:addRef(ref)
	FactionManager.Map[ref:getId()] = ref
end

function FactionManager:removeRef(ref)
	FactionManager.Map[ref:getId()] = nil
end
