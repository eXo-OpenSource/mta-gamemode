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
	}
}