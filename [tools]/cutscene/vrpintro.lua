introScene = {
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
			pos = {0.4, 0.35};
			size = {0.2, 0.34};
			starttick = 0;
			duration = 19000;
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 5000;
			starttick = 4000;
			text = "Bevor es losgehen kann ein paar Worte zum Spielkonzept.";
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
			action = "Vehicle.create";
			starttick = 19000;
			id = "hotwirevehicle";
			model = 411;
			pos = {1436.9, -1736.7, 12.95};
			rot = {0, 0, 270};
		};
		{
			action = "Ped.create";
			starttick = 19000;
			id = "hotwireped";
			model = 107;
			pos = {1437, -1735.5, 13.4};
			rot = 180;
		};
		{
			action = "Ped.setAnimation";
			starttick = 19500;
			id = "hotwireped";
			animBlock = "BOMBER";
			anim = "BOM_Plant";
			looped = false;
		};
		{
			action = "Camera.set";
			starttick = 19000;
			pos = {1444.7, -1732.4, 15};
			lookat = {1436.9, -1736.7, 12.95};
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 4000;
			starttick = 19000;
			text = "Entscheide dich für die böse Seite und starte als Kleinkrimineller";
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 4000;
			starttick = 23000;
			text = "Je mehr Taten du vollbringst, desto mehr Möglichkeiten hast du";
		};
		{
			action = "Camera.move";
			pos = {1444.7, -1732.4, 15};
			lookat = {1436.9, -1736.7, 12.95};
			targetlookat = {1437.6, -1723, 14};
			starttick = 27000;
			duration = 4000;
		};
		{
			action = "Ped.create";
			id = "dealingpad1";
			model = 108;
			rot = 307;
			starttick = 27000;
			pos = {1439.3, -1726.3, 13.6};
		};
		{
			action = "Ped.setAnimation";
			starttick = 27000;
			id = "dealingpad1";
			animBlock = "DEALER";
			anim = "DEALER_IDLE_01";
			looped = true;
		};
		{
			action = "Ped.create";
			id = "dealingpad2";
			model = 125;
			rot = 127;
			starttick = 27000;
			pos = {1440, -1725.5, 13.6};
		};
		{
			action = "Ped.setAnimation";
			starttick = 27000;
			id = "dealingpad2";
			animBlock = "DEALER";
			anim = "DEALER_IDLE_02";
			looped = true;
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 5000;
			starttick = 27000;
			text = "Werde Drogenboss, kontrolliere die Stadt und halte die Polizei auf Trab";
		};
		{
			action = "Camera.move";
			pos = {1444.7, -1732.4, 15};
			lookat = {1437.6, -1723, 14};
			targetlookat = {1478.8, -1732.3, 13.4};
			starttick = 32000;
			duration = 6000;
		};
		{
			action = "Ped.create";
			id = "policedriver";
			model = 280;
			rot = 0;
			starttick = 31000;
			pos = {1440, -1725.5, 13.6};
		};
		{
			action = "Vehicle.create";
			starttick = 31000;
			id = "policecar";
			model = 596;
			pos = {1512.5, -1730.4, 13};
			rot = {0, 0, 90};
		};
		{
			action = "Ped.warpIntoVehicle";
			starttick = 31000;
			id = "policedriver";
			vehicle = "policecar";
		};
		{
			action = "Ped.setControlState";
			starttick = 34000;
			id = "policedriver";
			control = "accelerate";
			state = true;
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 5000;
			starttick = 33000;
			text = "...oder starte als Verkehrspolizist und sorge für Frieden auf den Straßen";
		};
		{
			action = "Vehicle.create";
			starttick = 38000;
			id = "rhino";
			model = 432;
			pos = {1823.7, -1751.4, 13.3};
		};
		{
			action = "Ped.warpIntoVehicle";
			starttick = 40000;
			id = "policedriver";
			vehicle = "rhino";
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 5000;
			starttick = 40000;
			text = "und gehörige irgendwann zur Elite";
		};
		{
			action = "Camera.move";
			--pos = {1478.8, -1732.3, 13.4};
			--lookat = {1798.5, -1732.5, 15};
			targetpos = {1798.5, -1732.5, 15};
			targetlookat = {1821.5, -1732.1, 15};
			starttick = 39000;
			duration = 2000;
		};
		{
			action = "Ped.setControlState";
			starttick = 43000;
			id = "policedriver";
			control = "accelerate";
			state = false;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 45000;
			duration = 5000;
			text = "Doch zuerst solltest du etwas Kleingeld sammeln";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 45000;
			duration = 5000;
			text = "Doch zuerst solltest du etwas Kleingeld sammeln";
		};
	};
}
