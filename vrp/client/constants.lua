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

HTTP_DOWNLOAD = not DEBUG
FILE_HTTP_SERVER_URL = "https://download.exo-reallife.de/files/release/production/vrp_assets/" -- Todo: move to config
FILE_HTTP_FALLBACK_URL = "https://download2.exo-reallife.de/files/release/production/vrp_assets/" -- Todo: see above
TEXTURE_HTTP_URL = "https://picupload.pewx.de/textures"
HTTP_CONNECT_ATTEMPTS = 2 -- Todo: see above

RadarDesign = {Monochrome = 1, GTA = 2}
for i, v in pairs(RadarDesign) do RadarDesign[v] = i end

UIStyle = {vRoleplay = 1, eXo = 2, Default = 3, Chart = 4,
		[1] = "vRoleplay", [2] = "eXo", [3] = "Default", [4] = "Chart",}

--for i, v in pairs(UIStyle) do UIStyle[v] = i end -- this doesn't work for some weird reason!

NametagStyle = {On = 1, Off = 2}
for i, v in pairs(NametagStyle) do NametagStyle[v] = i end

MATERIAL_TYPES =
{
	[1] = 	--// GRASS
	{
		9,
		10,
		11,
		12,
		13,
		14,
		15,
		16,
		17,
		20,
		80,
		81,
		82,
		115,
		116,
		117,
		118,
		119,
		120,
		121,
		122,
		125,
		146,
		147,
		148,
		149,
		150,
		151,
		152,
		153,
		160,
	},
	[2] = 	--// DIRT
	{
		19,
		21,
		22,
		24,
		25,
		26,
		27,
		40,
		83,
		84,
		87,
		88,
		100,
		110,
		123,
		124,
		126,
		128,
		129,
		130,
		132,
		133,
		141,
		142,
		145,
		155,
		156,
	},
	[3] = { -- BUSHY, but not hedge
		111,
		112,
		114,
	}
}


HelpTextTitles = {
	Jobs = {
		Boxer = "Job: Boxer";
		BusDriver = "Job: Busfahrer";
		Farmer = "Job: Bauer";
		Logistician = "Job: Logistik";
		Lumberjack = "Job: Holzfäller";
		Mechanic = "Job: Mechaniker";
		Police = "Job: Polizist";
		RoadSweeper = "Job: Straßenkehrer";
		Trashman = "Job: Müllmann";
		ServiceTechnician = "Job: Service-Techniker";
		PizzaDelivery = "Job: Pizza-Lieferant";
		HeliTransport = "Job: Helikopterpilot";
		ForkLift = "Job: Gabelstapler-Fahrer";
		TreasureSeeker = "Job: Schatzsucher";
		Gravel = "Job: Kiesgruben-Arbeiter";
	};
	Minigames = {
		ZombieSurvival = "Minigame: Zombie Survival";
		GoJump = "Minigame: GoJump";
		SideSwipe = "Minigame: SideSwipe";
		SniperGame = "Minigame: Sniper Game";
		TCars = "Minigame: 2Cars";
		Roulette = "Casino: Roulette";
	};
}

