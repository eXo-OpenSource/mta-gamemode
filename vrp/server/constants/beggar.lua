BeggarPositions = {
    {Vector3(1279.204, -2046.976, 59.213), Vector3(0, 0, 175)};
    {Vector3(-1930.83, -1782.53, 31.27), Vector3(-0.00, 0.00, 359.70)};
    {Vector3(2089.27, -2116.40, 13.55), Vector3(0, 0, 259.53)};
    {Vector3(803.33, -1644.34, 13.55), Vector3(0, 0, 253.24)};
    {Vector3(-2255.91, 2374.16, 5.01), Vector3(0, 0, 118.50)};
    {Vector3(815.34, 856.50, 12.05), Vector3(0, 0, 201.83)};
    {Vector3(2333.54, 80.29, 26.62), Vector3(0, 0, 288.07)};
    {Vector3(476.70, -1528.23, 20.01), Vector3(0, 0, 263.35)};
    {Vector3(1107.72, -1420.29, 15.80), Vector3(0, 0, 173.50)};
    {Vector3(1937.72, -2137.05, 13.70), Vector3(0, 0, 183.47)};
    {Vector3(1928.44, -1787.65, 13.39), Vector3(0, 0, 289.37)};
    {Vector3(2231.72, -1153.99, 25.89), Vector3(0, 0, 177.72)};
    {Vector3(2178.32, 1272.41, 10.82), Vector3(-0.00, 0.00, 193.39)};
}

BeggarTypes = {
	Money = 1;
	Food = 2;
	Water = 3;
    Ecstasy = 4;
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
    { -- Type: Ecstasy
		"Hey! Bock auf nen Ecstasy Trip?"
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
    {
		"Schön mit dir Geschäfte zu machen. Wenn du wieder Stoff brauchst, komm vorbei!"
	};
}

BeggarNoHelpPhrases = {
	"Bye."
}

BeggarRobPhrases = {
	"Ich habe eh schon nichts. Und da willst du mir noch mehr nehmen? Da."
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

BeggarNames = {
    "Uwe",
    "Karsten Stahl",
    "Donetasty S.",
    "Jizzynex H.",
    "Scheißhaus Schorch",
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
    "Stivi K.",
    "Johann Arschgucker",
    "Axel SChweiß",
    "Gisela von Hinten",
    "Peter Peters",
    "Tim Buktu",
    "Reiner Ernst",
    "Ernst Haft",
    "Klieh Doris",
    "Rosa Loch",
    "Wilma Lutschen",
    "Marie Juhana",
    "Ernst Scherz"
}

BeggarAnimations = {
	{
        "crack", "crckdeth2", -1, false, true, false
    };
    {
        "beach", "ParkSit_M_loop", -1, true, true, true
    };
    {
        "beach", "SitnWait_loop_W", -1, true, false, true
    };
    {
        "beach", "bather", -1, true, false, true
    };
}
