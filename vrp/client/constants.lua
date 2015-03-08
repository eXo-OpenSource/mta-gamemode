-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/constants.lua
-- *  PURPOSE:     Global clientside constants
-- *
-- ****************************************************************************

screenWidth, screenHeight = guiGetScreenSize()
screenSize = Vector2(screenWidth, screenHeight)
ASPECT_RATIO_MULTIPLIER = (screenWidth/screenHeight)/1.8

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

RadarDesign = {Monochrome = 1, GTA = 2}

HelpTexts = {
	General = {
		Main = [[Todo]];
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
			Doneasty <doneasty@v-roleplay.net> (außerdem verantwortlich für Grafik und Design)
			Sarcasm <sarcasm@v-roleplay.net> (außerdem verantwortlich für den Webauftritt)

			Moderation:
			Toxsi <toxsi@v-roleplay.net> (außerdem verantwortlich für Mapping)

			Vielen Dank an:
			Sam@ke (für seine wunderschönen Shader)
			thefleshpound (für seine Zeit als Grafiker)
			Schlumpf (für seine kurze Zeit als Mapper)
			ReZ (für seine kurze Zeit als Mapper)
			Alex (für seine Zeit als Mapper)
		]];
	};
	Jobs = {
		BusDriver = [[Todo]];
		Farmer = [[Todo]];
		Logistician = [[Todo]];
		Lumberjack = [[Todo]];
		Mechanic = [[Todo]];
		Police = [[Todo]];
		RoadSweeper = [[Todo]];
		Trashman = [[Todo]];
	};
};

HelpTextTitles = {
	General = {
		Main = "Main";
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
	}
}