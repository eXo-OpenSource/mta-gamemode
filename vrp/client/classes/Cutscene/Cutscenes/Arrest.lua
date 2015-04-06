CutscenePlayer:getSingleton():registerCutscene("Arrest", {
	name = "Arrest";
	startscene = "Arrest1";
	debug = true;
	interior = 1;

	{
		uid = "Arrest1";
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
			time = 1000;
			starttick = 500;
		};
		{
			action = "Ped.create";
			starttick = 500;
			id = "police1";
			model = 280;
			pos = {2780.5, -2970.4, 45};
			rot = 180;
		};
		{
			action = "Ped.create";
			starttick = 500;
			id = "police2";
			model = 281;
			pos = {2778.5, -2970.4, 45};
			rot = 180;
		};
		{
			action = "Ped.create";
			starttick = 500;
			id = "localplayer";
			model = 107;
			pos = {2779.5, -2970.4, 45};
			rot = 180;
		};
		{
			action = "Ped.setAnimation";
			starttick = 700;
			id = "localplayer";
			animBlock = "ped";
			anim = "WALK_player";
			looped = true;
		}; -- cower
		{
			action = "Ped.setAnimation";
			starttick = 700;
			id = "police1";
			animBlock = "ped";
			anim = "WALK_player";
			looped = true;
		};
		{
			action = "Ped.setAnimation";
			starttick = 700;
			id = "police2";
			animBlock = "ped";
			anim = "WALK_player";
			looped = true;
		};
		{
			action = "Camera.set";
			starttick = 0;
			pos = {2781.1, -2989.9, 46.6};
			lookat = {2761.5, -2893.3, 29.5};
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 2000;
			starttick = 0;
			text = "Du wurdest verhaftet und wirst jetzt einem Richter vorgeführt,";
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 2000;
			starttick = 2000;
			text = "der gleich dein Urteil spricht";
		};
		{
			action = "General.fade";
			fadein = false;
			time = 500;
			starttick = 4000;
		};
		{
			action = "General.change_scene";
			starttick = 4500;
			scene = "Arrest2";
		}
	};
	{
		uid = "Arrest2";
		{
			action = "General.fade";
			fadein = true;
			time = 1000;
			starttick = 1000;
		};
		{
			action = "Ped.create";
			starttick = 0;
			id = "localplayer";
			model = 107;
			pos = {2778.6, -2992.2, 44.9};
			rot = 180;
		};
		{
			action = "Ped.setAnimation";
			starttick = 200;
			id = "localplayer";
			animBlock = "ped";
			anim = "SEAT_idle";
			looped = false;
		};
		{
			action = "Ped.create";
			starttick = 0;
			id = "judge";
			model = 17;
			pos = {2779.2, -2998.6, 44.9};
			rot = 0;
		};
		{
			action = "Camera.set";
			starttick = 500;
			pos = {2781.1, -2989.9, 47.5};
			--lookat = {2781.1, -2989.9, 47.6};
			lookat = {2750, -3081, 10};
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 4000;
			starttick = 0;
			text = "Du wurdest zu einer Haftstrafe verurteilt!";
		};
		{
			action = "General.finish";
			starttick = 4000;
		};
	};
})
