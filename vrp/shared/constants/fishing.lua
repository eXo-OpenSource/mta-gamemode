--MAX_FISHING_LEVEL = 15 --> main.lua

FISHING_BAGS = {
	["Kühlbox"] = {max = 65, level = 8},
	["Kühltasche"] = {max = 25, level = 4},
	["Kleine Kühltasche"] = {max = 15, level = 0},
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
