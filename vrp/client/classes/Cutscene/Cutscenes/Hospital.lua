CutscenePlayer:getSingleton():registerCutscene("Hospital", {
	name = "Hospital";
	startscene = "Hospital";
	debug = true;
	interior = 0;
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
			action = "General.fade";
			fadein = true;
			time = 1000;
			starttick = 500;
		};
		{
			action = "Camera.set";
			starttick = 0;
			pos = {-2024.3822021484, -48.927898406982, 1048.4494628906};
			lookat = {-2023.5892333984,-49.506484985352,1048.2584228516};
		};
		{
			action = "Ped.create";
			starttick = 0;
			id = "patient";
			model = 154;
			pos = {-2016.37683, -50.29544, 1048.36609};
			rot = 180;
		};
		{
			action = "Ped.setAnimation";
			starttick = 0;
			id = "patient";
			animBlock = "beach";
			anim = "bather";
			looped = true;
		};
		{
			action = "Ped.create";
			starttick = 250;
			id = "doc1";
			model = 70;
			pos = {-2008.38098, -67.82353, 1047.64685};
			rot = 0;
		};
		{
			action = "Ped.setAnimation";
			starttick = 300;
			id = "doc1";
			animBlock = "ped";
			anim = "WALK_player";
			looped = true;
		};
		{
			action = "Ped.setAnimation";
			starttick = 8000;
			id = "doc1";
			animBlock = "";
			anim = "";
			looped = true;
		};
		{
			action = "Ped.setControlState";
			starttick = 5000;
			id = "doc1";
			control = "left";
			state = true
		};
		{
			action = "Ped.setControlState";
			starttick = 9500;
			id = "doc1";
			control = "left";
			state = false
		};
		{
			action = "Camera.move";
			pos = {-2011.744140625,-59.730400085449,1049.7779541016};
			lookat = {-2012.1694335938,-58.879188537598,1049.4704589844};
			targetlookat = {-2012.1694335938,-58.879188537598,1049.4704589844};
			starttick = 9500;
			duration = 6000;
		};
		{
			action = "Ped.setControlState";
			starttick = 9600;
			id = "doc1";
			control = "forwards";
			state = true
		};
		{
			action = "Ped.setControlState";
			starttick = 10800;
			id = "doc1";
			control = "forwards";
			state = false
		};
		{
			action = "Ped.setControlState";
			starttick = 11000;
			id = "doc1";
			control = "left";
			state = true
		};
		{
			action = "Ped.setControlState";
			starttick = 11500;
			id = "doc1";
			control = "left";
			state = false
		};
		{
			action = "Ped.setControlState";
			starttick = 11500;
			id = "doc1";
			control = "left";
			state = false
		};
		{
			action = "Ped.setAnimation";
			starttick = 12000;
			id = "doc1";
			animBlock = "ped";
			anim = "IDLE_chat";
			looped = true;
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 2000;
			starttick = 11000;
			text = "Doktor: Guten Tag, sie sehen gut aus!";
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 4000;
			starttick = 13000;
			text = "Doktor: Wir können Sie heute aus dem Krankenhaus entlassen!";
		};
		{
			action = "Graphic.setLetterBoxText";
			duration = 4000;
			starttick = 17000;
			text = "Patient: Wir ja auch endlich Zeit! Auf Wiedersehen!";
		};
		{
			action = "General.finish";
			starttick = 21000;
		};
	};
})
