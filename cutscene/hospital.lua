hospitalScene = {
	name = "Hospital";
	startscene = "Hospital";
	debug = true;
	
	-- Scene 1 
	{
		uid = "Hospital";
		letterbox = true;
		{
			action = "General.fade";
			fadein = false;
			time = 0;
			starttick = 0;
		};
		{
			action = "Camera.set";
			starttick = 0;
			pos = {-2006.5, -71.8, 1050.6};
			lookat = {-2008.5, -73.8, 1050.6};
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
			text = "eXo Krankenhaus";
			scale = 3;
			pos = { 0.5, 0.35 };
		};
	};
}