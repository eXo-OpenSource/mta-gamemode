-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/RcVanExtension.lua
-- *  PURPOSE:     Vehicle rc van extension class
-- *
-- ****************************************************************************
RcVanExtension = inherit(Object) --gets inherited from vehicle to provide methods to vehicle object

RcVanExtensionLastUse = {}
RcVanExtensionLoadBatteryTimer = {}
RcVanExtensionBattery = {}

function RcVanExtension:toggleBaron(player, state, force)
    if state then
        if not RcVanExtensionLastUse[self:getId()] then
            RcVanExtensionLastUse[self:getId()] = 0
        end

        if RcVanExtensionLastUse[self:getId()] + RC_TOGGLE_COOLDOWN <= getRealTime().timestamp then
            self.m_Baron = TemporaryVehicle.create(464, self.position.x, self.position.y, self.position.z+1.5, self.rotation.z)

            self:setData("BaronUser", player, true)
            player:setData("UsingBaron", true, true)
            player:setData("RCVan", self, true)
            player:setPublicSync("isInvisible", true)
            
            if isTimer(RcVanExtensionLoadBatteryTimer[self:getId()]) then killTimer(RcVanExtensionLoadBatteryTimer[self:getId()]) end
            player:triggerEvent("Countdown", RcVanExtensionBattery[self:getId()] or 15*60, "Batterie")
            self.m_BaronBatteryTimer = setTimer(bind(self.toggleBaron, self), RcVanExtensionBattery[self:getId()] and RcVanExtensionBattery[self:getId()]*1000 or 15*60*1000, 1, player, false, true)
            
            self.m_BaronRange = createColSphere(0, 0, 0, 500)
            self.m_BaronRange:attach(self)

            player.m_BaronOldSeat = player.vehicleSeat
            player:setAlpha(0)
            player:removeFromVehicle()
            player:warpIntoVehicle(self.m_Baron)      
            player:setCameraTarget() -- if the player minimize the window, the camera target will still be the rc van

            self.m_RcVanExtensionVehicleDamage = bind(self.Event_rveVehicleDamage, self)
            self.m_RcVanExtensionVehicleStartEnter = bind(self.Event_rveVehicleStartEnter, self)
            self.m_RcVanExtensionVehicleStartEnterVan = bind(self.Event_rveVehicleStartEnterVan, self)
            self.m_RcVanExtensionVehicleStartExit = bind(self.Event_rveVehicleStartExit, self)
            self.m_RcVanExtensionColShapeHit = bind(self.Event_rveColShapeHit, self)
            self.m_RcVanExtensionColShapeLeave = bind(self.Event_rveColShapeLeave, self)
            addEventHandler("onVehicleDamage", self.m_Baron, self.m_RcVanExtensionVehicleDamage)
            addEventHandler("onVehicleStartEnter", self.m_Baron, self.m_RcVanExtensionVehicleStartEnter)
            addEventHandler("onVehicleStartEnter", self, self.m_RcVanExtensionVehicleStartEnterVan)
            addEventHandler("onVehicleStartExit", self.m_Baron, self.m_RcVanExtensionVehicleStartExit)
            addEventHandler("onColShapeHit", self.m_BaronRange, self.m_RcVanExtensionColShapeHit)
            addEventHandler("onColShapeLeave", self.m_BaronRange, self.m_RcVanExtensionColShapeLeave)
        else
            player:sendError(_("Du kannst den RC Baron noch nicht wieder nutzen.", player))
        end
    else
        if force then
            RcVanExtensionLastUse[self:getId()] = getRealTime().timestamp
            player:sendWarning(_("Dein RC Baron ist zerstört.", player))
        else
            RcVanExtensionLastUse[self:getId()] = getRealTime().timestamp - RC_TOGGLE_COOLDOWN
        end

        removeEventHandler("onVehicleDamage", self.m_Baron, self.m_RcVanExtensionVehicleDamage)
        removeEventHandler("onVehicleStartEnter", self.m_Baron, self.m_RcVanExtensionVehicleStartEnter)
        removeEventHandler("onVehicleStartEnter", self, self.m_RcVanExtensionVehicleStartEnter)
        removeEventHandler("onVehicleStartExit", self.m_Baron, self.m_RcVanExtensionVehicleStartExit)
        removeEventHandler("onColShapeHit", self.m_BaronRange, self.m_RcVanExtensionColShapeHit)
        removeEventHandler("onColShapeLeave", self.m_BaronRange, self.m_RcVanExtensionColShapeLeave)

        RcVanExtensionBattery[self:getId()] = self.m_BaronBatteryTimer:getDetails()/1000 
        if isTimer(self.m_BaronBatteryTimer) then killTimer(self.m_BaronBatteryTimer) end
        player:triggerEvent("CountdownStop", "Batterie")
        
        RcVanExtensionLoadBatteryTimer[self:getId()] = setTimer(function()
            if RcVanExtensionBattery[self:getId()] < 900 then
                RcVanExtensionBattery[self:getId()] = tonumber(RcVanExtensionBattery[self:getId()]) + 5
            else
                RcVanExtensionBattery[self:getId()] = 900
                killTimer(RcVanExtensionLoadBatteryTimer[self:getId()])
            end
        end, 10000, 0)

        player:setAlpha(255)
        player:removeFromVehicle()
        player:warpIntoVehicle(self, player.m_BaronOldSeat)
        self.m_Baron:destroy()
        self.m_BaronRange:destroy()

        self:setData("BaronUser", nil, true)
        player:setData("UsingBaron", nil, true)
        player:setData("RCVan", nil, true)
        player:setPublicSync("isInvisible", false)
    end
        

end

function RcVanExtension:Event_rveVehicleDamage(loss)
    if source:getHealth() < 250 then
        local player = source:getOccupant()
        self:toggleBaron(player, false, true)
    end
end

function RcVanExtension:Event_rveColShapeHit(player)
    if player.type ~= "player" then return end
    player:triggerEvent("CountdownStop", "Connection lost")
    player:triggerEvent("RVE:withinRange")
    if isTimer(player.m_rveOutOfRangeTimer) then killTimer(player.m_rveOutOfRangeTimer) end
end

function RcVanExtension:Event_rveColShapeLeave(player)
    if player.type ~= "player" then return end
    player:triggerEvent("RVE:outOfRange")
    player:triggerEvent("Countdown", 15, "Connection lost")
    player.m_rveOutOfRangeTimer = setTimer(function()
        self:toggleBaron(player, false, true)
        player:triggerEvent("RVE:withinRange")
    end, 15000, 1)
end

function RcVanExtension:Event_rveVehicleStartEnter()
    cancelEvent()
end

function RcVanExtension:Event_rveVehicleStartEnterVan(player, seat)
    if self:getData("BaronUser") then
        if seat == self:getData("BaronUser").m_BaronOldSeat then
            cancelEvent()
        end
    end
end

function RcVanExtension:Event_rveVehicleStartExit(player)
    self:toggleBaron(player, false, true)
end

