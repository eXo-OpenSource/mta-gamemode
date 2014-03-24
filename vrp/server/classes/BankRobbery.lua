-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************
BankRobbery = inherit(Object)

function BankRobbery:constructor(position, rotation, interior, dimension)
	self.m_Safe = createObject(2332, position.X, position.Y, position.Z, 0, 0, rotation)
	setElementInterior(self.m_Safe, interior)
	setElementDimension(self.m_Safe, dimension or 0)
	
	setObjectScale(self.m_Safe, 6)
	-- Todo: Create a dummy wall to create a 'fake collider'
end

function BankRobbery.initializeAll()
	BankRobbery:new(Vector(359.8, 160.7, 1009.9), 130, 3)
end
