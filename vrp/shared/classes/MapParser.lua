MapParser = inherit(Object)

local readFuncs = {
	object = function(attributes)
		return {type = "object", model = tonumber(attributes.model), x = tonumber(attributes.posX), y = tonumber(attributes.posY), z = tonumber(attributes.posZ),
			rx = tonumber(attributes.rotX), ry = tonumber(attributes.rotY), rz = tonumber(attributes.rotZ), interior = tonumber(attributes.interior), doublesided = toboolean(attributes.doublesided),
			alpha = tonumber(attributes.alpha), scale = tonumber(attributes.scale), collisions = attributes.collisions}
	end;
	marker = function(attributes)
		return {type = "marker", markertype = attributes.type, x = tonumber(attributes.posX), y = tonumber(attributes.posY), z = tonumber(attributes.posZ),
			size = tonumber(attributes.size), color = attributes.color}
	end;
	removeWorldObject = function(attributes)
		return {type = "removeWorldObject", radius = tonumber(attributes.radius), model = tonumber(attributes.model), lodModel = tonumber(attributes.lodModel),
			posX = tonumber(attributes.posX), posY = tonumber(attributes.posY), posZ = tonumber(attributes.posZ), interior = tonumber(attributes.interior)}
	end;
	spawnpoint = function(attributes)
		return {type = "spawnpoint", model = tonumber(attributes.vehicle), x = tonumber(attributes.posX), y = tonumber(attributes.posY), z = tonumber(attributes.posZ),
			rx = tonumber(attributes.rotX), ry = tonumber(attributes.rotY), rz = tonumber(attributes.rotZ) or tonumber(attributes.rotation)}
	end;
	racepickup = function(attr)
		return {type = "racepickup", pickuptype = attr.type, x = tonumber(attr.posX), y = tonumber(attr.posY), z = tonumber(attr.posZ),
			rx = tonumber(attr.rotX), ry = tonumber(attr.rotY), rz = tonumber(attr.rotZ), model = tonumber(attr.vehicle)}
	end;
	checkpoint = function(attributes)
		return {type = "checkpoint", checkpointType = attributes.type, x = tonumber(attributes.posX), y = tonumber(attributes.posY), z = tonumber(attributes.posZ), size = tonumber(attributes.size)}
	end;
	startmarker = function(attributes)
		return {type="startmarker", x = tonumber(attributes.posX), y = tonumber(attributes.posY), z = tonumber(attributes.posZ)}
	end;
	info = function(attributes)
		return {type="infoPed", model = tonumber(attributes.model), x = tonumber(attributes.posX), y = tonumber(attributes.posY), z = tonumber(attributes.posZ),
			rx = tonumber(attributes.rotX), ry = tonumber(attributes.rotY), rz = tonumber(attributes.rotZ), respawn = toboolean(attributes.Respawn)}
	end;
}
local createFuncs = {
	object = function(info)
		local o = createObject(info.model, info.x, info.y, info.z, info.rx, info.ry, info.rz)
		setElementDoubleSided(o, info.doublesided or false)
		setElementAlpha(o, info.alpha or 255)
		setObjectScale(o, info.scale or 1)
		setElementCollisionsEnabled(o, info.collisions ~= "false")
		return o
	end;
	marker = function(info)
		local m = createMarker(info.x, info.y, info.z, info.markertype, info.size, getColorFromString(info.color))
		return m
	end;
	checkpoint = function(info)
		local m = createMarker(info.x, info.y, info.z, "cylinder", info.size, 0, 0, 0, 0)
		m.checkpointType = info.checkpointType
		return m
	end;
	removeWorldObject = function(info)
		removeWorldModel(info.model, info.radius, info.posX, info.posY, info.posZ, info.interior)
		removeWorldModel(info.lodModel, info.radius, info.posX, info.posY, info.posZ, info.interior)
		return info
	end;
	spawnpoint = function(info) return info end;
	startmarker = function(info) return info end;
	infoPed = function(info) return info end;
	racepickup = function(info)
		local model, func
		if info.pickuptype == "nitro" then
			model = 2839
			func = function(vehicle) addVehicleUpgrade(vehicle, 1010) end
		elseif info.pickuptype == "vehiclechange" then
			model = 2838
			func = function(vehicle) setElementModel(vehicle, info.model) end
		else
			model = 2837
			func = function(vehicle) vehicle:fix() end
		end

		local colsphere = createColSphere(info.x, info.y, info.z, 3.5)
		local pickup = createPickup(info.x, info.y, info.z, 3, model, 0)
		addEventHandler(SERVER and "onColShapeHit" or "onClientColShapeHit", colsphere, function(hitElement)
			if getElementType(hitElement) ~= "player" then return end
			local vehicle = getPedOccupiedVehicle(hitElement)
			if vehicle then func(vehicle) end
		end)
		if info.pickuptype == "vehiclechange" then pickup.targetModel = info.model end
		setElementParent(colsphere, pickup)
		return pickup
	end;
}

function MapParser:constructor(path, skip)
	self.m_MapData = {}
	self.m_Maps = {}

	if skip then return end

	local xmlRoot = xmlLoadFile(path)
	local infoNode = xmlRoot:findChild("info", 0)
	if infoNode then
		self.m_Mapname = infoNode:getAttribute("Mapname")
		self.m_Author = infoNode:getAttribute("Author")
	end

	for k, node in pairs(xmlNodeGetChildren(xmlRoot)) do
		local nodeName = xmlNodeGetName(node)
		if readFuncs[nodeName] then
			table.insert(self.m_MapData, readFuncs[nodeName](xmlNodeGetAttributes(node)))
		end
	end

	xmlUnloadFile(xmlRoot)
end

function MapParser:destructor()
	for k, map in pairs(self.m_Maps) do
		self:destroy(k)
	end
end

function MapParser:create(dimension)
	dimension = dimension or 0

	local map = {}
	for k, info in pairs(self.m_MapData) do
		local element = createFuncs[info.type](info)
		if isElement(element) then
			element._type = info.type
			setElementDimension(element, dimension)
		end
		table.insert(map, element)
	end

	table.insert(self.m_Maps, map)
	return #self.m_Maps
end

function MapParser:destroy(index)
	assert(self.m_Maps[index])

	for k, element in pairs(self.m_Maps[index]) do
		if isElement(element) then
			destroyElement(element)
		elseif type(element) == "table" then -- that's a small hack
			-- do not uncomment the following!!!
			--restoreWorldModel(info.model, info.radius, info.posX, info.posY, info.posZ, info.interior)
			--restoreWorldModel(info.lodModel, info.radius, info.posX, info.posY, info.posZ, info.interior)
		end
	end
	table.remove(self.m_Maps, index)
end

function MapParser:getElements(mapIndex)
	return self.m_Maps[mapIndex or 1]
end

function MapParser:getElementsByType(elementType, mapIndex)
	local elements = {}
	for k, element in pairs(self.m_Maps[mapIndex or 1]) do
		if element.type == elementType or (element._type and element._type == elementType) then
			table.insert(elements, element)
		end
	end

	return elements
end

function MapParser:getElementsByTypeFromData(elementType)
	local elements = {}
	for _, info in pairs(self.m_MapData) do
		if info.type == elementType then
			table.insert(elements, info)
		end
	end

	return elements
end

function MapParser:getMapName()
	return self.m_Mapname
end

function MapParser:getMapAuthor()
	return self.m_Author
end
