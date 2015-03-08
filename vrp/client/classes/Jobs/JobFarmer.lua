-- // Client

JobFarmer = inherit(Job)

addEvent("onReciveFarmerData",true)

function JobFarmer:constructor()
	Job.constructor(self, -1059, -1206, 128, "Farmer.png", "files/images/Jobs/HeaderFarmer.png", _"Farmer", _([[
	1.Saat auslegen
	2.Farmen
	3.Abliefern
	]]),self.onInfo)
	
end

function JobFarmer:onInfo()
	setCameraMatrix(-1091.6918945313,-1176.2930908203,130.55819702148,-1092.5964355469,-1176.6628417969,130.34576416016,0,70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Es gibt verschiedene Aufgaben auf der Farm.",255,255,255,true)
	-- ### 1
	setTimer(function()
	setCameraMatrix(-1091.8424072266,-1210.099609375,150.94630432129,-1092.6723632813,-1209.7435302734,150.51698303223,0,70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Eine davon ist es mit dem Traktor die Saat auszulegen.",255,255,255,true)
	end, 3500, 1)
	-- ### 2
	setTimer(function()
	setCameraMatrix(-1052.7027587891,-1232.0666503906,130.13720703125,-1053.5568847656,-1231.6258544922,129.86116027832,0,70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Die Fahrzeuge kannst du dir bei diesem Marker holen.",255,255,255,true)
	end, 7000, 1)
	-- ### 3
	setTimer(function()
	setCameraMatrix(-1071.8698730469,-1220.8608398438,130.6183013916,-1071.9873046875,-1219.8944091797,130.38986206055,0,70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Mit dem Traktor kannst du das Korn ernten und mit dem Wagon",255,255,255,true)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF kannst du das Getreide zur Abgabe bringen.",255,255,255,true)
	end, 12000, 1)	
	--- ### 4
	setTimer(function()
	setCameraMatrix(-1050.2618408203,-1637.7829589844,85.58869934082,-1051.2099609375,-1637.5382080078,85.385673522949,0,70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Diese musste du zu diesem Punkt bringen.",255,255,255,true)
	end, 18000, 1)		
	-- ### LAST
	setTimer(function()
	setCameraTarget(localPlayer,localPlayer)
	end, 21500,1)
end

function JobFarmer:start()
	-- Show text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.Farmer), _(HelpTexts.Jobs.Farmer))
end

function JobFarmer:stop()
	-- Reset text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
end

