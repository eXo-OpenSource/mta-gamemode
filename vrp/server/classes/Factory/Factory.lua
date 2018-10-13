-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Factory/Factory.lua
-- *  PURPOSE:     Factory class
-- *
-- ****************************************************************************

Factory = inherit(Object)

function Factory:constructor(id, position)
	self.m_Pickup = createPickup(position, 3, 1239, 0)
end
