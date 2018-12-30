BeggarPhraseTypes = {Help = 1, Thanks = 2, NoHelp = 3, Rob = 4, Decline = 5, InVehicle = 6, NoTrust = 7, Destination = 8}
BeggarHelpPhrases = {
	{ -- Type: Money
		"Ey du! Haste mal nen Euro?",
        "Eine kleine Spende für den Abschaum der Gesellschaft?",
        "Ich brauche dringend Geld für ein Monatsticket beim EPT!"
	};
	{ -- Type: Food
		"I.. Ic.. Ich hab so Hunger... Hast du einen Burger?",
        "Ich sterbe fast vor Hunger - du hast nicht zufällig einen Burger für mich?"
	};
	{ -- Type: Transport
		"Du da! Ich hab kein Geld für ein Taxi! Kannst du mich fahren?",
		"Hilfe, ich hab mich verlaufen! Nimmst du mich mit?",
	};
	{ -- Type: Weed
		"Hast du Weed? Ich zahle einen guten Preis!",
        "Ich brauch GRAS! SOFORT!!!",
        "Du siehst mir aus wie ein Drogenkurier, hast du auch was für mich?"
	};
    { -- Type: Heroin
		"Hey! Bock auf nen Heroin Trip?",
		"Pssst, du da! Habe das beste Heroin der Stadt!"
	};
}

BeggarThanksPhrases = {
	{ -- Type: Money
		"Vielen Dank. Jetzt kann ich mir wieder Bier kaufen!",
        "Danke dir! Und mach nicht die gleichen Fehler wie ich!",
        "Da wird sich gleich eine ganz bestimmte Stripperin freuen - danke!"
	};
	{ -- Type: Food
		"Danke Meister, meine Ratte wäre fast verhungert.",
        "Danke... ich bin zwar Vegetarier, aber das Fleisch kann ich ja wegwerfen..",
        "Danke dir, der Abfall vom Cluckin' Bell schmeckt einfach nicht",
        "Grazie! Iste viele beeesser als der Miiist von Pizza Stack!"
	};
	{ -- Type: Transport
		"Vielen Dank, genau da musste ich hin!",
        "Danke Kollege, San Andreas braucht mehr von deiner Sorte!",
        "Hier ist doch ein viel besserer Platz zum Betteln."
	};
    { -- Type: Weed
		"Schön, mit dir Geschäfte zu machen.",
        "Danke, ich brauche das Zeug echt dringend!",
        "Das wird ein tolles Geburtstagsgeschenk!"
	};
	{ -- Type: Heroin
		"Schön, mit dir Geschäfte zu machen.",
        "Nimm nicht zu viel davon!",
        "Ich bin nicht schuld, wenn du im Krankenhaus aufwachst!"
	};
}

BeggarNoHelpPhrases = {
	"You mofugga!",
    "Dann halt nicht.",
    "Ja lauf ruhig weg!",
    "Einen schönen Tag noch.",
    "Man sieht sich immer zwei Mal im Leben!",
    "Heute nicht so sozial drauf?",
    "Ach komm schon!",
    "Mach doch nicht diesen!",
    "Du kannst mich doch hier nicht zurücklassen!",
    "Komm wieder zurück!"
}

BeggarRobPhrases = {
	"Ich habe eh schon nichts. Und da willst du mir noch mehr nehmen?",
    "Das ist doch nun wirklich das allerletzte!",
    "Womit hab ich das nur verdient?",
    "Wenn du wüsstest wo die Scheine schon überall waren...",
    "Und dann nennen die Leute MICH den 'Abschaum der Gesellschaft'! Pff..."
}

BeggarDeclinePhrases = {
	"Ne, da will ich nicht mit!",
	"Das kostet bestimmt Geld. Zieh ab!",
	"In DAS Vehikel? Abgelehnt.",
	"Ich habs mir anders überlegt.",
    "Sorry, I have a boyfriend!"
}

BeggarInVehiclePhrases = {
	"Du wirst doch wohl noch Zeit zum Aussteigen haben!"
}


BeggarNoTrustPhrases = {
	"Mit dir will ich nichts mehr zu tun haben!",
    "Zieh Leine!",
    "Nö, dich mag ich nicht mehr.",
    "Erst klauen und dann Geschäfte machen? Nein danke!",
    "Mit Terroristen verhandle ich nicht!"
}

BeggarDestinationPhrases = {
    "Ich möchte nach %s.",
    "Kannst du mich bitte bei %s rauslassen?",
    "Und auf geht's nach %s!"
}

BeggarTransportPositions = {
	Vector3(1482.74, -1725.00, 13.55), -- Usertreff
	Vector3(1648.6, -2323.8, 12.2), -- Flughafen
	Vector3(1786.2, -1285, 12.5), -- Stadthalle
	Vector3(1264, -2022, 58), -- Premiumshop
}


BeggarSkins = {
    200,
    77,
    78,
    79,
    133,
    134,
    135,
    136,
    137
}

BeggarItemBuyTypes = {
    [5] = {"Heroin"} -- list of all items that a beggar type sells to the player (and that a player can potentially rob by killing him)
}

BeggarItemBuy = {
	["Heroin"] = {["amount"] = 5, ["pricePerAmount"] = 30}
}

BeggarNames = { -- Wer namen zwischendrin einfügt wird erschossen!
    "Uwe",
    "Karsten Stahl",
    "Donetasty S.",
    "Jizzynex H.",
    "Scheißhaus Schorsch",
    "Pfandflaschen Tony",
    "Trompeten Heinz",
    "Vodka Willi",
    "Fliesentisch Klaus",
    "Gürtelrosen Sepp",
    "Detlev Maier",
    "Gustav Gans",
    "Jürgen Chefs",
    "Leon Messi",
    "Christian Ronald",
    "Manfred Neuer",
    "Stomas Müllner",
    "Freddy Feuerfelsen",
    "Schteven K.",
    "Johann Arschgucker",
    "Axel Schweiß",
    "Gisela von Hinten",
    "Peter Peters",
    "Tim Buktu",
    "Reiner Ernst",
    "Ernst Haft",
    "Klieh Doris",
    "Rosa Loch",
    "Wilma Lutschen",
    "Marie Juhana",
    "Ernst Scherz",
	"Stummy Stumpf",
    "Jesus",
    "Donald Trump",
    "Maestro Emm"
}

BeggarAnimations = {
	{
        "crack", "crckdeth2", -1, false, true, false
    };
    {
        "dealer", "dealer_idle", -1, true, true, true
    };
    {
        "dealer", "dealer_idle", -1, true, false, true
    };
    {
        "dealer", "dealer_idle", -1, true, false, true
    };
}
