companyColors = {}
companyRankNames = {}
companySkins = {}
companyDutyMarker = {}
companyDutyMarkerInterior = {}

COMPANY_MAX_RANK_LOANS ={
	[0] = 750,
	[1] = 1000,
	[2] = 1250,
	[3] = 1500,
	[4] = 1750,
	[5] = 2000
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
companyDutyMarker[2] = Vector3(920.61, -1163.71, 16.98)

-- ID 3 = SAN News:
companyRankNames[3] = {
[0] = "Zeitungsjunge",
[1] = "Klatschtante",
[2] = "Zeitungsreporter",
[3] = "Reporter",
[4] = "Journalist",
[5] = "Chefredakteur"
}
companyColors[3] = {["r"] = 255,["g"] = 255,["b"] = 0}
companySkins[3] = {[59]=true,[141]=true,[186]=true,[187]=true,[188]=true,[189]=true}
companyDutyMarker[3] = Vector3(735.65, -1348.45, 13.51)

-- ID 4 = Public Transport:
companyRankNames[4] = {
[0] = "Polierer",
[1] = "Taxi-Fahrer",
[2] = "Kassier",
[3] = "Bus-Fahrer",
[4] = "Fahrzeugverwalter",
[5] = "Transportmanager"
}
companyColors[4] = {["r"] = 255,["g"] = 200,["b"] = 0}
companySkins[4] = {[61]=true, [147]=true, [240]=true, [253]=true,[255]=true, [275]=true}
companyDutyMarker[4] = Vector3(1755.45, -1896.06, 13.56)
