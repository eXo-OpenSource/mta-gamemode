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

	self:createDutyPickup(1720.80, -1772.05, 13.88,0) -- PD Interior
	addRemoteEvents{"factionRescueToggleDuty"}
	addEventHandler("factionRescueToggleDuty", root, bind(self.Event_toggleDuty, self))
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

function FactionRescue:createDutyPickup(x,y,z,int)
	self.m_DutyPickup = createPickup(x,y,z, 3, 1275) --PD
	setElementInterior(self.m_DutyPickup, int)
	addEventHandler("onPickupHit", self.m_DutyPickup,
		function(hitElement)
			if getElementType(hitElement) == "player" then
				local faction = hitElement:getFaction()
				if faction then
					if faction:isRescueFaction() == true then
						hitElement:triggerEvent("showRescueFactionDutyGUI")
						--hitElement:getFaction():updateStateFactionDutyGUI(hitElement)
					end
				end
			end
			cancelEvent()
		end
	)
end

function FactionRescue:Event_toggleDuty(type)
	local faction = client:getFaction()
	if faction:isRescueFaction() then
		if client:isFactionDuty() then
			client:setDefaultSkin()
			client.m_FactionDuty = false
			client:sendInfo(_("Du bist nicht mehr im Dienst!", client))
			client:setPublicSync("Faction:Duty",false)
			client:setPublicSync("Rescue:Type",false)
			client:getInventory():removeAllItem("Barrikade")
		else
			client.m_FactionDuty = true
			client:sendInfo(_("Du bist nun im Dienst!", client))
			client:setPublicSync("Faction:Duty",true)
			client:setPublicSync("Rescue:Type",type)
			faction:changeSkin(client, type)
			client:getInventory():removeAllItem("Barrikade")
			client:getInventory():giveItem("Barrikade", 10)
		end
	else
		client:sendError(_("Du bist in nicht im Rescue-Team!", client))
	end
end
