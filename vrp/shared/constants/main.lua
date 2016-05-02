PRIVATE_DIMENSION_SERVER = 65535 -- This dimension should not be used for playing
PRIVATE_DIMENSION_CLIENT = 2 -- This dimension should be used for things which
							 -- happen while the player is in PRIVATE_DIMENSION on the server

RANK = {}
RANK[-1] = "Banned"
RANK[0] = "User"
RANK[1] = "Supporter"
RANK[2] = "Moderator"
RANK[3] = "SuperModerator"
RANK[4] = "Administrator"
RANK[5] = "Developer"

local r2 = {}
for k, v in pairs(RANK) do
	r2[k] = v
	r2[v] = k
end
RANK = r2

ADMIN_RANK_PERMISSION = {
	["kick"] = RANK.Supporter,
	["rkick"] = RANK.Supporter,
	["prison"] = RANK.Supporter,
	["gethere"] = RANK.Supporter,
	["goto"] = RANK.Supporter,
	["showVehicles"] = RANK.Supporter,
	["warn"] = RANK.Supporter,
	["supportMode"] = RANK.Supporter,
	["smode"] = RANK.Supporter,
	["warn"] = RANK.Supporter,
	["addWarn"] = RANK.Supporter,
	["timeban"] = RANK.Moderator,
	["permaban"] = RANK.SuperModerator,
	["nickchange"] = RANK.SuperModerator,
	["setFaction"] = RANK.SuperModerator,
	["setCompany"] = RANK.SuperModerator,
	["removeWarn"] = RANK.SuperModerator
}

BankStat = {
	Transfer = 0,
	Income = 1,
	Payment = 2,
	Withdrawal = 3,
	Deposit = 4,
	Job = 5,
}

GroupRank = {
	Normal = 0,
	Manager = 1,
	Leader = 2
}

FactionRank = {
	Normal = 0,
	Manager = 5,
	Leader = 6
}

CompanyRank = {
	Normal = 0,
	Manager = 4,
	Leader = 5
}


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
		Weapon = 1850,
		MinLevel = 7,
	},
	[31] = { -- M4A1
		Magazine = {price=60,amount=50},
		Weapon = 2500,
		MinLevel = 7,
	},
	[29] = { -- MP5
		Magazine = {price=40,amount=30},
		Weapon = 1000,
		MinLevel = 6,
	},
	[25] = { -- Shotgun
		Magazine = {price=2,amount=1},
		Weapon = 900,
		MinLevel = 5,
	},
	[33] = { -- Rifle
		Magazine = {price=4,amount=1},
		Weapon = 1250,
		MinLevel = 6,
	},
	[22] = { -- Pistol
		Magazine = {price=15,amount=17},
		Weapon = 450,
		MinLevel = 3,
	},
	[24] = { -- Desert Eagle
		Magazine = {price=7,amount=7},
		Weapon = 1150,
		MinLevel = 3,
	},
	[1] = { -- Brass Knuckles
		Weapon = 50,
		MinLevel = 0,
	},
	[0] = { -- Armor
		Weapon = 150,
		MinLevel = 0,
	},
}

