-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionRescue.lua
-- *  PURPOSE:     Faction Rescue Class
-- *
-- ****************************************************************************
FactionRescue = inherit(Singleton)
addRemoteEvents{"factionRescueToggleDuty", "factionRescueHealPlayerQuestion", "factionRescueDiscardHealPlayer", "factionRescueHealPlayer", "factionRescueWastedFinished", "factionRescueChangeSkin", "factionRescueToggleStretcher"}

function FactionRescue:constructor()
	-- Duty Pickup
	self:createDutyPickup(1721.06, -1752.76, 13.55, 0) -- Base
	self:createDutyPickup(1760.72, -1744.20, 6, 0) -- Garage


	self.m_Skins = {}
	self.m_Skins["medic"] = {70, 71, 274, 275, 276}
	self.m_Skins["fire"] = {260, 277, 278, 279}

	self.m_LastStrecher = {}

	-- Barriers
	--VehicleBarrier:new(Vector3(1743.09, -1742.30, 13.30), Vector3(0, 90, -180)).onBarrierHit = bind(self.onBarrierHit, self)
	--VehicleBarrier:new(Vector3(1740.59, -1807.80, 13.40), Vector3(0, 90, -15.75)).onBarrierHit = bind(self.onBarrierHit, self)
	--VehicleBarrier:new(Vector3(1811.50, -1761.50, 13.40), Vector3(0, 90, 90)).onBarrierHit = bind(self.onBarrierHit, self)

	local elevator = Elevator:new()

	elevator:addStation("UG Garage", Vector3(1756.40, -1747.44, 6.22))
	elevator:addStation("Erdgeschoss", Vector3(1744.63, -1752.5, 13.57))
	elevator:addStation("1.Obergeschoss", Vector3(1744.63, -1751.69, 18.81))
	elevator:addStation("3.OG Heliport 1", Vector3(1778.19, -1786.69, 46.18))
	elevator:addStation("3.OG Heliport 2", Vector3(1785.10, -1788.13, 46.18))


	self.m_Faction = FactionManager.Map[4]

	nextframe( -- Todo workaround
		function ()
			local safe = createObject(2332, 1187.70, -1396.50, 6.4, 0, 0, 180)
			FactionManager:getSingleton():getFromId(4):setSafe(safe)
		end
	)


	self:createNoCollissionSpawn()

	-- Events
	addEventHandler("factionRescueToggleDuty", root, bind(self.Event_toggleDuty, self))
	addEventHandler("factionRescueHealPlayerQuestion", root, bind(self.Event_healPlayerQuestion, self))
	addEventHandler("factionRescueDiscardHealPlayer", root, bind(self.Event_discardHealPlayer, self))
	addEventHandler("factionRescueHealPlayer", root, bind(self.Event_healPlayer, self))
	addEventHandler("factionRescueWastedFinished", root, bind(self.Event_OnPlayerWastedFinish, self))
	addEventHandler("factionRescueChangeSkin", root, bind(self.Event_changeSkin, self))
	addEventHandler("factionRescueToggleStretcher", root, bind(self.Event_ToggleStretcher, self))


end

function FactionRescue:destructor()
end

function FactionRescue:countPlayers()
	return #self.m_Faction:getOnlinePlayers()
end

function FactionRescue:getOnlinePlayers()
	local players = {}

	for index, value in pairs(self.m_Faction:getOnlinePlayers()) do
		table.insert(players, value)
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

function FactionRescue:createNoCollissionSpawn()
	local col = createColSphere(HOSPITAL_POSITION, 3)
	addEventHandler("onColShapeLeave", col, function(hitElement, dim)
		if dim and hitElement:getType() == "player" then
			hitElement:setCollisionsEnabled(true)
		end
	end)
end

