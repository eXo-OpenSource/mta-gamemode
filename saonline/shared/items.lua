Items = {
-- Wer irgendwo mittendrin Items einfügt wird erschossen.
-- ID				  Name				Beschreibung			   																	Pfad zum Bil	Maximale Stackanzahl 
{ "ITEM_CRACK",		"Crack"; 			"Crack ist eine gefährliche Droge."; 														nil; 			5};
{ "ITEM_HEROIN",	"Heroin"; 			"Heroin ist eine gefährliche Droge."; 														nil; 			5};
{ "ITEM_MARIHUANA",	"Marihuana"; 		"Marihuana ist eine Droge."; 																nil; 			5};
{ "ITEM_LSD",		"LSD"; 				"LSD ist eine gefährliche Droge."; 															nil; 			5};
{ "ITEM_NEWSPAPER", "Zeitung"; 			"Lies die Zeitung, um alle Neuigkeiten zu erfahren!"; 										nil; 			5};
{ "ITEM_KEYS", 		"Schlüssel"; 		"Dies ist der Schlüssel für …"; 															nil; 			5};
{ "ITEM_PASSPORT", 	"Personalausweis";	"Der Personalausweis dient zur Identifizierung und ist eine gleichzeitige Arbeitserlaubnis";nil; 			5};
{ "ITEM_FLOWERS", 	"Blumen"; 			"Mache jemandem eine Freue und schenke ihm Blumen!"; 										nil; 			5};
{ "ITEM_SHORT_DILDO","Kurzer Dildo"; 	"Der kleine Männerersatz."; 																nil; 			5};
{ "ITEM_LONG_DILDO","Langer Dildo"; 	"Der lange Männerersatz."; 																	nil; 			5};
}

local newitems = {}
for id, info in ipairs(Items) do
	newitems[id] = { id = id; name = info[2]; description = info[3]; imagepath = info[4]; maxstack = info[5]; }
	_G[info[1]] = id
end
Items = newitems;