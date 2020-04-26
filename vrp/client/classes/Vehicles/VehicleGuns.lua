-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicles/VehicleGuns.lua
-- *  PURPOSE:     Client Vehicle Gun Class
-- *
-- ****************************************************************************

VehicleGuns = inherit(Singleton)
VehicleGuns.Cooldowns = {
    [425] = 5000, --Hunter
    [432] = 5000, --Rhino
    [520] = 5000 --Hydra
}
VehicleGuns.ControlToDeactivate = {
    [425] = "vehicle_fire", --Hunter
    [432] = "vehicle_fire", --Rhino
    [520] = "vehicle_secondary_fire" --Hydra
}
VehicleGuns.LastShoot = {ShotAt=0, LockedUntil=0}

function VehicleGuns:constructor()
    self.m_ShootBind = bind(self.onShoot, self)
    self.m_UpdateBind = bind(self.update, self)
    addEventHandler("onClientVehicleEnter", root, bind(self.onVehicleEnter, self))
    addEventHandler("onClientVehicleExit", root, bind(self.onVehicleExit, self))
    addEventHandler("vehicleEngineStateChange", root, bind(self.onEngineStateChange, self))
end

function VehicleGuns:onShoot()
    if localPlayer:getOccupiedVehicle() then
        if isControlEnabled(self.m_Control) then
            if localPlayer:getOccupiedVehicle():getEngineState() then
                if VehicleGuns.LastShoot.LockedUntil < getTickCount() then
                    local cooldown = VehicleGuns.Cooldowns[localPlayer:getOccupiedVehicle():getModel()]
                    VehicleGuns.LastShoot = {ShotAt=getTickCount(), LockedUntil=getTickCount()+cooldown}
                    addEventHandler("onClientRender", root, self.m_UpdateBind)

                    local time = (VehicleGuns.LastShoot.LockedUntil-VehicleGuns.LastShoot.ShotAt) / 1000
                    self.m_Countdown = ShortCountdown:new(time, "Nachladen", "files/images/Other/Bullet.png")
                end
            end
        end
    end
end

function VehicleGuns:update()
    if VehicleGuns.LastShoot.LockedUntil >= getTickCount() or (localPlayer:getOccupiedVehicle() and localPlayer:getOccupiedVehicle():getEngineState() == false) then
        toggleControl(self.m_Control, false)
    else
        if self:isKeyPressed() == false then
            removeEventHandler("onClientRender", root, self.m_UpdateBind)
            toggleControl(self.m_Control, true)
        end
    end
end

function VehicleGuns:onVehicleEnter(player, seat)
    if player == localPlayer then
        if seat == 0 then
            if VehicleGuns.Cooldowns[source:getModel()] then
                self.m_Control = VehicleGuns.ControlToDeactivate[source:getModel()]
                bindKey(self.m_Control, "down", self.m_ShootBind)
                addEventHandler("onClientRender", root, self.m_UpdateBind)
            end
        end
    end
end

function VehicleGuns:onVehicleExit(player, seat)
    if player == localPlayer then
        unbindKey(self.m_Control, "down", self.m_ShootBind)
        if self.m_Countdown then
            delete(self.m_Countdown)
        end
    end
end

function VehicleGuns:onEngineStateChange(state)
    if VehicleGuns.Cooldowns[source:getModel()] then
        if state == false then
            if not isEventHandlerAdded("onClientRender", root, self.m_UpdateBind) then
                addEventHandler("onClientRender", root, self.m_UpdateBind)
            end
        end
    end
end

function VehicleGuns:isKeyPressed()
    local keyPressed = false
    for key, state in pairs(getBoundKeys("vehicle_fire")) do
        if getKeyState(key) then
            keyPressed = true
        end
    end
    return keyPressed
end