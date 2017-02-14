SceneTour = {
	name = "Intro";
	startscene = "Welcome";
	debug = true;

	-- Scene 1
	{
		uid = "Welcome";
		letterbox = true;
		{
			action = "General.fade";
			fadein = false;
			time = 0;
			starttick = 0;
		};
		{
			action = "General.weather";
			time = {9,0};
			farclipdistance = 2000;
			fogdistance = 0;
			clouds = false;
			weather = 0;
			starttick = 0;
		};
		{
			action = "Audio.playSound";
			path = "Intro.mp3";
			starttick = 0;
			duration = 200000;
		};
		{
			action = "Camera.set";
			starttick = 0;
			pos = {1492, -159.8, 185};
			lookat = {1553.3, -1338.8, 176.4};
		};
		{
			action = "Camera.move";
			starttick = 0;
			duration = 19000;
			pos = {1492, -159.8, 185};
			targetpos = {1530.8, -945.3, 179};
			lookat = {1553.3, -1338.8, 176.4};
		};
		{
			action = "General.fade";
			fadein = true;
			time = 10000;
			starttick = 50;
		};
		{
			action = "Graphic.drawText";
			color = tocolor(255, 255, 255);
			duration = 19000;
			starttick = 0;
			text = "Willkommen auf";
			scale = 3;
			pos = { 0.5, 0.35 };
		};
		{
			action = "Graphic.drawImage";
			path = "Logo.png";
			pos = {0.4, 0.4};
			size = {0.2, 0.2};
			starttick = 0;
			duration = 19000;
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 5000;
			starttick = 4000;
			text = "Bevor es losgehen kann, ein paar Worte zum Spielkonzept.";
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 5000;
			starttick = 9000;
			text = "Grundsätzlich bist du frei in all deinen Tätigkeiten,";
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 5000;
			starttick = 14000;
			text = "musst aber mit den Konsequenzen rechnen.";
		};
					{
			action = "General.fade";
			fadein = false;
			time = 2000;
			starttick = 17000;
		};
		{
			action = "General.change_scene";
			starttick = 19000;
			scene = "Noobspawn/PD";
		}
	};
	{
		uid = "Noobspawn/PD";
		{
			action = "Camera.set";
			starttick = 0;
			pos = {1431.35, -1727.59, 22.38};
			lookat = {1480.72, -1773.21, 15.78 };
		};
		{
			action = "General.fade";
			fadein = true;
			time = 1000;
			starttick = 1000;
		};

		{
			action = "Camera.move"; -- Noobspawn
			pos = {1431.35, -1727.59, 22.38};
			targetpos = {1521.80, -1733.61, 28.29};
			lookat = {1480.72, -1773.21, 15.78};
			starttick = 2000;
			duration = 5000;
		};
		{
			action = "Camera.move"; -- Rotate to PD
			pos = {1521.80, -1733.61, 28.29};
			targetpos = {1521.80, -1733.61, 28.29};
			lookat = {1480.72, -1773.21, 15.78};
			targetlookat = {1549.98, -1675.27, 15.20};
			starttick = 7000;
			duration = 3000;
		};
		{
			action = "Camera.move"; -- PD
			pos = {1521.80, -1733.61, 28.29};
			targetpos = {1510.83, -1604.54, 28.27};
			lookat = {1549.98, -1675.27, 15.20};
			targetlookat = { 1546.64, -1627.34, 13.38};
			starttick = 10000;
			duration = 8000;
		};
		{
			action = "Ped.create";
			id = "policedriver";
			model = 280;
			rot = 0;
			starttick = 15000;
			pos = {1529.57, -1584.75, 13.55};
		};
		{
			action = "Vehicle.create";
			starttick = 15000;
			id = "policecar";
			model = 596;
			pos = {1527.91, -1585.17, 13.27};
			rot = {0, 0, 180};
		};
		{
			action = "Ped.warpIntoVehicle";
			starttick = 15000;
			id = "policedriver";
			vehicle = "policecar";
		};
		{
			action = "Ped.setControlState";
			starttick = 15000;
			id = "policedriver";
			control = "accelerate";
			state = true;
		};
		{
			action = "Ped.create";
			id = "robber";
			model = 174;
			rot = 180;
			starttick = 15000;
			pos = {1537.35, -1585.83, 13.55};
		};
		{
			action = "Ped.setAnimation";
			starttick = 15000;
			id = "robber";
			animBlock = "ped";
			anim = "run_player";
			looped = true;
		};
		{
			action = "Ped.create";
			id = "robberCop";
			model = 280;
			rot = 180;
			starttick = 16000;
			pos = {1537.35, -1585.83, 13.55};
		};
		{
			action = "Ped.setAnimation";
			starttick = 16000;
			id = "robberCop";
			animBlock = "ped";
			anim = "run_player";
			looped = true;
		};
		{
			action = "Ped.giveWeapon";
			starttick = 16000;
			id = "robberCop";
			weapon = 24;
		};

		{
			action = "Camera.move"; -- Move to robbers
			pos = {1510.83, -1604.54, 28.27};
			targetpos = {1529.14, -1641.64, 13.38};
			lookat = {1546.64, -1627.34, 13.38};
			targetlookat = {1537.17, -1631.83, 13.38};
			starttick = 18000;
			duration = 4000;
		};

		{
			action = "Ped.setAnimation";
			starttick = 23000;
			id = "robber";
			animBlock = "shop";
			anim = "SHP_HandsUp_Scr";
			looped = false;
		};
		{
			action = "Ped.setAnimation";
			starttick = 23000;
			id = "robberCop";
			animBlock = "ped";
			anim = "arrestgun";
			looped = false;
		};
		{
			action = "Camera.move"; -- Move up
			pos = {1529.14, -1641.64, 13.38};
			targetpos = {1529.14, -1641.64, 60};
			lookat = {1537.17, -1631.83, 13.38};
			targetlookat = {1661.25, -1699.25, 60};
			starttick = 24000;
			duration = 4000;
		};
		{
			action = "Camera.move"; -- Drive To Rescue
			pos = {1529.14, -1641.64, 60};
			targetpos = {1693.79, -1713.92, 30};
			lookat = {1661.25, -1699.25, 60};
			targetlookat = {1745.94, -1744.71, 30};
			starttick = 28000;
			duration = 4000;
		};
		{
			action = "Camera.move"; -- Drive To Rescue
			pos = {1693.79, -1713.92, 30};
			targetpos = {1848.13, -1711.83, 49.94};
			lookat = {1745.94, -1744.71, 30};
			targetlookat = {1745.94, -1744.71, 30};
			starttick = 32000;
			duration = 5000;
		};
	};
}


