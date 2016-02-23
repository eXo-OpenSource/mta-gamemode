-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionRescue.lua
-- *  PURPOSE:     Faction Rescue Class
-- *
-- ****************************************************************************
FactionRescue = inherit(Singleton)
addRemoteEvents{"factionRescueToggleDuty", "factionRescueHealPlayerQuestion", "factionRescueDiscardHealPlayer", "factionRescueHealPlayer"}

function FactionRescue:constructor()
	-- Duty Pickup
	self:createDutyPickup(1720.80, -1772.05, 13.88,0)

	-- Barriers
	VehicleBarrier:new(Vector3(1743.09, -1742.30, 13.30), Vector3(0, 90, -180)).onBarrierHit = bind(self.onBarrierHit, self)
	VehicleBarrier:new(Vector3(1740.59, -1807.80, 13.39), Vector3(0, 0, -15.75)).onBarrierHit = bind(self.onBarrierHit, self)

	-- Register in Player Hook
	PlayerManager:getSingleton():getWastedHook():register(bind(self.Event_OnPlayerWasted, self))

	-- Events
	addEventHandler("factionRescueToggleDuty", root, bind(self.Event_toggleDuty, self))
	addEventHandler("factionRescueHealPlayerQuestion", root, bind(self.Event_healPlayerQuestion, self))
	addEventHandler("factionRescueDiscardHealPlayer", root, bind(self.Event_discardHealPlayer, self))
	addEventHandler("factionRescueHealPlayer", root, bind(self.Event_healPlayer, self))

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

function FactionRescue:onBarrierHit(player)
    if not player:getFaction() or not player:getFaction():isRescueFaction() then
        player:sendError(_("Zufahrt Verboten!", player))
        return false
    end
    return true
end

function FactionRescue:createDutyPickup(x,y,z,int)
	self.m_DutyPickup = createPickup(x,y,z, 3, 1275)
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

-- Death System
function FactionRescue:createDeathPickup(player)
	player.m_DeathPickup = Pickup(player:getPosition(), 3, 1254, 0)
	addEventHandler("onPickupHit", player.m_DeathPickup,
		function (hitPlayer)
			if hitPlayer:getFaction() and hitPlayer:getFaction():isRescueFaction() then
				hitPlayer:sendShortMessage(("He's dead son.\nIn Memories of %s"):format(player:getName()))
				-- open clientside gui
			end
		end
	)
end

function FactionRescue:Event_OnPlayerWasted(player)
	-- if we return true here, we have to handle the spawn in this function
	-- if we retrun false here, we don't have to do this

	local faction = FactionManager:getSingleton():getFromId(4)
	if #faction:getOnlinePlayers() > 0 then
		if not player.m_DeathPickup then
			local zoneName, cityName = getZoneName(player:getPosition()), getZoneName(player:getPosition(), true)

			faction:sendShortMessage(("%s died.\nPosition: %s - %s"):format(player:getName(), zoneName, cityName))
			self:createDeathPickup(player)
			player:respawn()

			return true
		else -- This should never never happen!
			outputDebug("Internal Error! Player died while he is Dead. Dafuq?")
		end
	end

	return false
end

function FactionRescue:Event_healPlayerQuestion(target)
	if isElement(target) then
		if target:getHealth() < 100 then
			local costs = math.floor(100-target:getHealth())
			target:triggerEvent("questionBox", _("Der Medic %s bietet Ihnen eine Heilung an! \nDiese kostet %d$! Annehmen?", target, client.name, costs), "factionRescueHealPlayer", "factionRescueDiscardHealPlayer", client, target)
		else
			client:sendError(_("Der Spieler hat volles Leben!", client))
		end
	else
		client:sendError(_("Interner Fehler: Argumente falsch @FactionRescue:Event_healPlayerQuestion!", client))
	end
end

function FactionRescue:Event_discardHealPlayer(medic, target)
    medic:sendError(_("Der Spieler %s hat die Heilung abgelehnt!", medic, target.name))
    target:sendError(_("Du hast die Heilung mit %s abgelehnt!", target, medic.name))
end

function FactionRescue:Event_healPlayer(medic, target)
	if isElement(target) then
		if target:getHealth() < 100 then

			local costs = math.floor(100-target:getHealth())
			if target:getMoney() >= costs then
				medic:sendInfo(_("Du hast den Spieler %s für %d$ geheilt!", medic, target.name, costs ))
				target:sendInfo(_("Du wurdest von medic %s für %d$ geheilt!", target, medic.name, costs ))
				target:setHealth(100)
				target:takeMoney(costs)
				self.m_Faction:setMoney(self.m_Faction:getMoney() + costs)
			else
				medic:sendError(_("Der Spieler hat nicht genug Geld! (%d$)", medic, costs))
				target:sendError(_("Du hast nicht genug Geld! (%d$)", target, costs))

			end
		else
			medic:sendError(_("Der Spieler hat volles Leben!", medic))
		end
	else
		medic:sendError(_("Interner Fehler: Argumente falsch @FactionRescue:Event_healPlayer!", medic))
	end
end
