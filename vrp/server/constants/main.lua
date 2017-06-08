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

CHAT_WHISPER_RANGE = 2.5
CHAT_TALK_RANGE = 10
CHAT_SCREAM_RANGE = 30
CHAT_DISTRICT_RANGE = 50

CheatSeverity = {Low = 1, Middle = 2, High = 3, Brutal = 4}

NOOB_SPAWN = Vector3(1798.417, -1303.119, 120.255)
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
	[2] = 2000,
	[3] = 2400,
	[4] = 3000,
	[5] = 3600,
	[6] = 4500,
}

JAIL_COSTS =
{
	[1] = 500,
	[2] = 1000,
	[3] = 1500,
	[4] = 2500,
	[5] = 3500,
	[6] = 4500,
}

RESOURCES_TO_STOP = {
    "scoreboard";
    "helpmanager";
}

setWeaponProperty(24,"pro","target_range",45)
setWeaponProperty(24,"poor","target_range",45)
setWeaponProperty(24,"std","target_range",45)

setWeaponProperty(24,"pro","weapon_range",45)
setWeaponProperty(24,"poor","weapon_range",45)
setWeaponProperty(24,"std","weapon_range",45)

setWeaponProperty(24,"pro","accuracy",1.5)
setWeaponProperty(24,"poor","accuracy",1.5)
setWeaponProperty(24,"std","accuracy",1.5)

setWeaponProperty(28,"poor", "accuracy",1.1000000238419)
setWeaponProperty(28,"pro", "accuracy",1.1000000238419)
setWeaponProperty(28,"std", "accuracy",1.1000000238419)

setWeaponProperty(29,"pro","accuracy",0.9)
setWeaponProperty(29,"poor","accuracy",0.9)
setWeaponProperty(29,"std","accuracy",0.9)

setWeaponProperty(31,"pro","accuracy",0.8)
setWeaponProperty(31,"poor","accuracy",0.8)
setWeaponProperty(31,"std","accuracy",0.8)

setWeaponProperty(31,"pro","weapon_range",105)
setWeaponProperty(31,"poor","weapon_range",105)
setWeaponProperty(31,"std", "weapon_range",105)

setWeaponProperty(32,"pro","weapon_range",50)
setWeaponProperty(32,"poor","weapon_range",50)
setWeaponProperty(32,"std", "weapon_range",50)

setWeaponProperty(32,"pro","target_range",50)
setWeaponProperty(32,"poor","target_range",50)
setWeaponProperty(32,"std", "target_range",50)

setWeaponProperty(32,"poor", "accuracy",1.1999999523163)
setWeaponProperty(32,"pro", "accuracy",1.1999999523163)
setWeaponProperty(32,"std", "accuracy",1.1999999523163)

setWeaponProperty(33,"pro","weapon_range",160)
setWeaponProperty(33,"poor","weapon_range",160)
setWeaponProperty(33,"std","weapon_range",160)

setWeaponProperty(33,"pro","target_range",160)
setWeaponProperty(33,"poor","target_range",160)
setWeaponProperty(33,"std","target_range",160)
