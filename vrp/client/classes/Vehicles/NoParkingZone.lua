NoParkingZone = inherit(Object)

function NoParkingZone:constructor(col)
    self.m_Colshape = col
    self.m_ColShapeHit = bind(self.Event_onColShapeHit, self)
    addEventHandler("onClientColShapeHit", self.m_Colshape, self.m_ColShapeHit)
    self.m_ColShapeLeave = bind(self.Event_onColShapeLeave, self)
    addEventHandler("onClientColShapeLeave", self.m_Colshape, self.m_ColShapeLeave)
end

function NoParkingZone:Event_onColShapeHit( hE, bDim ) 
    if bDim and hE == localPlayer then 
        hE.m_DisallowParking = true
    end
end

function NoParkingZone:Event_onColShapeLeave( hE, bDim )
    if bDim and hE == localPlayer then 
        hE.m_DisallowParking = false
    end
end
