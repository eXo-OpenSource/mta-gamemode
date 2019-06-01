-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Company/Company.lua
-- *  PURPOSE:     Company Client
-- *
-- ****************************************************************************

CompanyManager = inherit(Singleton)
CompanyManager.Map = {}

function CompanyManager:constructor()
	PublicTransport:new()
	MechanicTow:new()

	triggerServerEvent("getCompanies", localPlayer)
	addRemoteEvents{"loadClientCompany", "companyForceOffduty"}
	addEventHandler("loadClientCompany", root, bind(self.loadCompany, self))
	addEventHandler("companyForceOffduty", root, bind(self.companyForceOffduty, self))
end

function CompanyManager:loadCompany(Id, name, name_short, rankNames)
	CompanyManager.Map[Id] = Company:new(Id, name, name_short, rankNames)
end

function CompanyManager:getFromId(id)
	return CompanyManager.Map[id]
end

function CompanyManager:companyForceOffduty()
	if localPlayer:getPublicSync("Company:Duty") then
		triggerServerEvent("companyToggleDuty", localPlayer, true, false, true)
	end
end

Company = inherit(Object)

function Company:constructor(Id, name, name_short, rankNames)
	self.m_Id = Id
	self.m_Name = name
	self.m_NameShort = name_short
	self.m_RankNames = rankNames
end

function Company:getId()
	return self.m_Id
end

function Company:getName()
	return self.m_Name
end

function Company:getShortName()
	return self.m_NameShort
end

function Company:getOnlinePlayers()
	local players = {}
	for _, player in pairs(Element.getAllByType"player") do
		if player:getCompany() and player:getCompany() == self then
			table.insert(players, player)
		end
	end
	return players
end
