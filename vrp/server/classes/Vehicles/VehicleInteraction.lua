-- ****************************************************************************
-- *
-- *  PROJECT:    vRoleplay
-- *  FILE:       server/classes/VehicleInteraction.lua
-- *  PURPOSE:    Vehicle Interaction class
-- *
-- ****************************************************************************
VehicleInteraction = inherit(Singleton)

function VehicleInteraction:constructor()
	addRemoteEvents{"onInteractVehicleDoor", "onActionVehicleDoor", "onLockVehicleDoor", "onMouseMenuRepairkit"}

	addEventHandler("onInteractVehicleDoor", root, bind(self.doInteractions, self))
	addEventHandler("onActionVehicleDoor", root, bind(self.doAction, self))
	addEventHandler("onLockVehicleDoor", root, bind(self.doLock, self))
	addEventHandler("onMouseMenuRepairkit", root, bind(self.Event_repairVehicle, self))
end

function VehicleInteraction:doInteractions(door)
	local lookAtVehicle = getPedTarget(client)

    if lookAtVehicle and getElementType(lookAtVehicle) == "vehicle" then
		if lookAtVehicle:hasKey(client) or client:getRank() >= RANK.Moderator or (not isVehicleLocked(lookAtVehicle) and client:getFaction() and client:getFaction():isStateFaction() and client:isFactionDuty()) then
			local doorRatio = getVehicleDoorOpenRatio(lookAtVehicle, door)
			local doorStateS = getElementData(lookAtVehicle, tostring(door), true)

			if not (doorStateS) then
				setElementData(lookAtVehicle, door, "closed", true)
			end

			self:interactWith(client, lookAtVehicle, door)
			setPedAnimation(client, "Ped", "CAR_open_LHS", 300, false, false, true, false)

			client:triggerEvent("onDoorOpened", getElementPosition(client))
		else
			client:sendError(_("Du hast kein Schlüssel für das Fahrzeug!", client))
		end
   end
end

function VehicleInteraction:doLock(vehicle)
	if not vehicle or getElementType(vehicle) ~= "vehicle" then return end

	if vehicle:hasKey(client) or client:getRank() >= RANK.Moderator then
		if vehicle:isLocked() then
			vehicle:playLockEffect(false)
			vehicle:setLocked(false)
		else
			vehicle:playLockEffect(true)
			vehicle:setLocked(true)
			for i = 0, 5 do
				if getVehicleDoorState(vehicle, i) == 4 then
					setVehicleDoorState(vehicle, i, 2)
				end
			end
		end
	else
		client:sendError(_("Du hast kein Schlüssel für das Fahrzeug!", client))
	end
end

function VehicleInteraction:Event_repairVehicle()
	self:repairVehicle(client, source)
end

function VehicleInteraction:repairVehicle(player, veh)
	if player:getInventoryOld():getItemAmount("Reparaturkit") > 0 then
		if veh.isBroken and veh:isBroken() then
			player:sendInfo(_("Das Fahrzeug wird repariert! Bitte warten!", player))
			player:getInventoryOld():removeItem("Reparaturkit", 1)
			player:setAnimation("BAR" ,"Barserve_give" ,0 ,true)
			setTimer(function(player, veh)
				veh:setBroken(false)
				veh:setHealth(veh:getHealth() + 300)

				if isElement(player) then
					player:sendInfo(_("Das Fahrzeug wurde erfolgreich repariert!", player))
					player:setAnimation(false)
					player:setAnimation("carry", "crry_prtial", 1, false, true, true, false) -- Stop Animation Work Arround
				end
			end, 5000, 1, player, veh)
		else
			player:sendError(_("Das Fahrzeug hat keinen Totalschaden!", player))
		end
	else
		player:sendError(_("Du hast keinen Reparaturkit dabei!", player))
	end
end

function VehicleInteraction:doAction(door)
	local lookAtVehicle = getPedTarget(client)

    if lookAtVehicle and isElement(lookAtVehicle) and getElementType(lookAtVehicle) == "vehicle" then
		local veh = lookAtVehicle
        local doorRatio = getVehicleDoorOpenRatio(lookAtVehicle, door)
        local checkDoor = getVehicleDoorState(lookAtVehicle, door)
		local doorStateS = getElementData(lookAtVehicle, tostring(door))
		if not (doorStateS) then
            setElementData(lookAtVehicle, door, "closed", true)
        end

		local doorState = getElementData(veh, door)

		if doorRatio > 0 or checkDoor == 4 or doorState == "open" then
			if door == 1 then
				if instanceof(veh, GroupVehicle) or instanceof(veh, PermanentVehicle, true) then
					if veh:hasKey(client) or client:getRank() >= RANK.Moderator or (not isVehicleLocked(veh) and client:getFaction() and client:getFaction():isStateFaction() and client:isFactionDuty()) then
						if veh.getTrunk and veh:getTrunk() and veh:getTrunk().open then
							veh:getTrunk():open(client)
						end
					else
						client:sendError(_("Du hast kein Schlüssel für das Fahrzeug!", client))
					end
				end
			elseif door == 0 then
				self:repairVehicle(client, veh)
			end
		else
			if door == 1 then doorname = "Der Kofferraum" else doorname="Die Motorhaube" end
			client:sendError(_("%s ist nicht geöffnet!", client, doorname))
		end

	end
end

function VehicleInteraction:interactWith(source, vehicle, door)
    local doorRatio = getVehicleDoorOpenRatio(vehicle, door)

    if doorRatio == 0 or doorRatio == 1 then
        setVehicleDoorOpenRatio(vehicle, door, 1 - doorRatio, 500)
	end
end
