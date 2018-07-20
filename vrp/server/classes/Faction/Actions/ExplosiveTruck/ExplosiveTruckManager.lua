-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/ExplosiveTruck/ExplosiveTruckManager.lua
-- *  PURPOSE:     C4 Truck Manager Class
-- *
-- ****************************************************************************

addRemoteEvents{"ExplosiveTruckManager:start"}

ExplosiveTruckManager = inherit(Singleton)
ExplosiveTruckManager.Active = {}

function ExplosiveTruckManager:constructor()
	addEventHandler("ExplosiveTruckManager:start", root, bind(self.start, self))
end

function ExplosiveTruckManager:destructor()
	removeEventHandler("ExplosiveTruckManager:start", root, self.start)
end

function ExplosiveTruckManager:start()
	local faction = client:getFaction()

	if not faction or not faction:isEvilFaction() then
		client:sendError("Du bist in keiner bösen Fraktion!")

		return
	end

	local factionId = faction:getId()

	if ExplosiveTruckManager.Active[factionId] then
		client:sendError("Es läuft bereits ein Transport deiner Fraktion!")

		return
	end

	if faction:getMoney() < ExplosiveTruck.Price then
		client:sendError("Deine Fraktion hat nicht genügend Geld!")

		return
	end

	ExplosiveTruckManager.Active[factionId] = ExplosiveTruck:new(faction, client)
end
