factionColors = {}
factionCarColors = {}
factionRankNames = {}
factionSkins = {}
factionWeapons = {}
evilFactionInteriorEnter = {}
factionWTDestination = {}

TICKET_PRICE = 2000



FACTION_STATE_WT_DESTINATION = Vector3(1598.78064, -1611.63953, 12.5)
WEAPONTRUCK_NAME = {["evil"] = "Waffentruck", ["state"] = "Staats-Waffentruck"}
WEAPONTRUCK_NAME_SHORT = {["evil"] = "Waffentruck", ["state"] = "Staats-WT"}

WEAPONTRUCK_MIN_MEMBERS = {["evil"] = 3, ["state"] = 3}
BANKROB_MIN_MEMBERS = DEBUG and 0 or 5
WEEDTRUCK_MIN_MEMBERS = 3
SHOPROB_MIN_MEMBERS = 3
HOUSEROB_MIN_MEMBERS = 2

FACTION_MAX_RANK_LOANS ={
	[0] = 750,
	[1] = 1000,
	[2] = 1500,
	[3] = 1750,
	[4] = 2000,
	[5] = 2500,
	[6] = 3000
}

FACTION_MIN_RANK_KARMA = {
	[0] = 1;
	[1] = 25;
	[2] = 50;
	[3] = 75;
	[4] = 100;
	[5] = 125;
	[6] = 150;
}

-- Vehicle Shaders
factionVehicleShaders = {
	-- SAPD
	[1] = {
		[560] = {shaderEnabled = true, textureName = "#emapsultanbody256", texturePath = "files/images/Textures/PoliceTexture.png"};
		[596] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/PoliceTexture.png"};
		[598] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/PoliceTexture.png"};
		[599] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/PoliceTexture.png"};
		[497] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/PoliceTexture.png"};

	};

	-- FBI
	[2] = {
		[528] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/FBITexture.png"};
		[601] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/FBITexture.png"};
		[497] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/FBITexture.png"};
	};

	-- Army
	[3] = {
		[497] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/Empty.png"};
		[470] = {shaderEnabled = true, textureName = "vehiclegrunge256", texturePath = "files/images/Textures/Special/6.png"};
	};

	-- Rescue
	[4] = {
		[416] = {shaderEnabled = true, textureName = "ambulan92decal128", texturePath = "files/images/Textures/RescueTexture.png"};
		[599] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/RescueTexture2.png"};
		[497] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/RescueTexture2.png"};
	};
}

-- ID 1 = Police Departement:
factionRankNames[1] = {
[0] = "Cadet",
[1] = "Officer",
[2] = "Detective",
[3] = "Lieutnant",
[4] = "Captain",
[5] = "Deputy",
[6] = "Chief"
}
factionColors[1] = {["r"] = 0,["g"] = 255,["b"] = 255}
factionCarColors[1] = {["r"] = 0,["g"] = 0,["b"] = 0, ["r1"] = 255,["g1"] = 255,["b1"] = 255}
factionSkins[1] = {[93]=true,[265]=true, [266]=true, [267]=true,[280]=true,[281]=true,[282]=true, [283]=true, [284]=true, [288]=true}
factionWeapons[1] = {[3]=true,[23]=true,[24]=true,[25]=true,[29]=true,[31]=true, [34]=true}
factionWTDestination[1] = Vector3(1524.96, -1440.70, 12.3)

-- ID 2 = FBI:
factionRankNames[2] = {
[0] = "Probationary Agent",
[1] = "Special Agent",
[2] = "Senior Special Agent",
[3] = "Supervisory Special Agent",
[4] = "Section Chief",
[5] = "Deputy Director",
[6] = "FBI-Director"
}
factionColors[2] = {["r"] = 0,["g"] = 50,["b"] = 255}
factionCarColors[2] = {["r"] = 0,["g"] = 0,["b"] = 0, ["r1"] = 0,["g1"] = 0,["b1"] = 0}
factionSkins[2] = {[163]=true, [164]=true, [165]=true,[166]=true,[285]=true,[286]=true,[294]=true,[295]=true}
factionWeapons[2] = {[3]=true, [23]=true, [24]=true,[25]=true,[29]=true,[31]=true, [34]=true}
factionWTDestination[2] = Vector3(1524.96, -1440.70, 12.3)

