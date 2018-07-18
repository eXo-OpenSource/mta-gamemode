ParkGarageZone = inherit(Object)

function ParkGarageZone:constructor(col)
    self.m_Colshape = col
    self.m_ColShapeHit = bind(self.Event_onColShapeHit, self)
    addEventHandler("onColShapeHit", self.m_Colshape, self.m_ColShapeHit)
    self.m_ColShapeLeave = bind(self.Event_onColShapeLeave, self)
    addEventHandler("onColShapeLeave", self.m_Colshape, self.m_ColShapeLeave)
end

function ParkGarageZone:Event_onColShapeHit( hE, bDim ) 
    if bDim  then 
        hE.m_InParkGarage = true
    end
end

function ParkGarageZone:Event_onColShapeLeave( hE, bDim )
    if bDim  then 
        hE.m_InParkGarage = false
    end
end
