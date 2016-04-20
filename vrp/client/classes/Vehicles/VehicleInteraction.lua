-- ****************************************************************************
-- *
-- *  PROJECT:    vRoleplay
-- *  FILE:       client/classes/VehicleInteraction.lua
-- *  PURPOSE:    Vehicle Interaction class
-- *
-- ****************************************************************************
VehicleInteraction = inherit(Singleton)

function VehicleInteraction:constructor()
	self.m_minDistance = 10
	self.m_interactButton = "O"
	self.m_actionButton = "K"
	self.m_lockButton = "L"

	self.m_isDebug = false
	self.m_lookAtVehicle = nil
	self.m_doorName = ""

	bindKey(self.m_interactButton, "down", bind(self.interact, self))
	bindKey(self.m_actionButton, "down", bind(self.action, self))
	bindKey(self.m_lockButton, "down", bind(self.lock, self))

	addRemoteEvents{"onDoorOpened", "onDoorClosed"}

	addEventHandler("onDoorOpened", root, bind(self.onDoorOpened, self))
	addEventHandler("onDoorClosed", root, bind(self.onDoorClosed, self))

	addEventHandler("onClientRender", root, bind(self.render, self))

end

function VehicleInteraction:render()
	self.m_lookAtVehicle = getPedTarget(localPlayer)
    if self.m_lookAtVehicle and getElementType(self.m_lookAtVehicle) == "vehicle" then
		if not isPedInVehicle(localPlayer) then
			local vehPos = self.m_lookAtVehicle:getPosition()
			local vehRot = self.m_lookAtVehicle:getRotation()
			local playerPos = localPlayer:getPosition()
			if getDistanceBetweenPoints3D(vehPos, playerPos) < self.m_minDistance and self:getDoor() then
				if (not isVehicleLocked(self.m_lookAtVehicle)) then
					local checkDoor = getVehicleDoorState(self.m_lookAtVehicle, self:getDoor())

					-- 0 (hood), 1 (trunk), 2 (front left), 3 (front right), 4 (rear left), 5 (rear right)
					local door = self:getDoor()

					if (door == 0) then
						doorName = "der #00FF00Motorhaube"
					elseif (door == 1) then
						doorName = "des #00FF00Kofferraumes"
					elseif (door == 2) then
						doorName = "der #00FF00linken Vordertür"
					elseif (door == 3) then
						doorName = "der #00FF00rechten Vordertür"
					elseif (door == 4) then
						doorName = "der #00FF00linken hinteren Tür"
					elseif (door == 5) then
						doorName = "der #00FF00rechten hinteren Tür"
					end


						local doorRatio = getVehicleDoorOpenRatio(self.m_lookAtVehicle, self:getDoor())

						if (doorRatio <= 0 and checkDoor ~= 4) then
								dxDrawRectangle ( screenWidth/2 - 125, screenHeight/2 - 8, 250, 16, tocolor( 0, 0, 0, 90 ))
								dxDrawText("#FFFFFFDrücke #00FF00" .. self.m_interactButton .. "#FFFFFF zum Öffnen " .. doorName .. "#FFFFFF!", screenWidth/2, screenHeight/2, screenWidth/2, screenHeight/2, tocolor(255, 255, 255, 255), 1, "arial", "center", "center", false, false, false, true, true)
							if getElementData(self.m_lookAtVehicle,"owner") == getPlayerName(getLocalPlayer()) then
								dxDrawRectangle ( screenWidth/2 - 135, screenHeight/2 +12, 270, 16, tocolor( 0, 0, 0, 90 ))
								dxDrawText("#FFFFFFDrücke #FF0000 "..self.m_lockButton.." #FFFFFF um das Fahrzeug abzuschließen!", screenWidth/2, screenHeight/2+38, screenWidth/2, screenHeight/2, tocolor(255, 255, 255, 255), 1, "arial", "center", "center", false, false, false, true, true)
							end
						end
						if (doorRatio > 0 or checkDoor == 4) then
							if (checkDoor ~= 4 ) then
								dxDrawRectangle ( screenWidth/2 - 125, screenHeight/2 - 8, 250, 16, tocolor( 0, 0, 0, 90 ))
								dxDrawText("#FFFFFFDrücke #00FF00" .. self.m_interactButton .. "#FFFFFF zum Schließen " .. doorName .. "#FFFFFF!", screenWidth/2, screenHeight/2, screenWidth/2, screenHeight/2, tocolor(255, 255, 255, 255), 1, "arial", "center", "center", false, false, false, true, true)
							end
							if door == 1 then
								dxDrawRectangle ( screenWidth/2 - 135, screenHeight/2 +12, 270, 16, tocolor( 0, 0, 0, 90 ))
								dxDrawText("#FFFFFFDrücke #FF0000" .. self.m_actionButton .. "#FFFFFF um den Kofferraum zu durchsuchen!", screenWidth/2, screenHeight/2+38, screenWidth/2, screenHeight/2, tocolor(255, 255, 255, 255), 1, "arial", "center", "center", false, false, false, true, true)
							elseif door == 0 then
								dxDrawRectangle ( screenWidth/2 - 135, screenHeight/2 +12, 270, 16, tocolor( 0, 0, 0, 90 ))
								dxDrawText("#FFFFFFDrücke #FF0000" .. self.m_actionButton .. "#FFFFFF um den Motor zu reparieren!", screenWidth/2, screenHeight/2+38, screenWidth/2, screenHeight/2, tocolor(255, 255, 255, 255), 1, "arial", "center", "center", false, false, false, true, true)
							end
						end
				else
					dxDrawRectangle ( screenWidth/2 - 100, screenHeight/2 - 8, 200, 16, tocolor( 0, 0, 0, 90 ))
					dxDrawText("#FF0000 Fahrzeug ist verschlossen!", screenWidth/2, screenHeight/2, screenWidth/2, screenHeight/2, tocolor(255, 255, 255, 255), 1, "arial", "center", "center", false, false, false, true, true)
					if getElementData(self.m_lookAtVehicle,"owner") == getPlayerName(getLocalPlayer()) then
						dxDrawRectangle ( screenWidth/2 - 135, screenHeight/2 +12, 270, 16, tocolor( 0, 0, 0, 90 ))
						dxDrawText("#FFFFFFDrücke #FF0000 "..self.m_lockButton.." #FFFFFF um das Fahrzeug aufzuschließen!", screenWidth/2, screenHeight/2+38, screenWidth/2, screenHeight/2, tocolor(255, 255, 255, 255), 1, "arial", "center", "center", false, false, false, true, true)
					end
				end
	        end
		end
    end
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


