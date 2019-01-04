WEATHER_ZONES = {
	"Los Santos",
	"San Fierro",
	"Whetstone",
	"Las Venturas",
	"Tierra Robada",
	"Red County", -- Los Santos County
	"Flint County",
	"Bone County",
}

WEATHER_ZONE_WEATHERS = {
	["Los Santos"] = {0, 1, 2, 3, 4},
	["San Fierro"] = {5, 6, 7, 8, 9},
	["Whetstone"] = {5, 6, 7, 8, 9},
	["Las Venturas"] = {10, 11, 12},
	["Tierra Robada"] = {10, 11, 12},
	["Red County"] = {13, 14, 15, 16}, -- Los Santos County
	["Flint County"] = {13, 14, 15, 16},
	["Bone County"] = {17, 18, 19},
}

-- chance = duplicates the id x times to increase its chance
-- minimumDuration = minimum duration in minutes
-- changeChance = the chance in percent to change the weather after minimumDuration reached
WEATHER_ID_DESCRIPTION = {
	-- Los Santos
	[0] = {chance = 4, minimumDuration = 90, changeChance = 60, info = "sehr sonnig"},
	[1] = {chance = 5, minimumDuration = 90, changeChance = 40, info = "sonnig"},
	[2] = {chance = 2, minimumDuration = 60, changeChance = 60, info = "sehr sonnig, leicht bewölkt"},
	[3] = {chance = 3, minimumDuration = 60, changeChance = 40, info = "sonnig, leicht bewökt"},
	[4] = {chance = 1, minimumDuration = 45, changeChance = 70, info = "bewölkt"},

	-- San Fierro / Whetstone
	[5] = {chance = 5, minimumDuration = 90, changeChance = 40, info = "sonnig"},
	[6] = {chance = 4, minimumDuration = 60, changeChance = 60, info = "sehr sonnig"},
	[7] = {chance = 3, minimumDuration = 45, changeChance = 60, info = "bewölkt"},
	[8] = {chance = 1, minimumDuration = 30, changeChance = 80, info = "regen"},
	[9] = {chance = 2, minimumDuration = 30, changeChance = 70, info = "neblig"},

	-- Las Venturas / Tierra Robada
	[10] = {chance = 4, minimumDuration = 90, changeChance = 40, info = "sonnig"},
	[11] = {chance = 3, minimumDuration = 60, changeChance = 60, info = "sehr sonnig"},
	[12] = {chance = 2, minimumDuration = 45, changeChance = 60, info = "bewölkt"},

	-- Red County / Flint County
	[13] = {chance = 4, minimumDuration = 60, changeChance = 60, info = "sehr sonnig"},
	[14] = {chance = 3, minimumDuration = 90, changeChance = 40, info = "sonnig"},
	[15] = {chance = 2, minimumDuration = 45, changeChance = 60, info = "bewölkt"},
	[16] = {chance = 1, minimumDuration = 30, changeChance = 80, info = "regen"},

	-- Bone County
	[17] = {chance = 3, minimumDuration = 60, changeChance = 60, info = "sehr sonnig"},
	[18] = {chance = 4, minimumDuration = 90, changeChance = 40, info = "sonnig"},
	[19] = {chance = 1, minimumDuration = 30, changeChance = 80, info = "Sandsturm"},
}
