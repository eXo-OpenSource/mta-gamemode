STATIC_INTERIOR_MAP_PATH = "files/maps/static-interior/"
DYNAMIC_INTERIOR_MAP_PATH = "files/maps/dynamic-interior/"
DYNAMIC_INTERIOR_NOT_FOUND = "Map nicht gefunden!"
DYNAMIC_INTERIOR_SUCCESS = "Aktiv!"
DYNAMIC_INTERIOR_ERROR_MAP = "Map nicht erstellt!"
DYNAMIC_INTERIOR_INFO_ENTRANCE = "Map besitzt keinen Eingang!"
DYNAMIC_INTERIOR_DUMMY_DIMENSION = PRIVATE_DIMENSION_SERVER
DYNAMIC_INTERIOR_EDGE_TOLERANCE = 300
DYNAMIC_INTERIOR_HEIGHT_TOLERANCE = 100
DYNAMIC_INTERIOR_GRID_START_Z = 2000
DYNAMIC_INTERIOR_GRID_START_X = -3000
DYNAMIC_INTERIOR_GRID_START_Y = -3000
DYNAMIC_INTERIOR_GRID_END_X = 3000
DYNAMIC_INTERIOR_GRID_END_Y = 3000
DYNAMIC_INTERIOR_MAX_DIMENSION = DYNAMIC_INTERIOR_DUMMY_DIMENSION - 1
DYNAMIC_INTERIOR_GRID_START_INTERIOR = 20 
DYNAMIC_INTERIOR_GRID_START_DIMENSION = 1 
DYNAMIC_INTERIOR_ENTRANCE_CREATE_FUNC = createMarker
DYNAMIC_INTERIOR_ENTRANCE_OBJECT = "marker"
DYNAMIC_INTERIOR_ENTRANCE_OBJECT_TYPE = "cylinder"
DYANMIC_INTERIOR_PLACE_MODES = 
{
	FIND_BEST_PLACE = 1,  -- this mode moves the interior to the best place position
	KEEP_POSITION = 2,  -- this mode keeps the interiors position and generates one map in every dimension
	KEEP_POSITION_ONE_DIMENSION = 3,  -- this mode keeps the interiors position but only generates it for one dimension
	MANUAL_INPUT = 4 -- this leaves the positioning up to external methods
}
DYNAMIC_INTERIOR_TEMPORARY_ID = 0
STATIC_INTERIOR_ID_TO_PATH = {}
STATIC_INTERIOR_SHOP_ID_TO_PATH = {}
DYANMIC_INTERIOR_SERVER_OWNER = 0
DYNAMIC_INTERIOR_SERVER_OWNER_TYPE = 0


for index, data in ipairs(HOUSE_INTERIOR_TABLE) do 
	local path = ("%s/house/interior-%s%s"):format(STATIC_INTERIOR_MAP_PATH, index, ".map")
	local rootNode = xmlCreateFile(path,"map")
	local childNode = xmlCreateChild(rootNode, "marker")
	xmlNodeSetAttribute(childNode, "type", "cylinder")
	xmlNodeSetAttribute(childNode, "id", "entrance")
	xmlNodeSetAttribute(childNode, "color", "#0000ffff") 
	xmlNodeSetAttribute(childNode, "size", "1")
	xmlNodeSetAttribute(childNode, "dimension", "0") 
	xmlNodeSetAttribute(childNode, "alpha", "255")
	xmlNodeSetAttribute(childNode, "interior", data[1]) 	
	xmlNodeSetAttribute(childNode, "posX", data[2]) 
	xmlNodeSetAttribute(childNode, "posY", data[3])
	xmlNodeSetAttribute(childNode, "posZ", data[4]) 	
	xmlSaveFile(rootNode)
	xmlUnloadFile(rootNode)
	STATIC_INTERIOR_ID_TO_PATH[index] = path
end

function coordinateToMap(path, data) 

	local rootNode = xmlCreateFile(path,"map")
	local childNode = xmlCreateChild(rootNode, "marker")
	xmlNodeSetAttribute(childNode, "type", "cylinder")
	xmlNodeSetAttribute(childNode, "id", "entrance")
	xmlNodeSetAttribute(childNode, "color", "#0000ffff") 
	xmlNodeSetAttribute(childNode, "size", "1")
	xmlNodeSetAttribute(childNode, "dimension", "0") 
	xmlNodeSetAttribute(childNode, "alpha", "255")
	xmlNodeSetAttribute(childNode, "interior", data.interior) 	
	xmlNodeSetAttribute(childNode, "posX", data.position.x) 
	xmlNodeSetAttribute(childNode, "posY", data.position.y)
	xmlNodeSetAttribute(childNode, "posZ", data.position.z) 	
	xmlSaveFile(rootNode)
	xmlUnloadFile(rootNode)
	return path
end

local path = ("%s/faction/default.map"):format(STATIC_INTERIOR_MAP_PATH)
local rootNode = xmlCreateFile(path,"map")

