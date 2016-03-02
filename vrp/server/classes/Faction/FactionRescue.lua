-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionRescue.lua
-- *  PURPOSE:     Faction Rescue Class
-- *
-- ****************************************************************************
FactionRescue = inherit(Singleton)
addRemoteEvents{"factionRescueToggleDuty", "factionRescueHealPlayerQuestion", "factionRescueDiscardHealPlayer", "factionRescueHealPlayer", "factionRescueGetStretcher", "factionRescueRemoveStretcher", "factionRescueWastedFinished"}

function FactionRescue:constructor()
	-- Duty Pickup
	self:createDutyPickup(1720.80, -1772.05, 13.88,0)

	-- Barriers
	VehicleBarrier:new(Vector3(1743.09, -1742.30, 13.30), Vector3(0, 90, -180)).onBarrierHit = bind(self.onBarrierHit, self)
	VehicleBarrier:new(Vector3(1740.59, -1807.80, 13.39), Vector3(0, 90, -15.75)).onBarrierHit = bind(self.onBarrierHit, self)

	-- Register in Player Hook
	PlayerManager:getSingleton():getWastedHook():register(bind(self.Event_OnPlayerWasted, self))

	-- Events
	addEventHandler("factionRescueToggleDuty", root, bind(self.Event_toggleDuty, self))
	addEventHandler("factionRescueHealPlayerQuestion", root, bind(self.Event_healPlayerQuestion, self))
	addEventHandler("factionRescueDiscardHealPlayer", root, bind(self.Event_discardHealPlayer, self))
	addEventHandler("factionRescueHealPlayer", root, bind(self.Event_healPlayer, self))
	addEventHandler("factionRescueGetStretcher", root, bind(self.Event_GetStretcher, self))
	addEventHandler("factionRescueRemoveStretcher", root, bind(self.Event_RemoveStretcher, self))
	addEventHandler("factionRescueWastedFinished", root, bind(self.Event_OnPlayerWastedFinish, self))


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
function FactionRescue:Event_GetStretcher()
	local faction = FactionManager:getSingleton():getFromId(4)
	if client:getFaction() == faction then
		-- Check for the correct Vehicle
		if client.m_RescueStretcher then
			if client.m_RescueStretcher.m_Vehicle ~= source then
				client:sendError(_("Deine Trage befindet sich in einem anderen Fahrzeug!", client))
				return
			end
		end

		local distance = math.abs(((source:getPosition() + source.matrix.forward*-4.5) - client:getPosition()).length)
		outputDebug(distance)
		if distance >= 2.5 and distance <= 4 then
			-- Open the doors
			source:setDoorState(4, 0)
			source:setDoorState(5, 0)
			source:setDoorOpenRatio(4, 1)
			source:setDoorOpenRatio(5, 1)

			-- Create the Stretcher
			if not client.m_RescueStretcher then
				client.m_RescueStretcher = createObject(2146, source:getPosition() + source.matrix.forward*-3, source:getRotation())
				client.m_RescueStretcher:setCollisionsEnabled(false)
				client.m_RescueStretcher.m_Vehicle = source
			end

			-- Move the Stretcher to the Player
			moveObject(client.m_RescueStretcher, 3000, client:getPosition() + client.matrix.forward*1.4 + Vector3(0, 0, -0.5), Vector3(0, 0, client:getRotation().z - source:getRotation().z), "InOutQuad")
			client:setFrozen(true)

			setTimer(
				function (client)
					client.m_RescueStretcher:attach(client, Vector3(0, 1.4, -0.5))
					client:toggleControlsWhileObjectAttached(false)
					client:setFrozen(false)
				end, 3000, 1, client
			)
		else
			client:sendWarning(_("Die Trage kann in dieser Position nicht ausgeladen werden!", client))
			local tempMarker = createMarker(source:getPosition() + source.matrix.forward*-7.5, "corona", 1)
			setTimer(
				function ()
					tempMarker:destroy()
				end, 5000, 1
			)
		end
	end
end

