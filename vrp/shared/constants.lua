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
			[445] = 3750,
			[527] = 4000,
			[542] = 6000,
			[585] = 7500,
			[546] = 5700,
			[404] = 3000,
			[600] = 7200,
			[479] = 3700,
			[543] = 2700,
			[567] = 8000,
			[439] = 6500,
			[566] = 5000,
			[549] = 3500,
			[491] = 5000
		};
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
	Hotwire = {id = 3, text = "Fahrzeug kurzgeschlossen", maxwanted = 2},
	BankRobbery = {id = 4, text = "Banküberfall", maxwanted = 6, maxdistance = math.huge},
	JailGateOpen = {id = 5, text = "Unberechtigtes Öffnen der Gefängnisschleuse", maxwanted = 3, maxdistance = 2000},
	JailCellsOpen = {id = 6, text = "Beihilfe zum Massengefängnisausbruch", maxwanted = 6, maxdistance = 3000},
	JailBreak = {id = 7, text = "Gefängnisausbruch", maxwanted = 4, maxdistance = 3000},
	PlacingBomb = {id = 8, text = "Legen einer Bombe", maxwanted = 6, maxdistance = 5000},
}

AmmuNationInfo = {
	
	[30] = {
		Magazine = {price=30,amount=30},
		Weapon = 1850,
	},	
	[31] = {
		Magazine = {price=60,amount=50},
		Weapon = 2500,
	},	
	[29] = {
		Magazine = {price=40,amount=30},
		Weapon = 1000,
	},
	[25] = {
		Magazine = {price=2,amount=1},
		Weapon = 1500,
	},
	[22] = {
		Magazine = {price=15,amount=17},
		Weapon = 450,
	},	
	[23] = {
		Magazine = {price=15,amount=17},
		Weapon = 600,
	},	
}

GangAreaData = {
	{wallPosition = Vector(2526.3, -1665.1, 15.4), wallRotation = 180, areaPosition = Vector(2448.5, -1679.4, 25), width = 100, height = 100, resources = 1000},
	{wallPosition = Vector(2251, -1408.2002, 24.4), wallRotation = 270, areaPosition = Vector(2220.6563, -1443.9, 25), width = 115, height = 100, resources = 1200},
	{wallPosition = Vector(663.5, -1208.9004, 18.2), wallRotation = 127.9, areaPosition = Vector(647.29901, -1261.09, 30), width = 150, height = 100, resources = 2000},
}
TURFING_STOPREASON_LEAVEAREA = 1
TURFING_STOPREASON_NEWOWNER = 2
TURFING_STOPREASON_DEFENDED = 3
