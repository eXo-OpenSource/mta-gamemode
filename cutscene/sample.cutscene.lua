scene = {
name = "BoatToLS";
startscene = "ViewCoast";
debug = true;
	-- Scene 1 
	{
		uid = "ViewCoast";
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
			time = 10000;
			starttick = 50;
		};
		{
			action = "Camera.set";
			starttick = 0;
			pos = { 2925, -2680, 1 };
			lookat = { 2856, -2605, 7.4 };
		};
		{
			action = "Camera.move";
			starttick = 4000;
			duration = 12000;
			pos = { 2811, -2565, 14 };
			lookat = { 2928, -2676, 0 };
			targetlookat = { 2738, -2585, 1 };
		};
		{
			action = "Vehicle.create";
			starttick = 0;
			id = "boat";
			model = 453;
			pos = { 2928, -2676, 0 };
			rot = { 0, 0, 40 };
		};
		{
			action = "Ped.create";
			starttick = 0;
			id = "boatpilot";
			model = 0;
			pos = { 2928, -2676, 0 };
			rot = { 0, 0, 40 };
		};
		{
			action = "Ped.warpIntoVehicle";
			starttick = 0;
			id = "boatpilot";
			vehicle = "boat";
		};	
		{
			action = "Ped.setControlState";
			starttick = 0;
			id = "boatpilot";
			control = "accelerate";
			state = true;
		};	
		{
			action = "Ped.setControlState";
			starttick = 3000;
			id = "boatpilot";
			control = "vehicle_left";
			state = true;
		};		
		{
			action = "Ped.setControlState";
			starttick = 3500;
			id = "boatpilot";
			control = "vehicle_left";
			state = false;
		};		
		{
			action = "Ped.setControlState";
			starttick = 4000;
			id = "boatpilot";
			control = "vehicle_left";
			state = true;
		};		
		{
			action = "Ped.setControlState";
			starttick = 4500;
			id = "boatpilot";
			control = "vehicle_left";
			state = false;
		};
		{
			action = "Ped.setControlState";
			starttick = 5000;
			id = "boatpilot";
			control = "vehicle_left";
			state = true;
		};		
		{
			action = "Ped.setControlState";
			starttick = 5500;
			id = "boatpilot";
			control = "vehicle_left";
			state = false;
		};
		{
			action = "Ped.setControlState";
			starttick = 6500;
			id = "boatpilot";
			control = "vehicle_left";
			state = true;
		};		
		{
			action = "Ped.setControlState";
			starttick = 7000;
			id = "boatpilot";
			control = "vehicle_left";
			state = false;
		};
		{
			action = "Ped.setControlState";
			starttick = 12000;
			id = "boatpilot";
			control = "accelerate";
			state = false;
		};			
		{
			action = "Ped.setControlState";
			starttick = 12100;
			id = "boatpilot";
			control = "vehicle_left";
			state = true;
		};	
		{
			action = "Ped.setControlState";
			starttick = 15700;
			id = "boatpilot";
			control = "vehicle_left";
			state = false;
		};	

		{
			action = "Vehicle.setEngine";
			starttick = 18000;
			id = "boat";
			state = false;
		};						
	};
}