HelpTexts = {
	Jobs = {
		Boxer = [[
			Als Boxer musst du gegen andere Boxer antreten und diese im Kampf besiegen.
			Gewinnst du den Kampf, gewinnst du ein Preisgeld.
			Verlierst du jedoch, gehst du leer aus.
		]];
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
		Logistician = [[
			Als Logistiker ist es dein Job, Container zum anderen Verladezentrum zu fahren.
			Dazu hast du einen DFT-300 zur Verfügung, den du dir am roten Marker erstellen kannst.
			Anschließend musst du unter den Ladekran fahren und warten bis der Container aufgeladen wurde.
			Dein Ziel wird dir auf der Karte markiert.
		]];
		Lumberjack = [[
			Als Holzfäller musst du die Bäume am Hügel (gelb markiert auf der Karte)
			fällen und sie zum Sägewerk fahren.
			Sofern du genug Bäume gefällt hast schnappst du dir einen Flatbed und fährst in den blauen Marker, neben welchem sich ein Haufen von Bäumen angesammelt hat (deine gefällten Bäume).
			Nun werden diese Bäume aufgeladen. Nachdem sie aufgeladen wurden musst du zum Sägewerk fahren (die rote Säge oder Punkt auf der Karte). Dort lieferst du sie ab.
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
			Laufe in den roten Marker und hole dir dein benötigtes Fahrzeug.
			Sofern du es hast kannst du nun losfahren und über den auf der Straße liegenden Müll fahren um ihn aufzukehren.
		]];
		HeliTransport = [[
			Du bist der Pilot eines Helikopters und musst Waren transportieren.
			Deinen Helikopter bekommst du beim roten Marker.
			Mit diesem begibst du dich dann zum markierten Ort an den LS-Docks, wo Waren auf dich warten.
			Lande darauf und fliege anschließend zum angegebenen Zielort!
		]];
		Trashman = [[
			Als Müllmann musst du mit deinem Müllwagen Abfalltonnen & Container abholen.
			Im roten Marker bekommst du dein benötigtes Fahrzeug.
			In den Straßen von Los Santos sind Mülltonnen verteilt, neben denen du halten musst.
			Fahre Anschließend zur Deponie zurück und lade deinen Müll in der Dump-Area aus.
		]];
		ServiceTechnician = [[Todo]];
		PizzaDelivery = [[
			Als Pizzalieferant hast du die Aufgabe die Ware des Pizza Stacks an die jeweiligen Orte zu liefern.
			Du erhälst deine Ware beim Pizza Stack ( Marker ) und lieferst Sie zum Ziel ( Ziel-Icon beim Radar ) ab.
			Desto schneller du dies schaffst, desto höher ist dein Bonus.
		]];
		ForkLift = [[
			Wenn du Gabelstaplerfahrer bist, kannst du mit deinem Forklift Kisten aufladen.
			Diese musst du anschließend bei den LKW's abliefern.
			Deinen Forklift kannst du dir am roten Marker erstellen.
		]];
		TreasureSeeker = [[
			Als Schatzsucher fährst du hinaus aufs Meer um den Grund des Meeres nach Wertgegenständen
			abzusuchen. Anschließend hebst du diese in dein Schiff und entlädst sie am Hafen!

			Drücke 'Leertaste' um den "Schatz" aufzunehmen.
		]];
		Gravel = [[
			Der Job ist in 3 Arbeitsschritte aufgeteilt die verschiedene Spieler zu gleich ausführen können.

			1.) Abbau mit Spitzhacke: Baue die hellen Felsen direkt neben dem Dozer-Spawn mit der Spitzhacke ab. (Klicken zum Abbauen)

			2.) Einlagern: Lagere die abgebauten Gesteinsbrocken ein indem du diese mit dem Dozer in die Behälter schiebst.

			3.) Transport: Transportiere die eingelagerten Gesteinsbrocken mit dem Dumper aus der Kiesgrube. Zum Beladen fahre einfach unter ein Förderband.
		]];

	};
	Minigames = {
		ZombieSurvival = [[
			Kämpfe gegen Zombies bis zu deinem bitteren Tod! In der Area spawnen immer wieder gute Waffen,
			die du dringend für deinen Überlebenskampf brauchst!
		]];
		GoJump = [[
			Minigame: GoJump
		]];
		SideSwipe = [[
			Minigame: SideSwipe (Keine Highscores, da noch nicht fertig!)
		]];
		SniperGame = [[
			Erledige alle gespawnten Peds mit gezielten Kopfschüssen bevor sie die gelbe Linie übertreten!
		]];
		TCars = [[
			Steuere beide Autos mit den Tasten 'a' und 'd' oder Pfeilsten links, rechts. Weiche den Kästchen aus und sammel jeden Punkt.
		]];
		Roulette = [[
			Das Ziel ist wie bei jedem Glücksspiel mit einer „Wette“ Geld zu gewinnen. Man setzt einen bestimmten Betrag
			ein Feld und vertraut auf sein Glück!
		]];

	};
};

SkinShops = {
	{
		Marker = Vector3(218.2, -98.5, 1004.3);
		MarkerInt = 15;
		PlayerPos = Vector3(217.922, -98.563, 1005.258);
		PlayerRot = Vector3(0.000, 0.000, 299);
		CameraMatrix = {216.056396484375, -99.181800842285156, 1006.8388061523437, 216.90571594238281, -98.900047302246094, 1006.3923950195312, 0, 70};
		Levels = {1, 5};
	};
	{
		Marker = Vector3(177.179, -86.714, 1000.805);
		MarkerInt = 18;
		PlayerPos = Vector3(181.724, -88.541, 1002.023);
		PlayerRot = Vector3(0.000, 0.000, 90);
		CameraMatrix = {177.40980529785, -87.031700134277, 1003.7614746094, 178.3257598877, -87.35213470459, 1003.5198974609, 0, 70};
		Levels = {6, 10};
	};
}