-- ID 3 = Army:
factionRankNames[3] = {
[0] = "Private",
[1] = "Corporal",
[2] = "Staff Sergeant",
[3] = "Warrant Officer",
[4] = "Major",
[5] = "Colonel",
[6] = "General"
}
factionColors[3] = {["r"] = 0,["g"] = 125,["b"] = 0}
factionCarColors[3] = {["r"] = 215,["g"] = 200,["b"] = 100, ["r1"] = 215,["g1"] = 200,["b1"] = 100}
factionSkins[3] = {[73]=true,[191]=true,[287]=true,[312]=true, [70]=true}
factionWeapons[3] = {[6]=true,[23]=true, [24]=true,[29]=true,[31]=true,[16]=true,[17]=true,[45]=true, [34]=true}
factionWTDestination[3] = Vector3(1524.96, -1440.70, 12.3)

-- ID 4 = Rescue Team:
factionRankNames[4] = {
	[0] = "Trainee",
	[1] = "Assistant",
	[2] = "Paramedic",
	[3] = "Engineer",
	[4] = "Battalion Chief",
	[5] = "Division Chief",
	[6] = "Commissioner"
}
factionColors[4] = {["r"] = 255, ["g"] = 120, ["b"] = 0}
factionCarColors[4] = {["r"] = 255, ["g"] = 255, ["b"] = 255, ["r1"] = 178, ["g1"] = 35, ["b1"] = 33}
factionSkins[4] = {[27]=true, [277]=true, [278]=true, [279]=true,[70]=true, [71]=true, [274]=true, [275]=true, [276]=true, [70]=true}
factionWeapons[4] = {[9]=true}

-- ID 5 = La Cosa Nostra:
factionRankNames[5] = {
[0] = "Giovane D'Honore",
[1] = "Picciotto",
[2] = "Sgarrista",
[3] = "Caporegime",
[4] = "Consigliere",
[5] = "Capo Bastone",
[6] = "Capo Crimini"
}
factionColors[5] = {["r"] = 100,["g"] = 100,["b"] = 100}
factionCarColors[5] = {["r"] = 10,["g"] = 10,["b"] = 10, ["r1"] = 10,["g1"] = 10,["b1"] = 10}
factionSkins[5] = {[111]=true, [112]=true, [113]=true, [124]=true, [125]=true, [126]=true, [127]=true,[237]=true,[272]=true}
factionWeapons[5] = {[2]=true, [24]=true, [25]=true, [26]=true, [29]=true, [30]=true, [31]=true, [33]=true, [34]=true}
evilFactionInteriorEnter[5] = Vector3(691.58, -1275.94, 13.56)
factionWTDestination[5] = Vector3(722.1865234375,-1198.2119140625,18.6)
--factionWTDestination[5] = Vector3(-1855.22, 1409.12, 7.19) --TESTING

-- ID 6 = Yakuza
factionRankNames[6] = {
[0] = "Aonisai",
[1] = "Menba",
[2] = "Kaikei",
[3] = "Shingiin",
[4] = "Shateigashira",
[5] = "Kobun",
[6] = "Oyabun"
}
factionColors[6] = {["r"] = 140,["g"] = 20,["b"] = 0}
factionCarColors[6] = {["r"] = 140,["g"] = 20,["b"] = 0, ["r1"] = 140,["g1"] = 20,["b1"] = 0}
factionSkins[6] = {[121]=true, [123]=true, [203]=true, [122]=true, [186]=true, [294]=true, [228]=true,[224]=true, [49]=true, [141]=true}
factionWeapons[6] = {[1]=true, [8]=true, [24]=true, [25]=true, [29]=true, [30]=true, [31]=true, [33]=true, [34]=true}
evilFactionInteriorEnter[6] = Vector3( 1419.80, -1353.06, 13.56)
factionWTDestination[6] = Vector3( 1418.18, -1240.70, 13.38)

-- ID 7 = Grove
factionRankNames[7] = {
[0] = "Newbie",
[1] = "Hoody",
[2] = "Homeboy",
[3] = "Pimp",
[4] = "Violent",
[5] = "Cuzz",
[6] = "Junkie"
}
factionColors[7] = {["r"] = 18,["g"] = 140,["b"] = 52}
factionCarColors[7] = {["r"] = 18,["g"] = 140,["b"] = 52, ["r1"] = 18,["g1"] = 140,["b1"] = 52}
factionSkins[7] = {[105]=true, [106]=true, [107]=true, [269]=true, [270]=true, [271]=true, [293]=true, [300]=true, [301]=true, [311]=true}
factionWeapons[7] = {[5]=true, [24]=true, [25]=true, [28]=true, [29]=true, [30]=true, [31]=true, [33]=true, [34]=true}
evilFactionInteriorEnter[7] = Vector3(2459.54, -1690.76, 13.4)
factionWTDestination[7] = Vector3(2495.0478515625,-1667.689453125,12.96682834625)

