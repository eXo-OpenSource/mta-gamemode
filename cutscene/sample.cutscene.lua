scene = {
name = "sample cutscene";
startscene = "myfirstscene";
	-- Scene 1 
	{
		uid = "myfirstscene";
		letterbox = true;
		
		-- 
		{
			type = "Camera";
			action = "set";
			starttick = 1000;
			pos = { 0, 0, 5 };
			lookat = { 0, 0, 0 };
		};

		{
			type = "Camera";
			action = "set";
			starttick = 2000;
			pos = { 0, 0, 10 };
			lookat = { 0, 0, 0 };
		};
		
		{
			type = "Camera";
			action = "move";
			starttick = 3000;
			duration = 5000;
			pos = { 0, 0, 10 };
			targetpos = { 0, 0, 20 };
			lookat = { 0, 5, 0 };
			targetlookat = { 0, 10, 0 };
		};
	}
}