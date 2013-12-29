-- This needs to be updated with a proper intro
CutscenePlayer:getSingleton():registerCutscene("Intro", {
name = "Intro";
startscene = "Intro";
debug = true;
	-- Scene 1 
	{
		uid = "Intro";
		letterbox = false;
		{
			action = "General.fade";
			fadein = false;
			time = 0;
			starttick = 0;
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
			duration = 20000;
			text = "V Roleplay";
			starttick = 0;
			scale = 5;
			pos = { 0.5, 0.3 };
		};
		{
			action = "Graphic.drawText";
			color = tocolor(255, 255, 255);
			duration = 20000;
			starttick = 0;
			text = "Hier kommt noch ein längeres Intro";
			scale = 2;
			pos = { 0.5, 0.5 };
		};
		{ 
			action = "Camera.set";
			starttick = 0;
			pos = { 1441, -1410, 80 };
			lookat = { 1440, -1410, 80 };
		};
		{
			action = "General.finish";
			starttick = 20000;
		}
	};
})