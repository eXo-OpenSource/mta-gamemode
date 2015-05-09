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
-- Wer irgendwo mittendrin Items einfügt oder entfernt, wird erschossen.
-- ID				  Name				Beschreibung			   																	Pfad zum Bild							Klasse			Stapelbar			 	Kategorie			Nach Benutzung entfernen  ModelId
{ "ITEM_PASSPORT", 	"Personalausweis";	"Der Personalausweis dient zur Identifizierung und ist eine gleichzeitige Arbeitserlaubnis"; "files/images/Items/Passport.png";		ItemPassport,	false,					ItemCategory.Player,	false,					0};
{ "ITEM_HOTWIREKIT", "Kurzschließkit";	"Autos abgeschlossen? Kein Problem!";														"files/images/Items/HotwireKit.png";	ItemHotwireKit,	false,					ItemCategory.Tools,		false,					0};
{ "ITEM_BOMB",		"Bombe";			"Erzeugt eine große Explosion und wird bei verschiedenen Events benötigt";					"files/images/Items/Bomb.png";			ItemBomb,		true,					ItemCategory.Other,		true,					0};
{ "ITEM_RADIO",		"Radio";			"Ein Radio, das Musik für alle abspielt";													"files/images/Items/Radio.png";			ItemRadio,		false,					ItemCategory.Other,		false,					2226};
}

local newitems = {}
for id, info in ipairs(Items) do
	newitems[id] = { id = id; name = info[2]; description = info[3]; imagepath = info[4]; class = info[5]; stackable = info[6]; category = info[7]; removeAfterUsage = info[8]; modelId = info[9] }
	_G[info[1]] = id
end
Items = newitems;