-- ID 8 = Ballas
factionRankNames[8] = {
[0] = "Serbant",
[1] = "Newcomer",
[2] = "Dealer",
[3] = "Smoker",
[4] = "Homie",
[5] = "OG.Nigga",
[6] = "Big Boss"
}
factionColors[8] = {["r"] = 200,["g"] = 0,["b"] = 255}
factionCarColors[8] = {["r"] = 200,["g"] = 0,["b"] = 255, ["r1"] = 200,["g1"] = 0,["b1"] = 255}
factionSkins[8] = {[13]=true, [102]=true, [103]=true, [104]=true, [195]=true, [296]=true, [297]=true, [304]=true}
factionWeapons[8] = {[5]=true, [24]=true, [25]=true, [32]=true, [29]=true, [30]=true, [31]=true, [33]=true, [34]=true}
evilFactionInteriorEnter[8] = Vector3(2232.70, -1436.40, 24.90)
factionWTDestination[8] = Vector3(2212.42, -1435.53, 22.5)

-- ID 9 = Biker
factionRankNames[9] = {
[0] = "Hangaround",
[1] = "Prospect",
[2] = "Patch Member",
[3] = "Road Captain",
[4] = "Sergeant at Arms",
[5] = "Vice-President",
[6] = "President"
}
factionColors[9] = {["r"] = 150,["g"] = 100,["b"] = 100}
factionCarColors[9] = {["r"] = 150,["g"] = 100,["b"] = 100, ["r1"] = 150,["g1"] = 100,["b1"] = 100}
factionSkins[9] = {[100]=true, [181]=true, [242]=true, [247]=true, [248]=true, [254]=true, [291]=true,[298]=true,[299]=true}
factionWeapons[9] = {[7]=true, [18]=true, [24]=true, [26]=true, [29]=true, [30]=true, [31]=true, [33]=true, [34]=true}
evilFactionInteriorEnter[9] =  Vector3(687.20, -445.40, 16.3)
factionWTDestination[9] =   Vector3(659.80,-463.10,15.30)



-- ID 10 = Vatos
factionRankNames[10] = {
[0] = "Novivo",
[1] = "Miembro",
[2] = "Trepador",
[3] = "Veterano",
[4] = "Derecha",
[5] = "Guerriero",
[6] = "Jeffe Boss"
}
factionColors[10] = {["r"] = 255,["g"] = 252,["b"] = 170}
factionCarColors[10] = {["r"] = 255,["g"] = 252,["b"] = 170, ["r1"] = 255,["g1"] = 252,["b1"] = 170}
factionSkins[10] = {[108]=true, [109]=true, [110]=true, [114]=true, [115]=true, [116]=true, [173]=true,[174]=true,[175]=true,[292]=true}
factionWeapons[10] = {[5]=true, [24]=true, [26]=true, [29]=true, [30]=true, [31]=true, [33]=true, [34]=true,[32] = true}
evilFactionInteriorEnter[10] =Vector3(2880.46, -2158.97, 4.26)
factionWTDestination[10] = Vector3(2844.1006, -2147.5, 7.8)

