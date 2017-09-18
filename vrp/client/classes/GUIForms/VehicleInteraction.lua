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
	self.m_minDistanceToVeh = 10
	self.m_minDistanceToComp = 2
	self.m_interactButton = "O"
	self.m_actionButton = "K"
	self.m_lockButton = "L"
	self.m_isDebug = false
	self.m_lookAtVehicle = nil
    self.m_LastInteraction = 0
    self.m_InteractionTimeout = 600 -- make this longer than door open ratio time so it doesn't get affected by lagg

	self.m_doorNames = {
		[0] = _"der #00FF00Motorhaube",
		[1] = _"des #00FF00Kofferraumes",
		[2] = _"der #00FF00linken Vordertür",
		[3] = _"der #00FF00rechten Vordertür",
		[4] = _"der #00FF00linken hinteren Tür",
		[5] = _"der #00FF00rechten hinteren Tür"
	}
    self.m_ValidDoors = {
        bonnet_dummy    = 0,
        boot_dummy      = 1, 
        door_lf_dummy   = 2, 
        door_rf_dummy   = 3,
        door_lr_dummy   = 4, 
        door_rr_dummy   = 5,
    }

	bindKey(self.m_interactButton, "down", bind(self.interact, self))
	bindKey(self.m_actionButton, "down", bind(self.action, self))
	bindKey(self.m_lockButton, "down", bind(self.lock, self))

	self.m_DoorOpenedBind = bind(self.onDoorOpened, self)
	self.m_DoorClosedBind = bind(self.onDoorClosed, self)
	self.m_RenderBind = bind(self.render, self)

	addEventHandler("onDoorOpened", root, self.m_DoorOpenedBind)
	addEventHandler("onDoorClosed", root, self.m_DoorClosedBind)
	addEventHandler("onClientRender", root, self.m_RenderBind)

	-- Font
	GUIFontContainer.constructor(self, "", 1, VRPFont(16))
end

function VehicleInteraction:destructor()
	removeEventHandler("onDoorOpened", root, self.m_DoorOpenedBind)
	removeEventHandler("onDoorClosed", root, self.m_DoorClosedBind)
	removeEventHandler("onClientRender", root, self.m_RenderBind)
end

function VehicleInteraction:render()
    if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/VehicleInteraction") end
	local playerPos = localPlayer:getPosition()
	self.m_lookAtVehicle = getPedTarget(localPlayer)
    if self.m_lookAtVehicle and getElementType(self.m_lookAtVehicle) == "vehicle" and not getControlState("aim_weapon") then
		if not isPedInVehicle(localPlayer) and not GUIElement.getHoveredElement() then
            if getTickCount() - self.m_LastInteraction > self.m_InteractionTimeout then
                local vehPos = self.m_lookAtVehicle:getPosition()
                local doorId = self:getDoor()
                if getDistanceBetweenPoints3D(vehPos, playerPos) < self.m_minDistanceToVeh and doorId then
                    if not isVehicleLocked(self.m_lookAtVehicle) then
                        local isDoorBroken = getVehicleDoorState(self.m_lookAtVehicle, doorId) == 4
                        local doorName = self.m_doorNames[doorId]
                        local doorRatio = getVehicleDoorOpenRatio(self.m_lookAtVehicle, doorId)

                        if doorRatio <= 0 and not isDoorBroken then
                                self:drawTextBox(_("#FFFFFFDrücke #00FF00 %s #FFFFFF zum Öffnen %s#FFFFFF!", self.m_interactButton, doorName), 0)
                            if self:isOwner(self.m_lookAtVehicle) then
                                self:drawTextBox(_("#FFFFFFDrücke #FF0000 %s #FFFFFF um das Fahrzeug abzuschließen!", self.m_lockButton), 1)
                            end
                        end
                        if doorRatio > 0 or isDoorBroken then
                            if not isDoorBroken then
                                self:drawTextBox(_("#FFFFFFDrücke #00FF00 %s #FFFFFF zum Schließen %s#FFFFFF!", self.m_interactButton, doorName), 0)
                            end
                            if doorId == 1 then
                                if getElementData(self.m_lookAtVehicle, "OwnerType") == "group" or getElementData(self.m_lookAtVehicle, "OwnerType") == "player" then
                                    self:drawTextBox(_("#FFFFFFDrücke #FF0000 %s #FFFFFF um den Kofferraum zu durchsuchen!", self.m_actionButton), 1)
                                end
                            elseif doorId == 0 then
                                self:drawTextBox(_("#FFFFFFDrücke #FF0000 %s #FFFFFF um den Motor zu reparieren!", self.m_actionButton), 1)
                            elseif self.m_lookAtVehicle:getModel() == 416 then
                                if doorId == 4 or doorId == 5 then
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
    end
    if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/VehicleInteraction", 1, 1) end
