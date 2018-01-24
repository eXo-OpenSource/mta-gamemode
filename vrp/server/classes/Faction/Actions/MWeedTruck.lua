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
	self.m_BankAccount = BankServer.get("action.trucks")

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
					if FactionState:getSingleton():countPlayers() < WEEDTRUCK_MIN_MEMBERS then
						hitElement:sendError(_("Es müssen mindestens %d Staatsfraktionisten online sein!",hitElement, WEEDTRUCK_MIN_MEMBERS))
						return false
					end
					QuestionBox:new(hitElement, hitElement, _("Möchtest du einen Weed-Truck starten? Kosten: %s", hitElement, toMoneyString(MWeedTruck.Settings["costs"])), "weedTruckStart")
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
	local faction = source:getFaction()
	if faction then
		if faction:isEvilFaction() then
			if ActionsCheck:getSingleton():isActionAllowed(source) then
				if faction:getMoney() >= MWeedTruck.Settings["costs"] then
					faction:transferMoney(self.m_BankAccount, MWeedTruck.Settings["costs"], "Weed-Truck", "Action", "WeedTruck")
					self.m_CurrentWeedTruck = WeedTruck:new(source)
					ActionsCheck:getSingleton():setAction("Weed-Truck")
					FactionState:getSingleton():sendMoveRequest(TSConnect.Channel.STATE)
					StatisticsLogger:getSingleton():addActionLog("Weed-Truck", "start", source, faction, "faction")
				else
					source:sendError(_("Du hast nicht genug Geld in der Fraktionskasse! (%s)", source, toMoneyString(MWeedTruck.Settings["costs"])))
				end
			end
		end
	end
end
