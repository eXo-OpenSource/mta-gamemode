MapParser = inherit(Object)

local readFuncs = {
	object = function(attributes)
		return {type = "object", model = tonumber(attributes.model), x = tonumber(attributes.posX), y = tonumber(attributes.posY), z = tonumber(attributes.posZ),
			rx = tonumber(attributes.rotX), ry = tonumber(attributes.rotY), rz = tonumber(attributes.rotZ), doublesided = toboolean(attributes.doublesided)}
	end;
}
local createFuncs = {
	object = function(info)
		local o = createObject(info.model, info.x, info.y, info.z, info.rx, info.ry, info.rz)
		setElementDoubleSided(o, info.doublesided or false)
		return o
	end;
}

function MapParser:constructor(path)
	self.m_MapData = {}
	self.m_Maps = {}
	
	local xmlRoot = xmlLoadFile(path)
	for k, node in pairs(xmlNodeGetChildren(xmlRoot)) do
		local nodeName = xmlNodeGetName(node)
		if readFuncs[nodeName] then
			table.insert(self.m_MapData, readFuncs[nodeName](xmlNodeGetAttributes(node)))
		end
	end
end

function MapParser:create(dimension)
	dimension = dimension or 0
	
	local map = {}
	for k, info in pairs(self.m_MapData) do
		local element = createFuncs[info.type](info)
		setElementDimension(element, dimension)
		table.insert(map, element)
	end
	
	table.insert(self.m_Maps, map)
	return #self.m_Maps
end

function MapParser:destroy(index)
	assert(self.m_Maps[index])
	
	for k, element in pairs(self.m_Maps[index]) do
		destroyElement(element)
	end
	table.remove(self.m_Maps, index)
end
