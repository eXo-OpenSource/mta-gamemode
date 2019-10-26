WEAPON_DAMAGE = {
	[8] = 35,

	[22] = 10,
	[23] = 15,
	[24] = 35,

	[25] = 20,
	
	[26] = 25,
	
	[27] = 0,

	[28] = 8,
	[29] = 8,
	[32] = 8,

	[30] = 9,
	[31] = 7,

	[33] = 15,
	[34] = 50,

	[51] = 40
}

DAMAGE_MULTIPLIER = {
	[3] = 1.2, -- Torso
	[4] = 1.2, -- Ass
	[5] = 1, -- Left Arm
	[6] = 1, -- Right Arm
	[7] = 1, -- Left Leg
	[8] = 1, -- Right Leg
	[9] = 2 -- Head
}


WEAPON_MODELS_WORLD = 
{
	[2] = 333, 
	[3] = 334,
	[4] = 335, 
	[5] = 336, 
	[6] = 337, 
	[7] = 338, 
	[8] = 339,
	[9] = 341, 
	[10] = 321,
	[11] = 322,
	[12] = 323,
	[14] = 325,
	[15] = 326,
	[16] = 342,
	[17] = 343, 
	[18] = 344,
	[22] = 346, 
	[23] = 347, 
	[24] = 348, 
	[25] = 349, 
	[26] = 350, 
	[27] = 351, 
	[28] = 352, 
	[29] = 353, 
	[30] = 355, 
	[31] = 356, 
	[33] = 357, 
	[34] = 358, 
	[35] = 359, 
	[36] = 360,
	[37] = 361, 
	[38] = 362,
	[39] = 363, 
	[40] = 364,
	[41] = 365,
	[42] = 366,
	[43] = 367,
	[44] = 368,
	[45] = 369,
	[46] = 371,
}

WEAPON_NAMES = {
	[0] = "Faust",
	[1] = "Schlagring",
	[2] = "Golfschläger",
	[3] = "Schlagstock",
	[4] = "Messer",
	[5] = "Baseball-Schläger",
	[6] = "Schaufel",
	[7] = "Billiard Queue",
	[8] = "Katana",
	[9] = "Kettensäge",
	[10] = "Langer Dildo",
	[11] = "Kurzer Dildo",
	[12] = "Vibrator",
	[14] = "Blumen",
	[15] = "Gehstock",
	[16] = "Granate",
	[17] = "Tränengas",
	[18] = "Molotov-Cocktail",
	[22] = "9mm Pistole",
	[23] = "Taser",
	[24] = "Desert Eagle",
	[25] = "Schrotflinte",
	[26] = "Abgesägte Schrot",
	[27] = "SPAZ-12",
	[28] = "Uzi",
	[29] = "MP5",
	[30] = "AK-47",
	[31] = "M4",
	[32] = "TEC-9",
	[33] = "Jagd-Gewehr",
	[34] = "Sniper",
	[35] = "Raketenwerfer",
	[36] = "RPG",
	[37] = "Flammenwerfer",
	[38] = "Minigun",
	[39] = "Rucksack-Bomben",
	[40] = "Fernzünder",
	[41] = "Spray-Dose",
	[42] = "Feuerlöscher",
	[43] = "Kamera",
	[44] = "Nachtsicht-Gerät",
	[45] = "Wärmesicht-Gerät",
	[46] = "Fallschirm"
}

TRADE_DISABLED_WEAPONS = { --weapons that should not be traded with
	[9] = true, --Chainsaw
}

NO_MUNITION_WEAPONS = { 
	[0] = true;
	[1] = true;
	[2] = true;
	[3] = true;
	[4] = true;
	[5] = true;
	[6] = true;
	[7] = true;
	[8] = true;
	[9] = true;
	[10] = true;
	[11] = true;
	[12] = true;
	[13] = true;
	[14] = true;
	[15] = true;
	[44] = true;
	[45] = true;
	[46] = true;
}

THROWABLE_WEAPONS = --throwable weapons
{
	[16] = true,
	[17] = true,
	[18] = true,
	[39] = true,
}

WEAPON_CLIPS = { -- changed clip sizes for shotguns
	[25] = 6,
	[33] = 5,
	[34] = 4
}

MIN_WEAPON_LEVELS = {
	[0] = 0, -- Faust
	[1] = 0, -- Schlagring
	[2] = 0, -- Golfschläger
	[3] = 0, -- Schlagstock
	[4] = 0, -- Messer
	[5] = 0, -- Baseball Schläger
	[6] = 0, -- Schaufel
	[7] = 0, -- Billiard Queue
	[8] = 1, -- Katana
	[9] = 1, -- Kettensäge
	[10] = 0, -- Langer Pinker Dildo
	[11] = 0, -- Kurzer Dildo
	[12] = 0, -- Vibrator
	[14] = 0, -- Blumen
	[15] = 0, -- Gehstock
	[16] = 6, -- Granaten
	[17] = 6, -- Tränengas
	[18] = 6, -- Molotov Cocktails
	[22] = 3, -- 9mm Pistole
	[23] = 3, -- Taser
	[24] = 4, -- Desert Eagle
	[25] = 5, -- Schrotflinte
	[26] = 6, -- Abgesägte Schrotflinte
	[27] = 7, -- SPAZ-12 Spezialwaffe
	[28] = 7, -- Uzi
	[29] = 7, -- MP5
	[30] = 8, -- AK-47
	[31] = 8, -- M4
	[32] = 7, -- TEC-9
	[33] = 7, -- Jagd Gewehr
	[34] = 8, -- Sniper
	[35] = 8, -- Raketenwerfer
	[36] = 8, -- RPG
	[37] = 8, -- Flammenwerfer
	[38] = 10, -- Minigun
	[39] = 8, -- Rucksack-Bomben
	[40] = 8, -- Bomben Auslöser
	[41] = 1, -- Spray-Dose
	[42] = 0, -- Feuerlöscher
	[43] = 0, -- Kamera
	[44] = 0, -- Nachtsicht-Gerät
	[45] = 0, -- Wärmesicht-Gerät
	[46] = 0, -- Fallschirm"
}

WEAPON_IDS = {}
for id, name in pairs(WEAPON_NAMES) do
	WEAPON_IDS[name] = id
end

EXPLOSIVE_DAMAGE_MULTIPLIER = {
	[16] = 2,
	[19] = 3,
	[35] = 3,
	[36] = 3,
	[39] = 2.5,
	[51] = 2,
	[59] = 3
}