function FactionRescue:Event_RemoveStretcher()
	local faction = FactionManager:getSingleton():getFromId(4)
	if client:getFaction() == faction then
		if client.m_RescueStretcher  then
			if client.m_RescueStretcher.m_Vehicle == source then
				local distance = math.abs(((source:getPosition() + source.matrix.forward*-4.5) - client:getPosition()).length)
				if distance >= 2.5 and distance <= 4 then
					-- Move it into the Vehicle
					client.m_RescueStretcher:detach()
					client.m_RescueStretcher:setRotation(client:getRotation())
					client.m_RescueStretcher:setPosition(client:getPosition() + client.matrix.forward*1.4 + Vector3(0, 0, -0.5))
					moveObject(client.m_RescueStretcher, 3000, source:getPosition() + source.matrix.forward*-2, Vector3(0, 0, source:getRotation().z - client:getRotation().z), "InOutQuad")

					-- Enable Controls
					client:toggleControlsWhileObjectAttached(true)

					setTimer(
						function(source, client)
							-- Close the doors
							source:setDoorOpenRatio(4, 0)
							source:setDoorOpenRatio(5, 0)

							client.m_RescueStretcher:destroy()
							client.m_RescueStretcher = nil
						end, 3000, 1, source, client
					)
				else
					client:sendWarning(_("Die Trage kann in dieser Position nicht ausgeladen werden!", client))
					local tempMarker = createMarker(source:getPosition() + source.matrix.forward*-7.5, "corona", 1)
					setTimer(
						function ()
							tempMarker:destroy()
						end, 5000, 1
					)
				end
			else
				client:sendError(_("In dieses Fahrzeug kannst du die Trage nicht einladen!", client))
			end
		else
			client:sendError(_("Du hast keine Trage!", client))
		end
	end
end

--[[ Very buggy, i don't know why? TODO!
function FactionRescue:Event_RemoveStretcher()
	local faction = FactionManager:getSingleton():getFromId(4)
	if client:getFaction() == faction then
		if client.m_RescueStretcher and client.m_RescueStretcher.m_Vehicle == source then
			local distance = math.abs(((source:getPosition() + source.matrix.forward*-4.5) - client:getPosition()).length)
			if distance >= 2.5 and distance <= 4 then
				-- Move it into the Vehicle
				client.m_RescueStretcher:setPosition(client:getPosition() + Vector3(0, 1.4, -0.5))
				client.m_RescueStretcher:setRotation(client:getRotation())
				client.m_RescueStretcher:detach()
				moveObject(client.m_RescueStretcher, 3000, source:getPosition() + source.matrix.forward*-2, 0, 0, 0, "InOutQuad")

				-- Enable Controls
				client:toggleControlsWhileObjectAttached(true)

				setTimer(
					function(source, client)
						-- Close the doors
						source:setDoorOpenRatio(4, 0)
						source:setDoorOpenRatio(5, 0)

						-- Attach to the Vehicle
						client.m_RescueStretcher:setPosition(source:getPosition() + source.matrix.forward*-2)
						client.m_RescueStretcher:setRotation(source:getRotation())
						outputDebug(client.m_RescueStretcher:attach(source, source:getPosition() + source.matrix.forward*-2))
					end, 3000, 1, source, client
				)
			else
				client:sendWarning(_("Die Trage kann in dieser Position nicht ausgeladen werden!", client))
				local tempMarker = createMarker(source:getPosition() + source.matrix.forward*-7.5, "corona", 1)
				setTimer(
					function ()
						tempMarker:destroy()
					end, 5000, 1
				)
			end
		else
			client:sendError(_("In dieses Fahrzeug kannst du die Trage nicht einladen!", client))
		end
	end
end
--]]

function FactionRescue:createDeathPickup(player, ...)
	player.m_DeathPickup = Pickup(player:getPosition(), 3, 1254, 0)
	--player:setPosition(player.m_DeathPickup:getPosition())
	--player:kill()

	addEventHandler("onPickupHit", player.m_DeathPickup,
		function (hitPlayer)
			if hitPlayer:getFaction() and hitPlayer:getFaction():isRescueFaction() then
				if hitPlayer:getPublicSync("Faction:Duty") and hitPlayer:getPublicSync("Rescue:Type") == "medic" then
					hitPlayer:sendShortMessage(("He's dead son.\nIn Memories of %s"):format(player:getName()))
				end
			end
		end
	)

	-- Create PlayerDeathTimeout
	self:createDeathTimeout(player, ...)
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

function FactionRescue:Event_OnPlayerWasted(player)
	-- if we return true here, we have to handle the spawn in this function
	-- if we retrun false here, we don't have to do this

	local faction = FactionManager:getSingleton():getFromId(4)
	if #faction:getOnlinePlayers() > 0 then
		if not player.m_DeathPickup then
			faction:sendShortMessage(("%s died.\nPosition: %s - %s"):format(player:getName(), getZoneName(player:getPosition()), getZoneName(player:getPosition(), true)))
			self:createDeathPickup(player, function () player:triggerEvent("playerRescueWasted") end)
			return true
		else -- This should never never happen!
			outputDebug("Internal Error! Player died while he is Dead. Dafuq?")
		end
	end

	return false
end

function FactionRescue:Event_OnPlayerWastedFinish()
	source:setCameraTarget(player)
	source:respawn()
	source:fadeCamera(true, 1)
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
