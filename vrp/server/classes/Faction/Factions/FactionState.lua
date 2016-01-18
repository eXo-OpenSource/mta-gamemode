-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionManager.lua
-- *  PURPOSE:     Factionmanager Class
-- *
-- ****************************************************************************

FactionState = inherit(Faction)
  -- implement by children


function FactionState:constructor(Id, Name_Short, Name, Money, players)
	self:createDutyPickup(252.6, 69.4, 1003.64,6)
	self:createArrestZone(1564.92, -1693.55, 5.89)
end

function FactionState:destructor()
end

function FactionState:createDutyPickup(x,y,z,int)
	self.m_DutyPickup = createPickup(x,y,z, 3, 1275) --PD
	setElementInterior(self.m_DutyPickup, int)
	addEventHandler("onPickupHit", self.m_DutyPickup,
		function(hitElement)
			if getElementType(hitElement) == "player" then
				local faction = hitElement:getFaction()
				if faction:isStateFaction() == true then
					hitElement:triggerEvent("showStateFactionDutyGUI")
					hitElement:getFaction():updateStateFactionDutyGUI(hitElement)
				end
			end
			cancelEvent()
		end
	)
end

function FactionState:createArrestZone(x,y,z,int)
	self.m_ArrestZone = createPickup(x,y,z, 3, 1318) --PD
	self.m_ArrestZoneCol = createColSphere(x,y,z, 4) --PD
	addEventHandler("onPickupHit", self.m_ArrestZone,
		function(hitElement)
			if getElementType(hitElement) == "player" then
				local faction = hitElement:getFaction()
				if faction:isStateFaction() == true then
					hitElement:triggerEvent("showStateFactionArrestGUI",self.m_ArrestZoneCol)
				end
			end
			cancelEvent()
		end
	)
end
