-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/Managers/NailWorldItemManager.lua
-- *  PURPOSE:     Nail World Item Manager class
-- *
-- ****************************************************************************

NailWorldItemManager = inherit(Singleton)
NailWorldItemManager.WheelNames = {"wheel_lf_dummy", "wheel_lb_dummy", "wheel_rf_dummy", "wheel_rb_dummy"}

function NailWorldItemManager:constructor()
    addEventHandler("onClientElementStreamIn", resourceRoot, bind(self.onStreamIn, self))
    addEventHandler("onClientElementStreamOut", resourceRoot, bind(self.onStreamOut, self))

    self.m_OnHitBind = bind(self.onColShapeHit, self)
    self.m_OnLeaveBind = bind(self.onColShapeLeave, self)
    self.m_OnEnterBind = bind(self.onVehicleEnter, self)
    self.m_OnExitBind = bind(self.onVehicleExit, self)
    self.m_CheckBind = bind(self.checkForHit, self)

    self.m_NailsToCheck = {}
    self.m_NailColShapes = {}

    addEventHandler("onClientVehicleEnter", root, self.m_OnEnterBind)
    addEventHandler("onClientVehicleExit", root, self.m_OnExitBind)
end

function NailWorldItemManager:onStreamIn()
    if source:getModel() == 2892 then
        local x, y, z = getElementPosition(source)
        self.m_NailColShapes[source] = createColSphere(x, y, z, 15)
        self.m_NailColShapes[source].object = source

        addEventHandler("onClientColShapeHit", self.m_NailColShapes[source], self.m_OnHitBind)
        addEventHandler("onClientColShapeLeave", self.m_NailColShapes[source], self.m_OnLeaveBind)
    end
end

function NailWorldItemManager:onStreamOut()
    if self.m_NailColShapes[source] then
        self.m_NailColShapes[source]:destroy()
        self.m_NailColShapes[source] = nil
    end
end

function NailWorldItemManager:onColShapeHit(hitElement, matchingDim)
    if hitElement:getType() == "vehicle" and hitElement.controller == localPlayer then
        self.m_NailsToCheck[source.object] = true
        if not isTimer(self.m_Timer) then
            self.m_Timer = setTimer(self.m_CheckBind, 10, 0)
        end
    end
end

function NailWorldItemManager:onColShapeLeave(leaveElement, matchingDim)
    if not isElement(source.object) then
        self.m_NailColShapes[source.object] = nil
        source:destroy()
    end

    if leaveElement:getType() == "vehicle" and leaveElement.controller == localPlayer then
        if self.m_NailsToCheck[source.object] then
            self.m_NailsToCheck[source.object] = nil
        end

        if table.size(self.m_NailsToCheck) == 0 then
            if isTimer(self.m_Timer) then
                self.m_Timer:destroy()
            end
        end
    end
end

function NailWorldItemManager:onVehicleEnter(player, seat)
    if player == localPlayer and seat == 0 then
        for index, colshape in pairs(self.m_NailColShapes) do
            if source:isWithinColShape(colshape) then
                if isElement(colshape.object) then
                    self.m_NailsToCheck[colshape.object] = true
                    if not isTimer(self.m_Timer) then
                        self.m_Timer = setTimer(self.m_CheckBind, 10, 0)
                    end
                else
                    colshape:destroy()
                    self.m_NailColShapes[colshape] = nil
                end
            end
        end
    end
end

function NailWorldItemManager:onVehicleExit(player, seat)
    if player == localPlayer and seat == 0 then
        if isTimer(self.m_Timer) then
            self.m_Timer:destroy()
        end
        self.m_NailsToCheck = {}
    end
end

function NailWorldItemManager:checkForHit()
    if not localPlayer.vehicle then
        return
    end
    
    local wheelStates = {localPlayer.vehicle:getWheelStates()}
    local trigger = false

    for index, wheel in pairs(NailWorldItemManager.WheelNames) do
        local wx, wy, wz = localPlayer.vehicle:getComponentPosition(wheel, "world")

        if wheelStates[index] == 0 then
            for nailObject, value in pairs(self.m_NailsToCheck) do
                if isElement(nailObject) then
                    local minX, minY, minZ, maxX, maxY, maxZ = nailObject:getBoundingBox()
                    local objectMatrix = nailObject:getMatrix()
                    local minVec = objectMatrix:transformPosition(Vector3(minX, minY, minZ))
                    local maxVec = objectMatrix:transformPosition(Vector3(maxX, maxY, maxZ))

                    if isPositionBetweenPoints(wx, wy, wz, minVec.x, minVec.y, minVec.z, maxVec.x, maxVec.y, maxVec.z+0.5) then
                        wheelStates[index] = 1
                        trigger = true
                    end
                end
            end
        end
    end

    if trigger then
        triggerServerEvent("Nails:flattenWheel", localPlayer, localPlayer.vehicle, wheelStates)
    end
end