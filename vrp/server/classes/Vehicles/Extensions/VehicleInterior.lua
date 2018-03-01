-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleInterior.lua
-- *  PURPOSE:     Vehicle Interior class
-- *
-- ****************************************************************************

VehicleInterior = inherit(Object) 

function VehicleInterior:constructor( intId, vehicle )
	self.m_Locked = false
	self.m_Interior = intId
	self.m_Dimension = vehicle.m_VehicleInteriorId
end

function VehicleInterior:destructor() 

end

function VehicleInterior:setLocked( state ) 
	self.m_Locked = state
end
