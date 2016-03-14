factionColors = {}
factionRankNames = {}
factionSkins = {}
factionWeapons = {}
evilFactionInteriorEnter = {}
factionWTDestination = {}

FACTION_STATE_WT_DESTINATION = Vector3(1598.78064, -1611.63953, 13.44956)
WEAPONTRUCK_NAME = {["evil"] = "Waffentruck", ["state"] = "Staats-Waffentruck"}

FACTION_MAX_RANK_LOANS ={
	[0] = 750,
	[1] = 1000,
	[2] = 1500,
	[3] = 1750,
	[4] = 2000,
	[5] = 2500,
	[6] = 3000
}

-- Vehicle Shaders
factionVehicleShaders = {
	-- SAPD
	[1] = {
		[596] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/PoliceTexture.png"};
		[599] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/PoliceTexture.png"};
		[497] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/PoliceTexture.png"};
	};

	-- FBI
	[2] = {
		[528] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/FBITexture.png"};
		[601] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/FBITexture.png"};
		[497] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/FBITexture.png"};
	};

	-- Rescue
	[4] = {
		[416] = {shaderEnabled = true, textureName = "ambulan92decal128", texturePath = "files/images/Textures/RescueTexture.png"};
		[599] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/RescueTexture2.png"};
		[497] = {shaderEnabled = true, textureName = "vehiclepoldecals128", texturePath = "files/images/Textures/RescueTexture2.png"};
	}
}

-- ID 1 = Police Departement:
factionRankNames[1] = {
[0] = "Cadet",
[1] = "Officer",
[2] = "Detective",
[3] = "Captain",
[4] = "Lieutnant",
[5] = "Deputy",
[6] = "Chief"
}
factionColors[1] = {["r"] = 11,["g"] = 102,["b"] = 8}
factionSkins[1] = {[93]=true,[265]=true, [266]=true, [267]=true,[280]=true,[281]=true,[282]=true, [283]=true, [284]=true, [288]=true}
factionWeapons[1] = {[3]=true,[24]=true,[25]=true,[29]=true,[31]=true}
factionWTDestination[1] = Vector3(2716.21, -2413.49, 13)

-- ID 2 = FBI:
factionRankNames[2] = {
[0] = "Probationary Agent",
[1] = "Agent",
[2] = "Special Agent",
[3] = "Supervisory Special Agent",
[4] = "Section Chief",
[5] = "Deputy Director",
[6] = "FBI-Director"
}
factionColors[2] = {["r"] = 96,["g"] = 96,["b"] = 96}
factionSkins[2] = {[163]=true, [164]=true, [165]=true,[166]=true,[285]=true,[286]=true,[294]=true,[295]=true}
factionWeapons[2] = {[24]=true,[27]=true,[29]=true,[31]=true}
factionWTDestination[2] = Vector3(2716.21, -2413.49, 13)

-- ID 3 = Army:
factionRankNames[3] = {
[0] = "Private",
[1] = "Corporal",
[2] = "Staff Sergeant",
[3] = "Major",
[4] = "Warrant Officer",
[5] = "Colonel",
[6] = "General"
}
factionColors[3] = {["r"] = 0,["g"] = 125,["b"] = 0}
factionSkins[3] = {[73]=true,[191]=true,[287]=true,[312]=true}
factionWeapons[3] = {[6]=true,[24]=true,[29]=true,[31]=true,[16]=true,[17]=true,[45]=true}
factionWTDestination[3] = Vector3(2716.21, -2413.49, 13)

-- ID 4 = Rescue Team:
factionRankNames[4] = {
[0] = "Rescue-Trainee",
[1] = "Rescue-Assistant",
[2] = "Rescue-Member",
[3] = "Chief of Operations",
[4] = "Rescue-Secretary",
[5] = "Rescue-Deputy",
[6] = "Rescue-Chief"
}
--factionColors[4] = {["r"] = 255,["g"] = 85,["b"] = 0}
factionColors[4] = {["r"] = 187,["g"] = 0,["b"] = 0}
factionSkins[4] = {[260]=true, [277]=true, [278]=true, [279]=true,[70]=true, [71]=true, [274]=true, [275]=true, [276]=true}
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
factionSkins[5] = {[111]=true, [112]=true, [113]=true, [124]=true, [125]=true, [126]=true, [127]=true,[237]=true,[272]=true}
factionWeapons[5] = {[4]=true, [22]=true, [24]=true, [25]=true, [26]=true, [29]=true, [33]=true, [34]=true}
evilFactionInteriorEnter[5] = {["x"] = 691.58, ["y"]= -1275.94, ["z"] = 13.56}
factionWTDestination[5] = Vector3(722.1865234375,-1198.2119140625,18.6)
--factionWTDestination[5] = Vector3(-1855.22, 1409.12, 7.19) --TESTING

-- ID 6 = Yakuza
factionRankNames[6] = {
[0] = "Oyabun",
[1] = "Saiko-Kamon",
[2] = "Wakagashira",
[3] = "Shateigashira",
[4] = "Shingiin",
[5] = "Kyodai",
[6] = "Shatei"
}
factionColors[6] = {["r"] = 140,["g"] = 20,["b"] = 0}
factionSkins[6] = {[49]=true, [57]=true, [59]=true, [120]=true, [122]=true, [123]=true, [141]=true,[60]=true,[58]=true}
factionWeapons[6] = {[8]=true,[24]=true,[25]=true,[29]=true,[41]=true}
evilFactionInteriorEnter[6] = {["x"] = 691.58, ["y"]= -1275.94, ["z"] = 13.56}
factionWTDestination[6] = Vector3(708.103515625,-1436.1279296875,13.5390625)

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
	[34] = {["Waffe"] = 5, ["Magazine"] = 15, ["WaffenPreis"] = 690, ["MagazinPreis"] = 8}, -- Sniper
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
