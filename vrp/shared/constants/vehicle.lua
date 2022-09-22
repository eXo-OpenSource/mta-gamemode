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
	[556] = "monstera92body256a",
	[557] = "monsterb92body256a",
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
	[460] = true,
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
	
	
CAR_COLORS_FROM_ID =
{
	"weiß","hell-blau","dunkel-rot","grau","lila","oranger","hell-blau", "weiß","grau","grau-blau","grau","grau-blau","grau","weiß","grau", "dunkel-grün","rot","pupurn", "grau",
	"blau", "pupurn", "violett", "weiß", "grau", "grau", "weiß", "grau", "grau-blau", "grau", "braun", "braun-rot", "hell-blau", "grau", "grau", "grau", "schwarz-grau", "grau-grün", "hell-blau", "grau-blau", 
	"dunkel-grau", "grau", "rot", "dunkel-rot", "dunkel-grün", "dunkel-rot", "grau", "grau", "grau", "hell-grau", "dunkel-grau", "grau-grün", "grau-blau", "dunke-blau", "dunkel-blau", "braun", "hell-blau", "grau-braun", "dunkel-rot", "dunkel-blau", 
	"grau", "braun", "dunkel-rot", "hell-blau", "grau-weiß", "ocker", "dunkel-braun", "hell-blau", "grau", "rosa", "rot", "blau", "grau", "hell-grau", "rot", "dunkel-grau", "grau", "hell-grau", "rot", "blau", 
	"rosa", "grau", "rot", "grau", "braun", "lila", "grün", "blau", "dunkel-rot", "grau", "hell-grau", "dunkel-blau", "grau", "blau", "dunkel-blau", "dunke-blau", "hell-grau", "hell-grau", "grau", "braun", 
	"blau", "dunkel-grau", "hell-braun", "blau", "hell-braun", "grau", "blau", "hell-grau", "blau", "grau", "braun", "hell-grau", "blau", "braun", "grau-grün", "dunkel-rot", "dunkel-blau", "dunkel-rot", "hell-blau", "grau",
	"hell-grau", "dunkel-rot", "grau", "braun", "dunkel-rot", "dunkel-blau", "pink", [0] = "schwarz"
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

VEHICLE_OBJECT_ATTACH_POSITIONS = {
	[428] = { --vehicle model, securicar in this case
		loadMarkerPos = Vector3(0, -3.5, 0),
		vehicleDoors = {4, 5},
		objectId = 1550, -- money bag
		objectNames = {"Geldsack", "Geldsäcke"},
        randomRotation = true, --random z-rotaion on attach to provide some variety
        positions = { -- in loading order, e.g. the first row is the first object position to load
            Vector3(0.3, -1, 0.2),
            Vector3(-0.3, -1, 0.2),
            Vector3(0.7, -1.61, 0.2),
            Vector3(-0.7, -1.59, 0.2),
            Vector3(0.21, -1.6, 0.2),
            Vector3(-0.21, -1.58, 0.2),
            Vector3(0.7, -2.51, 0.2),
            Vector3(-0.7, -2.52, 0.2),
            Vector3(0.21, -2.51, 0.2),
            Vector3(-0.21, -2.49, 0.2),
        },
	},

	[456] = { --vehicle model, yankee in this case
	loadMarkerPos = Vector3(0, -5.25, 0),
	vehicleDoors = {1},
	objectId = 1575, -- drug package
	objectNames = {"Drogenpaket", "Drogenpakete"},
	randomRotation = false, --random z-rotaion on attach to provide some variety
	positions = { -- in loading order, e.g. the first row is the first object position to load
	Vector3(0.5, -0.1, 0.03), Vector3(-0.6, -0.1, 0.03),
	Vector3(-0.6, -1.1, 0.03), Vector3(0.5, -1, 0.03),
	Vector3(0.5, -1.9, 0.03), Vector3(0.5, -2.8, 0.03), 
	Vector3(-0.6, -1.9, 0.03), Vector3(-0.6, -2.8, 0.03), 
	Vector3(0.5, -3.7, 0.03), Vector3(-0.6, -3.7, 0.03),	
	},
	scale = 1.6 -- the objects scale, when attached
	},
}

FUEL_PRICE_RANGE = { --price per liter
	["petrol"] = {2.5, 6},
	["petrol_plus"] = {2.8, 6.8},
	["diesel"] = {2.1, 6.5},
	["jetfuel"] = {7, 12},
	["universal"] = {0, 0},
	["nofuel"] = {0, 0},

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
EVIL_FUEL_PRICE_MULTIPLICATOR = 3
SERVICE_FUEL_PRICE_MULTIPLICATOR = 3
SERVICE_REPAIR_PRICE_MULTIPLICATOR = 3

VEHICLE_VARIANTS = {
	[404]={0,1,2},
	[407]={0,1,2},
	[408]={0},
	[413]={0},
	[414]={0,1,2,3},
	[415]={0,1},
	[416]={0,1},
	[422]={0,1},
	[423]={0,1},
	[424]={0},
	[428]={0,1},
	[433]={0,1},
	[434]={0},
	[435]={0,1,2,3,4,5},
	[437]={0,1},
	[439]={0,1,2},
	[440]={0,1,2,3,4,5},
	[442]={0,1,2},
	[449]={0,1,2,3,4},
	[450]={0},
	[453]={0,1},
	[455]={0,1,2},
	[456]={0,1,2,3},
	[457]={0,1,2,3,4,5},
	[459]={0},
	[470]={0,1,2},
	[472]={0,1,2},
	[477]={0},
	[478]={0,1,2},
	[482]={0},
	[483]={0,1},
	[484]={0},
	[485]={0,1,2},
	[499]={0,1,2,3},
	[500]={0,1},
	[502]={0,1,2,3,4,5},
	[503]={0,1,2,3,4,5},
	[504]={0,1,2,3,4,5},
	[506]={0},
	[521]={0,1,2,3,4},
	[522]={0,1,2,3,4},
	[535]={0,1},
	[543]={0,1,2,3,4},
	[552]={0,1},
	[555]={0,1},
	[556]={0,1,2},
	[557]={0,1},
	[571]={0,1},
	[581]={0,1,2,3,4},
	[583]={0,1},
	[595]={0,1},
	[600]={0,1},
	[601]={0,1,2,3},
	[605]={0,1,2,3,4},
	[607]={0,1,2}
}

VEHICLE_SPEEDO_MAXVELOCITY_OFFSET = 16.066834862484

VEHICLE_TUNINGKIT_CATEGORIES = {
	["Motor"] = {{"maxVelocity","Topspeed"}, {"engineAcceleration","Beschleunigung"}, {"engineInertia", "Trägheitsmoment"}, {"driveType", "Antrieb"}},
	["Reifen"] = {{"tractionMultiplier", "Bodenhaftung"}, {"tractionBias", "Haftungsverlagerung"}, {"tractionLoss", "Haftungsstabilität"}},
	["Fahrwerk"] = {{"suspensionForceLevel", "Federungsresistenz"}, {"suspensionFrontRearBias", "Federungsverlagerung"}, {"suspensionDamping", "Federungs-Dämpfung"}, {"suspensionLowerLimit", "Tieferlegung"}, {"steeringLock", "Lenkbereich"} },
	["Bremsen"] = {{"brakeDeceleration", "Bremskraft"}, {"brakeBias", "Bremsverlagerung"}},
}

VEHICLE_TUNINGKIT_DESCRIPTION = {
	["engineAcceleration"] = { 
		{0, 60}, -- range
		"Die Beschleunigung deines Fahrzeuges in m/s²", -- tooltip-description
		"m/s²" -- unit
	},
	["maxVelocity"] = { 
		{0.1, 400}, -- range
		"Die maximale Geschwindigkeit deines Fahrzeuges in km/h", -- tooltip-description
		"km/h" -- unit
	},
	["engineInertia"] = { 
		{-30, 30}, -- range
		"Die Trägheit des Fahrzeuges!",
	},
	["driveType"] = { 
		{0, 2}, -- range
		"Der Antrieb deines Fahrzeuges: Hinter, Vorder- oder Allrad!",
	},
	["tractionMultiplier"] = { 
		{-5, 5}, -- range
		"Der Grip deiner Reifen auf der Oberfläche der Fahrbahn!",
	},
	["tractionBias"] = { 
		{0, 1}, -- range
		"Die Verlagerung des Grips!",
	},
	["tractionLoss"] = { 
		{0, 3}, -- range
		"Die Stabilität bezüglich der Bodenhaftung beim Bremsen/Anfahren!",
	},
	["suspensionForceLevel"] = { 
		{0, 10}, -- range
		"Die Resistenz deiner Fahrzeug-Feder!",
	},
	["suspensionDamping"] = { 
		{0, 1}, -- range
		"Die Dämpffähigkeit deiner Federung!",
	},
	["suspensionLowerLimit"] = { 
		{-0.2, 0.2}, -- range
		"Die Länge deiner Federung und damit Höhe des Fahrwerks!",
	},
	["suspensionFrontRearBias"] = { 
		{0, 1}, -- range
		"Die Verlagerung der Federung!",
	},
	["steeringLock"] = { 
		{0, 90}, -- range
		"Der Lenkradius deines Fahrzeuges in Grad!",
		"°"
	},
	["brakeDeceleration"] = { 
		{0.1, 10}, -- range
		"Die Bremskraft deines Fahrzeuges in m/s²!",
	},
	["brakeBias"] = { 
		{0, 1}, -- range
		"Die Bremskraftverlagerung!",
	},
}

OLD_VEHICLE_PRICES = 
{
	[469] = 18000,
	[487] = 60000,
	[579] = 30000,
	[541] = 90000,
	[506] = 70000,
	[415] = 150000,
	[429] = 80000,
	[484] = 150000,
	[454] = 99000,
	[446] = 117900,
	[452] = 50000,
	[473] = 7900,
	[493] = 42500,
	[593] = 32500,
	[553] = 90000,
	[519] = 300000,
	[513] = 120000,
	[511] = 70000,
	[471] = 4500,
	[478] = 30000,
	[483] = 35000,
	[580] = 99000,
	[411] = 180000,
	[400] = 15000,
	[436] = 10000,
	[566] = 80000,
	[549] = 2500,
	[604] = 900,
	[605] = 5000,
	[475] = 18000,
	[426] = 20000,
	[527] = 15000,
	[542] = 9000,
	[458] = 13000,
	[481] = 500,
	[510] = 600,
	[462] = 900,
	[581] = 3500,
	[468] = 35000,
	[522] = 45000,
	[562] = 60000,
	[589] = 100000,
	[496] = 50000,
	[559] = 85000,
	[561] = 70000,
	[560] = 50000,
	[440] = 60000,
	[402] = 90000,
	[533] = 100000,
	[451] = 400000,
	[603] = 40000,
	[492] = 34000,
	[558] = 75000,
	[489] = 39000,
	[460] = 90000,
	[467] = 50000,
	[507] = 60000,
}

PlaneSizeTable = {
    [577] = {32.5, 32.5},
    [592] = {25, 35},
    [511] = {12.5, 12.5},
    [593] = {15, 15},
    [513] = {15, 15},
    [553] = {15, 15}
}

VehicleShopColors =  -- unified colors for the vehicle shop
{
	{160,160,160},
	{133, 133, 133},
	{105,105,105},   
	{128,128,128},
	{105,105,105},
}

VEHICLES_WITH_BULLET_ARMOR = {
	[425] = 2, --Hunter
    [432] = 2 --Rhino
}

VEHICLE_MAX_PASSENGER = { -- Only extra passenger, driver and normal passenger seats are not included
	[511] = 4, -- Beagle -- normal = 1
	[519] = 7, -- Shamal -- normal = 0
	[553] = 10, -- Nevada -- normal = 0
	[577] = 15, -- AT-400 -- normal = 1
	[592] = 15, -- Andromada -- normal = 1
}

VEHICLE_SEAT_EXTENSION_DOOR_OFFSET = {
	[511] = Vector3(2.5, 2.7, 0),
	[519] = Vector3(2, 3.6, 0),
	[553] = Vector3(-2, -3.6, 0),
	[577] = Vector3(3, 19, 1.4),
	[592] = Vector3(3, 11.3, 0),
}

--[[VEHICLE_SEAT_EXTENSION_SEAT_OFFSET = {
	[511] = {
		Vector3(-0.4, 1.6, -0.4),
		Vector3(0.3, 1.6, -0.4),
		Vector3(-0.4, 0.5, -0.4),
		Vector3(0.3, 0.5, -0.4),
	}
}]]

SHAMAL_EXTENSION_INTERIOR_POSITION = {
	[0] = {Vector3(0.81, 35.85, 1199.6), 0},
	[1] = {Vector3(2.57, 35.87, 1199.59), 0},
	[2] = {Vector3(2.86, 29.80, 1199.59), 180},
	[3] = {Vector3(0.61, 28.76, 1199.59), 180},
	[4] = {Vector3(2.84, 28.64, 1199.59), 0},
	[5] = {Vector3(0.61, 27.60, 1199.59), 0},
	[6] = {Vector3(2.88, 26.37, 1199.59), 0},
	[7] = {Vector3(0.57, 25.30, 1199.59), 0},
   }

VEHICLE_MIN_DAYS_TO_REGISTER_AGAIN = DEBUG and 0 or 3*24*60*60

VehicleSpawnPositionAfterRegister = {
{1504.75, -1847.58, 12.25},
{1507.75, -1847.53, 12.25},
{1510.75, -1847.48, 12.25},
{1520.74, -1846.97, 12.25},
{1524.74, -1846.91, 12.25},
{1531.74, -1846.79, 12.25},
}

RC_TOGGLE_COOLDOWN = 60*20

RC_UPGRADE_VEHICLE = {
	[441] = true, -- RC Bandit
	[464] = true, -- RC Baron
	[501] = true, -- RC Goblin
	[564] = true, -- RC Tiger
}

RC_UPGRADE_VEHICLE_PRICE = {
    [441] =     350000, -- RC Bandit
    [464] =     500000, -- RC Baron
    [501] =     750000, -- RC Goblin
    [564] =     650000, -- RC Tiger
}