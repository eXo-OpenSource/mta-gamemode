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
    if bDim then 
        setElementDimension(hE, self.m_DestinationDim)
        setElementInterior(hE, self.m_DestinationInt)
        if self.m_Pos then 
            hE:setPosition(self.m_Pos)
        end
    end
end

function InstantTeleportArea:Event_onColShapeLeave( hE, bDim )
    if hE:getDimension() == self.m_DestinationDim and hE:getInterior() == self.m_DestinationInt then 
        setElementDimension(hE, self.m_Colshape:getDimension())
        setElementInterior(hE, self.m_Colshape:getInterior())
        if self.m_Pos then 
            hE:setPosition(self.m_Pos)
        end
    end
end
