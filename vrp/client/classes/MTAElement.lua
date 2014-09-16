MTAElement = inherit(Object)
registerElementClass(MTAElement, "ped")
registerElementClass(MTAElement, "object")
registerElementClass(MTAElement, "pickup")
registerElementClass(MTAElement, "marker")
registerElementClass(MTAElement, "colshape")

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
