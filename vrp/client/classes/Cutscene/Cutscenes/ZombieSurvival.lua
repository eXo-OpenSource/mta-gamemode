CutscenePlayer:getSingleton():registerCutscene("ZombieSurvivalCutscene", {
	name = "Intro";
	startscene = "init_Scene";
	debug = true;

	-- Init Scene
	{
		uid = "init_Scene";
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
			fogdistance = 10;
			clouds = true;
			weather = 8;
			starttick = 0;
		};
		{
			action = "Object.create";
			id = "object_1";
			model = 3863;
			pos = {-32.4, 1377.8, 9.3};
			rot = 274;
			starttick = 0;
		};
		{
			action = "Ped.create";
			id = "guy_1";
			model = 162;
			pos = {-31.64, 1377.67, 9.17};
			rot = 90;
			starttick = 0;
		};
		{
			action = "Ped.create";
			id = "localPlayer";
			model = 1;
			pos = {-45.905, 1376.090, 10.208};
			rot = -85;
			starttick = 0;
		};
		{
			action = "Camera.set";
			starttick = 0;
			pos = {-41.4, 1366.4, 11.2};
			lookat = {-41.2, 1367.3, 11.1};
			fov = 70;
		};
		{
			action = "General.change_scene";
			scene = "1_Scene";
			starttick = 250;
		};
	};

	-- Scene 1
	{
		uid = "1_Scene";
		letterbox = true;
		{
			action = "General.fade";
			fadein = true;
			time = 1000;
			starttick = 0;
		};
		{
			action = "Ped.setAnimation";
			starttick = 0;
			id = "guy_1";
			animBlock = "SMOKING";
			anim = "M_smklean_loop";
			looped = false;
		};
		{
			action = "Ped.setAnimation";
			starttick = 1750;
			id = "guy_1";
			animBlock = "ped";
			anim = "IDLE_chat";
			looped = true;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 1750;
			duration = 3000;
			text = "Stranger: Hello my Friend. Komm mal her!";
		};
		{
			action = "Ped.setAnimation";
			starttick = 4750;
			id = "guy_1";
			animBlock = nil;
			anim = nil;
		};
		{
			action = "Ped.setPedControlState";
			starttick = 4250;
			id = "localPlayer";
			control = "forwards";
			state = true
		};
		{
			action = "Ped.setPedControlState";
			starttick = 6450;
			id = "localPlayer";
			control = "forwards";
			state = false
		};
		{
			action = "Ped.setAnimation";
			starttick = 6500;
			id = "localPlayer";
			animBlock = "ped";
			anim = "IDLE_chat";
			looped = true;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 6500;
			duration = 3000;
			text = "You: Wer sind Sie? Was wollen Sie von mir?";
		};
		{
			action = "Ped.setAnimation";
			starttick = 9500;
			id = "localPlayer";
			animBlock = nil;
			anim = nil;
		};
		{
			action = "Ped.setAnimation";
			starttick = 10000;
			id = "guy_1";
			animBlock = "ped";
			anim = "IDLE_chat";
			looped = true;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 10000;
			duration = 3000;
			text = "Stranger: Ich will dir was anbieten, hast du interesse an bisschen Spaß?";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 13000;
			duration = 3000;
			text = "Stranger: Ich habe das was besonderes aus meinem Garten, nennt sich \"Orange Haze\"";
		};
		{
			action = "Ped.setAnimation";
			starttick = 16000;
			id = "guy_1";
			animBlock = nil;
			anim = nil;
		};
		{
			action = "Ped.setAnimation";
			starttick = 16000;
			id = "localPlayer";
			animBlock = "ped";
			anim = "IDLE_chat";
			looped = true;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 16000;
			duration = 3000;
			text = "You: Hab ich noch nie gehört und Ich bin eigentlich nicht interessiert an Drogen!";
		};
		{
			action = "Ped.setAnimation";
			starttick = 19000;
			id = "localPlayer";
			animBlock = nil;
			anim = nil;
		};
		{
			action = "Ped.setAnimation";
			starttick = 19000;
			id = "guy_1";
			animBlock = "DEALER";
			anim = "DEALER_DEAL";
			looped = false;
		};
		{
			action = "Ped.setAnimation";
			starttick = 22000;
			id = "guy_1";
			animBlock = "ped";
			anim = "IDLE_chat";
			looped = true;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 22000;
			duration = 5000;
			text = "Stranger: Eigentlich? Siehst du Ich hab dir was hingelegt, der erste Joint ist sogar kostenlos!";
		};
		{
			action = "Ped.setAnimation";
			starttick = 27000;
			id = "guy_1";
			animBlock = nil;
			anim = nil;
		};
		{
			action = "Ped.setAnimation";
			starttick = 27000;
			id = "localPlayer";
			animBlock = "SHOP";
			anim = "Smoke_RYD";
			looped = false;
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 27000;
			duration = 2000;
			text = "You: Na gut! Probieren kann man es ja mal.";
		};
		{
			action = "Graphic.setLetterBoxText";
			starttick = 29000;
			duration = 1000;
			text = "Stranger: Viel Spaß! Und pass auf die Zomb...";
		};
		{
			action = "General.fade";
			fadein = false;
			starttick = 29000;
			time = 1500;
		};
		{
			action = "General.finish";
			starttick = 30500;
		}
	};

})