DEFAULT_GANGAREA_RESOURCES = 500
GangAreaData = {
	{wallPosition = Vector3(2512.3999, -1683.4, 13.9), wallRotation = 129, areaPosition = Vector3(2419.7507, -1627.7887, 15), width = 122, height = 99},
	{wallPosition = Vector3(2080.5, -1597.1, 13.8), wallRotation = 269.5, areaPosition = Vector3(2052.886, -1538.6737, 30), width = 52, height = 70},
	{wallPosition = Vector3(1758.7, -1938.9, 14), wallRotation = 0, areaPosition = Vector3(1683.1904, -1828.8699, 30), width = 125, height = 179},
	{wallPosition = Vector3(1761.5, -1350.2, 16), wallRotation = 0, areaPosition = Vector3(1720.04, -1306.9941, 30), width = 120, height = 150},
	{wallPosition = Vector3(1913.1, -1361.5, 14), wallRotation = 267, areaPosition = Vector3(1854.2794, -1344.212, 30), width = 131, height = 112},
	{wallPosition = Vector3(1959.6, -1173.6, 20.4), wallRotation = 179.5, areaPosition = Vector3(1860.3521, -1140.6764, 30), width = 208, height = 117},
	{wallPosition = Vector3(2215.5, -1173.9, 26.1), wallRotation = 89.75, areaPosition = Vector3(2185.2979, -1130.2002, 30), width = 82, height = 85},
	{wallPosition = Vector3(2768.2, -1625, 11.3), wallRotation = 0, areaPosition = Vector3(2743.6201, -1495.0059, 30), width = 111, height = 155},
	--{wallPosition = Vector3(920.29999, -1231.7, 17.3), wallRotation = 87, areaPosition = Vector3(801.5957, -1154.6094, 30), width = 139, height = 155},
	{wallPosition = Vector3(1237.9, -916.40002, 43.1), wallRotation = 280, areaPosition = Vector3(1156.7124, -850.0401, 30), width = 185, height = 75},
	{wallPosition = Vector3(382.70001, -1875.7, 8.2), wallRotation = 92, areaPosition = Vector3(342.92822, -1796.2261, 30), width = 75, height = 320},
	{wallPosition = Vector3(1065.2, -1617.6, 21.1), wallRotation = 0, areaPosition = Vector3(1035.9404, -1575.9678, 30), width = 111, height = 90},
	{wallPosition = Vector3(474.60001, -1517.6, 20.8), wallRotation = 0, areaPosition = Vector3(425.46933, -1443.4115, 30), width = 102, height = 135},
	{wallPosition = Vector3(2808.8999, -1426.1, 40.5), wallRotation = 270.75, areaPosition = Vector3(2786.498, -1422.0381, 30), width = 43, height = 55},
	{wallPosition = Vector3(2822.2, -2383.2, 12.5), wallRotation = 180.25, areaPosition = Vector3(2805.8359, -2314.9021, 30), width = 53, height = 230},
	{wallPosition = Vector3(2274.7, -68.9, 27), wallRotation = 0, areaPosition = Vector3(2221.5364, -25.009064, 30), width = 122, height = 75},
	{wallPosition = Vector3(731.29999, -1337.2, 13.9), wallRotation = 0, areaPosition = Vector3(636.13751, -1316.6031, 30), width = 162, height = 80},
	{wallPosition = Vector3(1084.5, -1219.5, 18.2), wallRotation = 0, areaPosition = Vector3(1061.6533, -1147.5967, 30), width = 160, height = 135},
	{wallPosition = Vector3(2761.8999, -2015.6, 13.9), wallRotation = 0, areaPosition = Vector3(2720.2043, -1893.7759, 30), width = 100, height = 155},


	-- Regex to get table from map file
	--[[
		areaY=(.*) height=(.*) areaX=(.*) maxZ=(.*) width=(.*) posX=(.*) posY=(.*) posZ=(.*) rotX=(.*) rotY=(.*) rotZ=(.*)
		1			2			3			4			5		6			7			8		9			10		11
		{wallPosition = Vector3\(\6, \7, \8\), wallRotation = \11, areaPosition = Vector3\(\3, \1, \4\), width = \5, height = \2},
	]]
}
-- Fix positions (creation tool is wrong, but I'm too lazy to fix the coordinates manually)
for k, v in pairs(GangAreaData) do
	GangAreaData[k].areaPosition = Vector3(v.areaPosition.x, v.areaPosition.y - v.height, v.areaPosition.z)
end

TURFING_STOPREASON_LEAVEAREA = 1
TURFING_STOPREASON_NEWOWNER = 2
TURFING_STOPREASON_DEFENDED = 3

SkinInfo = {
	-- skinId -- skinName -- skinPrice
	[0] = {"CJ", 5000},
	[130] = {"Native Ugly", 100},
	[157] = {"Farmer Girl", 500},
	[27] = {"Construction Worker (YMCA)", 750},
	[30] = {"Drug Dealer", 750},
	[82] = {"Black Elvis", 1000},
	[87] = {"Stripper", 600},
	[299] = {"Claude Speed", 950},
	--[289] = {"Zero", 800}, -- does not work
	[269] = {"Big Smoke", 2000},
	[264] = {"Clown", 75},
	[254] = {"Biker", 300},
	[249] = {"PIMP", 2500},
	[248] = {"Blonde Biker", 300},
	[241] = {"Afro", 100},
	[216] = {"Noble Lady", 900},
	[227] = {"Oriental Businessman", 1500},
	[220] = {"African", 500},
	[219] = {"Rich Woman", 1200},
	-- [208] = {"Suximu", 120}, -- does not work
	[200] = {"Hillbilly", 100},
	[195] = {"Denise Robinson", 200},
	[188] = {"Guy with green shirt", 200},
	[187] = {"Businessman 2", 1000},
	[185] = {"Latino", 350},
	[181] = {"Punk", 500},
	[173] = {"Rifa", 500},
	[174] = {"Rifa 2", 500},
	[163] = {"FBI", 1000},
	[164] = {"FBI 2", 1000},
}

MAX_KARMA_LEVEL = 150

VehicleSpecialProperty = {Color = -1, LightColor = -2}

Tasks = {
	TASK_GUARD = 1,
	TASK_SHOOT_TARGET = 2,
	TASK_GETTING_TARGETTED = 3,
}

VehiclePositionType = {World = 0, Garage = 1, Mechanic = 2, Hangar = 3}

GROUP_RENAME_TIMEOUT = 60*60*24*30 -- 30 Days (in seconds)

GARAGE_UPGRADES_COSTS = {[1] = 200000, [2] = 250000, [3] = 500000}
HANGAR_UPGRADES_COSTS = {[1] = 9999999, [2] = 0, [3] = 0}
GARAGE_UPGRADES_TEXTS = {[0] = "Garage: keine Garage", [1] = "Garage: Standard Garage", [2] = "Garage: Komfortable Garage", [3] = "Garage: Luxus Garage"}
HANGAR_UPGRADES_TEXTS = {[0] = "Hangar: kein Hangar", [1] = "Hangar: Unkown Hangar", [2] = "Hangar: Unkown Hangar", [3] = "Hangar: Unkown Hangar"}

WEAPONTRUCK_MAX_LOAD = 10000

PlayerAttachObjects = {
	[1550] = {["model"] = 1550, ["name"] = "Geldsack", ["pos"] = Vector3(0, -0.3, 0.3), ["rot"] = Vector3(0, 0, 180)},
	[2912] = {["model"] = 2912, ["name"] = "Waffenkiste", ["pos"] = Vector3(-0.09, 0.35, 0.45), ["rot"] = Vector3(10, 0, 0)}
}

PLAYER_DEATH_TIME = 3*60*1000
VEHICLE_SPECIAL_SMOKE = {[512] = true, [513] = true}

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

AD_COLORS = {"Orange", "Grün", "Hell-Blau"}

AD_DURATIONS = {
	["20 Sekunden"] = 20,
	["30 Sekunden"] = 30,
	["45 Sekunden"] = 45
}