function VehicleInteraction:isInteractableVehicle()
    local vehicle = self.m_lookAtVehicle
    local interactableVehicles = {  602, 429, 402, 541, 415, 480, 562, 587, 565, 559, 603, 506, 558, 555, 536, 575,
                                    518, 419, 534, 576, 412, 496, 401, 527, 542, 533, 526, 474, 545, 517, 410, 436,
                                    475, 439, 549, 491, 599, 552, 499, 422, 414, 600, 543, 478, 456, 554, 589, 500,
                                    489, 442, 495, 560, 567, 445, 438, 507, 585, 466, 492, 546, 551, 516, 467, 426,
                                    547, 405, 580, 550, 566, 420, 540, 421, 529, 490, 596, 598, 597, 418, 579, 400,
                                    470, 404, 479, 458, 561, 411, 451, 477, 535, 528, 525, 508, 494, 502, 503, 423,
                                    416, 427, 609, 498, 428, 459, 482, 582, 413, 440, 433, 524, 455, 403, 443, 515,
                                    514, 408, 407, 544, 601, 573, 574, 483, 588, 434, 444, 583, 409}

    local model = getElementModel(vehicle)
	for i, v in pairs(interactableVehicles) do
        if (v == model) then
            return true
        end
    end
end


function VehicleInteraction:getInteractableVehicleType()
    local vehicle = self.m_lookAtVehicle

    -- front doors, hood, trunk
    local twoDoors = {  602, 429, 402, 541, 415, 480, 562, 587, 565, 559, 603, 506, 558, 555, 536, 575,
                        518, 419, 534, 576, 412, 496, 401, 527, 542, 533, 526, 474, 545, 517, 410, 436,
                        475, 439, 549, 491, 599, 552, 499, 422, 414, 600, 543, 478, 456, 554, 589, 500,
                        489, 442, 495, }

    -- front doors, rear doors, hood, trunk
    local fourDoors = { 560, 567, 445, 438, 507, 585, 466, 492, 546, 551, 516, 467, 426, 547, 405, 580,
                        550, 566, 420, 540, 421, 529, 490, 596, 598, 597, 418, 579, 400, 470, 404, 479,
                        458, 561}

    -- front doors, hood  (small cars)
    local twoDoorsNoTrunk = {411, 451, 477, 535, 528, 525, 508, 494, 502, 503, 423}

    -- front doors, hood, rear doors at backside
    local vans = {416, 427, 609, 498, 428, 459, 482, 582, 413, 440}

    -- front doors, hood (big cars)
    local trucks = {433, 524, 455, 403, 443, 515, 514, 408}

    -- front doors
    -- 407 and 544 firetrucks, 601 swat tank , 574 sweeper, 483 camper, 588 hotdog, 434 hotrod, 444 monstertruck, 583 tug
    local special = {407, 544, 601, 573, 574, 483, 588, 434, 444, 583}

    -- stretch
    local stretch = {409}

    if (self:isInteractableVehicle()) == true then
        for i, v in pairs(twoDoors) do
            if (v == getElementModel(vehicle)) then
                return "2 doors"
            end
        end

        for i, v in pairs(twoDoorsNoTrunk) do
            if (v == getElementModel(vehicle)) then
                return "2 doors, no trunk"
            end
        end

        for i, v in pairs(fourDoors) do
            if (v == getElementModel(vehicle)) then
                return "4 doors"
            end
        end

        for i, v in pairs(vans) do
            if (v == getElementModel(vehicle)) then
                return "Van"
            end
        end

        for i, v in pairs(trucks) do
            if (v == getElementModel(vehicle)) then
                return "Truck"
            end
        end

        for i, v in pairs(special) do
            if (v == getElementModel(vehicle)) then
                return "Special"
            end
        end

        for i, v in pairs(stretch) do
            if (v == getElementModel(vehicle)) then
                return "Stretch"
            end
        end
    else
        return "not useable"
    end
end


function VehicleInteraction:interact()
    if (self.m_lookAtVehicle) and (getElementType(self.m_lookAtVehicle) == "vehicle") and (self:getDoor()) then
        local checkDoor = getVehicleDoorState(self.m_lookAtVehicle, self:getDoor())
        if (checkDoor ~= 4 ) then
            if not(isVehicleLocked(self.m_lookAtVehicle)) then
                if not isPedInVehicle(localPlayer) then
					triggerServerEvent("onInteractVehicleDoor", localPlayer, tonumber(self:getDoor()))
					local x, y, z = getElementPosition(localPlayer)
					triggerEvent("onDoorOpened", root, x, y, z)
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
		end
    end
end

function VehicleInteraction:lock()
	if (self.m_lookAtVehicle) and (getElementType(self.m_lookAtVehicle) == "vehicle") and (self:getDoor()) then
		if getElementData(self.m_lookAtVehicle,"owner") == getPlayerName(getLocalPlayer()) then
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
