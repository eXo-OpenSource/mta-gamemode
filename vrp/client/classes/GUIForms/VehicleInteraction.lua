-- ****************************************************************************
-- *
-- *  PROJECT:    vRoleplay
-- *  FILE:       client/classes/VehicleInteraction.lua
-- *  PURPOSE:    Vehicle Interaction class
-- *
-- ****************************************************************************
VehicleInteraction = inherit(Singleton)
inherit(GUIFontContainer, VehicleInteraction)

addRemoteEvents{"onDoorOpened", "onDoorClosed"}

function VehicleInteraction:constructor()
	self.sWidth, self.sHeight = guiGetScreenSize()
	self.m_minDistance = 10
	self.m_minDistance2 = 8
	self.m_interactButton = "O"
	self.m_actionButton = "K"
	self.m_lockButton = "L"
	self.m_isDebug = false
	self.m_lookAtVehicle = nil
	self.m_doorName = ""

	self.m_doorNames = {
		[0] = _"der #00FF00Motorhaube",
		[1] = _"des #00FF00Kofferraumes",
		[2] = _"der #00FF00linken Vordertür",
		[3] = _"der #00FF00rechten Vordertür",
		[4] = _"der #00FF00linken hinteren Tür",
		[5] = _"der #00FF00rechten hinteren Tür"
	}

	bindKey(self.m_interactButton, "down", bind(self.interact, self))
	bindKey(self.m_actionButton, "down", bind(self.action, self))
	bindKey(self.m_lockButton, "down", bind(self.lock, self))

	addEventHandler("onDoorOpened", root, bind(self.onDoorOpened, self))
	addEventHandler("onDoorClosed", root, bind(self.onDoorClosed, self))
	addEventHandler("onClientRender", root, bind(self.render, self))

	-- Font
	GUIFontContainer.constructor(self, "", 1, VRPFont(16))
end

function VehicleInteraction:render()
    if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/VehicleInteraction") end
	local playerPos = localPlayer:getPosition()
	self.m_lookAtVehicle = getPedTarget(localPlayer)
    if self.m_lookAtVehicle and getElementType(self.m_lookAtVehicle) == "vehicle" and not getControlState("aim_weapon") then
		if not isPedInVehicle(localPlayer) and not GUIElement.getHoveredElement() then
			local vehPos = self.m_lookAtVehicle:getPosition()
			local vehRot = self.m_lookAtVehicle:getRotation()
			if getDistanceBetweenPoints3D(vehPos, playerPos) < self.m_minDistance and self:getDoor() then
				if not isVehicleLocked(self.m_lookAtVehicle) then
					local checkDoor = getVehicleDoorState(self.m_lookAtVehicle, self:getDoor())
					local door = self:getDoor()
					local doorName = self.m_doorNames[door]
					local doorRatio = getVehicleDoorOpenRatio(self.m_lookAtVehicle, self:getDoor())

					if doorRatio <= 0 and checkDoor ~= 4 then
							self:drawTextBox(_("#FFFFFFDrücke #00FF00 %s #FFFFFF zum Öffnen %s#FFFFFF!", self.m_interactButton, doorName), 0)
						if self:isOwner(self.m_lookAtVehicle) then
							self:drawTextBox(_("#FFFFFFDrücke #FF0000 %s #FFFFFF um das Fahrzeug abzuschließen!", self.m_lockButton), 1)
						end
					end
					if doorRatio > 0 or checkDoor == 4 then
						if checkDoor ~= 4 then
							self:drawTextBox(_("#FFFFFFDrücke #00FF00 %s #FFFFFF zum Schließen %s#FFFFFF!", self.m_interactButton, doorName), 0)
						end
						if door == 1 then
							if getElementData(self.m_lookAtVehicle, "OwnerType") == "group" or getElementData(self.m_lookAtVehicle, "OwnerType") == "player" then
								self:drawTextBox(_("#FFFFFFDrücke #FF0000 %s #FFFFFF um den Kofferraum zu durchsuchen!", self.m_actionButton), 1)
							end
						elseif door == 0 then
							self:drawTextBox(_("#FFFFFFDrücke #FF0000 %s #FFFFFF um den Motor zu reparieren!", self.m_actionButton), 1)
						elseif self.m_lookAtVehicle:getModel() == 416 then
							if door == 4 or door == 5 then
								if localPlayer:getPublicSync("Faction:Duty") and localPlayer:getPublicSync("Rescue:Type") == "medic" then
									self:drawTextBox(_("#FFFFFFDrücke #00FF00 %s #FFFFFF zum ein- oder ausladen der Trage!", self.m_actionButton), 1)
								end
							end
						end
					end
				else
					self:drawTextBox(_("#FF0000 Fahrzeug ist verschlossen!", self.m_lockButton), 0)
					if self:isOwner(self.m_lookAtVehicle) then
						self:drawTextBox(_("#FFFFFFDrücke #FF0000 %s #FFFFFF um das Fahrzeug aufzuschließen!", self.m_lockButton), 1)
					end
				end
	        end
		end
    end
    if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/VehicleInteraction", 1, 1) end
