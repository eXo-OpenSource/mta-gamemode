-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionRescue.lua
-- *  PURPOSE:     Faction Rescue Class
-- *
-- ****************************************************************************
FactionRescue = inherit(Singleton)
addRemoteEvents{
	"factionRescueToggleDuty", "factionRescueHealPlayerQuestion", "factionRescueDiscardHealPlayer", "factionRescueHealPlayer",
	"factionRescueWastedFinished", "factionRescueChangeSkin", "factionRescueToggleStretcher", "factionRescuePlayerHealBase",
	"factionRescueReviveAbort", "factionRescueToggleLadder"
}

function FactionRescue:constructor()
	-- Duty Pickup
	self:createDutyPickup(1721.06, -1752.76, 13.55, 0) -- Base
	self:createDutyPickup(1760.72, -1744.20, 6, 0) -- Garage


	self.m_Skins = {}
	self.m_Skins["medic"] = {70, 71, 274, 275, 276}
	self.m_Skins["fire"] = {27, 277, 278, 279}

	self.m_LastStrecher = {}

	-- Barriers
	--VehicleBarrier:new(Vector3(1743.09, -1742.30, 13.30), Vector3(0, 90, -180)).onBarrierHit = bind(self.onBarrierHit, self)
	--VehicleBarrier:new(Vector3(1740.59, -1807.80, 13.40), Vector3(0, 90, -15.75)).onBarrierHit = bind(self.onBarrierHit, self)
	--VehicleBarrier:new(Vector3(1811.50, -1761.50, 13.40), Vector3(0, 90, 90)).onBarrierHit = bind(self.onBarrierHit, self)

	local elevator = Elevator:new()

	elevator:addStation("UG Garage", Vector3(1756.40, -1747.44, 6.22))
	elevator:addStation("Erdgeschoss", Vector3(1744.63, -1752.5, 13.57))
	elevator:addStation("1.Obergeschoss", Vector3(1744.63, -1751.69, 18.81))
	elevator:addStation("2.Obergeschoss", Vector3(1744.63, -1751.69, 23.533))
	elevator:addStation("3.OG Heliport 1", Vector3(1778.19, -1786.69, 46.18))
	elevator:addStation("3.OG Heliport 2", Vector3(1785.10, -1788.13, 46.18))

	local terraceElevator = Elevator:new()
	terraceElevator:addStation("2.Obergeschoss", Vector3(1720.411, -1753.330, 23.539))
	terraceElevator:addStation("Terrasse unten", Vector3(1743.533, -1765.879, 31.322))
	terraceElevator:addStation("Terrasse oben", Vector3( 1743.533, -1765.879, 36.891))

	self.m_Faction = FactionManager.Map[4]

	self.m_LadderBind = bind(self.ladderFunction, self)
	self.m_MoveLadderBind = bind(self.moveLadder, self)


	nextframe( -- Todo workaround
		function ()
			local safe = createObject(2332, 1720, -1752.40, 14.10, 0, 0, 90)
			FactionManager:getSingleton():getFromId(4):setSafe(safe)

			FactionManager:getSingleton():createVehicleServiceMarker("Rescue", Vector3(1798, -1739.7, 5)) --Unity garage
			FactionManager:getSingleton():createVehicleServiceMarker("Rescue", Vector3(1713.385, -1774.8, 12.5)) --Unity side
		end
	)

	-- Events
	addEventHandler("factionRescueToggleDuty", root, bind(self.Event_toggleDuty, self))
	addEventHandler("factionRescueHealPlayerQuestion", root, bind(self.Event_healPlayerQuestion, self))
	addEventHandler("factionRescueDiscardHealPlayer", root, bind(self.Event_discardHealPlayer, self))
	addEventHandler("factionRescueHealPlayer", root, bind(self.Event_healPlayer, self))
	addEventHandler("factionRescueWastedFinished", root, bind(self.Event_OnPlayerWastedFinish, self))
	addEventHandler("factionRescueChangeSkin", root, bind(self.Event_changeSkin, self))
	addEventHandler("factionRescueToggleStretcher", root, bind(self.Event_ToggleStretcher, self))
	addEventHandler("factionRescuePlayerHealBase", root, bind(self.Event_healPlayerHospital, self))
	addEventHandler("factionRescueReviveAbort", root, bind(self.destroyDeathBlip, self))
	addEventHandler("factionRescueToggleLadder", root, bind(self.Event_toggleLadder, self))



	PlayerManager:getSingleton():getQuitHook():register(
		function(player)
			if player.m_DeathPickup then
				player.m_DeathPickup:destroy()
				player.m_DeathPickup = nil
				for index, rescuePlayer in pairs(self:getOnlinePlayers()) do
					rescuePlayer:triggerEvent("rescueRemoveDeathBlip", player)
				end
			end
		end
	)


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

