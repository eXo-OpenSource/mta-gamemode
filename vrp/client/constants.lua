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

UIStyle = {vRoleplay = 1, eXo = 2, Default = 3}
for i, v in pairs(UIStyle) do UIStyle[v] = i end

HelpTextTitles = {
	General = {
		Main = "vRoleplay";
		LoginRegister = "Login/Registration";
		Team = "Team";
		OldVRPTeam = "vRP-Team";
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
		ServiceTechnician = "Job: Service-Techniker";
		PizzaDelivery = "Job: Pizza-Lieferant"
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
			Entwicklung:
			[eXo]Stumpy
			Heisi
			StiviK
			Jusonex (kleinere Unterstüzung)
			Strobe
			PewX

			Projektleitung:
			[eXo]Stumpy
			Heisi

			stellv. Projektleitung:
			[eXo]Clausus
			[eXo]LAURIIST4AR
			StiviK

			Administration:
			[eXo]xXKing
			[eXo]Chris

			Moderation (+S.Mod):
			[eXo]StrongVan
			[eXo]Don_Leone
			[eXo]High5
			[eXo]Phil

			Support:
			[eXo]Gamer64
			[eXo]Creo
			[eXo]Bonez
			[eXo]Janni_Morita
			[eXo]AfGun

			Informationen zum damaligen vRP-Team und Unterstützer unter "vRP-Team".
		]];
		OldVRPTeam = [[
			Dies ist das ehemalige Team des vRP-Gamemodes, die uns freundlicherweise den Gamemode überlassen haben.

			Entwicklung und Administration:
			Jusonex
			sbx320
			Revelse
			StiviK

			Administration:
			Doneasty (außerdem Grafik und Design)

			Moderation:
			Sarcasm (außerdem Webauftritt)
			Johnny (außerdem Mapping)
			Toxsi (außerdem Mapping)

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
		PizzaDelivery = [[Todo]];
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

SkinShops = {
	{
		Marker = Vector3(218.2, -98.5, 1004.3);
		MarkerInt = 15;
		PlayerPos = Vector3(217.922, -98.563, 1005.258);
		PlayerRot = Vector3(0.000, 0.000, 299);
		CameraMatrix = {216.056396484375, -99.181800842285156, 1006.8388061523437, 216.90571594238281, -98.900047302246094, 1006.3923950195312, 0, 70}
	};
	{
		Marker = Vector3(177.179, -86.714, 1000.805);
		MarkerInt = 18;
		PlayerPos = Vector3(181.724, -88.541, 1002.023);
		PlayerRot = Vector3(0.000, 0.000, 90);
		CameraMatrix = {177.40980529785, -87.031700134277, 1003.7614746094, 178.3257598877, -87.35213470459, 1003.5198974609, 0, 70}
	};
}

AFK_POSITIONS = {
	Vector2(435.701171875, -81.822265625),
	Vector2(460.5546875, -85.5390625),
	Vector2(458.5517578125, -85.5029296875),
	Vector2(453.8857421875, -85.578125),
	Vector2(455.205078125, -85.4189453125),
	Vector2(455.794921875, -82.3564453125),
	Vector2(454.373046875, -82.2666015625),
	Vector2(452.2412109375, -84.7158203125),
	Vector2(450.8154296875, -85.2353515625),
	Vector2(449.4658203125, -85.1494140625),
	Vector2(447.8525390625, -85.046875),
	Vector2(445.78515625, -84.916015625),
	Vector2(444.3955078125, -84.8271484375),
	Vector2(443.66796875, -84.166015625),
	Vector2(443.771484375, -82.5322265625),
	Vector2(444.2373046875, -81.37109375),
	Vector2(445.3369140625, -81.44140625),
	Vector2(446.4755859375, -81.513671875),
	Vector2(448.0166015625, -81.611328125),
	Vector2(449.4873046875, -81.705078125),
	Vector2(450.572265625, -81.7744140625),
	Vector2(451.421875, -81.5986328125),
	Vector2(451.529296875, -79.9130859375),
	Vector2(450.6669921875, -79.564453125),
	Vector2(448.9091796875, -79.4521484375),
	Vector2(447.6455078125, -79.3720703125),
	Vector2(442.1015625, -82.0595703125),
	Vector2(440.7900390625, -82.14453125),
	Vector2(439.80078125, -81.220703125),
	Vector2(438.33984375, -81.1142578125),
	Vector2(436.7880859375, -81.2685546875),
	Vector2(436.677734375, -82.6376953125),
	Vector2(436.83984375, -84.267578125),
	Vector2(436.9501953125, -85.37890625),
	Vector2(439.37109375, -84.9228515625),
	Vector2(439.5166015625, -83.5263671875),
	Vector2(441.0458984375, -86.7060546875),
	Vector2(444.7568359375, -86.8828125),
	Vector2(449.890625, -87.5380859375),
	Vector2(449.861328125, -86.4619140625),
	Vector2(449.302734375, -86.08203125),
	Vector2(448.921875, -85.4658203125),
	Vector2(448.8740234375, -84.2822265625),
	Vector2(448.126953125, -83.833984375),
	Vector2(446.916015625, -83.8837890625),
	Vector2(445.8271484375, -83.9287109375),
	Vector2(444.7578125, -83.9716796875),
	Vector2(449.81640625, -83.6552734375),
	Vector2(451.9228515625, -83.6513671875),
	Vector2(452.708984375, -84.8583984375),
	Vector2(452.1357421875, -85.1845703125),
	Vector2(441.248046875, -85.46484375),
	Vector2(433.4052734375, -86.10546875),
	Vector2(433.478515625, -88.27734375),
	Vector2(435.087890625, -88.7861328125),
	Vector2(436.3271484375, -88.7353515625),
	Vector2(438.3701171875, -88.65234375),
	Vector2(440.04296875, -88.583984375),
	Vector2(442.09375, -88.5),
	Vector2(443.7734375, -88.498046875),
	Vector2(445.2744140625, -88.4375),
	Vector2(447.44921875, -88.431640625),
	Vector2(449.4912109375, -88.390625),
	Vector2(451.7255859375, -88.44140625),
	Vector2(452.8935546875, -88.3935546875),
	Vector2(454.853515625, -88.3134765625),
	Vector2(456.439453125, -88.2490234375),
	Vector2(457.1630859375, -88.2197265625),
	Vector2(458.787109375, -86.90234375)
}
