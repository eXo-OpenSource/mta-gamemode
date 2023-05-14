NonOcclusionZone = inherit(Object)

function NonOcclusionZone:constructor(col)
    self.m_Colshape = col
    self.m_ColShapeHit = bind(self.Event_onColShapeHit, self)
    addEventHandler("onClientColShapeHit", self.m_Colshape, self.m_ColShapeHit)
    self.m_ColShapeLeave = bind(self.Event_onColShapeLeave, self)
    addEventHandler("onClientColShapeLeave", self.m_Colshape, self.m_ColShapeLeave)
end

function NonOcclusionZone:destructor()
	destroyElement(self.m_Colshape)
end

function NonOcclusionZone:Event_onColShapeHit( hE, bDim ) 
    if bDim and hE == localPlayer then 
		setOcclusionsEnabled(false)
    end
end

function NonOcclusionZone:Event_onColShapeLeave( hE, bDim )
    if bDim and hE == localPlayer then 
        setOcclusionsEnabled(true)
    end
end
