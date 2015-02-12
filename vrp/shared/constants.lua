MAX_CHARACTERS = 5
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
	Damage = {id = 2, text = "Körperverletzung", maxwanted = 2, maxdistance = 80},
	Hotwire = {id = 3, text = "Fahrzeug kurzgeschlossen", maxwanted = 2, maxdistance = 400},
	BankRobbery = {id = 4, text = "Banküberfall", maxwanted = 6, maxdistance = math.huge},
	JailGateOpen = {id = 5, text = "Unberechtigtes Öffnen der Gefängnisschleuse", maxwanted = 3, maxdistance = 2000},
	JailCellsOpen = {id = 6, text = "Beihilfe zum Massengefängnisausbruch", maxwanted = 6, maxdistance = 3000},
	JailBreak = {id = 7, text = "Gefängnisausbruch", maxwanted = 4, maxdistance = 3000},
	PlacingBomb = {id = 8, text = "Legen einer Bombe", maxwanted = 6, maxdistance = 5000},
	HouseRob = {id = 9, text = "Einbruch", maxwanted = 3, maxdistance = math.huge},
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

GangAreaData = {
	{wallPosition = Vector3(2526.3, -1665.1, 15.4), wallRotation = 180, areaPosition = Vector3(2448.5, -1679.4, 25), width = 100, height = 100, resources = 1000},
	{wallPosition = Vector3(2251, -1408.2002, 24.4), wallRotation = 270, areaPosition = Vector3(2220.6563, -1443.9, 25), width = 115, height = 100, resources = 1200},
	{wallPosition = Vector3(663.5, -1208.9004, 18.2), wallRotation = 127.9, areaPosition = Vector3(647.29901, -1261.09, 30), width = 150, height = 100, resources = 2000},
}
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
