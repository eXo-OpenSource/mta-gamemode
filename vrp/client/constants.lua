-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/constants.lua
-- *  PURPOSE:     Global clientside constants
-- *
-- ****************************************************************************
screenWidth, screenHeight = guiGetScreenSize()
screenSize = Vector2(screenWidth, screenHeight)
ASPECT_RATIO_MULTIPLIER = (screenWidth/screenHeight)/(16/9)

NO_MUNITION_ITEMS = {
	[0] = true;
	[1] = true;
	[2] = true;
	[3] = true;
	[4] = true;
	[5] = true;
	[7] = true;
	[8] = true;
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

WeaponIcons = {
	[0] = "Fist.png",
	[1] = "BrassKnuckles.png",
	[2] = "Golf.png",
	[3] = "Nightstick.png",
	[4] = "Knife.png",
	[5] = "BaseballBat.png",
	[6] = "Shovel.png",
	[7] = "Cue.png",
	[8] = "Katana.png",
	[9] = "Chainsaw.png",
	[10] = "Dildo.png",
	[11] = "DildoSmall.png",
	[12] = "Vibrator.png",
	[14] = "Flowers.png",
	[15] = "Cane.png",
	[16] = "Grenade.png",
	[17] = "Teargas.png",
	[18] = "Molotov.png",
	[22] = "Pistol.png",
	[23] = "SilencedPistol.png",
	[24] = "Deagle.png",
	[25] = "Shotgun.png",
	[26] = "SawnOffShotgun.png",
	[27] = "SPAZ-12.png",
	[28] = "Uzi.png",
	[29] = "MP5.png",
	[30] = "AK-47.png",
	[31] = "M4.png",
	[32] = "TEC-9.png",
	[33] = "CountryRifle.png",
	[34] = "Sniper.png",
	[35] = "RPG.png",
	[36] = "RocketHS.png",
	[37] = "FlameThrower.png",
	[38] = "Minigun.png",
	[39] = "Satchel.png",
	[40] = "SatchelDetonator.png",
	[41] = "Spraycan.png",
	[42] = "FireExtinguisher.png",
	[43] = "Camera.png",
	[44] = "Nightvision.png",
	[45] = "Nightvision.png",
	[46] = "Parachute.png",
}
for k, v in pairs(WeaponIcons) do WeaponIcons[k] = "files/images/Weapons/"..v end

RadarDesign = {Monochrome = 1, GTA = 2}
for i, v in pairs(RadarDesign) do RadarDesign[v] = i end

UIStyle = {vRoleplay = 1, eXo = 2}
for i, v in pairs(UIStyle) do UIStyle[v] = i end

HelpTextTitles = {
	General = {
		Main = "vRoleplay";
		LoginRegister = "Login/Registration";
		Team = "Team";
	};
	Jobs = {
		BusDriver = "Job: Busfahrer";
		Farmer = "Job: Bauer";
		Logistician = "Job: Logistik";
		Lumberjack = "Job: Holzfäller";
		Mechanic = "Job: Mechaniker";
		Police = "Job: Polizist";
		RoadSweeper = "Job: Straßenkehrer";
		Trashman = "Job: Müllmann";
		ServiceTechnician = "Job: Service-Techniker"
	};
	Events = {
		Deathmatch = "Event: Deathmatch";
		DMRace = "Event: DM-Race";
		StreetRace = "Event: Street Race";
	};
}

HelpTexts = {
	General = {
		Main = [[
			vRoleplay ist ein Server-Projekt für die Multiplayer Modifikation Multi Theft Auto: San Andreas für GTA: San Andreas.
			Ziel des Projekts ist ein möglichst umfangreiches, neuartiges Rollenspiel zu schaffen.

			Wir befinden uns derzeit in der Alpha Testphase, was bedeutet, dass es momentan hauptsächlich darum geht,
			das richtige Balancing zu finden und fehlende Features auszumachen.
		]],
		LoginRegister = [[
			Dies ist das Login Fenster. Im Tab 'Login' kannst Du dich einloggen, im Tab 'Registrieren' demzufolge registrieren.

			Tipp:
			Wenn du den Server erst einmal testen möchtest, kannst du als Gast spielen und dich während des Spielens registrieren.
			Für ein optimales Spielerlebnis und um Verluste zu vermeiden, empfehlen wir Dir jedoch eine sofortige Registration.
		]];
		Team = [[
			Entwicklung und Administration:
			Jusonex <jusonex@v-roleplay.net>
			sbx320 <sbx320@v-roleplay.net>
			Revelse <revelse@v-roleplay.net>
			StiviK <stivik@v-roleplay.net>

			Administration:
			Doneasty <doneasty@v-roleplay.net> (außerdem Grafik und Design)

			Moderation:
			Sarcasm <sarcasm@v-roleplay.net> (außerdem Webauftritt)
			Johnny <johnny@v-roleplay.net> (außerdem Mapping)
			Toxsi <toxsi@v-roleplay.net> (außerdem Mapping)

			Vielen Dank an:
			Sam@ke (für seine wunderschönen Shader)
			thefleshpound (für seine Zeit als Grafiker)
			Schlumpf (für seine kurze Zeit als Mapper)
			ReZ (für seine kurze Zeit als Mapper)
			Alex (für seine Zeit als Mapper)
			Audifire (für das Verteilen von Müll)
			Poof (für das Schreiben von Hilfetexten)

			Alpha-Tester:
			Gibaex
		]];
	};
	Jobs = {
		BusDriver = [[
			Als Busfahrer musst du die Bürger von Los Santos von A nach B transportieren.
			Im Grunde musst du nur dem roten Marker mit dem grauen Dreieck folgen und
			kurz an den jeweiligen Bushaltestellen anhalten.

			Wenn du keine Lust mehr hast und dine Tour beenden willst,
			musst du nur aus dem Bus aussteigen und weglaufen.
		]];
		Farmer = [[
			Als Farmer hast du 3 Aufgaben: sähen, ernten und beliefern.
			Spawne zu Anfang im roten Marker einen Traktor um mit diesem auf dem Feld hinter dem Marker zu sähen.
			Anschließend spawnst du dir einen Mähdrescher, mit welchem du nun deine Ernte einholst.
			Anschließend holst du dir deinen kleinen Pick up Truck (ebenfalls im roten Marker) und
			belieferst den auf der Karte angezeigten Supermarkt ("Waypoint"-Blip).
		]];
		Logistician = [[Todo]];
		Lumberjack = [[
			Als Holzfäller musst du die Bäume am Hügel fällen und sie zum Sägewerk fahren.
			Sofern du genug Bäume gefällt hast schnappst du dir einen Flatbed und fährst in den
			blauen Marker, neben welchem sich ein Haufen von Bäumen angesammelt hat (deine gefällten Bäume).
			Nun werden diese Bäume aufgeladen. Nachdem sie aufgeladen wurden musst du zum Sägewerk fahren (die rote Säge auf der Karte).
			Dort lieferst du sie ab.
		]];
		Mechanic = [[
			Als Mechaniker musst du die Autos deiner Mitbürger reparieren. Du reparierst sie, indem du auf das gewünschte Auto klickst und "reparieren" wählst.

			ACHTUNG: im Fahrzeug muss sich ein Fahrer befinden!
		]];
		Police = [[
			Als Polizist hast du die Aaufgabe die bösen Buben zu jagen.
			Mithilfe deines Schlagstocks kannst du sie in das Gefängnis befördern.
			Du kannst allerdings keine Wanteds verteilen, da diese automatisch vom System vergeben werden.
			Um die Wanteds deiner Mitspieler einzusehen musst du den Polizeicomputer (F2) öffnen.

			ACHTUNG: wenn dein Karma in den negativen Bereich fällt wirst du automatisch gefeuert!
		]];
		RoadSweeper = [[
			Als Straßenkehrer hast du die Aufgabe mithilfe der Kehrmaschine die Straßen von Los Santos sauberzuhalten.
			Lufe in den roten Marker und hole dir dein benötigtes Fahrzeug.
			Sofern du es hast kannst du nun losfahren und über den auf der Straße liegenden Müll fahren um ihn aufzukehren.
		]];
		Trashman = [[Todo]];
		ServiceTechnician = [[Todo]];
	};
	Events = {
		Deathmatch = [[Todo]];
		DMRace = [[Todo]];
		StreetRace = [[Todo]];
	};
};

Tipps = {
	{"", "Schon ein paar vRP-Points bekommen? Nein? Dann suche auf der Karte nach schwebenden vRoleplay Logos oder bekomme Archievements! Mithilfe der vRP-Points kannst du dir diverse Premiumdinge holen oder sie in XP eintauschen."};
	{"wie ändere ich mein Karma", "Um auf die gute Seite zu wechseln kannst du a.) gute Taten vollbringen oder b.) ein paar deiner gesammelten XP in Karmapunkte eintauschen. Wenn dein Karma im positiven Bereich ist kannst du dich als Polizist versuchen und weiter positives Karma sammeln. Wenn du auf die böse Seite wechseln willst musst du im Grunde nur böses tun. Raube Läden aus, überfalle Leute und lebe ein Gangsterleben."};
	{"wie komme ich in eine Gang", "Um in eine Gang zu kommen muss der Gangboss dir eine Einladung senden. Diese wird dir auf dein Handy (Hotkey 'K') geschickt. Du findest sie in der Dashboard App."};
	{"wie gründe ich eine Gang", "Um eine Gang zu gründen brauchst du a.) reichlich XP und b.) ein großes Vermögen, denn die Gründung kostet 100.000$! Du kannst sie im Self-Menü unter 'Gruppen' gründen. Als Boss hast du Rang 2 und kannst die Ränge nach belieben verwalten. Natürlich kannst du die Gruppe jederzeit verlassen und/oder löschen."};
	{"wo parke ich meine Autos", "Das Garagensymbol auf der Map zeigt dir die Standorte für die Garagen. Anfangs hast du eine Garage mit 3 Standplätzen. Diese Garage kannst du jederzeit unter 'Fahrzeuge' gegen Geld upgraden. Übrigens kannst du nur in der Garage geparkte Fahrzeuge respawnen!"};
	{"welche Jobs eignen sich für den Anfang", "Anfangs stehen dir durch dein geringes Level wenige Jobs zur Auswahl. Du kannst anfangs nur den Kehrmaschinen und den Farmerjob machen. Je nachdem wieviel XP du hast stehen dir weitere Jobs wie der Holzfäller oder der Müllfahrer zur Auswahl."};
	{"wie erreiche ich das Team", "Um das Team zu erreichen kannst du das Support System auf dem Hotkey 'hierderkrassehotkey' öffnen und ein Ticket schreiben."};
	{"was macht man als Gang", "Als Gruppe mit positivem Durchschnittskarma kann man besipielsweise auf Verbecherjagd gehen (sofern man Polizist ist). Mit negativem Karma kann man diverse Raubüberfälle auf Läden, Häuser oder Banken starten, Ganggebiete erobern, seine 'Brüder' aus dem Knast holen, mit Drogen dealen und die Stadt nach und nach erobern."};
}
