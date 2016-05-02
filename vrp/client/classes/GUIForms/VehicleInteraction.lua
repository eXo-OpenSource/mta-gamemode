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
	self.m_minDistance = 10
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
	self.m_lookAtVehicle = getPedTarget(localPlayer)
    if self.m_lookAtVehicle and getElementType(self.m_lookAtVehicle) == "vehicle" then
		if not isPedInVehicle(localPlayer) and not GUIElement.getHoveredElement() then
			local vehPos = self.m_lookAtVehicle:getPosition()
			local vehRot = self.m_lookAtVehicle:getRotation()
			local playerPos = localPlayer:getPosition()
			if getDistanceBetweenPoints3D(vehPos, playerPos) < self.m_minDistance and self:getDoor() then
				if not isVehicleLocked(self.m_lookAtVehicle) then
					local checkDoor = getVehicleDoorState(self.m_lookAtVehicle, self:getDoor())

					local door = self:getDoor()
					local doorName = self.m_doorNames[door]

					local doorRatio = getVehicleDoorOpenRatio(self.m_lookAtVehicle, self:getDoor())

					if doorRatio <= 0 and checkDoor ~= 4 then
							self:drawTextBox(_("#FFFFFFDrücke #00FF00 %s #FFFFFF zum Öffnen %s#FFFFFF!", self.m_interactButton, doorName), 0)
						if getElementData(self.m_lookAtVehicle,"OwnerName") == getPlayerName(localPlayer) then
							self:drawTextBox(_("#FFFFFFDrücke #FF0000 %s #FFFFFF um das Fahrzeug abzuschließen!", self.m_lockButton), 1)
						end
					end
					if doorRatio > 0 or checkDoor == 4 then
						if checkDoor ~= 4 then
							self:drawTextBox(_("#FFFFFFDrücke #00FF00 %s #FFFFFF zum Schließen %s#FFFFFF!", self.m_interactButton, doorName), 0)
						end
						if door == 1 then
							self:drawTextBox(_("#FFFFFFDrücke #FF0000 %s #FFFFFF um den Kofferraum zu durchsuchen!", self.m_actionButton), 1)
						elseif door == 0 then
							self:drawTextBox(_("#FFFFFFDrücke #FF0000 %s #FFFFFF um den Motor zu reparieren!", self.m_actionButton), 1)
						end
					end
				else
					self:drawTextBox(_("#FF0000 Fahrzeug ist verschlossen!", self.m_lockButton), 0)
					if getElementData(self.m_lookAtVehicle,"OwnerName") == getPlayerName(localPlayer) then
						self:drawTextBox(_("#FFFFFFDrücke #FF0000 %s #FFFFFF um das Fahrzeug aufzuschließen!", self.m_lockButton), 1)
					end
				end
	        end
		end
    end
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

	local types = {
		["2 doors"] = twoDoors,
		["2 doors, no trunk"] = twoDoorsNoTrunk,
		["4 doors"] = fourDoors,
		["Van"] = vans,
		["Truck"] = trucks,
		["Special"] = special,
		["stretch"] = stretch
	}

    for name, type in pairs(types) do
		for index, model in pairs(type) do
			if vehicle:getModel() == model then
				return name
			end
		end
	end
    return "not useable"
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
		if getElementData(self.m_lookAtVehicle,"OwnerName") == getPlayerName(localPlayer) then
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