(15, 'Ich bin seit der Beta dabei!', 'Logge dich waehrend der iLife-Betaphase ein.', 8, 2),
(2, 'Erster! :)', 'Logge dich innerhalb der ersten 4 Stunden nach der Eroeffnung ein.', 8, 3),
(3, 'Es hat sich ausgesimst', 'Stelle mehr als 60 Moebelstuecke in dein Haus.', 4, 4),
(4, 'Breaking Bad', 'Erlange mindestens 98% Reinheit beim Drogenkoch Job.', 2, 5),
(5, 'Der Start ins Leben', 'Gehe Arbeiten.', 2, 6),
(6, 'Trautes Heim - Glueck allein', 'Kaufe dir ein Haus', 4, 7),
(7, 'Die Taube war es!', 'T\\oete einen Spieler', 1, 1),
(8, 'Bin ich Kenny?', 'Sterbe 100 mal.', 1, 1),
(9, 'Brrrrrummm', 'Tune dein Fahrzeug', 3, 1),
(10, 'Stellt die Gummibaeume auf!', 'Kaufe ein Fahrzeug.', 3, 1),
(11, 'Penner Style', 'Finde 100 Pfandflaschen.', 7, 8),
(12, 'Neues Aussehen!', 'Individualisiere dein HUD.', 1, 1),
(13, 'Das ballert!', 'Nehme eine beliebige Droge.', 7, 1),
(14, 'Gemeinschaft', 'Gebe einen anderen Spieler den Schluessel fuer dein Haus.', 4, 1),
(1, 'JSON Placeholder', 'Do not give this Achievement!!!!', 8, 1),
(16, 'Da war ja was drin', 'Finde etwas in einer Mueltonne', 7, 1),
(17, 'Die ersten Schritte', 'Erreiche zehn Spielstunden', 1, 1),
(18, 'Es geht vorran', 'Erreiche 50 Spielstunden', 1, 1),
(19, 'Gelegenheitsspieler', 'Erreiche 100 Spielstunden', 1, 1),
(20, 'Stammspieler', 'Erreiche 250 Spielstunden', 1, 1),
(21, 'Suchtlappen', 'Erreiche 500 Spielstunden', 1, 9),
(22, 'Kein Leben?!', 'Erreiche 1000 Spielstunden', 1, 10),
(23, 'Den Kodex ehren', 'Finde Dexter un schlie\\sze seine Quest ab.', 10, 11),
(24, 'Pew, Pew, PewX!', 'Finde den HorrorClown', 10, 1),
(25, 'Very Impressive!', 'Finde das Doge Easteregg', 10, 1),
(26, 'Ich hab den Lappen', 'Zeige jemanden deinen F\\uehrerschein', 1, 1),
(27, 'Pinkman', 'Erlange mindestens 60% Reinheit beim Drogenkoch Job.', 2, 1),
(28, 'Rainbows', 'Faerbe ein Fahrzeug um.', 3, 1),
(29, 'And it''s gone', 'Verliere ein Fahrzeug.', 3, 1),
(30, 'Wisch Wasch', 'Fahre durch die Waschstra\\sze', 3, 1),
(31, 'Hier, benutz es!', 'Gebe deinen Fahrzeugschluessel an einen anderen Spieler.', 3, 1),
(32, 'Ich wei\\sz nicht wohin!', 'Parke hundert Fahrzeuge!', 3, 1),
(33, 'Quereinsteiger', 'Verdiene 30.000$', 2, 1),
(34, 'Angestellter', 'Verdiene 100.000$', 2, 1),
(35, 'Manager', 'Verdiene 250.000$', 2, 1),
(36, 'Dauerarbeiter', 'Verdiene 1.000.000$', 2, 12),
(37, 'Ich habe eine Villa!', 'Kaufe ein Haus mit einem Wert von mind. 900.000$', 4, 1),
(38, 'Das Ambiente passt', 'Spiele Musik in deinem Haus ab', 4, 1),
(39, 'Laggt vielleicht etwas!', 'Platziere mehr als 100 Moebelstuecke in deinem Haus', 4, 1),
(40, 'Wozu nur eins?', 'Kaufe dir ein zweites Haus', 4, 1),
(41, 'Medal of iLife', 'Dieses Achievement wird fuer besonderes Engagement vergeben!', 8, 16),
(42, 'Armageddon? Pah', 'Rette die Welt vor boesen Aliens!', 8, 1),
(43, 'Ich bin so traurig!', 'Musiziere auf der kleinsten Geige der Welt.', 8, 1),
(44, 'iRacer', 'Oeffne eine iRace-Kiste', 8, 1),
(45, 'Neuschreiberling!', 'Finde ReWrite und klicke ihn an!', 10, 1),
(46, 'Streichel das Pony!', 'Finde Dawi und klicke ihn an!', 10, 1),
(47, 'Fuck you internet!', 'Finde Shape und klicke ihn an!', 10, 1),
(48, 'Ich bin ein Eishorn', 'Finde Marcelsius und klicke ihn an!', 10, 1),
(49, 'Irgendwo Fachpersonal?', 'Finde Samy und klicke ihn an!', 10, 1),
(50, 'Verkaufst du Kamele?', 'Finde KingK und klicke ihn an!', 10, 1),
(51, 'SUV?! MuLtiVaN!', 'Finde Noneatme und klicke ihn an!', 10, 1),
(52, 'Omnomnom', 'Finde Monster und klicke ihn an!', 10, 1),
(53, 'Gleich gibts Haue!', 'Finde Ryker und klicke ihn an!', 10, 1),
(54, 'This Audi on Fire!', 'Finde Audifire und klicke ihn an!', 10, 1),
(55, 'Reazon der Baer!', 'Finde Reazon', 10, 1),
(56, 'Schrotty Jenkins', 'Finde Schrotty', 10, 1),
(57, 'Wo ist es hin?', 'Lass dir ein Objekt fl\\oeten gehen.\r\n', 4, 13),
(58, 'Gesucht', 'Bekomme ein Wanted', 1, 1),
(59, 'Knastbruder', 'Komme ins Gef\\aengnis', 1, 1),
(60, 'Panzerknacker', 'Bekomme sechs Wanteds', 1, 1),
(61, 'Ihre Werbung hier!', 'Benutze einen Werbeantrag!', 7, 1),
(62, 'Ich bin nicht s\\uechtig!', 'Bleibe 12 Stunden eingeloggt!', 1, 1),
(63, 'Goldener Schuss', 'Sterbe an einer \\Ueberdosis Drogen', 1, 1),
(64, 'Gewonnen!', 'Gewinne 12.000$ mit einem Rubbellos', 7, 1),
(65, 'Parteiisch', 'Trete einer Fraktion bei', 5, 1),
(66, 'Private Show', 'Besuche einen Stripclub', 6, 1),
(67, '\\Ueberlebensk\\uenstler', 'Gewinne ein HungerGame', 1, 1),
(68, 'Und? Schick?', 'Kaufe dir einen Skin', 1, 1),
(69, 'Bewaffnet', 'Komme in den Besitz einer Waffe', 1, 1),
(70, 'Herrscher', 'Gewinne 100 Gangwars', 5, 14),
(71, 'Disco Disco Party Party', 'Betrete einen Club', 6, 1),
(72, 'Alles Fit?', 'Betrete ein GYM', 6, 1),
(73, '\\Ueber den Wolken', 'Bezwinge den Mount Chilliard', 6, 1),
(74, 'Wo ist denn...', 'Benutze den Kartenfilter', 1, 1),
(75, 'Hier, ist f\\uer dich...', '\\Ueberweise jemanden Geld', 1, 1),
(76, 'Wahre Kunst!', 'Benutze "Das Buch der Gotteskunst"', 7, 15),
(77, 'Jeder liebt Shrimps!', 'Konsumiere "Shrimps"', 7, 1),
(78, 'Wer l\\aesst sowas zur\\ueck?!', 'Finde ein Drogenpaket', 7, 1),
(79, 'Big Boss', 'Werde zum Leader einer Fraktion ernannt!', 5, 1),
(80, 'Back to the Roots!', 'Verlasse eine Fraktion', 5, 1),
(81, 'Rein mit dir!', 'Bringe einen Spieler in das Gef\\aengnis.', 5, 1),
(82, 'BzzzZZZzzzz!', 'Tazer einen Gejagten!', 5, 1),
(83, 'Er wollte nicht anders!', 'T\\oete einen Spieler und bringe ihn dadurch in das Gef\\aengnis', 5, 1),
(84, 'Holland?!', 'Fahre nach Bayside!', 6, 1),
(85, 'Garnichts los?', 'Fahre zum San Fierro Bahnhof.', 6, 1),
(86, 'Es hat keinen Sinn!', 'Begehe Selbstmord', 1, 1),
(87, 'Bauer Jenkins', 'Finde Bauer Jenkins.', 10, 1),
(88, 'Bergsteiger Jenkins', 'Finde den Bergsteiger Jenkins.', 10, 1),
(89, 'Vorarbeiter Jenkins', 'Finde Vorarbeiter Jenkins.', 10, 1),
(90, 'Golfer Jenkins', 'Finde Golfer Jenkins.', 10, 1),
(91, 'Dealer Jenkins', 'Finde Dealer Jenkins.', 10, 1),
(92, 'K\\oenig Jenkins', 'Finde K\\oenig Jenkins.', 10, 1),
(93, 'Holzf\\aeller Jenkins', 'Finde Holzf\\aeller Jenkins.', 10, 1),
(94, 'Hassprediger Jenkins', 'Finde Hassprediger Jenkins.', 10, 1),
(95, 'G\\uenther Jenkins', 'Finde G\\uenther Jenkins.', 10, 1),
(96, 'Chemiker Jenkins', 'Finde Chemiker Jenkins.', 10, 1),
(97, 'Angler Jenkins', 'Finde Angler Jenkins.', 10, 1),
(98, 'Penner Jenkins', 'Finde Penner Jenkins.', 10, 1),
(99, 'Praesident Jenkins', 'Finde Praesident Jenkins.', 10, 1),
(100, 'Indianer Jenkins', 'Finde Indianer Jenkins.', 10, 1),
(101, 'Imbiss Jenkins', 'Finde Imbiss Jenkins.', 10, 1),
(102, 'Wetterfrosch Jenkins', 'Finde Wetterfrosch Jenkins.', 10, 1),
(103, 'Kolumbus Jenkins', 'Finde Kolumbus Jenkins.', 10, 1),
(104, 'Autobot Jenkins', 'Finde Autobot Jenkins.', 10, 1),
(105, 'Bibliothekar Jenkins', 'Finde Bibliothekar Jenkins.', 10, 1),
(106, 'Mutant Jenkins', 'Finde Mutant Jenkins.', 10, 1),
(107, 'Schwarzmarkt Jenkins', 'Finde Schwarzmarkt Jenkins.', 10, 1),
(108, 'Bigfoot Jenkins', 'Finde Bigfoot Jenkins.', 10, 1),
(109, 'Callgirl Jenkins', 'Finde Callgirl Jenkins.', 10, 1),
(110, 'Einsamer Jenkins', 'Finde Einsamer Jenkins.', 10, 1),
(111, 'Mediziner Jenkins', 'Finde Mediziner Jenkins.', 10, 1),
(112, 'Chicken Jenkins', 'Finde Chicken Jenkins.', 10, 1),
(113, 'Eine lange Reise', 'Finde alle Jenkins Eastereggs.', 10, 17),
(114, 'MMORPG?!', 'Schlie\\sze eine normale Quest ab.', 9, 1),
(115, 'T\\aeglich Brot', 'Erledige eine t\\aegliche Quest.', 9, 1),
(116, 'Und nochmal!', 'Schlie\\sze eine wiederholbare Quest ab.', 9, 1),
(117, 'Fortschritt', 'Schlie\\sze 25 normale Quests ab.', 9, 1),
(118, 'Dauerquester', 'Schlie\\sze 50 normale Quests ab.', 9, 1),
(119, 'Bin ich bald durch?', 'Schlie\\sze 100 normale Quests ab.', 9, 1),
(120, 'Wie ist das m\\oeglich?', 'Schlie\\sze 250 normale Quests ab.', 9, 18),
(121, 'Alles wie immer!', 'Schlie\\sze 25 t\\aegliche Quests ab.', 9, 1),
(122, 'Nichts ver\\aendert sich!', 'Schlie\\sze 50 t\\aegliche Quests ab.', 9, 1),
(123, 'Gestern, wie morgen!', 'Schlie\\sze 100 t\\aegliche Quests ab.', 9, 1),
(124, 'Langsam wirds langweilig!', 'Schlie\\sze 250 t\\aegliche Quests ab.', 9, 19),
(125, 'Wow, das geht schnell.', 'Schlie\\sze 25 wiederholbare Quests ab.', 9, 1),
(126, 'Alternative zum Job?', 'Schlie\\sze 50 wiederholbare Quests ab.', 9, 1),
(127, 'Lohnt sich!', 'Schlie\\sze 100 wiederholbare Quests ab.', 9, 1),
(128, 'Wirklich!', 'Schlie\\sze 250 wiederholbare Quests ab.', 9, 20),
(129, 'Was f\\uer ein seltsamer Film', 'Schlie\\sze die Questreihe des Regisseurs an den Filmstudios ab!', 9, 1),
(130, 'Trippertum', 'Schlie\\sze die Questreihe des Johnnytums ab.', 9, 1),
(131, 'Bitte l\\aecheln!', 'Werde einmal geblitzt.', 3, 1),
(132, 'Einmal war nicht genug', 'Werde 100 mal geblitzt.', 3, 1),
(133, 'Atemlos durch die Stadt', 'Werde mit \\ueber 180 km/h geblitzt.', 3, 22),
(134, 'Hier findet die keiner!', 'Pflanze eine Drogenpflanze an.', 2, 1),
(135, 'In der Wurzel liegt die K\\uerze', 'Pflanze 1000 Drogenpflanzen an.', 2, 23),
(136, 'Der Start in die Selbstst\\aendigkeit', 'Erwerbe ein Business.', 11, 24),
(137, 'Schau mal was ich hab!', 'Erwerbe ein Prestige.', 11, 1),
(138, 'Die Wirtschaft Ankurbeln', 'Stelle ein Angebot in den Markt.', 11, 1),
(139, 'Grosseinkaeufer', 'Erwerbe 500 Items vom Markt.', 11, 1),
(140, 'Grossverkaeufer', 'Stelle 100 Angebote in den Markt.', 11, 25);
