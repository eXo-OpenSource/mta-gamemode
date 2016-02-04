-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/MWeaponTruck.lua
-- *  PURPOSE:     Weapon Truck Manager Class
-- *
-- ****************************************************************************

MWeaponTruck = inherit(Singleton)

function MWeaponTruck:constructor()
	self:createStartPoint(-1869.14, 1421.49, 6.5)
	self.m_IsCurrentWT = false
	addRemoteEvents{"onWeaponTruckLoad"}
	addEventHandler("onWeaponTruckLoad", root, bind(self.Event_onWeaponTruckLoad, self))
end

function MWeaponTruck:destructor()
end

function MWeaponTruck:createStartPoint(x, y, z)
	--self.m_Blip = Blip:new("Waypoint.png", x, y, self.m_Driver)
	self.m_StartMarker = createMarker(x, y, z, "cylinder",1)
	addEventHandler("onMarkerHit", self.m_StartMarker, bind(self.onStartPointHit, self))
end

function MWeaponTruck:onStartPointHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction then
			if faction:isEvilFaction() then
				if ActionsCheck:getSingleton():isActionAllowed(hitElement) then
					hitElement:triggerEvent("showFactionWTLoadGUI",faction.m_ValidWeapons, faction.m_WeaponDepotInfo)
				end
			else
				hitElement:sendError(_("Den Waffentruck können nur Mitglieder böser Fraktionen starten!",hitElement))
			end
		else
			hitElement:sendError(_("Den Waffentruck können nur Mitglieder böser Fraktionen starten!",hitElement))
		end
	end
end

function MWeaponTruck:Event_onWeaponTruckLoad(weaponTable)
	local faction = client:getFaction()
	local totalAmount = 0
	if faction then
		for weaponID,v in pairs(weaponTable) do
			for typ,amount in pairs(weaponTable[weaponID]) do
				if amount > 0 then
					if typ == "Waffe" then
						totalAmount = totalAmount + faction.m_WeaponDepotInfo[weaponID]["WaffenPreis"] * amount
					elseif typ == "Munition" then
						totalAmount = totalAmount + faction.m_WeaponDepotInfo[weaponID]["MagazinPreis"] * amount
					end
				end
			end
		end
		if client:getMoney() >= totalAmount then
			if ActionsCheck:getSingleton():isActionAllowed(client) then
				if not self.m_CurrentWT then
					outputChatBox(_("Ein Waffentruck wird beladen!",hitElement),rootElement,255,0,0)
					outputChatBox(_("Die Kisten stehen bereit zum beladen! Gesamtkosten: %d$",client,totalAmount),client,255,125,0)
					self.m_CurrentWT = WeaponTruck:new(client,weaponTable)
					ActionsCheck:getSingleton():setAction("Waffentruck")
				else
					client:sendError(_("Es läuft aktuell bereits ein Waffentruck!",client))
				end
			end
		else
			client:sendError(_("Du hast nicht ausreichend Geld! (%d$)",client,totalAmount))
		end
	else
		client:sendError(_("Du bist in keiner Fraktion!",client))
	end
end
