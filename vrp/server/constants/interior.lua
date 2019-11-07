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

INTERIOR_OWNER_TYPES = 
{
	SERVER = 0,
	HOUSE = 1,
	SHOP = 2,
	FACTION = 3, 
	COMPANY = 4,
	GROUP = 5, 
}