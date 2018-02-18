-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Super/MTAElement.lua
-- *  PURPOSE:     MTAElement class
-- *
-- ****************************************************************************
MTAElement = inherit(Object)
registerElementClass("ped", MTAElement)
registerElementClass("object", MTAElement)
registerElementClass("pickup", MTAElement)
registerElementClass("marker", MTAElement)
registerElementClass("colshape", MTAElement)

function MTAElement:constructor()
	self.m_Data = {}
end

function MTAElement:virtual_constructor()
	MTAElement.constructor(self)
end

function MTAElement:setData(key, value, sync)
	self.m_Data[key] = value
	
	if sync then
		setElementData(self, key, value)
	end
end

function MTAElement:getData(key)
	return self.m_Data[key]
end

function MTAElement:setDimension(dimension)
	setElementDimension(self, dimension)
end

function MTAElement:setInterior(interior, x, y, z)
	setElementInterior(self, interior, x, y, z)
end