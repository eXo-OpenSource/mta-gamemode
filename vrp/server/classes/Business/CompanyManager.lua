-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/CompanyManager.lua
-- *  PURPOSE:     CompanyManager class
-- *
-- ****************************************************************************
CompanyManager = inherit(Singleton)
CompanyManager.Map = {}

function CompanyManager:constructor()
  outputServerLog("Loading companies...")
  local result = sql:queryFetch("SELECT * FROM ??_companies", sql:getPrefix())
  for i, row in pairs(result) do
    local result2 = sql:queryFetch("SELECT Id, CompanyRank FROM ??_character WHERE CompanyId = ?", sql:getPrefix(), row.Id)
    local players = {}
    for i, row2 in ipairs(result2) do
      players[row2.Id] = row2.CompanyRank
    end

    if Company.DerivedClasses[row.Id] then
      self:addRef(Company.DerivedClasses[row.Id]:new(row.Id, row.Name, row.Creator, players, row.lastNameChange, row.BankAccount, fromJSON(row.Settings) or {["VehiclesCanBeModified"]=false}, row.RankLoans, row.RankSkins))
    else
      self:addRef(Company:new(row.Id, row.Name, row.Creator, players, row.lastNameChange, row.BankAccount, fromJSON(row.Settings) or {["VehiclesCanBeModified"]=false}, row.RankLoans, row.RankSkins))
    end
  end

  -- Add events
  addRemoteEvents{"companyRequestInfo"}
  addEventHandler("companyRequestInfo", root, bind(self.Event_companyRequestInfo, self))
end

function CompanyManager:destructor()
  for i, v in pairs(CompanyManager.Map) do
    delete(v)
  end
end

function CompanyManager:getFromId(Id)
  return CompanyManager.Map[Id]
end

function CompanyManager:addRef(ref)
  CompanyManager.Map[ref:getId()] = ref
end

function CompanyManager:removeRef(ref)
  CompanyManager.Map[ref:getId()] = nil
end

function CompanyManager:Event_companyRequestInfo()
	local company = client:getCompany()

	if company then
--id, name, rank, money, players, skins, rankNames, rankLoans, rankSkins
		client:triggerEvent("companyRetrieveInfo",company:getId(), company:getName(), company:getPlayerRank(client), company:getMoney(), company:getPlayers(), company.m_Skins, company.m_RankNames, company.m_RankLoans, company.m_RankSkins)
	else
		client:triggerEvent("companyRetrieveInfo")
	end
end