function FactionRescue:sendWarning(text, header, withOffDuty, ...)
	for k, player in pairs(self:getOnlinePlayers()) do
		if player:isFactionDuty() or withOffDuty then
			player:sendWarning(_(text, player, ...), 30000, header)
		end
	end
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
						if not hitElement.vehicle then
							hitElement.m_CurrentDutyPickup = source
							hitElement:triggerEvent("showRescueFactionDutyGUI")
							--hitElement:getFaction():updateStateFactionDutyGUI(hitElement)
						else
      						hitElement:sendError(_("Du darfst nicht in einem Fahrzeug sitzen!", hitElement))
						end
					end
				end
			end
			cancelEvent()
		end
	)
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

function FactionRescue:Event_toggleDuty(type, wasted)
	local faction = client:getFaction()
	if faction:isRescueFaction() then
		if getDistanceBetweenPoints3D(client.position, client.m_CurrentDutyPickup.position) <= 10 or wasted then
			if client:isFactionDuty() then
				client:setDefaultSkin()
				client.m_FactionDuty = false
				client:sendInfo(_("Du bist nicht mehr im Dienst deiner Fraktion!", client))
				client:setPublicSync("Faction:Duty",false)
				client:setPublicSync("Rescue:Type",false)
				client:getInventory():removeAllItem("Warnkegel")
				takeWeapon(client,42)
			else
				if client:getPublicSync("Company:Duty") and client:getCompany() then
					client:sendWarning(_("Bitte beende zuerst deinen Dienst im Unternehmen!", client))
					return false
				end
				takeWeapon(client,42)
				if type == "fire" then
					giveWeapon(client, 42, 2000, true)
				end
				client.m_FactionDuty = true
				client:sendInfo(_("Du bist nun im Dienst deiner Fraktion!", client))
				client:setPublicSync("Faction:Duty",true)
				client:setPublicSync("Rescue:Type",type)
				client:getInventory():removeAllItem("Warnkegel")
				client:getInventory():giveItem("Warnkegel", 10)
				self:Event_changeSkin(client)
			end
		else
			client:sendError(_("Du bist zu weit entfernt!", client))
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
					setElementAlpha(client,255)
					if isElement(client.ped_deadDouble) then
						destroyElement(client.ped_deadDouble)
					end
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
	setElementAlpha(player,255)
	if isElement(player.ped_deadDouble) then
		destroyElement(player.ped_deadDouble)
	end
	-- Move the Stretcher to the Player
	moveObject(player.m_RescueStretcher, 3000, player:getPosition() + player.matrix.forward*1.4 + Vector3(0, 0, -0.5), Vector3(0, 0, player:getRotation().z - vehicle:getRotation().z), "InOutQuad")
	player:setFrozen(true)

	setTimer(
		function (player)
			player.m_RescueStretcher:attach(player, Vector3(0, 1.4, -0.5))
			if isElement(player.ped_deadDouble) then
				player.m_RescueStretcher:attach(player.ped_deadDouble, Vector3(0, 1.4, -0.5))
			end
			player:toggleControlsWhileObjectAttached(false)
			toggleControl(player, "jump", true) -- But allow jumping
			player:setFrozen(false)
			setElementAlpha(player,255)
			if isElement(player.ped_deadDouble) then
				destroyElement(player.ped_deadDouble)
			end
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
	setElementAlpha(player,255)
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
					self.m_Faction:giveMoney(100, "Rescue Team Wiederbelebung")
					player:giveMoney(50, "Rescue Team Wiederbelebung")
					if deadPlayer:giveReviveWeapons() then
						outputChatBox("Du hast deine Waffen während des Verblutens gesichert!", deadPlayer, 200, 200, 0)
					end
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
	local money = math.floor(player:getMoney()*0.25)
	player:takeMoney(money, "beim Tod verloren")
	player.m_DeathPickup.money = money

	for index, rescuePlayer in pairs(self:getOnlinePlayers()) do
		rescuePlayer:sendShortMessage(("%s ist gestorben. %s \nPosition: %s - %s"):format(player:getName(), gw, getZoneName(player:getPosition()), getZoneName(player:getPosition(), true)))
		rescuePlayer:triggerEvent("rescueCreateDeathBlip", player)
	end

	nextframe(function () if player.m_DeathPickup then player:setPosition(player.m_DeathPickup:getPosition()) end end)

	addEventHandler("onPickupHit", player.m_DeathPickup,
		function (hitPlayer)
			if hitPlayer:getType() == "player" and not hitPlayer.vehicle then
				if hitPlayer:getFaction() and hitPlayer:getFaction():isRescueFaction() then
					if hitPlayer:getPublicSync("Faction:Duty") and hitPlayer:getPublicSync("Rescue:Type") == "medic" then
						if hitPlayer.m_RescueStretcher then
							if not hitPlayer.m_RescueStretcher.player then
								player:attach(hitPlayer.m_RescueStretcher, 0, -0.2, 1.4)
								setElementAlpha(player,255)
								if isElement(player.ped_deadDouble) then
									destroyElement(player.ped_deadDouble)
								end
								hitPlayer.m_RescueStretcher.player = player
								if source.money and source.money > 0 then
									hitPlayer:giveMoney(source.money, "verlorenes Geld zurückbekommen")
									source.money = 0
								end

								source:destroy()
								player.m_DeathPickup = nil
								for index, rescuePlayer in pairs(self:getOnlinePlayers()) do
									rescuePlayer:triggerEvent("rescueRemoveDeathBlip", player)
								end
							else
								hitPlayer:sendError(_("Es liegt bereits ein Spieler auf der Trage!", hitPlayer))
							end
						else
							hitPlayer:sendError(_("Du hast keine Trage dabei!", hitPlayer))
						end
					end
				else
					if source.money and source.money > 0 then
						hitPlayer:giveMoney(source.money, "bei Leiche gefunden")
						source.money = 0
					end
					hitPlayer:sendShortMessage(("He's dead son.\nIn Memories of %s"):format(player:getName()))
				end
			end
		end
	)
	-- Create PlayerDeathTimeout
	--self:createDeathTimeout(player, ...)
end

function FactionRescue:destroyDeathBlip()
	if client.m_DeathPickup then
		client.m_DeathPickup:destroy()
		client.m_DeathPickup = nil
		for index, rescuePlayer in pairs(self:getOnlinePlayers()) do
			rescuePlayer:triggerEvent("rescueRemoveDeathBlip", client)
		end
	end
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
	source:setCameraTarget(source)
	source:fadeCamera(true, 1)
	source:respawn()
end

function FactionRescue:Event_healPlayerQuestion(target)
	if isElement(target) then
		if target:getHealth() < 100 then
			local costs = math.floor(100-target:getHealth())
			QuestionBox:new(client, target, _("Der Medic %s bietet Ihnen eine Heilung an! \nDiese kostet %d$! Annehmen?", target, client.name, costs), "factionRescueHealPlayer", "factionRescueDiscardHealPlayer", client, target)
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

function FactionRescue:Event_healPlayerHospital()
	if isElement(client) then
		if client:getHealth() < 100 then
			local costs = math.floor(100-client:getHealth())
			if client:getMoney() >= costs then
				client:setHealth(100)
				StatisticsLogger:getSingleton():addHealLog(client, 100, "Rescue Team [Heal-Bot]")
				client:sendInfo(_("Du wurdest für %s$ von dem Arzt geheilt!", client, costs))

				client:takeMoney(costs, "Rescue Team Heilung")
				self.m_Faction:giveMoney(costs, "Rescue Team Heilung")
			else
				client:sendError(_("Du hast zu wenig Geld dabei! (%s$)", client, costs))
			end
		else
			client:sendError(_("Du hast bereits volles Leben.", client))
		end
	end
end

function FactionRescue:onLadderTruckEnter(player, seat)
	if seat > 0 then return end
	if not source.LadderEnabled then
		player:sendShortMessage(_("Klicke auf das Fahrzeug um die Leiter zu bedienen!", player))
	else
		player:sendShortMessage(_("Klicke auf das Fahrzeug um die Leiter zu deaktivieren!", player))
		self:toggleLadder(source, player, true)
	end
end

function FactionRescue:disableLadderBinds(player)
	if player and isElement(player) and getElementType(player) == "player" then
		unbindKey(player, "w", "both", self.m_LadderBind)
		unbindKey(player, "a", "both", self.m_LadderBind)
		unbindKey(player, "s", "both", self.m_LadderBind)
		unbindKey(player, "d", "both", self.m_LadderBind)
		unbindKey(player, "lctrl", "both", self.m_LadderBind)
		unbindKey(player, "lshift", "both", self.m_LadderBind)
	end
end

function FactionRescue:onLadderTruckExit(player, seat)
	if seat > 0 then return end
	if source.LadderEnabled then
		self:disableLadderBinds(player)
		triggerClientEvent(player, "rescueLadderFixCamera", source)
		if source.LadderTimer and isTimer(source.LadderTimer) then
			killTimer(source.LadderTimer)
		end
	end
end

function FactionRescue:onLadderTruckReset(veh)
	if veh.Ladder then
		veh.Ladder["main"]:setAttachedOffsets(0, 0.5, 1.1)
		veh.Ladder["ladder1"]:setAttachedOffsets(0, 0, 0)
		veh.Ladder["ladder2"]:setAttachedOffsets(0, -1.4, 0.2)
		veh.Ladder["ladder3"]:setAttachedOffsets(0, -1, 0.2)
		veh.LadderEnabled = false
		veh.m_DisableToggleHandbrake = false
	else
		addEventHandler("onVehicleEnter", veh, bind(self.onLadderTruckEnter, self))
		addEventHandler("onVehicleStartExit", veh, bind(self.onLadderTruckExit, self))

		veh.LadderEnabled = false
		veh.LadderMove = {}

		veh.Ladder = {}
		veh.Ladder["main"] = createObject(1932, veh:getPosition())
		veh.Ladder["main"]:attach(veh, 0, 0.5, 1.1)
		veh.Ladder["mainAttachOffset"] = Vector3(0, 0.5, 1.1)

		veh.Ladder["ladder1"] = createObject(1931, veh:getPosition())
		veh.Ladder["ladder1"]:attach(veh.Ladder["main"], 0, 0, 0)

		veh.Ladder["ladder2"] = createObject(1931, veh:getPosition())
		veh.Ladder["ladder2"]:setScale(0.8)
		veh.Ladder["ladder2"]:attach(veh.Ladder["ladder1"], 0, -1.4, 0.2)

		veh.Ladder["ladder3"] = createObject(1931, veh:getPosition())
		veh.Ladder["ladder3"]:setScale(0.6)
		veh.Ladder["ladder3"]:attach(veh.Ladder["ladder2"], 0, -1, 0.2)
		for i,v in pairs(veh.Ladder) do
			if isElement(v) then
				if i ~= "main" then
					setElementCollisionsEnabled(v, true)
				end
				setElementData(v, "vehicle-attachment", veh) --register as a clickable object of the fire truck (mouse menu)
			end
		end
	end

	for i,v in pairs(veh.Ladder) do
		if isElement(v) then
			setElementCollisionsEnabled(v, false)
		end
	end

	if veh.LadderTimer and isTimer(veh.LadderTimer) then
		killTimer(veh.LadderTimer)
	end
end

function FactionRescue:toggleLadder(veh, player, force)
	if veh.LadderEnabled and not force then
		if veh.LadderTimer and isTimer(veh.LadderTimer) then
			killTimer(veh.LadderTimer)
		end
		if player then 
			player:sendShortMessage(_("Leiter deaktiviert! Du Kannst das Fahrzeug wieder fahren!", player)) 
			self:disableLadderBinds(player)
			triggerClientEvent(player, "rescueLadderFixCamera", veh)
		end
		self:onLadderTruckReset(veh)
		veh:setFrozen(false)
		triggerClientEvent("rescueLadderUpdateCollision", veh, false)
	else
		player:sendShortMessage(_("Leiter aktiviert! Bediene die Leiter mit W,A,S,D; STRG und SHIFT!", player))
		veh.LadderEnabled = true
		bindKey(player, "w", "both", self.m_LadderBind)
		bindKey(player, "a", "both", self.m_LadderBind)
		bindKey(player, "s", "both", self.m_LadderBind)
		bindKey(player, "d", "both", self.m_LadderBind)
		bindKey(player, "lctrl", "both", self.m_LadderBind)
		bindKey(player, "lshift", "both", self.m_LadderBind)
		veh.LadderTimer = setTimer(self.m_MoveLadderBind, 50, 0, veh)
		veh:setFrozen(true)
		veh.m_DisableToggleHandbrake = true
		triggerClientEvent("rescueLadderUpdateCollision", veh, true)
	end
end


function FactionRescue:Event_toggleLadder()
	self:toggleLadder(source, client)
end

function FactionRescue:ladderFunction(player, key, state)
	local veh = player.vehicle
	if not veh then self:disableLadderBinds(player) return end
	if veh:getModel() ~= 544 then self:disableLadderBinds(player) return end

	if key == "d" then	veh.LadderMove["left"] = state == "down" and true or false end
	if key == "a" then	veh.LadderMove["right"] = state == "down" and true or false end
	if key == "w" then	veh.LadderMove["up"] = state == "down" and true or false end
	if key == "s" then	veh.LadderMove["down"] = state == "down" and true or false end
	if key == "lctrl" then	veh.LadderMove["in"] = state == "down" and true or false end
	if key == "lshift" then	veh.LadderMove["out"] = state == "down" and true or false end
end

function FactionRescue:moveLadder(veh)
	local x, y, z, rx, ry, rz = getElementAttachedOffsets(veh.Ladder["main"])
	local x1, y1, z1, rx1, ry1, rz1 = getElementAttachedOffsets(veh.Ladder["ladder1"])
	local x2, y2, z2, rx2, ry2, rz2 = getElementAttachedOffsets(veh.Ladder["ladder2"])
	local x3, y3, z3, rx3, ry3, rz3 = getElementAttachedOffsets(veh.Ladder["ladder3"])


	if veh.LadderMove["right"] then
		veh.Ladder["main"]:setAttachedOffsets(x, y, z, rx, ry, rz+0.7)
	elseif veh.LadderMove["left"] then
		veh.Ladder["main"]:setAttachedOffsets(x, y, z, rx, ry, rz-0.7)
	end

	if veh.LadderMove["up"] then
		if rx1 > -50 then
			veh.Ladder["ladder1"]:setAttachedOffsets(x1, y1, z1, rx1-0.5, ry1, rz1)
		end
	elseif veh.LadderMove["down"] then
		if rx1 < 0 then
			veh.Ladder["ladder1"]:setAttachedOffsets(x1, y1, z1, rx1+0.5, ry1, rz1)
		end
	end

	if veh.LadderMove["in"] then
		if y3 < -1.4 then
			veh.Ladder["ladder3"]:setAttachedOffsets(x3, y3+0.1, z3, rx3, ry3, rz3)
		elseif y2 < -1.4 then
			veh.Ladder["ladder2"]:setAttachedOffsets(x2, y2+0.1, z2, rx2, ry2, rz2)
		end
	elseif veh.LadderMove["out"] then
		if y2 > -5.5 then
			veh.Ladder["ladder2"]:setAttachedOffsets(x2, y2-0.05, z2, rx2, ry2, rz2)
		elseif y3 > -4.5 then
			veh.Ladder["ladder3"]:setAttachedOffsets(x3, y3-0.05, z3, rx3, ry3, rz3)
		end
	end

	if veh.controller then 
		triggerClientEvent(veh.controller, "rescueLadderFixCamera", veh, veh.Ladder["main"], veh.Ladder["ladder3"])
	else --fallback, timer gets killed automatically in most cases
		killTimer(sourceTimer)
	end
end