-- General:
factionWeaponDepotInfo = {
	[1] = {["Waffe"] = 10, ["Magazine"] = 0, ["WaffenPreis"] = 10, ["MagazinPreis"] = 0}, -- Brass Knuckles
	[2] = {["Waffe"] = 10, ["Magazine"] = 0, ["WaffenPreis"] = 10, ["MagazinPreis"] = 0}, -- Golf Club
	[3] = {["Waffe"] = 10, ["Magazine"] = 0, ["WaffenPreis"] = 10, ["MagazinPreis"] = 0}, -- Nightstick
	[4] = {["Waffe"] = 10, ["Magazine"] = 0, ["WaffenPreis"] = 10, ["MagazinPreis"] = 0}, -- Knife
	[5] = {["Waffe"] = 10, ["Magazine"] = 0, ["WaffenPreis"] = 10, ["MagazinPreis"] = 0}, -- Baseball Bat
	[6] = {["Waffe"] = 10, ["Magazine"] = 0, ["WaffenPreis"] = 10, ["MagazinPreis"] = 0}, -- Shovel
	[7] = {["Waffe"] = 10, ["Magazine"] = 0, ["WaffenPreis"] = 10, ["MagazinPreis"] = 0}, -- Pool Cue
	[8] = {["Waffe"] = 10, ["Magazine"] = 0, ["WaffenPreis"] = 10, ["MagazinPreis"] = 0}, -- Katana
	[9] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Chainsaw
	[10] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Long Purple Dildo
	[11] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Short tan Dildo
	[12] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Vibrator
	[14] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Flowers
	[15] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Cane
	[16] = {["Waffe"] = 10, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Grenade
	[17] = {["Waffe"] = 10, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Tear Gas
	[18] = {["Waffe"] = 10, ["Magazine"] = 0, ["WaffenPreis"] = 80, ["MagazinPreis"] = 0}, -- Molotov Cocktails
	[22] = {["Waffe"] = 20, ["Magazine"] = 50, ["WaffenPreis"] = 140, ["MagazinPreis"] = 20}, -- Pistol
	[23] = {["Waffe"] = 10, ["Magazine"] = 40, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Taser
	[24] = {["Waffe"] = 10, ["Magazine"] = 20, ["WaffenPreis"] = 550, ["MagazinPreis"] = 100}, -- Deagle
	[25] = {["Waffe"] = 16, ["Magazine"] = 100, ["WaffenPreis"] = 170, ["MagazinPreis"] = 3}, -- Shotgun
	[26] = {["Waffe"] = 8, ["Magazine"] = 30, ["WaffenPreis"] = 0, ["MagazinPreis"] = 5}, -- Sawn-Off Shotgun
	[27] = {["Waffe"] = 8, ["Magazine"] = 16, ["WaffenPreis"] = 0, ["MagazinPreis"] = 60}, -- SPAZ-12 Combat Shotgun
	[28] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Uzi
	[29] = {["Waffe"] = 20, ["Magazine"] = 60, ["WaffenPreis"] = 180, ["MagazinPreis"] = 50}, -- MP5
	[30] = {["Waffe"] = 20, ["Magazine"] = 60, ["WaffenPreis"] = 480, ["MagazinPreis"] = 75}, -- AK47
	[31] = {["Waffe"] = 15, ["Magazine"] = 40, ["WaffenPreis"] = 540, ["MagazinPreis"] = 85}, -- M4
	[32] = {["Waffe"] = 20, ["Magazine"] = 60, ["WaffenPreis"] = 200, ["MagazinPreis"] = 70}, -- Tec9
	[33] = {["Waffe"] = 10, ["Magazine"] = 60, ["WaffenPreis"] = 400, ["MagazinPreis"] = 5}, -- County Rifle
	[34] = {["Waffe"] = 5, ["Magazine"] = 15, ["WaffenPreis"] = 5000, ["MagazinPreis"] = 100}, -- Sniper
	[35] = {["Waffe"] = 3, ["Magazine"] = 9, ["WaffenPreis"] = 2000, ["MagazinPreis"] = 500}, -- Rocket Launcher
	[36] = {["Waffe"] = 3, ["Magazine"] = 9, ["WaffenPreis"] = 3000, ["MagazinPreis"] = 700}, -- Heat-Seeking RPG
	[37] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Flamethrower
	[38] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Minigun
	[39] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Satchel Charges
	[40] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Satchel Detonator
	[41] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Spraycan
	[42] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Fire Extinguisher
	[43] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Camera
	[44] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Night-Vision Goggles
	[45] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0}, -- Infrared Goggles
	[46] = {["Waffe"] = 0, ["Magazine"] = 0, ["WaffenPreis"] = 0, ["MagazinPreis"] = 0} -- Parachute
}

factionWeaponDepotInfoState = {}
for index, key in pairs(factionWeaponDepotInfo) do
	factionWeaponDepotInfoState[index] = {
		["Waffe"] = key["Waffe"]*4,
		["Magazine"] = key["Magazine"]*4,
		["WaffenPreis"] = key["WaffenPreis"],
		["MagazinPreis"] = key["MagazinPreis"]
		}
end
