-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/MWeedTruck.lua
-- *  PURPOSE:     Weed Truck Manager Class
-- *
-- ****************************************************************************

MWeedTruck = inherit(Singleton)
MWeedTruck.Settings = {["costs"] = 10000}

function MWeedTruck:constructor()
	self:createStartPoint(-1095.50, -1614.75, 75.5)

	self.m_HelpColShape = createColSphere(-1095.50, -1614.75, 75.5, 5)
	addEventHandler("onColShapeHit", self.m_HelpColShape, bind(self.onHelpColHit, self))
	addEventHandler("onColShapeLeave", self.m_HelpColShape, bind(self.onHelpColHit, self))

	addRemoteEvents{"weedTruckStart"}
	addEventHandler("weedTruckStart", root, bind(self.Event_weedTruckStart, self))
end

function MWeedTruck:destructor()
end

function MWeedTruck:createStartPoint(x, y, z, type)
	--self.m_Blip = Blip:new("Waypoint.png", x, y, self.m_Driver)
	local marker = createMarker(x, y, z, "cylinder",1)
	addEventHandler("onMarkerHit", marker, bind(self.onStartPointHit, self))
end

function MWeedTruck:onHelpColHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		if hitElement:getFaction() and hitElement:getFaction():isEvilFaction() then
			hitElement:triggerEvent("setManualHelpBarText", "HelpTextTitles.Actions.WeedTruck", "HelpTexts.Actions.WeedTruck", true)
		end
	end
end

function MWeedTruck:onHelpColLeave(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		hitElement:triggerEvent("resetManualHelpBarText")
	end
end

function MWeedTruck:onStartPointHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction then
			if faction:isEvilFaction() then
				if ActionsCheck:getSingleton():isActionAllowed(hitElement) then
					hitElement:triggerEvent("questionBox", _("Möchtest du einen Weed-Truck starten? Kosten: %d$", hitElement, MWeedTruck.Settings["costs"]), "weedTruckStart")
				end
			else
				hitElement:sendError(_("Den Weed-Truck können nur Mitglieder böser Fraktionen starten!",hitElement))
			end
		else
			hitElement:sendError(_("Den Weed-Truck können nur Fraktions-Mitglieder starten!",hitElement))
		end
	end
end

function MWeedTruck:Event_weedTruckStart()
	local faction = client:getFaction()
	if faction then
		if faction:isEvilFaction() then
			if ActionsCheck:getSingleton():isActionAllowed(client) then
				if client:getMoney() >= MWeedTruck.Settings["costs"] then
					self.m_CurrentWeedTruck = WeedTruck:new(client)
					ActionsCheck:getSingleton():setAction("Weed-Truck")
					StatisticsLogger:getSingleton():addActionLog("Weed-Truck", "start", client, faction, "faction")

				else
					hitElement:sendError(_("Du hast nicht genug Geld dabei!",hitElement))
				end
			end
		end
	end
end
