PROJECT_NAME = "eXo Reallife"
PROJECT_VERSION = "1.5"

PRIVATE_DIMENSION_SERVER = 65535 -- This dimension should not be used for playing
PRIVATE_DIMENSION_CLIENT = 2 -- This dimension should be used for things which
							 -- happen while the player is in PRIVATE_DIMENSION on the server

-- LEVELS
MAX_JOB_LEVEL = 10
MAX_WEAPON_LEVEL = 10
MAX_VEHICLE_LEVEL = 10
MAX_SKIN_LEVEL = 10
MAX_FISHING_LEVEL = 10

MAX_WANTED_LEVEL = 12

-- EVENTS:
EVENT_EASTER = false
EVENT_HALLOWEEN = false
EVENT_CHRISTMAS = false
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

	--admin general
	["event"] = RANK.Moderator,
	["eventMoneyWithdraw"] = RANK.Moderator,
	["eventMoneyDeposit"] = RANK.Supporter,
	["vehicleTexture"] = RANK.Moderator,
	["spect"] = RANK.Supporter,
	["smode"] = RANK.Supporter,
	["adminAnnounce"] = RANK.Supporter,
	["clearchat"] = RANK.Supporter,
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
	["respawnVehicle"] = RANK.Supporter, -- respawn per click
	["parkVehicle"] = RANK.Supporter, -- set spawn position
	["repairVehicle"] = RANK.Supporter, -- repair per click
	["despawnVehicle"] = RANK.Supporter, -- despawn
	["deleteVehicle"] = RANK.Administrator, -- permanently destroy vehicle
	["looseVehicleHandbrake"] = RANK.Supporter,

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

	--keypad-system 
	["placeKeypadObjects"] = RANK.Administrator -- ItemKeyPad, ItemEntrance, ItemDoor
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

WEAPONTRUCK_MAX_LOAD = 60000
WEAPONTRUCK_MAX_LOAD_STATE = 60000

PlayerAttachObjects = {
	[1550] = {["model"] = 1550, ["name"] = "Geldsack", ["pos"] = Vector3(0, -0.3, 0.3), ["rot"] = Vector3(0, 0, 180)},
	[2912] = {["model"] = 2912, ["name"] = "Waffenkiste", ["pos"] = Vector3(-0.09, 0.35, 0.45), ["rot"] = Vector3(10, 0, 0)}
}

MAX_VEHICLES_PER_LEVEL = 1.5 -- Todo: improve this
VEHICLE_SPECIAL_SMOKE = {[512] = true, [513] = true}
VEHICLE_SPECIAL_TEXTURE = {
	[417] = "leviathnbody8bit256",
	[425] = "hunterbody8bit256a",
	[447] = "sparrow92body128",
	[460] = "skimmer92body128",
	[469] = "sparrow92body128",
	[481] = "vehiclegeneric256", --bmx
	[483] = "remapcamperbody256",
	[487] = "maverick92body128",
	[488] = "polmavbody128a",
	[497] = "polmavbody128a",
	[510] = "mtbike64x128",
	[511] = "beagle256",
	[512] = "cropdustbody256",
	[513] = "stunt256",
	[519] = "shamalbody256",
	[521] = "fcr90092body128",
	[522] = "nrg50092body128",
	[534] = "remapremington256body",
	[535] = "#emapslamvan92body128",
	[536] = "#emapblade92body128",
	[548] = "cargobob92body256",
	[553] = "nevada92body256",
	[558] = "@hite",
	[559] = "#emapjesterbody256",
	[560] = "#emapsultanbody256",
	[561] = "#emapstratum292body256",
	[562] = "#emapelegybody128",
	[563] = "raindance92body128",
	[565] = "#emapflash92body256",
	[567] = "#emapsavanna92body128",
	[575] = "remapbroadway92body128",
	[576] = "remaptornado92body128",
	[577] = "at400_92_256",
	[581] = "bf40092body128",
	[586] = "wayfarerbody8bit128",
	[593] = "dodo92body8bit256",
}

VEHICLE_BIKES = {
[481] = true,
[509] = true,
[510] = true,
}

PLANES_SINGLE_ENGINE = {
[593] = true,
[512] = true,
[476] = true,
[513] = true,
}

PLANES_TWIN_ENGINE = {
[511] = true,
[553] = true,
}

PLANES_JET = {
[520] = true,
[519] = true,
}

