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