end

function VehicleInteraction:drawTextBox(text, count)
	local width, height = 270, 16
	local x, y = screenWidth/2 - width/2, screenHeight/2 + count*20
	dxDrawRectangle(x, y, width, height, tocolor( 0, 0, 0, 90 ))
	dxDrawText(text, x, y, x+width, y+height, tocolor(255, 255, 255, 255), 1, self.m_Font, "center", "center", false, false, false, true, false)

end

function VehicleInteraction:getDoor()

    local min, minid = 10, 10 -- placeholders, no reason
    for type, id in pairs(self.m_ValidDoors) do
        local compPos
        local x, y, z = self.m_lookAtVehicle:getComponentPosition(type, "world")
        if x then --check if there is a component
            local vx, vy, vz = getElementPosition(self.m_lookAtVehicle)
            local x0, y0, z0, x1, y1, z1 = self.m_lookAtVehicle:getBoundingBox()

            if id == 0 then -- hood
                compPos = self.m_lookAtVehicle.matrix.forward*y1 + Vector3(vx, vy, vz)
            elseif id == 1 then -- trunk
                compPos = self.m_lookAtVehicle.matrix.forward*y0 + Vector3(vx, vy, vz)
            else
                compPos = self.m_lookAtVehicle.matrix.forward*(-0.5) + Vector3(x, y, z) -- move the door position a little bit backwards
            end
        end

        if compPos then
            local distToComp = getDistanceBetweenPoints3D(compPos, localPlayer.position)
            if distToComp < self.m_minDistanceToComp and distToComp < min then -- get the closest component
                min = distToComp
                minid = id
            end
        end
    end
    return minid < 10 and minid
end

function VehicleInteraction:interact()
    if (self.m_lookAtVehicle) and (getElementType(self.m_lookAtVehicle) == "vehicle") and (self:getDoor()) then
        local checkDoor = getVehicleDoorState(self.m_lookAtVehicle, self:getDoor())
        if (checkDoor ~= 4 ) then
            if not (isVehicleLocked(self.m_lookAtVehicle)) then
                if not isPedInVehicle(localPlayer) then
                    if getTickCount() - self.m_LastInteraction > self.m_InteractionTimeout then
                        self.m_LastInteraction = getTickCount()
					    triggerServerEvent("onInteractVehicleDoor", localPlayer, tonumber(self:getDoor()))
                    end
				end
            end
        end
    end
end

function VehicleInteraction:action()
	if (self.m_lookAtVehicle) and (getElementType(self.m_lookAtVehicle) == "vehicle") and (self:getDoor()) then
        if getTickCount() - self.m_LastInteraction > self.m_InteractionTimeout then
            local checkDoor = getVehicleDoorState(self.m_lookAtVehicle, self:getDoor())
            local door = tonumber(self:getDoor())
            if door == 0 or door == 1 then
                local doorRatio = getVehicleDoorOpenRatio(self.m_lookAtVehicle, door)
                if doorRatio > 0 or checkDoor == 4 then
                    if not(isVehicleLocked(self.m_lookAtVehicle)) then
                        if not isPedInVehicle(localPlayer) then
                            self.m_LastInteraction = getTickCount()
                            triggerServerEvent("onActionVehicleDoor", localPlayer, door)
                        end
                    end
                end
            elseif (door == 4 or door == 5) and self.m_lookAtVehicle:getModel() == 416 then
                if localPlayer:getPublicSync("Faction:Duty") and localPlayer:getPublicSync("Rescue:Type") == "medic" then
                    self.m_LastInteraction = getTickCount()
                    triggerServerEvent("factionRescueToggleStretcher", localPlayer, self.m_lookAtVehicle)
                end
            end
        end
    end
end

function VehicleInteraction:lock()
	if (self.m_lookAtVehicle) and (getElementType(self.m_lookAtVehicle) == "vehicle") and (self:getDoor()) then
		if self:isOwner(self.m_lookAtVehicle) then
			if not isPedInVehicle(localPlayer) then
                if getTickCount() - self.m_LastInteraction > self.m_InteractionTimeout then
                    self.m_LastInteraction = getTickCount()
				    triggerServerEvent("onLockVehicleDoor", localPlayer, door)
                end
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
