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


-- 0 = Nomen, 1 = Verb, 2 = Adjektiv
SKRIBBLE_WORDS = {
	{"Affe", 0},
	{"Banane", 0},
	{"Monitor", 0},
	{"Katze", 0},
	{"Hund", 0},
	{"Kuh", 0},
	{"Esel", 0},
	{"Kamel", 0},
	{"Bier", 0},
	{"Strand", 0},
	{"Sonne", 0},
	{"Radio", 0},
	{"Toaster", 0},
	{"Tastatur", 0},
	{"Waffe", 0},
	{"Maus", 0},
	{"Elefant", 0},
	{"Pizza", 0},
	{"Eis", 0},
	{"Eiffelturm", 0},
	{"Palme", 0},
	{"Bergspitze", 0},
	{"Bus", 0},
	{"Verkehr", 0},
	{"Straße", 0},
	{"Lastwagen", 0},
	{"Sonnenbrille", 0},
	{"Basketball", 0},
	{"Tennisschläger", 0},
	{"Fußballtor", 0},
	{"Flaschenöffner", 0},
	{"Korkenzieher", 0},
	{"Weinglas", 0},
	{"Bauernhaus", 0},
	{"Knast", 0},
	{"Erdbeere", 0},
	{"Kirsche", 0},
	{"Apfel", 0},
	{"Bonbon", 0},
	{"Birne", 0},
	{"Banane", 0},
	{"Spinne", 0},
	{"Spinnennetz", 0},
	{"Totenschädel", 0},
	{"Kürbis", 0},
	{"Hut", 0},
	{"Arm", 0},
	{"Ellenbogen", 0},
	{"Mittelfinger", 0},
	{"Taille", 0},
	{"Biene", 0},
	{"Europa", 0},
	{"Afrika", 0},
	{"Kaffeetasse", 0},
	{"Teekanne", 0},
	{"Korb", 0},
	{"Flughafen", 0},
	{"Hangar", 0},
	{"Flugzeugträger", 0},
	{"Geländewagen", 0},
	{"Blume", 0},
	{"Garten", 0},
	{"Wunde", 0},
	{"Mikrofon", 0},
	{"Gehirn", 0},
	{"Klarinette", 0},
	{"Gitarre", 0},
	{"Kompass", 0},
	{"Landkarte", 0},
	{"Segelschiff", 0},
	{"Flugzeug", 0},
	{"Panzer", 0},
	{"Grafikkarte", 0},
	{"Mainboard", 0},
	{"Drucker", 0},
	{"Taschenrechner", 0},
	{"Schlüsselloch", 0},
	{"Hamsterrad", 0},
	{"Papagei", 0},
	{"Tannenbaum", 0},
	{"Weihnachtsmann", 0},
	{"Schneemann", 0},
	{"Gitarre", 0},
	{"Klavier", 0},
	{"Hase", 0},
	{"Igel", 0},
	{"Maus", 0},
	{"Steckdose", 0},
	{"Glühbirne", 0},
	{"Headset", 0},
	{"Besteck", 0},
	{"Mülltonne", 0},
	{"Gurke", 0},
	{"Mistgabel", 0},
	{"Traktor", 0},
	{"Rosenstrauß", 0},
	{"Gamepad", 0},
	{"Spielkonsole", 0},
	{"Fluss", 0},
	{"UFO", 0},
	{"Hydrant", 0},
	{"Hut", 0},
	{"Cowboy", 0},
	{"Prostituierte", 0},
	{"Straßenstrich", 0},
	{"Golfschläger", 0},
	{"Hockeyschläger", 0},
	{"Minigolf", 0},
	{"Muschel", 0},

	{"laufen", 1},
	{"gehen", 1},
	{"spielen", 1},
	{"singen", 1},
	{"tanzen", 1},
	{"denken", 1},
	{"beobachten", 1},

	{"schnell", 2},
	{"hässlich", 2},
	{"durstig", 2},
	{"betrunken", 2},
	{"treffen", 2},

}