SHADERS = {
	["SkyBox"] = {["event"] = "switchSkyBox" },
	["Detail"] = {["event"] = "switchDetail" },
	["Contrast"] = {["event"] = "switchContrast" },
	["Carpaint"] = {["event"] = "switchCarPaint" },
	["Roadshine"] = {["event"] = "switchRoadshine" },
	["Water"] = {["event"] = "switchWaterRefract" },
	["WetRoads"] = {["event"] = "switchWetRoads" },
	["Bloom"] = {["event"] = "switchBloom" },
	--["Sun"] = {["event"] = "switchSunShader"},
	["DoF"] = {["event"] = "switchDoF"},
}

GUNBOX_CRATES = {
	createObject(2977, 1366.06, -1286.34, 12.4),
	createObject(2977, 2397.80, -1980.82, 12.4),
	createObject(2977, 1328.33, -1560.27, 12.6)
}

for i = 1,#GUNBOX_CRATES do
	setElementFrozen( GUNBOX_CRATES[i], true)
	setObjectBreakable( GUNBOX_CRATES[i], false)
end


AREA51_WARNING = createColCuboid(-32.87, 1667.50, -35, 450, 450, 135)
addEventHandler("onClientColShapeHit",AREA51_WARNING,function(hE)
	if hE == localPlayer then
		if ShortMessage then
			if not(localPlayer:getFaction() and localPlayer:getFaction():isStateFaction()) then
				ShortMessage:new(_"Du betrittst ein militärisches Sperrgebiet! Sei vorsichtig!")
			end
		end
	end
end)

NOTIFICATION_TYPE_INVATION = 1
NOTIFICATION_TYPE_GAME     = 2

TEXTURE_SYSTEM_HELP =
{
	[1] = "In diesem Modus werden Fahrzeug-Texturen erst geladen, wenn ein entsprechendes Fahrzeug in deiner Nähe ist. Dies führt dazu, dass du nur die Texturen lädst, welche du auch benötigst.\nSinnvoll bei Graifkkarten mit wenig Videospeicher",
	[2] = "In diesem Modus werden beim einloggen alle Fahrzeug-Texturen geladen.\nAchtung: Dies führt zu einem Standbild von mehreren Sekunden! Anschließend müssen jedoch keine Texturen mehr geladen werden.\nSinnvoll bei Grafikkarten mit viel Videospeicher!",
	[3] = "Alle optionalen Texturen (Custom-Texturen, etc.) sind ausgeschaltet und werden nicht geladen.",
}

TEXTURE_LOADING_MODE = {STREAM = 1, PERMANENT = 2, NONE = 3, [1] = "STREAM", [2] = "PERMANENT", [3] = "NONE"}
TEXTURE_LOADING_MODE.DEFAULT = dxGetStatus()["VideoCardRAM"] >= 256 and TEXTURE_LOADING_MODE.PERMANENT or TEXTURE_LOADING_MODE.NONE
FILE_TEXTURE_DEFAULT_STATE = dxGetStatus()["VideoCardRAM"] >= 256
HTTP_TEXTURE_DEFAULT_STATE = dxGetStatus()["VideoCardRAM"] >= 512

CUSTOM_RINGSOUND_PATH = "files/audio/Ringtones/custom.mp3"
CUSTOM_FACTION_RINGSOUND_PATH = "files/audio/Ringtones/customFaction.mp3"
CUSTOM_COMPANY_RINGSOUND_PATH = "files/audio/Ringtones/customCompany.mp3"
CUSTOM_GROUP_RINGSOUND_PATH = "files/audio/Ringtones/customGroup.mp3"
CUSTOM_TUNINGSOUND_PATH = "files/audio/vehicles/VehicleTuning.mp3"

PHONE_MODELS = {
	{Name = "Nexus 5", Image = "Nexus_5.png", IconPreset = "Android"},
	{Name = "iPhone schwarz", Image = "iPhone_schwarz.png", IconPreset = "iPhone"},
	{Name = "iPhone weiß", Image = "iPhone_weiss.png", IconPreset = "iPhone"},
}
for k, v in pairs(PHONE_MODELS) do if type(v) == "table" then PHONE_MODELS[v.Name] = k end end


