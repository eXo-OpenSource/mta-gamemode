ItemCategory = {All = 1, Drugs = 2, Player = 3, Vehicle = 4, Tools = 5, Other = 6}
ItemItemCategoryNames = {[ItemCategory.All] = "Alle", [ItemCategory.Drugs] = "Drogen", [ItemCategory.Player] = "Spieler", [ItemCategory.Vehicle] = "Fahrzeug",
	[ItemCategory.Tools] = "Werkzeuge", [ItemCategory.Other] = "Sonstiges"}

Items = {
-- Wer irgendwo mittendrin Items einfügt wird erschossen.
-- ID				  Name				Beschreibung			   																	Pfad zum Bild	Klasse			Maximale Stackanzahl 	Kategorie
{ "ITEM_CRACK",		"Crack"; 			"Crack ist eine gefährliche Droge."; 														nil; 			ItemCrack,		5,						ItemCategory.Drugs};
{ "ITEM_HEROIN",	"Heroin"; 			"Heroin ist eine gefährliche Droge."; 														nil; 			ItemHeroin,		5,						ItemCategory.Drugs};
{ "ITEM_MARIHUANA",	"Marihuana"; 		"Marihuana ist eine Droge."; 																nil; 			ItemMaruhuana,	5,						ItemCategory.Drugs};
{ "ITEM_LSD",		"LSD"; 				"LSD ist eine gefährliche Droge."; 															nil; 			ItemLSD,		5,						ItemCategory.Drugs};
{ "ITEM_NEWSPAPER", "Zeitung"; 			"Lies die Zeitung, um alle Neuigkeiten zu erfahren!"; 										nil; 			ItemNewsPaper,	5,						ItemCategory.Other};
{ "ITEM_KEY", 		"Schlüssel"; 		"Dies ist der Schlüssel für …"; 															nil; 			ItemKey,		0,						ItemCategory.Vehicle};
{ "ITEM_PASSPORT", 	"Personalausweis";	"Der Personalausweis dient zur Identifizierung und ist eine gleichzeitige Arbeitserlaubnis";nil; 			ItemPassport,	5,						ItemCategory.Player};
{ "ITEM_FLOWERS", 	"Blumen"; 			"Mache jemandem eine Freue und schenke ihm Blumen!"; 										nil; 			ItemFlowers,	5,						ItemCategory.Other};
{ "ITEM_DILDO",		"Dildo"; 			"Der kleine Männerersatz."; 																nil; 			ItemDildo,		5,						ItemCategory.Other};
}

local newitems = {}
for id, info in ipairs(Items) do
	newitems[id] = { id = id; name = info[2]; description = info[3]; imagepath = info[4]; class = info[5]; maxstack = info[6]; category = info[7] }
	_G[info[1]] = id
end
Items = newitems;