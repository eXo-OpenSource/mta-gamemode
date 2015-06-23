-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Business/CompanyManager.lua
-- *  PURPOSE:     Companymanager Class
-- *
-- ****************************************************************************

CompanyManager = inherit(Singleton)

function CompanyManager:constructor()
  self.m_Companies = {
    TestCompany:new("TestCompany", "test", Vector3(2075, -1250, 24), 34508);
  }
  for k, v in ipairs(self.m_Companies) do
    v:setId(k)
    v:addPlayers()
	end

  -- Todo: this sync method should be work fine -> test it.
  addEventHandler("playerReady", root, bind(CompanyManager.sendFullSync, self))
end

function CompanyManager:getFromId(Id)
  return self.m_Companies[Id]
end

function CompanyManager:sendFullSync()
  for i, v in pairs(self.m_Companies) do
    v:sendSync()
  end
end

function CompanyManager:addRef(ref)
  local id = #CompanyManager.m_Companies + 1
	CompanyManager.m_Companies[id] = ref
  ref:setId(id)
end

function CompanyManager:removeRef(ref)
	CompanyManager.m_Companies[ref:getId()] = nil
end
