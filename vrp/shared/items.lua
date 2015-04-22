-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/items.lua
-- *  PURPOSE:     Item definition file
-- *
-- ****************************************************************************
ItemCategory = {All = 1, Drugs = 2, Player = 3, Vehicle = 4, Tools = 5, Other = 6}
ItemItemCategoryNames = {[ItemCategory.All] = "Alle", [ItemCategory.Drugs] = "Drogen", [ItemCategory.Player] = "Spieler", [ItemCategory.Vehicle] = "Fahrzeug",
	[ItemCategory.Tools] = "Werkzeuge", [ItemCategory.Other] = "Sonstiges"}

Items = {
-- Wer irgendwo mittendrin Items einfügt wird erschossen.
-- ID				  Name				Beschreibung			   																	Pfad zum Bild							Klasse			Stapelbar			 	Kategorie			Nach Benutzung entfernen  ModelId
{ "ITEM_CRACK",		"Crack"; 			"Crack ist eine gefährliche Droge."; 														nil; 									ItemCrack,		true,					ItemCategory.Drugs,		true,					0};
{ "ITEM_HEROIN",	"Heroin"; 			"Heroin ist eine gefährliche Droge."; 														nil; 									ItemHeroin,		true,					ItemCategory.Drugs,		true,					0};
{ "ITEM_HASH",		"Haschisch"; 		"Verschafft dir für 10min mehr Gesundheit";													nil; 									ItemHash,		true,					ItemCategory.Drugs,		true,					0};
{ "ITEM_LSD",		"LSD"; 				"LSD ist eine gefährliche Droge."; 															nil; 									ItemLSD,		true,					ItemCategory.Drugs,		true,					0};
{ "ITEM_NEWSPAPER", "Zeitung"; 			"Lies die Zeitung, um alle Neuigkeiten zu erfahren!"; 										nil; 									ItemNewsPaper,	true,					ItemCategory.Other,		false,					0};
{ "ITEM_KEY", 		"Schlüssel"; 		"Dies ist der Schlüssel für …"; 															nil; 									ItemKey,		true,					ItemCategory.Vehicle,	false,					0};
{ "ITEM_PASSPORT", 	"Personalausweis";	"Der Personalausweis dient zur Identifizierung und ist eine gleichzeitige Arbeitserlaubnis"; "files/images/Items/Passport.png";		ItemPassport,	false,					ItemCategory.Player,	false,					0};
{ "ITEM_FLOWERS", 	"Blumen"; 			"Mache jemandem eine Freue und schenke ihm Blumen!"; 										nil; 									ItemFlowers,	false,					ItemCategory.Other,		true,					0};
{ "ITEM_DILDO",		"Dildo"; 			"Der kleine Männerersatz."; 																nil; 									ItemDildo,		false,					ItemCategory.Other,		true,					0};
{ "ITEM_HOTWIREKIT", "Kurzschließkit";	"Autos abgeschlossen? Kein Problem!";														nil;									ItemHotwireKit,	false,					ItemCategory.Tools,		false,					0};
{ "ITEM_BOMB",		"Bombe";			"Erzeugt eine große Explosion und wird bei verschiedenen Events benötigt";					nil;									ItemBomb,		true,					ItemCategory.Other,		true,					0};
{ "ITEM_RADIO",		"Radio";			"Ein Radio, das Musik für alle abspielt";													nil;									ItemRadio,		false,					ItemCategory.Other,		false,					2226};
}

local newitems = {}
for id, info in ipairs(Items) do
	newitems[id] = { id = id; name = info[2]; description = info[3]; imagepath = info[4]; class = info[5]; stackable = info[6]; category = info[7]; removeAfterUsage = info[8]; modelId = info[9] }
	_G[info[1]] = id
end
Items = newitems;
