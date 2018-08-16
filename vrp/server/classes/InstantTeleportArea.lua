InstantTeleportArea = inherit(Object)

function InstantTeleportArea:constructor(col, int, dim, pos)
    self.m_Colshape = col
    self.m_DestinationDim = dim or 0
    self.m_DestinationInt = int or 0
    self.m_Pos = pos or false
    self.m_ColShapeHit = bind(self.Event_onColShapeHit, self)
    addEventHandler("onColShapeHit", self.m_Colshape, self.m_ColShapeHit)
    self.m_ColShapeLeave = bind(self.Event_onColShapeLeave, self)
    addEventHandler("onColShapeLeave", self.m_Colshape, self.m_ColShapeLeave)
end

function InstantTeleportArea:Event_onColShapeHit( hE, bDim ) 
    local hE = hE
    if bDim then 
        if hE:getType() ~= "vehicle" or not hE:getTowingVehicle() then  
            setElementDimension(hE, self.m_DestinationDim)
            setElementInterior(hE, self.m_DestinationInt)
        end
        if hE:getType() == "vehicle" and hE:getTowedByVehicle() then
            local veh = hE:getTowedByVehicle()
            setElementDimension(veh, self.m_DestinationDim)
            setElementInterior(veh, self.m_DestinationInt)
            nextframe(function() 
                detachTrailerFromVehicle(hE)
                attachTrailerToVehicle(hE, veh) 
            end)
        end
        if self.m_Pos then 
            hE:setPosition(self.m_Pos)
        end
    end
end

function InstantTeleportArea:Event_onColShapeLeave( hE, bDim )
    local hE = hE
    if hE:getDimension() == self.m_DestinationDim and hE:getInterior() == self.m_DestinationInt then 
        if hE:getType() ~= "vehicle" or not hE:getTowingVehicle() then
            setElementDimension(hE, self.m_Colshape:getDimension())
            setElementInterior(hE, self.m_Colshape:getInterior())
        end
        if hE:getType() == "vehicle" and hE:getTowedByVehicle() then
            local veh = hE:getTowedByVehicle()
            setElementDimension(veh, self.m_Colshape:getDimension())
            setElementInterior(veh, self.m_Colshape:getInterior())
            nextframe(function() 
                detachTrailerFromVehicle(hE)
                outputDebug(attachTrailerToVehicle(hE, veh)) 
            end)
        end
        if self.m_Pos then 
            hE:setPosition(self.m_Pos)
        end
    end
end
