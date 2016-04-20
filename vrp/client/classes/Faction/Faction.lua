-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Faction.lua
-- *  PURPOSE:     Faction Client
-- *
-- ****************************************************************************

FactionManager = inherit(Singleton)
FactionManager.Map = {}

function FactionManager:constructor()
	triggerServerEvent("getFactions", localPlayer)
	addRemoteEvents{"loadClientFaction"}
	addEventHandler("loadClientFaction", root, bind(self.loadFaction, self))
end

function FactionManager:loadFaction(Id, name, name_short, rankNames, factionType)
	FactionManager.Map[Id] = Faction:new(Id, name, name_short, rankNames, factionType)
end

function FactionManager:getFromId(id)
	return FactionManager.Map[id]
end

Faction = inherit(Object)

function Faction:constructor(Id, name, name_short, rankNames, factionType)
	self.m_Id = Id
	self.m_Name = name
	self.m_NameShort = name_short
	self.m_RankNames = rankNames
	self.m_FactionType = factionTyp
end

function Faction:getName()
	return self.m_Name
end

function Faction:getShortName()
	return self.m_NameShort
end