end

function VehicleInteraction:drawTextBox(text, count)
	local width, height = 270, 16
	local x, y = screenWidth/2 - width/2, screenHeight/2 + count*20
	dxDrawRectangle(x, y, width, height, tocolor( 0, 0, 0, 90 ))
	dxDrawText(text, x, y, x+width, y+height, tocolor(255, 255, 255, 255), 1, self.m_Font, "center", "center", false, false, false, true, false)

end

function VehicleInteraction:getPlayerToVehicleRelatedPosition()
    if self.m_lookAtVehicle and getElementType(self.m_lookAtVehicle) == "vehicle" then
        local vx, vy, vz = getElementPosition(self.m_lookAtVehicle)
        local rxv, ryv, rzv = getElementRotation(self.m_lookAtVehicle)
        local px, py, pz = getElementPosition(localPlayer)
        local anglePlayerToVehicle = math.atan2(px - vx, py - vy)
        local formattedAnglePlayerToVehicle = math.deg(anglePlayerToVehicle) + 180
        local vehicleRelatedPosition = formattedAnglePlayerToVehicle + rzv

        if (vehicleRelatedPosition < 0) then
            vehicleRelatedPosition = vehicleRelatedPosition + 360
        elseif (vehicleRelatedPosition > 360) then
            vehicleRelatedPosition = vehicleRelatedPosition - 360
        end

        return math.floor(vehicleRelatedPosition) + 0.5
    else
        return "false"
    end
end


function VehicleInteraction:getDoor()
    local veh = self:getInteractableVehicleType(self.m_lookAtVehicle)
	local pos = self:getPlayerToVehicleRelatedPosition()
    if (veh) == "2 doors" then
        -- 0 (hood), 1 (trunk), 2 (front left), 3 (front right)
        if (pos >= 140) and (pos <= 220) then
            return 0
        end

        if (pos >= 330) and (pos <= 360)  or (pos >= 0) and (pos <= 30) then
            return 1
        end

        if (pos >= 65) and (pos <= 120) then
            return 2
        end

        if (pos >= 240) and (pos <= 295) then
            return 3
        end
    elseif (veh) == "2 doors, no trunk" then
        -- 0 (hood), 2 (front left), 3 (front right)
        if (pos >= 140) and (pos <= 220) then
            return 0
        end

        if (pos >= 65) and (pos <= 120) then
            return 2
        end

        if (pos >= 240) and (pos <= 295) then
            return 3
        end
    elseif (veh) == "4 doors" then
        -- 0 (hood), 1 (trunk), 2 (front left), 3 (front right), 4 (rear left), 5 (rear right)
        if (pos >= 140) and (pos <= 220) then
            return 0
        end

        if (pos >= 330) and (pos <= 360)  or (pos >= 0) and (pos <= 30) then
            return 1
        end

        if (pos >= 91) and (pos <= 120) then
            return 2
        end

        if (pos >= 240) and (pos <= 270) then
            return 3
        end

        if (pos >= 60) and (pos <= 90) then
            return 4
        end

        if (pos >= 271) and (pos <= 300) then
            return 5
        end
    elseif (veh) == "Van" then
        -- 0 (hood), 2 (front left), 3 (front right), 4 (rear left at back), 5 (rear right at back)
        if (pos >= 140) and (pos <= 220) then
            return 0
        end

        if (pos >= 91) and (pos <= 130) then
            return 2
        end

        if (pos >= 230) and (pos <= 270) then
            return 3
        end

        if (pos >= 0) and (pos <= 30) then
            return 4
        end

        if (pos >= 330) and (pos <= 360) then
            return 5
        end
    elseif (veh) == "Truck" then
        -- 0 (hood), 2 (front left), 3 (front right)
        if (pos >= 160) and (pos <= 200) then
            return 0
        end

        if (pos >= 120) and (pos <= 155) then
            return 2
        end

        if (pos >= 205) and (pos <= 230) then
            return 3
        end
    elseif (veh) == "Special" then
        -- 2 (front left), 3 (front right)
        if (pos >= 120) and (pos <= 155) then
            return 2
        end

        if (pos >= 205) and (pos <= 230) then
            return 3
        end
    elseif (veh) == "Stretch" then
        -- 0 (hood), 1 (trunk), 2 (front left), 3 (front right), 4 (rear left), 5 (rear right)
        if (pos >= 140) and (pos <= 220) then
            return 0
        end

        if (pos >= 330) and (pos <= 360)  or (pos >= 0) and (pos <= 30) then
            return 1
        end

        if (pos >= 91) and (pos <= 120) then
            return 2
        end

        if (pos >= 240) and (pos <= 270) then
            return 3
        end

        if (pos >= 60) and (pos <= 90) then
            return 4
        end

        if (pos >= 271) and (pos <= 300) then
            return 5
        end
    end

    return nil
