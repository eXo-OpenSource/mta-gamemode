-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/InteriorEntrance.lua
-- *  PURPOSE:     interor entrance object 
-- *
-- ****************************************************************************
InteriorEntrance = inherit(Object) 

function InteriorEntrance:constructor(super, position, interior, dimension) 
	self:setSuper(super)
	self:setPosition(position)
	self:setInterior(interior or 0)
	self:setDimension(dimension or 0)
end


function InteriorEntrance:destructor() 

end

function InteriorEntrance:setSuper(instance) 
	assert(type(instance) == "table", "Bad argument @ InteriorEntrance.setSuper")
	self.m_Instance = instance
end

function InteriorEntrance:setDimension(dimension) 
	assert(dimension, "Bad argument @ InteriorEntrance.setDimension")
	self.m_Dimension = dimension or 0
	return self
end

function InteriorEntrance:setInterior(interior) 
	assert(interior, "Bad argument @ InteriorEntrance.setInterior")
	self.m_Interior = interior or 0
	return self
end

function InteriorEntrance:setPosition(position) 
	assert(position, "Bad argument @ InteriorEntrance.setPosition")
	self.m_Position = position
	return self
end

function InteriorEntrance:getPosition() return self.m_Position end
function InteriorEntrance:getDimension() return self.m_Dimension end 
function InteriorEntrance:getInterior() return self.m_Interior end 
function InteriorEntrance:getSuper() return self.m_Instance end