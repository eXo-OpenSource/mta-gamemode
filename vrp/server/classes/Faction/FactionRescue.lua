-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionRescue.lua
-- *  PURPOSE:     Faction Rescue Class
-- *
-- ****************************************************************************

FactionRescue = inherit(Singleton)
  -- implement by children

function FactionRescue:constructor()
	outputDebug("Faction Rescue loaded")
end

function FactionRescue:destructor()
end

function FactionRescue:countPlayers()
	local factions = FactionManager:getSingleton():getAllFactions()
	local amount = 0
	for index,faction in pairs(factions) do
		if faction:isRescueFaction() then
			amount = amount+faction:getOnlinePlayers()
		end
	end
	return amount
end

function FactionRescue:getOnlinePlayers()
	local factions = FactionManager:getSingleton():getAllFactions()
	local players = {}
	for index,faction in pairs(factions) do
		if faction:isRescueFaction() then
			for index, value in pairs(faction:getOnlinePlayers()) do
				table.insert(players, value)
			end
		end
	end
	return players
end