--[[ EASTEREGG-ARCADE ]]
EASTEREGG_IMAGE_PATH = ":"..getResourceName(getThisResource()).."/files/images/arcade-game/"
EASTEREGG_FILE_PATH = ":"..getResourceName(getThisResource()).."/files/fonts/"
EASTEREGG_SFX_PATH = ":"..getResourceName(getThisResource()).."/files/audio/arcade-sfx/"
EASTEREGG_TICK_CAP = 1000/ 59.99
EASTEREGG_NATIVE_RATIO = {x=1024;y=512}
EASTEREGG_WINDOW_WIDTH, EASTEREGG_WINDOW_HEIGHT = screenWidth, screenHeight
EASTEREGG_FONT_SCALE = 1
EASTEREGG_JUMP_RATIO = 16
EASTEREGG_PROJECTILE_SPEED = 3
EASTEREGG_ARENA_IMAGE = "arena"
local w, h = screenWidth, screenHeight
if EASTEREGG_WINDOW_WIDTH >= 1600 then
	EASTEREGG_FONT_SCALE = 1
	EASTEREGG_WINDOW = {{x=(w*0.5)-512;y=(h*0.5)-256}, {x=1024, y=512}}
	EASTEREGG_JUMP_RATIO = 16
	EASTEREGG_PROJECTILE_SPEED = 1
elseif EASTEREGG_WINDOW_WIDTH >= 1024 then
	EASTEREGG_FONT_SCALE = 0.75
	EASTEREGG_WINDOW = {{x=(w*0.5)-256;y=(h*0.5)-128}, {x=512, y=256}}
	EASTEREGG_JUMP_RATIO = 8
	EASTEREGG_PROJECTILE_SPEED = 0.4
else
	EASTEREGG_FONT_SCALE = 0.75
	EASTEREGG_WINDOW = {{x=(w*0.5)-256;y=(h*0.5)-128}, {x=512, y=256}}
	EASTEREGG_JUMP_RATIO = 8
	EASTEREGG_PROJECTILE_SPEED = 0.25
end
EASTEREGG_RESOLUTION_RATIO = (EASTEREGG_WINDOW[2].x * EASTEREGG_WINDOW[2].y )  /  (EASTEREGG_NATIVE_RATIO.x*EASTEREGG_NATIVE_RATIO.y)
EASTEREGG_KEY_MOVES =
{
	["a"] = "left",
	["d"] = "right",
	["s"] = "crouch",
	["w"] = "jump",
	["space"] = "punch",
	["<"] = "strafe_left",
	[">"] = "strafe_right",
}
EASTEREGG_MAX_UPDATE_RATE = 80
EASTEREGG_SLEEP_UPDATETICK = 1000/ EASTEREGG_MAX_UPDATE_RATE
EASTEREGG_DISPLAY_SIZE = {x=512, y=256}

JobBoxerFights = { --Gewicht, Leben, erforderliches Boxerlevel
	{"Fliegengewicht", 50, 0},
	{"Leichtgewicht", 75, 10},
	{"Mittelgewicht", 100, 25},
	{"Cruisergewicht", 150, 50},
	{"Schwergewicht", 200, 100}
}

JobBoxerFightRandoms = { --maxRandom, punch, block, left, right
	{15, 6, 9, 11, 13},
	{15, 7, 10, 11, 13},
	{14, 8, 11, 12, 13},
	{16, 8, 13, 14, 15},
	{17, 10, 17, 17, 17}
}


METER_TO_FEET = 3.28084
KMH_TO_KNOTS = 0.539957


ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM = {
	PFD = {
		INDEX = 1,
		--//PRIMARY FLIGHT DISPLAY
		GROUNDSPEED_DISPLAY = 1;
		ARTIFICIAL_HORIZON = 2;
		ALTIMETER = 3;
	};
	SFD = {
		INDEX = 2;
		--//SECONDARY FLIGHT DISPLAY
		CAUTION_WARNING_DISPLAY = 1;
		HEADING_INDICATOR = 2;
	};
	ECAS = {
		INDEX = 3;
		--//ENGINE INDICATION AND CREW ALERTING SYSTEM
		ENGINE_PANEL = 1;
	};
}
