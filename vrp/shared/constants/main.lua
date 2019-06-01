PROJECT_NAME = "eXo Reallife"
PROJECT_VERSION = "1.8.1"

PRIVATE_DIMENSION_SERVER = 65535 -- This dimension should not be used for playing
PRIVATE_DIMENSION_CLIENT = 2 -- This dimension should be used for things which
							 -- happen while the player is in PRIVATE_DIMENSION on the server

INGAME_WEB_PATH = "https://ingame.exo-reallife.de"
PICUPLOAD_PATH = "https://picupload.pewx.de"

if DEBUG then
	INGAME_WEB_PATH = "https://ingame-dev.exo-reallife.de"
end

-- LEVELS
MAX_JOB_LEVEL = 10
MAX_WEAPON_LEVEL = 10
MAX_VEHICLE_LEVEL = 10
MAX_SKIN_LEVEL = 10
MAX_FISHING_LEVEL = 15

MAX_WANTED_LEVEL = 12

-- EVENTS:
EVENT_EASTER = false
EVENT_EASTER_SLOTMACHINES_ACTIVE = false
EVENT_HALLOWEEN = false
EVENT_CHRISTMAS = false --quests, mostly
EVENT_CHRISTMAS_MARKET = (EVENT_CHRISTMAS and getRealTime().monthday >= 6 and getRealTime().monthday <= 26) -- determines whether the christmas market is enabled at pershing square (shops, ferris wheel, wheels of fortune)
SNOW_SHADERS_ENABLED = true -- disable them during summer time
FIREWORK_ENABLED = true -- can users use firework ?
FIREWORK_SHOP_ACTIVE = false -- can users buy firework at the user meetup point`?

-- BONI:
PAYDAY_NOOB_BONUS = 500 -- dollar
PAYDAY_NOOB_BONUS_MAX_PLAYTIME = 50 -- hours

--TEXTURES:
TEXTURE_STATUS = {
	["Testing"] = 0,
	["Pending"] = 1,
	["Active"] = 2,
	["Declined"] = 3
}
local status = {}
for k, v in pairs(TEXTURE_STATUS) do
	status[k] = v
	status[v] = k
end
TEXTURE_STATUS = status

--ALCOHOL:
MAX_ALCOHOL_LEVEL = 6
ALCOHOL_LOSS_INTERVAL =  5*60 -- IN SECONDS
ALCOHOL_LOSS = 0.5 -- every 10 Minutes

--JOB_LEVELS:
JOB_LEVEL_PIZZA = 0
JOB_LEVEL_SWEEPER = 0
JOB_LEVEL_LOGISTICAN = 1
JOB_LEVEL_TRASHMAN = 2
JOB_LEVEL_TREASURESEEKER = 2
JOB_LEVEL_FORKLIFT = 3
JOB_LEVEL_LUMBERJACK = 3
JOB_LEVEL_HELITRANSPORT = 4
JOB_LEVEL_FARMER = 5
JOB_LEVEL_GRAVEL = 6
JOB_LEVEL_BOXER = 8

JOB_EXTRA_POINT_FACTOR = 1.5 -- point multiplicator for every job

BLIP_CATEGORY = {
	Default = "Allgemein",
	Shop = "Shops",
	Job = "Arbeitsstellen",
	Faction = "Fraktions-Basen",
	Company = "Unternehmenssitze",
	VehicleMaintenance = "Fahrzeug-Unterhaltung",
	Leisure = "Freizeit",
	Other = "Anderes",
}

BLIP_COLOR_CONSTANTS = {
	Red = {200, 0, 0},
	Orange = {255, 150, 0},
	Yellow = {200, 200, 0},
	Green = {20, 255, 50},
	Blue = {20, 70, 200},
}

BLIP_CATEGORY_ORDER = {
	BLIP_CATEGORY.Default, BLIP_CATEGORY.Job, BLIP_CATEGORY.Faction, BLIP_CATEGORY.Company, BLIP_CATEGORY.VehicleMaintenance, BLIP_CATEGORY.Shop, BLIP_CATEGORY.Leisure, BLIP_CATEGORY.Other
}

--USER RANKS:
RANK = {}
RANK[-1] = "Banned"
RANK[0] = "User"
RANK[1] = "Ticketsupporter"
RANK[2] = "Clanmember"
RANK[3] = "Supporter"
RANK[4] = "Moderator"
RANK[5] = "Administrator"
RANK[6] = "Servermanager"
RANK[7] = "Developer"
RANK[8] = "StellvProjektleiter"
RANK[9] = "Projektleiter"


local r2 = {}
for k, v in pairs(RANK) do
	r2[k] = v
	r2[v] = k
end
RANK = r2

--ADMIN PERMISSIONS:
ADMIN_RANK_PERMISSION = {

	--player punish
	["freeze"] = RANK.Supporter,
	["rkick"] = RANK.Supporter,
	["prison"] = RANK.Supporter,
	["offlinePrison"] = RANK.Supporter,
	["unprison"] = RANK.Moderator,
	["offlineUnPrison"] = RANK.Moderator,
	["warn"] = RANK.Supporter,
	["offlineWarn"] = RANK.Supporter,
	["removeWarn"] = RANK.Administrator,
	["removeOfflineWarn"] = RANK.Administrator,
	["timeban"] = RANK.Supporter,
	["permaban"] = RANK.Supporter,
	["offlineTimeban"] = RANK.Supporter,
	["offlinePermaban"] = RANK.Supporter,
	["offlineUnban"] = RANK.Administrator,
	["loginFix"] = RANK.Moderator,
	["vehicleMenu"] = RANK.Moderator,
	["syncForum"] = RANK.Supporter,
	--admin general
	["event"] = RANK.Moderator,
	["eventMoneyWithdraw"] = RANK.Moderator,
	["eventMoneyDeposit"] = RANK.Supporter,
	["vehicleTexture"] = RANK.Moderator,
	["spect"] = RANK.Supporter,
	["smode"] = RANK.Supporter,
	["adminAnnounce"] = RANK.Supporter,
	["clearchat"] = RANK.Supporter,
	["clearAd"] = RANK.Supporter,
	["supermanFly"] = RANK.Moderator, -- flying supporter
	["nickchange"] = RANK.Moderator,
	["offlineNickchange"] = RANK.Moderator,

	--group management
	["setFaction"] = RANK.Administrator,
	["setCompany"] = RANK.Administrator,
	["resetAction"] = RANK.Moderator,
	["playerHistory"] = RANK.Supporter,
	["respawnFaction"] = RANK.Supporter, -- respawn whole faction
	["respawnCompany"] = RANK.Supporter, -- respawn whole company

	--teleport
	["direction"] = RANK.Supporter, -- Up Down Left Right
	["mark"] = RANK.Supporter, -- also gotomark
	["gethere"] = RANK.Clanmember,
	["goto"] = RANK.Clanmember,
	["tp"] = RANK.Supporter,
	["gotocords"] = RANK.Supporter,

	--vehicle interaction
	["checkOverlappingVehicles"] = RANK.Administrator,
	["respawnRadius"] = RANK.Supporter,
	["showVehicles"] = RANK.Supporter,
	["showGroupVehicles"] = RANK.Supporter,
	["toggleVehicleHandbrake"] = RANK.Moderator,
	["respawnVehicle"] = RANK.Supporter, -- respawn per click
	["parkVehicle"] = RANK.Supporter, -- set spawn position
	["repairVehicle"] = RANK.Supporter, -- repair per click
	["despawnVehicle"] = RANK.Supporter, -- despawn
	["deleteVehicle"] = RANK.Administrator, -- permanently destroy vehicle
	["looseVehicleHandbrake"] = RANK.Supporter,
	["editVehicleGeneral"] = RANK.Administrator, -- this is used to just open the window itself
	["editVehicleModel"] = RANK.Administrator,
	["editVehicleOwnerType"] = RANK.Administrator,
	["editVehicleOwnerID"] = RANK.Administrator,
	["editVehicleTunings"] = RANK.Administrator,
	["editVehicleHandling"] = RANK.Administrator, -- handling editor
	["editVehicleTexture"] = RANK.Developer, --override textures without visiting the texture shop


	--development
	["cookie"] = RANK.Developer, -- give that man a cookie
	["showDebugElementView"] = RANK.Administrator, --F10 view
	["runString"] = RANK.Servermanager, --drun, dcrun, dpcrun
	["seeRunString"] = RANK.Moderator, --chat and console outputs from above

	--World Items (e.g. Barricade)
	["moveWorldItem"] 				= RANK.Supporter,
	["deleteWorldItem"] 			= RANK.Supporter,
	["showWorldItemInformation"] 	= RANK.Supporter,

	--server edit tools
	["editHouse"] = RANK.Administrator,
	["freeHouse"] = RANK.Administrator, -- free house from owner, tenants and house bank account money
	["pedMenu"] = RANK.Administrator,
	["fireMenu"] = RANK.Administrator,
	["eventGangwarMenu"] = RANK.Administrator,
	["transactionMenu"] = RANK.Administrator,

	--keypad-system
	["placeKeypadObjects"] = RANK.Administrator, -- ItemKeyPad, ItemEntrance, ItemDoor

	["disablereg"] = RANK.Servermanager --disablereg, enablereg
}

GroupRank = {
	Normal = 0,
	Rank1 = 1,
	Rank2 = 2,
	Rank3 = 3,
	Rank4 = 4,
	Manager = 5,
	Leader = 6
}

FactionRank = {
	Normal = 0,
	Rank3 = 3,
	Rank4 = 4,
	Manager = 5,
	Leader = 6
}

CompanyRank = {
	Normal = 0,
	Manager = 4,
	Leader = 5
}

OBJECT_DELETE_MIN_RANK = 4 -- faction/company/group rank to destroy WorldItems (i.e. not put them into their inventory)

local r3 = {}
for k, v in pairs(GroupRank) do
	r3[k] = v
	r3[v] = k
end
GroupRank = r3

Crime = {
	Kill = {id = 1, text = "Mord", maxwanted = 4, maxdistance = 1500},
	Hotwire = {id = 2, text = "Fahrzeug kurzgeschlossen", maxwanted = 2, maxdistance = 400},
	BankRobbery = {id = 3, text = "Banküberfall", maxwanted = 6, maxdistance = math.huge},
	JailBreak = {id = 4, text = "Gefängnisausbruch", maxwanted = 4, maxdistance = math.huge},
	PlacingBomb = {id = 5, text = "Legen einer Bombe", maxwanted = 6, maxdistance = 5000},
	HouseRob = {id = 6, text = "Einbruch", maxwanted = 3, maxdistance = math.huge},
	ShopRob = {id = 7, text = "Raubüberfall", maxwanted = 5, maxdistance = math.huge}
}

AmmuNationInfo = {
	[30] = { -- AK-47
		Magazine = {price=30,amount=30},
		Weapon = 1850
	},
	[31] = { -- M4A1
		Magazine = {price=60,amount=50},
		Weapon = 2500
	},
	[29] = { -- MP5
		Magazine = {price=40,amount=30},
		Weapon = 1000
	},
	[25] = { -- Shotgun
		Magazine = {price=2,amount=1},
		Weapon = 900
	},
	[33] = { -- Rifle
		Magazine = {price=4,amount=1},
		Weapon = 1250
	},
	[22] = { -- Pistol
		Magazine = {price=15,amount=17},
		Weapon = 450
	},
	[24] = { -- Desert Eagle
		Magazine = {price=7,amount=7},
		Weapon = 1150
	},
	[1] = { -- Brass Knuckles
		Weapon = 50
	},
	[0] = { -- Armor
		Weapon = 150
	},
}

DEFAULT_GANGAREA_RESOURCES = 500
SprayWallData = {
	{wallPosition = Vector3(2512.3999, -1683.4, 13.9), 	wallRotation = 129},
	{wallPosition = Vector3(2080.5, -1597.1, 13.8), 	wallRotation = 269.5},
	{wallPosition = Vector3(1758.7, -1938.9, 14), 		wallRotation = 0},
	{wallPosition = Vector3(1761.5, -1350.2, 16), 		wallRotation = 0},
	{wallPosition = Vector3(1913.1, -1361.5, 14), 		wallRotation = 267},
	{wallPosition = Vector3(1959.6, -1173.6, 20.4), 	wallRotation = 179.5},
	{wallPosition = Vector3(2215.5, -1173.9, 26.1), 	wallRotation = 89.75},
	{wallPosition = Vector3(2768.2, -1625, 11.3), 		wallRotation = 0},
	{wallPosition = Vector3(1237.9, -916.40002, 43.1), 	wallRotation = 280},
	{wallPosition = Vector3(382.70001, -1875.7, 8.2), 	wallRotation = 92},
	{wallPosition = Vector3(1065.2, -1617.6, 21.1), 	wallRotation = 0},
	{wallPosition = Vector3(474.60001, -1517.6, 20.8), 	wallRotation = 0},
	{wallPosition = Vector3(2808.8999, -1426.1, 40.5), 	wallRotation = 270.75},
	{wallPosition = Vector3(2822.2, -2383.2, 12.5), 	wallRotation = 180.25},
	{wallPosition = Vector3(2274.7, -68.9, 27), 		wallRotation = 0},
	{wallPosition = Vector3(731.29999, -1337.2, 13.9), 	wallRotation = 0},
	{wallPosition = Vector3(1084.5, -1219.5, 18.2), 	wallRotation = 0},
	{wallPosition = Vector3(2761.8999, -2015.6, 13.9), 	wallRotation = 0},
}

TURFING_STOPREASON_LEAVEAREA = 1
TURFING_STOPREASON_NEWOWNER = 2
TURFING_STOPREASON_DEFENDED = 3

SkinInfo = {
	-- skinId -- skinName -- skinPrice
	[0] = {"CJ", 5000},
	[2] = {"Weißer Hut", 50},
	[7] = {"Jeans-Jacke", 50},
	[14] = { "Hawai-Shirt", 50},
	[15] = { "Karriertes Hemd", 70},
	[17] = {"Buisiness", 120},
	[18] = {"Strandboy",20},
	[19] = {"Rapper", 50},
	[20] = {"Gelbes Shirt",90},
	[21] = {"Blau karriertes Hemd", 80},
	[22] = {"Rapper 2", 100},
	[23] = {"Skater", 50},
	[24] = {"Los Santos Jacke",60},
	[25] = {"College Jacke", 80},
	[26] = {"Camper", 100},
	[28] = {"Tank top",60},
	[29] = {"Hoodie",50},
	[30] = {"Tanktop Kreuz", 100},
	[32] = {"Augenklappe", 80},
	[33] = {"Trenchcoat", 100},
	[34] = {"Cowboy", 80},
	[35] = {"Anglerhut", 90},
	[36] = {"Baseball Cap",100},
	[37] = {"Baseball Cap2",90},
	[43] = {"Daddy cool",100},
	[46] = {"Weißes Hemd, Kette", 120},
	[47] = {"Grünes Hemd", 100},
	[48] = {"Blau weiß gestreift",90},
	[57] = { "Anzug ( Asiate )", 100},
	[58] = {"Zinkrot Hemd ( Asiate )", 80},
	[59] = {"Gestreiftes Hemd", 70},
	[60] = {"Pullover, Jeans", 90},
	[66] = {"College Jacke2", 80},
	[73] = {"Army jeans, Sandalen", 100},
	[94] = {"Golf Outfit", 90},
	[97] = {"Strand 2", 40},
	[98] = {"Polo-Hemd, jeans", 100},
	[100] = {"Biker", 130},
	[101] = {"Parker-Jacke", 120},
	[133] = {"Trucker, rote Cap", 140},
	[136] = {"Ganja-Mütze, rote jeans", 80},
	[142] = {"Festtagsgewand ( Afrikaner )", 100},
	[143] = {"Sonnenbrille, blaue jacke", 100},
	[144] = {"Maske, Afro", 120},
	[146] = {"Maske, Sandalen", 130},
	[147] = {"Business-Anzug, Grau",160},
	[154] = {"Strand3", 40},
	[158] = {"Cowboy 2", 60},
	[161] = {"Cowboy 3", 70},
	[170] = {"Roter Pullover", 90},
	[171] = {"Anzug, Fliege", 170},
	[177] = {"Frasier-Schnitt, blaues shirt", 90},
	[176] = {"Blaues Shirt", 120},
	[179] = {"Army tanktop, Dogtags", 90},
	[180] = {"Basketball-Shirt", 60},
	[184] = {"Blau weiß Schwarzes Shirt", 90},
	[206] = {"Olives Shirt", 100},

	[1] = {"Offenes Hemd", 50},
	[9] = {"Brauner Anzug", 120},
	[10] = {"Alte Dame", 50},
	[12] = {"Schwarzes Kleid", 120},
	[31] = {"Farmerin", 70},
	[38] = {"Golferin", 80},
	[39] = {"Alte Dame", 60},
	[40] = {"Roter Rock", 100},
	[41] = {"Trainingsanzug", 60},
	[45] = {"Grüne Badehose", 50},
	[53] = {"Golferin 2", 80},
	[55] = {"Gestreifter Rock", 80},
	[56] = {"Rock mit grünes Oberteil", 70},
	[62] = {"Opa in Schlafanzug", 50},
	[67] = {"Gangster mit weißen Oberteil", 70},
	[69] = {"Jeanshose, Jeansoberteil", 60},
	[72] = {"Trucker mit Bart", 60},
	[76] = {"Business Dame", 130},
	[88] = {"Alte Dame mit roten Oberteil", 60},
	[91] = {"Weißer Rock", 80},
	[95] = {"Armer Rentner", 90},
	[148] = {"Frau mit blauen Anzug", 120},
	[150] = {"Frau mit gestreifter Kleidung", 110},
	[157] = {"Bauerin", 60},
	[170] = {"Rotes T-Shirt", 70},
	[172] = {"Anzug, Fliege 2", 170},
	[182] = {"Rentner mit Bierbauch", 70},
	[185] = {"Gesteiftes Hemd mit schwarzer Hose", 90},
	[190] = {"Frau Bauchfrei", 80},
	[193] = {"Frau Bauchfrei 2", 80},
	[214] = {"Weißes Kleid", 120},
	[215] = {"Weiße Rose mit gelben Oberteil", 100},
	[223] = {"Gangster mit Goldkette", 120},
	[241] = {"Afro mit Bierbauch", 100},
	[249] = {"Zuhälter", 250},
	[250] = {"Mann mit grünes T-Shirt", 80},
	[258] = {"Kariertes Hemd", 100},
	[259] = {"Kariertes Hemd 2", 100},
	[261] = {"Trucker mit Bart 2", 60},
}

MAX_KARMA_LEVEL = 150

Tasks = {
	TASK_GUARD = 1,
	TASK_SHOOT_TARGET = 2,
	TASK_GETTING_TARGETTED = 3,
}

VehicleTypes = {
	Player = 1;
	Faction = 2;
	Company = 3;
	Group = 4;
}

VehicleTypeName = {
	[VehicleTypes.Player] = "player";
	[VehicleTypes.Faction] = "faction";
	[VehicleTypes.Company] = "company";
	[VehicleTypes.Group] = "group";
}

VehiclePositionType = {World = 0, Garage = 1, Mechanic = 2, Hangar = 3, Harbor = 4}
VehicleType = {Automobile = 0, Plane = 1, Bike = 2, Helicopter = 3, Boat = 4, Trailer = 5}
VehicleSpecial = {Soundvan = 1}
VEHICLE_TOTAL_LOSS_HEALTH = 260 -- below = total loss
NO_LICENSE_VEHICLES = {509, 481, 462, 510, 448}
TRUCK_MODELS =  {499, 609, 498, 524, 532, 578, 486, 406, 573, 455, 588, 403, 514, 423, 414, 443, 515, 531, 456, 433, 427, 407, 544, 432, 431, 437, 408}

GROUP_RENAME_TIMEOUT = 60*60*24*30 -- 30 Days (in seconds)
GROUP_RENAME_COSTS = 10000

GROUP_NAME_MIN = 5
GROUP_NAME_MAX = 24
GROUP_NAME_MATCH = "^[a-zA-Z0-9 _.-]*$"

GARAGE_UPGRADES_COSTS = {[1] = 200000, [2] = 250000, [3] = 500000}
HANGAR_UPGRADES_COSTS = {[1] = 9999999, [2] = 0, [3] = 0}
GARAGE_UPGRADES_TEXTS = {[0] = "Garage: keine Garage", [1] = "Garage: Standard Garage", [2] = "Garage: Komfortable Garage", [3] = "Garage: Luxus Garage"}
HANGAR_UPGRADES_TEXTS = {[0] = "Hangar: kein Hangar", [1] = "Hangar: Unkown Hangar", [2] = "Hangar: Unkown Hangar", [3] = "Hangar: Unkown Hangar"}

WEAPONTRUCK_MAX_LOAD = 60000 -- Dollars
EVIDENCETRUCK_MAX_LOAD = 60000 -- Dollars
STATE_EVIDENCE_MAX_OBJECTS = 100000 -- dollars
STATE_EVIDENCE_MAX_CLIPS = 50
STATE_EVIDENCE_OBJECT_PRICE = {
	Waffe = 1, -- * weapon cost
	Munition = 1, -- * munition cost
	Item = 10
}


PlayerAttachObjects = {
	[1550] = {model = 1550, name = "Geldsack", pos = Vector3(0, -0.2, 0), rot = Vector3(0, 0, 180), blockJump = true, bone = 3, placeDown = true},
	[2912] = {model = 2912, name = "Waffenkiste", pos = Vector3(0, 0.35, 0.45), rot = Vector3(10, 0, 0), blockJump = true, blockSprint = true, blockWeapons = true, blockVehicle = true, animationData = {"carry", "crry_prtial", 1, true, true, false, true}, placeDown = true},
	[2919] = {model = 2919, name = "Waffen", pos = Vector3(0, -0.2, 0), rot = Vector3(0, 90, 90), 	blockJump = true, bone = 3, blockSprint = true,  blockVehicle = false, placeDown = true},
	[1826] = {model = 1826, name = "Angelruten", pos = Vector3(-0.03, 0.02, 0.05), rot = Vector3(180, 120, 0), blockJump = false, bone = 12, blockSprint = true, blockVehicle = true},
}



COROUTINE_STATUS_RUNNING = "running"
COROUTINE_STATUS_SUSPENDED = "suspended"
COROUTINE_STATUS_DEAD = "dead"

THREAD_PRIORITY_LOW = 500
THREAD_PRIORITY_MIDDLE = 250
THREAD_PRIORITY_HIGH = 150
THREAD_PRIORITY_HIGHEST = 50

AD_COST = 30
AD_COST_PER_CHAR = 3
AD_BREAK_TIME = 30 -- In Seconds

AD_DURATIONS = {
	["20 Sekunden"] = 20,
	["30 Sekunden"] = 30,
	["45 Sekunden"] = 45
}

BODYPART_NAMES = {
	[3] = "Körper",
	[4] =  "Arsch",
	[5] =  "Linker Arm",
	[6] =  "Rechter Arm",
	[7] =  "Linkes Bein",
	[8] =  "Rechtes Bein",
	[9] =  "Kopf"
}

MEDIC_TIME = 180000
DEATH_TIME = 30000
DEATH_TIME_PREMIUM = 0
DEATH_TIME_ADMIN = 0


if DEBUG then
	MEDIC_TIME = 25000
	DEATH_TIME = 0
end


BeggarTypes = { -- Important: Do not change order! Only add a new one below!
	Money = 1;
	Food = 2;
	Transport = 3;
    Weed = 4;
	Heroin = 5;
}

BeggarTypeNames = {}
for i, v in pairs(BeggarTypes) do
	BeggarTypeNames[v] = i
end

HOSPITAL_POSITION = Vector3(1177.80, -1323.94, 14.09)
HOSPITAL_ROTATION = Vector3(0, 0, 270)

WEAPON_LEVEL = {
	[1] = {["costs"] = 500, ["hours"] = 1},
	[2] = {["costs"] = 750, ["hours"] = 2},
	[3] = {["costs"] = 1000, ["hours"] = 3},
	[4] = {["costs"] = 1500, ["hours"] = 6},
	[5] = {["costs"] = 2000, ["hours"] = 8},
	[6] = {["costs"] = 2500, ["hours"] = 10},
	[7] = {["costs"] = 3250, ["hours"] = 14},
	[8] = {["costs"] = 4000, ["hours"] = 18},
	[9] = {["costs"] = 4750, ["hours"] = 22},
	[10] = {["costs"] = 5500, ["hours"] = 30}
}

BOXING_MONEY = {0, 50, 100, 500, 1000, 5000, 10000, 50000, 100000}

FERRIS_IDS = {
	Base = 6461,
	Gond = 3752,
	Wheel = 6298,
}

SPAWN_LOCATIONS = {
	DEFAULT = 0,
	NOOBSPAWN = 1,
	GARAGE = 2,
	FACTION_BASE = 3,
	COMPANY_BASE = 4,
	HOUSE = 5,
	VEHICLE = 6,
	GROUP_BASE = 7
}

VEHICLE_MODEL_SPAWNS = {
	[508] = true,
	[484] = true,
	[483] = true,
	[454] = true,
}

VEHICLE_SPAWN_OFFSETS = {
	[508] = Vector3(3, 0, 0),
	[484] = Vector3(0, -2, 2),
	[483] = Vector3(2, 2, 0),
	[454] = Vector3(-0.4, -3.0, 2),
}

HOUSE_INTERIOR_TABLE = {
	[1] = {1, 223.27027893066, 1287.4304199219, 1081.9130859375};
	[2] = {5, 2233.8625488281, -1113.7662353516, 1050.8828125};
	[3] = {8, 2365.224609375, -1135.1401367188, 1050.875};
	[4] = {11, 2282.9448242188, -1139.9676513672, 1050.8984375};
	[5] = {6, 2196.373046875, -1204.3984375, 1049.0234375};
	[6] = {10, 2270.2353515625, -1210.4715576172, 1047.5625};
	[7] = {6, 2309.1716308594, -1212.6801757813, 1049.0234375};
	[8] = {1, 2217.1474609375, -1076.2725830078, 1050.484375};
	[9] = {2, 2237.5483398438, -1081.1091308594, 1049.0234375};
	[10] = {9, 2318.0712890625, -1026.2338867188, 1050.2109375};
	[11] = {4, 260.99948120117, 1284.8186035156, 1080.2578125};
	[12] = {5, 140.2495880127, 1366.5075683594, 1083.859375};
	[13] = {9, 82.978126525879, 1322.5451660156, 1083.8662109375};
	[14] = {15, -284.0530090332, 1471.0965576172, 1084.375};
	[15] = {4, -260.75534057617, 1456.6932373047, 1084.3671875};
	[16] = {8, -42.373157501221, 1405.9846191406, 1084.4296875};
	[17] = {2, 2454.717041, -1700.871582, 1013.515197};
	[18] = {1, 2527.654052, -1679.388305, 1015.515197};
	[19] = {8, 2807.619873, -1171.899902, 1025.5234375};
	[20] = {5, 318.564971, 1118.209960, 1083.5234375};
	[21] = {12, 2324.419921, -1145.568359, 1050.5234375};
	[22] = {5, 1298.8719482422, -796.77032470703, 1083.6569824219};
	[23] = {21, 1480.55, 1329.45, 13.09}; -- sewers
	[24] = {21, 1530.05, 1475.21, 13.20}; -- sewers2
	[25] = {17, -959.65, 1954.80, 9.5}; -- dam generator
	[26] = {9, 313.95544, 957.64325, 2009.87683}; -- terror storage
	[27] = {0, 506.76, -1521.03, 32.11}; -- terror office
}

CompanyStaticId = {
	DRIVINGSCHOOL = 1,
	MECHANIC = 2,
	SANNEWS = 3,
	EPT = 4,
}

FactionStaticId = {
	SAPD = 1,
	FBI = 2,
	MBT = 3,
	RESCUE = 4,
	LCN = 5,
	YAKUZA = 6,
	GROVE = 7,
	BALLAS = 8,
	OUTLAWS = 9,
	VATOS = 10,
	TRIAD = 11
}

SEASONS = {
	SPRING = 1,
	SUMMER = 2,
	FALL = 3,
	WINTER = 4,
}

COLLECTABLES_COUNT_PER_PLAYER = 40 -- how many collectables each player can collect
