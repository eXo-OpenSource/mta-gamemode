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
	if lookAtVehicle:isLocked() then
		lookAtVehicle:setLocked(false)
	else
		lookAtVehicle:setLocked(true)
	end
end

function VehicleInteraction:doAction(door)
	local lookAtVehicle = getPedTarget(client)

    if (lookAtVehicle) and (getElementType(lookAtVehicle) == "vehicle" ) then
		local veh = lookAtVehicle
        local doorRatio = getVehicleDoorOpenRatio(lookAtVehicle, door)
        local checkDoor = getVehicleDoorState(lookAtVehicle, door)
		local doorStateS = getElementData(lookAtVehicle, tostring(door))
		if not (doorStateS) then
            setElementData(lookAtVehicle, door, "closed", true)
        end

		local doorState = getElementData(veh, door)

		if doorRatio > 0 or checkDoor == 4 or doorState == "open" then
			if isPrivatveh(veh) then
				if door == 1 then
					if exoGetElementData ( veh, "stuning1" ) then
						openKofferraumServer(client,veh)
						exoSetElementData ( client, "clickedVehicle", veh )
						showCursor ( client, true )
						setElementData ( client, "ElementClicked", true )
					else
						outputChatBox("Das Fahrzeug hat keinen Kofferraum eingebaut!",client,255,0,0)
					end
				elseif door == 0 then
					if exoGetElementData(veh,"owner") == getclientName(client) then
						if getclientItemAnzahl(client,"Reparaturkit") > 0 then
							if exoGetElementData(veh,"totalschaden") == true then
								infobox ( client, "\nMotor wird repariert!\n Bitte warten!!", 4500, 0, 0, 255 )
								setPedAnimation(client,"BAR","Barserve_give",-1,true)
								setTimer(function()
									saveTotalschadenForPrivVeh ( veh,0 )
									takeItem(client,"Reparaturkit",1)
									outputChatBox("Motor wird repariert! Totalschaden repariert!",client,0,255,0)
									setPedAnimation(client)
								end,5000,1)
							else
								infobox ( client, "\nDas Fahrzeug hat keinen Totalschaden!", 7500, 255, 0, 0 )
							end
						else
							infobox ( client, "\nDu hast keinen Reparaturkit!", 7500, 255, 0, 0 )
						end
					else
						infobox ( client, "\nDas ist nicht\n dein Fahrzeug, es gehört "..exoGetElementData(veh,"owner").."!", 7500, 255, 0, 0 )
					end
				end
			end
		else
			if door == 1 then doorname = "Der Kofferraum" else doorname="Die Motorhaube" end
			outputChatBox(doorname.." ist nicht offen!",client,255,0,0)
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
