-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/PoliceAnnouncements.lua
-- *  PURPOSE:     Police Announcement Sounds class
-- *
-- ****************************************************************************
PoliceAnnouncements = inherit(Singleton)
POLICE_SIREN_SYNC_INTERVAL = 600000

addRemoteEvents{"PoliceAnnouncements:triggerChaseSound"}
function PoliceAnnouncements:constructor()
    self.m_SirenVehicles = {} -- states: active, secondary, inactive
    self.m_BindFunction = bind(self.handleBind, self)
    self.m_ChaseSoundBind = bind(self.triggerChaseSound, self)
    self.m_SirenSyncBind = bind(self.syncSirens, self)
    
    self.m_SirenSyncTimer = setTimer(self.m_SirenSyncBind, POLICE_SIREN_SYNC_INTERVAL, 0)
    addEventHandler("PoliceAnnouncements:triggerChaseSound", root, self.m_ChaseSoundBind)
end

function PoliceAnnouncements:destructor()
    removeEventHandler("PoliceAnnouncements:triggerChaseSound", root, self.m_ChaseSoundBind)
end

function PoliceAnnouncements:triggerWantedSound(target, wantedreason)
    local modelId = false
    local color = false
    if target:getOccupiedVehicle() then
        vehicle = target:getOccupiedVehicle()
        modelId = vehicle:getModel()
        color = vehicle:getColor()
    end
    local zone = getZoneName(target:getPosition())
    for key, player in ipairs(getElementsByType("player")) do
        if player:getFaction() and player:getFaction():isStateFaction() then
            if player:isFactionDuty() then
                player:triggerEvent("PoliceAnnouncement:wanted", zone, wantedreason, modelId, color)
            end
        end
    end
end

function PoliceAnnouncements:triggerChaseSound(vehicle)
    local cx, cy, cz = getElementPosition(vehicle)
    if vehicle:getVehicleType() == 4 then
        chaseSoundType = "Boat"
        chaseSoundRandom = math.random(1, #POLICE_ANNOUNCEMENT_CHASE_SOUNDS["Boat"])
    elseif vehicle:getVehicleType() == 3 then
        chaseSoundType = "Helicopter"
        chaseSoundRandom = math.random(1, #POLICE_ANNOUNCEMENT_CHASE_SOUNDS["Helicopter"])
    else
        chaseSoundType = "Vehicles"
        chaseSoundRandom = math.random(1, #POLICE_ANNOUNCEMENT_CHASE_SOUNDS["Vehicles"])
    end
    for key, player in ipairs(getElementsByType("player")) do
        local x, y, z = getElementPosition(player)
        if getDistanceBetweenPoints3D(cx, cy, cz, x, y, z) < 200 then
            player:triggerEvent("PoliceAnnouncement:chase", vehicle, chaseSoundType, chaseSoundRandom)
        end
    end
end

function PoliceAnnouncements:isValidVehicle(vehicle)
    if getElementData(vehicle, "StateVehicle") and vehicle:getVehicleType() ~= "Helicopter" and vehicle:getVehicleType() ~= "Plane" and vehicle:getModel() ~= 432 then
        return true
    end
end

function PoliceAnnouncements:syncSirens(singlePlayer)
    if singlePlayer then
        singlePlayer:triggerEvent("PoliceAnnouncement:syncSiren", self.m_SirenVehicles)
        return
    end
    for key, player in ipairs(getElementsByType("player")) do
        player:triggerEvent("PoliceAnnouncement:syncSiren", self.m_SirenVehicles)
    end
end

function PoliceAnnouncements:setSirenState(vehicle, sirenType)
    if not self.m_SirenVehicles[vehicle] and sirenType == "inactive" then return end

    if self:isValidVehicle(vehicle) then 
        self.m_SirenVehicles[vehicle] = sirenType
        for key, player in ipairs(getElementsByType("player")) do
            player:triggerEvent("PoliceAnnouncement:siren", vehicle, sirenType)
        end
    end
end

function PoliceAnnouncements:getSirenState(vehicle)
    return self.m_SirenVehicles[vehicle] and self.m_SirenVehicles[vehicle] or "inactive"
end

function PoliceAnnouncements:handleBind(player, key, keystate)
    if player ~= player.vehicle.controller then return end
    if keystate == "down" then
        player.m_LastSirenAction = getTickCount()
        if self:getSirenState(player.vehicle) == "active" then
            self:setSirenState(player.vehicle, "secondary")
        end
    elseif keystate == "up" then
        if getTickCount() - player.m_LastSirenAction < 200 then
            if self:getSirenState(player.vehicle) == "inactive" then
                self:setSirenState(player.vehicle, "active")
            elseif self:getSirenState(player.vehicle) == "active" then
                self:setSirenState(player.vehicle, "inactive")
            elseif self:getSirenState(player.vehicle) == "secondary" then
                self:setSirenState(player.vehicle, "inactive")
            end
        else
            if self:getSirenState(player.vehicle) == "secondary" then
                self:setSirenState(player.vehicle, "active")
            end
        end
    end
end