-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/Shamal.lua
-- *  PURPOSE:     Vehicle Shamal  class
-- *
-- ****************************************************************************
Shamal = inherit(Object)

function Shamal:constructor(shamal)
    self.m_Shamal = shamal
    self.m_ShamalDimension = DimensionManager:getSingleton():getFreeDimension()
    self.m_ShamalEnterCol = createColSphere(0, 0, 0, 3)
    self.m_ShamalEnterCol:attach(self.m_Shamal, 2, 3.6, 0)
    self.m_Passengers = {}

    self.m_EnterExit = bind(self.enterExit, self)
    addEventHandler("onColShapeHit", self.m_ShamalEnterCol, bind(self.Event_onColShapeHit, self))
    addEventHandler("onColShapeLeave", self.m_ShamalEnterCol, bind(self.Event_onColShapeLeave, self))
    addEventHandler("onVehicleExplode", self.m_Shamal, bind(self.Event_onVehicleExplode, self))
    addEventHandler("onVehicleEnter", self.m_Shamal, bind(self.Event_onVehicleEnter, self))
    addEventHandler("onVehicleExit", self.m_Shamal, bind(self.Event_deleteDriver, self))
    addEventHandler("onVehicleStartEnter", self.m_Shamal, bind(self.Event_onVehicleStartEnter, self))
end

function Shamal:Event_onColShapeHit(hitElement, matchingDim)
    if not hitElement:isDead() and hitElement.type == "player" then
        bindKey(hitElement, "g", "down", self.m_EnterExit, true)
    end
end

function Shamal:Event_onColShapeLeave(leaveElement, matchingDim)
    unbindKey(leaveElement, "g", "down", self.m_EnterExit)
end

function Shamal:Event_onVehicleStartEnter(player)
    unbindKey(player, "g", "down", self.m_EnterExit)
end

function Shamal:Event_onVehicleEnter(player, seat)
    if seat == 0 then
        self:createDriver(player:getModel())
    end
end

function Shamal:createDriver(skinId)
    self.m_ShamalDriver = Ped.create(skinId, ShamalManager.InteriorPositions[0][1], ShamalManager.InteriorPositions[0][2])
    self.m_ShamalDriver:setInterior(1)
    self.m_ShamalDriver:setDimension(self.m_ShamalDimension)
    self.m_ShamalDriver:setData("NPC:Immortal", true)
    nextframe(function()
        self.m_ShamalDriver:setAnimation("PED", "SEAT_down", -1, false, false, false, true)
    end)
end

function Shamal:Event_deleteDriver()
    self.m_ShamalDriver:destory()
end

function Shamal:enterExit(player, key, keystate, enter)
    if enter then
        if #self.m_Passengers <= VEHICLE_MAX_PASSENGER[519] then
            if not table.find(self.m_Passengers, player) then
                player:attach(self.m_Shamal)
                player:setCameraTarget(self.m_Shamal)
                table.insert(self.m_Passengers, player)
                player:setData("Shamal:Passenger", true, true)
                player:setData("Shamal", self.m_Shamal, true)
                setTimer(function() bindKey(player, "g", "down", self.m_EnterExit, false) end, 250, 1)
            else
                player:sendError(_"Du kannst nicht 2x einsteigen o.O")
            end
        else
            player:sendInfo(_"Das Flugzeug ist voll.")
        end
    else
        local pos = self.m_ShamalEnterCol:getPosition()
        player:detach(self.m_Shamal)
        player:setPosition(pos.x, pos.y, pos.z - 1)
        player:setCameraTarget()
        unbindKey(player, "g", "down", self.m_EnterExit)
        table.removevalue(self.m_Passengers, player)
        player:setData("Shamal:Passenger", nil, true)
        player:setData("Shamal", nil, true)
    end
end

function Shamal:enterExitInterior(player, enter)
    if enter == true then
        unbindKey(player, "g", "down", self.m_EnterExit)
        player:setRotation(0, 0, ShamalManager.InteriorPositions[#self.m_Passengers][2])
        nextframe(function()    
            player:setCameraTarget() 
            player:detach(self.m_Shamal)
            player:setPosition(ShamalManager.InteriorPositions[#self.m_Passengers][1])
            player:setInterior(1)
            player:setDimension(self.m_ShamalDimension)
            player:setAnimation("PED", "SEAT_up", -1, false, false, false, false)
        end)
        setTimer(function()
        self.m_ShamalDriver:setAnimation("PED", "SEAT_down", -1, false, false, false, true)
        self.m_ShamalDriver:setAnimationProgress("SEAT_down", 1)
        end, 150, 1)

        player.shamalInterior = self
    elseif enter == "quit" then
        local pos = self.m_ShamalEnterCol:getPosition()
        player:detach()
        player:setInterior(0)
        player:setDimension(0)
        player:setPosition(pos.x, pos.y, pos.z - 1)
        player.shamalInterior = nil
    else
        player:setInterior(0)
        player:setDimension(0)
        player:attach(self.m_Shamal)
        player:setCameraTarget(self.m_Shamal)
        bindKey(player, "g", "down", self.m_EnterExit, false)
        player.shamalInterior = nil
    end
end

function Shamal:Event_onVehicleExplode()
    for i, passenger in pairs(self.m_Passengers) do
        --createExplosion(passenger:getPosition(), 7)
        self:enterExitInterior(passenger, false)
        self:enterExit(passenger, "g", "down", false)
        passenger:kill()
    end
end