end

function VehicleInteraction:getInteractableVehicleType()
	return getVehicleInteractType(self.m_lookAtVehicle)
end


function VehicleInteraction:interact()
    if (self.m_lookAtVehicle) and (getElementType(self.m_lookAtVehicle) == "vehicle") and (self:getDoor()) then
        local checkDoor = getVehicleDoorState(self.m_lookAtVehicle, self:getDoor())
        if (checkDoor ~= 4 ) then
            if not (isVehicleLocked(self.m_lookAtVehicle)) then
                if not isPedInVehicle(localPlayer) then
					triggerServerEvent("onInteractVehicleDoor", localPlayer, tonumber(self:getDoor()))
				end
            end
        end
    end
end

function VehicleInteraction:action()
	if (self.m_lookAtVehicle) and (getElementType(self.m_lookAtVehicle) == "vehicle") and (self:getDoor()) then
		local checkDoor = getVehicleDoorState(self.m_lookAtVehicle, self:getDoor())
		local door = tonumber(self:getDoor())
		if door == 0 or door == 1 then
			local doorRatio = getVehicleDoorOpenRatio(self.m_lookAtVehicle, door)
			if doorRatio > 0 or checkDoor == 4 then
				if not(isVehicleLocked(self.m_lookAtVehicle)) then
					if not isPedInVehicle(localPlayer) then
						triggerServerEvent("onActionVehicleDoor", localPlayer, door)
					end
				end
			end
		elseif (door == 4 or door == 5) and self.m_lookAtVehicle:getModel() == 416 then
			if localPlayer:getPublicSync("Faction:Duty") and localPlayer:getPublicSync("Rescue:Type") == "medic" then
				triggerServerEvent("factionRescueToggleStretcher", localPlayer, self.m_lookAtVehicle)
			end
		end
    end
end

function VehicleInteraction:lock()
	if (self.m_lookAtVehicle) and (getElementType(self.m_lookAtVehicle) == "vehicle") and (self:getDoor()) then
		if self:isOwner(self.m_lookAtVehicle) then
			if not isPedInVehicle(localPlayer) then
				triggerServerEvent("onLockVehicleDoor", localPlayer, door)
			end
		end
	end
end

function VehicleInteraction:onDoorOpened(x, y, z)
	local sound = playSound3D("files/audio/onDoorOpened.mp3", x, y, z, false)
    setSoundMaxDistance(sound, 5)
end

function VehicleInteraction:onDoorClosed(x, y, z)
    local sound = playSound3D("files/audio/onDoorClosed.mp3", x, y, z, false)
    setSoundMaxDistance(sound, 5)
end

function VehicleInteraction:isOwner(veh)
	local ownerName = veh:getData("OwnerName")
	if ownerName == localPlayer:getName() then
		return true
	elseif ownerName == localPlayer:getGroupName() then
		return true
	elseif localPlayer:getCompany() and ownerName == localPlayer:getCompany():getName() then
		return true
	elseif localPlayer:getFaction() and ownerName == localPlayer:getFaction():getName() then
		return
	end
	return false
end
