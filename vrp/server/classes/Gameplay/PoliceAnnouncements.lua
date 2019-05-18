-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/PoliceAnnouncements.lua
-- *  PURPOSE:     Police Announcement Sounds class
-- *
-- ****************************************************************************
PoliceAnnouncements = inherit(Singleton)

addRemoteEvents{"PoliceAnnouncements:triggerChaseSound"}
function PoliceAnnouncements:constructor()
    self.m_SirenVehicles = {}

    self.m_ChaseSoundBind = bind(self.triggerChaseSound, self)
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

function PoliceAnnouncement:triggerSiren(vehicle)

end