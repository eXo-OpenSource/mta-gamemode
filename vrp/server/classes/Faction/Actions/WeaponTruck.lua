-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/WeaponTruck.lua
-- *  PURPOSE:     Weapon Truck Class
-- *
-- ****************************************************************************

WeaponTruck = inherit(Singleton)

function WeaponTruck:constructor()
	self:createStartPoint(-1869.14, 1421.49, 6.5)
end

function WeaponTruck:destructor()
end

function WeaponTruck:createStartPoint(x, y, z)
	--self.m_Blip = Blip:new("Waypoint.png", x, y, self.m_Driver)
	self.m_StartMarker = createMarker(x, y, z, "cylinder",1)
	addEventHandler("onMarkerHit", self.m_StartMarker, bind(self.onStartPointHit, self))
end

function WeaponTruck:onStartPointHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction then
			if faction:isEvilFaction() then
				hitElement:triggerEvent("showFactionWTLoadGUI",faction.m_ValidWeapons, faction.m_WeaponDepotInfo)
			else
				hitElement:sendError(_("Den Waffentruck können nur Mitglieder böser Fraktionen starten!",hitElement))
			end
		else
			hitElement:sendError(_("Den Waffentruck können nur Mitglieder böser Fraktionen starten!",hitElement))
		end
	end
end