PLANES_JUMBO_JET = {
[592] = true,
[577] = true,
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

WEAPON_NAMES = {
	[0] = "Faust",
	[1] = "Schlagring",
	[2] = "Golfschläger",
	[3] = "Schlagstock",
	[4] = "Messer",
	[5] = "Baseball Schläger",
	[6] = "Schaufel",
	[7] = "Billiard Queue",
	[8] = "Katana",
	[9] = "Kettensäge",
	[10] = "Langer Dildo",
	[11] = "Kurzer Dildo",
	[12] = "Vibrator",
	[14] = "Blumen",
	[15] = "Gehstock",
	[16] = "Granaten",
	[17] = "Tränengas",
	[18] = "Molotov Cocktails",
	[22] = "9mm Pistole",
	[23] = "Taser",
	[24] = "Desert Eagle",
	[25] = "Schrotflinte",
	[26] = "Abgesägte Schrot",
	[27] = "SPAZ-12",
	[28] = "Uzi",
	[29] = "MP5",
	[30] = "AK-47",
	[31] = "M4",
	[32] = "TEC-9",
	[33] = "Jagd Gewehr",
	[34] = "Sniper",
	[35] = "Raketenwerfer",
	[36] = "RPG",
	[37] = "Flammenwerfer",
	[38] = "Minigun",
	[39] = "Rucksack-Bomben",
	[40] = "Bomben Auslöser",
	[41] = "Spray-Dose",
	[42] = "Feuerlöscher",
	[43] = "Kamera",
	[44] = "Nachtsicht-Gerät",
	[45] = "Wärmesicht-Gerät",
	[46] = "Fallschrirm"
}

WEAPON_CLIPS = {
	[25] = 6,
	[33] = 5,
	[34] = 4
}

MIN_WEAPON_LEVELS = {
	[0] = 0, -- Faust
	[1] = 0, -- Schlagring
	[2] = 0, -- Golfschläger
	[3] = 0, -- Schlagstock
	[4] = 0, -- Messer
	[5] = 0, -- Baseball Schläger
	[6] = 0, -- Schaufel
	[7] = 0, -- Billiard Queue
	[8] = 1, -- Katana
	[9] = 1, -- Kettensäge
	[10] = 0, -- Langer Pinker Dildo
	[11] = 0, -- Kurzer Dildo
	[12] = 0, -- Vibrator
	[14] = 0, -- Blumen
	[15] = 0, -- Gehstock
	[16] = 6, -- Granaten
	[17] = 6, -- Tränengas
	[18] = 6, -- Molotov Cocktails
	[22] = 3, -- 9mm Pistole
	[23] = 3, -- Taser
	[24] = 4, -- Desert Eagle
	[25] = 5, -- Schrotflinte
	[26] = 6, -- Abgesägte Schrotflinte
	[27] = 7, -- SPAZ-12 Spezialwaffe
	[28] = 7, -- Uzi
	[29] = 7, -- MP5
	[30] = 8, -- AK-47
	[31] = 8, -- M4
	[32] = 7, -- TEC-9
	[33] = 7, -- Jagd Gewehr
	[34] = 8, -- Sniper
	[35] = 8, -- Raketenwerfer
	[36] = 8, -- RPG
	[37] = 8, -- Flammenwerfer
	[38] = 10, -- Minigun
	[39] = 8, -- Rucksack-Bomben
	[40] = 8, -- Bomben Auslöser
	[41] = 1, -- Spray-Dose
	[42] = 0, -- Feuerlöscher
	[43] = 0, -- Kamera
	[44] = 0, -- Nachtsicht-Gerät
	[45] = 0, -- Wärmesicht-Gerät
	[46] = 0, -- Fallschrirm"
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

WEAPON_IDS = {}
for id, name in pairs(WEAPON_NAMES) do
	WEAPON_IDS[name] = id
end

MEDIC_TIME = 180000
DEATH_TIME = 30000
DEATH_TIME_PREMIUM = 0
DEATH_TIME_ADMIN = 0


if DEBUG then
	MEDIC_TIME = 25000
	DEATH_TIME = 0
end


VRP_RADIO = {
	{"You FM", "http://metafiles.gl-systemhaus.de/hr/youfm_2.m3u"},
	{"181.FM", "http://www.181.fm/winamp.pls?station=181-power&style=mp3&description=Power%20181%20(Top%2040)&file=181-power.pls"},
	{"RMF Dance", "http://files.kusmierz.be/rmf/rmfdance-3.mp3"},
	{"Kronehit", "http://onair-ha1.krone.at/kronehit-hd.mp3.m3u"},
	{"Life Radio", "http://94.136.28.10:8000/liferadio.m3u"},
	{"OE3", "http://mp3stream7.apasf.apa.at:8000"},
	{"FM 4", "http://mp3stream1.apasf.apa.at:8000/listen.pls"},
	{"NSW-LiVE", "http://nsw-radio.de"},
	{"Technobase.fm", "http://listen.technobase.fm/dsl.asx"},
	{"Hardbase.fm", "http://listen.hardbase.fm/tunein-dsl-asx"},
	{"Housetime.fm", "http://listen.housetime.fm/tunein-dsl-asx"},
	{"Techno4Ever", "http://www.techno4ever.net/t4e/stream/dsl_listen.asx"},
	{"ClubTime.fm", "http://listen.ClubTime.fm/dsl.pls"},
	{"CoreTime.fm", "http://listen.CoreTime.fm/dsl.pls"},
	{"Lounge FM Austria", "http://digital.lounge.fm"},
	{"Rock Antenne", "http://www.rockantenne.de/webradio/rockantenne.m3u"},
	{"Raute Musik Rock", "http://rock-high.rautemusik.fm/listen.pls"},
	{"FFS (nicht 24/7 online)", "http://ffs-gaming.com:8008/ffs.ogg"},


	-- GTA channels
	{"Playback FM", 1},
	{"K-Rose", 2},
	{"K-DST", 3},
	{"Bounce FM", 4},
	{"SF-UR", 5},
	{"Radio Los Santos", 6},
	{"Radio X", 7},
	{"CSR 103.9", 8},
	{"K-Jah West", 9},
	{"Master Sounds 98.3", 10},
	{"WCTR", 11},
	{"User Track Player", 12}
}

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

HOSPITAL_POSITION = Vector3(1739.09, -1747.98, 18.81)
HOSPITAL_ROTATION = Vector3(0, 0, 180)

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


FISHING_BAGS = {
	["Kühlbox"] = {max = 65, level = 8},
	["Kühltasche"] = {max = 25, level = 4},
	["Kleine Kühltasche"] = {max = 15, level = 0},
}

-- (level * 15)^2 // for i = 1, 10 do print(("[%s] = %s,"):format(i, (i*15)^2)) end
FISHING_LEVELS = {
	[1] = 225,
	[2] = 900,
	[3] = 2025,
	[4] = 3600,
	[5] = 5625,
	[6] = 8100,
	[7] = 11025,
	[8] = 14400,
	[9] = 18225,
	[10] = 22500,
}

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

CAR_COLORS_FROM_ID =
{
	"weiß","hell-blau","dunkel-rot","grau","lila","oranger","hell-blau",
	"weiß","grau","grau-blau","grau","grau-blau","grau","weiß","grau",
	"dunkel-grün","rot","pupurn", "grau", "blau", "pupurn", "violett",
	"weiß", "grau", "grau", "weiß", "grau", "grau-blau", "grau", "braun",
	"braun-rot", "hell-blau", "grau", "grau", "grau", "schwarz-grau", "grau-grün",
	"hell-blau", "grau-blau", "dunke-grau", "grau", "rot", "dunkel-rot",
	"dunkel-grün", "dunkel-rot", "hell-grau", "grau", "grau", "hell-blau",
	"hell-blau", "dunkel-grau", "grau-grün", "grau-blau", "dunke-blau", "dunkel-blau",
	"braun", "hell-blau", "grau-braun", "dunkel-rot", "dunkel-blau", "grau",
	"braun", "dunkel-rot", "hell-blau", "grau-weiß", "ocker", "dunkel-braun", "hell-blau",
	"grau", "rosa", "rot", "blau", "grau", "hell-grau", "rot", "dunkel-grau", "grau",
	"hell-grau", "rot", "blau", "rosa", "grau", "rot", "grau", "braun", "lila", "grün",
	"blau", "dunkel-rot", "grau", "hell-blau", "dunkel-blau", "grau", "blau", "dunkel-blau",
	"dunke-blau", "hell-grau", "hell-blau", "grau", "braun", "blau", "dunkel-grau",
	"hell-braun", "blau", "hell-braun", "grau", "blau", "hell-grau", "blau", "grau", "braun", "hell-grau",
	"blau", "braun", "grau-grün", "dunkel-rot", "dunkel-blau", "dunkel-rot", "hell-blau", "grau",
	"hell-grau", "dunkel-rot", "grau", "braun", "dunkel-rot", "dunkel-blau", "pink", [0] = "schwarz"
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
	[24] = {17, -959.65, 1954.80, 9.5}; -- dam generator
	[25] = {9, 313.95544, 957.64325, 2009.87683}; -- terror storage
}

VEHICLE_PICKUP = {
	[422] = true,
	[554] = true,
	[433] = true,
	[444] = true,
	[556] = true,
	[557] = true,
	[478] = true,
	[578] = true,
	[535] = true,
	[543] = true,
	[605] = true,
	[600] = true,
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
	YAKUZZA = 6,
	GROVE = 7,
	BALLAS = 8,
	OUTLAWS = 9,
	VATOS = 10
}

FUEL_PRICE = { --price per liter
	["petrol"] = 2.3,
	["petrol_plus"] = 3.4,
	["diesel"] = 1.7,
	["jetfuel"] = 4.6,
	["universal"] = 0,
	["nofuel"] = 0,

}
FUEL_NAME = { --display name
	["petrol"] = "Super",
	["petrol_plus"] = "Super Plus",
	["diesel"] = "Diesel",
	["jetfuel"] = "Kerosin",
	["universal"] = "Universal-Kraftstoff",
	["nofuel"] = "kein Kraftstoff",

}
FUEL_PRICE_MULTIPLICATOR = 2
MECHANIC_FUEL_PRICE_MULTIPLICATOR = 2.5
SERVICE_FUEL_PRICE_MULTIPLICATOR = 5
SERVICE_REPAIR_PRICE_MULTIPLICATOR = 5
