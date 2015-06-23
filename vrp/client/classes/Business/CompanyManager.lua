-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Business/CompanyManager.lua
-- *  PURPOSE:     Companymanager Class
-- *
-- ****************************************************************************

CompanyManager = inherit(Singleton)

function CompanyManager:constructor()
  self.m_Companies = {
    TestCompany:new("TestCompany", "test", Vector3(2075, -1250, 24));
  }
  for k, v in ipairs(self.m_Companies) do
		v:setId(k)
	end

  addRemoteEvents{"receiveSync"}
  addEventHandler("receiveSync", root, bind(self.receiveSync, self))
end

function CompanyManager:getFromId(Id)
  return self.m_Companies[Id]
end


function CompanyManager:receiveSync(Id, ...)
  if self:getFromId(Id) then
    self:getFromId(Id):receiveSyncInfo(...)
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
