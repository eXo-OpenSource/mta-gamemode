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

VEHICLESHOPS = {
	["Coutt and Schutz"] = {
		ImgPath = "files/images/CouttSchutz.png";
		Position = {2132, -1150.3, 23};
		Rect = {2141.3, -1207.74, 24.47, 76.15};
		Spawn = {2148.2, -1179.96, 23.5, 90};
		Vehicles = {
			[536] = 7200, -- Blade
			[518] = 8300, -- Buccaneer
			[540] = 9000, -- Vincent
			[589] = 11000, -- Club
			[533] = 11300, -- Feltzer
			[561] = 13000, -- Stratum
			[402] = 14000, -- Buffallo
			[400] = 14500, -- Landstalker
			[550] = 16000, -- Sunrise
			[603] = 17000, -- Phoenix
			[489] = 17000, -- Rancher
			[560] = 19000, -- Sultan
		};
	};
	["Bertram's bobbycars"] = {
		ImgPath = "files/images/Bertrams.png";
		Position = {310.39999, -1798.5, 3.5};
		Rect = {308.8, -1812.5, 20, 20};
		Spawn = {321.70001, -1789.6, 4.7};
		Vehicles = {
			[543] = 2700, -- Sadler
			[404] = 3000, -- Perennial
			[549] = 3500, -- Tampa
			[479] = 3700, -- Regina
			[445] = 3750, -- Admiral
			[527] = 4000, -- Cadrona
			[566] = 5000, -- Tahoma
			[491] = 5000, -- Virgo
			[546] = 5700, -- Intruder
			[542] = 6000, -- Clover
			[600] = 7200, -- Picador
			[585] = 7500, -- Emperor
			[439] = 6500, -- Stallion
			[567] = 8000, -- Savanna
		};
	};
	["Harry's bikes"] = {
		ImgPath = "files/images/HarrysBikes.png";
		Position = {1310.2, -1368.3, 12.5};
		Rect = {1271.5, -1384.4, 12, 12};
		Spawn = {1274.9, -1373.6, 13.1};
		Vehicles = {
			[581] = 8000, -- BF-400
			[521] = 8000, -- FCR-900
			[463] = 12000, -- Freeway
			[522] = 16000, -- NRG-500
			[461] = 9000, -- PCJ-600
			[468] = 4500, -- Sanchez
		}
	};
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

Crime = {
	Kill = {id = 1, text = "Mord", maxwanted = 4, maxdistance = 1500},
	Hotwire = {id = 2, text = "Fahrzeug kurzgeschlossen", maxwanted = 2, maxdistance = 400},
	BankRobbery = {id = 3, text = "Banküberfall", maxwanted = 6, maxdistance = math.huge},
	JailBreak = {id = 4, text = "Gefängnisausbruch", maxwanted = 4, maxdistance = math.huge},
	PlacingBomb = {id = 5, text = "Legen einer Bombe", maxwanted = 6, maxdistance = 5000},
	HouseRob = {id = 6, text = "Einbruch", maxwanted = 3, maxdistance = math.huge},
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
		Weapon = 1500,
		MinLevel = 5,
	},
	[22] = { -- Pistol
		Magazine = {price=15,amount=17},
		Weapon = 450,
		MinLevel = 3,
	},
	[23] = { -- Silenced Pistol
		Magazine = {price=15,amount=17},
		Weapon = 600,
		MinLevel = 3,
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
	{wallPosition = Vector3(920.29999, -1231.7, 17.3), wallRotation = 87, areaPosition = Vector3(801.5957, -1154.6094, 30), width = 139, height = 155},
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
	[289] = {"Zero", 800},
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
	[208] = {"Suximu", 120},
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

VehicleSpecialProperty = {Color = -1}
