-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/ShamalExtension.lua
-- *  PURPOSE:     Vehicle Shamal extension class
-- *
-- ****************************************************************************
ShamalExtension = inherit(Object) --gets inherited from vehicle to provide methods to vehicle object

function ShamalExtension:initShamalExtension()
    self.m_ShamalDimension = DimensionManager:getSingleton():getFreeDimension()
    self.m_hasShamalExtension = true

    self.m_ShamalExtensionVehicleExplode = bind(self.Event_seOnVehicleExplode, self)
    self.m_ShamalExtensionVehicleEnter = bind(self.Event_seOnVehicleEnter, self)
    self.m_ShamalExtensionDeleteDriver = bind(self.Event_seDeleteDriver, self)
    addEventHandler("onVehicleExplode", self, self.m_ShamalExtensionVehicleExplode)
    addEventHandler("onVehicleEnter", self, self.m_ShamalExtensionVehicleEnter)
    addEventHandler("onVehicleExit", self, self.m_ShamalExtensionDeleteDriver)
end

function ShamalExtension:delShamalExtension()
    self:seRemovePlayersFromInterior()
    DimensionManager:getSingleton():freeDimension(self.m_ShamalDimension)
    self.m_hasShamalExtension = nil
    
    removeEventHandler("onVehicleExplode", self, self.m_ShamalExtensionVehicleExplode)
    removeEventHandler("onVehicleEnter", self, self.m_ShamalExtensionVehicleEnter)
    removeEventHandler("onVehicleExit", self, self.m_ShamalExtensionDeleteDriver)
end

function ShamalExtension:Event_seOnVehicleEnter(player, seat)
    if seat == 0 then
        self:seCreateDriver(player:getModel())
    end
end

function ShamalExtension:seCreateDriver(skinId)
    self.m_ShamalDriver = Ped.create(skinId, SHAMAL_EXTENSION_INTERIOR_POSITION[0][1], SHAMAL_EXTENSION_INTERIOR_POSITION[0][2])
    self.m_ShamalDriver:setInterior(1)
    self.m_ShamalDriver:setDimension(self.m_ShamalDimension)
    self.m_ShamalDriver:setData("NPC:Immortal", true)
    nextframe(function()
        self.m_ShamalDriver:setAnimation("PED", "SEAT_down", -1, false, false, false, true)
    end)
end

function ShamalExtension:Event_seDeleteDriver()
    self.m_ShamalDriver:destroy()
    self.m_ShamalDriver = nil
end

function ShamalExtension:seEnterExitInterior(player, enter)
    if enter == true then
        unbindKey(player, "g", "down", self.m_SeatExtensionEnterExit)
        player:setRotation(0, 0, SHAMAL_EXTENSION_INTERIOR_POSITION[#self.m_SeatExtensionPassengers][2])
        player:setData("SE:InShamal", true, true)
        nextframe(function()    
            player:setCameraTarget() 
            player:detach(self)
            player:setPosition(SHAMAL_EXTENSION_INTERIOR_POSITION[#self.m_SeatExtensionPassengers][1])
            player:setInterior(1)
            player:setDimension(self.m_ShamalDimension)
            player:setAlpha(255)
            player:setAnimation("PED", "SEAT_up", -1, false, false, false, false)
        end)
        if self.m_ShamalDriver then
            setTimer(function()
            self.m_ShamalDriver:setAnimation("PED", "SEAT_down", -1, false, false, false, true)
            self.m_ShamalDriver:setAnimationProgress("SEAT_down", 1)
            end, 150, 1)
        end

    elseif enter == "quit" then
        local pos = self.m_SeatExtensionCol:getPosition()
        player:detach()
        player:setInterior(0)
        player:setDimension(0)
        player:setPosition(pos.x, pos.y, pos.z - 1)
    elseif enter == "death" then
        player:setData("SE:InShamal", nil, true)
    else
        player:setInterior(0)
        player:setDimension(0)
        player:attach(self)
        player:setAlpha(0)
        player:setCameraTarget(self)
        bindKey(player, "g", "down", self.m_SeatExtensionEnterExit, false)
        player:setData("SE:InShamal", nil, true)
    end
end

function ShamalExtension:Event_seOnVehicleExplode()
    for i, passenger in pairs(self.m_SeatExtensionPassengers) do
        self:seEnterExitInterior(passenger, false)
    end
end

function ShamalExtension:hasShamalExtension()
    return self.m_hasShamalExtension
end

function ShamalExtension:seRemovePlayersFromInterior()
    for i, v in pairs(self.m_SeatExtensionPassengers) do
        if v:getData("SE:InShamal") then
            self:seEnterExitInterior(v, false)
        end
    end 
end