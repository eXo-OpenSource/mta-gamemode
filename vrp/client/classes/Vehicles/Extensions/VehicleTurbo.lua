-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleTurbo.lua
-- *  PURPOSE:     turbo exhaust effect
-- *
-- ****************************************************************************

VehicleTurbo = inherit(Singleton)

local texName = "smoke"
local count = 0
function VehicleTurbo:constructor() 
    self.m_Vehicles ={}
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
    for vehicle, bool in pairs(self.m_Vehicles) do 
        if vehicle and isElement(vehicle) then
            if vehicle.m_LastGear ~= getVehicleCurrentGear(vehicle) then 
                vehicle.m_LastGearChange = now
                vehicle.m_LastGear = getVehicleCurrentGear(vehicle)
            end
            local x,y,z = getElementPosition(vehicle)
            local fumePosition = Vector3(getVehicleModelExhaustFumesPosition(vehicle:getModel()))
            local fumePosition2
            fumePosition = vehicle:getPosition() + vehicle.matrix.right*fumePosition.x +vehicle.matrix.forward*fumePosition.y + vehicle.matrix.up*fumePosition.z
            if vehicle.m_IsDoubleExhaust then
                fumePosition2 = Vector3(getVehicleModelExhaustFumesPosition(vehicle:getModel()))
                fumePosition2 = vehicle:getPosition() + (vehicle.matrix.right*(fumePosition2.x*-1)) + vehicle.matrix.forward*fumePosition2.y + vehicle.matrix.up*fumePosition2.z
            end
            local rx, ry, rz = getElementRotation(vehicle)  
            if fumePosition then
                if vehicle.m_LastGearChange and now - vehicle.m_LastGearChange < 400 then 
                    if not vehicle.m_ExhaustTurbo then
                        vehicle.m_ExhaustTurbo = createEffect("gunflash", fumePosition.x, fumePosition.y, fumePosition.z, 90, 90, -1*rz+180)
                        vehicle.m_ExhaustTurbo:setSpeed(0.5)
                        if vehicle.m_IsDoubleExhaust then
                            vehicle.m_ExhaustTurbo2 = createEffect("gunflash", fumePosition2.x, fumePosition2.y, fumePosition2.z, 90, 90, -1*rz+180)
                            vehicle.m_ExhaustTurbo2:setSpeed(0.5)
                        end
                    else 
                        vehicle.m_ExhaustTurbo:setPosition(fumePosition)
                        vehicle.m_ExhaustTurbo:setRotation( 90, 90, rz*-1+180)
                        if vehicle.m_IsDoubleExhaust then
                            if vehicle.m_ExhaustTurbo2 then
                                vehicle.m_ExhaustTurbo2:setPosition(fumePosition2)
                                vehicle.m_ExhaustTurbo2:setRotation( 90, 90, rz*-1+180)
                            end
                        end
                    end
                else 
                    if vehicle.m_ExhaustTurbo then 
                        vehicle.m_ExhaustTurbo:destroy()
                        vehicle.m_ExhaustTurbo = nil
                    end
                    if vehicle.m_ExhaustTurbo2 then 
                        vehicle.m_ExhaustTurbo2:destroy()
                        vehicle.m_ExhaustTurbo2 = nil
                    end
                end
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
