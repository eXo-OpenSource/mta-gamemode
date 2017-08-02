-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobFarmer.lua
-- *  PURPOSE:     Farmer job
-- *
-- ****************************************************************************
JobFarmer = inherit(Job)
addRemoteEvents{"Job.updateFarmPlants", "Job.updatePlayerPlants", "onReciveFarmerData", "Job.updateIncome"}

function JobFarmer:constructor()
	Job.constructor(self, 1, -62.62, 76.34, 3.12, 250, "Farmer.png", {117, 93, 65}, "files/images/Jobs/HeaderFarmer.png", _(HelpTextTitles.Jobs.Farmer):gsub("Job: ", ""), _(HelpTexts.Jobs.Farmer), self.onInfo)
	self:setJobLevel(JOB_LEVEL_FARMER)
	-- add job to help menu
	HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.Farmer):gsub("Job: ", ""), "jobs.farmer")
end
function JobFarmer:onInfo()
	if localPlayer.vehicle then
		ErrorBox:new(_"Bitte erst aus dem Fahrzeug aussteigen!")
		return
	end

	setCameraMatrix(-1.8428000211716, 135.26879882813, 35.644901275635, -2.3047368526459, 134.49794006348, 35.206272125244, 0, 70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Es gibt verschiedene Aufgaben auf der Farm.",255,255,255,true)
	-- ### 1
	setTimer(function()
	setCameraMatrix(-98.922798156738, 65.984901428223, 44.70890045166, -99.658416748047, 65.534629821777, 44.202819824219, 0, 70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Eine davon ist es mit dem Traktor die Saat auszulegen.",255,255,255,true)
	end, 3500, 1)
	-- ### 2
	setTimer(function()
	setCameraMatrix(-110.18440246582, 59.231700897217, 25.98390007019, -109.43939208984, 59.41569519043, 25.342723846436, 0, 70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Fahrzeuge kannst du hier (Marker sichtbar nach dem annehmen) abholen.",255,255,255,true)
	end, 7000, 1)
	-- ### 3
	setTimer(function()
	setCameraMatrix(-44.745899200439, 84.956596374512, 24.216800689697, -44.504783630371, 84.290466308594, 23.511016845703, 0, 70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Mit dem Mähdrescher kannst du das Korn ernten und mit dem Walton",255,255,255,true)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF kannst du das Getreide zur Abgabe bringen.",255,255,255,true)
	end, 12000, 1)
	--- ### 4

	setTimer(function()
	setCameraMatrix( -2132.4262695313 , -2465.71875 , 56.393901824951 , -2132.8205566406 , -2465.2470703125 , 55.605262756348 , 0 , 70 )
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Bringe das Getreide zu diesem Punkt!",255,255,255,true)
	end, 18000, 1)
	-- ### LAST
	setTimer(function()
	setCameraTarget(localPlayer,localPlayer)
	localPlayer:setPosition(-59.908, 76.689,3.117)
	end, 21500,1)
end


function JobFarmer:start()
	-- Show text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.Farmer), _(HelpTexts.Jobs.Farmer), true, self.onInfo)

	-- Create info display
	self.m_FarmerImage = GUIImage:new(screenWidth/2-200/2, 10, 200, 50, "files/images/Jobs/Farmerdisplay.png")
	self.m_FarmLabel = GUILabel:new(55, 4, 55, 40, "0", self.m_FarmerImage):setFont(VRPFont(40))
	self.m_TruckLabel = GUILabel:new(150, 4, 50, 40, "0", self.m_FarmerImage):setFont(VRPFont(40))
	self.m_FarmerRectangle = GUIRectangle:new(screenWidth/2-200/2, 60, 200, 40, rgb(3, 17, 39))
	self.m_EarnLabel = GUILabel:new(10, 5, 180, 17, _"Einkommen bisher: 0$", self.m_FarmerRectangle):setFont(VRPFont(20))
	self.m_EarnInfoLabel = GUILabel:new(10, 25, 180, 15, "Steig aus um das Geld zu erhalten!", self.m_FarmerRectangle):setFont(VRPFont(15))

	-- Register update events
	addEventHandler("Job.updateFarmPlants", root, function (num)
		self.m_FarmLabel:setText(tostring(num))
	end)
	addEventHandler("Job.updatePlayerPlants", root, function (num)
		self.m_TruckLabel:setText(tostring(num))
	end)
	addEventHandler("Job.updateIncome", root, function (num)
		self.m_EarnLabel:setText(_("Einkommen bisher: %d$", num))
	end)
end

function JobFarmer:stop()
	-- Reset text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)

	-- delete infopanels
	delete(self.m_FarmerImage)
	delete(self.m_FarmerRectangle)
end
