BeggarPositions = {
    {Vector3(1279.204, -2046.976, 59.213), Vector3(0, 0, 175)}
}

BeggarTypes = {
	Money = 1;
	Food = 2;
	Water = 3;
}
for i, v in pairs(BeggarTypes) do
	BeggarTypes[v] = i
end

BeggarPhraseTypes = {Help = 1, Thanks = 2, NoHelp = 3, Rob = 4}
BeggarHelpPhrases = {
	{ -- Type: Money
		"Ey du! Haste mal nen Euro?";
	};
	{ -- Type: Food
		"I.. Ic.. Ich hab so Hunger... Haste was?"
	};
	{ -- Type: Water
		"Du da! Willste mich hier verdursten lassen?"
	};
}

BeggarThanksPhrases = {
	{
		"Vielen Dank. Jetzt kann ich mir wieder Bier kaufen!"
	};
	{
		"Danke Meister, meine Ratte wäre fast verhungert."
	};
	{
		"Mercie."
	};
}

BeggarNoHelpPhrases = {
	"Bye."
}

BeggarRobPhrases = {
	"Ich habe eh schon nichts. Und da willst du mir noch mehr nehmen? Da."
}

BeggarSkins = {200, 77, 78, 79, 133, 134, 135, 136, 137}
BeggarNames = {"Uwe", "Karsten Stahl", "Donetasty S.", "Jizzynex H.", "Scheißhaus Schorch", "Pfandflaschen Tony", "Trompeten Heinz", "Vodka Willi", "Fliesentisch Klaus", "Gürtelrosen Sepp"}

BeggarAnimations = {
	{"crack", "crckdeth2", -1, false, true, false}
}
