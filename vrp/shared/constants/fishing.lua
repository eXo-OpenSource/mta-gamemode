--MAX_FISHING_LEVEL = 15 --> main.lua
MIN_FISHING_DIFFICULTY = 15
MAX_FISHING_DIFFUCULTY = 150

FISHING_INVENTORY_BAG = "Items"

FISHING_EQUIPMENT = {
	-- Coolingbags
	["Kühlbox"] = {level = 8},
	["Kühltasche"] = {level = 4},
	["Kleine Kühltasche"] = {level = 0},

	-- Fishingrods
	["Bambusstange"] = {level = 0},
	["Angelrute"] = {level = 3},
	["Profi Angelrute"] = {level = 7},
	["Legendäre Angelrute"] = {level = 13},

	-- Baits
	["Köder"] = {level = 3},
	["Leuchtköder"] = {level = 5},
	["Pilkerköder"] = {level = 11},

	-- Accessories
	-- TODO
}

FISHING_BAGS = {
	["Kühlbox"] = {max = 65},
	["Kühltasche"] = {max = 25},
	["Kleine Kühltasche"] = {max = 15},
}

FISHING_RODS = {
	["Bambusstange"] = 			{baitSlots = 0, accessorieSlots = 0, difficultyReduction = 0, biteTimeReduction = 0},
	["Angelrute"] = 			{baitSlots = 1, accessorieSlots = 0, difficultyReduction = 15, biteTimeReduction = 4000},
	["Profi Angelrute"] = 		{baitSlots = 1, accessorieSlots = 1, difficultyReduction = 25, biteTimeReduction = 7500},
	["Legendäre Angelrute"] = 	{baitSlots = 1, accessorieSlots = 1, difficultyReduction = 40, biteTimeReduction = 10000},
}

FISHING_BAITS = {
	[false] = 			{biteTimeReduction = 0, difficultyReduction = 0},
	["Köder"] = 		{biteTimeReduction = 1000, difficultyReduction = 25, location = {"lake", "river", "coast", "sump", "desert", "cave"}},
	["Leuchtköder"] = 	{biteTimeReduction = 5000, difficultyReduction = 5, location = {"lake", "river", "coast", "sump", "desert", "cave"}},
	["Pilkerköder"] = 	{biteTimeReduction = 5000, difficultyReduction = 15, location = {"ocean"}},
}

FISHING_ACCESSORIES = {

}

-- (level * 15)^2 // for i = 1, 15 do print(("[%s] = %s,"):format(i, math.floor((i*15)^(i>10 and 2.2 or 2)))) end
FISHING_LEVELS = {
	[1] = 225,
	[2] = 900,
	[3] = 2025,
	[4] = 3600,
	[5] = 5625,
	[6] = 8100,
	[7] = 11025,
	[8] = 14400,
	[9] = 18225,
	[10] = 22500,
	[11] = 75590,
	[12] = 91537,
	[13] = 109163,
	[14] = 128493,
	[15] = 149555,
}

FISHING_COOLING_BAGS = {"Kleine Kühltasche", "Kühltasche", "Kühlbox"}

FISHING_MOTIONTYPE = {
	MIXED = 0,
	DART = 1,
	SMOOTH = 2,
	SINKER = 3,
	FLOATER = 4,
}

FISHING_EVENT_ID = {
	EASTER = 1,
	HALLOWEEN = 2,
	CHRISTMAS = 3,
}

FISHING_DESERT_WATERHEIGHT = 13
FISHING_DESERT_WATER = {
	{l = -33, r = 82, u = 1590, d = 1464},
	{l = -80, r = -33, u = 1590, d = 1511},
	{l = -59, r = -33, u = 1511, d = 1489},
	{l = -44, r = -33, u = 1489, d = 1475},
	{l = -70, r = -59, u = 1511, d = 1500},
	{l = -50, r = -44, u = 1489, d = 1481},
}

FISHING_BAD_CATCH_MESSAGES = {
	"eine alte Brille",
	"eine rolle Toilettenpapier",
	"ein Stück rostiges Blech",
	"ein hauch von Tüll",
	"einen Stock",
	"eine Zahnbürste",
	"ein defektes Smartphone",
	"einen alten Hut",
	"eine Patronenhülse",
	"einen BH in Übergröße",
	"ein benutztes Kondom",
	"ein unbenutztes Kondom",
	"Lippenstift",
	"einen Stift",
	"Metallschrott",
	"die Unterhose von xXKing",
	"Socken von Stumpy",
	"einen nutzlosen SchrimpX",
	"einen PawnX Sticker",
	"eine alte Tastatur",
	"eine alte CD",
	"eine alte Maus",
	"eine leere Flasche Bier",
	"eine leere Bierdose",
	"eine leere Cola Dose",
	"ein volles Glas Wasser",
	"ein leeres Glas Wasser",
	"ein Blatt Papier",
	"eine alte Zeitung",
}
