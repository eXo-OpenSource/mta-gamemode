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

	self.m_NeedHelpBlip = {}

	addRemoteEvents{"loadClientFaction", "stateFactionNeedHelp"}
	addEventHandler("loadClientFaction", root, bind(self.loadFaction, self))
	addEventHandler("stateFactionNeedHelp", root, bind(self.stateFactionNeedHelp, self))

end

function FactionManager:loadFaction(Id, name, name_short, rankNames, factionType, color)
	FactionManager.Map[Id] = Faction:new(Id, name, name_short, rankNames, factionType, color)
end

function FactionManager:stateFactionNeedHelp(player)
	local pos = player:getPosition()

	if self.m_NeedHelpBlip[player] then delete(self.m_NeedHelpBlip[player]) end
	self.m_NeedHelpBlip[player] = Blip:new("NeedHelp.png", pos.x, pos.y,9999)
	self.m_NeedHelpBlip[player]:attachTo(player)
	self.m_NeedHelpBlip[player]:setStreamDistance(2000)

	setTimer(function(blip)
		if blip then delete(blip) end
	end, 20000, 1, self.m_NeedHelpBlip[player])
end

function FactionManager:getFromId(id)
	return FactionManager.Map[id]
end

function FactionManager:getFactionNames()
	local table = {}
	for id, faction in pairs(FactionManager.Map) do
		table[id] = faction:getShortName()
	end
	return table
end

Faction = inherit(Object)

function Faction:constructor(Id, name, name_short, rankNames, factionType, color)
	self.m_Id = Id
	self.m_Name = name
	self.m_NameShort = name_short
	self.m_RankNames = rankNames
	self.m_Type = factionType
	self.m_Color = color
end

function Faction:getId()
	return self.m_Id
end

function Faction:isStateFaction()
	return self.m_Type == "State"
end

function Faction:isEvilFaction()
	return self.m_Type == "Evil"
end

function Faction:getName()
	return self.m_Name
end

function Faction:getShortName()
	return self.m_NameShort
end

function Faction:getColor()
	return self.m_Color
end
