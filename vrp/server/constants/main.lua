-- Dirty way to set globals i guess
--[[
if fileExists(':vrp/server/config/config.json') then
  local file = fileOpen(':vrp/server/config/config.json', true)
  local data = fileRead(file, fileGetSize(file))
  data = fromJSON(data)

  MYSQL_CONFIG = data['mysql']

else
  outputDebugString("Trump did this to us")
  -- Even dirtier way to prevent running without config
  -- shutdown('No config no server')
end
]]
API_URL = "http://v-roleplay.net/forum/wcf/lib/data/vrp/api/api.php?"
IS_TESTSERVER = getServerName():find("Script") ~= nil
PERFORMANCE_HOOK_TRIGGER_PERCENT = 20 -- everything that has a higher percentage on lua timiing gets sent to slack
PERFORMANCE_HOOK_TRIGGER_PERCENT_FUNC = 1 -- every function that has a higher percentage on lua timiing gets sent to slack

CHAT_WHISPER_RANGE = 2.5
CHAT_TALK_RANGE = 10
CHAT_SCREAM_RANGE = 30
CHAT_DISTRICT_RANGE = 50

CheatSeverity = {Low = 1, Middle = 2, High = 3, Brutal = 4}

NOOB_SPAWN = Vector3(1481.07, -1764.84, 18.80)
NOOB_SKIN = 78

START_MONEY_BAR = 5000

Interiors = {
    -- Name -- Dimension ("Allocate" a block of dimensions)
    AmmuNation1 = 50000,
    AmmuNation2 = 50001,
}

BankAccountTypes = {
  Player = 1;
  Faction = 2;
  Company = 3;
  Admin = 4;
  Server = 5;
  Shop = 6;
  House = 7;
  Group = 8;
  VehicleShop = 9;
}

USER_GROUP_TYPES = {
	Faction = 1;
	Company = 2;
	Group = 3;
}

AFK_POSITIONS = {
	Vector2(435.701171875, -81.822265625),
	Vector2(460.5546875, -85.5390625),
	Vector2(458.5517578125, -85.5029296875),
	Vector2(453.8857421875, -85.578125),
	Vector2(455.205078125, -85.4189453125),
	Vector2(455.794921875, -82.3564453125),
	Vector2(454.373046875, -82.2666015625),
	Vector2(452.2412109375, -84.7158203125),
	Vector2(450.8154296875, -85.2353515625),
	Vector2(449.4658203125, -85.1494140625),
	Vector2(447.8525390625, -85.046875),
	Vector2(445.78515625, -84.916015625),
	Vector2(444.3955078125, -84.8271484375),
	Vector2(443.66796875, -84.166015625),
	Vector2(443.771484375, -82.5322265625),
	Vector2(444.2373046875, -81.37109375),
	Vector2(445.3369140625, -81.44140625),
	Vector2(446.4755859375, -81.513671875),
	Vector2(448.0166015625, -81.611328125),
	Vector2(449.4873046875, -81.705078125),
	Vector2(450.572265625, -81.7744140625),
	Vector2(451.421875, -81.5986328125),
	Vector2(451.529296875, -79.9130859375),
	Vector2(450.6669921875, -79.564453125),
	Vector2(448.9091796875, -79.4521484375),
	Vector2(447.6455078125, -79.3720703125),
	Vector2(442.1015625, -82.0595703125),
	Vector2(440.7900390625, -82.14453125),
	Vector2(439.80078125, -81.220703125),
	Vector2(438.33984375, -81.1142578125),
	Vector2(436.7880859375, -81.2685546875),
	Vector2(436.677734375, -82.6376953125),
	Vector2(436.83984375, -84.267578125),
	Vector2(436.9501953125, -85.37890625),
	Vector2(439.37109375, -84.9228515625),
	Vector2(439.5166015625, -83.5263671875),
	Vector2(441.0458984375, -86.7060546875),
	Vector2(444.7568359375, -86.8828125),
	Vector2(449.890625, -87.5380859375),
	Vector2(449.861328125, -86.4619140625),
	Vector2(449.302734375, -86.08203125),
	Vector2(448.921875, -85.4658203125),
	Vector2(448.8740234375, -84.2822265625),
	Vector2(448.126953125, -83.833984375),
	Vector2(446.916015625, -83.8837890625),
	Vector2(445.8271484375, -83.9287109375),
	Vector2(444.7578125, -83.9716796875),
	Vector2(449.81640625, -83.6552734375),
	Vector2(451.9228515625, -83.6513671875),
	Vector2(452.708984375, -84.8583984375),
	Vector2(452.1357421875, -85.1845703125),
	Vector2(441.248046875, -85.46484375),
	Vector2(433.4052734375, -86.10546875),
	Vector2(433.478515625, -88.27734375),
	Vector2(435.087890625, -88.7861328125),
	Vector2(436.3271484375, -88.7353515625),
	Vector2(438.3701171875, -88.65234375),
	Vector2(440.04296875, -88.583984375),
	Vector2(442.09375, -88.5),
	Vector2(443.7734375, -88.498046875),
	Vector2(445.2744140625, -88.4375),
	Vector2(447.44921875, -88.431640625),
	Vector2(449.4912109375, -88.390625),
	Vector2(451.7255859375, -88.44140625),
	Vector2(452.8935546875, -88.3935546875),
	Vector2(454.853515625, -88.3134765625),
	Vector2(456.439453125, -88.2490234375),
	Vector2(457.1630859375, -88.2197265625),
	Vector2(458.787109375, -86.90234375)
}

BAIL_PRICES =
{
	[1] = 1200,
	[2] = 1600,
	[3] = 2000,
	[4] = 2400,
	[5] = 3000,
	[6] = 3500,
	[7] = 4000,
	[8] = 5000,
	[9] = 7000,
	[10] = 8000,
	[11] = 9000,
	[12] = 10000,
}

JAIL_COSTS =
{
	[1] = 500,
	[2] = 1000,
	[3] = 1500,
	[4] = 2000,
	[5] = 2500,
	[6] = 3000,
	[7] = 3500,
	[8] = 4000,
	[9] = 5000,
	[10] = 6000,
	[11] = 7000,
	[12] = 8000,
}

JAIL_TIME_PER_WANTED_BAIL = 3
JAIL_TIME_PER_WANTED_ARREST = 3
JAIL_TIME_PER_WANTED_KILL = 4
JAIL_TIME_PER_WANTED_OFFLINE = 5

CHAT_MSG_REPEAT_COOLDOWN = 500 -- cooldown for different chat messages
CHAT_SAME_MSG_REPEAT_COOLDOWN = 3000 -- cooldown for same chat messages

RESOURCES_TO_STOP = {
    "scoreboard";
    "helpmanager";
}

JobBoxerMoney = {
    75,
    185,
    325,
    450,
    700
}


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
for index, data in ipairs(HOUSE_INTERIOR_TABLE) do 
	local path = ("%sinterior-%s%s"):format(STATIC_INTERIOR_MAP_PATH, index, ".map")
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
DYANMIC_INTERIOR_SERVER_OWNER = 0
DYNAMIC_INTERIOR_SERVER_OWNER_TYPE = 0