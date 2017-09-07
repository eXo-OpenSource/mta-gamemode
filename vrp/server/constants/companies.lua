companyColors = {}
companyRankNames = {}
companySkins = {}
companyDutyMarker = {}
companyDutyMarkerInterior = {}
companyDutyMarkerDimension = {}
companySpawnpoint = {}

COMPANY_MAX_RANK_LOANS ={
	[0] = 750,
	[1] = 1000,
	[2] = 1250,
	[3] = 1500,
	[4] = 1750,
	[5] = 2000
}

-- Vehicle Shaders
companyVehicleShaders = {
	-- M&T
	[2] = {
		[552] = {shaderEnabled = true, textureName = "trash92decal128", texturePath = "files/images/Textures/MechanicTexture.png"};
		[459] = {shaderEnabled = true, textureName = "topfun92decals128", texturePath = "files/images/Textures/MechanicTexture2.png"};
	};

	-- EPT
	[4] = {
		[431] = {shaderEnabled = true, textureName = "bus92decals128", texturePath = "files/images/Textures/BusTexture.png"};
	};
}

-- ID 1 = Fahrschule:
companyRankNames[1] = {
[0] = "Praktikant",
[1] = "Auszubildender",
[2] = "Fahrlehrer",
[3] = "Ausbilder",
[4] = "Geschäftsführer Stellv.",
[5] = "Geschäftsführer"
}
companyColors[1] = {["r"] = 255,["g"] = 255,["b"] = 255}
companySkins[1] = {[217]=true, [226]=true, [250]=true, [290]=true, [295]=true,[296]=true,[299]=true}
companyDutyMarker[1] = Vector3(-2023.07, -114.14, 1035.17)
companyDutyMarkerInterior[1] = 3
companySpawnpoint[1] = {Vector3(-2029.85, -116.75, 1035.17), 3, 0}

-- ID 2 = Mech & Tow:
companyRankNames[2] = {
[0] = "Hilfsarbeiter",
[1] = "Hobbyschrauber",
[2] = "Mechaniker-Lehrling",
[3] = "Mechaniker",
[4] = "Chef-Mechaniker",
[5] = "Geschäftsführer"
}
companyColors[2] = {["r"] = 0,["g"] = 220,["b"] = 255}
companySkins[2] = {[36]=true, [44]=true, [50]=true,[192]=true,[268]=true}
companyDutyMarker[2] = Vector3(857.006, -1183.823, 17.269)
companySpawnpoint[2] = {Vector3(854.230, -1186.297, 17.269), 0, 0}

-- ID 3 = SAN News:
companyRankNames[3] = {
[0] = "Zeitungsjunge",
[1] = "Klatschtante",
[2] = "Zeitungsreporter",
[3] = "Reporter",
[4] = "Journalist",
[5] = "Chefredakteur"
}
companyColors[3] = {["r"] = 255, ["g"] = 170, ["b"] = 0}
companySkins[3] = {[59]=true,[141]=true,[186]=true,[187]=true,[188]=true,[189]=true}
companyDutyMarker[3] = Vector3(735.65, -1348.45, 13.51)
companySpawnpoint[3] = {Vector3(735.97, -1338.20, 13.53), 0, 0}

-- ID 4 = Public Transport:
companyRankNames[4] = {
[0] = "Polierer",
[1] = "Taxifahrer",
[2] = "Kassierer",
[3] = "Busfahrer",
[4] = "Fahrzeugverwalter",
[5] = "Transportmanager"
}
companyColors[4] = {["r"] = 255, ["g"] = 210, ["b"] = 0}
companySkins[4] = {[61]=true, [147]=true, [240]=true, [253]=true,[255]=true, [275]=true}
companyDutyMarker[4] = Vector3(1234.52, -63.90, 1011.32)
companyDutyMarkerInterior[4] = 12
companyDutyMarkerDimension[4] = 4
companySpawnpoint[4] = {Vector3(1228.25, -60.51, 1011.33), 12, 4}
