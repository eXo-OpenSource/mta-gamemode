-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Faction.lua
-- *  PURPOSE:     Faction Client
-- *
-- ****************************************************************************

Faction = inherit(Object)

function Faction:constructor(Id, name, name_short, rankNames, factionType, color, navigationPosition, diplomacy)
	self.m_Id = Id
	self.m_Name = name
	self.m_NameShort = name_short
	self.m_RankNames = rankNames
	self.m_Type = factionType
	self.m_Color = color
	self.m_NavigationPosition = normaliseVector(navigationPosition)
	self.m_Diplomacy = diplomacy
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

function Faction:isRescueFaction()
	return self.m_Type == "Rescue"
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

function Faction:getNavigationPosition()
	return self.m_NavigationPosition
end

function Faction:setDiplomacy(diplomacy)
	self.m_Diplomacy = diplomacy
end

function Faction:getDiplomacy(targetFaction)
	local factionId, status
	for index, data in pairs(self.m_Diplomacy) do
		factionId, status = unpack(data)
		if factionId == targetFaction:getId() then
			return status
		end
	end
end

function Faction:getAllianceFaction()
	local factionId, status
	if not self.m_Diplomacy then return false end
	for index, data in pairs(self.m_Diplomacy) do
		factionId, status = unpack(data)
		if status == FACTION_DIPLOMACY["Verbündet"] then
			if FactionManager:getSingleton():getFromId(factionId) then
				return FactionManager:getSingleton():getFromId(factionId)
			end
		end
	end
	return false
end

function Faction:hasWarWith(faction)
	local factionId, status
	if not self.m_Diplomacy then return false end
	for index, data in pairs(self.m_Diplomacy) do
		factionId, status = unpack(data)
		if factionId == faction:getId() then
			if status == FACTION_DIPLOMACY["Im Krieg"] then
				return true
			end
		end
	end
	return false
end