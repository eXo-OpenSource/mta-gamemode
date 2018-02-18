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

function MTAElement:setData(key, value)
	self.m_Data[key] = value
end

function MTAElement:getData(key)
	return self.m_Data[key] or getElementData(self, key)
end

function MTAElement:setDimension(dimension)
	setElementDimension(self, dimension)
end

function MTAElement:setInterior(interior, x, y, z)
	setElementInterior(self, interior, x, y, z)
end