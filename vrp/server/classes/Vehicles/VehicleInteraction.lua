-- ****************************************************************************
-- *
-- *  PROJECT:    vRoleplay
-- *  FILE:       server/classes/VehicleInteraction.lua
-- *  PURPOSE:    Vehicle Interaction class
-- *
-- ****************************************************************************
VehicleInteraction = inherit(Singleton)

function VehicleInteraction:constructor()

	addRemoteEvents{"onInteractVehicleDoor", "onActionVehicleDoor", "onLockVehicleDoor"}

	addEventHandler("onInteractVehicleDoor", root, bind(self.doInteractions, self))
	addEventHandler("onActionVehicleDoor", root, bind(self.doAction, self))
	addEventHandler("onLockVehicleDoor", root, bind(self.doLock, self))

end

function VehicleInteraction:doInteractions(door)
	local lookAtVehicle = getPedTarget(client)
    if lookAtVehicle and (getElementType(lookAtVehicle) == "vehicle" ) then
        local doorRatio = getVehicleDoorOpenRatio(lookAtVehicle, door)
        local doorStateS = getElementData(lookAtVehicle, tostring(door), true)

        if not (doorStateS) then
            setElementData(lookAtVehicle, door, "closed", true)
        end
        self:interactWith(client, lookAtVehicle, door)
        setPedAnimation(client, "Ped", "CAR_open_LHS", 300, false, false, true, false)
   end
end

function VehicleInteraction:doLock()
	local lookAtVehicle = getPedTarget(client)
	if lookAtVehicle:hasKey(client) or client:getRank() >= RANK.Moderator then
		if lookAtVehicle:isLocked() then
			lookAtVehicle:setLocked(false)
		else
			lookAtVehicle:setLocked(true)
		end
	else
		client:sendError(_("Du hast keinen Schlüssel für das Fahrzeug!", client))
	end
end

function VehicleInteraction:doAction(door)
	local lookAtVehicle = getPedTarget(client)

    if lookAtVehicle and (getElementType(lookAtVehicle) == "vehicle" ) then
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
				if lookAtVehicle:getTrunk() then
					lookAtVehicle:getTrunk():open(client)
				end
			elseif door == 0 then
				if client:getInventory():getItemAmount("Reparaturkit") > 0 then
					if veh.isBroken and veh:isBroken() then
						client:sendInfo(_("Das Fahrzeug wird repariert! Bitte warten!", client))
						client:setAnimation("BAR" ,"Barserve_give" ,0 ,true)
						local player = client
						setTimer(function()
							veh:setBroken(false)
							veh:setHealth(veh:getHealth() + 300)

							player:sendInfo(_("Das Fahrzeug wurde erfolgreich repariert!", player))
							player:setAnimation(false)
							player:getInventory():removeItem("Reparaturkit", 1)
						end, 5000, 1)
					else
						client:sendError(_("Das Fahrzeug hat keinen Totalschaden!", client))
					end
				else
					client:sendError(_("Du hast keinen Reparaturkit dabei!", client))
				end
			end
		else
			if door == 1 then doorname = "Der Kofferraum" else doorname="Die Motorhaube" end
			client:sendError(_("%s ist nicht geöffnet!", client, doorname))
		end

	end
end



function VehicleInteraction:interactWith(source, vehicle, door)
    local doorRatio = getVehicleDoorOpenRatio(vehicle, door)
    local doorState = getElementData(vehicle, door)

    if (doorRatio <= 0) then
        doorState = "closed"
    elseif (doorRatio >= 1) then
        doorState = "open"
    end

    if doorRatio == 0 or doorRatio == 1 then
        if (doorState == "closed") then
            setTimer(function()
                if (doorRatio <= 1) then
                    doorRatio = doorRatio + 0.1
                    if (doorRatio >= 1) then
                        doorRatio = 1
                        setElementData(vehicle, door, "open", true)
                    end
                end
                setElementData(vehicle, door, "closed", true)
                setVehicleDoorOpenRatio(vehicle, door, doorRatio)
            end, 50, 11)

        elseif (doorState == "open") then
            setTimer ( function()

                if (doorRatio > 0) then
                    doorRatio = doorRatio - 0.1

                    if (doorRatio <= 0) then
                        doorRatio = 0
                        setElementData(vehicle, door, "closed", true)
                    end
                end
                setElementData(vehicle, door, "open", true)
                setVehicleDoorOpenRatio(vehicle, door, doorRatio)
            end, 50, 11)
		end
    else
		if doorRatio == 0 or doorRatio == 1 then
			self:interactWith(source, vehicle, door)
		end
	end
end
