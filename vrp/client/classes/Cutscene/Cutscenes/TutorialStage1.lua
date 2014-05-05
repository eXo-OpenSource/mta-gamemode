CutscenePlayer:getSingleton():registerCutscene("Tutorial.Stage1", {
name = "Tutorial.Stage1";
startscene = "ViewFront";
debug = true;
	-- Scene 1 
	{
		uid = "ViewFront";
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
			time = 2000;
			starttick = 50;
		};
		{
			action = "Camera.moveCircle";
			starttick = 0;
			duration = 1000;
			startangle = -60;
			targetangle = 90;
			distance = 4;
			pos = { 2244.3603515625, -1665.5961914063, 16.275800704956 };
			lookat = "player";
		};	
		{
			action = "General.finish";
			starttick = 1250;
		};
	};
})