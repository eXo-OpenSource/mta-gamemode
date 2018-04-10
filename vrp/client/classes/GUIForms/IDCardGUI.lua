-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/IDCardGUI.lua
-- *  PURPOSE:     ID-Card GUI
-- *
-- ****************************************************************************
IDCardGUI = inherit(GUIForm)
inherit(Singleton, IDCardGUI)

addRemoteEvents{"showIDCard"}

function IDCardGUI:constructor(player)

	if not player then player = localPlayer end

	GUIForm.constructor(self, screenWidth/2-400/2, screenHeight/2-320/2, 400, 320)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Ausweis", true, true, self)

	GUILabel:new(10, 40, 140, 30, player:getName(), self)
	GUIWebView:new(10, 70, 140, 160, INGAME_WEB_PATH .. "/ingame/skinPreview/skinPreviewHead.php?skin="..player:getModel(), true, self)

	GUILabel:new(10, 205, 140, 25, _"Levels", self)
	GUILabel:new(10, 230, 140, 20, _"Job:", self)
	GUILabel:new(10, 250, 140, 20, _"Waffen:", self)
	GUILabel:new(10, 270, 140, 20, _"Fahrzeug:", self)
	GUILabel:new(10, 290, 140, 20, _"Skin:", self)

	self.m_LevelLabels = {}
	self.m_LevelLabels["job"] = GUILabel:new(140, 230, 40, 20, "0", self)
	self.m_LevelLabels["weapon"] = GUILabel:new(140, 250, 40, 20, "0", self)
	self.m_LevelLabels["vehicle"] = GUILabel:new(140, 270, 40, 20, "0", self)
	self.m_LevelLabels["skin"] = GUILabel:new(140, 290, 40, 20, "0", self)

	GUILabel:new(200, 43, 140, 25, _"Lizenzen", self)
	GUILabel:new(200, 68, 140, 20, _"Auto:", self)
	GUILabel:new(200, 88, 140, 20, _"Motorrad:", self)
	GUILabel:new(200, 108, 140, 20, _"Lastkraftwagen:", self)
	GUILabel:new(200, 128, 140, 20, _"Pilot:", self)

	self.m_LicenseLabels = {}
	self.m_LicenseLabels["car"] = GUILabel:new(370, 68, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_LicenseLabels["bike"] = GUILabel:new(370, 88, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_LicenseLabels["truck"] = GUILabel:new(370, 108, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_LicenseLabels["pilot"] = GUILabel:new(370, 128, 40, 25, FontAwesomeSymbols.Square, self)

	for index, label in pairs(self.m_LicenseLabels) do
		label:setFont(FontAwesome(20))
		label:setColor(Color.Red)
	end

	GUILabel:new(200, 153, 140, 25, _"STVO", self)
	GUILabel:new(200, 178, 140, 20, _"Auto:", self)
	GUILabel:new(200, 198, 140, 20, _"Motorrad:", self)
	GUILabel:new(200, 218, 140, 20, _"Lastkraftwagen:", self)
	GUILabel:new(200, 238, 140, 20, _"Pilot:", self)

	self.m_STVODriving = GUILabel:new(320, 178, 60, 20, "0", self):setAlignX("right")
	self.m_STVOBike = GUILabel:new(320, 198, 60, 20, "0", self):setAlignX("right")
	self.m_STVOTruck = GUILabel:new(320, 218, 60, 20, "0", self):setAlignX("right")
	self.m_STVOPilot = GUILabel:new(320, 238, 60, 20, "0", self):setAlignX("right")

	GUILabel:new(200, 263, 140, 25, _"Wanteds:", self)
	self.m_Wanteds = GUILabel:new(320, 263, 60, 20, "0", self):setAlignX("right")

	triggerServerEvent("Event_getIDCardData", localPlayer, player)

	addRemoteEvents{"Event_receiveIDCardData"}
	addEventHandler("Event_receiveIDCardData", root, bind(self.Event_receiveIDCardData, self))
end

function IDCardGUI:Event_receiveIDCardData(car, bike, truck, pilot, jobLevel, weaponLevel, vehicleLevel, skinLevel, wantedLevel, stvoLevels)
	local carSymbol, carColor = self:getSymbol(car)
	self.m_LicenseLabels["car"]:setText(carSymbol)
	self.m_LicenseLabels["car"]:setColor(carColor)
	local bikeSymbol, bikeColor = self:getSymbol(bike)
	self.m_LicenseLabels["bike"]:setText(bikeSymbol)
	self.m_LicenseLabels["bike"]:setColor(bikeColor)
	local truckSymbol, truckColor = self:getSymbol(truck)
	self.m_LicenseLabels["truck"]:setText(truckSymbol)
	self.m_LicenseLabels["truck"]:setColor(truckColor)
	local pilotSymbol, pilotColor = self:getSymbol(pilot)
	self.m_LicenseLabels["pilot"]:setText(pilotSymbol)
	self.m_LicenseLabels["pilot"]:setColor(pilotColor)

	self.m_LevelLabels["job"]:setText(tostring(jobLevel))
	self.m_LevelLabels["weapon"]:setText(tostring(weaponLevel))
	self.m_LevelLabels["vehicle"]:setText(tostring(vehicleLevel))
	self.m_LevelLabels["skin"]:setText(tostring(skinLevel))

	self.m_Wanteds:setText(tostring(wantedLevel))

	self.m_STVODriving:setText(stvoLevels["Driving"])
	self.m_STVOBike:setText(stvoLevels["Bike"])
	self.m_STVOTruck:setText(stvoLevels["Truck"])
	self.m_STVOPilot:setText(stvoLevels["Pilot"])
end

function IDCardGUI:getSymbol(bool)
	if bool == true then
		return FontAwesomeSymbols.CheckSquare, Color.Green
	else
		return FontAwesomeSymbols.Square, Color.Red
	end
end

addEventHandler("showIDCard", root, function(target)
	IDCardGUI:new(target)
end)