function FactionRescue:Event_changeSkin(player)

	if not player then player = client end

	local type = player:getPublicSync("Rescue:Type")
	local curskin = getElementModel(player)

	local suc = false
	for i = curskin+1, 313 do
		if table.find(self.m_Skins[type], i) then
			suc = true
			player:setModel(i)
			break
		end
	end
	if suc == false then
		for i = 0, curskin do
			if table.find(self.m_Skins[type], i) then
				suc = true
				player:setModel(i)
				break
			end
		end
	end
	player:triggerEvent("showRescueFactionDutyGUI", true)

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
			if client:getPublicSync("Company:Duty") and client:getCompany() then
				client:sendWarning(_("Bitte beende zuerst deinen Unternehmens-Dienst!", client))
				return false
			end
			if type == "fire" then
				giveWeapon(client,42,200,true)
			end
			client.m_FactionDuty = true
			client:sendInfo(_("Du bist nun im Dienst!", client))
			client:setPublicSync("Faction:Duty",true)
			client:setPublicSync("Rescue:Type",type)
			client:getInventory():removeAllItem("Barrikade")
			client:getInventory():giveItem("Barrikade", 10)
			self:Event_changeSkin(client)
		end
	else
		client:sendError(_("Du bist in nicht im Rescue-Team!", client))
		return false
	end
end

-- Death System
function FactionRescue:Event_ToggleStretcher(vehicle)
	if client:getFaction() == self.m_Faction then
		if client:isFactionDuty() and client:getPublicSync("Rescue:Type") == "medic" then
			if not self.m_LastStrecher[client] or timestampCoolDown(self.m_LastStrecher[client], 6) then
				if client.m_RescueStretcher then
					self:removeStretcher(client, vehicle)
				else
					self:getStretcher(client, vehicle)
				end
			else
				client:sendError(_("Du kannst die Trage nicht so oft hintereinander aus/einladen!", client))
			end
		else
			client:sendError(_("Du bist nicht im Medic-Dienst!", client))
		end
	end
end

function FactionRescue:getStretcher(player, vehicle)
	-- Open the doors
	self.m_LastStrecher[client] = getRealTime().timestamp
	vehicle:setDoorState(4, 0)
	vehicle:setDoorState(5, 0)
	vehicle:setDoorOpenRatio(4, 1)
	vehicle:setDoorOpenRatio(5, 1)

	-- Create the Stretcher
	if not player.m_RescueStretcher then
		player.m_RescueStretcher = createObject(2146, vehicle:getPosition() + vehicle.matrix.forward*-3, vehicle:getRotation())
		player.m_RescueStretcher:setCollisionsEnabled(false)
		player.m_RescueStretcher.m_Vehicle = vehicle
	end

	-- Move the Stretcher to the Player
	moveObject(player.m_RescueStretcher, 3000, player:getPosition() + player.matrix.forward*1.4 + Vector3(0, 0, -0.5), Vector3(0, 0, player:getRotation().z - vehicle:getRotation().z), "InOutQuad")
	player:setFrozen(true)

	setTimer(
		function (player)
			player.m_RescueStretcher:attach(player, Vector3(0, 1.4, -0.5))
			player:toggleControlsWhileObjectAttached(false)
			player:setFrozen(false)
		end, 3000, 1, player
	)
end

