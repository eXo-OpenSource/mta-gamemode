-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/MWeaponTruck.lua
-- *  PURPOSE:     Weapon Truck Manager Class
-- *
-- ****************************************************************************

MWeaponTruck = inherit(Singleton)


function MWeaponTruck:constructor()
	self:createStartPoint(-1869.14, 1421.49, 6.2, "evil")
	self:createStartPoint(117.28, 1884.58, 17, "state")
	self.m_CurrentWT = false
	self.m_CurrentType = ""
	self.m_BankAccount = BankServer.get("action.trucks")
	addRemoteEvents{"onWeaponTruckLoad"}
	addEventHandler("onWeaponTruckLoad", root, bind(self.Event_onWeaponTruckLoad, self))
end

function MWeaponTruck:destructor()
end

function MWeaponTruck:createStartPoint(x, y, z, type)
	--self.m_Blip = Blip:new("Waypoint.png", x, y, self.m_Driver)
	local marker = createMarker(x, y, z, "cylinder",1)
	marker.type = type
	addEventHandler("onMarkerHit", marker, bind(self.onStartPointHit, self))
	self.m_HelpColShape = createColSphere(x, y, z, 5)
	self.m_HelpColShape.type = type
	addEventHandler("onColShapeHit", self.m_HelpColShape, bind(self.onHelpColHit, self))
	addEventHandler("onColShapeLeave", self.m_HelpColShape, bind(self.onHelpColHit, self))

end

function MWeaponTruck:onHelpColHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		if source.type == "evil" then
			if hitElement:getFaction() and hitElement:getFaction():isEvilFaction() then
				hitElement:triggerEvent("setManualHelpBarText", "HelpTextTitles.Actions.WeaponTruck", "HelpTexts.Actions.WeaponTruck", true)
			end
		elseif source.type == "state" then
			if hitElement:getFaction() and hitElement:getFaction():isStateFaction() then
				hitElement:triggerEvent("setManualHelpBarText", "HelpTextTitles.Actions.StateWeaponTruck", "HelpTexts.Actions.StateWeaponTruck", true)
			end
		end
	end
end

function MWeaponTruck:onHelpColLeave(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		hitElement:triggerEvent("resetManualHelpBarText")
	end
end

function MWeaponTruck:onStartPointHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction then
			if (faction:isEvilFaction() and source.type == "evil") or (faction:isStateFaction() and source.type == "state" and hitElement:isFactionDuty()) then
				if source.type == "evil" then
					if FactionState:getSingleton():countPlayers() < WEAPONTRUCK_MIN_MEMBERS[source.type] and not DEBUG then
						hitElement:sendError(_("Es müssen mindestens 3 Staatsfraktionisten online sein!",hitElement))
						return
					end
				elseif source.type == "state" then
					if FactionEvil:getSingleton():countPlayers() < WEAPONTRUCK_MIN_MEMBERS[source.type] and not DEBUG then
						hitElement:sendError(_("Es müssen mindestens 3 Spieler böser Fraktionen online sein!",hitElement))
						return
					end
				end

				if ActionsCheck:getSingleton():isActionAllowed(hitElement) then
					hitElement:triggerEvent("showFactionWTLoadGUI")
					self.m_CurrentType = source.type
				end
			else
				if source.type == "evil" then
					hitElement:sendError(_("Den Waffentruck können nur Mitglieder böser Fraktionen starten!",hitElement))
				elseif source.type == "state" then
					hitElement:sendError(_("Den Staats-Waffentruck können nur Mitglieder von Staats-Fraktionen im Dienst starten!",hitElement))
				end
			end
		else
			hitElement:sendError(_("Den Waffentruck können nur Fraktions-Mitglieder starten!",hitElement))
		end
	end
end

function MWeaponTruck:Event_onWeaponTruckLoad(weaponTable)
	if ActionsCheck:getSingleton():isActionAllowed(client) then
		local faction = client:getFaction()

		if faction:isEvilFaction() then
			self.m_CurrentType = "evil"
		elseif faction:isStateFaction() then
			if client:isFactionDuty() then
				self.m_CurrentType = "state"
			else
				client:sendError(_("Du bist nicht im Dienst!",client))
				return
			end
		else
			client:sendError(_("Ungültige Fraktion!",client))
		end

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
			if faction:getMoney() >= totalAmount then
				if totalAmount > 0 then
					if ActionsCheck:getSingleton():isActionAllowed(client) then

						if self.m_CurrentType == "evil" then
							faction:transferMoney(self.m_BankAccount, totalAmount, "Waffen-Truck", "Action", "WeaponTruck")
						elseif self.m_CurrentType == "state" then
							if not client:isFactionDuty() then
								client:sendError(_("Du bist nicht im Dienst!",client))
								return
							end
							faction:transferMoney(self.m_BankAccount, totalAmount, "Waffen-Truck", "Action", "WeaponTruck")
						end
						ActionsCheck:getSingleton():setAction(WEAPONTRUCK_NAME[self.m_CurrentType])
						FactionState:getSingleton():sendMoveRequest(TSConnect.Channel.STATE)
						if self.m_CurrentWT then delete(self.m_CurrentWT) end
						client:sendInfo(_("Die Ladung steht bereit! Klicke die Kisten an und bringe sie zum Waffen-Truck! Gesamtkosten: %d$",client,totalAmount))
						self.m_CurrentWT = WeaponTruck:new(client, weaponTable, totalAmount, self.m_CurrentType)
						PlayerManager:getSingleton():breakingNews("Ein %s wird beladen", WEAPONTRUCK_NAME[self.m_CurrentType])
						Discord:getSingleton():outputBreakingNews(string.format("Ein %s wird beladen", WEAPONTRUCK_NAME[self.m_CurrentType]))
						if self.m_CurrentType == "evil" then
							FactionState:getSingleton():sendWarning("Ein %s wird beladen", "Neuer Einsatz", true, WeaponTruck.spawnPos[self.m_CurrentType], WEAPONTRUCK_NAME[self.m_CurrentType])
						else
							FactionEvil:getSingleton():sendWarning("Ein %s wird beladen", "Neue Aktion", true, WeaponTruck.spawnPos[self.m_CurrentType], WEAPONTRUCK_NAME[self.m_CurrentType])
						end
						StatisticsLogger:getSingleton():addActionLog(WEAPONTRUCK_NAME[self.m_CurrentType], "start", client, client:getFaction(), "faction")
					end
				else
					client:sendError(_("Du hast zuwenig augeladen! Mindestens: %d$",client,self.m_AmountPerBox))
				end
			else
				client:sendError(_("Ihr hast nicht ausreichend Geld in der Fraktions_Kasse! (%d$)",client,totalAmount))
			end
		else
			client:sendError(_("Du bist in keiner Fraktion!",client))
		end
	end
end
