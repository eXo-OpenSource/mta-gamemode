-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleTurbo.lua
-- *  PURPOSE:     turbo exhaust effect
-- *
-- ****************************************************************************

VehicleTurbo = inherit(Singleton)
--//todo add check if vehicle has turbokit installed before creating exhaust fumes
local texName = "smoke"
local count = 0
function VehicleTurbo:constructor() 
    self.m_Vehicles ={}
    self.m_Exhausts ={}
    for k, v in ipairs(getElementsByType("vehicle", root, true)) do  -- todo check if vehicle has actual turbokit installed and not have every car with exhaust-flames
        self.m_Vehicles[v] = true
        v.m_LastGear = getVehicleCurrentGear(v)
        v.m_IsDoubleExhaust = bitAnd(v:getHandling()["modelFlags"], 0x00002000) == 0x00002000
    end
    self.m_RenderBind = bind(self.Event_Render, self)
    addEventHandler("onClientPreRender", root, self.m_RenderBind)

    addEventHandler("onClientElementStreamIn", root, bind(self.Event_onStreamElementIn, self))

    addEventHandler("onClientElementStreamOut", root, bind(self.Event_onStreamElementOut, self))
end


function VehicleTurbo:destructor()

end

function VehicleTurbo:Event_Render()
    local now = getTickCount()
    local fumePosition, posExhaust, posExhaust2, rot, matrixVehicle
    for vehicle, bool in pairs(self.m_Vehicles) do 
        if vehicle and isElement(vehicle) then
            self:checkGear(vehicle)
            fumePosition = Vector3(getVehicleModelExhaustFumesPosition(vehicle:getModel()))
            matrixVehicle = vehicle.matrix
            posExhaust = vehicle:getPosition() + matrixVehicle.right*fumePosition.x + matrixVehicle.forward*fumePosition.y + matrixVehicle.up*fumePosition.z*0.98
            posExhaust2 = vehicle:getPosition() + (matrixVehicle.right*(fumePosition.x*-1)) + matrixVehicle.forward*fumePosition.y + matrixVehicle.up*fumePosition.z*0.98
            rot = vehicle:getRotation()  
            if posExhaust and rot then
                if vehicle.m_EffectCount and vehicle.m_EffectCount < vehicle.m_EffectMaxCount and now - vehicle.m_LastGearChange < 4000 then
                    if vehicle.m_LastGearChange and now - vehicle.m_LastGearChange < 100 then 
                        if not self.m_Exhausts[vehicle] then
                            self:createExhaust(vehicle, {posExhaust, posExhaust2}, rot)
                        else 
                            self:updateExhaust(vehicle, {posExhaust, posExhaust2}, rot)
                        end
                    else 
                        self:destroyExhaust(vehicle)
                    end
                else    
                    self:destroyExhaust(vehicle)
                end
            end
        end
    end
end

function VehicleTurbo:checkGear(vehicle)
    local now = getTickCount()
    if vehicle.m_LastGear ~= getVehicleCurrentGear(vehicle) then 
        vehicle.m_LastGearChange = now
        vehicle.m_LastGear = getVehicleCurrentGear(vehicle)
        vehicle.m_EffectCount = 0
        vehicle.m_EffectMaxCount = math.random(2, 4)
    end
end

function VehicleTurbo:createExhaust(vehicle, pos, rot)
    local exhaustCount = vehicle.m_IsDoubleExhaust and 2 or 1
    if self.m_Exhausts[vehicle] then
        self:destroyExhaust(vehicle)
    end
    if not self.m_Exhausts[vehicle] then 
        self.m_Exhausts[vehicle] = {}
    end
    for i = 1, exhaustCount do 
        self.m_Exhausts[vehicle][i] = createEffect("gunflash", pos[i].x, pos[i].y, pos[i].z)
        self.m_Exhausts[vehicle][i]:setRotation(90, 90, -1*rot.z+180)
        self.m_Exhausts[vehicle][i]:setSpeed(math.random(5, 10) / 10)
        self.m_Exhausts[vehicle][i].sound = Sound3D("files/audio/vehicles/turbo.ogg", vehicle:getPosition())
        self.m_Exhausts[vehicle][i].sound:setMaxDistance(30)
        self.m_Exhausts[vehicle][i].sound:setSpeed(math.random(8, 12)/10)
        self.m_Exhausts[vehicle][i].sound:setEffectEnabled("echo", true)
        attachElements(self.m_Exhausts[vehicle][i], vehicle)
    end
    vehicle.m_EffectCount = vehicle.m_EffectCount + 1
end

function VehicleTurbo:destroyExhaust(vehicle)
    if self.m_Exhausts[vehicle] then
        for i = 1, #self.m_Exhausts[vehicle] do 
            if self.m_Exhausts[vehicle][i] and isElement(self.m_Exhausts[vehicle][i]) then
                self.m_Exhausts[vehicle][i]:destroy()
                self.m_Exhausts[vehicle][i] = nil
            end
        end
    end
    self.m_Exhausts[vehicle] = nil
end

function VehicleTurbo:updateExhaust(vehicle, pos, rot )
    if self.m_Exhausts[vehicle] then 
        local exhaustCount = vehicle.m_IsDoubleExhaust and 2 or 1
        for i = 1, exhaustCount do 
            if self.m_Exhausts[vehicle][i] then
                self.m_Exhausts[vehicle][i]:setPosition(pos[i].x, pos[i].y, pos[i].z)
                self.m_Exhausts[vehicle][i]:setRotation(90, 90, -1*rot.z+180)
            end
        end
    end
end

function VehicleTurbo:Event_onStreamElementIn()
    if getElementType(source) == "vehicle" then 
        self.m_Vehicles[source] = true
        source.m_LastGear = getVehicleCurrentGear(source)
        source.m_IsDoubleExhaust = bitAnd(source:getHandling()["modelFlags"], 0x00002000) == 0x00002000
    end
end

function VehicleTurbo:Event_onStreamElementOut()
    if getElementType(source) == "vehicle" then 
        self.m_Vehicles[source] = nil
    end
end