function FactionRescue:removeStretcher(player, vehicle)
	-- Move it into the Vehicle
	self.m_LastStrecher[client] = getRealTime().timestamp
	player.m_RescueStretcher:detach()
	player.m_RescueStretcher:setRotation(player:getRotation())
	player.m_RescueStretcher:setPosition(player:getPosition() + player.matrix.forward*1.4 + Vector3(0, 0, -0.5))
	moveObject(player.m_RescueStretcher, 3000, vehicle:getPosition() + vehicle.matrix.forward*-2, Vector3(0, 0, vehicle:getRotation().z - player:getRotation().z), "InOutQuad")

	-- Enable Controls
	player:toggleControlsWhileObjectAttached(true)

	setTimer(
		function(vehicle, player)
			-- Close the doors
			vehicle:setDoorOpenRatio(4, 0)
			vehicle:setDoorOpenRatio(5, 0)

			if player.m_RescueStretcher.player then
				local deadPlayer = player.m_RescueStretcher.player
				if deadPlayer:isDead() then
					deadPlayer:triggerEvent("abortDeathGUI")
					local pos = vehicle.position - vehicle.matrix.forward*4
					deadPlayer:sendInfo(_("Du wurdest erfolgreich wiederbelebt!", deadPlayer))
					player:sendShortMessage(_("Du hast den Spieler erfolgreich wiederbelebt!", player))
					deadPlayer:setCameraTarget(player)
					deadPlayer:respawn(pos)
					deadPlayer:fadeCamera(true, 1)
				else
					player:sendShortMessage(_("Der Spieler ist nicht Tod!", player))
				end
			end

			player.m_RescueStretcher:destroy()
			player.m_RescueStretcher = nil
		end, 3000, 1, vehicle, player
	)
end

function FactionRescue:createDeathPickup(player, ...)
	local pos = player:getPosition()
	local gw = ""
	if player:isInGangwar() then gw = "(Gangwar)" end

	player.m_DeathPickup = Pickup(pos, 3, 1254, 0)

	for index, rescuePlayer in pairs(self:getOnlinePlayers()) do
		rescuePlayer:sendShortMessage(("%s ist gestorben. %s \nPosition: %s - %s"):format(player:getName(), gw, getZoneName(player:getPosition()), getZoneName(player:getPosition(), true)))
		rescuePlayer:triggerEvent("rescueCreateDeathBlip", player)
	end

	nextframe(function () player:setPosition(player.m_DeathPickup:getPosition()) end)
	--player:kill()

	addEventHandler("onPickupHit", player.m_DeathPickup,
		function (hitPlayer)
			if hitPlayer:getFaction() and hitPlayer:getFaction():isRescueFaction() then
				if hitPlayer:getPublicSync("Faction:Duty") and hitPlayer:getPublicSync("Rescue:Type") == "medic" then
					if hitPlayer.m_RescueStretcher then
						player:attach(hitPlayer.m_RescueStretcher, 0, -0.2, 1.4)
						hitPlayer.m_RescueStretcher.player = player
					else
						hitPlayer:sendError(_("Du hast keine Trage dabei!", hitPlayer))
					end
				end
			else
				hitPlayer:sendShortMessage(("He's dead son.\nIn Memories of %s"):format(player:getName()))
			end
		end
	)

	setTimer(
		function ()
			if player.m_DeathPickup then
				player.m_DeathPickup:destroy()
				player.m_DeathPickup = nil
				for index, rescuePlayer in pairs(self:getOnlinePlayers()) do
					rescuePlayer:triggerEvent("rescueRemoveDeathBlip", player)
				end
			end
		end,
	player:getPublicSync("DeathTime"), 1)
	-- Create PlayerDeathTimeout
	--self:createDeathTimeout(player, ...)

end

function FactionRescue:createDeathTimeout(player, callback)
	--player:triggerEvent("playerRescueDeathTimeout", PLAYER_DEATH_TIME)
	setTimer(
		function ()
			if player.m_DeathPickup then
				player.m_DeathPickup:destroy()
				player.m_DeathPickup = nil
			end
			return callback()
		end, 5000, 1
		-- PLAYER_DEATH_TIME
	)
end

function FactionRescue:Event_OnPlayerWastedFinish()
	source:setCameraTarget(player)
	source:fadeCamera(true, 1)
	source:setCollisionsEnabled(false)
	source:respawn()
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
				StatisticsLogger:getSingleton():addHealLog(client, 100, "Rescue Team "..medic.name)

				target:takeMoney(costs, "Rescue Team Heilung")
				self.m_Faction:giveMoney(costs, "Rescue Team Heilung")
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
