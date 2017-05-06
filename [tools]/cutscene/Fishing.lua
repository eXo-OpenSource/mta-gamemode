Fishing = {
	name = "Fishing";
	startscene = "FishingBehavior";
	debug = true;

	-- Scene 1 // Verhalten der Fische
	{
		uid = "FishingBehavior";
		letterbox = true;
		{
			action = "General.fade";
			fadein = false;
			time = 0;
			starttick = 0;
		};
		{
			action = "General.weather";
			time = {12,0};
			farclipdistance = 2000;
			fogdistance = 0;
			clouds = false;
			weather = 0;
			starttick = 0;
		};
		{
			action = "Camera.set";
			starttick = 0;
			pos = {369.29, -2079.87, 8.75};
			lookat = {369.27, -2078.87, 8.66};
		};
		{
			action = "General.fade";
			fadein = true;
			time = 2000;
			starttick = 50;
		};
		{
			action = "Camera.move";
			pos = {369.29, -2079.87, 8.75};
			targetpos = {423.07, -2114.71, 29.37};
			lookat = {369.27, -2078.87, 8.66};
			targetlookat = {422.54, -2113.94, 29.01};
			starttick = 50;
			duration = 10000;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 600;
			duration = 10000;
			text = "Hallo werter Angel Freund, ich bin Lutz und werde dir nun einige Grundlagen zum Angeln erklären!";
		};
		{
			action = "Camera.move";
			pos = {423.07, -2114.71, 29.37};
			lookat = {422.54, -2113.94, 29.01};
			targetpos = {381.55, -1923.77, 16.78};
			targetlookat = {381.78, -1922.87, 16.4};
			starttick = 11000;
			duration = 9000;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 11000;
			duration = 9000;
			text = "Bevor du loslegen kannst, benötigst du eine Angel und etwas, wo du deinen Fang aufbewahren kannst.\nDas bekommst du alles im Angelshop, der hier in der Nähe ist.";
		};
		{
			action = "Camera.move";
			pos = {381.55, -1923.77, 16.78};
			lookat = {381.78, -1922.87, 16.4};
			targetpos = {349.56, -1880.07, 35.34};
			targetlookat = {350.34, -1880.09, 34.71};
			starttick = 20000;
			duration = 12500;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 20000;
			duration = 12500;
			text = "Einige Dinge wirst du erst kaufen können, wenn du genug Erfahrung gesammelt hast.\nDie Angel und eine kleine Kühltasche ist für den Anfang erst mal ausreichend!";
		};
		{
			action = "General.fade";
			fadein = false;
			time = 2000;
			starttick = 30900;
		};
		{
			action = "General.fade";
			fadein = true;
			time = 2000;
			starttick = 33000;
		};
		{
			action = "Camera.moveCircle";
			pos = {349.56, -1880.07, 65};
			lookat = {349.56, -1880.07, 16};
			distance = 180;
			startangle = -45;
			targetangle = 45;
			starttick = 33000;
			duration = 12000;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 33000;
			duration = 3000;
			text = "Es ist nicht egal wo du Angeln gehst!";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 36000;
			duration = 6000;
			text = "Es wird unterschieden zwischen\nMeer (bzw. Ozean) ...";
		};
		{
			action = "General.fade";
			fadein = false;
			time = 2000;
			starttick = 43000;
		};
		{
			action = "Camera.move";
			pos = {797.87, -199.15, 18.20};
			lookat = {699.65, -217.85, 16.63};
			targetpos = {417.01, -271.68, 12.11};
			targetlookat = {318.79, -290.38, 10.54};
			starttick = 45000;
			duration = 6000;
		};
		{
			action = "General.fade";
			fadein = true;
			time = 2000;
			starttick = 45000;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 46000;
			duration = 4000;
			text = "\n... Flüssen ...";
		};
		{
			action = "General.fade";
			fadein = false;
			time = 1000;
			starttick = 50000;
		};
		{
			action = "Camera.move";
			pos = {1785.92, -227.61, 95.31};
			lookat = {1875.96, -202.95, 59.48};
			targetpos = {2101.35, -111.37, 2.69};
			targetlookat = {2146.33, -23.09, -10.87};
			starttick = 51000;
			duration = 15000;
		};
		{
			action = "General.fade";
			fadein = true;
			time = 2000;
			starttick = 51000;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 51000;
			duration = 4000;
			text = "\n... und Seen.";
		};

		{
			action = "Graphic.setLetterBoxText";
			starttick = 56000;
			duration = 5000;
			text = "Die meisten Fische sind unabhängig vom Wetter.\nJedoch gibt es Fische die sich nur fangen lassen, wenn es trocken ist ...";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 61000;
			duration = 8000;
			text = "... oder wenn es regnet.";
		};
		{
			action = "General.weather";
			time = {12,0};
			farclipdistance = 2000;
			fogdistance = 0;
			clouds = false;
			weather = 8;
			starttick = 61000;
		};
		{
			action = "General.fade";
			fadein = false;
			time = 2000;
			starttick = 69000;
		};
		{
			action = "General.weather";
			time = {12,0};
			farclipdistance = 2000;
			fogdistance = 0;
			clouds = false;
			weather = 0;
			starttick = 70000;
		};
		{
			action = "General.fade";
			fadein = true;
			time = 2000;
			starttick = 71000;
		};
		{
			action = "Camera.moveCircle";
			pos = {1601.64, -1365.74, 133.46};
			lookat = {1601.64, -1365.74, 133.46};
			distance = 400;
			startangle = 135;
			targetangle = 90;
			starttick = 71000;
			duration = 21000;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 71000;
			duration = 5000;
			text = "Was?! Du kannst nicht rund um die Uhr angeln gehen?\nDann wars das wohl mit dem Profi Angler!";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 76000;
			duration = 5000;
			text = "Auch Fische gehen schlafen. Wann? Das entscheiden sie selbst.\n Einige lassen sich nur am Tag fangen ...";
		};
		{
			action = "General.weather";
			time = {0,0};
			farclipdistance = 2000;
			fogdistance = 0;
			clouds = false;
			weather = 0;
			starttick = 81000;
		};
		{
			action = "General.fade";
			fadein = false;
			time = 200;
			starttick = 80800;
		};
		{
			action = "General.fade";
			fadein = true;
			time = 200;
			starttick = 81000;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 81000;
			duration = 4000;
			text = "... einige nur nachts ...";
		};
		{
			action = "General.fade";
			fadein = false;
			time = 200;
			starttick = 84800;
		};
		{
			action = "General.fade";
			fadein = true;
			time = 200;
			starttick = 85000;
		};
		{
			action = "General.weather";
			time = {6,0};
			farclipdistance = 2000;
			fogdistance = 0;
			clouds = false;
			weather = 0;
			starttick = 85000;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 85000;
			duration = 5000;
			text = "... oder ganz früh am Morgen!";
		};
		{
			action = "General.fade";
			fadein = false;
			time = 2000;
			starttick = 90000;
		};
		{
			action = "General.finish";
			starttick = 92000;
		};
	};

	-- Scene 2 // Fangen von Fische
	{
		uid = "FishingCatch";
		letterbox = true;
		{
			action = "General.fade";
			fadein = false;
			time = 0;
			starttick = 0;
		};
		{
			action = "General.fade";
			fadein = true;
			time = 2000;
			starttick = 50;
		};
		{
			action = "General.weather";
			time = {12,0};
			farclipdistance = 2000;
			fogdistance = 0;
			clouds = false;
			weather = 0;
			starttick = 0;
		};
		{
			action = "Camera.moveCircle";
			pos = {389.9, -2028.44, 40};
			lookat = {389.9, -2028.44, 22};
			distance = 200;
			startangle = 45;
			targetangle = 180;
			starttick = 50;
			duration = 60000;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 50;
			duration = 4000;
			text = "Nun gut, dass Verhalten der Fische sollte nun geklärt sein.";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 4050;
			duration = 5950;
			text = "Jetzt musst du noch lernen, wie man mit der Angel umgeht.";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 10000;
			duration = 10000;
			text = "Nachdem du dir eine Angel gekauft hast, kannst du diese im Inventar ausrüsten.\nDrücke dafür einfach 'i' und klicke mit der Maus auf die Angel.";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 20000;
			duration = 5000;
			text = "Vergiss die Kühltasche nicht, um deine Fische aufzubewahren!";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 25000;
			duration = 5000;
			text = "Alles dabei? Perfekt. Jetzt schnell zum Wasser und die Angel auswerfen!";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 30000;
			duration = 10000;
			text = "Halte zum auswerfen die linke Maustaste gedrückt. Du siehst einen Indikator.\nVersuche die Angel möglichst perfekt auszuwerfen!";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 40000;
			duration = 5000;
			text = "Landet der Schwimmer im Wasser, heißt es warten ...";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 45000;
			duration = 3500;
			text = "... und warten ...";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 48500;
			duration = 3500;
			text = "... bis ein Fisch anbeißt!";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 52000;
			duration = 8000;
			text = "Du hast was gehört? Oder vielleicht etwas im Wasser gesehen? Perfekt!\n Drücke die linke Maustaste um die Angel einzuziehen.";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 60000;
			duration = 5000;
			text = "Solltest du zu langsam sein, entkommt der Fisch.";
		};
		{
			action = "General.fade";
			fadein = false;
			time = 1000;
			starttick = 59000;
		};
		{
			action = "Camera.move";
			pos = {1138.92, -69.45, 33.23};
			lookat = {1042.29, -94.52, 27.4};
			targetpos = {862.45, -141.19, 16.54};
			targetlookat = {765.82, -166.27, 10.71};
			starttick = 60000;
			duration = 60000;
		};
		{
			action = "General.fade";
			fadein = true;
			time = 1000;
			starttick = 60000;
		};
		{
			action = "Graphic.drawImage";
			path = "tour_bobberbar_info.png";
			pos = {0.7, 0.2};
			size = {0.17, 0.62};
			starttick = 65000;
			duration = 17500;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 65000;
			duration = 10000;
			text = "Auch hier zeigt jeder Fisch sein eigenes Verhalten.\nBalanciere den grünen Balken wie auf dem Bild zu sehen auf Höhe des Fisches.";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 75000;
			duration = 7500;
			text = "Zum Balancieren klicke mehrfach und schnell mit der linken Maustaste.\nIst der rechte balken komplett gefüllt, hast du den Fisch gefangen!";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 82500;
			duration = 6500;
			text = "Mit jedem Fang steigt deine Erfahrung.\n Dein Fischer Level und Fortschritt ist unter F2 -> Punkte sichtbar.";
		};
		{
			action = "General.fade";
			fadein = false;
			time = 2000;
			starttick = 88000;
		};
		{
			action = "General.finish";
			starttick = 90000;
		};
	};

	-- Scene 3 // Handeln mit Fischen
	{
		uid = "FishingTrading";
		letterbox = true;
	};
}
