addEvent("interior_fix:onDimChange", true)
addEvent("interior_fix:onIntChange", true)
local client = {}
local last_int = -1
local resourceName = getResourceName(resource)
addEventHandler("interior_fix:onIntChange", localPlayer, function( int ) 
	parseIntMap( int )
end)


addEventHandler("interior_fix:onDimChange", localPlayer, function( dim ) 
	changeMapDim(dim)
end)  

function changeMapDim(dim)
	if client.m_ObjectsEntities then
		for i = 1, #client.m_ObjectsEntities do
			obj = client.m_ObjectsEntities[i]
			if obj and isElement(obj) then 
				setElementDimension(obj, dim)
			end
		end
	end
end

function parseIntMap(int)
	if int > 0 and last_int ~= int then
		deleteObjects()
		client.xmlRoot = xmlLoadFile(":"..resourceName.."/interior"..int..".xml")
		if client.xmlRoot then
			client.m_MapChildren = xmlNodeGetChildren( client.xmlRoot )
			client.m_xmlObjects = { }
			local i_iterator = 0 
			while ( xmlFindChild( client.xmlRoot, "object", i_iterator) ) do 
				table.insert( client.m_xmlObjects, xmlFindChild( client.xmlRoot, "object", i_iterator)  )
				i_iterator = i_iterator + 1
			end
			last_int = int
			createObjects()
		end
	elseif int == 0 then
		deleteObjects()
		last_int = 0
	end
end

function deleteObjects()
	if client.m_ObjectsEntities then
		local obj
		for i = 1, #client.m_ObjectsEntities do
			obj = client.m_ObjectsEntities[i]
			if obj and isElement(obj) then 
				destroyElement(obj)
			end
		end
		client.m_ObjectsEntities ={}
	end
end

function createObjects() 
	client.m_ObjectsEntities = {}
	local model, posX, posY, posZ, rotX, rotY, rotZ, interior, dimension, team, obj, scale, alpha
	dimension = getElementDimension(localPlayer)
	for key, obj in ipairs( client.m_xmlObjects ) do 
		model = xmlNodeGetAttribute(obj, "model")
		posX  = xmlNodeGetAttribute(obj, "posX")
		posY  = xmlNodeGetAttribute(obj, "posY")
		posZ  = xmlNodeGetAttribute(obj, "posZ")
		rotX = xmlNodeGetAttribute(obj, "rotX")
		rotY = xmlNodeGetAttribute(obj, "rotY")
		rotZ = xmlNodeGetAttribute(obj, "rotZ")
		scale = xmlNodeGetAttribute(obj, "scale")
		alpha = xmlNodeGetAttribute(obj, "alpha")
		interior = xmlNodeGetAttribute(obj, "interior")
		client.m_ObjectsEntities[#client.m_ObjectsEntities+1] = createObject(model, posX, posY, posZ, rotX, rotY, rotZ)
		setObjectScale(client.m_ObjectsEntities[#client.m_ObjectsEntities], tonumber(scale))
		setElementDimension(client.m_ObjectsEntities[#client.m_ObjectsEntities] , dimension )
		setElementAlpha(client.m_ObjectsEntities[#client.m_ObjectsEntities], alpha)
		setElementInterior(client.m_ObjectsEntities[#client.m_ObjectsEntities] , interior )
	end
end