local intFactionData = {
	{351, 2818, -1173.6, 1025.6, 80, 340, 0},
	{348, 2813.6001, -1166.8, 1025.64, 90, 0, 332},
	{3016, 2820.3999, -1167.7, 1025.7, 0, 0, 18},
	{1271, 2818.69995, -1167.30005, 1025.4, 0, 0, 314},
	{1271, 2818.19995, -1166.80005, 1024.699, 0, 0, 314},
	{1271, 2818.2, -1166.8, 1025.4, 0, 0, 312},
	{1271, 2818.7, -1167.3, 1024.7, 0, 0, 313.995},
	{1271, 2819.2, -1167.8, 1024.7, 0, 0, 314.495},
	{1271, 2819.2, -1167.8, 1025.4, 0, 0, 315.25},
	{2041, 2819.1001, -1165.2, 1025.9, 0, 0, 10},
	{2042, 2818.3, -1166.8, 1025.8},
	{2359, 2817.7, -1165.1, 1025.9, 0, 0, 348},
	{2358, 2820.2, -1165.1, 1024.7 },
	{2358, 2820.19995, -1165.09998, 1024.9, 0, 0, 354},
	{2358, 2820.2, -1165.1, 1025.1, 0, 0, 10},
	{2358, 2820.2, -1165.1, 1025.3},
	{2358, 2820.2, -1165.1, 1025.5, 0, 0, 348},
	{349, 2818.8999, -1167.7, 1025.8, 90, 0, 0},
	{349, 2818.8999, -1167.7, 1025.8, 90, 0, 0},
	{2977, 2819.3, -1170.6, 1024.4, 0, 0, 30.5},
	{2332, 2814.6001, -1173.8, 1026.6, 0, 0, 180}
}

for index, data in pairs(intFactionData) do 
	local childNode = xmlCreateChild(rootNode, "object")
	xmlNodeSetAttribute(childNode, "id", ("object %s"):format(index))
	xmlNodeSetAttribute(childNode, "dimension", "0") 
	xmlNodeSetAttribute(childNode, "model", data[1]) 	
	xmlNodeSetAttribute(childNode, "posX", data[2]) 
	xmlNodeSetAttribute(childNode, "posY", data[3])
	xmlNodeSetAttribute(childNode, "posZ", data[4])
	xmlNodeSetAttribute(childNode, "rotX", data[5]) 
	xmlNodeSetAttribute(childNode, "rotY", data[6]) 
	xmlNodeSetAttribute(childNode, "rotZ", data[7])  
	xmlNodeSetAttribute(childNode, "interior", 8) 		
end

local childNode = xmlCreateChild(rootNode, "marker")
xmlNodeSetAttribute(childNode, "type", "cylinder")
xmlNodeSetAttribute(childNode, "id", "entrance")
xmlNodeSetAttribute(childNode, "color", "#0000ffff") 
xmlNodeSetAttribute(childNode, "size", "1")
xmlNodeSetAttribute(childNode, "dimension", "0") 
xmlNodeSetAttribute(childNode, "alpha", "255")
xmlNodeSetAttribute(childNode, "interior", 8) 	
xmlNodeSetAttribute(childNode, "posX", 2807.66) 
xmlNodeSetAttribute(childNode, "posY", -1174.34)
xmlNodeSetAttribute(childNode, "posZ", 1025.57+.5) 	

local childNode = xmlCreateChild(rootNode, "ped") -- default faction ped
xmlNodeSetAttribute(childNode, "model", 200) 	
xmlNodeSetAttribute(childNode, "id", "faction-ped")
xmlNodeSetAttribute(childNode, "dimension", "0") 
xmlNodeSetAttribute(childNode, "interior", 8) 	
xmlNodeSetAttribute(childNode, "posX", 2819.20) 
xmlNodeSetAttribute(childNode, "posY", -1166.77)
xmlNodeSetAttribute(childNode, "posZ", 1025.58) 	
xmlNodeSetAttribute(childNode, "rotX", 0) 
xmlNodeSetAttribute(childNode, "rotY", 0) 
xmlNodeSetAttribute(childNode, "rotZ", 133.63)  


local childNode = xmlCreateChild(rootNode, "object") -- default item-depot
xmlNodeSetAttribute(childNode, "id", "item-depot")
xmlNodeSetAttribute(childNode, "model", 2972) 	
xmlNodeSetAttribute(childNode, "dimension", "0") 
xmlNodeSetAttribute(childNode, "interior", 8) 	
xmlNodeSetAttribute(childNode, "posX", 2816.8) 
xmlNodeSetAttribute(childNode, "posY", -1173.5)
xmlNodeSetAttribute(childNode, "posZ", 1024.4) 	
xmlNodeSetAttribute(childNode, "rotX", 0) 
xmlNodeSetAttribute(childNode, "rotY", 0) 
xmlNodeSetAttribute(childNode, "rotZ", 0)  

local childNode = xmlCreateChild(rootNode, "object") -- default equipment-depot
xmlNodeSetAttribute(childNode, "id", "item-equipment")
xmlNodeSetAttribute(childNode, "dimension", "0") 
xmlNodeSetAttribute(childNode, "model", 964) 	
xmlNodeSetAttribute(childNode, "interior", 8) 	
xmlNodeSetAttribute(childNode, "posX", 2819.84) 
xmlNodeSetAttribute(childNode, "posY", -1173.51)
xmlNodeSetAttribute(childNode, "posZ", 1024.4) 	
xmlNodeSetAttribute(childNode, "rotX", 0) 
xmlNodeSetAttribute(childNode, "rotY", 0) 
xmlNodeSetAttribute(childNode, "rotZ", 0)  


xmlSaveFile(rootNode)
xmlUnloadFile(rootNode)


INTERIOR_OWNER_TYPES = 
{
	SERVER = 0,
	HOUSE = 1,
	SHOP = 2,
	FACTION = 3, 
	COMPANY = 4,
	GROUP = 5, 
}

